local M = {}

--- Retrieves a list of valid, named open buffer names
--- @return table # Array of buffer paths/names
function M.get_candidates()
    local v = vim.api
    local raw_buffers = {}
    local counts = {}

    for _, buf in ipairs(v.nvim_list_bufs()) do
        if v.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            local full_path = v.nvim_buf_get_name(buf)

            if full_path ~= "" then
                local relative = vim.fn.fnamemodify(full_path, ":~:.")
                local basename = vim.fs.basename(full_path)

                table.insert(raw_buffers, {
                    full_path = full_path,
                    relative = relative,
                    basename = basename,
                })

                counts[basename] = (counts[basename] or 0) + 1
            end
        end
    end

    local candidates = {}
    for _, item in ipairs(raw_buffers) do
        -- Use relative path if the basename is shared across multiple buffers
        if counts[item.basename] > 1 then
            table.insert(candidates, item.relative)
        else
            table.insert(candidates, item.basename)
        end
    end

    return candidates
end

return M
