if exists("g:loaded_gtranslate_nvim")
  finish
endif

let s:save_cpo = &cpoptions
set cpoptions&vim

function s:argJoin(arglist)
  return join(map(
       \   copy(a:arglist),
       \   {_, s -> "'" . substitute(s, "'", '\\''', "g") . "'"}
       \ ), ", ")
endfunction

function s:completionWrapper(...)
  return luaeval(printf("require'gtranslate'.complete(%s)", s:argJoin(a:000)))
endfunction

function! s:runTranslate(...)
  call luaeval(printf("require'gtranslate'.run(%s)", s:argJoin(a:000)))
endfunction

command -nargs=* -range -complete=customlist,s:completionWrapper
      \ Translate call s:runTranslate(<f-args>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
let g:loaded_gtranslate_nvim = 1
