local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local skill = fk.CreateSkill{
  name = "fms__diamond_curse",
  tags = { Skill.Compulsory },
}

common.addTurnReset(skill, "fms__diamond_curse_used-turn")

skill:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      player:getMark("fms__diamond_curse_used-turn") == 0 and
      data and common.isSlash(data.card)
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fms__diamond_curse_used-turn", 1)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(data.disresponsiveList, p)
    end
  end,
})

return skill
