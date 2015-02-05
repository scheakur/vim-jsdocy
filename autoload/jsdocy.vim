"=============================================================================
" vim-jsdocy - Generate JsDoc comment
" Copyright (c) 2013 Scheakur <http://scheakur.com/>
"
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Interface {{{
function! jsdocy#add_jsdoc()
	let jsdoc = jsdocy#make_jsdoc()
	call append(line('.') - 1, jsdoc)
endfunction


function! jsdocy#make_jsdoc(...)
	let for_input_mode = get(a:, 1, 0)
	let comment_symbols = s:make_comment_symbols(for_input_mode)
	let tags = s:get_tags()
	return s:make_jsdoc(comment_symbols, tags)
endfunction
" }}}


" Tag class {{{
let s:Tag = {
\	'name': 'tag name',
\	'sub': 'sub text',
\	'opt': 'optional text',
\}


function! s:Tag.new(...)
	let tag = deepcopy(self)
	let tag.opt = get(a:, 1, '')
	return tag
endfunction


function! s:Tag.to_str()
	let opt = (self.opt != '') ? (' ' . self.opt) : ''
	return '@' . self.name . self.sub . opt
endfunction
" }}}


" Tags {{{
function! s:tag(tag_name, ...)
	let tag = deepcopy(s:Tag)
	let tag.name = a:tag_name
	let tag.sub = get(a:, 1, '')
	return tag
endfunction

let s:Param = s:tag('param', ' {}')
let s:Return = s:tag('return', ' {}')
let s:Construtor = s:tag('constructor')
" }}}


" Internal functions {{{
function! s:get_tags()
	let fn_decl = s:get_function_declaration()
	let tags = s:get_params(fn_decl)
	let opt = s:get_option(fn_decl)
	call add(tags, opt)
	return tags
endfunction


function! s:get_params(fn_decl)
	if (a:fn_decl == '')
		return []
	endif

	let params_str = substitute(a:fn_decl, '.*(\s*\([^(]*\)\s*).*', '\1', '')
	let params = []

	for str in split(params_str, '\s*,\s*')
		let p = s:Param.new(str)
		call add(params, p)
	endfor

	return params
endfunction


function! s:get_option(fn_decl)
	let fn_name = s:get_function_name(a:fn_decl)
	if s:is_constructor(fn_name)
		return s:Construtor.new()
	endif
	return s:Return.new()
endfunction


function! s:get_function_name(fn_decl)
	if (a:fn_decl == '')
		return ''
	endif
	return substitute(a:fn_decl, '.*function\s\+\(\w*\)\s*(.*', '\1', '')
endfunction


function! s:is_constructor(fn_name)
	if empty(a:fn_name)
		return 0
	endif
	let c = a:fn_name[:0]
	return c !=# '_' && c ==# toupper(c)
endfunction


function! s:get_function_declaration()
	let num = line('.')
	let lines = getbufline('%', num, num + 10)
	let fn_lines = []
	let in_fn = 0

	for line in lines
		if !in_fn && line =~# 'function\s*\( \w*\)\?\s*('
			let in_fn = 1
		endif
		if in_fn
			call add(fn_lines, line)
			if  line =~# ')'
				break
			endif
		endif
		if !in_fn && line !~# '^\s*$'
			return ''
		endif
	endfor

	let fn_decl = join(fn_lines, '')
	return substitute(fn_decl, '\([^)]\+)\).*', '\1', '')
endfunction


function! s:make_jsdoc(symbols, tags)
	let [start, mid, end] = a:symbols
	let jsdoc = []
	call add(jsdoc, start)
	for tag in a:tags
		call add(jsdoc, mid . tag.to_str())
	endfor
	call add(jsdoc, end)
	return jsdoc
endfunction


function! s:make_comment_symbols(for_input_mode)
	if (a:for_input_mode)
		let start = '/**'
		let mid = ''
		let end = '/'
	else
		let offset = s:get_offset(a:for_input_mode)
		let space = repeat(' ', offset)
		let start = space . '/**'
		let mid = space . ' * '
		let end = space . ' */'
	endif
	return [start, mid, end]
endfunction


function! s:get_offset(with_curr_pos)
	if (a:with_curr_pos)
		return col('.') - 1
	endif
	return indent('.')
endfunction
" }}}
