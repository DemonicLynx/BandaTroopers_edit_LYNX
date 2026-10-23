# Decisions

Approved stall fix: approach budget10s from start, then configured search seconds on actual anchor arrival, total10s+search cap. Memory freshness still uses chase_time before start. Movement FALSE is transient until existing4s no-progress timeout. Failed anchor ends search rather than marking it reached. Clear cover in maintenance before action arbitration only for eligible search with no visible target or grenade emergency.

Directional follow-up: sample forward and +/-45-degree rays, advancing two tiles per waypoint within the original radius. Skip unsafe destinations, let native navigation decide transit and door access. Prediction-off uses approach heading, stationary fallback uses initial facing. Flanker retains lateral initial approach. No room discovery or new settings needed.

All six approved. Master controls lost-contact pursuit only, not visible combat or retreat. Defaults: enabled; easy one extra point/no team/prediction, medium three points/prediction/sharing, hard five/team roles. Radius max6, group iteration cap16, candidates max169. Roles stable per search; report shares position/timestamp/direction, never enemy reference; no relay. Same order datum retained; fallback return anchor only without a current order. No changes to scenery diagnostic.
