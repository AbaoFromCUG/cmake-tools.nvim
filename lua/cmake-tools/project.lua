local Path = require("plenary.path")
local codemodel = require("cmake-tools.codemodel")
local Target = require("cmake-tools.target")
local backbone = require("cmake-tools.backbone")

---@class cmake-tools.Project
---@field private cmake_path? string
---@field private build_directory ? string
---@field private source_directory? string
---@field private targets? cmake-tools.Target[]
local Project = {}

---Project consctructor
---@param source_dir? string source directory
---@return cmake-tools.Project
function Project:new(source_dir)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.source_directory = source_dir
    return o
end

---get project source directory, default is current directory
---@return Path
function Project:get_source_directory()
    local resolver = require("integrator.resolver")
    local source_dir = self.source_directory or vim.loop.cwd() --[[@as string]]
    return Path:new(resolver.resolve_string(source_dir))
end

---get cmake executable path, default is `exepath("cmake")`
---@return Path
function Project:get_cmake_path()
    local cmake = require("cmake-tools")
    local cmake_path = self.cmake_path or cmake.config.cmake_path
    return Path:new(vim.fn.exepath(cmake_path))
end

---get project build directory, default is `${source_dir}/build`
---@return Path
function Project:get_build_directory()
    local cmake = require("cmake-tools")
    local resolver = require("integrator.resolver")
    local build_dir = self.build_directory or cmake.config.build_dir --[[@as string]]
    return Path:new(resolver.resolve_string(build_dir))
end

---get query directory of cmake build tree
---@return Path
function Project:get_query_directory()
    -- https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html
    return self:get_build_directory() / ".cmake/api/v1/query/"
end

---get reply directory of cmake build tree
---@return Path
function Project:get_reply_directory()
    return self:get_build_directory() / ".cmake/api/v1/reply/"
end

---get compile_commands.json path
---@return Path
function Project:get_compile_commands_path()
    return self:get_build_directory() / "compile_commands.json"
end

function Project:configure()
    ---@type Path
    local query_file = self:get_query_directory():joinpath("codemodel-v2")
    if not query_file:exists() and not query_file:touch({ parents = true }) then
        local err = "Can't create codemodel-v2 query file"
        -- vim.notify(err, vim.log.levels.ERROR, { title = "cmake-tools" })
        return false, err
    end
    local cmake_path = self:get_cmake_path()
    local source_dir = self:get_source_directory()
    local build_dir = self:get_build_directory()

    -- local cmd = string.format("%s -S %s -B %s -DCMAKE_EXPORT_COMPILE_COMMANDS=1", cmake_path, source_dir, build_dir)
    local args = { "-S", source_dir, "-B", build_dir, "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" }
    if not backbone.run(cmake_path, args) then
        return false, "cmake configure failed"
    end

    local reply_dir = self:get_reply_directory()
    local targets = codemodel.load_reply(reply_dir)
    self.targets = {}
    for _, target in ipairs(targets) do
        if target.type ~= "UTILITY" then
            table.insert(
                self.targets,
                Target:new({
                    name = target.name,
                    type = target.type,
                    artifict_path = build_dir / target.artifacts[1].path,
                })
            )
        end
    end
    return true
end

function Project:build()
    local cmake_path = self:get_cmake_path()
    local build_dir = self:get_build_directory()
    -- local cmd = string.format("%s --build %s --target all", cmake_path, build_dir)
    local args = { "--build", build_dir, "--target", "all" }
    if not backbone.run(cmake_path, args) then
        return false, "cmake build failed"
    end
    return true
end

return Project
