local fms__popcorn_chicken_skill = fk.CreateSkill{
  name = "fms__popcorn_chicken_skill",
}

fms__popcorn_chicken_skill:addEffect("cardskill", {
  prompt = function(self, _, _, _, extra_data)
    return extra_data and extra_data.analepticRecover and
      ("#peach_dying::" .. extra_data.must_targets[1]) or
      "#peach_skill"
  end,

  mod_target_filter = function(self, player, to_select)
    return to_select:isWounded()
  end,

  can_use = Util.CanUseToSelf,

  on_effect = function(self, room, effect)
    local player = effect.to
    if player.dead then
      return
    end

    local skills = table.filter(player.player_skills, function(s)
      return s:isPlayerSkill(player) and (
        player:usedSkillTimes(s.name, Player.HistoryGame) ~= 0 or
        player:usedSkillTimes(s.name, Player.HistoryTurn) ~= 0 or
        player:usedSkillTimes(s.name, Player.HistoryRound) ~= 0 or
        player:usedSkillTimes(s.name, Player.HistoryPhase) ~= 0
      )
    end)

    if #skills > 0 then
      local choices = table.map(skills, function(s)
        return s.name
      end)

      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = self.name,
        prompt = "鸡米花：请选择一个要重置的技能",
      })

      if choice then
        room:setPlayerMark(player, "@recharge-" .. choice, 0)
        if player:usedSkillTimes(choice, Player.HistoryGame) ~= 0 then
          player:setSkillUseHistory(choice, 0, Player.HistoryGame)
        end
        if player:usedSkillTimes(choice, Player.HistoryTurn) ~= 0 then
          player:setSkillUseHistory(choice, 0, Player.HistoryTurn)
        end
        if player:usedSkillTimes(choice, Player.HistoryRound) ~= 0 then
          player:setSkillUseHistory(choice, 0, Player.HistoryRound)
        end
        if player:usedSkillTimes(choice, Player.HistoryPhase) ~= 0 then
          player:setSkillUseHistory(choice, 0, Player.HistoryPhase)
        end
      end
    end

    if player.dead then
      return
    end

    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        card = effect.card,
        recoverBy = effect.from,
        skillName = self.name,
      }
    end
  end,
})

return fms__popcorn_chicken_skill
