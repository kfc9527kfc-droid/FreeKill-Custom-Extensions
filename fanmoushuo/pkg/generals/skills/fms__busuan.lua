local busuan = fk.CreateSkill{
  name = "fms__busuan",
}

Fk:loadTranslationTable{
  ["fms__busuan"] = "卜算",
  [":fms__busuan"] = "结束阶段，你可以观看牌堆顶X+Y张牌，并将其中任意张牌添加“卜算”标记（X为你体力值，Y为存活人数）。<br>"..
  "[“这个命盘不错”]",
  ["#fms__busuan-invoke"] = "卜算：你可以观看牌堆顶 %arg 张牌，并将其中任意张牌添加“卜算”标记",
  ["#fms__busuan-choose"] = "卜算：选择任意张牌，为其添加“卜算”标记",
  ["@@fms__busuan_nosuit"] = "卜算",
}

busuan:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local n = player.hp + #player.room.alive_players
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__busuan-invoke:::" .. tostring(n),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player.hp + #room.alive_players
    if n <= 0 or #room.draw_pile == 0 then return end

    local ids = {}
    for i = 1, math.min(n, #room.draw_pile) do
      table.insert(ids, room.draw_pile[i])
    end

    local chosen = room:askToChooseCards(player, {
      target = player,
      min = 0,
      max = #ids,
      flag = {
        card_data = {
          { "$Top", ids }
        }
      },
      skill_name = self.name,
      prompt = "#fms__busuan-choose",
    })

    for _, id in ipairs(chosen or {}) do
      local real = Fk:getCardById(id, true)
      if real and real:getMark("@@fms__busuan_nosuit") == 0 then
        room:setCardMark(real, "@@fms__busuan_nosuit", 1)
      end
    end
  end,
})

return busuan
