# gh-dash Neovim Plugin

## A Neovim plugin integrating the open-source gh-dash TUI for the `gh` cli ([gh-dash](https://github.com/dlvhdr/gh-dash/)).
> Latest version: ![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/johnseth97/gh-dash.nvim?sort=semver)

### Features:
- ✅ Toggle gh-dash floating window with `:ghdash-toggle`
- ✅ Optional keymap mapping via `setup` call
- ✅ Background running when window hidden
- ✅ Statusline integration via `require('ghdash').status()` 

### Installation:

- Install the `gh-dash` CLI via npm, or mark autoinstall as true in the config function

```bash
npm install -g @openai/gh-dash
```

- Grab an API key from OpenAI and set it in your environment variables:
  - Note: You can also set it in your `~/.bashrc` or `~/.zshrc` file to persist across sessions, but be careful with security. Especially if you share your config files.

```bash
export OPENAI_API_KEY=your_api_key
```

- Use your plugin manager, e.g. lazy.nvim:

```lua
return {
  'johnseth97/gh-dash.nvim',
  lazy = true,
  keys = {
    {
      '<leader>cc',
      function() require('gh-dash').toggle() end,
      desc = 'Toggle gh-dash popup',
    },
  },
  opts = {
    keymaps     = {},    -- disable internal mapping
    border      = 'rounded', -- or 'double'
    width       = 0.8,
    height      = 0.8,
    autoinstall = true,
  },
}
```

### Usage:
- Call `:gh-dash` (or `:gh-dashToggle`) to open or close the gh-dash popup.
-- Map your own keybindings via the `keymaps.toggle` setting.
- Add the following code to show presence of backgrounded gh-dash window in lualine:
```lua
require('gh-dash').status() -- drop in to your lualine sections
```
