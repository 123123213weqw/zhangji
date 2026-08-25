-- [ts]: Input.ts
local ____exports = {} -- 1
local ____InputManager = require("InputManager") -- 2
local CreateManager = ____InputManager.CreateManager -- 2
local Trigger = ____InputManager.Trigger -- 2
--- Actions are intentionally expressed in Dora's standard controller names.
-- The R36S SDL mapping and the desktop virtual pad both produce these names,
-- so game code never needs to know Linux js0 button numbers.
____exports.inputManager = CreateManager({Lab = { -- 9
	Up = Trigger.Down({{key = "Up"}, {button = "dpup"}}), -- 11
	Down = Trigger.Down({{key = "Down"}, {button = "dpdown"}}), -- 15
	Left = Trigger.Down({{key = "Left"}, {button = "dpleft"}}), -- 19
	Right = Trigger.Down({{key = "Right"}, {button = "dpright"}}), -- 23
	A = Trigger.Down({{key = "J"}, {button = "a"}}), -- 27
	B = Trigger.Down({{key = "K"}, {button = "b"}}), -- 28
	X = Trigger.Down({{key = "U"}, {button = "x"}}), -- 29
	Y = Trigger.Down({{key = "I"}, {button = "y"}}), -- 30
	L1 = Trigger.Down({{key = "Q"}, {button = "leftshoulder"}}), -- 31
	R1 = Trigger.Down({{key = "E"}, {button = "rightshoulder"}}), -- 35
	L3 = Trigger.Down({{key = "Z"}, {button = "leftstick"}}), -- 39
	R3 = Trigger.Down({{key = "C"}, {button = "rightstick"}}), -- 43
	Select = Trigger.Down({{key = "Escape"}, {button = "back"}}), -- 47
	Start = Trigger.Down({{key = "Return"}, {button = "start"}}) -- 51
}}) -- 51
--- Dora exposes L2/R2 as controller axes rather than ButtonName values. These
-- helpers make keyboard presses behave exactly like the virtual trigger pad.
function ____exports.installKeyboardAxes() -- 62
	local node = ____exports.inputManager:getNode() -- 63
	node:onKeyDown(function(keyName) -- 64
		repeat -- 64
			local ____switch4 = keyName -- 64
			local ____cond4 = ____switch4 == "W" -- 64
			if ____cond4 then -- 64
				____exports.inputManager:emitAxis("lefty", 1) -- 67
				break -- 68
			end -- 68
			____cond4 = ____cond4 or ____switch4 == "S" -- 68
			if ____cond4 then -- 68
				____exports.inputManager:emitAxis("lefty", -1) -- 70
				break -- 71
			end -- 71
			____cond4 = ____cond4 or ____switch4 == "A" -- 71
			if ____cond4 then -- 71
				____exports.inputManager:emitAxis("leftx", -1) -- 73
				break -- 74
			end -- 74
			____cond4 = ____cond4 or ____switch4 == "D" -- 74
			if ____cond4 then -- 74
				____exports.inputManager:emitAxis("leftx", 1) -- 76
				break -- 77
			end -- 77
			____cond4 = ____cond4 or ____switch4 == "1" -- 77
			if ____cond4 then -- 77
				____exports.inputManager:emitAxis("lefttrigger", 1) -- 79
				break -- 80
			end -- 80
			____cond4 = ____cond4 or ____switch4 == "3" -- 80
			if ____cond4 then -- 80
				____exports.inputManager:emitAxis("righttrigger", 1) -- 82
				break -- 83
			end -- 83
		until true -- 83
	end) -- 64
	node:onKeyUp(function(keyName) -- 87
		repeat -- 87
			local ____switch6 = keyName -- 87
			local ____cond6 = ____switch6 == "W" or ____switch6 == "S" -- 87
			if ____cond6 then -- 87
				____exports.inputManager:emitAxis("lefty", 0) -- 91
				break -- 92
			end -- 92
			____cond6 = ____cond6 or (____switch6 == "A" or ____switch6 == "D") -- 92
			if ____cond6 then -- 92
				____exports.inputManager:emitAxis("leftx", 0) -- 95
				break -- 96
			end -- 96
			____cond6 = ____cond6 or ____switch6 == "1" -- 96
			if ____cond6 then -- 96
				____exports.inputManager:emitAxis("lefttrigger", 0) -- 98
				break -- 99
			end -- 99
			____cond6 = ____cond6 or ____switch6 == "3" -- 99
			if ____cond6 then -- 99
				____exports.inputManager:emitAxis("righttrigger", 0) -- 101
				break -- 102
			end -- 102
		until true -- 102
	end) -- 87
end -- 62
return ____exports -- 62