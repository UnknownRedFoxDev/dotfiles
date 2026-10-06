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
--- @param input string[]
--- @return string
function Completion.common_prefix(candidates, input)
    if #candidates == 0 then return "" end
    if #candidates == 1 then return candidates[1] end

    local prefix_candidates = {}

    -- Filter by input first, if given
    if input and #input > 0 then
        local lower_input = input:lower()
        for _, match in ipairs(candidates) do
            if match:lower():sub(1, #input) == lower_input then
                table.insert(prefix_candidates, match)
            end
        end
    else
        prefix_candidates = candidates
    end

    -- If neither candidate nor prefix gave any candidates, return nothing
    if #prefix_candidates == 0 then
        return ""
    end

    -- Otherwirse, return the common prefix amongst all candidates
    local prefix = prefix_candidates[1]
    for i = 2, #prefix_candidates do
        local str = prefix_candidates[i]
        local j = 1
        while j <= #prefix and j <= #str and prefix:sub(j, j):lower() == str:sub(j, j):lower() do
            j = j + 1
        end
        prefix = prefix:sub(1, j - 1)
        if prefix == "" then break end
    end

    return prefix
end

return Completion
