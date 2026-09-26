local leile_give = fk.CreateSkill{
  name = "#fms__leile_give",
}

Fk:loadTranslationTable{
  ["#fms__leile-choose"] = "累了：你可以令一名其他角色获得“累了”",
}

leile_give:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:hasSkill("fms__leile", true)
    end)
    if #targets == 0 then
      return false
    end

    local tos = room:askToChoosePlayers(
      player,
      {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = "fms__leile",
        prompt = "#fms__leile-choose",
        cancelable = true,
      }
    )

    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if not to or not to:isAlive() then return end

    room:doIndicate(player, { to })
    room:handleAddLoseSkills(to, "fms__leile|#fms__leile_give")
  end,
})

return leile_give
