local fms__growth = fk.CreateSkill{
  name = "fms__growth",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["fms__growth"] = "成长",
  [":fms__growth"] = "觉醒技，回合开始时，若第三轮已结束，你可以将武将牌替换为隐藏武将“戴承旭·成长”，然后将体力上限调整至3，并将体力回复至3。",

  ["$fms__growth1"] = "成长，总是在沉默里发生。",
  ["$fms__growth2"] = "这一次，我会走向新的自己。",
}

fms__growth:addEffect(fk.TurnStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    local round_count = room:getBanner("RoundCount") or 1

    return
      target == player and
      player:hasSkill(self.name) and
      player:getMark(self.name) == 0 and
      player:getMark("fms__growth_used-round") == 0 and
      round_count >= 4
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:setPlayerMark(player, self.name, 1)

    room:changeHero(player, "fms__daichengxu_awaken", false, false, true, false)

    if player.maxHp ~= 3 then
      room:changeMaxHp(player, 3 - player.maxHp)
    end

    if player.dead then
      return
    end

    if player.hp < 3 then
      room:recover{
        who = player,
        num = 3 - player.hp,
        recoverBy = player,
        skillName = self.name,
      }
    elseif player.hp > 3 then
      room:loseHp(player, player.hp - 3, self.name)
    end

    room:setPlayerMark(player, "fms__growth_used-round", 0)
  end,
})

-- 自己回合开始后，若尚未觉醒，则开始新一轮统计
fms__growth:addEffect(fk.EventPhaseStart, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return
      target == player and
      player.phase == Player.Start and
      player:hasSkill("fms__growth", true) and
      player:getMark("fms__growth") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fms__growth_used-round", 0)
  end,
})

return fms__growth
