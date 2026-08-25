# Handheld Coding Agent Instructions

This repository is the connection layer between a coding agent and the owner's
Wi-Fi handheld. The handheld is discovered by MAC address; never assume or
hard-code its current DHCP address in commands or generated files.

## Required workflow

1. Before any handheld task, run:

   ```bash
   ./handheld status --json
   ```

2. If the status succeeds, execute non-interactive work with:

   ```bash
   ./handheld exec -- <command> [args...]
   ```

3. Transfer files only through:

   ```bash
   ./handheld push [-r] <local> <remote>
   ./handheld pull [-r] <remote> <local>
   ```

4. Use `./handheld shell` only when an interactive terminal is genuinely
   required. Prefer `exec` because its result is deterministic and auditable.

5. If discovery fails, report that the handheld is not visible on the current
   Wi-Fi. If discovery works but SSH is closed, ask the user to enable ArkOS
   **Options -> Enable Remote Services**. Do not scan unrelated ports or guess
   another device.

## Device facts

- Expected hostname: `darkosre-r36`
- MAC identity: read from `config/handheld.json`
- SSH user: read from `config/handheld.json`
- Authentication: dedicated key outside the repository
- No password, private key, token, or other secret may be committed here

## Verification

After changing the connection tooling, run:

```bash
python3 -m unittest discover -s tests -v
./handheld status --json
./handheld exec -- uname -a
```
