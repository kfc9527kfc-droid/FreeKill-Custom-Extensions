local function getShitTargets(room)
  return table.filter(room.alive_players, function(p)
    return p:getMark("@fms__shit") == 0
  end)
end

local function suitToSkippedPhase(suit)
  if suit == Card.Spade then
    return Player.Draw
  elseif suit == Card.Club then
    return Player.Play
  elseif suit == Card.Diamond then
    return Player.Judge
  elseif suit == Card.Heart then
    return Player.Discard
  end
  return 0
end

local ruce = fk.CreateSkill{
  name = "fms__ruce",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__ruce"] = "如厕",
  [":fms__ruce"] = "锁定技，当你的体力值发生变化后，你令一名角色获得“shit”标记（每名角色同时至多只能有一个）。拥有“shit”标记的角色的准备阶段进行判定：♠跳过摸牌阶段，♣跳过出牌阶段，<font color='red'>♦</font>跳过判定阶段，<font color='red'>♥</font>跳过弃牌阶段。<br>"..
  "[“你是来拉屎的吧？”]",

  ["@fms__shit"] = "shit",
  ["#fms__ruce-choose"] = "如厕：令一名角色获得“shit”标记",
}

-- 体力值变化后，令一名角色获得shit
ruce:addEffect(fk.HpChanged, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      #getShitTargets(player.room) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = getShitTargets(room)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = self.name,
      prompt = "#fms__ruce-choose",
      cancelable = false,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    if not to then return end
    player.room:setPlayerMark(to, "@fms__shit", 1)
  end,
})

-- 有shit的角色在每个准备阶段都必须判定
ruce:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player.phase == Player.Start and
      player:getMark("@fms__shit") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "fms__shit_skip_phase-turn", 0)

    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if player.dead then return end

    local phase = suitToSkippedPhase(judge.card.suit)
    if phase ~= 0 then
      room:setPlayerMark(player, "fms__shit_skip_phase-turn", phase)
    end
  end,
})

-- 到对应阶段时直接跳过
ruce:addEffect(fk.EventPhaseChanging, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return
      target == player and
      player:getMark("fms__shit_skip_phase-turn") > 0 and
      data.phase == player:getMark("fms__shit_skip_phase-turn") and
      not data.skipped
  end,
  on_refresh = function(self, event, target, player, data)
    data.skipped = true
    player.room:setPlayerMark(player, "fms__shit_skip_phase-turn", 0)
  end,
})

ruce:addLoseEffect(function(self, player, isDeath)
  local room = player.room
  room:setPlayerMark(player, "fms__shit_skip_phase-turn", 0)
  for _, p in ipairs(room.alive_players) do
    room:setPlayerMark(p, "@fms__shit", 0)
  end
end)

return ruce
