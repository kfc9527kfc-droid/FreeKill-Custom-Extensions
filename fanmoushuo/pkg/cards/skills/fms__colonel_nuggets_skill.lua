local fms__colonel_nuggets_skill = fk.CreateSkill{
  name = "fms__colonel_nuggets_skill",
}

fms__colonel_nuggets_skill:addEffect("cardskill", {
  prompt = function(self, _, _, _, extra_data)
    return extra_data and extra_data.analepticRecover and
      ("#peach_dying::" .. extra_data.must_targets[1]) or
      "#peach_skill"
  end,

  mod_target_filter = function(self, player, to_select)
    return to_select:isWounded()
  end,

  can_use = Util.CanUseToSelf,

  on_effect = function(self, room, effect)
    if effect.to.dead then
      return
    end

    room:changeShield(effect.to, 1)

    if effect.to.dead then
      return
    end

    if effect.to:isWounded() then
      room:recover{
        who = effect.to,
        num = 1,
        card = effect.card,
        recoverBy = effect.from,
        skillName = self.name,
      }
    end
  end,
})

return fms__colonel_nuggets_skill
