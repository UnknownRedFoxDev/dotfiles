return {
    "X3eRo0/dired.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
        require("dired").setup({
            path_separator = "/",
            sort_order = "dirs",
            show_hidden = true,
            show_icons = true,
            override_cwd = true,
        })
    end,
}
