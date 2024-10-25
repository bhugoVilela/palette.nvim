local M = {}

function M.readme(theme_name)
  local format_str = '\
  <p align="center"> \
    <h2 align="center">%theme_name% for Neovim</h2>\
  </p>\
  <p align="center">Theme Description</p>\
  <p align="center">Generate using [palette.nvim](https://github.com/bhugovilela/palette.nvim)</p>\
\
  ## Getting started\
\
  Install %theme_name% using your favourite plugin manager:\
\
  > Warning: replace GITHUB_USER with your own github username\
\
  **paq-nvim**\
\
  ```lua\
  { "GITHUB_USER/%theme_name%" }\
  ```\
\
  **lazy.nvim**\
\
  ```lua\
  { "GITHUB_USER/%theme_name%" }\
  ```\
\
  **Plug**\
\
  ```lua\
  plug "GITHUB_USER/%theme_name%" \
  ```\
\
  After installation just add `vim.cmd "colorscheme %theme_name%"` to your config and it will load on startup\
\
  ## Gallery\
\
  > Add glamour shots here\
  '

  return string.gsub(format_str, '%%theme_name%%', theme_name)
end

return M
