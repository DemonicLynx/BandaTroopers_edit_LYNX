/datum/tacmap
	var/list/viewer_maps = list()

/// A UI viewer owns a separate native map; shared map_holder remains the snapshot source.
/datum/tacmap/proc/get_viewer_map(mob/user)
	if(QDELETED(user) || QDELETED(map_holder))
		return null
	// Match drawing/tgui_interact: a shared source must not grant another viewer Live Map access.
	if(istype(src, /datum/tacmap/drawing) && !isxeno(user) && !skillcheck(user, SKILL_LEADERSHIP, SKILL_LEAD_NOVICE))
		release_viewer_map(user)
		return null
	var/datum/tacmap_holder/holder = viewer_maps[user]
	if(holder && (QDELETED(holder.map) || holder.live_marker_z != map_holder.live_marker_z || holder.live_marker_flags != map_holder.live_marker_flags))
		release_viewer_map(user)
		holder = null
	if(QDELETED(holder))
		holder = new /datum/tacmap_holder(null, map_holder.live_marker_z, map_holder.live_marker_flags)
		viewer_maps[user] = holder
		user.client?.register_map_obj(holder.map)
	return holder

/datum/tacmap/proc/register_viewer_map(mob/user)
	var/datum/tacmap_holder/holder = get_viewer_map(user)
	if(holder)
		user.client?.register_map_obj(holder.map)

/datum/tacmap/proc/viewer_map_data(mob/user)
	var/datum/tacmap_holder/holder = get_viewer_map(user)
	return list("mapRef" = holder?.map_ref, "mapPanX" = holder?.pan_x, "mapPanY" = holder?.pan_y)

/datum/tacmap/proc/release_viewer_map(mob/user)
	var/datum/tacmap_holder/holder = viewer_maps[user]
	viewer_maps -= user
	if(!holder)
		return
	user.client?.clear_map(holder.map_ref)
	qdel(holder)

/datum/tacmap/proc/release_all_viewer_maps()
	for(var/mob/user as anything in viewer_maps.Copy())
		release_viewer_map(user)

/datum/tacmap/ui_close(mob/user)
	release_viewer_map(user)
	if(user.mind)
		UnregisterSignal(user.mind, COMSIG_MIND_TRANSFERRED)
	return ..()

/datum/tacmap/ui_data(mob/user)
	return viewer_map_data(user)

/datum/tacmap/proc/transfer_viewer_map(mob/previous_body, mob/new_body)
	if(!new_body)
		release_viewer_map(previous_body)
		return
	var/datum/tacmap_holder/holder = viewer_maps[previous_body]
	if(holder)
		viewer_maps -= previous_body
		release_viewer_map(new_body)
		viewer_maps[new_body] = holder
	register_viewer_map(new_body)
