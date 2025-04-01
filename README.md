<p align="center">
<img src="/icon.png" width="150"/>
<h2 align="center">Palette.nvim</h2>
</p>
<p align="center">Modify `:highlight` and create new color schemes on the fly</p>

![main](https://github.com/bhugoVilela/palette.nvim/actions/workflows/tests.yml/badge.svg?branch=main)

**Palette.nvim** allows you to modify and create new color schemes with ease.
Modify `:highlight` directly and preview your tweaks in real-time with the 
`:Palette new` command. Once Satisfied, export your scheme effortlessly via 
`:Palette export [name?]`

### Features
- **Clone & Edit**: Clone your current color scheme and modify it to fit
your preferences (`:Palette new`).
- **Instant Feedback**: Real-time preview of color changes with automatic 
updates on file save (`BufWrite`).
- **Powerful**: Experimental features like `:h palette-include` and 
`palette-no-export` extend the highlights syntax in powerful ways to make 
creating colorschemes a breeze.
`:h palette-extended-syntax`
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

https://github.com/user-attachments/assets/92cb9527-fa1f-4836-a3ce-c32dda8356bc

### Design Decisions
**Palette.nvim** is a hobby plugin, I just wanted to tweak slightly some of the
colors I found in different colorschemes. I hacked this together in a couple of
afternoons and therefore it's very simple. Performance was an afterthought since
this plugin shouldn't impact your workflow. That said the plugin is very lazy 
by default only loading its contents when the `:Palette` cmd is run.

### Installation
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
Plug 'bhugovilela/palette.nvim'
```

### Setup
```lua
vim.g.palette_config = {
    -- folder where colorschemes will be saved to
    export_path = vim.fn.stdpath('config') .. '/colors'
}

```

### How to use
#### 1. Clone the current colorscheme
```vim
:Palette new
```
#### 2. Edit the colorscheme manually

(optional: Use `:InspectTree` in some other buffer to find which highlight
groups are being used where)

Tweak some highlights and save (:w) to see changes applied automatically.

> [!TIP]
> Palette.nvim extends the highlight syntax for extra flexibility.
>
> **Read [the manual](docs/palette.txt)** `:h palette.nvim` to learn about it.

#### 3. Export the colorscheme
```vim
:Palette export <colorscheme_name>
```
will export the colorscheme and make it available for `:colorscheme`


### Caveats
1. This plugin was built in a couple of afternoons, a proper version could do with
a decent parser, I could not, however, bring myself to write a parser for such a
small hobby plugin. I could've written a parser in treesitter but it would be
more effort than I would like to put in this.

2. The error handling isn't great because of the point above.

3. The experimental features lack proper documentation. `:h palette-include` for
   example, is equivalent to a preprocessor macro and does not replace linking.

### Further reading
- The [help docs](docs/palette.txt) are a lot more detailed than this readme and I
highly recommend reading them before starting.
- [This presentation](https://speakerdeck.com/cocopon/creating-your-lovely-color-scheme) 
by Hiroki Kokubun is a good introduction to highlights and how they work.

<!-- vim: colorcolumn=80 tw=80 
-->
