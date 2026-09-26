local sl__fuluwa = fk.CreateSkill{
  name = "sl__fuluwa",
  tags = { Skill.Permanent, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sl__fuluwa"] = "福禄娃",
  [":sl__fuluwa"] = "持恒技，共鸣技。游戏开始时，召唤“大娃”作为你的下家；福禄娃阵亡后，其弟弟代替之出场；你受到的伤害转移给福禄娃。",
  ["$sl__fuluwa1"] = "葫芦娃，出来吧！",
  ["$sl__fuluwa2"] = "兄弟们，保护我！",
}

local brothers = {
  "sl__dawa",
  "sl__erwa",
  "sl__sanwa",
  "sl__siwawa",
  "sl__liuwa",
  "sl__qiwa",
  "sl__fuluxiaojingang",
}

-- 统一强制设置每个葫芦娃的固定体力/上限（按init.lua定义）
local function slSetFixedHuluState(room, player, generalName)
  local cfg = {
    sl__dawa = { hp = 3, maxHp = 7 },
    sl__erwa = { hp = 2, maxHp = 2 },
    sl__sanwa = { hp = 1, maxHp = 3 },
    sl__siwawa = { hp = 4, maxHp = 5 },
    sl__liuwa = { hp = 2, maxHp = 6 },
    sl__qiwa = { hp = 1, maxHp = 7 },
    sl__fuluxiaojingang = { hp = 7, maxHp = 7 },
  }

  local data = cfg[generalName]
  if not data then return end

  -- 先修正体力上限
  if player.maxHp ~= data.maxHp then
    room:changeMaxHp(player, data.maxHp - player.maxHp)
  end

  -- 再修正当前体力
  if player.hp > data.hp then
    room:loseHp(player, player.hp - data.hp, "sl__fuluwa", player)
  elseif player.hp < data.hp then
    room:recover{
      who = player,
      num = data.hp - player.hp,
      recoverBy = player,
      skillName = "sl__fuluwa",
    }
  end
end

-- 【新增】统一同步特殊视图标记（千里眼QML标记）
local function slSyncSpecialViewMarks(room, player)
  if not player then return end
  room:setPlayerMark(
    player,
    "@[sl__qianliyan]",
    player:hasSkill("sl__qianliyan", true, true) and 1 or 0
  )
end

sl__fuluwa:addEffect(fk.GameStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
      and (player.general == "sl__huluye" or player.deputyGeneral == "sl__huluye")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "sl__fuluwa_index", 1)

    local summoned = room:summonPlayer(player, player.next, { general = brothers[1] })
    if summoned then
      room:setPlayerMark(player, "sl__fuluwa_current", summoned.id)
      slSyncSpecialViewMarks(room, summoned)  -- 【新增】召唤后立即同步
    end
  end,
})

-- 当前福禄娃死亡后，原地变为下一位弟弟
sl__fuluwa:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    if not (
      player:hasSkill(self.name)
      and (player.general == "sl__huluye" or player.deputyGeneral == "sl__huluye")
    ) then
      return false
    end

    local current_id = player:getMark("sl__fuluwa_current")
    return current_id and current_id ~= 0 and data.who and data.who.id == current_id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local current = data.who
    if not current then return end

    local index = player:getMark("sl__fuluwa_index")
    if not index or index == 0 then
      index = 1
    end

    local next_index = index + 1
    if next_index > #brothers then
      room:setPlayerMark(player, "sl__fuluwa_current", 0)
      return
    end

    room:setPlayerMark(player, "sl__fuluwa_index", next_index)

    -- 复活原角色并原地换将
    room:revivePlayer(current, false)
    room:changeHero(current, brothers[next_index], true, false, true, false)

    -- 关键修复：切换成功后立即强制矫正体力/上限
    slSetFixedHuluState(room, current, brothers[next_index])

    -- 【新增】换将后立即同步千里眼标记
    slSyncSpecialViewMarks(room, current)

    room:setPlayerMark(player, "sl__fuluwa_current", current.id)
  end,
})

-- 你受到的伤害转移给当前福禄娃
sl__fuluwa:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    if not (
      player:hasSkill(self.name)
      and (player.general == "sl__huluye" or player.deputyGeneral == "sl__huluye")
    ) then
      return false
    end

    local current_id = player:getMark("sl__fuluwa_current")
    if not current_id or current_id == 0 then return false end

    local brother = player.room:getPlayerById(current_id)
    return brother and not brother.dead and data.to == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local current_id = player:getMark("sl__fuluwa_current")
    local brother = room:getPlayerById(current_id)
    if brother and not brother.dead then
      data.to = brother
    end
  end,
})

return sl__fuluwa
