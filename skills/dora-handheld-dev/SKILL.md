---
name: dora-handheld-dev
description: Develop and autonomously debug Dora SSR games in the desktop R36S simulation, then move a locally verified build to the configured handheld. Use for Dora/R36S game coding, input mapping, build/run/log iteration, or desktop-to-handheld handoff in this repository.
---

# Dora Handheld Dev

Use the desktop Dora runtime for the fast development loop. The physical R36S
is a final compatibility target, not a prerequisite for ordinary coding.

## Find the project

Work from the repository root. Use the project named by the user. Otherwise,
locate the nearest Dora folder containing one `init.tsx`, `init.ts`, or
`init.lua`; fall back to `dora/ButtonLab`.

Pass a non-default project to the wrapper with an absolute path:

```bash
DORA_PROJECT=/absolute/path/to/project ./dora-lab dev
```

## Autonomous desktop loop

1. Inspect the project and preserve its existing language and structure.
2. Run `./dora-lab keys` when input behavior is relevant. Game logic should
   consume the shared Dora `InputManager` actions rather than raw OS key codes.
3. After source changes, run `DORA_PROJECT=... ./dora-lab dev`. The wrapper
   starts Dora, connects the TypeScript compiler when needed, builds, and runs.
4. Read `./dora-lab log`; fix compile/runtime failures and repeat without asking
   the user to operate Dora for ordinary recoverable errors.
5. Add a deterministic startup or scenario marker for new behavior, and confirm
   it in the log. Also exercise the relevant keyboard or virtual-pad path.

Keyboard, the on-screen `GamePad`, and the R36S controller may be used together.
Keep the competition mapping visible with `./dora-lab keys`; do not create a
separate keyboard-only gameplay implementation.

For a new project or any input-related change, read
[references/input-mapping.md](references/input-mapping.md). It defines the
Action names, keyboard-to-handheld conversion, required adapter module, and
copy-ready listener pattern. Ensure the project has that adapter before calling
its input support complete.

## Move to the handheld

Do this when the user requests a device check or after the desktop build is
working:

1. Build the selected project with `DORA_PROJECT=... ./dora-lab build` so the
   handoff contains Lua runtime files and assets.
2. Run `./handheld status --json`. Never reuse a remembered DHCP address.
3. Inspect the current Dora launcher/workspace on the device before choosing a
   destination. Transfer only through `./handheld push` and execute through
   `./handheld exec`.
4. Run the same scenario marker on the device, collect its log, and compare
   resolution, input, asset loading, and runtime errors with desktop results.
5. Keep device-specific adjustments isolated to configuration or an adapter;
   do not fork the game logic into desktop and handheld versions.

If the handheld is unavailable, continue all useful desktop work and report the
remaining device-only verification instead of blocking development.
