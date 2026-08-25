---
name: dora-handheld-dev
description: Develop and autonomously debug a native desktop Dora SSR game first, then adapt the working game to R36S controls and constraints. Use for Dora game coding, desktop build/run/log iteration, handheld adaptation, or desktop-to-handheld handoff in this repository.
---

# Dora Handheld Dev

Build the desktop game first. Preserve normal computer input, window behavior,
and debugging ergonomics until the game works. Treat R36S support as a later
adapter and compatibility pass, not as a keyboard substitute or a prerequisite
for ordinary coding.

## Find the project

Work from the repository root. Use the project named by the user. Otherwise,
locate the nearest Dora folder containing one `init.tsx`, `init.ts`, or
`init.lua`. If none exists, create a normal desktop Dora project for the user's
game instead of starting from a handheld simulator.

Pass a non-default project to the wrapper with an absolute path:

```bash
DORA_PROJECT=/absolute/path/to/project ./dora-lab dev
```

## Autonomous desktop loop

1. Inspect the project and preserve its existing language and structure.
2. Preserve the intended native computer controls, including keyboard and mouse.
   Do not show the handheld `GamePad`, force 640x480, or replace PC controls
   during this phase.
3. After source changes, run `DORA_PROJECT=... ./dora-lab dev`. The wrapper
   starts Dora, connects the TypeScript compiler when needed, builds, and runs.
4. Read `./dora-lab log`; fix compile/runtime failures and repeat without asking
   the user to operate Dora for ordinary recoverable errors.
5. Add a deterministic startup or scenario marker for new behavior and confirm
   it in the log. Exercise the actual desktop control path.

## Handheld adaptation pass

Start this only after the desktop game is playable or when the user explicitly
requests it. Read
[references/desktop-to-handheld-input.md](references/desktop-to-handheld-input.md)
before changing controls. Inventory the game's existing player intents, keep
the desktop provider intact, and add a separate R36S input/UI profile. The
on-screen `GamePad` is an adaptation test tool and must not become the desktop
game's primary interface.

Prefer separate entry files when target setup differs. Keep `init.ts`/`init.lua`
as the native desktop entry and compile a second entry such as
`handheld.ts`/`handheld.lua`. Run that profile without rewriting the desktop
entry:

```bash
DORA_PROJECT=/absolute/path/to/project DORA_ENTRY=handheld.lua ./dora-lab dev
```

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
5. Keep device-specific input, resolution, layout, and asset adjustments in the
   handheld profile; do not fork the game logic into desktop and handheld games.

If the handheld is unavailable, continue all useful desktop work and report the
remaining device-only verification instead of blocking development.
