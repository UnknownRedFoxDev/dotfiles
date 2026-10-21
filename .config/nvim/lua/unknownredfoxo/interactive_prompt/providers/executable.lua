local M = {}

--- Finds executables either in CWD (if input starts with "./") or in system $PATH
--- @param input string
--- @return table # List of { display = string, value = string }
function M.get_candidates(input)
    input = input or ""
    local candidates = {}

    if #input > 0 then
        local seen = {}

        -- Local CWD Executables (when the input starts with "./")
        if input:sub(1, 2) == "./" then
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
            local add = true
            if handle then
                while true do
                    add = true
                    local name, type_ = vim.uv.fs_scandir_next(handle)
                    if not name then break end

                    local full_path = search_dir .. "/" .. name
                    local display_name = name
                    local item_value = prefix .. name

                    if type_ == "directory" then
                        display_name = display_name .. "/"
                        item_value = item_value .. "/"
                    elseif vim.fn.executable(full_path) ~= 1 then
                        add = false
                    end

                    if add == true then
                        table.insert(candidates, {
                            display = display_name,
                            value = item_value,
                        })
                    end
                end
            end
            return candidates
        end

        -- $PATH Executables
        local path_env = os.getenv("PATH") or ""
        local paths = vim.split(path_env, ":", { trimempty = true })

        for _, dir in ipairs(paths) do
            local handle = vim.uv.fs_scandir(dir)
            if handle then
                while true do
                    local name, type_ = vim.uv.fs_scandir_next(handle)
                    if not name then break end

                    if not seen[name] then
                        local full_path = dir .. "/" .. name
                        if vim.fn.executable(full_path) == 1 then
                            seen[name] = true
                            table.insert(candidates, {
                                display = name,
                                value = name,
                            })
                        end
                    end
                end
            end
        end
    end
    return candidates
end

return M
