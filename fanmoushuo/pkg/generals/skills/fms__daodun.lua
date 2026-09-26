local function isDaodunEquip(card)
  return
    card and
    card.type == Card.TypeEquip and
    (
      card.sub_type == Card.SubtypeWeapon or
      card.sub_type == Card.SubtypeArmor
    )
end

local function hasDaodunPutCard(player)
  for _, id in ipairs(player:getCardIds("he")) do
    local c = Fk:getCardById(id)
    if isDaodunEquip(c) then
      return true
    end
  end
  return false
end

local function getDaodunIds(player)
  local ids = {}
  for _, id in ipairs(player:getPile("fms__daodun")) do
    local c = Fk:getCardById(id)
    if isDaodunEquip(c) then
      table.insert(ids, id)
    end
  end
  return ids
end

local function getOtherDaodunIds(player, exclude_ids)
  local ids = {}
  for _, id in ipairs(getDaodunIds(player)) do
    if not table.contains(exclude_ids, id) then
      table.insert(ids, id)
    end
  end
  return ids
end

local function hasSameEquipSkillElsewhere(player, skill_name, exclude_ids)
  for _, id in ipairs(getOtherDaodunIds(player, exclude_ids)) do
    local card = Fk:getCardById(id)
    if card and card.equip_skills then
      for _, s in ipairs(card.equip_skills) do
        if s.name == skill_name then
          return true
        end
      end
    end
  end
  return false
end

local function addEquipSkillsFromIds(room, player, ids)
  for _, id in ipairs(ids) do
    local card = Fk:getCardById(id)
    if card and card.equip_skills then
      for _, s in ipairs(card.equip_skills) do
        if not player:hasSkill(s, true) then
          room:handleAddLoseSkills(player, s.name, nil, false, true)
        end
      end
    end
  end
end

local function removeEquipSkillsFromIds(room, player, ids)
  for _, id in ipairs(ids) do
    local card = Fk:getCardById(id)
    if card and card.equip_skills then
      for _, s in ipairs(card.equip_skills) do
        if not hasSameEquipSkillElsewhere(player, s.name, ids) then
          room:handleAddLoseSkills(player, "-" .. s.name, nil, false, true)
        end
      end
    end
  end
end

local fms__daodun = fk.CreateSkill{
  name = "fms__daodun",
  tags = { Skill.Compulsory },
  derived_piles = "fms__daodun",
}

Fk:loadTranslationTable{
  ["fms__daodun"] = "刀盾",
  [":fms__daodun"] = "锁定技，游戏开始时，你废除所有装备栏并获得“刀盾领域”；出牌阶段，你可以将武器牌和防具牌置入“刀盾领域”，视为装备之。<br>"..
  "[“我的刀盾”]",
  ["#fms__daodun"] = "刀盾",
  ["#fms__daodun-put"] = "刀盾：你可以将任意张武器牌和防具牌置入“刀盾领域”",
  ["fms__daodun_pile"] = "刀盾领域",
}

fms__daodun:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local equipSlots = player:getAvailableEquipSlots()
    if #equipSlots > 0 then
      room:abortPlayerArea(player, equipSlots)
    end
  end,
})

fms__daodun:addEffect("active", {
  anim_type = "special",
  prompt = "#fms__daodun-put",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:hasSkill(self.name) and hasDaodunPutCard(player)
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      pattern = ".|.|.|.|.|equip",
      prompt = "#fms__daodun-put",
      skill_name = self.name,
      cancelable = true,
    })

    if #cards == 0 then
      return
    end

    local valid = {}
    for _, id in ipairs(cards) do
      local c = Fk:getCardById(id)
      if isDaodunEquip(c) then
        table.insert(valid, id)
      end
    end

    if #valid == 0 then
      return
    end

    addEquipSkillsFromIds(room, player, valid)
    player:addToPile("fms__daodun", valid, true, self.name, player)
  end,
})

fms__daodun:addEffect("atkrange", {
  virtual_weapon_func = function(self, player)
    local n = 0

    for _, id in ipairs(getDaodunIds(player)) do
      local card = Fk:getCardById(id)
      if card and card.sub_type == Card.SubtypeWeapon then
        n = math.max(n, card.attack_range or 0)
      end
    end

    if n > 0 then
      return n
    end
  end,
})

fms__daodun:addLoseEffect(function(self, player, is_death)
  local ids = getDaodunIds(player)
  if #ids > 0 then
    removeEquipSkillsFromIds(player.room, player, ids)
  end
end)

return fms__daodun
