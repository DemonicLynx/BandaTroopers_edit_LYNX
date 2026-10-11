/datum/preferences/proc/get_banda_valid_accessory_styles(facial = FALSE)
	var/list/valid_styles = list()
	var/list/source_styles = facial ? GLOB.facial_hair_styles_list : GLOB.hair_styles_list

	for(var/style_name in source_styles)
		var/datum/sprite_accessory/accessory = source_styles[style_name]
		if(!accessory || !(species in accessory.species_allowed) || !accessory.selectable)
			continue
		if(facial)
			if(gender == MALE && accessory.gender == FEMALE)
				continue
			if(gender == FEMALE && accessory.gender == MALE)
				continue
		valid_styles[style_name] = accessory

	return valid_styles

/datum/preferences/proc/get_banda_accessory_preview(datum/sprite_accessory/accessory, client/viewer, facial = FALSE)
	if(!accessory || !viewer || !accessory.icon || isnull(accessory.icon_state))
		return "<span class='picker-no-preview'>NO IMAGE</span>"

	var/image/accessory_appearance = image(icon = accessory.icon, icon_state = "[accessory.icon_state]_s", dir = SOUTH)
	var/color_key = "native"
	if(accessory.do_coloration)
		var/accessory_color = facial ? rgb(r_facial, g_facial, b_facial) : rgb(r_hair, g_hair, b_hair)
		accessory_appearance.color = list(null, null, null, null, accessory_color)
		color_key = accessory_color

	var/icon/accessory_preview = getFlatIcon(accessory_appearance, defdir = SOUTH, no_anim = TRUE)
	if(!accessory_preview)
		return "<span class='picker-no-preview'>NO IMAGE</span>"

	var/resource_key = "[accessory.type]|[accessory.icon_state]|[color_key]"
	var/resource_name = "banda_accessory_[md5(resource_key)].png"
	var/sprite_position_class = facial ? " picker-sprite-facial" : " picker-sprite-hair"
	viewer << browse_rsc(accessory_preview, resource_name)
	return "<img class='picker-sprite[sprite_position_class]' src='[resource_name]' alt='Accessory preview'>"

/proc/get_banda_accessory_picker_styles(interface_hue_inverse = 0)
	return {"
		<style>
			* { box-sizing: border-box; }
			html { width: 100%; min-height: 100%; margin: 0; padding: 0; }
			body { width: 100%; min-height: 100%; margin: 0; padding: 0; overflow-x: hidden; overflow-y: scroll; background: #000500; color: #72ef7a; font-family: Consolas, 'Lucida Console', 'Courier New', monospace; scrollbar-color: #4ee45a #061507; scrollbar-face-color: #31933a; scrollbar-track-color: #061507; scrollbar-arrow-color: #8cff93; scrollbar-shadow-color: #0a2e0d; }
			a, a:link, a:visited { color: #79f782; text-decoration: none; }
			body::-webkit-scrollbar { width: 15px; }
			body::-webkit-scrollbar-track { background: #061507; border-left: 1px solid #246b2b; }
			body::-webkit-scrollbar-thumb { min-height: 42px; background: #31933a; border: 2px solid #061507; box-shadow: inset 0 0 0 1px #67e970; }
			body::-webkit-scrollbar-button { height: 15px; background: #174b1c; border: 1px solid #3bb646; }
			.picker-crt { position: relative; width: 100%; min-height: 100%; padding: 13px; overflow: visible; background: radial-gradient(ellipse at 50% 28%, rgba(15, 72, 20, .24), rgba(0, 5, 0, .98) 72%), #000500; }
			.picker-crt:before { content: ''; position: absolute; z-index: 30; inset: 0; pointer-events: none; background: repeating-linear-gradient(0deg, rgba(0, 0, 0, .19) 0, rgba(0, 0, 0, .19) 1px, rgba(66, 255, 79, .025) 2px, transparent 4px), radial-gradient(ellipse at center, transparent 58%, rgba(0, 0, 0, .65) 100%); }
			.picker-terminal { position: relative; z-index: 2; width: 100%; overflow: visible; border: 1px solid #43d84e; background: rgba(0, 13, 2, .82); box-shadow: inset 0 0 28px rgba(44, 255, 57, .07), 0 0 12px rgba(44, 255, 57, .14); }
			.picker-crt.banda-text-override .picker-terminal, .picker-crt.banda-text-override .picker-terminal *, .picker-crt.banda-text-override .picker-terminal *:before, .picker-crt.banda-text-override .picker-terminal *:after { color: var(--banda-text-color) !important; }
			.picker-crt.banda-text-override a.picker-close:hover, .picker-crt.banda-text-override a.picker-close:hover * { color: #001700 !important; }
			.picker-header { min-height: 64px; padding: 12px 15px 10px; border-bottom: 1px dashed rgba(91, 255, 101, .62); display: flex; align-items: center; }
			.picker-heading { flex: 1 1 auto; min-width: 0; }
			.picker-title { color: #8cff93; font-size: 21px; line-height: 26px; letter-spacing: 3px; text-transform: uppercase; text-shadow: 0 0 8px rgba(84, 255, 95, .55); }
			.picker-subtitle { color: #48c952; font-size: 10px; line-height: 15px; letter-spacing: 2px; text-transform: uppercase; }
			a.picker-close, a.picker-close:link, a.picker-close:visited { flex: 0 0 auto; margin-left: 14px; padding: 8px 13px; border: 1px solid #43d84e; background: rgba(8, 49, 12, .82); color: #8cff93; font-size: 11px; letter-spacing: 1px; text-transform: uppercase; }
			a.picker-close:hover { color: #001700; background: #78ef80; border-color: #b5ffba; text-shadow: none; }
			.picker-scroll { padding: 10px; overflow: visible; }
			.picker-grid { display: flex; flex-wrap: wrap; align-content: flex-start; margin: -5px; }
			a.picker-card, a.picker-card:link, a.picker-card:visited { position: relative; display: flex; flex-direction: column; width: 146px; height: 154px; margin: 5px; padding: 7px; overflow: hidden; border: 1px solid #277c2e; background: rgba(1, 22, 4, .88); color: #75dc7c; box-shadow: inset 0 0 15px rgba(49, 255, 62, .035); }
			a.picker-card:hover { border-color: #83ff8b; background: rgba(17, 65, 22, .86); color: #b9ffbd; box-shadow: 0 0 10px rgba(62, 255, 75, .22), inset 0 0 18px rgba(61, 255, 73, .08); }
			a.picker-card.selected { border-color: #9dffa3; background: rgba(30, 92, 36, .88); color: #d1ffd4; box-shadow: 0 0 11px rgba(74, 255, 86, .3), inset 0 0 19px rgba(90, 255, 101, .1); }
			a.picker-card.selected:before { content: 'ВЫБРАНО'; position: absolute; z-index: 4; top: 4px; right: 5px; color: #aaffb0; font-size: 8px; letter-spacing: 1px; }
			.picker-sprite-box { flex: 0 0 105px; display: flex; align-items: center; justify-content: center; overflow: hidden; border: 1px solid rgba(67, 216, 78, .43); background-color: #071008; background-image: radial-gradient(circle at 50% 45%, rgba(39, 78, 43, .58) 0, rgba(10, 27, 12, .92) 58%, #040a05 100%); box-shadow: inset 0 0 18px rgba(62, 255, 75, .08); }
			.picker-sprite { display: block; width: 150px; height: 150px; max-width: none; flex: 0 0 150px; object-fit: contain; transform-origin: 50% 42%; image-rendering: pixelated; image-rendering: crisp-edges; filter: hue-rotate([interface_hue_inverse]deg) drop-shadow(0 0 7px rgba(135, 255, 143, .35)); }
			.picker-sprite-facial { transform: translateY(18px) scale(1.2); }
			.picker-sprite-hair { transform: translateY(52px) scale(1.2); }
			.picker-no-preview { color: #4e8e53; font-size: 9px; letter-spacing: 1px; }
			.picker-label { flex: 1 1 auto; min-height: 0; padding: 6px 2px 0; overflow: hidden; font-size: 10px; line-height: 13px; text-align: center; text-transform: uppercase; }
			.picker-empty { margin: 18px; padding: 20px; border: 1px dashed #347f3b; color: #5ead65; text-align: center; letter-spacing: 2px; }
		</style>
		[get_banda_character_preferences_translation_script()]
	"}

/datum/preferences/proc/show_banda_accessory_picker(mob/user, facial = FALSE)
	if(!user || !user.client)
		return

	var/list/valid_styles = get_banda_valid_accessory_styles(facial)
	var/list/sorted_style_names = list()
	for(var/style_name in valid_styles)
		sorted_style_names += style_name
	sorted_style_names = sortList(sorted_style_names)
	var/current_style = facial ? f_style : h_style
	var/picker_kind = facial ? "facial" : "hair"
	var/window_id = facial ? "banda_facial_hair_picker" : "banda_hair_picker"
	var/window_title = facial ? "Растительность на лице" : "Причёска" // SS220 EDIT: localize the native browser-window title as well as its HTML contents
	var/catalog_title = facial ? "ВЫБОР РАСТИТЕЛЬНОСТИ НА ЛИЦЕ" : "ВЫБОР ПРИЧЁСКИ"
	var/interface_hue_rotation = get_banda_terminal_hue_rotation()
	var/text_override_class = get_banda_terminal_text_override_class()
	var/text_override_style = get_banda_terminal_text_override_style()
	var/effect_class = get_banda_terminal_effect_class()
	var/dat = get_banda_accessory_picker_styles(-interface_hue_rotation)

	dat += "<body onload=\"var selected=document.getElementById('selected-style'); if(selected){selected.scrollIntoView(true);}\"><div class='picker-crt[text_override_class][effect_class]' style='filter: hue-rotate([interface_hue_rotation]deg);[text_override_style]'><div class='picker-terminal'>"
	dat += "<div class='picker-header'><div class='picker-heading'><div class='picker-title'>[catalog_title]</div><div class='picker-subtitle'>Выберите вариант по спрайту</div></div>"
	dat += "<a class='picker-close' href='byond://?_src_=prefs;preference=close_accessory_picker;kind=[picker_kind]'>ЗАКРЫТЬ</a></div>"
	dat += "<div class='picker-scroll'><div class='picker-grid'>"

	if(!length(sorted_style_names))
		dat += "<div class='picker-empty'>НЕТ ДОСТУПНЫХ ВАРИАНТОВ</div>"
	else
		for(var/style_name in sorted_style_names)
			var/datum/sprite_accessory/accessory = valid_styles[style_name]
			var/selected_class = style_name == current_style ? " selected" : ""
			var/selected_id = style_name == current_style ? " id='selected-style'" : ""
			var/style_preview = get_banda_accessory_preview(accessory, user.client, facial)
			var/style_label = html_encode("[style_name]")
			dat += "<a[selected_id] class='picker-card[selected_class]' href='byond://?_src_=prefs;preference=select_accessory_style;kind=[picker_kind];accessory=\ref[accessory]'>"
			dat += "<span class='picker-sprite-box'>[style_preview]</span><span class='picker-label'>[style_label]</span></a>"

	dat += "</div></div></div></div></body>"
	show_browser(user, dat, window_title, window_id, width = 850, height = 680)

/datum/preferences/proc/select_banda_accessory_style(datum/sprite_accessory/selected_accessory, facial = FALSE)
	if(!selected_accessory)
		return FALSE

	var/list/valid_styles = get_banda_valid_accessory_styles(facial)
	for(var/style_name in valid_styles)
		if(valid_styles[style_name] != selected_accessory)
			continue
		if(facial)
			f_style = style_name
		else
			h_style = style_name
		return TRUE

	return FALSE
