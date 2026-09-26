local xiaoju = fk.CreateSkill {
  name = "xiaoju",
  mode_skill = true,
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["xiaoju"] = "啸聚",
  [":xiaoju"] = "锁定技，你对原先阵营的地主造成的伤害+1。",
}

xiaoju:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(xiaoju.name) and data.to ~= player then
      return (player:hasMark("@!tiger_team") and data.to.role == "tiger_lord")
        or (player:hasMark("@!loong_team") and data.to.role == "loong_lord")
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
  end
})

return xiaoju
