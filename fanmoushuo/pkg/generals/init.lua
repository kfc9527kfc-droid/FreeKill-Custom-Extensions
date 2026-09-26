local extension = Package:new("fanmoushuo_generals", Package.GeneralPack)
extension.extensionName = "fanmoushuo"

extension:loadSkillSkelsByPath("./packages/fanmoushuo/pkg/generals/skills")
extension:loadSkillSkelsByPath("./packages/fanmoushuo/pkg/cards/skills")


Fk:loadTranslationTable{
    ["fanmoushuo"] = "凡某说",
    ["fanmoushuo_generals"] = "凡某说",

    ["fms__daichengxu"] = "戴承旭",
    ["#fms__daichengxu"] = "太阳刚刚升起",
    ["designer:fms__daichengxu"] = "凡某",
    ["illustrator:fms__daichengxu"] = "戴承旭",
    ["cv:fms__daichengxu"] = "戴承旭",
    ["~fms__daichengxu"] = "我 不想 道别~道别！",

    ["fms__daichengxu_awaken"] = "戴承旭",
    ["#fms__daichengxu_awaken"] = "孩子长大了",
    ["designer:fms__daichengxu_awaken"] = "凡某",
    ["illustrator:fms__daichengxu_awaken"] = "戴承旭",
    ["cv:fms__daichengxu_awaken"] = "戴承旭",
    ["~fms__daichengxu_awaken"] = "总会有，更亮的时候。",
    
    ["$fms__bieji"] = "别急的技能台词",
    ["$fms__a_question"] = "babybabybaby",
    ["$fms__budui"] = "我从来没想过~我会这样做",
}

local daichengxu = General:new(
    extension,
    "fms__daichengxu",
    "god",
    6,
    6,
    General.Male
)

daichengxu:addSkills{"fms__bieji", "fms__a_question", "fms__budui", "fms__growth"}

local daichengxu_awaken = General:new(
    extension,
    "fms__daichengxu_awaken",
    "god",
    3,
    3,
    General.Male
)

daichengxu_awaken:addSkills{"fms__diamond", "fms__enchant"}
daichengxu_awaken.hidden = true

Fk:loadTranslationTable{
    ["fms__hurongjun"] = "胡荣君",
    ["#fms__hurongjun"] = "我从不红温",
    ["~fms__hurongjun"] = "",
    ["designer:fms__hurongjun"] = "凡某",
    ["illustrator:fms__hurongjun"] = "暂无",
    ["cv:fms__hurongjun"] = "暂无",
}

local hurongjun = General:new(
    extension,
    "fms__hurongjun",
    "god",
    4,
    4,
    General.Male
)

hurongjun:addSkills{"fms__bababoyi", "fms__junlintianxia"}

Fk:loadTranslationTable{
    ["fms__huangzhongtian"] = "黄中天",
    ["#fms__huangzhongtian"] = "The King of Shit",
    ["~fms__huangzhongtian"] = "这次……真要去厕所了……",
    ["designer:fms__huangzhongtian"] = "凡某",
    ["illustrator:fms__huangzhongtian"] = "黄师傅",
    ["cv:fms__huangzhongtian"] = "征集ing",
}

local huangzhongtian = General:new(
    extension,
    "fms__huangzhongtian",
    "god",
    7,
    7,
    General.Male
)

huangzhongtian:addSkills{"fms__ruce", "fms__ruguo", "fms__chouzhi"}
huangzhongtian:addRelatedSkills{"fms__ruri"}

Fk:loadTranslationTable{
    ["fms__caojunkai"] = "曹俊恺",
    ["#fms__caojunkai"] = "睡教教主",
    ["~fms__caojunkai"] = "我先……睡了……",
    ["designer:fms__caojunkai"] = "凡某",
    ["illustrator:fms__caojunkai"] = "佚名",
    ["cv:fms__caojunkai"] = "暂无",
}

local caojunkai = General:new(
    extension,
    "fms__caojunkai",
    "god",
    3,
    3,
    General.Male
)

caojunkai:addSkills{"fms__kunle", "fms__leile", "#fms__leile_give", "fms__qiaole"}

Fk:loadTranslationTable{
    ["fms__liyang"] = "李师傅",
    ["#fms__liyang"] = "书记",
    ["~fms__liyang"] = "下回再见",
    ["designer:fms__liyang"] = "凡某",
    ["illustrator:fms__caojunkai"] = "佚名",
    ["cv:fms__caojunkai"] = "暂无",
}

local liyang = General:new(
    extension,
    "fms__liyang",
    "god",
    5,
    5,
    General.Male
)

liyang:addSkills{"fms__busuan", "fms__shuji", "fms__yanyi", "#fms__yanyi_control"}

Fk:loadTranslationTable{
    ["fms__cailixiang"] = "蔡利翔",
    ["#fms__cailixiang"] = "卷王",
    ["~fms__cailixiang"] = "……",
    ["designer:fms__cailixiang"] = "凡某",
    ["illustrator:fms__cailixiang"] = "暂无",
    ["cv:fms__cailixiang"] = "暂无",
}

local cailixiang = General:new(
    extension,
    "fms__cailixiang",
    "god",
    2,
    2,
    General.Male
)

cailixiang:addSkills{"fms__daodun", "fms__manba", "fms__shejiweiren", "fms__buquzaiqi"}


Fk:loadTranslationTable{
  ["fms__guohaoyu"] = "郭浩宇",
  ["#fms__guohaoyu"] = "那个男人",
  ["illustrator:fms__guohaoyu"] = "凡某",

  ["fms__guohaoyu_wei"] = "郭浩宇",
  ["#fms__guohaoyu_wei"] = "那个男人",
  ["illustrator:fms__guohaoyu_wei"] = "凡某",

  ["fms__guohaoyu_shu"] = "郭浩宇",
  ["#fms__guohaoyu_shu"] = "那个男人",
  ["illustrator:fms__guohaoyu_shu"] = "凡某",

  ["fms__guohaoyu_wu"] = "郭浩宇",
  ["#fms__guohaoyu_wu"] = "那个男人",
  ["illustrator:fms__guohaoyu_wu"] = "凡某",

  ["fms__guohaoyu_qun"] = "郭浩宇",
  ["#fms__guohaoyu_qun"] = "那个男人",
  ["illustrator:fms__guohaoyu_qun"] = "凡某",

  ["~fms__guohaoyu"] = "我怎么什么都会一点……",
  ["!fms__guohaoyu"] = "天下技法，尽入我手！",
}

local guohaoyu = General:new(extension, "fms__guohaoyu", "god", 8)
guohaoyu:addSkills { "fms__chaobiao", "fms__gaowan", "fms__xinhuoxiangchuan", "fms__yueshu"}

local guohaoyu_wei = General:new(extension, "fms__guohaoyu_wei", "wei", 8)
guohaoyu_wei:addSkills { "fms__chaobiao", "fms__gaowan", "fms__xinhuoxiangchuan", "fms__yueshu"}
guohaoyu_wei.hidden = true

local guohaoyu_shu = General:new(extension, "fms__guohaoyu_shu", "shu", 8)
guohaoyu_shu:addSkills { "fms__chaobiao", "fms__gaowan", "fms__xinhuoxiangchuan", "fms__yueshu"}
guohaoyu_shu.hidden = true

local guohaoyu_wu = General:new(extension, "fms__guohaoyu_wu", "wu", 8)
guohaoyu_wu:addSkills { "fms__chaobiao", "fms__gaowan", "fms__xinhuoxiangchuan", "fms__yueshu"}
guohaoyu_wu.hidden = true

local guohaoyu_qun = General:new(extension, "fms__guohaoyu_qun", "qun", 8)
guohaoyu_qun:addSkills { "fms__chaobiao", "fms__gaowan", "fms__xinhuoxiangchuan", "fms__yueshu"}
guohaoyu_qun.hidden = true

Fk:loadTranslationTable{
    ["fms__caikefan"] = "蔡可凡",
    ["#fms__caikefan"] = "没经济没建模",
    ["~fms__caikefan"] = "……",
    ["designer:fms__caikefan"] = "凡某",
    ["illustrator:fms__caikefan"] = "暂无",
    ["cv:fms__caikefan"] = "暂无",
}

local caikefan = General:new(
    extension,
    "fms__caikefan",
    "god",
    1,
    1,
    General.Male
)

caikefan:addSkills{"fms__fastfood", "fms__vmefifty", "fms__family_bucket"}

return extension
