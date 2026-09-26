local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local fms__enchant = fk.CreateSkill{
  name = "fms__enchant",
}

Fk:loadTranslationTable{
  ["fms__enchant"] = "附魔",
  [":fms__enchant"] = "出牌阶段，你可以弃置X张牌，对【钻石剑】或【钻石甲】进行附魔（X为本回合此技能已发动次数+1）。每件装备至多保留3个附魔；若已满3个，则改为用新附魔替换其中一个。你的【钻石剑】或【钻石甲】销毁后，你摸Y张牌（Y为其附魔数）。",
  ["#fms__enchant-discard"] = "附魔：弃置 %arg 张牌，然后选择【钻石剑】或【钻石甲】进行附魔",
  ["#fms__enchant-choose-equip"] = "附魔：请选择要附魔的装备",
  ["#fms__enchant-replace"] = "附魔：该装备已有3层附魔，请选择要替换的附魔（新附魔为 %arg）",
  ["#fms__enchant-get"] = "附魔：%from 的 %arg 获得了附魔 %arg2",
}

fms__enchant:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fms__enchant_used-turn", 0)
  end,
})

fms__enchant:addEffect("active", {
  anim_type = "special",
  prompt = "#fms__enchant-choose-equip",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    local x = player:getMark("fms__enchant_used-turn") + 1
    return #common.getEnchantableChoices(player) > 0 and #player:getCardIds("he") >= x
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local x = player:getMark("fms__enchant_used-turn") + 1

    local cards = room:askToCards(player, {
      min_num = x,
      max_num = x,
      include_equip = true,
      cancelable = true,
      skill_name = self.name,
      prompt = "#fms__enchant-discard:::" .. tostring(x),
    })
    if #cards ~= x then
      return
    end

    local choices = common.getEnchantableChoices(player)
    if #choices == 0 then
      return
    end

    local choice = choices[1]
    if #choices > 1 then
      choice = room:askToChoice(player, {
        choices = choices,
        skill_name = self.name,
        prompt = "#fms__enchant-choose-equip",
      })
    end
    if not choice then
      return
    end

    local equip = common.getCardByChoice(player, choice)
    if not equip then
      return
    end

    room:throwCard(cards, self.name, player, player)
    if player.dead then
      return
    end

    local new_buff = common.randomBuff(equip)
    if not new_buff then
      return
    end

    if common.countBuffs(equip) >= 3 then
      local current = common.getCurrentBuffs(equip)
      local replace = room:askToChoice(player, {
        choices = current,
        skill_name = self.name,
        prompt = "#fms__enchant-replace:::" .. Fk:translate(new_buff),
      })
      if replace then
        room:setCardMark(equip, replace, 0)
      end
    end

    room:setCardMark(equip, new_buff, 1)
    room:setPlayerMark(player, "fms__enchant_used-turn", x)
    common.refreshDiamondBuffSkills(room, player)

    room:sendLog{
      type = "#fms__enchant-get",
      from = player.id,
      arg = Fk:translate(equip.trueName),
      arg2 = Fk:translate(new_buff),
      toast = true,
    }
  end,
})

fms__enchant:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or player.dead then
      return false
    end

    for _, move in ipairs(data) do
      if move.from == player and move.toArea == Card.Void then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and common.isDiamondEquip(card) and info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.from == player and move.toArea == Card.Void then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and common.isDiamondEquip(card) and info.fromArea == Card.PlayerEquip then
            n = n + common.countBuffs(card)
          end
        end
      end
    end

    if n > 0 then
      player:drawCards(n, self.name)
    end

    common.refreshDiamondBuffSkills(player.room, player)
  end,
})

return fms__enchant
