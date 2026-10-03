// DemonicLynx for BandaMarines
/datum/controller/subsystem/minimaps
	/// One deferred redraw per moving z-level, not one full redraw per moving marker.
	var/list/pending_live_marker_refresh = list()
	/// Includes private viewer maps as well as cached shared maps.
	var/list/live_tacmap_holders = list()

/datum/tacmap_holder
	var/live_marker_z
	var/live_marker_flags

/// Overlay appearances are snapshots: moving their source image requires reapplying them.
/datum/controller/subsystem/minimaps/proc/queue_live_marker_refresh(zlevel)
	if(!zlevel || pending_live_marker_refresh["[zlevel]"])
		return
	var/has_live_map = FALSE
	for(var/datum/tacmap_holder/holder as anything in live_tacmap_holders)
		if(!QDELETED(holder) && holder.live_marker_z == zlevel && !QDELETED(holder.map))
			has_live_map = TRUE
			break
	if(!has_live_map)
		return
	pending_live_marker_refresh["[zlevel]"] = TRUE
	addtimer(CALLBACK(src, PROC_REF(refresh_live_markers), zlevel), world.tick_lag)

/datum/controller/subsystem/minimaps/proc/refresh_live_markers(zlevel)
	pending_live_marker_refresh -= "[zlevel]"
	for(var/datum/tacmap_holder/holder as anything in live_tacmap_holders)
		if(!QDELETED(holder) && holder.live_marker_z == zlevel)
			holder.refresh_live_markers()

/datum/tacmap_holder/proc/refresh_live_markers()
	if(QDELETED(map))
		return
	var/datum/hud_displays/display = SSminimaps.minimaps_by_z["[live_marker_z]"]
	if(!display)
		return
	var/list/markers = list()
	for(var/flag in bitfield2list(live_marker_flags))
		markers |= display.images_raw["[flag]"]
	map.overlays = markers
