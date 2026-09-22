function GrepByCwd()
    local success, input = pcall(vim.fn.input, { prompt = "Grep > " })
    if success and input ~= "" then
        require("telescope.builtin").grep_string({ search = input, cwd = vim.fn.expand('%:h') })
    end
end

function FindTaskByHUID()
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

function AlignSections(opts)
    local sep = ""

    if opts ~= nil then
        sep = opts.args
    end

    if sep == "" or sep == nil then
        sep = vim.fn.input("Align regexp: ")
    end

    local f_line = opts.line1
    local l_line = opts.line2

    -- Exit if user cancels input
    if sep == "" then
        return
    end

    local extra  = 1
    local lines  = vim.api.nvim_buf_get_lines(0, f_line - 1, l_line, false)
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

local function CreateCustomBuffer(buf_name, delete_prev_win_instance, delete_prev_buf_instance, split_size)
    local target_win = nil
    local target_buf = nil
    split_size = split_size or 16

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match(vim.pesc(buf_name) .. "$") then
            target_win = win
            target_buf = buf
            break
        end
    end

    if delete_prev_win_instance == true then
        if target_win then
            vim.api.nvim_win_close(target_win, true)
        end
    end

    vim.cmd(string.format("botright %dsplit", split_size))
    if delete_prev_buf_instance == true then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match(vim.pesc(buf_name) .. "$") then
                vim.api.nvim_buf_delete(buf, { force = true })
                break
            end
        end
    end
    return target_win, target_buf
end

function RunCommandBuffer(wrapped_cmd, buf_name)
    local current_buf = vim.api.nvim_create_buf(true, true)
    if current_buf then
        vim.api.nvim_win_set_buf(0, current_buf)
        vim.bo[current_buf].buftype = 'nofile'

        local start_time = vim.uv.hrtime()
        vim.fn.jobstart(wrapped_cmd, {
            term = true,
            on_exit = function(_, exit_code, _)
                local elapsed_ns = vim.uv.hrtime() - start_time
                local elapsed_ms = elapsed_ns / 1e6

                local duration_str = (elapsed_ms >= 1000)
                    and string.format("%.2fs", elapsed_ms / 1000)
                    or string.format("%dms", math.floor(elapsed_ms))

                vim.defer_fn(function()
                    if not vim.api.nvim_buf_is_valid(current_buf) then return end

                    vim.bo[current_buf].modifiable = true

                    local prefix = "Process "
                    local status_text = (exit_code == 0) and "finished" or "exited abnormally"
                    local full_status = (exit_code == 0) and status_text or (status_text .. " with code " .. tostring(exit_code))
                    local full_msg = prefix .. full_status .. string.format(" at %s", os.date("%Y-%m-%d %H:%M:%S")) .. ", duration: " .. duration_str

                    -- Reverse search to find the last empty line
                    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
                    local last_content_line = #lines
                    for i = #lines, 1, -1 do
                        if lines[i]:match("%S") then
                            last_content_line = i
                            break
                        end
                    end

                    -- Replace the "[Process Exit <exit_code>]" by a custom message
                    vim.api.nvim_buf_set_lines(current_buf, last_content_line, -1, false, { "", full_msg })

                    -- Highlights
                    local ns_id = vim.api.nvim_create_namespace("run_cmd_status")
                    local symbol_hl = (exit_code == 0) and "DiagnosticOk" or "DiagnosticError"
                    local line_idx = vim.api.nvim_buf_line_count(current_buf) - 1
                    local status_start = string.len(prefix)
                    local status_end = status_start + string.len(status_text)

                    -- "finshed" / "exited abnormally" highlighting
                    vim.api.nvim_buf_add_highlight(current_buf, ns_id, symbol_hl, line_idx, status_start, status_end)

                    -- <exit_code> highlighting
                    if exit_code ~= 0 then
                        local exit_code_start = status_end + string.len(" with code ")
                        local exit_code_end = exit_code_start + string.len(tostring(exit_code))
                        vim.api.nvim_buf_add_highlight(current_buf, ns_id, symbol_hl, line_idx, exit_code_start, exit_code_end)
                    end

                    vim.bo[current_buf].modifiable = false

                    -- Force scroll down to see the custom message, othrwise it would get chopped off by the auto-scroll
                    for _, win in ipairs(vim.fn.win_findbuf(current_buf)) do
                        if vim.api.nvim_win_is_valid(win) then
                            vim.api.nvim_win_call(win, function()
                                local total_lines = vim.api.nvim_buf_line_count(current_buf)
                                vim.api.nvim_win_set_cursor(win, { total_lines, 0 })
                            end)
                        end
                    end
                end, 1)
            end,
        })

        vim.api.nvim_buf_set_name(current_buf, buf_name)
        vim.cmd("normal! G")
    end
end

local function CreateCommandBuffer(cmd, buf_name)
    local target_win, target_buf = CreateCustomBuffer(buf_name, true, true)

    local shell = vim.o.shell
    local cwd = vim.uv.cwd()
    local header = string.format("printf '-*- mode: command; default-directory: \"%%s\" -*-\\nProcess started at %%s\\n\\n%%s\\n'; %s", cmd)

    local wrapped_cmd = string.format("%s -c %s", shell, vim.fn.shellescape(string.format(header, cwd, os.date("%Y-%m-%d %H:%M:%S"), cmd)))
    return wrapped_cmd
end

function RunCommand()
    -- local cmd = vim.fn.input("Run command: ", "", "shellcmd")
    local status, cmd = pcall(function()
        return vim.fn.input("Run command: ")
    end)

    if not status or cmd == "" or cmd == nil then
        return
    end

    if cmd:match("^grep%s") and not cmd:match("%-%-color") then
        cmd = cmd:gsub("^grep", "grep --color=always")
    end

    _G.last_command_ran = cmd
    local buf_name = "*Run Output*"
    local wrapped_cmd = CreateCommandBuffer(cmd, buf_name)

    RunCommandBuffer(wrapped_cmd, buf_name)
end

function RunLastCommandRan()
    if _G.last_command_ran ~= nil then
        local buf_name = "*Run Output*"
        local wrapped_cmd = CreateCommandBuffer(_G.last_command_ran, buf_name)

        RunCommandBuffer(wrapped_cmd, buf_name)
    end
end

function DisplayBuffers()
  local builtin = require('telescope.builtin')
  local themes = require('telescope.themes')

  -- Open the standard buffer list using a clean dropdown theme
  builtin.buffers(themes.get_dropdown({
    winblend = 10,
    previewer = false, -- Turn off preview if you want it to look minimal like a mini-buffer
    shorten_path = true,
  }))
end

function DisplayScratch()
    local buf_name = "*Scratch*"
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


    local new_buf = vim.api.nvim_create_buf(true, true)
    vim.bo[new_buf].buftype = "nofile"
    vim.bo[new_buf].filetype = "markdown"

    local header = {
        ";; This buffer is for notes you don't want to save. You can evaluate your lua functions here too.",
        ";; If you want to create a file, visit that file with `:e <filename>`",
        ";; then enter the text in that file's own buffer.",
        "",
        "",
    }


    vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, header)
    if not target_win then
        -- vim.cmd('botright 16split')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match(vim.pesc(buf_name) .. "$") then
                target_buf = buf
                break
            end
        end
    end
    if target_buf then vim.api.nvim_buf_delete(target_buf, { force = true })
    end
    vim.api.nvim_buf_set_name(new_buf, buf_name)
    vim.api.nvim_win_set_buf(0, new_buf)

    vim.cmd('normal! G')  -- Go to the bottom the buffer
end

function DisplayBuffers()
  local builtin = require('telescope.builtin')
  local themes = require('telescope.themes')

  -- Open the standard buffer list using a clean dropdown theme
  builtin.buffers(themes.get_dropdown({
    winblend = 10,
    previewer = false, -- Turn off preview if you want it to look minimal like a mini-buffer
    shorten_path = true,
  }))
end

function OpenFileUnderCursor()
    -- Pattern matches: path/file.ext:digits (handles HUID folder structures cleanly)
    local line = vim.api.nvim_get_current_line()
    local path = ""
    local line_num = ""
    local col_num = ""
    path, line_num, col_num = line:match("([^:\n%s]+):(%d+):(%d+):?")

    if path == "" or path == nil then
        path, line_num = line:match("([^:\n%s]+):(%d+):")
    end

    if path == "" then
        print("No valid file path and line number found on this line.")
        return
    end

    -- Ensure the target window still exists, fallback to a smart split if it doesn't
    if _G.last_editor_win and vim.api.nvim_win_is_valid(_G.last_editor_win) then
        vim.api.nvim_set_current_win(_G.last_editor_win)
    else
        vim.cmd("wincmd k") -- Jump up one window as a sane fallback
        _G.last_editor_win = vim.api.nvim_get_current_win()
    end

    local target = ""
    if path ~= "" and path ~= nil then
        target = vim.fn.fnameescape(path)
    end

    if target ~= nil and target ~= "" then
        if col_num == nil then
            vim.cmd(string.format("edit +call\\ cursor(%d,1) %s", line_num, target))
        else
            vim.cmd(string.format("edit +call\\ cursor(%d,%s) %s", line_num, col_num, target))
        end
    end
end

local function isTasksDirPresent()
    local isTasksDirPresent = vim.system({ "tatr", "ls" }):wait()

    if isTasksDirPresent.code == 1 then
        vim.notify("Tasks is not present", vim.log.levels.INFO)
    --     vim.ui.input({
    --         prompt = "No tasks/ directory was found. Create one? Y/n: ",
    --     }, function(choice)
    --         if choice == "" or choice == "y" or choice == "Y" then
    --             vim.system({ "tatr", "init", "y" }):wait()
    --         else
    --             cancelCommand = true
    --         end
    --     end)
        return false
    end
    return true
end

function CreateAndOpenTask(title)
    local result = ""
    -- result = vim.api.nvim_exec2("!tatr new --no-editor ".. title, {output = true})
    result = vim.system({ "tatr", "new", "--no-editor", title }):wait()

    if result == nil or result == "" then
        return;
    end

    local match = result.stderr:match(": (.-)$")

    if match == "" then
        vim.notify("Failed to find match", vim.log.levels.ERROR)
        return;
    end

    vim.cmd('botright 16split')
    vim.cmd(string.format("edit %s", match))
end

function newTask()
    local status, title = pcall(function()
        return vim.fn.input("task title: ")
    end)

    if not status or title == "" or title == nil then
        return
    end

    if isTasksDirPresent() then
        CreateAndOpenTask(title)
    end
end

-- TASK(): aaaaaaaaaaaaaaaaaa
function CreateTaskFromComment()
    local curr_line = vim.api.nvim_get_current_line()
    local huid_pattern = "%w+%(%): (%w+)"
    local match = string.match(curr_line, huid_pattern)
    if not match then
        vim.notify("No task match found on line", vim.log.levels.WARN)
        return
    end

    if isTasksDirPresent() then
        CreateAndOpenTask(match)
    end
end

function copyHuidToClipboard()
    local huid_pattern = "/?(%d+%-%d+)/?"
    -- local path = "/home/user/19970101-000000/TASK.md"
    -- local path = "/home/unknownredfoxo/dev/env/tasks/20260824-235359"
    local path = vim.fn.expand('%:p:h')
    local match = string.match(path, huid_pattern)
    -- local match_str = "(none)"
    -- if match ~= nil then
    --     match_str = match
    -- end
    --
    -- local msg = "Found huid: \""
    --             .. match_str
    --             .. "\" for path: \""
    --             .. path .. "\""
    -- vim.notify(msg, vim.log.levels.ERROR)

    if match ~= nil then
        vim.fn.setreg("+", match);
    end
end

-- local function get_buffer_names()
--     local names = {}
--     for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--         if vim.api.nvim_buf_is_loaded(buf) then
--             local name = vim.api.nvim_buf_get_name(buf)
--             if name ~= "" then
--                 -- Extract just the filename or tail path for easy reading
--                 table.insert(names, vim.fs.basename(name))
--             end
--         end
--     end
--     return names
-- end
--
-- -- Custom completion function passed to vim.fn.input
-- _G.buffer_input_completion = function(ArgLead, CmdLine, CursorPos)
--     local buffer_names = get_buffer_names()
--
--     if ArgLead == "" then
--         return buffer_names
--     end
--
--     -- Uses Neovim's built-in fuzzy matcher
--     return vim.fn.matchfuzzy(buffer_names, ArgLead)
-- end
--
-- -- Usage wrapper
-- function prompt_buffer_name()
--     local status, input = pcall(function()
--         return vim.fn.input({
--             prompt = "Buffer: ",
--             completion = "customlist,v:lua.buffer_input_completion",
--         })
--     end)
--
--     vim.cmd("redraw");
--     local selected_buf = input
--     if status and input ~= "" then
--         local buffer_names = get_buffer_names()
--         local matches = vim.fn.matchfuzzy(buffer_names, input)
--         selected_buf = matches[1] or input
--
--         vim.notify(string.format("Selected buffer: %s", selected_buf), vim.log.levels.INFO);
--     end
--
--     local target_buf = nil
--     for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--         local name = vim.api.nvim_buf_get_name(buf)
--         if name:match(vim.pesc(selected_buf) .. "$") then
--             target_buf = buf
--             break
--         end
--     end
--
--     vim.api.nvim_win_set_buf(0, target_buf)
-- end

--
-- local buffer_names = {}
-- local delimer_pattern = "[%s%.,%-_/]"
--

function live_buffer_prompt(opts)
    opts = opts or {}
    local prompt_label = opts.prompt or "Input: "
    local get_candidates = opts.get_candidates or function() return {} end
    local delimer_pattern = opts.delimers or "[%s,%-_/]"
    local input = opts.initial_input or ""

    local cursor = opts.initial_cursor or 1 -- from 1 to #input+1
    io.stdout:write("\27[?25l")

    local function cleanup()
        io.stdout:write("\27[?25h")
        vim.cmd("redraw")
        print("")
      end

    local bs_keys = { [string.char(127)] = true, [string.char(8)] = true, [vim.keycode("<BS>")] = true, }
    local ctrl_bs_keys = { [string.char(8)] = true, [string.char(23)] = true, [vim.keycode("<C-BS>")] = true, [vim.keycode("<C-W>")] = true, }
    local del_keys = { ["\128\107D"] = true, [vim.keycode("<Del>")] = true, }
    local ctrl_del_keys = { ["\128\252\4\128\107D"] = true, [vim.keycode("<C-Del>")] = true, }

    local left_keys = { ["\128\107kl"] = true, [vim.keycode("<Left>")] = true, }
    local ctrl_left_keys = { ["\128\253U"] = true, ["\128\252\4\128\107kl"] = true, [vim.keycode("<C-Left>")] = true, [string.char(2)] = true, }
    local right_keys = { ["\128\107kr"] = true, [vim.keycode("<Right>")] = true, }
    local ctrl_right_keys = { ["\128\253V"] = true, ["\128\252\4\128\107kr"] = true, [vim.keycode("<C-Right>")] = true, [string.char(6)] = true, }
    local home_keys = { ["\128\107kh"] = true, [vim.keycode("<Home>")] = true, [string.char(1)] = true, }
    local end_keys = { ["\128\107@7"] = true, [vim.keycode("<End>")] = true, [string.char(5)] = true, }

    local tab_keys = {[string.char(9)] = true,}

    while true do
        local prefix = input:match("([^/]*)$") or input
        local candidates = get_candidates(input, prefix)

        local hints = {}
        local trim_hints = false
        for i, name in ipairs(candidates) do
            if i > 8 then
                trim_hints = true
                break
            end
            table.insert(hints, string.format("%s", name))
        end
        local end_hints = trim_hints and " | ...}" or "}"
        local hint_str = #hints > 0 and " {" .. table.concat(hints, " | ") .. end_hints or "{}"

        local head = input:sub(1, cursor - 1)
        local char_at_cursor = input:sub(cursor, cursor)
        local tail = ""

        if char_at_cursor == "" then
            char_at_cursor = " "
        else
            tail = input:sub(cursor + 1) .. " "
        end

        vim.cmd("redraw")
        vim.api.nvim_echo({
            { prompt_label, "Question" },
            { head, "Normal" },
            { char_at_cursor, "Cursor" },
            { tail, "Normal" },
            { hint_str, "Comment" },
        }, false, {})

        local ok, char = pcall(vim.fn.getcharstr)

        -- -------------------------
        -- PRINT KEYCODE
        -- input = input .. "Bytes: " .. vim.inspect({ char:byte(1, #char) })
        -- -------------------------

        if not ok or char == "\27" or char == vim.keycode("<Esc>") then
            cleanup()
            return nil
        elseif char == "\r" or char == "\n" or char == vim.keycode("<CR>") then
            cleanup()
            return input or candidates[1]

        elseif left_keys[char] then
            if cursor > 1 then cursor = cursor - 1 end
        elseif ctrl_left_keys[char] then
            while cursor > 1 and input:sub(cursor - 1, cursor - 1):match(delimer_pattern) do
                cursor = cursor - 1
            end

            while cursor > 1 and not input:sub(cursor - 1, cursor - 1):match(delimer_pattern) do
                cursor = cursor - 1
            end

        elseif right_keys[char] then
            if cursor <= #input then cursor = cursor + 1 end
        elseif ctrl_right_keys[char] then
            while cursor <= #input and not input:sub(cursor, cursor):match(delimer_pattern) do
                cursor = cursor + 1
            end

            while cursor <= #input and input:sub(cursor, cursor):match(delimer_pattern) do
                cursor = cursor + 1
            end

        elseif home_keys[char] then
            cursor = 1

        elseif end_keys[char] then
            cursor = #input + 1

        -- DELETE KEY
        elseif ctrl_del_keys[char] then
            -- Removing the trailing delimer
            while cursor <= #input and input:sub(cursor, cursor):match(delimer_pattern) do
                input = input:sub(1, cursor - 1) .. input:sub(cursor + 1)
            end

            -- Removing the word until the delimiter is found
            while cursor <= #input and not input:sub(cursor, cursor):match(delimer_pattern) do
                input = input:sub(1, cursor - 1) .. input:sub(cursor + 1)
            end
        elseif del_keys[char] then
            if cursor <= #input then
                input = input:sub(1, cursor - 1) .. input:sub(cursor + 1)
            end

        -- BACKSPACE KEY
        elseif ctrl_bs_keys[char] then
            -- Removing the trailing delimer
            while cursor > 1 and input:sub(cursor - 1, cursor - 1):match(delimer_pattern) do
                input = input:sub(1, cursor - 2) .. input:sub(cursor)
                cursor = cursor - 1
            end

            -- Removing the word until the delimiter is found
            while cursor > 1 and not input:sub(cursor - 1, cursor - 1):match(delimer_pattern) do
                input = input:sub(1, cursor - 2) .. input:sub(cursor)
                cursor = cursor - 1
            end
        elseif bs_keys[char] then
            if cursor > 1 then
                input = input:sub(1, cursor - 2) .. input:sub(cursor)
                cursor = cursor - 1
            end

        elseif tab_keys[char] then
            if #candidates > 0 then
                local top_match = candidates[1]
                local left_part = input:sub(1, cursor-1)
                local right_part = input:sub(cursor)

                local token_start = left_part:find("[^/]*$") or 1
                local base_prefix = left_part:sub(1, token_start-1)

                local token_end   = right_part:find("[/.]")
                local tail_remainder = token_end and right_part:sub(token_end) or ""

                input = base_prefix .. top_match .. tail_remainder
                cursor = #base_prefix + #top_match + 1
            end

        elseif #char == 1 and char:byte() >= 32 then -- Printable characters
            input = input:sub(1, cursor - 1) .. char .. input:sub(cursor)
            cursor = cursor + 1
        end
    end
end

function select_buffers()
    local selected = live_buffer_prompt({
        prompt = "Buffer: ",
        get_candidates = function(_, prefix)
            local names = {}
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name ~= "" then
                        table.insert(names, vim.fs.basename(name))
                    end
                end
            end
            if prefix and prefix ~= "" then
                names = vim.fn.matchfuzzy(names, prefix)
            end
            return names
        end,
    })
    if selected then
        local target_buf = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match(vim.pesc(selected) .. "$") then
                target_buf = buf
                break
            end
        end

        if target_buf then
            vim.api.nvim_win_set_buf(0, target_buf)
        end
    end
    print("")
end

local function find_candidate_dirs(input_str, prefix)
    local expanded = vim.fn.expand(input_str)

    local dir
    if expanded:sub(-1) == "/" then
        dir = expanded
    else
        dir = vim.fs.dirname(expanded) or "."
    end

    if dir ~= "/" and dir:sub(-1) ~= "/" then
        dir = dir .. "/"
    end

    if vim.fn.isdirectory(dir) == 0 then
        return {}
    end

    local entries = vim.fn.readdir(dir)
    local dirs = {}
    local files = {}
    local candidates = {}

    for _, entry in ipairs(entries) do
        local is_dir = vim.fn.isdirectory(dir .. entry) == 1

        if is_dir then
            table.insert(dirs, entry .. "/")
        else
            table.insert(files, entry)
        end
    end

    if not prefix or prefix == "" then
        for _, d in ipairs(dirs) do table.insert(candidates, d) end
        for _, f in ipairs(files) do table.insert(candidates, f) end
        return candidates
    end

    dirs = vim.fn.matchfuzzy(dirs, prefix)
    files = vim.fn.matchfuzzy(files, prefix)

    for _, d in ipairs(dirs) do table.insert(candidates, d) end
    for _, f in ipairs(files) do table.insert(candidates, f) end
    return candidates
end

function FindFile()
    local cwd = vim.fn.getcwd()
    if cwd:sub(-1) ~= "/" then cwd = cwd .. "/" end
    local selected = live_buffer_prompt({
        prompt = "Find File: ",
        initial_input = cwd,
        initial_cursor = #cwd + 1,
        get_candidates = find_candidate_dirs
    })

    if selected and selected ~= "" and selected ~= cwd then
        local full_path = vim.fn.fnameescape(vim.fn.expand(selected))
        if vim.fn.isdirectory(full_path) == 1 then
            print("Path: " .. full_path)
            vim.cmd(string.format("cd %s", full_path))
            -- if vim.api.nvim_get_option_value("buftype", {buf = 0}) == "acwrite" or
            --    vim.api.nvim_get_option_value("filetype", {buf = 0}) == "dired"then
            if vim.bo.buftype == "acwrite" or vim.bo.filetype == "dired" then
                vim.cmd.Dired()
            end
        else
            print("file: " .. full_path)
            vim.cmd(string.format("edit %s", full_path))
        end
    else
        print("")
    end
end

function FindFirstError()
    local lines = vim.api.nvim_buf_get_lines(0, 2, -1, false)
    local find_error_regex = "([^:\n%s]+):(%d+):(%d+):?"
    local file, line_num, col_num
    vim.cmd("normal! gg")
    for i, line in ipairs(lines) do
        file, line_num, col_num = string.match(line, find_error_regex)
        if file and line_num and col_num then
            print(string.format("File: %s\n\tat line: %d\n\ton column: %d\n", file, line_num, col_num))
            vim.api.nvim_win_set_cursor(0, { i + 2, 0 })
            break;
        end
    end

    OpenFileUnderCursor()
end
