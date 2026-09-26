local sl__dali = fk.CreateSkill {
  name = "sl__dali",
}

Fk:loadTranslationTable {
  ["sl__dali"] = "大力",
  [":sl__dali"] = "体力上限可以作为【杀】或无次数限制的【酒】使用。",
  ["#sl__dali"] = "大力：请选择要作为的牌名",
  ["$sl__dali1"] = "力拔山兮！",
  ["$sl__dali2"] = "大娃在此，谁敢造次？",
}

sl__dali:addEffect("viewas", {
  prompt = "#sl__dali",
  pattern = "slash,analeptic",
  interaction = function(self, player)
    local names = {}
    for name, _ in pairs(Fk.all_card_types) do
      local card = Fk:cloneCard(name)
      if not card.is_derived and not table.contains(Fk:currentRoom().disabled_packs, card.package.name)
        and (card.name == "analeptic" or card.name == "slash")  -- 仅限普通杀 + 酒
        and ((Fk.currentResponsePattern == nil) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        table.insertIfNeed(names, name)
      end
    end
    if #names == 0 then return end
    return UI.ComboBox { choices = names }
  end,
  card_filter = function(self, player, to_select, selected)
    return false  -- 无需选择任何实体牌（体力上限直接虚拟转化）
  end,
  view_as = function(self, player, cards)
    if #cards ~= 0 or not self.interaction.data then return end
    local card_name = self.interaction.data
    local card = Fk:cloneCard(card_name)
    card.skillName = sl__dali.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local card_name = use.card.name

    -- 仅酒获得无次数限制
    if card_name == "analeptic" then
      use.extraUse = true
    end

    -- 体力上限转化：每次使用消耗1点体力上限（参考吸水）
    room:changeMaxHp(player, -1)
  end,
})

sl__dali:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    -- 仅酒绕过次数限制，普通杀正常受次数/距离/防具限制
    return card and table.contains(card.skillNames, sl__dali.name) and card.name == "analeptic"
  end,
})

return sl__dali
