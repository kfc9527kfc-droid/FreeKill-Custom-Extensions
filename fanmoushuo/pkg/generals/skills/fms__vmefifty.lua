local fms__vmefifty = fk.CreateSkill{
  name = "fms__vmefifty",
  max_phase_use_time = 1,
}

Fk:loadTranslationTable{
  ["fms__vmefifty"] = "V我50",
  [":fms__vmefifty"] = "出牌阶段限一次，你可以展示手牌，令所有角色选择是否正面朝上交给你一张牌，然后若你手牌点数之和不小于50，视为对你与交给牌的角色使用【五谷丰登】。",
  ["#fms__vmefifty"] = "V我50：你可以展示手牌，令所有角色选择是否交给你一张牌",
  ["#FmsV50Log"] = "%from 的手牌点数和为 %arg",
  ["#fms__vmefifty-give"] = "V我50：%src 的手牌点数和为 %arg，你可以交给其一张牌",
}

fms__vmefifty:addEffect("active", {
  prompt = "#fms__vmefifty",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  times = function(self, player)
    return 1 - player:usedSkillTimes(fms__vmefifty.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(fms__vmefifty.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    room:delay(800)

    local function sumNum()
      local n = 0
      for _, id in ipairs(player:getCardIds("h")) do
        n = n + Fk:getCardById(id).number
      end
      return n
    end

    room:sendLog{
      type = "#FmsV50Log",
      from = player.id,
      arg = sumNum(),
      toast = true,
    }

    local targets = { player }

    for _, to in ipairs(room:getOtherPlayers(player)) do
      if player.dead then break end
      if not to.dead and not to:isNude() then
        local cards = room:askToCards(to, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          cancelable = true,
          skill_name = fms__vmefifty.name,
          prompt = "#fms__vmefifty-give:" .. player.id .. "::" .. sumNum(),
        })
        if #cards > 0 then
          room:obtainCard(player, cards, true, fk.ReasonGive, to, fms__vmefifty.name)
          table.insert(targets, to)
        end
      end
    end

    if not player.dead and sumNum() >= 50 then
      local card = Fk:cloneCard("amazing_grace")
      card.skillName = fms__vmefifty.name
      if player:prohibitUse(card) then return end

      targets = table.filter(targets, function(p)
        return not p.dead and not player:isProhibited(p, card)
      end)

      if #targets > 0 then
        room:useCard{
          from = player,
          tos = targets,
          card = card,
        }
      end
    end
  end,
})

return fms__vmefifty
