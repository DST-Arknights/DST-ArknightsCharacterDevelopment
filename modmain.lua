GLOBAL.setmetatable(env, {
  __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end
})
local common = require "ark_dev_common"

Assets = {Asset("ATLAS", "images/ark_skill.xml")}

AddModRPCHandler("arkSkill", "RequestSyncAllSkillStatus", function(player)
  if player and player.components.ark_skill then
    player.components.ark_skill:RequestSyncAllSkillStatus()
  end
end)

AddClientModRPCHandler("arkSkill", "SyncSkillStatus", function(skillIndex, ...)
  local arkSkillUi = ThePlayer.HUD.controls.arkSkillUi
  if not arkSkillUi then
    return
  end
  local skillUi = arkSkillUi:GetSkill(skillIndex)
  skillUi:SyncSkillStatus(...)
end)

AddModRPCHandler("arkSkill", "HandEmitSkill", function(player, skillIndex)
  if player and player.components.ark_skill then
    player.components.ark_skill:HandEmitSkill(skillIndex)
  end
end)

AddClassPostConstruct('widgets/controls', function(self, owner)
  local config = common.getPlayerArkSkillConfigTuning(owner)
  if not config then
    return
  end
  if not self.inv or not self.inv.hand_inv then
    return
  end
  local ArkSkillUi = require "widgets/ark_skill_ui"
  self.arkSkillUi = self.inv.hand_inv:AddChild(ArkSkillUi(owner, config))
  self.arkSkillUi:SetPosition(config.position or Vector3(-800, 80, 0))
  self.arkSkillUi:SetScale(.4, .4, .4)
  return
end)

local function findSkillHotKeyIndex(hotKey, skillConfigs)
  for i, config in ipairs(skillConfigs) do
    if config.hotKey == hotKey then
      return i
    end
  end
end

AddClassPostConstruct("screens/playerhud", function(self)
  local _OnRawKey = self.OnRawKey
  function self:OnRawKey(key, down)
    local config = common.getPlayerArkSkillConfigTuning(self.owner)
    if not config then
      self.OnRawKey = _OnRawKey
      return _OnRawKey(self, key, down)
    end
    if not down then
      return _OnRawKey(self, key, down)
    end
    local skillIndex = findSkillHotKeyIndex(key, config.skills)
    if not skillIndex then
      return _OnRawKey(self, key, down)
    end
    SendModRPCToServer(GetModRPC("arkSkill", "HandEmitSkill"), skillIndex,
      TheInput:IsKeyDown(KEY_CTRL) or TheInput:IsKeyDown(KEY_RCTRL)
    )
    return true
  end
end)

