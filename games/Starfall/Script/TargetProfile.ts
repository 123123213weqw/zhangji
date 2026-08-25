import { App, PlatformType, Size } from "Dora";

export type TargetKind = "desktop" | "handheld";

export interface TargetProfile {
	kind: TargetKind;
	width: number;
	height: number;
	showVirtualPad: boolean;
	controls: string;
}

export function desktopProfile(): TargetProfile {
	return {
		kind: "desktop",
		width: 960,
		height: 640,
		showVirtualPad: false,
		controls: "WASD / ARROWS MOVE   MOUSE AIM   CLICK / SPACE DASH   P PAUSE   R RESTART",
	};
}

export function handheldProfile(): TargetProfile {
	return {
		kind: "handheld",
		width: 640,
		height: 480,
		showVirtualPad: App.platform === PlatformType.macOS || App.platform === PlatformType.Windows,
		controls: "LEFT STICK / DPAD MOVE   RIGHT STICK AIM   A DASH   START PAUSE   X RESTART",
	};
}

export function applyTargetProfile(profile: TargetProfile): void {
	App.targetFPS = 60;
	if (App.platform === PlatformType.macOS || App.platform === PlatformType.Windows) {
		App.fullScreen = false;
		App.winSize = Size(profile.width, profile.height);
	}
}
