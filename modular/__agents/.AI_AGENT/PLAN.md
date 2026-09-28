# PLAN

## Active Task
Harden Human AI navigation and make Quick Order: Approach persistent during combat.

## Goal
- Allow walking over canonical underfloor pipes, vents, cables, and disposal pipes.
- Allow only low, non-obscuring flora as traversal; reject bushes, tall grass, jungle cover, and trees.
- Prevent immediate back-and-forth detour oscillation and throttle failed idle-position retries.
- Keep Approach assigned across combat action interruptions while allowing simultaneous firing.
- Clear Approach only on arrival, a replacement Hold order, reset, or confirmed repeated path failure.

## Scope
- Modular navigation safety and quick-order control.
- Minimal Human AI pathfinding, brain reset, and Quick Approach integration.
- Focused Human AI unit assertions.
- Deployment target: `C:\BandaTroopers_edit_LYNX`.

## Acceptance Criteria
- NPCs cross floor tiles containing non-dense underfloor infrastructure.
- NPCs never settle in or path through visually obscuring vegetation.
- Local detours prefer any legal alternative over immediately returning to the previous turf.
- Approach remains active during combat and does not conflict with Fire At Target.
- Interrupted Approach resumes; unreachable orders terminate after bounded failures instead of endless cell oscillation.
