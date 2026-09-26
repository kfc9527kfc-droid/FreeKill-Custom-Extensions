local infernal_affairs_desc = [[
# 无间道模式简介

8名玩家4v4进行对战的内鬼变体竞技模式。

## 身份分发

龙虎双方每方各有主帅1人、忠臣2人、内鬼1人。其中内鬼在明面上属于敌阵营，即其会显示为
龙队队员，但实际上身份是虎队的内鬼。

主帅可以看到显示为敌方的角色的身份（也就是敌方的忠臣和我方的内鬼）。

主帅增加1点体力上限和1点体力。

## 选将与行动

双方主帅先选将并同时亮出，随后其他角色同时选将。

随机一方的主帅先行动。

当主帅被击杀后，对方阵营中由己方安插的内鬼暴露，亮出身份。
例如，龙主帅被击杀后，虎内鬼亮出，需要注意主帅被击杀并不会结束游戏。

## 奖惩

* 任何角色击杀和自己相同阵营的角色弃置所有牌。
* 当主帅被击杀后，对方阵营中的由己方安插的内鬼亮出身份牌。

## 胜利条件

击杀对方安插在我方的内鬼后获胜。

## 10人局变体规则 (新月杀村规)

每方各增加一名忠臣。

## 6人局变体规则 (新月杀村规)

直接删除1名忠臣的话内奸身份会暴露，所以6人局情况下规则需要稍作修改。

* 6人时不启用主帅身份，每方两忠一内。
* 行动顺序完全随机。
* 所有人可看到显示为自己敌方的下家的身份。

]]

local infernal_affairs_getLogic = function()
  local infernal_affairs_logic = GameLogic:subclass("infernal_affairs_logic")
  function infernal_affairs_logic:initialize(room)
    GameLogic.initialize(self, room)
    self.role_table = {
      [6] = { "loong_loyalist", "loong_renegade", "loong_loyalist",
        "tiger_loyalist", "tiger_renegade", "tiger_loyalist", },
      [8] = { "loong_loyalist", "loong_loyalist", "loong_renegade", "loong_lord",
        "tiger_loyalist", "tiger_loyalist", "tiger_renegade", "tiger_lord", },
      [10] = { "loong_loyalist", "loong_loyalist", "loong_loyalist", "loong_renegade", "loong_lord",
        "tiger_loyalist", "tiger_loyalist", "tiger_loyalist", "tiger_renegade", "tiger_lord", },
    }
  end

  --- 分配身份
  function infernal_affairs_logic:assignRoles()
    local room = self.room
    local n = #room.players
    local roles = table.simpleClone(self.role_table[n])
    room:shuffleTable(roles)
    local first = room:tableRandomPick { "loong_lord", "tiger_lord" }
    local firstIdx = table.indexOf(roles, first)
    if firstIdx ~= -1 then
      roles[1], roles[firstIdx] = roles[firstIdx], roles[1]
    else
      room:setBanner("infernal_affairs_6_players", true)
    end

    for i = 1, n do
      local p = room.players[i]
      p.role = roles[i]
      if p.role:endsWith("_lord") then
        room:setPlayerProperty(p, "role_shown", true)
      end
      room:broadcastProperty(p, "role")
    end

    for _, p in ipairs(room.players) do
      -- 内奸显示为对方阵营.
      if p.role == "tiger_renegade" then
        room:addPlayerMark(p, "@!loong_team-noclear")
      elseif p.role == "loong_renegade" then
        room:addPlayerMark(p, "@!tiger_team-noclear")
      else
        local prefix = p.role:split("_")[1]
        room:addPlayerMark(p, "@!" .. prefix .. "_team-noclear")
      end
    end
  end

  --- 进行选将
  function infernal_affairs_logic:chooseGenerals()
    local room = self.room
    local generalNum = room:getSettings('generalNum')
    local n = room:getSettings('enableDeputy') and 2 or 1

    local function getLords()
      local lords = {}
      for _, p in ipairs(room.players) do
        if p.role == "loong_lord" or p.role == "tiger_lord" then table.insertIfNeed(lords, p) end
      end
      return lords
    end
    local lords = getLords()
    if #lords > 0 then
      local lord1, lord2 = lords[1], lords[2]
      if lord1 ~= nil and lord2 ~= nil then
        room:setCurrent(lord1)
        local lords_generals = table.random(room.general_pile, #lords * generalNum)
        local req = Request:new(lords, "AskForGeneral")
        req.timeout = self.room:getSettings('generalTimeout')
        for i, p in ipairs(lords) do
          local arg = table.slice(lords_generals, (i - 1) * generalNum + 1, i * generalNum + 1)
          req:setData(p, { arg, n })
          req:setDefaultReply(p, table.random(arg, n))
        end

        for _, p in ipairs(lords) do
          local result = req:getResult(p)
          local general, deputy = result[1], result[2]
          room:prepareGeneral(p, general, deputy)
        end

        room:askToChooseKingdom(lords)

        self:broadcastGeneralForPlayer(lord1)
        self:broadcastGeneralForPlayer(lord2)
        room:broadcastProperty(lord1, "kingdom")
        room:broadcastProperty(lord2, "kingdom")

        local attachskill = function(lord)
          -- 显示技能
          local canAttachSkill = function(player, skillName)
            local skill = Fk.skills[skillName]
            if not skill then
              fk.qCritical("Skill: " .. skillName .. " doesn't exist!")
              return false
            end
            if skill:hasTag(Skill.Lord) and not (player.role == "lord" and player.role_shown and room:isGameMode("role_mode")) then
              return false
            end

            if skill:hasTag(Skill.AttachedKingdom) and not table.contains(skill:getSkeleton().attached_kingdom, player.kingdom) then
              return false
            end

            return true
          end
          local lord_skills = {}
          for _, s in ipairs(Fk.generals[lord.general].skills) do
            if canAttachSkill(lord, s.name) then
              table.insertIfNeed(lord_skills, s.name)
            end
          end
          for _, sname in ipairs(Fk.generals[lord.general].other_skills) do
            if canAttachSkill(lord, sname) then
              table.insertIfNeed(lord_skills, sname)
            end
          end

          local deputyGeneral = Fk.generals[lord.deputyGeneral]
          if deputyGeneral then
            for _, s in ipairs(deputyGeneral.skills) do
              if canAttachSkill(lord, s.name) then
                table.insertIfNeed(lord_skills, s.name)
              end
            end
            for _, sname in ipairs(deputyGeneral.other_skills) do
              if canAttachSkill(lord, sname) then
                table.insertIfNeed(lord_skills, sname)
              end
            end
          end
          for _, skill in ipairs(lord_skills) do
            room:doBroadcastNotify("AddSkill", {
              lord.id,
              skill
            })
          end
        end

        attachskill(lord1)
        attachskill(lord2)
      end
    else
      room:setCurrent(room.players[1])
    end

    local nonlord = table.filter(room.players, function(p) return not table.contains(lords, p) end)
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

  return infernal_affairs_logic
end

local infernal_affairs_mode = fk.CreateGameMode {
  name = "infernal_affairs_mode",
  minPlayer = 6,
  maxPlayer = 10,
  feasible = function(self, settings)
    return settings.playerNum % 2 == 0
  end,
  logic = infernal_affairs_getLogic,
  rule = "#infernal_affairs_rule&",
  surrender_func = function(self, playedTime)
    local roleCheck = false
    local roleText = ""

    local alive_players = table.filter(Fk:currentRoom().players, function(p)
      return not p.dead or p.rest > 0
    end)

    if Self.role == "tiger_renegade" then
      roleCheck = not table.find(alive_players, function(p)
        return p ~= Self and table.contains({ "tiger_loyalist", "tiger_lord" }, p.role)
      end)
      roleText = "虎方仅剩下你一人"
    elseif Self.role == "loong_renegade" then
      roleCheck = not table.find(alive_players, function(p)
        return p ~= Self and table.contains({ "loong_loyalist", "loong_renegade", }, p.role)
      end)
      roleText = "龙方仅剩下你一人"
    else
      roleCheck = false
    end

    return {
      { text = "time limitation: 5 min", passed = playedTime >= 300 },
      { text = roleText,                 passed = roleCheck },
    }
  end,
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end
    local winner = ""
    if victim.role == "tiger_renegade" then
      winner = "loong_loyalist+loong_renegade+loong_lord"
    elseif victim.role == "loong_renegade" then
      winner = "tiger_loyalist+tiger_renegade+tiger_lord"
    end
    return winner
  end,
  get_adjusted = function(self, player)
    local list = {}
    if player.role:endsWith("_lord") then
      list.hp = player.hp + 1
      list.maxHp = player.maxHp + 1
    end
    return list
  end,
  reward_punish = function(self, victim, killer)
    if killer and self:friendEnemyJudge(victim, killer) then
      killer:throwAllCards("he")
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
  ["infernal_affairs_mode"] = "无间道",
  [":infernal_affairs_mode"] = infernal_affairs_desc,

  ["loong_lord"] = "龙主公",
  ["loong_loyalist"] = "龙忠臣",
  ["loong_rebel"] = "龙反贼",
  ["loong_renegade"] = "龙内奸",

  ["tiger_lord"] = "虎主公",
  ["tiger_loyalist"] = "虎忠臣",
  ["tiger_rebel"] = "虎反贼",
  ["tiger_renegade"] = "虎内奸",

  ["loong_loyalist+loong_renegade+loong_lord"] = "龙方",
  ["tiger_loyalist+tiger_renegade+tiger_lord"] = "虎方",
}

return infernal_affairs_mode
