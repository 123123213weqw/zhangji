# R36S input mapping

## Contract

Keep one `InputManager` instance in `Script/Input.ts`. Keyboard keys, Dora's
on-screen `GamePad`, and the R36S SDL controller must all feed this instance.
Game code listens to Action names or controller axes and must not contain a
parallel keyboard-only control path.

For a new project, copy or adapt the maintained adapter from
`dora/ButtonLab/Script/Input.ts`. Preserve the exported interface:

```ts
export const INPUT_CONTEXT: string;
export const inputManager: InputManager;
export function installKeyboardAxes(): void;
```

Initialize it once in the entry file:

```ts
import { AxisName } from "Dora";
import {
	INPUT_CONTEXT,
	inputManager,
	installKeyboardAxes,
} from "Script/Input";

installKeyboardAxes();
inputManager.pushContext(INPUT_CONTEXT);

inputManager.onCompleted("A", () => jump());
inputManager.onCompleted("Start", () => pause());

inputManager.getNode().onAxis((_controllerId, axis, value) => {
	if (axis === AxisName.LeftX) player.moveX = value;
	if (axis === AxisName.LeftY) player.moveY = value;
});
```

Add Dora's `GamePad` with the same `inputManager` only when on-screen controls
are wanted. Do not create another manager for the virtual pad.

## Fixed mapping

| Game Action/input | Keyboard substitute | R36S/Dora input |
| --- | --- | --- |
| `Up`, `Down`, `Left`, `Right` | Arrow keys | D-pad |
| `A` | Space or J | A |
| `B` | Left Shift or K | B |
| `X`, `Y` | U, I | X, Y |
| `L1`, `R1` | Q, E | Left/Right shoulder |
| `L3`, `R3` | Z, C | Left/Right stick click |
| `Select`, `Start` | Escape, Enter | Back, Start |
| `LeftX`, `LeftY` | W/A/S/D | Left stick axes |
| `RightX`, `RightY` | T/F/G/H | Right stick axes |
| `LeftTrigger`, `RightTrigger` | 1, 3 | L2/R2 axes |

The direction order for both keyboard stick groups is up/left/down/right.
L2/R2 are axes, not `ButtonName` values. The R36S Guide/FN button is outside
Dora's standard `ButtonName`; never make it required for gameplay.

## Verification

After changing input code:

1. Run `DORA_PROJECT=/absolute/project ./dora-lab dev`.
2. Confirm one keyboard substitute produces the intended Action.
3. Confirm the matching virtual button produces the same Action.
4. Move each emulated stick and confirm its axis returns to zero on release.
5. Print a deterministic input marker and verify it with `./dora-lab log`.

On the physical device, compare the Action/axis log rather than Linux button
numbers. A game that passes only keyboard events is not ready for handoff.
