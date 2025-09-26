require('kitty-themes').setup({
  -- Default configuration for kitty-themes.nvim
  
  -- Style options
  transparent = false,
  term_colors = true,
  ending_tildes = false,
  
  -- Auto-detection
  auto_detect = false,
  auto_detect_background = true,
  
  -- Detection settings
  detect = {
    osc_timeout = 100,
    fallback_enabled = true,
    debug = false,
  },
})