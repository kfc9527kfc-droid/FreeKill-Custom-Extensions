local sl__daxiao = fk.CreateSkill {
  name = "sl__daxiao",
  tags = { Skill.Switch, Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["sl__daxiao"] = "大小",
  [":sl__daxiao"] = "转换技，锁定技，阳：你造成的伤害+1；阴：你受到的伤害-1。",
  [":sl__daxiao_yang"] = "转换技，锁定技，" ..
    "<font color=\"#E0DB2F\">阳：你造成的伤害+1；</font>" ..
    "<font color=\"gray\">阴：你受到的伤害-1。</font>",
  [":sl__daxiao_yin"] = "转换技，锁定技，" ..
    "<font color=\"gray\">阳：你造成的伤害+1；</font>" ..
    "<font color=\"#E0DB2F\">阴：你受到的伤害-1。</font>",
  ["$sl__daxiao1"] = "大！",
  ["$sl__daxiao2"] = "小！",
}

-- 阳：造成的伤害+1，触发后自动切换为阴（静音）
sl__daxiao:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sl__daxiao.name) and
      player:getSwitchSkillState(sl__daxiao.name, false) == fk.SwitchYang
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeDamage(1)
    room:switchSkillState(player, self.name, true)  -- mute = true，屏蔽提示框
  end,
})

-- 阴：受到的伤害-1（参考“远程减伤”），触发后自动切换为阳（静音）
sl__daxiao:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sl__daxiao.name) and
      player:getSwitchSkillState(sl__daxiao.name, false) == fk.SwitchYin and
      data and data.damage > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.changeDamage then
      data:changeDamage(-1)
    else
      data.damage = math.max(0, data.damage - 1)
    end
    room:switchSkillState(player, self.name, true)  -- mute = true，屏蔽提示框
  end,
})

return sl__daxiao
