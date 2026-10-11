// DemonicLynx for BandaMarines

/mob/new_player
	var/banda_lobby_intro_played = FALSE
	var/banda_last_briefing_text
	var/banda_lobby_visible = FALSE
	var/banda_lobby_render_generation = 0

/mob/new_player/proc/show_terminal_lobby(refresh = FALSE)
	if(!client)
		return
	client.restore_banda_character_editor_pane()
	client.resize_banda_lobby_pane()
	close_browser(src, "playersetup")
	client << browse_rsc(file("interface/Grand9K_Pixel.ttf"), "Grand9K_Pixel.ttf")
	client << browse_rsc(file("interface/Pix_Cyrillic.ttf"), "Pix_Cyrillic.ttf")
	banda_lobby_visible = TRUE
	var/render_generation = ++banda_lobby_render_generation
	var/datum/preferences/preferences = client.prefs
	var/effect_class = preferences?.get_banda_terminal_effect_class() || ""
	var/effects_enabled = preferences?.uses_banda_terminal_decorative_effects()
	var/play_lobby_intro = !banda_lobby_intro_played && effects_enabled
	banda_lobby_intro_played = TRUE
	var/lobby_intro_class = play_lobby_intro ? " booting" : ""
	if(play_lobby_intro)
		play_banda_lobby_startup_effect()
		addtimer(CALLBACK(src, PROC_REF(play_banda_lobby_authorized_effect), render_generation), 27)

	var/round_pending = !SSticker || !SSticker.mode || SSticker.current_state <= GAME_STATE_PREGAME
	var/primary_choice
	var/primary_title
	var/primary_subtitle
	var/primary_icon
	var/primary_state_class

	if(round_pending)
		primary_choice = ready ? "unready" : "ready"
		primary_title = ready ? "ГОТОВ" : "НЕ ГОТОВ"
		primary_subtitle = ready ? "Ожидание начала операции" : "Нажмите, чтобы подтвердить"
		primary_icon = ready ? "<svg viewBox='0 0 64 64'><rect x='12' y='12' width='40' height='40'/><path d='M20 33l8 8 17-21'/></svg>" : "<svg viewBox='0 0 64 64'><rect x='12' y='12' width='40' height='40'/><path d='M21 32h22'/></svg>"
		primary_state_class = ready ? "ready-active" : "ready-inactive"
	else
		primary_choice = "late_join"
		primary_title = "ПРИСОЕДИНИТЬСЯ"
		primary_subtitle = "Войти в текущий раунд"
		primary_icon = "<svg viewBox='0 0 64 64' class='filled-icon'><path d='M18 10l38 22-38 22z'/></svg>"
		primary_state_class = "join-active"

	var/interface_hue_rotation = preferences?.get_banda_terminal_hue_rotation() || 0
	var/interface_hue_inverse = -interface_hue_rotation
	var/text_override_class = preferences?.get_banda_terminal_text_override_class() || ""
	var/text_override_style = preferences?.get_banda_terminal_text_override_style() || ""
	var/character_highlight_class = preferences?.banda_lobby_character_highlight ? " character-highlight" : ""
	var/character_name = html_encode(preferences?.real_name || client.key || "НЕИЗВЕСТНО")
	var/character_age = preferences ? html_encode("[preferences.age]") : "—"
	var/character_gender = "—"
	var/character_species = "—"
	var/character_body_size = "—"
	var/character_body_type = "—"
	var/character_origin = "—"
	var/character_squad = "—"
	var/character_job = "—"
	var/character_wy_relation = "—"

	if(preferences)
		character_gender = preferences.gender == MALE ? "МУЖСКОЙ" : "ЖЕНСКИЙ"
		character_species = html_encode(banda_translate_character_preference_text(preferences.species || "—"))
		character_body_size = html_encode(banda_translate_character_preference_text(preferences.body_size || "—"))
		character_body_type = html_encode(banda_translate_character_preference_text(preferences.body_type || "—"))
		character_origin = html_encode(banda_translate_character_preference_text(preferences.origin || "—"))
		if(preferences.preferred_squad && preferences.preferred_squad != "None")
			character_squad = html_encode(banda_translate_character_preference_text(preferences.preferred_squad))
		var/list/high_priority_jobs = preferences.get_jobs_by_priority(HIGH_PRIORITY)
		if(length(high_priority_jobs))
			var/preferred_job_bucket = high_priority_jobs[1]
			var/preferred_job_title = GLOB.RoleAuthority?.get_active_role_title_for_preference_bucket(preferred_job_bucket) || preferred_job_bucket
			var/datum/job/preferred_job
			if(GLOB.RoleAuthority)
				preferred_job = GLOB.RoleAuthority.roles_by_name[preferred_job_title]
			character_job = html_encode(preferred_job?.disp_title || preferred_job?.title || preferred_job_bucket)
		character_wy_relation = html_encode(banda_translate_character_preference_text(preferences.weyland_yutani_relation || "—"))

	var/character_image
	if(preferences)
		if(!preferences.preview_dummy)
			preferences.update_preview_icon()
		if(preferences.preview_dummy)
			var/original_preview_direction = preferences.preview_dummy.dir
			preferences.preview_dummy.dir = SOUTH
			var/icon/flattened_character = getFlatIcon(preferences.preview_dummy, defdir = SOUTH, no_anim = TRUE)
			preferences.preview_dummy.dir = original_preview_direction
			var/character_url = icon2html(flattened_character, client, sourceonly = TRUE)
			if(character_url)
				character_image = "<img class='character-sprite[character_highlight_class]' src='[character_url]' alt='[character_name]'>"
	if(!character_image)
		character_image = "<div class='character-fallback'>НЕТ ИЗОБРАЖЕНИЯ</div>"

	var/mission_details = "ОЖИДАНИЕ ОПЕРАТИВНОЙ СВОДКИ...<span class='terminal-cursor'>&#9608;</span>"
	var/mission_typewriter_source = ""
	var/mission_typing_class = ""
	var/datum/custom_event_info/global_event = GLOB.custom_event_info_list?["Global"]
	if(global_event?.msg)
		var/briefing_text = "[global_event.msg]"
		var/safe_briefing = html_encode(briefing_text)
		mission_details = replacetext(safe_briefing, "\n", "<br>")
		if(briefing_text != banda_last_briefing_text)
			banda_last_briefing_text = briefing_text
			if(effects_enabled)
				mission_details = ""
				mission_typing_class = " typing"
				mission_typewriter_source = "<textarea id='missionTypewriterSource' class='mission-typewriter-source'>[safe_briefing]</textarea>"
				var/typewriter_sound_delay = max(1, CEILING(length(briefing_text) / 25, 1))
				addtimer(CALLBACK(src, PROC_REF(play_banda_lobby_type_complete_effect), briefing_text, render_generation), typewriter_sound_delay)
	else
		banda_last_briefing_text = null

	var/source_ref = "\ref[src]"
	var/brand_icon = "<svg viewBox='0 0 72 82'><path d='M8 8v34l28 27 28-27V8L36 35z'/><path d='M8 8l28 27L64 8'/><path d='M18 50l18 18 18-18'/></svg>"
	var/character_icon = "<svg viewBox='0 0 64 64' class='filled-icon'><circle cx='32' cy='20' r='11'/><path d='M12 53c1-14 9-21 20-21s19 7 20 21z'/></svg>"
	var/manifest_icon = "<svg viewBox='0 0 64 64' class='filled-icon'><circle cx='32' cy='18' r='8'/><circle cx='14' cy='24' r='6'/><circle cx='50' cy='24' r='6'/><path d='M19 53c0-13 5-22 13-22s13 9 13 22zM3 52c0-11 4-19 11-19 4 0 7 2 9 6-3 4-5 8-5 13zM46 52c0-5-2-9-5-13 2-4 5-6 9-6 7 0 11 8 11 19z'/></svg>"
	var/observe_icon = "<svg viewBox='0 0 64 64'><path d='M5 32s10-17 27-17 27 17 27 17-10 17-27 17S5 32 5 32z'/><circle cx='32' cy='32' r='9' class='icon-fill'/></svg>"
	var/html = {"
		<style>
			@font-face { font-family: 'Grand9K Pixel'; src: url('Grand9K_Pixel.ttf') format('truetype'); font-weight: normal; font-style: normal; }
			@font-face { font-family: 'Pix Cyrillic'; src: url('Pix_Cyrillic.ttf') format('truetype'); font-weight: normal; font-style: normal; }
			* { box-sizing: border-box !important; }
			html, body, .uiWrapper, .uiContent { width: 100% !important; height: 100% !important; margin: 0 !important; padding: 0 !important; overflow: hidden !important; }
			body { background: #000 !important; color: #68ff72 !important; font-family: 'Grand9K Pixel', 'Lucida Console', monospace !important; font-smooth: never; -webkit-font-smoothing: none; }
			a, a:link, a:visited, a:hover, a:active { color: inherit !important; text-decoration: none !important; }
			@keyframes crt-roll { 0% { top: -22%; } 100% { top: 112%; } }
			@keyframes crt-flicker { 0%, 18%, 22%, 62%, 66%, 100% { opacity: .98; } 20%, 64% { opacity: .91; } }
			@keyframes crt-warp { 0%, 93%, 100% { transform: translateX(0) skewX(0); } 94% { transform: translateX(1px) skewX(.08deg); } 95% { transform: translateX(-1px) skewX(-.08deg); } 96% { transform: translateX(0) skewX(0); } }
			@keyframes noise-shift { 0%, 100% { transform: translate(0, 0); opacity: .20; } 33% { transform: translate(1px, -1px); opacity: .27; } 66% { transform: translate(-1px, 1px); opacity: .18; } }
			@keyframes phosphor-pulse { 0%, 100% { text-shadow: 0 0 4px rgba(78, 255, 91, .72); } 50% { text-shadow: 0 0 8px rgba(100, 255, 112, .95); } }
			@keyframes cursor-blink { 0%, 48% { opacity: 1; } 49%, 100% { opacity: 0; } }
			@keyframes terminal-open { 0% { opacity: .2; transform: scaleY(.003); filter: brightness(3.2); } 18% { opacity: 1; transform: scaleY(.012); filter: brightness(2.8); } 72% { transform: scaleY(1.025); filter: brightness(1.35); } 100% { opacity: 1; transform: scaleY(1); filter: brightness(1); } }
			@keyframes boot-flare { 0% { opacity: 0; transform: scaleX(.04); } 12% { opacity: 1; transform: scaleX(.32); } 48% { opacity: 1; transform: scaleX(1); box-shadow: 0 0 8px #7dff87, 0 0 30px #42ff51, 0 0 70px rgba(51, 255, 66, .82); } 100% { opacity: 0; transform: scaleX(1); box-shadow: 0 0 2px #65ff70; } }
			@keyframes staged-reveal { 0% { opacity: 0; transform: translateY(8px); filter: brightness(1.7); } 55% { opacity: 1; transform: translateY(-1px); } 100% { opacity: 1; transform: translateY(0); filter: brightness(1); } }
			@keyframes auth-line-reveal { 0% { opacity: 0; transform: translateX(-8px); } 45% { opacity: 1; transform: translateX(2px); text-shadow: 0 0 9px rgba(105, 255, 116, .9); } 100% { opacity: 1; transform: translateX(0); } }
			@keyframes dossier-data-reveal { 0% { opacity: 0; filter: brightness(2); } 35% { opacity: .28; } 55% { opacity: 1; filter: brightness(1.5); } 100% { opacity: 1; filter: brightness(1); } }
			@keyframes auth-panel-life { 0% { opacity: 0; visibility: visible; } 10%, 88% { opacity: 1; visibility: visible; } 100% { opacity: 0; visibility: hidden; } }
			@keyframes activity-pulse { 0%, 100% { opacity: .58; text-shadow: 0 0 3px rgba(88, 255, 99, .5); } 50% { opacity: 1; text-shadow: 0 0 8px rgba(109, 255, 119, .95); } }
			@keyframes signal-interference { 0%, 94%, 97%, 100% { opacity: 0; transform: translateY(-18vh); } 95% { opacity: .13; transform: translateY(36vh); } 96% { opacity: .06; transform: translateY(72vh); } }
			@keyframes cursor-finish { 0%, 18%, 36%, 54%, 72% { opacity: 1; } 9%, 27%, 45%, 63%, 100% { opacity: 0; } }
			.crt-shell { width: 100%; height: 100%; min-height: 520px; position: relative; overflow: hidden; background: #000 !important; animation: crt-flicker 7s infinite; }
			.crt-shell:before { content: ''; position: absolute; z-index: 40; inset: 0; pointer-events: none; background-image: repeating-linear-gradient(0deg, rgba(0, 0, 0, .28) 0, rgba(0, 0, 0, .28) 1px, rgba(61, 255, 74, .045) 2px, transparent 4px), radial-gradient(ellipse at center, transparent 48%, rgba(0, 0, 0, .86) 100%); opacity: .96; }
			.crt-shell:after { content: ''; position: absolute; z-index: 41; left: 0; right: 0; top: -22%; height: 18%; pointer-events: none; background: linear-gradient(180deg, transparent, rgba(88, 255, 98, .06), rgba(190, 255, 194, .12), rgba(34, 255, 47, .04), transparent); animation: crt-roll 8s linear infinite; }
			.crt-speckle { position: absolute; z-index: 39; inset: 0; pointer-events: none; opacity: .23; background-image: radial-gradient(circle at 12% 9%, #65ff6e 0, #65ff6e 1px, transparent 2px), radial-gradient(circle at 73% 7%, #65ff6e 0, #65ff6e 1px, transparent 2px), radial-gradient(circle at 91% 27%, #65ff6e 0, #65ff6e 1px, transparent 2px), radial-gradient(circle at 18% 77%, #65ff6e 0, #65ff6e 1px, transparent 2px), radial-gradient(circle at 69% 83%, #65ff6e 0, #65ff6e 1px, transparent 2px); animation: noise-shift .24s steps(2, end) infinite; }
			.signal-interference { position: absolute; z-index: 44; left: 0; right: 0; top: 0; height: 5px; pointer-events: none; opacity: 0; background: linear-gradient(180deg, transparent, rgba(187, 255, 192, .8), rgba(65, 255, 79, .34), transparent); box-shadow: 0 0 9px rgba(89, 255, 100, .4); animation: signal-interference 31s linear 8s infinite; }
			.crt-frame { position: absolute; z-index: 38; inset: 4px; pointer-events: none; border: 2px solid rgba(91, 255, 100, .42); box-shadow: inset 0 0 0 3px #000, inset 0 0 0 4px rgba(65, 199, 74, .19), inset 0 0 34px rgba(26, 255, 43, .08); }
			.terminal { position: relative; z-index: 5; width: 100%; height: 100%; padding: 16px 26px 18px; display: flex; flex-direction: column; gap: 10px; animation: crt-warp 9s steps(1, end) infinite; }
			.crt-shell.banda-text-override .terminal, .crt-shell.banda-text-override .terminal *, .crt-shell.banda-text-override .terminal *:before, .crt-shell.banda-text-override .terminal *:after { color: var(--banda-text-color) !important; }
			.crt-shell.banda-text-override a.menu-item.primary, .crt-shell.banda-text-override a.menu-item.primary * { color: #001900 !important; }
			.boot-flare { display: none; position: absolute; z-index: 55; left: 3%; right: 3%; top: 50%; height: 2px; margin-top: -1px; pointer-events: none; background: #b6ffbb; transform-origin: center; }
			.crt-shell.booting .terminal { transform-origin: 50% 50%; animation: terminal-open 1.44s cubic-bezier(.18, .72, .2, 1) both, crt-warp 9s steps(1, end) 1.6s infinite; }
			.crt-shell.booting .boot-flare { display: block; animation: boot-flare 1.56s ease-out both; }
			.crt-shell.booting .brand { animation: staged-reveal .28s ease-out 1.05s backwards; }
			.crt-shell.booting .menu-item:nth-child(1) { animation: staged-reveal .24s ease-out 1.25s backwards; }
			.crt-shell.booting .menu-item:nth-child(2) { animation: staged-reveal .24s ease-out 1.37s backwards; }
			.crt-shell.booting .menu-item:nth-child(3) { animation: staged-reveal .24s ease-out 1.49s backwards; }
			.crt-shell.booting .menu-item:nth-child(4) { animation: staged-reveal .24s ease-out 1.61s backwards; }
			.crt-shell.booting .main-divider { animation: staged-reveal .24s ease-out 1.55s backwards; }
			.crt-shell.booting .dossier { animation: staged-reveal .28s ease-out 1.68s backwards; }
			.crt-shell.booting .mission { animation: staged-reveal .3s ease-out 3.02s backwards; }
			.crt-shell.banda-effects-reduced { animation: none; }
			.crt-shell.banda-effects-reduced:after, .crt-shell.banda-effects-reduced .crt-speckle, .crt-shell.banda-effects-reduced .signal-interference, .crt-shell.banda-effects-reduced .brand-title, .crt-shell.banda-effects-reduced .system-status { animation: none; }
			.crt-shell.banda-effects-reduced .signal-interference { display: none; }
			.crt-shell.banda-effects-reduced .terminal { animation: none; }
			.crt-shell.banda-effects-reduced.booting .terminal { animation: terminal-open 1.44s cubic-bezier(.18, .72, .2, 1) both; }
			.crt-shell.banda-effects-off, .crt-shell.banda-effects-off *, .crt-shell.banda-effects-off:before, .crt-shell.banda-effects-off:after, .crt-shell.banda-effects-off *:before, .crt-shell.banda-effects-off *:after { animation: none !important; transition: none !important; }
			.crt-shell.banda-effects-off .crt-speckle, .crt-shell.banda-effects-off .signal-interference, .crt-shell.banda-effects-off .boot-flare { display: none; }
			.brand { flex: 0 0 108px; min-height: 108px; display: flex; align-items: center; justify-content: center; position: relative; text-transform: uppercase; border-bottom: 1px solid rgba(74, 218, 83, .18); }
			.brand-line { display: flex; align-items: center; justify-content: center; gap: 24px; }
			.brand-rule { color: #58ef63; font-size: 24px; letter-spacing: 11px; white-space: nowrap; opacity: .82; text-shadow: 0 0 5px rgba(84, 255, 95, .7); }
			.brand-main { display: flex; align-items: center; gap: 18px; }
			.brand-mark { width: 56px; height: 64px; color: #68ff72; filter: drop-shadow(0 0 7px rgba(88, 255, 99, .75)); }
			.brand-mark svg { width: 100%; height: 100%; fill: none; stroke: currentColor; stroke-width: 5; stroke-linejoin: miter; }
			.brand-title { font-size: 31px; line-height: 34px; letter-spacing: 5px; font-weight: normal; animation: phosphor-pulse 4s ease-in-out infinite; white-space: nowrap; }
			.brand-subtitle { margin-top: 3px; font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 17px; line-height: 19px; letter-spacing: 5px; text-align: center; color: #58ef63; }
			.system-status { position: absolute; right: 5px; bottom: 7px; color: #61e96b; font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 9px; line-height: 12px; letter-spacing: 2px; animation: activity-pulse 3.2s ease-in-out infinite; }
			.main-grid { flex: 0 0 400px; min-height: 400px; display: flex; gap: 0; }
			.menu { flex: 0 0 44%; width: 44%; min-width: 315px; display: flex; flex-direction: column; gap: 2px; padding: 10px 10px 5px 2px; border-right: 0; position: relative; }
			.menu:after { content: '01 / 02 / 03 / 04'; position: absolute; right: 18px; top: 0; padding: 1px 5px; background: #000; color: rgba(87, 244, 98, .42); font-size: 7px; line-height: 9px; letter-spacing: 1px; }
			.main-divider { flex: 0 0 24px; position: relative; min-width: 24px; }
			.main-divider:before { content: ''; position: absolute; left: 50%; top: 8px; bottom: 8px; width: 2px; margin-left: -1px; background: repeating-linear-gradient(180deg, #59ef64 0, #59ef64 22px, transparent 22px, transparent 36px); opacity: .92; box-shadow: 0 0 4px rgba(83, 255, 94, .35); }
			a.menu-item, a.menu-item:link, a.menu-item:visited { flex: 1 1 0; min-height: 0; display: flex !important; align-items: center; position: relative; padding: 7px 14px !important; color: #66f96f !important; border: 1px solid transparent !important; border-left: 3px solid transparent !important; background: #000 !important; text-transform: none; overflow: hidden; transition: border-color .08s linear, background-color .08s linear, filter .08s linear, transform .06s linear; }
			a.menu-item:hover, a.menu-item:active { border-color: rgba(98, 255, 108, .74) !important; border-left-color: #7cff85 !important; background: rgba(19, 70, 23, .35) !important; box-shadow: inset 0 0 0 2px rgba(83, 255, 94, .08), inset 0 0 22px rgba(78, 255, 90, .08); }
			a.menu-item:active { transform: translate(2px, 1px); filter: brightness(1.45); }
			a.menu-item.primary { background: #69ef72 !important; color: #001900 !important; border-color: #9cffA3 !important; border-left: 8px solid #9cffa3 !important; box-shadow: 8px 0 0 rgba(72, 255, 84, .11), 0 0 12px rgba(72, 255, 84, .38), inset 0 0 0 2px rgba(0, 65, 7, .26); }
			a.menu-item.primary:after { content: ''; position: absolute; right: -10%; top: 0; width: 48%; height: 100%; pointer-events: none; background: repeating-linear-gradient(0deg, rgba(0, 30, 2, .18) 0, rgba(0, 30, 2, .18) 1px, transparent 2px, transparent 4px); transform: skewX(-16deg); opacity: .55; }
			a.menu-item.ready-inactive { opacity: .56; background: #000 !important; color: #65e96e !important; border-color: rgba(79, 194, 87, .34) !important; border-left-color: rgba(101, 233, 110, .58) !important; }
			a.menu-item.ready-active, a.menu-item.join-active { opacity: 1; }
			.menu-icon { width: 66px; min-width: 66px; height: 62px; display: flex; align-items: center; justify-content: center; margin-right: 16px; position: relative; z-index: 2; color: currentColor; }
			.menu-icon svg { width: 46px; height: 46px; fill: none; stroke: currentColor; stroke-width: 4; stroke-linecap: square; stroke-linejoin: miter; shape-rendering: crispEdges; filter: drop-shadow(0 0 4px rgba(79, 255, 91, .65)); }
			.menu-icon svg.filled-icon { fill: currentColor; stroke: none; }
			.menu-icon svg .icon-fill { fill: currentColor; stroke: none; }
			.menu-copy { position: relative; z-index: 2; display: block; min-width: 0; }
			.menu-title { display: block; font-size: 22px; line-height: 25px; letter-spacing: 2px; font-weight: normal; white-space: nowrap; text-shadow: 2px 0 0 rgba(60, 178, 69, .28); }
			.menu-subtitle { display: block; margin-top: 3px; font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 15px; line-height: 17px; letter-spacing: .5px; white-space: nowrap; }
			.dossier { flex: 1 1 auto; min-width: 0; border: 2px solid #50ef5b; background-color: #000 !important; background-image: repeating-linear-gradient(0deg, rgba(54, 255, 67, .018) 0, rgba(54, 255, 67, .018) 1px, transparent 1px, transparent 4px), repeating-linear-gradient(90deg, rgba(54, 255, 67, .018) 0, rgba(54, 255, 67, .018) 1px, transparent 1px, transparent 6px) !important; position: relative; display: flex; flex-direction: column; box-shadow: inset 0 0 0 3px #000, inset 0 0 0 4px rgba(80, 239, 91, .28), 0 0 8px rgba(44, 255, 57, .12); }
			.dossier:before, .dossier:after { content: ''; position: absolute; width: 14px; height: 14px; border-color: #79ff82; pointer-events: none; }
			.dossier:before { left: 5px; top: 5px; border-left: 2px solid; border-top: 2px solid; }
			.dossier:after { right: 5px; bottom: 5px; border-right: 2px solid; border-bottom: 2px solid; }
			.dossier-title { flex: 0 0 47px; min-height: 47px; border-bottom: 1px solid #50ef5b; display: flex; align-items: center; justify-content: center; font-size: 22px; letter-spacing: 5px; font-weight: normal; white-space: nowrap; text-shadow: 2px 0 0 rgba(89, 255, 99, .35); }
			.dossier-title:before, .dossier-title:after { content: '---'; margin: 0 26px; letter-spacing: 7px; }
			.dossier-content { flex: 1 1 auto; min-height: 0; display: flex; flex-direction: column; }
			.dossier-auth { display: none; position: absolute; z-index: 6; left: 12px; right: 12px; top: 61px; bottom: 12px; align-items: center; justify-content: center; flex-direction: column; border: 1px dashed rgba(87, 235, 97, .42); background: rgba(0, 9, 1, .94); font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 15px; line-height: 25px; letter-spacing: 2px; text-align: left; }
			.dossier-auth-line { width: 80%; opacity: 0; }
			.dossier-auth-line:before { content: '> '; color: #42ba4b; }
			.dossier-auth-line.granted { color: #b7ffbc; }
			.crt-shell.booting .dossier-auth { display: flex; animation: auth-panel-life 1.06s linear 1.80s both; }
			.crt-shell.booting .dossier-auth-line:nth-child(1) { animation: auth-line-reveal .25s steps(2, end) 1.92s both; }
			.crt-shell.booting .dossier-auth-line:nth-child(2) { animation: auth-line-reveal .25s steps(2, end) 2.20s both; }
			.crt-shell.booting .dossier-auth-line:nth-child(3) { animation: auth-line-reveal .28s steps(2, end) 2.48s both; }
			.crt-shell.booting .dossier-content { opacity: 0; animation: dossier-data-reveal .28s steps(2, end) 2.82s both; }
			.dossier-main { flex: 1 1 auto; min-height: 0; display: flex; padding: 10px 12px 8px; gap: 14px; }
			.portrait { flex: 0 0 40%; min-width: 150px; border: 1px solid #55f260; position: relative; overflow: hidden; display: flex; align-items: center; justify-content: center; background-color: #000 !important; background-image: radial-gradient(circle at 50% 58%, rgba(80, 255, 91, .16), transparent 57%), repeating-linear-gradient(90deg, rgba(63, 255, 75, .04) 0, rgba(63, 255, 75, .04) 1px, transparent 1px, transparent 5px), repeating-linear-gradient(0deg, rgba(63, 255, 75, .025) 0, rgba(63, 255, 75, .025) 1px, transparent 1px, transparent 5px) !important; box-shadow: inset 0 0 0 4px #000, inset 0 0 0 5px rgba(85, 242, 96, .25); }
			.character-sprite { position: absolute; z-index: 2; left: 50%; top: 76%; display: block; width: 420px; height: 420px; max-width: none; max-height: none; object-fit: contain; transform: translate(-50%, -50%); image-rendering: pixelated; image-rendering: crisp-edges; filter: hue-rotate([interface_hue_inverse]deg) drop-shadow(0 5px 5px rgba(0, 0, 0, .82)); }
			.character-sprite.character-highlight { filter: grayscale(1) sepia(1) saturate(5) hue-rotate(66deg) brightness(.92) contrast(1.2) drop-shadow(0 0 8px rgba(72, 255, 83, .45)); }
			.character-fallback { position: relative; z-index: 2; font-size: 12px; letter-spacing: 2px; }
			.dossier-data { flex: 1 1 auto; min-width: 0; padding: 3px 0; display: flex; flex-direction: column; justify-content: center; }
			.dossier-name { margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px dashed rgba(84, 244, 94, .38); color: #86ff8d; font-size: 16px; line-height: 20px; letter-spacing: 1px; text-transform: uppercase; word-break: break-word; }
			.data-row { display: flex; align-items: flex-start; font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 14px; line-height: 16px; margin: 2px 0; min-width: 0; text-transform: uppercase; }
			.data-label { flex: 0 0 47%; color: #62df69; white-space: nowrap; }
			.data-separator { flex: 0 0 13px; color: #43c94d; }
			.data-value { flex: 1 1 auto; min-width: 0; color: #83ff8a; overflow-wrap: break-word; }
			.dossier-footer { flex: 0 0 60px; min-height: 60px; border-top: 1px solid #50ef5b; display: flex; align-items: center; padding: 7px 14px; background: #000; }
			.footer-globe { width: 48px; height: 48px; border: 1px solid #65f86f; border-radius: 50%; position: relative; margin-right: 16px; box-shadow: 0 0 8px rgba(73, 255, 84, .22); }
			.footer-globe:before { content: ''; position: absolute; left: 8px; right: 8px; top: -1px; bottom: -1px; border-left: 1px solid #65f86f; border-right: 1px solid #65f86f; border-radius: 50%; }
			.footer-globe:after { content: ''; position: absolute; left: -1px; right: -1px; top: 22px; border-top: 1px solid #65f86f; }
			.footer-copy { font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 13px; line-height: 15px; letter-spacing: 1px; }
			.footer-bars { margin-left: auto; width: 34%; height: 34px; opacity: .72; background: repeating-linear-gradient(90deg, #59e963 0, #59e963 1px, transparent 1px, transparent 3px, #59e963 3px, #59e963 5px, transparent 5px, transparent 8px); }
			.mission { flex: 1 1 auto; min-height: 205px; border-top: 2px solid #53ee5e; position: relative; padding-top: 8px; display: flex; flex-direction: column; background: #000; box-shadow: inset 0 3px 0 #000, inset 0 4px 0 rgba(83, 238, 94, .24); }
			.mission-heading { flex: 0 0 42px; min-height: 42px; display: flex; align-items: center; font-size: 18px; line-height: 22px; letter-spacing: 1px; font-weight: normal; }
			.mission-label { flex: 0 0 auto; display: flex; align-items: center; white-space: nowrap; }
			.mission-diags { margin-left: 15px; color: #5af365; letter-spacing: 2px; font-size: 21px; transform: skewX(-15deg); }
			.mission-rule { flex: 1 1 auto; min-width: 40px; margin-left: 10px; height: 2px; background: repeating-linear-gradient(90deg, rgba(87, 244, 98, .9) 0, rgba(87, 244, 98, .9) 30px, transparent 30px, transparent 48px); }
			.mission-dots { margin-left: 12px; letter-spacing: 7px; }
			.mission-body { flex: 1 1 auto; min-width: 0; min-height: 0; overflow-x: hidden; overflow-y: auto; padding: 12px 10px 14px; color: #72ee7a !important; background: #000 !important; font-family: 'Pix Cyrillic', 'Lucida Console', monospace; font-size: 17px; line-height: 23px; letter-spacing: .7px; white-space: normal; scrollbar-color: #4ee45a #061507; }
			.mission-text { display: block; width: 100%; max-width: 100%; white-space: pre-wrap; word-wrap: break-word; overflow-wrap: break-word; word-break: break-all; }
			.mission-text.typing { white-space: pre-wrap; }
			.mission-text.typing:after { content: '\\2588'; display: inline-block; margin-left: 2px; animation: cursor-blink .55s steps(1, end) infinite; }
			.mission-text.typed:after { content: '\\2588'; display: inline-block; margin-left: 2px; animation: cursor-finish 1.15s steps(1, end) both; }
			.mission-typewriter-source { display: none; }
			.terminal-cursor { animation: cursor-blink 1s steps(1, end) infinite; }
			@media (max-width: 760px) {
				.terminal { padding: 12px 14px 10px; gap: 9px; }
				.brand { flex-basis: 92px; min-height: 92px; }
				.brand-line { gap: 11px; }
				.brand-rule { font-size: 17px; letter-spacing: 6px; }
				.brand-mark { width: 40px; height: 48px; }
				.brand-main { gap: 10px; }
				.brand-title { font-size: 20px; line-height: 24px; letter-spacing: 2px; }
				.brand-subtitle { font-size: 11px; line-height: 15px; letter-spacing: 4px; }
				.system-status { font-size: 7px; line-height: 9px; letter-spacing: 1px; }
				.main-grid { flex-basis: 340px; min-height: 340px; gap: 0; }
				.menu { flex-basis: 43%; width: 43%; min-width: 260px; padding-right: 6px; gap: 4px; }
				.main-divider { flex-basis: 14px; min-width: 14px; }
				a.menu-item { padding: 5px 8px !important; }
				.menu-icon { width: 46px; min-width: 46px; height: 46px; margin-right: 8px; }
				.menu-icon svg { width: 35px; height: 35px; }
				.menu-title { font-size: 14px; line-height: 18px; letter-spacing: 1px; }
				.menu-subtitle { font-size: 9px; line-height: 12px; }
				.dossier-title { flex-basis: 36px; min-height: 36px; font-size: 14px; letter-spacing: 2px; }
				.dossier-title:before, .dossier-title:after { margin: 0 8px; letter-spacing: 3px; }
				.dossier-auth { top: 48px; font-size: 10px; line-height: 18px; letter-spacing: 1px; }
				.dossier-main { padding: 6px; gap: 7px; }
				.portrait { min-width: 104px; }
				.character-sprite { width: 295px; height: 295px; top: 75%; }
				.dossier-name { font-size: 11px; line-height: 14px; }
				.data-row { font-size: 8px; line-height: 11px; margin: 1px 0; }
				.data-label { flex-basis: 45%; }
				.dossier-footer { flex-basis: 43px; min-height: 43px; padding: 4px 8px; }
				.footer-globe { width: 32px; height: 32px; margin-right: 8px; }
				.footer-globe:after { top: 14px; }
				.footer-copy { font-size: 8px; line-height: 10px; }
				.mission { min-height: 170px; }
				.mission-heading { flex-basis: 32px; min-height: 32px; font-size: 15px; }
				.mission-body { font-size: 11px; line-height: 17px; }
			}
		</style>
		<div class='crt-shell[lobby_intro_class][text_override_class][effect_class]' style='filter: hue-rotate([interface_hue_rotation]deg);[text_override_style]'>
			<div class='crt-speckle'></div>
			<div class='signal-interference'></div>
			<div class='crt-frame'></div>
			<div class='boot-flare'></div>
			<div class='terminal'>
				<div class='brand'>
					<div class='brand-line'>
						<div class='brand-rule'>-----</div>
						<div class='brand-main'><div class='brand-mark'>[brand_icon]</div><div class='brand-title'>ТЕРМИНАЛ ПЕРСОНАЛА</div></div>
						<div class='brand-rule'>-----</div>
					</div>
					<div class='system-status'>&#9679; СИСТЕМА АКТИВНА</div>
				</div>
				<div class='main-grid'>
					<div class='menu'>
						<a class='menu-item primary [primary_state_class]' href='byond://?src=[source_ref];lobby_choice=[primary_choice]'><span class='menu-icon'>[primary_icon]</span><span class='menu-copy'><span class='menu-title'>[primary_title]</span><span class='menu-subtitle'>[primary_subtitle]</span></span></a>
						<a class='menu-item' href='byond://?src=[source_ref];lobby_choice=show_preferences'><span class='menu-icon'>[character_icon]</span><span class='menu-copy'><span class='menu-title'>ПЕРСОНАЖ</span><span class='menu-subtitle'>Настройка персонажа</span></span></a>
						<a class='menu-item' href='byond://?src=[source_ref];lobby_choice=manifest'><span class='menu-icon'>[manifest_icon]</span><span class='menu-copy'><span class='menu-title'>МАНИФЕСТ</span><span class='menu-subtitle'>Список текущего экипажа</span></span></a>
						<a class='menu-item' href='byond://?src=[source_ref];lobby_choice=observe'><span class='menu-icon'>[observe_icon]</span><span class='menu-copy'><span class='menu-title'>НАБЛЮДАТЬ</span><span class='menu-subtitle'>Войти как наблюдатель</span></span></a>
					</div>
					<div class='main-divider'></div>
					<div class='dossier'>
						<div class='dossier-title'>ЛИЧНОЕ ДЕЛО</div>
						<div class='dossier-auth'><div class='dossier-auth-line'>ПОИСК ЗАПИСИ...</div><div class='dossier-auth-line'>ИДЕНТИФИКАЦИЯ...</div><div class='dossier-auth-line granted'>ДОСТУП РАЗРЕШЁН</div></div>
						<div class='dossier-content'>
						<div class='dossier-main'>
							<div class='portrait'>[character_image]</div>
							<div class='dossier-data'>
								<div class='dossier-name'>[character_name]</div>
								<div class='data-row'><span class='data-label'>ВОЗРАСТ</span><span class='data-separator'>:</span><span class='data-value'>[character_age]</span></div>
								<div class='data-row'><span class='data-label'>ПОЛ</span><span class='data-separator'>:</span><span class='data-value'>[character_gender]</span></div>
								<div class='data-row'><span class='data-label'>ВИД</span><span class='data-separator'>:</span><span class='data-value'>[character_species]</span></div>
								<div class='data-row'><span class='data-label'>КОМПЛЕКЦИЯ</span><span class='data-separator'>:</span><span class='data-value'>[character_body_size]</span></div>
								<div class='data-row'><span class='data-label'>ТЕЛОСЛОЖЕНИЕ</span><span class='data-separator'>:</span><span class='data-value'>[character_body_type]</span></div>
								<div class='data-row'><span class='data-label'>ПРОИСХОЖДЕНИЕ</span><span class='data-separator'>:</span><span class='data-value'>[character_origin]</span></div>
								<div class='data-row'><span class='data-label'>ОТРЯД</span><span class='data-separator'>:</span><span class='data-value'>[character_squad]</span></div>
								<div class='data-row'><span class='data-label'>ОТНОШЕНИЕ К WY</span><span class='data-separator'>:</span><span class='data-value'>[character_wy_relation]</span></div>
								<div class='data-row'><span class='data-label'>ДОЛЖНОСТЬ</span><span class='data-separator'>:</span><span class='data-value'>[character_job]</span></div>
							</div>
						</div>
						<div class='dossier-footer'><div class='footer-globe'></div><div class='footer-copy'>АРХИВ ПЕРСОНАЛА<br>ЛИЧНОСТЬ ПОДТВЕРЖДЕНА</div><div class='footer-bars'></div></div>
						</div>
					</div>
				</div>
				<div class='mission'>
					<div class='mission-heading'><span class='mission-label'><span>ДЕТАЛИ МИССИИ</span><span class='mission-diags'>///</span></span><span class='mission-rule'></span><span class='mission-dots'>...</span></div>
					<div class='mission-body'><span id='missionText' class='mission-text[mission_typing_class]'>[mission_details]</span>[mission_typewriter_source]</div>
				</div>
			</div>
		</div>
		<script>
			(function() {
				var source = document.getElementById('missionTypewriterSource');
				var output = document.getElementById('missionText');
				if (!source || !output) return;
				var text = source.value || '';
				var position = 0;
				var timer = window.setInterval(function() {
					position = Math.min(position + 4, text.length);
					output.textContent = text.substring(0, position);
					if (position >= text.length) {
						window.clearInterval(timer);
						output.className = 'mission-text typed';
					}
				}, 16);
			})();
		</script>
	"}

	if(refresh)
		close_browser(src, "lobbybrowser")
	winset(client, "mapwindow.lobbybrowser", "is-visible=true")
	show_browser(src, html, null, "lobbybrowser", "can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0", existing_container = "mapwindow")
