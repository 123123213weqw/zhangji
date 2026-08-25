-- [ts]: Input.ts
local ____exports = {} -- 1
local ____InputManager = require("InputManager") -- 2
local CreateManager = ____InputManager.CreateManager -- 2
local Trigger = ____InputManager.Trigger -- 2
--- Actions are intentionally expressed in Dora's standard controller names.
-- The R36S SDL mapping and the desktop virtual pad both produce these names,
-- so game code never needs to know Linux js0 button numbers.
____exports.INPUT_CONTEXT = "Game" -- 9
____exports.inputManager = CreateManager({[____exports.INPUT_CONTEXT] = { -- 11
	Up = Trigger.Down({{key = "Up"}, {button = "dpup"}}), -- 13
	Down = Trigger.Down({{key = "Down"}, {button = "dpdown"}}), -- 17
	Left = Trigger.Down({{key = "Left"}, {button = "dpleft"}}), -- 21
	Right = Trigger.Down({{key = "Right"}, {button = "dpright"}}), -- 25
	A = Trigger.Down({{key = "J"}, {key = "Space"}, {button = "a"}}), -- 29
	B = Trigger.Down({{key = "K"}, {key = "LShift"}, {button = "b"}}), -- 34
	X = Trigger.Down({{key = "U"}, {button = "x"}}), -- 39
	Y = Trigger.Down({{key = "I"}, {button = "y"}}), -- 40
	L1 = Trigger.Down({{key = "Q"}, {button = "leftshoulder"}}), -- 41
	R1 = Trigger.Down({{key = "E"}, {button = "rightshoulder"}}), -- 45
	L3 = Trigger.Down({{key = "Z"}, {button = "leftstick"}}), -- 49
	R3 = Trigger.Down({{key = "C"}, {button = "rightstick"}}), -- 53
	Select = Trigger.Down({{key = "Escape"}, {button = "back"}}), -- 57
	Start = Trigger.Down({{key = "Return"}, {button = "start"}}) -- 61
}}) -- 61
--- Dora exposes L2/R2 as controller axes rather than ButtonName values. These
-- helpers make keyboard presses behave exactly like the virtual trigger pad.
function ____exports.installKeyboardAxes() -- 72
	local node = ____exports.inputManager:getNode() -- 73
	node:onKeyDown(function(keyName) -- 74
		repeat -- 74
			local ____switch4 = keyName -- 74
			local ____cond4 = ____switch4 == "W" -- 74
			if ____cond4 then -- 74
				____exports.inputManager:emitAxis("lefty", 1) -- 77
				break -- 78
			end -- 78
			____cond4 = ____cond4 or ____switch4 == "S" -- 78
			if ____cond4 then -- 78
				____exports.inputManager:emitAxis("lefty", -1) -- 80
				break -- 81
			end -- 81
			____cond4 = ____cond4 or ____switch4 == "A" -- 81
			if ____cond4 then -- 81
				____exports.inputManager:emitAxis("leftx", -1) -- 83
				break -- 84
			end -- 84
			____cond4 = ____cond4 or ____switch4 == "D" -- 84
			if ____cond4 then -- 84
				____exports.inputManager:emitAxis("leftx", 1) -- 86
				break -- 87
			end -- 87
			____cond4 = ____cond4 or ____switch4 == "T" -- 87
			if ____cond4 then -- 87
				____exports.inputManager:emitAxis("righty", 1) -- 89
				break -- 90
			end -- 90
			____cond4 = ____cond4 or ____switch4 == "G" -- 90
			if ____cond4 then -- 90
				____exports.inputManager:emitAxis("righty", -1) -- 92
				break -- 93
			end -- 93
			____cond4 = ____cond4 or ____switch4 == "F" -- 93
			if ____cond4 then -- 93
				____exports.inputManager:emitAxis("rightx", -1) -- 95
				break -- 96
			end -- 96
			____cond4 = ____cond4 or ____switch4 == "H" -- 96
			if ____cond4 then -- 96
				____exports.inputManager:emitAxis("rightx", 1) -- 98
				break -- 99
			end -- 99
			____cond4 = ____cond4 or ____switch4 == "1" -- 99
			if ____cond4 then -- 99
				____exports.inputManager:emitAxis("lefttrigger", 1) -- 101
				break -- 102
			end -- 102
			____cond4 = ____cond4 or ____switch4 == "3" -- 102
			if ____cond4 then -- 102
				____exports.inputManager:emitAxis("righttrigger", 1) -- 104
				break -- 105
			end -- 105
		until true -- 105
	end) -- 74
	node:onKeyUp(function(keyName) -- 109
		repeat -- 109
			local ____switch6 = keyName -- 109
			local ____cond6 = ____switch6 == "W" or ____switch6 == "S" -- 109
			if ____cond6 then -- 109
				____exports.inputManager:emitAxis("lefty", 0) -- 113
				break -- 114
			end -- 114
			____cond6 = ____cond6 or (____switch6 == "A" or ____switch6 == "D") -- 114
			if ____cond6 then -- 114
				____exports.inputManager:emitAxis("leftx", 0) -- 117
				break -- 118
			end -- 118
			____cond6 = ____cond6 or (____switch6 == "T" or ____switch6 == "G") -- 118
			if ____cond6 then -- 118
				____exports.inputManager:emitAxis("righty", 0) -- 121
				break -- 122
			end -- 122
			____cond6 = ____cond6 or (____switch6 == "F" or ____switch6 == "H") -- 122
			if ____cond6 then -- 122
				____exports.inputManager:emitAxis("rightx", 0) -- 125
				break -- 126
			end -- 126
			____cond6 = ____cond6 or ____switch6 == "1" -- 126
			if ____cond6 then -- 126
				____exports.inputManager:emitAxis("lefttrigger", 0) -- 128
				break -- 129
			end -- 129
			____cond6 = ____cond6 or ____switch6 == "3" -- 129
			if ____cond6 then -- 129
				____exports.inputManager:emitAxis("righttrigger", 0) -- 131
				break -- 132
			end -- 132
		until true -- 132
	end) -- 109
end -- 72
return ____exports -- 72