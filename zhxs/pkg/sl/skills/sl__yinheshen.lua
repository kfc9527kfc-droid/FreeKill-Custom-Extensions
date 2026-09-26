local yinheshen = fk.CreateSkill{
  name = "sl__yinheshen",
}

Fk:loadTranslationTable{
  ["sl__yinheshen"] = "银河神",
  [":sl__yinheshen"] = "你的体力不大于1时：当一张牌进入弃牌堆后，你可以弃置一张手牌并获得之。",
  ["#sl__yinheshen"] = "银河神：你可以弃置一张手牌并获得一张进入弃牌堆的牌",
}

yinheshen:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if player.hp > 1 then return false end
    if player:isKongcheng() then return false end
    if not data then return false end

    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player.room.discard_pile, info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end

    if #ids == 0 then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = {}

    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(room.discard_pile, info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end

    if #ids == 0 then return false end

    local choice = room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#sl__yinheshen",
    })
    if not choice then return false end

    event:setCostData(self, { ids = ids })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = event:getCostData(self).ids
    if not ids or #ids == 0 then return end
    if player:isKongcheng() then return end

    local discard = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = self.name,
      cancelable = false,
    })
    if #discard == 0 then return end

    local get_id = room:askToChooseCards(player, {
      target = player,
      min = 1,
      max = 1,
      flag = { card_data = { { "pile_discard", ids } } },
      skill_name = self.name,
      prompt = "#sl__yinheshen",
    })[1]

    if get_id and table.contains(room.discard_pile, get_id) then
      room:moveCardTo(get_id, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player)
    end
  end,
})

return yinheshen
