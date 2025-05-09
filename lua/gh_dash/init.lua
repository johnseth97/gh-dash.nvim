local M = {}

local config = {
  keymaps = {},
  border = 'single',
  custom_border = {
    {}, -- Top left corner
    {}, -- Top side
    {}, -- Top right corner
    {}, -- Right side
    {}, -- Bottom right corner
    {}, -- Bottom side
    {}, -- Bottom left corner
    {}, -- Left side
  },
  width = 0.8,
  height = 0.8,
  cmd = { 'gh', 'dash' },
  -- whether to auto-install the gh_dash TUI not found (requires npm)
  autoinstall = false,
}

local state = {
  buf = nil,
  win = nil,
  job = nil,
}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
  -- define commands for toggling the gh_dash popup
  vim.api.nvim_create_user_command('GHdash', function()
    M.toggle()
  end, { desc = 'Toggle gh-dash popup' })
  vim.api.nvim_create_user_command('GHdashToggle', function()
    M.toggle()
  end, { desc = 'Toggle gh-dash popup (alias)' })
  -- optional keymap for toggle
  if config.keymaps.toggle then
    vim.api.nvim_set_keymap('n', config.keymaps.toggle, '<cmd>GHdashToggle<CR>', { noremap = true, silent = true })
  end
end

local styles = {
  single = {
    { '╭', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╮', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '╯', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╰', 'FloatBorder' },
    { '│', 'FloatBorder' },
  },
  double = {
    { '╔', 'FloatBorder' },
    { '═', 'FloatBorder' },
    { '╗', 'FloatBorder' },
    { '║', 'FloatBorder' },
    { '╝', 'FloatBorder' },
    { '═', 'FloatBorder' },
    { '╚', 'FloatBorder' },
    { '║', 'FloatBorder' },
  },
  square = {
    { '┌', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '┐', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '┘', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '└', 'FloatBorder' },
    { '│', 'FloatBorder' },
  },
  custom = config.custom_border,
  none = nil,
}

-- Create a floating window displaying the gh_dash buffer
local function open_window()
  -- compute dimensions and position
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  -- resolve border style (string or table)
  local border = config.border
  if type(border) == 'string' then
    if border == 'none' then
      border = 'none'
    else
      border = styles[border] or styles.single
    end
  end
  -- open floating window
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = border,
  })
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) or vim.api.nvim_buf_get_option(state.buf, 'modified') then
    -- create an unlisted scratch buffer for the terminal
    state.buf = vim.api.nvim_create_buf(false, false)
    -- buffer options
    vim.api.nvim_buf_set_option(state.buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(state.buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'gh_dash')
    -- Escape backgrounds the window cleanly
    -- Map <Esc> in terminal mode to hide the popup
    vim.api.nvim_buf_set_keymap(
      state.buf,
      't',
      '<Esc>',
      [[<C-\><C-n><cmd>lua vim.defer_fn(function() require('gh_dash').toggle() end, 10)<CR>]],
      { noremap = true, silent = true }
    )
  end
  open_window()
  -- determine if config.cmd is a simple executable name (no args) for checking
  local check_cmd = nil
  if type(config.cmd) == 'string' then
    -- treat as simple executable if no whitespace (no args)
    if not config.cmd:find '%s' then
      check_cmd = config.cmd
    end
  elseif type(config.cmd) == 'table' and #config.cmd > 0 then
    check_cmd = config.cmd[1]
  end
  -- if simple command and not found, handle auto-install or notify
  if check_cmd and vim.fn.executable(check_cmd) == 0 then
    if config.autoinstall then
      if vim.fn.executable 'gh' == 1 then
        -- install via npm in the floating terminal to show output
        do
          local shell_cmd = vim.o.shell or 'sh'
          local cmd = {
            shell_cmd,
            '-c',
            "echo 'Autoinstalling gh_dash via gh CLI extensions...'; gh extension install dlvhdr/gh-dash",
          }
          state.job = vim.fn.termopen(cmd, {
            cwd = vim.loop.cwd(),
            on_exit = function(_, exit_code, _)
              state.job = nil
              if exit_code == 0 then
                vim.schedule(function()
                  M.close()
                end)
              end
            end,
          })
        end
      else
        -- show installation instructions in the gh_dash popup
        local msg = {
          'gh CLI not found; cannot auto-install gh_dash extension.',
          '',
          'Please install the gh CLI via your system package manager',
          'i.e. `brew install gh`',
        }
        vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, msg)
      end
    else
      -- show instructions inline when autoinstall is disabled
      local msg = {
        'gh_dash CLI not found.',
        '',
        'Install with:',
        'gh extension install dlvhdr/gh-dash',
        '',
        'Or enable autoinstall in your plugin setup:',
        '  require("gh_dash").setup{ autoinstall = true }',
      }
      vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, msg)
    end
    return
  end
  -- spawn the gh_dash CLI in the floating terminal buffer
  if not state.job then
    state.job = vim.fn.termopen(config.cmd, {
      wd = vim.loop.cwd(),
      on_exit = function(_, exit_code, _)
        state.job = nil
        if exit_code == 0 then
          vim.schedule(function()
            M.close()
          end)
        end
      end,
    })
  end
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
    state.buf = nil
  end
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    -- HIDE the window (don't kill the job)
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
  elseif state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    -- Reopen window into existing buffer
    open_window()
  else
    -- Full open if everything is gone
    M.open()
  end
end

function M.statusline()
  if state.job and not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    return '[gh_dash]'
  end
  return ''
end

--- Return a lualine.nvim component for displaying gh_dash status
-- Usage: table.insert(opts.sections.lualine_x, require('gh_dash').status())
function M.status()
  return {
    -- component function
    function()
      return M.statusline()
    end,
    -- only show when gh_dash job is running in background
    cond = function()
      return M.statusline() ~= ''
    end,
    -- gear icon
    icon = '',
    -- default color (blue)
    color = { fg = '#51afef' },
  }
end

return M
