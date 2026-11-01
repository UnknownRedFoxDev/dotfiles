local buffer_provider = require("unknownredfoxo.interactive_prompt.providers.buffer")
local file_provider   = require("unknownredfoxo.interactive_prompt.providers.file")
local executable      = require("unknownredfoxo.interactive_prompt.providers.executable")
local ui              = require("unknownredfoxo.interactive_prompt.ui")
local buffers         = require("unknownredfoxo.buffers")
local cwd             = require("unknownredfoxo.interactive_prompt.cwd")
local completion      = require("unknownredfoxo.interactive_prompt.completion")

local M = {}
_G.run_command_history = _G.run_command_history or {}

--- Opens the interactive prompt pre-populated with the current different commands available
--- @param opts table|nil configuration options
function M.select_executable(opts)
    opts = opts or {}

    ui.open({
        prompt = opts.prompt or "Execute> ",
        candidates = executable.get_candidates,
        history = _G.run_command_history,
        prefer_candidate = true,
        on_submit = function(choice)
            if choice and choice ~= "" then
                if choice:match("^grep%s") and not choice:match("%-%-color") then
                    choice = choice:gsub("^grep", "grep --color=always")
                end

                _G.last_command_ran = choice

                local buf_name = "*Run Output*"
                local wrapped_choice = buffers.create_command_buffer(choice, buf_name)

                buffers.execute_command_buffer(wrapped_choice, buf_name)
            end
        end,
    })
end

--- Opens the interactive prompt pre-populated with the current directory's items
--- @param opts table|nil configuration options
function M.select_file(opts)
    opts = opts or {}

    local initial_dir = vim.fn.getcwd() .. "/"

    ui.open({
        prompt = opts.prompt or "Find File: ",
        candidates = file_provider.get_candidates,
        show_no_matches = true,
        default_input = initial_dir,
        prefer_candidate = false,
        on_submit = function(choice)
            if choice and choice ~= "" then
                vim.cmd("edit " .. vim.fn.fnameescape(choice))
                local ok, stat = pcall(vim.uv.fs_stat, choice)
                if ok and stat then
                    if stat.type == "directory" then
                        vim.api.nvim_set_current_dir(choice)
                    else
                        local dir = vim.fn.fnamemodify(choice, ":p:h")
                        vim.api.nvim_set_current_dir(dir)
                    end
                else
                    -- File doesn't exist yet, set CWD to parent (or to path if it ends with /)
                    if choice:sub(-1) == "/" then
                        vim.api.nvim_set_current_dir(choice)
                    else
                        local dir = vim.fn.fnamemodify(choice, ":p:h")
                        vim.api.nvim_set_current_dir(dir)
                    end
                end
            end
        end,
    })
end

--- Opens the interactive prompt pre-populated with open buffers
--- @param opts table|nil configuration options
function M.select_buffer(opts)
    opts = opts or {}

    local candidates = buffer_provider.get_candidates()

    ui.open({
        prompt = opts.prompt or "Switch buffer: ",
        candidates = candidates,
        show_no_matches = true,
        prefer_candidate = true,
        on_submit = function(choice)
            if choice and choice ~= "" then
                local valid = false
                for _, cand in ipairs(candidates) do
                    if completion.get_value(cand) == choice then
                        valid = true
                    end
                end
                if valid then
                    vim.cmd("buffer " .. vim.fn.fnameescape(choice))
                    cwd.sync_cwd(vim.api.nvim_get_current_buf())
                else
                    vim.notify("Buffer not found: " .. choice, vim.log.levels.ERROR)
                end
            end
        end,
    })
end

--- Opens a man page in a non-modifiable buffer
--- @param opts table|nil configuration options
function M.man_page(opts)
    opts = opts or {}

    ui.open({
        prompt = "man> ",
        candidates = function() return {} end,
        show_no_matches = false,
        prefer_candidate = false,
        on_submit = function(choice)
            if choice and choice ~= "" then
                local buf_name = "*Man " .. choice .. "*"
                local man_cmd = string.format("man %s | col -b", vim.fn.shellescape(choice))

                -- Create buffer
                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_name(buf, buf_name)
                vim.bo[buf].buftype = "nofile"
                vim.bo[buf].bufhidden = "hide"
                vim.bo[buf].modifiable = true
                vim.bo[buf].filetype = "man"

                -- Run man command and capture output
                local output = vim.fn.system(man_cmd)
                local lines = vim.split(output, "\n")

                -- Remove empty trailing lines
                while #lines > 0 and lines[#lines] == "" do
                    table.remove(lines)
                end

                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.bo[buf].modifiable = false

                -- Open in current window
                vim.cmd(string.format("botright %dsplit", vim.o.lines/2))
                vim.api.nvim_set_current_buf(buf)
            end
        end,
    })
end

return M
