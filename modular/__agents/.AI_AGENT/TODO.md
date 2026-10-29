# Contract and fidelity
| ID | Type | Requirement | Status |
| --- | --- | --- | --- |
| M1 | MUST | Separate static/base visibility and idempotent actual hybrid contributions; turf lifecycle integration | SOURCE DONE |
| M2 | MUST | Correct off lifecycle, gun flag ordering, camera offsets/view invalidation | SOURCE DONE |
| M3 | MUST | New directional masks hidden until initial shadow calculation completes | SOURCE DONE |
| M4 | MUST | Directional full-tile/border geometry and opacity/move/turn invalidation | SOURCE DONE |
| K1 | KEEP | Old compositor, movement timing, beam appearance, aim conventions and event queues | PRESERVED |
| R1 | REJECT | No RenderLab rollout, global cache/tick change, fullbright, tests/compile/restart | RESPECTED |
| C1 | CHECK | Diff, include/callsite/old-path audit and static review | DONE; runtime NOT RUN |

Forbidden substitutions: hide all light permanently; treat all borders as full walls; use dependency membership as actual illumination; wrap native luminosity counters without replacing conflicting writers; faster polling in place of event invalidation; claim existing glide snap is fixed.
Old paths: luminosity +=/-= contributor counter -> replaced; native static assignment based on hybrid_lights_affecting -> replaced; partial blockers in directional full-tile groups -> excluded and replaced with edge lines; initial unshadowed directional mask -> hidden until ready. Native full-wall grouping/compositor KEEP.

Verification boundary: compilation, tests, server restart and client acceptance NOT RUN by user request. Two pre-existing test expectations were adapted to the new behavior without execution. GPU compositing, queued door-update latency, tile-edge artifacts, walking glide and 100-source CPU cost remain unverified; smooth movement and shared performance caches are deferred stages, not completed work.
