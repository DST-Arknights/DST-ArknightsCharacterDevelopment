name = ChooseTranslationTable({
  en = "Arknights Character Development",
  zh = "明日方舟 养成包"
})
description = ChooseTranslationTable({
  en = [[Character development package for Arknights.]],
  zh = [[角色养成]]
})
author = "望月心灵"
version = "0.0.1"
forumthread = "https://github.com/TohsakaKuro/DST-ArknightsCharacterDevelopment/issues"

api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = false

dst_compatible = true
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"arknights", "明日方舟", "item", "物品", "养成"}
configuration_options = {{
  name = "language",
  label = ChooseTranslationTable({
      en = "Choose Language",
      zh = "选择语言"
  }),
  hover = ChooseTranslationTable({
      en = "Choose the language of the mod",
      zh = "选择mod的语言"
  }),
  options = {{
      description = ChooseTranslationTable({
          en = "Chinese",
          zh = "中文"
      }),
      data = "zh"
  }, {
      description = ChooseTranslationTable({
          en = "Auto",
          zh = "自动"
      }),
      data = "auto"
  }},
  default = "auto"
}}