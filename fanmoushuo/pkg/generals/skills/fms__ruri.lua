local function appendSkippedPhase(room, player, phase)
  local record = player:getTableMark("fms__ruri_skipped")
  table.insert(record, phase)
  room:setPlayerMark(player, "fms__ruri_skipped", record)
end

local ruri = fk.CreateSkill{
  name = "fms__ruri",
}

Fk:loadTranslationTable{
  ["fms__ruri"] = "如日",
  [":fms__ruri"] = "回合开始时，你可以移去全场的“shit”，并摸等量的牌，然后你于本回合额外执行你上个回合开始至今全场被跳过的阶段。<br>"..
  "[“我！@#￥%……&*”]",

  ["#fms__ruri-invoke"] = "如日：你可以移去全场的“shit”，摸等量的牌，并额外执行记录的被跳过阶段",
}

-- 记录全场被跳过的阶段
ruri:addEffect(fk.EventPhaseChanging, {
  mute = true,
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return
      player:hasSkill(self.name, true) and
      data.skipped and
      data.phase > Player.Start and
      data.phase < Player.Finish
  end,
  on_refresh = function(self, event, target, player, data)
    appendSkippedPhase(player.room, player, data.phase)
  end,
})

-- 回合开始时：可选择清shit、摸牌、执行额外阶段
ruri:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#fms__ruri-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 移去全场shit并摸等量牌
    local n = 0
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@fms__shit") > 0 then
        n = n + 1
        room:setPlayerMark(p, "@fms__shit", 0)
      end
    end
    if n > 0 and not player.dead then
      player:drawCards(n, self.name)
    end
    if player.dead then return end

    -- 读取并清空“上个回合开始至今”记录的被跳过阶段
    local record = player:getTableMark("fms__ruri_skipped")
    room:setPlayerMark(player, "fms__ruri_skipped", 0)

    -- 依次追加额外阶段
    for _, phase in ipairs(record) do
      if player.dead then return end
      player:gainAnExtraPhase(phase)
    end
  end,
})

ruri:addLoseEffect(function(self, player, isDeath)
  local room = player.room
  room:setPlayerMark(player, "fms__ruri_skipped", 0)
end)

return ruri
