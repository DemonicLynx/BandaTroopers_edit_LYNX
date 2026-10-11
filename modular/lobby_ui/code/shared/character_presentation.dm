/proc/get_banda_character_preferences_styles(interface_hue_inverse = 0)
	return {"
		<style>
			* { box-sizing: border-box; }
			html, body { width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden; }
			body { background: #000500; color: #69ff72; font-family: Consolas, 'Lucida Console', 'Courier New', monospace; }
			a, a:link, a:visited { color: #7dff85; text-decoration: none; }
			a:hover, a:active { color: #d0ffd3; text-shadow: 0 0 7px rgba(95, 255, 106, .95); }
			@keyframes prefs-crt-roll { 0% { top: -22%; } 100% { top: 112%; } }
			@keyframes prefs-crt-flicker { 0%, 19%, 23%, 63%, 67%, 100% { opacity: .99; } 21%, 65% { opacity: .93; } }
			@keyframes prefs-noise-shift { 0%, 100% { transform: translate(0, 0); opacity: .15; } 50% { transform: translate(1px, -1px); opacity: .22; } }
			@keyframes prefs-tab-glitch { 0% { opacity: .45; transform: translateX(-5px); filter: brightness(1.65); } 28% { opacity: .9; transform: translateX(4px) skewX(-1deg); text-shadow: -3px 0 rgba(126, 255, 136, .42), 3px 0 rgba(18, 122, 29, .55); } 57% { transform: translateX(-2px) skewX(.5deg); } 100% { opacity: 1; transform: translateX(0); filter: brightness(1); text-shadow: none; } }
			.prefs-crt { position: relative; width: 100%; height: 100%; min-width: 760px; min-height: 560px; overflow: hidden; background: radial-gradient(ellipse at 50% 35%, rgba(14, 70, 18, .22), rgba(0, 5, 0, .96) 72%), #000500; animation: prefs-crt-flicker 8s infinite; }
			.prefs-crt:before { content: ''; position: absolute; z-index: 40; inset: 0; pointer-events: none; background: repeating-linear-gradient(0deg, rgba(0, 0, 0, .22) 0, rgba(0, 0, 0, .22) 1px, rgba(60, 255, 73, .035) 2px, transparent 4px), radial-gradient(ellipse at center, transparent 52%, rgba(0, 0, 0, .68) 100%); }
			.prefs-crt:after { content: ''; position: absolute; z-index: 41; left: 0; right: 0; top: -22%; height: 17%; pointer-events: none; background: linear-gradient(180deg, transparent, rgba(80, 255, 91, .04), rgba(178, 255, 184, .11), rgba(35, 255, 48, .035), transparent); animation: prefs-crt-roll 9s linear infinite; }
			.prefs-crt-speckle { position: absolute; z-index: 39; inset: 0; pointer-events: none; background-image: radial-gradient(circle at 11% 8%, #6aff74 0, #6aff74 1px, transparent 2px), radial-gradient(circle at 69% 15%, #6aff74 0, #6aff74 1px, transparent 2px), radial-gradient(circle at 91% 38%, #6aff74 0, #6aff74 1px, transparent 2px), radial-gradient(circle at 27% 84%, #6aff74 0, #6aff74 1px, transparent 2px); animation: prefs-noise-shift .28s steps(2, end) infinite; }
			.prefs-crt-frame { position: absolute; z-index: 38; inset: 4px; pointer-events: none; border: 1px solid rgba(91, 255, 101, .32); box-shadow: inset 0 0 28px rgba(29, 255, 44, .08); }
			.prefs-terminal { position: relative; z-index: 5; width: 100%; height: 100%; padding: 16px 20px 18px; display: flex; flex-direction: column; gap: 10px; }
			.prefs-crt.banda-text-override .prefs-terminal, .prefs-crt.banda-text-override .prefs-terminal *, .prefs-crt.banda-text-override .prefs-terminal *:before, .prefs-crt.banda-text-override .prefs-terminal *:after { color: var(--banda-text-color) !important; }
			.prefs-crt.banda-text-override a.prefs-tab.active, .prefs-crt.banda-text-override a.prefs-tab.active *, .prefs-crt.banda-text-override a.prefs-back-button:hover, .prefs-crt.banda-text-override a.prefs-back-button:hover * { color: #001700 !important; }
			.prefs-header { flex: 0 0 auto; min-height: 70px; display: flex; align-items: center; border-bottom: 1px dashed rgba(92, 255, 102, .68); padding: 3px 4px 10px; }
			.prefs-brand { flex: 1 1 auto; min-width: 0; text-transform: uppercase; }
			.prefs-brand-title { color: #83ff8a; font-size: 26px; line-height: 31px; letter-spacing: 5px; font-weight: 700; text-shadow: 0 0 8px rgba(84, 255, 95, .65); white-space: nowrap; }
			.prefs-brand-subtitle { color: #4fe95a; font-size: 12px; line-height: 17px; letter-spacing: 4px; }
			.prefs-slot-tools { flex: 0 0 auto; display: flex; gap: 7px; }
			a.prefs-tool, a.prefs-tool:link, a.prefs-tool:visited { display: block; border: 1px solid #3ccc48; background: rgba(4, 35, 7, .72); color: #79ff82; padding: 8px 11px; font-size: 11px; letter-spacing: 1px; text-transform: uppercase; box-shadow: inset 0 0 12px rgba(54, 255, 69, .06); }
			a.prefs-tool:hover { border-color: #9aff9f; background: rgba(28, 91, 33, .72); }
			.prefs-tabs { flex: 0 0 auto; display: flex; flex-wrap: wrap; gap: 5px; padding-bottom: 1px; }
			a.prefs-tab, a.prefs-tab:link, a.prefs-tab:visited { display: block; flex: 1 1 135px; min-width: 112px; max-width: 205px; border: 1px solid #278d30; border-left: 4px solid #43d84e; background: rgba(0, 18, 2, .72); color: #65e96f; padding: 7px 9px; font-size: 11px; line-height: 14px; letter-spacing: .8px; text-align: center; text-transform: uppercase; white-space: nowrap; }
			a.prefs-tab:hover { border-color: #77ff7f; background: rgba(29, 87, 33, .62); }
			a.prefs-tab.active, a.prefs-tab.active:link, a.prefs-tab.active:visited { color: #001700; background: #68ef72; border-color: #a4ffaa; box-shadow: 0 0 11px rgba(79, 255, 91, .32), inset 0 0 16px rgba(224, 255, 226, .23); text-shadow: none; }
			.prefs-workspace { flex: 1 1 auto; min-height: 0; display: flex; gap: 12px; }
			.prefs-crt.tab-switching .prefs-workspace { transform-origin: 50% 20%; animation: prefs-tab-glitch .16s steps(2, end) both; }
			.prefs-crt.banda-effects-reduced, .prefs-crt.banda-effects-reduced:after, .prefs-crt.banda-effects-reduced .prefs-crt-speckle, .prefs-crt.banda-effects-reduced.tab-switching .prefs-workspace { animation: none; }
			.prefs-crt.banda-effects-off, .prefs-crt.banda-effects-off *, .prefs-crt.banda-effects-off:before, .prefs-crt.banda-effects-off:after, .prefs-crt.banda-effects-off *:before, .prefs-crt.banda-effects-off *:after { animation: none !important; transition: none !important; }
			.prefs-crt.banda-effects-off .prefs-crt-speckle { display: none; }
			.prefs-workspace.full { min-height: 0; overflow: hidden; }
			.prefs-workspace.full .prefs-content { width: 100%; height: calc(100vh - 175px); max-height: calc(100vh - 175px); overflow-x: hidden; overflow-y: scroll; }
			.prefs-workspace.human { align-items: flex-start; }
			.prefs-workspace.human .prefs-preview-panel { height: 50%; min-height: 390px; max-height: 50%; }
			.prefs-workspace.human .prefs-content { align-self: stretch; height: 100%; }
			.prefs-preview-panel { flex: 0 0 33%; min-width: 280px; position: relative; border: 1px solid #48df53; background: rgba(0, 18, 2, .72); overflow: hidden; display: flex; flex-direction: column; box-shadow: inset 0 0 25px rgba(44, 255, 57, .06); }
			.prefs-preview-panel:before { content: ''; position: absolute; left: 7px; top: 7px; width: 16px; height: 16px; border-left: 2px solid #83ff8b; border-top: 2px solid #83ff8b; pointer-events: none; }
			.prefs-preview-panel:after { content: ''; position: absolute; right: 7px; bottom: 7px; width: 16px; height: 16px; border-right: 2px solid #83ff8b; border-bottom: 2px solid #83ff8b; pointer-events: none; }
			.prefs-preview-title { flex: 0 0 auto; min-height: 43px; border-bottom: 1px solid #3bc746; padding: 12px 10px 8px; color: #8cff93; text-align: center; font-size: 14px; letter-spacing: 2px; text-transform: uppercase; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
			.prefs-preview-stage { flex: 1 1 auto; min-height: 0; position: relative; display: flex; align-items: center; justify-content: center; padding: 12px 48px 30px; background: radial-gradient(ellipse at 50% 78%, rgba(83, 255, 94, .17), transparent 45%), repeating-linear-gradient(90deg, rgba(61, 255, 73, .025) 0, rgba(61, 255, 73, .025) 1px, transparent 1px, transparent 5px); }
			.prefs-preview-stage:before { content: ''; position: absolute; z-index: 1; left: 16%; right: 16%; bottom: 18px; height: 22px; border: 1px solid rgba(95, 255, 106, .62); background: radial-gradient(ellipse at center, rgba(111, 255, 121, .34), rgba(18, 94, 25, .19) 52%, rgba(0, 8, 1, .86) 75%); box-shadow: 0 0 8px rgba(74, 255, 86, .62), 0 0 24px rgba(74, 255, 86, .31), inset 0 0 8px rgba(144, 255, 151, .38); transform: perspective(60px) rotateX(48deg); }
			.prefs-preview-stage:after { content: ''; position: absolute; z-index: 0; left: 23%; right: 23%; bottom: 19px; height: 58%; background: linear-gradient(180deg, transparent, rgba(75, 255, 87, .10)); clip-path: polygon(34% 0, 66% 0, 100% 100%, 0 100%); pointer-events: none; }
			.prefs-character-sprite { position: relative; z-index: 2; display: block; width: 310px; height: 310px; max-width: 94%; max-height: 94%; object-fit: contain; image-rendering: pixelated; image-rendering: crisp-edges; filter: hue-rotate([interface_hue_inverse]deg) drop-shadow(0 8px 4px rgba(0, 0, 0, .78)) drop-shadow(0 0 7px rgba(72, 255, 83, .38)); }
			.prefs-preview-fallback { color: #53c95c; font-size: 11px; letter-spacing: 2px; }
			a.prefs-preview-arrow, a.prefs-preview-arrow:link, a.prefs-preview-arrow:visited { position: absolute; z-index: 4; top: 50%; width: 42px; height: 58px; margin-top: -29px; border: 1px solid #4bea57; background: rgba(0, 22, 2, .86); color: #83ff8b; font-size: 37px; line-height: 52px; text-align: center; box-shadow: 0 0 9px rgba(70, 255, 82, .22), inset 0 0 12px rgba(70, 255, 82, .08); }
			a.prefs-preview-arrow:hover { background: rgba(44, 130, 50, .72); border-color: #b0ffb5; }
			.prefs-preview-arrow.left { left: 10px; }
			.prefs-preview-arrow.right { right: 10px; }
			.prefs-preview-caption { flex: 0 0 auto; min-height: 35px; border-top: 1px dashed rgba(68, 218, 78, .55); padding: 9px 8px 7px; color: #4ee65a; font-size: 10px; letter-spacing: 2px; text-align: center; text-transform: uppercase; }
			.prefs-content { flex: 1 1 auto; min-width: 0; min-height: 0; position: relative; overflow-y: auto; padding: 17px 16px 76px; border: 1px solid #48df53; background: rgba(0, 13, 2, .78); color: #91ee97; font-size: 12px; line-height: 18px; scrollbar-color: #4ee45a #061507; }
			.prefs-content h1, .prefs-content h2 { margin: 0 0 9px; padding: 5px 7px; border-bottom: 1px dashed rgba(75, 224, 85, .46); color: #83ff8b; font-size: 15px; line-height: 20px; letter-spacing: 1px; text-transform: uppercase; text-decoration: none; }
			.prefs-content h1 { font-size: 17px; }
			.prefs-content h1 u, .prefs-content h2 u { text-decoration: none; }
			.prefs-content a, .prefs-content a:link, .prefs-content a:visited { display: inline-block; margin: 1px 0; padding: 1px 5px; border: 1px solid rgba(55, 184, 65, .64); background: rgba(9, 51, 13, .64); color: #8cff93; }
			.prefs-content a:hover { border-color: #a7ffac; background: rgba(37, 112, 43, .72); }
			.prefs-content #column1, .prefs-content #column2, .prefs-content #column3 { width: 32%; min-width: 185px; float: left; margin-right: 1.3%; padding: 0 9px 12px; }
			.prefs-content #column3 { margin-right: 0; }
			.prefs-content .square { width: 14px; height: 14px; display: inline-block; border: 1px solid #63dd6c; vertical-align: middle; }
			.prefs-content:after { content: ''; display: table; clear: both; }
			a.prefs-back-button, a.prefs-back-button:link, a.prefs-back-button:visited { position: absolute; z-index: 25; right: 35px; bottom: 28px; display: block; min-width: 190px; padding: 11px 18px; border: 1px solid #85ff8d; border-left: 5px solid #85ff8d; background: rgba(11, 58, 15, .94); color: #a1ffa7; box-shadow: 0 0 13px rgba(71, 255, 83, .3), inset 0 0 18px rgba(71, 255, 83, .1); font-size: 13px; line-height: 18px; letter-spacing: 2px; text-align: center; }
			a.prefs-back-button:hover { background: rgba(68, 210, 78, .88); color: #001b02; border-color: #c5ffc9; text-shadow: none; }
			a.prefs-tool:active, a.prefs-tab:active, a.prefs-preview-arrow:active, .prefs-content a:active, a.prefs-back-button:active { transform: translate(1px, 1px); filter: brightness(1.45); }
			.linkOff { pointer-events: none; }
			@media (max-width: 840px) {
				.prefs-terminal { padding: 10px 12px 12px; gap: 7px; }
				.prefs-header { min-height: 57px; }
				.prefs-brand-title { font-size: 20px; line-height: 24px; letter-spacing: 3px; }
				.prefs-brand-subtitle { font-size: 9px; line-height: 13px; letter-spacing: 2px; }
				a.prefs-tool { padding: 6px 7px; font-size: 9px; }
				a.prefs-tab { flex-basis: 108px; min-width: 95px; padding: 5px 6px; font-size: 9px; }
				.prefs-preview-panel { flex-basis: 31%; min-width: 225px; }
				.prefs-preview-stage { padding: 16px 40px 39px; }
				.prefs-character-sprite { width: 245px; height: 245px; }
				.prefs-content { padding: 13px 10px 68px; font-size: 10px; line-height: 15px; }
				.prefs-content #column1, .prefs-content #column2, .prefs-content #column3 { min-width: 155px; padding: 0 5px 10px; }
				a.prefs-back-button { right: 24px; bottom: 20px; min-width: 165px; padding: 8px 12px; font-size: 11px; }
			}
		</style>
		[get_banda_character_preferences_translation_script()]
	"}

/proc/get_banda_auxiliary_preferences_styles()
	return {"
		<style>
			* { box-sizing: border-box; }
			html, body { width: 100%; min-height: 100%; margin: 0; padding: 0; }
			body { overflow-x: hidden; overflow-y: auto; background: #000500; color: #79ed81; font-family: 'Grand9K Pixel', 'Pix Cyrillic', Consolas, 'Lucida Console', monospace; scrollbar-color: #3dbb47 #061207; }
			@keyframes banda-aux-flicker { 0%, 18%, 22%, 63%, 67%, 100% { opacity: .995; } 20%, 65% { opacity: .94; } }
			.banda-aux-crt { position: relative; min-height: 100vh; padding: 14px; overflow: hidden; background: radial-gradient(ellipse at 50% 30%, rgba(18, 82, 24, .24), rgba(0, 5, 0, .98) 72%), #000500; animation: banda-aux-flicker 8s infinite; }
			.banda-aux-crt.banda-effects-reduced { animation: none; }
			.banda-aux-crt.banda-effects-off, .banda-aux-crt.banda-effects-off *, .banda-aux-crt.banda-effects-off:before, .banda-aux-crt.banda-effects-off:after, .banda-aux-crt.banda-effects-off *:before, .banda-aux-crt.banda-effects-off *:after { animation: none !important; transition: none !important; }
			.banda-aux-crt.banda-text-override .banda-aux-frame, .banda-aux-crt.banda-text-override .banda-aux-frame *, .banda-aux-crt.banda-text-override .banda-aux-frame *:before, .banda-aux-crt.banda-text-override .banda-aux-frame *:after { color: var(--banda-text-color) !important; }
			.banda-aux-crt:before { content: ''; position: fixed; z-index: 30; inset: 0; pointer-events: none; background: repeating-linear-gradient(0deg, rgba(0, 0, 0, .22) 0, rgba(0, 0, 0, .22) 1px, rgba(61, 255, 74, .035) 2px, transparent 4px), radial-gradient(ellipse at center, transparent 48%, rgba(0, 0, 0, .62) 100%); }
			.banda-aux-frame { position: relative; z-index: 2; min-height: calc(100vh - 28px); padding: 13px; border: 1px solid #39bd44; background: rgba(0, 12, 2, .78); box-shadow: inset 0 0 30px rgba(49, 255, 62, .06), 0 0 12px rgba(49, 255, 62, .12); }
			.banda-aux-frame:before, .banda-aux-frame:after { content: ''; position: absolute; width: 18px; height: 18px; pointer-events: none; }
			.banda-aux-frame:before { left: 7px; top: 7px; border-left: 2px solid #8aff92; border-top: 2px solid #8aff92; }
			.banda-aux-frame:after { right: 7px; bottom: 7px; border-right: 2px solid #8aff92; border-bottom: 2px solid #8aff92; }
			.banda-aux-header { margin: 0 10px 12px; padding: 7px 12px 11px; border-bottom: 1px dashed rgba(88, 234, 98, .62); text-align: center; text-transform: uppercase; }
			.banda-aux-brand { color: #4dcc58; font-size: 10px; letter-spacing: 5px; }
			.banda-aux-title { margin-top: 5px; color: #91ff98; font-size: 22px; line-height: 28px; letter-spacing: 4px; text-shadow: 0 0 8px rgba(85, 255, 96, .58); }
			.banda-aux-subtitle { margin-top: 4px; color: #53c85d; font-size: 9px; line-height: 14px; letter-spacing: 2px; }
			.banda-aux-content { position: relative; padding: 4px 8px 10px; color: #8bea92; font-family: Consolas, 'Lucida Console', monospace; font-size: 12px; line-height: 17px; }
			.banda-aux-content table { color: #8bea92 !important; border-collapse: separate; border-spacing: 4px; }
			.banda-aux-content table table { border: 1px solid rgba(54, 172, 64, .48); background: rgba(0, 22, 3, .72); }
			.banda-aux-content tr { background: rgba(4, 35, 7, .72) !important; }
			.banda-aux-content tr:nth-child(even) { background: rgba(8, 48, 12, .72) !important; }
			.banda-aux-content td { padding: 5px 6px; color: #8bea92 !important; border-bottom: 1px solid rgba(50, 149, 58, .28); }
			.banda-aux-content del { color: #487d4d; }
			.banda-aux-content a, .banda-aux-content a:link, .banda-aux-content a:visited { display: inline-block; margin: 1px; padding: 3px 6px; border: 1px solid rgba(63, 191, 73, .66); background: rgba(7, 47, 11, .82); color: #91ff98; text-decoration: none; box-shadow: inset 0 0 10px rgba(56, 255, 69, .05); transition: border-color .08s linear, background-color .08s linear, filter .08s linear, transform .06s linear; }
			.banda-aux-content a:hover, .banda-aux-content a:active { border-color: #b2ffb7; background: rgba(44, 123, 50, .86); color: #d5ffd8; text-shadow: 0 0 6px rgba(101, 255, 111, .9); }
			.banda-aux-content a:active { transform: translate(1px, 1px); filter: brightness(1.4); }
			.banda-aux-content a.inactive { border-color: rgba(52, 102, 57, .46); background: rgba(4, 20, 6, .8); color: #426f46; }
			.banda-aux-content a.red { border-color: #c65757; color: #ff8a8a; }
			.banda-aux-content a.purple { border-color: #a16ac8; color: #d7a1ff; }
			.banda-aux-content a.blue { border-color: #5c89cf; color: #9fc3ff; }
			.banda-aux-content a.green { border-color: #57c964; color: #9cffaa; }
			.banda-aux-content a.orange { border-color: #c99a50; color: #ffd08a; }
			.banda-job-window .banda-aux-content { font-size: 15px; line-height: 22px; }
			.banda-job-window .banda-aux-content td { padding: 8px 9px; }
			.banda-job-window .banda-aux-content a, .banda-job-window .banda-aux-content a:link, .banda-job-window .banda-aux-content a:visited { padding: 5px 8px; font-size: 13px; line-height: 18px; }
			.banda-aux-actions { margin: 2px 0 10px; text-align: center; }
			.banda-aux-actions a { min-width: 170px; padding: 7px 15px; border-left-width: 4px; letter-spacing: 2px; text-transform: uppercase; }
			.banda-aux-note { margin: 8px auto; padding: 7px 10px; max-width: 760px; border-left: 3px solid #45c650; background: rgba(8, 48, 12, .62); color: #68d971; text-align: center; }
			.banda-record-grid { display: flex; flex-wrap: wrap; gap: 10px; align-items: stretch; justify-content: center; }
			.banda-record-card { flex: 1 1 205px; min-width: 190px; min-height: 160px; padding: 12px; border: 1px solid #359d3e; background: rgba(2, 27, 5, .82); box-shadow: inset 0 0 18px rgba(52, 255, 66, .045); }
			.banda-record-index { color: #45b84f; font-size: 9px; letter-spacing: 2px; }
			.banda-record-card a { display: block; margin: 7px 0 10px; padding: 8px; text-align: center; letter-spacing: 1px; text-transform: uppercase; }
			.banda-record-preview { min-height: 68px; padding: 9px; overflow-wrap: anywhere; border-top: 1px dashed rgba(69, 185, 77, .48); color: #72cc79; font-family: Consolas, monospace; font-size: 11px; line-height: 16px; }
			@media (max-width: 700px) {
				.banda-aux-crt { padding: 7px; }
				.banda-aux-frame { min-height: calc(100vh - 14px); padding: 8px; }
				.banda-aux-title { font-size: 17px; line-height: 22px; letter-spacing: 2px; }
				.banda-aux-content { padding: 2px; font-size: 10px; line-height: 14px; }
				.banda-aux-content td { padding: 3px; }
				.banda-aux-content a { padding: 2px 4px; }
				.banda-job-window .banda-aux-content { font-size: 12px; line-height: 18px; }
				.banda-job-window .banda-aux-content td { padding: 5px; }
				.banda-job-window .banda-aux-content a { padding: 3px 5px; font-size: 11px; line-height: 15px; }
			}
		</style>
	"}

/datum/preferences/proc/get_banda_auxiliary_window_header(title, subtitle, window_class = "")
	var/interface_hue_rotation = get_banda_terminal_hue_rotation()
	var/text_override_class = get_banda_terminal_text_override_class()
	var/text_override_style = get_banda_terminal_text_override_style()
	var/effect_class = get_banda_terminal_effect_class()
	var/dat = get_banda_auxiliary_preferences_styles()
	dat += "<body onselectstart='return false;'><div class='banda-aux-crt [window_class][text_override_class][effect_class]' style='filter: hue-rotate([interface_hue_rotation]deg);[text_override_style]'><div class='banda-aux-frame'>"
	dat += "<div class='banda-aux-header'><div class='banda-aux-title'>[title]</div><div class='banda-aux-subtitle'>[subtitle]</div></div>"
	dat += "<div class='banda-aux-content'>"
	return dat

/datum/preferences/proc/get_banda_auxiliary_window_footer()
	return "</div></div></div></body>"
