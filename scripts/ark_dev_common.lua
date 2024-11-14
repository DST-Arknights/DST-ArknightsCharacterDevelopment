local constants = require("ark_dev_constants")

local function getPlayerArkSkillConfigTuning(player)
  local tuningKey = player.arkSkillTuningKey or "ARK_SKILL_" .. player.prefab:upper()
  local res = TUNING[tuningKey]
  if not res then
    return
  end
  -- 搞几个默认值进去
  for i, config in ipairs(res.skills) do
    config.chargeType = config.chargeType or constants.CHARGE_TYPE.TIME
    config.autoEmit = config.autoEmit or nil
    for j, levelConfig in ipairs(config.levels) do
      levelConfig.charge = levelConfig.charge or 1
      levelConfig.buffTime = levelConfig.buffTime or 1
      levelConfig.bullet = levelConfig.bullet or 1
      levelConfig.maxEmitCharge = levelConfig.maxEmitCharge or 1
    end
  end
  return res
end

return {
  getPlayerArkSkillConfigTuning = getPlayerArkSkillConfigTuning
}