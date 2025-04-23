-- tests/gh_dash_spec.lua
-- luacheck: globals describe it assert eq
-- luacheck: ignore a            -- “a” is imported but unused
local a = require 'plenary.async.tests'
local eq = assert.equals

describe('gh_dash.nvim', function()
  before_each(function()
    vim.cmd 'set noswapfile' -- prevent side effects
    vim.cmd 'silent! bwipeout!' -- close any open gh_dash windows
  end)

  it('loads the module', function()
    local ok, gh_dash = pcall(require, 'gh_dash')
    assert(ok, 'gh_dash module failed to load')
    assert(gh_dash.open, 'gh_dash.open missing')
    assert(gh_dash.close, 'gh_dash.close missing')
    assert(gh_dash.toggle, 'gh_dash.toggle missing')
  end)

  it('creates gh_dash commands', function()
    require('gh_dash').setup { keymaps = {} }

    local cmds = vim.api.nvim_get_commands {}
    assert(cmds['GHDash'], 'GHDash command not found')
    assert(cmds['GHDashToggle'], 'GHDashToggle command not found')
  end)

  it('opens a floating terminal window', function()
    require('gh_dash').setup { cmd = "echo 'test'" }
    require('gh_dash').open()

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    eq(ft, 'gh_dash')

    require('gh_dash').close()
  end)

  it('toggles the window', function()
    require('gh_dash').setup { cmd = "echo 'test'" }

    require('gh_dash').toggle()
    local win1 = vim.api.nvim_get_current_win()
    assert(vim.api.nvim_win_is_valid(win1), 'gh_dash window should be open')

    require('gh_dash').toggle()
    local still_valid = pcall(vim.api.nvim_win_get_buf, win1)
    assert(not still_valid, 'gh_dash window should be closed')
  end)

  it('shows statusline only when job is active but window is not', function()
    require('gh_dash').setup { cmd = 'sleep 1000' }
    require('gh_dash').open()

    vim.defer_fn(function()
      require('gh_dash').close()
      local status = require('gh_dash').statusline()
      eq(status, '[gh_dash]')
    end, 100)
  end)
end)
