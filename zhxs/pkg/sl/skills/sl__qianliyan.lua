local sl__qianliyan = fk.CreateSkill{
  name = "sl__qianliyan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sl__qianliyan"] = "千里眼",
  [":sl__qianliyan"] = "锁定技，出牌阶段，牌堆顶X张牌始终对你可见（X为你的体力上限）。",

  ["@[sl__qianliyan]"] = "千里眼",

  ["$sl__qianliyan1"] = "千里眼，明察秋毫。",
  ["$sl__qianliyan2"] = "顺风千里，尽收眼底。",
}

sl__qianliyan:addEffect("targetmod", {
  -- 占位，实际效果由QML标记实现
})

local function slCanViewQianliyan(p)
  if not p or not p:hasSkill("sl__qianliyan", true, true) then
    return false
  end

  if p.phase ~= Player.Play then
    return false
  end

  -- 情况1：自己就是这个角色（直接选二娃/直接选小金刚）
  if Self and Self.id == p.id then
    return true
  end

  -- 情况2：自己是葫芦爷，且该角色是当前召唤出来的福禄娃
  if Self and Self:hasSkill("sl__fuluwa", true, true) then
    return Self:getMark("sl__fuluwa_current") == p.id
  end

  return false
end

Fk:addQmlMark{
  name = "sl__qianliyan",
  how_to_show = function(name, value, p)
    if slCanViewQianliyan(p) then
      return " "
    end
    return "#hidden"
  end,
  qml_data = function(name, value, p)
    local drawPile = Fk:currentRoom().draw_pile
    local cards = {}
    for i = 1, math.min(p.maxHp, #drawPile), 1 do
      table.insert(cards, drawPile[i])
    end
    return cards
  end,
  qml_path = function(name, value, p)
    if slCanViewQianliyan(p) then
      return "packages/utility/qml/ViewPile"
    end
    return ""
  end,
}

sl__qianliyan:addAcquireEffect(function (self, player)
  player.room:setPlayerMark(player, "@[sl__qianliyan]", 1)
end)

sl__qianliyan:addLoseEffect(function (self, player)
  player.room:setPlayerMark(player, "@[sl__qianliyan]", 0)
end)

return sl__qianliyan
