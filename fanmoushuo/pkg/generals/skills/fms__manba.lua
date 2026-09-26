local function countHeCards(player)
  return #player:getCardIds("he")
end

local function getProduct(ids)
  local prod = 1
  for _, id in ipairs(ids) do
    local n = Fk:getCardById(id).number
    if not n or n <= 0 then
      return 0
    end
    prod = prod * n
  end
  return prod
end

local fms__manba = fk.CreateSkill{
  name = "fms__manba",
}

Fk:loadTranslationTable{
  ["fms__manba"] = "曼巴",
  [":fms__manba"] = "出牌阶段限一次，你可以弃置至少两张牌，回复1点体力；若这些牌点数的乘积为24，你加1点体力上限并回复1点体力。<br>"..
  "[“What can I say”]",
  ["#fms__manba"] = "曼巴：你可以弃置至少两张牌，回复1点体力；若这些牌点数的乘积为24，你加1点体力上限并回复1点体力",
}

fms__manba:addEffect("active", {
  anim_type = "support",
  prompt = "#fms__manba",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return
      player:usedSkillTimes(fms__manba.name, Player.HistoryPhase) == 0 and
      countHeCards(player) >= 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = room:askToCards(player, {
      min_num = 2,
      max_num = 999,
      include_equip = true,
      prompt = "#fms__manba",
      skill_name = fms__manba.name,
      cancelable = true,
    })

    if #cards < 2 then return end

    local prod = getProduct(cards)
    room:throwCard(cards, fms__manba.name, player, player)

    if player.dead then return end

    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = fms__manba.name,
    }

    if player.dead then return end

    if prod == 24 then
      room:changeMaxHp(player, 1)
      if player.dead then return end

      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = fms__manba.name,
      }
    end
  end,
})

return fms__manba
