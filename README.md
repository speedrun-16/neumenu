# neumenu
![Author](https://img.shields.io/badge/Author-PWNED-8cf?style=for-the-badge "Author") ![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge "Version")

A modern, feature rich menu system for AMX Mod X with support for pagination, dynamic callbacks, selection markers and flexible item management.

## ☰ Features

- **Per-player menu instances** with independent state management
- **Automatic pagination** with configurable items per page
- **Hybrid callback system** - use item-specific or menu-wide generic callbacks
- **Non-selectable labels and separators** for visual organization
- **Custom selection markers** for currently selected items (example: `•`, `►`)
- **Configurable selection sounds** with auto-prevention for already-selected items
- **Automatic key management** and page navigation (keys 8/9 for Back/Next)
- **Menu reopening support** with preserved pagination state
- **Data packing utilities** for passing multiple values via item data
- **Auto-exit option** with customizable exit callbacks

## ☰ Installation

- Copy `neumenu.inc` to your AMX Mod X `include/` directory
- Include it in your plugin:
   ```pawn
   #include <neumenu>
   ```

## ☰ Quick Start

### Basic Menu with Individual Callbacks

```pawn
public show_weapon_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\yWeapon Menu",
        .reopen_callback = "@show_weapon_menu"
    );

    neu_menu_add_item(menu, "AK-47", .callback = "@select_weapon", .data = CSW_AK47);
    neu_menu_add_item(menu, "M4A1", .callback = "@select_weapon", .data = CSW_M4A1);
    neu_menu_add_item(menu, "AWP", .callback = "@select_weapon", .data = CSW_AWP);

    neu_menu_display(menu, id);
}

@select_weapon(id, weapon_id)
{
    // give the player the selected weapon
    give_item(id, weapon_id);
    client_print_color(id, print_team_default, "^3[Menu]^1 You selected weapon ID: ^3%d", weapon_id);
}
```

### Paginated Menu with Generic Callback

```pawn
public show_settings_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\ySettings Menu",
        .generic_callback = "@handle_setting_toggle",
        .reopen_callback = "@show_settings_menu",
        .paginated = true,
        .items_per_page = 7
    );

    neu_menu_add_item(menu, fmt("Sound: %s", g_player_sound[id] ? "\yON" : "\rOFF"), .data = SETTING_SOUND, .reopen = true);
    neu_menu_add_item(menu, fmt("HUD: %s", g_player_hud[id] ? "\yON" : "\rOFF"), .data = SETTING_HUD, .reopen = true);
    neu_menu_add_item(menu, fmt("Messages: %s", g_player_msgs[id] ? "\yON" : "\rOFF"), .data = SETTING_MSGS, .reopen = true);

    neu_menu_display(menu, id);
}

@handle_setting_toggle(id, key, data)
{
    switch (data)
    {
        case SETTING_SOUND: g_player_sound[id] = !g_player_sound[id];
        case SETTING_HUD: g_player_hud[id] = !g_player_hud[id];
        case SETTING_MSGS: g_player_msgs[id] = !g_player_msgs[id];
    }
}
```

## ☰ Core API Reference

### Menu Creation

#### `neu_menu_create()`

Creates a new menu instance for a player.

```pawn
stock neu_menu_create(
    player_id,                      // player index (1-32)
    const title[],                  // menu title (supports color codes: \y, \r, \d, \w)
    timeout = -1,                   // menu timeout in seconds (-1 = no timeout)
    bool:auto_exit = true,          // add exit option
    bool:paginated = false,         // enable pagination
    items_per_page = 7,             // items per page (default: 7)
    const generic_callback[] = "",  // optional: callback for all items
    const reopen_callback[] = "",   // optional: callback to rebuild menu
    const exit_callback[] = "",     // optional: callback when exiting
    const selection_marker[] = "",  // optional: custom marker (e.g., "•")
    const selection_sound[] = ""    // optional: custom sound file
)
```

**Returns:** Menu handle (player_id)

**Example:**
```pawn
new menu = neu_menu_create(
    .player_id = id,
    .title = "\yMain Menu",
    .paginated = true,
    .selection_marker = "►"
);
```

### Adding Items

#### `neu_menu_add_item()`

Adds a selectable item to the menu.

```pawn
stock neu_menu_add_item(
    menu_id,                    // menu handle
    const text[],               // item text (supports color codes)
    const callback[] = "",      // callback function name
    data = 0,                   // custom integer data
    bool:enabled = true,        // whether item is selectable
    bool:reopen = false,        // reopen menu after selection
    bool:selected = false       // show selection marker
)
```

**Returns:** Item index, or -1 on failure

**Callback Signatures:**
- **Item-specific callback:** `@callback(id, data)`
- **Generic callback:** `@callback(id, key, data)`

**Example:**
```pawn
// with specific callback
neu_menu_add_item(menu, "Option 1", .callback = "@handle_option1");

// using generic callback (no specific callback needed)
neu_menu_add_item(menu, "Option 2", .data = 2);

// with reopen flag (menu rebuilds after selection)
neu_menu_add_item(menu, "Toggle Setting", .callback = "@toggle", .reopen = true);

// selected item with custom marker
neu_menu_add_item(menu, "Current Selection", .selected = true);
```

#### `neu_menu_add_label()`

Adds a non-selectable text label.

```pawn
stock neu_menu_add_label(menu_id, const text[])
```

**Example:**
```pawn
neu_menu_add_label(menu, "\dWeapons");
neu_menu_add_item(menu, "AK-47", .callback = "@select_weapon");
neu_menu_add_item(menu, "M4A1", .callback = "@select_weapon");
```

#### `neu_menu_add_separator()`

Adds a visual separator (empty line).

```pawn
stock neu_menu_add_separator(menu_id)
```

**Example:**
```pawn
neu_menu_add_item(menu, "Option 1");
neu_menu_add_separator(menu);
neu_menu_add_item(menu, "Option 2");
```

### Displaying Menus

#### `neu_menu_display()`

Displays the menu to the player.

```pawn
stock neu_menu_display(menu_id, player)
```

**Example:**
```pawn
neu_menu_display(menu, id);
```

### Destroying Menus

#### `neu_menu_destroy()`

Destroys a menu and frees resources.

```pawn
stock neu_menu_destroy(menu_id)
```

**Example:**
```pawn
neu_menu_destroy(id);  // destroy menu for player
```

## ☰ Data Packing Utilities

### `neu_pack_data()`

Packs up to 4 bytes (0-255) into a single integer.

```pawn
stock neu_pack_data(byte0 = 0, byte1 = 0, byte2 = 0, byte3 = 0)
```

**Example:**
```pawn
new data = neu_pack_data(weapon_id, ammo_count, team_id, flags);
neu_menu_add_item(menu, "Item", .data = data);
```

### `neu_unpack_byte()`

Extracts a byte from packed data.

```pawn
stock neu_unpack_byte(data, index)  // index: 0-3
```

**Example:**
```pawn
@callback(id, data)
{
    new weapon = neu_unpack_byte(data, 0);
    new ammo = neu_unpack_byte(data, 1);
    new team = neu_unpack_byte(data, 2);
}
```

## ☰ Helper Functions

### `neu_create_simple_menu()`

Quick helper for creating menus with individual callbacks.

```pawn
stock neu_create_simple_menu(
    player,
    const title[],
    const items[][],
    const callbacks[][],
    item_count,
    bool:paginated = false,
    items_per_page = 7
)
```

**Example:**
```pawn
new const items[][] = { "Option 1", "Option 2", "Option 3" };
new const callbacks[][] = { "@cb1", "@cb2", "@cb3" };
neu_create_simple_menu(id, "Menu", items, callbacks, 3);
```

### `neu_create_generic_menu()`

Quick helper for creating menus with a single generic callback.

```pawn
stock neu_create_generic_menu(
    player,
    const title[],
    const items[][],
    item_count,
    const generic_callback[],
    bool:paginated = false,
    items_per_page = 7
)
```

**Example:**
```pawn
new const items[][] = { "Option 1", "Option 2", "Option 3" };
neu_create_generic_menu(id, "Menu", items, 3, "@generic_handler");
```

## ☰ Advanced Features

### Pagination

Automatically splits menus with many items into pages. Navigation uses keys 8 (Back) and 9 (Next).

```pawn
new menu = neu_menu_create(
    .player_id = id,
    .title = "\yItem Browser",
    .paginated = true,
    .items_per_page = 7  // Keys 1-7 for items, 8-9 for navigation
);

// add as many items as needed - pages are created automatically
for (new i = 0; i < 50; i++) {
    neu_menu_add_item(menu, fmt("Item #%d", i + 1), .data = i);
}

neu_menu_display(menu, id);
```

**Page indicator** is automatically shown in title: `Item Browser (Page 2/8)`

### Custom Selection Markers

Highlight currently selected items with custom markers.

```pawn
new menu = neu_menu_create(
    .player_id = id,
    .title = "\yWeapon Selection",
    .selection_marker = "•"  // unicode selection marker
);

neu_menu_add_item(menu, "AK-47", .selected = false);
neu_menu_add_item(menu, "M4A1", .selected = true);   // shows: [•] M4A1
neu_menu_add_item(menu, "AWP", .selected = false);

neu_menu_display(menu, id);
```

**Display:**
```
[1] AK-47
[•] M4A1
[3] AWP
```

### Menu Reopening

Automatically reopen and rebuild menus after item selection (useful for settings menus).

```pawn
@show_settings_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\ySettings",
        .reopen_callback = "@show_settings_menu"  // this function rebuilds menu
    );

    // use .reopen = true to trigger rebuild after selection
    neu_menu_add_item(menu, fmt("Sound: %s", g_sound[id] ? "ON" : "OFF"),
                     .callback = "@toggle_sound",
                     .reopen = true);  // menu reopens after toggle

    neu_menu_display(menu, id);
}

@toggle_sound(id, data)
{
    g_sound[id] = !g_sound[id];
    // menu automatically reopens via reopen_callback
}
```

### Exit Callbacks

Execute custom logic when the player exits the menu.

```pawn
new menu = neu_menu_create(
    .player_id = id,
    .title = "\yMain Menu",
    .exit_callback = "@on_menu_exit"
);

@on_menu_exit(id)
{
    client_print_color(id, print_team_default, "^3[Menu]^1 Thanks for visiting!");
}
```

### Selection Sounds

Play custom sounds when items are selected.

```pawn
new menu = neu_menu_create(
    .player_id = id,
    .title = "\yMenu",
    .selection_sound = "buttons/button9.wav"
);
```

**Note:** Sound is not played if item has `.selected = true` (prevents spam)

### Labels and Separators

Organize menus with visual elements.

```pawn
new menu = neu_menu_create(id, "\yShop Menu");

neu_menu_add_label(menu, "\dPrimary Weapons");
neu_menu_add_item(menu, "AK-47 ($2700)");
neu_menu_add_item(menu, "M4A1 ($3100)");

neu_menu_add_separator(menu);  // empty line

neu_menu_add_label(menu, "\dSecondary Weapons");
neu_menu_add_item(menu, "Desert Eagle ($650)");
neu_menu_add_item(menu, "USP ($500)");

neu_menu_display(menu, id);
```

### Complete Example

See the example plugin `neumenu_example.sma` for a comprehensive demonstration of all features.

## ☰ Color Codes

Use these codes in menu titles and item text:

| Code | Color  |
|------|--------|
| `\y` | Yellow |
| `\r` | Red    |
| `\w` | White  |
| `\d` | Gray   |

## ☰ Limits

- **Non-paginated menus:** Maximum 9 selectable items (keys 1-9)
- **Paginated menus:** Unlimited items (automatically split into pages)
- **Labels:** Do not count toward item limits
- **Max title length:** 256 characters
- **Max menu length:** Defined by `MAX_MENU_LENGTH = 512`

## ☰ Notes

- Each player can have one menu open at a time
- Menu state is preserved during reopens (current page, selections)
- Always call `neu_menu_destroy()` when done to prevent memory leaks
- Labels in paginated menus appear with their following selectable items
- Generic callbacks receive the raw key index, specific callbacks do not

## Author

[PWNED](https://github.com/5z3f)
