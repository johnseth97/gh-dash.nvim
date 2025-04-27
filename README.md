# gh-dash.nvim
<img width="1477" alt="image" src="https://github.com/user-attachments/assets/84bffe05-a2c3-4bdb-9cbe-0ea0be0ea279" />

## A Neovim plugin integrating the open-source gh-dash TUI for the `gh` CLI ([gh-dash](https://github.com/dlvhdr/gh-dash/))

> Latest version: ![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/johnseth97/gh-dash.nvim?sort=semver)

### Features

- ✅ Toggle gh-dash floating window with `:GHdashToggle`
- ✅ Optional keymap mapping via `setup` call
- ✅ Background running when window hidden
- ✅ Lualine integration via `require('gh_dash').status`

### Installation

- Install the 'gh' command line tool for your OS from [GitHub CLI](https://cli.github.com/).

e.g. for macOS:

```bash
brew install gh
```

- Install the `gh-dash` TUI as a plugin from the `gh` command
- Alternatively, mark autoinstall as true in the config function

```bash
gh extension install dlvhdr/gh-dash
```

- Use your plugin manager to install, e.g. lazy.nvim:

```lua
return {
  'johnseth97/gh-dash.nvim',
  lazy = true,
  keys = {
    {
      '<leader>cc',
      function() require('gh_dash').toggle() end,
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

- If you are not using Lazy, I assume you can figure out how to clone the repo.

### Usage

- Call `:GHdash` (or `:GHdashToggle`) to open or close the gh-dash popup.
-- Map your own keybindings via the `keymaps.toggle` setting.
- Add the following code to show presence of backgrounded gh-dash window in lualine:

```lua
require('gh-dash').status() -- drop in to your lualine sections
```
