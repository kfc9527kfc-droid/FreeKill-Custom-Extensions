local skill = fk.CreateSkill{
  name = "fms__diamond_fire",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data and data.to and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
  end,
})

return skill
