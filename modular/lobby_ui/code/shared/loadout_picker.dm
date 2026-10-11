/datum/preferences/proc/get_banda_loadout_total_cost()
	var/total_cost = 0
	if(!islist(gear))
		return total_cost

	for(var/gear_name in gear)
		var/datum/gear/gear_entry = GLOB.gear_datums_by_name[gear_name]
		total_cost += gear_entry?.cost

	return total_cost

/datum/preferences/proc/get_banda_loadout_preview(datum/gear/gear_entry, client/viewer)
	if(!gear_entry?.path || !viewer || !ispath(gear_entry.path, /atom))
		return "<span class='loadout-no-preview'>НЕТ ИЗОБРАЖЕНИЯ</span>"

	var/atom/item_path = gear_entry.path
	var/icon_file = initial(item_path.icon)
	var/icon_state = initial(item_path.icon_state)
	if(!icon_file || isnull(icon_state) || !(icon_state in icon_states(icon_file)))
		return "<span class='loadout-no-preview'>НЕТ ИЗОБРАЖЕНИЯ</span>"

	var/icon/item_preview = icon(icon_file, icon_state, SOUTH)
	var/item_color = initial(item_path.color)
	if(item_color && item_color != "#FFFFFF")
		item_preview.Blend(item_color, ICON_MULTIPLY)
	var/item_url = icon2html(item_preview, viewer, sourceonly = TRUE)
	if(!item_url)
		return "<span class='loadout-no-preview'>НЕТ ИЗОБРАЖЕНИЯ</span>"

	return "<img class='loadout-sprite' src='[item_url]' alt='[html_encode(banda_translate_loadout_label(gear_entry.display_name))]'>"

/proc/get_banda_loadout_picker_styles()
	return {"
		<style>
			.loadout-summary { margin: 10px; padding: 10px 14px; border-left: 4px solid #62e86b; background: rgba(7, 47, 11, .82); color: #8cff93; font-size: 13px; line-height: 19px; letter-spacing: 1px; }
			.loadout-category { margin: 9px 10px; border: 1px solid #2f9e39; background: rgba(0, 19, 3, .84); box-shadow: inset 0 0 17px rgba(59, 255, 72, .045); }
			a.loadout-category-toggle, a.loadout-category-toggle:link, a.loadout-category-toggle:visited { display: flex; align-items: center; min-height: 44px; padding: 9px 13px; border-left: 5px solid #4cd858; background: rgba(8, 50, 12, .82); color: #91ff98; font-size: 14px; line-height: 20px; letter-spacing: 2px; text-transform: uppercase; }
			a.loadout-category-toggle:hover { background: rgba(31, 101, 38, .9); color: #caffce; }
			.loadout-category-marker { flex: 0 0 34px; color: #b2ffb7; font-size: 18px; }
			.loadout-category-name { flex: 1 1 auto; }
			.loadout-category-count { flex: 0 0 auto; color: #54bf5d; font-size: 10px; letter-spacing: 1px; }
			.loadout-category-items { display: flex; flex-wrap: wrap; align-content: flex-start; padding: 8px; border-top: 1px dashed rgba(79, 211, 88, .48); }
			a.loadout-card, a.loadout-card:link, a.loadout-card:visited { position: relative; display: flex; flex-direction: column; width: 154px; height: 174px; margin: 5px; padding: 8px; overflow: hidden; border: 1px solid #287f30; background: rgba(1, 24, 4, .9); color: #75dc7c; box-shadow: inset 0 0 16px rgba(49, 255, 62, .04); }
			a.loadout-card:hover { border-color: #8aff92; background: rgba(18, 68, 23, .9); color: #c6ffca; box-shadow: 0 0 11px rgba(62, 255, 75, .24), inset 0 0 19px rgba(61, 255, 73, .09); }
			.loadout-sprite-box { flex: 0 0 108px; display: flex; align-items: center; justify-content: center; overflow: hidden; border: 1px solid rgba(67, 216, 78, .45); background: radial-gradient(circle at 50% 50%, rgba(42, 92, 48, .58), rgba(7, 19, 9, .96) 68%); }
			.loadout-sprite { display: block; width: 96px; height: 96px; object-fit: contain; image-rendering: pixelated; image-rendering: crisp-edges; filter: drop-shadow(0 0 7px rgba(135, 255, 143, .38)); }
			.loadout-no-preview { color: #4e8e53; font-size: 9px; line-height: 13px; letter-spacing: 1px; text-align: center; }
			.loadout-card-name { flex: 1 1 auto; min-height: 0; padding: 6px 2px 0; overflow: hidden; font-size: 10px; line-height: 13px; text-align: center; text-transform: uppercase; }
			.loadout-card-cost { flex: 0 0 auto; padding-top: 3px; color: #a4ffab; font-size: 9px; line-height: 12px; text-align: center; letter-spacing: 1px; }
		</style>
		<script type='text/javascript'>
			function toggleLoadoutCategory(contentId, markerId) {
				var content = document.getElementById(contentId);
				var marker = document.getElementById(markerId);
				if (!content || !marker) return;
				var opening = content.style.display === 'none';
				content.style.display = opening ? 'flex' : 'none';
				marker.innerHTML = opening ? '&#91;-&#93;' : '&#91;+&#93;';
			}
		</script>
	"}

/datum/preferences/proc/show_banda_loadout_picker(mob/user, open_category)
	if(!user?.client)
		return

	if(!islist(gear))
		gear = list()

	var/list/sorted_categories = list()
	for(var/category in GLOB.gear_datums_by_category)
		sorted_categories += category
	sorted_categories = sortList(sorted_categories)

	var/interface_hue_rotation = get_banda_terminal_hue_rotation()
	var/text_override_class = get_banda_terminal_text_override_class()
	var/text_override_style = get_banda_terminal_text_override_style()
	var/effect_class = get_banda_terminal_effect_class()
	var/dat = get_banda_accessory_picker_styles(-interface_hue_rotation)
	dat += get_banda_loadout_picker_styles()
	dat += "<body><div class='picker-crt[text_override_class][effect_class]' style='filter: hue-rotate([interface_hue_rotation]deg);[text_override_style]'><div class='picker-terminal'>"
	dat += "<div class='picker-header'><div class='picker-heading'><div class='picker-title'>КАТАЛОГ ЛОДАУТА</div><div class='picker-subtitle'>РАСКРОЙТЕ КАТЕГОРИЮ И ВЫБЕРИТЕ ПРЕДМЕТ</div></div>"
	dat += "<a class='picker-close' href='byond://?_src_=prefs;preference=loadout;task=close_picker'>ЗАКРЫТЬ</a></div>"
	var/total_cost = get_banda_loadout_total_cost()
	dat += "<div class='loadout-summary'>ИСПОЛЬЗОВАНО ОЧКОВ: [total_cost] / [MAX_GEAR_COST] &nbsp;//&nbsp; ОСТАЛОСЬ: [MAX_GEAR_COST - total_cost]</div>"

	if(!length(sorted_categories))
		dat += "<div class='picker-empty'>НЕТ ДОСТУПНЫХ КАТЕГОРИЙ</div>"
	else
		var/category_index = 0
		for(var/category in sorted_categories)
			category_index++
			var/list/category_gear = GLOB.gear_datums_by_category[category]
			if(!islist(category_gear))
				continue
			var/list/sorted_gear_labels = list()
			for(var/gear_label in category_gear)
				sorted_gear_labels += gear_label
			sorted_gear_labels = sortList(sorted_gear_labels)
			var/is_open = category == open_category
			var/content_id = "loadout-category-[category_index]"
			var/marker_id = "loadout-marker-[category_index]"
			var/safe_category = html_encode("[banda_translate_loadout_label(category)]")
			dat += "<div class='loadout-category'>"
			dat += "<a class='loadout-category-toggle' href='#' onclick=\"toggleLoadoutCategory('[content_id]', '[marker_id]'); return false;\"><span id='[marker_id]' class='loadout-category-marker'>[is_open ? "&#91;-&#93;" : "&#91;+&#93;"]</span><span class='loadout-category-name'>[safe_category]</span><span class='loadout-category-count'>[length(sorted_gear_labels)]</span></a>"
			dat += "<div id='[content_id]' class='loadout-category-items' style='display: [is_open ? "flex" : "none"];'>"
			for(var/gear_label in sorted_gear_labels)
				var/datum/gear/gear_entry = category_gear[gear_label]
				if(!gear_entry)
					continue
				var/item_preview = get_banda_loadout_preview(gear_entry, user.client)
				var/safe_item_name = html_encode("[banda_translate_loadout_label(gear_entry.display_name)]")
				dat += "<a class='loadout-card' href='byond://?_src_=prefs;preference=loadout;task=add;gear=\ref[gear_entry]'>"
				dat += "<span class='loadout-sprite-box'>[item_preview]</span><span class='loadout-card-name'>[safe_item_name]</span><span class='loadout-card-cost'>[gear_entry.cost] ОЧК.</span></a>"
			dat += "</div></div>"

	dat += "</div></div></body>"
	show_browser(user, dat, "Каталог лодаута", "banda_loadout_picker", width = 900, height = 720)
