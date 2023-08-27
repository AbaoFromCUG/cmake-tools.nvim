local cmake = require("cmake-tools")
local Project = require("cmake-tools.project")

local simple_project = vim.fn.getcwd() .. "/tests/simple_project"
local default_build_project = simple_project .. "/build"
describe("build", function()
    before_each(function()
        vim.fn.delete(default_build_project, "rf")
    end)
    it("simple", function()
        vim.api.nvim_set_current_dir(simple_project)
        local project = Project:new(simple_project)

        assert.equals(simple_project .. "/build", project:get_build_directory().filename)

        assert(project:configure())
        assert(project:build())
        ---@type cmake-tools.Target[]
        local targets = project.targets
        assert.equals(#targets, 2)

        for _, target in ipairs(targets) do
            assert(target.artifict_path:exists())
        end
    end)
end)
