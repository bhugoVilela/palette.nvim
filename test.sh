#!/usr/bin/env bash

# nvim --headless -c "PlenaryBustedDirectory tests/palette {minimal_init = './tests/minimal_init.lua'}"
nvim --headless --clean -u ./tests/minimal_init.lua -c "PlenaryBustedDirectory tests/palette/ {minimal_init = './tests/minimal_init.lua', sequential = true}"
# nvim -c "PlenaryBustedDirectory tests/palette {minimal_init = './tests/minimal_init.lua'}"


