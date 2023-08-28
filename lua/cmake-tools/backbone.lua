local M = {}

local function toggleterm(cmd)
    local code
    local Terminal = require("toggleterm.terminal").Terminal
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

local function terminal(cmd, args)
    local code
    local FloatTerminal = require("terminal.term").FloatTerminal
    local Job = require("terminal.job")
    cmd = tostring(cmd)
    for i, arg in ipairs(args) do
        args[i] = tostring(arg)
    end
    local t = FloatTerminal:new()

    local job = Job:new({
        cmd = cmd,
        args = args,
        on_exit = function(exit_code)
            code = exit_code
            if code == 0 then
                -- t:close()
            end
        end,
    })

    job:watch_stdout(function(data)
        t:write(data)
    end)
    t:open()
    job:start()

    vim.wait(10000, function()
        return code ~= nil
    end, 10)
    return code == 0
end

function M.run(cmd, args)
    return terminal(cmd, args)
end

return M
