local M = {}

M.get_task_opts = function(defn)
    local cmd = nil
    if defn.args then
        cmd = { "cmake", defn.command, unpack(defn.args) }
    else
        cmd = { "cmake", defn.command }
    end
    return {
        cmd = cmd,
    }
end

return M
