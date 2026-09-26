local fms__chaobiao = fk.CreateSkill{
  name = "fms__chaobiao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fms__chaobiao"] = "超标",
  [":fms__chaobiao"] = "锁定技，结束阶段，你减1点体力上限，然后变更势力（魏、蜀、吴、群中自选）。<br>"..
  "[“今天又要玩超标武将了”]",
  ["#fms__chaobiao-choice"] = "超标：请选择你要变更的势力",
}

local fms__form_map = {
  wei = "fms__guohaoyu_wei",
  shu = "fms__guohaoyu_shu",
  wu = "fms__guohaoyu_wu",
  qun = "fms__guohaoyu_qun",
}

local function fms__isGuohaoyuForm(name)
  return name == "fms__guohaoyu"
    or name == "fms__guohaoyu_wei"
    or name == "fms__guohaoyu_shu"
    or name == "fms__guohaoyu_wu"
    or name == "fms__guohaoyu_qun"
end

local function fms__changeGuohaoyuForm(room, player, kingdom)
  local new_general = fms__form_map[kingdom]
  if not new_general then return end

  if fms__isGuohaoyuForm(player.general) then
    player.general = new_general
    room:broadcastProperty(player, "general")
  elseif fms__isGuohaoyuForm(player.deputyGeneral) then
    player.deputyGeneral = new_general
    room:broadcastProperty(player, "deputyGeneral")
  end
end

fms__chaobiao:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(self.name)
      and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:changeMaxHp(player, -1)
    if player.dead then return end

    local choice = room:askToChoice(player, {
      choices = { "wei", "shu", "wu", "qun" },
      skill_name = self.name,
      prompt = "#fms__chaobiao-choice",
    })

    if player.kingdom ~= choice then
      room:changeKingdom(player, choice, true)
    end

    fms__changeGuohaoyuForm(room, player, choice)

    if not player.dead and player:hasSkill("fms__gaowan", true) then
      local all_skills = {
        "jianxiong", "hujia", "guicai", "fankui", "ganglie", "tuxi", "luoyi", "tiandu", "yiji", "luoshen", "qingguo",
        "rende", "jijiang", "wusheng", "paoxiao", "guanxing", "kongcheng", "longdan", "mashu", "tieqi", "jizhi", "qicai",
        "zhiheng", "jiuyuan", "qixi", "keji", "kurou", "yingzi", "fanjian", "guose", "liuli", "qianxun", "lianying", "xiaoji", "jieyin",
        "qingnang", "jijiu", "wushuang", "lijian", "biyue",
      }

      local kingdom_skill_map = {
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

      local changes = {}
      for _, skill in ipairs(all_skills) do
        table.insert(changes, "-" .. skill)
      end
      for _, skill in ipairs(kingdom_skill_map[choice] or {}) do
        table.insert(changes, skill)
      end

      room:handleAddLoseSkills(player, table.concat(changes, "|"), nil, false, true)
    end
  end,
})

return fms__chaobiao
