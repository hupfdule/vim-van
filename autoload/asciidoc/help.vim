let s:user_syntax_help_file= split(&rtp, ',')[0]. '/vim-asciidoc-ng/asciidoc_syntax_help.adoc'


""
" Open a short syntax help in a new window
"
" If a user provided help file is found at
" `.vim/vim-asciidoc-ng/asciidoc_syntax_help.adoc` that one is displayed.
" Otherwise the default help file provided by this plugin is displayed.
"
" The option 'g:asciidoc_help_vertial' defines whether the new windows be
" be split vertically.
function! asciidoc#help#syntax() abort
  " TODO: Additionally to split/vsplit support tabs and floating windows
  " TODO: Also allow opening botright, etc.
  " TODO: DIfferentiate betwen "syntax help" and "vim plugin help".
  "       Provide both. Can "vim plugin help" be generated somehow?
  "       At least the <Plug>mappings (and maybe the commands) may be
  "       displayed (even if without additional description)
  " TODO: Avoid opening it twice if it is already open.
  "       Instead jump to the existing window.
  " TODO: Provide nnoremap for closing the window (q or gq?)
  if filereadable(s:user_syntax_help_file)
    let l:syntax_help_file= s:user_syntax_help_file
  else
    let l:syntax_help_file= s:default_syntax_help_file
  endif

  let l:cmd= 'split ' . l:syntax_help_file
  if get(g:, 'asciidoc_help_vertical', 0)
    let l:cmd= 'v' . l:cmd
  endif
  execute l:cmd
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap nomodifiable
  normal gg
endfunction
