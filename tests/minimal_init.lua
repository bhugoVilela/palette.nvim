local tests_rtp = "./tests_rtp"
local plenary_dir = tests_rtp.."/plenary.nvim"

vim.fn.system("ls "..tests_rtp.." || mkdir "..tests_rtp)

local is_not_a_directory = vim.fn.isdirectory(plenary_dir) == 0
if is_not_a_directory then
  vim.fn.system("cd "..tests_rtp.." && git clone https://github.com/nvim-lua/plenary.nvim --depth 1 && cd -")
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(tests_rtp)
vim.opt.rtp:append(plenary_dir)

vim.cmd("runtime plugin/plenary.nvim")
vim.cmd("runtime plugin/palette.lua")

require("plenary.busted")
require('palette')
