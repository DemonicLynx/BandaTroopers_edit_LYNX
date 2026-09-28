# EVIDENCE

## E-001: Read-only findings
- `human_ai_turf_is_safe()` rejects every structure except a traversal allowlist; underfloor pipes, cables, vents, and disposal pipes therefore block otherwise walkable floors.
- The flora allowlist currently admits all grass, bush, jungle, and forest families when non-dense, including above-mob sprites that visually hide NPCs.
- Normal and idle destinations use strict safety, but path steps use the flora allowlist; an NPC can remain visually hidden whenever traversal stalls on such a step.
- `quick_approach.Destroy()` always clears the brain order, so any combat/emergency preemption permanently loses the command.
- Quick Approach uses `ACTION_USING_LEGS`, while Fire At Target uses only `ACTION_USING_HANDS`; they are naturally compatible if the order survives.
- Local detours do not remember the immediately previous turf, permitting A-B-A oscillation around an unreachable route.

## E-002: Plan-mapping self-challenge
- PASS WITH BOUNDED EXCEPTIONS.
- Broad non-dense structure allowance rejected: it reintroduces disappearing NPCs in props and containers.
- Broad FLOOR_PLANE allowance rejected: lattices, weeds, traps, and alien structures share that plane.
- Making Approach an uninterruptible blocking action rejected: it would suppress emergency reactions and is unnecessary for concurrent firing.
- Selected approach keeps exact type/layer guards, separates persistent order state from transient action state, and bounds genuine failures.

## E-003: Verification plan
- Focused unit assertions for underfloor allowlist, obscuring flora rejection, non-conflict with firing, persistent preemption, bounded failure, and detour memory.
- `git diff --check`, include/callsite audit, and changed-scope inspection.
- DreamMaker/dm-test intentionally not run under the user's standing constraint.

## E-004: Implementation
- Added an exact non-dense allowlist for atmos pipes/vents, power cables, and disposal pipes.
- Flora traversal now rejects tall grass and any flora rendered at or above `MOB_LAYER`; low grass remains traversable but is still not a standing destination.
- Successful movement remembers the previous turf and local step scoring strongly avoids an immediate return when another route exists.
- Failed idle redistribution now waits five seconds before retrying.
- Quick Approach order state survives action deletion, clears explicitly on arrival/reset/Hold, and stops after three real navigation failures or two A-B-A returns.
- Quick Order preemption preserves `target_turf` when a combat target exists, while movement remains legs-only and firing hands-only.

## E-005: Verification
- PASS: `git diff --check` on all changed tracked files; no whitespace errors.
- PASS: Human AI module manifest includes navigation safety, quick-order control, and idle-position modules.
- PASS: exact underfloor type definitions exist for pipes, cable, and disposal pipe.
- PASS: focused assertions cover low/obscuring flora, all allowed underfloor families, arbitrary FLOOR_PLANE rejection, concurrent firing compatibility, target preservation, interrupted-order persistence, and bounded unreachable-order failure.
- PASS: `dreamchecker` lookup confirmed it is unavailable.
- NOT RUN: DreamMaker/dm-test, following the user's standing request.

## Plan fidelity matrix
| ID | Status | Evidence |
| --- | --- | --- |
| M1 | DONE | `human_ai_is_underfloor_infrastructure()` exact allowlist. |
| M2 | DONE | Layer and tall-grass guards in `human_ai_is_passable_flora()`. |
| M3 | DONE | Approach Destroy no longer erases brain state; combat target turf is preserved. |
| M4 | DONE | Previous-turf scoring plus bounded failure/oscillation counters. |
| K1 | DONE | Generic structures and arbitrary FLOOR_PLANE props remain rejected. |
| K2 | DONE | Quick Approach uses legs; Fire At Target remains hands-only and non-conflicting. |
| R1 | DONE | No density-only or FLOOR_PLANE-wide exception added. |
| C1 | DONE | Focused test coverage and static checks completed. |
