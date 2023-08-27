local Terminal = require("toggleterm.terminal").Terminal

local M = {}

function M.run(cmd)
    local code
    local terminal = Terminal:new({
        cmd = cmd,
        close_on_exit = false,
        on_exit = function(t, job, exit_code, name)
            code = exit_code
            if code == 0 then
                t:close()
            end
        end,
    })
    terminal:open()

    while code == nil do
        vim.wait(1000000000, function()
            return code ~= nil
        end, 10)
    end
    return code == 0
end

return M
