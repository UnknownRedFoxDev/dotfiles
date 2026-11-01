local M = {}

function M.get_candidates()
    local handle = io.popen("man -k . 2>/dev/null")
    if not handle then return {} end

    local candidates = {}
    local seen = {}

    for line in handle:lines() do
        -- Extract name and section from "name (section) - description"
        local name, section = line:match("^(%S+) %((%d%a?)%)")
        if name and section and not seen[name] then
            seen[name] = true
            table.insert(candidates, {
                display = name .. " (" .. section .. ")",
                value = name .. "(" .. section .. ")",
            })
        end
    end

    handle:close()
    return candidates
end

return M
