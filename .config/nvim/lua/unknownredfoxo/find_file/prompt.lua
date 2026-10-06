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

return Prompt
