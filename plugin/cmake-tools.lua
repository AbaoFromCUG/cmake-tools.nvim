local cmake = require("cmake-tools")
vim.api.nvim_create_user_command("CMake", function(command)
    if #command.fargs == 0 then
        cmake.project:configure()
        return
    end
    local subcommand = command.fargs[1]
    cmake.project[subcommand](cmake.project)
end, {
    complete = function()
        return { "build", "configure" }
    end,
    nargs = "*",
    bang = true,
    desc = "CMake command",
})
