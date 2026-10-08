local buffer_provider = require("unknownredfoxo.find_file.providers.buffer")
local file_provider   = require("unknownredfoxo.find_file.providers.file")
local executable      = require("unknownredfoxo.find_file.providers.executable")
local ui              = require("unknownredfoxo.find_file.ui")
local buffers         = require("unknownredfoxo.buffers")

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
        perfer_candidate = true,
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
        perfer_candidate = false,
        on_submit = function(choice)
            if choice and choice ~= "" then
                vim.cmd("edit " .. vim.fn.fnameescape(choice))
                if vim.uv.fs_stat(choice).type == "directory" then
                    vim.api.nvim_set_current_dir(choice)
                else
                    local dir = vim.fn.fnamemodify(choice, ":p:h")
                    vim.api.nvim_set_current_dir(dir)
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
        perfer_candidate = true,
        on_submit = function(choice)
            if choice and choice ~= "" then
                vim.cmd("buffer " .. vim.fn.fnameescape(choice))
            end
        end,
    })
end

return M
