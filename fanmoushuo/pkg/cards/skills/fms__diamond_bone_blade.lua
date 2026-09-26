local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_bone_blade",
  tags = { Skill.Compulsory },
}

skill:addEffect("targetmod", {
  bypass_distances = function(self, player, active_skill, card, to)
    return player:hasSkill(self.name) and common.isSlash(card)
  end,
})

return skill
