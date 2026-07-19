function GrepByCwd()
    local success, input = pcall(vim.fn.input, { prompt = "Grep > " })
    if success and input ~= "" then
        require("telescope.builtin").grep_string({ search = input, cwd = vim.fn.expand('%:p:h') })
    end
end

function FindToDoByTimestamp()
    local curr_line = vim.api.nvim_get_current_line()
    local huid_pattern = "%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d"

    local match = string.match(curr_line, huid_pattern)

    if not match then
        vim.notify("No task timestamp found on line", vim.log.levels.WARN)
        return
    end

    -- TASK(20260719-172727): bogus amongus
    local path = vim.fs.find(match, {
        path = vim.uv.cwd(),
        limit = 1,
    })

    if #path == 0 then
        vim.notify("No task of HUID: " .. match .. " was found", vim.log.levels.WARN)
        return
    end

    vim.cmd('botright 16split')
    vim.cmd('e ' .. path[1] .. "/TASK.md")
    vim.cmd('normal! gg')

    -- require("telescope.builtin").live_grep({
    --     cwd = vim.fn.expand('%:p:h'),
    --     default_text = comment_char .. " TODO\\(" .. timestamp .. "\\)",
    --     grep_open_files = true,
    -- })
end

function AddTodo()
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local success, input = pcall(vim.fn.input, { prompt = "Enter TODO > " })
    if success and input ~= "" then
        local comment_char = vim.bo.commentstring:match("([^ ]+)") or "#"
        local line = comment_char .. " TODO(" .. timestamp .. "): " .. input
        local line_num = vim.api.nvim_buf_line_count(0) + 1
        vim.api.nvim_buf_set_lines(0, line_num - 1, line_num - 1, false, { line })
        vim.fn.setreg('"', comment_char .. " See TODO(" .. timestamp .. ")")
    end
end

function AlignSections(opts)
    local f_line = opts.line1
    local l_line = opts.line2

    local sep = opts.args
    if sep == "" or sep == nil then
        sep = vim.fn.input("Align regexp: ")
    end

    -- Exit if user cancels input
    if sep == "" then
        return
    end

    local extra = 1
    local lines = vim.api.nvim_buf_get_lines(0, f_line - 1, l_line, false)
    local maxpos = 0

    -- Escape special Lua pattern characters in the separator
    local safe_sep = sep:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

    -- Pass 1: Find the maximum width of the prefix
    for _, line in ipairs(lines) do
        local prefix = line:match("(.-)%s*" .. safe_sep)
        if prefix then
            if #prefix > maxpos then
                maxpos = #prefix
            end
        end
    end

    -- Pass 2: Reconstruct lines
    local new_lines = {}
    for _, line in ipairs(lines) do
        local prefix, suffix = line:match("(.-)%s*(" .. safe_sep .. ".*)")
        if prefix and suffix then
            local padding = string.rep(" ", maxpos - #prefix + extra)
            table.insert(new_lines, prefix .. padding .. suffix)
        else
            table.insert(new_lines, line)
        end
    end

    vim.api.nvim_buf_set_lines(0, f_line - 1, l_line, false, new_lines)
end

function RunCommand()
    local cmd = vim.fn.input("Run command: ")

    if cmd == "" then
        return
    end

    local buf_name = "*Run Output*"
    local target_win = nil
    local target_buf = nil

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match(vim.pesc(buf_name) .. "$") then
            target_win = win
            target_buf = buf
            break
        end
    end

    if not target_win then
        vim.cmd('botright 16split')
    end

    vim.cmd('terminal ' .. cmd)
    -- vim.cmd('normal! gg') -- Go to the top of the buffer
    vim.cmd('normal! G')  -- Go to the bottom the buffer
    local current_buf = vim.api.nvim_get_current_buf()
    if target_buf then
        vim.api.nvim_buf_delete(target_buf, { force = true })
    end
    vim.api.nvim_buf_set_name(current_buf, buf_name)
end

