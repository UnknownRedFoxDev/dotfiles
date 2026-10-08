local Prompt = require("unknownredfoxo.interactive_prompt.prompt")

describe("Prompt word-boundary navigation & deletion", function()
    local prompt

    before_each(function()
        prompt = Prompt.new()
    end)

    describe("<C-BS> / delete_word_left", function()
        it("deletes a word backward in standard text", function()
            prompt:set_input("hello world")
            prompt.cursor = 11 -- at end
            prompt:delete_prev_word()
            assert.equals("hello ", prompt.input)
            assert.equals(6, prompt.cursor)
        end)

        it("deletes path components and delimiters step-by-step", function()
            prompt:set_input("/home/user/.config/nvim/init.lua")
            prompt.cursor = #prompt.input -- 32

            -- Delete 'lua'
            prompt:delete_prev_word()
            assert.equals("/home/user/.config/nvim/init.", prompt.input)
            assert.equals(29, prompt.cursor)

            -- Delete 'init.'
            prompt:delete_prev_word()
            assert.equals("/home/user/.config/nvim/", prompt.input)
            assert.equals(24, prompt.cursor)

            -- Delete 'nvim/'
            prompt:delete_prev_word()
            assert.equals("/home/user/.config/", prompt.input)
            assert.equals(19, prompt.cursor)

            -- Delete 'config/'
            prompt:delete_prev_word()
            assert.equals("/home/user/.", prompt.input)
            assert.equals(12, prompt.cursor)
        end)

        it("handles deletion at start of input safely", function()
            prompt:set_input("hello")
            prompt.cursor = 0
            prompt:delete_prev_word()
            assert.equals("hello", prompt.input)
            assert.equals(0, prompt.cursor)
        end)
    end)

    describe("<C-Del> / delete_word_right", function()
        it("deletes a word forward in standard text", function()
            prompt:set_input("hello world")
            prompt.cursor = 0
            prompt:delete_next_word()
            assert.equals(" world", prompt.input)
            assert.equals(0, prompt.cursor)
        end)

        it("deletes forward path components from cursor", function()
            prompt:set_input("lua/find_file/init.lua")
            prompt.cursor = 0

            -- Delete 'lua'
            prompt:delete_next_word()
            assert.equals("/find_file/init.lua", prompt.input)
            assert.equals(0, prompt.cursor)

            -- Delete '/'
            prompt:delete_next_word()
            assert.equals("/init.lua", prompt.input)
            assert.equals(0, prompt.cursor)
        end)

        it("handles deletion at end of input safely", function()
            prompt:set_input("hello")
            prompt.cursor = 5
            prompt:delete_next_word()
            assert.equals("hello", prompt.input)
            assert.equals(5, prompt.cursor)
        end)
    end)

    describe("<C-Left> and <C-Right> movement", function()
        it("jumps back and forth across path boundaries correctly", function()
            prompt:set_input("/var/log/syslog")
            prompt.cursor = #prompt.input -- 15

            -- Move left to start of 'syslog'
            prompt:move_to_prev_word()
            assert.equals(10, prompt.cursor)

            -- Move left to start 'log'
            prompt:move_to_prev_word()
            assert.equals(6, prompt.cursor)

            -- Move left to start of 'var'
            prompt:move_to_prev_word()
            assert.equals(2, prompt.cursor)

            -- Move right to end of 'var' on '/'
            prompt:move_to_next_word()
            assert.equals(5, prompt.cursor)

            -- Move right to end of 'log' on '/'
            prompt:move_to_next_word()
            assert.equals(9, prompt.cursor)
        end)
    end)
end)
