local palette_filetype = 'palette-nvim'
local palette_file_extension = 'palettenvim'

local PaletteNvimGroup = vim.api.nvim_create_augroup("PaletteNvim", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = palette_filetype,
	group = PaletteNvimGroup,
	callback = function()
		require('palette').on_buffer_update()
		require('palette').set_on_buffer_write(0, PaletteNvimGroup)
	end
})

vim.api.nvim_create_user_command('Palette', function(opts)
	require('palette').palette_user_command(opts)
end, { nargs = '+', desc = 'palette.nvim command', bang = true })

