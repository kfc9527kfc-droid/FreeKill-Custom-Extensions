local desc = [[
# 暴虐无道模式简介

此为身份模式的一种变体，未明确说明的规则按身份局处理。

## 身份分发

原文中分别用暴君、诤臣、逆乱、间者指代主公、忠臣、反贼、内奸。

* 4人：主忠反内
* 5人：主忠反反内
* 6人：主忠忠反反内

主公的身份特权改为增加2点体力上限（没有增加体力值）。

## 奖惩

主公击杀任何角色后回复1点体力。

## 胜负条件

- 主公(暴君)：所有其他角色死亡。
- 忠臣(诤臣)：所有反贼和主公都死亡。
- 反贼(逆乱)：有存活反贼的情况下，主公死亡。
- 内奸(间者)：有胜利条件满足时，若为你的回合，改为你获胜。

内奸的胜利条件说的更完整就是：

* 任何时候回合内击杀主公都可获胜
* 若只剩自己和主公，在自己回合内死亡也可获胜

## 新月杀村规

房主可以让主公再获得飞扬跋扈的加成。

]]

local function getlogic()
  local base = Fk.game_modes["aaa_role_mode"].logic()
  local logic = base:subclass("tyrannical_mode_logic")

  function logic:initialize(room)
    base.initialize(self, room)

    self.role_table[4] = { "lord", "loyalist", "rebel", "renegade" }
    self.role_table[5] = { "lord", "loyalist", "rebel", "rebel", "renegade" }
    self.role_table[6] = { "lord", "loyalist", "loyalist", "rebel", "rebel", "renegade" }
  end

  --- 进行选将
  function logic:chooseGenerals()
    local room = self.room
    local generalNum = room:getSettings('generalNum')
    local n = room:getSettings('enableDeputy') and 2 or 1
    local lord = room:getLord()
    local lord_generals = {}

    if lord ~= nil then
      room:setCurrent(lord)

      --抽专属模式主公董卓
      local generals = {}
      local dongzhuo = "ofl2__dongzhuo"
      if Fk:canUseGeneral(dongzhuo) then
        table.insertIfNeed(generals, dongzhuo)
        if table.contains(room.general_pile, dongzhuo) then table.removeOne(room.general_pile, dongzhuo) end
        table.insertTableIfNeed(generals, room:getNGenerals(generalNum - 1))
      else
        generals = room:getNGenerals(generalNum)
      end

      lord_generals = room:askToChooseGeneral(lord, { generals = generals, n = n })
      local lord_general, deputy
      if type(lord_generals) == "table" then
        deputy = lord_generals[2]
        lord_general = lord_generals[1]
      else
        lord_general = lord_generals
        lord_generals = { lord_general }
      end

      generals = table.filter(generals, function(g) return not table.contains(lord_generals, g) end)
      room:returnToGeneralPile(generals)

      room:prepareGeneral(lord, lord_general, deputy, true)

      room:askToChooseKingdom({ lord })
    end

    local nonlord = room:getOtherPlayers(lord, true)
    local generals = table.random(room.general_pile, #nonlord * generalNum)

    local req = Request:new(nonlord, "AskForGeneral")
    req.timeout = self.room:getSettings('generalTimeout')
    for i, p in ipairs(nonlord) do
      local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
      req:setData(p, { arg, n })
      req:setDefaultReply(p, table.random(arg, n))
    end

    for _, p in ipairs(nonlord) do
      local result = req:getResult(p)
      local general, deputy = result[1], result[2]
      room:prepareGeneral(p, general, deputy)
    end

    room:askToChooseKingdom(nonlord)
  end

  function logic:attachGeneralSkillsToPlayer(p)
    base.attachGeneralSkillsToPlayer(self, p)
    local room = self.room
    if p.role == "lord" and room:getSettings("TyrannicalLandlord") then
      room:handleAddLoseSkills(p, "m_feiyang|m_bahu", nil, false)
    end
  end

  return logic
end

local mode = fk.CreateGameMode {
  name = "tyrannical_mode",
  minPlayer = 4,
  maxPlayer = 6,
  logic = getlogic,
  main_mode = "role_mode",
  rule = "#tyrannical_mode_rule&",
  reward_punish = function(self, victim, killer)
    if killer and killer.role == "lord" and killer:isWounded() then
      killer.room:recover {
        who = killer,
        num = 1,
        skillName = "kill",
      }
    end
  end,
  get_adjusted = function(self, player)
    if player.role == "lord" then
      return { maxHp = player.maxHp + 2 }
    end
    return {}
  end,
  winner_getter = function(self, victim)
    local room = victim.room
    local winner = ""
    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)

    if #alive == 1 then
      -- 只剩一人存活：主公
      winner = "lord"
    elseif victim.role == "lord" then
      -- 主公死亡：若有反贼存活则反贼胜，否则忠臣胜
      if not table.find(alive, function(p) return p.role == "rebel" end) then
        winner = "loyalist"
      else
        winner = "rebel"
      end
    end

    -- 内奸补丁
    if winner ~= "" then
      local current = room.current
      if current.role == "renegade" then
        winner = "renegade"
      end
    end

    return winner
  end,
}

local W = require "ui_emu.preferences"
mode.ui_settings = {
  W.PreferenceGroup {
    title = "Game Rule",

    W.SwitchRow {
      _settingsKey = "TyrannicalLandlord",
      title = "tyrannical_landlord_rule",
    },
  },
}

Fk:loadTranslationTable {
  ["tyrannical_mode"] = "暴虐无道",
  [":tyrannical_mode"] = desc,

  ["tyrannical_landlord_rule"] = "主公增加飞扬跋扈",
  ["help: tyrannical_landlord_rule"] = "实战主公胜率极低，故添加此开关",
}

return mode
