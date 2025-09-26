# kitty-themes.nvim

A comprehensive Neovim colorscheme plugin that brings all the beautiful [kitty terminal themes](https://github.com/kovidgoyal/kitty-themes) to Neovim with intelligent auto-detection features.

## Features

- 🎨 **169 Beautiful Themes**: All themes from the official kitty-themes collection
- 🔍 **Auto-Detection**: Automatically detect your terminal theme and background
- 🌐 **Remote Support**: Works over SSH with proper environment forwarding
- ⚡ **Performance**: Embedded theme data for fast loading
- 🎛️ **Interactive**: Easy theme switching with preview functionality
- 🔧 **Configurable**: Extensive customization options

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "odysseyalive/kitty-themes.nvim",
  config = function()
    require("kitty-themes").setup({
      -- Enable auto-detection
      auto_detect = true,
      auto_detect_background = true,
      
      -- Other options
      transparent = false,
      term_colors = true,
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "odysseyalive/kitty-themes.nvim",
  config = function()
    require("kitty-themes").setup()
  end
}
```

## Usage

### Basic Commands

```vim
" Load a specific theme
:KittyThemes Dracula

" Auto-detect and load theme
:KittyThemesDetect

" List all available themes
:KittyThemesList

" Show terminal information
:KittyThemesInfo

" Preview themes interactively
:KittyThemesPreview

" Load a random theme
:KittyThemesRandom
```

### Lua API

```lua
local kitty_themes = require("kitty-themes")

-- Load a theme
kitty_themes.load("Monokai")

-- Auto-detect theme
kitty_themes.auto_detect()

-- Get available themes
local themes = kitty_themes.get_themes()

-- Get terminal information
local info = kitty_themes.get_terminal_info()
```

## Configuration

```lua
require("kitty-themes").setup({
  -- Style variations for supported themes
  style = "darker", -- darker, dark, cool, deep, warm, warmer, light
  
  -- Enable transparent background
  transparent = false,
  
  -- Enable terminal colors
  term_colors = true,
  
  -- Show ending tildes
  ending_tildes = false,
  
  -- Auto-detection settings
  auto_detect = false, -- Auto-detect on startup
  auto_detect_background = true, -- Auto-detect light/dark background
  
  -- Detection configuration
  detect = {
    osc_timeout = 100, -- OSC query timeout in milliseconds
    fallback_enabled = true, -- Enable fallback detection methods
    debug = false, -- Enable debug output
  },
})
```

## Auto-Detection

The plugin includes sophisticated auto-detection capabilities:

### Local Terminal Detection

- **OSC Sequences**: Query terminal for background color and theme information
- **Environment Variables**: Check terminal-specific variables
- **Background Analysis**: Automatically determine light/dark background

### Remote Terminal Support

- **SSH Environment Forwarding**: Forward theme information over SSH
- **Dotfile Parsing**: Parse local terminal configurations
- **Fallback Methods**: Multiple detection strategies for headless environments

### Setting up SSH Forwarding

Add to your local shell configuration (`.bashrc`, `.zshrc`):

```bash
# Forward terminal theme information over SSH
if [ -n "$KITTY_WINDOW_ID" ]; then
  export BACKGROUND_THEME="$(kitty @ get-colors 2>/dev/null | grep -E '^# ' | head -1 | cut -d' ' -f2-)"
fi

# SSH with forwarded environment
alias ssh='SSH_ENV="TERM_PROGRAM COLORTERM BACKGROUND_THEME" ssh'
```

## Available Themes

The plugin includes 169 themes organized in categories:

- **Light Themes**: Github, AtomOneLight, PencilLight, etc.
- **Dark Themes**: Dracula, OneDark, Monokai, etc.  
- **Material Themes**: Material, MaterialDark, OceanicMaterial, etc.
- **Gruvbox**: gruvbox_dark, gruvbox_light
- **And many more...**

Use `:KittyThemesList` to see all available themes in a organized view.

## Development

### Building from Source

```bash
# Generate colorscheme files from kitty themes
python3 build.py

# Or use the development script
./build.sh

# Generate embedded data for production
./build.sh --embedded
```

### Project Structure

```
kitty-themes.nvim/
├── lua/kitty-themes/
│   ├── init.lua          # Main plugin entry point
│   ├── detect.lua        # Auto-detection system
│   ├── remote.lua        # Remote/SSH support
│   ├── commands.lua      # User commands
│   └── embedded.lua      # Embedded theme data
├── colors/               # Generated .vim colorschemes
├── themes/               # Original kitty theme files
├── build.py             # Python build script
└── build.sh             # Development build script
```

## Contributing

Contributions are welcome! Please feel free to:

1. Report bugs
2. Suggest new features  
3. Submit pull requests
4. Add new themes

## License

This project is licensed under the MIT License. The original kitty themes are from the [kitty-themes](https://github.com/kovidgoyal/kitty-themes) project.

## Acknowledgments

- [kitty-themes](https://github.com/kovidgoyal/kitty-themes) for the beautiful theme collection
- [nord.nvim](https://github.com/shaunsingh/nord.nvim) for the plugin structure inspiration
- The Neovim community for making extensible editors possible
