" LiquidCarbonTransparentInverse colorscheme for Neovim
" Generated from kitty theme: LiquidCarbonTransparentInverse
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'LiquidCarbonTransparentInverse'
set termguicolors
" Define colors
let s:none = 'NONE'
let s:bg_solid = '#000000'
" Check transparency from global var OR from Lua plugin config
let s:transparent = get(g:, 'kitty_themes_transparent', 0)
if !s:transparent
  silent! let s:transparent = luaeval("(function() local ok, m = pcall(require, 'kitty-themes'); return ok and m.config and m.config.transparent end)()")
endif
let s:bg = s:transparent ? s:none : s:bg_solid
let s:fg = '#afc2c2'
let s:cursor = '#ffffff'
let s:selection = '#7cbeff'

" Terminal colors
let s:color0 = '#bbcbcc'
let s:color1 = '#ff2f2f'
let s:color2 = '#549a6f'
let s:color3 = '#ccac00'
let s:color4 = '#0099cc'
let s:color5 = '#cc68c8'
let s:color6 = '#79c4cc'
let s:color7 = '#000000'
let s:color8 = '#ffffff'
let s:color9 = '#ff2f2f'
let s:color10 = '#549a6f'
let s:color11 = '#ccac00'
let s:color12 = '#0099cc'
let s:color13 = '#cc68c8'
let s:color14 = '#79c4cc'
let s:color15 = '#000000'

" Helper function for setting highlights
function! s:hi(group, guifg, guibg, attr)
  let l:attr = a:attr
  let l:sp = ''
  
  " Extract sp= from attr if present
  if l:attr =~ 'sp='
    let l:sp = ' gui' . substitute(l:attr, '.*\(sp=#[0-9a-fA-F]\{6\}\).*', '\1', '')
    let l:attr = substitute(l:attr, '\s*sp=#[0-9a-fA-F]\{6\}\s*', ' ', 'g')
    let l:attr = substitute(l:attr, '^\s\+\|\s\+$', '', 'g')  " trim whitespace
  endif
  
  if a:guibg == s:none
    exec 'hi ' . a:group . ' guifg=' . a:guifg . ' guibg=NONE gui=' . l:attr . l:sp
  else
    exec 'hi ' . a:group . ' guifg=' . a:guifg . ' guibg=' . a:guibg . ' gui=' . l:attr . l:sp
  endif
endfunction

call s:hi('StatusLine', s:fg, s:color8, 'bold')
call s:hi('StatusLineNC', s:color8, s:color0, 'NONE')
call s:hi('StatusLineTerm', s:fg, s:color8, 'bold')
call s:hi('StatusLineTermNC', s:color8, s:color0, 'NONE')
call s:hi('TabLine', s:color7, s:color0, 'NONE')
call s:hi('TabLineFill', s:color8, s:color0, 'NONE')
call s:hi('TabLineSel', s:fg, s:color4, 'bold')
call s:hi('Pmenu', s:fg, s:color8, 'NONE')
call s:hi('PmenuSel', s:bg_solid, s:color4, 'bold')
call s:hi('PmenuSbar', s:none, s:color8, 'NONE')
call s:hi('PmenuThumb', s:none, s:color7, 'NONE')
call s:hi('WinSeparator', s:color8, s:none, 'NONE')
call s:hi('VertSplit', s:color8, s:none, 'NONE')
call s:hi('EndOfBuffer', s:color8, s:none, 'NONE')
call s:hi('ColorColumn', s:none, s:color0, 'NONE')
call s:hi('SignColumn', s:color8, s:none, 'NONE')
call s:hi('FoldColumn', s:color8, s:none, 'NONE')
call s:hi('Folded', s:color8, s:color0, 'italic')
call s:hi('CurSearch', s:bg_solid, s:color3, 'bold')
call s:hi('Substitute', s:bg_solid, s:color5, 'bold')
call s:hi('MoreMsg', s:color2, s:none, 'bold')
call s:hi('ModeMsg', s:color4, s:none, 'bold')
call s:hi('Question', s:color3, s:none, 'bold')
call s:hi('CursorIM', s:bg_solid, s:cursor, 'NONE')
call s:hi('TermCursor', s:bg_solid, s:cursor, 'NONE')
call s:hi('TermCursorNC', s:bg_solid, s:color8, 'NONE')
call s:hi('SpellBad', s:color1, s:none, 'underline')
call s:hi('SpellCap', s:color3, s:none, 'underline')
call s:hi('SpellLocal', s:color6, s:none, 'underline')
call s:hi('SpellRare', s:color5, s:none, 'underline')
call s:hi('DiagnosticUnderlineError', s:none, s:none, 'underline sp=#ff2f2f')
call s:hi('DiagnosticUnderlineWarn', s:none, s:none, 'underline sp=#ccac00')
call s:hi('DiagnosticUnderlineInfo', s:none, s:none, 'underline sp=#0099cc')
call s:hi('DiagnosticUnderlineHint', s:none, s:none, 'underline sp=#79c4cc')
call s:hi('GitSignsTopdelete', s:color1, s:none, 'NONE')
call s:hi('GitSignsChangedelete', s:color5, s:none, 'NONE')
call s:hi('GitSignsUntracked', s:color8, s:none, 'NONE')
call s:hi('FloatBorder', s:color8, s:none, 'NONE')
call s:hi('FloatTitle', s:color4, s:none, 'bold')
call s:hi('QuickFixLine', s:none, s:color0, 'NONE')
call s:hi('qfLineNr', s:color3, s:none, 'NONE')
call s:hi('qfFileName', s:color4, s:none, 'NONE')
call s:hi('markdownCode', s:color6, s:color0, 'NONE')
call s:hi('markdownCodeBlock', s:color6, s:color0, 'NONE')
call s:hi('markdownCodeDelimiter', s:color8, s:none, 'NONE')
call s:hi('@text.literal.markdown', s:color6, s:color0, 'NONE')
call s:hi('@text.literal.block.markdown', s:color6, s:color0, 'NONE')
call s:hi('Normal', s:fg, s:bg, s:none)
call s:hi('NormalFloat', s:fg, s:bg, s:none)
call s:hi('Cursor', s:bg_solid, s:cursor, s:none)
call s:hi('CursorLine', s:none, s:color8, s:none)
call s:hi('CursorColumn', s:none, s:color8, s:none)
call s:hi('LineNr', s:color8, s:none, s:none)
call s:hi('CursorLineNr', s:fg, s:none, 'bold')
call s:hi('Visual', s:none, s:selection, s:none)
call s:hi('VisualNOS', s:none, s:selection, s:none)
call s:hi('Search', s:bg_solid, s:color3, s:none)
call s:hi('IncSearch', s:bg_solid, s:color11, s:none)
call s:hi('Comment', s:color8, s:none, 'italic')
call s:hi('Constant', s:color12, s:none, s:none)
call s:hi('String', s:color2, s:none, s:none)
call s:hi('Character', s:color2, s:none, s:none)
call s:hi('Number', s:color13, s:none, s:none)
call s:hi('Boolean', s:color13, s:none, s:none)
call s:hi('Float', s:color13, s:none, s:none)
call s:hi('Identifier', s:color14, s:none, s:none)
call s:hi('Function', s:color12, s:none, s:none)
call s:hi('Statement', s:color13, s:none, s:none)
call s:hi('Conditional', s:color13, s:none, s:none)
call s:hi('Repeat', s:color13, s:none, s:none)
call s:hi('Label', s:color13, s:none, s:none)
call s:hi('Operator', s:color13, s:none, s:none)
call s:hi('Keyword', s:color13, s:none, s:none)
call s:hi('Exception', s:color13, s:none, s:none)
call s:hi('PreProc', s:color3, s:none, s:none)
call s:hi('Include', s:color3, s:none, s:none)
call s:hi('Define', s:color3, s:none, s:none)
call s:hi('Macro', s:color3, s:none, s:none)
call s:hi('PreCondit', s:color3, s:none, s:none)
call s:hi('Type', s:color11, s:none, s:none)
call s:hi('StorageClass', s:color11, s:none, s:none)
call s:hi('Structure', s:color11, s:none, s:none)
call s:hi('Typedef', s:color11, s:none, s:none)
call s:hi('Special', s:color14, s:none, s:none)
call s:hi('SpecialChar', s:color9, s:none, s:none)
call s:hi('Tag', s:color9, s:none, s:none)
call s:hi('Delimiter', s:fg, s:none, s:none)
call s:hi('SpecialComment', s:color8, s:none, 'italic')
call s:hi('Debug', s:color9, s:none, s:none)
call s:hi('Error', s:color9, s:none, s:none)
call s:hi('ErrorMsg', s:color9, s:none, s:none)
call s:hi('WarningMsg', s:color11, s:none, s:none)
call s:hi('DiffAdd', s:color2, s:none, s:none)
call s:hi('DiffChange', s:color3, s:none, s:none)
call s:hi('DiffDelete', s:color1, s:none, s:none)
call s:hi('DiffText', s:color4, s:none, s:none)
call s:hi('GitSignsAdd', s:color2, s:none, s:none)
call s:hi('GitSignsChange', s:color3, s:none, s:none)
call s:hi('GitSignsDelete', s:color1, s:none, s:none)
call s:hi('DiagnosticError', s:color9, s:none, s:none)
call s:hi('DiagnosticWarn', s:color11, s:none, s:none)
call s:hi('DiagnosticInfo', s:color12, s:none, s:none)
call s:hi('DiagnosticHint', s:color14, s:none, s:none)

" Terminal colors
let g:terminal_color_0 = s:color0
let g:terminal_color_1 = s:color1
let g:terminal_color_2 = s:color2
let g:terminal_color_3 = s:color3
let g:terminal_color_4 = s:color4
let g:terminal_color_5 = s:color5
let g:terminal_color_6 = s:color6
let g:terminal_color_7 = s:color7
let g:terminal_color_8 = s:color8
let g:terminal_color_9 = s:color9
let g:terminal_color_10 = s:color10
let g:terminal_color_11 = s:color11
let g:terminal_color_12 = s:color12
let g:terminal_color_13 = s:color13
let g:terminal_color_14 = s:color14
let g:terminal_color_15 = s:color15