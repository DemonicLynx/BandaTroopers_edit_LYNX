# EVIDENCE

## Discovery
- Terminal collapse state currently initializes as an empty object, so every category begins expanded because `!!collapsedCategories[category]` is false.
- The highlighted terminal `ВСЕ` button is emitted only by `KeybindQuickNavigation`; Classic separately uses `labels.all` inside its dropdown.
- `jumpToCategory('ALL')` is a terminal-only branch that expands every category and becomes dead code once the button is removed.
- Individual quick navigation and search-by-key already set `[category]: false` before deferred scrolling, which is compatible with initially collapsed categories.

## Plan-mapping challenge — PASS
1. CSS-only hiding would leave dead interaction markup. Rejected; remove JSX and branch.
2. Setting a global collapsed boolean would prevent independent state. Rejected; initialize the existing per-category map.
3. Removing the provider's `all` label would alter Classic localization. Rejected; Classic retains it.
4. Persisting collapse state is outside the request. Rejected.

## Verification
- The `useState` initializer now builds a per-category map with every canonical category set to `true`, so the first terminal render is collapsed without an expanded flash.
- Removed the terminal `ВСЕ/ALL` button markup and obsolete `category === 'ALL'` branch. Individual quick buttons still write `[category]: false` before deferred scrolling.
- Search-by-key retains the same reveal-before-scroll path for hidden rows. Classic retains its independent `ALL` dropdown entry and original 360px dimensions.
- Regression coverage asserts initial collapsed state, absence of the terminal all-button, presence of Classic `ALL`, and the existing reveal path.
- Post-deploy Node tests: 18/18 passed.
- Post-deploy static modularity audit: passed.
- Targeted `git diff --check`: passed.
- SHA-256 comparison confirmed all three repository files match staging, source checkout, and PR replacement package; PR README also matches.
- Compilation and the full build were intentionally not run per the user's explicit instruction.
