local common = require("ark_dev_common")
local CONSTANTS = require("ark_dev_constants")

local function makeArkSkillLevelUp(idx, level)
  local prefabName = common.genArkSkillLevelUpPrefabName(idx, level)
  local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag('ark_skill_level_up')
    if not TheWorld.ismastersim then
      return inst
    end
    inst:AddComponent('inventoryitem')
    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
      if owner and owner.components.ark_skill then
        owner.components.ark_skill:LevelUpSkill(idx)
      end
      inst:Remove()
    end)
    return inst
  end
  return Prefab(prefabName, fn, {}, {})
end

local prefabs = {}
for i = 1, CONSTANTS.MAX_SKILL_LIMIT do
  for j = 1, CONSTANTS.MAX_SKILL_LEVEL do
    if j ~= 1 then
      table.insert(prefabs, makeArkSkillLevelUp(i, j))
    end
  end
end
return unpack(prefabs)