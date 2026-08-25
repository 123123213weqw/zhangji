# Desktop-first R36S adaptation

## Principle

Finish a native desktop control scheme first. R36S support is a second input
provider for the same gameplay intents, not a table that pretends controller
buttons are keyboard keys.

Do not put platform checks throughout game logic. Gameplay should expose
semantic intents such as `Move`, `Primary`, `Cancel`, `Interact`, `Pause`, and
`Camera`; input providers produce those intents.

## Adaptation workflow

1. Inventory every desktop input and the gameplay intent it causes. Include
   mouse position/delta, held keys, clicks, wheel input, chords, and UI focus.
2. If raw keyboard or mouse checks are scattered through gameplay, move only
   those checks behind a desktop input provider without changing behavior.
3. Add a handheld provider beside it. Map controller buttons and axes to the
   existing intents; do not remove or rewrite the desktop provider.
4. Select the provider through one target/profile setting at startup. Keep
   resolution and handheld UI selection in that same profile boundary.
5. Add the on-screen Dora `GamePad` only to the handheld preview so developers
   can test the controller provider without possessing the R36S.

A suitable project shape is:

```text
Script/Input/Actions.ts       semantic intents consumed by the game
Script/Input/Desktop.ts       native keyboard and mouse provider
Script/Input/Handheld.ts      Dora ButtonName/AxisName provider
Script/TargetProfile.ts       selects desktop or handheld at startup
```

Names may follow the existing project style; preserving the separation is what
matters.

## Default handheld choices

Derive the final mapping from gameplay semantics. When the game has no stronger
convention, use these defaults:

| Gameplay intent | R36S control |
| --- | --- |
| Digital menu/navigation | D-pad |
| Player movement | Left stick; add D-pad only if digital movement is valid |
| Camera or pointer-like aim | Right stick |
| Primary/confirm | A |
| Secondary/cancel/back | B |
| Two additional actions | X and Y |
| Frequent modifiers/actions | L1 and R1 |
| Analog actions | L2 and R2 axes |
| Rare stick-mode actions | L3 and R3 |
| Pause | Start |
| Inventory/map/secondary menu | Select/Back |

Prefer direct mappings for actions used together. If the desktop game depends
on pointer precision, text entry, or more simultaneous actions than the
controller can express, adapt the interaction design instead of inventing an
opaque keyboard-to-button conversion.

L2/R2 are `AxisName` values, not `ButtonName` values. The R36S Guide/FN button
is outside Dora's standard `ButtonName`; never require it for gameplay.

## Display and UI profile

The desktop profile keeps its native window and PC UI. The handheld profile:

- uses a 640x480 logical layout;
- replaces hover-only interactions with focus or direct selection;
- keeps essential text and hit targets readable at that resolution;
- provides controller focus for menus and dialogs;
- avoids requiring a mouse or software keyboard for the main loop.

Do not shrink the desktop UI blindly. Reflow only the handheld profile while
sharing scenes, state, assets, and game rules.

## Verification

1. Re-run the desktop scenario and confirm its original controls still work.
2. Enable the handheld profile locally and exercise every mapped intent with
   the virtual `GamePad` or a controller.
3. Confirm sticks return to zero, triggers cover their expected range, and
   simultaneous actions remain usable.
4. Run the same scenario on R36S and compare intent-level logs, not Linux button
   numbers.
5. Document the final player-facing R36S layout after adaptation; do not present
   the temporary PC development keys as the handheld control guide.
