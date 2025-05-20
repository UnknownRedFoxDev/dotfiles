
local duskfox = require("nightfox.palette").load("duskfox")

require('feline').setup({
  components = {
    active = {
      {
        { -- Left section
          provider = "vi_mode",
          icon = "",
          hl = { fg = duskfox.bg1, bg = duskfox.blue.base },
          right_sep = { str = " ", hl = { bg = duskfox.bg3 } }
        },
        { provider = "file_info", hl = { fg = duskfox.fg1 } }
      },
      {
        { -- Right section
          provider = "git_branch",
          icon = "󰘬",
          hl = { fg = duskfox.bg1, bg = duskfox.magenta.base },
          left_sep = { str = " ", hl = { bg = duskfox.bg3 } }
        },
        { provider = "git_diff_added", hl = { fg = duskfox.green.base } },
        { provider = "git_diff_removed", hl = { fg = duskfox.red.base } },
        { provider = "position", hl = { fg = duskfox.fg1 } }
      }
    }
  },
  theme = {
    bg = duskfox.bg1,
    fg = duskfox.fg1,
    vi_mode = {
      NORMAL = duskfox.blue.base,
      INSERT = duskfox.green.base,
      VISUAL = duskfox.magenta.base
    }
  }
})
