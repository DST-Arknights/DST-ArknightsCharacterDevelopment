local utils = require "ark_utils"

local i18n = {
  ['zh'] = {
    emitType = {
      passive = '被动',
      hand = '手动触发',
      auto = '自动触发',
      attack = '攻击触发',
      under_attack = '受击触发',
    },
    chargeType = {
      none = '无',
      auto = '自动回复',
      attack = '攻击回复',
      under_attack = '受击回复',
    },
    second = '秒',
    hotKey = '快捷键',
    setting = '设置',
    none = '无',
    locked = '未解锁',
    tipSettingSkillHotKey = '请按下任意键',
    cancel = '取消',
    reset = '重置',
    tipSettingSkillHotKeyConflict = '冲突的按键',
  }
}

local function get(path)
  local lang = TUNING.ARK_DEV_CONFIG.language
  local data = utils.get(i18n, lang .. '.' .. path)
  return data
end

return get