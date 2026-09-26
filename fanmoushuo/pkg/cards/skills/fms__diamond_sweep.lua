local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_sweep",
  tags = { Skill.Compulsory },
}

common.addTurnReset(skill, "fms__diamond_sweep_used-turn")

skill:addEffect("targetmod", {
  extra_target_func = function(self, player, active_skill, card)
    if not player:hasSkill(self.name) or not common.isSlash(card) then
      return 0
    end
    if player:getMark("fms__diamond_sweep_used-turn") > 0 then
      return 0
    end
    return 99
  end,
})

skill:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      player:getMark("fms__diamond_sweep_used-turn") == 0 and
      data and common.isSlash(data.card)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fms__diamond_sweep_used-turn", 1)
  end,
})

return skill
