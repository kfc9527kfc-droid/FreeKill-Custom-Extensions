local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

Fk:loadTranslationTable{
  ["#fms__diamond_rob-prey"] = "抢夺：获得 %dest 一张手牌",
}

local skill = fk.CreateSkill{
  name = "fms__diamond_rob",
  tags = { Skill.Compulsory },
}

common.addTurnReset(skill, "fms__diamond_rob_used-turn")

skill:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player:getMark("fms__diamond_rob_used-turn") == 0 and
      data and data.to and not data.to.dead and
      not data.to:isKongcheng() and
      data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askToChooseCard(player, {
      target = data.to,
      flag = "h",
      skill_name = self.name,
      prompt = "#fms__diamond_rob-prey::" .. data.to.id,
    })
    if id then
      room:obtainCard(player, id, false, fk.ReasonPrey)
      room:setPlayerMark(player, "fms__diamond_rob_used-turn", 1)
    end
  end,
})

return skill
