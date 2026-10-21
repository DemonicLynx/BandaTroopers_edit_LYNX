/datum/unit_test/human_ai_settings_schema/Run()
	for(var/level in list("easy", "medium", "hard"))
		TEST_ASSERT(human_ai_settings_validate(human_ai_settings_preset(level)), "Invalid built-in difficulty profile")
	var/list/profile = human_ai_settings_preset()
	var/list/copy = human_ai_settings_validate(profile)
	copy["medicine"] = FALSE
	TEST_ASSERT(profile["medicine"], "Validation returned an alias")
	TEST_ASSERT(!human_ai_settings_valid_value("unknown", TRUE), "Unknown control accepted")
	TEST_ASSERT(!human_ai_settings_valid_value("fuse_reserve", 0), "Unsafe fuse reserve accepted")
	TEST_ASSERT(!human_ai_settings_valid_value("medicine", 0.5), "Fractional boolean accepted")
	TEST_ASSERT(!human_ai_settings_validate(list("medicine" = TRUE)), "Incomplete profile accepted")
	TEST_ASSERT(!human_ai_settings_validate(list("medicine" = FALSE)), "Partial global profile accepted")
	var/datum/human_ai_personal_slots/slots = allocate(/datum/human_ai_personal_slots, null)
	TEST_ASSERT_EQUAL(length(slots.slots), 3, "Personal slot limit changed")
	TEST_ASSERT(slots.valid_name("Мой профиль 3"), "Cyrillic personal name rejected")
	TEST_ASSERT(!slots.valid_name("../other"), "Invalid personal name accepted")
	TEST_ASSERT(!slots.valid_name("   "), "Blank name accepted")

/datum/unit_test/human_ai_settings_lifecycle/Run()
	var/datum/human_ai_settings_service/original = GLOB.human_ai_settings
	var/datum/human_ai_settings_service/service = allocate(/datum/human_ai_settings_service)
	service.loaded = TRUE
	service.profile = human_ai_settings_preset()
	GLOB.human_ai_settings = service
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	service.apply_global(human_ai_settings_preset("hard"), service.revision)
	var/inherited = brain.setting("reaction") == 0.3 && brain.setting("medicine")
	owner.stat = DEAD
	var/dead_revision = brain.settings_revision
	service.apply_global(human_ai_settings_preset("easy"), service.revision)
	var/dead_untouched = brain.settings_revision == dead_revision && brain.setting("reaction") == 0.3
	var/dead_rejected = !brain.sync_settings(TRUE)
	owner.stat = CONSCIOUS
	brain.sync_settings()
	var/revived = brain.setting("reaction") == 1.2 && !brain.setting("medicine")
	var/mob/living/carbon/human/new_owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/new_brain = allocate(/datum/human_ai_brain, new_owner)
	var/new_inherits = new_brain.setting("reaction") == 1.2
	var/stale_rejected = !service.apply_global(human_ai_settings_preset(), service.revision - 1)
	var/datum/ai_action/emergency = GLOB.AI_actions[/datum/ai_action/throw_back_nade]
	var/escape_available = brain.settings_allow_action(emergency)
	GLOB.human_ai_settings = original
	TEST_ASSERT(inherited, "Living NPC did not adopt global profile")
	TEST_ASSERT(dead_untouched && dead_rejected, "Dead NPC settings were modified")
	TEST_ASSERT(revived && new_inherits, "Living lifecycle did not inherit latest settings")
	TEST_ASSERT(stale_rejected, "Stale editor overwrote current settings")
	TEST_ASSERT(escape_available, "Disabling throwback disabled emergency escape")

/datum/unit_test/human_ai_settings_help_and_migration/Run()
	var/list/schema = human_ai_settings_schema()
	for(var/key in schema)
		var/list/definition = schema[key]
		if(!definition["boolean"])
			TEST_ASSERT(length(human_ai_settings_help(key)), "Numeric control lacks help: [key]")
	var/list/old_profile = human_ai_settings_preset()
	old_profile -= "grenade_chance"
	old_profile -= "stealth_enabled"
	old_profile["reaction"] = 2
	var/list/migrated = human_ai_settings_import(old_profile, 1)
	TEST_ASSERT(migrated && migrated["reaction"] == 2 && migrated["grenade_chance"] == 100 && migrated["stealth_enabled"], "Old saved profile failed migration")
	TEST_ASSERT(!("grenade_chance" in old_profile), "Migration mutated saved source")
	old_profile -= "medicine"
	TEST_ASSERT(!human_ai_settings_import(old_profile, 1), "Migration accepted arbitrary partial profile")
	TEST_ASSERT(!human_ai_settings_valid_value("grenade_chance", -1), "Negative probability accepted")
	TEST_ASSERT(!human_ai_settings_valid_value("grenade_chance", 101), "Probability over 100 accepted")

/datum/unit_test/human_ai_global_grenade_and_stealth/Run()
	var/datum/human_ai_settings_service/original = GLOB.human_ai_settings
	var/datum/human_ai_settings_service/service = allocate(/datum/human_ai_settings_service)
	service.loaded = TRUE
	service.profile = human_ai_settings_preset()
	GLOB.human_ai_settings = service
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	owner.dir = SOUTH
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/rear_hidden = !brain.human_ai_can_visually_detect_target(target)
	var/list/profile = human_ai_settings_preset()
	profile["grenade_chance"] = 0
	profile["stealth_enabled"] = FALSE
	service.apply_global(profile, service.revision)
	brain.begin_combat_grenade_decision()
	var/zero_rejected = !brain.should_attempt_combat_grenade()
	var/rear_visible = brain.human_ai_can_visually_detect_target(target)
	profile["grenade_chance"] = 100
	service.apply_global(profile, service.revision)
	var/no_reroll = !brain.should_attempt_combat_grenade()
	brain.begin_combat_grenade_decision()
	var/hundred_selected = brain.should_attempt_combat_grenade()
	brain.consume_combat_grenade_decision()
	var/consumed = !brain.should_attempt_combat_grenade()
	GLOB.human_ai_settings = original
	TEST_ASSERT(rear_hidden && rear_visible, "Global stealth switch did not control rear-facing exclusion")
	TEST_ASSERT(zero_rejected && no_reroll && hundred_selected && consumed, "Global grenade probability broke encounter caching")
