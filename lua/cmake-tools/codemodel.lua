local Path = require("plenary.path")

---@class codemodel.Artifact
---@field path string

---@class codemodel.Target: cmake-tools.ITarget
---@field artifacts? codemodel.Artifact[] except "UTILITY"

local M = {}

---load reply from reply directory
---@param reply_dir Path
---@return codemodel.Target[] targets
function M.load_reply(reply_dir)
    local codemodel_path = vim.fs.find(function(name)
        return name:match("^codemodel%-v2%-%w*%.json")
    end, { path = reply_dir.filename, type = "file" })
    assert(#codemodel_path == 1, "need configure first")
    codemodel_path = Path:new(codemodel_path[1])
    local codemodel = vim.json.decode(codemodel_path:read())
    local targets = codemodel["configurations"][1]["targets"]

    for index, target in ipairs(targets) do
        local target_path = reply_dir / target["jsonFile"]
        target = vim.json.decode(target_path:read())
        targets[index] = target
    end
    return targets
end

return M
