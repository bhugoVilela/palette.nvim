local m = {}

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

return m
