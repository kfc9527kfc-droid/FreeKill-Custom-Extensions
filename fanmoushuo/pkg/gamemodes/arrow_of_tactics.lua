local desc = [[
# 锋矢奇谋模式简介

一种4v4变体模式。

## 身份分发

龙虎两队，每队各有大将、中坚、前锋、诱饵各1人（游戏内分别显示为主忠反内）。

只有双方阵营的前锋亮出身份。

前锋增加1点体力上限和体力。

## 选将与行动

所有人同时选将，随机一队的前锋首先行动。

## 奖惩

前锋死亡后，本阵营大将亮出身份。

诱饵被敌方阵营击杀后，敌方阵营大将亮出身份并弃置所有牌。

## 胜利条件

击杀敌方大将获胜。
]]

local getlogic = function()
  local logic = GameLogic:subclass("arrow_of_tactics_logic")
  function logic:initialize(room)
    GameLogic.initialize(self, room)
    self.role_table = {
      { "loong_loyalist", "loong_rebel", "loong_renegade", "loong_lord",
        "tiger_loyalist", "tiger_rebel", "tiger_renegade", "tiger_lord", },
    }
  end

  --- 分配身份
  function logic:assignRoles()
    local room = self.room
    local roles = self.role_table[1]
    room:shuffleTable(roles)
    local first = room:tableRandomPick { "loong_rebel", "tiger_rebel" }
    local firstIdx = table.indexOf(roles, first)
    roles[1], roles[firstIdx] = roles[firstIdx], roles[1]

    for i = 1, 8 do
      local p = room.players[i]
      p.role = roles[i]
      if p.role:endsWith("_rebel") then
        room:setPlayerProperty(p, "role_shown", true)
      end
      room:broadcastProperty(p, "role")
    end

    for _, p in ipairs(room.players) do
      local prefix = p.role:split("_")[1]
      room:addPlayerMark(p, "@!" .. prefix .. "_team-noclear")
    end
  end

  --- 进行选将
  function logic:chooseGenerals()
    local room = self.room
    local generalNum = room:getSettings('generalNum')
    local n = room:getSettings('enableDeputy') and 2 or 1

    local nonlord = table.simpleClone(room.players)
    room:setCurrent(nonlord[1])
    local generals = room:tableRandomPick(room.general_pile, #nonlord * generalNum)

    local req = Request:new(nonlord, "AskForGeneral")
    req.timeout = self.room:getSettings('generalTimeout')
    for i, p in ipairs(nonlord) do
      local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
      req:setData(p, { arg, n })
      req:setDefaultReply(p, room:tableRandomPick(arg, n))
    end

    for _, p in ipairs(nonlord) do
      local result = req:getResult(p)
      local general, deputy = result[1], result[2]
      room:prepareGeneral(p, general, deputy)
    end

    room:askToChooseKingdom(nonlord)
  end

  return logic
end

local mode = fk.CreateGameMode {
  name = "arrow_of_tactics",
  minPlayer = 8,
  maxPlayer = 8,
  logic = getlogic,
  rule = "#arrow_of_tactics_rule&",
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end
    local winner = ""
    if victim.role == "tiger_lord" then
      winner = "loong_loyalist+loong_renegade+loong_rebel+loong_lord"
    elseif victim.role == "loong_lord" then
      winner = "tiger_loyalist+tiger_renegade+tiger_rebel+tiger_lord"
    end
    return winner
  end,
  get_adjusted = function(self, player)
    local list = {}
    if player.role:endsWith("_rebel") then
      list.hp = player.hp + 1
      list.maxHp = player.maxHp + 1
    end
    return list
  end,
  reward_punish = function(self, victim, killer)
    -- 内被击杀后，主丢掉所有牌
    -- 亮出身份在Rule中 因为奖惩可能被跳过
    if victim.role:endsWith("_renegade") and killer and not self:friendEnemyJudge(victim, killer) then
      local prefix = killer.role:split("_")[1]
      local room = victim.room
      local lord = table.find(room.alive_players, function(p)
        return p.role == prefix .. "_lord"
      end)
      if lord then
        lord:throwAllCards("he")
      end
    end
  end,
  friend_enemy_judge = function(self, targetOne, targetTwo)
    if targetOne == targetTwo then return true end
    if targetOne.role:startsWith("loong") and targetTwo.role:startsWith("loong") then return true end
    if targetOne.role:startsWith("tiger") and targetTwo.role:startsWith("tiger") then return true end
    return false
  end
}

Fk:loadTranslationTable {
  ["arrow_of_tactics"] = "锋矢奇谋",
  [":arrow_of_tactics"] = desc,
}

return mode
