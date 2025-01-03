-- 将字符串按指定长度拆分成字符串数组
local function splitStringByLength(str, length)
  local result = {}
  local currentLength = 0
  local currentString = ""
  local i = 1

  while i <= #str do
    local char = str:sub(i, i)
    local byte = string.byte(char)
    local charLength = 1

    if byte >= 0 and byte <= 127 then
      currentLength = currentLength + 1
    elseif byte >= 192 and byte <= 223 then
      charLength = 2
      currentLength = currentLength + 2
    elseif byte >= 224 and byte <= 239 then
      charLength = 3
      currentLength = currentLength + 2
    elseif byte >= 240 and byte <= 247 then
      charLength = 4
      currentLength = currentLength + 2
    end

    currentString = currentString .. str:sub(i, i + charLength - 1)
    i = i + charLength

    if currentLength >= length then
      table.insert(result, currentString)
      currentString = ""
      currentLength = 0
    end
  end

  if currentString ~= "" then
    table.insert(result, currentString)
  end

  return result
end

return {
  splitStringByLength = splitStringByLength
}