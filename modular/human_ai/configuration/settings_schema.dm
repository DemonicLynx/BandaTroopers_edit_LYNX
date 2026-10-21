/// Metadata is also the UI contract. Unknown keys and out-of-range values are rejected.
/proc/human_ai_settings_schema()
	var/static/list/schema = list(
		"stealth_enabled" = list("label" = "Стелс для ИИ", "section" = "Бой", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"reaction" = list("label" = "Реакция, секунд", "section" = "Бой", "min" = 0.2, "max" = 3, "default" = 0.7),
		"accuracy" = list("label" = "Множитель точности", "section" = "Бой", "min" = 0.3, "max" = 1, "default" = 0.85),
		"burst_limit" = list("label" = "Максимум выстрелов в очереди", "section" = "Бой", "min" = 1, "max" = 12, "default" = 6, "integer" = TRUE),
		"burst_pause" = list("label" = "Пауза между очередями, секунд", "section" = "Бой", "min" = 0.5, "max" = 5, "default" = 1),
		"chase_time" = list("label" = "Преследование потерянной цели, секунд", "section" = "Бой", "min" = 0, "max" = 30, "default" = 7),
		"cover" = list("label" = "Использовать укрытия", "section" = "Бой", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"cover_mode" = list("label" = "Выбор укрытия: 0 — ближайшее, 1 — оценка, 2 — смена при попадании", "section" = "Бой", "min" = 0, "max" = 2, "default" = 1, "integer" = TRUE),
		"tactical_distance" = list("label" = "Учитывать вооружение противника при выборе дистанции", "section" = "Бой", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"retreat_health" = list("label" = "Отступление при здоровье ниже, %", "section" = "Бой", "min" = 0, "max" = 70, "default" = 30, "integer" = TRUE),
		"grenades" = list("label" = "Ручные гранаты", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"underbarrel" = list("label" = "Подствольный гранатомёт", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"throwback" = list("label" = "Безопасный обратный бросок", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"fuse_reserve" = list("label" = "Резерв запала, секунд", "section" = "Гранаты", "min" = 2, "max" = 6, "default" = 2),
		"grenade_chance" = list("label" = "Шанс броска гранаты, %", "section" = "Гранаты", "min" = 0, "max" = 100, "default" = 100, "integer" = TRUE),
		"medicine" = list("label" = "Разрешить медицину", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"self_heal" = list("label" = "Лечить себя", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"heal_npcs" = list("label" = "Лечить союзных NPC", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"heal_players" = list("label" = "Лечить союзных игроков", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"drugs" = list("label" = "Использовать медикаменты", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"repair_self" = list("label" = "Ремонтировать себя — синтетик", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"repair_allies" = list("label" = "Ремонтировать союзных синтетиков", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"heal_out_of_combat" = list("label" = "Лечить только после завершения боя", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"open_door" = list("label" = "Открывать двери", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pry_door" = list("label" = "Вскрывать двери инструментом", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"climb_barricade" = list("label" = "Перелезать баррикады", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"climb_structure" = list("label" = "Перелезать конструкции", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"destroy" = list("label" = "Разрушать разрешённые препятствия", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pickup" = list("label" = "Подбирать предметы", "section" = "Снаряжение", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"switch_weapons" = list("label" = "Подбирать основное оружие под дистанцию боя", "section" = "Снаряжение", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"early_reload" = list("label" = "Заранее менять почти пустой магазин вне боя", "section" = "Снаряжение", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"follow_distance" = list("label" = "Дополнительная дистанция следования", "section" = "Движение", "min" = 0, "max" = 5, "default" = 0, "integer" = TRUE),
		"hold_radius" = list("label" = "Радиус удержания: 0 — без дополнительного ограничения", "section" = "Движение", "min" = 0, "max" = 20, "default" = 0, "integer" = TRUE),
		"path_retries" = list("label" = "Неудачные поиски пути до увеличенной паузы", "section" = "Движение", "min" = 1, "max" = 10, "default" = 3, "integer" = TRUE),
	)
	return schema

/proc/human_ai_settings_valid_value(key, value)
	if(!istext(key))
		return FALSE
	var/list/definition = human_ai_settings_schema()[key]
	if(!definition || !isnum(value) || value < definition["min"] || value > definition["max"])
		return FALSE
	if((definition["integer"] || definition["boolean"]) && round(value) != value)
		return FALSE
	return TRUE

/// Returns a new flat list, never a caller-owned profile or shared metadata.
/proc/human_ai_settings_validate(list/values)
	if(!islist(values))
		return null
	var/list/schema = human_ai_settings_schema()
	if(length(values) != length(schema))
		return null
	var/list/result = list()
	for(var/key in values)
		if(!human_ai_settings_valid_value(key, values[key]))
			return null
		result[key] = values[key]
	return result

/// Version 1 lacks the two additive controls. Never accept arbitrary partial saves.
/proc/human_ai_settings_import(list/values, version)
	if(!islist(values) || !(version in list(1, 2)))
		return null
	var/list/migrated = values.Copy()
	if(version == 1)
		if(!("grenade_chance" in migrated))
			migrated["grenade_chance"] = 100
		if(!("stealth_enabled" in migrated))
			migrated["stealth_enabled"] = TRUE
	return human_ai_settings_validate(migrated)

/proc/human_ai_settings_help(key)
	var/static/list/descriptions = list(
		"reaction" = "Минимальная задержка перед стрельбой после обнаружения новой цели. Меньше — NPC открывает огонь быстрее. Фактическая реакция зависит также от такта ИИ и готовности оружия. Единицы: секунды.",
		"accuracy" = "Множитель точности создаваемого снаряда. 1 сохраняет исходную точность оружия; 0.65 оставляет 65% от неё. Это не вероятность попадания: дистанция, укрытие и оружие продолжают влиять на результат.",
		"burst_limit" = "Верхний предел выстрелов в автоматической очереди до паузы. Меньше — более короткие очереди. Собственный меньший лимит оружия сохраняется; настройка не превращает одиночный режим в автоматический. Единицы: выстрелы.",
		"burst_pause" = "Минимальная пауза после достижения лимита очереди. Больше — реже длинные серии огня. Собственные задержки ИИ и оружия могут увеличить паузу. Единицы: секунды.",
		"chase_time" = "Как долго разрешено преследовать последнюю известную позицию потерянной цели. Отсчёт идёт от последнего визуального наблюдения. 0 отключает такое преследование; новое обнаружение цели обновляет отсчёт. Единицы: секунды.",
		"cover_mode" = "0 — ближайшая безопасная позиция с положительной оценкой защиты. 1 — позиция с лучшей оценкой. 2 — та же оценка плюс повторный поиск при попадании по NPC в укрытии. Работает при включённом использовании укрытий.",
		"retreat_health" = "Порог здоровья в процентах от максимального: ниже него NPC пытается увеличить дистанцию до противника. Это обычное движение, без прохода через стены и нарушения границ приказа. 0 означает отступление только при здоровье ниже нуля.",
		"fuse_reserve" = "Минимальный запас времени для безопасного обратного броска сверх расчётного времени подхода. Больше — NPC реже рискует подбирать гранату. Не меняет запал самой гранаты. Если времени мало, NPC пытается убежать. Единицы: секунды.",
		"grenade_chance" = "Одна проверка вероятности за боевое столкновение для ручной гранаты или подствольного гранатомёта. 0% — не использовать, 100% — выбрать применение при наличии безопасной возможности. Нужны разрешённый тип гранат, боеприпас и безопасная цель. Изменение значения не перебрасывает уже принятое решение; действует со следующей проверкой. Обратный бросок не затрагивает.",
		"follow_distance" = "Добавляет расстояние к стандартной дистанции следования за командиром отряда. 0 оставляет обычное построение; больше — NPC держится дальше. Единицы: тайлы.",
		"hold_radius" = "Дополнительное ограничение удаления от исходной точки приказа удержания. 0 не добавляет радиус, но исходная граница приказа сохраняется. Бегство от активной гранаты может временно выйти за границы. Единицы: тайлы.",
		"path_retries" = "После указанного числа неудачных поисков пути обычная пауза повторного поиска увеличивается втрое. Меньше — быстрее снижает частоту безуспешных попыток. Не разрешает проход сквозь препятствия. Единицы: попытки.",
		"stealth_enabled" = "Включено: NPC не замечает новую цель в трёх направлениях позади себя. Уже обнаруженная цель остаётся известной, а нападение вызывает ответ. Выключено: задней слепой зоны нет. Обычная дальность, стены и проверки видимости сохраняются.",
	)
	return descriptions[key]

/proc/human_ai_settings_preset(level = "medium")
	if(!(level in list("easy", "medium", "hard")))
		return null
	var/list/result = list()
	var/list/schema = human_ai_settings_schema()
	for(var/key in schema)
		var/list/definition = schema[key]
		result[key] = definition["default"]
	if(level == "easy")
		result["reaction"] = 1.2
		result["accuracy"] = 0.65
		result["burst_limit"] = 3
		result["burst_pause"] = 2
		result["chase_time"] = 3
		result["cover_mode"] = 0
		result["switch_weapons"] = FALSE
		result["early_reload"] = FALSE
		for(var/key in list("grenades", "underbarrel", "heal_npcs", "heal_players", "drugs", "repair_allies", "destroy"))
			result[key] = FALSE
		result["heal_out_of_combat"] = TRUE
	else if(level == "hard")
		result["reaction"] = 0.3
		result["accuracy"] = 1
		result["burst_limit"] = 8
		result["burst_pause"] = 0.5
		result["chase_time"] = 12
		result["throwback"] = TRUE
		result["cover_mode"] = 2
		result["tactical_distance"] = TRUE
	return result
