/datum/preferences/proc/show_banda_manifest(mob/user, manifest_html)
	if(!uses_banda_terminal_interface() || !istext(manifest_html))
		return FALSE

	var/html = get_banda_auxiliary_window_header("МАНИФЕСТ ПЕРСОНАЛА", "ТЕКУЩИЙ СОСТАВ ЭКИПАЖА", "banda-manifest-window")
	html += "<div class='banda-manifest-data'>[manifest_html]</div>"
	html += {"
		<style>
			@keyframes banda-manifest-row-reveal { 0% { opacity: 0; transform: translateY(-5px); filter: brightness(1.6); } 100% { opacity: 1; transform: translateY(0); filter: brightness(1); } }
			.banda-manifest-window .banda-aux-content { padding: 5px 12px 18px; }
			.banda-manifest-window .banda-manifest-data > div { width: 100%; }
			.banda-manifest-window table.manifest { width: 100%; border-collapse: separate !important; border-spacing: 0 4px !important; color: #8bea92 !important; }
			.banda-manifest-window table.manifest th { height: auto !important; padding: 8px 10px !important; border: 1px solid #3bc746 !important; background: rgba(7, 52, 11, .94) !important; color: #91ff98 !important; font-size: 13px; line-height: 18px; letter-spacing: 1px; text-transform: uppercase; text-align: center; box-shadow: inset 0 0 14px rgba(69, 255, 82, .08); }
			.banda-manifest-window table.manifest tr.head th { border-color: #78ef80 !important; background: rgba(20, 91, 27, .94) !important; color: #c5ffc9 !important; letter-spacing: 2px; }
			.banda-manifest-window table.manifest td { padding: 7px 10px !important; border: 1px solid rgba(48, 156, 57, .46) !important; background: rgba(2, 25, 5, .88) !important; color: #8bea92 !important; font-size: 12px; line-height: 17px; }
			.banda-manifest-window table.manifest tr.alt td { background: rgba(7, 44, 11, .9) !important; }
			.banda-manifest-window table.manifest td:first-child { width: 38%; text-align: left !important; color: #b0ffb5 !important; }
			.banda-manifest-window table.manifest td:nth-child(2) { width: 42%; }
			.banda-manifest-window table.manifest td:nth-child(3) { width: 20%; text-align: center; }
			.banda-manifest-window table.manifest tr.manifest-row-loading { opacity: 0; animation: banda-manifest-row-reveal .18s ease-out both; }
			.banda-aux-crt.banda-effects-off.banda-manifest-window table.manifest tr.manifest-row-loading { opacity: 1; animation: none !important; }
			@media (max-width: 600px) {
				.banda-manifest-window .banda-aux-content { padding: 3px 2px 10px; }
				.banda-manifest-window table.manifest th, .banda-manifest-window table.manifest td { padding: 5px 4px !important; font-size: 10px; line-height: 14px; }
			}
		</style>
	"}
	html += {"
		<script>
			(function() {
				var rows = document.querySelectorAll('table.manifest tr');
				for (var index = 0; index < rows.length; index++) {
					var row = rows.item(index);
					row.className += ' manifest-row-loading';
					row.style.animationDelay = Math.min(index * 35, 1200) + 'ms';
				}
			})();
		</script>
	"}
	html += get_banda_auxiliary_window_footer()
	show_browser(user, html, "Манифест персонала", "manifest", width = 760, height = 750)
	return TRUE
