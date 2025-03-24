local config_var = 'palette_config'

local M = {}

local config_options = {
  export_path = {
    type = 'string',
    required = false,
    default = function()
      return vim.fn.stdpath('config')..'/colors'
    end,
    parse = function(value)
      return vim.fn.expand(value)
    end
  }
}

---@alias ParsedConfig { export_path: string }

--- parses vim.g.palette_config and returns the config parsed and validated
--- @param override ParsedConfig keys to override (are still parsed)
--- @return ParsedConfig
function M.parse_config(override)
  local config = vim.g[config_var] or {}
  if override then
    local new_config = vim.tbl_deep_extend('force', config, override)
    config = new_config
  end

  local result = {}

  for name, opts in pairs(config_options) do
    if opts.required and config[name] == nil then
      return nil, "Invalid Palette.nvim config", "Missing required option "..name
    end
    local value = config[name]
    if value == nil then
      if type(opts.default) == 'function' then
        value = opts.default()
      else
        value = opts.default
      end
    end
    if opts.parse then
      value, errmsg = opts.parse(value)
      if errmsg then
        return nil, "Invalid Palette.nvim config", errmsg
      end
    end
    result[name] = value
  end
  return result
end

function M.parse_config_or_err()
  local res, err, msg = M.parse_config()
  if (err) then
    error(err..' '..msg)
  end
  return res
end

return M

