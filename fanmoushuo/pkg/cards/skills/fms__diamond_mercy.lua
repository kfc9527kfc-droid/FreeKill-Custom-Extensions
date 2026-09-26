Fk:loadTranslationTable{
  ["#fms__diamond_mercy"] = "怜悯：你可以将所有手牌当【桃】使用",
}

local skill = fk.CreateSkill{
  name = "fms__diamond_mercy",
}

skill:addEffect("viewas", {
  pattern = "peach",
  prompt = "#fms__diamond_mercy",
  mute_card = false,
  card_filter = function(self, player, to_select, selected)
    if not player then
      return false
    end
    return table.contains(player:getCardIds("h"), to_select)
  end,
  view_as = function(self, player, cards)
    if not player or not player:hasSkill(self.name) then
      return nil
    end

    local hands = player:getCardIds("h")
    if #hands == 0 or #cards ~= #hands then
      return nil
    end

    for _, id in ipairs(hands) do
      if not table.contains(cards, id) then
        return nil
      end
    end

    local peach = Fk:cloneCard("peach")
    peach:addSubcards(cards)
    peach.skillName = self.name
    return peach
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, response)
    if not player or response ~= "peach" then
      return false
    end
    if not player:hasSkill(self.name) or player:isKongcheng() then
      return false
    end
    local room = player.room
    return room and room.current ~= player
  end,
})

return skill
