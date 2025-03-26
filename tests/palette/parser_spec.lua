require('plenary.busted')
require('palette')
local Lexer = require('palette.lexer')
local Parser = require('palette.parser')



local warn = {
	untested = function(self) self("Test assertions weren't made") end,
	not_implemented = function(self) self("Test Not Implemented") end
}

setmetatable(warn, {
	__call = function(_, msg)
		print('WARN: ' .. msg)
	end
})

describe("Parser", function()
	describe("parse_highlight", function()
		it("should fail to parse an empty string", function()
			local str = ""
			local result = Parser.run_parser_string(Parser.parse_highlight, str)
			assert.equals(result, nil)
		end)

		it("should fail to parse an highlight with name only", function()
			local str = "test"
			local result = Parser.run_parser_string(Parser.parse_highlight, str)
			assert.are_not.equals(result, nil)
			assert.equals(result.hl_name.content, 'test')
			assert.equals(Parser.isError(result.preview), true)
		end)

		it("should fail to parse an highlight with name and preview only", function()
			local str = "test xxx"
			local result = Parser.run_parser_string(Parser.parse_highlight, str)
			assert.are_not.equals(result, nil)
			assert.equals(Parser.isError(result.properties), true)
		end)

		it("should fail to parse an highlight with invalid shortcut", function()
			local str = "test xxx invalid"
			local result = Parser.run_parser_string(Parser.parse_highlight, str)
			assert.equals(#result.properties, 1)
			assert.equals(Parser.isError(result.properties[#result.properties]), true)
		end)
	end)
	describe("parse_file", function()
		it("works", function()
			local str = "\n\nTermCursor       xxx links to NormalNC\n"
				.. "SpecialKey \t xxx noexport guifg=NvimDarkGrey4 gui=bold,underline\n"
				.. "  -- ignore this comments\n"
				.. "-- ignore this comments as well\n"
				.. "Cursor xxx +=Normal->fg,Normal->bg --ignore this comment\n"
				.. "\t noexport"

			local hls, cursor = Parser.run_parser_string(Parser.parse_file, str)
			assert.equals(#hls, 3)

			local expect = { {
				hl_name = {
					content = "TermCursor",
					finish = {
						col = 10,
						line = 3,
					},
					start = {
						col = 1,
						line = 3,
					},
					tag = "Id",
				},
				preview = {
					content = "xxx",
					finish = {
						col = 20,
						line = 3,
					},
					start = {
						col = 18,
						line = 3,
					},
					tag = "Id",
				},
				properties = { {
					lexems = { {
						content = "links",
						finish = {
							col = 26,
							line = 3,
						},
						start = {
							col = 22,
							line = 3,
						},
						tag = "Id",
					}, {
						content = "to",
						finish = {
							col = 29,
							line = 3,
						},
						start = {
							col = 28,
							line = 3,
						},
						tag = "Id",
					}, {
						content = "NormalNC",
						finish = {
							col = 38,
							line = 3,
						},
						start = {
							col = 31,
							line = 3,
						},
						tag = "Id",
					} },
					value = {
						content = "NormalNC",
						finish = {
							col = 38,
							line = 3,
						},
						start = {
							col = 31,
							line = 3,
						},
						tag = "Id",
					},
				} },
			}, {
				hl_name = {
					content = "SpecialKey",
					finish = {
						col = 10,
						line = 4,
					},
					start = {
						col = 1,
						line = 4,
					},
					tag = "Id",
				},
				preview = {
					content = "xxx",
					finish = {
						col = 16,
						line = 4,
					},
					start = {
						col = 14,
						line = 4,
					},
					tag = "Id",
				},
				properties = { {
					property = {
						content = "noexport",
						finish = {
							col = 25,
							line = 4,
						},
						start = {
							col = 18,
							line = 4,
						},
						tag = "Id",
					},
				}, {
					property = {
						content = "guifg",
						finish = {
							col = 31,
							line = 4,
						},
						start = {
							col = 27,
							line = 4,
						},
						tag = "Id",
					},
					values = { {
						value = {
							content = "NvimDarkGrey4",
							finish = {
								col = 45,
								line = 4,
							},
							start = {
								col = 33,
								line = 4,
							},
							tag = "Id",
						},
					} },
				}, {
					property = {
						content = "gui",
						finish = {
							col = 49,
							line = 4,
						},
						start = {
							col = 47,
							line = 4,
						},
						tag = "Id",
					},
					values = { {
						value = {
							content = "bold",
							finish = {
								col = 54,
								line = 4,
							},
							start = {
								col = 51,
								line = 4,
							},
							tag = "Id",
						},
					}, {
						value = {
							content = "underline",
							finish = {
								col = 64,
								line = 4,
							},
							start = {
								col = 56,
								line = 4,
							},
							tag = "Id",
						},
					} },
				} },
			}, {
				hl_name = {
					content = "Cursor",
					finish = {
						col = 6,
						line = 7,
					},
					start = {
						col = 1,
						line = 7,
					},
					tag = "Id",
				},
				preview = {
					content = "xxx",
					finish = {
						col = 10,
						line = 7,
					},
					start = {
						col = 8,
						line = 7,
					},
					tag = "Id",
				},
				properties = { {
					property = {
						content = "+",
						finish = {
							col = 12,
							line = 7,
						},
						start = {
							col = 12,
							line = 7,
						},
						tag = "Id",
					},
					values = { {
						property = {
							content = "fg",
							finish = {
								col = 23,
								line = 7,
							},
							start = {
								col = 22,
								line = 7,
							},
							tag = "Id",
						},
						value = {
							content = "Normal",
							finish = {
								col = 19,
								line = 7,
							},
							start = {
								col = 14,
								line = 7,
							},
							tag = "Id",
						},
					}, {
						property = {
							content = "bg",
							finish = {
								col = 34,
								line = 7,
							},
							start = {
								col = 33,
								line = 7,
							},
							tag = "Id",
						},
						value = {
							content = "Normal",
							finish = {
								col = 30,
								line = 7,
							},
							start = {
								col = 25,
								line = 7,
							},
							tag = "Id",
						},
					} },
				}, {
					property = {
						content = "noexport",
						finish = {
							col = 10,
							line = 8,
						},
						start = {
							col = 3,
							line = 8,
						},
						tag = "Id",
					},
				} },
			} }

			assert.are.same(hls, expect)
		end)
	end)
end)
