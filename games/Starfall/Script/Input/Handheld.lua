-- [ts]: Handheld.ts
local ____exports = {} -- 1
local ____InputManager = require("InputManager") -- 2
local CreateManager = ____InputManager.CreateManager -- 2
local Trigger = ____InputManager.Trigger -- 2
local CONTEXT = "Starfall" -- 9
function ____exports.installHandheldInput(actions) -- 11
	local manager = CreateManager({[CONTEXT] = { -- 12
		Primary = Trigger.Down({button = "a"}), -- 14
		Pause = Trigger.Down({{button = "start"}, {button = "back"}}), -- 15
		Restart = Trigger.Down({button = "x"}) -- 19
	}}) -- 19
	local node = manager:getNode() -- 22
	local leftX = 0 -- 23
	local leftY = 0 -- 24
	local rightX = 0 -- 25
	local rightY = 0 -- 26
	manager:onCompleted( -- 28
		"Primary", -- 28
		function() return actions:queuePrimary() end -- 28
	) -- 28
	manager:onCompleted( -- 29
		"Pause", -- 29
		function() return actions:queuePause() end -- 29
	) -- 29
	manager:onCompleted( -- 30
		"Restart", -- 30
		function() return actions:queueRestart() end -- 30
	) -- 30
	node:onButtonDown(function(_controllerId, buttonName) -- 32
		repeat -- 32
			local ____switch7 = buttonName -- 32
			local ____cond7 = ____switch7 == "dpleft" -- 32
			if ____cond7 then -- 32
				actions:setDirection("left", true) -- 34
				break -- 34
			end -- 34
			____cond7 = ____cond7 or ____switch7 == "dpright" -- 34
			if ____cond7 then -- 34
				actions:setDirection("right", true) -- 35
				break -- 35
			end -- 35
			____cond7 = ____cond7 or ____switch7 == "dpup" -- 35
			if ____cond7 then -- 35
				actions:setDirection("up", true) -- 36
				break -- 36
			end -- 36
			____cond7 = ____cond7 or ____switch7 == "dpdown" -- 36
			if ____cond7 then -- 36
				actions:setDirection("down", true) -- 37
				break -- 37
			end -- 37
		until true -- 37
	end) -- 32
	node:onButtonUp(function(_controllerId, buttonName) -- 40
		repeat -- 40
			local ____switch9 = buttonName -- 40
			local ____cond9 = ____switch9 == "dpleft" -- 40
			if ____cond9 then -- 40
				actions:setDirection("left", false) -- 42
				break -- 42
			end -- 42
			____cond9 = ____cond9 or ____switch9 == "dpright" -- 42
			if ____cond9 then -- 42
				actions:setDirection("right", false) -- 43
				break -- 43
			end -- 43
			____cond9 = ____cond9 or ____switch9 == "dpup" -- 43
			if ____cond9 then -- 43
				actions:setDirection("up", false) -- 44
				break -- 44
			end -- 44
			____cond9 = ____cond9 or ____switch9 == "dpdown" -- 44
			if ____cond9 then -- 44
				actions:setDirection("down", false) -- 45
				break -- 45
			end -- 45
		until true -- 45
	end) -- 40
	node:onAxis(function(_controllerId, axisName, value) -- 48
		repeat -- 48
			local ____switch11 = axisName -- 48
			local ____cond11 = ____switch11 == "leftx" -- 48
			if ____cond11 then -- 48
				leftX = value -- 50
				break -- 50
			end -- 50
			____cond11 = ____cond11 or ____switch11 == "lefty" -- 50
			if ____cond11 then -- 50
				leftY = value -- 51
				break -- 51
			end -- 51
			____cond11 = ____cond11 or ____switch11 == "rightx" -- 51
			if ____cond11 then -- 51
				rightX = value -- 52
				break -- 52
			end -- 52
			____cond11 = ____cond11 or ____switch11 == "righty" -- 52
			if ____cond11 then -- 52
				rightY = value -- 53
				break -- 53
			end -- 53
		until true -- 53
		actions:setLeftAxis(leftX, leftY) -- 55
		actions:setRightAxis(rightX, rightY) -- 56
	end) -- 48
	manager:pushContext(CONTEXT) -- 58
	return {manager = manager} -- 59
end -- 11
return ____exports -- 11