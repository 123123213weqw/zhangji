-- [tsx]: init.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 4
local Director = ____Dora.Director -- 7
local Label = ____Dora.Label -- 9
local Size = ____Dora.Size -- 11
local ____DoraX = require("DoraX") -- 13
local React = ____DoraX.React -- 13
local toNode = ____DoraX.toNode -- 13
local ____InputManager = require("InputManager") -- 14
local GamePad = ____InputManager.GamePad -- 14
local ____Input = require("Script.Input") -- 15
local INPUT_CONTEXT = ____Input.INPUT_CONTEXT -- 15
local inputManager = ____Input.inputManager -- 15
local installKeyboardAxes = ____Input.installKeyboardAxes -- 15
if App.platform == "macOS" or App.platform == "Windows" then -- 15
	App.fullScreen = false -- 18
	App.winSize = Size(640, 480) -- 19
end -- 19
local title = Label("sarasa-mono-sc-regular", 24) -- 22
if title then -- 22
	title.text = "R36S Button Lab" -- 24
	title.y = 200 -- 25
	title:addTo(Director.ui) -- 26
end -- 26
local status = Label("sarasa-mono-sc-regular", 18) -- 29
if status then -- 29
	status.text = "Click a virtual button or use the keyboard" -- 31
	status.y = 165 -- 32
	status:addTo(Director.ui) -- 33
end -- 33
local hints = Label("sarasa-mono-sc-regular", 13) -- 36
if hints then -- 36
	hints.text = "D-pad: arrows  Sticks: WASD / TFGH  A: Space/J  B: Shift/K\n" .. "X/Y: U/I  L1/R1: Q/E  L2/R2: 1/3  Start/Select: Enter/Esc" -- 38
	hints.y = 125 -- 40
	hints.textWidth = 600 -- 41
	hints:addTo(Director.ui) -- 42
end -- 42
local history = {} -- 45
local function record(message) -- 46
	__TS__ArrayUnshift(history, message) -- 47
	if #history > 4 then -- 47
		table.remove(history) -- 48
	end -- 48
	if status then -- 48
		status.text = table.concat(history, "\n") -- 49
	end -- 49
	print("[ButtonLab] " .. message) -- 50
end -- 46
local actions = { -- 53
	"Up", -- 54
	"Down", -- 54
	"Left", -- 54
	"Right", -- 54
	"A", -- 55
	"B", -- 55
	"X", -- 55
	"Y", -- 55
	"L1", -- 56
	"R1", -- 56
	"L3", -- 56
	"R3", -- 56
	"Select", -- 56
	"Start" -- 56
} -- 56
for ____, action in ipairs(actions) do -- 59
	inputManager:onCompleted( -- 60
		action, -- 60
		function() return record("action " .. action) end -- 60
	) -- 60
end -- 60
local inputNode = inputManager:getNode() -- 63
inputNode:onButtonDown(function(controllerId, buttonName) -- 64
	record((("pad " .. tostring(controllerId)) .. " down ") .. buttonName) -- 65
end) -- 64
inputNode:onButtonUp(function(controllerId, buttonName) -- 67
	record((("pad " .. tostring(controllerId)) .. " up ") .. buttonName) -- 68
end) -- 67
inputNode:onAxis(function(controllerId, axisName, value) -- 70
	record((((("pad " .. tostring(controllerId)) .. " axis ") .. axisName) .. "=") .. tostring(value)) -- 71
end) -- 70
inputNode:onKeyDown(function(keyName) -- 73
	record("key down " .. keyName) -- 74
end) -- 73
inputNode:onKeyUp(function(keyName) -- 76
	record("key up " .. keyName) -- 77
end) -- 76
installKeyboardAxes() -- 80
inputManager:pushContext(INPUT_CONTEXT) -- 81
local ____opt_0 = toNode(React.createElement(GamePad, {inputManager = inputManager, color = 4285125375, primaryOpacity = 0.58, secondaryOpacity = 0.28})) -- 81
if ____opt_0 ~= nil then -- 81
	____opt_0:addTo(Director.ui) -- 83
end -- 83
inputManager:emitButtonDown("a") -- 93
inputManager:emitButtonUp("a") -- 94
inputManager:emitKeyDown("Space") -- 95
inputManager:emitKeyUp("Space") -- 96
inputManager:emitAxis("leftx", 0.5) -- 97
inputManager:emitAxis("leftx", 0) -- 98
print("BUTTON_LAB_SELF_TEST_OK") -- 99
return ____exports -- 99