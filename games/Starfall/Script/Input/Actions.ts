export class GameActions {
	private left = false;
	private right = false;
	private up = false;
	private down = false;
	private leftX = 0;
	private leftY = 0;
	private rightX = 0;
	private rightY = 0;
	private primaryQueued = false;
	private pauseQueued = false;
	private restartQueued = false;
	private pointerActive = false;
	private pointerX = 1;
	private pointerY = 0;

	setDirection(direction: "left" | "right" | "up" | "down", pressed: boolean): void {
		switch (direction) {
			case "left": this.left = pressed; break;
			case "right": this.right = pressed; break;
			case "up": this.up = pressed; break;
			case "down": this.down = pressed; break;
		}
	}

	setLeftAxis(x: number, y: number): void {
		this.leftX = math.abs(x) >= 0.18 ? x : 0;
		this.leftY = math.abs(y) >= 0.18 ? y : 0;
	}

	setRightAxis(x: number, y: number): void {
		this.rightX = math.abs(x) >= 0.18 ? x : 0;
		this.rightY = math.abs(y) >= 0.18 ? y : 0;
	}

	setPointer(x: number, y: number): void {
		this.pointerX = x;
		this.pointerY = y;
		this.pointerActive = true;
	}

	queuePrimary(): void { this.primaryQueued = true; }
	queuePause(): void { this.pauseQueued = true; }
	queueRestart(): void { this.restartQueued = true; }

	consumePrimary(): boolean {
		const value = this.primaryQueued;
		this.primaryQueued = false;
		return value;
	}

	consumePause(): boolean {
		const value = this.pauseQueued;
		this.pauseQueued = false;
		return value;
	}

	consumeRestart(): boolean {
		const value = this.restartQueued;
		this.restartQueued = false;
		return value;
	}

	getMove(): [number, number] {
		let x = this.leftX + (this.right ? 1 : 0) - (this.left ? 1 : 0);
		let y = this.leftY + (this.up ? 1 : 0) - (this.down ? 1 : 0);
		const length = math.sqrt(x * x + y * y);
		if (length > 1) {
			x /= length;
			y /= length;
		}
		return [x, y];
	}

	getAim(playerX: number, playerY: number, fallbackX: number, fallbackY: number): [number, number] {
		let x = this.rightX;
		let y = this.rightY;
		if (math.abs(x) + math.abs(y) < 0.18 && this.pointerActive) {
			x = this.pointerX - playerX;
			y = this.pointerY - playerY;
		}
		if (math.abs(x) + math.abs(y) < 0.001) {
			x = fallbackX;
			y = fallbackY;
		}
		const length = math.sqrt(x * x + y * y);
		if (length <= 0.001) return [1, 0];
		return [x / length, y / length];
	}

	reset(): void {
		this.left = false;
		this.right = false;
		this.up = false;
		this.down = false;
		this.leftX = 0;
		this.leftY = 0;
		this.rightX = 0;
		this.rightY = 0;
		this.primaryQueued = false;
		this.pauseQueued = false;
		this.restartQueued = false;
	}
}
