---@class Utility : Object
local Utility = {}

------------------------------------------------------------------------------------------------------
local fhyx_pile = {
  {"slash", Card.Club, 4},
  {"thunder__slash", Card.Spade, 4},
  {"fire__slash", Card.Heart, 4},
  {"jink", Card.Diamond, 2},
  {"peach", Card.Heart, 6},
  {"analeptic", Card.Spade, 9},
  {"ex_nihilo", Card.Heart, 8},
  {"amazing_grace", Card.Heart, 4},
  {"dismantlement", Card.Spade, 3},
  {"snatch", Card.Diamond, 3},
  {"fire_attack", Card.Diamond, 2},
  {"duel", Card.Diamond, 1},
  {"savage_assault", Card.Spade, 13},
  {"archery_attack", Card.Heart, 1},
  {"nullification", Card.Heart, 13},
  {"indulgence", Card.Heart, 6},
  {"supply_shortage", Card.Spade, 10},
  {"iron_chain", Card.Club, 12},
  {"lightning", Card.Heart, 12},
  {"collateral", Card.Club, 13},
  {"god_salvation", Card.Heart, 1},
  {"eight_diagram", Card.Spade, 2},
  {"nioh_shield", Card.Club, 2},
  {"vine", Card.Spade, 2},
  {"silver_lion", Card.Club, 1},
  {"dilu", Card.Club, 5},
  {"chitu", Card.Heart, 5},
  {"dayuan", Card.Spade, 13},
  {"zixing", Card.Diamond, 13},
  {"hualiu", Card.Diamond, 13},
  {"zhuahuangfeidian", Card.Heart, 13},
  {"jueying", Card.Spade, 5},
  {"crossbow", Card.Diamond, 1},
  {"qinggang_sword", Card.Spade, 6},
  {"guding_blade", Card.Spade, 1},
  {"ice_sword", Card.Spade, 2},
  {"double_swords", Card.Spade, 2},
  {"blade", Card.Spade, 5},
  {"spear", Card.Spade, 12},
  {"axe", Card.Diamond, 5},
  {"fan", Card.Diamond, 1},
  {"halberd", Card.Diamond, 12},
  {"kylin_bow", Card.Heart, 5},
  {"role__wooden_ox", Card.Diamond, 5},
}

--为房间加载额外牌堆
Utility.PrepareExtraPile = function(room)
  if room:getBanner("fhyx_extra_pile") then return end
  local all_names = {}
  for _, card in ipairs(Fk.cards) do
    if not table.contains(room.disabled_packs, card.package.name) and not card.is_derived then
      if not all_names[card.name] then
        all_names[card.name] = card
      end
    end
  end
  local cards = {}
  for name, card in pairs(all_names) do
    local c = table.find(fhyx_pile, function(info)
      return info[1] == name
    end)
    local id
    if c then
      id = room:printCard(table.unpack(c)).id
    else
      id = room:printCard(name, card.suit, card.number).id
    end
    table.insert(cards, id)
    room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
  end
  room:setBanner("fhyx_extra_pile", cards)
  room:setBanner("@$fhyx_extra_pile", table.simpleClone(cards))
  room:addSkill("#fhyx_extra_pile&")
end

------------------------------------------------------------------------------------------------------
--- SgshData 数据
---@class SgshDataSpec
---@field public general string @ 获得/失去的副将

---@class Utility.SgshData: SgshDataSpec, TriggerData
Utility.SgshData = TriggerData:subclass("SgshData")

--- TriggerEvent
---@class Utility.SgshTriggerEvent: TriggerEvent
---@field public data Utility.SgshData
Utility.SgshTriggerEvent = TriggerEvent:subclass("SgshEvent")

--- 获得副将前
---@class Utility.SgshBeforeAcquireDeputy: Utility.SgshTriggerEvent
Utility.SgshBeforeAcquireDeputy = Utility.SgshTriggerEvent:subclass("fk.SgshBeforeAcquireDeputy")

--- 失去副将前
---@class Utility.SgshBeforeLoseDeputy: Utility.SgshTriggerEvent
Utility.SgshBeforeLoseDeputy = Utility.SgshTriggerEvent:subclass("fk.SgshBeforeLoseDeputy")

--- 获得副将后
---@class Utility.SgshAcquireDeputy: Utility.SgshTriggerEvent
Utility.SgshAcquireDeputy = Utility.SgshTriggerEvent:subclass("fk.SgshAcquireDeputy")

--- 失去副将后
---@class Utility.SgshLoseDeputy: Utility.SgshTriggerEvent
Utility.SgshLoseDeputy = Utility.SgshTriggerEvent:subclass("fk.SgshLoseDeputy")

---@alias SgshTrigFunc fun(self: TriggerSkill, event: Utility.SgshTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.SgshData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.SgshTriggerEvent,
---  data: TrigSkelSpec<SgshTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

local blacklist = {
  "zuoci", "ol_ex__zuoci", "js__xushao", "js_re__xushao", "shichangshi", "starsp__xiahoudun", "ofl__godjiaxu"
}

---失去副将
---@param player ServerPlayer 玩家
---@param general? string 失去的副将，不填则自选失去
Utility.sgshLoseDeputy = function (player, general)
  local room = player.room
  local deputy = player:getTableMark("@&sgsh_deputy")
  if #deputy == 0 then return end
  local data = { general = general }
  if general == nil then
    local choices = deputy
    table.removeOne(choices, "sgsh__yuji")
    data.general = room:askToChooseGeneral(player, {
      generals = choices,
      n = 1,
      no_convert = true,
    })
  end
  room.logic:trigger(Utility.SgshBeforeLoseDeputy, player, data)
  if data.general == nil or data.general == "sgsh__yuji" then  --耦！
    return
  end
  general = data.general

  table.removeOne(deputy, general)
  table.insert(room.general_pile, general)
  room:setPlayerMark(player, "@&sgsh_deputy", deputy)
  local skills = Fk.generals[general]:getSkillNameList(player.role == "lord")
  room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"), nil, false, false)

  room:sendLog{
    type = "#SgshLoseDeputy",
    from = player.id,
    arg = general,
    toast = true,
  }
  room.logic:trigger(Utility.SgshLoseDeputy, player, { general = general })
end

---获得副将
---@param player ServerPlayer 玩家
---@param general? string 获得的副将，不填则随机获得
Utility.sgshAcquireDeputy = function (player, general)
  local room = player.room
  local data = { general = general }
  room.logic:trigger(Utility.SgshBeforeAcquireDeputy, player, data)
  if data.general == nil then
    local generals = table.filter(room.general_pile, function(name)
      return not table.contains(blacklist, name)
    end)
    if #generals == 0 then
      room:sendLog{
        type = "#NoGeneralDraw",
        toast = true,
      }
      room:gameOver("")
    end
    data.general = room:tableRandomPick(generals)
  end
  if data.general == nil then
    return
  end
  general = data.general
  table.removeOne(room.general_pile, general)
  room:addTableMark(player, "@&sgsh_deputy", general)

  local addRoleModSkills = function(p, skillName)
    local skill = Fk.skills[skillName]
    if not skill then
      fk.qCritical("Skill: "..skillName.." doesn't exist!")
      return
    end
    if (skill:hasTag(Skill.Lord) and p.role ~= "lord") or skill:hasTag(Skill.MainPlace) then
      return
    end
    if skill:hasTag(Skill.AttachedKingdom) and not table.contains(skill:getSkeleton().attached_kingdom, player.kingdom) then
      return
    end
    room:handleAddLoseSkills(p, skillName, nil, false)
  end
  for _, s in ipairs(Fk.generals[general]:getSkillNameList(player.role == "lord")) do
    addRoleModSkills(player, s)
  end

  room:sendLog{
    type = "#SgshAcquireDeputy",
    from = player.id,
    arg = general,
    toast = true,
  }
  room.logic:trigger(Utility.SgshAcquireDeputy, player, { general = general })

  while #player:getTableMark("@&sgsh_deputy") > 3 do
    Utility.sgshLoseDeputy(player)
  end
end

Fk:loadTranslationTable{
  ["#SgshLoseDeputy"] = "%from 失去了副将 %arg",
  ["#SgshAcquireDeputy"] = "%from 获得了副将 %arg",
}

------------------------------------------------------------------------------------------------------
--- OflShouliData 数据
---@class OflShouliDataSpec
---@field public n integer @ 数量

---@class Utility.OflShouliData: OflShouliDataSpec, TriggerData
Utility.OflShouliData = TriggerData:subclass("OflShouliData")

--- TriggerEvent
---@class Utility.OflShouliTriggerEvent: TriggerEvent
---@field public data Utility.OflShouliData
Utility.OflShouliTriggerEvent = TriggerEvent:subclass("OflShouliEvent")

--- 狩骊
---@class Utility.OflShouliMarkChanged: Utility.OflShouliTriggerEvent
Utility.OflShouliMarkChanged = Utility.OflShouliTriggerEvent:subclass("fk.OflShouliMarkChanged")

---@alias OflShouliTrigFunc fun(self: TriggerSkill, event: Utility.OflShouliTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.OflShouliData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.OflShouliTriggerEvent,
---  data: TrigSkelSpec<OflShouliTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

------------------------------------------------------------------------------------------------------
--- InsurrectionaryData 数据
---@class InsurrectionaryDataSpec
---@field public who ServerPlayer @ 玩家
---@field public reason? string @ 原因

---@class Utility.InsurrectionaryData: InsurrectionaryDataSpec, TriggerData
Utility.InsurrectionaryData = TriggerData:subclass("InsurrectionaryData")

--- TriggerEvent
---@class Utility.InsurrectionaryTriggerEvent: TriggerEvent
---@field public data Utility.InsurrectionaryData
Utility.InsurrectionaryTriggerEvent = TriggerEvent:subclass("InsurrectionaryEvent")

--- 加入起义军
---@class Utility.JoinInsurrectionary: Utility.InsurrectionaryTriggerEvent
Utility.JoinInsurrectionary = Utility.InsurrectionaryTriggerEvent:subclass("fk.JoinInsurrectionary")
--- 退出起义军
---@class Utility.QuitInsurrectionary: Utility.InsurrectionaryTriggerEvent
Utility.QuitInsurrectionary = Utility.InsurrectionaryTriggerEvent:subclass("fk.QuitInsurrectionary")

---@alias InsurrectionaryTrigFunc fun(self: TriggerSkill, event: Utility.InsurrectionaryTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.InsurrectionaryData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.InsurrectionaryTriggerEvent,
---  data: TrigSkelSpec<InsurrectionaryTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

---加入起义军
---@param player ServerPlayer 玩家
---@param skill_name? string 原因
Utility.joinInsurrectionary = function (player, skill_name)
  local room = player.room
  room:setPlayerMark(player, "@!insurrectionary", 1)
  local record = room:getBanner("insurrectionary") or {}
  table.insert(record, player.id)
  room:setBanner("insurrectionary", record)
  room:setBanner("@[:]insurrectionary", "insurrectionary_banner")
  room:sendLog{
    type = "#JoinInsurrectionary",
    from = player.id,
    toast = true,
  }
  room:addSkill("insurrectionary&")
  room.logic:trigger(Utility.JoinInsurrectionary, player, {who = player, reason = skill_name or "game_rule"}, false)
end

Utility.isInsurrectionary = function(player)
  return table.contains(Fk:currentRoom():getBanner("insurrectionary") or {}, player.id)
end

------------------------------------------------------------------------------------------------------
--- HenshinData 数据
---@class HenshinDataSpec
---@field public who ServerPlayer @ 玩家
---@field public reason? string @ 原因

---@class Utility.HenshinData: HenshinDataSpec, TriggerData
Utility.HenshinData = TriggerData:subclass("HenshinData")

--- TriggerEvent
---@class Utility.HenshinTriggerEvent: TriggerEvent
---@field public data Utility.HenshinData
Utility.HenshinTriggerEvent = TriggerEvent:subclass("HenshinEvent")

--- 变身后
---@class Utility.AfterHenshin: Utility.HenshinTriggerEvent
Utility.AfterHenshin = Utility.HenshinTriggerEvent:subclass("fk.AfterHenshin")
--- 消耗指示物后
---@class Utility.AfterEnergyCost: Utility.HenshinTriggerEvent
Utility.AfterEnergyCost = Utility.HenshinTriggerEvent:subclass("fk.AfterEnergyCost")

---@alias HenshinTrigFunc fun(self: TriggerSkill, event: Utility.HenshinTriggerEvent,
---  target: ServerPlayer, player: ServerPlayer, data: Utility.HenshinData):any

---@class SkillSkeleton
---@field public addEffect fun(self: SkillSkeleton, key: Utility.HenshinTriggerEvent,
---  data: TrigSkelSpec<HenshinTrigFunc>, attr: TrigSkelAttribute?): SkillSkeleton

---变身！
---@param player ServerPlayer 玩家
---@param name string 变身武将的名字
---@param prefix string 前缀（mhsj、mrss等……）
Utility.henshin = function (player, name, prefix)
  local room = player.room
  player:chat(Fk:translate(prefix.."_chat_"..name))
  player:throwAllCards("j")
  if player.dead then return end
  room:setPlayerMark(player, prefix.."__"..name, player.hp)
  local yes = false
  if player.general == prefix.."__"..name then
    player.general = prefix.."2__"..name
    room:broadcastProperty(player, "general")
    yes = true
  elseif player.deputyGeneral == prefix.."__"..name then
    player.deputyGeneral = prefix.."2__"..name
    room:broadcastProperty(player, "deputyGeneral")
    yes = true
  end
  if not yes then return end
  if player:getMark(prefix.."2__"..name) == 0 then
    room:setPlayerMark(player, prefix.."2__"..name, Fk.generals[prefix.."2__"..name].hp)
  end
  player.hp = math.min(player.maxHp, player:getMark(prefix.."2__"..name))
  room:broadcastProperty(player, "maxHp")
  room:broadcastProperty(player, "hp")
  local skills = Fk.generals[prefix.."2__"..name]:getSkillNameList(true)
  for _, s in ipairs(Fk.generals[prefix.."__"..name]:getSkillNameList(true)) do
    table.insert(skills, "-"..s)
  end
  room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false, false)
  room.logic:trigger(Utility.AfterHenshin, player, { who = player, name = name, type = prefix }, false)
end

--退出变身
---@param player ServerPlayer 玩家
---@param prefix string 前缀（mhsj、mrss等……）
Utility.quitHenshin = function (player, prefix)
  local room = player.room
  if player:getMark("prevent_quit_henshin") > 0 then return end
  local skills = {}
  if player.general:startsWith(prefix.."2__") then
    room:setPlayerMark(player, player.general, player.hp)
    for _, s in ipairs(Fk.generals[player.general]:getSkillNameList(true)) do
      table.insertIfNeed(skills, "-"..s)
    end
    local name = string.sub(player.general, 8)
    table.insertTableIfNeed(skills, Fk.generals[prefix.."__"..name]:getSkillNameList(true))
    player.general = prefix.."__"..name
    room:broadcastProperty(player, "general")
    player.hp = math.min(player.maxHp, player:getMark(prefix.."__"..name))
    room:broadcastProperty(player, "hp")
  end
  if player.deputyGeneral:startsWith(prefix.."2__") then
    room:setPlayerMark(player, player.deputyGeneral, player.hp)
    for _, s in ipairs(Fk.generals[player.deputyGeneral]:getSkillNameList(true)) do
      table.insertIfNeed(skills, "-"..s)
    end
    local name = string.sub(player.deputyGeneral, 8)
    table.insertTableIfNeed(skills, Fk.generals[prefix.."__"..name]:getSkillNameList(true))
    player.deputyGeneral = prefix.."__"..name
    room:broadcastProperty(player, "deputyGeneral")
    player.hp = math.min(player.maxHp, player:getMark(prefix.."__"..name))
    room:broadcastProperty(player, "hp")
  end
  room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false, false)
end

--消耗指示物
---@param player ServerPlayer 玩家
---@param num integer 消耗的指示物数
---@param prefix string 前缀（mhsj、mrss等……）
Utility.costEnergy = function (player, num, prefix)
  local room = player.room
  room:removePlayerMark(player, "@!"..prefix.."_energy", num)
  if player:getMark("@!"..prefix.."_energy") == 0 then
    Utility.quitHenshin(player, prefix)
  end
  room.logic:trigger(Utility.AfterEnergyCost, player, { who = player, num = num, type = prefix }, false)
end

return Utility
