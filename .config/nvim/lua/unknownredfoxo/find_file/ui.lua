local Prompt = require("unknownredfoxo.find_file.prompt")
local Completion = require("unknownredfoxo.find_file.completion")
local M = {}

vim.api.nvim_set_hl(0, "InteractivePromptCursor", { default = true, reverse = true })

function M.open(opts)
    opts = opts or {}
    local candidates = opts.candidates or {}

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
    local cleaned_up = false
    local orig_timeout = vim.o.timeout
    local orig_timeoutlen = vim.o.timeoutlen
    local label = opts.prompt or "Select: "

    vim.o.timeout = false

    local function close_ui()
        if cleaned_up then return end
        cleaned_up = true
        io.stdout:write("\27[?25h")
        vim.o.timeout = orig_timeout
        vim.o.timeoutlen = orig_timeoutlen
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local prompt = Prompt.new({
        on_change = function() end,
    })

    local current_matches = candidates

    local function update(text)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    end

    local function render(override_matches)
        local input = prompt:get_input()
        local cursor_pos = prompt:get_cursor()

        current_matches = override_matches or Completion.filter(input, candidates)
        local max_visible = 5

        local completion_str = ""
        if #current_matches > 1 then
            local limit = math.min(#current_matches, max_visible)
            local choices = table.concat(current_matches, " | ", 2, limit)
            local extra_fluff = #current_matches > max_visible and " | ..." or ""
            completion_str = string.format("{%s | %s%s}", current_matches[1], choices, extra_fluff)
        elseif #current_matches == 1 then
            local full_match = current_matches[1]
            if full_match:lower():sub(1, #input) == input:lower() then
                local suffix = full_match:sub(#input + 1)
                if #suffix > 0 then
                    completion_str = "[" .. suffix .. "]"
                else
                    completion_str = ""
                end
            else
                completion_str = "[" .. full_match .. "]"
            end
        else
            completion_str = "[No Matches]"
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
        if #input > 0 then
            vim.api.nvim_buf_add_highlight(buf, ns_id, "Normal", 0, input_start, input_end)
        end

        -- First Candidate
        if #current_matches > 0 then
            -- Skip space and opening brace '{' or '[' + space
            local match_start = input_end + 2
            local match_end = match_start + #current_matches[1]
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

    local keymap_opts = { buffer = buf, noremap = true, silent = true, nowait = true }

    vim.keymap.set("n", "<CR>", function()
        local result = current_matches[1] or prompt:get_input()
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
            prompt:set_input(current_matches[1])
        else
            local prefix = Completion.common_prefix(current_matches, input)
            if #prefix > #input then
                prompt:set_input(prefix)
            else
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
