# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`git-test` is a single-file bash git subcommand (the `git-test` script) that runs a test command against each *distinct tree* in a rev-list, caching results so amended/reordered commits with identical content are not re-tested. There is no build step; the deliverables are `git-test` (the script) and `git-test.1` (the man page).

This is a fork (`CervEdin/git-test`) of Spotify's archived `spotify/git-test` repo — upstream is dead, so there is nowhere to send patches; changes land here.

## Commands

Run the test suite (self-contained; creates a sandbox repo in `$TMPDIR/subject/` — it `rm -Rf`s and re-creates that directory each run):

    sh test.sh -v

Useful flags: `-q` quiet, `-x` exit on first failure, `-s <shell>` to run `git-test` under a different shell (default `/bin/bash`). There is no way to run a single test; `test.sh` is one linear script of assertions.

Lint (CI uses CodeClimate with ShellCheck on `git-test`, `test.sh`, `regress.sh`):

    shellcheck git-test test.sh regress.sh

Regression-test the whole branch history using git-test itself (see also README "Self-Test"):

    ./regress.sh

## Architecture

- **`git-test`** — everything lives here. Key mechanics:
  - Sources `git-sh-setup` from `git --exec-path` and uses `OPTIONS_SPEC` / `git rev-parse --parseopt` conventions, so it behaves like a core git command (clean work tree required, `cd_to_toplevel`).
  - **Cache**: files in `.git/test-cache/` named `<short-tree>_<short-verify-hash>_(pass|fail)`. The key hashes the verify command itself (`git hash-object`), so different test commands don't share results. A tree with both `_pass` and `_fail` files is "FLAPPY". `--redo` modes decide which cached results to ignore.
  - **Locking**: `mkdir "$cache"/testing` as a lock dir; `atexit_cleanup` trap restores the starting ref and unlocks.
  - **Ref selection** (`decide_refs`): with no args, excludes the configured test branch (`branch.<name>.test`, then `test.branch`, then `@{u}`), plus every remote's `master` and same-named branch; refuses to test the entire history if nothing narrows it down.
  - **Config priority** for verify/pre/post: command-line flag > `GIT_TEST_*` env var > `git config test.*` (this ordering is asserted by tests).
  - It literally `git checkout`s each commit to run tests, then checks the starting point back out.
  - Exit codes: 0 success, 5 for most failures (a failing test, lock held, dirty tree, no verify action).
- **`test.sh`** — bespoke pass/fail harness (`check` / `check_fail` assert on `$?` of the previous line; output is captured to `out`/`err` files and grepped). Tests hardcode the branch name `master`, so the sandbox repo is pinned to `-b master`.
- **`debian/`, `PKGBUILD`** — packaging only.

## Conventions

- The script targets bash (shebang `#!/bin/bash`) but other shells are supported "patches welcome"; avoid gratuitous bashisms and keep ShellCheck clean.
- Messages are printed directly (`echo`/`printf '%s'`), not wrapped in `gettext`/`eval_gettext` — the script never shipped its own translation catalog, so that wrapping only cost a fork per message. Tests grep for exact message text — update `test.sh` when changing output.
- Version lives in three places: `VERSION=` in `git-test`, `git-test.1` header, and `debian/changelog`.
