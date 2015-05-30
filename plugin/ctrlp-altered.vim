if exists('g:loaded_ctrlp_altered')
  finish
endif
let g:loaded_ctrlp_altered = 1

let s:save_cpo = &cpo
set cpo&vim

command! CtrlPAltered call ctrlp#init(ctrlp#altered#id())

let &cpo = s:save_cpo
unlet s:save_cpo
