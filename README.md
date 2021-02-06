# gtranslate.nvim

Plugin for neovim to translate text through https://translate.googleapis.com
written in Lua.

Requires Neovim v0.5

### Installation
The best way is to use [packer.nvim](https://github.com/wbthomason/packer.nvim),
because it allows installing libs from LuaRocks out of the box.
The plugin requires `lua-cjson` and `http` libraries to work:

```lua
local function load(use)
  use {'kraftwerk28/gtranslate.nvim', rocks = {'lua-cjson', 'http'}}
  -- ...other plugins
end

vim.cmd 'packadd packer.nvim'
require 'packer'.startup{load}
```

Though you can install rocks manually and then edit `package.path` to allow
nvim to require them

### Usage

```vimscript
:Translate <from-language> <to-language>
:Translate <to-language> " In this case, <from-language> is automatic
```

Select the text to translate (Visual mode), then type `:Translate <language>`
