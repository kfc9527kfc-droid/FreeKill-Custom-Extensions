local function suitText(suit)
  if suit == Card.Spade then
    return "黑桃"
  elseif suit == Card.Heart then
    return "红桃"
  elseif suit == Card.Club then
    return "梅花"
  elseif suit == Card.Diamond then
    return "方块"
  else
    return "无花色"
  end
end

local function typeText(card)
  if card.type == Card.TypeBasic then
    return "基本牌"
  elseif card.type == Card.TypeEquip then
    return "装备牌"
  elseif card.type == Card.TypeTrick then
    if card.sub_type == Card.SubtypeDelayedTrick then
      return "延时锦囊"
    else
      return "普通锦囊"
    end
  else
    return "未知类别"
  end
end

local function numberText(number)
  if number == 1 then
    return "A"
  elseif number == 11 then
    return "J"
  elseif number == 12 then
    return "Q"
  elseif number == 13 then
    return "K"
  elseif number and number > 0 then
    return tostring(number)
  else
    return "无点数"
  end
end

local function getTurnDiscardIds(room)
  local ids = {}
  room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
    for _, move in ipairs(e.data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(room.discard_pile, info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
  end, Player.HistoryTurn)
  return ids
end

local function rongHasSameNumber(player, number)
  if number <= 0 then return false end
  for _, id in ipairs(player:getPile("fms__rong")) do
    local card = Fk:getCardById(id)
    if card.number > 0 and card.number == number then
      return true
    end
  end
  return false
end

local function getAreaIds(player)
  local ids = {}
  for _, id in ipairs(player:getCardIds("ej")) do
    table.insert(ids, id)
  end
  return ids
end

local function buildChoices(area_ids, discard_ids)
  local choices = {}

  for _, id in ipairs(area_ids) do
    local c = Fk:getCardById(id)
    table.insert(
      choices,
      "区域|" .. id .. "|" .. Fk:translate(c.trueName) .. "|" .. suitText(c.suit) .. "|" .. numberText(c.number) .. "|" .. typeText(c)
    )
  end

  for _, id in ipairs(discard_ids) do
    local c = Fk:getCardById(id)
    table.insert(
      choices,
      "弃牌堆|" .. id .. "|" .. Fk:translate(c.trueName) .. "|" .. suitText(c.suit) .. "|" .. numberText(c.number) .. "|" .. typeText(c)
    )
  end

  table.insert(choices, "Cancel")
  return choices
end

local function parseChoice(choice)
  local source, id = string.match(choice, "^(.-)|(%d+)|")
  if source and id then
    return source, tonumber(id)
  end
  return nil, nil
end

local bababoyi = fk.CreateSkill{
  name = "fms__bababoyi",
  derived_piles = "fms__rong",
}

Fk:loadTranslationTable{
  ["fms__bababoyi"] = "巴巴博一",
  [":fms__bababoyi"] = "当你使用的牌与上一张牌的花色或类别相同时，你可以将自己区域内或当前回合弃牌堆中的一张牌置于武将牌旁，称为“荣区”[“咕咕嘎嘎”]；当你使用或打出某种点数的牌时，若“荣区”中有相同点数的牌，你摸一张牌。[“比比拉布”]",

  ["#fms__rong"] = "荣",
  ["@fms__bababoyi"] = "博一",

  ["#fms__bababoyi-put"] = "巴巴博一：你可以将一张牌置入“荣区”",
}

-- 保留这个，和你给的可见版本一致
Fk:addQmlMark{
  name = "fms__rong",
  how_to_show = function(_, value, player)
    return tostring(#player:getPile("fms__rong"))
  end,
  qml_data = function(_, _, player)
    return player:getPile("fms__rong")
  end,
  qml_path = "packages/utility/qml/ViewPile"
}

-- 前半段：与上一张牌同花色或同类别时，可以置一张牌入荣区
bababoyi:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name) and data and data.card) then
      return false
    end

    local last_suit = player:getMark("fms__bababoyi_last_suit")
    local last_type = player:getMark("fms__bababoyi_last_type")
    if last_suit == 0 and last_type == 0 then
      return false
    end

    local card = data.card
    local matched = false

    if card.suit ~= Card.NoSuit and last_suit ~= 0 and card.suit == last_suit then
      matched = true
    end
    if last_type ~= 0 and card.type == last_type then
      matched = true
    end

    if not matched then
      return false
    end

    local room = player.room
    local area_ids = getAreaIds(player)
    local discard_ids = getTurnDiscardIds(room)

    if #area_ids == 0 and #discard_ids == 0 then
      return false
    end

    event:setCostData(self, {
      area_ids = area_ids,
      discard_ids = discard_ids,
    })
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    local choices = buildChoices(cost.area_ids, cost.discard_ids)

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = self.name,
      prompt = "#fms__bababoyi-put",
    })

    if choice == "Cancel" then
      return false
    end

    local _, id = parseChoice(choice)
    if not id then
      return false
    end

    event:setCostData(self, { chosen_id = id })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local id = event:getCostData(self).chosen_id
    if not id then return end
    player:addToPile("fms__rong", { id }, true, self.name, player)
  end,
})

-- 后半段：使用牌时，只要荣区有相同点数就摸一张
bababoyi:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and data and data.card
  end,
  on_refresh = function(self, event, target, player, data)
    local number = data.card.number
    if #player:getPile("fms__rong") > 0 and rongHasSameNumber(player, number) then
      data.extra_data = data.extra_data or {}
      data.extra_data.fms__bababoyi_draw = true
    end
  end,
})

bababoyi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      data and
      data.extra_data and
      data.extra_data.fms__bababoyi_draw == true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

-- 后半段：打出牌时，只要荣区有相同点数就摸一张
bababoyi:addEffect(fk.PreCardRespond, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and data and data.card
  end,
  on_refresh = function(self, event, target, player, data)
    local number = data.card.number
    if #player:getPile("fms__rong") > 0 and rongHasSameNumber(player, number) then
      data.extra_data = data.extra_data or {}
      data.extra_data.fms__bababoyi_draw = true
    end
  end,
})

bababoyi:addEffect(fk.CardResponding, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      data and
      data.extra_data and
      data.extra_data.fms__bababoyi_draw == true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

-- 记录上一张牌的“花色+类别”
bababoyi:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and data and data.card
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local card = data.card

    room:setPlayerMark(player, "@fms__bababoyi", {
      suitText(card.suit),
      typeText(card),
    })

    if card.suit == Card.NoSuit then
      room:setPlayerMark(player, "fms__bababoyi_last_suit", 0)
    else
      room:setPlayerMark(player, "fms__bababoyi_last_suit", card.suit)
    end

    room:setPlayerMark(player, "fms__bababoyi_last_type", card.type)
  end,
})

bababoyi:addLoseEffect(function(self, player, isDeath)
  local room = player.room
  room:setPlayerMark(player, "fms__bababoyi_last_suit", 0)
  room:setPlayerMark(player, "fms__bababoyi_last_type", 0)
  room:setPlayerMark(player, "@fms__bababoyi", 0)
end)

return bababoyi
