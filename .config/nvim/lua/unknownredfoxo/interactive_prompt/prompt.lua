local Prompt = {}
Prompt.__index = Prompt

function Prompt.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Prompt)

    self.input = ""
    self.cursor = 0
    self.on_change = opts.on_change or function(_) end
    self.on_submit = opts.on_submit or function(_) end
    self.on_cancel = opts.on_cancel or function() end

    return self
end

function Prompt:set_input(text)
    if #text == 0 then return end
    self.input = text
    self.cursor = #text
end

function Prompt:get_input()
    return self.input
end

function Prompt:get_cursor()
    return self.cursor
end

function Prompt:insert(text)
    local head = self.input:sub(1, self.cursor)
    local tail = self.input:sub(self.cursor + 1)

    self.input = head .. text .. tail
    self.cursor = self.cursor + #text
    self.on_change(self.input)
end

function Prompt:backspace()
    if self.cursor <= 0 then
        return
    end

  local head = self.input:sub(1, self.cursor - 1)
  local tail = self.input:sub(self.cursor + 1)

  self.input = head .. tail
  self.cursor = self.cursor - 1
  self.on_change(self.input)
end

function Prompt:delete()
    if self.cursor >= #self.input then
        return
    end

  local head = self.input:sub(1, self.cursor)
  local tail = self.input:sub(self.cursor + 2)

  self.input = head .. tail
  self.on_change(self.input)
end

function Prompt:submit()
    self.on_submit(self.input)
end

function Prompt:cancel()
    self.on_cancel()
end

--- Classifies a character into a grouping ID for boundary checks
--- @param char string|nil Single character string
--- @return integer
local function char_class(char)
    if not char or char == ""    then return 0 end
    if char:match("%s")          then return 1 end  -- Whitespace
    if char:match("[%w_]")       then return 2 end  -- Word chars (letters, digits, _)
    if char:match("[/\\%.%-%:]") then return 3 end  -- Delimiters / Path separators
    return 4  -- Other symbols/punctuation
end

--- Finds previous boundary position moving left from cursor
--- @return integer # New 0-indexed cursor position
function Prompt:get_prev_word_pos()
    if self.cursor <= 0 then return 0 end

    local str = self.input
    local pos = self.cursor-1

    while pos > 0 and char_class(str:sub(pos, pos)) ~= 2 do
        pos = pos - 1
    end

    local target_class = char_class(str:sub(pos, pos))
    while pos > 0 and char_class(str:sub(pos, pos)) == target_class do
        pos = pos - 1
    end

    return pos
end

--- Finds next boundary position moving right from cursor
--- @return integer # New 0-indexed cursor position
function Prompt:get_next_word_pos()
    local len = #self.input
    if self.cursor >= len then return len end

    local str = self.input
    local pos = self.cursor + 1

    while pos <= len and char_class(str:sub(pos, pos)) ~= 2 do
        pos = pos + 1
    end

    local target_class = char_class(str:sub(pos, pos))
    while pos <= len and char_class(str:sub(pos, pos)) == target_class do
        pos = pos + 1
    end

    return pos - 1
end

function Prompt:move_to_prev_word()
    self.cursor = self:get_prev_word_pos()+1
end

function Prompt:move_to_next_word()
    self.cursor = self:get_next_word_pos()+1
end

function Prompt:delete_prev_word()
    if self.cursor <= 0 then return end -- can't delete what's not present

    local prev_pos = self:get_prev_word_pos()
    self.input = self.input:sub(1, prev_pos) .. self.input:sub(self.cursor + 1)
    self.cursor = prev_pos
end

function Prompt:delete_next_word()
    if self.cursor >= #self.input then return end -- can't delete what's not present

    local next_pos = self:get_next_word_pos()
    self.input = self.input:sub(1, self.cursor) .. self.input:sub(next_pos + 1)
end

function Prompt:set_history(history_table)
    self.history = history_table or {}
    self.history_idx = #self.history + 1
    self.saved_typed_input = nil
end

--- Navigates UP in history
function Prompt:history_up()
    if #self.history == 0 then return end

    -- Stash current draft input if leaving the bottom of history
    if self.history_idx > #self.history then
        self.saved_typed_input = self.input
    end

    if self.history_idx > 1 then
        self.history_idx = self.history_idx - 1
        self.input = self.history[self.history_idx]
        self.cursor = #self.input
    end
end

--- Navigates DOWN in history
function Prompt:history_down()
    if #self.history == 0 or self.history_idx > #self.history then return end

    self.history_idx = self.history_idx + 1

    if self.history_idx > #self.history then
        -- Restore saved draft
        self.input = self.saved_typed_input or ""
    else
        self.input = self.history[self.history_idx]
    end

    self.cursor = #self.input
end

--- Pushes a newly submitted value into history
function Prompt:add_history(value)
    if not value or value == "" then return end
    if self.history[#self.history] ~= value then
        table.insert(self.history, value)
    end
end

return Prompt
