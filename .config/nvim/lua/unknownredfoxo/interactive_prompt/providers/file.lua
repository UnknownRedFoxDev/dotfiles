local M = {}

--- Resolves files and directories dynamically based on the current input path
--- @param input string Current prompt input
--- @return table # Array of relative paths/filenames
function M.get_candidates(input)
    input = input or ""

    local expanded_input = vim.fn.expand(input)

    local search_dir = "."
    local prefix = ""

    if expanded_input:find("/") then
        if expanded_input:sub(1, 1) == "/" then
            search_dir = expanded_input:match("^(.*/)") or "/"
            prefix = search_dir
        else
            search_dir = expanded_input:match("^(.*/)") or "."
            prefix = input:match("^(.*/)") or ""
        end
    end

    local handle = vim.uv.fs_scandir(search_dir)
    if not handle then return {} end

    local entries = {}
    while true do
        local name, type_ = vim.uv.fs_scandir_next(handle)
        if not name then break end

        local item_path = prefix .. name
        local display_name = name

        if type_ == "directory" then
            item_path = item_path .. "/"
            display_name = display_name .. "/"
        end

        table.insert(entries, {
            display = display_name,
            value = item_path,
        })
    end

    return entries
end

return M
