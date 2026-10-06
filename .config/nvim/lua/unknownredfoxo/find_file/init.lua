local ui = require("unknownredfoxo.find_file.ui")
local test_candidates = {
  "foo_ooo",
  "foo_bar",
  "foo_foo",
  "foo_baz",
}

local M = {}

--- Opens the interactive file prompt
--- @param opts table|nil Custom configuration options
function M.open(opts)
  opts = opts or {}
  ui.open({
      prompt = "Select fruit: ",
      candidates = test_candidates,
      on_submit = function(choice)
        print("Selected: " .. choice)
      end,
  })
end

return M
