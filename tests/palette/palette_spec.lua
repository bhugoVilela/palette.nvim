require('plenary.busted')
require('palette')


local warn = {
	untested = function(self) self("Test assertions weren't made") end,
	not_implemented = function(self) self("Test Not Implemented") end
}

setmetatable(warn, {
	__call = function(_, msg)
		print('WARN: '..msg)
	end
})

describe(":Palette new", function()
	it("opens the editor", function()
		vim.cmd [[colorscheme blue]]
		vim.cmd [[Palette new]]
		local filetype = vim.bo.filetype
		assert.equals(filetype, 'palette-nvim')
	end)

	describe("editor", function()
		it("has highlights", function()
			vim.cmd "colorscheme blue"
			vim.cmd [[Palette new]]
			vim.cmd [[silent! execute "norm /^ErrorMsg\<CR>fx"]]

			if not vim.cmd.Inspect then
				warn:untested()
				return
			end

			local pos = vim.fn.getpos('.')
			local ns = vim.api.nvim_get_namespaces()['palettenvim']
			local exts = vim.api.nvim_buf_get_extmarks(0, ns, {pos[2]-1, pos[3]-1}, {pos[2]-1, pos[3]-1}, { hl_name = true, details=true })
			assert.equals(#exts, 1)
			assert.equals(exts[1][4].hl_group, 'ErrorMsg')
		end)

		describe("update an highlight", function()
			before_each(function()
				vim.cmd "colorscheme blue"
				vim.cmd [[Palette new]]
				vim.cmd [[silent! execute "norm /^ErrorMsg\<CR>"]]
				vim.cmd [[silent! execute "norm /guibg\<CR>"]]
				vim.cmd [[silent! execute "norm f#lce0000ff"]]
				vim.cmd [[write]]
			end)

			it("updates the highlight", function()
				vim.cmd [[redir => g:res]]
				vim.cmd [[silent! hi ErrorMsg]]
				vim.cmd [[redir END]]
				assert.equals(vim.g.res, "\nErrorMsg       xxx ctermfg=231 ctermbg=160 guifg=#ffffff guibg=#0000ff")
			end)
		end)
	end)
end)

describe(":Palette export", function()
	before_each(function()
		vim.cmd "colorscheme blue"
		vim.cmd [[Palette new]]
		vim.cmd [[silent! execute "norm /^ErrorMsg\<CR>"]]
		vim.cmd [[silent! execute "norm /guibg\<CR>"]]
		vim.cmd [[silent! execute "norm f#lce0000ff"]]
		vim.cmd [[silent! execute "norm GoTESTHI xxx export=false guifg=red\<esc>"]]
		vim.cmd [[write]]
	end)

	it("should export a colorscheme to config/colors/theme_name.lua by default", function()
		local filepath = vim.fn.stdpath('config') .. '/colors/' .. 'test_theme.lua'
		vim.fn.system("rm " .. filepath)

		vim.cmd "Palette export test_theme"

		local fileExists = vim.fn.filereadable(filepath) == 1
		assert.equals(fileExists, true)

		vim.fn.system("rm " .. filepath)
	end)

	it("should export a colorscheme to expand(g:palette_config.export_path) if set", function()
		vim.g.palette_config = { export_path = './colors' }
		vim.cmd "Palette export test_theme"

		local filepath = vim.fn.expand("./colors/test_theme.lua")
		local fileExists = vim.fn.filereadable(filepath) == 1
		assert.equals(fileExists, true)

		vim.fn.system("rm -rf ./colors")
	end)

	it("should be able to apply the colorscheme after exporting", function()
		vim.cmd "Palette export test_theme"

		vim.cmd "colorscheme test_theme"

		assert.equals(vim.g.colors_name, "test_theme")
	end)

	it("should not export a color with export=false", function()
		vim.cmd "Palette export test_theme"
		vim.cmd "colorscheme test_theme"

		vim.cmd [[redir => g:res]]
		vim.cmd [[silent! hi ErrorMsg]]
		vim.cmd [[redir END]]

		if not vim.api or not vim.api.nvim_get_hl then
			warn:untested()
			return
		end

		local res = vim.api.nvim_get_hl(0, { name = 'TESTHI' })
		assert.equals(res[1], nil)
	end)
end)

describe("logic", function()
	before_each(function()
		vim.cmd [[colorscheme blue]]
		vim.cmd [[Palette new]]
		vim.cmd [[silent! execute "norm GO"]]
		vim.cmd [[silent! execute "norm /^ErrorMsg\<CR>"]]
		vim.cmd [[silent! execute "norm /guibg\<CR>"]]
		vim.cmd [[silent! execute "norm f#lce0000ff"]]
		vim.cmd [[write]]
	end)

	it("should add all declared properties correctly", function()
		local highlights = {
			TESTHI = 'guibg=red guifg=#00ff00 ctermfg=1 ctermbg=2 gui=bold,nocombine cterm=italic',
			TESTHI2 = 'fg=#0000ff bg=#00ff00 export=false ctermbg=2',
		}

		for name, value in pairs(highlights) do
			local cmd = "norm Go" .. name .. ' xxx ' .. value .. "\\<esc>"
			vim.cmd("execute " .. '"' .. cmd .. '"')
		end
		vim.cmd("write")

		if not vim.api or not vim.api.nvim_get_hl then
			warn:untested()
			return
		end

		local hi = vim.api.nvim_get_hl(0, { name = 'TESTHI' })
		assert.equals(hi.bg, 16711680)
		assert.equals(hi.fg, 65280)
		assert.equals(hi.ctermfg, 1)
		assert.equals(hi.ctermbg, 2)
		assert.equals(hi.cterm.italic, true)
		assert.equals(hi.nocombine, true)

		local hi2 = vim.api.nvim_get_hl(0, { name = 'TESTHI2' })
		assert.equals(hi2.bg, 65280)
		assert.equals(hi2.fg, 255)
		assert.equals(hi2.export, nil)
	end)

	it('include should include another highlight properties', function()
		local highlights = {
			{ name = 'TESTINC', value = 'ctermfg=1 ctermbg=2 gui=bold cterm=italic' },
			{ name = 'TESTINC2', value = 'gui=nocombine' },
			{ name = 'TESTHI',  value = 'ctermfg=3 gui=italic +=TESTINC,TESTINC2 cterm=bold'}
		}

		for idx, hi in ipairs(highlights) do
			local cmd = "norm Go" .. hi.name .. ' xxx ' .. hi.value .. "\\<esc>"
			vim.cmd("execute " .. '"' .. cmd .. '"')
		end
		vim.cmd("write")

		if not vim.api or not vim.api.nvim_get_hl then
			warn:untested()
			return
		end

		local hi = vim.api.nvim_get_hl(0, { name = 'TESTHI' })
		assert.equals(hi.ctermfg, 1)
		assert.equals(hi.ctermbg, 2)
		assert.equals(hi.bold, true)
		assert.equals(hi.nocombine, true)
		assert.equals(hi.italic, true)
		assert.equals(hi.cterm.italic, true)
		assert.equals(hi.cterm.bold, true)
	end)

	it("should error on an unknown property", function()
		warn:not_implemented()
	end)

	it("should error on a malformed property", function()
		warn:not_implemented()
	end)

	it("should error when linking to a noexport highlight", function()
		warn:not_implemented()
	end)

	it("should error on malformed lines", function()
		warn:not_implemented()
	end)
end)

describe(":Palette exportAsPlugin", function()
	before_each(function()
		vim.cmd "colorscheme blue"
		vim.cmd [[Palette new]]
		vim.cmd [[silent! execute "norm /^ErrorMsg\<CR>"]]
		vim.cmd [[silent! execute "norm /guibg\<CR>"]]
		vim.cmd [[silent! execute "norm f#lce0000ff"]]
		vim.cmd [[write]]
	end)

	it("should export as plugin", function()
		vim.cmd [[Palette exportAsPlugin theme_name .]]

		assert.equals(vim.fn.isdirectory('./theme_name'), 1)
		assert.equals(vim.fn.isdirectory('./theme_name/colors'), 1)
		assert.equals(vim.fn.filereadable('./theme_name/colors/theme_name.lua'), 1)
		assert.equals(vim.fn.filereadable('./theme_name/README.md'), 1)

		vim.fn.system("rm -rf ./theme_name")
	end)

	it("should overwrite with bang", function()
		vim.cmd [[Palette exportAsPlugin theme_name .]]
		vim.cmd [[Palette! exportAsPlugin theme_name .]]

		assert.equals(vim.fn.isdirectory('./theme_name'), 1)
		assert.equals(vim.fn.isdirectory('./theme_name/colors'), 1)
		assert.equals(vim.fn.filereadable('./theme_name/colors/theme_name.lua'), 1)
		assert.equals(vim.fn.filereadable('./theme_name/README.md'), 1)

		vim.fn.system("rm -rf ./theme_name")
	end)
end)

