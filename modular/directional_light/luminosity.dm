/// Default hooks preserve ordinary hybrid lighting behavior.
/atom/movable/lighting_mask/proc/add_turf_luminosity(turf/target)
	target.luminosity += 1

/atom/movable/lighting_mask/proc/remove_turf_luminosity(turf/target)
	var/area/area = target.loc
	if(target.luminosity && !area.base_lighting_alpha)
		target.luminosity -= 1

/atom/movable/lighting_mask/proc/turf_light_factor(turf/target)
	return 1

/atom/movable/lighting_mask/flashlight_60
	/// Radial dependencies remain subscribed; only these turfs receive our luminosity.
	var/list/luminous_turfs

/// Shared normalized aperture for the texture and gameplay lighting.
/atom/movable/lighting_mask/flashlight_60/proc/beam_weight(forward, side)
	var/static/inner_slope = tan(20)
	var/static/outer_slope = tan(40)
	var/beam = 0
	if(forward > 0)
		beam = clamp((outer_slope - abs(side) / forward) / (outer_slope - inner_slope), 0, 1)
		beam = beam * beam * (3 - 2 * beam)
	var/halo = clamp(1 - sqrt(side * side + forward * forward) / 0.1, 0, 1)
	halo = halo * halo * (3 - 2 * halo)
	return max(beam, halo)

/atom/movable/lighting_mask/flashlight_60/turf_light_factor(turf/target)
	var/turf/origin = get_turf(attached_atom)
	if(!origin || !target || origin.z != target.z || radius <= 0)
		return 0
	var/dx = (target.x - origin.x) / radius
	var/dy = (target.y - origin.y) / radius
	if(dx * dx + dy * dy >= 1)
		return 0
	var/heading = current_angle + 180
	var/forward = dx * sin(heading) + dy * cos(heading)
	var/side = dx * cos(heading) - dy * sin(heading)
	return 2 * beam_weight(forward, side)

/atom/movable/lighting_mask/flashlight_60/add_turf_luminosity(turf/target)
	if(turf_light_factor(target) <= 0 || (target in luminous_turfs))
		return
	LAZYADD(luminous_turfs, target)
	target.luminosity += 1

/atom/movable/lighting_mask/flashlight_60/remove_turf_luminosity(turf/target)
	if(!(target in luminous_turfs))
		return
	LAZYREMOVE(luminous_turfs, target)
	target.luminosity = max(0, target.luminosity - 1)

/atom/movable/lighting_mask/flashlight_60/rotate(angle)
	set_beam_transform(angle)
	// At range10: at most441 cached candidates, no dview/shadow rebuilding.
	for(var/turf/target as anything in affecting_turfs)
		if(turf_light_factor(target) > 0)
			add_turf_luminosity(target)
		else
			remove_turf_luminosity(target)

/atom/movable/lighting_mask/flashlight_60/Destroy(force)
	for(var/turf/target as anything in luminous_turfs?.Copy())
		remove_turf_luminosity(target)
	return ..()
