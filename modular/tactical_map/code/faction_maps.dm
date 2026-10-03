// DemonicLynx for BandaMarines

/// Marker groups shared by CIC tactical maps for supported playable humanoid factions.
/proc/get_playable_humanoid_tacmap_flags()
	return MINIMAP_FLAG_USCM|MINIMAP_FLAG_PMC|MINIMAP_FLAG_UPP|MINIMAP_FLAG_TWE|MINIMAP_FLAG_CLF|MINIMAP_FLAG_UNSC|MINIMAP_FLAG_COVENANT

/// Makes generic marine CIC tables follow the faction selected by the active ship profile.
/// Every CIC table shows supported player factions together; explicit subtypes retain their ownership faction.
/obj/structure/machinery/prop/almayer/CICmap/proc/resolve_active_ship_tacmap_faction(active_ship_faction = GLOB.RoleAuthority?.get_main_ship_faction())
	if(faction == FACTION_MARINE && active_ship_faction)
		faction = active_ship_faction

	minimap_type = get_playable_humanoid_tacmap_flags()
