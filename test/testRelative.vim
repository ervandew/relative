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

" TestOpenFiles() {{{
function! TestOpenFiles()
  call relative#OpenFiles('split',
    \ 'test/files/subdir/test1.txt test/files/subdir/test2.txt')
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test2.txt') > -1,
    \ 'Did not open test2.txt.')
endfunction " }}}

" TestOpenRelative() {{{
function! TestOpenRelative()
  view test/files/test.txt

  call relative#OpenRelative('edit', 'subdir/test1.txt', 1)
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
endfunction " }}}

" TestCommandCompleteRelative() {{{
function! TestCommandCompleteRelative()
  view test/files/test.txt

  let results = relative#CommandCompleteRelative('p', 'SplitRelative s', 15)
  call vunit#AssertEquals(1, len(results), "Wrong number of results.")
  call vunit#AssertEquals('subdir/', results[0], "Wrong result.")

  let results = relative#CommandCompleteRelative('p', 'SplitRelative subdir/t', 22)
  call vunit#AssertEquals(2, len(results), "Wrong number of results.")
  call vunit#AssertEquals('subdir/test1.txt', results[0], "Wrong result 0.")
  call vunit#AssertEquals('subdir/test2.txt', results[1], "Wrong result 1.")
endfunction " }}}

" TestSplit() {{{
function! TestSplit()
  view test/files/test.txt

  Split test/files/subdir/test1.txt test/files/subdir/test2.txt

  call vunit#AssertEquals(winnr('$'), 3)
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test2.txt') > -1,
    \ 'Did not open test2.txt.')
endfunction " }}}

" TestTabnew() {{{
function! TestTabnew()
  Tabnew test/files/subdir/test1.txt test/files/subdir/test2.txt

  call vunit#AssertEquals(tabpagenr('$'), 3)
  tabnext 2
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
  tabnext 3
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test2.txt') > -1,
    \ 'Did not open test2.txt.')
endfunction " }}}

" TestEditRelative() {{{
function! TestEditRelative()
  view test/files/test.txt

  EditRelative subdir/test1.txt

  call vunit#AssertEquals(winnr('$'), 1)
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
  call vunit#AssertEquals(getline(1), 'test 1')
endfunction " }}}

" TestSplitRelative() {{{
function! TestSplitRelative()
  view test/files/test.txt

  SplitRelative subdir/test1.txt

  call vunit#AssertEquals(winnr('$'), 2)
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
  call vunit#AssertEquals(getline(1), 'test 1')
endfunction " }}}

" TestTabnewRelative() {{{
function! TestTabnewRelative()
  view test/files/test.txt

  TabnewRelative subdir/test1.txt subdir/test2.txt

  call vunit#AssertEquals(tabpagenr('$'), 3)
  tabnext 2
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test1.txt') > -1,
    \ 'Did not open test1.txt.')
  call vunit#AssertEquals(getline(1), 'test 1')

  tabnext 3
  call vunit#AssertTrue(bufwinnr('test/files/subdir/test2.txt') > -1,
    \ 'Did not open test2.txt.')
  call vunit#AssertEquals(getline(1), 'test 2')
endfunction " }}}

" TestReadRelative() {{{
function! TestReadRelative()
  view test/files/test.txt
  call cursor(line('$'), 1)

  ReadRelative subdir/test2.txt

  call vunit#AssertTrue(getline(2) =~ 'test 2')
endfunction " }}}

" TestArgsRelative() {{{
function! TestArgsRelative()
  view test/files/test.txt

  redir => list
  silent exec 'buffers'
  redir END
  let buffers = split(list, "\n")
  call vunit#PeekRedir()
  call vunit#AssertEquals(len(buffers), 1)

  ArgsRelative files/test1.txt files/test2.txt

  redir => list
  silent exec 'buffers'
  redir END
  let buffers = split(list, "\n")
  call vunit#PeekRedir()
  call vunit#AssertEquals(len(buffers), 3)
endfunction " }}}

" vim:ft=vim:fdm=marker
