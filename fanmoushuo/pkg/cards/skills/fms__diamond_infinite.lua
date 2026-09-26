local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_infinite",
  tags = { Skill.Compulsory },
}

skill:addEffect("targetmod", {
  bypass_times = function(self, player, active_skill, scope, card, to)
    if not player:hasSkill(self.name) or not card then
      return false
    end
    return common.isSlash(card) or common.isAnaleptic(card)
  end,
})

return skill
