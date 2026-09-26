local cards = require "packages.fanmoushuo.pkg.cards"
local generals = require "packages.fanmoushuo.pkg.generals"

-- SPDX-License-Identifier: GPL-3.0-or-later

local modes = Package:new("ofl__gamemode", Package.SpecialPack)

modes:loadSkillSkelsByPath("./packages/fanmoushuo/pkg/gamemodes/rule_skills")

modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.sgsh_mode")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.ofl_taixu_mode")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.infernal_affairs")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.insanity_mode")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.loyal_traitor")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.tyrannical_mode")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.arrow_of_tactics")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.alliance_vs_landlord")
modes:addGameMode(require "packages.fanmoushuo.pkg.gamemodes.each_scheming")


Fk:loadTranslationTable {
  ["fanmoushuo"] = "凡某说",
  ["ofl__gamemode"] = "线下游戏模式",
}

return {
  modes,
  cards,
  generals,
}
