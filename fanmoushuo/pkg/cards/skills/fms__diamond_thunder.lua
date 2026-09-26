local skill = fk.CreateSkill{
  name = "fms__diamond_thunder",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and data.to and not data.to.dead and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = data.to,
      reason = "lightning",
      pattern = ".|2~9|spade",
    }
    room:judge(judge)
    if judge:matchPattern() and not data.to.dead then
      room:damage{
        to = data.to,
        damage = 3,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
    end
  end,
})

return skill
