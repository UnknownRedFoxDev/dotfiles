local M = {}

--- Resolves files and directories dynamically based on the current input path
--- @param input string Current prompt input
--- @return table # Array of relative paths/filenames
function M.get_candidates(input)
    input = input or ""

    local search_dir = "."
    local prefix = ""

    if input:find("/") then
        search_dir = input:match("^(.*/)") or "."
        prefix = search_dir
    end

    local expanded_dir = vim.fn.expand(search_dir)
    local handle = vim.uv.fs_scandir(expanded_dir)
    if not handle then return {} end

    local entries = {}
    while true do
        local name, type_ = vim.uv.fs_scandir_next(handle)
        if not name then break end

        local item_path = (prefix == "" or prefix == "./") and name or (prefix .. name)
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
