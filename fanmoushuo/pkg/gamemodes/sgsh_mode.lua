local desc = [[
  # 三国杀·幻模式简介

  ___

  本模式为**身份模式的变种模式**，是线下发行的**官方正版模式**，货号S0096。

  游戏流程与身份局完全一致，仅增加以下特色规则：

  当一名角色受到1点伤害后，可以从剩余武将牌堆中随机获得一张武将牌作为副将，**每名角色至多拥有三张副将**。

  当副将超出数量限制时，须选择相应数量的副将移除，返回剩余武将牌堆。

  玩家同时拥有主将和**所有副将**的技能。一部分技能带有主将技/副将技标签，表示此技能仅在对应武将为主将/副将时才拥有。
]]

local sgsh_getLogic = function()
  local sgsh_logic = GameLogic:subclass("sgsh_logic") ---@class GameLogic

  function sgsh_logic:chooseGenerals()
    local room = self.room

    local ban_list = {
      "ofl__godjiaxu",
      "js__xushao", "js_re__xushao",
      "shichangshi",
      "zuoci", "ol_ex__zuoci", "mini_ex__zuoci",
      "nd_story__zhangbao", "nd_story__zhangliang",
    }
    for _, g in ipairs(ban_list) do
      table.removeOne(room.general_pile, g)
    end

    local generalNum = room:getSettings('generalNum')
    local lord = room:getLord()

    if lord ~= nil then
      room:setCurrent(lord)
      local generals = room:getNGenerals(generalNum)
      local lord_general = room:askToChooseGeneral(lord, { generals = generals, n = 1 })

      table.removeOne(generals, lord_general)
      room:returnToGeneralPile(generals)

      room:prepareGeneral(lord, lord_general, nil, true)

      room:askToChooseKingdom({lord})
    end

    local nonlord = room:getOtherPlayers(lord, true)
    local generals = room:tableRandomPick(room.general_pile, #nonlord * generalNum)

    local req = Request:new(nonlord, "AskForGeneral")
    req.timeout = self.room:getSettings('generalTimeout')
    for i, p in ipairs(nonlord) do
      local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
      req:setData(p, { arg, 1 })
      req:setDefaultReply(p, room:tableRandomPick(arg, 1))
    end

    for _, p in ipairs(nonlord) do
      local result = req:getResult(p)
      local general = result[1]
      room:prepareGeneral(p, general)
    end

    room:askToChooseKingdom(nonlord)
  end

  function sgsh_logic:attachSkillToPlayers()
    local room = self.room

    local addRoleModSkills = function(player, skillName)
      local skill = Fk.skills[skillName]
      if not skill then
        fk.qCritical("Skill: "..skillName.." doesn't exist!")
        return
      end
      if (skill:hasTag(Skill.Lord) and player.role ~= "lord") or skill:hasTag(Skill.DeputyPlace) then
        return
      end
      if skill:hasTag(Skill.AttachedKingdom) and not table.contains(skill:getSkeleton().attached_kingdom, player.kingdom) then
        return
      end
      room:handleAddLoseSkills(player, skillName, nil, false)
    end
    for _, p in ipairs(room.alive_players) do
      for _, s in ipairs(Fk.generals[p.general]:getSkillNameList(p.role == "lord")) do
        addRoleModSkills(p, s)
      end
    end
  end

  return sgsh_logic
end

local sgsh_mode = fk.CreateGameMode{
  name = "sgsh_mode",
  minPlayer = 2,
  maxPlayer = 8,
  main_mode = "role_mode",
  rule = "#sgsh_mode&",
  logic = sgsh_getLogic,
  surrender_func = Fk.game_modes["aaa_role_mode"].surrenderFunc,
}

Fk:loadTranslationTable{
  ["sgsh_mode"] = "三国杀·幻",
  [":sgsh_mode"] = desc,
}

return sgsh_mode
