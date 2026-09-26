local jinheshen = fk.CreateSkill{
  name = "sl__jinheshen",
}

Fk:loadTranslationTable{
  ["sl__jinheshen"] = "金河神",
  [":sl__jinheshen"] = "你的体力上限不小于6时：当你于回合外不因〖金河神〗获得手牌后，你可以摸一张牌。",
}

jinheshen:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if player.maxHp < 6 then return false end
    if player.room.current == player then return false end
    if not data then return false end

    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerHand and move.skillName ~= self.name then
        return true
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = self.name })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return jinheshen
