local heshen = fk.CreateSkill{
  name = "sl__heshen",
}

Fk:loadTranslationTable{
  ["sl__heshen"] = "河神",
  [":sl__heshen"] = "一名角色的弃牌阶段结束后，你可以秘密获得其中一张牌，然后其可以观看你的手牌并获得其中一张。若其获得的牌为你以此法获得的牌，你与其各摸两张牌；否则，你加1点体力上限。",
  ["#sl__heshen-invoke"] = "河神：你可以秘密获得 %dest 于此弃牌阶段进入弃牌堆的一张牌",
  ["#sl__heshen-give"] = "河神：观看 %src 的手牌并获得其中一张",
}

-- 第一段：在弃牌阶段进行中，实时记录进入弃牌堆的牌
heshen:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    local room = player.room
    local current = room.current
    return current and current.phase == Player.Discard and data
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local current = room.current
    if not current or current.phase ~= Player.Discard then return end

    local ids = current:getTableMark("sl__heshen_discards-phase")

    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(room.discard_pile, info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end

    room:setPlayerMark(current, "sl__heshen_discards-phase", ids)
  end,
})

-- 第二段：弃牌阶段结束后，从记录表里秘密获得其中一张
heshen:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target
      and target ~= player
      and target.phase == Player.Discard
      and player:hasSkill(self.name)
      and not player.dead
      and #target:getTableMark("sl__heshen_discards-phase") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#sl__heshen-invoke::"..target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local ids = table.filter(target:getTableMark("sl__heshen_discards-phase"), function(id)
      return table.contains(room.discard_pile, id)
    end)

    if #ids == 0 then return end

    local chosen = room:askToChooseCards(player, {
      target = player,
      min = 1,
      max = 1,
      flag = { card_data = { { "pile_discard", ids } } },
      skill_name = self.name,
      prompt = "#sl__heshen-invoke::"..target.id,
    })[1]

    if not chosen then return end
    if not table.contains(room.discard_pile, chosen) then return end

    room:moveCardTo(chosen, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player)

    if player.dead or target.dead or player:isKongcheng() then
      return
    end

    local secret_id = chosen

    local get_id = room:askToChooseCards(target, {
      target = player,
      min = 1,
      max = 1,
      flag = { card_data = { { player.general, player:getCardIds("h") } } },
      skill_name = self.name,
      prompt = "#sl__heshen-give:"..player.id,
    })[1]

    if not get_id then return end

    room:moveCardTo(get_id, Card.PlayerHand, target, fk.ReasonPrey, self.name, nil, true, target)

    if get_id == secret_id then
      if not player.dead then
        player:drawCards(2, self.name)
      end
      if not target.dead then
        target:drawCards(2, self.name)
      end
    else
      if not player.dead then
        room:changeMaxHp(player, 1)
      end
    end
  end,
})

-- 第三段：弃牌阶段结束后清空记录
heshen:addEffect(fk.EventPhaseEnd, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target and target.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    target.room:setPlayerMark(target, "sl__heshen_discards-phase", 0)
  end,
})

return heshen
