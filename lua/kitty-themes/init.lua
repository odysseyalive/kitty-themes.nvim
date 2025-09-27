local M = {}

-- Configuration defaults
M.config = {
  style = "darker", -- darker, dark, cool, deep, warm, warmer, light
  transparent = false, -- true/false
  term_colors = true, -- true/false
  ending_tildes = false, -- true/false
  cmp_itemkind_reverse = false, -- true/false
}

-- Setup function to apply configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  -- Setup commands directly to avoid circular dependency
  M.setup_commands()
end

-- Color parser
local function parse_kitty_theme(theme_content)
  local colors = {}
  local lines = vim.split(theme_content, '\n', { plain = true })
  
  for _, line in ipairs(lines) do
    if line:match('^%s*#') or line:match('^%s*$') then
      goto continue
    end
    
    local key, value = line:match('([%w_]+)%s+(.+)')
    if key and value then
      value = value:gsub('#', ''):gsub('%s+', '')
      if #value == 6 then
        colors[key] = '#' .. value
      end
    end
    
    ::continue::
  end
  
  return colors
end

-- Light theme detection
local function is_light_theme(bg_color)
  if not bg_color or bg_color == 'NONE' then
    return false
  end
  local hex = bg_color:gsub('#', '')
  if #hex ~= 6 then
    return false
  end
  
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  
  local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
  return luminance > 0.5
end

-- Load theme
function M.load(theme_name)
  local theme_file = string.format('%s/themes/%s.conf', vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h:h'), theme_name)
  
  if vim.fn.filereadable(theme_file) == 0 then
    vim.notify('Theme file not found: ' .. theme_file, vim.log.levels.ERROR)
    return
  end
  
  local content = table.concat(vim.fn.readfile(theme_file), '\n')
  local colors = parse_kitty_theme(content)
  
  -- Ensure we have required colors
  if not colors.background or not colors.foreground then
    vim.notify('Invalid theme: missing background or foreground colors', vim.log.levels.ERROR)
    return
  end
  
  -- Clear everything first
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  
  -- Set essential options
  vim.o.termguicolors = true
  vim.g.colors_name = theme_name
  
  -- Set background option before applying highlights
  local is_light = is_light_theme(colors.background)
  vim.o.background = is_light and 'light' or 'dark'
  
  -- Set terminal colors if enabled
  if M.config.term_colors then
    local terminal_colors = {
      colors.color0, colors.color1, colors.color2, colors.color3,
      colors.color4, colors.color5, colors.color6, colors.color7,
      colors.color8, colors.color9, colors.color10, colors.color11,
      colors.color12, colors.color13, colors.color14, colors.color15,
    }
    for i, color in ipairs(terminal_colors) do
      if color then
        vim.g['terminal_color_' .. (i - 1)] = color
      end
    end
  end
  
  -- Apply comprehensive highlights
  local bg_color = M.config.transparent and 'NONE' or colors.background
  local cursor_line_bg = M.config.transparent and 'NONE' or (colors.selection_background or colors.color0 or colors.background)
  
  local highlights = {
    -- Editor highlights
    Normal = { fg = colors.foreground, bg = bg_color },
    NormalFloat = { fg = colors.foreground, bg = M.config.transparent and 'NONE' or colors.background },
    NormalNC = { fg = colors.foreground, bg = bg_color }, -- Non-current windows
    Cursor = { fg = colors.background, bg = colors.cursor or colors.foreground },
    CursorLine = { bg = cursor_line_bg },
    CursorColumn = { bg = cursor_line_bg },
    LineNr = { fg = colors.color8 or colors.color7, bg = M.config.transparent and 'NONE' or colors.background },
    CursorLineNr = { fg = colors.foreground, bg = cursor_line_bg, bold = true },
    SignColumn = { fg = colors.color8, bg = M.config.transparent and 'NONE' or colors.background },
    Visual = { bg = colors.selection_background or colors.color8 },
    VisualNOS = { bg = colors.selection_background or colors.color8 },
    Search = { fg = colors.background, bg = colors.color3 },
    IncSearch = { fg = colors.background, bg = colors.color11 },
    
    -- Window and UI elements
    StatusLine = { fg = colors.foreground, bg = colors.color0 or colors.background },
    StatusLineNC = { fg = colors.color8, bg = colors.color0 or colors.background },
    TabLine = { fg = colors.color8, bg = colors.color0 or colors.background },
    TabLineFill = { bg = colors.color0 or colors.background },
    TabLineSel = { fg = colors.foreground, bg = colors.background },
    WinSeparator = { fg = colors.color8 },
    VertSplit = { fg = colors.color8 },
    
    -- Popup menu
    Pmenu = { fg = colors.foreground, bg = colors.color0 or colors.background },
    PmenuSel = { fg = colors.background, bg = colors.color6 },
    PmenuSbar = { bg = colors.color8 },
    PmenuThumb = { bg = colors.foreground },
    
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
    
    -- Additional important groups for proper background
    EndOfBuffer = { fg = M.config.ending_tildes and (colors.color8 or colors.color7) or bg_color, bg = bg_color },
    NonText = { fg = colors.color8 or colors.color7, bg = bg_color },
    Whitespace = { fg = colors.color8 or colors.color7 },
    SpecialKey = { fg = colors.color8 or colors.color7 },
    
    -- Floating windows
    FloatBorder = { fg = colors.color8, bg = M.config.transparent and 'NONE' or colors.background },
    NormalFloat = { fg = colors.foreground, bg = M.config.transparent and 'NONE' or colors.background },
    
    -- Telescope (if present)
    TelescopeNormal = { fg = colors.foreground, bg = M.config.transparent and 'NONE' or colors.background },
    TelescopeBorder = { fg = colors.color8, bg = M.config.transparent and 'NONE' or colors.background },
  }
  
  -- Apply highlights
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
  
  -- Force a redraw to ensure the background takes effect
  vim.schedule(function()
    vim.cmd('redraw!')
  end)
end

-- Get themes
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

-- Setup user commands (avoiding circular dependency)
function M.setup_commands()
  -- Main command to select and load themes
  vim.api.nvim_create_user_command('KittyThemes', function(opts)
    if opts.args and opts.args ~= '' then
      M.load(opts.args)
    else
      M.select_theme()
    end
  end, {
    nargs = '?',
    complete = function()
      return M.get_themes()
    end,
    desc = 'Load a kitty theme or open theme selector'
  })
  
  -- List all available themes
  vim.api.nvim_create_user_command('KittyThemesList', function()
    M.list_themes()
  end, {
    desc = 'List all available kitty themes'
  })
  
  -- Preview themes
  vim.api.nvim_create_user_command('KittyThemesPreview', function()
    M.preview_themes()
  end, {
    desc = 'Preview themes interactively'
  })
  
  -- Random theme
  vim.api.nvim_create_user_command('KittyThemesRandom', function()
    M.random_theme()
  end, {
    desc = 'Load a random kitty theme'
  })
end

-- Interactive theme selector
function M.select_theme()
  local themes = M.get_themes()
  
  if #themes == 0 then
    vim.notify('No kitty themes found', vim.log.levels.ERROR)
    return
  end
  
  vim.ui.select(themes, {
    prompt = 'Select a kitty theme:',
    format_item = function(item)
      return item:gsub('_', ' '):gsub('%.', ' ')
    end,
  }, function(choice)
    if choice then
      M.load(choice)
      vim.notify('Loaded theme: ' .. choice)
    end
  end)
end

-- List themes (simplified version)
function M.list_themes()
  local themes = M.get_themes()
  
  if #themes == 0 then
    vim.notify('No kitty themes found', vim.log.levels.ERROR)
    return
  end
  
  print("Available themes:")
  for i, theme in ipairs(themes) do
    print(string.format("%3d. %s", i, theme))
  end
end

-- Load a random theme
function M.random_theme()
  local themes = M.get_themes()
  
  if #themes == 0 then
    vim.notify('No themes available', vim.log.levels.ERROR)
    return
  end
  
  math.randomseed(os.time())
  local random_index = math.random(1, #themes)
  local theme = themes[random_index]
  
  M.load(theme)
  vim.notify('Random theme loaded: ' .. theme)
end

-- Preview themes with quick switching
function M.preview_themes()
  local themes = M.get_themes()
  local original_theme = vim.g.colors_name
  local current_index = 1
  
  if #themes == 0 then
    vim.notify('No kitty themes found', vim.log.levels.ERROR)
    return
  end
  
  -- Find current theme index
  for i, theme in ipairs(themes) do
    if theme == original_theme then
      current_index = i
      break
    end
  end
  
  local function load_theme_at_index(index)
    if index >= 1 and index <= #themes then
      current_index = index
      M.load(themes[current_index])
      return themes[current_index]
    end
  end
  
  local function show_preview_ui()
    local current_theme = themes[current_index]
    vim.notify(string.format('Theme %d/%d: %s (← → to navigate, Enter to confirm, Esc to cancel)', 
      current_index, #themes, current_theme), vim.log.levels.INFO)
  end
  
  local function cleanup_preview_keys()
    pcall(vim.keymap.del, 'n', '<Right>')
    pcall(vim.keymap.del, 'n', '<Left>')
    pcall(vim.keymap.del, 'n', '<CR>')
    pcall(vim.keymap.del, 'n', '<Esc>')
  end
  
  -- Set up temporary keymaps
  local function setup_preview_keys()
    local opts = { silent = true, noremap = true }
    
    vim.keymap.set('n', '<Right>', function()
      local theme = load_theme_at_index(current_index + 1)
      if theme then show_preview_ui() end
    end, opts)
    
    vim.keymap.set('n', '<Left>', function()
      local theme = load_theme_at_index(current_index - 1)
      if theme then show_preview_ui() end
    end, opts)
    
    vim.keymap.set('n', '<CR>', function()
      vim.notify('Theme selected: ' .. themes[current_index])
      cleanup_preview_keys()
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
      if original_theme then
        vim.cmd('colorscheme ' .. original_theme)
      end
      vim.notify('Preview cancelled')
      cleanup_preview_keys()
    end, opts)
  end
  
  setup_preview_keys()
  show_preview_ui()
end

M.parse_kitty_theme = parse_kitty_theme

return M