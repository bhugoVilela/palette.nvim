local m = {}

---@generic T
---@param self T
---@param o T
---@return T
function m.new(self, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function m.makeClass(klass)
  klass = klass or {}
  klass.new = m.new
  return klass
end

function m.tryGet(key)
  return function(obj)
    return obj and obj[key] or nil
  end
end

return m
