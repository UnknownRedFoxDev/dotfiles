local Completion = require("unknownredfoxo.find_file.completion")

describe("Completion engine", function()
    local candidates = {
        "main.c",
        "test.txt",
        "init.lua",
        "lua/unknownredfoxo/init.lua",
        "lua/unknownredfoxo/find_file/prompt.lua",
        "lua/unknownredfoxo/find_file/ui.lua",
        "tests/prompt.lua",
        "ui/style.toml",
    }

    it("return empty candidates", function()
        local matches = Completion.filter("", candidates)
        assert.same(candidates, matches)
    end)

    it("filters candidates by prefix match", function()
        local matches = Completion.filter("main", candidates)
        assert.same({ "main.c" }, matches)
    end)

    it("filters candidates by substring match", function()
        local matches = Completion.filter("prompt", candidates)
        assert.same({ "lua/unknownredfoxo/find_file/prompt.lua", "tests/prompt.lua" }, matches)
    end)

    it("finds common prefix among a set of matches", function()
        local matches = { "foo_bar", "foo_baz", "foo_qux" }
        local common = Completion.common_prefix(matches)
        assert.equals("foo_", common)
    end)

    it("common prefix among nothing", function()
        assert.equals("", Completion.common_prefix({}))
    end)

    it("common prefix among one match", function()
        local common = Completion.common_prefix({ "foo_bar" })
        assert.equals("foo_bar", common)
    end)

end)

