#!/usr/bin/env bash

if [ -z "$NVIM_EXE" ]; then
	NVIM_EXE=nvim
fi

$NVIM_EXE --headless --clean -u ./tests/minimal_init.lua -c "PlenaryBustedDirectory tests/palette/ {minimal_init = './tests/minimal_init.lua', sequential = true}"
# $NVIM --clean -u ./tests/minimal_init.lua -c "PlenaryBustedDirectory tests/palette/ {minimal_init = './tests/minimal_init.lua', sequential = true}"
