# Directional lighting

The 0.1-second subsystem is a deduplicated event queue, not a permanent list of enabled lamps. Each controller returns `PROCESS_KILL` after reading the latest state. Item light setters, movement, equipment changes and carrier facing/login/logout events wake it. Mouse handlers retain only the latest parameters and notify the current mob; multiple events share one pending entry. Parsed angles are cached per client/parameters/view. Mouse rotations below one degree relative to the rendered direction are suppressed; body/floor facing remains exact.

Native movement immediately synchronizes the existing mask holder and carrier glide. It does not wait for the aiming queue. Native shadow invalidation and its deduplicated mask queue remain independent: moving sources and changed opaque turfs still rebuild shadows. Turning only changes the cone transform and luminosity over cached radial candidates. Radius, intensity, feathering and armor body-only aiming are unchanged.

Off sources ignore wake requests. Stored sources release their emitter and leave the processing queue; source movement/equipment events restore them. Directly carried stored sources retain carrier lifecycle/movement notifications (needed when a carrier exits a container), but ignore mouse/facing notifications without an emitter. Old carrier/client subscriptions are removed on transfer, off and destruction.

## Verification

Use `tools/build/build.bat dm` and the focused directional unit tests through `dm-test`. `directional_beam_event_queue` checks batches of 1/10/30 lights: 100 wake events per light produce one pending entry; stationary lights have no persistent processing entries. The previous polling implementation performed approximately 10 controller calls per enabled light per second. These are queue-work counts, not a measured whole-server CPU improvement.

Client acceptance: walk/run with handheld, gun and helmet lights; check armor follows facing only; move cursor across walls/HUD/chat; transfer/store/drop lamps; turn an NPC and a floor lamp; open/close doors inside the beam; switch camera and return. Live CPU/frame-time profiling should compare identical scenes and player counts. No automatic production benchmark or server restart is performed.
