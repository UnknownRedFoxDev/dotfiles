local Prompt = require("unknownredfoxo.find_file.prompt")

describe("Prompt engine", function()
    it("empty prompt", function()
        local prompt = Prompt.new()

        assert.equals("", prompt:get_input())
        assert.equals(0, prompt:get_cursor()) end)

    it("prompt with character inserting and cursor updating", function()
        local prompt = Prompt.new()
        prompt:insert('a')
        prompt:insert('b')

        assert.equals("ab", prompt:get_input())
        assert.equals(2, prompt:get_cursor())
    end)

    it("prompt removing characters (backspace)", function()
        local prompt = Prompt.new()
        prompt:insert('a')
        prompt:insert('b')

        assert.equals("ab", prompt:get_input())
        assert.equals(2, prompt:get_cursor())

        prompt:backspace()
        assert.equals("a", prompt:get_input())
        assert.equals(1, prompt:get_cursor())
    end)

    it("prompt removing characters (delete)", function()
        local prompt = Prompt.new()
        prompt:insert('a')
        prompt:insert('b')

        assert.equals("ab", prompt:get_input())
        assert.equals(2, prompt:get_cursor())

        prompt:delete()
        assert.equals("a", prompt:get_input())
        assert.equals(1, prompt:get_cursor())
    end)

    it("fires on_change callback with input and candidates match test", function()
        local target_candidates = {"foo.lua", "bar.txt", "baz.c", "buzz.lua", "fiz.lua"}
        local matches = {}

        local prompt = Prompt.new({
            on_change = function(input)
                matches = {}
                for _, cand in ipairs(target_candidates) do
                    if cand:sub(1, #input) == input then
                        table.insert(matches, cand)
                    end
                end
            end,
        })

        prompt:insert('b')
        assert.same({"bar.txt", "baz.c", "buzz.lua"}, matches)
    end)
end)
