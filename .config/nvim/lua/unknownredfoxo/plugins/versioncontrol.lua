return {
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },
    {
        "NeogitOrg/neogit",
        lazy = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-mini/mini.pick",
        },
        cmd = "Neogit",
        config = function()
            require("neogit").setup({
                -- Options for 'kind':
                -- "split"    : Open in a horizontal split
                -- "vsplit"   : Open in a vertical split
                -- "floating" : Open in a floating window
                -- "replace"  : Replace the current window/buffer
                -- "tab"      : Open in a new tab page (default)
                kind = "split",

                popup = {
                    kind = "replace",
                },

                commit_view = {
                    kind = "replace",
                    verify_commit = "os_default",
                },

                log = {
                    kind = "replace",
                },

                reflog = {
                    kind = "replace",
                },
            })
        end,
    }
}
