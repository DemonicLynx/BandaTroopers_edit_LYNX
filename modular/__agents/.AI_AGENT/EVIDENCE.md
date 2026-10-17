# EVIDENCE

## Discovery
- `banda_menu_interface` defaults to `terminal`; `load_banda_menu_interface()` normalizes missing/invalid values to Terminal and `save_banda_menu_interface()` writes the root key.
- Both full preference load/save paths call the optional Lobby UI provider hooks.
- The terminal Settings action and right-panel verb call `save_preferences()` but ignore its boolean result, then unconditionally announce success.
- The right-panel verb returns immediately when the selected value already matches memory, so it neither rewrites the savefile nor refreshes a stale lobby surface.
- `show_selected_lobby()` already selects the renderer exclusively from the loaded preference; no separate lobby-state fix is required.

## Plan-mapping challenge — PASS
1. Doubt: forcing Terminal on every load would fix the screenshot. Rejected because it destroys the approved Classic choice. Keep Classic only when explicitly saved.
2. Doubt: a second dedicated theme file could be more reliable. Rejected because the established account savefile already owns the key and has locking/version semantics.
3. Doubt: only changing the success message is enough. Rejected because the same-value early return can still leave a stale Classic surface and never rewrite the key.
4. Doubt: callers can each handle rollback. Rejected to avoid divergence; one checked helper owns apply/save/rollback.

Alternatives rejected: unconditional Terminal override, parallel persistence, and unchecked retries. The existing synchronous save result is the authoritative success signal.

## Verification
- Plan fidelity: Terminal remains the default for missing/invalid data; successfully saved Classic remains valid; both entrypoints use the same checked save/rollback helper; same-value selection is no longer skipped and still refreshes the lobby.
- `node --test modular/lobby_ui/tools/terminal.test.cjs`: 12/12 passed, including the checked-persistence source contract.
- Added DM regression coverage for default, missing, invalid, explicit Terminal and explicit Classic savefile round trips; it compiles in the normal DM target.
- `check_modularity.ps1 -StaticOnly`: passed.
- `git diff --check` for the six changed module files: passed.
- `tools/build/build.bat dm tgui --force`: DM 0 errors, 0 warnings; TGUI up to date; 20.718s.
- Full `check_modularity.ps1`: enabled and disabled-module builds passed; disabled DM compile 0 errors/0 warnings; `modular.dme` restored byte-for-byte; final static audit passed.
- Deployment: six changed module files synchronized to `C:\BandaTroopers_LYNX` and the PR `replace_files` mirror; PR README synchronized separately; all 13 destination hashes matched staged sources.
- Not run: live reconnect/server-restart cycle against a real player savefile. Failed IO is now visible and cannot be reported as a successful selection.
