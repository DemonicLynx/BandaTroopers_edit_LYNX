# Old directional lighting: correctness stages 1–3
Approved 2026-10-29 after read-only audit. Target C:/BandaTroopers_LYNX, not the desktop cwd. Experimental renderer remains archived in C:/BandaTroopers_RenderLab.

## Scope
MUST implement separate static/base/actual hybrid visibility accounting; lifecycle and camera aiming fixes; initial shadow-ready publication and correct full-tile versus border blockers with opacity/move/turn invalidation. Native full-wall grouping, compositor and existing movement publication remain.
KEEP range10/power8/aperture, armor facing-only, floor facing, mouse/HUD fallback, deduplicated event queues, native queue comparison fix, unrelated user changes.
REJECT new renderer rollout, movement/glide changes, broader performance/cache redesign (stage4), tests or compilation/server restart, global faster ticks, fullbright, destructive git operations.

## Entrypoints and ownership
colonialmarines.dme -> modular/modular.dme -> directional_light/_directional_light.dme.
Accounting: modular accounting/luminosity with native static object, area and turf lifecycle hooks.
Lifecycle/aim: controller/cursor, gun activation and camera notifications.
Occlusion: native shadow calculator minimal extension hooks, modular border lines/readiness, opacity recalculation/turn notification.
Old-path audit: remove runtime luminosity increment/decrement accounting and static overwrite decisions based on dependency list; replace partial-as-full geometry for directional masks; remove new directional unshadowed publication. Native full-wall renderer intentionally remains callable.

## Acceptance and verification
Source/diff/include/callsite review only now. No compile, tests, server restart or runtime performance claims. Later manual acceptance: overlapping torches + ceiling/base lights; off/drop/storage/transfer; scoped aim/HUD; enable next to wall, open/close/turn border doors. Smooth walking remains explicitly outside this pass.

## Handoff status
Stages 1–3 implemented in source and statically reviewed. Conditional geometry-only subscriptions are necessary to retain walls hidden behind native opaque border cells; they do not expand gameplay illumination. See EVIDENCE.md for review findings and remaining verification limits. No runtime acceptance is implied. Stages 4–5 remain deferred.
