-- [ts]: init.ts
local ____exports = {} -- 1
local ____Game = require("Script.Game") -- 1
local startGame = ____Game.startGame -- 1
local ____TargetProfile = require("Script.TargetProfile") -- 2
local desktopProfile = ____TargetProfile.desktopProfile -- 2
startGame(desktopProfile()) -- 4
return ____exports -- 4