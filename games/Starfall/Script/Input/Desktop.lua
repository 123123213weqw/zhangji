-- [ts]: Desktop.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Director = ____Dora.Director -- 1
local Node = ____Dora.Node -- 1
function ____exports.installDesktopInput(actions, width, height, renderScale) -- 4
	local node = Node() -- 5
	node.width = width -- 6
	node.height = height -- 7
	node.scaleX = renderScale -- 8
	node.scaleY = renderScale -- 9
	local function setKey(keyName, pressed) -- 11
		repeat -- 11
			local ____switch4 = keyName -- 11
			local ____cond4 = ____switch4 == "A" or ____switch4 == "Left" -- 11
			if ____cond4 then -- 11
				actions:setDirection("left", pressed) -- 15
				break -- 16
			end -- 16
			____cond4 = ____cond4 or (____switch4 == "D" or ____switch4 == "Right") -- 16
			if ____cond4 then -- 16
				actions:setDirection("right", pressed) -- 19
				break -- 20
			end -- 20
			____cond4 = ____cond4 or (____switch4 == "W" or ____switch4 == "Up") -- 20
			if ____cond4 then -- 20
				actions:setDirection("up", pressed) -- 23
				break -- 24
			end -- 24
			____cond4 = ____cond4 or (____switch4 == "S" or ____switch4 == "Down") -- 24
			if ____cond4 then -- 24
				actions:setDirection("down", pressed) -- 27
				break -- 28
			end -- 28
		until true -- 28
	end -- 11
	node:onKeyDown(function(keyName) -- 32
		setKey(keyName, true) -- 33
		repeat -- 33
			local ____switch6 = keyName -- 33
			local ____cond6 = ____switch6 == "Space" or ____switch6 == "Return" -- 33
			if ____cond6 then -- 33
				actions:queuePrimary() -- 37
				break -- 38
			end -- 38
			____cond6 = ____cond6 or (____switch6 == "P" or ____switch6 == "Escape") -- 38
			if ____cond6 then -- 38
				actions:queuePause() -- 41
				break -- 42
			end -- 42
			____cond6 = ____cond6 or ____switch6 == "R" -- 42
			if ____cond6 then -- 42
				actions:queueRestart() -- 44
				break -- 45
			end -- 45
		until true -- 45
	end) -- 32
	node:onKeyUp(function(keyName) return setKey(keyName, false) end) -- 48
	node:onMouseMove(function(touch) return actions:setPointer(touch.location.x, touch.location.y) end) -- 49
	node:onTapBegan(function(touch) -- 50
		actions:setPointer(touch.location.x, touch.location.y) -- 51
		actions:queuePrimary() -- 52
	end) -- 50
	node:addTo(Director.entry) -- 54
	return node -- 55
end -- 4
return ____exports -- 4