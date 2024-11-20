local SKILL_STATUS = {
  LOCKED = 1,
  CHARGING = 2,
  BUFFING = 3,
  BULLETING = 4,
}

return {
  SKILL_STATUS = SKILL_STATUS,
  CHARGE_TYPE = {
    NONE = "none",
    AUTO = "auto",
    ATTACK = "attack",
    UNDER_ATTACK = "under_attack",
  },
  EMIT_TYPE = {
    PASSIVE = "passive",
    HAND = "hand",
    AUTO = "auto",
    ATTACK = "attack",
    UNDER_ATTACK = "under_attack",
  },
}