local palette_filetype = 'palette-nvim'
local palette_file_extension = 'palettenvim'
local palette_ns_id = vim.api.nvim_create_namespace('palettenvim')

local M = {}

local function getPluginConfig() 
  local config = {}
  if vim.g.palette_theme_export_path then
    config.export_path = vim.fn.expand(vim.g.palette_theme_export_path)
  else
    config.export_path = vim.fn.stdpath('config')..'/colors'
  end
  return config
end

local type_params = {
  fg = "string",
  bg = "string",
  sp = "string",
  blend = "number",
  bold = "boolean",
  standout = "boolean",
  underline = "boolean",
  undercurl = "boolean",
  underdouble = "boolean",
  underdotted = "boolean",
  underdashed = "boolean",
  strikethrough = "boolean",
  italic = "boolean",
  reverse = "boolean",
  nocombine = "boolean",
  link = "string",
  ctermfg = "string",
  ctermbg = "string",
  cterm = "string",
}

--- The table of highlight params, (see :h nvim_set_hl()) for the list of params
--- @class Highlights any

--- The params to be passed to nvim_buf_add_highlight
--- @class LiveHighlightParams any[]

--- Parse the current buffer and return
--- 1. the list of highlights needed to be applied to the buffer
--- 2. the list of highlights written in the buffer
--- 3. the theme name if available
--- @return Highlights, LiveHighlightParams, string?
local function parse_highlights()
  local live_highlights = {}
  local highlights = {}
  local theme_name = nil

  for line_nr = 1, vim.api.nvim_buf_line_count(0) do
    local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
    local next_line = vim.api.nvim_buf_get_lines(0, line_nr, line_nr + 1, false)[1] or ''
    local link = next_line:match('%s+ links to (%S+)')

    if string.sub(line, 1, 2) == '--' then
      if theme_name == nil then
        theme_name = line:match('--%s*Theme:%s+(%S+)')
      end
      goto continue
    end

    local hl_name, hl_definition = line:match('(%S+)%s+xxx (.*)')

    if hl_name and hl_definition then
      local properties = {}

      if link then
        properties.link = link
      end

      local linkTo = hl_definition:match('links to (%S+)')

      if linkTo then
        properties.link = linkTo
      end

      for key, value in hl_definition:gmatch('(%a+)=([%w#]+)') do
        if key == 'guifg' then
          key = 'fg'
        elseif key == 'guibg' then
          key = 'bg'
        elseif key == 'guisp' then
          key = 'sp'
        end
        if value:match('^%d+$') then
          value = tonumber(value)
        end
        if type_params[key] == 'number' then
          value = tonumber(value)
        elseif type_params[key] == 'boolean' then
          value = value == 'true' or value == 'True'
        end
        if (key == 'gui') then
          for subvalue in (value or ''):gmatch('([^,]+),*') do
            properties[subvalue] = true
          end
        elseif (key == 'cterm') then
          new_value = {}
          for subvalue in (value or ''):gmatch('([^,]+),*') do
            new_value[subvalue] = true
          end
          properties[key] = new_value
        else
          properties[key] = value
        end
      end

      highlights[hl_name] = properties
      table.insert(live_highlights, { 0, palette_ns_id, hl_name, line_nr - 1, 0, #hl_name })
    end
    ::continue::
  end
  return highlights, live_highlights, theme_name
end

---@param highlights? Highlights a table { [highlight_name]: params} of highlights ready to be set with vim.api.nvim_set_hl
local function update_highlights(highlights)
  if not highlights then
    highlights, _, _ = parse_highlights()
  end
  for name, value in pairs(highlights) do
    local suc = pcall(vim.api.nvim_set_hl, 0, name, value)
    if (not suc) then
      error("FAILED to set highlight "..name)
    end
  end
end

--- adds highlights to buffer
---@param live_highlights? list of highlights to apply to current buffer
local function apply_live_highlights(live_highlights)
  if not live_highlights then
    _, live_highlights = parse_highlights()
  end

  vim.api.nvim_buf_clear_namespace(0, palette_ns_id, 0, -1)
  for index, value in ipairs(live_highlights or {}) do
    vim.api.nvim_buf_add_highlight(value[1], value[2], value[3], value[4], value[5], value[6])
  end
end

--- creates BufWrite autocmd to update buffer
function M.set_on_buffer_write(bufnr, group)
  vim.api.nvim_create_autocmd('BufWrite', {
    group = group,
    buffer = bufnr or 0,
    callback = function()
      M.on_buffer_update()
    end
  })
end

--- updates the highlights
function M.on_buffer_update()
  vim.bo.syntax = palette_filetype
  local highlights, live_highlights = parse_highlights()
  update_highlights(highlights)
  apply_live_highlights(live_highlights)
end

local function create_color_dir()
  local uv = vim.loop
  local path = getPluginConfig().export_path
  local _, err, msg = uv.fs_mkdir(path, 511)
end

--- exports the current palette buffer into a colorscheme
local function create_color_theme(bufnr, theme_name_overwrite)
  bufnr = bufnr or 0
  local uv = vim.loop
  local config = getPluginConfig()

  local highlights, _, theme_name = parse_highlights(bufnr or 0)

  theme_name = theme_name_overwrite or theme_name

  if theme_name == nil then
    error("Missing theme_name, add -- Theme: <theme_name> to the file")
  end

  local content = ''
  -- content = 'local ns_id = vim.api.nvim_create_namespace("'..theme_name..'")'
  content = 'local ns_id = 0'
  content = content .. '\n' .. 'vim.o.termguicolors = true'
  content = content .. '\n' .. 'vim.g.colors_name = "' .. theme_name .. '"'

  for name, value in pairs(highlights) do
    local line = 'vim.api.nvim_set_hl(ns_id, "' .. name .. '", ' .. vim.inspect(value) .. ')'
    content = content .. '\n' .. line
  end

  local theme_path = config.export_path .. '/' .. theme_name .. '.lua'

  local fd, err, msg = uv.fs_open(theme_path, 'w+', 511)
  if fd == nil then
    print(err..' '..msg)
    error(msg)
  end

  uv.fs_write(fd, content)
  uv.fs_close(fd)
end

local function cmdPaletteNew()
  local uv = vim.loop
  local tmpdir, err, msg = uv.os_tmpdir()
  if err then
    error('failed to locate tmpdir' .. msg)
  end

  local tmp_file_path = tmpdir .. '/tmp.palettenvim'
  local fd = uv.fs_open(tmp_file_path, 'w+', 511)
  if not fd then
    error('failed to create tmpfile')
  end

  uv.fs_write(fd, {
    "-- vim: cms=--\\ %s ft=" .. palette_filetype,
    "\n-- Theme: theme_name\n",
  })
  uv.fs_close(fd)

  vim.cmd("redir >> " .. tmp_file_path .. " | silent! highlight | redir END")
  vim.cmd(":e " .. tmp_file_path)
end

local function cmdPaletteExportAsPlugin(theme_name, export_path, overwrite)
  package.loaded.palette = nil
  package.loaded.utils = nil
  local utils = require('palette.utils')
  local uv = vim.loop

  if not export_path then
    export_path = vim.fn.input({
      prompt = "Export Path (default: .): ", 
      completion = "file"
    })
    if #export_path == 0 then
      export_path = '.'
    end
  end

  local repo_path = vim.fn.expand(export_path)
  if string.sub(repo_path, #repo_path, #repo_path) == '/' then
    repo_path = string.sub(repo_path, 1, #repo_path - 1)
  end
  repo_path = repo_path..'/'..theme_name

  if vim.fn.isdirectory(repo_path) == 1 then
    if overwrite ~= true then
      local res = vim.fn.input({
        prompt = repo_path.." already exists, overwrite? (this will only overwrite the colorscheme file)(y/n): ",
        cancelreturn = 'n',
      })
      overwrite = #res == 0 or res == 'y'
    end
    if not overwrite then
      print("aborted")
      return
    end
  end

  if not overwrite then
    local suc, err, msg = uv.fs_mkdir(repo_path, 511)
    if not suc then
      error(msg)
    end

    local readme_content = utils.readme(theme_name)
    vim.fn.writefile(vim.fn.split(readme_content, '\n'), repo_path..'/README.md')
  end

  -- generate colorscheme file
  local old_export_path = vim.g.palette_theme_export_path
  vim.g.palette_theme_export_path = repo_path..'/colors'
  create_color_dir()
  create_color_theme(0, theme_name)
  vim.g.palette_theme_export_path = old_export_path
end

function CmdPaletteExportAsPlugin()
  cmdPaletteExportAsPlugin("test_theme")
end



function M.palette_user_command(opts)
  args = opts.fargs
  nargs = #opts.fargs

  local cmd = args[1]:lower()
  if cmd == 'export' then
    local theme_name = nil
    if nargs > 1 then
      theme_name = args[2]
    end

    if nargs > 2 then
      print('Palette export called with more than two arguments, ignoring extra arguments')
    end

    if vim.bo.filetype ~= palette_filetype then
      error('Palette export can only be called from a palette file. Use "Palette new" to start a new palette')
    end

    create_color_dir()
    create_color_theme(0, theme_name)
  elseif cmd == 'new' then
    if nargs > 1 then
      print('Palette new called with more than two arguments, ignoring extra arguments')
    end

    cmdPaletteNew()
  elseif cmd == 'exportasplugin' then
    local theme_name = nil
    local export_path = nil

    if nargs > 1 then
      theme_name = args[2]
    end
    if nargs > 2 then
      export_path = args[3]
    end

    if not theme_name then
      _, _, theme_name = parse_highlights()
    end

    cmdPaletteExportAsPlugin(theme_name, export_path, opts.bang)
  end
end

return M
