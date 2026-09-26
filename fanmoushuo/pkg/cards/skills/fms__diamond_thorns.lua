Fk:loadTranslationTable{
  ["#fms__diamond_thorns-discard"] = "荆棘：弃置 %dest 一张牌",
}

local skill = fk.CreateSkill{
  name = "fms__diamond_thorns",
  tags = { Skill.Compulsory },
}

skill:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(self.name) and
      data and data.damage > 0 and
      data.from and not data.from.dead and
      not data.from:isAllNude() and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askToChooseCard(player, {
      target = data.from,
      flag = "hej",
      skill_name = self.name,
      prompt = "#fms__diamond_thorns-discard::" .. data.from.id,
    })
    if id then
      room:throwCard(id, self.name, data.from, player)
    end
  end,
})

return skill
