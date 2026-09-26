local sl__baohulu = fk.CreateSkill{
  name = "sl__baohulu",
}

Fk:loadTranslationTable{
  ["sl__baohulu"] = "宝葫芦",
  [":sl__baohulu"] = "出牌阶段限一次，你获得每名其他角色区域内各一张牌、牌堆顶一张牌、弃牌堆一张牌。",
  ["$sl__baohulu1"] = "宝葫芦，收！",
  ["$sl__baohulu2"] = "神器在手，天下我有！",
}

sl__baohulu:addEffect("active", {
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  card_filter = function()
    return false
  end,
  on_use = function(self, room, effect)
    local player = effect.from

    -- 每名其他角色区域内各一张牌
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and not p:isAllNude() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "hej",
          skill_name = self.name,
        })
        if id then
          room:obtainCard(player, id, false, fk.ReasonPrey, player, self.name)
        end
        if player.dead then
          return
        end
      end
    end

    -- 牌堆顶一张牌
    if #room.draw_pile > 0 then
      local top = room.draw_pile[1]
      room:moveCardTo(top, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player)
    end

    -- 弃牌堆一张牌
    if #room.discard_pile > 0 then
      local ids = room:askToChooseCards(player, {
        target = player,
        min = 1,
        max = 1,
        flag = { card_data = { { "pile_discard", room.discard_pile } } },
        skill_name = self.name,
        prompt = "宝葫芦：从弃牌堆选择一张牌",
      })
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player)
      end
    end
  end,
})

return sl__baohulu
