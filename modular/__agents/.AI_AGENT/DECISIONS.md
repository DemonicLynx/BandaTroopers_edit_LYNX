# Decisions
Implement approved correctness stages1–3 only; stage4 performance sharing and stage5 smooth rendering are deferred.
Use module-owned visibility bookkeeping for all hybrid masks because fixing only directional masks would leave conflicting writers. Upstream changes are narrow integration hooks with SS220 markers.
Keep native full-wall geometry/compositor. Directional partial blockers use explicit border segments; native grouping itself is not rewritten.
When native LOS contains a partial border, collect bounded local geometry separately: native dview can hide a wall behind that border. Extra candidates have dedicated geometry subscriptions and never grant gameplay illumination. Without partial borders retain native LOS candidates. This is an occlusion correctness dependency, not stage4 global scene caching. Native gameplay visibility remains conservative around opaque border cells.
Invalidate on blocker-source composition and successful turf opacity changes even when directional bits remain ALL_CARDINALS: four borders and one solid blocker have different geometry despite identical bits. Rotation signals use their pending new direction.
Initial directional masks wait for native shadow completion before becoming visible. Existing published masks keep normal obstacle queue scheduling; no whole-server frequency increase.
Initial calculation occurs synchronously after final range and aim once lighting is initialized, so short muzzle flashes still publish. Initialization retains the native queued path. Existing movement publication/glide is not redesigned.
No tests created/run or compilation per user's explicit constraint. Source audit cannot establish client visual correctness or speedup.
Two existing test expectations were updated, not executed: boolean contributor accounting and explicit queuing for a test that previously assumed activation left initial work pending.
