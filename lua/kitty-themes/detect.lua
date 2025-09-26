local M = {}

-- Configuration for detection
M.config = {
  osc_timeout = 100, -- milliseconds to wait for OSC response
  fallback_enabled = true, -- enable fallback detection methods
  debug = false, -- enable debug output
}

local uv = vim.loop

-- Terminal query cache to avoid repeated queries
local query_cache = {}
local cache_duration = 30000 -- 30 seconds

-- Helper function to send OSC query and wait for response
local function osc_query(query_code, timeout)
  timeout = timeout or M.config.osc_timeout
  
  -- Check cache first
  local cache_key = query_code
  local cached = query_cache[cache_key]
  if cached and (uv.now() - cached.timestamp) < cache_duration then
    return cached.result
  end
  
  local result = nil
  local timer = uv.new_timer()
  local response_received = false
  
  -- Set up response handler
  local original_handler = vim.env.TERM_PROGRAM and function() end or nil
  
  -- Send OSC query
  io.write(string.format('\027]%s\027\\', query_code))
  io.flush()
  
  -- Wait for response with timeout
  local start_time = uv.now()
  while not response_received and (uv.now() - start_time) < timeout do
    uv.run('nowait')
    uv.sleep(10) -- Small delay to prevent tight loop
  end
  
  -- Cache the result
  query_cache[cache_key] = {
    result = result,
    timestamp = uv.now()
  }
  
  if timer then
    timer:close()
  end
  
  return result
end

-- Get terminal background color using OSC 11
function M.get_background_color()
  if M.config.debug then
    vim.notify('Detecting background color via OSC 11', vim.log.levels.DEBUG)
  end
  
  -- Skip if not in a terminal
  if not vim.env.TERM or vim.env.TERM == 'dumb' then
    return nil
  end
  
  -- Try OSC 11 query for background color
  local bg_color = osc_query('11;?')
  if bg_color then
    -- Parse RGB values from OSC response
    local r, g, b = bg_color:match('rgb:(%x+)/(%x+)/(%x+)')
    if r and g and b then
      -- Convert to proper hex values
      r = tonumber(r:sub(1, 2), 16) or 0
      g = tonumber(g:sub(1, 2), 16) or 0
      b = tonumber(b:sub(1, 2), 16) or 0
      
      if M.config.debug then
        vim.notify(string.format('Background RGB: %d, %d, %d', r, g, b), vim.log.levels.DEBUG)
      end
      
      return { r = r, g = g, b = b }
    end
  end
  
  return nil
end

-- Calculate perceived brightness of RGB color
local function get_perceived_brightness(r, g, b)
  -- Using relative luminance formula
  return (0.299 * r + 0.587 * g + 0.114 * b) / 255
end

-- Detect if background is light or dark
function M.detect_background_lightness()
  -- Try OSC query first
  local bg_color = M.get_background_color()
  if bg_color then
    local brightness = get_perceived_brightness(bg_color.r, bg_color.g, bg_color.b)
    local is_light = brightness > 0.5
    
    if M.config.debug then
      vim.notify(string.format('Background brightness: %.2f (%s)', brightness, is_light and 'light' or 'dark'), vim.log.levels.DEBUG)
    end
    
    return is_light and 'light' or 'dark'
  end
  
  -- Fallback methods
  if M.config.fallback_enabled then
    return M.fallback_background_detection()
  end
  
  return nil
end

-- Fallback background detection methods
function M.fallback_background_detection()
  -- Check common environment variables
  local theme_vars = {
    'COLORFGBG', -- Common in many terminals
    'THEME',
    'BACKGROUND',
    'COLORTERM',
  }
  
  for _, var in ipairs(theme_vars) do
    local value = vim.env[var]
    if value then
      if value:match('[Ll]ight') or value:match('[Ww]hite') then
        return 'light'
      elseif value:match('[Dd]ark') or value:match('[Bb]lack') then
        return 'dark'
      end
    end
  end
  
  -- Check terminal type
  local term = vim.env.TERM or ''
  if term:match('light') then
    return 'light'
  elseif term:match('dark') then
    return 'dark'
  end
  
  -- Default assumption for most terminals
  return 'dark'
end

-- Get current terminal name/type
function M.get_terminal_name()
  -- Check common terminal identification variables
  local term_vars = {
    'TERM_PROGRAM',      -- macOS Terminal, iTerm2
    'TERMINAL_EMULATOR', -- Some Linux terminals
    'WEZTERM_EXECUTABLE', -- WezTerm
    'KITTY_WINDOW_ID',   -- Kitty
    'ALACRITTY_SOCKET',  -- Alacritty
  }
  
  for _, var in ipairs(term_vars) do
    local value = vim.env[var]
    if value then
      -- Extract terminal name
      if var == 'TERM_PROGRAM' then
        return value:lower()
      elseif var == 'KITTY_WINDOW_ID' then
        return 'kitty'
      elseif var == 'ALACRITTY_SOCKET' then
        return 'alacritty'
      elseif var == 'WEZTERM_EXECUTABLE' then
        return 'wezterm'
      else
        return value:lower()
      end
    end
  end
  
  -- Check TERM variable for hints
  local term = vim.env.TERM or ''
  if term:match('kitty') then
    return 'kitty'
  elseif term:match('alacritty') then
    return 'alacritty'
  elseif term:match('wezterm') then
    return 'wezterm'
  elseif term:match('xterm') then
    return 'xterm'
  elseif term:match('screen') then
    return 'screen'
  elseif term:match('tmux') then
    return 'tmux'
  end
  
  return term
end

-- Detect current kitty theme (if in kitty terminal)
function M.detect_kitty_theme()
  -- Only works in kitty terminal
  if M.get_terminal_name() ~= 'kitty' then
    return nil
  end
  
  -- Try to get theme from kitty socket
  local kitty_socket = vim.env.KITTY_LISTEN_ON
  if not kitty_socket then
    return nil
  end
  
  -- This would require more complex implementation with kitty remote control
  -- For now, return nil and rely on other detection methods
  return nil
end

-- Auto-detect and load appropriate theme
function M.auto_detect_and_load()
  if M.config.debug then
    vim.notify('Starting auto-detection', vim.log.levels.DEBUG)
  end
  
  local terminal_name = M.get_terminal_name()
  local background = M.detect_background_lightness()
  
  if M.config.debug then
    vim.notify(string.format('Detected terminal: %s, background: %s', terminal_name or 'unknown', background or 'unknown'), vim.log.levels.INFO)
  end
  
  -- Try to find matching theme based on terminal and background
  local kitty_themes = require('kitty-themes').get_themes()
  local selected_theme = nil
  
  -- Look for themes matching terminal name
  if terminal_name then
    for _, theme in ipairs(kitty_themes) do
      local theme_lower = theme:lower()
      if theme_lower:match(terminal_name) then
        selected_theme = theme
        break
      end
    end
  end
  
  -- If no terminal-specific theme found, pick based on background
  if not selected_theme and background then
    for _, theme in ipairs(kitty_themes) do
      local theme_lower = theme:lower()
      if background == 'light' and (theme_lower:match('light') or theme_lower:match('day')) then
        selected_theme = theme
        break
      elseif background == 'dark' and (theme_lower:match('dark') or theme_lower:match('night')) then
        selected_theme = theme
        break
      end
    end
  end
  
  -- Fallback to popular themes
  if not selected_theme then
    local fallback_themes = {
      background == 'light' and 'Github' or 'Dracula',
      background == 'light' and 'AtomOneLight' or 'OneDark',
      'Monokai',
      'gruvbox_' .. (background or 'dark'),
    }
    
    for _, fallback in ipairs(fallback_themes) do
      if vim.tbl_contains(kitty_themes, fallback) then
        selected_theme = fallback
        break
      end
    end
  end
  
  -- Load the selected theme
  if selected_theme then
    if M.config.debug then
      vim.notify('Loading theme: ' .. selected_theme, vim.log.levels.INFO)
    end
    require('kitty-themes').load(selected_theme)
    return selected_theme
  else
    if M.config.debug then
      vim.notify('No suitable theme found', vim.log.levels.WARN)
    end
    return nil
  end
end

-- Interactive theme detection and switching
function M.detect_and_switch()
  local terminal_info = M.get_terminal_info()
  
  vim.ui.select(
    {'Auto-detect theme', 'Choose manually'},
    {
      prompt = string.format('Terminal: %s, Background: %s', terminal_info.name or 'unknown', terminal_info.background or 'unknown'),
    },
    function(choice)
      if choice == 'Auto-detect theme' then
        local theme = M.auto_detect_and_load()
        if theme then
          vim.notify('Loaded theme: ' .. theme)
        else
          vim.notify('Auto-detection failed, please choose manually')
          require('kitty-themes.commands').select_theme()
        end
      else
        require('kitty-themes.commands').select_theme()
      end
    end
  )
end

-- Get comprehensive terminal information
function M.get_terminal_info()
  local info = {
    name = M.get_terminal_name(),
    background = M.detect_background_lightness(),
    background_color = M.get_background_color(),
    term_var = vim.env.TERM,
    colorterm = vim.env.COLORTERM,
    term_program = vim.env.TERM_PROGRAM,
  }
  
  -- Add remote session detection
  info.remote = require('kitty-themes.remote').detect_remote_session()
  if info.remote.is_remote then
    info.ssh_connection = info.remote.ssh_info
    info.forwarded_display = info.remote.forwarded_display
  end
  
  return info
end

-- Setup auto-detection on colorscheme change
function M.setup_auto_detection()
  vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('KittyThemesAutoDetect', { clear = true }),
    callback = function()
      -- Small delay to ensure terminal is ready
      vim.defer_fn(function()
        if vim.g.kitty_themes_auto_detect then
          M.auto_detect_and_load()
        end
      end, 100)
    end,
  })
end

return M