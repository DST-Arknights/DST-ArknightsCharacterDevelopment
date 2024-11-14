local CONSTANTS = require "ark_dev_constants"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local Text = require "widgets/text"

local ArkSkill = Class(Widget, function(self, owner, config)
  Widget._ctor(self, "ArkSkill")
  self.owner = owner
  self.size = {128, 128}

  local skill = self:AddChild(Image(config.atlas, config.image))
  self.skill = skill
  skill:SetSize(self.size)

  local handEmitShadow = self:AddChild(Image("images/ui.xml", "black.tex"))
  self.handEmitShadow = handEmitShadow
  -- 设置底部对齐
  handEmitShadow:SetPosition(0, -self.size[2] / 2, 0)
  handEmitShadow:SetVRegPoint(ANCHOR_BOTTOM)
  handEmitShadow:SetSize(self.size)
  -- 设置黑色半透明
  handEmitShadow:SetTint(1, 1, 1, 0.6)

  local chargeShadow = self:AddChild(Image("images/ui.xml", "white.tex"))
  self.chargeShadow = chargeShadow
  chargeShadow:SetPosition(0, -self.size[2] / 2, 0)
  chargeShadow:SetVRegPoint(ANCHOR_BOTTOM)
  chargeShadow:SetSize(self.size)
  -- 设置绿色半透明
  chargeShadow:SetTint(0, 1, 0, 0.4)

  local buffShadow = self:AddChild(Image("images/ui.xml", "white.tex"))
  self.buffShadow = buffShadow
  buffShadow:SetPosition(0, -self.size[2] / 2, 0)
  buffShadow:SetVRegPoint(ANCHOR_BOTTOM)
  buffShadow:SetSize(self.size)
  -- 设置橘黄色半透明
  buffShadow:SetTint(1, 0.5, 0, 0.3)

  local stop = self:AddChild(Image("images/ark_skill.xml", "stop.tex"))
  self.stop = stop
  stop:SetSize(self.size)

  local lock = self:AddChild(Image("images/ark_skill.xml", "lock.tex"))
  self.lock = lock
  lock:SetSize(self.size)

  local autoEmit = self:AddChild(Image("images/ark_skill.xml", "auto_emit.tex"))
  self.autoEmit = autoEmit
  autoEmit:Hide()

  local frame = self:AddChild(Image("images/ark_skill.xml", "frame.tex"))
  frame:SetSize(self.size)
  local status = self:AddChild(Widget("ark_skill_status"))
  status:SetPosition(0, -self.size[2] / 2 - 20, 0)
  local statusImg = status:AddChild(Image("images/ark_skill.xml", "sprite_skill_ready.tex"))
  self.statusImg = statusImg
  statusImg:SetPosition(0, -12, 0)
  local statusText = status:AddChild(Text(FALLBACK_FONT_OUTLINE, 32))
  self.statusText = statusText
  statusText:SetPosition(10, 0, 0)
  statusText:SetFont(CODEFONT)

  -- 加一个文本框, 用来展示emitCharge
  local emitChargeText = self:AddChild(Text(FALLBACK_FONT_OUTLINE, 32))
  self.emitChargeText = emitChargeText
  emitChargeText:SetPosition(0, self.size[2] / 2 + 20, 0)

  self.config = config
  self.levelConfig = config.levels[1]
  self.emitCharge = 0
  self:SetChargeProgress(0)
  self:SetBuffProgress(0)
  self.owner:StartUpdatingComponent(self)
end)

local function CaseShadowScale(scale)
  local paddingScale = 0.08
  return paddingScale + (1 - 2 * paddingScale) * scale
end

local function UpdateTimeCharge(self, dt)
  if self.timeCharge == nil then
    return nil
  end
  self.timeCharge = self.timeCharge + dt
  local leftTime = self:SetChargeProgress(self.timeCharge)
  if leftTime <= 0 then
    self:StopTimeCharge()
  end
  return leftTime
end

local function UpdateTimeBuff(self, dt)
  if self.timeBuff == nil then
    return nil
  end
  self.timeBuff = self.timeBuff + dt
  local leftTime = self:SetBuffProgress(self.timeBuff)
  if leftTime <= 0 then
    self:StopTimeBuff()
  end
  return leftTime
end

function ArkSkill:SetChargeProgress(current)
  local total = self.levelConfig.charge
  self.statusText:SetString(string.format("%d/%d", math.floor(math.min(current, total - 1)), total))
  self.chargeShadow:SetScale(1, CaseShadowScale(current / total))
  return total - current
end

function ArkSkill:SetBullet(bullet)
  local total = self.levelConfig.bullet
  self.statusText:SetString(string.format("%d/%d", bullet, total))
  self.buffShadow:SetScale(1, CaseShadowScale(bullet / total))
end

function ArkSkill:StartTimeCharge(from)
  self.timeCharge = from
end

function ArkSkill:StopTimeCharge()
  self.timeCharge = nil
end

function ArkSkill:SetBuffProgress(current)
  local total = self.levelConfig.buffTime
  self.buffShadow:SetScale(1, 1 - CaseShadowScale(current / total))
  return total - current
end

function ArkSkill:StartTimeBuff(from)
  self.timeBuff = from
end

function ArkSkill:StopTimeBuff()
  self.timeBuff = nil
end

function ArkSkill:SyncSkillStatus(status, level, chargeProgress, buffProgress, bullet, emitCharge)
  print('SyncSkillStatus', status, level, chargeProgress, buffProgress, bullet, emitCharge)
  self.levelConfig = self.config.levels[level]
  self.emitCharge = emitCharge
  self.emitChargeText:SetString(tostring(emitCharge))

  -- 自动触发图案
  if self.config.autoEmit then
    if status == CONSTANTS.SKILL_STATUS.LOCKED then
      self.autoEmit:Hide()
    end
    self.autoEmit:Show()
  end
  -- 充能遮罩只在充能状态且充能没满时展示, 其余隐藏
  if status == CONSTANTS.SKILL_STATUS.CHARGING then
    self.chargeShadow:Show()
  else
    self.chargeShadow:Hide()
  end
  -- 状态栏, 弹药模式固定展示弹药
  if status == CONSTANTS.SKILL_STATUS.BULLETING then
    self.statusImg:SetTexture("images/ark_skill.xml", "sprite_skill_bullet.tex")
    self.statusText:SetColour(1, 1, 1, 1)
    self:SetBullet(bullet, self.levelConfig.bullet)
    self.stop:Show()
  else
    self.stop:Hide()
  end
  -- buff遮罩只在buff状态且buff没满时展示, 其余隐藏
  if status == CONSTANTS.SKILL_STATUS.BUFFING then
    self.statusImg:SetTexture("images/ark_skill.xml", "sprite_skill_notready.tex")
    self.statusText:SetColour(1, 1, 1, 1)
    self:StartTimeBuff(buffProgress)
    self.buffShadow:Show()
  else
    self:StopTimeBuff()
    self.buffShadow:Hide()
  end
  if status == CONSTANTS.SKILL_STATUS.LOCKED then
    self.lock:Show()
  else
    self.lock:Hide()
  end

  -- 手动触发的遮罩
  if self.emitCharge > 0 and not self.config.autoEmit and status ~= CONSTANTS.SKILL_STATUS.BUFFING then
    self.handEmitShadow:Hide()
  else
    self.handEmitShadow:Show()
  end

  -- 充能计时器只在类型为时间充能且充能状态且充能没满时启动, 其余停止

  self:SetChargeProgress(chargeProgress)
  if self.config.chargeType == CONSTANTS.CHARGE_TYPE.TIME and status == CONSTANTS.SKILL_STATUS.CHARGING
    and self.emitCharge < self.levelConfig.maxEmitCharge then
    self:StartTimeCharge(chargeProgress)
  else
    self:StopTimeCharge()
  end
  if status == CONSTANTS.SKILL_STATUS.LOCKED then
    self.statusImg:SetTexture("images/ark_skill.xml", "sprite_skill_notready.tex")
    self.statusText:SetColour(1, 1, 1, 1)
    self.statusText:SetString("LOCK")
  elseif status == CONSTANTS.SKILL_STATUS.CHARGING then
    if self.config.autoEmit then
      self.statusImg:SetTexture("images/ark_skill.xml", "sprite_skill_notready.tex")
      if self.emitCharge >= self.levelConfig.maxEmitCharge then
        self.statusText:SetString("")
      end
    else
      if self.emitCharge >= 1 then
        self.statusImg:SetTexture("images/ark_skill.xml", "sprite_skill_ready.tex")
        self.statusText:SetColour(0, 0, 0, 1)
      else
        self.statusImg:SetTexture("images/ark_skill.xml", "sprite_skill_notready.tex")
        self.statusText:SetColour(1, 1, 1, 1)
      end
      if self.emitCharge >= self.levelConfig.maxEmitCharge then
        self.statusText:SetString("READY")
      end
    end
  end
end

local function OnUpdate(self, dt)
  -- auto emit 旋转
  if self.autoEmit:IsVisible() then
    self.autoEmit:SetRotation(self.autoEmit:GetRotation() - 360 * dt / 10)
  end
  -- buff期间技能停止充能
  local leftBuffTime = UpdateTimeBuff(self, dt)
  if leftBuffTime == nil then
    UpdateTimeCharge(self, dt)
  elseif leftBuffTime > 0 then
    UpdateTimeCharge(self, dt + leftBuffTime)
  end
end

-- OnUpdate 需要第一帧检测, 第一帧要作点事情
function ArkSkill:OnUpdate(dt)
  SendModRPCToServer(GetModRPC("arkSkill", "RequestSyncAllSkillStatus"))
  self.OnUpdate = OnUpdate
end

return ArkSkill
