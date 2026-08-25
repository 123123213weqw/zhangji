# R36S Dora AI Game Development

AI-first repository for developing a native desktop Dora SSR game and adapting
the finished game to an R36S handheld. The included game, **STARFALL / 星坠拾荒者**,
is a complete example produced with the repository Skill. It keeps PC and R36S
input providers separate instead of forcing handheld controls during desktop
development.

## Play the included game

Native desktop version:

```bash
DORA_PROJECT="$PWD/games/Starfall" ./dora-lab dev
```

Handheld profile / local virtual-controller preview:

```bash
DORA_PROJECT="$PWD/games/Starfall" \
DORA_ENTRY=handheld.lua \
./dora-lab dev
```

Desktop controls are `WASD`/arrows to move, mouse to aim, click/`Space` to
dash, `P` to pause, and `R` to restart. See
[`games/Starfall/README.md`](games/Starfall/README.md) for the R36S mapping and
source map.

## AI coding agent: read this first

1. Read `skills/dora-handheld-dev/SKILL.md`.
2. Use the user's Dora project, or locate a directory containing `init.tsx`,
   `init.ts`, or `init.lua`.
3. Finish and debug the native computer version first. Preserve its keyboard,
   mouse, window, and desktop UI behavior.
4. Build and run autonomously:

   ```bash
   DORA_PROJECT=/absolute/path/to/project ./dora-lab dev
   ./dora-lab log
   ```

5. Only after the desktop version works, read
   `skills/dora-handheld-dev/references/desktop-to-handheld-input.md` and add a
   separate R36S input/UI profile.
6. Connect the physical handheld only when requested or when the local handheld
   profile is ready. Discover it through `./handheld`; never hard-code its DHCP
   address.

Ordinary compile and runtime errors should be diagnosed from Dora output and
fixed without asking the user to operate the engine manually.

## Workflow

```text
native desktop game
        ↓
desktop autonomous build/run/log loop
        ↓
isolated handheld input + 640x480 UI profile
        ↓
R36S Wi-Fi verification
```

The adaptation keeps desktop and handheld input providers separate while game
state, rules, scenes, and assets remain shared.

## Commands

### Dora desktop development

```bash
DORA_PROJECT=/absolute/path/to/project ./dora-lab dev
DORA_PROJECT=/absolute/path/to/project ./dora-lab build
DORA_PROJECT=/absolute/path/to/project ./dora-lab run
./dora-lab status
./dora-lab log
./dora-lab stop
```

`DORA_ENTRY` selects an alternate compiled entry, such as `handheld.lua`; it
defaults to `init.lua`.

When the current directory is itself a Dora project, `DORA_PROJECT` may be
omitted.

### R36S discovery and transfer

```bash
./handheld status --json
./handheld exec -- uname -a
./handheld push -r ./local-project /home/ark/project
./handheld pull /remote/log.txt ./log.txt
```

The wrapper discovers the device by the MAC stored in `config/handheld.json`.
SSH keys remain outside the repository.

## Codex Skill

The repository's reusable Skill is `skills/dora-handheld-dev/`. A cloned
repository is automatically routed to it by `AGENTS.md`.

It can also be installed into Codex explicitly:

```text
$skill-installer install https://github.com/123123213weqw/zhangji/tree/main/skills/dora-handheld-dev
```

Then invoke it with:

```text
$dora-handheld-dev Finish and debug the native desktop Dora game first, then adapt it to R36S.
```

## Repository structure

```text
AGENTS.md                         repository instructions for coding agents
dora-lab                         generic Dora project build/run/log wrapper
handheld                         stable R36S discovery/SSH/transfer entrypoint
config/handheld.json             non-secret device identity
games/Starfall/                  playable desktop + R36S Dora game
tools/handheld.py                connection implementation
tests/test_handheld.py           connection parser tests
tests/test_starfall.py           game profile/package checks
skills/dora-handheld-dev/        installable desktop-first adaptation Skill
```

## Verification

```bash
python3 -m unittest discover -s tests -v
DORA_PROJECT="$PWD/games/Starfall" ./dora-lab build
DORA_PROJECT="$PWD/games/Starfall" DORA_ENTRY=handheld.lua ./dora-lab run
./handheld status --json
```
