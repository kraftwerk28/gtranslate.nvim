" Stolen from:
" https://github.com/cjrsgu/google-translate-api-browser/blob/master/src/languages.ts#L5-L113
let s:languages = {
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

let s:langNameToCode = {}
let s:langCompletionList = []
for shortName in keys(s:languages)
  let s:longName = substitute(s:languages[shortName], ' ', '_', 'g')
  let s:langNameToCode[s:longName] = shortName
  let s:languages[shortName] = s:longName
  call add(s:langCompletionList, s:longName)
endfor

function! gtranslate#langCompletion(A, L, P)
  return filter(copy(s:langCompletionList), "v:val =~? a:A")
endfunction

function! s:getLangCode(lng)
  if index(keys(s:languages), a:lng) != -1
    return a:lng
  endif
  return get(s:langNameToCode, a:lng, '')
endfunction

function! gtranslate#runTranslate(...)
  if index([1, 2], len(a:000)) == -1
    echomsg "Wrong argument number"
    return
  endif

  if len(a:000) == 1
    if a:1 == ''
      echoerr "Unknown language"
      return
    endif
    let [l1, l2] = ['auto', s:getLangCode(a:1)]
  elseif len(a:000) == 2
    if a:1 == '' || a:2 == ''
      echomsg "Unknown language"
      return
    endif
    let [l1, l2] = [s:getLangCode(a:1), s:getLangCode(a:2)]
  endif

  let luastr = 'require("gtranslate").exec_translate("%s", "%s")'
  call luaeval(printf(luastr, l:l1, l:l2))
endfunction
