GLOBAL.setmetatable(env, {
  __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end
})

Assets = {Asset("ATLAS", "images/ark_skill.xml")}

TUNING.ARK_DEV_CONFIG = {
  language = 'zh'
}
local lang = GetModConfigData('language')
if lang ~= 'auto' then
    TUNING.ARK_ITEM_CONFIG.language = lang
end

AddModRPCHandler("arkSkill", "RequestSyncSkillStatus", function(player, idx)
  if player and player.components.ark_skill then
    player.components.ark_skill:RequestSyncSkillStatus(idx)
  end
end)

local function OnRpcSyncSkillStatus(skillIndex, ...)
  if not ThePlayer then
    return
  end
  local arkSkillUi = ThePlayer.HUD.controls.arkSkillUi
  if not arkSkillUi then
    return
  end
  OnRpcSyncSkillStatus = function(skillIndex, ...)
    local skillUi = arkSkillUi:GetSkill(skillIndex)
    skillUi:SyncSkillStatus(...)
  end
  OnRpcSyncSkillStatus(skillIndex, ...)
end

AddClientModRPCHandler("arkSkill", "SyncSkillStatus", OnRpcSyncSkillStatus)

AddModRPCHandler("arkSkill", "HandEmitSkill", function(player, skillIndex)
  if player and player.components.ark_skill then
    player.components.ark_skill:HandEmitSkill(skillIndex)
  end
end)

local function findSkillHotKeyIndex(hotKey, skillConfigs)
  for i, config in pairs(skillConfigs) do
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
  controls.arkSkillUi:SetPosition(config.position or Vector3(-840, 80, 0))
  controls.arkSkillUi:SetScale(.5, .5, .5)
  -- 记下原本的热键
  local originalHotKey = {}
  for i, skillConfig in pairs(config.skills) do
    originalHotKey[i] = skillConfig.hotKey
  end
  local localHotKey = nil
  function ThePlayer:SaveArkSkillLocalHotKey(idx, hotKey)
    localHotKey = localHotKey or {}
    if hotKey == nil then
      table.remove(localHotKey, idx)
    else
      localHotKey[idx] = hotKey
    end
    TheSim:SetPersistentString("ark_skill_local_hot_key" ..ThePlayer.userid .. ThePlayer.prefab, json.encode(localHotKey), false)
  end

  function ThePlayer:GetArkSkillLocalHotKey(idx)
    return config.skills[idx].hotKey
  end

  function ThePlayer:LoadArkSkillLocalHotKey()
    TheSim:GetPersistentString("ark_skill_local_hot_key" ..ThePlayer.userid .. ThePlayer.prefab, function(load_success, str)
      if not load_success then
        localHotKey = {}
        return
      end
      local ok, data = pcall(function() return json.decode(str) end)
      if not ok then
        localHotKey = {}
        return
      end
      localHotKey = data
    end)
  end
  function ThePlayer:RefreshArkSkillLocalHotKey()
    -- 先恢复原本的热键
    for i, hotKey in pairs(originalHotKey) do
      config.skills[i].hotKey = hotKey
    end
    if not localHotKey then
      return
    end
    for i, hotKey in pairs(localHotKey) do
      config.skills[i].hotKey = hotKey
    end
  end
  ThePlayer:LoadArkSkillLocalHotKey()
  ThePlayer:RefreshArkSkillLocalHotKey()
  -- 安装热键
  local _OnRawKey = ThePlayer.HUD.OnRawKey
  function ThePlayer.HUD:OnRawKey(key, down)
    if not down then
      return _OnRawKey(self, key, down)
    end
    if ThePlayer.HUD._settingSkillHotKeyCallback then
      -- 检查是否有冲突
      local conflictIndex = findSkillHotKeyIndex(key, config.skills)
      ThePlayer.HUD._settingSkillHotKeyCallback(key, conflictIndex)
      return true
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

