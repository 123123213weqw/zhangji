// @preview-file on clear

import {
	App,
	AxisName,
	ButtonName,
	Director,
	KeyName,
	Label,
	PlatformType,
	Size,
} from "Dora";
import { React, toNode } from "DoraX";
import { GamePad } from "InputManager";
import { inputManager, installKeyboardAxes } from "Script/Input";

if (App.platform === PlatformType.macOS || App.platform === PlatformType.Windows) {
	App.fullScreen = false;
	App.winSize = Size(640, 480);
}

const title = Label("sarasa-mono-sc-regular", 24);
if (title) {
	title.text = "R36S Button Lab";
	title.y = 200;
	title.addTo(Director.ui);
}

const status = Label("sarasa-mono-sc-regular", 18);
if (status) {
	status.text = "Click a virtual button or use the keyboard";
	status.y = 165;
	status.addTo(Director.ui);
}

const hints = Label("sarasa-mono-sc-regular", 13);
if (hints) {
	hints.text = "D-pad: arrows  ABXY: J/K/U/I  L1/R1: Q/E\n"
		+ "Left stick: WASD  L2/R2: 1/3  Start/Select: Enter/Esc";
	hints.y = 125;
	hints.textWidth = 600;
	hints.addTo(Director.ui);
}

const history: string[] = [];
const record = (message: string) => {
	history.unshift(message);
	if (history.length > 4) history.pop();
	if (status) status.text = history.join("\n");
	print(`[ButtonLab] ${message}`);
};

const actions = [
	"Up", "Down", "Left", "Right",
	"A", "B", "X", "Y",
	"L1", "R1", "L3", "R3", "Select", "Start",
];

for (const action of actions) {
	inputManager.onCompleted(action, () => record(`action ${action}`));
}

const inputNode = inputManager.getNode();
inputNode.onButtonDown((controllerId, buttonName) => {
	record(`pad ${controllerId} down ${buttonName}`);
});
inputNode.onButtonUp((controllerId, buttonName) => {
	record(`pad ${controllerId} up ${buttonName}`);
});
inputNode.onAxis((controllerId, axisName, value) => {
	record(`pad ${controllerId} axis ${axisName}=${value}`);
});
inputNode.onKeyDown((keyName) => {
	record(`key down ${keyName}`);
});
inputNode.onKeyUp((keyName) => {
	record(`key up ${keyName}`);
});

installKeyboardAxes();
inputManager.pushContext("Lab");

toNode(
	<GamePad
		inputManager={inputManager}
		color={0xff69d2ff}
		primaryOpacity={0.58}
		secondaryOpacity={0.28}
	/>,
)?.addTo(Director.ui);

// Deterministic smoke test: the same injection API is used by GamePad touches.
inputManager.emitButtonDown(ButtonName.A);
inputManager.emitButtonUp(ButtonName.A);
inputManager.emitKeyDown(KeyName.J);
inputManager.emitKeyUp(KeyName.J);
inputManager.emitAxis(AxisName.LeftX, 0.5);
inputManager.emitAxis(AxisName.LeftX, 0);
print("BUTTON_LAB_SELF_TEST_OK");
