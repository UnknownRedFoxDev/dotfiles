vim.keymap.set("n", "<leader>fe", vim.cmd.Dired)
vim.keymap.set("n", "<leader>w", vim.cmd.w)
vim.keymap.set("n", "<leader>q", vim.cmd.q)

-- vim.keymap.set("n", "<leader>gg", vim.cmd.LazyGit)
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit UI" })
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<Esc>", vim.cmd.nohlsearch)
vim.keymap.set("n", "<C-c>", vim.cmd.nohlsearch)

vim.keymap.set("n", "<A-b>", function()
    require("unknownredfoxo.find_file").select_buffer()
end, { desc = "Find buffer" })

vim.keymap.set("n", "<Leader>ff", function()
    require("unknownredfoxo.find_file").select_file()
end, { desc = "Find file" })

vim.keymap.set("n", "<A-x>", function()
    require("unknownredfoxo.find_file").select_executable()
end, { desc = "Find file" })

vim.keymap.set("n", "<A-f>", function ()
    require("telescope.builtin").find_files()
end)

vim.keymap.set("n", "<A-p>", function()
    require("telescope.builtin").git_files()
end)
vim.keymap.set("n", "<leader>fs", GrepByCwd)

-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
vim.keymap.set("n", "[d", vim.cmd.cprev)
vim.keymap.set("n", "]d", vim.cmd.cnext)
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, {})

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-K>", function()
    local line = vim.api.nvim_get_current_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, { line })
    vim.api.nvim_win_set_cursor(0, { row, 0 })
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-J>", function()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { line })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end, { noremap = true, silent = true })


vim.keymap.set("v", "<Leader>a", ":'<,'>AlignRegex<CR>", { silent = true })
vim.keymap.set("n", "<A-X>", RunLastCommandRan)
vim.keymap.set("n", "<C-s>", DisplayScratch, {silent = true})

vim.keymap.set('n', '<A-J>', OpenFileUnderCursor, { silent = true, noremap = true })
vim.keymap.set('n', '<A-F>', FindFile)
vim.keymap.set('n', '<A-e>', FindFirstError)
vim.keymap.set('n', '<A-w>', SwitchSplitToMain)

vim.keymap.set('n', '<A-t>c', newTask)
vim.keymap.set("n", "<A-t>f", FindTaskByHUID)
vim.keymap.set('n', '<A-t>F', CreateTaskFromComment)
