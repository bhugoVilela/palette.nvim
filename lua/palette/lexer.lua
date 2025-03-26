local makeClass = require('palette.utils.oop').makeClass

local m = {}

m.TOKEN_IDENTIFIER = 'Id'
m.TOKEN_EQUALS = '='
m.TOKEN_DOT = '.'
m.TOKEN_COMMA = ','
m.TOKEN_NEWLINE = 'NL'
m.TOKEN_INDENTATION = 'Indent'

---@class Position
---@field col number
---@field line number
local Position = makeClass()
m.Position = Position

function Position:__eq(other)
  return self.col == other.col and self.line == other.line
end

---@class Lexem
---@field start Position
---@field finish Position
---@field content string
---@field tag string
local Lexem = makeClass()
m.Lexem = Lexem

function Lexem:__eq(other)
  return self.start == other.start
    and self.finish == other.finish
    and self.content == other.content
    and self.tag == other.tag
end

--- Lexes a string into tokens
--- @return Lexem[]
function m.runLexer(str)

  local line = 1
  local col = 1

  local lexems = {}
  local lexem = nil
  local expectIndent = false
  local isComment = false

  local function acceptLiteral(char, expect, tag, pos)
    if char == expect then
      -- insert previous lexem
      if lexem then
        local ignore = expect == '\n' and lexem.tag == m.TOKEN_INDENTATION
        if not ignore then
          table.insert(lexems, lexem)
        end
        lexem = nil
      end
      table.insert(lexems, Lexem:new({
        start = pos,
        finish = Position:new({ line = pos.line, col = pos.col + #char - 1}),
        tag = tag,
        content = char
      }))
      return true
    end
    return false
  end

  for i = 1, #str do
    local c = str:sub(i,i)
    local pos = Position:new({ line = line, col = col })

    if c == '-' and #str > i and str:sub(i+1, i+1) == '-' then
      if lexem and lexem.tag ~= m.TOKEN_INDENTATION then
        table.insert(lexems, lexem)
      end
      lexem = nil
      isComment = true
    end

    if isComment and c ~= '\n' then
      goto continue
    end

    if acceptLiteral(c, '\n', m.TOKEN_NEWLINE, pos) 
      or acceptLiteral(c, '=', m.TOKEN_EQUALS, pos)
      or acceptLiteral(c, '->', m.TOKEN_DOT, pos)
      or acceptLiteral(c, ',', m.TOKEN_COMMA, pos) then
      isComment = false
      expectIndent = c == '\n'
    elseif (c == ' ' or c == '\t') then
      if lexem and lexem.tag ~= m.TOKEN_INDENTATION then
        table.insert(lexems, lexem)
        lexem = nil
      end

      if expectIndent then
        if lexem == nil then
          lexem = Lexem:new({
            tag = m.TOKEN_INDENTATION,
            start = pos,
            finish = pos,
            content = c
          })
        else
          lexem.content = lexem.content..c
          lexem.finish = pos
        end
      else --skip whitespace
        --noop
      end
    else --isIdentifier
      expectIndent = false
      if lexem and lexem.tag ~= m.TOKEN_IDENTIFIER then
        table.insert(lexems, lexem)
        lexem = nil
      end
      if not lexem then
        lexem = Lexem:new({
          tag = m.TOKEN_IDENTIFIER,
          start = pos,
          finish = pos,
          content = c
        })
      else
        lexem.content = lexem.content..c
        lexem.finish = pos
      end
    end

    ::continue::
    if c == '\n' then
      line = line + 1
      col = 1
    else
      col = col + 1
    end
  end

  if lexem and lexem.tag ~= m.TOKEN_INDENTATION then
    table.insert(lexems, lexem)
  end

  return lexems
end

return m
