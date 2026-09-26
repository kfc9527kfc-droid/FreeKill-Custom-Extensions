local fms__a_question = fk.CreateSkill{
  name = "fms__a_question",
}

Fk:loadTranslationTable{
  ["fms__a_question"] = "啊？",
  [":fms__a_question"] = "每个技能限一次，当其他角色使用技能时，你可以摸一张牌，然后获得其一张牌并标记该技能，然后你令此技能于此次结算后失效，直到此牌离开你的手牌。",
  ["#fms__a_question-invoke"] = "啊？：你可以摸一张牌，获得 %dest 一张牌，然后令其技能【%arg】于此次结算后失效，直到此牌离开你的手牌",
  ["fms__a_question_yes"] = "发动“啊？”",
  ["@@fms__a_question_invalid"] = "啊？失效",
  ["@fms__a_question_hand"] = "啊？",
}

fms__a_question:addEffect(fk.SkillEffect, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then
      return false
    end
    if not target or target == player then
      return false
    end
    if target:isNude() then
      return false
    end
    if not data or not data.skill then
      return false
    end
    if not data.skill:isPlayerSkill(target) then
      return false
    end

    local skill_name = data.skill:getSkeleton().name
    if not skill_name then
      return false
    end
    if not target:hasSkill(skill_name, true, true) then
      return false
    end

    local used_skills = player:getTableMark("fms__a_question_used_skills")
    return not table.contains(used_skills, skill_name)
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    local skill_name = data.skill:getSkeleton().name

    local choice = room:askToChoice(player, {
      choices = { "fms__a_question_yes", "Cancel" },
      skill_name = self.name,
      prompt = "#fms__a_question-invoke::" .. target.id .. ":" .. Fk:translate(skill_name),
    })
    if choice ~= "fms__a_question_yes" then
      return false
    end

    local c = room:askToChooseCards(player, {
      target = target,
      min = 1,
      max = 1,
      flag = "he",
      skill_name = self.name,
      prompt = "#fms__a_question-invoke::" .. target.id .. ":" .. Fk:translate(skill_name),
      cancelable = true,
    })
    if #c == 0 then
      return false
    end

    event:setCostData(self, {
      cid = c[1],
      skill_name = skill_name,
    })
    return true
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    if not cost then
      return
    end

    local cid = cost.cid
    local skill_name = cost.skill_name
    if not cid or not skill_name then
      return
    end

    -- 成长统计：从自己上个回合开始到现在，这一轮内只要用过“啊？”就记上
    room:setPlayerMark(player, "fms__growth_used-round", 1)

    player:drawCards(1, self.name)   -- ← 这里已修改为摸1张

    local used_skills = player:getTableMark("fms__a_question_used_skills")
    if not table.contains(used_skills, skill_name) then
      table.insert(used_skills, skill_name)
      room:setPlayerMark(player, "fms__a_question_used_skills", used_skills)
    end

    room:moveCardTo({ cid }, Player.Hand, player, fk.ReasonPrey, self.name, nil, true, player)

    local invalid_skills = target:getTableMark("@@fms__a_question_invalid")
    table.insert(invalid_skills, { player.id, skill_name, cid })
    room:setPlayerMark(target, "@@fms__a_question_invalid", invalid_skills)

    room:setCardMark(Fk:getCardById(cid), "@fms__a_question_hand", Fk:translate(Fk.skills[skill_name].name))
  end,
})

fms__a_question:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    local mark = from:getTableMark("@@fms__a_question_invalid")
    return #table.filter(mark, function(q)
      return q[2] == skill.name
    end) > 0
  end,
})

fms__a_question:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    local mark = player:getTableMark("@@fms__a_question_invalid")
    if #mark == 0 then
      return false
    end

    for _, move in ipairs(data) do
      if move.from then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            for _, rec in ipairs(mark) do
              if rec[1] == move.from.id and rec[3] == info.cardId then
                return true
              end
            end
          end
        end
      end
    end
    return false
  end,

  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("@@fms__a_question_invalid")
    local remain = {}

    for _, rec in ipairs(mark) do
      local holder_id = rec[1]
      local skill_name = rec[2]
      local card_id = rec[3]
      local removed = false

      for _, move in ipairs(data) do
        if move.from and move.from.id == holder_id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and info.cardId == card_id then
              removed = true
              break
            end
          end
        end
        if removed then
          break
        end
      end

      if removed then
        room:setCardMark(Fk:getCardById(card_id), "@fms__a_question_hand", 0)
      else
        table.insert(remain, { holder_id, skill_name, card_id })
      end
    end

    room:setPlayerMark(player, "@@fms__a_question_invalid", remain)
  end,
})

fms__a_question:addEffect("visibility", {
  card_visible = function(self, player, card)
    if card:getMark("@fms__a_question_hand") ~= 0 then
      return true
    end
  end,
})

return fms__a_question
