local bieji = fk.CreateSkill{
    name = "fms__bieji",
    tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
    ["fms__bieji"] = "别急",
    [":fms__bieji"] = "锁定技。你的主动出牌时间固定为666秒。<br>"..
    "[“不要着急好吧”]",
}

bieji:addEffect(fk.StartPlayCard, {
    can_refresh = function(self, event, target, player, data)
        return target == player and player:hasSkill("fms__bieji")
    end,
    on_refresh = function(self, event, target, player, data)
        data.timeout = 666
    end,
})

return bieji
