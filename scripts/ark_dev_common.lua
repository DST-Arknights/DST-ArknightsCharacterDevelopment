local function genArkSkillLevelUpPrefabName(idx, level)
  return 'ark_skill_level_up_' .. idx .. '_' .. level
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
  genArkSkillLevelTag = genArkSkillLevelTag,
  formatSkillLevelString = formatSkillLevelString,
}