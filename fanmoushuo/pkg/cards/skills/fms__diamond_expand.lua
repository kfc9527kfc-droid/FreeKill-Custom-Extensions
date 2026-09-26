local skill = fk.CreateSkill{
  name = "fms__diamond_expand",
  tags = { Skill.Compulsory },
}

skill:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(self.name) then
      return 2
    end
    return 0
  end,
})

return skill
