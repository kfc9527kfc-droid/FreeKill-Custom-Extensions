local desc = [[
# 失心疯模式简介

此为身份模式的一种变体，未明确说明的规则按身份局处理。

## 身份分发

原文中分别用教主、护法、官兵指代主公、忠臣、反贼。

本模式新增“失心疯”玩家。

“失心疯”的玩家无法看到自己的身份牌，只有主公能看到他的真实身份。

在身份分发阶段，除主公外随机几名角色会被标记为“失心疯”。

* 6人：主忠忠反反内，1名失心疯
* 7人：主忠忠反反反内，1名失心疯
* 8人：主忠忠反反反反内*，2名失心疯

*注：因为新月杀不支持双内故修改8人身份表，原版为3反2内。

房主也可以令房中再额外增加一名失心疯角色。

## 奖惩

任何人击杀“失心疯”后减一点体力上限，然后按身份模式继续进行奖惩。

## 新月杀村规

* 增加5人局：主忠反反内，1名失心疯
* 房主可以让场上额外增加一名失心疯，五人局除外。
* 房主可以令主公也无法看到失心疯的身份。
* 房主可以关闭击杀失心疯的惩罚。
]]

local insane_player_count = {
  [5] = 1,
  [6] = 1,
  [7] = 1,
  [8] = 2,
}

local function getlogic()
  local base = Fk.game_modes["aaa_role_mode"].logic()
  local logic = base:subclass("insanity_mode_logic")

  function logic:assignRoles()
    local room = self.room
    local n = #room.players
    self.role_table[6] = { "lord", "loyalist", "loyalist", "rebel", "rebel", "renegade" }
    local roles = table.simpleClone(self.role_table[n])
    room:shuffleTable(roles)
    room:handleAddLoseSkills(room.players[1], "#insanity_rule&")

    local nonlord

    for i = 1, n do
      local p = room.players[i]
      p.role = roles[i]
      if p.role == "lord" then
        room:setPlayerProperty(p, "role_shown", true)
        room:broadcastProperty(p, "role")
        nonlord = table.simpleClone(room.players)
        table.removeOne(nonlord, p)
      end
    end

    local insane_count = insane_player_count[n]
    if room:getSettings("moreInsane") and n > 5 then
      insane_count = insane_count + 1
    end

    local insanes = room:tableRandomPick(nonlord, insane_count)
    for _, p in ipairs(insanes) do
      room:addPlayerMark(p, "@!insane-noclear")
    end

    for _, p in ipairs(nonlord) do
      room:broadcastProperty(p, "role")
    end
  end

  return logic
end

local mode = fk.CreateGameMode {
  name = "insanity_mode",
  minPlayer = 5,
  maxPlayer = 8,
  main_mode = "role_mode",
  logic = getlogic,
  reward_punish = function(self, victim, killer)
    local room = victim.room
    local role_mode = Fk.game_modes["aaa_role_mode"]
    if victim:hasMark("@!insane-noclear") and killer and not room:getSettings("noPunish") then
      room:changeMaxHp(killer, -1)
    end
    return role_mode.deathRewardAndPunish(self, victim, killer)
  end,
}

local W = require "ui_emu.preferences"
mode.ui_settings = {
  W.PreferenceGroup {
    title = "Game Rule",

    W.SwitchRow {
      _settingsKey = "moreInsane",
      title = "insanity_mode_more_insane",
    },

    W.SwitchRow {
      _settingsKey = "lordIsInsane",
      title = "insanity_mode_lord_is_insane",
    },

  },

  W.PreferenceGroup {
    title = "",
    W.SwitchRow {
      _settingsKey = "noPunish",
      title = "insanity_mode_no_punish",
    },
  }
}


Fk:loadTranslationTable {
  ["insanity_mode"] = "失心疯",
  [":insanity_mode"] = desc,

  ["insanity_mode_more_insane"] = "额外增加一名“失心疯”",
  ["help: insanity_mode_more_insane"] = "五人局无效。",
  ["insanity_mode_lord_is_insane"] = "主公不知道“失心疯”的身份",
  ["help: insanity_mode_lord_is_insane"] = "如果主公视角也无法窥见失心疯？总之此乃瞎想的，建议不开",
  ["insanity_mode_no_punish"] = "杀死“失心疯”不减体力上限",
  ["help: insanity_mode_no_punish"] = "村规之取消Debuff，用于配合主公也看不见疯玩家",
}

return mode
