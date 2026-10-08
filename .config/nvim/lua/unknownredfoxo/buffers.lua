local M = {}

function M.create_custom_buffer(buf_name, delete_prev_win_instance, delete_prev_buf_instance, split_size)
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
        if #vim.api.nvim_list_wins() > 1 and target_win then
            vim.api.nvim_win_close(target_win, true)
        end
        vim.cmd(string.format("botright %dsplit", split_size))
    end

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

function M.create_command_buffer(cmd, buf_name)
    local target_win, target_buf = M.create_custom_buffer(buf_name, true, true)

    local shell = vim.o.shell
    local cwd = vim.uv.cwd()
    local header = string.format("printf '-*- mode: command; default-directory: \"%%s\" -*-\\nProcess started at %%s\\n\\n%%s\\n'; %s", cmd)

    local wrapped_cmd = string.format("%s -c %s", shell, vim.fn.shellescape(string.format(header, cwd, os.date("%Y-%m-%d %H:%M:%S"), cmd)))
    return wrapped_cmd
end

function M.execute_command_buffer(wrapped_cmd, buf_name)
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


return M
