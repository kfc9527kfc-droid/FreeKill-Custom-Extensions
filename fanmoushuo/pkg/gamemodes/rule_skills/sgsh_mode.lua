local rule = fk.CreateSkill {
  name = "#sgsh_mode&",
}

Fk:loadTranslationTable{
  ["#sgsh_mode&"] = "幻化",
  ["@&sgsh_deputy"] = "副将",
  ["#sgsh-deputy"] = "是否要获得副将？",
}

local U = require "packages.offline_new.ofl_util"

rule:addEffect(fk.Damaged, {
  priority = 0.001,
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead
  end,
  on_trigger = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = rule.name,
      prompt = "#sgsh-deputy",
    }) then
      U.sgshAcquireDeputy(player)
    end
  end,
})

rule:addEffect(fk.Death, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    table.insertIfNeed(room.general_pile, player.general)
    table.insertTableIfNeed(room.general_pile, player:getTableMark("@&sgsh_deputy"))
  end,
})

return rule
