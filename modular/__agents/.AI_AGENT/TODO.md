# TODO

## Contract
| ID | Type | Requirement | Status |
| --- | --- | --- | --- |
| M1 | MUST | Admit only non-dense canonical underfloor infrastructure. | DONE |
| M2 | MUST | Reject flora that renders at/above mob level or uses tall-grass overlays. | DONE |
| M3 | MUST | Keep Approach persistent through combat interruptions and compatible with firing. | DONE |
| M4 | MUST | Bound unreachable Approach retries and discourage immediate A-B-A detours. | DONE |
| K1 | KEEP | Tables, crates, lattices, machinery, props, walls, and dense objects remain forbidden. | DONE |
| K2 | KEEP | Combat targeting and firing remain active while Approach owns only movement. | DONE |
| R1 | REJECT | Do not broadly allow every non-dense structure or every FLOOR_PLANE object. | DONE |
| C1 | CHECK | Add focused static/unit coverage without local DreamMaker. | DONE |

## Forbidden Substitutions
- Do not permit structural lattice, weeds, traps, furniture, containers, or generic props based only on density/layer.
- Do not make Approach block hand-only firing actions.
- Do not clear a valid Approach merely because its action datum was temporarily preempted.
- Do not retry an unreachable order without a bounded failure limit.
