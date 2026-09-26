local sl__tiebi = fk.CreateSkill {
  name = "sl__tiebi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["sl__tiebi"] = "铁臂",
  [":sl__tiebi"] = "锁定技，你视为拥有场上的武器的效果。",
  ["$sl__tiebi1"] = "铁臂一挥，天下无敌！",
  ["$sl__tiebi2"] = "我的胳膊可有力了！",
}

sl__tiebi:addEffect("filter", {
  skill_filter = function(self, player)
    -- 使用智械的安全写法，避免递归
    if not table.contains(player:getSkillNameList(), self.name) or
       not Fk.skills[self.name]:isEffectable(player) then
      return
    end

    local skills = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      for _, card in ipairs(p:getEquipCards(Card.SubtypeWeapon)) do
        local equipSkills = card:getEquipSkills(p)
        if equipSkills then
          table.insertTableIfNeed(skills, table.map(equipSkills, function(s) return s.name end))
        end
      end
    end
    return skills
  end,
})

sl__tiebi:addEffect("atkrange", {
  virtual_weapon_func = function(self, player)
    if player:hasSkill(self.name) then  -- atkrange 里可以安全使用 hasSkill
      local n = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        for _, weapon in ipairs(p:getEquipCards(Card.SubtypeWeapon)) do
          n = math.max(n, weapon.attack_range)
        end
      end
      return n
    end
  end,
})

return sl__tiebi
