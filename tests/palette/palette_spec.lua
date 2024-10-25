require('plenary.busted')
require('palette')

describe(":Palette new", function()
	it("opens the editor", function()
		vim.cmd [[Palette new]]
		local filetype = vim.bo.filetype
		assert.equals(filetype, 'palette-nvim')
	end)

	describe("editor", function()
		it("has highlights", function()
			vim.cmd "colorscheme blue"
			vim.cmd [[Palette new]]
			vim.cmd [[silent! execute "norm /^ErrorMsg\<CR>"]]

			vim.cmd [[redir => g:test_hi]]
			vim.cmd [[silent! Inspect]]
			vim.cmd [[redir END]]

			local highlight = vim.g.test_hi:match('%s+- (%S+)')
			assert.equals(highlight, "ErrorMsg")
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
		vim.cmd [[write]]
	end)

	it("should export a colorscheme to config/colors/theme_name.lua by default", function()
		vim.cmd "Palette export test_theme"

		local filepath = vim.fn.stdpath('config')..'/colors/'..'test_theme.lua'
		local fileExists = vim.fn.filereadable(filepath) == 1
		assert.equals(fileExists, true)

		vim.fn.system("rm "..filepath)
	end)

	it("should export a colorscheme to expand(g:palette_theme_export_path) if set", function()
		vim.g.palette_theme_export_path = './colors'
		vim.cmd "Palette export test_theme"

		local filepath = vim.fn.expand("./colors/test_theme.lua")
		local fileExists = vim.fn.filereadable(filepath) == 1
		assert.equals(fileExists, true)

		vim.fn.system("rm -rf ./colors")
	end)

	it("should be able to apply the colorscheme after exporting", function()
		vim.g.palette_theme_export_path = './colors'
		vim.cmd "Palette export test_theme"

		vim.cmd "colorscheme test_theme"

		assert.equals(vim.g.colors_name, "test_theme")

		vim.fn.system("rm -rf ./colors")
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
