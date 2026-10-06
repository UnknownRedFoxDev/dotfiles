local Completion = {}

--- Filters candidates matching the query string
--- @param query string User input string
--- @param candidates string[] List of available items
--- @return string[]|nil List of matching candidates
function Completion.filter(input, candidates)
    if not input or input == "" then
        return candidates
    end

    local prefix_matches = {}
    local substring_matches = {}
    local lower_input = input:lower()

    for _, candidate in ipairs(candidates) do
        local lower_candidate = candidate:lower()
        if lower_candidate:sub(1, #input) == lower_input then
            table.insert(prefix_matches, candidate)
        elseif lower_candidate:find(lower_input, 1, true) then
            table.insert(substring_matches, candidate)
        end
    end

    -- Combine: Prefix matches come first, followed by substring matches
    local result = {}
    for _, match in ipairs(prefix_matches) do
        table.insert(result, match)
    end
    for _, match in ipairs(substring_matches) do
        table.insert(result, match)
    end

    return result
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
