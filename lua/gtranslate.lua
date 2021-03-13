local M = {}

local function require_libs()
  local ok, cjson = pcall(require, 'cjson')
  if not ok then
    print 'Module `lua-cjson` is not installed'
    return false
  end
  local ok, request = pcall(require, 'http.request')
  if not ok then
    print 'Module `http` is not installed'
    return false
  end
  local _, utils = pcall(require, 'http.util')

  return true, cjson, request, utils
end

function M.translate(text, ...)
  local ok, cjson, request, utils = require_libs()
  if not ok then return end

  local args = {...}
  local from_lng, to_lng
  if #args == 1 then
    from_lng, to_lng = 'auto', args[1]
  elseif #args == 2 then
    from_lng, to_lng = args[1], args[2]
  else
    return text
  end

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
  local ok, result = pcall(function()
    local b = cjson.decode(stream:get_body_as_string())
    return b[1][1][1]
  end)
  if ok then
    return result
  else
    print('Failed to translate', result)
    return text
  end
end

return M
