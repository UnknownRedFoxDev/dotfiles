return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate'
    }
}
-- return {
--     {
--         "nvim-treesitter/nvim-treesitter",
--         build = ":TSUpdate",
--         config = function()
--             require("nvim-treesitter.configs").setup({
--                 -- Add your treesitter configuration here (ensure_installed, highlight, etc.)
--                 highlight = { enable = true },
--                 indent = { enable = true },
--             })
--         end,
--     },
-- }
