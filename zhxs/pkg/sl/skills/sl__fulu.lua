local sl__fulu = fk.CreateSkill{
  name = "sl__fulu",
  tags = { Skill.Permanent, Skill.Limited },
}

Fk:loadTranslationTable{
  ["sl__fulu"] = "福禄",
  [":sl__fulu"] = "持恒技，限定技。你上场时更换至1号位，所有人体力上限+1，体力+1；你获得所有福禄娃的技能。",
  ["$sl__fulu1"] = "时空在手，兄弟齐心！",
  ["$sl__fulu2"] = "福禄永存，神器归一！",
}

local allBrotherSkills = {
  "sl__dali", "sl__daxiao",
  "sl__qianliyan", "sl__shunfenger",
  "sl__tongtou", "sl__tiebi",
  "sl__huowa", "sl__shuiwa",
  "sl__wuying", "sl__wuzong",
  "sl__baohulu",
}

-- 【新增】统一同步特殊视图标记（千里眼QML标记）
local function slSyncSpecialViewMarks(room, player)
  if not player then return end
  room:setPlayerMark(
    player,
    "@[sl__qianliyan]",
    player:hasSkill("sl__qianliyan", true, true) and 1 or 0
  )
end

sl__fulu:addEffect("active", {
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_num = 0,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = effect.from

    -- 置于1号位
    local players = table.simpleClone(room.players)
    local selfIndex
    for i, p in ipairs(players) do
      if p.id == player.id then
        selfIndex = i
        break
      end
    end
    if selfIndex then
      table.remove(players, selfIndex)
      table.insert(players, 1, player)
    end

    room.players = players
    for i = 1, #room.players do
      room.players[i].seat = i
    end
    for i = 1, #room.players - 1 do
      room.players[i].next = room.players[i + 1]
    end
    room.players[#room.players].next = room.players[1]
    room:setCurrent(room.players[1])
    room:doBroadcastNotify("ArrangeSeats", table.map(room.players, Util.IdMapper))

    -- 所有人+1上限+1体力
    for _, p in ipairs(room.alive_players) do
      room:changeMaxHp(p, 1)
      room:changeHp(p, 1)
    end

    -- 逐个获得福禄娃技能，避免整串添加失败
    for _, skill_name in ipairs(allBrotherSkills) do
      if Fk.skills[skill_name] and not player:hasSkill(skill_name, true, true) then
        room:handleAddLoseSkills(player, skill_name)
      end
    end

    -- 【新增】拿完全部技能后强制同步千里眼QML标记
    slSyncSpecialViewMarks(room, player)
  end,
})

return sl__fulu
