local function buildLoseChoices(player)
  local choices = { "Cancel" }
  for i = 1, player.hp do
    table.insert(choices, tostring(i))
  end
  return choices
end

local junlintianxia = fk.CreateSkill{
  name = "fms__junlintianxia",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__junlintianxia"] = "君临天下",
  [":fms__junlintianxia"] = "锁定技，准备阶段，若“荣”区中的牌数不小于10，你可以失去任意体力值，增加等量的手牌上限，然后你重铸所有手牌，获得“荣”区中的所有牌；若如此做，结束阶段，你失去所有手牌和“荣”区中的所有牌。<br>"..
  "[“都给我坐下！”]",

  ["#fms__junlintianxia-lose"] = "君临天下：你可以失去任意点体力，增加等量手牌上限，然后重铸所有手牌并获得所有“荣”",
}

-- 手牌上限修正
junlintianxia:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(self.name, true) then
      return player:getMark("fms__junlintianxia_extra_maxcards")
    end
    return 0
  end,
})

-- 准备阶段前半部分
junlintianxia:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player.phase == Player.Start and
      #player:getPile("fms__rong") >= 10 and
      player.hp > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = buildLoseChoices(player),
      skill_name = self.name,
      prompt = "#fms__junlintianxia-lose",
    })

    if choice == "Cancel" then
      return false
    end

    event:setCostData(self, { lose = tonumber(choice) })
    return tonumber(choice) and tonumber(choice) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local lose = event:getCostData(self).lose
    if not lose or lose <= 0 then return end

    -- 标记本回合已经发动过前半部分，结束阶段才会结算后半部分
    room:setPlayerMark(player, "fms__junlintianxia_active-turn", 1)

    -- 失去体力
    room:loseHp(player, lose)
    if player.dead then return end

    -- 增加手牌上限
    room:setPlayerMark(
      player,
      "fms__junlintianxia_extra_maxcards",
      player:getMark("fms__junlintianxia_extra_maxcards") + lose
    )

    -- 重铸所有手牌：全部置入弃牌堆，再摸等量牌
    local handcards = {}
    for _, id in ipairs(player:getCardIds("h")) do
      table.insert(handcards, id)
    end
    if #handcards > 0 then
      room:moveCardTo(
        handcards,
        Card.DiscardPile,
        nil,
        fk.ReasonPutIntoDiscardPile,
        self.name,
        nil,
        true,
        player
      )
      if player.dead then return end
      player:drawCards(#handcards, self.name)
    end

    -- 获得所有“荣”
    local rong = {}
    for _, id in ipairs(player:getPile("fms__rong")) do
      table.insert(rong, id)
    end
    if #rong > 0 then
      room:moveCardTo(
        rong,
        Card.PlayerHand,
        player,
        fk.ReasonJustMove,
        self.name,
        nil,
        true,
        player
      )
    end
  end,
})

-- 结束阶段后半部分：只有本回合准备阶段真的发动过前半部分才触发
junlintianxia:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player.phase == Player.Finish and
      player:getMark("fms__junlintianxia_active-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 清掉本回合标记
    room:setPlayerMark(player, "fms__junlintianxia_active-turn", 0)

    -- 失去所有手牌
    local handcards = {}
    for _, id in ipairs(player:getCardIds("h")) do
      table.insert(handcards, id)
    end
    if #handcards > 0 then
      room:moveCardTo(
        handcards,
        Card.DiscardPile,
        nil,
        fk.ReasonPutIntoDiscardPile,
        self.name,
        nil,
        true,
        player
      )
    end

    -- 失去所有“荣”
    local rong = {}
    for _, id in ipairs(player:getPile("fms__rong")) do
      table.insert(rong, id)
    end
    if #rong > 0 then
      room:moveCardTo(
        rong,
        Card.DiscardPile,
        nil,
        fk.ReasonPutIntoDiscardPile,
        self.name,
        nil,
        true,
        player
      )
    end
  end,
})

junlintianxia:addLoseEffect(function(self, player, isDeath)
  local room = player.room
  room:setPlayerMark(player, "fms__junlintianxia_extra_maxcards", 0)
  room:setPlayerMark(player, "fms__junlintianxia_active-turn", 0)
end)

return junlintianxia
