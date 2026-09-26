local rule = fk.CreateSkill {
  name = "#infernal_affairs_rule&",
}

rule:addEffect("visibility", {
  role_visible = function(self, player, target)
    if player.role == "loong_lord" and target:getMark("@!tiger_team-noclear") ~= 0 then
      return true
    end
    if player.role == "tiger_lord" and target:getMark("@!loong_team-noclear") ~= 0 then
      return true
    end

    if Fk:currentRoom():getBanner("infernal_affairs_6_players") then
      if player:getNextAlive(true, 1, true) ~= target then return nil end
      if target:getMark("@!loong_team-noclear") ~= player:getMark("@!loong_team-noclear") then
        return true
      end
    end
  end,
})

rule:addEffect(fk.Death, {
  can_refresh = function (self, event, target, player, data)
    return target == player and target.role:endsWith("_lord")
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local prefix = target.role:split("_")[1]
    local renegade = table.find(room.players, function(p)
      return p.role == prefix .. "_renegade"
    end)
    if not renegade then return end
    room:setPlayerProperty(renegade, "role_shown", true)
  end,
})


return rule

