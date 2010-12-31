" Author: Eric Van Dewoestine
" Version: 0.1
"
" License: {{{
"   Copyright (c) 2005 - 2010, Eric Van Dewoestine
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

" Command Declarations {{{

if !exists(':EditRelative')
  command -nargs=1 -complete=customlist,relative#CommandCompleteRelative
    \ EditRelative :call relative#OpenRelative('edit', '<args>', 1)
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ SplitRelative :call relative#OpenRelative('split', '<args>', 1)
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ TabnewRelative :call relative#OpenRelative('tablast | tabnew', '<args>')
  command -nargs=1 -complete=customlist,relative#CommandCompleteRelative
    \ ReadRelative :call relative#OpenRelative('read', '<args>')
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ ArgsRelative :call relative#OpenRelative('args', '<args>')
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ ArgAddRelative :call relative#OpenRelative('argadd', '<args>')
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ VimgrepRelative :call relative#GrepRelative('vimgrep', <q-args>)
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ VimgrepAddRelative :call relative#GrepRelative('vimgrepadd', <q-args>)
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ LvimgrepRelative :call relative#GrepRelative('lvimgrep', <q-args>)
  command -nargs=+ -complete=customlist,relative#CommandCompleteRelative
    \ LvimgrepAddRelative :call relative#GrepRelative('lvimgrepadd', <q-args>)
  command -nargs=1 -complete=customlist,relative#CommandCompleteRelativeDirs
    \ CdRelative :exec 'cd ' . expand('%:p:h') . '/<args>'
  command -nargs=1 -complete=customlist,relative#CommandCompleteRelativeDirs
    \ LcdRelative :exec 'lcd ' . expand('%:p:h') . '/<args>'
endif

if exists(':Split') != 2
  command -nargs=+ -complete=file
    \ Split :call relative#OpenFiles('split', '<args>')
endif
if !exists(':Tabnew') != 2
  command -nargs=+ -complete=file
    \ Tabnew :call relative#OpenFiles('tablast | tabnew', '<args>')
endif

" }}}

" vim:ft=vim:fdm=marker
