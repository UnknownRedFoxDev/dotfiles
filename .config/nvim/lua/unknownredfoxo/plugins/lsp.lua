return {
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
    {
        "saghen/blink.cmp",
        event = "VimEnter",
        version = "1.*",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                version = "2.*",
                build = (function()
                    if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then return end
                    return "make install_jsregexp"
                end)(),
            },
        },
        opts = {
            keymap = {
                preset = "super-tab",
                -- Override specific keys to disable snippet jumping
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
            },
            appearance = { nerd_font_variant = "mono" },
            sources = {
                default = { "lsp", "path", "snippets", "lazydev" },
                providers = {
                    lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            snippets = { preset = "luasnip" },
            signature = { enabled = true },
        },
    },
    { -- optional cmp completion source for require statements and module annotations
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
        end,
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'mason-org/mason.nvim',
                opts = {
                    ui = {
                        icons = {
                            package_installed = "✓",
                            package_pending = "➜",
                            package_uninstalled = "✗"
                        }
                    }
                }
            },
            { 'mason-org/mason-lspconfig.nvim' },
            { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
            {
                'j-hui/fidget.nvim',
                opts = {}
            },
            { 'saghen/blink.cmp' },
        },
        config = function()
            -- Paste your LspAttach autocmd and server configurations here
            -- local capabilities = require('blink.cmp').get_lsp_capabilities()

            local servers = {
                lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
                clangd = { cmd = { "clangd", "--background-index", "--clang-tidy" } }
            }

            -- Ensure tools are installed
            local ensure_installed = vim.tbl_keys(servers)
            vim.list_extend(ensure_installed, { 'stylua' })
            require('mason-tool-installer').setup({
                ensure_installed = ensure_installed
            })

            -- Setup servers
            require('mason-lspconfig').setup({
                ensure_installed = {},
                automatic_installation = false,
            })
        end,
    },
}
