GLOBAL.setmetatable(env, {
  __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end
})

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

local function findSkillHotKeyIndex(hotKey, skillConfigs)
  for i, config in ipairs(skillConfigs) do
    if config.hotKey == hotKey then
      return i
    end
  end
end

AddClientModRPCHandler("arkSkill", "SetupArkSkillUi", function(config)
  if not config or not ThePlayer.HUD or ThePlayer.HUD.controls.arkSkillUi then
    return
  end
  local config = json.decode(config)
  local controls = ThePlayer.HUD.controls
  local ArkSkillUi = require "widgets/ark_skill_ui"
  controls.arkSkillUi = controls.inv.hand_inv:AddChild(ArkSkillUi(ThePlayer, config))
  controls.arkSkillUi:SetPosition(config.position or Vector3(-800, 80, 0))
  controls.arkSkillUi:SetScale(.4, .4, .4)
  -- TODO: 加载本地热键设置
  -- 安装热键
  local _OnRawKey = ThePlayer.HUD.OnRawKey
  function ThePlayer.HUD:OnRawKey(key, down)
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

