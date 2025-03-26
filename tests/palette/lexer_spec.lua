require('palette.utils.development').reload()
require('plenary.busted')
require('palette')
local Lexer = require('palette.lexer')



local warn = {
	untested = function(self) self("Test assertions weren't made") end,
	not_implemented = function(self) self("Test Not Implemented") end
}

setmetatable(warn, {
	__call = function(_, msg)
		print('WARN: '..msg)
	end
})

describe("Lexer", function()
	it("should return an empty array if the string is empty", function()
		local result = Lexer.runLexer("")
		assert.equals(#result, 0)
	end)

	it("should lex an identifier", function()
		local ids = { "a", "abc", "1", "123", "abc_-_abc" }

		for i = 1, #ids do
			local id = ids[i]
			local result = Lexer.runLexer(id)
			local lexem = result[1]
			assert.equals(#result, 1)
			assert.equals(lexem.start, Lexer.Position:new({ line = 1, col = 1 }))
			assert.equals(lexem.finish, Lexer.Position:new({ line = 1, col = #id }))
			assert.equals(lexem.tag, Lexer.TOKEN_IDENTIFIER)
			assert.equals(lexem.content, id)
		end
	end)

	it("should lex operands", function()
		local chars = { 
			{"=", Lexer.TOKEN_EQUALS},
			{",", Lexer.TOKEN_COMMA},
		    {"->", Lexer.TOKEN_DOT} 
		}

		for _, v in ipairs(chars) do
			local char = v[1]
			local tag = v[2]
			local expected = Lexer.Lexem:new({
				start = Lexer.Position:new({ col = 1, line = 1 }),
				finish = Lexer.Position:new({ col = #char, line = 1 }),
				content = char,
				tag = tag
			})
			local result = Lexer.runLexer(char)
			assert.equals(#result, 1, 'on '..char)
			assert.equals(expected, result[1])
		end
	end)

	it("should ignore non-indentation whitespace", function()
		local examples = {
			{1, "   \n"}, 
			{0, "   "},
			{2, "   abc  \n"},
			{2, "\t\n   \n\t"},
		}

		for _, v in ipairs(examples) do
			local numLexems = v[1]
			local str = v[2]

			local result = Lexer.runLexer(str)
			assert.equals(#result, numLexems, str .. " => " .. vim.inspect(result))
		end
	end)

	it("should parse a large example correctly", function()
		local str = "\n\nTermCursor       xxx links to NormalNC\n"
		.."SpecialKey \t xxx noexport guifg=NvimDarkGrey4 gui=bold,underline\n"
		.."  -- ignore this comments\n"
		.."-- ignore this comments as well\n"
		.."Cursor +=Normal->fg,Normal->bg --ignore this comment\n"
		.."\t noexport"
		-- .."\t   \n"
		--
		local expected = {
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=1,line=1}),
				finish = Lexer.Position:new({col=1,line=1}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=1,line=2}),
				finish = Lexer.Position:new({col=1,line=2}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'TermCursor',
				start = Lexer.Position:new({col=1,line=3}),
				finish = Lexer.Position:new({col=10,line=3}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'xxx',
				start = Lexer.Position:new({col=18,line=3}),
				finish = Lexer.Position:new({col=20,line=3}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'links',
				start = Lexer.Position:new({col=22,line=3}),
				finish = Lexer.Position:new({col=26,line=3}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'to',
				start = Lexer.Position:new({col=28,line=3}),
				finish = Lexer.Position:new({col=29,line=3}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'NormalNC',
				start = Lexer.Position:new({col=31,line=3}),
				finish = Lexer.Position:new({col=38,line=3}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=39,line=3}),
				finish = Lexer.Position:new({col=39,line=3}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'SpecialKey',
				start = Lexer.Position:new({col=1,line=4}),
				finish = Lexer.Position:new({col=10,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'xxx',
				start = Lexer.Position:new({col=14,line=4}),
				finish = Lexer.Position:new({col=16,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'noexport',
				start = Lexer.Position:new({col=18,line=4}),
				finish = Lexer.Position:new({col=25,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'guifg',
				start = Lexer.Position:new({col=27,line=4}),
				finish = Lexer.Position:new({col=31,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_EQUALS,
				content = '=',
				start = Lexer.Position:new({col=32,line=4}),
				finish = Lexer.Position:new({col=32,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'NvimDarkGrey4',
				start = Lexer.Position:new({col=33,line=4}),
				finish = Lexer.Position:new({col=45,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'gui',
				start = Lexer.Position:new({col=47,line=4}),
				finish = Lexer.Position:new({col=49,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_EQUALS,
				content = '=',
				start = Lexer.Position:new({col=50,line=4}),
				finish = Lexer.Position:new({col=50,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'bold',
				start = Lexer.Position:new({col=51,line=4}),
				finish = Lexer.Position:new({col=54,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_COMMA,
				content = ',',
				start = Lexer.Position:new({col=55,line=4}),
				finish = Lexer.Position:new({col=55,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'underline',
				start = Lexer.Position:new({col=56,line=4}),
				finish = Lexer.Position:new({col=64,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=65,line=4}),
				finish = Lexer.Position:new({col=65,line=4}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=26,line=5}),
				finish = Lexer.Position:new({col=26,line=5}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=32,line=6}),
				finish = Lexer.Position:new({col=32,line=6}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'Cursor',
				start = Lexer.Position:new({col=1,line=7}),
				finish = Lexer.Position:new({col=6,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = '+',
				start = Lexer.Position:new({col=8,line=7}),
				finish = Lexer.Position:new({col=8,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_EQUALS,
				content = '=',
				start = Lexer.Position:new({col=9,line=7}),
				finish = Lexer.Position:new({col=9,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'Normal',
				start = Lexer.Position:new({col=10,line=7}),
				finish = Lexer.Position:new({col=15,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_DOT,
				content = '->',
				start = Lexer.Position:new({col=16,line=7}),
				finish = Lexer.Position:new({col=17,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'fg',
				start = Lexer.Position:new({col=18,line=7}),
				finish = Lexer.Position:new({col=19,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_COMMA,
				content = ',',
				start = Lexer.Position:new({col=20,line=7}),
				finish = Lexer.Position:new({col=20,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'Normal',
				start = Lexer.Position:new({col=21,line=7}),
				finish = Lexer.Position:new({col=26,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_DOT,
				content = '->',
				start = Lexer.Position:new({col=27,line=7}),
				finish = Lexer.Position:new({col=28,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'bg',
				start = Lexer.Position:new({col=29,line=7}),
				finish = Lexer.Position:new({col=30,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_NEWLINE,
				content = '\n',
				start = Lexer.Position:new({col=53,line=7}),
				finish = Lexer.Position:new({col=53,line=7}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_INDENTATION,
				content = '\t ',
				start = Lexer.Position:new({col=1,line=8}),
				finish = Lexer.Position:new({col=2,line=8}),
			}),
			Lexer.Lexem:new({
				tag = Lexer.TOKEN_IDENTIFIER,
				content = 'noexport',
				start = Lexer.Position:new({col=3,line=8}),
				finish = Lexer.Position:new({col=10,line=8}),
			}),
		}

		local result = Lexer.runLexer(str)
		assert.are.same(expected, result)
	end)
end)

