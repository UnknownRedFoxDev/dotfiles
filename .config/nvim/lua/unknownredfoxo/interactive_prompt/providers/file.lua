local M = {}

--- Resolves files and directories dynamically based on the current input path
--- @param input string User prompt input
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

    local directories = {}
    local files = {}
    while true do
        local name, type_ = vim.uv.fs_scandir_next(handle)
        if not name then break end

        local display_name = name
        local item_path = prefix .. name

        if type_ == "directory" then
            display_name = display_name .. "/"
            item_path = item_path .. "/"
            table.insert(directories, {
                display = display_name,
                value = item_path,
            })
        else
            table.insert(files, {
                display = display_name,
                value = item_path,
            })
        end
    end

    -- Directories followed by files
    local entries = {}
    for _, entry in ipairs(directories) do table.insert(entries, entry) end
    for _, entry in ipairs(files) do table.insert(entries, entry) end

    return entries
end

return M
