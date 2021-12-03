local M = {}

local translate_api = require("translate_api")
local lang = require("languages")

local default_to_language

local api, fn = vim.api, vim.fn

local function log_error(message)
  print("gtranslate.nvim: "..message)
end

local function translate_selection(from_lng, to_lng)
  local bufnum, start_line, start_col, _ = unpack(fn.getpos("'<"))
  local _, end_line, end_col, _ = unpack(fn.getpos("'>"))
  local selected_lines =
    api.nvim_buf_get_lines(bufnum, start_line-1, end_line, true)
  if #selected_lines == 0 then
    log_error("please select a text to translate")
    return
  end

  local end_col_utf8 = end_col
  local last_line = selected_lines[#selected_lines]
  if end_col < #last_line then
    local uindex = vim.str_utfindex(last_line, end_col)
    end_col_utf8 = vim.str_byteindex(last_line, uindex)
  end

  local lines_to_translate = {}
  for i, line in ipairs(selected_lines) do
    if i == 1 and i == #selected_lines then
      line = line:sub(start_col, end_col_utf8)
    elseif i == 1 and start_col > 1 then
      line = line:sub(start_col)
    elseif i == #selected_lines then
      line = line:sub(1, end_col_utf8)
    end
    table.insert(lines_to_translate, line)
  end

  for index, line in ipairs(lines_to_translate) do
    local function callback(translated_line)
      if index == 1 and index == #selected_lines then
        translated_line =
          selected_lines[1]:sub(1, start_col - 1) ..
          translated_line ..
          selected_lines[1]:sub(end_col_utf8 + 1)
      elseif index == 1 then
        translated_line =
          selected_lines[1]:sub(1, start_col - 1) ..
          translated_line
      elseif index == #selected_lines then
        translated_line =
          translated_line ..
          selected_lines[#selected_lines]:sub(end_col_utf8 + 1)
      end
      local nth_line = start_line + index - 2
      api.nvim_buf_set_lines(
        bufnum, nth_line, nth_line + 1,
        true, {translated_line}
      )
    end
    translate_api.translate(line, from_lng, to_lng, callback)
  end
end

local function resolve_lang_name(l)
  if lang.short_to_long[l] ~= nil then return l end
  if lang.long_to_short[l] ~= nil then return lang.long_to_short[l] end
end

function M.run(...)
  local nargs = select("#", ...)
  local from_lng, to_lng
  if nargs == 0 then
    if default_to_language == nil then
      error("`default_to_language` is not set.")
    end
    from_lng, to_lng = "auto", default_to_language
  elseif nargs == 1 then
    from_lng, to_lng = "auto", ...
  else
    from_lng, to_lng = ...
  end
  from_lng = resolve_lang_name(from_lng)
  if from_lng == nil then log_error("invalid `from` language") end
  to_lng = resolve_lang_name(to_lng)
  if to_lng == nil then log_error("invalid `to` language") end
  translate_selection(from_lng, to_lng)
end

function M.complete(arg_lead)
  local result = {}
  for _, long_name in pairs(lang.short_to_long) do
    if long_name:lower():match(arg_lead:lower()) then
      table.insert(result, long_name)
    end
  end
  return result
end

function M.setup(config)
  vim.validate {
    default_to_language = {config.default_to_language, function(l)
      if
        l == nil
        or lang.long_to_short[l] ~= nil
        or lang.short_to_long[l] ~= nil
      then
        return true
      end
    end},
  }
  default_to_language = config.default_to_language
end

return M
