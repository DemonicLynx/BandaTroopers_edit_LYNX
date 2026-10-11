#define BANDA_MENU_INTERFACE_TERMINAL "terminal"
#define BANDA_MENU_INTERFACE_CLASSIC "classic"
#define BANDA_LOBBY_BROWSER "mapwindow.lobbybrowser"
#define BANDA_MAIN_SPLIT "mainwindow.split"
#define BANDA_LOBBY_SPLITTER 50
#define BANDA_CHARACTER_EDITOR_SPLITTER 70
#define BANDA_TERMINAL_INTERFACE_COLOR "#68ff72"
#define BANDA_TERMINAL_EFFECTS_FULL "full"
#define BANDA_TERMINAL_EFFECTS_REDUCED "reduced"
#define BANDA_TERMINAL_EFFECTS_OFF "off"

/proc/get_banda_color_hue_degrees(color_value)
	var/list/channels = ReadRGB(color_value)
	if(length(channels) < 3)
		return 0
	var/red = channels[1] / 255
	var/green = channels[2] / 255
	var/blue = channels[3] / 255
	var/channel_max = max(red, green, blue)
	var/channel_min = min(red, green, blue)
	var/channel_delta = channel_max - channel_min
	if(channel_delta <= 0)
		return 0
	var/hue
	if(channel_max == red)
		hue = 60 * ((green - blue) / channel_delta)
	else if(channel_max == green)
		hue = 60 * (((blue - red) / channel_delta) + 2)
	else
		hue = 60 * (((red - green) / channel_delta) + 4)
	if(hue < 0)
		hue += 360
	return hue

/client
	/// Original left/right pane split before the terminal lobby temporarily occupies half of the BYOND window.
	var/banda_lobby_splitter_restore
	/// Original left/right pane split while the embedded terminal character editor is open.
	var/banda_character_editor_splitter_restore

/client/proc/resize_banda_lobby_pane()
	if(isnull(banda_lobby_splitter_restore))
		var/current_splitter = winget(src, BANDA_MAIN_SPLIT, "splitter")
		if(!length(current_splitter))
			return
		banda_lobby_splitter_restore = current_splitter
	winset(src, BANDA_MAIN_SPLIT, "splitter=[BANDA_LOBBY_SPLITTER]")

/client/proc/restore_banda_lobby_pane()
	if(isnull(banda_lobby_splitter_restore))
		return
	winset(src, BANDA_MAIN_SPLIT, "splitter=[banda_lobby_splitter_restore]")
	banda_lobby_splitter_restore = null

/client/proc/expand_banda_character_editor_pane()
	if(!isnull(banda_character_editor_splitter_restore))
		return
	var/current_splitter = winget(src, BANDA_MAIN_SPLIT, "splitter")
	if(!length(current_splitter) || text2num(current_splitter) >= BANDA_CHARACTER_EDITOR_SPLITTER)
		return
	banda_character_editor_splitter_restore = current_splitter
	winset(src, BANDA_MAIN_SPLIT, "splitter=[BANDA_CHARACTER_EDITOR_SPLITTER]")

/client/proc/restore_banda_character_editor_pane()
	if(isnull(banda_character_editor_splitter_restore))
		return
	winset(src, BANDA_MAIN_SPLIT, "splitter=[banda_character_editor_splitter_restore]")
	banda_character_editor_splitter_restore = null

/datum/preferences
	/// Account-wide lobby and character-editor presentation. New players use the terminal theme.
	var/banda_menu_interface = BANDA_MENU_INTERFACE_TERMINAL
	/// Whether the terminal lobby dossier applies its green monochrome filter to the character portrait.
	var/banda_lobby_character_highlight = TRUE
	/// Primary hue used by all terminal menu surfaces.
	var/banda_terminal_interface_color = BANDA_TERMINAL_INTERFACE_COLOR
	/// Optional text-only color override. Null keeps text under the general terminal hue rotation.
	var/banda_terminal_text_color
	/// Account-wide intensity of decorative terminal animations and sounds.
	var/banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
	/// Last terminal character-editor tab rendered; used only to animate real tab changes.
	var/banda_last_terminal_menu

/datum/preferences/proc/uses_banda_terminal_interface()
	return banda_menu_interface != BANDA_MENU_INTERFACE_CLASSIC

/datum/preferences/proc/set_banda_menu_interface(new_interface)
	if(new_interface != BANDA_MENU_INTERFACE_CLASSIC && new_interface != BANDA_MENU_INTERFACE_TERMINAL)
		banda_menu_interface = BANDA_MENU_INTERFACE_TERMINAL
		return
	banda_menu_interface = new_interface

/datum/preferences/proc/set_banda_terminal_effect_intensity(new_intensity)
	if(new_intensity != BANDA_TERMINAL_EFFECTS_FULL && new_intensity != BANDA_TERMINAL_EFFECTS_REDUCED && new_intensity != BANDA_TERMINAL_EFFECTS_OFF)
		banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
		return
	banda_terminal_effect_intensity = new_intensity

/datum/preferences/proc/get_banda_terminal_effect_class()
	switch(banda_terminal_effect_intensity)
		if(BANDA_TERMINAL_EFFECTS_REDUCED)
			return " banda-effects-reduced"
		if(BANDA_TERMINAL_EFFECTS_OFF)
			return " banda-effects-off"
	return ""

/datum/preferences/proc/get_banda_terminal_effect_label()
	switch(banda_terminal_effect_intensity)
		if(BANDA_TERMINAL_EFFECTS_REDUCED)
			return "Сниженная"
		if(BANDA_TERMINAL_EFFECTS_OFF)
			return "Выключена"
	return "Полная"

/datum/preferences/proc/uses_banda_terminal_decorative_effects()
	return banda_terminal_effect_intensity != BANDA_TERMINAL_EFFECTS_OFF

/datum/preferences/proc/set_banda_terminal_interface_color(new_color)
	var/list/channels = istext(new_color) ? ReadRGB(new_color) : null
	if(length(channels) < 3)
		banda_terminal_interface_color = BANDA_TERMINAL_INTERFACE_COLOR
		return
	banda_terminal_interface_color = rgb(channels[1], channels[2], channels[3])

/datum/preferences/proc/get_banda_terminal_hue_rotation()
	var/rotation = get_banda_color_hue_degrees(banda_terminal_interface_color) - get_banda_color_hue_degrees(BANDA_TERMINAL_INTERFACE_COLOR)
	if(rotation > 180)
		rotation -= 360
	else if(rotation < -180)
		rotation += 360
	return round(rotation)

/datum/preferences/proc/set_banda_terminal_text_color(new_color)
	var/list/channels = istext(new_color) ? ReadRGB(new_color) : null
	if(length(channels) < 3)
		banda_terminal_text_color = null
		return
	banda_terminal_text_color = rgb(channels[1], channels[2], channels[3])

/datum/preferences/proc/get_banda_terminal_text_css_color()
	if(isnull(banda_terminal_text_color))
		return null
	var/list/channels = ReadRGB(banda_terminal_text_color)
	if(length(channels) < 3)
		return null
	var/red = channels[1] / 255
	var/green = channels[2] / 255
	var/blue = channels[3] / 255
	var/channel_max = max(red, green, blue)
	var/channel_min = min(red, green, blue)
	var/channel_delta = channel_max - channel_min
	var/lightness = (channel_max + channel_min) / 2
	var/saturation = channel_delta > 0 ? channel_delta / (1 - abs(2 * lightness - 1)) : 0
	var/hue = get_banda_color_hue_degrees(banda_terminal_text_color) - get_banda_terminal_hue_rotation()
	if(hue < 0)
		hue += 360
	else if(hue >= 360)
		hue -= 360
	return "hsl([round(hue)], [round(saturation * 100)]%, [round(lightness * 100)]%)"

/datum/preferences/proc/get_banda_terminal_text_override_class()
	return isnull(banda_terminal_text_color) ? "" : " banda-text-override"

/datum/preferences/proc/get_banda_terminal_text_override_style()
	var/text_color = get_banda_terminal_text_css_color()
	return isnull(text_color) ? "" : "--banda-text-color: [text_color];"

/datum/preferences/proc/load_banda_menu_interface(savefile/preferences_file)
	var/saved_interface
	preferences_file["banda_menu_interface"] >> saved_interface
	set_banda_menu_interface(saved_interface)
	var/saved_character_highlight
	preferences_file["banda_lobby_character_highlight"] >> saved_character_highlight
	banda_lobby_character_highlight = isnull(saved_character_highlight) ? TRUE : !!saved_character_highlight
	var/saved_interface_color
	preferences_file["banda_terminal_interface_color"] >> saved_interface_color
	set_banda_terminal_interface_color(saved_interface_color)
	var/saved_text_color
	preferences_file["banda_terminal_text_color"] >> saved_text_color
	set_banda_terminal_text_color(saved_text_color)
	var/saved_effect_intensity
	preferences_file["banda_terminal_effect_intensity"] >> saved_effect_intensity
	set_banda_terminal_effect_intensity(saved_effect_intensity)

/datum/preferences/proc/save_banda_menu_interface(savefile/preferences_file)
	preferences_file["banda_menu_interface"] << banda_menu_interface
	preferences_file["banda_lobby_character_highlight"] << banda_lobby_character_highlight
	preferences_file["banda_terminal_interface_color"] << banda_terminal_interface_color
	preferences_file["banda_terminal_text_color"] << banda_terminal_text_color
	preferences_file["banda_terminal_effect_intensity"] << banda_terminal_effect_intensity

/datum/preferences/proc/get_banda_interface_preferences_controls()
	if(!uses_banda_terminal_interface())
		return ""
	var/highlight_label = banda_lobby_character_highlight ? "Вкл" : "Выкл"
	var/text_color_swatch = banda_terminal_text_color || banda_terminal_interface_color
	var/effect_label = get_banda_terminal_effect_label()
	return "<h2><b><u>Личные Настройки Интерфейса:</u></b></h2><b>Подсветка персонажа в личном деле:</b> <a href='byond://?_src_=prefs;preference=banda_lobby_character_highlight'><b>[highlight_label]</b></a><br><b>Интенсивность эффектов:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_effect_intensity'><b>[effect_label]</b></a><br><b>Изменение цвета интерфейса:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_interface_color'><b>Color</b> <span class='square' style='background-color: [banda_terminal_interface_color];'></span></a><br><b>Изменение цвета текста интерфейса:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_text_color'><b>Color</b> <span class='square' style='background-color: [text_color_swatch];'></span></a><br><a href='byond://?_src_=prefs;preference=banda_terminal_interface_color_reset'><b>Сброс изменения цвета интерфейса</b></a><br><br>"

/datum/preferences/proc/toggle_banda_lobby_character_highlight()
	banda_lobby_character_highlight = !banda_lobby_character_highlight
	save_preferences()

/datum/preferences/proc/cycle_banda_terminal_effect_intensity()
	switch(banda_terminal_effect_intensity)
		if(BANDA_TERMINAL_EFFECTS_FULL)
			banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_REDUCED
		if(BANDA_TERMINAL_EFFECTS_REDUCED)
			banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_OFF
		else
			banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
	save_preferences()

/datum/preferences/proc/select_banda_terminal_interface_color(mob/user)
	var/new_color = input(user, "Выберите цвет терминального интерфейса. Тёмные цвета могут ухудшить читаемость.", "Цвет интерфейса", banda_terminal_interface_color) as color|null
	if(isnull(new_color))
		return
	set_banda_terminal_interface_color(new_color)
	save_preferences()

/datum/preferences/proc/select_banda_terminal_text_color(mob/user)
	var/initial_color = banda_terminal_text_color || banda_terminal_interface_color
	var/new_color = input(user, "Выберите персональный цвет текста терминального интерфейса.", "Цвет текста интерфейса", initial_color) as color|null
	if(isnull(new_color))
		return
	set_banda_terminal_text_color(new_color)
	save_preferences()

/datum/preferences/proc/reset_banda_terminal_interface_color()
	set_banda_terminal_interface_color(BANDA_TERMINAL_INTERFACE_COLOR)
	set_banda_terminal_text_color(null)
	save_preferences()

/datum/preferences/proc/get_banda_character_menu_tabs()
	var/list/tabs = list()
	tabs += list(list("id" = "marine", "label" = "Human"))
	tabs += list(list("id" = "pltco", "label" = "Platoon Presets"))
	tabs += list(list("id" = "xeno", "label" = "Xenomorph"))
	if(owner.check_whitelist_status(WHITELIST_COMMANDER))
		tabs += list(list("id" = "co", "label" = "Commanding Officer"))
	tabs += list(list("id" = "synth", "label" = "Synthetic"))
	if(owner.check_whitelist_status(WHITELIST_PREDATOR))
		tabs += list(list("id" = "yautja", "label" = "Yautja"))
	if(owner.check_whitelist_status(WHITELIST_MENTOR))
		tabs += list(list("id" = "mentor", "label" = "Mentor"))
	tabs += list(list("id" = "settings", "label" = "Settings"))
	tabs += list(list("id" = "special", "label" = "Special Roles"))
	return tabs

/datum/preferences/proc/get_banda_character_preferences_header(mob/user)
	if(uses_banda_terminal_interface())
		return get_terminal_character_preferences_header(user)
	return get_classic_character_preferences_header(user)

/datum/preferences/proc/get_banda_character_preferences_footer()
	if(uses_banda_terminal_interface())
		return get_terminal_character_preferences_footer()
	return get_classic_character_preferences_footer()

/datum/preferences/proc/show_banda_character_preferences(mob/user, html)
	if(uses_banda_terminal_interface())
		show_terminal_character_preferences(user, html)
		return
	show_classic_character_preferences(user, html)

/datum/preferences/proc/select_classic_accessory_style(mob/user, facial = FALSE)
	var/list/valid_styles = get_banda_valid_accessory_styles(facial)
	var/prompt = facial ? "Выберите растительность на лице персонажа:" : "Выберите причёску персонажа:"
	var/title = "Настройка персонажа"
	var/list/localized_styles = get_banda_localized_preference_choices(valid_styles)
	var/selected_label = input(user, prompt, title) as null|anything in localized_styles
	var/selected_style = localized_styles[selected_label]
	if(!selected_style)
		return
	if(facial)
		f_style = selected_style
	else
		h_style = selected_style

/mob/new_player/proc/show_selected_lobby(refresh = FALSE)
	if(client?.prefs?.uses_banda_terminal_interface())
		show_terminal_lobby(refresh)
		return
	banda_lobby_visible = FALSE
	banda_lobby_render_generation++
	client?.restore_banda_character_editor_pane()
	client?.restore_banda_lobby_pane()
	show_classic_lobby(refresh)

/mob/proc/hide_banda_lobby_interface()
	if(!client)
		return
	if(istype(src, /mob/new_player))
		var/mob/new_player/player = src
		player.banda_lobby_visible = FALSE
		player.banda_lobby_render_generation++
	client.restore_banda_character_editor_pane()
	client.restore_banda_lobby_pane()
	close_browser(src, "lobbybrowser")
	close_browser(src, "playersetup")
	winset(client, BANDA_LOBBY_BROWSER, "is-visible=false")

/mob/new_player/proc/play_banda_lobby_click()
	if(!client?.prefs?.uses_banda_terminal_interface())
		return
	playsound_client(client, 'modular/lobby_ui/assets/menu_click.mp3', null, 45, FALSE, VOLUME_SFX)

/mob/new_player/proc/play_banda_lobby_startup_effect()
	if(!client?.prefs?.uses_banda_terminal_interface() || !client.prefs.uses_banda_terminal_decorative_effects() || !banda_lobby_visible)
		return
	playsound_client(client, 'modular/lobby_ui/assets/terminal_startup.ogg', null, 24, FALSE, VOLUME_SFX)

/mob/new_player/proc/play_banda_lobby_authorized_effect(expected_generation)
	if(!client?.prefs?.uses_banda_terminal_interface() || !client.prefs.uses_banda_terminal_decorative_effects() || !banda_lobby_visible || banda_lobby_render_generation != expected_generation)
		return
	playsound_client(client, 'modular/lobby_ui/assets/terminal_authorized.ogg', null, 22, FALSE, VOLUME_SFX)

/mob/new_player/proc/play_banda_lobby_type_complete_effect(expected_briefing, expected_generation)
	if(!client?.prefs?.uses_banda_terminal_interface() || !client.prefs.uses_banda_terminal_decorative_effects() || !banda_lobby_visible || banda_lobby_render_generation != expected_generation || banda_last_briefing_text != expected_briefing)
		return
	playsound_client(client, 'modular/lobby_ui/assets/terminal_type_complete.ogg', null, 18, FALSE, VOLUME_SFX)

/client/proc/play_banda_lobby_music()
	if(!prefs || !(prefs.toggles_sound & SOUND_LOBBY))
		return FALSE
	if(prefs.uses_banda_terminal_interface())
		var/sound/lobby_track = sound('modular/lobby_ui/assets/menu_bm.mp3', repeat = TRUE, wait = FALSE)
		playsound_client(src, lobby_track, null, 70, FALSE, VOLUME_LOBBY, SOUND_CHANNEL_LOBBY, SOUND_STREAM)
		return TRUE
	if(!SSticker?.login_music)
		return FALSE
	playsound_client(src, SSticker.login_music, null, 70, FALSE, VOLUME_LOBBY, SOUND_CHANNEL_LOBBY, SOUND_STREAM)
	return TRUE

/client/verb/select_banda_menu_interface()
	set name = "Выбрать интерфейс"
	set category = "Preferences.Menu"
	set desc = "Выбор классического или терминального интерфейса лобби и редактора персонажа."

	if(!prefs)
		return
	var/current_label = prefs.uses_banda_terminal_interface() ? "Терминальный" : "Классический"
	var/selection = tgui_alert(src, "Текущий интерфейс: [current_label].\nВыберите оформление лобби и редактора персонажа.", "Интерфейс меню", list("Терминальный", "Классический", "Отмена"))
	if(!selection || selection == "Отмена")
		return
	var/new_interface = selection == "Классический" ? BANDA_MENU_INTERFACE_CLASSIC : BANDA_MENU_INTERFACE_TERMINAL
	if(new_interface == prefs.banda_menu_interface)
		return

	prefs.set_banda_menu_interface(new_interface)
	prefs.save_preferences()
	restore_banda_character_editor_pane()
	to_chat(src, SPAN_NOTICE("Выбран интерфейс: [selection]. Настройка сохранена."))
	if(mob)
		close_browser(mob, "banda_hair_picker")
		close_browser(mob, "banda_facial_hair_picker")
		close_browser(mob, "preferencebrowser")
		winshow(mob, "preferencewindow", FALSE)

	if(istype(mob, /mob/new_player))
		src << sound(null, repeat = FALSE, wait = FALSE, volume = 0, channel = SOUND_CHANNEL_LOBBY)
		playtitlemusic()
		var/mob/new_player/player = mob
		player.new_player_panel_proc(TRUE)

/datum/custom_event_info/proc/refresh_banda_lobby_panels()
	if(faction != "Global")
		return
	for(var/mob/new_player/player as anything in GLOB.new_player_list)
		player.new_player_panel_proc(TRUE)

#undef BANDA_LOBBY_BROWSER
#undef BANDA_MAIN_SPLIT
#undef BANDA_LOBBY_SPLITTER
#undef BANDA_CHARACTER_EDITOR_SPLITTER
#undef BANDA_TERMINAL_INTERFACE_COLOR
#undef BANDA_TERMINAL_EFFECTS_FULL
#undef BANDA_TERMINAL_EFFECTS_REDUCED
#undef BANDA_TERMINAL_EFFECTS_OFF
#undef BANDA_MENU_INTERFACE_CLASSIC
#undef BANDA_MENU_INTERFACE_TERMINAL
