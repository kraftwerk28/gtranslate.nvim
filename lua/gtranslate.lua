local M = {}
local translate_api = require("api")
local api, fn = vim.api, vim.fn

local function translate_selection(from_lng, to_lng)
  local bufnum, start_line, start_col, _ = unpack(fn.getpos("'<"))
  local _, end_line, end_col, _ = unpack(fn.getpos("'>"))
  local selected_lines =
    api.nvim_buf_get_lines(bufnum, start_line-1, end_line, true)

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
        bufnum,
        nth_line,
        nth_line + 1,
        true,
        {translated_line}
      )
    end
    translate_api.translate(line, from_lng, to_lng, callback)
  end
end

function M.exec_translate(...)
  translate_selection(...)
end

return M
