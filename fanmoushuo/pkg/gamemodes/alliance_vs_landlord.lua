local desc = [[
# 合纵斗地主模式简介

由4人进行的游戏模式。

## 身份分发

龙虎两队，每队各有1地主和1农民。

农民增加1点体力上限和体力。

## 选将与行动

地主同时选将并亮出，随后农民选将。

座位固定为龙地主-虎地主-虎农民-龙农民。

## 起义事件

地主拥有技能〖奴役〗：出牌阶段限一次，你可以对己方阵营的农民造成1点伤害并摸三张牌。

每轮开始时，场上增加1枚“起义”标记，〖奴役〗发动后也增加1枚“起义”标记。
当“起义”达到7枚时，触发起义事件，此时两个农民脱离原阵营，
结成新阵营。

起义后的农民还获得〖啸聚〗：锁定技，你对原先阵营的地主造成的伤害+1。

## 奖惩

农民死亡后，与其同阵营的角色可以选择摸两张牌或回复1点体力。

## 胜利条件

击杀所有敌对阵营后获胜。

具体而言，起义之前，地主和农民是一队，击杀所有敌队；
起义之后，两个地主各自为战，两个农民结成一队，此时场上有3个阵营，
地主需要击杀所有其他角色，农民击杀所有地主即可获胜。

## 新月杀村规

房主可以自定义触发“起义”事件所需的标记数量。

]]

local getlogic = function()
  local logic = GameLogic:subclass("alliance_vs_landlord_logic")
  function logic:initialize(room)
    GameLogic.initialize(self, room)
    self.role_table = {
      { "loong_lord", "tiger_lord", "tiger_rebel", "loong_rebel" }
    }
  end

  --- 分配身份
  function logic:assignRoles()
    local room = self.room
    local roles = self.role_table[1]

    for i = 1, 4 do
      local p = room.players[i]
      p.role = roles[i]
      room:setPlayerProperty(p, "role_shown", true)
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

    local function getLords()
      local lords = {}
      for _, p in ipairs(room.players) do
        if p.role == "loong_lord" or p.role == "tiger_lord" then table.insertIfNeed(lords, p) end
      end
      return lords
    end
    local lords = getLords()
    if lords ~= {} then
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
  end

  function logic:attachGeneralSkillsToPlayer(p)
    GameLogic.attachGeneralSkillsToPlayer(self, p)
    if p.role:endsWith("_lord") then
      self.room:handleAddLoseSkills(p, "nuyi")
    end
  end

  return logic
end

local mode = fk.CreateGameMode {
  name = "alliance_vs_landlord",
  minPlayer = 4,
  maxPlayer = 4,
  logic = getlogic,
  rule = "#alliance_vs_landlord_rule&",
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end

    local room = victim.room
    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)

    local winner = ""
    local prefixes = table.map(alive, function(p) return p.role:split("_")[1] end)
    if table.every(prefixes, function(s) return s == prefixes[1] end) then
      local p = prefixes[1]
      if p == "loong" then
        winner = "loong_lord+loong_rebel"
      elseif p == "tiger" then
        winner = "tiger_lord+tiger_rebel"
      elseif p == "rebel" then
        winner = "rebel"
      end
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
    local room = victim.room
    if not victim.role:endsWith("rebel") then return end
    for _, p in ipairs(room:getOtherPlayers(victim)) do
      if p:isFriend(victim) then
        local choices = {"draw2", "Cancel"}
        if p:isWounded() then
          table.insert(choices, 2, "recover")
        end
        local choice = room:askToChoice(p, {
          choices = choices,
          skill_name = "PickLegacy",
        })
        if choice == "draw2" then
          p:drawCards(2, "game_rule")
        elseif choice == "recover" then
          room:recover{
            who = p,
            num = 1,
            recoverBy = p,
            skillName = "game_rule",
          }
        end
      end
    end
  end,
  friend_enemy_judge = function(self, targetOne, targetTwo)
    if targetOne == targetTwo then return true end
    if targetOne.role:startsWith("loong") and targetTwo.role:startsWith("loong") then return true end
    if targetOne.role:startsWith("tiger") and targetTwo.role:startsWith("tiger") then return true end
    return targetOne.role == targetTwo.role
  end
}

---@param room Room
---@diagnostic disable-next-line
mode.addRebelMark = function(room, count)
  local mark = room:getBanner("@rebellion") or 0
  local n = room:getSettings("rebelGoal") or 7
  if mark >= n then return end

  mark = mark + count
  room:setBanner("@rebellion", mark)
  if mark >= n then
    for _, p in ipairs(room.players) do
      if p.role:endsWith("_rebel") then
        room:setPlayerProperty(p, "role", "rebel")
        room:handleAddLoseSkills(p, "xiaoju")
      end
    end
  end
end

local W = require "ui_emu.preferences"
mode.ui_settings = {
  W.PreferenceGroup {
    title = "Game Rule",

    W.SpinRow {
      _settingsKey = "rebelGoal",
      title = "alliance_vs_landlord_rebel_goal",
      from = 3,
      to = 9,
    },
  },
}

Fk:loadTranslationTable {
  ["alliance_vs_landlord"] = "合纵斗地主",
  [":alliance_vs_landlord"] = desc,

  ["@rebellion"] = "起义",

  ["alliance_vs_landlord_rebel_goal"] = "自定义起义事件标记",
  ["help: alliance_vs_landlord_rebel_goal"] = "请根据自己将池的游戏节奏酌情调整。",
}

return mode
