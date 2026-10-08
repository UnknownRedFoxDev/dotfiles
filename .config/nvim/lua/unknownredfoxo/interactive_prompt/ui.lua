local Prompt = require("unknownredfoxo.interactive_prompt.prompt")
local Completion = require("unknownredfoxo.interactive_prompt.completion")
local M = {}
local candidates_provider

vim.api.nvim_set_hl(0, "InteractivePromptCursor", { default = true, reverse = true })

function M.open(opts)
    opts = opts or {}
    local prefer_candidate = opts.prefer_candidate or false
    local default_input = opts.default_input or ""
    local show_no_matches = opts.show_no_matches or false

    if type(opts.candidates) == "function" then
        candidates_provider = opts.candidates
    else
        local static_list = opts.candidates or {}
        candidates_provider = function() return static_list end
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = vim.o.lines - 4,
        col = 2,
        width = vim.o.columns - 4,
        height = 1,
        style = "minimal",
        border = "rounded",
    })

    io.stdout:write("\27[?25l")

    local ns_id = vim.api.nvim_create_namespace("emacs_prompt_ui")
    local got_cleaned = false
    local og_timeout = vim.o.timeout
    local og_timeoutlen = vim.o.timeoutlen
    local label = opts.prompt or "Select: "

    vim.o.timeout = false

    local function close_ui()
        if got_cleaned then return end
        got_cleaned = true
        io.stdout:write("\27[?25h")
        vim.o.timeout = og_timeout
        vim.o.timeoutlen = og_timeoutlen
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local prompt = Prompt.new({
        on_change = function() end,
    })

    if opts.history then
        prompt:set_history(opts.history)
    end


    local current_matches = candidates_provider(default_input)
    prompt:set_input(default_input)

    local function update(text)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    end

    local function get_display(cand)
        if not cand then return "" end
        return type(cand) == "table" and cand.display or cand
    end

    local function get_value(cand)
        if not cand then return "" end
        return type(cand) == "table" and cand.value or cand
    end

    local function render(override_matches)
        local input = prompt:get_input()
        local cursor_pos = prompt:get_cursor()

        if override_matches then
            current_matches = override_matches
        else
            local candidates = candidates_provider(input)
            current_matches = Completion.filter(input, candidates)
        end

        local max_visible = 5
        local completion_str = ""

        if #current_matches > 1 then
            local display_cand = {}
            local visible_limit = math.min(#current_matches, max_visible)
            for i = 2, visible_limit do
                table.insert(display_cand, get_display(current_matches[i]))
            end
            local available_cand = table.concat(display_cand, " | ")
            local extra_fluff = #current_matches > max_visible and " | ..." or ""

            completion_str = string.format("{%s | %s%s}", get_display(current_matches[1]), available_cand, extra_fluff)

        elseif #current_matches == 1 then
            local matched = get_value(current_matches[1])
            if matched:lower():sub(1, #input) == input:lower() then
                local suffix = matched:sub(#input + 1)
                if #suffix > 0 then
                    completion_str = "[" .. suffix .. "]"
                else
                    completion_str = ""
                end
            else
                completion_str = "[" .. get_display(current_matches[1]) .. "]"
            end
        else
            if show_no_matches == true then
                completion_str = "[No Matches]"
            else
                completion_str = ""
            end
        end

        local inline_display = label .. input .. " " .. completion_str
        update(inline_display)

        -- ========= HIGHLIGHTS =========
        vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

        -- Label
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Special", 0, 0, #label)

        -- Typed Input
        local input_start = #label
        local input_end = input_start + #input

        -- First Candidate
        if #current_matches > 0 then
            -- Skip space and opening brace '{' or '[' + space
            local match_start = input_end + 2
            local match_end = match_start + #get_display(current_matches[1])
            vim.api.nvim_buf_add_highlight(buf, ns_id, "MatchParen", 0, match_start, match_end)
        end

        -- Cursor
        local hl_cursor = #label + cursor_pos
        if cursor_pos < #input then
            vim.api.nvim_buf_add_highlight(buf, ns_id, "InteractivePromptCursor", 0, hl_cursor, hl_cursor + 1)
        else
            -- Fallback
            vim.api.nvim_buf_set_extmark(buf, ns_id, 0, hl_cursor, {
                virt_text = { { " ", "InteractivePromptCursor" } },
                virt_text_pos = "overlay",
            })
        end
    end

    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        once = true,
        callback = function()
            close_ui()
        end,
    })

    render()

    --- ==============================================================================
    ---                                    KEYMAPS
    --- ==============================================================================

    local keymap_opts = { buffer = buf, noremap = true, silent = true, nowait = true }

    vim.keymap.set("n", "<CR>", function()
        local input = prompt:get_input()
        local result

        if prefer_candidate and #current_matches > 0 then
            result = get_value(current_matches[1]) or input
        else
            result = (#input > 0 and input)
            or (#current_matches > 0 and get_value(current_matches[1]))
            or ""
        end

        if opts.history and result ~= "" then
            prompt:add_history(result)
        end

        close_ui()
        if opts.on_submit then
            opts.on_submit(result)
        end
    end, keymap_opts)

    vim.keymap.set("n", "<Esc>", function() close_ui() end, keymap_opts)
    vim.keymap.set("n", "<C-c>", function() close_ui() end, keymap_opts)

    vim.keymap.set("n", "<BS>", function()
        prompt:backspace()
        render()
    end, keymap_opts)

    vim.keymap.set("n", "<Del>", function()
        prompt:delete()
        render()
    end, keymap_opts)

    vim.keymap.set("n", "<Up>", function()
        prompt:history_up()
        render()
    end, keymap_opts)

    vim.keymap.set("n", "<Down>", function()
        prompt:history_down()
        render()
    end, keymap_opts)

    local word_keymaps = {
        ["<C-BS>"]     = function() prompt:delete_prev_word() end,
        ["<C-w>"]      = function() prompt:delete_prev_word() end,
        ["<C-h>"]      = function() prompt:delete_prev_word() end,
        ["<C-Del>"]    = function() prompt:delete_next_word() end,
        ["<C-Delete>"] = function() prompt:delete_next_word() end,
        ["<C-Left>"]   = function() prompt:move_to_prev_word() end,
        ["<A-b>"]      = function() prompt:move_to_prev_word() end,
        ["<C-Right>"]  = function() prompt:move_to_next_word() end,
        ["<A-f>"]      = function() prompt:move_to_next_word() end,
    }

    for key, fn in pairs(word_keymaps) do
        vim.keymap.set("n", key, function()
            fn()
            render()
        end, keymap_opts)
    end

    vim.keymap.set("n", "<Left>", function()
        if prompt.cursor > 0 then
            prompt.cursor = prompt.cursor - 1
            render()
        end
    end, keymap_opts)

    vim.keymap.set("n", "<Right>", function()
        if prompt.cursor < #prompt:get_input() then
            prompt.cursor = prompt.cursor + 1
            render()
        end
    end, keymap_opts)

    vim.keymap.set("n", "<Tab>", function()
        if #current_matches == 0 then return end

        local input = prompt:get_input()

        if #current_matches == 1 then
            local choice = get_value(current_matches[1])
            prompt:set_input(choice)

            -- If candidate is a directory, re-evaluate candidates immediately
            if choice:sub(-1) == "/" then
                render() -- Re-fetches candidates for the newly entered directory
                return
            end
        else
            local prefix = Completion.common_prefix(current_matches, input)
            if #prefix > #input then
                prompt:set_input(prefix)

                -- If prefix expansion lands cleanly on a directory boundary
                if prefix:sub(-1) == "/" then
                    render()
                    return
                end
            else
                -- Cycle candidates
                local first = table.remove(current_matches, 1)
                table.insert(current_matches, first)
            end
        end

        render(current_matches)
    end, keymap_opts)

    vim.keymap.set("n", "<S-Tab>", function()
        if #current_matches == 0 then return end

        local input = prompt:get_input()
        if #current_matches == 1 then
            prompt:set_input(current_matches[1])
        else
            local prefix = Completion.common_prefix(current_matches, input)
            if #prefix > #input then
                prompt:set_input(prefix)
            else
                local first = table.remove(current_matches, #current_matches-1)
                table.insert(current_matches, 1, first)
            end
        end

        render(current_matches)
    end, keymap_opts)

    for i = 32, 126 do
        local char = string.char(i)
        vim.keymap.set("n", char, function()
            prompt:insert(char)
            render()
        end, keymap_opts)
    end
end

return M
