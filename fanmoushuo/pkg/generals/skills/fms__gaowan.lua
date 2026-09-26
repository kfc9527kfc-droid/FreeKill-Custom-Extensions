local fms__gaowan = fk.CreateSkill{
  name = "fms__gaowan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__gaowan"] = "高玩",
  [":fms__gaowan"] = "锁定技，你视为拥有标准包中与当前势力相同的所有武将技能。<br>"..
  "[“我避你锋芒？”]",
}

local fms__all_std_skills = {
  "jianxiong", "hujia", "guicai", "fankui", "ganglie", "tuxi", "luoyi", "tiandu", "yiji", "luoshen", "qingguo",
  "rende", "jijiang", "wusheng", "paoxiao", "guanxing", "kongcheng", "longdan", "mashu", "tieqi", "jizhi", "qicai",
  "zhiheng", "jiuyuan", "qixi", "keji", "kurou", "yingzi", "fanjian", "guose", "liuli", "qianxun", "lianying", "xiaoji", "jieyin",
  "qingnang", "jijiu", "wushuang", "lijian", "biyue",
}

local fms__kingdom_skill_map = {
  wei = {
    "jianxiong", "hujia", "guicai", "fankui", "ganglie", "tuxi", "luoyi", "tiandu", "yiji", "luoshen", "qingguo",
  },
  shu = {
    "rende", "jijiang", "wusheng", "paoxiao", "guanxing", "kongcheng", "longdan", "mashu", "tieqi", "jizhi", "qicai",
  },
  wu = {
    "zhiheng", "jiuyuan", "qixi", "keji", "kurou", "yingzi", "fanjian", "guose", "liuli", "qianxun", "lianying", "xiaoji", "jieyin",
  },
  qun = {
    "qingnang", "jijiu", "wushuang", "lijian", "biyue",
  },
}

local function fms__refreshGaowanSkills(room, player)
  if not player:hasSkill("fms__gaowan", true) then return end

  local changes = {}
  for _, skill in ipairs(fms__all_std_skills) do
    table.insert(changes, "-" .. skill)
  end
  for _, skill in ipairs(fms__kingdom_skill_map[player.kingdom] or {}) do
    table.insert(changes, skill)
  end

  room:handleAddLoseSkills(player, table.concat(changes, "|"), nil, false, true)
end

fms__gaowan:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    fms__refreshGaowanSkills(player.room, player)
  end,
})

return fms__gaowan
