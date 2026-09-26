local M = {}

M.weapon_buffs = {
  "fms__diamond_fire",
  "fms__diamond_rob",
  "fms__diamond_power",
  "fms__diamond_break_armor",
  "fms__diamond_infinite",
  "fms__diamond_silence",
  "fms__diamond_curse",
  "fms__diamond_sharp",
  "fms__diamond_multi",
  "fms__diamond_bone_blade",
  "fms__diamond_sweep",
  "fms__diamond_blood",
  "fms__diamond_thunder",
}

M.armor_buffs = {
  "fms__diamond_thorns",
  "fms__diamond_far_reduce",
  "fms__diamond_guard",
  "fms__diamond_counter",
  "fms__diamond_expand",
  "fms__diamond_bless",
  "fms__diamond_absorb",
  "fms__diamond_mercy",
}

M.all_buffs = {
  "fms__diamond_fire",
  "fms__diamond_rob",
  "fms__diamond_power",
  "fms__diamond_break_armor",
  "fms__diamond_infinite",
  "fms__diamond_silence",
  "fms__diamond_curse",
  "fms__diamond_sharp",
  "fms__diamond_multi",
  "fms__diamond_bone_blade",
  "fms__diamond_sweep",
  "fms__diamond_blood",
  "fms__diamond_thunder",
  "fms__diamond_thorns",
  "fms__diamond_far_reduce",
  "fms__diamond_guard",
  "fms__diamond_counter",
  "fms__diamond_expand",
  "fms__diamond_bless",
  "fms__diamond_absorb",
  "fms__diamond_mercy",
}

function M.isDiamondSword(card)
  return card and card.name == "fms__diamond_sword"
end

function M.isDiamondArmor(card)
  return card and card.name == "fms__diamond_armor"
end

function M.isDiamondEquip(card)
  return M.isDiamondSword(card) or M.isDiamondArmor(card)
end

function M.isSlash(card)
  return card and card.trueName == "slash"
end

function M.isAnaleptic(card)
  return card and card.trueName == "analeptic"
end

function M.isDamageCard(card)
  if not card then
    return false
  end
  return table.contains({
    "slash",
    "duel",
    "fire_attack",
    "savage_assault",
    "archery_attack",
    "burning_camps",
  }, card.trueName)
end

function M.getBuffListByCard(card)
  if M.isDiamondSword(card) then
    return M.weapon_buffs
  elseif M.isDiamondArmor(card) then
    return M.armor_buffs
  end
  return {}
end

function M.countBuffs(card)
  local n = 0
  for _, buff in ipairs(M.getBuffListByCard(card)) do
    if (card:getMark(buff) or 0) > 0 then
      n = n + 1
    end
  end
  return n
end

function M.getCurrentBuffs(card)
  local buffs = {}
  for _, buff in ipairs(M.getBuffListByCard(card)) do
    if (card:getMark(buff) or 0) > 0 then
      table.insert(buffs, buff)
    end
  end
  return buffs
end

function M.findDiamondSwordId(player)
  for _, id in ipairs(player:getCardIds("e")) do
    local c = Fk:getCardById(id)
    if M.isDiamondSword(c) then
      return id
    end
  end
  return nil
end

function M.findDiamondArmorId(player)
  for _, id in ipairs(player:getCardIds("e")) do
    local c = Fk:getCardById(id)
    if M.isDiamondArmor(c) then
      return id
    end
  end
  return nil
end

function M.getEnchantableChoices(player)
  local choices = {}
  if M.findDiamondSwordId(player) then
    table.insert(choices, "fms__diamond_sword")
  end
  if M.findDiamondArmorId(player) then
    table.insert(choices, "fms__diamond_armor")
  end
  return choices
end

function M.getCardByChoice(player, choice)
  if choice == "fms__diamond_sword" then
    local id = M.findDiamondSwordId(player)
    return id and Fk:getCardById(id) or nil
  elseif choice == "fms__diamond_armor" then
    local id = M.findDiamondArmorId(player)
    return id and Fk:getCardById(id) or nil
  end
  return nil
end

function M.randomBuff(card)
  local current = M.getCurrentBuffs(card)
  local pool = {}

  for _, buff in ipairs(M.getBuffListByCard(card)) do
    if not table.contains(current, buff) then
      table.insert(pool, buff)
    end
  end

  if #pool == 0 then
    pool = M.getBuffListByCard(card)
  end
  if #pool == 0 then
    return nil
  end
  return pool[math.random(1, #pool)]
end

function M.cleanupAbsorbPile(room, player)
  local pile = player:getPile("fms__diamond_absorb")
  if #pile > 0 then
    room:moveCards({
      from = player,
      ids = pile,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = "fms__diamond_absorb",
    })
  end
  room:setPlayerMark(player, "fms__diamond_absorb_record", 0)
end

function M.refreshDiamondBuffSkills(room, player)
  if not room or not player then
    return
  end

  local should_have = {}

  local sword_id = M.findDiamondSwordId(player)
  if sword_id then
    local sword = Fk:getCardById(sword_id)
    for _, skill_name in ipairs(M.weapon_buffs) do
      if sword and sword:getMark(skill_name) > 0 then
        should_have[skill_name] = true
      end
    end
  end

  local armor_id = M.findDiamondArmorId(player)
  if armor_id then
    local armor = Fk:getCardById(armor_id)
    for _, skill_name in ipairs(M.armor_buffs) do
      if armor and armor:getMark(skill_name) > 0 then
        should_have[skill_name] = true
      end
    end
  end

  if not should_have["fms__diamond_absorb"] then
    M.cleanupAbsorbPile(room, player)
  end

  for _, skill_name in ipairs(M.all_buffs) do
    if should_have[skill_name] then
      if not player:hasSkill(skill_name, true) then
        room:handleAddLoseSkills(player, skill_name, nil, false, true)
      end
    else
      if player:hasSkill(skill_name, true) then
        room:handleAddLoseSkills(player, "-" .. skill_name, nil, false, true)
      end
    end
  end
end

function M.addTurnReset(skill, mark)
  skill:addEffect(fk.TurnStart, {
    global = true,
    can_refresh = function(self, event, target, player, data)
      return target == player and player:hasSkill(skill.name, true)
    end,
    on_refresh = function(self, event, target, player, data)
      player.room:setPlayerMark(player, mark, 0)
    end,
  })
end

Fk:loadTranslationTable{
  ["fms__diamond_fire"] = "火焰附加",
  [":fms__diamond_fire"] = "锁定技，你造成的伤害视为火焰伤害。",

  ["fms__diamond_rob"] = "抢夺",
  [":fms__diamond_rob"] = "锁定技，每回合限一次，当你造成伤害后，你获得受伤角色一张手牌。",

  ["fms__diamond_power"] = "力量",
  [":fms__diamond_power"] = "锁定技，每回合限一次，你造成的伤害+1。",

  ["fms__diamond_break_armor"] = "破甲",
  [":fms__diamond_break_armor"] = "锁定技，你使用的【杀】无视目标防具。",

  ["fms__diamond_infinite"] = "无限",
  [":fms__diamond_infinite"] = "锁定技，你使用【杀】和【酒】无次数限制。",

  ["fms__diamond_silence"] = "沉默",
  [":fms__diamond_silence"] = "锁定技，当你造成伤害后，受伤角色的武将技能失效直到回合结束。",

  ["fms__diamond_curse"] = "诅咒",
  [":fms__diamond_curse"] = "锁定技，每回合限一次，你使用的【杀】不能被响应。",

  ["fms__diamond_sharp"] = "锋利",
  [":fms__diamond_sharp"] = "锁定技，你造成的伤害改为体力流失。",

  ["fms__diamond_multi"] = "多重",
  [":fms__diamond_multi"] = "锁定技，每回合限一次，你使用的伤害类牌额外结算一次。",

  ["fms__diamond_bone_blade"] = "骨剑",
  [":fms__diamond_bone_blade"] = "锁定技，你使用【杀】无距离限制。",

  ["fms__diamond_sweep"] = "横扫之刃",
  [":fms__diamond_sweep"] = "锁定技，每回合限一次，你使用【杀】可以额外指定任意名目标。",

  ["fms__diamond_blood"] = "泣血",
  [":fms__diamond_blood"] = "锁定技，当你造成伤害后，你回复1点体力。",

  ["fms__diamond_thunder"] = "引雷",
  [":fms__diamond_thunder"] = "锁定技，当你造成伤害后，受伤角色进行一次“闪电”判定：若结果为黑桃2~9，其受到3点雷电伤害。",

  ["fms__diamond_thorns"] = "荆棘",
  [":fms__diamond_thorns"] = "锁定技，当你受到伤害后，你弃置伤害来源一张牌。",

  ["fms__diamond_far_reduce"] = "远程减伤",
  [":fms__diamond_far_reduce"] = "锁定技，当你受到攻击范围外角色造成的伤害时，此伤害-1。",

  ["fms__diamond_guard"] = "保护",
  [":fms__diamond_guard"] = "锁定技，当你受到属性伤害时，此伤害-1。",

  ["fms__diamond_counter"] = "反击",
  [":fms__diamond_counter"] = "当你受到伤害后，你可以视为对伤害来源使用一张【杀】。",

  ["fms__diamond_expand"] = "扩容",
  [":fms__diamond_expand"] = "锁定技，你的手牌上限+2。",

  ["fms__diamond_bless"] = "祝福",
  [":fms__diamond_bless"] = "锁定技，当你受到伤害后或回复体力后，你摸一张牌。",

  ["fms__diamond_absorb"] = "吸收",
  [":fms__diamond_absorb"] = "锁定技，回合外，当你成为伤害类牌的唯一目标后，你取消之并将此牌置于武将牌上；准备阶段，你令其使用者对你重新使用之。",

  ["fms__diamond_mercy"] = "怜悯",
  [":fms__diamond_mercy"] = "回合外，你可以将所有手牌当一张【桃】使用。",
}

local diamond_buff_sync = fk.CreateSkill{
  name = "#fms__diamond_buff_sync",
}

diamond_buff_sync:addEffect(fk.AfterCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    if not player then
      return false
    end

    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and M.isDiamondEquip(card) and info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end

      if move.to == player and move.toArea == Card.PlayerEquip then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and M.isDiamondEquip(card) then
            return true
          end
        end
      end
    end
    return false
  end,
  on_refresh = function(self, event, target, player, data)
    M.refreshDiamondBuffSkills(player.room, player)
  end,
})

return M
