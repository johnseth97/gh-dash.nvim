-- tests/ghdash_spec.lua
-- luacheck: globals describe it assert eq
-- luacheck: ignore a            -- “a” is imported but unused
local a = require 'plenary.async.tests'
local eq = assert.equals

describe('ghdash.nvim', function()
  before_each(function()
    vim.cmd 'set noswapfile' -- prevent side effects
    vim.cmd 'silent! bwipeout!' -- close any open ghdash windows
  end)

  it('loads the module', function()
    local ok, ghdash = pcall(require, 'ghdash')
    assert(ok, 'ghdash module failed to load')
    assert(ghdash.open, 'ghdash.open missing')
    assert(ghdash.close, 'ghdash.close missing')
    assert(ghdash.toggle, 'ghdash.toggle missing')
  end)

  it('creates ghdash commands', function()
    require('ghdash').setup { keymaps = {} }

    local cmds = vim.api.nvim_get_commands {}
    assert(cmds['ghdash'], 'ghdash command not found')
    assert(cmds['ghdashToggle'], 'ghdashToggle command not found')
  end)

  it('opens a floating terminal window', function()
    require('ghdash').setup { cmd = "echo 'test'" }
    require('ghdash').open()

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    eq(ft, 'ghdash')

    require('ghdash').close()
  end)

  it('toggles the window', function()
    require('ghdash').setup { cmd = "echo 'test'" }

    require('ghdash').toggle()
    local win1 = vim.api.nvim_get_current_win()
    assert(vim.api.nvim_win_is_valid(win1), 'ghdash window should be open')

    require('ghdash').toggle()
    local still_valid = pcall(vim.api.nvim_win_get_buf, win1)
    assert(not still_valid, 'ghdash window should be closed')
  end)

  it('shows statusline only when job is active but window is not', function()
    require('ghdash').setup { cmd = 'sleep 1000' }
    require('ghdash').open()

    vim.defer_fn(function()
      require('ghdash').close()
      local status = require('ghdash').statusline()
      eq(status, '[ghdash]')
    end, 100)
  end)
end)
