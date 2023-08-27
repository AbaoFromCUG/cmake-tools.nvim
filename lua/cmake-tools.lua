local Project = require("cmake-tools.project")

---@class cmake-tools.Config
---@field cmake_path? string cmake executable path, default is `exepath("cmake")`
---@field build_dir? string cmake build path, default is `{cwd}/build`, support placeholds: {cwd} {os} {build_type}

local M = {}

---@type cmake-tools.Config
M.config = {
    cmake_path = "cmake",
    build_dir = "${workspaceFolder}/build",
}

M.project = Project:new()

---@param config? cmake-tools.Config
function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config or {}) --[[@as cmake-tools.Config]]
end

return M
