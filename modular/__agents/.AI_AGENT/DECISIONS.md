# DECISIONS

- Keep `banda_menu_interface` in the existing root preferences savefile through the existing provider hooks.
- Centralize apply/save/rollback in one module-local preferences proc; callers never claim success from an unchecked write.
- Reapply and save an explicit selection even when it matches the in-memory value, then refresh the active new-player lobby.
- Preserve the existing validation rule: only exact `classic` is Classic; missing or invalid values normalize to Terminal.
