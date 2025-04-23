-- tests/init.lua
-- luacheck: globals describe it before_each
-- luacheck: ignore async
local async = require 'plenary.async.tests'

describe('gh_dash.nvim', function()
  it('should load without errors', function()
    require 'gh_dash'
  end)

  it('should respond to basic command', function()
    vim.cmd 'gh_dash'
    -- Add assertion if it triggers some output or state change
  end)
end)
