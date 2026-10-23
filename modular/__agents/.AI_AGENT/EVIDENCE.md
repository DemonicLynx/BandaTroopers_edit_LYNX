# Read-only plan mapping

Stall follow-up compiled via build.bat dm: exit0, 0 errors/0 warnings. New regression assertions not run. User reprioritized containment diagnosis before live verification.

Containment diagnosis round61: runtime.log 16:16:32 UTC reports Moses Logue loc=/obj/effect/decal/cleanable/blood/splatter. User screenshot shows Xia Wan in firedoor.contents. Existing diagnostic filters only chair/table/barricade, misses both. Concrete reachable defect: grenade_reactions get_live_grenade_escape_turf and idle_defensive_positions find_idle_defensive_position iterate range() with var/turf as anything, disabling type filtering over mixed atoms. human_ai_turf_is_safe lacks isturf guard, so nondense object with empty contents can pass. move_to_next_turf and complete_adjacent_move_to_turf accept nominal turf arguments without runtime type check and may call human.Move(object). This explains class of bug; exact triggering call for screenshot not logged. User requested investigation only; no containment fix yet.

Stall fix challenge: can_start/get_weight reject in_cover; maintenance must release it before cover wins action arbitration. Move(FALSE) can follow delayed door interaction or path failure; chase currently immediately advances. Old observed_at timeout also appears in core exit_combat and must be replaced there. Preserve nav handlers, diagnostics and dirty files. Actual screenshot cause is not proven.

Follow-up result: search.dm now samples three rays with depth increments capped at original radius; no radial fallback. Approach/observed/facing heading selection explicit; lateral initial flank retained. Native movement and scenery diagnostic unchanged. DM compile via tools/build/build.bat dm: 0 errors/0 warnings, exit0; git diff --check clean. Source assertions added for heading selection and depth termination, not executed this iteration. Multi-door runtime traversal not verified; uses existing handlers. No test artifacts created.

Follow-up challenge: search.dm currently scans range(radius, anchor); chase_action passes selected turf to move_to_next_turf; native pathfinding uses LinkBlocked and interactions. Replace picker, not collisions. Bounded directional targets do not guarantee accessible routes; failed routes retain existing point/time budgets. Door count itself is not a limit; search radius/deadline still are. Prior dirty changes preserved. Verification below belongs to previous iteration until follow-up completion.

## Final fidelity

| ID | Status | Evidence |
|---|---|---|
| M1 | DONE | pursuit/memory.dm and search.dm: two visible positions, no hidden-target coordinate read, radius6/points8/deadline/stall caps |
| M2 | DONE | scout/cover/flank roster roles; same-squad/faction/level one-hop reports capped16 at1Hz; no current_target assignment |
| M3 | DONE | per-tile nonblocking caution called only during pursuit movement, not emergency actions |
| M4 | DONE | expiry maintenance, master/Hold/new-order cancellation, retained orders and squad following,10-second fallback return |
| M5 | DONE | Pursuit panel section, eleven fields including existing chase_time, help, presets, v6 server/personal migration |
| KEEP/REJECT | DONE | ordinary Move path retained, no forceMove/sleep in pursuit, no blanket obstacle changes, previous scenery diagnostic preserved |

Old path audit: combat/chase_target.dm deleted and include replaced, timer-only settings gate replaced; old unrestricted enter_combat target_turf sharing removed. No TEST_FOCUS remains. git diff --check clean.

Verification: production DM0 errors/0 warnings, webpack and tgui-tsc pass. Focused runtime human_ai_pursuit, human_ai_pursuit_team, human_ai_settings_help_and_migration each status0 in data/unit_tests.json. Runner still returns nonzero8640 after writing results; not a clean full runner claim. Final small optimisation (reuse already confirmed visibility) and follower-return routing received final compile, not another runtime run. No live map/UI visual test. Removed only colonialmarines.test.dme/.dmb/.rsc after checking no test DreamDaemon remained; source regressions retained.

PASS WITH RISKS. Process scheduler checks settings for new and ongoing actions; chase old weight6 below cover15 and emergency handling. current_order survives combat; patrol requires !in_combat. set_target/update_target_pos are real-visibility observation entrypoints; on_shot target_turf cannot be used as verified memory. Search maintenance must expire even if action not selected. UI section list is explicit; field schema dynamic. Save exact-schema validation requires migration for server and slots. Death/deletion/target switch must clear search memory. Separate files under pursuit; no upstream hooks required.

Risks: asynchronous path delays => bounded per-goal stall timeout; role duplication => stable roster order and bounded candidate reservations; stale reports => original timestamp and consumed timestamp, no rebroadcast; caution pauses => per-position once; normal combat-decay timer => do not erase active finite search. Include via human_ai/_human_ai.dme; old combat/chase_target implementation must be deleted.
