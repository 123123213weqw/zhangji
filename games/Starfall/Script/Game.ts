import {
	Color,
	Color3,
	App,
	Director,
	DrawNode,
	Label,
	Node,
	TextAlign,
	Vec2,
	View,
} from "Dora";
import { CreateGamePad } from "InputManager";
import { GameActions } from "Script/Input/Actions";
import { installDesktopInput } from "Script/Input/Desktop";
import { installHandheldInput } from "Script/Input/Handheld";
import { applyTargetProfile, TargetProfile } from "Script/TargetProfile";

interface Orb {
	x: number;
	y: number;
	radius: number;
}

interface Hazard extends Orb {
	vx: number;
	vy: number;
	phase: number;
}

interface Particle {
	x: number;
	y: number;
	vx: number;
	vy: number;
	life: number;
	radius: number;
	color: number;
}

interface Player {
	x: number;
	y: number;
	aimX: number;
	aimY: number;
	dashX: number;
	dashY: number;
	dashTime: number;
	dashCooldown: number;
	invincible: number;
	hp: number;
}

const COLORS = {
	background: 0xff070b18,
	panel: 0xff0d1730,
	grid: 0xff16294b,
	border: 0xff2c4e76,
	cyan: 0xff63e8ff,
	cyanSoft: 0xff277c9b,
	yellow: 0xffffd85a,
	red: 0xffff5576,
	redDark: 0xff8b2949,
	white: 0xffe9f4ff,
	muted: 0xff7e9ab4,
	green: 0xff6dffb3,
};

function clamp(value: number, minimum: number, maximum: number): number {
	return math.max(minimum, math.min(maximum, value));
}

export function circlesOverlap(
	ax: number,
	ay: number,
	ar: number,
	bx: number,
	by: number,
	br: number,
): boolean {
	const dx = ax - bx;
	const dy = ay - by;
	const radius = ar + br;
	return dx * dx + dy * dy <= radius * radius;
}

class Random {
	private seed: number;

	constructor(seed: number) {
		this.seed = seed;
	}

	next(): number {
		this.seed = (this.seed * 48271) % 2147483647;
		return this.seed / 2147483647;
	}

	range(minimum: number, maximum: number): number {
		return minimum + (maximum - minimum) * this.next();
	}
}

function createLabel(text: string, size: number, x: number, y: number, color: number): Label.Type | undefined {
	const label = Label("sarasa-mono-sc-regular", size);
	if (label) {
		label.text = text;
		label.position = Vec2(x, y);
		label.color3 = Color3(color & 0xffffff);
	}
	return label;
}

function drawDiamond(draw: DrawNode.Type, x: number, y: number, radius: number, color: number): void {
	draw.drawPolygon([
		Vec2(x, y + radius),
		Vec2(x + radius, y),
		Vec2(x, y - radius),
		Vec2(x - radius, y),
	], Color(color));
}

export function runSelfTest(): void {
	assert(circlesOverlap(0, 0, 10, 15, 0, 5), "touching circles must collide");
	assert(!circlesOverlap(0, 0, 10, 16, 0, 5), "separated circles must not collide");
	const random = new Random(7);
	const first = random.next();
	assert(first > 0 && first < 1, "deterministic random must be normalized");
	print("STARFALL_SELF_TEST_OK");
}

export function startGame(profile: TargetProfile): void {
	applyTargetProfile(profile);
	runSelfTest();

	const width = profile.width;
	const height = profile.height;
	// Dora's 2D view uses render-buffer pixels. Scaling from the target's
	// logical size keeps the same composition on Retina desktops and 1x R36S.
	let renderScale = math.min(View.size.width / width, View.size.height / height);
	const actions = new GameActions();
	let desktopInputNode: Node.Type | undefined;
	if (profile.kind === "desktop") {
		desktopInputNode = installDesktopInput(actions, width, height, renderScale);
	} else {
		const handheldManager = installHandheldInput(actions).manager;
		if (profile.showVirtualPad) {
			CreateGamePad({
				inputManager: handheldManager,
				color: COLORS.cyan,
				primaryOpacity: 0.34,
				secondaryOpacity: 0.1,
				noDPad: true,
				noTriggerPad: true,
			}).addTo(Director.ui);
		}
		print("STARFALL_HANDHELD_INPUT_READY");
	}

	const halfWidth = width / 2;
	const halfHeight = height / 2;
	const arenaTop = halfHeight - 72;
	const arenaBottom = -halfHeight + 58;
	const arenaLeft = -halfWidth + 24;
	const arenaRight = halfWidth - 24;
	const root = Node();
	root.scaleX = renderScale;
	root.scaleY = renderScale;
	root.addTo(Director.entry);
	const draw = DrawNode();
	draw.addTo(root);

	const title = createLabel("STARFALL // 星坠拾荒者", profile.kind === "desktop" ? 24 : 20, 0, halfHeight - 30, COLORS.white);
	const scoreLabel = createLabel("", profile.kind === "desktop" ? 17 : 15, arenaLeft, halfHeight - 59, COLORS.yellow);
	const statusLabel = createLabel("", profile.kind === "desktop" ? 17 : 15, arenaRight, halfHeight - 59, COLORS.cyan);
	const messageLabel = createLabel("", profile.kind === "desktop" ? 28 : 23, 0, 10, COLORS.white);
	const subMessageLabel = createLabel("", profile.kind === "desktop" ? 15 : 13, 0, -23, COLORS.muted);
	const helpLabel = createLabel(profile.controls, profile.kind === "desktop" ? 13 : 11, 0, -halfHeight + 24, COLORS.muted);
	if (scoreLabel) {
		scoreLabel.anchor = Vec2(0, 0.5);
		scoreLabel.alignment = TextAlign.Left;
	}
	if (statusLabel) {
		statusLabel.anchor = Vec2(1, 0.5);
		statusLabel.alignment = TextAlign.Right;
	}
	title?.addTo(root);
	scoreLabel?.addTo(root);
	statusLabel?.addTo(root);
	messageLabel?.addTo(root);
	subMessageLabel?.addTo(root);
	helpLabel?.addTo(root);

	const random = new Random(20260825);
	let player: Player;
	let star: Orb;
	let hazards: Hazard[];
	let particles: Particle[];
	let score: number;
	let combo: number;
	let elapsed: number;
	let spawnTimer: number;
	let paused: boolean;
	let gameOver: boolean;
	let layoutReadyLogged = false;

	const spawnStar = (): Orb => ({
		x: random.range(arenaLeft + 32, arenaRight - 32),
		y: random.range(arenaBottom + 32, arenaTop - 32),
		radius: 10,
	});

	const spawnHazard = (): Hazard => {
		const speed = random.range(62, 105) + math.min(elapsed * 0.5, 55);
		const angle = random.range(0, math.pi * 2);
		return {
			x: random.range(arenaLeft + 60, arenaRight - 60),
			y: random.range(arenaBottom + 60, arenaTop - 60),
			radius: random.range(14, 22),
			vx: math.cos(angle) * speed,
			vy: math.sin(angle) * speed,
			phase: random.range(0, math.pi * 2),
		};
	};

	const burst = (x: number, y: number, color: number, count: number): void => {
		for (let i = 0; i < count; i++) {
			const angle = random.range(0, math.pi * 2);
			const speed = random.range(55, 170);
			particles.push({
				x,
				y,
				vx: math.cos(angle) * speed,
				vy: math.sin(angle) * speed,
				life: random.range(0.25, 0.7),
				radius: random.range(2, 5),
				color,
			});
		}
	};

	const reset = (): void => {
		player = {
			x: 0,
			y: arenaBottom + (arenaTop - arenaBottom) * 0.36,
			aimX: 1,
			aimY: 0,
			dashX: 1,
			dashY: 0,
			dashTime: 0,
			dashCooldown: 0,
			invincible: 0,
			hp: 3,
		};
		score = 0;
		combo = 0;
		elapsed = 0;
		spawnTimer = 4.5;
		paused = false;
		gameOver = false;
		particles = [];
		star = spawnStar();
		hazards = [spawnHazard(), spawnHazard(), spawnHazard()];
		actions.reset();
	};

	reset();

	const update = (dt: number): void => {
		if (actions.consumeRestart()) {
			reset();
			return;
		}
		if (actions.consumePause() && !gameOver) paused = !paused;
		if (gameOver) {
			if (actions.consumePrimary()) reset();
			return;
		}
		if (paused) return;

		const frameTime = math.min(dt, 1 / 20);
		elapsed += frameTime;
		player.dashCooldown = math.max(0, player.dashCooldown - frameTime);
		player.invincible = math.max(0, player.invincible - frameTime);

		const [moveX, moveY] = actions.getMove();
		const [aimX, aimY] = actions.getAim(player.x, player.y, player.aimX, player.aimY);
		player.aimX = aimX;
		player.aimY = aimY;
		if (actions.consumePrimary() && player.dashCooldown <= 0) {
			player.dashX = aimX;
			player.dashY = aimY;
			player.dashTime = 0.18;
			player.dashCooldown = 0.9;
			burst(player.x, player.y, COLORS.cyan, 8);
		}

		if (player.dashTime > 0) {
			player.dashTime -= frameTime;
			player.x += player.dashX * 560 * frameTime;
			player.y += player.dashY * 560 * frameTime;
			particles.push({
				x: player.x,
				y: player.y,
				vx: -player.dashX * 30,
				vy: -player.dashY * 30,
				life: 0.18,
				radius: 5,
				color: COLORS.cyanSoft,
			});
		} else {
			player.x += moveX * 205 * frameTime;
			player.y += moveY * 205 * frameTime;
		}
		player.x = clamp(player.x, arenaLeft + 16, arenaRight - 16);
		player.y = clamp(player.y, arenaBottom + 16, arenaTop - 16);

		for (const hazard of hazards) {
			hazard.x += hazard.vx * frameTime;
			hazard.y += hazard.vy * frameTime;
			hazard.phase += frameTime * 2.8;
			if (hazard.x < arenaLeft + hazard.radius || hazard.x > arenaRight - hazard.radius) {
				hazard.vx = -hazard.vx;
				hazard.x = clamp(hazard.x, arenaLeft + hazard.radius, arenaRight - hazard.radius);
			}
			if (hazard.y < arenaBottom + hazard.radius || hazard.y > arenaTop - hazard.radius) {
				hazard.vy = -hazard.vy;
				hazard.y = clamp(hazard.y, arenaBottom + hazard.radius, arenaTop - hazard.radius);
			}
			if (player.invincible <= 0 && circlesOverlap(player.x, player.y, 11, hazard.x, hazard.y, hazard.radius - 2)) {
				player.hp -= 1;
				player.invincible = 1.35;
				player.dashTime = 0;
				combo = 0;
				burst(player.x, player.y, COLORS.red, 18);
				if (player.hp <= 0) gameOver = true;
			}
		}

		if (circlesOverlap(player.x, player.y, 13, star.x, star.y, star.radius)) {
			combo += 1;
			score += 100 + math.min(combo, 10) * 20;
			burst(star.x, star.y, COLORS.yellow, 16);
			star = spawnStar();
		}

		spawnTimer -= frameTime;
		if (spawnTimer <= 0 && hazards.length < 9) {
			hazards.push(spawnHazard());
			spawnTimer = math.max(2.8, 7 - elapsed * 0.035);
		}

		for (let index = particles.length - 1; index >= 0; index--) {
			const particle = particles[index];
			particle.life -= frameTime;
			particle.x += particle.vx * frameTime;
			particle.y += particle.vy * frameTime;
			particle.vx *= 0.94;
			particle.vy *= 0.94;
			if (particle.life <= 0) particles.splice(index, 1);
		}
	};

	const render = (): void => {
		draw.clear();
		draw.drawPolygon([
			Vec2(-halfWidth, -halfHeight),
			Vec2(halfWidth, -halfHeight),
			Vec2(halfWidth, halfHeight),
			Vec2(-halfWidth, halfHeight),
		], Color(COLORS.background));
		draw.drawPolygon([
			Vec2(arenaLeft, arenaBottom),
			Vec2(arenaRight, arenaBottom),
			Vec2(arenaRight, arenaTop),
			Vec2(arenaLeft, arenaTop),
		], Color(COLORS.panel), 2, Color(COLORS.border));
		for (let x = arenaLeft + 48; x < arenaRight; x += 48) {
			draw.drawSegment(Vec2(x, arenaBottom), Vec2(x, arenaTop), 0.6, Color(COLORS.grid));
		}
		for (let y = arenaBottom + 48; y < arenaTop; y += 48) {
			draw.drawSegment(Vec2(arenaLeft, y), Vec2(arenaRight, y), 0.6, Color(COLORS.grid));
		}

		const pulse = 1 + math.sin(elapsed * 5) * 0.16;
		draw.drawDot(Vec2(star.x, star.y), star.radius * 1.8 * pulse, Color(0x22ffd85a));
		drawDiamond(draw, star.x, star.y, star.radius * pulse, COLORS.yellow);
		draw.drawSegment(Vec2(star.x - 14, star.y), Vec2(star.x + 14, star.y), 1, Color(COLORS.white));
		draw.drawSegment(Vec2(star.x, star.y - 14), Vec2(star.x, star.y + 14), 1, Color(COLORS.white));

		for (const hazard of hazards) {
			const wobble = 1 + math.sin(hazard.phase) * 0.08;
			draw.drawDot(Vec2(hazard.x, hazard.y), hazard.radius * wobble, Color(COLORS.redDark));
			draw.drawDot(Vec2(hazard.x, hazard.y), hazard.radius * 0.68, Color(COLORS.red));
			const diagonal = hazard.radius * 0.52;
			draw.drawSegment(
				Vec2(hazard.x - diagonal, hazard.y - diagonal),
				Vec2(hazard.x + diagonal, hazard.y + diagonal),
				2,
				Color(COLORS.background),
			);
			draw.drawSegment(
				Vec2(hazard.x - diagonal, hazard.y + diagonal),
				Vec2(hazard.x + diagonal, hazard.y - diagonal),
				2,
				Color(COLORS.background),
			);
		}

		for (const particle of particles) {
			draw.drawDot(Vec2(particle.x, particle.y), particle.radius, Color(particle.color));
		}

		const blinkVisible = player.invincible <= 0 || math.floor(player.invincible * 12) % 2 === 0;
		if (blinkVisible) {
			const nose = Vec2(player.x + player.aimX * 18, player.y + player.aimY * 18);
			const backX = player.x - player.aimX * 11;
			const backY = player.y - player.aimY * 11;
			const perpendicularX = -player.aimY * 10;
			const perpendicularY = player.aimX * 10;
			draw.drawDot(Vec2(player.x, player.y), player.dashTime > 0 ? 22 : 16, Color(0x2863e8ff));
			draw.drawPolygon([
				nose,
				Vec2(backX + perpendicularX, backY + perpendicularY),
				Vec2(backX - perpendicularX, backY - perpendicularY),
			], Color(COLORS.cyan), 2, Color(COLORS.white));
		}

		if (scoreLabel) scoreLabel.text = `SCORE ${score}   CHAIN x${combo}`;
		if (statusLabel) {
			const hearts = player.hp === 3 ? "◆◆◆" : player.hp === 2 ? "◆◆◇" : player.hp === 1 ? "◆◇◇" : "◇◇◇";
			const dash = player.dashCooldown <= 0 ? "READY" : `${math.ceil(player.dashCooldown * 10) / 10}s`;
			statusLabel.text = `HULL ${hearts}   DASH ${dash}`;
		}
		if (messageLabel) {
			messageLabel.visible = paused || gameOver;
			messageLabel.text = gameOver ? "SIGNAL LOST" : "PAUSED";
			messageLabel.color3 = Color3(gameOver ? COLORS.red & 0xffffff : COLORS.white & 0xffffff);
		}
		if (subMessageLabel) {
			subMessageLabel.visible = paused || gameOver;
			subMessageLabel.text = gameOver
				? (profile.kind === "desktop" ? "CLICK / SPACE TO RESTART" : "A TO RESTART")
				: (profile.kind === "desktop" ? "PRESS P TO RESUME" : "PRESS START TO RESUME");
		}
	};

	root.onUpdate((dt) => {
		// App.winSize takes effect on a later frame. Re-evaluating this also
		// makes the game resilient to desktop window-size and DPR changes.
		renderScale = math.min(View.size.width / width, View.size.height / height);
		root.scaleX = renderScale;
		root.scaleY = renderScale;
		if (desktopInputNode) {
			desktopInputNode.scaleX = renderScale;
			desktopInputNode.scaleY = renderScale;
		}
		if (!layoutReadyLogged
			&& math.abs(App.visualSize.width - width) < 1
			&& math.abs(App.visualSize.height - height) < 1) {
			layoutReadyLogged = true;
			print(`STARFALL_LAYOUT_READY profile=${profile.kind} visual=${App.visualSize.width}x${App.visualSize.height} scale=${renderScale}`);
		}
		update(dt);
		render();
		return false;
	});
	render();
	print(`STARFALL_READY profile=${profile.kind} size=${profile.width}x${profile.height} scale=${renderScale} visual=${App.visualSize.width}x${App.visualSize.height} view=${View.size.width}x${View.size.height} dpr=${App.devicePixelRatio}`);
}
