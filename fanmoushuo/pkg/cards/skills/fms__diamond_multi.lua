local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_multi",
  tags = { Skill.Compulsory },
}

common.addTurnReset(skill, "fms__diamond_multi_used-turn")

skill:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      player:getMark("fms__diamond_multi_used-turn") == 0 and
      data and data.firstTarget and common.isDamageCard(data.card)
  end,
  on_use = function(self, event, target, player, data)
    data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
    player.room:setPlayerMark(player, "fms__diamond_multi_used-turn", 1)
  end,
})

return skill
