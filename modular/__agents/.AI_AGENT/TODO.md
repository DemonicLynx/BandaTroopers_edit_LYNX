# Contract

Current: implement cover handoff, phase deadlines, bounded retries, update help and regression assertions; compile. Live map validation remains separate.

Current follow-up DONE: radial picker replaced, behavior documented, heading/depth regression assertions added. Production DM compile 0 errors/0 warnings; diff check clean. New runtime assertions and live multi-door scenario NOT run. No test build artifacts generated. Earlier completed items below remain KEEP requirements.

M1 DONE memory/search/prediction bounded by radius, time, points.
M2 DONE squad roles and sharing real observations only, radius/cadence caps.
M3 DONE corner/door hesitation without per-tick repeated pauses.
M4 DONE completion clears search, resumes orders/following or returns to start with timeout.
M5 DONE panel master/feature controls, help, presets, v6 persistence.
K1 DONE physical navigation, emergencies, Hold, dead exclusion, three personal slots.
R1 DONE no live hidden enemy coordinates, blind global scans, teleportation, legacy fallback.
C1 DONE WITH LIMITATION: DM0/0, TGUI/tsc pass, three focused assertions suites pass; runner exits nonzero8640. Focus removed, test artifacts deleted after process check. Live visual validation not performed.
Old path audit: combat/chase_target.dm removed/replaced by pursuit/chase_action.dm under same action type; settings_allow_action must not retain old timer-only gate.
