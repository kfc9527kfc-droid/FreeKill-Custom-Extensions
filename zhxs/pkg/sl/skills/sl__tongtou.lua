local sl__tongtou = fk.CreateSkill {
  name = "sl__tongtou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["sl__tongtou"] = "铜头",
  [":sl__tongtou"] = "锁定技，你视为拥有场上的防具的效果。",
  ["$sl__tongtou1"] = "铜头铁臂，刀枪不入！",
  ["$sl__tongtou2"] = "我的头可硬了！",
}

sl__tongtou:addEffect("filter", {
  skill_filter = function(self, player)
    -- 使用智械的安全写法，避免递归
    if not table.contains(player:getSkillNameList(), self.name) or
       not Fk.skills[self.name]:isEffectable(player) then
      return
    end

    local skills = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      for _, card in ipairs(p:getEquipCards(Card.SubtypeArmor)) do
        local equipSkills = card:getEquipSkills(p)
        if equipSkills then
          table.insertTableIfNeed(skills, table.map(equipSkills, function(s) return s.name end))
        end
      end
    end
    return skills
  end,
})

return sl__tongtou
