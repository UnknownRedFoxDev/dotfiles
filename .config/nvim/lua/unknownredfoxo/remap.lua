vim.keymap.set("n", "<leader>fe", vim.cmd.Dired)
vim.keymap.set("n", "<leader>w", vim.cmd.w)
vim.keymap.set("n", "<leader>q", vim.cmd.q)

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gg", vim.cmd.LazyGit)
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<Esc>", vim.cmd.nohlsearch)
vim.keymap.set("n", "<C-c>", vim.cmd.nohlsearch)

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope fuzzy find git files" })
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
vim.keymap.set("n", "<C-K>", "yyP", { noremap = true, silent = true })
vim.keymap.set("n", "<C-J>", "yyp", { noremap = true, silent = true })

vim.keymap.set("n", "<A-t>", AddTodo)
vim.keymap.set("n", "<A-f>", FindToDoByTimestamp)

-- Updated Mapping: This calls the command which then triggers the prompt
vim.keymap.set("v", "<Leader>a", ":AlignRegex<CR>", { silent = true })
