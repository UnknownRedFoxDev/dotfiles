local M = {}

function M.get_buffer_directory(buf)
    buf = buf or vim.api.nvim_get_current_buf()

    local buftype = vim.bo[buf].buftype
    if buftype ~= "" then return nil end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then return nil end

    local stat = vim.uv.fs_stat(name)
    if not stat then return nil end

    if stat.type == "directory" then
        return vim.fn.fnamemodify(name, ":p")
    else
        return vim.fn.fnamemodify(name, ":p:h")
    end
end

function M.sync_cwd(buf)
    local dir = M.get_buffer_directory(buf)
    if dir and dir ~= "" and dir ~= vim.fn.getcwd() then
        pcall(vim.api.nvim_set_current_dir, dir)
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("EmacsBufferCwd", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = group,
        callback = function(ev)
            M.sync_cwd(ev.buf)
        end,
    })
end

return M
