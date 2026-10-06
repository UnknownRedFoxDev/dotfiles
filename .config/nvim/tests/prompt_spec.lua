local Prompt = require("unknownredfoxo.find_file.prompt")

describe("Prompt engine", function()
    it("empty prompt", function()
        local prompt = Prompt.new()

        assert.equals("", prompt:get_input())
        assert.equals(0, prompt:get_cursor()) end)

    it("adding characters and cursor updating", function()
        local prompt = Prompt.new()
        prompt:insert('a')
        prompt:insert('b')

        assert.equals("ab", prompt:get_input())
        assert.equals(2, prompt:get_cursor())
    end)

    it("removing characters (backspace)", function()
        local prompt = Prompt.new()
        prompt:insert("ab")

        assert.equals("ab", prompt:get_input())
        assert.equals(2, prompt:get_cursor())

        prompt:backspace()
        assert.equals("a", prompt:get_input())
        assert.equals(1, prompt:get_cursor())
    end)

    it("deletes the character under the cursor", function()
        local prompt = Prompt.new()
        prompt:insert("abc")
        prompt.cursor = 1
        prompt:delete()
        assert.equals("ac", prompt:get_input())
        assert.equals(1, prompt:get_cursor())
    end)

    it("does nothing when delete is pressed at the end of input", function()
        local prompt = Prompt.new()
        prompt:insert("abc")
        prompt:delete()
        assert.equals("abc", prompt:get_input())
        assert.equals(3, prompt:get_cursor())
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
