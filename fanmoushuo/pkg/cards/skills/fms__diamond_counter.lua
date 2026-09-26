Fk:loadTranslationTable{
  ["#fms__diamond_counter-invoke"] = "反击：你可以视为对 %dest 使用一张【杀】",
}

local skill = fk.CreateSkill{
  name = "fms__diamond_counter",
}

skill:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and data.damage > 0 and
      data.from and not data.from.dead and
      data.from ~= player and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__diamond_counter-invoke::" .. data.from.id,
    }) then
      room:useVirtualCard("slash", nil, player, data.from, self.name, true)
    end
  end,
})

return skill
