local rule = fk.CreateSkill {
  name = "#arrow_of_tactics_rule&",
}

rule:addEffect(fk.Death, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local killer = data.killer
    local prefix
    if target.role:endsWith("_rebel") then
      prefix = target.role:split("_")[1]
    elseif target.role:endsWith("_renegade") and killer then
      if not killer:isFriend(target) then
        prefix = killer.role:split("_")[1]
      end
    end

    if not prefix then return end
    local lord = table.find(room.players, function(p)
      return p.role == prefix .. "_lord"
    end)
    if not lord then return end
    room:setPlayerProperty(lord, "role_shown", true)
  end,
})

return rule
