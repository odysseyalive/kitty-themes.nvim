" Monokai_Pro colorscheme for Neovim
" Generated from kitty theme: Monokai_Pro

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'Monokai_Pro'
set termguicolors

" Define colors
let s:none = 'NONE'
let s:bg_solid = '#403e41'
let s:bg = get(g:, 'kitty_themes_transparent', 0) ? s:none : s:bg_solid
let s:fg = '#fcfcfa'
let s:cursor = '#fcfcfa'
let s:selection = '#fcfcfa'

" Terminal colors
let s:color0 = '#403e41'
let s:color1 = '#ff6188'
let s:color2 = '#a9dc76'
let s:color3 = '#ffd866'
let s:color4 = '#fc9867'
let s:color5 = '#ab9df2'
let s:color6 = '#78dce8'
let s:color7 = '#fcfcfa'
let s:color8 = '#727072'
let s:color9 = '#ff6188'
let s:color10 = '#a9dc76'
let s:color11 = '#ffd866'
let s:color12 = '#fc9867'
let s:color13 = '#ab9df2'
let s:color14 = '#78dce8'
let s:color15 = '#fcfcfa'

" Helper function for setting highlights
function! s:hi(group, guifg, guibg, attr)
  if a:guibg == s:none
    exec 'hi ' . a:group . ' guifg=' . a:guifg . ' guibg=NONE gui=' . a:attr
  else
    exec 'hi ' . a:group . ' guifg=' . a:guifg . ' guibg=' . a:guibg . ' gui=' . a:attr
  endif
endfunction

" Basic highlighting
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

" Syntax highlighting
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

" Error and warning
call s:hi('Error', s:color9, s:none, s:none)
call s:hi('ErrorMsg', s:color9, s:none, s:none)
call s:hi('WarningMsg', s:color11, s:none, s:none)

" Diff
call s:hi('DiffAdd', s:color2, s:none, s:none)
call s:hi('DiffChange', s:color3, s:none, s:none)
call s:hi('DiffDelete', s:color1, s:none, s:none)
call s:hi('DiffText', s:color4, s:none, s:none)

" Git signs
call s:hi('GitSignsAdd', s:color2, s:none, s:none)
call s:hi('GitSignsChange', s:color3, s:none, s:none)
call s:hi('GitSignsDelete', s:color1, s:none, s:none)

" LSP diagnostics
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
