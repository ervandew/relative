" Author: Eric Van Dewoestine
" Version: 0.1
"
" License: {{{
"   Copyright (c) 2005 - 2012, Eric Van Dewoestine
"   All rights reserved.
"
"   Redistribution and use of this software in source and binary forms, with
"   or without modification, are permitted provided that the following
"   conditions are met:
"
"   * Redistributions of source code must retain the above
"     copyright notice, this list of conditions and the
"     following disclaimer.
"
"   * Redistributions in binary form must reproduce the above
"     copyright notice, this list of conditions and the
"     following disclaimer in the documentation and/or other
"     materials provided with the distribution.
"
"   * Neither the name of Eric Van Dewoestine nor the names of its
"     contributors may be used to endorse or promote products derived from
"     this software without specific prior written permission of
"     Eric Van Dewoestine.
"
"   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
"   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
"   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
"   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
"   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
"   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
"   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
"   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
"   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
"   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
"   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
" }}}

" OpenFiles(arg) {{{
" Opens one or more files using the supplied command.
function! relative#OpenFiles(command, arg)
  let command = a:command
  " support vim's :tab prefix command for :Split
  if histget("cmd") =~ '^\Mtab Split ' . a:arg
    let command = 'tablast | tabnew'
  endif
  let files = s:GetFiles('', a:arg)
  for file in files
    exec command . ' ' . escape(s:Simplify(file), ' ')
  endfor
endfunction " }}}

" OpenRelative(command, arg [, open_existing]) {{{
" Open one or more relative files.
function! relative#OpenRelative(command, arg, ...)
  if a:arg =~ '\*' && a:command == 'edit'
    echohl Error
    echom ':EditRelative does not support wildcard characters.'
    echohl Normal
    return
  endif

  let dir = expand('%:p:h')
  let files = s:GetFiles(dir, a:arg)
  for file in files
    let file = s:Simplify(file)
    if len(a:000) && a:000[0]
      call s:GoToBufferWindowOrOpen(file, a:command)
    else
      exec a:command . ' ' . file
    endif
  endfor
endfunction " }}}

" GrepRelative(command, args) {{{
" Executes the supplied vim grep command with the specified pattern against
" one or more file patterns.
function! relative#GrepRelative(command, args)
  let rel_dir = expand('%:p:h')
  let cwd = getcwd()
  try
    silent exec 'lcd ' . escape(rel_dir, ' ')
    silent! exec a:command . ' ' . a:args
  finally
    silent exec 'lcd ' . escape(cwd, ' ')
  endtry
  if a:command =~ '^l'
    let numresults = len(getloclist(0))
  else
    let numresults = len(getqflist())
  endif

  if numresults == 0
    echom 'No results found.'
  endif
endfunction " }}}

" s:GetFiles(dir, arg) {{{
" Parses the supplied arg to obtain a list of files based in the supplied
" directory.
function! s:GetFiles(dir, arg)
  let dir = a:dir
  if dir != '' && dir !~ '[/\]$'
    let dir .= '/'
  endif

  let results = []
  let files = split(a:arg, '[^\\]\zs\s')
  for file in files
    " wildcard filename
    if file =~ '\*'
      let glob = split(s:Glob(dir . file), '\n')
      call map(glob, "escape(v:val, ' ')")
      if len(glob) > 0
        let results += glob
      endif

    " regular filename
    else
      call add(results, dir . file)
    endif
  endfor
  return results
endfunction " }}}

" s:Glob(expr, [honor_wildignore]) {{{
" Used to issue a glob() handling any vim options that may otherwise disrupt
" it.
function! s:Glob(expr, ...)
  if len(a:000) == 0
    let savewig = &wildignore
    set wildignore=""
  endif

  let paths = split(a:expr, '\n')
  if len(paths) == 1
    let result = glob(paths[0])
  else
    let result = join(paths, "\n")
  endif

  if len(a:000) == 0
    let &wildignore = savewig
  endif

  return result
endfunction " }}}

" s:GoToBufferWindowOrOpen(name, cmd) {{{
" Gives focus to the window containing the buffer for the supplied file, or if
" none, opens the file using the supplied command.
function! s:GoToBufferWindowOrOpen(name, cmd)
  let winnr = bufwinnr(bufnr('^' . a:name . '$'))
  if winnr != -1
    exec winnr . "winc w"
  else
    let cmd = a:cmd
    " if splitting and the buffer is a unamed empty buffer, then switch to an
    " edit.
    if cmd == 'split' && expand('%') == '' &&
     \ !&modified && line('$') == 1 && getline(1) == ''
      let cmd = 'edit'
    endif
    silent exec cmd . ' ' . escape(s:Simplify(a:name), ' ')
  endif
endfunction " }}}

" s:Simplify(file) {{{
" Simply the supplied file to the shortest valid name.
function! s:Simplify(file)
  let file = a:file

  " Don't run simplify on url files, it will screw them up.
  if file !~ '://'
    let file = simplify(file)
  endif

  " replace all '\' chars with '/' except those escaping spaces.
  let file = substitute(file, '\\\([^[:space:]]\)', '/\1', 'g')
  let cwd = substitute(getcwd(), '\', '/', 'g')
  if cwd !~ '/$'
    let cwd .= '/'
  endif

  if file =~ '^' . cwd
    let file = substitute(file, '^' . cwd, '', '')
  endif

  return file
endfunction " }}}

" CommandCompleteRelative(argLead, cmdLine, cursorPos) {{{
" Custom command completion for relative files and directories.
function! relative#CommandCompleteRelative(argLead, cmdLine, cursorPos)
  let [argLead, results] = s:CommandCompleteRelative(a:argLead, a:cmdLine, a:cursorPos)
  return s:ParseCommandCompletionResults(argLead, results)
endfunction " }}}

" CommandCompleteRelativeDirs(argLead, cmdLine, cursorPos) {{{
" Custom command completion for relative directories.
function! relative#CommandCompleteRelativeDirs(argLead, cmdLine, cursorPos)
  let [argLead, results] = s:CommandCompleteRelative(a:argLead, a:cmdLine, a:cursorPos)
  let dir = substitute(expand('%:p:h'), '\', '/', 'g')
  call filter(results, "isdirectory(dir . '/' . v:val)")
  return s:ParseCommandCompletionResults(argLead, results)
endfunction " }}}

" s:CommandCompleteRelative(argLead, cmdLine, cursorPos) {{{
" Custom command completion for relative directories.
function! s:CommandCompleteRelative(argLead, cmdLine, cursorPos)
  let dir = substitute(expand('%:p:h'), '\', '/', 'g')

  let cmdLine = strpart(a:cmdLine, 0, a:cursorPos)
  let args = split(cmdLine, '[^\\]\s\zs')
  call map(args, 'substitute(v:val, "\\([^\\\\]\\)\\s\\+$", "\\1", "")')
  let argLead = cmdLine =~ '\s$' ? '' : args[len(args) - 1]

  let results = split(s:Glob(dir . '/' . argLead . '*', 1), '\n')
  call map(results, "substitute(v:val, '\\', '/', 'g')")
  call map(results, 'isdirectory(v:val) ? v:val . "/" : v:val')
  call map(results, 'substitute(v:val, dir, "", "")')
  call map(results, 'substitute(v:val, "^\\(/\\|\\\\\\)", "", "g")')
  call map(results, "substitute(v:val, ' ', '\\\\ ', 'g')")

  return [argLead, results]
endfunction " }}}

" s:ParseCommandCompletionResults(args) {{{
" Bit of a hack for vim's lack of support for escaped spaces in custom
" completion.
function! s:ParseCommandCompletionResults(argLead, results)
  let results = a:results
  if stridx(a:argLead, ' ') != -1
    let removePrefix = escape(substitute(a:argLead, '\(.*\s\).*', '\1', ''), '\')
    call map(results, "substitute(v:val, '^" . removePrefix . "', '', '')")
  endif
  return results
endfunction " }}}

" vim:ft=vim:fdm=marker
