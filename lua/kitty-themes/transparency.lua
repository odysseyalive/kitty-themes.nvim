-- kitty-themes.nvim transparency management module
-- Centralized system for handling transparent backgrounds

local M = {}

-- Internal state
local state = {
  enabled = false,
  initialized = false,
  config_ref = nil, -- Reference to main config
}

-- Initialize transparency system
function M.init(config)
  state.config_ref = config
  state.enabled = config.transparent or false
  state.initialized = true
  
  -- Sync global variable for VIM colorschemes
  M.sync_global_var()
end

-- Get current transparency status
function M.is_enabled()
  return state.enabled
end

-- Set transparency state (programmatic control)
function M.set_enabled(enabled)
  if type(enabled) ~= 'boolean' then
    error('transparency.set_enabled: expected boolean, got ' .. type(enabled))
  end
  
  state.enabled = enabled
  
  -- Update config reference if available
  if state.config_ref then
    state.config_ref.transparent = enabled
  end
  
  -- Sync global variable for VIM colorschemes
  M.sync_global_var()
  
  -- Trigger refresh if we have an active theme
  M.refresh_theme()
end

-- Toggle transparency state
function M.toggle()
  M.set_enabled(not state.enabled)
  return state.enabled
end

-- Sync transparency state to global variable for VIM colorschemes
function M.sync_global_var()
  vim.g.kitty_themes_transparent = state.enabled and 1 or 0
end

-- Update transparency when config changes
function M.update_from_config(config)
  if not state.initialized then
    M.init(config)
    return
  end
  
  local old_enabled = state.enabled
  local new_enabled = config.transparent or false
  
  if old_enabled ~= new_enabled then
    state.enabled = new_enabled
    state.config_ref = config
    M.sync_global_var()
    M.refresh_theme()
  end
end

-- Get background color based on transparency setting
function M.get_background_color(original_bg)
  return state.enabled and 'NONE' or original_bg
end

-- Get UI background color with fallbacks
function M.get_ui_background_color(colors)
  if state.enabled then
    return 'NONE'
  end
  return colors.color0 or colors.background
end

-- Get cursor line background with transparency handling
function M.get_cursor_line_background(colors)
  if state.enabled then
    return 'NONE'
  end
  return colors.selection_background or colors.color0 or colors.background
end

-- Refresh current theme if one is loaded
function M.refresh_theme()
  -- Check if we have a current theme loaded
  if vim.g.colors_name then
    -- Try to reload the current theme via the main module
    local ok, main_module = pcall(require, 'kitty-themes')
    if ok and type(main_module.load) == 'function' then
      -- Only reload if it's a kitty theme (has our naming pattern)
      local theme_name = vim.g.colors_name
      if main_module.get_themes and main_module.get_themes()[theme_name] then
        main_module.load(theme_name)
      end
    end
  end
end

-- Terminal capability detection (basic)
function M.supports_transparency()
  -- Check common terminal types that support transparency
  local term = vim.env.TERM or ''
  local term_program = vim.env.TERM_PROGRAM or ''
  
  -- Known terminals with good transparency support
  local supported_terms = {
    'kitty', 'alacritty', 'wezterm', 'st', 'urxvt'
  }
  
  local supported_programs = {
    'kitty', 'Alacritty', 'WezTerm', 'iTerm.app'
  }
  
  -- Check TERM
  for _, supported in ipairs(supported_terms) do
    if term:find(supported) then
      return true
    end
  end
  
  -- Check TERM_PROGRAM
  for _, supported in ipairs(supported_programs) do
    if term_program:find(supported) then
      return true
    end
  end
  
  -- Conservative fallback - assume transparency is supported
  -- Users can override this behavior through configuration
  return true
end

-- Get transparency info for debugging
function M.get_debug_info()
  return {
    enabled = state.enabled,
    initialized = state.initialized,
    global_var = vim.g.kitty_themes_transparent,
    terminal_support = M.supports_transparency(),
    current_theme = vim.g.colors_name,
    config_transparent = state.config_ref and state.config_ref.transparent,
  }
end

return M