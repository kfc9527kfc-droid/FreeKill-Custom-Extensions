local fms__yueshu = fk.CreateSkill{
  name = "fms__yueshu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__yueshu"] = "约束",
  [":fms__yueshu"] = "锁定技，每回合内，你使用过的非锁定技于本回合内失效；其它角色死亡时，你失去所有手牌。",
}

local fms__yueshu_excluded = {
  ["fms__chaobiao"] = true,
  ["fms__gaowan"] = true,
  ["fms__xinhuoxiangchuan"] = true,
  ["fms__yueshu"] = true,
}

local fms__all_record_skills = {
  "jianxiong", "hujia", "guicai", "fankui", "ganglie", "tuxi", "yiji", "luoshen",
  "rende", "jijiang", "wusheng", "guanxing", "longdan", "tieqi", "jizhi", "qicai",
  "zhiheng", "jiuyuan", "qixi", "keji", "kurou", "yingzi", "fanjian", "guose", "liuli", "qianxun",  "xiaoji", "jieyin",
  "qingnang", "jijiu", "wushuang", "lijian", "biyue",
  "fms__chaobiao", "fms__gaowan", "fms__xinhuoxiangchuan", "fms__yueshu",
}

local function fms__isExcludedSkill(skill_name)
  return fms__yueshu_excluded[skill_name] == true
end

local function fms__isNonCompulsorySkill(skill)
  if not skill then return false end
  return not skill:hasTag(Skill.Compulsory)
end

local function fms__getTurnInvalidMark(skill_name)
  return "_fms__yueshu_invalid_" .. skill_name
end

local function fms__clearYueshuMarks(room, player)
  for _, skill_name in ipairs(fms__all_record_skills) do
    room:setPlayerMark(player, fms__getTurnInvalidMark(skill_name), 0)
  end
end

-- 你的回合开始时，清空本回合“已失效”记录
fms__yueshu:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    fms__clearYueshuMarks(player.room, player)
  end,
})

-- 你发动过一次的非锁定技，本回合内立即失效
fms__yueshu:addEffect(fk.AfterSkillEffect, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) then
      return false
    end
    if not data or not data.skill then
      return false
    end

    local skill = data.skill
    if not skill.name then
      return false
    end
    if fms__isExcludedSkill(skill.name) then
      return false
    end
    if not fms__isNonCompulsorySkill(skill) then
      return false
    end

    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skill = data.skill
    room:setPlayerMark(player, fms__getTurnInvalidMark(skill.name), 1)
  end,
})

fms__yueshu:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    if not from or not skill or not skill.name then
      return false
    end
    if skill.name == "fms__yueshu" then
      return false
    end
    if fms__isExcludedSkill(skill.name) then
      return false
    end
    if not fms__isNonCompulsorySkill(skill) then
      return false
    end

    return from:getMark(fms__getTurnInvalidMark(skill.name)) > 0
  end,
})

-- 一名角色死亡时，你失去所有手牌
fms__yueshu:addEffect(fk.Death, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not player.dead and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(player:getCardIds("h"), self.name, player, player)
  end,
})

return fms__yueshu
