local budui = fk.CreateSkill{
  name = "fms__budui",
}

Fk:loadTranslationTable{
  ["fms__budui"] = "不对",
  [":fms__budui"] = "出牌阶段限一次，你可以选择获得一张本回合进入弃牌堆的牌。<br>"..
  "[“不对，刚刚打错了”]",
  ["#fms__budui"] = "不对：你可以获得一张本回合进入弃牌堆的牌",
}

budui:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#fms__budui",
  card_num = 0,
  target_num = 0,

  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,

  card_filter = Util.FalseFunc,

  on_use = function(self, room, effect)
    local player = effect.from
    local all_cards = {}

    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(all_cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)

    if #all_cards == 0 then return end

    local cards = room:askToChooseCards(player, {
      target = player,
      min = 1,
      max = 1,
      flag = { card_data = { { "pile_discard", all_cards } } },
      skill_name = self.name,
      prompt = "#fms__budui",
    })

    if #cards > 0 then
      -- 成长统计：从自己上个回合开始到现在，这一轮内只要用过“不对”就记上
      room:setPlayerMark(player, "fms__growth_used-round", 1)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player)
    end
  end,
})

return budui
