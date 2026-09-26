local rule = fk.CreateSkill {
  name = "#ofl_taixu_rule&",
}

Fk:loadTranslationTable{
  ["#ofl_taixu_rule&"] = "太虚幻魇",

  ["ofl_taixu_revive"] = "消耗1点命数复活",
  ["ofl_taixu_quit"] = "失败，退出游戏",
  ["#ofl_taixu_next"] = "<font color='grey'>===</font> 幻魇被击败！进入【%arg】 <font color='grey'>===</font>",
  ["#ofl_taixu_new_skills"] = "获得一个新的技能",
}

rule:addEffect(fk.GameOverJudge, {
  can_refresh = function (self, event, target, player, data)
    return target == player and Fk.game_modes[player.room:getSettings('gameMode')]:getWinner(player) ~= ""
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local hp = room:getBanner("@ofl_taixu_warrior_hp") or 0
    --凡人阵亡，选择复活或退出
    if room:getBanner("ofl_taixu_warrior") == player.id then
      if hp > 0 and room:askToChoice(player, {
        choices = { "ofl_taixu_revive", "ofl_taixu_quit" },
        skill_name = rule.name,
      }) == "ofl_taixu_revive" then
        hp = hp - 1
        room:setBanner("@ofl_taixu_warrior_hp", hp)
        room:setPlayerProperty(player, "dead", false)
        player._splayer:setDied(false)
        room:setPlayerProperty(player, "dying", false)
        room:setPlayerProperty(player, "maxHp", 4)
        room:setPlayerProperty(player, "hp", 4)
        table.insertIfNeed(room.alive_players, player)
        room:updateAllLimitSkillUI(player)
        room:sendLog {
          type = "#Revive",
          from = player.id,
        }
        room.logic:getCurrentEvent():shutdown()
      end
    else
    --幻魇阵亡，进入下一关
      local story = tonumber(room:getBanner("@ofl_taixu_story"):sub(17))
      if story >= 10 then return end
      hp = hp + 1
      story = story + 1
      room:sendLog{
        type = "#ofl_taixu_next",
        arg = "ofl_taixu_story_"..story,
        toast = true,
      }

      --重置身份和座次
      local warrior = room:getPlayerById(room:getBanner("ofl_taixu_warrior"))
      room:setCurrent(warrior)
      if warrior.seat ~= 1 then
        table.removeOne(room.players, warrior)
        table.insert(room.players, 1, warrior)
        room:arrangeSeats(room.players)
      end
      local roles = room.logic.role_table[#room.players]
      for i = 1, #room.players do
        local p = room.players[i]
        p.role = roles[i]
        room:setPlayerProperty(p, "role_shown", true)
        room:broadcastProperty(p, "role")
        room:setPlayerProperty(p, "dead", false)
        player._splayer:setDied(false)
        room:setPlayerProperty(p, "dying", false)
        table.insertIfNeed(room.alive_players, p)
      end

      --清除房间所有技能、mark、banner
      room.status_skills = {}
      for _, p in ipairs(room.players) do
        for i = #p.player_skills, 1, -1 do
          local s = p.player_skills[i]
          p:loseSkill(s)
          room:doBroadcastNotify("LoseSkill", { p.id, s.name })
        end
        for name, _ in pairs(p.mark) do
          if name ~= "ofl_taixu_skills" then
            room:setPlayerMark(p, name, 0)
          end
        end
        p.tag = {}
      end
      room.banners = {}
      room.tag = {}
      room.card_marks = {}

      --移除所有卡牌，重新构建牌堆
      for _, p in ipairs(room.players) do
        for _, area in ipairs({ Player.Hand, Player.Equip, Player.Judge }) do
          local cards = table.simpleClone(p.player_cards[area])
          if #cards > 0 then
            local move_to_notify = {   ---@type MoveCardsDataSpec
              moveInfo = {},
              from = p,
              to = nil,
              toArea = Card.Void,
              moveReason = fk.ReasonJustMove,
            }
            for _, id in ipairs(cards) do
              table.insert(move_to_notify.moveInfo, { cardId = id, fromArea = room:getCardArea(id) })
            end
            room:notifyMoveCards(nil, {move_to_notify})
            p:removeCards(area, cards)
          end
        end
        for name, ids in pairs(p.special_cards) do
          local cards = table.simpleClone(ids)
          if #cards > 0 then
            local move_to_notify = {   ---@type MoveCardsDataSpec
              moveInfo = {},
              from = p,
              to = nil,
              toArea = Card.Void,
              moveReason = fk.ReasonJustMove,
            }
            for _, id in ipairs(cards) do
              table.insert(move_to_notify.moveInfo, { cardId = id, fromArea = room:getCardArea(id), fromSpecialName = name })
            end
            room:notifyMoveCards(nil, {move_to_notify})
            p:removeCards(Player.Special, cards, name)
          end
        end
      end
      room:initCardManager()
      room.status_skills = {}
      for class, skills in pairs(Fk.global_status_skill) do
        room.status_skills[class] = {table.unpack(skills)}
      end
      room.skill_costs = {}
      room.logic:prepareDrawPile()

      --最后挂上本模式需要的几个信息
      room:setBanner("RoundCount", 0)
      room:doBroadcastNotify("UpdateRoundNum", 0)
      room:setBanner("@ofl_taixu_warrior_hp", hp)
      room:setBanner("@ofl_taixu_story", "ofl_taixu_story_" .. story)
      room:setBanner("ofl_taixu_warrior", warrior.id)

      --游戏炸了！
      local game_event = room.logic:getCurrentEvent():findParent(GameEvent.Game)
      if game_event then
        game_event:shutdown()
      end
      local logic = room.logic
      logic.all_game_events = {}
      logic.event_recorder = setmetatable({}, {
        -- 对派生事件而言 共用一个键 键取决于最接近GameEvent类的基类
        __newindex = function(t, k, v)
          if type(k) == "table" and k:isSubclassOf(GameEvent) then
            k = k:getBaseClass()
          end
          rawset(t, k, v)
        end,
        __index = function(t, k)
          if type(k) == "table" and k:isSubclassOf(GameEvent) then
            k = k:getBaseClass()
          end
          return rawget(t, k)
        end,
      })
      logic.current_event_id = 0
      logic.specific_events_id = {
        [GameEvent.Damage] = 1,
      }
      logic.current_trigger_event_id = 0

      --设置武将
      room:delay(2000)
      local warrior_general = Fk.generals[warrior._splayer:getAvatar()] or Fk.generals["os__gexuan"] or Fk.generals["blank_shibing"]
      room:setPlayerGeneral(warrior, warrior_general.name, true)
      room:broadcastProperty(warrior, "general")
      room:broadcastProperty(warrior, "kingdom")
      room:setPlayerProperty(warrior, "maxHp", 4)
      room:setPlayerProperty(warrior, "hp", 4)
      room:setPlayerProperty(warrior, "shield", 0)

      local story_generals = {
        {
          room:tableRandomPick({
            "huangjinleishi",
            "zhangchu",
            "js__zhangchu",
            "ty__zhangning",
            "os__zhangning",
            "mayuanyi",
            "zhangmancheng",
            "ol__zhangmancheng",
            "ty__zhangmancheng",
            "peiyuanshao",
            "ol__peiyuanshao",
            "guanhai",
            "ol__guanhai",
            "zhangkai",
            "zhangyan",
            "m_shi__zhangyan",
            "ty__zhangyan",
            "zhangjiaozhangbaozhangliang",
            "yanzhengh",
            "bairao",
            "busi",
            "suigu",
            "heman",
            "yudu",
            "tangzhou",
            "bocai",
            "chengyuanzhi",
            "dengmao",
            "gaosheng",
            "fuyun",
            "taosheng",
          }),
          "ofl_tx__zhangbao",
          "ofl_tx__zhangjiao",
          "ofl_tx__zhangliang"
        },
        {
          room:tableRandomPick({
            "ex__caocao",
            "js__caocao",
            "os_sp__caocao",
            "sx__caocao",
            "mini__caocao",
            "vd__caocao",
            "es__caocao",
            "ofl__caocao",
            "ofl2__caocao",
            "ofl3__caocao",
            "ofl4__caocao",
          }),
          "ofl_tx__zhangrang",
          "ofl_tx__hejin",
          "ofl_tx__yuanshao",
        },
        room:tableRandomPick({
          { "ofl_tx__lijue", "ofl_tx__fanchou", "ofl_tx__guosi", "ofl_tx__zhangji" },
          { "ofl_tx2__gaoshun", "ofl_tx__lvbu", "ofl_tx__liru", "ofl_tx__dongzhuo" },
        }),
        {
          "ofl_tx__jiling",
          "ofl_tx__dragon",
          "ofl_tx__yuejiu",
          "ofl_tx__yuanshu",
        },
        {
          "ofl_tx__gaoshun",
          "ofl_tx__godlvbu",
          "ofl_tx__zhangliao",
          "ofl_tx__chengong",
        },
        {
          room:tableRandomPick({ "gongsunfan", "yangang" }),
          "ofl_tx__quyi",
          "ofl_tx__gongsunzan",
          "ofl_tx__zhaoyun",
        },
        room:tableRandomPick({
          {"ofl_tx__zhouyu", "ofl_tx__taishici", "ofl_tx__sunce", "ofl_tx__daqiao"},
          { "ofl_tx__daqiao", "ofl_tx__xiaoqiao", "ofl_tx__zhouyu", "ofl_tx__sunce" },
        }),
        {
          room:tableRandomPick({ "ofl_tx__guotupangji", "ofl_tx__shenpei" }),
          "ofl_tx__yanliangwenchou",
          "ofl_tx__yuanshao",
          "ofl_tx__jvshou",
        },
        {
          "ofl_tx__guanyu",
          "ofl_tx__zhangfei",
          "ofl_tx2__zhaoyun",
          room:tableRandomPick({ "ofl_tx__liubei", "ofl_tx__wolong" }),
        },
        {
          room:tableRandomPick({ "ofl_tx__ganning", "ofl_tx__zhangxiu", "zhangyun" }),
          "ofl_tx__liuqi",
          "ofl_tx__liubiao",
          "ofl_tx__caifuren",
        },
      }
      for i = #room.players, 2, -1 do
        local p = room.players[i]
        local g = story_generals[story][4 - #room.players + i]
        if not Fk.generals[g] then
          g = "caocao"
        end
        room:setPlayerGeneral(p, g, true)
        room:broadcastProperty(p, "general")
        room:broadcastProperty(p, "kingdom")
        room:setPlayerProperty(p, "maxHp", Fk.generals[g].maxHp)
        room:setPlayerProperty(p, "hp", Fk.generals[g].hp)
        room:setPlayerProperty(p, "shield", 0)
      end

      if #warrior:getTableMark("ofl_taixu_skills") < 4 then
        local generals = Fk:getGeneralsRandomly(2)
        generals = table.map(generals, Util.NameMapper)
        local general = room:askToChooseGeneral(warrior, {
          generals = generals,
          n = 1,
        })
        local result = room:askToCustomDialog(warrior, {
          skill_name = "game_rule",
          qml_path = "packages/utility/qml/ChooseSkillBox.qml",
          extra_data = {
            Fk.generals[general]:getSkillNameList(false), 1, 1, "#ofl_taixu_new_skills", {general}
          },
        })
        if result ~= "" then
          result = result[1]
        else
          result = room:tableRandomPick(Fk.generals[general]:getSkillNameList(false))
        end
        room:addTableMark(warrior, "ofl_taixu_skills", result)
      end

      room.logic:attachSkillToPlayers()
      room.logic:prepareForStart()
      room.logic:action()
    end
  end,
})

return rule
