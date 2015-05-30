if !exists('g:loaded_ctrlp_altered')
  runtime! plugin/ctrlp_altered.vim
endif

let s:save_cpo = &cpo
set cpo&vim

let s:altered_var = {
  \   'init': 'ctrlp#altered#init()',
  \   'accept': 'ctrlp#altered#accept',
  \   'lname': 'altered',
  \   'sname': 'altered',
  \   'type': 'path',
  \ }

function! s:root_path()
  let out = system('git rev-parse --show-toplevel')
  if v:shell_error == 0
    return substitute(out, '\n', '', '')
  endif
endfunction

function! s:diff_command()
  if exists('g:ctrlp_altered_commit_size')
    let commit_size = g:ctrlp_altered_commit_size
  else
    let commit_size = 5
  endif

  let from_hash = system('git log --pretty=format:"%H" -n ' . commit_size . ' | tail -1')
  return 'git diff --stat --name-only HEAD && git diff --stat --name-only HEAD..' . from_hash
endfunction

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:altered_var)
else
  let g:ctrlp_ext_vars = [s:altered_var]
endif

function! ctrlp#altered#init()
  let root_path = s:root_path()
  let candidates = []

  for relative in split(system(s:diff_command()), '\n')
    let path = root_path . '/' . relative
    if filereadable(path)
      if index(candidates, relative) == -1
        call add(candidates, relative)
      endif
    endif
  endfor
  return candidates
endfunction

function! ctrlp#altered#accept(mode, str)
  call ctrlp#exit()
  execute 'edit ' . s:root_path() . '/' . a:str
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#altered#id()
  return s:id
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
