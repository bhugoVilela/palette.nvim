#!/usr/bin/env bash

if [ -z NVIM ]; then
	NVIM=nvim
fi

$NVIM --headless --clean -u ./tests/minimal_init.lua -c "PlenaryBustedDirectory tests/palette/ {minimal_init = './tests/minimal_init.lua', sequential = true}"
# $NVIM --clean -u ./tests/minimal_init.lua -c "PlenaryBustedDirectory tests/palette/ {minimal_init = './tests/minimal_init.lua', sequential = true}"
