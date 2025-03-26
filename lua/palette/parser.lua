--force reload all packages
require('palette.utils.development').reload()
local Lexer = require('palette.lexer')
local oop = require('palette.utils.oop')

--- map of keywords that are allowed as short assignments
local SHORT_ASSIGNMENTS = {
  ["noexport"] = true,
  ["cleared"] = true,
}

local m = {}

---@class NodeProperty
---@field tag string

--- ie. <name> = <NodeValue> [,<NodeValue>]*
---@class NodePropertyAssignment: NodeProperty
---@field tag "NODE_PROPERTY_ASSIGNMENT"
---@field property Lexem
---@field values NodeValue[]
local NodePropertyAssignment = {
  tag = "NODE_PROPERTY_ASSIGNMENT"
}
m.NodePropertyAssignment = NodePropertyAssignment

---@param property: Lexem
---@param values: NodeValue
function NodePropertyAssignment:new(property, values)
  return oop.new(self, {
    property = property,
    values = values
  })
end

--- ie. noexport
---@class NodeShortAssignment: NodeProperty
---@field tag "NODE_SHORT_ASSIGNMENT"
---@field property Lexem
local NodeShortAssignment = {
  tag = "NODE_SHORT_ASSIGNMENT"
}
m.NodeShortAssignment = NodeShortAssignment

---@param property: Lexem
function NodeShortAssignment:new(property)
  return oop.new(self, {
    property = property
  })
end

--- <value>[-><property>]
--- ie. red
--- ie. #ff00000
--- ie. Normal->bg
---@class NodeValue
---@field tag "NODE_VALUE"
---@field value Lexem
---@field property? Lexem
local NodeValue = {
  tag = "NODE_VALUE"
}
m.NodeValue = NodeValue

---@param value Lexem
---@param property? Lexem
function NodeValue:new(value, property)
  return oop.new(self, {
    value = value,
    property= property
  })
end

--- ie. links to <highlight_name>
---@class NodeExtendedLink
---@field tag "NODE_EXTENDED_LINK"
---@field lexems Lexem[]
---@field value Lexem
local NodeExtendedLink = {
  tag = "NODE_EXTENDED_LINK"
}
m.NodeExtendedLink = NodeExtendedLink

---@param lexems Lexem[]
function NodeExtendedLink:new(lexems)
  return oop.new(self, {
    lexems = lexems,
    value = lexems[#lexems]
  })
end

--- ie. <highlight_name> <preview> <NodeProperty>+
---@class NodeHighlight
---@field tag "NODE_HL"
---@field hl_name Lexem
---@field preview Lexem
---@field properties NodeProperty[]
local NodeHighlight = {
  tag = "NODE_HL"
}
m.NodeHighlight = NodeHighlight

---@param hl_name Lexem
---@param preview Lexem
---@param properties NodeProperty[]
function NodeHighlight:new(hl_name, preview, properties)
  return oop.new(self, {
    hl_name = hl_name,
    preview = preview,
    properties = properties
  })
end


---@class ErrorNode
---@field tag "ERROR"
---@field expected string
---@field message string
local ErrorNode = {
  tag = "ERROR"
}
m.ErrorNode = ErrorNode

function ErrorNode:new(expected, message)
  return oop.new(self, {
    expected = expected,
    message = message
  })
end

local function isError(node)
  return node and node.tag == "ERROR"
end
m.isError = isError


--- A cursor that points to the next Lexem to be processed
---@class LexerCursor
---@field idx number 
---@field lexems Lexem[]
local LexerCursor = {}

---@param lexems Lexem[]
---@param idx? number
function LexerCursor:new(lexems, idx)
  return oop.new(self, {
    lexems = lexems,
    idx = idx or 1
  })
end

function LexerCursor:has_next()
  return self.idx < #self.lexems
end

--- get next lexem without advancing the cursor
function LexerCursor:peek(n)
  n = n or 0
  return self.lexems[self.idx + n]
end

--- get and transform next lexem without advancing the cursor
function LexerCursor:peekWith(fn, n)
  n = n or 0
  local res = self.lexems[self.idx + n]
  return res and fn(res) or nil
end

--- get next lexem and advance the cursor
function LexerCursor:advance()
  local lexem = self:peek()
  self.idx = self.idx + 1
  return lexem
end

--- get next N lexems and advance cursor
function LexerCursor:advanceN(n) 
  if n < 1 then
    error("tried to advance negative amount of tokens")
  end

  if self.idx + n - 1 > #self.lexems then
    return nil
  end

  local lexems = {}
  for _ = 1, n do
    table.insert(lexems, self:advance())
  end
  return lexems
end

--- get and transform next lexem and advance cursor
function LexerCursor:advanceWith(fn)
  local lexem = self:peek()
  self.idx = self.idx + 1
  return lexem and fn(lexem) or nil
end

function LexerCursor:clone()
  return LexerCursor:new(self.lexems, self.idx)
end

--- modify current cursor to point to the same position
--- as the one passed in
---@param cursor LexerCursor
function LexerCursor:go_to(cursor)
  self.lexems = cursor.lexems
  self.idx = cursor.idx
end

--- @param cursor LexerCursor
local function parse_short_link(cursor)
  local backup = cursor:clone()

  local lexems = cursor:advanceN(3)

  if lexems 
    and lexems[1].content == "links"
    and lexems[2].content == "to"
    and lexems[3].tag == Lexer.TOKEN_IDENTIFIER then
    return NodeExtendedLink:new(lexems)
  end

  cursor:go_to(backup)
end

local function parse_value(cursor) 
  local backup = cursor:clone()
  local value = cursor:advance()
  local property = nil

  if not value or value.tag ~= Lexer.TOKEN_IDENTIFIER then
    cursor:go_to(backup)
    return
  end
  
  if cursor:peekWith(oop.tryGet('tag')) == Lexer.TOKEN_DOT then
    cursor:advance()
    property = cursor:peek()
    if not property or property.tag ~= Lexer.TOKEN_IDENTIFIER then
      property = ErrorNode("TOKEN_IDENTIFIER", "expected a property after a dot (.)")
    else
      property = cursor:advance()
    end
  end

  return NodeValue:new(value, property)
end

---@param cursor LexerCursor
local function parse_assignment(cursor)
  local backup = cursor:clone()

  local id = cursor:advance()
  if not id or id.tag ~= Lexer.TOKEN_IDENTIFIER then
    cursor:go_to(backup)
    return
  end

  if cursor:advanceWith(oop.tryGet('tag')) ~= Lexer.TOKEN_EQUALS then
    cursor:go_to(backup)
    return
  end

  local values = {}
  local expects_more = true

  while expects_more do
    local value = parse_value(cursor)
    if value then
      table.insert(values, value)

      if cursor:peekWith(oop.tryGet('tag')) == Lexer.TOKEN_COMMA then
        cursor:advance()
      else
        expects_more = false
      end
    else
      table.insert(values, ErrorNode:new("NodeValue", "missing property"))
      expects_more = false
    end
  end

  if #values > 0 then
    return NodePropertyAssignment:new(id, values)
  else
    return NodePropertyAssignment:new(id, { ErrorNode:new("NodeValue", "Expected at least one property after =")})
  end
end

---@param cursor LexerCursor
---@return boolean wether to continue or not
local function skip_continuation(cursor)
  local found_new_line = false
  while cursor:peekWith(oop.tryGet "content") == '\n' do
    found_new_line = true
    cursor:advance()
  end
  if not found_new_line then
    return true
  elseif cursor:peekWith(oop.tryGet "tag") == Lexer.TOKEN_INDENTATION then
    cursor:advance()
    return true
  end

  return false
end

local function parse_short_assignment(cursor) 
  local a = cursor:peek()
  if a and SHORT_ASSIGNMENTS[a.content] then
    return NodeShortAssignment:new(cursor:advance())
  end
  return nil
end

---@param cursor LexerCursor
local function parse_highlight(cursor)
  local backup = cursor:clone()

  local hl_name = backup:advance()

  if not hl_name or hl_name.tag ~= Lexer.TOKEN_IDENTIFIER then
    return nil
  end

  local preview = backup:advance()

  if not preview or preview.tag ~= Lexer.TOKEN_IDENTIFIER then
    return nil
  end

  local properties = {}

  local continue = true
  while continue and skip_continuation(backup) do
    local property = parse_short_link(backup) or parse_assignment(backup) or parse_short_assignment(backup)
    continue = not not property
    if property then
      table.insert(properties, property)
    end
  end


  -- advance cursor
  cursor:go_to(backup)
  return NodeHighlight:new(hl_name, preview, properties)
end

---@param cursor LexerCursor
local function parse_file(cursor)
  local highlights = {}
  local has_more = true
  while has_more do
    while cursor:peekWith(oop.tryGet "tag") == Lexer.TOKEN_NEWLINE do
      cursor:advance()
    end
    local hl = parse_highlight(cursor)

    if hl then
      table.insert(highlights, hl)
    else
      has_more = false
    end
  end
  return highlights[#highlights]
end

m.parse_highlight = parse_highlight
m.parse_file = parse_file

-- local str = "links to red"
-- print(vim.inspect(
--   parse_short_link(LexerCursor:new(Lexer.runLexer(str)))
-- ))


-- local str = "bg.red"
-- print(vim.inspect(
--   parse_value(LexerCursor:new(Lexer.runLexer(str)))
-- ))

-- local str = "bg"
-- print(vim.inspect(
--   parse_assignment(LexerCursor:new(Lexer.runLexer(str)))
-- ))

-- local str = "highlight xxx bg=red fg=blue +=normal.bold\nlinks to lmao"
-- print(vim.inspect(
--   parse_highlight(LexerCursor:new(Lexer.runLexer(str)))
-- ))

-- local str = io.open( "/home/bhugo/code/nvim-plugins/palette.nvim/test.hl","r"):read("*a")
-- print(vim.inspect(
--   parse_file(LexerCursor:new(Lexer.runLexer(str)))
-- ))
--
local str = io.open( "/home/bhugo/code/nvim-plugins/palette.nvim/test.hl","r"):read("*a")

require('palette.utils.development').measure_time(function ()
  parse_file(LexerCursor:new(Lexer.runLexer(str)))
end)

return m
