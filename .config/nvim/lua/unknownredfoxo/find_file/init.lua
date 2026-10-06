local ui = require("unknownredfoxo.find_file.ui")
local buffer_provider = require("unknownredfoxo.find_file.buffer")

local M = {}

--- Opens the interactive prompt pre-populated with open buffers
--- @param opts table|nil Custom configuration options
function M.select_buffer(opts)
    opts = opts or {}

    local candidates = buffer_provider.get_candidates()

    ui.open({
        prompt = opts.prompt or "Switch buffer> ",
        candidates = candidates,
        on_submit = function(choice)
            if choice and choice ~= "" then
                vim.cmd("buffer " .. vim.fn.fnameescape(choice))
            end
        end,
    })
end

return M
