---@class cmake-tools.ITarget
---@field name string
---@field type "EXECUTABLE"|"STATIC_LIBRARY"|"SHARED_LIBRARY"|"UTILITY"

---@class cmake-tools.Target: cmake-tools.ITarget
---@field artifict_path Path

local Target = {}

---Target constructor
---@param options? cmake-tools.Target
function Target:new(options)
    local o = options or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function Target:build() end
return Target
