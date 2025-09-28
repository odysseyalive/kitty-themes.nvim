# kitty-themes.nvim

A comprehensive Neovim colorscheme plugin that brings all the beautiful [kitty terminal themes](https://github.com/kovidgoyal/kitty-themes) to Neovim.

## Features

- 🎨 **170+ Beautiful Themes**: All themes from the official kitty-themes collection
- 🎛️ **Interactive Selection**: Easy theme switching with preview functionality
- ⚡ **Performance**: Fast loading with embedded theme data
- 🔧 **Configurable**: Extensive customization options
- 💻 **Terminal Colors**: Proper terminal color support

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  {
    "odysseyalive/kitty-themes.nvim",
    config = function()
      require("kitty-themes").setup({
        -- Configuration options
        transparent = false,
        term_colors = true,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "SeaShells",
    },
  }
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

" Interactive theme selector
:KittyThemes

" List all available themes
:KittyThemesList

" Preview themes interactively
:KittyThemesPreview

" Load a random theme
:KittyThemesRandom
```

### Lua API

```lua
local kitty_themes = require("kitty-themes")

-- Load a specific theme
kitty_themes.load("Monokai")

-- Get available themes
local themes = kitty_themes.get_themes()

-- Parse a kitty theme file
local colors = kitty_themes.parse_kitty_theme(content)
```

## Configuration

```lua
require("kitty-themes").setup({
  -- Style variations for supported themes
  style = "darker", -- darker, dark, cool, deep, warm, warmer, light
  
  -- Enable transparent background (works with all methods)
  transparent = false,
  
  -- Enable terminal colors
  term_colors = true,
  
  -- Show ending tildes
  ending_tildes = false,
})
```

### Transparency

The plugin provides unified transparent background support that works seamlessly with both Lua API and traditional `:colorscheme` commands.

**Basic Setup:**

```lua
require("kitty-themes").setup({
  transparent = true,  -- Enable transparent backgrounds
  term_colors = true,
})
```

**Usage Examples:**

```lua
-- Method 1: Using Lua API (recommended)
require("kitty-themes").load("Dracula")

-- Method 2: Traditional colorscheme command (also works!)
vim.cmd('colorscheme Dracula')
```

**Runtime Control:**

```lua
-- Toggle transparency on/off
require("kitty-themes").toggle_transparency()

-- Set transparency programmatically
require("kitty-themes").set_transparency(true)  -- or false

-- Check current transparency status
local is_transparent = require("kitty-themes").get_transparency_status()
```

**Commands:**

- `:KittyThemesToggleTransparency` - Toggle transparency on/off
- `:KittyThemesSetTransparency true/false` - Set transparency state

**Notes:**

- Transparency setting applies to all UI elements (statusline, popups, floating windows)
- Works with popular plugin integrations (Telescope, nvim-tree, etc.)
- Terminal emulator must support transparency (Kitty, Alacritty, WezTerm, etc.)

## Theme Selection

### Interactive Selection

The easiest way to choose a theme is using the interactive selector:

```vim
:KittyThemes
```

This opens a menu where you can browse and select from all 169 available themes.

### Direct Theme Loading

If you know the theme name, load it directly:

```vim
:KittyThemes Dracula
:KittyThemes gruvbox_dark  
:KittyThemes OneDark
:KittyThemes Github
```

### Browse All Themes

View all themes organized by category:

```vim
:KittyThemesList
```

### Preview Mode

Try themes with live preview:

```vim
:KittyThemesPreview
```

Use arrow keys to navigate, Enter to confirm, Esc to cancel.

### Random Theme

Feeling adventurous?

```vim
:KittyThemesRandom
```

## Quick Start

1. **Install the plugin** using your preferred plugin manager
2. **Browse themes**: `:KittyThemesList` to see all available options
3. **Try a theme**: `:KittyThemes Dracula` (or any theme name)  
4. **Interactive selection**: `:KittyThemes` to open the theme picker
5. **Preview mode**: `:KittyThemesPreview` to test themes with live preview

## Popular Themes to Try

- **Dark themes**: `Dracula`, `OneDark`, `Nord`, `Nordfox`, `gruvbox_dark`, `Monokai`
- **Light themes**: `Github`, `AtomOneLight`, `gruvbox_light`, `PencilLight`  
- **Material themes**: `Material`, `MaterialDark`, `OceanicMaterial`
- **Catppuccin variants**: `Catppuccin-Mocha`, `Catppuccin-Frappe`, `Catppuccin-Macchiato`, `Catppuccin-Latte`
- **Tokyo Night variants**: `tokyo_night_night`, `tokyo_night_storm`, `tokyo_night_day`, `tokyo_night_moon`
- **Rose Pine variants**: `rose-pine`, `rose-pine-moon`, `rose-pine-dawn`
- **Unique themes**: `Batman`, `Cyberpunk`, `Galaxy`, `Neon`

## Available Themes

The plugin includes 381+ themes organized in categories:

- **Light Themes**: Github, AtomOneLight, PencilLight, etc.
- **Dark Themes**: Dracula, OneDark, Monokai, Nord, Nordfox, etc.  
- **Material Themes**: Material, MaterialDark, OceanicMaterial, etc.
- **Gruvbox**: gruvbox_dark, gruvbox_light, gruvbox-material variants
- **Catppuccin**: All four variants (Latte, Frappe, Macchiato, Mocha)
- **Tokyo Night**: Multiple variants (Day, Night, Moon, Storm)
- **Rose Pine**: All variants (Rose Pine, Dawn, Moon)
- **Popular themes**: Nord, Catppuccin, Tokyo Night, Rose Pine, and many more...

Use `:KittyThemesList` to see all available themes in a organized view.

## API Reference

### Core Functions

```lua
local kitty_themes = require("kitty-themes")

-- Setup and configuration
kitty_themes.setup({
  transparent = false,
  term_colors = true,
  ending_tildes = false,
})

-- Theme management
kitty_themes.load("Dracula")           -- Load specific theme
kitty_themes.get_themes()              -- Get list of available themes
kitty_themes.random_theme()            -- Load random theme

-- Interactive selection
kitty_themes.select_theme()            -- Open theme selector
kitty_themes.list_themes()             -- Print all themes
kitty_themes.preview_themes()          -- Interactive preview mode
```

### Transparency Functions

```lua
-- Runtime transparency control
kitty_themes.toggle_transparency()              -- Toggle on/off
kitty_themes.set_transparency(true)             -- Set state
kitty_themes.get_transparency_status()          -- Get current state

-- Advanced transparency (from transparency module)
local transparency = require("kitty-themes.transparency")
transparency.supports_transparency()            -- Check terminal support
transparency.get_debug_info()                  -- Get debug information
```

### User Commands

| Command | Description |
|---------|-------------|
| `:KittyThemes [theme]` | Load theme or open selector |
| `:KittyThemesList` | List all available themes |
| `:KittyThemesPreview` | Interactive theme preview |
| `:KittyThemesRandom` | Load random theme |
| `:KittyThemesToggleTransparency` | Toggle transparency |
| `:KittyThemesSetTransparency <on/off>` | Set transparency |

## Development

### Updating Themes

To keep your themes up-to-date with the latest from the upstream kitty-themes repository:

```bash
# Check for missing themes
./update_themes.sh --check

# Download missing themes
./update_themes.sh

# Force update all themes (overwrite existing)
./update_themes.sh --force
```

The update script will:

1. Fetch the list of themes from the upstream kitty-themes repository
2. Compare with local themes to find missing ones
3. Download missing themes
4. Regenerate all colorscheme files

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
│   ├── commands.lua      # User commands and interface
│   └── embedded.lua      # Embedded theme data
├── colors/               # Generated .vim colorschemes
├── themes/               # Original kitty theme files
├── build.py             # Python build script
└── build.sh             # Development build script
```

## Troubleshooting

### Transparency Issues

**Transparency not working:**

1. **Check terminal support**: Ensure your terminal emulator supports transparency (Kitty, Alacritty, WezTerm, etc.)
2. **Verify setup**: Make sure transparency is enabled in your configuration:

   ```lua
   require("kitty-themes").setup({ transparent = true })
   ```

3. **Check terminal settings**: Verify your terminal has transparency/background opacity configured
4. **Debug transparency state**:

   ```lua
   -- Check current transparency status
   print(require("kitty-themes").get_transparency_status())
   ```

**Theme switching issues:**

1. **Use recommended method**: `require("kitty-themes").load("ThemeName")`
2. **For `:colorscheme` command**: The plugin automatically syncs transparency settings
3. **Manual refresh**: If needed, toggle transparency to refresh: `:KittyThemesToggleTransparency` (twice)

**Common terminal configurations:**

- **Kitty**: Set `background_opacity` in `kitty.conf`
- **Alacritty**: Set `background_opacity` in `alacritty.yml`
- **WezTerm**: Set `window_background_opacity` in config

### General Issues

**Theme not found:**

- Run `:KittyThemesList` to see available themes
- Check spelling of theme name (case-sensitive)

**Colors not displaying correctly:**

- Ensure `termguicolors` is enabled: `vim.o.termguicolors = true`
- Check terminal color support (24-bit/true color)

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
