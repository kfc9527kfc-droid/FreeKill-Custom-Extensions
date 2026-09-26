local skill = fk.CreateSkill{
  name = "fms__diamond_sharp",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.PreDamage, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and data.to and not data.to.dead and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    if data.preventDamage then
      data:preventDamage()
    end
  end,
})

return skill
