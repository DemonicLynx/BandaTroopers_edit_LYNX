/datum/modpack/lobby_ui
	name = "BandaTroopers selectable menu UI"
	desc = "Сохраняемый выбор классического или терминального лобби и редактора персонажа."
	author = "DemonicLynx for BandaMarines"

/datum/modpack/lobby_ui/pre_initialize()
	. = ..()
	if(.)
		return
	return SSmodpacks.register_lobby_ui_provider(src)

/datum/modpack/lobby_ui/lobby_ui_show_lobby(mob/new_player/player, refresh = FALSE)
	player.show_selected_lobby(refresh)
	return TRUE

/datum/modpack/lobby_ui/lobby_ui_hide(mob/user)
	user.hide_banda_lobby_interface()

/datum/modpack/lobby_ui/lobby_ui_play_click(mob/new_player/player)
	player.play_banda_lobby_click()

/datum/modpack/lobby_ui/lobby_ui_play_title_music(client/player_client)
	return player_client.play_banda_lobby_music()

/datum/modpack/lobby_ui/lobby_ui_show_manifest(mob/new_player/player, manifest_html)
	return player.client?.prefs?.show_banda_manifest(player, manifest_html) || FALSE

/datum/modpack/lobby_ui/lobby_ui_load_preferences(datum/preferences/preferences, savefile/preferences_file)
	preferences.load_banda_menu_interface(preferences_file)

/datum/modpack/lobby_ui/lobby_ui_save_preferences(datum/preferences/preferences, savefile/preferences_file)
	preferences.save_banda_menu_interface(preferences_file)

/datum/modpack/lobby_ui/lobby_ui_refresh_event_panels(datum/custom_event_info/event_info)
	event_info.refresh_banda_lobby_panels()

/datum/modpack/lobby_ui/lobby_ui_equip_character_preview(datum/preferences/preferences, mob/living/carbon/human/preview_dummy, datum/job/job)
	if(!preferences.uses_banda_terminal_interface())
		return FALSE
	if(preferences.banda_show_combat_gear)
		arm_equipment(preview_dummy, job, FALSE, FALSE, preferences.owner, TRUE)
	else
		preferences.equip_banda_preview_loadout_cosmetics()
	return TRUE

/datum/modpack/lobby_ui/lobby_ui_flavor_text_presentation(datum/preferences/preferences)
	if(!preferences?.uses_banda_terminal_interface())
		return null
	return list(
		"theme" = "crtgreen",
		"class_name" = "FlavorTextEditor--custom",
		"save_label" = "Сохранить",
		"revert_label" = "Вернуть",
		"editor_title" = "Описание: {category} (Shift+Enter — новая строка)",
		"category_labels" = list(
			"general" = "Общее",
			"head" = "Голова",
			"face" = "Лицо",
			"eyes" = "Глаза",
			"torso" = "Торс",
			"arms" = "Руки",
			"hands" = "Кисти",
			"legs" = "Ноги",
			"feet" = "Ступни",
			"helmet" = "Шлем",
			"armor" = "Броня",
		),
	)

/datum/modpack/lobby_ui/lobby_ui_flavor_text_window_title(datum/preferences/preferences)
	return preferences?.uses_banda_terminal_interface() ? "Описание персонажа" : null

/datum/modpack/lobby_ui/lobby_ui_uses_custom_character_editor(datum/preferences/preferences)
	return preferences?.uses_banda_terminal_interface()

/datum/modpack/lobby_ui/lobby_ui_character_header(datum/preferences/preferences, mob/user)
	if(!preferences?.uses_banda_terminal_interface())
		return null
	return preferences.get_terminal_character_preferences_header(user)

/datum/modpack/lobby_ui/lobby_ui_character_footer(datum/preferences/preferences)
	if(!preferences?.uses_banda_terminal_interface())
		return null
	return preferences.get_terminal_character_preferences_footer()

/datum/modpack/lobby_ui/lobby_ui_show_character_editor(datum/preferences/preferences, mob/user, html)
	if(!preferences?.uses_banda_terminal_interface())
		return FALSE
	preferences.show_terminal_character_preferences(user, html)
	return TRUE

/datum/modpack/lobby_ui/lobby_ui_character_equipment_controls(datum/preferences/preferences, mob/user)
	if(!preferences?.uses_banda_terminal_interface())
		return null
	var/list/personal_weapon_profile = GLOB.RoleAuthority?.get_main_ship_personal_weapon_profile()
	var/personal_weapon_label = personal_weapon_profile?["label"] || "Personal Weapon"
	var/dat = "<h2><b><u>Marine Gear:</u></b></h2>"
	dat += "<b>[personal_weapon_label]:</b> <a href ='byond://?_src_=prefs;preference=personalweapon;task=input'><b>[preferences.personal_weapon]</b></a><br>"
	dat += "<b>Underwear:</b> <a href ='byond://?_src_=prefs;preference=underwear;task=input'><b>[preferences.underwear]</b></a><br>"
	dat += "<b>Undershirt:</b> <a href='byond://?_src_=prefs;preference=undershirt;task=input'><b>[preferences.undershirt]</b></a><br>"
	dat += "<a href='byond://?_src_=prefs;preference=toggle_banda_combat_gear'><b>[preferences.banda_show_combat_gear ? "Выключить боевое снаряжение" : "Включить боевое снаряжение"]</b></a><br>"
	dat += "<span class='prefs-no-translate'><b>Личная экипировка:</b> "
	var/total_cost = 0
	if(!islist(preferences.gear))
		preferences.gear = list()
	if(length(preferences.gear))
		dat += "<br>"
		for(var/i = 1; i <= length(preferences.gear); i++)
			var/datum/gear/gear_item = GLOB.gear_datums_by_name[preferences.gear[i]]
			if(!gear_item)
				continue
			total_cost += gear_item.cost
			dat += "[html_encode(banda_translate_loadout_label(preferences.gear[i]))] ([gear_item.cost] очк.) <a href='byond://?src=\ref[user];preference=loadout;task=remove;gear=[i]'><b>Удалить</b></a><br>"
		dat += "<b>Использовано:</b> [total_cost] очк."
	else
		dat += "Нет"
	if(total_cost < MAX_GEAR_COST)
		dat += " <a href='byond://?src=\ref[user];preference=loadout;task=input'><b>Добавить</b></a>"
		if(LAZYLEN(preferences.gear))
			dat += " <a href='byond://?src=\ref[user];preference=loadout;task=clear'><b>Очистить</b></a>"
	return "[dat]</span>"

/datum/modpack/lobby_ui/lobby_ui_interface_controls(datum/preferences/preferences)
	return preferences?.get_banda_interface_preferences_controls() || ""

/datum/modpack/lobby_ui/lobby_ui_show_job_preferences(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return preferences?.show_banda_job_preferences(user, limit, split_jobs, width, height) || FALSE

/datum/modpack/lobby_ui/lobby_ui_show_job_slots(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return preferences?.show_banda_job_slots(user, limit, split_jobs, width, height) || FALSE

/datum/modpack/lobby_ui/lobby_ui_show_records(datum/preferences/preferences, mob/user)
	if(!preferences?.uses_banda_terminal_interface())
		return FALSE
	var/html = preferences.get_banda_auxiliary_window_header("ЗАПИСИ ПЕРСОНАЖА", "МЕДИЦИНСКОЕ // СЛУЖЕБНОЕ // ОХРАННОЕ ДОСЬЕ", "banda-record-window")
	html += "<div class='banda-record-grid'>"
	html += "<div class='banda-record-card'><div class='banda-record-index'>ФАЙЛ // 01</div><a href=\"byond://?src=\ref[user];preference=records;task=med_record\">МЕДИЦИНСКАЯ ЗАПИСЬ</a><div class='banda-record-preview'>[TextPreview(preferences.med_record, 80)]</div></div>"
	html += "<div class='banda-record-card'><div class='banda-record-index'>ФАЙЛ // 02</div><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">СЛУЖЕБНАЯ ЗАПИСЬ</a><div class='banda-record-preview'>[TextPreview(preferences.gen_record, 80)]</div></div>"
	html += "<div class='banda-record-card'><div class='banda-record-index'>ФАЙЛ // 03</div><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">ОХРАННАЯ ЗАПИСЬ</a><div class='banda-record-preview'>[TextPreview(preferences.sec_record, 80)]</div></div>"
	html += "</div><div class='banda-aux-actions'><a href=\"byond://?src=\ref[user];preference=records;records=-1\">ЗАКРЫТЬ</a></div>"
	html += preferences.get_banda_auxiliary_window_footer()
	close_browser(user, "preferences")
	show_browser(user, html, "Записи персонажа", "records", width = 760, height = 520)
	return TRUE

/datum/modpack/lobby_ui/lobby_ui_handle_preferences_topic(datum/preferences/preferences, mob/user, list/href_list)
	var/preference = href_list["preference"]
	switch(preference)
		if("banda_lobby_character_highlight")
			preferences.toggle_banda_lobby_character_highlight()
			preferences.ShowChoices(user)
			return TRUE
		if("banda_terminal_effect_intensity")
			preferences.cycle_banda_terminal_effect_intensity()
			preferences.ShowChoices(user)
			return TRUE
		if("banda_terminal_interface_color")
			preferences.select_banda_terminal_interface_color(user)
			preferences.ShowChoices(user)
			return TRUE
		if("banda_terminal_text_color")
			preferences.select_banda_terminal_text_color(user)
			preferences.ShowChoices(user)
			return TRUE
		if("banda_terminal_interface_color_reset")
			preferences.reset_banda_terminal_interface_color()
			preferences.ShowChoices(user)
			return TRUE
	if(!preferences.uses_banda_terminal_interface())
		return FALSE
	switch(preference)
		if("loadout")
			switch(href_list["task"])
				if("input")
					preferences.show_banda_loadout_picker(user)
					return TRUE
				if("add")
					var/datum/gear/selected_gear = locate(href_list["gear"])
					if(!selected_gear || GLOB.gear_datums_by_name[selected_gear.display_name] != selected_gear)
						return TRUE
					if(!islist(preferences.gear))
						preferences.gear = list()
					var/new_total_cost = preferences.get_banda_loadout_total_cost() + selected_gear.cost
					if(new_total_cost <= MAX_GEAR_COST)
						preferences.gear += selected_gear.display_name
						to_chat(user, SPAN_NOTICE("Добавлено: '[selected_gear.display_name]' за [selected_gear.cost] очк. Осталось: [MAX_GEAR_COST - new_total_cost] очк."))
					else
						to_chat(user, SPAN_WARNING("Добавление '[selected_gear.display_name]' превысит лимит лодаута в [MAX_GEAR_COST] очк."))
					preferences.ShowChoices(user)
					preferences.show_banda_loadout_picker(user, selected_gear.category)
					return TRUE
				if("close_picker")
					close_browser(user, "banda_loadout_picker")
					return TRUE
		if("toggle_banda_combat_gear")
			preferences.banda_show_combat_gear = !preferences.banda_show_combat_gear
			return FALSE
		if("h_style")
			preferences.show_banda_accessory_picker(user)
			return TRUE
		if("f_style")
			preferences.show_banda_accessory_picker(user, TRUE)
			return TRUE
		if("select_accessory_style")
			var/facial = href_list["kind"] == "facial"
			var/datum/sprite_accessory/selected_accessory = locate(href_list["accessory"])
			if(preferences.select_banda_accessory_style(selected_accessory, facial))
				preferences.ShowChoices(user)
				preferences.show_banda_accessory_picker(user, facial)
			return TRUE
		if("close_accessory_picker")
			close_browser(user, href_list["kind"] == "facial" ? "banda_facial_hair_picker" : "banda_hair_picker")
			return TRUE
		if("rotate_preview")
			if(preferences.preview_dummy)
				var/rotation = href_list["direction"] == "left" ? -90 : 90
				preferences.preview_dummy.setDir(turn(preferences.preview_dummy.dir, rotation))
			return FALSE
		if("return_to_lobby")
			var/mob/new_player/new_player_user = user
			if(istype(new_player_user))
				new_player_user.new_player_panel_proc(TRUE)
			else
				close_browser(user, "preferencebrowser")
				winshow(user, "preferencewindow", FALSE)
			return TRUE
	return FALSE

/datum/modpack/lobby_ui/lobby_ui_localized_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	if(!preferences?.uses_banda_terminal_interface())
		return tgui_input_list(user, prompt, title, options)
	return preferences.banda_localized_preference_choice(user, banda_translate_character_preference_text(prompt), banda_translate_character_preference_text(title), options)

/datum/modpack/lobby_ui/lobby_ui_translate_text(datum/preferences/preferences, text)
	if(!preferences?.uses_banda_terminal_interface())
		return text
	return banda_translate_character_preference_text(text)
