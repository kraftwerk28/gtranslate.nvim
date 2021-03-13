if exists('g:loaded_gtranslate_nvim')
  finish
endif
let s:save_cpo = &cpoptions
set cpoptions&vim

" The code for defining user command plus autocompletion
" will be in VimScript until the stable API in Lua will be released

" Stolen from:
" https://github.com/cjrsgu/google-translate-api-browser/blob/master/src/languages.ts#L5-L113
let s:langs = {
\   'auto': 'Automatic', 'af': 'Afrikaans', 'sq': 'Albanian',
\   'am': 'Amharic', 'ar': 'Arabic', 'hy': 'Armenian', 'az': 'Azerbaijani',
\   'eu': 'Basque', 'be': 'Belarusian', 'bn': 'Bengali', 'bs': 'Bosnian',
\   'bg': 'Bulgarian', 'ca': 'Catalan', 'ceb': 'Cebuano', 'ny': 'Chichewa',
\   'zh': 'Chinese Simplified', 'zh-cn': 'Chinese Simplified',
\   'zh-tw': 'Chinese Traditional', 'co': 'Corsican', 'hr': 'Croatian',
\   'cs': 'Czech', 'da': 'Danish', 'nl': 'Dutch', 'en': 'English',
\   'eo': 'Esperanto', 'et': 'Estonian', 'tl': 'Filipino', 'fi': 'Finnish',
\   'fr': 'French', 'fy': 'Frisian', 'gl': 'Galician', 'ka': 'Georgian',
\   'de': 'German', 'el': 'Greek', 'gu': 'Gujarati', 'ht': 'Haitian Creole',
\   'ha': 'Hausa', 'haw': 'Hawaiian', 'he': 'Hebrew', 'iw': 'Hebrew',
\   'hi': 'Hindi', 'hmn': 'Hmong', 'hu': 'Hungarian', 'is': 'Icelandic',
\   'ig': 'Igbo', 'id': 'Indonesian', 'ga': 'Irish', 'it': 'Italian',
\   'ja': 'Japanese', 'jw': 'Javanese', 'kn': 'Kannada', 'kk': 'Kazakh',
\   'km': 'Khmer', 'ko': 'Korean', 'ku': 'Kurdish (Kurmanji)', 'ky': 'Kyrgyz',
\   'lo': 'Lao', 'la': 'Latin', 'lv': 'Latvian', 'lt': 'Lithuanian',
\   'lb': 'Luxembourgish', 'mk': 'Macedonian', 'mg': 'Malagasy',
\   'ms': 'Malay', 'ml': 'Malayalam', 'mt': 'Maltese', 'mi': 'Maori',
\   'mr': 'Marathi', 'mn': 'Mongolian', 'my': 'Myanmar (Burmese)',
\   'ne': 'Nepali', 'no': 'Norwegian', 'ps': 'Pashto', 'fa': 'Persian',
\   'pl': 'Polish', 'pt': 'Portuguese', 'pa': 'Punjabi', 'ro': 'Romanian',
\   'ru': 'Russian', 'sm': 'Samoan', 'gd': 'Scots Gaelic', 'sr': 'Serbian',
\   'st': 'Sesotho', 'sn': 'Shona', 'sd': 'Sindhi', 'si': 'Sinhala',
\   'sk': 'Slovak', 'sl': 'Slovenian', 'so': 'Somali', 'es': 'Spanish',
\   'su': 'Sundanese', 'sw': 'Swahili', 'sv': 'Swedish', 'tg': 'Tajik',
\   'ta': 'Tamil', 'te': 'Telugu', 'th': 'Thai', 'tr': 'Turkish',
\   'uk': 'Ukrainian', 'ur': 'Urdu', 'uz': 'Uzbek', 'vi': 'Vietnamese',
\   'cy': 'Welsh', 'xh': 'Xhosa', 'yi': 'Yiddish', 'yo': 'Yoruba', 'zu': 'Zulu',
\ }

let s:langsrev = {}
let s:langscompl = []
for shortName in keys(s:langs)
  let s:longName = substitute(s:langs[shortName], ' ', '_', 'g')
  let s:langsrev[s:longName] = shortName
  let s:langs[shortName] = s:longName
  call add(s:langscompl, s:longName)
endfor

function! s:lng_code(lng)
  if index(keys(s:langs), a:lng) != -1
    return a:lng
  endif
  return get(s:langsrev, a:lng, '')
endfunction

function! s:lang_compl(A, L, P)
  return filter(copy(s:langscompl), 'v:val =~? a:A')
endfunction

function! s:run_translate(...)
  if index([1, 2], len(a:000)) == -1
    echomsg "Wrong argument number"
    return
  endif

  if len(a:000) == 1
    let l:l1 = s:lng_code(a:1)
    if l:l1 == ''
      echoerr "Unknown language"
      return
    endif
    let l:luaexpr = printf(
        \ "require'gtranslate'.translate(vim.fn.submatch(0), '%s')",
        \ l:l1)
  elseif len(a:000) == 2
    let l:l1 = s:lng_code(a:1)
    let l:l2 = s:lng_code(a:2)
    if l:l1 == '' || l:l2 == ''
      echomsg "Unknown language"
      return
    endif
    let l:luaexpr = printf(
        \ "require'gtranslate'.translate(vim.fn.submatch(0), '%s', '%s')",
        \ l:l1,
        \ l:l2)
  endif
  normal! ma
  execute printf('s#\%%V\_.*\%%V\_.#\=luaeval("%s")#', l:luaexpr)
  normal! `a
endfunction

command -nargs=+ -range -complete=customlist,s:lang_compl
      \ Translate call <SID>run_translate(<f-args>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
let g:loaded_gtranslate_nvim = 1
