local fms__fastfood = fk.CreateSkill{
  name = "fms__fastfood",
}

Fk:loadTranslationTable{
  ["fms__fastfood"] = "快餐",
  [":fms__fastfood"] = "游戏开始时，若你是场上第一名拥有此技能的角色，则将16张KFC美食卡洗入牌堆。当你使用【桃】或【酒】时，你可以从牌堆、弃牌堆中随机获得一张对应的美食牌；任何人使用美食牌时，也对你结算一次（若你无法回复体力，则只触发其额外效果）。",
  ["#fms__fastfood_invoke"] = "快餐：你可以获得一张对应的美食牌",
}

local peach_food_names = {
  "fms__egg_tart",
  "fms__original_chicken",
  "fms__burger",
  "fms__popcorn_chicken",
  "fms__colonel_nuggets",
}

local analeptic_food_names = {
  "fms__cola",
  "fms__coffee",
  "fms__mashed_potato",
}

local all_food_names = {
  "fms__egg_tart",
  "fms__original_chicken",
  "fms__burger",
  "fms__popcorn_chicken",
  "fms__colonel_nuggets",
  "fms__cola",
  "fms__coffee",
  "fms__mashed_potato",
}

local function isInNameList(name, list)
  for _, n in ipairs(list) do
    if n == name then
      return true
    end
  end
  return false
end

local function isPeachFood(card)
  return card and isInNameList(card.name, peach_food_names)
end

local function isAnalepticFood(card)
  return card and isInNameList(card.name, analeptic_food_names)
end

local function isFoodCard(card)
  return isPeachFood(card) or isAnalepticFood(card)
end

local function isFirstFastfoodOwner(player)
  for _, p in ipairs(player.room.alive_players) do
    if p:hasSkill("fms__fastfood") then
      return p == player
    end
  end
  return false
end

local function getRandomFoodFromAreas(room, name_list)
  local ids = {}

  for _, id in ipairs(room.draw_pile) do
    local c = Fk:getCardById(id)
    if c and isInNameList(c.name, name_list) then
      table.insert(ids, id)
    end
  end

  for _, id in ipairs(room.discard_pile) do
    local c = Fk:getCardById(id)
    if c and isInNameList(c.name, name_list) then
      table.insert(ids, id)
    end
  end

  if #ids == 0 then
    return nil
  end

  return room:tableRandomPick(ids)
end

local function resetOneSkill(room, player, skill_name)
  room:setPlayerMark(player, "@recharge-" .. skill_name, 0)
  if player:usedSkillTimes(skill_name, Player.HistoryGame) ~= 0 then
    player:setSkillUseHistory(skill_name, 0, Player.HistoryGame)
  end
  if player:usedSkillTimes(skill_name, Player.HistoryTurn) ~= 0 then
    player:setSkillUseHistory(skill_name, 0, Player.HistoryTurn)
  end
  if player:usedSkillTimes(skill_name, Player.HistoryRound) ~= 0 then
    player:setSkillUseHistory(skill_name, 0, Player.HistoryRound)
  end
  if player:usedSkillTimes(skill_name, Player.HistoryPhase) ~= 0 then
    player:setSkillUseHistory(skill_name, 0, Player.HistoryPhase)
  end
end

local function resolveFoodExtraEffect(room, player, food_name, skill_name)
  if food_name == "fms__egg_tart" then
    player:drawCards(2, skill_name)

  elseif food_name == "fms__original_chicken" then
    room:addPlayerMark(player, MarkEnum.AddMaxCards, 1)

  elseif food_name == "fms__burger" then
    room:changeMaxHp(player, 1)

  elseif food_name == "fms__popcorn_chicken" then
    local skills = table.filter(player.player_skills, function(s)
      return s:isPlayerSkill(player) and (
        player:usedSkillTimes(s.name, Player.HistoryGame) ~= 0 or
        player:usedSkillTimes(s.name, Player.HistoryTurn) ~= 0 or
        player:usedSkillTimes(s.name, Player.HistoryRound) ~= 0 or
        player:usedSkillTimes(s.name, Player.HistoryPhase) ~= 0
      )
    end)

    if #skills > 0 then
      local choice = room:askToChoice(player, {
        choices = table.map(skills, function(s) return s.name end),
        skill_name = skill_name,
        prompt = "鸡米花：请选择一个要重置的技能",
      })
      if choice then
        resetOneSkill(room, player, choice)
      end
    end

  elseif food_name == "fms__colonel_nuggets" then
    room:changeShield(player, 1)

  elseif food_name == "fms__cola" then
    player:reset()

  elseif food_name == "fms__coffee" then
    room:setPlayerMark(player, "fms__coffee_skip_discard-turn", 1)

  elseif food_name == "fms__mashed_potato" then
    room:setPlayerMark(player, "fms__mashed_potato_buff-turn", 1)
  end
end

local function resolveFoodToFastfoodOwner(room, owner, card, skill_name)
  if not owner or owner.dead or not card then
    return
  end

  local food_name = card.name
  resolveFoodExtraEffect(room, owner, food_name, skill_name)

  if owner.dead then
    return
  end

  if isPeachFood(card) then
    if owner:isWounded() then
      room:recover{
        who = owner,
        num = 1,
        recoverBy = owner,
        skillName = skill_name,
      }
    end
  elseif isAnalepticFood(card) then
    owner.drank = owner.drank + 1
    room:broadcastProperty(owner, "drank")
  end
end

fms__fastfood:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(self.name)
      and isFirstFastfoodOwner(player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}

    for _, card in ipairs(Fk.cards) do
      if isInNameList(card.name, all_food_names) and card.suit ~= Card.NoSuit then
        table.insert(cards, room:printCard(card.name, card.suit, card.number).id)
      end
    end

    if #cards == 0 then
      return
    end

    table.shuffle(cards)

    local positions = {}
    local y = #room.draw_pile
    for _ = 1, #cards do
      table.insert(positions, math.random(y + 1))
    end
    table.sort(positions, function(a, b) return a > b end)

    local moveInfos = {}
    for i = 1, #cards do
      table.insert(moveInfos, {
        ids = { cards[i] },
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
        drawPilePosition = positions[i],
      })
    end

    room:moveCards(table.unpack(moveInfos))
  end,
})

fms__fastfood:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(self.name)
      and data
      and data.card
      and (data.card.trueName == "peach" or data.card.trueName == "analeptic")
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__fastfood_invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pool = (data.card.trueName == "peach") and peach_food_names or analeptic_food_names
    local id = getRandomFoodFromAreas(room, pool)
    if id then
      room:obtainCard(player, id, false, fk.ReasonPrey)
    end
  end,
})

fms__fastfood:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
      and not player.dead
      and data
      and data.card
      and isFoodCard(data.card)
  end,
  on_use = function(self, event, target, player, data)
    resolveFoodToFastfoodOwner(player.room, player, data.card, self.name)
  end,
})

fms__fastfood:addEffect(fk.EventPhaseChanging, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:getMark("fms__coffee_skip_discard-turn") > 0
      and data.phase == Player.Discard
      and not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fms__coffee_skip_discard-turn", 0)
    data.skipped = true
  end,
})

fms__fastfood:addEffect(fk.Damage, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:getMark("fms__mashed_potato_buff-turn") > 0
      and data
      and data.card
      and data.card.trueName == "slash"
      and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "fms__mashed_potato_buff-turn", 0)
    if not player.dead and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
})

return fms__fastfood
