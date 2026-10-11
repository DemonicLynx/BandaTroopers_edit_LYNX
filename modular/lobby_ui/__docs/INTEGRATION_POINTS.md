# Lobby UI: точки интеграции и fallback

Этот файл описывает единственные разрешённые связи между модулем `modular/lobby_ui` и основным кодом. Он нужен для повторного внесения минимальных точек вызова после синхронизации с upstream.

## Как отключить модуль

Удалите или закомментируйте одну строку в `modular/modular.dme`:

```dm
#include "lobby_ui/_lobby_ui.dme"
```

После этого проект должен собираться, а игроки должны получать стандартное меню лобби, стандартное окно настроек персонажа, стандартную музыку входа и стандартные вспомогательные окна.

## Правило для внешнего кода

Вне `modular/lobby_ui` запрещены ссылки на `/datum/modpack/lobby_ui`, переменные `banda_*`, процедуры `banda_*`, стили и данные конкретной темы. Разрешены только нейтральные вызовы через `SSmodpacks?.lobby_ui_provider` или общие шлюзы `SSmodpacks.lobby_ui_choice()` и `SSmodpacks.lobby_ui_translate()`.

Каждая такая точка помечается комментарием:

```dm
// SS220 DemonicLynx "Lobby UI" - neutral provider hook; upstream behavior is the fallback.
```

Контракт провайдера находится в `modular/_modpack.dm`, регистрация и общие шлюзы — в `modular/_modpacks.dm`, реализация — в `modular/lobby_ui/_lobby_ui.dm`.

## Карта нейтральных точек вызова

| Файл вне модуля | Точка | Что предоставляет модуль | Стандартный fallback |
| --- | --- | --- | --- |
| `code/modules/mob/new_player/new_player.dm` | `new_player_panel()` | Новое меню лобби | Полный классический HTML лобби |
| `code/modules/mob/new_player/new_player.dm` | `Topic()` | Звук нажатия | Без дополнительного звука |
| `code/modules/mob/new_player/new_player.dm` | `ViewManifest()` | CRT-оформление стандартных данных манифеста | Исходное окно `Crew Manifest` |
| `code/modules/mob/new_player/new_player.dm` | `close_spawn_windows()` | Закрытие модульного окна | Закрытие стандартных окон |
| `code/game/sound.dm` | `client/playtitlemusic()` | Зацикленная музыка модуля | `SSticker.login_music` на стандартном канале лобби |
| `code/modules/client/preferences_savefile.dm` | загрузка/сохранение preferences | Настройки темы, цветов, подсветки и превью | Никаких дополнительных полей |
| `code/modules/mob/new_player/preferences_setup.dm` | `update_preview_icon()` | Модульное снаряжение превью | `arm_equipment()` upstream |
| `code/modules/client/preferences.dm` | `ShowChoices()` | Оболочка, содержимое и показ редактора | Полное стандартное окно Preferences |
| `code/modules/client/preferences.dm` | `SetChoices()` | Полная отрисовка терминального окна приоритетов должностей | Полное стандартное Job Preferences |
| `code/modules/client/preferences.dm` | `set_job_slots()` | Полная отрисовка терминального окна назначения слотов | Полное стандартное Job Assignment |
| `code/modules/client/preferences.dm` | `SetRecords()` | Оформление записей | Стандартное Set Records |
| `code/modules/client/preferences.dm` | `process_link()` | Модульные действия ссылок | Стандартный switch обработчика |
| `code/modules/client/preferences.dm` | `SSmodpacks.lobby_ui_choice()` | Перевод английских prompt/title и отображаемых вариантов с сохранением канонических значений | Обычный английский `tgui_input_list()` |
| `code/modules/client/preferences.dm` | `SSmodpacks.lobby_ui_translate()` | Перевод отдельных английских prompt/title/labels | Исходный английский текст |
| `code/modules/client/flavor_text_editor.dm` | TGUI presentation/title | Тема и русские подписи редактора описания | Стандартная тема и заголовок |
| `code/modules/admin/tabs/event_tab.dm` | обновление Setup Event Info | Мгновенное обновление текста миссии | Никакого push-обновления классического меню |
| `tgui/packages/tgui/interfaces/FlavorTextEditor.tsx` | `custom_presentation` | Применение необязательного описания внешнего вида | Встроенные классические значения |
| `tgui/packages/tgui/styles/interfaces/FlavorTextEditor.scss` | класс `--custom` | Нейтральный контейнер для необязательной темы | Стандартные стили TGUI |
| `interface/skin.dmf` | `lobbybrowser`, `preferencebrowser`, `preferencewindow` | Нейтральные browser-host поверхности | Они скрыты и не меняют классический интерфейс |

## Повторное внесение после upstream

1. Найдите перечисленные процедуры в актуальном upstream.
2. Внесите только короткий вызов провайдера и оставьте исходное тело процедуры полноценным fallback.
3. Не переносите HTML, русские строки, CSS, аудио-пути или состояние Lobby UI в основной код.
4. Добавьте маркер `SS220 DemonicLynx "Lobby UI"` непосредственно над вызовом.
5. Проверьте, что вне модуля отсутствуют прямые имена реализации:

```powershell
rg -n "datum/modpack/lobby_ui|banda_|uses_banda|get_banda|show_banda" code interface tgui
```

Допустимы только нейтральное поле `lobby_ui_provider`, методы контракта `lobby_ui_*`, generic TGUI payload `custom_presentation` и browser-host элементы из таблицы.

Полная терминальная разметка Job Preferences и Job Assignment находится в `modular/lobby_ui/code/shared/auxiliary_preferences.dm`. Таблица русских переводов диалогов персонажа находится в `modular/lobby_ui/code/shared/character_localization.dm`. В `preferences.dm` эти данные дублировать нельзя.

## Проверка отключаемости

Запустите локальный безопасный checker из корня репозитория:

```powershell
powershell -ExecutionPolicy Bypass -File modular/lobby_ui/tools/check_modularity.ps1
```

Он выполняет static audit, DM-сборку с модулем и DM-сборку без него. Перед временным отключением сохраняются точные байты `modular/modular.dme`; восстановление выполняется в `finally` и подтверждается SHA-256. Скрипт отказывается работать, если точная include-строка отсутствует или встречается больше одного раза, и не изменяет include других модулей.

DreamMaker напрямую для этой проверки не используется.

## Готовые фрагменты для повторного внесения

Номера строк ниже соответствуют рабочему дереву на **10 октября 2026 года**. После синхронизации с upstream они могут сместиться. Главный ориентир — путь, имя процедуры/элемента и соседний стандартный код. Вставки не должны удалять стандартное тело: оно остаётся fallback при отключённом модуле.

### 1. Подключение и нейтральный контракт

`modular/modular.dme:19`, рядом с include остальных модулей:

```dm
#include "lobby_ui/_lobby_ui.dme"
```

Это единственная строка, включающая реализацию. Нейтральные точки ниже обязаны компилироваться без неё.

`modular/_modpack.dm:19–87`, после стандартных lifecycle-процедур `/datum/modpack`:

```dm
// SS220 DemonicLynx "Lobby UI" - neutral optional provider contract; null/no-op behavior keeps the upstream classic interface.
/datum/modpack/proc/lobby_ui_show_lobby(mob/new_player/player, refresh = FALSE)
	return FALSE

/datum/modpack/proc/lobby_ui_hide(mob/user)
	return

/datum/modpack/proc/lobby_ui_play_click(mob/new_player/player)
	return

/datum/modpack/proc/lobby_ui_play_title_music(client/player_client)
	return FALSE

/datum/modpack/proc/lobby_ui_show_manifest(mob/new_player/player, manifest_html)
	return FALSE

/datum/modpack/proc/lobby_ui_load_preferences(datum/preferences/preferences, savefile/preferences_file)
	return

/datum/modpack/proc/lobby_ui_save_preferences(datum/preferences/preferences, savefile/preferences_file)
	return

/datum/modpack/proc/lobby_ui_refresh_event_panels(datum/custom_event_info/event_info)
	return

/datum/modpack/proc/lobby_ui_equip_character_preview(datum/preferences/preferences, mob/living/carbon/human/preview_dummy, datum/job/job)
	return FALSE

/datum/modpack/proc/lobby_ui_flavor_text_presentation(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_flavor_text_window_title(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_uses_custom_character_editor(datum/preferences/preferences)
	return FALSE

/datum/modpack/proc/lobby_ui_character_header(datum/preferences/preferences, mob/user)
	return null

/datum/modpack/proc/lobby_ui_character_footer(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_show_character_editor(datum/preferences/preferences, mob/user, html)
	return FALSE

/datum/modpack/proc/lobby_ui_character_equipment_controls(datum/preferences/preferences, mob/user)
	return null

/datum/modpack/proc/lobby_ui_interface_controls(datum/preferences/preferences)
	return ""

/datum/modpack/proc/lobby_ui_show_job_preferences(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return FALSE

/datum/modpack/proc/lobby_ui_show_job_slots(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return FALSE

/datum/modpack/proc/lobby_ui_show_records(datum/preferences/preferences, mob/user)
	return FALSE

/datum/modpack/proc/lobby_ui_handle_preferences_topic(datum/preferences/preferences, mob/user, list/href_list)
	return FALSE

/datum/modpack/proc/lobby_ui_localized_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	return tgui_input_list(user, prompt, title, options)

/datum/modpack/proc/lobby_ui_translate_text(datum/preferences/preferences, text)
	return text
```

`modular/_modpacks.dm:8–28`, поле добавить внутри `SUBSYSTEM_DEF(modpacks)` после `loaded_modpacks`, процедуры — перед `Initialize()`:

```dm
	// SS220 DemonicLynx "Lobby UI" - neutral optional provider registration; null preserves all standard fallbacks.
	/// Optional provider for lobby and character-preferences presentation.
	var/datum/modpack/lobby_ui_provider

/datum/controller/subsystem/modpacks/proc/register_lobby_ui_provider(datum/modpack/provider)
	if(!provider)
		return "Lobby UI provider is null"
	if(lobby_ui_provider && lobby_ui_provider != provider)
		return "Lobby UI provider is already registered by [lobby_ui_provider.name]"
	lobby_ui_provider = provider
	return null

/datum/controller/subsystem/modpacks/proc/lobby_ui_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	// SS220 DemonicLynx "Lobby UI" - neutral localization gateway; the standard input list is the fallback.
	if(lobby_ui_provider)
		return lobby_ui_provider.lobby_ui_localized_choice(preferences, user, prompt, title, options)
	return tgui_input_list(user, prompt, title, options)

/datum/controller/subsystem/modpacks/proc/lobby_ui_translate(datum/preferences/preferences, text)
	// SS220 DemonicLynx "Lobby UI" - neutral translation gateway; unchanged text is the fallback.
	return lobby_ui_provider?.lobby_ui_translate_text(preferences, text) || text
```

### 2. Меню лобби, музыка и закрытие окон

`code/game/sound.dm:260–267`, якорь `/client/proc/playtitlemusic()`. Вставить в начало, до проверки `SSticker?.login_music`:

```dm
/client/proc/playtitlemusic()
	// SS220 DemonicLynx "Lobby UI" - neutral provider hook; upstream music is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_play_title_music(src))
		return TRUE
	if(!SSticker?.login_music)
		return FALSE
```

`code/modules/mob/new_player/new_player.dm:32–38`, якорь `/mob/new_player/proc/new_player_panel_proc`, сразу после проверки `client`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional provider hook; complete classic lobby fallback follows.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_lobby(src, refresh))
		return
```

`new_player.dm:70–72`, якорь `/mob/new_player/Topic`, после проверки `client`, до стандартного `switch`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional click-feedback hook; classic fallback is silence.
	if(href_list["lobby_choice"])
		SSmodpacks?.lobby_ui_provider?.lobby_ui_play_click(src)
```

`new_player.dm:398–409`, якорь `/mob/new_player/proc/ViewManifest()`. Сначала получить стандартный HTML один раз, затем перед исходной разметкой окна добавить provider-вызов:

```dm
/mob/new_player/proc/ViewManifest()
	var/manifest_html = GLOB.data_core.get_manifest(FALSE, TRUE)
	// SS220 DemonicLynx "Lobby UI" - optional manifest renderer; the complete classic browser below is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_manifest(src, manifest_html))
		return

	var/dat = "<html><body>"
	dat += "<h4><center>Crew Manifest:</center></h4>"
	dat += manifest_html

	show_browser(src, dat, "Crew Manifest", "manifest", width = 450, height = 750)
```

Модуль получает уже сформированный `manifest_html`; `code/datums/datacore.dm` менять не нужно. Это сохраняет единый источник данных и не затрагивает манифесты в других интерфейсах.

`new_player.dm:443–448`, якорь `/mob/proc/close_spawn_windows`, между закрытием стандартных окон и сбросом звука:

```dm
	close_browser(src, "latechoices")
	close_browser(src, "playersetup")
	// SS220 DemonicLynx "Lobby UI" - optional cleanup hook; standard windows are closed above.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_hide(src)
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = SOUND_CHANNEL_LOBBY)
```

### 3. Savefile, превью и Setup Event Info

`code/modules/client/preferences_savefile.dm:303–304`, в конце загрузки стандартных preference-полей:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional provider load hook; null keeps classic defaults.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_load_preferences(src, S)
```

`preferences_savefile.dm:519–520`, в конце сохранения стандартных preference-полей:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional provider save hook; null requires no data.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_save_preferences(src, S)
```

`code/modules/mob/new_player/preferences_setup.dm:206–208`, после `preview_dummy.update_hair()`, вместо безусловного `arm_equipment()`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional preview provider; upstream equipment is the fallback.
	if(!SSmodpacks?.lobby_ui_provider?.lobby_ui_equip_character_preview(src, preview_dummy, J))
		arm_equipment(preview_dummy, J, FALSE, FALSE, owner, show_job_gear)
```

`code/modules/admin/tabs/event_tab.dm:38–39` и `:46–47`, после удаления и после обновления `custom_event_info`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional refresh hook; classic lobby needs no push update.
	SSmodpacks?.lobby_ui_provider?.lobby_ui_refresh_event_panels(CEI)
```

### 4. Редактор персонажа и вспомогательные окна

Все точки находятся в `code/modules/client/preferences.dm`. Стандартная разметка после раннего provider-вызова не удаляется.

`ShowChoices():321–325`, сразу после проверки `user.client`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional character-shell provider; complete upstream header is the fallback.
	var/datum/modpack/lobby_ui_provider = SSmodpacks?.lobby_ui_provider
	var/custom_character_editor = lobby_ui_provider?.lobby_ui_uses_custom_character_editor(src)
	var/dat = lobby_ui_provider?.lobby_ui_character_header(src, user)
	if(isnull(dat))
		// Полный стандартный header/body upstream должен остаться внутри этого if.
```

`ShowChoices():429–431`, перед всем стандартным блоком `Marine Gear`:

```dm
			// SS220 DemonicLynx "Lobby UI" - optional complete equipment renderer; upstream controls are the fallback.
			var/custom_equipment_controls = lobby_ui_provider?.lobby_ui_character_equipment_controls(src, user)
			if(isnull(custom_equipment_controls))
				// Полный стандартный блок Marine Gear upstream остаётся здесь,
				// включая Personal Weapon, Underwear, Undershirt,
				// Backpack Type, Preferred Armor, Show Job Gear,
				// Background и Custom Loadout.
			else
				dat += custom_equipment_controls
```

Terminal provider полностью формирует этот блок. Поэтому он может не показывать отдельные classic-настройки, не удаляя их из стандартного fallback.

`ShowChoices():617–618`, в `MENU_SETTINGS` перед стандартным `Input Settings`:

```dm
			// SS220 DemonicLynx "Lobby UI" - optional module settings; classic fallback adds nothing.
			dat += lobby_ui_provider?.lobby_ui_interface_controls(src) || ""
```

`ShowChoices():720–725`, вместо стандартного безусловного footer/show-browser хвоста:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional footer/display hooks; upstream browser is the fallback.
	dat += lobby_ui_provider?.lobby_ui_character_footer(src) || "</div></body>"
	if(!lobby_ui_provider?.lobby_ui_show_character_editor(src, user, dat))
		winshow(user, "preferencewindow", TRUE)
		show_browser(user, dat, "Preferences", "preferencebrowser", width = 1000, height = 800, existing_container = "preferencewindow")
		onclose(user, "preferencewindow", src)
```

`SetChoices():736–741`, после проверки `GLOB.RoleAuthority`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional complete window renderer; the unchanged classic window below is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_job_preferences(src, user, limit, splitJobs, width, height))
		return
```

`set_job_slots():865–870`, после проверки `GLOB.RoleAuthority`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional complete window renderer; the unchanged classic window below is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_job_slots(src, user, limit, splitJobs, width, height))
		return
```

`SetRecords():942–945`, в начале процедуры:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional records renderer; complete upstream records window is the fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_show_records(src, user))
		return
```

`process_link():1108–1112`, перед стандартным `switch(href_list["preference"])`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional action provider; upstream switch is the complete fallback.
	if(SSmodpacks?.lobby_ui_provider?.lobby_ui_handle_preferences_topic(src, user, href_list))
		return TRUE
```

#### Нейтральные шлюзы локализации

Вызовы `lobby_ui_translate()` сейчас находятся на строках `1347`, `1357`, `1699`, `1705`, `1712`, `1733`, `1780`, `1834`, `1947–1948`, `1959`.

Вызовы `lobby_ui_choice()` — на строках `1750`, `1755`, `1761`, `1767`, `1773`, `1807`, `1815`, `1825`, `1847`, `1852`, `1857`, `1862`, `1869`, `1901`, `1916`, `1926`, `1938`, `1942`, `1954`, `1974`.

Шаблоны замены стандартных диалогов:

```dm
SSmodpacks.lobby_ui_translate(src, "Original upstream English text")

var/choice = SSmodpacks.lobby_ui_choice(
	src,
	user,
	"Original upstream English prompt",
	"Original upstream English title",
	canonical_options,
)
```

В core передаются только исходные английские строки и канонические значения. Русские подписи и обратное преобразование выбора хранятся в `modular/lobby_ui/code/shared/character_localization.dm`.

### 5. Flavor Text Editor

`code/modules/client/flavor_text_editor.dm:9–12`, внутри `ui_data()` после создания `categories`:

```dm
	// SS220 DemonicLynx "Lobby UI" - optional presentation data; TGUI defaults remain classic.
	var/list/custom_presentation = SSmodpacks?.lobby_ui_provider?.lobby_ui_flavor_text_presentation(prefs)
	if(custom_presentation)
		.["custom_presentation"] = custom_presentation
```

`flavor_text_editor.dm:24–26`, внутри `tgui_interact()`, вместо жёсткого заголовка:

```dm
		// SS220 DemonicLynx "Lobby UI" - optional title provider; upstream title is the fallback.
		var/window_title = SSmodpacks?.lobby_ui_provider?.lobby_ui_flavor_text_window_title(user.client?.prefs) || "Flavor Text Editor"
		ui = new(user, src, "FlavorTextEditor", window_title)
```

`tgui/packages/tgui/interfaces/FlavorTextEditor.tsx:19–26`, добавить в `Data`:

```tsx
  custom_presentation?: {
    theme?: string;
    class_name?: string;
    save_label?: string;
    revert_label?: string;
    editor_title?: string;
    category_labels?: Record<string, string>;
  };
```

`FlavorTextEditor.tsx:31–66`, получить payload и вычислить подписи:

```tsx
  // SS220 DemonicLynx "Lobby UI" - generic optional presentation payload; classic labels are the fallback.
  const { general, categories, custom_presentation: presentation } = data;

  const getCategoryLabel = (categoryName: string) =>
    presentation?.category_labels?.[categoryName] ||
    categoryName[0].toUpperCase() + categoryName.slice(1);
  const categoryLabel = getCategoryLabel(category);
  const editorTitle = presentation?.editor_title
    ? presentation.editor_title.replace('{category}', categoryLabel)
    : `Edit ${category} flavor text (Shift+Enter for new line)`;
```

Передать в `Window` тему `presentation?.theme || 'crtblue'`, в `Window.Content` класс `FlavorTextEditor ${presentation?.class_name || ''}`; вкладке — `getCategoryLabel(iterateCategory)`, Section — `editorTitle`, кнопкам — `presentation?.save_label || 'Save'` и `presentation?.revert_label || 'Revert'`.

`tgui/packages/tgui/styles/interfaces/FlavorTextEditor.scss` копируется целиком. Подключение в `tgui/packages/tgui/styles/main.scss:63–64`:

```scss
// SS220 DemonicLynx "Lobby UI" - generic optional FlavorTextEditor presentation styles.
@include meta.load-css('./interfaces/FlavorTextEditor.scss');
```

TGUI-мост остаётся вне DM-модуля, потому что TypeScript/SCSS собираются независимо от include в `modular.dme`. Все поля необязательны, поэтому стандартный редактор остаётся fallback.

### 6. Нейтральные BYOND browser-host элементы

`interface/skin.dmf:239–249`, внутри основного окна:

```dmf
	// SS220 DemonicLynx "Lobby UI" - neutral hidden browser host; the classic lobby remains the fallback.
	elem "lobbybrowser"
		type = BROWSER
		pos = 0,0
		size = 640x480
		anchor1 = 0,0
		anchor2 = 100,100
		is-visible = false
		background-color = #020810
		saved-params = ""
	// SS220 DemonicLynx "Lobby UI" - end neutral lobby browser host.
```

`interface/skin.dmf:456–472`, внутри окна `preferences`, после его корневого `MAIN`:

```dmf
	// SS220 DemonicLynx "Lobby UI" - neutral hidden character-editor browser host; classic Preferences remains the fallback.
	elem "preferencebrowser"
		type = BROWSER
		pos = 0,0
		size = 0x0
		anchor1 = 0,0
		anchor2 = 100,100
		background-color = none
		saved-params = ""
	elem "preview"
		type = MAP
		pos = 0,-10
		size = 0x250
		anchor1 = 0,0
		anchor2 = 100,0
		is-visible = false
	// SS220 DemonicLynx "Lobby UI" - end neutral character-editor browser host.
```

### 7. Проверка после повторного портирования

```powershell
rg -n "lobby_ui_provider|lobby_ui_choice|lobby_ui_translate|custom_presentation|lobbybrowser|preferencebrowser" code modular interface tgui
```

Затем выполнить обе сборки через `BUILD.cmd`: сначала с include модуля, затем временно без него. Успех только первой сборки означает, что во внешнем коде осталась прямая зависимость от реализации или потерян стандартный fallback.
