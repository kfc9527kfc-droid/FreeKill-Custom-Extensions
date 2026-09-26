local yanyi_control = fk.CreateSkill{
  name = "#fms__yanyi_control",
}

Fk:loadTranslationTable{
  ["#fms__yanyi_control"] = "演绎控制",
}

-- 额外回合结束后，解除控制并令其死亡
yanyi_control:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:getMark("fms__yanyi_die_after_extra") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local controller_id = player:getMark("fms__yanyi_controller")
    local controller = controller_id ~= 0 and room:getPlayerById(controller_id) or nil

    if controller and not controller.dead then
      controller:uncontrol(player)
    end

    room:setPlayerMark(player, "fms__yanyi_controller", 0)
    room:setPlayerMark(player, "fms__yanyi_die_after_extra", 0)

    if not player.dead then
      room:killPlayer{
        who = player,
        damage = nil,
      }
    end
  end,
})

return yanyi_control
