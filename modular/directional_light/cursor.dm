/// Preserve native event forwarding, including World Edit hover.
/client
	var/directional_light_params
	var/mob/directional_light_mouse_owner
	var/directional_light_event = "outside"
	var/directional_light_cached_params
	var/directional_light_cached_view
	var/directional_light_cached_angle

/client/proc/directional_light_track(atom/object, location, control, params)
	// Obscured map cells hit the map's click catcher, not an interactive HUD button.
	var/is_hud = istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher)
	if(control != "mapwindow.map" || is_hud)
		directional_light_params = null
		directional_light_event = "outside/HUD"
		SEND_SIGNAL(mob, "directional_light_aim")
		return
	directional_light_mouse_owner = mob
	directional_light_params = params
	directional_light_event = "map"
	SEND_SIGNAL(mob, "directional_light_aim")

/client/MouseEntered(object, location, control, params)
	directional_light_track(object, location, control, params)
	return ..()

/client/MouseMove(object, location, control, params)
	directional_light_track(object, location, control, params)
	return ..()

/client/MouseExited(object, location, control, params)
	directional_light_params = null
	directional_light_event = "exit"
	SEND_SIGNAL(mob, "directional_light_aim")
	return ..()

/// Screen-relative coordinates remain correct while the normal camera follows its owner.
/client/proc/directional_light_angle(mob/holder)
	if(holder != mob || holder != directional_light_mouse_owner || eye != mob || !directional_light_params)
		return dir2angle(holder.dir)
	if(directional_light_cached_params == directional_light_params && directional_light_cached_view == view && !isnull(directional_light_cached_angle))
		return directional_light_cached_angle
	var/list/parameters = params2list(directional_light_params)
	var/list/axes = splittext(parameters["screen-loc"] || "", ",")
	if(length(axes) != 2)
		return dir2angle(holder.dir)
	var/list/horizontal = splittext(axes[1], ":")
	var/list/vertical = splittext(axes[2], ":")
	if(length(horizontal) != 2 || length(vertical) != 2)
		return dir2angle(holder.dir)
	var/list/dimensions = getviewsize(view)
	var/dx = (text2num(horizontal[1]) - 1) * world.icon_size + text2num(horizontal[2]) - dimensions[1] * world.icon_size / 2
	var/dy = (text2num(vertical[1]) - 1) * world.icon_size + text2num(vertical[2]) - dimensions[2] * world.icon_size / 2
	if(!dx && !dy)
		return dir2angle(holder.dir)
	directional_light_cached_params = directional_light_params
	directional_light_cached_view = view
	directional_light_cached_angle = delta_to_angle(dx, dy)
	return directional_light_cached_angle
