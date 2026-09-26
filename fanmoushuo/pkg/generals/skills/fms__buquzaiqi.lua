local buquzaiqi = fk.CreateSkill{
  name = "fms__buquzaiqi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["fms__buquzaiqi"] = "不屈再起",
  [":fms__buquzaiqi"] = "限定技，当你处于濒死状态时，你可以选择至多三名其他角色，这些角色依次可以选择是否交给你一张手牌，然后你将体力值与体力上限调整至X（X为你以此法获得的手牌数），这些以此法给你牌的角色各回复1点体力，你对其余其他角色各造成1点伤害；洗牌时，此技能重置。<br>"..
  "[“别怕，我有被动”]",

  ["#fms__buquzaiqi-choose"] = "不屈再起：选择至多三名其他角色",
  ["#fms__buquzaiqi-give:%src"] = "不屈再起：你可以交给 %src 一张手牌",
}

buquzaiqi:addEffect(fk.AskForPeaches, {
  anim_type = "defensive",

  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(self.name) and
      player.dying and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room

    local tos = room:askToChoosePlayers(player, {
      targets = table.filter(room.alive_players, function(p)
        return p ~= player
      end),
      min_num = 0,
      max_num = 3,
      prompt = "#fms__buquzaiqi-choose",
      skill_name = self.name,
      cancelable = true,
    })

    if #tos == 0 then
      return
    end

    local givers = {}
    local obtained = 0

    for _, p in ipairs(tos) do
      if not p.dead and not player.dead and #p:getCardIds("h") > 0 then
        local cards = room:askToCards(p, {
          min_num = 0,
          max_num = 1,
          include_equip = false,
          skill_name = self.name,
          pattern = ".|.|.|hand",
          prompt = "#fms__buquzaiqi-give:" .. player.id,
          cancelable = true,
        })

        if #cards > 0 then
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, p)
          if not p.dead then
            table.insert(givers, p)
          end
          obtained = obtained + 1
        end
      end
    end

    if player.dead then
      return
    end

    local x = obtained

    if player.maxHp ~= x then
      room:changeMaxHp(player, x - player.maxHp)
      if player.dead then
        return
      end
    end

    if player.hp ~= x then
      if player.hp < x then
        room:recover{
          who = player,
          num = x - player.hp,
          recoverBy = player,
          skillName = self.name,
        }
      elseif player.hp > x then
        room:loseHp(player, player.hp - x, self.name)
      end
      if player.dead then
        return
      end
    end

    for _, p in ipairs(givers) do
      if not p.dead and p:isWounded() then
        room:recover{
          who = p,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    end

    for _, p in ipairs(room.alive_players) do
      if p ~= player and not table.contains(givers, p) then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
})

buquzaiqi:addEffect(fk.AfterDrawPileShuffle, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name, true)
  end,

  on_refresh = function(self, event, target, player, data)
    player:setSkillUseHistory(self.name, 0, Player.HistoryGame)
  end,
})

return buquzaiqi
