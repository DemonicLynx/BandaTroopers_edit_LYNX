# PLAN

## MUST
- Start every terminal KeyBinds category collapsed when the window opens.
- Remove the terminal quick-navigation `ВСЕ/ALL` button highlighted by the user.
- Keep every individual category quick button; it must still expand and scroll to its target.
- Keep search-by-key able to reveal a row inside an initially collapsed category.

## KEEP
- Preserve independent category collapse state after opening.
- Preserve Classic dropdown, including its canonical `ALL` option.
- Preserve key capture, search, add, clear, reset, persistence, theme styling, and localization.
- Preserve the previous non-compiling verification constraint.

## REJECT
- No persisted collapse preference.
- No removal of the Classic `ALL` filter.
- No compilation or full build.

## CHECK
- Initial state maps every terminal category to collapsed, terminal quick navigation contains only category buttons, reveal-before-scroll remains present, Classic dropdown still contains `ALL`, tests/static audit/diff/hash verification.

## Forbidden substitutions
- Do not merely hide the `ВСЕ` button with CSS; remove it from terminal markup.
- Do not make quick buttons navigate to a still-collapsed category.

