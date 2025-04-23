-- tests/init.lua
-- luacheck: globals describe it before_each
-- luacheck: ignore async
local async = require 'plenary.async.tests'

describe('ghdash.nvim', function()
  it('should load without errors', function()
    require 'ghdash'
  end)

  it('should respond to basic command', function()
    vim.cmd 'ghdash'
    -- Add assertion if it triggers some output or state change
  end)
end)
