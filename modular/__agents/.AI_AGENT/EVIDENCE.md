# Discovery and self-challenge

Verification: tools/build/build.bat dm succeeded, 0 errors/0 warnings. git diff --check clean before documentation update. Regression source assertions added for scatter bounds, migrations and all preset spacing defaults; not executed in this turn. No test binaries generated. Runtime game behavior not interactively verified.

Spacing read-only challenge: combat_spacing.get_weight is also rechecked on trigger; cover has a separate crowding rejection. Both must be gated to fully disable the feature. No movement/retreat replacement required.

Scatter challenge: apply_bullet_scatter is too early (burst penalties added later). simulate_scatter owns final directional angle; hook before random offset avoids weapon mutation and handles bursts. Old path audit: no earlier multiplier added, accuracy independent. Metadata drives panel; imports must migrate both server and personal slots. Prior uncommitted tuning preserved.

PASS WITH RISKS. Health uses species.total_health so maxHealth-only is insufficient; modular hook required. Ingestion waits10 seconds in vessels, unseen by blood-only OD checks; track patient-wide vessels until transfer/Destroy. Per-medic cooldown rejected. Grenade planning and release must use same policies. Separation respects action slots and orders. Bounded candidates, no unbounded list mutation.

Stale task-state contained stash markers from finished tasks; no Git unmerged product paths. Replaced only four task-state files for current scope. Include chain colonialmarines.dme -> human_ai/_human_ai.dme; schema -> service snapshots -> actions.

## Fidelity
M1 DONE: schema health10–300/accuracy0.3–3, dynamic panel/help, version3 migration; service sets per-human percent/maxHealth, updatehealth uses modular capacity hook, injuries retained, dead application excluded.
M2 DONE: independent grenade_safety/throwback_safety in all launch/return planning and release paths, self distance/fuse/trajectory retained.
M3 DONE: throwback gate radius2; bounded escape scorer prioritizes distance5 and safe floors; hand/launcher landing restricted to hostile or adjacent tile.
M4 DONE: combat_spacing action, bounded adjacent steps, crowd penalty, 1s cooldown, order boundaries; cover destinations reject crowding.
M5 DONE: swallowed vessels tracked patient-wide through transfer/Destroy; dose prediction includes pending and blood amounts. Existing final transfer guards retained.
KEEP/REJECT DONE: no individual settings, no shared species changes, no forced movement, module panel retained; upstream only health and ingestion hooks.

DM production and CIBUILDING compile0/0, TGUI webpack and tsc pass, diff-check pass. Historical50 lobby errors did not reproduce in this checkout; no lobby changes made. Focused runtime first run: schema/migration/pending-dose pass; two old fixture assumptions failed (5x5 room insufficient for5-tile escape, easy preset incorrectly expected all medicine disabled). Corrected fixture size with restoration and expected drugs=false. Second run four settings/medicine tests passed, grenade test exposed firearm-lane filtering of unsafe throwback. Separated can_target fire-lane flag (default true for all other callers), throwback still validates its physical trajectory. Third run grenade test status0 in data/unit_tests.json; all five selected tests have passing final results across reruns. Wrapper itself exited nonzero8528 after final test, no runtime exception recorded; clean full runner status not claimed. No leftover test DreamDaemon process. Temporary TEST_FOCUS removed, final production rebuild0/0. No in-game visual verification or live dispersion battle test.

| ID | Type | Status | Evidence |
| --- | --- | --- | --- |
| M1 | MUST | DONE | schema/service/health hook, lifecycle and migration tests |
| M2 | MUST | DONE | hand/launcher/throwback policy checks; grenade regression |
| M3 | MUST | DONE | radius2 gate, five-tile escape scorer, adjacent landing search |
| M4 | MUST | DONE | combat_spacing.dm and cover destination exclusion |
| M5 | MUST | DONE | patient-owned pending vessels and passing dose regression |
| K1/R1 | KEEP/REJECT | DONE | global snapshot guards, modular logic, only two upstream hook surfaces |
| C1 | CHECK | DONE WITH LIMITATION | builds and assertions pass; runner nonzero exit remains unexplained |
