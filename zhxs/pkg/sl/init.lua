local extension = Package:new("sl")
extension.extensionName = "zhxs"

extension:loadSkillSkelsByPath("./packages/zhxs/pkg/sl/skills")

local huluye = General:new(extension, "sl__huluye", "qun", 1)
huluye.maxHp = 1
huluye:addSkills { "sl__fuluwa", "sl__renzhi" }

Fk:loadTranslationTable{
  ["sl__huluye"] = "葫芦爷",
  ["#sl__huluye"] = "葫芦召唤师",
  --["illustrator:sl__huluye"] = "",
  ["~sl__huluye"] = "葫芦召唤师……但我还是不行了……",
}

local dawa = General:new(extension, "sl__dawa", "qun", 3)
dawa.maxHp = 7          -- 严格按您“3/7”要求：起始体力3，上限7
dawa.hidden = true
dawa:addSkills { "sl__dali", "sl__daxiao" }

Fk:loadTranslationTable{
  ["sl"] = "十万个冷笑话",
  ["sl__dawa"] = "大娃",
  ["#sl__dawa"] = "力大无穷",
  --["illustrator:sl__dawa"] = "",
  ["~sl__dawa"] = "力大无穷……但我还是不行了……",
}

local erwa = General:new(extension, "sl__erwa", "qun", 2)
erwa.maxHp = 2
erwa.hidden = true
erwa:addSkills { "sl__qianliyan", "sl__shunfenger" }

Fk:loadTranslationTable{
  ["sl__erwa"] = "二娃",
  ["#sl__erwa"] = "无所不知",
  --["illustrator:sl__erwa"] = "",
  ["~sl__erwa"] = "无所不知……但我还是不行了……",
}

local sanwa = General:new(extension, "sl__sanwa", "qun", 1)
sanwa.maxHp = 3
sanwa.hidden = true
sanwa:addSkills { "sl__tongtou", "sl__tiebi" }

Fk:loadTranslationTable{
  ["sl__sanwa"] = "三娃",
  ["#sl__sanwa"] = "刀枪不入",
  --["illustrator:sl__sanwa"] = "",
  ["~sl__sanwa"] = "刀枪不入……但我还是不行了……",
}

local siwawa = General:new(extension, "sl__siwawa", "qun", 4)
siwawa.maxHp = 5
siwawa.hidden = true
siwawa:addSkills { "sl__huowa", "sl__shuiwa" }

Fk:loadTranslationTable{
  ["sl__siwawa"] = "四/五娃",
  ["#sl__siwawa"] = "水火不容",
  --["illustrator:sl__siwawa"] = "",
  ["~sl__siwawa"] = "水火不容……但我还是不行了……",
}

local liuwa = General:new(extension, "sl__liuwa", "qun", 2)
liuwa.maxHp = 6
liuwa.hidden = true
liuwa:addSkills { "sl__wuying", "sl__wuzong" }

Fk:loadTranslationTable{
  ["sl__liuwa"] = "六娃",
  ["#sl__liuwa"] = "神出鬼没",
  --["illustrator:sl__liuwa"] = "",
  ["~sl__liuwa"] = "神出鬼没……但我还是不行了……",
}

local qiwa = General:new(extension, "sl__qiwa", "qun", 1)
qiwa.maxHp = 7
qiwa.hidden = true
qiwa:addSkills { "sl__baohulu" }

Fk:loadTranslationTable{
  ["sl__qiwa"] = "七娃",
  ["#sl__qiwa"] = "神器法宝",
  --["illustrator:sl__qiwa"] = "",
  ["~sl__qiwa"] = "神器法宝……但我还是不行了……",
}

local fuluxiaojingang = General:new(extension, "sl__fuluxiaojingang", "qun", 7)
fuluxiaojingang.maxHp = 7
fuluxiaojingang.hidden = true
fuluxiaojingang:addSkills { "sl__fulu", "sl__jiushu" }
fuluxiaojingang.shield = 7

Fk:loadTranslationTable{
  ["sl__fuluxiaojingang"] = "福禄小金刚",
  ["#sl__fuluxiaojingang"] = "时空管理者",
  --["illustrator:sl__fuluxiaojingang"] = "",
  ["~sl__fuluxiaojingang"] = "老婆大人叫我回家吃饭了",
}


local heshen = General:new(extension, "sl__heshen", "god", 2, 2)
heshen.shield = 2
heshen:addSkills{"sl__heshen","sl__jinheshen","sl__yinheshen",}

Fk:loadTranslationTable{
  ["sl__heshen"] = "银河也是河",
  ["#sl__heshen"] = "二次概念河神",
  ["~sl__heshen"] = "河……也是会干的……",
  ["designer:sl__heshen"] = "你",
  ["illustrator:sl__heshen"] = "佚名",
  ["cv:sl__heshen"] = "暂无",
}

return extension
