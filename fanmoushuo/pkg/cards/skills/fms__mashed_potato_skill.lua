local fms__mashed_potato_skill = fk.CreateSkill{
  name = "fms__mashed_potato_skill",
}

fms__mashed_potato_skill:addEffect("cardskill", {
  prompt = function(self, _, _, _, extra_data)
    return extra_data and extra_data.analepticRecover and "#peach_skill" or "#analeptic_skill"
  end,

  max_turn_use_time = 1,
  mod_target_filter = Util.TrueFunc,

  can_use = function(self, player, card, extra_data)
    return Util.CanUseToSelf(self, player, card, extra_data) and
      ((extra_data and (extra_data.bypass_times or extra_data.analepticRecover)) or
      self:withinTimesLimit(player, Player.HistoryTurn, card, "analeptic", player))
  end,

  on_use = function(self, room, use)
    if use.extra_data and use.extra_data.analepticRecover then
      use.extraUse = true
    end
  end,

  on_effect = function(self, room, effect)
    local to = effect.to
    if to.dead then
      return
    end

    room:setPlayerMark(to, "fms__mashed_potato_buff-turn", 1)

    if effect.extra_data and effect.extra_data.analepticRecover then
      if to:isWounded() then
        room:recover{
          who = to,
          num = 1,
          recoverBy = effect.from,
          card = effect.card,
          skillName = self.name,
        }
      end
    else
      to.drank = to.drank + 1 + ((effect.extra_data or {}).additionalDrank or 0)
      room:broadcastProperty(to, "drank")
    end
  end,
})

fms__mashed_potato_skill:addEffect(fk.Damage, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:getMark("fms__mashed_potato_buff-turn") > 0
      and data
      and data.card
      and data.card.trueName == "slash"
      and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "fms__mashed_potato_buff-turn", 0)
    if not player.dead and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
})

return fms__mashed_potato_skill
