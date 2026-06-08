# objectscript-refactor-linter-demo

A small InterSystems IRIS web app — a playable Space Invaders with a persistent
high-score board — used to try out `oto-lint`, an ObjectScript linter.

The score logic lives in `.mac` routines under `src/`; the game and UI are a CSP
page. `oto-lint` runs over the routines in CI on every push and PR and uploads
SARIF, so findings show up under Security → Code scanning and inline on the diff.

```
src/score/Board.mac      high-score storage + ranking
src/web/ArcadeWeb.cls     Space Invaders (canvas) + leaderboard + JSON endpoints
```

Lint locally:

```sh
bin/oto-lint.linux --config=.oto-lint.json --format=text $(find src -name '*.mac')
```

Enabled rules and severities live in `.oto-lint.json`. `.cls` classes aren't
parsed yet, so the UI class is not linted.
