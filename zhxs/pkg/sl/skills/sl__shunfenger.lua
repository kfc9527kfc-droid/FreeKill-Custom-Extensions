local sl__shunfenger = fk.CreateSkill {
  name = "sl__shunfenger",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sl__shunfenger"] = "顺风耳",
  [":sl__shunfenger"] = "所有人的手牌对你可见。",
}

sl__shunfenger:addEffect("visibility", {
  card_visible = function(self, player, card)
    if player:hasSkill(sl__shunfenger.name) and Fk:currentRoom():getCardArea(card) == Card.PlayerHand then
      return true
    end
  end
})

return sl__shunfenger
