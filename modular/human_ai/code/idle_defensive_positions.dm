// DemonicLynx for BandaMarines
#define HUMAN_AI_IDLE_CLUSTER_RADIUS 1
#define HUMAN_AI_IDLE_CLUSTER_SIZE 3
// DemonicLynx for BandaMarines
#define HUMAN_AI_IDLE_POSITION_RADIUS 3
#define HUMAN_AI_IDLE_POSITION_CAPACITY 2
#define HUMAN_AI_IDLE_RECHECK_DELAY 5 SECONDS

/datum/human_ai_brain
	/// A non-combat post reserved while this AI waits for the next engagement.
	var/turf/idle_defensive_position
	/// Prevents settled AI from repeatedly re-evaluating the same local formation.
	var/idle_defensive_recheck_at = 0
	// DemonicLynx for BandaMarines
	/// Passable objects whose turf is valid for traversal but never for an idle defensive post.
	var/static/list/idle_defensive_position_forbidden_types = list(
		/obj/structure/machinery,
		/obj/structure/closet,
		/obj/structure/bed,
	)

/// Returns whether routine idle movement is safe without displacing a higher-priority behavior.
/datum/human_ai_brain/proc/can_seek_idle_defensive_position()
	if(!has_valid_tied_human() || tied_human.client || tied_human.stat != CONSCIOUS || tied_human.is_mob_incapacitated())
		return FALSE
	if(in_combat || current_target || target_turf || current_cover || hold_position || current_order)
		return FALSE
	if(tied_human.on_fire || active_grenade_found || quick_approach || sniper_home || machinegunner_home)
		return FALSE
	if(healing_someone || found_injured_ally || length(to_pickup))
		return FALSE
	if(healing_start_check(tied_human))
		return FALSE
	return TRUE

/// Counts nearby friendly Human AI using actual positions, not reservations.
/datum/human_ai_brain/proc/is_in_idle_ai_cluster()
	if(!has_valid_tied_human())
		return FALSE

	var/nearby_allies = 0
	for(var/datum/human_ai_brain/other_brain as anything in GLOB.human_ai_brains)
		if(!other_brain.has_valid_tied_human() || !faction_check(other_brain.tied_human))
			continue
		if(get_dist(tied_human, other_brain.tied_human) > HUMAN_AI_IDLE_CLUSTER_RADIUS)
			continue
		nearby_allies++
		if(nearby_allies >= HUMAN_AI_IDLE_CLUSTER_SIZE)
			return TRUE
	return FALSE

/// Returns how much static protection surrounds an otherwise usable standing tile.
/datum/human_ai_brain/proc/get_idle_position_cover_score(turf/candidate)
	var/cover_score = 0
	for(var/cardinal in GLOB.cardinals)
		var/turf/neighbor = get_step(candidate, cardinal)
		if(!neighbor)
			continue
		if(istype(neighbor, /turf/closed))
			cover_score += 20
			continue
		for(var/obj/structure/cover in neighbor.contents)
			if(!cover.density || cover.projectile_coverage <= PROJECTILE_COVERAGE_NONE)
				continue
			cover_score += 10 + round(cover.projectile_coverage / 10)
			break
	return cover_score

/// Builds one local occupancy snapshot so every candidate does not rescan the global brain list.
/datum/human_ai_brain/proc/get_nearby_idle_position_counts(search_radius = HUMAN_AI_IDLE_POSITION_RADIUS + 2)
	var/list/position_counts = list()
	var/turf/origin = get_turf(tied_human)
	for(var/datum/human_ai_brain/other_brain as anything in GLOB.human_ai_brains)
		if(other_brain == src || !other_brain.has_valid_tied_human() || !faction_check(other_brain.tied_human))
			continue
		var/turf/other_position = other_brain.idle_defensive_position ? other_brain.idle_defensive_position : get_turf(other_brain.tied_human)
		if(!other_position || other_position.z != origin.z || get_dist(origin, other_position) > search_radius)
			continue
		position_counts[other_position] = (position_counts[other_position] || 0) + 1
	return position_counts

/// Scores a local post while enforcing the one-or-two NPC reservation limit.
/datum/human_ai_brain/proc/score_idle_defensive_position(turf/candidate, list/position_counts)
	if(!candidate || candidate == get_turf(tied_human) || idle_defensive_position_is_blocked(candidate))
		return -INFINITY
	if((locate(/obj/item/explosive/mine) in candidate.contents) || (locate(/obj/flamer_fire) in candidate.contents))
		return -INFINITY
	if(!position_counts)
		position_counts = get_nearby_idle_position_counts()

	var/exact_occupants = 0
	var/nearby_occupants = 0
	var/spacing_penalty = 0
	for(var/turf/other_position as anything in position_counts)
		var/occupant_count = position_counts[other_position]
		var/position_distance = get_dist(candidate, other_position)
		if(position_distance <= HUMAN_AI_IDLE_CLUSTER_RADIUS)
			nearby_occupants += occupant_count
		if(!position_distance)
			exact_occupants += occupant_count
		else if(position_distance == 1)
			spacing_penalty += 12 * occupant_count
		else if(position_distance == 2)
			spacing_penalty += 4 * occupant_count

	if(exact_occupants || nearby_occupants >= HUMAN_AI_IDLE_POSITION_CAPACITY)
		return -INFINITY

	var/distance = get_dist(tied_human, candidate)
	var/score = get_idle_position_cover_score(candidate)
	score += min(distance, 4) * 2
	score -= max(0, distance - 4) * 3
	score -= spacing_penalty
	return score

/// Chooses one bounded local defensive post, preferring cover and space over crowding.
/datum/human_ai_brain/proc/find_idle_defensive_position()
	if(!has_valid_tied_human())
		return

	var/turf/origin = get_turf(tied_human)
	var/list/position_counts = get_nearby_idle_position_counts()
	var/turf/best_position
	var/best_score = -INFINITY
	for(var/turf/candidate as anything in range(HUMAN_AI_IDLE_POSITION_RADIUS, origin))
		if(candidate.z != origin.z)
			continue
		var/candidate_score = score_idle_defensive_position(candidate, position_counts)
		if(candidate_score <= best_score)
			continue
		best_score = candidate_score
		best_position = candidate
	return best_position

/// Checks destination obstruction while allowing the owner to remain on its already reached post.
/datum/human_ai_brain/proc/idle_defensive_position_is_blocked(turf/candidate, ignore_owner = FALSE)
	if(QDELETED(candidate) || candidate.density)
		return TRUE
	for(var/atom/movable/obstacle as anything in candidate.contents)
		if(ignore_owner && obstacle == tied_human)
			continue
		// DemonicLynx for BandaMarines
		if(obstacle.density || is_type_in_list(obstacle, idle_defensive_position_forbidden_types))
			return TRUE
	return FALSE

// DemonicLynx for BandaMarines
/// Returns whether an idle movement step would enter any shutter, including an open non-dense one.
/datum/human_ai_brain/proc/idle_defensive_step_has_shutter(turf/candidate)
	return candidate && (locate(/obj/structure/machinery/door/poddoor/shutters) in candidate)

// DemonicLynx for BandaMarines
/// Takes one bounded idle-only step without letting generic navigation route through a shutter.
/datum/human_ai_brain/proc/move_to_idle_defensive_position(turf/destination)
	if(!has_valid_tied_human() || !destination)
		return FALSE

	var/current_distance = get_dist(tied_human, destination)
	if(!current_distance)
		return TRUE
	if(current_distance == 1)
		if(idle_defensive_step_has_shutter(destination))
			return FALSE
		return try_adjacent_move_to_turf(destination)

	var/preferred_direction = get_dir(tied_human, destination)
	var/turf/best_step
	var/list/best_interactions
	var/best_distance = INFINITY
	for(var/direction in GLOB.cardinals)
		if(!(direction & preferred_direction))
			continue

		var/turf/next_turf = get_step(tied_human, direction)
		if(!next_turf || idle_defensive_step_has_shutter(next_turf))
			continue

		var/list/interactions = get_adjacent_move_interactions(next_turf)
		if(isnull(interactions))
			continue

		var/next_distance = get_dist(next_turf, destination)
		if(next_distance > current_distance || next_distance >= best_distance)
			continue

		best_distance = next_distance
		best_step = next_turf
		best_interactions = interactions

	if(!best_step)
		return FALSE
	return complete_adjacent_move_to_turf(best_step, TRUE, best_interactions)

/// Keeps non-leaders close enough to rejoin their squad when its anchor moves away.
/datum/human_ai_brain/proc/idle_position_is_with_squad()
	if(!squad_id || is_squad_leader)
		return TRUE
	var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
	var/mob/living/carbon/human/squad_leader = squad?.squad_leader?.tied_human
	if(!squad_leader)
		return TRUE
	return get_dist(tied_human, squad_leader) <= max(view_distance, HUMAN_AI_IDLE_POSITION_RADIUS + 1)

/datum/ai_action/idle_defensive_position
	name = "Occupy Idle Defensive Position"
	action_flags = ACTION_USING_LEGS
	var/turf/destination

/datum/ai_action/idle_defensive_position/get_weight(datum/human_ai_brain/brain)
	if(!brain.can_seek_idle_defensive_position() || !brain.is_in_idle_ai_cluster())
		return 0
	return 6

/datum/ai_action/idle_defensive_position/Added()
	destination = brain.find_idle_defensive_position()
	brain.idle_defensive_position = destination

/datum/ai_action/idle_defensive_position/Destroy(force, ...)
	if(brain && brain.idle_defensive_position == destination)
		brain.idle_defensive_position = null
	destination = null
	return ..()

/datum/ai_action/idle_defensive_position/trigger_action()
	. = ..()
	if(!brain.can_seek_idle_defensive_position() || !brain.idle_position_is_with_squad())
		return ONGOING_ACTION_COMPLETED

	if(!destination || brain.idle_defensive_position_is_blocked(destination, TRUE))
		destination = brain.find_idle_defensive_position()
		brain.idle_defensive_position = destination
		if(!destination)
			return ONGOING_ACTION_COMPLETED

	if(get_dist(brain.tied_human, destination) > 0)
		// DemonicLynx for BandaMarines
		if(!brain.move_to_idle_defensive_position(destination))
			return ONGOING_ACTION_COMPLETED
		return ONGOING_ACTION_UNFINISHED

	if(world.time >= brain.idle_defensive_recheck_at)
		brain.idle_defensive_recheck_at = world.time + HUMAN_AI_IDLE_RECHECK_DELAY
		if(brain.is_in_idle_ai_cluster())
			var/turf/new_destination = brain.find_idle_defensive_position()
			if(new_destination)
				destination = new_destination
				brain.idle_defensive_position = new_destination
	return ONGOING_ACTION_UNFINISHED

#undef HUMAN_AI_IDLE_CLUSTER_RADIUS
#undef HUMAN_AI_IDLE_CLUSTER_SIZE
#undef HUMAN_AI_IDLE_POSITION_RADIUS
#undef HUMAN_AI_IDLE_POSITION_CAPACITY
#undef HUMAN_AI_IDLE_RECHECK_DELAY
