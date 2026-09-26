local desc = [[
# 各怀鬼胎模式简介

此为身份模式的一种变体，未明确说明的规则按身份局处理。

## 身份分发

* 5人：主忠恶奸逆
* 6人：主忠忠恶奸逆
* 7人：主忠忠恶奸逆逆

## 奖惩

任何人击杀“贼”摸三张牌，主公击杀忠臣弃置所有牌。

## 胜利条件

- 主公和忠臣：所有恶贼、逆贼、奸贼死亡。
- 恶贼：忠臣存活的情况下主公死亡；或所有其他角色死亡。
- 奸贼：没有忠臣存活的情况下主公死亡。
- 逆贼：在奸贼、恶贼均存活或者均死亡的情况下主公死亡。
]]

local function getlogic()
  local base = Fk.game_modes["aaa_role_mode"].logic()
  local logic = base:subclass("each_scheming_mode_logic")

  function logic:assignRoles()
    local room = self.room
    local n = #room.players
    self.role_table = {
      { "lord", "loyalist", "each_scheming_bully", "each_scheming_renegade", "each_scheming_traitor" },
      { "lord", "loyalist", "loyalist",            "each_scheming_bully",    "each_scheming_renegade", "each_scheming_traitor" },
      { "lord", "loyalist", "loyalist",            "each_scheming_bully",    "each_scheming_renegade", "each_scheming_traitor", "each_scheming_traitor" },
    }
    local roles = table.simpleClone(self.role_table[n - 4])
    room:shuffleTable(roles)

    for i = 1, n do
      local p = room.players[i]
      p.role = roles[i]
      if p.role == "lord" then
        room:setPlayerProperty(p, "role_shown", true)
      end
      room:broadcastProperty(p, "role")
    end
  end

  return logic
end

local mode = fk.CreateGameMode {
  name = "each_scheming",
  minPlayer = 5,
  maxPlayer = 7,
  logic = getlogic,
  main_mode = "role_mode",
  reward_punish = function(self, victim, killer)
    local room = victim.room
    if not killer or killer.dead then return end
    if string.startsWith(victim.role, "each_scheming") then
      killer:drawCards(3, "kill")
    elseif victim.role == "loyalist" and killer.role == "lord" then
      killer:throwAllCards("he")
    end
  end,
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end

    local room = victim.room
    local winner = ""
    local all_winner = ""
    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)

    if victim.role == "lord" then
      if table.find(alive, function(p) return p.role == "loyalist" end)
          or (#alive == 1 and alive[1].role == "renegade") then
        winner = "each_scheming_bully"
        all_winner = winner .. "+" .. all_winner
      end
      if not table.find(alive, function(p) return p.role == "loyalist" end) then
        winner = "each_scheming_renegade"
        all_winner = winner .. "+" .. all_winner
      end
      if (not table.find(alive, function(p)
            return p.role == "each_scheming_bully" or p.role == "each_scheming_renegade"
          end)) or (table.find(alive, function(p) return p.role == "each_scheming_bully" end)
            and table.find(alive, function(p) return p.role == "each_scheming_renegade" end)) then
        winner = "each_scheming_traitor"
        all_winner = winner .. "+" .. all_winner
      end
    elseif victim.role ~= "loyalist" then
      local lord_win = true
      for _, p in ipairs(alive) do
        if p.role == "each_scheming_bully" or p.role == "each_scheming_renegade" or p.role == "each_scheming_traitor" then
          lord_win = false
          break
        end
      end
      if lord_win then
        winner = "lord+loyalist"
        all_winner = winner .. "+" .. all_winner
      end
    end
    return all_winner
  end,
  friend_enemy_judge = function(self, targetOne, targetTwo)
    if targetOne.role == targetTwo.role then return true end
    if table.contains({ "lord", "loyalist" }, targetOne.role) and
        table.contains({ "lord", "loyalist" }, targetTwo.role) then
      return true
    else
      return false
    end
  end,
  surrender_func = function(self, playedTime)
    local roleCheck = false
    local roleText = ""

    local alive_players = table.filter(Fk:currentRoom().players, function(p)
      return not p.dead or p.rest > 0
    end)

    if Self.role == "lord" then
      roleCheck = not table.find(alive_players, function(p)
        return p ~= Self and table.contains({ "loyalist" }, p.role)
      end)
      roleText = "所有忠臣已死亡"
    elseif Self.role == "each_scheming_bully" then
      roleCheck = not table.find(alive_players, function(p)
        return p ~= Self and table.contains({ "each_scheming_renegade", "each_scheming_traitor" }, p.role)
      end)
      roleText = "奸贼，逆贼已全部阵亡"
    elseif Self.role == "each_scheming_renegade" then
      roleCheck = not table.find(alive_players, function(p)
        return p ~= Self and table.contains({ "each_scheming_bully", "each_scheming_traitor" }, p.role)
      end)
      roleText = "恶贼，逆贼已全部阵亡"
    elseif Self.role == "each_scheming_traitor" then
      roleCheck = not table.find(alive_players, function(p)
        return p ~= Self and
            table.contains({ "each_scheming_bully", "each_scheming_traitor", "each_scheming_renegade" }, p.role)
      end)
      roleText = "恶贼，奸贼已阵亡，逆贼仅一人存活"
    else
      roleCheck = false
    end

    return {
      { text = "time limitation: 5 min", passed = playedTime >= 300 },
      { text = roleText,                 passed = roleCheck },
    }
  end,
}

Fk:loadTranslationTable {
  ["each_scheming"] = "各怀鬼胎",
  [":each_scheming"] = desc,

  ["each_scheming_bully"] = "恶贼",
  ["each_scheming_renegade"] = "奸贼",
  ["each_scheming_traitor"] = "逆贼"
}

return mode
