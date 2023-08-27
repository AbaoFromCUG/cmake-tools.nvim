local cmake = require("cmake-tools")
local Project = require("cmake-tools.project")

local simple_project = vim.fn.getcwd() .. "/tests/simple_project"
local build_path = simple_project .. "/build"
describe("configure", function()
    before_each(function()
        vim.fn.delete(build_path, "rf")
    end)
    after_each(function()
        vim.fn.delete(build_path, "rf")
    end)
    it("simple", function()
        vim.api.nvim_set_current_dir(simple_project)
        local project = Project:new(simple_project)
        assert.equals(build_path, project:get_build_directory().filename)

        assert(project:configure())
        assert.equals(true, project:get_reply_directory():is_dir())
        assert.equals(true, project:get_compile_commands_path():is_file())
        ---@type codemodel.Target[]
        local targets = project.targets
        assert.equals(#targets, 2)

        for _, target in ipairs(targets) do
            if target.name == "app" then
                assert.equals(target.type, "EXECUTABLE")
            elseif target.name == "lib" then
                assert.equals(target.type, "SHARED_LIBRARY")
            else
                assert(false)
            end
        end
    end)
end)
