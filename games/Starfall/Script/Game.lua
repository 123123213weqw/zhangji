-- [ts]: Game.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 2
local Color3 = ____Dora.Color3 -- 3
local App = ____Dora.App -- 4
local Director = ____Dora.Director -- 5
local DrawNode = ____Dora.DrawNode -- 6
local Label = ____Dora.Label -- 7
local Node = ____Dora.Node -- 8
local Vec2 = ____Dora.Vec2 -- 10
local View = ____Dora.View -- 11
local ____InputManager = require("InputManager") -- 13
local CreateGamePad = ____InputManager.CreateGamePad -- 13
local ____Actions = require("Script.Input.Actions") -- 14
local GameActions = ____Actions.GameActions -- 14
local ____Desktop = require("Script.Input.Desktop") -- 15
local installDesktopInput = ____Desktop.installDesktopInput -- 15
local ____Handheld = require("Script.Input.Handheld") -- 16
local installHandheldInput = ____Handheld.installHandheldInput -- 16
local ____TargetProfile = require("Script.TargetProfile") -- 17
local applyTargetProfile = ____TargetProfile.applyTargetProfile -- 17
local COLORS = { -- 54
	background = 4278651672, -- 55
	panel = 4279047984, -- 56
	grid = 4279642443, -- 57
	border = 4281093750, -- 58
	cyan = 4284737791, -- 59
	cyanSoft = 4280777883, -- 60
	yellow = 4294957146, -- 61
	red = 4294923638, -- 62
	redDark = 4287310153, -- 63
	white = 4293522687, -- 64
	muted = 4286487220, -- 65
	green = 4285398963 -- 66
} -- 66
local function clamp(value, minimum, maximum) -- 69
	return math.max( -- 70
		minimum, -- 70
		math.min(maximum, value) -- 70
	) -- 70
end -- 69
function ____exports.circlesOverlap(ax, ay, ar, bx, by, br) -- 73
	local dx = ax - bx -- 81
	local dy = ay - by -- 82
	local radius = ar + br -- 83
	return dx * dx + dy * dy <= radius * radius -- 84
end -- 73
local Random = __TS__Class() -- 87
Random.name = "Random" -- 87
function Random.prototype.____constructor(self, seed) -- 90
	self.seed = seed -- 91
end -- 90
function Random.prototype.next(self) -- 94
	self.seed = self.seed * 48271 % 2147483647 -- 95
	return self.seed / 2147483647 -- 96
end -- 94
function Random.prototype.range(self, minimum, maximum) -- 99
	return minimum + (maximum - minimum) * self:next() -- 100
end -- 99
local function createLabel(text, size, x, y, color) -- 104
	local label = Label("sarasa-mono-sc-regular", size) -- 105
	if label then -- 105
		label.text = text -- 107
		label.position = Vec2(x, y) -- 108
		label.color3 = Color3(color & 16777215) -- 109
	end -- 109
	return label -- 111
end -- 104
local function drawDiamond(draw, x, y, radius, color) -- 114
	draw:drawPolygon( -- 115
		{ -- 115
			Vec2(x, y + radius), -- 116
			Vec2(x + radius, y), -- 117
			Vec2(x, y - radius), -- 118
			Vec2(x - radius, y) -- 119
		}, -- 119
		Color(color) -- 120
	) -- 120
end -- 114
function ____exports.runSelfTest() -- 123
	assert( -- 124
		____exports.circlesOverlap( -- 124
			0, -- 124
			0, -- 124
			10, -- 124
			15, -- 124
			0, -- 124
			5 -- 124
		), -- 124
		"touching circles must collide" -- 124
	) -- 124
	assert( -- 125
		not ____exports.circlesOverlap( -- 125
			0, -- 125
			0, -- 125
			10, -- 125
			16, -- 125
			0, -- 125
			5 -- 125
		), -- 125
		"separated circles must not collide" -- 125
	) -- 125
	local random = __TS__New(Random, 7) -- 126
	local first = random:next() -- 127
	assert(first > 0 and first < 1, "deterministic random must be normalized") -- 128
	print("STARFALL_SELF_TEST_OK") -- 129
end -- 123
function ____exports.startGame(profile) -- 132
	applyTargetProfile(profile) -- 133
	____exports.runSelfTest() -- 134
	local width = profile.width -- 136
	local height = profile.height -- 137
	local renderScale = math.min(View.size.width / width, View.size.height / height) -- 140
	local actions = __TS__New(GameActions) -- 141
	local desktopInputNode -- 142
	if profile.kind == "desktop" then -- 142
		desktopInputNode = installDesktopInput(actions, width, height, renderScale) -- 144
	else -- 144
		local handheldManager = installHandheldInput(actions).manager -- 146
		if profile.showVirtualPad then -- 146
			CreateGamePad({ -- 148
				inputManager = handheldManager, -- 149
				color = COLORS.cyan, -- 150
				primaryOpacity = 0.34, -- 151
				secondaryOpacity = 0.1, -- 152
				noDPad = true, -- 153
				noTriggerPad = true -- 154
			}):addTo(Director.ui) -- 154
		end -- 154
		print("STARFALL_HANDHELD_INPUT_READY") -- 157
	end -- 157
	local halfWidth = width / 2 -- 160
	local halfHeight = height / 2 -- 161
	local arenaTop = halfHeight - 72 -- 162
	local arenaBottom = -halfHeight + 58 -- 163
	local arenaLeft = -halfWidth + 24 -- 164
	local arenaRight = halfWidth - 24 -- 165
	local root = Node() -- 166
	root.scaleX = renderScale -- 167
	root.scaleY = renderScale -- 168
	root:addTo(Director.entry) -- 169
	local draw = DrawNode() -- 170
	draw:addTo(root) -- 171
	local title = createLabel( -- 173
		"STARFALL // 星坠拾荒者", -- 173
		profile.kind == "desktop" and 24 or 20, -- 173
		0, -- 173
		halfHeight - 30, -- 173
		COLORS.white -- 173
	) -- 173
	local scoreLabel = createLabel( -- 174
		"", -- 174
		profile.kind == "desktop" and 17 or 15, -- 174
		arenaLeft, -- 174
		halfHeight - 59, -- 174
		COLORS.yellow -- 174
	) -- 174
	local statusLabel = createLabel( -- 175
		"", -- 175
		profile.kind == "desktop" and 17 or 15, -- 175
		arenaRight, -- 175
		halfHeight - 59, -- 175
		COLORS.cyan -- 175
	) -- 175
	local messageLabel = createLabel( -- 176
		"", -- 176
		profile.kind == "desktop" and 28 or 23, -- 176
		0, -- 176
		10, -- 176
		COLORS.white -- 176
	) -- 176
	local subMessageLabel = createLabel( -- 177
		"", -- 177
		profile.kind == "desktop" and 15 or 13, -- 177
		0, -- 177
		-23, -- 177
		COLORS.muted -- 177
	) -- 177
	local helpLabel = createLabel( -- 178
		profile.controls, -- 178
		profile.kind == "desktop" and 13 or 11, -- 178
		0, -- 178
		-halfHeight + 24, -- 178
		COLORS.muted -- 178
	) -- 178
	if scoreLabel then -- 178
		scoreLabel.anchor = Vec2(0, 0.5) -- 180
		scoreLabel.alignment = "Left" -- 181
	end -- 181
	if statusLabel then -- 181
		statusLabel.anchor = Vec2(1, 0.5) -- 184
		statusLabel.alignment = "Right" -- 185
	end -- 185
	if title ~= nil then -- 185
		title:addTo(root) -- 187
	end -- 187
	if scoreLabel ~= nil then -- 187
		scoreLabel:addTo(root) -- 188
	end -- 188
	if statusLabel ~= nil then -- 188
		statusLabel:addTo(root) -- 189
	end -- 189
	if messageLabel ~= nil then -- 189
		messageLabel:addTo(root) -- 190
	end -- 190
	if subMessageLabel ~= nil then -- 190
		subMessageLabel:addTo(root) -- 191
	end -- 191
	if helpLabel ~= nil then -- 191
		helpLabel:addTo(root) -- 192
	end -- 192
	local random = __TS__New(Random, 20260825) -- 194
	local player -- 195
	local star -- 196
	local hazards -- 197
	local particles -- 198
	local score -- 199
	local combo -- 200
	local elapsed -- 201
	local spawnTimer -- 202
	local paused -- 203
	local gameOver -- 204
	local layoutReadyLogged = false -- 205
	local function spawnStar() -- 207
		return { -- 207
			x = random:range(arenaLeft + 32, arenaRight - 32), -- 208
			y = random:range(arenaBottom + 32, arenaTop - 32), -- 209
			radius = 10 -- 210
		} -- 210
	end -- 207
	local function spawnHazard() -- 213
		local speed = random:range(62, 105) + math.min(elapsed * 0.5, 55) -- 214
		local angle = random:range(0, math.pi * 2) -- 215
		return { -- 216
			x = random:range(arenaLeft + 60, arenaRight - 60), -- 217
			y = random:range(arenaBottom + 60, arenaTop - 60), -- 218
			radius = random:range(14, 22), -- 219
			vx = math.cos(angle) * speed, -- 220
			vy = math.sin(angle) * speed, -- 221
			phase = random:range(0, math.pi * 2) -- 222
		} -- 222
	end -- 213
	local function burst(x, y, color, count) -- 226
		do -- 226
			local i = 0 -- 227
			while i < count do -- 227
				local angle = random:range(0, math.pi * 2) -- 228
				local speed = random:range(55, 170) -- 229
				particles[#particles + 1] = { -- 230
					x = x, -- 231
					y = y, -- 232
					vx = math.cos(angle) * speed, -- 233
					vy = math.sin(angle) * speed, -- 234
					life = random:range(0.25, 0.7), -- 235
					radius = random:range(2, 5), -- 236
					color = color -- 237
				} -- 237
				i = i + 1 -- 227
			end -- 227
		end -- 227
	end -- 226
	local function reset() -- 242
		player = { -- 243
			x = 0, -- 244
			y = arenaBottom + (arenaTop - arenaBottom) * 0.36, -- 245
			aimX = 1, -- 246
			aimY = 0, -- 247
			dashX = 1, -- 248
			dashY = 0, -- 249
			dashTime = 0, -- 250
			dashCooldown = 0, -- 251
			invincible = 0, -- 252
			hp = 3 -- 253
		} -- 253
		score = 0 -- 255
		combo = 0 -- 256
		elapsed = 0 -- 257
		spawnTimer = 4.5 -- 258
		paused = false -- 259
		gameOver = false -- 260
		particles = {} -- 261
		star = spawnStar() -- 262
		hazards = { -- 263
			spawnHazard(), -- 263
			spawnHazard(), -- 263
			spawnHazard() -- 263
		} -- 263
		actions:reset() -- 264
	end -- 242
	reset() -- 267
	local function update(dt) -- 269
		if actions:consumeRestart() then -- 269
			reset() -- 271
			return -- 272
		end -- 272
		if actions:consumePause() and not gameOver then -- 272
			paused = not paused -- 274
		end -- 274
		if gameOver then -- 274
			if actions:consumePrimary() then -- 274
				reset() -- 276
			end -- 276
			return -- 277
		end -- 277
		if paused then -- 277
			return -- 279
		end -- 279
		local frameTime = math.min(dt, 1 / 20) -- 281
		elapsed = elapsed + frameTime -- 282
		player.dashCooldown = math.max(0, player.dashCooldown - frameTime) -- 283
		player.invincible = math.max(0, player.invincible - frameTime) -- 284
		local moveX, moveY = table.unpack( -- 286
			actions:getMove(), -- 286
			1, -- 286
			2 -- 286
		) -- 286
		local aimX, aimY = table.unpack( -- 287
			actions:getAim(player.x, player.y, player.aimX, player.aimY), -- 287
			1, -- 287
			2 -- 287
		) -- 287
		player.aimX = aimX -- 288
		player.aimY = aimY -- 289
		if actions:consumePrimary() and player.dashCooldown <= 0 then -- 289
			player.dashX = aimX -- 291
			player.dashY = aimY -- 292
			player.dashTime = 0.18 -- 293
			player.dashCooldown = 0.9 -- 294
			burst(player.x, player.y, COLORS.cyan, 8) -- 295
		end -- 295
		if player.dashTime > 0 then -- 295
			player.dashTime = player.dashTime - frameTime -- 299
			player.x = player.x + player.dashX * 560 * frameTime -- 300
			player.y = player.y + player.dashY * 560 * frameTime -- 301
			particles[#particles + 1] = { -- 302
				x = player.x, -- 303
				y = player.y, -- 304
				vx = -player.dashX * 30, -- 305
				vy = -player.dashY * 30, -- 306
				life = 0.18, -- 307
				radius = 5, -- 308
				color = COLORS.cyanSoft -- 309
			} -- 309
		else -- 309
			player.x = player.x + moveX * 205 * frameTime -- 312
			player.y = player.y + moveY * 205 * frameTime -- 313
		end -- 313
		player.x = clamp(player.x, arenaLeft + 16, arenaRight - 16) -- 315
		player.y = clamp(player.y, arenaBottom + 16, arenaTop - 16) -- 316
		for ____, hazard in ipairs(hazards) do -- 318
			hazard.x = hazard.x + hazard.vx * frameTime -- 319
			hazard.y = hazard.y + hazard.vy * frameTime -- 320
			hazard.phase = hazard.phase + frameTime * 2.8 -- 321
			if hazard.x < arenaLeft + hazard.radius or hazard.x > arenaRight - hazard.radius then -- 321
				hazard.vx = -hazard.vx -- 323
				hazard.x = clamp(hazard.x, arenaLeft + hazard.radius, arenaRight - hazard.radius) -- 324
			end -- 324
			if hazard.y < arenaBottom + hazard.radius or hazard.y > arenaTop - hazard.radius then -- 324
				hazard.vy = -hazard.vy -- 327
				hazard.y = clamp(hazard.y, arenaBottom + hazard.radius, arenaTop - hazard.radius) -- 328
			end -- 328
			if player.invincible <= 0 and ____exports.circlesOverlap( -- 328
				player.x, -- 330
				player.y, -- 330
				11, -- 330
				hazard.x, -- 330
				hazard.y, -- 330
				hazard.radius - 2 -- 330
			) then -- 330
				player.hp = player.hp - 1 -- 331
				player.invincible = 1.35 -- 332
				player.dashTime = 0 -- 333
				combo = 0 -- 334
				burst(player.x, player.y, COLORS.red, 18) -- 335
				if player.hp <= 0 then -- 335
					gameOver = true -- 336
				end -- 336
			end -- 336
		end -- 336
		if ____exports.circlesOverlap( -- 336
			player.x, -- 340
			player.y, -- 340
			13, -- 340
			star.x, -- 340
			star.y, -- 340
			star.radius -- 340
		) then -- 340
			combo = combo + 1 -- 341
			score = score + (100 + math.min(combo, 10) * 20) -- 342
			burst(star.x, star.y, COLORS.yellow, 16) -- 343
			star = spawnStar() -- 344
		end -- 344
		spawnTimer = spawnTimer - frameTime -- 347
		if spawnTimer <= 0 and #hazards < 9 then -- 347
			hazards[#hazards + 1] = spawnHazard() -- 349
			spawnTimer = math.max(2.8, 7 - elapsed * 0.035) -- 350
		end -- 350
		do -- 350
			local index = #particles - 1 -- 353
			while index >= 0 do -- 353
				local particle = particles[index + 1] -- 354
				particle.life = particle.life - frameTime -- 355
				particle.x = particle.x + particle.vx * frameTime -- 356
				particle.y = particle.y + particle.vy * frameTime -- 357
				particle.vx = particle.vx * 0.94 -- 358
				particle.vy = particle.vy * 0.94 -- 359
				if particle.life <= 0 then -- 359
					__TS__ArraySplice(particles, index, 1) -- 360
				end -- 360
				index = index - 1 -- 353
			end -- 353
		end -- 353
	end -- 269
	local function render() -- 364
		draw:clear() -- 365
		draw:drawPolygon( -- 366
			{ -- 366
				Vec2(-halfWidth, -halfHeight), -- 367
				Vec2(halfWidth, -halfHeight), -- 368
				Vec2(halfWidth, halfHeight), -- 369
				Vec2(-halfWidth, halfHeight) -- 370
			}, -- 370
			Color(COLORS.background) -- 371
		) -- 371
		draw:drawPolygon( -- 372
			{ -- 372
				Vec2(arenaLeft, arenaBottom), -- 373
				Vec2(arenaRight, arenaBottom), -- 374
				Vec2(arenaRight, arenaTop), -- 375
				Vec2(arenaLeft, arenaTop) -- 376
			}, -- 376
			Color(COLORS.panel), -- 377
			2, -- 377
			Color(COLORS.border) -- 377
		) -- 377
		do -- 377
			local x = arenaLeft + 48 -- 378
			while x < arenaRight do -- 378
				draw:drawSegment( -- 379
					Vec2(x, arenaBottom), -- 379
					Vec2(x, arenaTop), -- 379
					0.6, -- 379
					Color(COLORS.grid) -- 379
				) -- 379
				x = x + 48 -- 378
			end -- 378
		end -- 378
		do -- 378
			local y = arenaBottom + 48 -- 381
			while y < arenaTop do -- 381
				draw:drawSegment( -- 382
					Vec2(arenaLeft, y), -- 382
					Vec2(arenaRight, y), -- 382
					0.6, -- 382
					Color(COLORS.grid) -- 382
				) -- 382
				y = y + 48 -- 381
			end -- 381
		end -- 381
		local pulse = 1 + math.sin(elapsed * 5) * 0.16 -- 385
		draw:drawDot( -- 386
			Vec2(star.x, star.y), -- 386
			star.radius * 1.8 * pulse, -- 386
			Color(587192410) -- 386
		) -- 386
		drawDiamond( -- 387
			draw, -- 387
			star.x, -- 387
			star.y, -- 387
			star.radius * pulse, -- 387
			COLORS.yellow -- 387
		) -- 387
		draw:drawSegment( -- 388
			Vec2(star.x - 14, star.y), -- 388
			Vec2(star.x + 14, star.y), -- 388
			1, -- 388
			Color(COLORS.white) -- 388
		) -- 388
		draw:drawSegment( -- 389
			Vec2(star.x, star.y - 14), -- 389
			Vec2(star.x, star.y + 14), -- 389
			1, -- 389
			Color(COLORS.white) -- 389
		) -- 389
		for ____, hazard in ipairs(hazards) do -- 391
			local wobble = 1 + math.sin(hazard.phase) * 0.08 -- 392
			draw:drawDot( -- 393
				Vec2(hazard.x, hazard.y), -- 393
				hazard.radius * wobble, -- 393
				Color(COLORS.redDark) -- 393
			) -- 393
			draw:drawDot( -- 394
				Vec2(hazard.x, hazard.y), -- 394
				hazard.radius * 0.68, -- 394
				Color(COLORS.red) -- 394
			) -- 394
			local diagonal = hazard.radius * 0.52 -- 395
			draw:drawSegment( -- 396
				Vec2(hazard.x - diagonal, hazard.y - diagonal), -- 397
				Vec2(hazard.x + diagonal, hazard.y + diagonal), -- 398
				2, -- 399
				Color(COLORS.background) -- 400
			) -- 400
			draw:drawSegment( -- 402
				Vec2(hazard.x - diagonal, hazard.y + diagonal), -- 403
				Vec2(hazard.x + diagonal, hazard.y - diagonal), -- 404
				2, -- 405
				Color(COLORS.background) -- 406
			) -- 406
		end -- 406
		for ____, particle in ipairs(particles) do -- 410
			draw:drawDot( -- 411
				Vec2(particle.x, particle.y), -- 411
				particle.radius, -- 411
				Color(particle.color) -- 411
			) -- 411
		end -- 411
		local blinkVisible = player.invincible <= 0 or math.floor(player.invincible * 12) % 2 == 0 -- 414
		if blinkVisible then -- 414
			local nose = Vec2(player.x + player.aimX * 18, player.y + player.aimY * 18) -- 416
			local backX = player.x - player.aimX * 11 -- 417
			local backY = player.y - player.aimY * 11 -- 418
			local perpendicularX = -player.aimY * 10 -- 419
			local perpendicularY = player.aimX * 10 -- 420
			draw:drawDot( -- 421
				Vec2(player.x, player.y), -- 421
				player.dashTime > 0 and 22 or 16, -- 421
				Color(677636351) -- 421
			) -- 421
			draw:drawPolygon( -- 422
				{ -- 422
					nose, -- 423
					Vec2(backX + perpendicularX, backY + perpendicularY), -- 424
					Vec2(backX - perpendicularX, backY - perpendicularY) -- 425
				}, -- 425
				Color(COLORS.cyan), -- 426
				2, -- 426
				Color(COLORS.white) -- 426
			) -- 426
		end -- 426
		if scoreLabel then -- 426
			scoreLabel.text = (("SCORE " .. tostring(score)) .. "   CHAIN x") .. tostring(combo) -- 429
		end -- 429
		if statusLabel then -- 429
			local hearts = player.hp == 3 and "◆◆◆" or (player.hp == 2 and "◆◆◇" or (player.hp == 1 and "◆◇◇" or "◇◇◇")) -- 431
			local dash = player.dashCooldown <= 0 and "READY" or tostring(math.ceil(player.dashCooldown * 10) / 10) .. "s" -- 432
			statusLabel.text = (("HULL " .. hearts) .. "   DASH ") .. dash -- 433
		end -- 433
		if messageLabel then -- 433
			messageLabel.visible = paused or gameOver -- 436
			messageLabel.text = gameOver and "SIGNAL LOST" or "PAUSED" -- 437
			messageLabel.color3 = Color3(gameOver and COLORS.red & 16777215 or COLORS.white & 16777215) -- 438
		end -- 438
		if subMessageLabel then -- 438
			subMessageLabel.visible = paused or gameOver -- 441
			subMessageLabel.text = gameOver and (profile.kind == "desktop" and "CLICK / SPACE TO RESTART" or "A TO RESTART") or (profile.kind == "desktop" and "PRESS P TO RESUME" or "PRESS START TO RESUME") -- 442
		end -- 442
	end -- 364
	root:onUpdate(function(dt) -- 448
		renderScale = math.min(View.size.width / width, View.size.height / height) -- 451
		root.scaleX = renderScale -- 452
		root.scaleY = renderScale -- 453
		if desktopInputNode then -- 453
			desktopInputNode.scaleX = renderScale -- 455
			desktopInputNode.scaleY = renderScale -- 456
		end -- 456
		if not layoutReadyLogged and math.abs(App.visualSize.width - width) < 1 and math.abs(App.visualSize.height - height) < 1 then -- 456
			layoutReadyLogged = true -- 461
			print((((((("STARFALL_LAYOUT_READY profile=" .. profile.kind) .. " visual=") .. tostring(App.visualSize.width)) .. "x") .. tostring(App.visualSize.height)) .. " scale=") .. tostring(renderScale)) -- 462
		end -- 462
		update(dt) -- 464
		render() -- 465
		return false -- 466
	end) -- 448
	render() -- 468
	print((((((((((((((((("STARFALL_READY profile=" .. profile.kind) .. " size=") .. tostring(profile.width)) .. "x") .. tostring(profile.height)) .. " scale=") .. tostring(renderScale)) .. " visual=") .. tostring(App.visualSize.width)) .. "x") .. tostring(App.visualSize.height)) .. " view=") .. tostring(View.size.width)) .. "x") .. tostring(View.size.height)) .. " dpr=") .. tostring(App.devicePixelRatio)) -- 469
end -- 132
return ____exports -- 132