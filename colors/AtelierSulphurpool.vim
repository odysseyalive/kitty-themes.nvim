" AtelierSulphurpool colorscheme for Neovim
" Generated from kitty theme: AtelierSulphurpool

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'AtelierSulphurpool'
set termguicolors

" Define colors
let s:none = 'NONE'
let s:bg_solid = '#202745'
let s:bg = get(g:, 'kitty_themes_transparent', 0) ? s:none : s:bg_solid
let s:fg = '#969cb3'
let s:cursor = '#969cb3'
let s:selection = '#5e6686'

" Terminal colors
let s:color0 = '#202745'
let s:color1 = '#c84821'
let s:color2 = '#ab9639'
let s:color3 = '#c08a2f'
let s:color4 = '#3d8ed0'
let s:color5 = '#6678cc'
let s:color6 = '#21a1c8'
let s:color7 = '#969cb3'
let s:color8 = '#6a7394'
let s:color9 = '#c76a28'
let s:color10 = '#283256'
let s:color11 = '#5e6686'
let s:color12 = '#898ea3'
let s:color13 = '#dee1f0'
let s:color14 = '#9c6279'
let s:color15 = '#f4f7ff'

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
