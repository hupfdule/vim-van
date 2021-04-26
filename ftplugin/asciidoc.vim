" Vim filetype plugin for asciidoc files
" Language:     AsciiDoc
" Maintainer:   Marco Herrn <marco@mherrn.de>
" Last Changed: 07. September 2019
" URL:          http://github.com/hupfdule/vim-asciidoc-ng/
" License:      MIT?

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Commands =============================================================== {{{

  " Navigation ----------------------------------------------------------- {{{

    " Section jumps ...................................................... {{{

      " Jump between adjacent section headings
      nnoremap <buffer> <Plug>(VanNextSection) :<c-u>call asciidoc#sections#jump_to_next_section_title(v:count1, 'n', v:false)<cr>
      onoremap <buffer> <Plug>(VanNextSection) :<c-u>call asciidoc#sections#jump_to_next_section_title(v:count1, 'o', v:false)<cr>
      xnoremap <buffer> <Plug>(VanNextSection) :<c-u>call asciidoc#sections#jump_to_next_section_title(v:count1, 'v', v:false)<cr>
      nnoremap <buffer> <Plug>(VanPrevSection) :<c-u>call asciidoc#sections#jump_to_next_section_title(v:count1, 'n', v:true)<cr>
      onoremap <buffer> <Plug>(VanPrevSection) :<c-u>call asciidoc#sections#jump_to_next_section_title(v:count1, 'o', v:true)<cr>
      xnoremap <buffer> <Plug>(VanPrevSection) :<c-u>call asciidoc#sections#jump_to_next_section_title(v:count1, 'v', v:true)<cr>
      " TODO: Allow disabling of mappings
      nmap <buffer> ]] <Plug>(VanNextSection)
      omap <buffer> ]] <Plug>(VanNextSection)
      xmap <buffer> ]] <Plug>(VanNextSection)
      nmap <buffer> [[ <Plug>(VanPrevSection)
      omap <buffer> [[ <Plug>(VanPrevSection)
      xmap <buffer> [[ <Plug>(VanPrevSection)

      " Jump between sibling section headings
      nnoremap <buffer> <Plug>(VanNextSiblingSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'n', 'sibling', v:false)<cr>
      onoremap <buffer> <Plug>(VanNextSiblingSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'o', 'sibling', v:false)<cr>
      xnoremap <buffer> <Plug>(VanNextSiblingSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'v', 'sibling', v:false)<cr>
      nnoremap <buffer> <Plug>(VanPrevSiblingSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'n', 'sibling', v:true)<cr>
      onoremap <buffer> <Plug>(VanPrevSiblingSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'o', 'sibling', v:true)<cr>
      xnoremap <buffer> <Plug>(VanPrevSiblingSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'v', 'sibling', v:true)<cr>
      " TODO: Allow disabling of mappings
      nmap <buffer> ]} <Plug>(VanNextSiblingSection)
      omap <buffer> ]} <Plug>(VanNextSiblingSection)
      xmap <buffer> ]} <Plug>(VanNextSiblingSection)
      nmap <buffer> [{ <Plug>(VanPrevSiblingSection)
      omap <buffer> [{ <Plug>(VanPrevSiblingSection)
      xmap <buffer> [{ <Plug>(VanPrevSiblingSection)
      nmap <buffer> <c-j> <Plug>(VanNextSiblingSection)
      omap <buffer> <c-j> <Plug>(VanNextSiblingSection)
      xmap <buffer> <c-j> <Plug>(VanNextSiblingSection)
      nmap <buffer> <c-k> <Plug>(VanPrevSiblingSection)
      omap <buffer> <c-k> <Plug>(VanPrevSiblingSection)
      xmap <buffer> <c-k> <Plug>(VanPrevSiblingSection)

      " Jump between parent / child section headings
      nnoremap <buffer> <Plug>(VanNextChildSection)  :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'n', 'parent-child', v:false)<cr>
      onoremap <buffer> <Plug>(VanNextChildSection)  :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'o', 'parent-child', v:false)<cr>
      xnoremap <buffer> <Plug>(VanNextChildSection)  :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'v', 'parent-child', v:false)<cr>
      nnoremap <buffer> <Plug>(VanNextParentSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'n', 'parent-child', v:true)<cr>
      onoremap <buffer> <Plug>(VanNextParentSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'o', 'parent-child', v:true)<cr>
      xnoremap <buffer> <Plug>(VanNextParentSection) :<c-u>call asciidoc#sections#jump_to_section_title(v:count1, 'v', 'parent-child', v:true)<cr>
      " TODO: Allow disabling of mappings
      nmap <buffer> ]> <Plug>(VanNextChildSection)
      omap <buffer> ]> <Plug>(VanNextChildSection)
      xmap <buffer> ]> <Plug>(VanNextChildSection)
      nmap <buffer> [< <Plug>(VanNextParentSection)
      omap <buffer> [< <Plug>(VanNextParentSection)
      xmap <buffer> [< <Plug>(VanNextParentSection)
      nmap <buffer> <c-l> <Plug>(VanNextChildSection)
      omap <buffer> <c-l> <Plug>(VanNextChildSection)
      xmap <buffer> <c-l> <Plug>(VanNextChildSection)
      nmap <buffer> <c-h> <Plug>(VanPrevParentSection)
      omap <buffer> <c-h> <Plug>(VanPrevParentSection)
      xmap <buffer> <c-h> <Plug>(VanPrevParentSection)

      " FIXME: Provide mappings for jump to section end? (][, [], etc.)
      "        Low priority as the end of a section is always directly
      "        above the start of the next one (but there may be multiple
      "        empty lines, anchor lines and label lines in between!)



    " END Section jumps .................................................. }}}

  " END Navigation ------------------------------------------------------- }}}

  " Help ----------------------------------------------------------------- {{{

    " Syntax help ........................................................ {{{

    command!                 VanSyntaxHelp   call asciidoc#help#syntax()
    nnoremap <buffer> <Plug>(VanSyntaxHelp)  :<c-u>VanSyntaxHelp<cr>
    vnoremap <buffer> <Plug>(VanSyntaxHelp)  :<c-u>VanSyntaxHelp<cr>
    inoremap <buffer> <Plug>(VanSyntaxHelp)  <c-o>:VanSyntaxHelp<cr>
    nmap g?           <Plug>(VanSyntaxHelp)
    vmap g?           <Plug>(VanSyntaxHelp)
    imap <c-g>?       <Plug>(VanSyntaxHelp)

    " END Syntax help .................................................... }}}

  " END Help ------------------------------------------------------------- }}}

" END Commands =========================================================== }}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker :
