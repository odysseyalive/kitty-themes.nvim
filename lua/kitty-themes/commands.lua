local M = {}

local kt_module = nil

-- Setup user commands
function M.setup(kitty_themes_module)
  kt_module = kitty_themes_module
  
  -- Main command to select and load themes
  vim.api.nvim_create_user_command('KittyThemes', function(opts)
    if opts.args and opts.args ~= '' then
      kt_module.load(opts.args)
    else
      M.select_theme()
    end
  end, {
    nargs = '?',
    complete = function()
      return kt_module.get_themes()
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
  local themes = kt_module.get_themes()
  
  if #themes == 0 then
    vim.notify('No kitty themes found', vim.log.levels.ERROR)
    return
  end
  
  vim.ui.select(themes, {
    prompt = 'Select a kitty theme:',
    format_item = function(item)
      -- Format theme names nicely
      return item:gsub('_', ' '):gsub('%.', ' ')
    end,
  }, function(choice)
    if choice then
      kt_module.load(choice)
      vim.notify('Loaded theme: ' .. choice)
    end
  end)
end

-- List all themes in a nice format
function M.list_themes()
  local themes = kt_module.get_themes()
  
  if #themes == 0 then
    vim.notify('No kitty themes found', vim.log.levels.ERROR)
    return
  end
  
  -- Create a new buffer to display themes
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = math.min(80, vim.o.columns - 10),
    height = math.min(25, vim.o.lines - 10),
    col = math.floor((vim.o.columns - 80) / 2),
    row = math.floor((vim.o.lines - 25) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Available Kitty Themes ',
    title_pos = 'center',
  })
  
  -- Prepare content
  local lines = {}
  table.insert(lines, 'Available Kitty Themes (' .. #themes .. ' total)')
  table.insert(lines, string.rep('=', 40))
  table.insert(lines, '')
  
  -- Group themes by category
  local categories = {
    Light = {},
    Dark = {},
    Material = {},
    Monokai = {},
    Gruvbox = {},
    Other = {}
  }
  
  for _, theme in ipairs(themes) do
    local theme_lower = theme:lower()
    if theme_lower:match('light') or theme_lower:match('day') then
      table.insert(categories.Light, theme)
    elseif theme_lower:match('material') then
      table.insert(categories.Material, theme)
    elseif theme_lower:match('monokai') then
      table.insert(categories.Monokai, theme)
    elseif theme_lower:match('gruvbox') then
      table.insert(categories.Gruvbox, theme)
    elseif theme_lower:match('dark') or theme_lower:match('night') then
      table.insert(categories.Dark, theme)
    else
      table.insert(categories.Other, theme)
    end
  end
  
  -- Display categories
  for category, category_themes in pairs(categories) do
    if #category_themes > 0 then
      table.insert(lines, category .. ' Themes:')
      table.insert(lines, string.rep('-', #category + 8))
      
      for _, theme in ipairs(category_themes) do
        table.insert(lines, '  • ' .. theme)
      end
      
      table.insert(lines, '')
    end
  end
  
  table.insert(lines, '')
  table.insert(lines, 'Usage: :KittyThemes <theme_name>')
  table.insert(lines, 'Press q to close, Enter to select theme under cursor')
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'kitty-themes')
  
  -- Set up keymaps for the buffer
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  
  local function select_theme_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local theme = line:match('  • (.+)')
    if theme then
      close_window()
      kt_module.load(theme)
      vim.notify('Loaded theme: ' .. theme)
    end
  end
  
  vim.keymap.set('n', 'q', close_window, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', close_window, { buffer = buf, silent = true })
  vim.keymap.set('n', '<CR>', select_theme_under_cursor, { buffer = buf, silent = true })
end

-- Preview themes with quick switching
function M.preview_themes()
  local themes = kt_module.get_themes()
  local original_theme = vim.g.colors_name
  local current_index = 1
  
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
      kt_module.load(themes[current_index])
      return themes[current_index]
    end
  end
  
  local function show_preview_ui()
    local current_theme = themes[current_index]
    vim.notify(string.format('Theme %d/%d: %s (← → to navigate, Enter to confirm, Esc to cancel)', 
      current_index, #themes, current_theme), vim.log.levels.INFO)
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
      M.cleanup_preview_keys()
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
      if original_theme then
        vim.cmd('colorscheme ' .. original_theme)
      end
      vim.notify('Preview cancelled')
      M.cleanup_preview_keys()
    end, opts)
  end
  
  function M.cleanup_preview_keys()
    vim.keymap.del('n', '<Right>')
    vim.keymap.del('n', '<Left>')
    vim.keymap.del('n', '<CR>')
    vim.keymap.del('n', '<Esc>')
  end
  
  setup_preview_keys()
  show_preview_ui()
end

-- Load a random theme
function M.random_theme()
  local themes = kt_module.get_themes()
  
  if #themes == 0 then
    vim.notify('No themes available', vim.log.levels.ERROR)
    return
  end
  
  math.randomseed(os.time())
  local random_index = math.random(1, #themes)
  local theme = themes[random_index]
  
  kt_module.load(theme)
  vim.notify('Random theme loaded: ' .. theme)
end

return M