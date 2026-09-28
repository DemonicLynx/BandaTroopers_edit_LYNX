# DECISIONS

## D-001: Exact underfloor allowlist
- Allow `/obj/structure/pipes`, `/obj/structure/cable`, and `/obj/structure/disposalpipe` only when non-dense.
- Reject a generic FLOOR_PLANE rule because lattices, alien structures, traps, and other gameplay objects also use that plane.

## D-002: Visibility-aware flora traversal
- Permit only non-dense flora below `MOB_LAYER`, excluding tall grass with above-mob overlays.
- This preserves low ground-cover traversal without letting NPCs disappear inside bushes, jungle plants, or trees.

## D-003: Persist the order, not the action instance
- `quick_approach` remains brain state when its action is preempted; arrival or bounded failure clears it explicitly.
- Fire At Target remains hand-only and therefore runs alongside the movement action.

## D-004: Bounded anti-oscillation
- Record the previous navigation turf and penalize immediate return steps when another legal step exists.
- Abort Approach after repeated actual navigation failures, not ordinary movement-delay ticks.
