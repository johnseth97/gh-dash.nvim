-- tests/gh_dash_spec.lua
local eq = assert.equals

describe('gh_dash.nvim', function()
  before_each(function()
    vim.cmd 'set noswapfile'
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
        if ft == 'gh_dash' then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end
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
    assert(cmds['GHdash'], 'GHdash command not found')
    assert(cmds['GHdashToggle'], 'GHdashToggle command not found')
  end)

  it('opens a floating terminal window', function()
    require('gh_dash').setup { cmd = "echo 'test'" }
    require('gh_dash').open()

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    assert(vim.api.nvim_buf_is_valid(buf), 'buffer should exist')
    eq(vim.api.nvim_buf_get_option(buf, 'filetype'), 'gh_dash')

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

  pending('hides the window on <Esc> but keeps job alive', function()
    -- this test is not reliable in headless mode, skipping for now
    --
    -- require('gh_dash').setup { cmd = 'echo "test"' }
    -- require('gh_dash').open()
    --
    -- local win = vim.api.nvim_get_current_win()
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', true)
    --
    -- local win_still_valid = pcall(vim.api.nvim_win_get_buf, win)
    -- assert(not win_still_valid, '<Esc> should hide the window')
    --
    -- local status = require('gh_dash').statusline()
    -- eq(status, '[gh_dash]', 'job should still be running after hiding window')
  end)

  it('shows statusline only when job is active but window is not', function()
    require('gh_dash').setup { cmd = 'echo "test"' }
    require('gh_dash').open()
    require('gh_dash').close()

    local status = require('gh_dash').statusline()
    eq(status, '[gh_dash]')
  end)
end)
