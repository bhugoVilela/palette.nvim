.PHONY: test generate_filetypes lint luarocks_upload test_luarocks_install
test:
	mkdir -p ~/.config/nvim
	nvim --headless --clean -u ./tests/minimal_init.lua -c "PlenaryBustedDirectory tests/palette/ {minimal_init = './tests/minimal_init.lua', sequential = true}"

lint:
	luacheck lua/palette
