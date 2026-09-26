local skill = fk.CreateSkill{
  name = "#fms__diamond_armor_skill",
  attached_equip = "fms__diamond_armor",
}

Fk:loadTranslationTable{
  ["#fms__diamond_armor_skill"] = "钻石甲",
  ["#fms__diamond_armor-destroy"] = "钻石甲：离开装备区时，你可以令其销毁",
}

skill:addEffect(fk.BeforeCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player and move.toArea ~= Card.Void then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and card.name == "fms__diamond_armor" and info.fromArea == Card.PlayerEquip then
            if room:askToSkillInvoke(player, {
              skill_name = self.name,
              prompt = "#fms__diamond_armor-destroy",
            }) then
              room:setCardMark(card, MarkEnum.DestructOutEquip, 1)
            end
          end
        end
      end
    end
  end,
})

return skill
