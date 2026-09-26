local desc = [[
# 大忠似奸模式简介

此为身份模式的一种变体，未明确说明的规则按身份局处理。

## 身份分发

原文中分别用昏君、忠臣、义兵、奸臣指代主公、忠臣、反贼、内奸。

* 6人：主忠忠反反内
* 7人：主忠忠反反反内
* 8人：主忠忠忠反反反内

本模式反贼之间身份牌互相可见。

## 奖惩

任何人击杀反贼可以摸两张牌。

## 胜负条件

- 主公(昏君)：所有忠臣和反贼都死亡。
- 忠臣：主公存活的情况下所有反贼和内奸死亡。
- 反贼(义兵)：主公死亡。
- 内奸(奸臣)：主公存活的情况下忠臣全部死亡。反贼无需死亡。自己好像也无需存活。

这些胜利条件有时可以同时满足，比如忠臣和反贼全灭时主公与内奸同时获胜。

## 新月杀村规

针对内奸胜利条件中含混不清的地方，房主可以自己决定内奸是否必须在存活状态下取胜。

]]

local function getlogic()
  local base = Fk.game_modes["aaa_role_mode"].logic()
  local logic = base:subclass("loyal_traitor_logic")

  function logic:initialize(room)
    base.initialize(self, room)

    self.role_table[6] = { "lord", "loyalist", "loyalist", "rebel", "rebel", "renegade" }
    self.role_table[7] = { "lord", "loyalist", "loyalist", "rebel", "rebel", "rebel", "renegade" }
    self.role_table[8] = { "lord", "loyalist", "loyalist", "loyalist", "rebel", "rebel", "rebel", "renegade" }
  end

  return logic
end

local mode = fk.CreateGameMode {
  name = "loyal_traitor",
  minPlayer = 6,
  maxPlayer = 8,
  logic = getlogic,
  main_mode = "role_mode",
  rule = "#loyal_traitor_rule&",
  reward_punish = function(self, victim, killer)
    if victim.role == "rebel" and killer then
      killer:drawCards(2, "kill")
    end
  end,
  winner_getter = function(self, victim)
    local room = victim.room
    local winner = ""
    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)

    if victim.role == "lord" then
      -- 主公死亡：反贼立刻获胜
      winner = "rebel"
    else
      -- 剩余情况有点复杂 直接一个个判 毕竟加了个内奸规则开关
      local winners = {}
      local noLoyalist = not table.find(alive, function(p) return p.role == "loyalist" end)
      local noRebel = not table.find(alive, function(p) return p.role == "rebel" end)
      local noRenegade = not table.find(alive, function(p) return p.role == "renegade" end)

      -- 主公：忠臣和反贼全灭
      if noLoyalist and noRebel then table.insert(winners, "lord") end
      -- 忠臣：反贼和内奸全灭
      if noRebel and noRenegade then table.insert(winners, "loyalist") end
      -- 内奸：首先得忠臣全灭
      if noLoyalist then
        -- 然后需要避开启用内奸存活规则且内奸全灭的情况
        if not (room:getSettings("renegadeShouldAlive") and noRenegade) then
          table.insert(winners, "renegade")
        end
      end

      winner = table.concat(winners, "+")
    end

    return winner
  end,
}

local W = require "ui_emu.preferences"
mode.ui_settings = {
  W.PreferenceGroup {
    title = "Game Rule",

    W.SwitchRow {
      _settingsKey = "renegadeShouldAlive",
      title = "loyal_traitor_renegade_should_alive",
    },
  },
}

Fk:loadTranslationTable {
  ["loyal_traitor"] = "大忠似奸",
  [":loyal_traitor"] = desc,

  ["loyal_traitor_renegade_should_alive"] = "内奸需存活才能取胜",
  ["help: loyal_traitor_renegade_should_alive"] = "原版此规则存在争议，故增加此开关以让房主有村规的余地",
}

return mode
