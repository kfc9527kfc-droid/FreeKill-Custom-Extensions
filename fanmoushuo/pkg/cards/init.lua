local extension = Package:new("fanmoushuo_cards", Package.CardPack)
extension.extensionName = "fanmoushuo"

require "packages.fanmoushuo.pkg.cards.skills.fms__egg_tart_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__original_chicken_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__burger_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__popcorn_chicken_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__colonel_nuggets_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__cola_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__coffee_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__mashed_potato_skill"

require "packages.fanmoushuo.pkg.cards.skills.fms__diamond_sword_skill"
require "packages.fanmoushuo.pkg.cards.skills.fms__diamond_armor_skill"

local fms__egg_tart = fk.CreateCard{
  name = "fms__egg_tart",
  type = Card.TypeBasic,
  skill = "fms__egg_tart_skill",
}

local fms__original_chicken = fk.CreateCard{
  name = "fms__original_chicken",
  type = Card.TypeBasic,
  skill = "fms__original_chicken_skill",
}

local fms__burger = fk.CreateCard{
  name = "fms__burger",
  type = Card.TypeBasic,
  skill = "fms__burger_skill",
}

local fms__popcorn_chicken = fk.CreateCard{
  name = "fms__popcorn_chicken",
  type = Card.TypeBasic,
  skill = "fms__popcorn_chicken_skill",
}

local fms__colonel_nuggets = fk.CreateCard{
  name = "fms__colonel_nuggets",
  type = Card.TypeBasic,
  skill = "fms__colonel_nuggets_skill",
}

local fms__cola = fk.CreateCard{
  name = "fms__cola",
  type = Card.TypeBasic,
  skill = "fms__cola_skill",
}

local fms__coffee = fk.CreateCard{
  name = "fms__coffee",
  type = Card.TypeBasic,
  skill = "fms__coffee_skill",
}

local fms__mashed_potato = fk.CreateCard{
  name = "fms__mashed_potato",
  type = Card.TypeBasic,
  skill = "fms__mashed_potato_skill",
}

local fms__diamond_sword = fk.CreateWeapon{
  name = "fms__diamond_sword",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 1,
  equip_skill = "#fms__diamond_sword_skill",
}

local fms__diamond_armor = fk.CreateArmor{
  name = "fms__diamond_armor",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
  equip_skill = "#fms__diamond_armor_skill",
}

extension:loadCardSkels{
  fms__egg_tart,
  fms__original_chicken,
  fms__burger,
  fms__popcorn_chicken,
  fms__colonel_nuggets,
  fms__cola,
  fms__coffee,
  fms__mashed_potato,
  fms__diamond_sword,
  fms__diamond_armor,
}

extension:addCardSpec("fms__egg_tart", Card.Heart, 3)
extension:addCardSpec("fms__egg_tart", Card.Diamond, 9)

extension:addCardSpec("fms__original_chicken", Card.Club, 4)
extension:addCardSpec("fms__original_chicken", Card.Spade, 10)

extension:addCardSpec("fms__burger", Card.Heart, 5)
extension:addCardSpec("fms__burger", Card.Diamond, 11)

extension:addCardSpec("fms__popcorn_chicken", Card.Club, 6)
extension:addCardSpec("fms__popcorn_chicken", Card.Spade, 12)

extension:addCardSpec("fms__colonel_nuggets", Card.Heart, 7)
extension:addCardSpec("fms__colonel_nuggets", Card.Diamond, 13)

extension:addCardSpec("fms__cola", Card.Club, 2)
extension:addCardSpec("fms__cola", Card.Spade, 8)

extension:addCardSpec("fms__coffee", Card.Heart, 1)
extension:addCardSpec("fms__coffee", Card.Diamond, 6)

extension:addCardSpec("fms__mashed_potato", Card.Club, 5)
extension:addCardSpec("fms__mashed_potato", Card.Spade, 9)

extension:addCardSpec("fms__diamond_sword", Card.Diamond, 6)
extension:addCardSpec("fms__diamond_armor", Card.Diamond, 6)

Fk:loadTranslationTable{
  ["fanmoushuo_cards"] = "凡某说卡牌",

  ["fms__egg_tart"] = "蛋挞",
  [":fms__egg_tart"] = "基本牌。你使用此牌时，先摸两张牌，再按【桃】结算。",

  ["fms__original_chicken"] = "原味鸡",
  [":fms__original_chicken"] = "基本牌。你使用此牌时，先令手牌上限永久+1，再按【桃】结算。",

  ["fms__burger"] = "汉堡",
  [":fms__burger"] = "基本牌。你使用此牌时，先令体力上限永久+1，再按【桃】结算。",

  ["fms__popcorn_chicken"] = "鸡米花",
  [":fms__popcorn_chicken"] = "基本牌。你使用此牌时，先重置一个技能，再按【桃】结算。",

  ["fms__colonel_nuggets"] = "上校鸡块",
  [":fms__colonel_nuggets"] = "基本牌。你使用此牌时，先获得1点护甲，再按【桃】结算。",

  ["fms__cola"] = "可乐",
  [":fms__cola"] = "基本牌。你使用此牌时，先复原武将牌，再按【酒】结算。",

  ["fms__coffee"] = "咖啡",
  [":fms__coffee"] = "基本牌。你使用此牌时，先令你跳过本回合弃牌阶段，再按【酒】结算。",

  ["fms__mashed_potato"] = "土豆泥",
  [":fms__mashed_potato"] = "基本牌。你使用此牌时，先令你下一张【杀】造成伤害后回复1点体力，再按【酒】结算。",

  ["fms__diamond_sword"] = "钻石剑",
  [":fms__diamond_sword"] = "装备牌·武器<br /><b>攻击范围</b>：1<br /><b>武器技能</b>：此牌可保留至多3个附魔；离开装备区时，你可以令其销毁。",

  ["fms__diamond_armor"] = "钻石甲",
  [":fms__diamond_armor"] = "装备牌·防具<br /><b>防具技能</b>：此牌可保留至多3个附魔；离开装备区时，你可以令其销毁。",
}

return extension
