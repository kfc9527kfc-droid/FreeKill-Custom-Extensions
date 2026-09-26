local skill = fk.CreateSkill{
  name = "fms__diamond_far_reduce",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and data.damage > 0 and
      data.from and not data.from.dead and
      not player:inMyAttackRange(data.from)
  end,
  on_use = function(self, event, target, player, data)
    if data.changeDamage then
      data:changeDamage(-1)
    else
      data.damage = math.max(0, data.damage - 1)
    end
  end,
})

return skill
