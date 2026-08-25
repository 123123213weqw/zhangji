import { AxisName, ButtonName, KeyName } from "Dora";
import { CreateManager, Trigger } from "InputManager";

/**
 * Actions are intentionally expressed in Dora's standard controller names.
 * The R36S SDL mapping and the desktop virtual pad both produce these names,
 * so game code never needs to know Linux js0 button numbers.
 */
export const INPUT_CONTEXT = "Game";

export const inputManager = CreateManager({
	[INPUT_CONTEXT]: {
		Up: Trigger.Down([
			{ key: KeyName.Up },
			{ button: ButtonName.Up },
		]),
		Down: Trigger.Down([
			{ key: KeyName.Down },
			{ button: ButtonName.Down },
		]),
		Left: Trigger.Down([
			{ key: KeyName.Left },
			{ button: ButtonName.Left },
		]),
		Right: Trigger.Down([
			{ key: KeyName.Right },
			{ button: ButtonName.Right },
		]),
		A: Trigger.Down([
			{ key: KeyName.J },
			{ key: KeyName.Space },
			{ button: ButtonName.A },
		]),
		B: Trigger.Down([
			{ key: KeyName.K },
			{ key: KeyName.LShift },
			{ button: ButtonName.B },
		]),
		X: Trigger.Down([{ key: KeyName.U }, { button: ButtonName.X }]),
		Y: Trigger.Down([{ key: KeyName.I }, { button: ButtonName.Y }]),
		L1: Trigger.Down([
			{ key: KeyName.Q },
			{ button: ButtonName.LeftShoulder },
		]),
		R1: Trigger.Down([
			{ key: KeyName.E },
			{ button: ButtonName.RightShoulder },
		]),
		L3: Trigger.Down([
			{ key: KeyName.Z },
			{ button: ButtonName.LeftStick },
		]),
		R3: Trigger.Down([
			{ key: KeyName.C },
			{ button: ButtonName.RightStick },
		]),
		Select: Trigger.Down([
			{ key: KeyName.Escape },
			{ button: ButtonName.Back },
		]),
		Start: Trigger.Down([
			{ key: KeyName.Return },
			{ button: ButtonName.Start },
		]),
	},
});

/**
 * Dora exposes L2/R2 as controller axes rather than ButtonName values. These
 * helpers make keyboard presses behave exactly like the virtual trigger pad.
 */
export function installKeyboardAxes(): void {
	const node = inputManager.getNode();
	node.onKeyDown((keyName) => {
		switch (keyName) {
			case KeyName.W:
				inputManager.emitAxis(AxisName.LeftY, 1);
				break;
			case KeyName.S:
				inputManager.emitAxis(AxisName.LeftY, -1);
				break;
			case KeyName.A:
				inputManager.emitAxis(AxisName.LeftX, -1);
				break;
			case KeyName.D:
				inputManager.emitAxis(AxisName.LeftX, 1);
				break;
			case KeyName.T:
				inputManager.emitAxis(AxisName.RightY, 1);
				break;
			case KeyName.G:
				inputManager.emitAxis(AxisName.RightY, -1);
				break;
			case KeyName.F:
				inputManager.emitAxis(AxisName.RightX, -1);
				break;
			case KeyName.H:
				inputManager.emitAxis(AxisName.RightX, 1);
				break;
			case KeyName.Num1:
				inputManager.emitAxis(AxisName.LeftTrigger, 1);
				break;
			case KeyName.Num3:
				inputManager.emitAxis(AxisName.RightTrigger, 1);
				break;
		}
	});

	node.onKeyUp((keyName) => {
		switch (keyName) {
			case KeyName.W:
			case KeyName.S:
				inputManager.emitAxis(AxisName.LeftY, 0);
				break;
			case KeyName.A:
			case KeyName.D:
				inputManager.emitAxis(AxisName.LeftX, 0);
				break;
			case KeyName.T:
			case KeyName.G:
				inputManager.emitAxis(AxisName.RightY, 0);
				break;
			case KeyName.F:
			case KeyName.H:
				inputManager.emitAxis(AxisName.RightX, 0);
				break;
			case KeyName.Num1:
				inputManager.emitAxis(AxisName.LeftTrigger, 0);
				break;
			case KeyName.Num3:
				inputManager.emitAxis(AxisName.RightTrigger, 0);
				break;
		}
	});
}
