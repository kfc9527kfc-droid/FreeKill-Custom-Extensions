local yanyi = fk.CreateSkill{
  name = "fms__yanyi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["fms__yanyi"] = "演绎",
  [":fms__yanyi"] = "限定技，一名角色死亡时，你可以令其复原，并由你操作，然后其立即进行一个额外回合。<br>"..
  "[“谢谢，谢谢大家*★,°*:.☆(￣▽￣)/$:*.°★* 。”]",
  ["#fms__yanyi-invoke"] = "演绎：你可以令 %dest 复原，由你操控其执行一个额外回合，然后其死亡",
}

yanyi:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      target ~= nil and
      not player.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__yanyi-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:setPlayerMark(player, "@@fms__yanyi_used", 1)

    -- 复原目标
    if target.dead then
      room:revivePlayer(target, false)
    end
    if target:isWounded() or target.hp < 1 then
      room:recover{
        who = target,
        num = math.max(1, 1 - target.hp),
        recoverBy = player,
        skillName = self.name,
      }
    end
    if not target.faceup then
      target:turnOver()
    end

    if target.dead then return end

    -- 记录由谁控制，以及额外回合结束后要死亡
    room:setPlayerMark(target, "fms__yanyi_controller", player.id)
    room:setPlayerMark(target, "fms__yanyi_die_after_extra", 1)

    -- 由你控制其额外回合
    player:control(target)
    target:gainAnExtraTurn()
  end,
})

return yanyi
