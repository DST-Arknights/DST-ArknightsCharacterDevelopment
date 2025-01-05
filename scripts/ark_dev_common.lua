local function genArkSkillLevelUpPrefabName(idx, level)
  return 'ark_skill_level_up_' .. idx .. '_' .. level
end

local function parseArkSkillLevelUpPrefabName(prefabName)
  -- 匹配格式: ark_skill_level_up_数字_数字
  local idx, level = string.match(prefabName, "ark_skill_level_up_(%d+)_(%d+)")
  if idx and level then
    return tonumber(idx), tonumber(level)
  end
  return nil, nil
end

local function genArkSkillLevelTag(idx, level)
  return 'ark_skill_level_' .. idx .. '_' .. level
end

local function formatSkillLevelString(level)
  if level == 8 then
    return "Rank Ⅰ"
  elseif level ==  9 then
    return "Rank Ⅱ"
  elseif level == 10 then
    return "Rank Ⅲ"
  end
  return tostring(level)
end

return {
  genArkSkillLevelUpPrefabName = genArkSkillLevelUpPrefabName,
  parseArkSkillLevelUpPrefabName = parseArkSkillLevelUpPrefabName,
  genArkSkillLevelTag = genArkSkillLevelTag,
  formatSkillLevelString = formatSkillLevelString,
}