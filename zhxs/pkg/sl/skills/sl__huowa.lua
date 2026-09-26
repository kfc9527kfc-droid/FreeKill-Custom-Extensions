local sl__huowa = fk.CreateSkill{
  name = "sl__huowa",
}

Fk:loadTranslationTable{
  ["sl__huowa"] = "火娃",
  [":sl__huowa"] = "出牌阶段限一次，你选择至多两名角色，各造成一点火焰伤害。",
  ["#sl__huowa"] = "火娃：选择至多两名其他角色，各造成1点火焰伤害",
  ["$sl__huowa1"] = "火娃在此！",
  ["$sl__huowa2"] = "烧死你们！",
}

sl__huowa:addEffect("active", {
  anim_type = "offensive",
  min_target_num = 1,
  max_target_num = 2,
  card_num = 0,
  prompt = "#sl__huowa",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function() return false end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected < 2 and to_select ~= player and not table.contains(selected, to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    for _, p in ipairs(effect.tos) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        }
      end
    end
  end,
})

return sl__huowa
