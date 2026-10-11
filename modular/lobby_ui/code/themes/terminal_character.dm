/datum/preferences/proc/get_terminal_character_preferences_header(mob/user)
	var/character_name = html_encode(real_name || "UNKNOWN")
	var/character_preview
	if(current_menu == "marine")
		update_preview_icon()
		character_preview = get_banda_character_preferences_preview(user.client)

	var/interface_hue_rotation = get_banda_terminal_hue_rotation()
	var/interface_hue_inverse = -interface_hue_rotation
	var/text_override_class = get_banda_terminal_text_override_class()
	var/text_override_style = get_banda_terminal_text_override_style()
	var/effect_class = get_banda_terminal_effect_class()
	var/tab_transition_class = !isnull(banda_last_terminal_menu) && banda_last_terminal_menu != current_menu ? " tab-switching" : ""
	banda_last_terminal_menu = current_menu
	var/dat = get_banda_character_preferences_styles(interface_hue_inverse)
	dat += "<body onselectstart='return false;'>"
	if(!path)
		return dat

	dat += "<div class='prefs-crt[text_override_class][tab_transition_class][effect_class]' style='filter: hue-rotate([interface_hue_rotation]deg);[text_override_style]'><div class='prefs-crt-speckle'></div><div class='prefs-crt-frame'></div>"
	dat += "<div class='prefs-terminal'>"
	dat += "<div class='prefs-header'>"
	dat += "<div class='prefs-brand'><div class='prefs-brand-title'>ЛИЧНОЕ ДЕЛО &quot;[character_name]&quot;</div></div>"
	dat += "<div class='prefs-slot-tools'>"
	dat += "<a class='prefs-tool' href=\"byond://?src=\ref[user];preference=open_load_dialog\"><b>Load Slot</b></a>"
	dat += "<a class='prefs-tool' href=\"byond://?src=\ref[user];preference=save\"><b>Save Slot</b></a>"
	dat += "<a class='prefs-tool' href=\"byond://?src=\ref[user];preference=reload\"><b>Reload Slot</b></a>"
	dat += "</div></div>"
	dat += "<div class='prefs-tabs'>"
	for(var/list/tab as anything in get_banda_character_menu_tabs())
		var/menu_id = tab["id"]
		var/menu_label = tab["label"]
		dat += "<a class='prefs-tab[current_menu == menu_id ? " active linkOff" : ""]' href=\"byond://?src=\ref[user];preference=change_menu;menu=[menu_id]\"><b>[menu_label]</b></a>"
	dat += "</div>"
	dat += "<div class='prefs-workspace[current_menu == "marine" ? " human" : " full"]'>"
	if(current_menu == "marine")
		dat += "<div class='prefs-preview-panel'><div class='prefs-preview-title'>[character_name]</div>"
		dat += "<div class='prefs-preview-stage'>"
		dat += "<a class='prefs-preview-arrow left' title='Rotate left' href='byond://?_src_=prefs;preference=rotate_preview;direction=left'>&#8249;</a>"
		dat += "[character_preview]"
		dat += "<a class='prefs-preview-arrow right' title='Rotate right' href='byond://?_src_=prefs;preference=rotate_preview;direction=right'>&#8250;</a>"
		dat += "</div></div>"
	dat += "<div class='prefs-content'>"
	return dat

/datum/preferences/proc/get_terminal_character_preferences_footer()
	return "</div><a class='prefs-back-button' href='byond://?_src_=prefs;preference=return_to_lobby'>вернуться назад</a></div></div></div></body>"

/datum/preferences/proc/show_terminal_character_preferences(mob/user, html)
	if(istype(user, /mob/new_player))
		var/mob/new_player/player = user
		player.banda_lobby_visible = FALSE
		player.banda_lobby_render_generation++
		winshow(user, "preferencewindow", FALSE)
		user.client.expand_banda_character_editor_pane()
		winset(user.client, "mapwindow.lobbybrowser", "is-visible=true")
		show_browser(user, html, null, "lobbybrowser", "can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0", existing_container = "mapwindow")
		return
	winshow(user, "preferencewindow", TRUE)
	show_browser(user, html, "Настройки персонажа", "preferencebrowser", width = 1000, height = 800, existing_container = "preferencewindow")
	onclose(user, "preferencewindow", src)
