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



vim.api.nvim_create_user_command("AddTodo", AddTodo, {})
vim.api.nvim_create_user_command("FindTODO", FindToDoByTimestamp, {})
vim.api.nvim_create_user_command("AlignRegex", AlignSections, { range = true, nargs = "?" })
vim.api.nvim_create_user_command("GrepByCwd", GrepByCwd, { range = true, nargs = "?" })
