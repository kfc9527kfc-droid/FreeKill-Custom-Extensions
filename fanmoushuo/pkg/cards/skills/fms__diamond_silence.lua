Fk:loadTranslationTable{
  ["@@fms__diamond_silenced-turn"] = "沉默",
}

local skill = fk.CreateSkill{
  name = "fms__diamond_silence",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and data.to and not data.to.dead and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@@fms__diamond_silenced-turn", 1)
  end,
})

skill:addEffect("invalidity", {
  invalidity_func = function(self, from, s)
    return from:getMark("@@fms__diamond_silenced-turn") > 0 and s:isPlayerSkill(from, true)
  end,
})

skill:addEffect(fk.TurnEnd, {
  global = true,
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@@fms__diamond_silenced-turn") > 0 then
        room:setPlayerMark(p, "@@fms__diamond_silenced-turn", 0)
      end
    end
  end,
})

return skill
