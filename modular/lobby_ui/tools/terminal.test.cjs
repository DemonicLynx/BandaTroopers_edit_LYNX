// Run with: node --test modular/lobby_ui/tools/terminal.test.cjs
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.join(__dirname, '..');
const { createBandaLoadoutSequence } = require('../assets/loadout.js');

function clock() {
  let now = 0, next = 0;
  const tasks = new Map();
  return {
    schedule(fn, ms) { const id = ++next; tasks.set(id, { fn, time: now + ms }); return id; },
    cancel(id) { tasks.delete(id); },
    advance(ms) {
      const end = now + ms;
      for (;;) {
        const due = [...tasks].filter(([, v]) => v.time <= end).sort((a, b) => a[1].time - b[1].time)[0];
        if (!due) break;
        tasks.delete(due[0]); now = due[1].time; due[1].fn();
      }
      now = end;
    },
  };
}
function sequence() {
  const timer = clock(), rows = [1];
  let finished = 0, waiting = 0;
  const controller = createBandaLoadoutSequence(9, n => rows.push(n), () => finished++, () => waiting++, timer.schedule, timer.cancel);
  return { timer, rows, controller, get finished() { return finished; }, get waiting() { return waiting; } };
}
test('early data accelerates every remaining row, without skipping rows', () => {
  const s = sequence();
  s.controller.ready();
  s.timer.advance(404);
  assert.equal(s.finished, 0);
  s.timer.advance(1);
  assert.equal(s.finished, 1);
  assert.deepEqual(s.rows, [1,2,3,4,5,6,7,8,9]);
});
test('slow data waits after all nine rows; a late ready opens exactly once', () => {
  const s = sequence();
  s.timer.advance(10000);
  assert.equal(s.waiting, 1);
  assert.equal(s.finished, 0);
  s.controller.ready(); s.controller.ready();
  s.timer.advance(45);
  assert.equal(s.finished, 1);
});
test('closing the document cancels its sequence and ignores stale ready', () => {
  const s = sequence();
  s.timer.advance(480);
  s.controller.stop(); s.controller.ready(); s.timer.advance(10000);
  assert.equal(s.finished, 0);
  assert.deepEqual(s.rows, [1,2,3]);
});
function element(tagName, children = [], attrs = {}) {
  const node = { tagName, nodeType: 1, className: attrs.class || '', getAttribute: key => attrs[key] || '', setAttribute: (key, value) => { attrs[key] = value; } };
  node.firstChild = children[0];
  children.forEach((child, i) => { child.parentNode = node; child.nextSibling = children[i + 1]; });
  return node;
}
const text = value => ({ nodeType: 3, nodeValue: value });
test('actual translation walker preserves textarea, names and protected user content', () => {
  const dm = fs.readFileSync(path.join(root, 'code/shared/character_localization.dm'), 'utf8');
  let script = dm.substring(dm.indexOf('<script type=', dm.indexOf('var/script ='))).split('</script>')[0].replace(/^.*?>/, '');
  script = script.replace('[translations_json]', JSON.stringify({ Medical: 'Медицинская', Name: 'Имя' }))
    .replace('[phrase_translations_json]', JSON.stringify([['Medical', 'Медицинская']]))
    .replaceAll('[interface_language]', 'ru').replace(/\\([\[\]])/g, '$1');
  const label = text(' Medical: '), record = text('Medical'), name = text('Medical'), protectedText = text('Medical');
  const nameLink = element('A', [name], { href: 'byond://?_src_=prefs;preference=name;task=input' });
  let run;
  const document = {
    title: 'Medical',
    documentElement: element('HTML'),
    body: element('BODY', [element('DIV', [label]), element('TEXTAREA', [record]), nameLink, element('SPAN', [protectedText], { class: 'prefs-no-translate' })]),
    getElementsByTagName: () => [nameLink],
    addEventListener: (_, fn) => { run = fn; },
  };
  vm.runInNewContext(script, { document, window: {} });
  run();
  assert.equal(label.nodeValue, ' Медицинская: ');
  for (const unchanged of [record, name, protectedText]) assert.equal(unchanged.nodeValue, 'Medical');
});
test('notice expires at five seconds independently of effects', () => {
  const timer = clock(), state = { style: {} };
  let run;
  const window = { setTimeout: timer.schedule, clearTimeout: timer.cancel };
  const document = {
    querySelector: selector => selector === '.prefs-save-state' ? state : null,
    addEventListener: (_, fn) => { run = fn; },
  };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8'), { window, document });
  run();
  timer.advance(4999);
  assert.equal(state.style.visibility, 'visible');
  timer.advance(1);
  assert.equal(state.style.visibility, 'hidden');
});
test('additional settings expand and collapse without navigation', () => {
  const attributes = { 'aria-expanded': 'false' };
  const bodyAttributes = { 'aria-hidden': 'true' };
  const marker = { innerText: '+' };
  const body = { setAttribute: (name, value) => { bodyAttributes[name] = value; } };
  const section = { className: 'prefs-settings-collapsible', querySelector: selector => selector === '.prefs-settings-collapsible-body' ? body : null };
  const toggle = {
    parentNode: { parentNode: section },
    getAttribute: name => attributes[name],
    setAttribute: (name, value) => { attributes[name] = value; },
    querySelector: selector => selector === '.prefs-settings-toggle-marker' ? marker : null,
  };
  const window = { clearTimeout() {}, setTimeout() {} };
  const document = { addEventListener() {}, querySelector() { return null; } };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8'), { window, document });
  assert.equal(window.toggleBandaAdditional(toggle), false);
  assert.equal(attributes['aria-expanded'], 'true');
  assert.equal(bodyAttributes['aria-hidden'], 'false');
  assert.match(section.className, /\bopen\b/);
  assert.equal(marker.innerText, '−');
  window.toggleBandaAdditional(toggle);
  assert.equal(attributes['aria-expanded'], 'false');
  assert.equal(bodyAttributes['aria-hidden'], 'true');
  assert.doesNotMatch(section.className, /\bopen\b/);
  assert.equal(marker.innerText, '+');
});
test('terminal settings renderer keeps the approved action inventory only', () => {
  const source = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const start = source.indexOf('/datum/preferences/proc/get_banda_terminal_settings_controls()');
  const end = source.indexOf('/datum/preferences/proc/toggle_banda_lobby_character_highlight()', start);
  assert.ok(start >= 0 && end > start);
  const renderer = source.slice(start, end);
  for (const action of [
    'preference=hotkeys', 'preference=viewmacros', 'preference=ui', 'preference=UIcolor', 'preference=UIalpha',
    'preference=customcursors', 'preference=ghost_ears', 'preference=ghost_sight', 'preference=ghost_radio',
    'preference=ghost_spyradio', 'preference=ghost_hivemind', 'preference=lang_chat_disabled',
    'preference=langchat_emotes', 'preference=hear_faxes', 'preference=ghost_vision_pref', 'preference=lobby_music',
    'preference=sound_vox', 'preference=hear_admin_sounds', 'toggle_admin_sound_types', 'preference=ambientocclusion',
    'preference=auto_fit_viewport', 'preference=adaptive_zoom', 'preference=tgui_fancy', 'preference=tgui_lock',
    'preference=window_scale', 'preference=mouse_button_activation', 'switch_item_animations', 'toggle_dualwield',
    'set_eye_blur_type', 'set_flash_type', 'set_crit_type', 'preference=inputcolor', 'preference=hide_statusbar',
    'preference=no_radials_preference', 'preference=no_radial_labels_preference',
    'preference=hear_observer_announcements', 'preference=tooltips',
  ]) assert.match(renderer, new RegExp(action.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  for (const removed of ['preference=inputstyle', 'preference=stylesheet', 'preference=ooc_flag', 'preference=ViewMC', 'preference=publicity', 'receive_random_tip', 'preference=metadata']) {
    assert.doesNotMatch(renderer, new RegExp(removed));
  }
});
test('terminal tabs contain long labels at every configured text size', () => {
  const css = fs.readFileSync(path.join(root, 'assets/character.css'), 'utf8');
  const match = css.match(/a\.prefs-tab, a\.prefs-tab:link, a\.prefs-tab:visited \{([^}]+)\}/);
  assert.ok(match);
  const rule = match[1];
  assert.match(rule, /display:\s*flex/);
  assert.match(rule, /overflow:\s*hidden/);
  assert.match(rule, /white-space:\s*normal/);
  assert.match(rule, /overflow-wrap:\s*break-word/);
  assert.match(rule, /word-wrap:\s*break-word/);
  assert.doesNotMatch(rule, /white-space:\s*nowrap/);

  const renderer = fs.readFileSync(path.join(root, 'code/themes/terminal_character.dm'), 'utf8');
  assert.match(renderer, /for\(var\/list\/tab as anything in get_banda_character_menu_tabs\(\)\)/);
  assert.match(renderer, /preference=change_menu;menu=\[menu_id\]/);
});
test('terminal settings keep labels left and controls right in scoped grids', () => {
  const css = fs.readFileSync(path.join(root, 'assets/character.css'), 'utf8');
  assert.match(css, /\.prefs-settings-column[^\{]*\{[^}]*display:\s*grid[^}]*grid-template-columns:\s*minmax\(0, 1fr\) minmax\(54px, 46%\)/);
  assert.match(css, /\.prefs-settings-column > a:not\(\.prefs-settings-action\)[^\{]*\{[^}]*grid-column:\s*2[^}]*justify-self:\s*end/);
  assert.match(css, /\.prefs-settings-collapsible\.open \.prefs-settings-collapsible-body[^\{]*\{[^}]*display:\s*grid/);
  assert.match(css, /\.prefs-settings-column > br[^\{]*\{[^}]*display:\s*none/);

  const source = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const start = source.indexOf('/datum/preferences/proc/get_banda_interface_preferences_controls()');
  const end = source.indexOf('/datum/preferences/proc/toggle_banda_lobby_character_highlight()', start);
  assert.ok(start >= 0 && end > start);
  const settings = source.slice(start, end);
  assert.equal((settings.match(/class='prefs-settings-column'/g) || []).length, 3);
  assert.equal((settings.match(/class='prefs-settings-action'/g) || []).length, 3);
  for (const action of ['preference=banda_terminal_settings_reset', 'switch_item_animations', 'toggle_dualwield']) {
    const line = settings.split('\n').find(candidate => candidate.includes(action));
    assert.ok(line && line.includes("class='prefs-settings-action'"), action);
  }
});
test('interface selection uses checked persistence and always refreshes explicit choices', () => {
  const controller = fs.readFileSync(path.join(root, 'code/interface_controller.dm'), 'utf8');
  const helperStart = controller.indexOf('/datum/preferences/proc/set_and_save_banda_menu_interface(new_interface)');
  const helperEnd = controller.indexOf('/datum/preferences/proc/get_banda_interface_preferences_controls()', helperStart);
  assert.ok(helperStart >= 0 && helperEnd > helperStart);
  const helper = controller.slice(helperStart, helperEnd);
  assert.match(helper, /if\(save_preferences\(\)\)/);
  assert.match(helper, /set_banda_menu_interface\(previous_interface\)/);

  const verbStart = controller.indexOf('/client/verb/select_banda_menu_interface()');
  const verbEnd = controller.indexOf('/datum/custom_event_info/proc/refresh_banda_lobby_panels()', verbStart);
  assert.ok(verbStart >= 0 && verbEnd > verbStart);
  const verb = controller.slice(verbStart, verbEnd);
  assert.match(verb, /if\(!prefs\.set_and_save_banda_menu_interface\(new_interface\)\)/);
  assert.match(verb, /player\.new_player_panel_proc\(TRUE\)/);
  assert.doesNotMatch(verb, /new_interface == prefs\.banda_menu_interface/);

  const provider = fs.readFileSync(path.join(root, '_lobby_ui.dm'), 'utf8');
  assert.match(provider, /if\(!preferences\.set_and_save_banda_menu_interface\("classic"\)\)/);
  assert.doesNotMatch(provider, /preferences\.set_banda_menu_interface\("classic"\)\s*\n\s*preferences\.save_preferences\(\)/);
});
test('classic renderers remain isolated from terminal resources and state', () => {
  for (const file of ['classic_character.dm', 'classic_lobby.dm']) {
    const source = fs.readFileSync(path.join(root, 'code/themes', file), 'utf8');
    assert.doesNotMatch(source, /get_banda_terminal_styles|banda_saved_character_signature|ensure_banda_character_preview/);
  }
});

test('editor block focus follows glow and clears on exit or window blur', () => {
  function element() {
    const classes = new Set(), attributes = {};
    return {
      className: '', events: {}, children: [],
      classList: { add: name => classes.add(name), remove: name => classes.delete(name), contains: name => classes.has(name) },
      getAttribute: name => attributes[name] || null,
      setAttribute: (name, value) => { attributes[name] = value; },
      appendChild(child) { this.children.push(child); },
      addEventListener(name, handler) { this.events[name] = handler; },
    };
  }
  const blocks = Array.from({ length: 5 }, element), workspace = element(), editor = element();
  workspace.querySelectorAll = () => blocks;
  editor.querySelector = selector => selector === '.prefs-workspace' ? workspace : null;
  let loaded;
  const document = {
    querySelector: selector => selector === '.prefs-crt' ? editor : null,
    createElement: element,
    addEventListener: (_, handler) => { loaded = handler; },
  };
  const window = { events: {}, clearTimeout() {}, setTimeout() {}, addEventListener(name, handler) { this.events[name] = handler; } };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'assets/terminal.js'), 'utf8'), { window, document });
  loaded();
  assert.ok(blocks.every(block => block.children.length === 1 && block.children[0].getAttribute('aria-hidden') === 'true'));
  blocks[0].events.mouseenter.call(blocks[0]);
  assert.ok(workspace.classList.contains('prefs-focus-active'));
  blocks[1].events.mouseenter.call(blocks[1]);
  assert.equal(blocks.filter(block => block.classList.contains('prefs-focus-current')).length, 1);
  assert.ok(blocks[1].classList.contains('prefs-focus-current'));
  blocks[1].events.mouseleave();
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
  blocks[2].events.mouseenter.call(blocks[2]);
  window.events.blur();
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
  editor.classList.add('banda-glow-off');
  blocks[3].events.mouseenter.call(blocks[3]);
  assert.ok(!workspace.classList.contains('prefs-focus-active'));
  editor.classList.remove('banda-glow-off');
  blocks[3].events.mouseenter.call(blocks[3]);
  assert.ok(workspace.classList.contains('prefs-focus-active'));
});
