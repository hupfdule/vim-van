" FIXME: We could also support an /additional/ set of regexes that provide
" capture groups for things like secondary anchors, actual title, etc.

""
" An ATX heading line.
" It supports markdown style heading markers ('#').
"
" Capturing group 1 contains the leading level markers.
" Capturing group 2 contains the actual heading text (including any optional inline anchors).
" Capturing group 3 contains the optional trailing level markers (including the leading whitespace).
let asciidoc#regex#atx_heading  = '^'
let asciidoc#regex#atx_heading .= '\('                                     " the level markers                                    (group 1)
let asciidoc#regex#atx_heading .=   '=\{1,6}'                              " up to 6 leading '='
let asciidoc#regex#atx_heading .=   '\|'                                   " or
let asciidoc#regex#atx_heading .=   '\#\{1,6}'                             " up to 6 leading '#' (markdown style)
let asciidoc#regex#atx_heading .= '\)'
let asciidoc#regex#atx_heading .= '\s\+'                                   " at least 1 space
let asciidoc#regex#atx_heading .= '\(\S.\{-}\)'                            " the actual title: at least 1 non-space character     (group 2)
let asciidoc#regex#atx_heading .= '\(\s\+\1\)\?'                           " optional trailing level markers                      (group 3)
let asciidoc#regex#atx_heading .= '$'


""
" The line preceding an actual heading line.
" For a valid heading this must be one of:
"  - the start of the file
"  - an empty line
"  - an anchor line
"  - a label line
let asciidoc#regex#heading_preceding_line  = ''
let asciidoc#regex#heading_preceding_line .= '\%('
let asciidoc#regex#heading_preceding_line .=   '\%^'                " start of file
let asciidoc#regex#heading_preceding_line .=   '\|'                 " or
let asciidoc#regex#heading_preceding_line .=   '^\s*$'              " empty line
let asciidoc#regex#heading_preceding_line .=   '\|'                 " or
let asciidoc#regex#heading_preceding_line .=   '^\[.*\]\s*$'        " anchor line
let asciidoc#regex#heading_preceding_line .=   '\|'                 " or
let asciidoc#regex#heading_preceding_line .=   '^\.[^.].*\s*$'      " label line
let asciidoc#regex#heading_preceding_line .= '\)'

""
" The actual setext heading text.
" It must not be an anchor (enclosed in brackets) and not be a label
" (starting with a dot).
let asciidoc#regex#setext_heading_text  = ''
let asciidoc#regex#setext_heading_text .= '\%('
let asciidoc#regex#setext_heading_text .=    '\%('                         " must either (to avoid matching anchor lines)
let asciidoc#regex#setext_heading_text .=      '\%(^[^[].*[^]]\s*$\)'      " have not starting or ending bracket
let asciidoc#regex#setext_heading_text .=      '\|'                        " or
let asciidoc#regex#setext_heading_text .=      '\%(^[^[].*]\s*$\)'         " have not starting bracket
let asciidoc#regex#setext_heading_text .=      '\|'                        " or
let asciidoc#regex#setext_heading_text .=      '\%(^\[.*[^]]\s*$\)'        " have not ending bracket
let asciidoc#regex#setext_heading_text .=   '\)'
let asciidoc#regex#setext_heading_text .=   '\&'                           " and
let asciidoc#regex#setext_heading_text .=   '\%(^[^.].*$\)'                " must not start with a dot (must not be a label)
let asciidoc#regex#setext_heading_text .= '\)'

""
" The underline under a setext heading.
" This must match the length of the actual heading text ± 1 character (2
" for python AsciiDoc), but this is not possible to express via regex.
" Therefore this check must be done afterwards.
"
" Capturing group 1 contains a single underline char
let asciidoc#regex#setext_heading_underline  = ''
let asciidoc#regex#setext_heading_underline .= '^'
let asciidoc#regex#setext_heading_underline .= '\([=\-~^+]\)\1\+'          " one of the underline chars at least twice            (group 1)
let asciidoc#regex#setext_heading_underline .= '\s*'
let asciidoc#regex#setext_heading_underline .= '$'                         " and optional trailing whitespace

""
" Block delimiters.
" The opening and ending delimiters must match exactly in length (at least
" for asciidoctor), but this is not possible to express via regex.
" Therefore this check must be done afterwards.
" Also it is absolutely impossible to distinguish an ending block delimiter
" that incidentally happens to have the same length as the line preceding
" it from a setext heading without parsing the document.
"
" Capturing group 1 contains the delimiter chars.
let asciidoc#regex#block_delimiters  = '^'
let asciidoc#regex#block_delimiters .= '\%('
let asciidoc#regex#block_delimiters .=   '\([-.~_+^=*\/]\)\1\{3,}'         " at least 4 delimiter characters                      (group 1)
let asciidoc#regex#block_delimiters .=   '\|'                              " or
let asciidoc#regex#block_delimiters .=   '--'                              " exactly 2 dashes (an open block)
let asciidoc#regex#block_delimiters .= '\)'
let asciidoc#regex#block_delimiters .= '\s*'                               " and optional trailing whitespace
let asciidoc#regex#block_delimiters .= '$'

""
" Bibliography entries.
" This actually only matches the line with the bibliography anchor.
"
" Capturing group 1 contains the bibref.
" Capturing group 2 (optional) contains the reftext
" Capturing group 3 (optional) contains the entries content (from the remainder of the line)
let asciidoc#regex#bib_entry  = '^'
let asciidoc#regex#bib_entry .= '\s*[-*]\s*'                               " a leading dash or asterisk
let asciidoc#regex#bib_entry .= '\[\[\['                                   " three opening brackets
let asciidoc#regex#bib_entry .= '\(\w\+\)'                                 " at least one word character as the actual bibref     (group 1)
let asciidoc#regex#bib_entry .= '\%(,\s*'                                  " optionally after a comma
let asciidoc#regex#bib_entry .=   '\(.\{-\}\)'                             " the reference text                                   (group 2)
let asciidoc#regex#bib_entry .= '\)\?'
let asciidoc#regex#bib_entry .= '\]\]\]'                                   " three closing brackets
let asciidoc#regex#bib_entry .= '\s*\(.*\)'                                " the remainder of the line as the refs actual content (group 3)
let asciidoc#regex#bib_entry .= '$'


""
" An anchor.
" This is a regular anchor that is enclosed in double brackets.
" It is not an exact definition of such an anchor, because it must be a
" valid XMLName, but this regex actually accepts any characters except [,]
" and whitespace.
"
" Capturing group 1 contains the anchor name.
let asciidoc#regex#anchor  = '\[\['                                        " two opening brackets
let asciidoc#regex#anchor .= '\([^\[\][:space:]]\+\)'                      " at least on char (except brackets and whitespace)    (group 1)
let asciidoc#regex#anchor .= '\]\]'                                        " two closing brackets

""
" An anchor in shorthand notation.
" This is an anchor with only a single pair of brackets and a leading #
" before the anchor name.
"
" Capturing group 1 contains the anchor name.
let asciidoc#regex#anchor_short  = '\[#'                                   " one opening bracket and a hash sign
let asciidoc#regex#anchor_short .= '\([^\[\][:space:]]\+\)'                " at least on char (except brackets and whitespace)    (group 1)
let asciidoc#regex#anchor_short .= '\]'                                    " one closing bracket

""
" A label line
" A label line must start with a dot, immediately followed by the label
" text.
"
" Capturing group 1 contains the label text.
let asciidoc#regex#label_line  = '^'                                       " at the start of the line
let asciidoc#regex#label_line .= '\.'                                      " a dot
let asciidoc#regex#label_line .= '\(\S.\+\)'                               " the actual label text (starting with non-whitespace) (group 1)
let asciidoc#regex#label_line .= '\s\+'                                    " an arbitrary number of whitespace after it
let asciidoc#regex#label_line .= '$'
