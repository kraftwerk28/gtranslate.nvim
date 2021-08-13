if exists('g:loaded_gtranslate_nvim')
  finish
endif

let s:save_cpo = &cpoptions
set cpoptions&vim

command -nargs=+ -range -complete=customlist,gtranslate#langCompletion
      \ Translate
      \ call gtranslate#runTranslate(<f-args>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
let g:loaded_gtranslate_nvim = 1
