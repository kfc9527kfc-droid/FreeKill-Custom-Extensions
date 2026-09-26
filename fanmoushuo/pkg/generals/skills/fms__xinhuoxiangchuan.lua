local fms__xinhuoxiangchuan = fk.CreateSkill{
  name = "fms__xinhuoxiangchuan",
}

Fk:loadTranslationTable{
  ["fms__xinhuoxiangchuan"] = "薪火相传",
  [":fms__xinhuoxiangchuan"] = "室长技，你死亡时，可以将所有手牌分配给任意名123宿舍的角色。",
  ["#fms__xinhuoxiangchuan-choose"] = "薪火相传：你可以将所有手牌分配给任意名123宿舍的角色",
}

-- 这里把“123宿舍”成员写成白名单
-- 你把这些武将名按你的包实际情况补全即可
local fms__dorm_123_generals = {
  ["fms__caojunkai"] = true,
  ["fms__hurongjun"] = true,
  -- ["fms__xxx"] = true,
  -- ["fms__yyy"] = true,
}

local function fms__isDorm123Player(player)
  if not player then return false end
  return fms__dorm_123_generals[player.general] or fms__dorm_123_generals[player.deputyGeneral]
end

fms__xinhuoxiangchuan:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and fms__isDorm123Player(p)
    end)
    if #targets == 0 then
      return false
    end
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__xinhuoxiangchuan-choose",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    if #cards == 0 then return end

    local targets = table.map(
      table.filter(room.alive_players, function(p)
        return p ~= player and fms__isDorm123Player(p)
      end),
      function(p) return p.id end
    )
    if #targets == 0 then return end

    -- 逐张分配手牌
    for _, id in ipairs(cards) do
      if player.dead or room:getCardArea(id) ~= Card.PlayerHand then
        break
      end

      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        skill_name = self.name,
        prompt = "#fms__xinhuoxiangchuan-choose",
        cancelable = false,
      })

      if #to > 0 then
        local toPlayer = room:getPlayerById(to[1])
        room:obtainCard(toPlayer, id, false, fk.ReasonGive)
      end
    end
  end,
})

return fms__xinhuoxiangchuan
