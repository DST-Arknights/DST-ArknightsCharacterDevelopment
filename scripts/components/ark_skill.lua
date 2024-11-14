local CONSTANTS = require "ark_dev_constants"

local ArkSkill = Class(function(self, inst)
  self.inst = inst
end)

function ArkSkill:SetupSkillConfig(config)
  self.config = config
  -- 搞几个默认值进去
  for _, config in ipairs(config.skills) do
    config.chargeType = config.chargeType or CONSTANTS.CHARGE_TYPE.TIME
    config.autoEmit = config.autoEmit or nil
    for _, levelConfig in ipairs(config.levels) do
      levelConfig.charge = levelConfig.charge or 1
      levelConfig.buffTime = levelConfig.buffTime or 1
      levelConfig.bullet = levelConfig.bullet or 1
      levelConfig.maxEmitCharge = levelConfig.maxEmitCharge or 1
    end
  end
  self.skills = {}
  for i, config in ipairs(config.skills) do
    local level = 1
    self.skills[i] = {
      data = {
        level = level,
        status = CONSTANTS.SKILL_STATUS.LOCKED,
        chargeProgress = 0,
        buffProgress = 0,
        bullet = 0,
        emitCharge = 0
      },
      config = config,
      levelConfig = config.levels[level],
      timeCharge = false,
      timeBuff = false
    }
  end
  for i, skill in ipairs(self.skills) do
    if skill.config.unlock then
      self:UnLock(i)
    end
  end
  self.inst:StartUpdatingComponent(self)
  -- 下次调度让客户端安装UI
  self.inst:DoTaskInTime(0, function()
    SendModRPCToClient(GetClientModRPC("arkSkill", "SetupArkSkillUi"), self.inst.userid, json.encode(config))
  end)
end

-- 便捷的几个方法
function ArkSkill:GetSkill(idx)
  return self.skills[idx]
end

function ArkSkill:GetSkillData(idx)
  return self:GetSkill(idx).data
end

function ArkSkill:GetConfig(idx)
  return self:GetSkill(idx).config
end

function ArkSkill:GetLevelConfig(idx)
  return self:GetSkill(idx).levelConfig
end

-- 时间更新
function ArkSkill:StartTimeCharge(idx)
  self:GetSkill(idx).timeCharge = true
end

function ArkSkill:StopTimeCharge(idx)
  self:GetSkill(idx).timeCharge = false
end

function ArkSkill:StartTimeBuff(idx)
  self:GetSkill(idx).timeBuff = true
end

function ArkSkill:StopTimeBuff(idx)
  self:GetSkill(idx).timeBuff = false
end

-- 状态变换

function ArkSkill:UnLock(idx)
  -- 直接去充能状态
  self:GoCharging(idx)
end

function ArkSkill:GoCharging(idx)
  local config = self:GetConfig(idx)
  local levelConfig = self:GetLevelConfig(idx)
  local data = self:GetSkillData(idx)
  data.status = CONSTANTS.SKILL_STATUS.CHARGING
  if config.chargeType == CONSTANTS.CHARGE_TYPE.TIME then
    self:StartTimeCharge(idx)
  end
  self:SyncSkillStatus(idx)
end

function ArkSkill:GoBuffing(idx)
  local data = self:GetSkillData(idx)
  data.status = CONSTANTS.SKILL_STATUS.BUFFING
  self:StartTimeBuff(idx)
  self:SyncSkillStatus(idx)
end

function ArkSkill:SyncSkillStatus(idx)
  local data = self:GetSkillData(idx)
  SendModRPCToClient(GetClientModRPC("arkSkill", "SyncSkillStatus"), self.inst.userid, idx, data.status, data.level,
    data.chargeProgress, data.buffProgress, data.bullet, data.emitCharge)
end

function ArkSkill:RequestSyncAllSkillStatus()
  -- 循环#skills计数
  for i = 1, #self.skills do
    self:SyncSkillStatus(i)
  end

end

function ArkSkill:OnUpdateBuff(idx, dt)
  if not self:GetSkill(idx).timeBuff then
    return nil
  end
  return self:AddBuffProgress(idx, dt)
end

function ArkSkill:OnUpdateTimeCharge(idx, dt)
  if not self:GetSkill(idx).timeCharge then
    return
  end
  self:AddChargeProgress(idx, dt)
end

function ArkSkill:OnUpdate(dt)
  for i = 1, #self.skills do
    -- buff流动期间, 不会自动时间充能
    local leftBuffTime = self:OnUpdateBuff(i, dt)
    if leftBuffTime == nil then
      self:OnUpdateTimeCharge(i, dt)
    elseif leftBuffTime > 0 then
      self:OnUpdateTimeCharge(i, dt + leftBuffTime)
    end
  end
end

-- 推荐暴露的方法

function ArkSkill:AddChargeProgress(idx, value)
  local data = self:GetSkillData(idx)
  local levelConfig = self:GetLevelConfig(idx)
  data.chargeProgress = data.chargeProgress + value
  local leftCharge = data.chargeProgress - levelConfig.charge
  if leftCharge >= 0 then
    data.emitCharge = data.emitCharge + 1
    if data.emitCharge < levelConfig.maxEmitCharge then
      data.chargeProgress = leftCharge
    else -- 超出最大充能量
      self:StopTimeCharge(idx)
      data.chargeProgress = 0
    end
    self:SyncSkillStatus(idx)
  end
  return leftCharge
end

function ArkSkill:AddBuffProgress(idx, value)
  local data = self:GetSkillData(idx)
  local levelConfig = self:GetLevelConfig(idx)
  data.buffProgress = data.buffProgress + value
  local leftBuff = data.buffProgress - levelConfig.buffTime
  if leftBuff >= 0 then
    data.buffProgress = leftBuff
    self:GoCharging(idx)
    self:StopTimeBuff(idx)
  end
  return leftBuff
end

function ArkSkill:HandEmitSkill(idx)
  local config = self:GetConfig(idx)
  if config.autoEmit then
    return
  end
  local data = self:GetSkillData(idx)
  if data.emitCharge <= 0 then
    return
  end
  -- TODO: 真实执行技能接口
  data.emitCharge = data.emitCharge - 1
  data.buffProgress = 0
  self:GoBuffing(idx)
end

return ArkSkill
