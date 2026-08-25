import { Director, KeyName, Node } from "Dora";
import { GameActions } from "Script/Input/Actions";

export function installDesktopInput(actions: GameActions, width: number, height: number, renderScale: number): Node.Type {
	const node = Node();
	node.width = width;
	node.height = height;
	node.scaleX = renderScale;
	node.scaleY = renderScale;

	const setKey = (keyName: KeyName, pressed: boolean) => {
		switch (keyName) {
			case KeyName.A:
			case KeyName.Left:
				actions.setDirection("left", pressed);
				break;
			case KeyName.D:
			case KeyName.Right:
				actions.setDirection("right", pressed);
				break;
			case KeyName.W:
			case KeyName.Up:
				actions.setDirection("up", pressed);
				break;
			case KeyName.S:
			case KeyName.Down:
				actions.setDirection("down", pressed);
				break;
		}
	};

	node.onKeyDown((keyName) => {
		setKey(keyName, true);
		switch (keyName) {
			case KeyName.Space:
			case KeyName.Return:
				actions.queuePrimary();
				break;
			case KeyName.P:
			case KeyName.Escape:
				actions.queuePause();
				break;
			case KeyName.R:
				actions.queueRestart();
				break;
		}
	});
	node.onKeyUp((keyName) => setKey(keyName, false));
	node.onMouseMove((touch) => actions.setPointer(touch.location.x, touch.location.y));
	node.onTapBegan((touch) => {
		actions.setPointer(touch.location.x, touch.location.y);
		actions.queuePrimary();
	});
	node.addTo(Director.entry);
	return node;
}
