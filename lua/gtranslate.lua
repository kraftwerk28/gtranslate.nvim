local function require_libs()
  local ok, cjson = pcall(require, 'cjson')
  if not ok then
    print('Module `lua-cjson` is not installed')
    return false
  end
  local ok, request = pcall(require, 'http.request')
  if not ok then
    print('Module `http` is not installed')
    return false
  end
  local _, utils = pcall(require, 'http.util')

  return true, cjson, request, utils
end

local function translate(text, from_lng, to_lng)
  local ok, cjson, request, utils = require_libs()
  if not ok then return end
  if text:gsub('%s+', '') == '' then return text end

  local base = 'https://translate.googleapis.com'
  local path = '/translate_a/single'
  local params = {
    client = 'gtx',
    sl = from_lng,
    tl = to_lng,
    dt = 't',
    q = text,
  }
  local url = string.format('%s%s?%s', base, path, utils.dict_to_query(params))

  local req = request.new_from_uri(url)
  local _, stream = req:go(5)
  local ok, result = pcall(
    function()
      local b = cjson.decode(stream:get_body_as_string())
      return b[1][1][1]
    end
  )
  if ok then
    return result
  else
    print('Failed to translate', result)
    return text
  end
end

local MAX_LINE_LEN = 65535

local function buf_translate(lang1, lang2)
  local get_lines = vim.api.nvim_buf_get_lines
  local set_lines = vim.api.nvim_buf_set_lines
  local from_lang, to_lang
  if lang2 == nil then
    from_lang, to_lang = 'auto', lang1
  else
    from_lang, to_lang = lang1, lang2
  end

  local startpos, endpos = vim.fn.getpos [['<]], vim.fn.getpos [['>]]
  local bufnr = startpos[1]
  local start_line, start_col = startpos[2], startpos[3]
  local end_line, end_col = endpos[2], endpos[3]
  local lines = get_lines(bufnr, start_line - 1, end_line, true)

  if start_line == end_line then
    local line = lines[1]
    local text = line:sub(start_col, end_col)
    local new_text = line:sub(1, start_col - 1) ..
                       translate(text, from_lang, to_lang)
    if end_col <= MAX_LINE_LEN then
      new_text = new_text .. line:sub(end_col + 1)
    end
    set_lines(bufnr, start_line - 1, end_line, true, {new_text})
  else
    local translated = {}
    local line = lines[1]
    local text = line:sub(start_col)
    local tr = translate(text, from_lang, to_lang)
    table.insert(translated, line:sub(1, start_col - 1) .. tr)
    for i = 2, #lines - 1 do
      tr = translate(lines[i], from_lang, to_lang)
      table.insert(translated, tr)
    end
    line = lines[#lines]
    text = line:sub(1, end_col)
    tr = translate(text, from_lang, to_lang)
    if end_col <= MAX_LINE_LEN then tr = tr .. line:sub(end_col + 1) end
    table.insert(translated, tr)
    set_lines(bufnr, start_line - 1, end_line, true, translated)
  end
end

local function exec_translate(...)
  local args = {...}
  local cb = function() buf_translate(unpack(args)) end
  vim.schedule(cb)
end

return {exec_translate = exec_translate}
