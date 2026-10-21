local Completion = {}

--- Retrieve the display label from candidate's table
--- @param candidate table The candidate
--- @return string
function Completion.get_display(candidate)
    return type(candidate) == "table" and candidate.display or candidate
end

--- Retrieve the value from candidate's table
--- @param candidate string|table The candidate
--- @return string
function Completion.get_value(candidate)
    return type(candidate) == "table" and candidate.value or candidate
end

--- Filters candidates matching the query string
--- @param query string User input string
--- @param candidates string[] List of available items
--- @return string[]|nil # List of matching candidates
function Completion.filter(input, candidates)
    if not input or input == "" then
        return candidates
    end

    local prefix_matches = {}
    local substring_matches = {}
    local lower_input = input:lower()

    for _, candidate in ipairs(candidates) do
        local value = Completion.get_value(candidate)
        local lower_val = value:lower()

        if lower_val:sub(1, #input) == lower_input then
            table.insert(prefix_matches, candidate)
        elseif lower_val:find(lower_input, 1, true) then
            table.insert(substring_matches, candidate)
        end
    end

    -- Combines prefix matches followed by substring matches
    local result = {}
    for _, match in ipairs(prefix_matches) do table.insert(result, match) end
    for _, match in ipairs(substring_matches) do table.insert(result, match) end

    return result
end

--- Calculates the longest common prefix across a list of strings
--- @param candidates string[] Found list of candidates
--- @param input string[] User input
--- @return string
function Completion.common_prefix(candidates, input)
    if #candidates == 0 then return "" end
    if #candidates == 1 then return Completion.get_value(candidates[1]) end

    local prefix_candidates = {}

    -- Filter by input first, if given
    if input and #input > 0 then
        local lower_input = input:lower()
        for _, match in ipairs(candidates) do
            local val = Completion.get_value(match)
            if val:lower():sub(1, #input) == lower_input then
                table.insert(prefix_candidates, val)
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
    local prefix = Completion.get_value(prefix_candidates[1])
    for i = 2, #prefix_candidates do
        local str = Completion.get_value(prefix_candidates[i])
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
