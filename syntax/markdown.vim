" Vim syntax file
" Language:	Markdown
" Maintainer:	Ben Williams <benw@plasticboy.com>
" URL:		http://plasticboy.com/markdown-vim-mode/
" Remark:	Uses HTML syntax file
" TODO: 	Handle stuff contained within stuff (e.g. headings within blockquotes)


" Read the HTML syntax to start with
if version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim

  if exists('b:current_syntax')
    unlet b:current_syntax
  endif
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif

syn spell toplevel
syn case ignore
syn sync linebreaks=1

let s:conceal = ''
let s:concealends = ''
if has('conceal')
  let s:conceal = ' conceal'
  let s:concealends = ' concealends'
endif

"additions to HTML groups
syn region htmlItalic start="\%(^\|\s\)\zs\*\ze[^\\\*\t ]" end="[^\\\*\t ]\zs\*\ze\_W" keepend
syn region htmlItalic start="\%(^\|\s\)\zs_\ze[^\\_\t ]" end="[^\\_\t ]\zs_\ze\_W" keepend
syn region htmlBold start="\*\*\ze\S" end="\S\zs\*\*" keepend
syn region htmlBold start="__\ze\S" end="\S\zs__" keepend
syn region htmlBoldItalic start="\*\*\*\ze\S" end="\S\zs\*\*\*" keepend
syn region htmlBoldItalic start="___\ze\S" end="\S\zs___" keepend

" [link](URL) | [link][id] | [link][] | ![image](URL)
syn region mkdFootnotes matchgroup=mkdDelimiter start="\[^"    end="\]"
execute 'syn region mkdID matchgroup=mkdDelimiter    start="\["    end="\]" contained oneline' . s:conceal
execute 'syn region mkdURL matchgroup=mkdDelimiter   start="("     end=")"  contained oneline' . s:conceal
execute 'syn region mkdLink matchgroup=mkdDelimiter  start="\\\@<!!\?\[" end="\n\{-,1}[^]]\{-}\zs\]\ze[[(]" contains=@mkdNonListItem,@Spell nextgroup=mkdURL,mkdID skipwhite oneline' . s:concealends

" Autolink without angle brackets.
" mkd  inline links:           protocol   optional  user:pass@       sub/domain                 .com, .co.uk, etc      optional port   path/querystring/hash fragment
"                            ------------ _____________________ --------------------------- ________________________ ----------------- __
syntax match   mkdInlineURL /https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*/

" Autolink with parenthesis.
syntax region  mkdInlineURL matchgroup=mkdDelimiter start="(\(https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*)\)\@=" end=")"

" Autolink with angle brackets.
syn region mkdInlineURL matchgroup=mkdDelimiter start="\\\@<!<\ze[a-z][a-z0-9,.-]\{1,22}:\/\/[^> ]*>" end=">"

" Link definitions: [id]: URL (Optional Title)
syn region mkdLinkDef matchgroup=mkdDelimiter   start="^ \{,3}\zs\[" end="]:" oneline nextgroup=mkdLinkDefTarget skipwhite
syn region mkdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mkdLinkTitle,mkdLinkDef skipwhite skipnl oneline
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+"+     end=+"+  contained
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+'+     end=+'+  contained
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+(+     end=+)+  contained

"HTML headings
syn region htmlH1       start="^\s*#"                   end="$" contains=@Spell
syn region htmlH2       start="^\s*##"                  end="$" contains=@Spell
syn region htmlH3       start="^\s*###"                 end="$" contains=@Spell
syn region htmlH4       start="^\s*####"                end="$" contains=@Spell
syn region htmlH5       start="^\s*#####"               end="$" contains=@Spell
syn region htmlH6       start="^\s*######"              end="$" contains=@Spell
syn match  htmlH1       /^.\+\n=\+$/ contains=@Spell
syn match  htmlH2       /^.\+\n-\+$/ contains=@Spell

"define Markdown groups
syn match  mkdLineBreak    /  \+$/
syn region mkdBlockquote   start=/^\s*>/                   end=/$/ contains=mkdLineBreak,@Spell
syn region mkdCode         start=/\(\([^\\]\|^\)\\\)\@<!`/ end=/\(\([^\\]\|^\)\\\)\@<!`/
syn region mkdCode         start=/\s*``[^`]*/              end=/[^`]*``\s*/
syn region mkdCode         start=/^\s*\z(`\{3,}\)[^`]*$/   end=/^\s*\z1`*\s*$/
syn region mkdCode         start=/\s*\~\~[^\~]*/           end=/[^\~]*\~\~\s*/
syn region mkdCode         start=/^\s*\z(\~\{3,}\)\s*[0-9A-Za-z_+-]*\s*$/         end=/^\s*\z1\~*\s*$/
syn region mkdCode         start="<pre[^>]*\\\@<!>"        end="</pre>"
syn region mkdCode         start="<code[^>]*\\\@<!>"       end="</code>"
syn region mkdFootnote     start="\[^"                     end="\]"
syn match  mkdCode         /^\s*\n\(\(\s\{8,}[^ ]\|\t\t\+[^\t]\).*\n\)\+/
syn match  mkdCode         /\%^\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/
syn match  mkdCode         /^\s*\n\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/ contained
syn match  mkdListItem     /^\s*\%([-*+]\|\d\+\.\)\s\+/ contained
syn region mkdListItemLine start="^\s*\%([-*+]\|\d\+\.\)\s\+" end="$" oneline contains=@mkdNonListItem,mkdListItem,@Spell
syn region mkdNonListItemBlock start="\(\%^\(\s*\([-*+]\|\d\+\.\)\s\+\)\@!\|\n\(\_^\_$\|\s\{4,}[^ ]\|\t+[^\t]\)\@!\)" end="^\(\s*\([-*+]\|\d\+\.\)\s\+\)\@=" contains=@mkdNonListItem,@Spell
syn region lqdHighlight    start=/^{%\s*highlight\(\s\+\w\+\)\{0,1}\s*%}$/ end=/^{%\s*endhighlight\s*%}$/
syn match  mkdRule         /^\s*\*\s\{0,1}\*\s\{0,1}\*$/
syn match  mkdRule         /^\s*-\s\{0,1}-\s\{0,1}-$/
syn match  mkdRule         /^\s*_\s\{0,1}_\s\{0,1}_$/
syn match  mkdRule         /^\s*-\{3,}$/
syn match  mkdRule         /^\s*\*\{3,5}$/

" YAML frontmatter
"
if get(g:, 'vim_markdown_frontmatter', 0)
  syn include @yamlTop syntax/yaml.vim
  syn region Comment matchgroup=mkdDelimiter start="\%^---$" end="^---$" contains=@yamlTop
  unlet! b:current_syntax
endif

if get(g:, 'vim_markdown_toml_frontmatter', 0)
  try
    syn include @tomlTop syntax/toml.vim
    syn region Comment matchgroup=mkdDelimiter start="\%^+++$" end="^+++$" transparent contains=@tomlTop
    unlet! b:current_syntax
  catch /E484/
    syn region Comment matchgroup=mkdDelimiter start="\%^+++$" end="^+++$"
  endtry
endif

if get(g:, 'vim_markdown_json_frontmatter', 0)
  try
    syn include @jsonTop syntax/json.vim
    syn region Comment matchgroup=mkdDelimiter start="\%^{$" end="^}$" contains=@jsonTop
    unlet! b:current_syntax
  catch /E484/
    syn region Comment matchgroup=mkdDelimiter start="\%^{$" end="^}$"
  endtry
endif

if get(g:, 'vim_markdown_math', 0)
  syn include @tex syntax/tex.vim
  syn region mkdMath matchgroup=mkdDelimiter start="\\\@<!\$" end="\$" contains=@tex
  syn region mkdMath matchgroup=mkdDelimiter start="\\\@<!\$\$" end="\$\$" contains=@tex
endif

syn cluster mkdNonListItem contains=@htmlTop,htmlItalic,lqdHighlight,htmlBold,htmlBoldItalic,mkdFootnotes,mkdInlineURL,mkdLink,mkdLinkDef,mkdLineBreak,mkdBlockquote,mkdCode,mkdRule,htmlH1,htmlH2,htmlH3,htmlH4,htmlH5,htmlH6,mkdMath

"highlighting for Markdown groups
HtmlHiLink lqdHighlight     String
HtmlHiLink mkdString        String
HtmlHiLink mkdCode          String
HtmlHiLink mkdCodeStart     String
HtmlHiLink mkdCodeEnd       String
HtmlHiLink mkdFootnote      Comment
HtmlHiLink mkdBlockquote    Comment
HtmlHiLink mkdListItem      Identifier
HtmlHiLink mkdRule          Identifier
HtmlHiLink mkdLineBreak     Todo
HtmlHiLink mkdFootnotes     htmlLink
HtmlHiLink mkdLink          htmlLink
HtmlHiLink mkdURL           htmlString
HtmlHiLink mkdInlineURL     htmlLink
HtmlHiLink mkdID            Identifier
HtmlHiLink mkdLinkDef       mkdID
HtmlHiLink mkdLinkDefTarget mkdURL
HtmlHiLink mkdLinkTitle     htmlString
HtmlHiLink mkdDelimiter     Delimiter

let b:current_syntax = "mkd"

delcommand HtmlHiLink
" vim: ts=8