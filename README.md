<h1 align="center"> printer.nvim </h1>
<p align="center"><sup> Neovim plugin that adds an operator which allows quick adding printing/logging statements with text from textobjects / visual range based on the filetype </sup></p>

![demo](https://user-images.githubusercontent.com/83038443/189985116-a4e72aab-0faa-4b05-8960-44f5822367d4.gif)

### Installation

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'rareitems/printer.nvim',
    config = function()
        require('printer').setup({
            keymap = "gp" -- Plugin doesn't have any keymaps by default
          })
    end
}
```

### Usage

Use your keymap followed by a motion to quickly print/log the text from the motion.

### Default Configuration

```lua
{
    behavior = "insert_below" -- behavior for the operator, "yank" will not insert but instead put text into the default '"' register
    formatters  = {
      -- check lua/formatters.lua for default value of formatters
    }
}
```

#### More Configuration Stuffs

```lua
use {
    'rareitems/printer.nvim',
    config = function()
        require('printer').setup({
            keymap = "gp" -- Plugin doesn't have any keymaps by default
            behavior = "insert_below" -- how operator should behave
            -- "insert_below" will insert the text below the cursor
            --  "yank" will not insert but instead put text into the default '"' register
            formatters = {
              -- you can define your formatters for specific filetypes
              -- by assigning function that takes a string, which is a text from the motion, and returns a string
              lua = function(text)
                return string.format('print("%s: " .. %s)', text, text)
              end,
            }
          })
    end
}
```
