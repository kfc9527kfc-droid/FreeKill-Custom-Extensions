local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_power",
  tags = { Skill.Compulsory },
}

common.addTurnReset(skill, "fms__diamond_power_used-turn")

skill:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player:getMark("fms__diamond_power_used-turn") == 0 and
      data and data.to and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    if data.changeDamage then
      data:changeDamage(1)
    else
      data.damage = data.damage + 1
    end
    player.room:setPlayerMark(player, "fms__diamond_power_used-turn", 1)
  end,
})

return skill
