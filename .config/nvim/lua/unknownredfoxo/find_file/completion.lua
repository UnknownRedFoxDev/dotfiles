local Completion = {}

--- Filters candidates matching the query string
--- @param query string User input string
--- @param candidates string[] List of available items
--- @return string[]|nil List of matching candidates
function Completion.filter(query, candidates)
    if not query or query == "" then
        return candidates
    end

    local results = {}
    local lower_query = query:lower()

    for _, item in ipairs(candidates) do
        local lower_item = item:lower()

        if lower_item:sub(1, #lower_query) == lower_query then
            table.insert(results, item)
        elseif lower_item:find(lower_query, 1, true) then
            table.insert(results, item)
        end
    end

    -- for _, item in ipairs(prefix_matches) do
    --     table.insert(results, item)
    -- end
    -- for _, item in ipairs(substring_matches) do
    --     table.insert(results, item)
    -- end

    return results
end

--- Calculates the longest common prefix across a list of strings
--- @param candidates string[]
--- @return string
function Completion.common_prefix(candidates)
    if not candidates or candidates == {} then
        return ""
    end

    local prefix = candidates[1]
    for i = 2, #candidates do
        while candidates[i]:sub(1, #prefix) ~= prefix and #prefix > 0 do
            prefix = prefix:sub(1, #prefix - 1)
        end
    end

    return prefix
end

return Completion
