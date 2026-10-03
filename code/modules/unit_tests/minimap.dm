// DemonicLynx for BandaMarines - START: adaptive minimap layout regression coverage
/datum/unit_test/minimap_adaptive_layout/Run()
	var/list/small_layout = calculate_minimap_layout(10, 20, 109, 69)
	TEST_ASSERT_EQUAL(small_layout["scale"], MINIMAP_SCALE, "A small map should retain the normal minimap scale.")
	TEST_ASSERT_EQUAL(small_layout["scaled_width"], 200, "The small map width was scaled incorrectly.")
	TEST_ASSERT_EQUAL(small_layout["scaled_height"], 100, "The small map height was scaled incorrectly.")
	TEST_ASSERT_EQUAL(small_layout["x_offset"], 156, "The small map was not centered horizontally.")
	TEST_ASSERT_EQUAL(small_layout["y_offset"], 206, "The small map was not centered vertically.")

	var/list/wide_layout = calculate_minimap_layout(1, 1, 400, 200)
	TEST_ASSERT_EQUAL(wide_layout["scaled_width"], MINIMAP_PIXEL_SIZE, "A wide map should fit the full canvas width.")
	TEST_ASSERT_EQUAL(wide_layout["scaled_height"], 256, "A wide map did not preserve its aspect ratio.")
	TEST_ASSERT_EQUAL(wide_layout["x_offset"], 0, "A full-width map should not have a horizontal offset.")
	TEST_ASSERT_EQUAL(wide_layout["y_offset"], 128, "A wide map was not centered vertically.")

	var/list/tall_layout = calculate_minimap_layout(1, 1, 200, 400)
	TEST_ASSERT_EQUAL(tall_layout["scaled_width"], 256, "A tall map did not preserve its aspect ratio.")
	TEST_ASSERT_EQUAL(tall_layout["scaled_height"], MINIMAP_PIXEL_SIZE, "A tall map should fit the full canvas height.")
	TEST_ASSERT_EQUAL(tall_layout["x_offset"], 128, "A tall map was not centered horizontally.")
	TEST_ASSERT_EQUAL(tall_layout["y_offset"], 0, "A full-height map should not have a vertical offset.")

	var/wide_left_marker = minimap_world_to_pixel(1, 1, wide_layout["scale"], wide_layout["x_offset"])
	var/wide_right_marker = minimap_world_to_pixel(400, 1, wide_layout["scale"], wide_layout["x_offset"])
	TEST_ASSERT(wide_left_marker >= -2, "The first marker escaped the left edge of the fitted map.")
	TEST_ASSERT(wide_right_marker < MINIMAP_PIXEL_SIZE, "The last marker escaped the right edge of the fitted map.")

	var/small_first_marker = minimap_world_to_pixel(10, 10, small_layout["scale"], small_layout["x_offset"])
	TEST_ASSERT_EQUAL(small_first_marker, small_layout["x_offset"] - 2, "Marker conversion ignored a non-default world origin.")

	// DemonicLynx for BandaMarines - START: tactical map scrollbar pan limits
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(0, 0, 512, 430), -64, "The horizontal scrollbar did not expose the left edge margin.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(50, 0, 512, 430), 41, "The horizontal scrollbar did not center the map.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(100, 0, 512, 430), 146, "The horizontal scrollbar did not expose the right edge margin.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(0, 32, 480, 310, 128, 64), -96, "The vertical scrollbar did not expose the extended downward margin.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(50, 32, 480, 310, 128, 64), 101, "The asymmetric vertical range moved the map away from its center.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(100, 32, 480, 310, 128, 64), 234, "The vertical scrollbar did not expose the opposite content edge margin.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(0, 156, 356, 430), 92, "A small map did not expose its first edge margin.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(50, 156, 356, 430), 41, "A small map did not center at the middle scrollbar position.")
	TEST_ASSERT_EQUAL(calculate_minimap_pan_shift(100, 156, 356, 430), -10, "A small map did not expose its opposite edge margin.")
	// DemonicLynx for BandaMarines - END
// DemonicLynx for BandaMarines - END

// SS220 EDIT - START: DemonicLynx for BandaMarines - private views never share pan state
/datum/unit_test/minimap_private_views/Run()
	var/mob/first_user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/second_user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/new_body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/tacmap/tacmap = allocate(/datum/tacmap, null, MINIMAP_FLAG_USCM)
	tacmap.map_holder = allocate(/datum/tacmap_holder, null, run_loc_floor_bottom_left.z, MINIMAP_FLAG_USCM)
	var/datum/tacmap_holder/first = tacmap.get_viewer_map(first_user)
	var/datum/tacmap_holder/second = tacmap.get_viewer_map(second_user)
	TEST_ASSERT(first != second && first.map != second.map && first.map_ref != second.map_ref, "Two viewers share a native tactical map.")
	var/second_screen_loc = second.map.screen_loc
	var/shared_screen_loc = tacmap.map_holder.map.screen_loc
	first.set_pan(0, 100, 250, 200)
	TEST_ASSERT_EQUAL(second.map.screen_loc, second_screen_loc, "One viewer moved the other viewer's map.")
	TEST_ASSERT_EQUAL(tacmap.map_holder.map.screen_loc, shared_screen_loc, "Private pan moved the shared snapshot map.")
	TEST_ASSERT(first in SSminimaps.live_tacmap_holders, "Private map is missing from live marker updates.")
	tacmap.transfer_viewer_map(first_user, new_body)
	TEST_ASSERT_EQUAL(tacmap.get_viewer_map(new_body), first, "Body transfer lost the private view.")
	tacmap.ui_close(new_body)
	TEST_ASSERT(QDELETED(first), "Closing the view leaked its holder.")
	TEST_ASSERT(!(first in SSminimaps.live_tacmap_holders), "Closed view remains in the live refresh registry.")
	TEST_ASSERT(!QDELETED(second), "Closing one viewer deleted another viewer's map.")
	qdel(tacmap)
	TEST_ASSERT(QDELETED(second), "Destroying the source leaked the other viewer's map.")
// SS220 EDIT - END

// SS220 EDIT - START: DemonicLynx for BandaMarines - live refresh preserves visibility and pan
/datum/unit_test/minimap_live_markers/Run()
	var/zlevel = run_loc_floor_bottom_left.z
	var/datum/tacmap_holder/holder = allocate(/datum/tacmap_holder, null, zlevel, MINIMAP_FLAG_USCM)
	var/datum/hud_displays/display = SSminimaps.minimaps_by_z["[zlevel]"]
	TEST_ASSERT_NOTNULL(display, "Test z-level has no minimap display.")
	var/image/friendly = image('icons/ui_icons/map_blips.dmi', pixel_x = 10, pixel_y = 20)
	var/image/hidden = image('icons/ui_icons/map_blips.dmi', pixel_x = 100, pixel_y = 200)
	display.images_raw["[MINIMAP_FLAG_USCM]"] += friendly
	display.images_raw["[MINIMAP_FLAG_XENO]"] += hidden
	var/original_screen_loc = holder.map.screen_loc
	holder.refresh_live_markers()
	var/initial_count = length(holder.map.overlays)
	friendly.pixel_x = 30
	holder.refresh_live_markers()
	var/found_moved = FALSE
	var/found_hidden = FALSE
	for(var/image/marker as anything in holder.map.overlays)
		if(marker.pixel_x == 30 && marker.pixel_y == 20)
			found_moved = TRUE
		if(marker.pixel_x == 100 && marker.pixel_y == 200)
			found_hidden = TRUE
	// Restore shared data before assertions can abort this test.
	display.images_raw["[MINIMAP_FLAG_USCM]"] -= friendly
	display.images_raw["[MINIMAP_FLAG_XENO]"] -= hidden
	TEST_ASSERT(found_moved, "Live map retained the old marker appearance after movement.")
	TEST_ASSERT(!found_hidden, "Live refresh leaked an unauthorized faction marker.")
	TEST_ASSERT_EQUAL(length(holder.map.overlays), initial_count, "Live refresh accumulated stale marker copies.")
	TEST_ASSERT_EQUAL(holder.map.screen_loc, original_screen_loc, "Marker refresh changed the map pan.")
// SS220 EDIT - END

// SS220 EDIT - START: DemonicLynx for BandaMarines - playable faction tacmap and live marker regression coverage
/datum/unit_test/minimap_playable_faction_live_markers/Run()
	var/zlevel = run_loc_floor_bottom_left.z
	var/player_flags = get_playable_humanoid_tacmap_flags()
	var/datum/tacmap_holder/player_holder = allocate(/datum/tacmap_holder, null, zlevel, player_flags)
	var/datum/hud_displays/display = SSminimaps.minimaps_by_z["[zlevel]"]
	TEST_ASSERT_NOTNULL(display, "Test z-level has no minimap display.")

	var/image/upp_marker = image('icons/ui_icons/map_blips.dmi', pixel_x = 12, pixel_y = 24)
	var/image/uscm_marker = image('icons/ui_icons/map_blips.dmi', pixel_x = 120, pixel_y = 240)
	var/image/xeno_marker = image('icons/ui_icons/map_blips.dmi', pixel_x = 220, pixel_y = 340)
	display.images_raw["[MINIMAP_FLAG_UPP]"] += upp_marker
	display.images_raw["[MINIMAP_FLAG_USCM]"] += uscm_marker
	display.images_raw["[MINIMAP_FLAG_XENO]"] += xeno_marker
	player_holder.refresh_live_markers()

	var/found_upp = FALSE
	var/found_uscm = FALSE
	var/found_xeno = FALSE
	for(var/image/marker as anything in player_holder.map.overlays)
		if(marker.pixel_x == 12 && marker.pixel_y == 24)
			found_upp = TRUE
		if(marker.pixel_x == 120 && marker.pixel_y == 240)
			found_uscm = TRUE
		if(marker.pixel_x == 220 && marker.pixel_y == 340)
			found_xeno = TRUE

	upp_marker.pixel_x = 36
	player_holder.refresh_live_markers()
	var/found_moved_upp = FALSE
	for(var/image/marker as anything in player_holder.map.overlays)
		if(marker.pixel_x == 36 && marker.pixel_y == 24)
			found_moved_upp = TRUE

	// Restore shared display data before assertions can abort this test.
	display.images_raw["[MINIMAP_FLAG_UPP]"] -= upp_marker
	display.images_raw["[MINIMAP_FLAG_USCM]"] -= uscm_marker
	display.images_raw["[MINIMAP_FLAG_XENO]"] -= xeno_marker
	var/expected_player_flags = MINIMAP_FLAG_USCM|MINIMAP_FLAG_PMC|MINIMAP_FLAG_UPP|MINIMAP_FLAG_TWE|MINIMAP_FLAG_CLF|MINIMAP_FLAG_UNSC|MINIMAP_FLAG_COVENANT
	TEST_ASSERT_EQUAL(player_flags, expected_player_flags, "Playable humanoid tacmap flags are incomplete.")
	TEST_ASSERT_EQUAL(get_minimap_flag_for_faction(FACTION_UPP), MINIMAP_FLAG_UPP, "UPP resolved to the wrong minimap flag.")
	TEST_ASSERT(found_upp, "The tactical map did not render its UPP player marker.")
	TEST_ASSERT(found_uscm, "The tactical map did not render its USCM player marker alongside UPP.")
	TEST_ASSERT(!found_xeno, "The playable humanoid tactical map leaked a xenomorph marker.")
	TEST_ASSERT(found_moved_upp, "The tactical map retained the old UPP player position after refresh.")

/datum/unit_test/minimap_active_ship_faction/Run()
	var/obj/structure/machinery/prop/almayer/CICmap/generic_map = allocate(/obj/structure/machinery/prop/almayer/CICmap, run_loc_floor_bottom_left)
	generic_map.faction = FACTION_MARINE
	generic_map.minimap_type = MINIMAP_FLAG_USCM
	generic_map.resolve_active_ship_tacmap_faction(FACTION_UPP)
	TEST_ASSERT_EQUAL(generic_map.faction, FACTION_UPP, "A generic CIC map did not adopt the active UPP faction.")
	TEST_ASSERT_EQUAL(generic_map.minimap_type, get_playable_humanoid_tacmap_flags(), "A generic CIC map did not adopt the playable faction marker mask.")

	var/obj/structure/machinery/prop/almayer/CICmap/upp/explicit_upp_map = allocate(/obj/structure/machinery/prop/almayer/CICmap/upp, get_step(run_loc_floor_bottom_left, EAST))
	explicit_upp_map.resolve_active_ship_tacmap_faction(FACTION_MARINE)
	TEST_ASSERT_EQUAL(explicit_upp_map.faction, FACTION_UPP, "An explicit UPP map was overwritten by the active ship faction.")
	TEST_ASSERT_EQUAL(explicit_upp_map.minimap_type, get_playable_humanoid_tacmap_flags(), "An explicit UPP map did not adopt the playable faction marker mask.")
// SS220 EDIT - END
