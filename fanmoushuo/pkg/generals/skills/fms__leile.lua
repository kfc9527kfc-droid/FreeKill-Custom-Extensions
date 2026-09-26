local leile = fk.CreateSkill{
  name = "fms__leile",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__leile"] = "累了",
  [":fms__leile"] = "锁定技，出牌阶段开始时，你进行判定，若点数小于你当前体力值，你结束出牌阶段。你死亡后选择一名角色获得“累了”<br>"..
  "[“最后一把，再打最后一把”]",
}

leile:addEffect(fk.EventPhaseChanging, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      not data.skipped and
      data.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if player.dead then return end

    if judge.card.number > 0 and judge.card.number < player.hp then
      data.skipped = true
    end
  end,
})

return leile
