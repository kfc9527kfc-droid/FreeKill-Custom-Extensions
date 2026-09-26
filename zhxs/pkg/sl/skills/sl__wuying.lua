local sl__wuying = fk.CreateSkill{
  name = "sl__wuying",
}

Fk:loadTranslationTable{
  ["sl__wuying"] = "无影",
  [":sl__wuying"] = "准备阶段，你选择基本牌或锦囊牌，然后你无法成为此类牌的目标。",
  ["#sl__wuying-choose"] = "无影：请选择你无法成为目标的牌的类型",
  ["@sl__wuying"] = "无影：%arg",
  ["$sl__wuying1"] = "神出鬼没！",
  ["$sl__wuying2"] = "你打不到我！",
}

sl__wuying:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = { "基本牌", "锦囊牌" },
      skill_name = self.name,
      prompt = "#sl__wuying-choose",
    })
    local t = (choice == "基本牌") and "basic" or "trick"
    room:setPlayerMark(player, "sl__wuying_type", t)
    room:setPlayerMark(player, "@sl__wuying", choice)
  end,
})

sl__wuying:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if not (to and to:hasSkill(self.name) and card) then
      return false
    end

    local t = to:getMark("sl__wuying_type")
    if t == "basic" then
      return card.type == Card.TypeBasic
    elseif t == "trick" then
      return card.type == Card.TypeTrick
    end

    return false
  end,
})

return sl__wuying
