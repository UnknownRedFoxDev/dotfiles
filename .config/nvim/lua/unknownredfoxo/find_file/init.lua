local ui = require("unknownredfoxo.find_file.ui")
local buffer_provider = require("unknownredfoxo.find_file.providers.buffer")
local file_provider = require("unknownredfoxo.find_file.providers.file")

local M = {}

--- Opens the interactive prompt pre-populated with the current directory's items
--- @param opts table|nil configuration options
function M.select_file(opts)
    opts = opts or {}

    local initial_dir = vim.fn.getcwd() .. "/"

    ui.open({
        prompt = opts.prompt or "Find File: ",
        candidates = file_provider.get_candidates,
        default_input = initial_dir,
        perfer_candidate = false,
        on_submit = function(choice)
            if choice and choice ~= "" then
                vim.cmd("edit " .. vim.fn.fnameescape(choice))
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
        prompt = opts.prompt or "Switch buffer> ",
        candidates = candidates,
        perfer_candidate = true,
        on_submit = function(choice)
            if choice and choice ~= "" then
                vim.cmd("buffer " .. vim.fn.fnameescape(choice))
            end
        end,
    })
end

return M
