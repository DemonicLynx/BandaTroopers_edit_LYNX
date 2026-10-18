# DECISIONS

- Build the initial collapsed-state object directly from `glob_keybinds` in the `useState` initializer, so the first render already contains collapsed headers and never flashes expanded rows.
- Remove the terminal all-button JSX and the obsolete `category === 'ALL'` navigation branch rather than masking them with CSS.
- Retain `activeCategory = null` as the initial state; no category is highlighted until an individual quick button is used.
- Keep the provider's `all` label because Classic still uses its original `ALL` dropdown option.
- Continue without compilation per the user's instruction.

