local sl__renzhi = fk.CreateSkill{
  name = "sl__renzhi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sl__renzhi"] = "人质",
  [":sl__renzhi"] = "锁定技。你没有装备区和判定区；你始终翻面；你获得的牌归福禄娃所有。",
  ["$sl__renzhi1"] = "我来做人质！",
  ["$sl__renzhi2"] = "兄弟们，冲啊！",
}

-- 废除装备区和判定区
sl__renzhi:addEffect(fk.GameStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local slots = player:getAvailableEquipSlots()
    if not table.contains(player.sealedSlots, Player.JudgeSlot) then
      table.insert(slots, Player.JudgeSlot)
    end
    room:abortPlayerArea(player, slots)
  end,
})

-- 始终翻面
sl__renzhi:addEffect(fk.GameStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player.faceup
  end,
  on_use = function(self, event, target, player, data)
    player:turnOver()
  end,
})

sl__renzhi:addEffect(fk.EventAcquireSkill, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.skill.name == self.name and player.faceup
  end,
  on_use = function(self, event, target, player, data)
    player:turnOver()
  end,
})

sl__renzhi:addEffect(fk.BeforeTurnOver, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not player.faceup
  end,
  on_use = function(self, event, target, player, data)
    data.prevented = true
  end,
})

-- 你获得的牌归当前福禄娃所有
sl__renzhi:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end

    local current_id = player:getMark("sl__fuluwa_current")
    if not current_id or current_id == 0 then return false end

    local brother = player.room:getPlayerById(current_id)
    if not brother or brother.dead then return false end

    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerHand then
        return true
      end
    end
    return false
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local current_id = player:getMark("sl__fuluwa_current")
    local brother = room:getPlayerById(current_id)
    if not brother or brother.dead then return end

    local cards = {}
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(cards, info.cardId)
        end
      end
    end

    if #cards > 0 then
      room:obtainCard(brother, cards, false, fk.ReasonGive, brother, self.name)
    end
  end,
})

return sl__renzhi
