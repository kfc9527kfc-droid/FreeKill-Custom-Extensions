local skill = fk.CreateSkill{
  name = "#fms__diamond_sword_skill",
  attached_equip = "fms__diamond_sword",
}

Fk:loadTranslationTable{
  ["#fms__diamond_sword_skill"] = "钻石剑",
  ["#fms__diamond_sword-destroy"] = "钻石剑：离开装备区时，你可以令其销毁",
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
          if card and card.name == "fms__diamond_sword" and info.fromArea == Card.PlayerEquip then
            if room:askToSkillInvoke(player, {
              skill_name = self.name,
              prompt = "#fms__diamond_sword-destroy",
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
