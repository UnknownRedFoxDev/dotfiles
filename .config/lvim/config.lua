lvim.colorscheme="duskfox"

-- Add tabby.nvim plugin
lvim.plugins = {
    {
        "EdenEast/nightfox.nvim"
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({
                options = {
                theme = "auto",
                component_separators = { left = '', right = '' },
                section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" }
                }
            })
        end,
    },
}

lvim.builtin.lir.active = false

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg and vim.fn.isdirectory(arg) == 1 then
      vim.cmd("Explore")
    end
  end,
})

-- Customize netwr.nvim (AI generated slop config btw)
vim.g.netrw_banner = 0        -- Hide the banner
vim.g.netrw_liststyle = 1     -- Tree-style view
vim.g.netrw_winsize = 15      -- Set window size to 25%

-- Always show tabline
vim.opt.tabstop = 4       -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4    -- Number of spaces for auto-indent
vim.opt.expandtab = true  -- Convert tabs to spaces
vim.opt.smartindent = true -- Enable smart indentation
vim.opt.autoindent = true -- Maintain indentation from previous line
lvim.builtin.autopairs.active = false
vim.opt.relativenumber = true

