-- [ts]: TargetProfile.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Size = ____Dora.Size -- 1
function ____exports.desktopProfile() -- 13
	return { -- 14
		kind = "desktop", -- 15
		width = 960, -- 16
		height = 640, -- 17
		showVirtualPad = false, -- 18
		controls = "WASD / ARROWS MOVE   MOUSE AIM   CLICK / SPACE DASH   P PAUSE   R RESTART" -- 19
	} -- 19
end -- 13
function ____exports.handheldProfile() -- 23
	return { -- 24
		kind = "handheld", -- 25
		width = 640, -- 26
		height = 480, -- 27
		showVirtualPad = App.platform == "macOS" or App.platform == "Windows", -- 28
		controls = "LEFT STICK / DPAD MOVE   RIGHT STICK AIM   A DASH   START PAUSE   X RESTART" -- 29
	} -- 29
end -- 23
function ____exports.applyTargetProfile(profile) -- 33
	App.targetFPS = 60 -- 34
	if App.platform == "macOS" or App.platform == "Windows" then -- 34
		App.fullScreen = false -- 36
		App.winSize = Size(profile.width, profile.height) -- 37
	end -- 37
end -- 33
return ____exports -- 33