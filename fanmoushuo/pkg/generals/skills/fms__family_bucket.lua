local fms__family_bucket = fk.CreateSkill{
  name = "fms__family_bucket",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__family_bucket"] = "全家桶",
  [":fms__family_bucket"] = "锁定技，你使用的【五谷丰登】改为展示X张KFC美食牌（X为此牌目标数）。",
}

local food_names = {
  "fms__egg_tart",
  "fms__original_chicken",
  "fms__burger",
  "fms__popcorn_chicken",
  "fms__colonel_nuggets",
  "fms__cola",
  "fms__coffee",
  "fms__mashed_potato",
}

local function isInNameList(name, list)
  for _, n in ipairs(list) do
    if n == name then
      return true
    end
  end
  return false
end

local function getFoodIdsFromAreas(room)
  local ids = {}

  for _, id in ipairs(room.draw_pile) do
    local c = Fk:getCardById(id)
    if c and isInNameList(c.name, food_names) then
      table.insert(ids, id)
    end
  end

  for _, id in ipairs(room.discard_pile) do
    local c = Fk:getCardById(id)
    if c and isInNameList(c.name, food_names) then
      table.insert(ids, id)
    end
  end

  return ids
end

fms__family_bucket:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(self.name)
      and data
      and data.card
      and data.card.trueName == "amazing_grace"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = getFoodIdsFromAreas(room)
    if #ids == 0 then
      return
    end

    table.shuffle(ids)

    local x = #data.tos
    if x <= 0 then
      x = #room.alive_players
    end

    local chosen = {}
    for i = 1, math.min(x, #ids) do
      table.insert(chosen, ids[i])
    end

    if #chosen > 0 then
      data.extra_data = data.extra_data or {}
      data.extra_data.orig_cards = chosen
    end
  end,
})

return fms__family_bucket
