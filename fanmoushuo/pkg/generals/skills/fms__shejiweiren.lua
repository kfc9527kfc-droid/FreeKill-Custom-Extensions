local dorm128 = {
  "fms__daichengxu",
  "fms__liyang",
  "fms__huangzhongtian",
}

local function isDorm128(player)
  return
    table.contains(dorm128, player.general) or
    table.contains(dorm128, player.deputyGeneral)
end

local shejiweiren = fk.CreateSkill{
  name = "fms__shejiweiren",
}

Fk:loadTranslationTable{
  ["fms__shejiweiren"] = "舍己为人",
  [":fms__shejiweiren"] = "室长技，出牌阶段，你可以减1点体力上限，令一名128宿舍角色回复1点体力并摸一张牌。",
  ["#fms__shejiweiren"] = "舍己为人：你可以减1点体力上限，令一名128宿舍角色回复1点体力并摸一张牌",
}

shejiweiren:addEffect("active", {
  anim_type = "support",
  prompt = "#fms__shejiweiren",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player.maxHp and player.maxHp > 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and isDorm128(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if not target then return end

    room:changeMaxHp(player, -1)
    if player.dead then return end

    if target:isAlive() then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = shejiweiren.name,
      }
    end

    if target:isAlive() then
      target:drawCards(1, shejiweiren.name)
    end
  end,
})

return shejiweiren
