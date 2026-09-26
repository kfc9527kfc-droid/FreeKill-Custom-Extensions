local nuyi = fk.CreateSkill {
  name = "nuyi",
  mode_skill = true,
}

Fk:loadTranslationTable {
  ["nuyi"] = "奴役",
  [":nuyi"] = "出牌阶段限一次，你可以对己方阵营的农民造成1点伤害并摸三张牌，然后场上的“起义”标记+1。",

  ["#nuyi"] = "奴役：对己方阵营的农民造成伤害然后自己摸牌",
}

nuyi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#nuyi",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(nuyi.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and ((player.role == "tiger_lord" and to_select.role == "tiger_rebel")
      or (player.role == "loong_lord" and to_select.role == "loong_rebel"))
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    room:damage{
      from = from,
      to = effect.tos[1],
      damage = 1,
      skillName = nuyi.name,
    }

    if from:isAlive() then
      from:drawCards(3, nuyi.name)
    end

    local mode = Fk.game_modes[room:getSettings('gameMode')]
    ---@diagnostic disable-next-line
    mode.addRebelMark(room, 1)
  end,
})

return nuyi

