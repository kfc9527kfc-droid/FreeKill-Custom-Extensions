local sl__jiushu = fk.CreateSkill{
  name = "sl__jiushu",
  tags = { Skill.Permanent, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sl__jiushu"] = "救赎",
  [":sl__jiushu"] = "持恒技。你在你的第一个回合结束后阵亡；然后“葫芦爷”失去“人质”技能。",
  ["$sl__jiushu1"] = "兄弟们，我来救赎！",
  ["$sl__jiushu2"] = "时空轮回，福禄永存！",
}

sl__jiushu:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(self.name)
      and player:getMark("sl__jiushu_firstturn") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "sl__jiushu_firstturn", 1)

    local huluye = table.find(room.players, function(p)
      return (p.general == "sl__huluye" or p.deputyGeneral == "sl__huluye") and not p.dead
    end)

    -- 第一个回合结束后阵亡
    if not player.dead then
      room:killPlayer(player)
    end

    -- 然后“葫芦爷”失去“人质”
    if huluye and not huluye.dead then
      room:handleAddLoseSkills(huluye, "-sl__renzhi")
    end
  end,
})

return sl__jiushu
