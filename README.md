<p align="center">
<h2 align="center">Palette.nvim</h2>
</p>
<p align="center">Modify `:highlight` and create new color schemes on the fly</p>

![main](https://github.com/bhugoVilela/palette.nvim/actions/workflows/tests.yml/badge.svg?branch=main)

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
- **Instant Plugin**: Export your theme as plugin with `:Palette exportAsPlugin`.
A plugin folder will be created ready to be committed and pushed into github.
- **Lazy by default**: The code is only loaded the first time you call `:Palette new`
or open a buffer with `ft=palette-nvim`
- **Comprehensive Help**: Access detailed help files with `:help palette.nvim`.


https://github.com/user-attachments/assets/affbeb0d-d6a6-4915-bc41-3292db6bce5d


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

### Creating a colorscheme
[This presentation](https://speakerdeck.com/cocopon/creating-your-lovely-color-scheme) 
by Hiroki Kokubun is a good introduction to highlights and how they work.

<!-- vim: colorcolumn=80 tw=80 
-->
