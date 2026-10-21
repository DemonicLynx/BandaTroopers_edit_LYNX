# Human AI settings panel

Open **Game Master → HumanAI → Human AI Settings** (R_DEBUG required).

This directory owns the panel: `settings_panel.dm`, `HumanAISettings.tsx` and its local SWC configuration. TGUI contains only the interface export and dependency bridge. Runtime policy and persistence are in `../configuration`; combat, medicine, navigation and equipment consume the policy in their own subsystems.

## Application

All edits are drafts. Difficulty and slot loading never apply automatically. Settings are global only: no individual NPC selection, override API or reset-exceptions action exists. Applying displays a confirmation and rechecks authorization and global revision after the dialog. Application affects living current and future NPCs. Dead NPCs keep their snapshots; revival adopts the latest globals on the first living process tick.

«Применить настройки» confirms and applies the draft. «Показать текущие настройки с сервера» replaces the draft with the active global profile without changing NPC behavior. Its question-mark tooltip explains draft loss. Every numeric control has a question-mark tooltip with semantics, units and valid bounds. Personal slots store full global profiles, never NPC references.

## Persistence

Each admin ckey has exactly three slots in `data/player_saves/<initial>/<ckey>/human_ai_settings.sav`. Names accept Cyrillic/Latin letters, digits and spaces, up to 40 characters. Save/overwrite, rename and delete require confirmation. Schema version 2 adds grenade_chance and stealth_enabled. Valid version-1 profiles retain all existing values and acquire defaults for only these two fields; arbitrary partial or malformed profiles are rejected.

Global changes normally last for this server process. «Сохранить для сервера после перезапуска» persists the currently applied global profile to `data/human_ai_settings.sav`; it does not apply/save a draft. Built-in profiles do not occupy personal slots.

## Safety and semantics

«Шанс броска гранаты, %»: 0–100, default 100 to preserve prior behavior. Uses the existing single cached roll per combat encounter for hand grenades/underbarrel launcher. Changes do not reroll a decided encounter. Emergency throwback is separate and all safety gates remain.

«Стелс для ИИ» defaults on: initial acquisition ignores three rear-facing directions. Switching off removes only this rear blind spot; normal view range, walls and faction checks remain. Already acquired targets and explicit aggression responses are unchanged.

| Preset | Reaction | Accuracy multiplier | Burst cap / pause | Lost-target chase | Grenades / launcher / throwback | Ally treatment / drugs |
|---|---|---|---|---|---|---|
| Easy | 1.2 s | 0.65 | 3 / 2 s | 3 s | off / off / off | off / off |
| Medium | 0.7 s | 0.85 | 6 / 1 s | 7 s | on / on / off | on / on |
| Hard | 0.3 s | 1.0 | 8 / 0.5 s | 12 s | on / on / on | on / on |

All presets allow self-care, self synthetic repair, doors, prying and climbing. Easy forbids destruction, ally synthetic repair, tactical weapon switching and proactive reload. All retain escape from live grenades, protected objects and low-health retreat. Medium is the initial profile when no valid server default exists.

Settings restrict existing capabilities; they do not give an unequipped NPC medical supplies, tools or forbidden actions. Protected destruction, physics, friendly-fire checks, overdose checks and live grenade escape remain mandatory. Disabling grenade throwback still permits escape. A committed throw is allowed to finish.

Reaction is a minimum firing delay after acquiring a new target, quantized by AI processing. Accuracy scales projectile accuracy rather than guaranteeing a hit percentage. Weapon-specific burst limits still apply. Easy cover prefers the nearest positively scored safe tile; medium uses the existing score; hard rescores when hit inside cover. Tactical range adds spacing against a visible human without a firearm in their active hand. Low-health spacing, not teleportation, implements retreat. Follow distance adds to the existing squad formation distance. Hold radius adds a restriction to the issued boundary; live grenade escape can temporarily leave it. Path retry threshold increases the existing failure backoff rather than forcing a path through scenery.

Medicine always retains threat and patient-safety checks. The out-of-combat option adds a stricter requirement. Proactive reload requires no combat, a detachable magazine below 25%, and a better compatible carried replacement. Runtime settings changes and server saves are logged in the admin log.
