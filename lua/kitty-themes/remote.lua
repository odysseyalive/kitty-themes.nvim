local M = {}

-- Remote session detection configuration
M.config = {
  ssh_env_vars = {
    'SSH_CLIENT',
    'SSH_CONNECTION', 
    'SSH_TTY'
  },
  forwarded_vars = {
    'DISPLAY',
    'KITTY_WINDOW_ID',
    'TERM_PROGRAM',
    'COLORTERM',
    'BACKGROUND_THEME'  -- Custom var for forwarded theme info
  },
  dotfile_paths = {
    '~/.config/kitty/kitty.conf',
    '~/.config/kitty/current-theme.conf',
    '~/.kitty.conf',
    '~/.config/alacritty/alacritty.yml',
    '~/.config/wezterm/wezterm.lua',
    '~/.tmux.conf'
  }
}

-- Detect if we're in a remote SSH session
function M.is_remote_session()
  for _, var in ipairs(M.config.ssh_env_vars) do
    if vim.env[var] then
      return true
    end
  end
  
  -- Check if we're in tmux/screen over SSH
  if (vim.env.TMUX or vim.env.STY) and vim.env.SSH_CONNECTION then
    return true
  end
  
  return false
end

-- Get SSH connection information
function M.get_ssh_info()
  if not M.is_remote_session() then
    return nil
  end
  
  local info = {}
  
  -- Parse SSH_CLIENT (client_ip client_port server_port)
  if vim.env.SSH_CLIENT then
    local parts = vim.split(vim.env.SSH_CLIENT, ' ')
    info.client_ip = parts[1]
    info.client_port = parts[2]
    info.server_port = parts[3]
  end
  
  -- Parse SSH_CONNECTION (client_ip client_port server_ip server_port)
  if vim.env.SSH_CONNECTION then
    local parts = vim.split(vim.env.SSH_CONNECTION, ' ')
    info.client_ip = info.client_ip or parts[1]
    info.client_port = info.client_port or parts[2]
    info.server_ip = parts[3]
    info.server_port = parts[4]
  end
  
  -- Get SSH TTY
  info.tty = vim.env.SSH_TTY
  
  return info
end

-- Check for X11 or display forwarding
function M.detect_display_forwarding()
  local forwarding = {
    x11 = false,
    display = vim.env.DISPLAY,
    forwarded_vars = {}
  }
  
  -- Check if DISPLAY is set (X11 forwarding)
  if vim.env.DISPLAY then
    forwarding.x11 = true
  end
  
  -- Check for forwarded environment variables
  for _, var in ipairs(M.config.forwarded_vars) do
    if vim.env[var] then
      forwarding.forwarded_vars[var] = vim.env[var]
    end
  end
  
  return forwarding
end

-- Parse local dotfiles for theme information
function M.parse_dotfiles_for_theme()
  local theme_info = {}
  
  for _, path in ipairs(M.config.dotfile_paths) do
    local expanded_path = vim.fn.expand(path)
    
    if vim.fn.filereadable(expanded_path) == 1 then
      local content = vim.fn.readfile(expanded_path)
      
      -- Parse different config formats
      if path:match('kitty%.conf') then
        theme_info.kitty = M.parse_kitty_config(content)
      elseif path:match('alacritty') then
        theme_info.alacritty = M.parse_alacritty_config(content)
      elseif path:match('wezterm') then
        theme_info.wezterm = M.parse_wezterm_config(content)
      elseif path:match('tmux') then
        theme_info.tmux = M.parse_tmux_config(content)
      end
    end
  end
  
  return theme_info
end

-- Parse kitty configuration for theme information
function M.parse_kitty_config(content)
  local config = {}
  
  for _, line in ipairs(content) do
    -- Skip comments
    if line:match('^%s*#') or line:match('^%s*$') then
      goto continue
    end
    
    -- Look for include statements (theme files)
    local include_file = line:match('include%s+(.+%.conf)')
    if include_file then
      -- Extract theme name from path
      local theme_name = include_file:match('([^/]+)%.conf$')
      if theme_name then
        config.theme = theme_name
      end
    end
    
    -- Look for color definitions
    local key, value = line:match('(%w+)%s+(.+)')
    if key and key:match('color') or key:match('ground') or key:match('cursor') then
      config[key] = value
    end
    
    ::continue::
  end
  
  return config
end

-- Parse alacritty configuration for theme information
function M.parse_alacritty_config(content)
  local config = {}
  local in_colors = false
  
  for _, line in ipairs(content) do
    -- Detect colors section
    if line:match('^colors:') then
      in_colors = true
      goto continue
    elseif line:match('^%w+:') and in_colors then
      in_colors = false
    end
    
    if in_colors then
      -- Parse color definitions
      local key, value = line:match('%s*(%w+):%s*(.+)')
      if key and value then
        config[key] = value
      end
    end
    
    ::continue::
  end
  
  return config
end

-- Parse wezterm configuration for theme information
function M.parse_wezterm_config(content)
  local config = {}
  
  for _, line in ipairs(content) do
    -- Look for color scheme assignments
    local scheme = line:match('color_scheme%s*=%s*["\']([^"\']+)["\']')
    if scheme then
      config.color_scheme = scheme
    end
    
    -- Look for color overrides
    local color_def = line:match('(%w+)%s*=%s*["\']([^"\']+)["\']')
    if color_def and color_def:match('color') then
      config[color_def] = line:match('["\']([^"\']+)["\']')
    end
  end
  
  return config
end

-- Parse tmux configuration for theme information  
function M.parse_tmux_config(content)
  local config = {}
  
  for _, line in ipairs(content) do
    -- Look for status bar colors and theme-related settings
    if line:match('status%-') or line:match('pane%-') or line:match('window%-') then
      local setting, value = line:match('set%s+%-g%s+([%w%-]+)%s+(.+)')
      if setting and value then
        config[setting] = value
      end
    end
  end
  
  return config
end

-- Attempt to detect theme in headless/remote environment
function M.detect_remote_theme()
  local detection = {
    method = nil,
    theme = nil,
    background = nil,
    confidence = 0
  }
  
  -- Method 1: Check forwarded environment variables
  local forwarded_theme = vim.env.BACKGROUND_THEME
  if forwarded_theme then
    detection.method = 'forwarded_env'
    detection.theme = forwarded_theme
    detection.confidence = 0.9
    return detection
  end
  
  -- Method 2: Parse dotfiles
  local dotfile_themes = M.parse_dotfiles_for_theme()
  
  if dotfile_themes.kitty and dotfile_themes.kitty.theme then
    detection.method = 'kitty_config'
    detection.theme = dotfile_themes.kitty.theme
    detection.confidence = 0.8
  elseif dotfile_themes.alacritty then
    detection.method = 'alacritty_config'
    detection.confidence = 0.7
    -- Would need mapping from alacritty themes to kitty themes
  elseif dotfile_themes.wezterm and dotfile_themes.wezterm.color_scheme then
    detection.method = 'wezterm_config'
    detection.confidence = 0.7
    -- Would need mapping from wezterm themes to kitty themes
  end
  
  -- Method 3: Guess from environment
  local term_program = vim.env.TERM_PROGRAM
  if term_program then
    if term_program:match('[Ii][Tt]erm') then
      detection.method = 'env_guess'
      detection.theme = 'Monokai'  -- Common iTerm theme
      detection.confidence = 0.3
    elseif term_program:match('[Tt]erminal') then
      detection.method = 'env_guess'
      detection.theme = 'Pro'  -- macOS Terminal default
      detection.confidence = 0.3
    end
  end
  
  -- Background detection in remote environment
  if vim.env.COLORFGBG then
    -- COLORFGBG format is typically "foreground;background"
    local parts = vim.split(vim.env.COLORFGBG, ';')
    if #parts == 2 then
      local bg_num = tonumber(parts[2])
      if bg_num then
        -- Common convention: 0-7 are dark, 8-15 are light
        detection.background = bg_num > 7 and 'light' or 'dark'
      end
    end
  end
  
  return detection
end

-- Comprehensive remote session detection
function M.detect_remote_session()
  return {
    is_remote = M.is_remote_session(),
    ssh_info = M.get_ssh_info(),
    forwarded_display = M.detect_display_forwarding(),
    dotfile_themes = M.parse_dotfiles_for_theme(),
    theme_detection = M.detect_remote_theme()
  }
end

-- Setup SSH environment forwarding helper
function M.setup_ssh_forwarding_helper()
  -- Create a helper script that can be sourced in SSH sessions
  local helper_script = [[
#!/bin/bash
# Kitty themes SSH forwarding helper
# Source this in your .bashrc or .zshrc on the remote system

# Function to forward current terminal theme info
forward_theme_info() {
  if [ -n "$KITTY_WINDOW_ID" ]; then
    # Try to get current kitty theme
    local theme=$(kitty @ get-colors 2>/dev/null | grep -E "^# " | head -1 | cut -d' ' -f2-)
    if [ -n "$theme" ]; then
      export BACKGROUND_THEME="$theme"
    fi
  fi
  
  # Forward other useful variables
  [ -n "$TERM_PROGRAM" ] && export TERM_PROGRAM
  [ -n "$COLORTERM" ] && export COLORTERM
  
  # Detect background from terminal if possible
  local bg_detect=$(detect_background_brightness)
  [ -n "$bg_detect" ] && export BACKGROUND_TYPE="$bg_detect"
}

# Background brightness detection using OSC sequences
detect_background_brightness() {
  # This would need to be implemented based on the terminal's OSC support
  echo "dark"  # Default fallback
}

# Auto-forward on SSH
if [ -n "$SSH_CONNECTION" ]; then
  forward_theme_info
fi
]]
  
  return helper_script
end

return M