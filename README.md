# angular-switcher.nvim

## LazyVim

``` lua >> nvim/lua/plugins/angular-switcher.lua
return {
  {
    "asmolenic/angular-switcher.nvim",
    event = "BufReadPre", -- lazy-load on first file read
    cond = function()
      -- Look upward from the current buffer for "angular.json"
      local util = require("lspconfig.util")
      local root = util.root_pattern("angular.json")(vim.fn.expand("%:p:h"))
      return root ~= nil
    end,
    config = function()
      require("angular-switcher").setup()
    end,
  },
}
```
