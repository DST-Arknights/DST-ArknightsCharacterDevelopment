local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local CONSTANTS = require "ark_dev_constants"
local i18n = require "ark_dev_i18n"
local TextButton = require "widgets/textbutton"

local ArkSkillDesc = Class(Widget, function(self, owner, descConfig, idx)
  Widget._ctor(self, "ArkSkillDesc")
  self.owner = owner
  self.size = {1000, 618}
  self.hotKey = descConfig.hotKey
  self.idx = idx
  local bg = self:AddChild(Image("images/ui.xml", "white.tex"))
  bg:SetSize(self.size)
  bg:SetTint(0.23, 0.23, 0.23, 0.7)
  local leftOffset = - self.size[1] / 2 + 60
  local topOffset = self.size[2] / 2 - 80
  -- 技能名称
  local skillName = self:AddChild(Text(FALLBACK_FONT_FULL, 100, descConfig.name))
  local skillNameSizeX = skillName:GetRegionSize()
  skillName:SetPosition(leftOffset + skillNameSizeX / 2, topOffset, 0)

  topOffset = topOffset - 100
  local tagLeftOffset = leftOffset + 100
  -- 小标题
  -- 被动, 没有充能方式, 没有触发方式, 没有充能值, 没有buff持续时间
  if descConfig.emitType == CONSTANTS.EMIT_TYPE.PASSIVE then
    local tag = self:AddChild(Widget("tag"))
    tag:SetPosition(tagLeftOffset, topOffset, 0)
    local tagBg = tag:AddChild(Image("images/ark_skill.xml", "skill_desc_bg4.tex"))
    local tagText = tag:AddChild(Text(FALLBACK_FONT_FULL, 70, i18n('emitType.' .. descConfig.emitType)))
  else
    local tagChargeBg = nil
    if descConfig.chargeType == CONSTANTS.CHARGE_TYPE.AUTO then
      tagChargeBg = Image("images/ark_skill.xml", "skill_desc_bg1.tex")
    elseif descConfig.chargeType == CONSTANTS.CHARGE_TYPE.UNDER_ATTACK then
      tagChargeBg = Image("images/ark_skill.xml", "skill_desc_bg3.tex")
    elseif descConfig.chargeType == CONSTANTS.CHARGE_TYPE.ATTACK then
      tagChargeBg = Image("images/ark_skill.xml", "skill_desc_bg3.tex")
    end
    local tagCharge = self:AddChild(Widget("tagCharge"))
    tagCharge:SetPosition(tagLeftOffset, topOffset, 0)
    local tagChargeBg = tagCharge:AddChild(tagChargeBg)
    local tagChargeText = tagCharge:AddChild(Text(FALLBACK_FONT_FULL, 70, i18n('chargeType.' .. descConfig.chargeType)))
    tagLeftOffset = tagLeftOffset + 210

    local tagEmit = self:AddChild(Widget("tagEmit"))
    tagEmit:SetPosition(tagLeftOffset, topOffset, 0)
    local tagEmitBg = tagEmit:AddChild(Image("images/ark_skill.xml", "skill_desc_bg2.tex"))
    local tagEmitText = tagEmit:AddChild(Text(FALLBACK_FONT_FULL, 70, i18n('emitType.' .. descConfig.emitType)))
    tagLeftOffset = tagLeftOffset + 180

    local tagChargeNum = self:AddChild(Widget("tagChargeNum"))
    tagChargeNum:SetPosition(tagLeftOffset, topOffset, 0)
    local tagChargeNumBg = tagChargeNum:AddChild(Image("images/ark_skill.xml", "skill_desc_bg4.tex"))
    local tagChargeNumIcon = tagChargeNum:AddChild(Image("images/ark_skill.xml", "skill_desc_icon_charge.tex"))
    tagChargeNumIcon:SetSize(54, 54)
    tagChargeNumIcon:SetPosition(-40, 0, 0)
    local tagChargeNumText = tagChargeNum:AddChild(Text(FALLBACK_FONT_FULL, 70, tostring(descConfig.charge)))
    tagChargeNumText:SetPosition(20, 0, 0)
    tagLeftOffset = tagLeftOffset + 180

    if descConfig.buffTime then
      local tagBuff = self:AddChild(Widget("tagBuff"))
      tagBuff:SetPosition(tagLeftOffset, topOffset, 0)
      local tagBuffBg = tagBuff:AddChild(Image("images/ark_skill.xml", "skill_desc_bg6.tex"))
      local tagBuffIcon = tagBuff:AddChild(Image("images/ark_skill.xml", "skill_desc_icon_clock.tex"))
      tagBuffIcon:SetSize(46, 46)
      tagBuffIcon:SetPosition(-60, 0, 0)
      local tagBuffText = tagBuff:AddChild(Text(FALLBACK_FONT_FULL, 70, tostring(descConfig.buffTime) .. i18n("second")))
      tagBuffText:SetPosition(30, 0, 0)
    end
  end
  topOffset = topOffset - 100
  if descConfig.desc then
    local descs = string.split(descConfig.desc, '\n')
    for i, desc in ipairs(descs) do
      local descText = self:AddChild(Text(FALLBACK_FONT_FULL, 80, desc))
      local sizeX = descText:GetRegionSize()
      descText:SetPosition(leftOffset + sizeX / 2, topOffset, 0)
      topOffset = topOffset - 60
    end
  end

  -- 脚部
  local foot = self:AddChild(Widget("foot"))
  -- 脚部左边技能等级, 右边热键
  foot:SetPosition(0, -self.size[2] / 2 + 100, 0)
  local levelString = "Lv: " .. descConfig.level
  if descConfig.level > 9 then
    levelString = levelString + " MAX"
  end
  local levelText = foot:AddChild(Text(FALLBACK_FONT_FULL, 80, levelString))
  local levelTextSizeX = levelText:GetRegionSize()
  levelText:SetPosition(leftOffset + levelTextSizeX / 2, 0, 0)
  -- 热键
  -- 热键放到右下角
  if descConfig.emitType == CONSTANTS.EMIT_TYPE.HAND then
    local hotKeyText = foot:AddChild(Text(FALLBACK_FONT_FULL, 80))
    self.hotKeyText = hotKeyText
    hotKeyText:SetPosition(self.size[1] / 2 - 440, 0, 0)
    self:RefreshHotKey()
    local hotKeyButton = foot:AddChild(TextButton("hotkeySetting"))
    hotKeyButton:SetTextSize(80)
    hotKeyButton:SetText("["..i18n("setting").."]")
    hotKeyButton:SetFont(FALLBACK_FONT_FULL)
    self.hotKeyButton = hotKeyButton
    hotKeyButton:SetPosition(self.size[1] / 2 - 240, 0, 0)
    hotKeyButton:SetOnClick(function()
      self:SettingHotKey()
    end)
    local hotKeyResetButton = foot:AddChild(TextButton("hotkeyReset"))
    hotKeyResetButton:SetTextSize(80)
    hotKeyResetButton:SetText("["..i18n("reset").."]")
    hotKeyResetButton:SetFont(FALLBACK_FONT_FULL)
    hotKeyResetButton:SetPosition(self.size[1] / 2 - 110, 0, 0)
    hotKeyResetButton:SetOnClick(function()
      ThePlayer:SaveArkSkillLocalHotKey(self.idx, nil)
      ThePlayer:RefreshArkSkillLocalHotKey()
      local hotKey = ThePlayer:GetArkSkillLocalHotKey(self.idx)
      self.hotKey = hotKey
      self:RefreshHotKey()
    end)
  end
end)

function ArkSkillDesc:RefreshHotKey()
  local hotKeyString = nil
  if self.hotKey ~= nil then
    hotKeyString = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][self.hotKey]
  else
    hotKeyString = i18n('none')
  end
  self.hotKeyText:SetString(i18n("hotKey") .. ": " .. hotKeyString)
end

function ArkSkillDesc:SettingHotKeyCallback(key, conflictIdx)
  if conflictIdx and conflictIdx ~= self.idx then
    self:RefreshHotKey()
    self.hotKeyText:SetString(i18n("tipSettingSkillHotKeyConflict"))
    return
  end
  self.hotKey = key
  ThePlayer:SaveArkSkillLocalHotKey(self.idx, key)
  self:RefreshHotKey()
  self.hotKeyButton:SetText("["..i18n("setting").."]")
  ThePlayer:RefreshArkSkillLocalHotKey()
  ThePlayer.HUD._settingSkillHotKeyCallback = nil
end

function ArkSkillDesc:SettingHotKey()
  if ThePlayer.HUD._settingSkillHotKeyCallback then
    self:RefreshHotKey()
    self.hotKeyButton:SetText("["..i18n("setting").."]")
    ThePlayer.HUD._settingSkillHotKeyCallback = nil
  else
    self.hotKeyText:SetString(i18n("tipSettingSkillHotKey"))
    self.hotKeyButton:SetText("["..i18n("cancel").."]")
    ThePlayer.HUD._settingSkillHotKeyCallback = function(key, conflictIdx)
      self:SettingHotKeyCallback(key, conflictIdx)
    end
  end
end

function ArkSkillDesc:GetSize()
  return Vector3(self.size[1], self.size[2], 0)
end

function ArkSkillDesc:Kill()
  ThePlayer.HUD._settingSkillHotKeyCallback = nil
  -- 调用基类的 Kill 方法
  ArkSkillDesc._base.Kill(self)
end

return ArkSkillDesc
