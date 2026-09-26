local function collectSameNameAndSuitHandIds(room, true_name, suit)
  local ids = {}
  for _, p in ipairs(room.alive_players) do
    for _, id in ipairs(p:getCardIds("h")) do
      local c = Fk:getCardById(id, true)
      if c and c.trueName == true_name and c.suit == suit then
        table.insertIfNeed(ids, id)
      end
    end
  end
  return ids
end

local function collectSameNameAndSuitDrawPileIds(room, true_name, suit)
  local ids = {}
  if room.draw_pile then
    for _, id in ipairs(room.draw_pile) do
      local c = Fk:getCardById(id, true)
      if c and c.trueName == true_name and c.suit == suit then
        table.insertIfNeed(ids, id)
      end
    end
  end
  return ids
end

local qiaole = fk.CreateSkill{
  name = "fms__qiaole",
  tags = { Skill.Compulsory },
  derived_piles = "fms__qiaole_void",
}

Fk:loadTranslationTable{
  ["fms__qiaole"] = "翘了",
  [":fms__qiaole"] = "锁定技，结束阶段，若你未翻面，你亮出牌堆底一张牌并获得之；若此牌为红色，你翻面，然后将全场手牌区、牌堆中与此牌同名且同花色的牌移出游戏。<br>"..
  "[“我这学期不会再翘一节课……(你怎么课上一半回来了)，我就翘了0.5节”]",

  ["#fms__qiaole_void"] = "移出",
}

qiaole:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player.phase == Player.Finish and
      player.faceup
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    if not room.draw_pile or #room.draw_pile == 0 then return end

    -- 亮出牌堆底一张牌，并获得之
    local id = room.draw_pile[#room.draw_pile]
    room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)

    local card = Fk:getCardById(id, true)
    if not card or player.dead then return end

    -- 只有红色时，后续“翻面 + 移出同名且同花色牌”才成立
    if card.color ~= Card.Red then return end

    local true_name = card.trueName
    local suit = card.suit

    -- 先翻面
    player:turnOver()
    if player.dead then return end

    if not true_name or true_name == "" or suit == Card.NoSuit then return end

    -- 收集全场手牌区、牌堆中与亮出牌同名且同花色的牌
    local ids = {}
    table.insertTable(ids, collectSameNameAndSuitHandIds(room, true_name, suit))
    table.insertTable(ids, collectSameNameAndSuitDrawPileIds(room, true_name, suit))

    -- 注意：包括刚刚获得的这张红色牌本身
    if #ids > 0 and player:hasSkill(self.name, true) then
      player:addToPile("fms__qiaole_void", ids, true, self.name, player)
    end
  end,
})

return qiaole
