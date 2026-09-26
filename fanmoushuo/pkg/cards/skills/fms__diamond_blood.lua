local skill = fk.CreateSkill{
  name = "fms__diamond_blood",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      player:isWounded() and
      data and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name,
    }
  end,
})

return skill
