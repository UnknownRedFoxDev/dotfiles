-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.builtin.lualine.active = "none"
lvim.colorscheme = "duskfox"

lvim.builtin.bufferline.active = false
-- lvim.builtin.bufferline.options.mode = "buffers"

require("tabby").setup({
    tabline = require("tabby.presets").active_wins_at_tail,
    options = {
        enforce_regular_tabs = true
    }
})

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
        end
    },
    {
        "nanozuki/tabby.nvim",
        config = function()
            local theme = {
              fill = 'TabLineFill',
              -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
              head = 'TabLine',
              current_tab = 'TabLineSel',
              tab = 'TabLine',
              win = 'TabLine',
              tail = 'TabLine',
            }
            require('tabby').setup({
              line = function(line)
                return {
                  {
                    { '  ', hl = theme.head },
                    line.sep('', theme.head, theme.fill),
                  },
                  line.tabs().foreach(function(tab)
                    local hl = tab.is_current() and theme.current_tab or theme.tab
                    return {
                      line.sep('', hl, theme.fill),
                      tab.is_current() and '' or '󰆣',
                      tab.number(),
                      tab.name(),
                      tab.close_btn(''),
                      line.sep('', hl, theme.fill),
                      hl = hl,
                      margin = ' ',
                    }
                  end),
                  line.spacer(),
                  line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                    return {
                      line.sep('', theme.win, theme.fill),
                      win.is_current() and '' or '',
                      win.buf_name(),
                      line.sep('', theme.win, theme.fill),
                      hl = theme.win,
                      margin = ' ',
                    }
                  end),
                  {
                    line.sep('', theme.tail, theme.fill),
                    { '  ', hl = theme.tail },
                  },
                  hl = theme.fill,
                }
              end,
              -- option = {}, -- setup modules' option,
            })
        end,
        event = "UIEnter",
        priority = 1000
    }
}

vim.opt.tabstop = 4       -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4    -- Number of spaces for auto-indent
vim.opt.expandtab = true  -- Convert tabs to spaces
vim.opt.smartindent = true -- Enable smart indentation
vim.opt.autoindent = true -- Maintain indentation from previous line
lvim.builtin.autopairs.active = false
vim.opt.relativenumber = true


vim.o.showtabline = 2
-- Use modern preset (avoids legacy code)
-- require("tabby").setup({
--     tabline = require("tabby.presets").active_wins_at_tail
-- })

-- local theme = {
--   fill = 'TabLineFill',
--   -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
--   head = 'TabLine',
--   current_tab = 'TabLineSel',
--   tab = 'TabLine',
--   win = 'TabLine',
--   tail = 'TabLine',
-- }
-- require('tabby').setup({
--   line = function(line)
--     return {
--       {
--         { '  ', hl = theme.head },
--         line.sep('', theme.head, theme.fill),
--       },
--       line.tabs().foreach(function(tab)
--         local hl = tab.is_current() and theme.current_tab or theme.tab
--         return {
--           line.sep('', hl, theme.fill),
--           tab.is_current() and '' or '󰆣',
--           tab.number(),
--           tab.name(),
--           tab.close_btn(''),
--           line.sep('', hl, theme.fill),
--           hl = hl,
--           margin = ' ',
--         }
--       end),
--       line.spacer(),
--       line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
--         return {
--           line.sep('', theme.win, theme.fill),
--           win.is_current() and '' or '',
--           win.buf_name(),
--           line.sep('', theme.win, theme.fill),
--           hl = theme.win,
--           margin = ' ',
--         }
--       end),
--       {
--         line.sep('', theme.tail, theme.fill),
--         { '  ', hl = theme.tail },
--       },
--       hl = theme.fill,
--     }
--   end,
--   -- option = {}, -- setup modules' option,
-- })

