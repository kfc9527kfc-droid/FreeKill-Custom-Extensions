local fms__cola_skill = fk.CreateSkill{
  name = "fms__cola_skill",
}

fms__cola_skill:addEffect("cardskill", {
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

    to:reset()

    if to.dead then
      return
    end

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

return fms__cola_skill
