local M = {}

local fn = vim.fn

local function str_split(str, sep)
  local result = {}
  sep = sep or " "
  for sub in str:gmatch("([^" .. sep .. "]+)") do
    table.insert(result, sub)
  end
  return result
end

function M.translate(text, from_lng, to_lng, callback)
  local ok, curl = pcall(require, 'plenary.curl')
  assert(ok, [["plenary.nvim" is not installed]])
  if text:gsub("%s+", "") == "" then
    return text
  end
  local on_response = vim.schedule_wrap(function(res)
    pcall(function()
      local raw = fn.json_decode(res.body)[1][1][1]
      callback(raw)
    end)
  end)
  curl.get {
    url = "https://translate.googleapis.com/translate_a/single",
    query = {
      client = "gtx",
      sl = from_lng,
      tl = to_lng,
      dt = "t",
      q = text,
    },
    callback = on_response,
  }
end

return M
