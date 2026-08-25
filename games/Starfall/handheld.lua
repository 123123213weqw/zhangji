-- [ts]: handheld.ts
local ____exports = {} -- 1
local ____Game = require("Script.Game") -- 1
local startGame = ____Game.startGame -- 1
local ____TargetProfile = require("Script.TargetProfile") -- 2
local handheldProfile = ____TargetProfile.handheldProfile -- 2
startGame(handheldProfile()) -- 4
return ____exports -- 4