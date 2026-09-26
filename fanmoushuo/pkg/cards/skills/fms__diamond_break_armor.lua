local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_break_armor",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and common.isSlash(data.card) and data.to and not data.to.dead
  end,
  on_refresh = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

return skill
