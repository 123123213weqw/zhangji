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
	A = Trigger.Down({{key = "J"}, {key = "Space"}, {button = "a"}}), -- 27
	B = Trigger.Down({{key = "K"}, {key = "LShift"}, {button = "b"}}), -- 32
	X = Trigger.Down({{key = "U"}, {button = "x"}}), -- 37
	Y = Trigger.Down({{key = "I"}, {button = "y"}}), -- 38
	L1 = Trigger.Down({{key = "Q"}, {button = "leftshoulder"}}), -- 39
	R1 = Trigger.Down({{key = "E"}, {button = "rightshoulder"}}), -- 43
	L3 = Trigger.Down({{key = "Z"}, {button = "leftstick"}}), -- 47
	R3 = Trigger.Down({{key = "C"}, {button = "rightstick"}}), -- 51
	Select = Trigger.Down({{key = "Escape"}, {button = "back"}}), -- 55
	Start = Trigger.Down({{key = "Return"}, {button = "start"}}) -- 59
}}) -- 59
--- Dora exposes L2/R2 as controller axes rather than ButtonName values. These
-- helpers make keyboard presses behave exactly like the virtual trigger pad.
function ____exports.installKeyboardAxes() -- 70
	local node = ____exports.inputManager:getNode() -- 71
	node:onKeyDown(function(keyName) -- 72
		repeat -- 72
			local ____switch4 = keyName -- 72
			local ____cond4 = ____switch4 == "W" -- 72
			if ____cond4 then -- 72
				____exports.inputManager:emitAxis("lefty", 1) -- 75
				break -- 76
			end -- 76
			____cond4 = ____cond4 or ____switch4 == "S" -- 76
			if ____cond4 then -- 76
				____exports.inputManager:emitAxis("lefty", -1) -- 78
				break -- 79
			end -- 79
			____cond4 = ____cond4 or ____switch4 == "A" -- 79
			if ____cond4 then -- 79
				____exports.inputManager:emitAxis("leftx", -1) -- 81
				break -- 82
			end -- 82
			____cond4 = ____cond4 or ____switch4 == "D" -- 82
			if ____cond4 then -- 82
				____exports.inputManager:emitAxis("leftx", 1) -- 84
				break -- 85
			end -- 85
			____cond4 = ____cond4 or ____switch4 == "T" -- 85
			if ____cond4 then -- 85
				____exports.inputManager:emitAxis("righty", 1) -- 87
				break -- 88
			end -- 88
			____cond4 = ____cond4 or ____switch4 == "G" -- 88
			if ____cond4 then -- 88
				____exports.inputManager:emitAxis("righty", -1) -- 90
				break -- 91
			end -- 91
			____cond4 = ____cond4 or ____switch4 == "F" -- 91
			if ____cond4 then -- 91
				____exports.inputManager:emitAxis("rightx", -1) -- 93
				break -- 94
			end -- 94
			____cond4 = ____cond4 or ____switch4 == "H" -- 94
			if ____cond4 then -- 94
				____exports.inputManager:emitAxis("rightx", 1) -- 96
				break -- 97
			end -- 97
			____cond4 = ____cond4 or ____switch4 == "1" -- 97
			if ____cond4 then -- 97
				____exports.inputManager:emitAxis("lefttrigger", 1) -- 99
				break -- 100
			end -- 100
			____cond4 = ____cond4 or ____switch4 == "3" -- 100
			if ____cond4 then -- 100
				____exports.inputManager:emitAxis("righttrigger", 1) -- 102
				break -- 103
			end -- 103
		until true -- 103
	end) -- 72
	node:onKeyUp(function(keyName) -- 107
		repeat -- 107
			local ____switch6 = keyName -- 107
			local ____cond6 = ____switch6 == "W" or ____switch6 == "S" -- 107
			if ____cond6 then -- 107
				____exports.inputManager:emitAxis("lefty", 0) -- 111
				break -- 112
			end -- 112
			____cond6 = ____cond6 or (____switch6 == "A" or ____switch6 == "D") -- 112
			if ____cond6 then -- 112
				____exports.inputManager:emitAxis("leftx", 0) -- 115
				break -- 116
			end -- 116
			____cond6 = ____cond6 or (____switch6 == "T" or ____switch6 == "G") -- 116
			if ____cond6 then -- 116
				____exports.inputManager:emitAxis("righty", 0) -- 119
				break -- 120
			end -- 120
			____cond6 = ____cond6 or (____switch6 == "F" or ____switch6 == "H") -- 120
			if ____cond6 then -- 120
				____exports.inputManager:emitAxis("rightx", 0) -- 123
				break -- 124
			end -- 124
			____cond6 = ____cond6 or ____switch6 == "1" -- 124
			if ____cond6 then -- 124
				____exports.inputManager:emitAxis("lefttrigger", 0) -- 126
				break -- 127
			end -- 127
			____cond6 = ____cond6 or ____switch6 == "3" -- 127
			if ____cond6 then -- 127
				____exports.inputManager:emitAxis("righttrigger", 0) -- 129
				break -- 130
			end -- 130
		until true -- 130
	end) -- 107
end -- 70
return ____exports -- 70