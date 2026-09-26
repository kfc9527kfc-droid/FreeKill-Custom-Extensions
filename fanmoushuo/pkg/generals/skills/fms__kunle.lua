local U = require "packages.utility.utility"

local function clearKunleDeclared(player)
  local room = player.room
  for _, cid in ipairs(player:getCardIds("h")) do
    local c = Fk:getCardById(cid, true)
    if c:getMark("fms__kunle_declared") ~= 0 then
      room:setCardMark(c, "fms__kunle_declared", 0)
      room:setCardMark(c, "@fms__kunle_declared", 0)
    end
  end
end

local function hasKunleState(player)
  return player:getMark("fms__kunle_suit-turn") ~= 0 and player:getMark("fms__kunle_number-turn") ~= 0
end

-- 改动点：由“同花色且同点数”改为“同花色或同点数”
local function matchKunleCard(player, cid)
  if not hasKunleState(player) then return false end
  local card = Fk:getCardById(cid, true)
  if not card or card.suit == Card.NoSuit or card.number <= 0 then return false end

  local suit_mark = player:getMark("fms__kunle_suit-turn")
  local number_mark = player:getMark("fms__kunle_number-turn")

  return card.suit == suit_mark or card.number == number_mark
end

local function isOrdinaryTrick(name)
  local card = Fk:cloneCard(name)
  return card and card.type == Card.TypeTrick and card.sub_type ~= Card.SubtypeDelayedTrick
end

local function isBasicOrOrdinaryTrick(name)
  local card = Fk:cloneCard(name)
  if not card then return false end
  return card.type == Card.TypeBasic or isOrdinaryTrick(name)
end

local function getKunleDeclaredCard(player)
  for _, cid in ipairs(player:getCardIds("h")) do
    local name = Fk:getCardById(cid, true):getMark("fms__kunle_declared")
    if type(name) == "string" and isBasicOrOrdinaryTrick(name) then
      local card = Fk:cloneCard(name)
      card.skillName = "fms__kunle"
      card:addSubcard(cid)
      return card
    end
  end
end

local function hasUndeclaredKunleCard(player)
  for _, cid in ipairs(player:getCardIds("h")) do
    local c = Fk:getCardById(cid, true)
    if c:getMark("fms__kunle_declared") == 0 and matchKunleCard(player, cid) then
      return true
    end
  end
  return false
end

local function getKunleChoices()
  local all_names = Fk:getAllCardNames("bt")
  local choices = {}
  for _, name in ipairs(all_names) do
    if isBasicOrOrdinaryTrick(name) then
      table.insert(choices, name)
    end
  end
  return choices
end

local kunle = fk.CreateSkill{
  name = "fms__kunle",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__kunle"] = "困了",
  [":fms__kunle"] = "锁定技，准备阶段，你亮出牌堆顶的一张牌并获得之，若此牌为黑色，你翻面；然后直至你下个回合开始，你可以将与亮出的牌同花色或同点数的牌，当作任意基本牌或普通锦囊牌使用。<br>"..
  "[“你可曾见过凌晨三点的经济学院”]",

  ["@fms__kunle"] = "困了",
  ["@fms__kunle_declared"] = "困了",
  ["#fms__kunle0"] = "困了：选择一张与亮出牌同花色或同点数的手牌，声明一种基本牌或普通锦囊牌",
  ["#fms__kunle-use"] = "困了：你可以将这张牌当 %arg 使用或打出",
  ["#fms__kunle-choice"] = "困了：声明一种基本牌或普通锦囊牌，本回合内你可以将此牌当之使用或打出",
}

-- 到自己回合开始时，清空上一轮记录
kunle:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "fms__kunle_suit-turn", 0)
    room:setPlayerMark(player, "fms__kunle_number-turn", 0)
    room:setPlayerMark(player, "@fms__kunle", 0)
    clearKunleDeclared(player)
  end,
})

-- 准备阶段：亮出牌堆顶一张牌并获得之；若为黑色则翻面，并记录花色/点数直到下个回合开始
kunle:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    clearKunleDeclared(player)
    room:setPlayerMark(player, "fms__kunle_suit-turn", 0)
    room:setPlayerMark(player, "fms__kunle_number-turn", 0)
    room:setPlayerMark(player, "@fms__kunle", 0)

    if #room.draw_pile == 0 then return end

    local id = room.draw_pile[1]
    room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)

    local card = Fk:getCardById(id, true)
    if not card then return end

    if card.color == Card.Black then
      room:setPlayerMark(player, "fms__kunle_suit-turn", card.suit)
      room:setPlayerMark(player, "fms__kunle_number-turn", card.number)
      room:setPlayerMark(player, "@fms__kunle", {
        card:getSuitString(true),
        card:getNumberStr(),
      })
      player:turnOver()
    end
  end,
})

kunle:addEffect("viewas", {
  pattern = ".",
  prompt = function(self, player, selected_cards, selected_targets)
    local card = getKunleDeclaredCard(player)
    if card then
      return "#fms__kunle-use:::" .. card:toLogString()
    end
    return "#fms__kunle0"
  end,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".",
  },
  card_filter = function(self, player, to_select, selected, selected_targets)
    if #selected > 0 or not hasKunleState(player) then return false end

    local declared = getKunleDeclaredCard(player)
    if declared then
      return to_select == declared.subcards[1] and player:canUseOrResponseInCurrent(declared)
    end

    local card = Fk:getCardById(to_select, true)
    return
      table.contains(player:getCardIds("h"), to_select) and
      card:getMark("fms__kunle_declared") == 0 and
      matchKunleCard(player, to_select)
  end,
  view_as = function(self, player, cards)
    if #cards > 0 then
      return getKunleDeclaredCard(player)
    end
  end,
  feasible = function(self, player, selected, selected_cards, card)
    return #selected_cards == 1
  end,
  on_use = function(self, room, effect, card, params)
    if card then
      return ViewAsSkill:onUse(room, effect, card, params)
    end

    local player = effect.from
    local id = effect.cards[1]
    if not id or not table.contains(player:getCardIds("h"), id) then return end

    local choice = U.askForChooseCardNames(
      room,
      player,
      getKunleChoices(),
      1,
      1,
      kunle.name,
      "#fms__kunle-choice"
    )[1]

    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = choice,
      toast = true,
    }

    local real = Fk:getCardById(id, true)
    room:setCardMark(real, "fms__kunle_declared", choice)
    room:setCardMark(real, "@fms__kunle_declared", Fk:translate(choice))
  end,
  enabled_at_play = function(self, player)
    if not hasKunleState(player) then return false end
    local card = getKunleDeclaredCard(player)
    if card then
      return player:canUse(card)
    end
    return hasUndeclaredKunleCard(player)
  end,
  enabled_at_response = function(self, player, response)
    if not hasKunleState(player) then return false end
    local card = getKunleDeclaredCard(player)
    if card then
      return player:canUseOrResponseInCurrent(card)
    end
    return hasUndeclaredKunleCard(player)
  end,
})

kunle:addLoseEffect(function(self, player, isDeath)
  local room = player.room
  room:setPlayerMark(player, "fms__kunle_suit-turn", 0)
  room:setPlayerMark(player, "fms__kunle_number-turn", 0)
  room:setPlayerMark(player, "@fms__kunle", 0)
  clearKunleDeclared(player)
end)

return kunle
