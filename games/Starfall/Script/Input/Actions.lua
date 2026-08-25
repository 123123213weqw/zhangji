-- [ts]: Actions.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
____exports.GameActions = __TS__Class() -- 1
local GameActions = ____exports.GameActions -- 1
GameActions.name = "GameActions" -- 1
function GameActions.prototype.____constructor(self) -- 1
	self.left = false -- 2
	self.right = false -- 3
	self.up = false -- 4
	self.down = false -- 5
	self.leftX = 0 -- 6
	self.leftY = 0 -- 7
	self.rightX = 0 -- 8
	self.rightY = 0 -- 9
	self.primaryQueued = false -- 10
	self.pauseQueued = false -- 11
	self.restartQueued = false -- 12
	self.pointerActive = false -- 13
	self.pointerX = 1 -- 14
	self.pointerY = 0 -- 15
end -- 1
function GameActions.prototype.setDirection(self, direction, pressed) -- 17
	repeat -- 17
		local ____switch4 = direction -- 17
		local ____cond4 = ____switch4 == "left" -- 17
		if ____cond4 then -- 17
			self.left = pressed -- 19
			break -- 19
		end -- 19
		____cond4 = ____cond4 or ____switch4 == "right" -- 19
		if ____cond4 then -- 19
			self.right = pressed -- 20
			break -- 20
		end -- 20
		____cond4 = ____cond4 or ____switch4 == "up" -- 20
		if ____cond4 then -- 20
			self.up = pressed -- 21
			break -- 21
		end -- 21
		____cond4 = ____cond4 or ____switch4 == "down" -- 21
		if ____cond4 then -- 21
			self.down = pressed -- 22
			break -- 22
		end -- 22
	until true -- 22
end -- 17
function GameActions.prototype.setLeftAxis(self, x, y) -- 26
	self.leftX = math.abs(x) >= 0.18 and x or 0 -- 27
	self.leftY = math.abs(y) >= 0.18 and y or 0 -- 28
end -- 26
function GameActions.prototype.setRightAxis(self, x, y) -- 31
	self.rightX = math.abs(x) >= 0.18 and x or 0 -- 32
	self.rightY = math.abs(y) >= 0.18 and y or 0 -- 33
end -- 31
function GameActions.prototype.setPointer(self, x, y) -- 36
	self.pointerX = x -- 37
	self.pointerY = y -- 38
	self.pointerActive = true -- 39
end -- 36
function GameActions.prototype.queuePrimary(self) -- 42
	self.primaryQueued = true -- 42
end -- 42
function GameActions.prototype.queuePause(self) -- 43
	self.pauseQueued = true -- 43
end -- 43
function GameActions.prototype.queueRestart(self) -- 44
	self.restartQueued = true -- 44
end -- 44
function GameActions.prototype.consumePrimary(self) -- 46
	local value = self.primaryQueued -- 47
	self.primaryQueued = false -- 48
	return value -- 49
end -- 46
function GameActions.prototype.consumePause(self) -- 52
	local value = self.pauseQueued -- 53
	self.pauseQueued = false -- 54
	return value -- 55
end -- 52
function GameActions.prototype.consumeRestart(self) -- 58
	local value = self.restartQueued -- 59
	self.restartQueued = false -- 60
	return value -- 61
end -- 58
function GameActions.prototype.getMove(self) -- 64
	local x = self.leftX + (self.right and 1 or 0) - (self.left and 1 or 0) -- 65
	local y = self.leftY + (self.up and 1 or 0) - (self.down and 1 or 0) -- 66
	local length = math.sqrt(x * x + y * y) -- 67
	if length > 1 then -- 67
		x = x / length -- 69
		y = y / length -- 70
	end -- 70
	return {x, y} -- 72
end -- 64
function GameActions.prototype.getAim(self, playerX, playerY, fallbackX, fallbackY) -- 75
	local x = self.rightX -- 76
	local y = self.rightY -- 77
	if math.abs(x) + math.abs(y) < 0.18 and self.pointerActive then -- 77
		x = self.pointerX - playerX -- 79
		y = self.pointerY - playerY -- 80
	end -- 80
	if math.abs(x) + math.abs(y) < 0.001 then -- 80
		x = fallbackX -- 83
		y = fallbackY -- 84
	end -- 84
	local length = math.sqrt(x * x + y * y) -- 86
	if length <= 0.001 then -- 86
		return {1, 0} -- 87
	end -- 87
	return {x / length, y / length} -- 88
end -- 75
function GameActions.prototype.reset(self) -- 91
	self.left = false -- 92
	self.right = false -- 93
	self.up = false -- 94
	self.down = false -- 95
	self.leftX = 0 -- 96
	self.leftY = 0 -- 97
	self.rightX = 0 -- 98
	self.rightY = 0 -- 99
	self.primaryQueued = false -- 100
	self.pauseQueued = false -- 101
	self.restartQueued = false -- 102
end -- 91
return ____exports -- 91