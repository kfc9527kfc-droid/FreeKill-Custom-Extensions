local rule = fk.CreateSkill {
  name = "#alliance_vs_landlord_rule&",
}

rule:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, target, player, data)
    return player.seat == 1
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mode = Fk.game_modes[room:getSettings('gameMode')]
    ---@diagnostic disable-next-line
    mode.addRebelMark(room, 1)
  end,
})

return rule
