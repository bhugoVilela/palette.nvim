<p align="center">
<h2 align="center">Palette.nvim</h2>
</p>
<p align="center">Modify `:highlight` and create new color schemes on the fly</p>

**Palette.nvim** allows you to modify and create new color schemes with ease.
Modify `:highlight` directly and preview your tweaks in real-time with the 
`:Palette new` command. Once Satisfied, export your scheme effortlessly via 
`:Palette export [name?]`

### Features
- **Clone & Edit**: Easily clone your current color scheme and modify it to fit
your preferences (`:Palette new`).
- **Instant Feedback**: Real-time preview of color changes with automatic 
updates on file save (`BufWrite`).
- **Simple Export**: Generate and export your customized color schemes with a 
single command (`:Palette export [name?]`). Once exported, your theme will be 
available in `:colorscheme <name>`
- **Effortless Sharing**: Generated color schemes are single-file, ensuring 
easy sharing. They are stored at 
`vim.fn.stdpath('config')/colors/theme_name.lua`.
- **Lazy by default**: The code is only loaded the first time you call `:Palette new`
or open a buffer with `ft=palette-nvim`
- **Comprehensive Help**: Access detailed help files with `:help palette.nvim`.

### Design Decisions
**Palette.nvim** is designed to be small, lightweight, and efficient. The 
plugin includes only a minimal syntax file for the palette editor, with the 
entire implementation contained within a single file.

### Instalation
With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a>
```lua
{ 'bhugovilela/palette.nvim' }
```

With <a href="https://github.com/echasnovski/mini.nvim">echasnovski/mini.nvim</a>
```lua
add('bhugovilela/palette.nvim')
```

With <a href="https://github.com/junegunn/vim-plug">junegunn/vim-plug</a>
```lua
Plug 'bhugovilela/mini.nvim'
```


