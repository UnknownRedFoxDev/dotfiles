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

    it("handles nil input by evaluating all matches", function()
        local matches = { "app_one", "app_two" }
        assert.equals("app_", Completion.common_prefix(matches, nil))
    end)

    it("finds prefix across all matches when input is empty string", function()
        local matches = { "test_a", "test_b" }
        assert.equals("test_", Completion.common_prefix(matches, ""))
    end)

    it("returns empty string when input is empty and candidates share no prefix", function()
        local matches = { "apple", "banana" }
        assert.equals("", Completion.common_prefix(matches, ""))
    end)

    it("returns exact input when prefix candidates diverge immediately", function()
        local matches = { "fooA", "fooB" }
        assert.equals("foo", Completion.common_prefix(matches, "foo"))
    end)

    it("stops at the shortest exact match", function()
        local matches = { "foo", "foo_bar", "foo_baz" }
        assert.equals("foo", Completion.common_prefix(matches, "fo"))
    end)

    it("handles file paths and special symbols safely", function()
        local matches = { "dir/file.c", "dir/file.h" }
        assert.equals("dir/file.", Completion.common_prefix(matches, "dir/"))
    end)

    it("preserves candidate case even when input casing differs wildly", function()
        local matches = { "SYSTEM_A", "SYSTEM_B" }
        assert.equals("SYSTEM_", Completion.common_prefix(matches, "sySt"))
    end)

    it("ignores substring matches if prefix matches exist", function()
        local matches = { "app_main", "app_test", "sub_app_main" }
        assert.equals("app_", Completion.common_prefix(matches, "ap"))
    end)

    it("handles input longer than the matching candidates", function()
        local matches = { "foo" }
        assert.equals("foo", Completion.common_prefix(matches, "foo_bar"))
    end)

    it("handles inputs containing spaces", function()
        local matches = { "my file A", "my file B" }
        assert.equals("my file ", Completion.common_prefix(matches, "my "))
    end)end)

