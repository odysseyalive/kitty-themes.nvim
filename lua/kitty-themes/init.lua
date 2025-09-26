local M = {}

-- Configuration defaults
M.config = {
  style = "darker", -- darker, dark, cool, deep, warm, warmer, light
  transparent = false, -- true/false
  term_colors = true, -- true/false
  ending_tildes = false, -- true/false
  cmp_itemkind_reverse = false, -- true/false
  auto_detect = false, -- Auto-detect terminal theme on startup
  auto_detect_background = true, -- Auto-detect light/dark background
}

-- Setup function to apply configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  
  -- Setup commands
  require('kitty-themes.commands').setup()
  
  -- Enable auto-detection if requested
  if M.config.auto_detect then
    vim.g.kitty_themes_auto_detect = true
    require('kitty-themes.detect').setup_auto_detection()
  end
end

-- Color palette parser for kitty themes
local function parse_kitty_theme(theme_content)
  local colors = {}
  local lines = vim.split(theme_content, '\n', { plain = true })
  
  for _, line in ipairs(lines) do
    -- Skip comments and empty lines
    if line:match('^%s*#') or line:match('^%s*$') then
      goto continue
    end
    
    -- Parse color definitions
    local key, value = line:match('(%w+)%s+(.+)')
    if key and value then
      -- Clean up the color value
      value = value:gsub('#', ''):gsub('%s+', '')
      if #value == 6 then
        colors[key] = '#' .. value
      end
    end
    
    ::continue::
  end
  
  return colors
end

-- Convert kitty colors to Neovim highlight groups
local function apply_highlights(colors)
  -- Terminal colors mapping
  local terminal_colors = {
    colors.color0,   -- black
    colors.color1,   -- red
    colors.color2,   -- green
    colors.color3,   -- yellow
    colors.color4,   -- blue
    colors.color5,   -- magenta
    colors.color6,   -- cyan
    colors.color7,   -- white
    colors.color8,   -- bright black
    colors.color9,   -- bright red
    colors.color10,  -- bright green
    colors.color11,  -- bright yellow
    colors.color12,  -- bright blue
    colors.color13,  -- bright magenta
    colors.color14,  -- bright cyan
    colors.color15,  -- bright white
  }
  
  -- Set terminal colors if enabled
  if M.config.term_colors then
    for i, color in ipairs(terminal_colors) do
      if color then
        vim.g['terminal_color_' .. (i - 1)] = color
      end
    end
  end
  
  -- Basic highlight groups
  local highlights = {
    -- Editor highlights
    Normal = { fg = colors.foreground, bg = M.config.transparent and 'NONE' or colors.background },
    NormalFloat = { fg = colors.foreground, bg = colors.background },
    Cursor = { fg = colors.background, bg = colors.cursor or colors.foreground },
    CursorLine = { bg = colors.color8 or colors.background },
    LineNr = { fg = colors.color8 or colors.color7 },
    CursorLineNr = { fg = colors.foreground, bold = true },
    Visual = { bg = colors.selection_background or colors.color8 },
    VisualNOS = { bg = colors.selection_background or colors.color8 },
    Search = { fg = colors.background, bg = colors.color3 },
    IncSearch = { fg = colors.background, bg = colors.color11 },
    
    -- Syntax highlighting
    Comment = { fg = colors.color8, italic = true },
    Constant = { fg = colors.color12 or colors.color4 },
    String = { fg = colors.color2 },
    Character = { fg = colors.color2 },
    Number = { fg = colors.color13 or colors.color5 },
    Boolean = { fg = colors.color13 or colors.color5 },
    Float = { fg = colors.color13 or colors.color5 },
    Identifier = { fg = colors.color14 or colors.color6 },
    Function = { fg = colors.color12 or colors.color4 },
    Statement = { fg = colors.color13 or colors.color5 },
    Conditional = { fg = colors.color13 or colors.color5 },
    Repeat = { fg = colors.color13 or colors.color5 },
    Label = { fg = colors.color13 or colors.color5 },
    Operator = { fg = colors.color13 or colors.color5 },
    Keyword = { fg = colors.color13 or colors.color5 },
    Exception = { fg = colors.color13 or colors.color5 },
    PreProc = { fg = colors.color3 },
    Include = { fg = colors.color3 },
    Define = { fg = colors.color3 },
    Macro = { fg = colors.color3 },
    PreCondit = { fg = colors.color3 },
    Type = { fg = colors.color11 or colors.color3 },
    StorageClass = { fg = colors.color11 or colors.color3 },
    Structure = { fg = colors.color11 or colors.color3 },
    Typedef = { fg = colors.color11 or colors.color3 },
    Special = { fg = colors.color14 or colors.color6 },
    SpecialChar = { fg = colors.color9 or colors.color1 },
    Tag = { fg = colors.color9 or colors.color1 },
    Delimiter = { fg = colors.foreground },
    SpecialComment = { fg = colors.color8, italic = true },
    Debug = { fg = colors.color9 or colors.color1 },
    
    -- Error and warning
    Error = { fg = colors.color9 or colors.color1 },
    ErrorMsg = { fg = colors.color9 or colors.color1 },
    WarningMsg = { fg = colors.color11 or colors.color3 },
    
    -- Diff
    DiffAdd = { fg = colors.color2, bg = 'NONE' },
    DiffChange = { fg = colors.color3, bg = 'NONE' },
    DiffDelete = { fg = colors.color1, bg = 'NONE' },
    DiffText = { fg = colors.color4, bg = 'NONE' },
    
    -- Git signs
    GitSignsAdd = { fg = colors.color2 },
    GitSignsChange = { fg = colors.color3 },
    GitSignsDelete = { fg = colors.color1 },
    
    -- LSP
    DiagnosticError = { fg = colors.color9 or colors.color1 },
    DiagnosticWarn = { fg = colors.color11 or colors.color3 },
    DiagnosticInfo = { fg = colors.color12 or colors.color4 },
    DiagnosticHint = { fg = colors.color14 or colors.color6 },
  }
  
  -- Apply highlights
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Load a specific kitty theme
function M.load(theme_name)
  local theme_file = string.format('%s/themes/%s.conf', vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h:h'), theme_name)
  
  -- Check if theme file exists
  if vim.fn.filereadable(theme_file) == 0 then
    vim.notify('Theme file not found: ' .. theme_file, vim.log.levels.ERROR)
    return
  end
  
  -- Auto-detect background if enabled
  if M.config.auto_detect_background and not vim.g.kitty_themes_background_set then
    local background = require('kitty-themes.detect').detect_background_lightness()
    if background then
      vim.o.background = background
      vim.g.kitty_themes_background_set = true
    end
  end
  
  -- Read and parse theme
  local content = table.concat(vim.fn.readfile(theme_file), '\n')
  local colors = parse_kitty_theme(content)
  
  -- Apply the theme
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  
  vim.o.termguicolors = true
  vim.g.colors_name = theme_name
  
  apply_highlights(colors)
end

-- Get list of available themes
function M.get_themes()
  local themes_dir = string.format('%s/themes', vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h:h'))
  local themes = {}
  
  local files = vim.fn.glob(themes_dir .. '/*.conf', false, true)
  for _, file in ipairs(files) do
    local theme_name = vim.fn.fnamemodify(file, ':t:r')
    table.insert(themes, theme_name)
  end
  
  table.sort(themes)
  return themes
end

-- Auto-detection functions
M.auto_detect = require('kitty-themes.detect').auto_detect_and_load
M.detect_and_switch = require('kitty-themes.detect').detect_and_switch
M.get_terminal_info = require('kitty-themes.detect').get_terminal_info

-- Expose parse function for external use
M.parse_kitty_theme = parse_kitty_theme

return M