local skill = fk.CreateSkill{
  name = "fms__diamond_bless",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

skill:addEffect(fk.HpRecover, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return skill
