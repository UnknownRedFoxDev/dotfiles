return {
    { "nvim-lua/plenary.nvim" },
    {
        "nvim-telescope/telescope.nvim",
        config = function()
            require("telescope").setup({
                pickers = { find_files = { hidden = true } }
            })
        end
    },
}
