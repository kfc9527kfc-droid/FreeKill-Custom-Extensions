local chouzhi = fk.CreateSkill{
  name = "fms__chouzhi",
}

Fk:loadTranslationTable{
  ["fms__chouzhi"] = "抽纸",
  [":fms__chouzhi"] = "每回合限一次，当一名角色的判定牌生效前，你可以获得之，然后使用牌堆底的那张牌替代之。",
  ["#fms__chouzhi-invoke"] = "抽纸：你可以获得 %dest 的判定牌，然后用牌堆底的牌替代之",
}

chouzhi:addEffect(fk.AskForRetrial, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    local room = player.room
    return player:hasSkill(chouzhi.name)
      and player:usedSkillTimes(chouzhi.name, Player.HistoryTurn) == 0
      and data.card
      and not data.card:isVirtual()
      and room:getCardArea(data.card:getEffectiveId()) == Card.Processing
      and #room.draw_pile > 0
  end,

  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__chouzhi-invoke::" .. target.id,
    })
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local old_id = data.card:getEffectiveId()
    if room:getCardArea(old_id) ~= Card.Processing then return end
    if #room.draw_pile == 0 then return end

    local bottom_id = room.draw_pile[#room.draw_pile]

  -- 先获得原判定牌
    room:obtainCard(player, old_id, true, fk.ReasonJustMove, player, chouzhi.name)

  -- 再用牌堆底的牌替代判定牌
    room:changeJudge{
      card = Fk:getCardById(bottom_id),
      player = target,
      data = data,
      skillName = chouzhi.name,
      exchange = false,
    }
  end,
})

return chouzhi
