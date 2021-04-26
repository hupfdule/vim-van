
let s:setext_underline_chars= ['=', '-', '~', '^', '+']


""
" Search for a heading.
" This searches for ATX as well as Setext headings.
"
" This function only returns the line number of the next heading. To get
" more details about a heading (the text, the level, etc.) call
" @function(asciidoc#sections#get_heading)
"
" @param {lnum}  The line number to start the search from.
" @param {flags} The search flags to use.
"                The following flags are supported:
"                  'c'    accept match on line {lnum}
"                  'b'    search backward instead of forward
"                Use an empty string for the default flags.
" @returns The line number of the next heading or 0 if no heading
"          could be found.
"          The returned line number will always be the line number of the
"          actual heading text and not the line number of a preceding label
"          or anchor and also not the line number of a succeeding Setext
"          underline.
function! asciidoc#sections#search_heading(lnum, flags) abort
  " TODO: Check validity of lnum and flags

  let l:allow_current_line = stridx(a:flags, 'c') !=# -1
  let l:range = stridx(a:flags, 'b') !=# -1
        \ ? reverse(range(1, l:allow_current_line ? a:lnum : a:lnum - 1))
        \ : range(l:allow_current_line ? a:lnum : a:lnum + 1, line('$'))

  let l:old_pos = getcurpos()
  call cursor(a:lnum, 0)

  let l:next_heading = 0
  for l:lnum in l:range
    let l:line = getline(l:lnum)

    " Check ATX heading
    if l:line =~# g:asciidoc#regex#atx_heading
      let l:next_heading = l:lnum
      break
    endif

    " Check Setext heading
    let l:prevline = getline(l:lnum - 1)
    let l:nextline = getline(l:lnum + 1)
    if l:nextline         =~# g:asciidoc#regex#setext_heading_underline
          \ && l:line     =~# g:asciidoc#regex#setext_heading_text
          \ && l:prevline =~# g:asciidoc#regex#heading_preceding_line
      let l:next_heading = l:lnum
      break
    endif
  endfor

  call setpos('.', l:old_pos)
  return l:next_heading
endfunction


""
" Return a dict with details about the section heading at line {lnum}.
"
" The given {lnum} must be the line with the actual heading text. It may
" not be the Setext underline and it may not be a leading anchor line. The
" line number returned by @function(asciidoc#sections#search_heading) will
" always return the correct line number.
"
" If there is not section heading at {lnum} an empty dict is returned.
"
" Otherwise a dict with the following content is returned:
"   - 'lnum':    The line number of the actual heading text. Will be the same
"                as the argument {lnum}.
"   - 'type':    The type of heading. May be one of:
"                - atx_symmetric
"                - atx_asymmetric
"                - setext
"   - 'level':   The level of the section. Level 0 is is the document tile or
"                a document part title.
"   - 'title':   The actual title text.
"   - 'anchors': A list of the primary and secondary anchors. If no anchors
"                are defined it will be an empty list.
"
" @returns a dict with the info about the section heading at line {lnum} or
"          an empty dict if no section heading was found.
function! asciidoc#sections#get_heading_info(lnum) abort
  let l:line = getline(a:lnum)

  " try ATX heading
  let l:info = s:get_atx_heading_info(a:lnum)
  if l:info !=# {}
    return l:info
  endif

  " try Setext heading
  let l:info = s:get_setext_heading_info(a:lnum)
  if l:info !=# {}
    return l:info
  endif

  " if neither an ATX nor a Setext heading could be found, return an empty
  " dict.
  return {}
endfunction


""
" Return the heading info for an ATX heading at line {lnum}.
"
" The given {lnum} must be the line with the actual heading text.
" If there is no ATX section heading at {lnum} an empty dict is returned
" (even if there is a valid Setext section heading at {lnum}).
"
" See @function(asciidoc#sections#get_heading_info) for details about the
" returned dict.
"
" @returns a dict with the info about the section heading at line {lnum} or
"          an empty dict if no section heading was found.
function! s:get_atx_heading_info(lnum) abort
  let l:line  = getline(a:lnum)
  let l:match = matchlist(l:line, g:asciidoc#regex#atx_heading)
  if l:match ==# []
    " if the current line is not an ATX heading, just return an empty dict
    return {}
  elseif getline(a:lnum - 1) !~# g:asciidoc#regex#heading_preceding_line
    " if the line above {lnum} is not valid for a heading, this is not a
    " heading as well. We return an empty dict then.
    return {}
  else
    let l:info = {}
    let l:info['lnum']    = a:lnum
    let l:info['level']   = len(l:match[1]) - 1
    let l:info['title']   = asciidoc#sections#strip_inline_anchors(l:match[2])
    let l:info['type']    = l:match[3] !=# '' ? 'symmetric' : 'atx_asymmetric'
    let l:info['anchors'] = asciidoc#sections#get_inline_anchors(l:match[2])

    let l:primary_anchor = s:get_primary_anchor(a:lnum)
    if l:primary_anchor !=# ''
      let l:info['anchors'] = extend([l:primary_anchor], l:info['anchors'])
    endif

    return l:info
  endif
endfunction


""
" Return the heading info for an ATX heading at line {lnum}.
"
" The given {lnum} must be the line with the actual heading text.
" If there is no ATX section heading at {lnum} an empty dict is returned
" (even if there is a valid Setext section heading at {lnum}).
"
" See @function(asciidoc#sections#get_heading_info) for details about the
" returned dict.
"
" @returns a dict with the info about the section heading at line {lnum} or
"          an empty dict if no section heading was found.
function! s:get_setext_heading_info(lnum) abort
  let l:line            = getline(a:lnum)
  let l:underline       = getline(a:lnum + 1)
  let l:match           = matchlist(l:line, g:asciidoc#regex#setext_heading_text)
  let l:match_underline = matchlist(l:underline, g:asciidoc#regex#setext_heading_underline)
  if l:match ==# []
    " if the current line is not a Setext heading, just return an empty dict
    return {}
  elseif l:match_underline ==# []
    " if the line below {lnum} is not a valid Setext underline, this is not a
    " heading as well. We return an empty dict then.
    return {}
  elseif abs(len(substitute(l:line, '\s\+$', '', '')) - len(substitute(l:underline, '\s\+$', '', ''))) > 1
    " If the heading text and its underline differ in length (with a
    " tolerance of 1 char) this is not a heading as well. We return an
    " empty dict then.
    return {}
  elseif getline(a:lnum - 1) !~# g:asciidoc#regex#heading_preceding_line
    " if the line above {lnum} is not valid for a heading, this is not a
    " heading as well. We return an empty dict then.
    return {}
  else
    let l:info = {}
    let l:info['lnum']    = a:lnum
    let l:info['level']   = index(s:setext_underline_chars, l:match_underline[1])
    let l:info['title']   = asciidoc#sections#strip_inline_anchors(l:match[0])
    let l:info['type']    = 'setext'
    let l:info['anchors'] = asciidoc#sections#get_inline_anchors(l:match[2])

    let l:primary_anchor = s:get_primary_anchor(a:lnum)
    if l:primary_anchor !=# ''
      let l:info['anchors'] = extend([l:primary_anchor], l:info['anchors'])
    endif

    return l:info
  endif
endfunction


""
" Get the inline anchors of a section heading title.
"
" The {title} must be the title without any ATX level markers.
"
" @returns a list of all the inline anchors, starting with the primary one
"          (that must be located at the right with at least one space
"          separating it from the rest.
"          If there are no inline anchors an empty list is returned.
function! asciidoc#sections#get_inline_anchors(title) abort
  let l:anchors = []

  let l:finished = 0
  let l:count = 1
  while !finished
    let l:match = matchlist(a:title, g:asciidoc#regex#anchor, 0, l:count)
    if l:match !=# []
      let l:count += 1
      let l:anchors = add(l:anchors, l:match[1])
    else
      let l:finished = 1
    endif
  endwhile

  " If the last anchor is actually a primary anchor (prepended by a
  " whitespace character) move it to the beginning of the result.
  if len(l:anchors) ># 0 && match(a:title, '\s\+\[\[' . l:anchors[-1] . '\]\]\s*$') !=# -1
    let l:primary = remove(l:anchors, -1)
    let l:anchors = extend([l:primary], l:anchors)
  endif

  return l:anchors
endfunction


""
" Strip all inline anchors from the given text.
"
" Multiple whitespaces around anchors are reduced to one space.
" Leading and trailing whitespace around {text} is removed.
"
" This will only remove inline anchors. It will not remove anchors in the
" shorthand notation ([#anchor])
"
" @returns the {text} with all anchors removed
function! asciidoc#sections#strip_inline_anchors(text) abort
  " hack: Add spaces to make matching the leading and trailing anchors
  " easier. Those spaces will be trimmed at the any anyway.
  let l:stripped = ' ' . a:text . ' '
  " replace anchors /without/ surrounding spaces with an empty string
  let l:stripped = substitute(l:stripped, '\%(\S\zs' . g:asciidoc#regex#anchor . '\ze\S\)\+', '', 'g')
  " replace anchors surrounded by spaces with a single space
  let l:stripped = substitute(l:stripped, '\%(\s*' . g:asciidoc#regex#anchor . '\s*\)\+', ' ', 'g')
  "  remove remaining leading and trailing whitespace
  let l:stripped = trim(l:stripped)

  return l:stripped
endfunction


""
" Get the primary anchor from the lines above {lnum}.
"
" Only label lines may be between {lnum} and the anchor line.
"
" Both lines may be either a label line or an anchor line. However, if
" {lnum}-1 is a valid anchor line, {lnum}-2 is ignored.
"
" It is assumed that {lnum} contains a section heading. This is not
" validated by this method.
"
" @returns the anchor above the given line or an empty string if no anchor
" was found.
function! s:get_primary_anchor(lnum) abort
  let l:prev= getline(a:lnum - 1)
  " try normal anchor
  let l:match = matchlist(l:prev, '^' . g:asciidoc#regex#anchor . '\s*$')
  if l:match !=# []
    return l:match[1]
  endif

  " try shorthand anchor
  let l:match = matchlist(l:prev, '^' . g:asciidoc#regex#anchor_short . '\s*$')
  if l:match !=# []
    return l:match[1]
  endif

  " if the preveding line is a label, try the line before it.
  if l:prev =~# g:asciidoc#regex#label_line
    return s:get_primary_anchor(a:lnum - 1)
  endif

  return ''
endfunction


""
" Jump to the next/previous section heading.
"
" {count} specifies the number of section headings to jump. If there are
" not enough section headings remaining in the target direction, no jump will
" be done.
"
" If {backwards} is 'v:true' the jump will be made backwards.
"
" @param {count} the number of section headings to jump (1 to jump to the
"                next section heading)
" @param {mode} the mode to operate in. May be 'v' for visual mode.
"               Actually other values are not checked. This is only used
"               for reselection of the visual area.
" @param {backwards} if 'v:true' the jump will be executed backwards
"
" TODO: How to test mappings in normal, visual and operator pending mode?
function! asciidoc#sections#jump_to_next_section_title(count, mode, backwards) abort
  " reselect visual area if we should operate in visual mode
  if a:mode ==# 'v'
    normal! gv
  endif

  let l:flags = ''
  if a:backwards
    let l:flags .= 'b'
  endif

  let l:lnum = line('.')
  for i in range(1, a:count)
    let l:lnum = asciidoc#sections#search_heading(l:lnum, l:flags)
    " if there aren't enough sections to jump, don't jump at all
    if l:lnum ==# 0
      return
    endif
  endfor

  " Jump to the first column of the target section heading
  call cursor(l:lnum, 1)
endfunction


""
" Jump to the next/previous sibling or parent/child section heading.
"
" {count} specifies the number of section headings to jump. If there are
" not enough section headings remaining in the target direction, no jump will
" be done.
"
" If {backwards} is 'v:true' the jump will be made backwards.
"
" @param {count}     The number of section headings to jump (1 to jump to the
"                    next section heading).
" @param {mode}      The mode to operate in. May be 'v' for visual mode.
"                    Actually other values are not checked. This is only used
"                    for reselection of the visual area.
" @param {traversal} Specifies whether to search for:
"                       'sibling': sibling sections
"                       'parent-child': parent / child sections
" @param {backwards} If 'v:true' the jump will be executed backwards.
"                    For a 'parent-child' traversal backwars means
"                    searching for parent sections, otherwise for child
"                    sections.
"
" TODO: How to test mappings in normal, visual and operator pending mode?
function! asciidoc#sections#jump_to_section_title(count, mode, traversal, backwards) abort
  " FIXME: Validate parameters
  let l:cur_section = asciidoc#sections#get_heading_info(line('.'))
  if l:cur_section ==# {}
    let l:cur_section_line = asciidoc#sections#search_heading(line('.'), 'b')
    let l:cur_section = asciidoc#sections#get_heading_info(l:cur_section_line)
  endif

  " If the cursor is before the first section title, do nothing
  if l:cur_section ==# {}
    return
  endif

  let l:flags = a:backwards ? 'b' : ''

  " When searching for child sections, stop at the first wrong section
  if a:traversal ==# 'parent-child' && !a:backwards
    let l:flags .= '1'
  endif

  " find the next section heading of the target level
  let l:next_section_lnum = l:cur_section['lnum']
  let l:level = l:cur_section['level']
  for i in range(1, a:count)
    if a:traversal ==# 'parent-child'
      if a:backwards
        let l:level = l:level - 1
      else
        let l:level = l:level + 1
      endif
    endif
    let l:next_section_lnum = s:find_next_section_heading(l:next_section_lnum, l:level, l:flags)
    if l:next_section_lnum ==# 0
      break
    endif
  endfor

  " jump if a target could be found
  if l:next_section_lnum !=# 0
    call cursor(l:next_section_lnum, 1)
  endif
endfunction


""
" Return the line number of the next section heading of the given {level}.
"
" @param {lnum} The line number to start search at (inclusive).
" @param {flags} Any combination of the following:
"                'b': search backwards instead of forwards
"                '1': stop after the first found heading, even if it didn't
"                     match
" @returns the line number of the next section heading of the given {level}
"          or 0 if no matching section heading could be found
function! s:find_next_section_heading(lnum, level, flags) abort
  let l:next_section_lnum = a:lnum
  while v:true
    if a:flags =~# 'b'
      let l:start_lnum = l:next_section_lnum - 1
    else
      let l:start_lnum = l:next_section_lnum + 1
    endif

    " if we get before the first line, Stop
    if l:start_lnum <=# 0
      return 0
    endif

    let l:next_section_lnum = asciidoc#sections#search_heading(l:start_lnum, a:flags)

    " stop if no further section heading was found
    if l:next_section_lnum ==# 0
      return 0
    endif

    " if the found headings level matches the requested one, return it
    let l:next_section = asciidoc#sections#get_heading_info(l:next_section_lnum)
    if l:next_section['level'] ==# a:level
      return l:next_section_lnum
    elseif a:flags =~# '1'
      " if we should stop at the first found heading, do this here
      return 0
    endif
  endwhile

  return 0
endfunction
