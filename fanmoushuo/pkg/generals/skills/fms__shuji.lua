local shuji = fk.CreateSkill{
  name = "fms__shuji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__shuji"] = "书记",
  [":fms__shuji"] = "锁定技，你无法成为被“卜算”的黑色牌的目标；你无法使用或打出被“卜算”的红色牌；当你成为被“卜算”的红色牌的目标时，你获得使用者一张牌。<br>"..
  "[“老师，我太想进步了”]",
  ["#fms__shuji-prey"] = "书记：获得 %src 一张牌",
}

local function getRealShujiCard(card)
  if not card then return nil end
  if card.id then
    local real = Fk:getCardById(card.id, true)
    if real then return real end
  end
  return card
end

local function isBusuanMarked(card)
  local real = getRealShujiCard(card)
  return real and real.getMark and real:getMark("@@fms__busuan_nosuit") > 0
end

local function isBusuanBlack(card)
  local real = getRealShujiCard(card)
  return real and isBusuanMarked(real) and real.color == Card.Black
end

local function isBusuanRed(card)
  local real = getRealShujiCard(card)
  return real and isBusuanMarked(real) and real.color == Card.Red
end

local function getDataFromPlayer(room, data)
  if not data or not data.from then return nil end
  if type(data.from) == "table" then
    return data.from
  end
  return room:getPlayerById(data.from)
end

shuji:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:hasSkill(self.name) and isBusuanRed(card)
  end,

  prohibit_response = function(self, player, card)
    return player:hasSkill(self.name) and isBusuanRed(card)
  end,

  is_prohibited = function(self, from, to, card)
    return to and to:hasSkill(self.name) and isBusuanBlack(card)
  end,
})

shuji:addEffect(fk.TargetConfirmed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) then
      return false
    end
    if not data or not data.card then
      return false
    end
    if not isBusuanRed(data.card) then
      return false
    end

    local from = getDataFromPlayer(player.room, data)
    return from and from ~= player and not from.dead and not from:isNude()
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = getDataFromPlayer(room, data)
    if not from or from.dead or from:isNude() then
      return
    end

    local id = room:askToChooseCard(player, {
      target = from,
      flag = "he",
      skill_name = self.name,
      prompt = "#fms__shuji-prey:" .. from.id,
    })

    if id then
      room:obtainCard(player, id, false, fk.ReasonPrey)
    end
  end,
})

return shuji
