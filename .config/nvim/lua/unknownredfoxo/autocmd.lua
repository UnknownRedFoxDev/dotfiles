vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "",
    group = vim.api.nvim_create_augroup("kickstart_highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local curPosBefore = vim.fn.getcurpos()
        vim.cmd("%s/\\s\\+$//e")
        vim.fn.setpos(".", curPosBefore)
    end,
})

vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "dired",
    callback = function()
        local full_path = vim.api.nvim_buf_get_name(0)
        local last_dir = vim.fn.fnamemodify(full_path, ":t")

        if last_dir == "" then
            last_dir = "root"
        end

        local new_name = "dired: " .. last_dir
        vim.api.nvim_buf_set_name(0, new_name)
    end,
})

_G.last_editor_win = vim.api.nvim_get_current_win()

vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    local buf = vim.api.nvim_win_get_buf(0)
    -- Only update if we are leaving a normal file, NOT our log window
    if not vim.b[buf].is_run_output and vim.bo[buf].buftype == "" and not vim.bo[buf].buftype == "terminal" then
      _G.last_editor_win = vim.api.nvim_get_current_win()
    end
  end,
})

vim.api.nvim_create_user_command("FindTask", FindTaskByHUID, {})
vim.api.nvim_create_user_command("AlignRegex", AlignSections, { range = true, nargs = "?" })
vim.api.nvim_create_user_command("GrepByCwd", GrepByCwd, { range = true, nargs = "?" })
