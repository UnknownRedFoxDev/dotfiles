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
            local cwd = vim.fn.getcwd()
            local handle = vim.uv.fs_scandir(cwd)

            if handle then
                while true do
                    local name, type_ = vim.uv.fs_scandir_next(handle)
                    if not name then break end

                    -- Check if item is executable
                    local full_path = cwd .. "/" .. name
                    if vim.fn.executable(full_path) == 1 then
                        local exec_str = "./" .. name
                        table.insert(candidates, {
                            display = exec_str,
                            value = exec_str,
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
                        -- Verify executable status
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
