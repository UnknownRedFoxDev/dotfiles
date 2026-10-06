local Prompt = require("unknownredfoxo.find_file.prompt")
local Completion = require("unknownredfoxo.find_file.completion")
local M = {}

vim.api.nvim_set_hl(0, "InteractivePromptCursor", { default = true, reverse = true })

function M.open(opts)
    opts = opts or {}
    local candidates = opts.candidates or {}

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = vim.o.lines - 4,
        col = 2,
        width = vim.o.columns - 4,
        height = 1,
        style = "minimal",
        border = "rounded",
        -- title = opts.prompt or "Find file> "
    })

    io.stdout:write("\27[?25l")

    local ns_id = vim.api.nvim_create_namespace("emacs_prompt_ui")
    local cleaned_up = false
    local orig_timeout = vim.o.timeout
    local orig_timeoutlen = vim.o.timeoutlen
    local prompt_str = opts.prompt or "Select: "

    -- Disable mapping timeouts while inside the minibuffer
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

    local function render()
        local input = prompt:get_input()
        local cursor_pos = prompt:get_cursor()

        current_matches = Completion.filter(input, candidates)

        local inline_display = ""
        local completion_str = ""
        if #current_matches > 1 then
            local choices = table.concat(current_matches, " | ", 1, math.min(#current_matches, 5))
            completion_str = string.format("{%s}", choices)
        elseif #current_matches == 1 then
            completion_str = string.format("[%s]", current_matches[1])
        else
            completion_str = "[No Matches]"
        end

        inline_display = prompt_str .. input .. " " .. completion_str
        update(inline_display)

        vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

        local hl_cursor = #prompt_str + cursor_pos

        if cursor_pos < #input then
            vim.api.nvim_buf_add_highlight(buf, ns_id, "InteractivePromptCursor", 0, hl_cursor, hl_cursor + 1)
        else
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

    -- Corrected table name and added nowait = true
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

    for i = 32, 126 do
        local char = string.char(i)
        vim.keymap.set("n", char, function()
            prompt:insert(char)
            render()
        end, keymap_opts)
    end
end

return M
