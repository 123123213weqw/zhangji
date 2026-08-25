import { AxisName, ButtonName } from "Dora";
import { CreateManager, Trigger } from "InputManager";
import { GameActions } from "Script/Input/Actions";

export interface HandheldInput {
	manager: ReturnType<typeof CreateManager>;
}

const CONTEXT = "Starfall";

export function installHandheldInput(actions: GameActions): HandheldInput {
	const manager = CreateManager({
		[CONTEXT]: {
			Primary: Trigger.Down({ button: ButtonName.A }),
			Pause: Trigger.Down([
				{ button: ButtonName.Start },
				{ button: ButtonName.Back },
			]),
			Restart: Trigger.Down({ button: ButtonName.X }),
		},
	});
	const node = manager.getNode();
	let leftX = 0;
	let leftY = 0;
	let rightX = 0;
	let rightY = 0;

	manager.onCompleted("Primary", () => actions.queuePrimary());
	manager.onCompleted("Pause", () => actions.queuePause());
	manager.onCompleted("Restart", () => actions.queueRestart());

	node.onButtonDown((_controllerId, buttonName) => {
		switch (buttonName) {
			case ButtonName.Left: actions.setDirection("left", true); break;
			case ButtonName.Right: actions.setDirection("right", true); break;
			case ButtonName.Up: actions.setDirection("up", true); break;
			case ButtonName.Down: actions.setDirection("down", true); break;
		}
	});
	node.onButtonUp((_controllerId, buttonName) => {
		switch (buttonName) {
			case ButtonName.Left: actions.setDirection("left", false); break;
			case ButtonName.Right: actions.setDirection("right", false); break;
			case ButtonName.Up: actions.setDirection("up", false); break;
			case ButtonName.Down: actions.setDirection("down", false); break;
		}
	});
	node.onAxis((_controllerId, axisName, value) => {
		switch (axisName) {
			case AxisName.LeftX: leftX = value; break;
			case AxisName.LeftY: leftY = value; break;
			case AxisName.RightX: rightX = value; break;
			case AxisName.RightY: rightY = value; break;
		}
		actions.setLeftAxis(leftX, leftY);
		actions.setRightAxis(rightX, rightY);
	});
	manager.pushContext(CONTEXT);
	return { manager };
}
