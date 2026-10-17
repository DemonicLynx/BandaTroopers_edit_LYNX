# PLAN — Persisted terminal-interface selection

## MUST
- Terminal remains the default when no valid saved interface exists.
- Explicit Terminal or Classic selection is written to the account preferences savefile and restored after reconnect/server restart.
- The UI refreshes to the selected interface even when the in-memory value already matches the selection.
- Success is reported only after `save_preferences()` succeeds; failure keeps the previous value and is shown to the player.

## KEEP
- Existing root savefile key, provider load/save hooks, terminal Settings entry and right-panel Preferences verb.
- Explicitly saved Classic remains respected; “terminal priority” means default/fallback, not removal of Classic.
- All lobby/editor presentation and disabled-module fallback behavior.

## REJECT
- A second savefile or client-side-only theme state.
- Unconditional “saved” messages after failed IO.
- Forcing Terminal over an explicitly and successfully saved Classic choice.

## CHECK
- Default/missing/invalid/Terminal/Classic savefile round trips.
- Both selection entrypoints use the checked save helper and refresh the lobby.
- Static modularity, diff check and standard build.
