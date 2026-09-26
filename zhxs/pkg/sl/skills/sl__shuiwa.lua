local sl__shuiwa = fk.CreateSkill{
  name = "sl__shuiwa",
}

Fk:loadTranslationTable{
  ["sl__shuiwa"] = "水娃",
  [":sl__shuiwa"] = "出牌阶段限一次，你选择至多两名角色，各弃置其两张牌。",
  ["#sl__shuiwa"] = "水娃：选择至多两名其他角色，各弃置其两张牌",
  ["#sl__shuiwa-discard"] = "水娃：弃置 %dest 两张牌",
  ["$sl__shuiwa1"] = "水娃在此！",
  ["$sl__shuiwa2"] = "淹死你们！",
}

sl__shuiwa:addEffect("active", {
  anim_type = "control",
  min_target_num = 1,
  max_target_num = 2,
  card_num = 0,
  prompt = "#sl__shuiwa",
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
      if not p.dead and not p:isNude() then
        local cards = room:askToChooseCards(player, {
          target = p,
          flag = "he",
          skill_name = self.name,
          min = 1,
          max = 2,
          prompt = "#sl__shuiwa-discard::" .. p.id,
        })
        if #cards > 0 then
          room:throwCard(cards, self.name, p, player)
        end
      end
    end
  end,
})

return sl__shuiwa
