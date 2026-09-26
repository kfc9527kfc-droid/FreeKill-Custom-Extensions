local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

Fk:loadTranslationTable{
  ["#fms__diamond_absorb-choose"] = "吸收：选择对 %dest 使用的 %arg 的副目标",
}

local function cleanupAbsorbMark(room, player)
  local pile = player:getPile("fms__diamond_absorb")
  if #pile == 0 then
    room:setPlayerMark(player, "fms__diamond_absorb_record", 0)
    return
  end

  local mark = player:getTableMark("fms__diamond_absorb_record")
  local keep = {}
  for _, rec in ipairs(mark) do
    if #rec == 2 and table.contains(pile, rec[1]) then
      table.insert(keep, rec)
    end
  end
  room:setPlayerMark(player, "fms__diamond_absorb_record", #keep > 0 and keep or 0)
end

local skill = fk.CreateSkill{
  name = "fms__diamond_absorb",
  tags = { Skill.Compulsory },
  derived_piles = "fms__diamond_absorb",
}

skill:addEffect(fk.TargetConfirming, {
  can_trigger = function(self, event, target, player, data)
    return
      player == target and player:hasSkill(self.name) and
      player.room.current ~= player and
      data and data.card and common.isDamageCard(data.card) and
      not (data.extra_data and data.extra_data.useByDiamondAbsorb) and
      #Card:getIdList(data.card) == 1 and
      Fk:getCardById(Card:getIdList(data.card)[1], true).name == data.card.name and
      data:isOnlyTarget(player) and
      not data.cancelled
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:cancelCurrentTarget()
    if room:getCardArea(data.card) ~= Card.Processing then
      return false
    end

    player:addToPile("fms__diamond_absorb", data.card, true, self.name)
    if table.contains(player:getPile("fms__diamond_absorb"), data.card.id) then
      room:addTableMark(player, "fms__diamond_absorb_record", { data.card.id, data.from.id })
    end
  end,
})

skill:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return
      player == target and player:hasSkill(self.name) and
      player.phase == Player.Start and
      #player:getPile("fms__diamond_absorb") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("fms__diamond_absorb_record")

    while #player:getPile("fms__diamond_absorb") > 0 do
      local id = player:getPile("fms__diamond_absorb")[1]
      local remove_it = true
      local card = Fk:getCardById(id)

      local pid = nil
      for _, rec in ipairs(mark) do
        if #rec == 2 and rec[1] == id then
          pid = rec[2]
          break
        end
      end

      if pid ~= nil then
        local from = room:getPlayerById(pid)
        if from and from:isAlive() then
          if not from:prohibitUse(card) and not from:isProhibited(player, card) and
            card.skill:modTargetFilter(from, player, {}, card, { bypass_distances = true }) then
            local tos = { player }

            if card.skill:getMinTargetNum(from) == 2 then
              local targets = table.filter(room.alive_players, function(p)
                return p ~= player and card.skill:targetFilter(from, p, { player }, {}, card)
              end)
              if #targets > 0 then
                local chosen = room:askToChoosePlayers(from, {
                  targets = targets,
                  min_num = 1,
                  max_num = 1,
                  prompt = "#fms__diamond_absorb-choose::" .. player.id .. ":" .. card:toLogString(),
                  skill_name = self.name,
                  cancelable = false,
                })
                if #chosen > 0 then
                  table.insertTable(tos, chosen)
                end
              end
            end

            if #tos >= card.skill:getMinTargetNum(from) then
              remove_it = false
              room:useCard{
                from = from,
                tos = tos,
                card = card,
                extra_data = { useByDiamondAbsorb = true },
                extraUse = true,
              }
            end
          end
        end
      end

      if remove_it then
        room:moveCards({
          from = player,
          ids = { id },
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = self.name,
        })
      end
    end
  end,
})

skill:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name, true) and type(player:getMark("fms__diamond_absorb_record")) == "table"
  end,
  on_refresh = function(self, event, target, player, data)
    cleanupAbsorbMark(player.room, player)
  end,
})

return skill
