local ruguo = fk.CreateSkill{
  name = "fms__ruguo",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["fms__ruguo"] = "如果",
  [":fms__ruguo"] = "觉醒技，准备阶段，若全场所有角色均有“shit”标记，你获得“如日”，然后体力上限减3。<br>"..
  "[“如果没如果~”]",
}

ruguo:addEffect(fk.EventPhaseStart, {
  anim_type = "wake",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player.phase == Player.Start and
      player:getMark("fms__ruguo_wake") == 0 and
      table.every(player.room.alive_players, function(p)
        return p:getMark("@fms__shit") > 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "fms__ruguo_wake", 1)
    room:handleAddLoseSkills(player, "fms__ruri")
    room:changeMaxHp(player, -3)
  end,
})

return ruguo
