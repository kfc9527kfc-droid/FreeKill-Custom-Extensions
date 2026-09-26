local U = require "packages.utility.utility"
local common = require "packages.fanmoushuo.pkg.diamond_enchant_common"

local fms__diamond = fk.CreateSkill{
  name = "fms__diamond",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__diamond"] = "钻石",
  [":fms__diamond"] = "锁定技，准备阶段，若你的装备区没有【钻石剑】或【钻石甲】，你将对应牌置入你的装备区。",
}

local function getAvailableDeriveId(room, ids)
  for _, id in ipairs(ids) do
    if room:getCardArea(id) == Card.Void then
      return id
    end
  end
  return nil
end

local function putOneIntoEquip(room, player, name, suit, number, derive_key, skill_name)
  local ids = U.prepareDeriveCards(room, {
    { name, suit, number },
  }, derive_key)

  local id = getAvailableDeriveId(room, ids)
  if id then
    room:moveCardIntoEquip(player, id, skill_name, true, player)
  end
end

fms__diamond:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    if not common.findDiamondSwordId(player) then
      putOneIntoEquip(room, player, "fms__diamond_sword", Card.diamond, 6, "fms__diamond_sword_derive", self.name)
    end

    if not common.findDiamondArmorId(player) then
      putOneIntoEquip(room, player, "fms__diamond_armor", Card.diamond, 6, "fms__diamond_armor_derive", self.name)
    end

    common.refreshDiamondBuffSkills(room, player)
  end,
})

return fms__diamond
