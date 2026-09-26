local sl__wuzong = fk.CreateSkill{
  name = "sl__wuzong",
}

Fk:loadTranslationTable{
  ["sl__wuzong"] = "无踪",
  [":sl__wuzong"] = "准备阶段，你选择红色牌或黑色牌，然后你无法成为此类牌的目标。",
  ["#sl__wuzong-choose"] = "无踪：请选择你无法成为目标的牌的颜色",
  ["@sl__wuzong"] = "无踪：%arg",
  ["$sl__wuzong1"] = "神出鬼没！",
  ["$sl__wuzong2"] = "你打不到我！",
}

sl__wuzong:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = { "红色牌", "黑色牌" },
      skill_name = self.name,
      prompt = "#sl__wuzong-choose",
    })
    local c = (choice == "红色牌") and "red" or "black"
    room:setPlayerMark(player, "sl__wuzong_color", c)
    room:setPlayerMark(player, "@sl__wuzong", choice)
  end,
})

sl__wuzong:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if not (to and to:hasSkill(self.name) and card) then
      return false
    end

    local c = to:getMark("sl__wuzong_color")
    if c == "red" then
      return card.color == Card.Red
    elseif c == "black" then
      return card.color == Card.Black
    end

    return false
  end,
})

return sl__wuzong
