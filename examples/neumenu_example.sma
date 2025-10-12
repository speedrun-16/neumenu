/**
 * @brief neumenu example
 *
 * This plugin demonstrates all features of the neumenu library including:
 * - Basic menus with individual callbacks
 * - Paginated menus with automatic page navigation
 * - Generic callbacks for multiple items
 * - Selection markers for currently selected items
 * - Menu reopening with preserved state
 * - Labels and separators for visual organization
 * - Data packing for passing multiple values
 * - Custom exit callbacks
 * - Selection sounds
 * - Dynamic menu updates
 *
 * Commands:
 * - say /menu     : Opens main menu demonstrating all features
 * - say /weapons  : Opens weapon selection menu (individual callbacks)
 * - say /settings : Opens settings menu (generic callback + reopen)
 * - say /items    : Opens paginated item browser
 * - say /advanced : Opens advanced features demo
 *
 * Version: 1.0
 * Author: PWNED
 */

#include <amxmodx>
#include <amxmisc>
#include <neumenu>

#pragma semicolon 1

// =============================================================================
// PLUGIN INFORMATION
// =============================================================================

#define PLUGIN_NAME     "Neumenu Example"
#define PLUGIN_VERSION  "1.0"
#define PLUGIN_AUTHOR   "PWNED"

// =============================================================================
// SETTINGS ENUM
// =============================================================================

enum player_settings
{
    SETTING_SOUND,
    SETTING_HUD,
    SETTING_MESSAGES,
    SETTING_AUTOBUY,
    SETTING_NOTIFICATIONS
};

// =============================================================================
// GLOBAL VARIABLES
// =============================================================================

// player settings storage
new bool:g_player_sound[MAX_PLAYERS + 1];
new bool:g_player_hud[MAX_PLAYERS + 1];
new bool:g_player_messages[MAX_PLAYERS + 1];
new bool:g_player_autobuy[MAX_PLAYERS + 1];
new bool:g_player_notifications[MAX_PLAYERS + 1];

// player selected weapon
new g_player_selected_weapon[MAX_PLAYERS + 1];

// =============================================================================
// PLUGIN INITIALIZATION
// =============================================================================

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    // register commands
    register_clcmd("say /menu", "@cmd_main_menu");
    register_clcmd("say /weapons", "@cmd_weapon_menu");
    register_clcmd("say /settings", "@cmd_settings_menu");
    register_clcmd("say /items", "@cmd_item_browser");
    register_clcmd("say /advanced", "@cmd_advanced_menu");
}

public client_putinserver(id)
{
    // initialize player settings
    g_player_sound[id] = true;
    g_player_hud[id] = true;
    g_player_messages[id] = true;
    g_player_autobuy[id] = false;
    g_player_notifications[id] = true;
    g_player_selected_weapon[id] = 1;  // AK-47
}

// =============================================================================
// EXAMPLE 1: MAIN MENU (Basic Menu with Individual Callbacks)
// =============================================================================

@cmd_main_menu(id)
{
    @show_main_menu(id);
    return PLUGIN_HANDLED;
}

@show_main_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\yNEUMENU Demo - Main Menu^n\dChoose a demo to see different features",
        .reopen_callback = "@show_main_menu",
        .exit_callback = "@on_main_menu_exit"
    );

    // add menu items with specific callbacks
    neu_menu_add_item(menu, "Weapon Selection Demo", .callback = "@cmd_weapon_menu");
    neu_menu_add_item(menu, "Settings Demo \d(Generic Callback)", .callback = "@cmd_settings_menu");
    neu_menu_add_item(menu, "Paginated Browser Demo", .callback = "@cmd_item_browser");
    neu_menu_add_item(menu, "Advanced Features Demo", .callback = "@cmd_advanced_menu");

    neu_menu_add_separator(menu);
    neu_menu_add_label(menu, "\dInformation");
    neu_menu_add_item(menu, "About This Plugin", .callback = "@show_about");

    neu_menu_display(menu, id);
}

@show_about(id, data)
{
    client_print(id, print_console, "========================================");
    client_print(id, print_console, "Neumenu Example Plugin v%s", PLUGIN_VERSION);
    client_print(id, print_console, "========================================");
    client_print(id, print_console, "");
    client_print(id, print_console, "This plugin demonstrates all features of the neumenu library:");
    client_print(id, print_console, "- Individual and generic callbacks");
    client_print(id, print_console, "- Pagination with automatic page navigation");
    client_print(id, print_console, "- Selection markers and custom sounds");
    client_print(id, print_console, "- Menu reopening with preserved state");
    client_print(id, print_console, "- Labels, separators, and data packing");
    client_print(id, print_console, "");
    client_print(id, print_console, "Commands:");
    client_print(id, print_console, "  /menu     - Main menu");
    client_print(id, print_console, "  /weapons  - Weapon selection");
    client_print(id, print_console, "  /settings - Settings with generic callback");
    client_print(id, print_console, "  /items    - Paginated item browser");
    client_print(id, print_console, "  /advanced - Advanced features");
    client_print(id, print_console, "========================================");

    client_print_color(id, print_team_default, "^3[neumenu]^1 Information printed to console");
}

@on_main_menu_exit(id)
{
    client_print_color(id, print_team_default, "^3[neumenu]^1 Thanks for checking out the demo!");
}

// =============================================================================
// EXAMPLE 2: WEAPON MENU (Individual Callbacks + Selection Markers)
// =============================================================================

@cmd_weapon_menu(id)
{
    @show_weapon_menu(id);
    return PLUGIN_HANDLED;
}

@show_weapon_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\yWeapon Selection Menu^n\dSelect your preferred weapon",
        .reopen_callback = "@show_weapon_menu",
        .selection_marker = "•",  // custom bullet point marker
        .selection_sound = "buttons/button9.wav"
    );

    // add label
    neu_menu_add_label(menu, "\dRifles");

    // add weapons with selection markers
    neu_menu_add_item(menu, "AK-47 \d($2700)",
                     .callback = "@select_weapon",
                     .data = 1,
                     .selected = (g_player_selected_weapon[id] == 1),
                     .reopen = true);

    neu_menu_add_item(menu, "M4A1 \d($3100)",
                     .callback = "@select_weapon",
                     .data = 2,
                     .selected = (g_player_selected_weapon[id] == 2),
                     .reopen = true);

    neu_menu_add_item(menu, "AUG \d($3500)",
                     .callback = "@select_weapon",
                     .data = 3,
                     .selected = (g_player_selected_weapon[id] == 3),
                     .reopen = true);

    neu_menu_add_separator(menu);
    neu_menu_add_label(menu, "\dSniper Rifles");

    neu_menu_add_item(menu, "AWP \d($4750)",
                     .callback = "@select_weapon",
                     .data = 4,
                     .selected = (g_player_selected_weapon[id] == 4),
                     .reopen = true);

    neu_menu_add_item(menu, "Scout \d($2750)",
                     .callback = "@select_weapon",
                     .data = 5,
                     .selected = (g_player_selected_weapon[id] == 5),
                     .reopen = true);

    neu_menu_add_separator(menu);
    neu_menu_add_item(menu, "Back to Main Menu", .callback = "@back_to_main");

    neu_menu_display(menu, id);
}

@select_weapon(id, weapon_id)
{
    g_player_selected_weapon[id] = weapon_id;

    new const weapon_names[][] = {
        "",  // index 0 unused
        "AK-47",
        "M4A1",
        "AUG",
        "AWP",
        "Scout"
    };

    client_print_color(id, print_team_default, "^3[Weapon]^1 You selected: ^3%s", weapon_names[weapon_id]);
}

@back_to_main(id, data)
{
    @show_main_menu(id);
}

// =============================================================================
// EXAMPLE 3: SETTINGS MENU (Generic Callback + Menu Reopening)
// =============================================================================

@cmd_settings_menu(id)
{
    @show_settings_menu(id);
    return PLUGIN_HANDLED;
}

@show_settings_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\ySettings Menu^n\dToggle your preferences",
        .generic_callback = "@handle_setting_toggle",  // all items use this callback
        .reopen_callback = "@show_settings_menu"
    );

    // all items use the generic callback and reopen the menu after selection
    neu_menu_add_item(menu,
                     fmt("Sound Effects: %s", g_player_sound[id] ? "\yON" : "\rOFF"),
                     .data = _:SETTING_SOUND,
                     .reopen = true);

    neu_menu_add_item(menu,
                     fmt("HUD Display: %s", g_player_hud[id] ? "\yON" : "\rOFF"),
                     .data = _:SETTING_HUD,
                     .reopen = true);

    neu_menu_add_item(menu,
                     fmt("Chat Messages: %s", g_player_messages[id] ? "\yON" : "\rOFF"),
                     .data = _:SETTING_MESSAGES,
                     .reopen = true);

    neu_menu_add_item(menu,
                     fmt("Auto Buy: %s", g_player_autobuy[id] ? "\yON" : "\rOFF"),
                     .data = _:SETTING_AUTOBUY,
                     .reopen = true);

    neu_menu_add_item(menu,
                     fmt("Notifications: %s", g_player_notifications[id] ? "\yON" : "\rOFF"),
                     .data = _:SETTING_NOTIFICATIONS,
                     .reopen = true);

    neu_menu_add_separator(menu);
    neu_menu_add_item(menu, "Back to Main Menu", .callback = "@back_to_main");

    neu_menu_display(menu, id);
}

// generic callback receives: id, key, data
@handle_setting_toggle(id, key, data)
{
    new const setting_names[][] = {
        "Sound Effects",
        "HUD Display",
        "Chat Messages",
        "Auto Buy",
        "Notifications"
    };

    // toggle the setting based on data
    switch (player_settings:data)
    {
        case SETTING_SOUND:
        {
            g_player_sound[id] = !g_player_sound[id];
            client_print_color(id, print_team_default, "^3[Settings]^1 %s: ^3%s",
                             setting_names[data], g_player_sound[id] ? "ON" : "OFF");
        }
        case SETTING_HUD:
        {
            g_player_hud[id] = !g_player_hud[id];
            client_print_color(id, print_team_default, "^3[Settings]^1 %s: ^3%s",
                             setting_names[data], g_player_hud[id] ? "ON" : "OFF");
        }
        case SETTING_MESSAGES:
        {
            g_player_messages[id] = !g_player_messages[id];
            client_print_color(id, print_team_default, "^3[Settings]^1 %s: ^3%s",
                             setting_names[data], g_player_messages[id] ? "ON" : "OFF");
        }
        case SETTING_AUTOBUY:
        {
            g_player_autobuy[id] = !g_player_autobuy[id];
            client_print_color(id, print_team_default, "^3[Settings]^1 %s: ^3%s",
                             setting_names[data], g_player_autobuy[id] ? "ON" : "OFF");
        }
        case SETTING_NOTIFICATIONS:
        {
            g_player_notifications[id] = !g_player_notifications[id];
            client_print_color(id, print_team_default, "^3[Settings]^1 %s: ^3%s",
                             setting_names[data], g_player_notifications[id] ? "ON" : "OFF");
        }
    }

    // menu automatically reopens due to .reopen = true
}

// =============================================================================
// EXAMPLE 4: PAGINATED ITEM BROWSER (Pagination Demo)
// =============================================================================

@cmd_item_browser(id)
{
    @show_item_browser(id);
    return PLUGIN_HANDLED;
}

@show_item_browser(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\yItem Browser",
        .reopen_callback = "@show_item_browser",
        .paginated = true,         // enable pagination
        .items_per_page = 7        // 7 items per page (keys 8/9 for navigation)
    );

    // add many items - pagination automatically creates pages
    neu_menu_add_label(menu, "\dAll Items");

    for (new i = 1; i <= 50; i++)
    {
        neu_menu_add_item(menu,
                         fmt("Item #%d \d(Value: %d)", i, i * 100),
                         .callback = "@select_item",
                         .data = i);
    }

    neu_menu_add_separator(menu);
    neu_menu_add_item(menu, "Back to Main Menu", .callback = "@back_to_main");

    neu_menu_display(menu, id);
}

@select_item(id, item_id)
{
    client_print_color(id, print_team_default, "^3[Browser]^1 You selected Item #^3%d^1 (Value: ^3%d^1)",
                      item_id, item_id * 100);
}

// =============================================================================
// EXAMPLE 5: ADVANCED FEATURES (Data Packing + Dynamic Updates)
// =============================================================================

@cmd_advanced_menu(id)
{
    @show_advanced_menu(id);
    return PLUGIN_HANDLED;
}

@show_advanced_menu(id)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\yAdvanced Features Demo",
        .reopen_callback = "@show_advanced_menu"
    );

    neu_menu_add_label(menu, "\dData Packing Demo");
    neu_menu_add_label(menu, "\dClick items to see multiple values unpacked");
    neu_menu_add_separator(menu);

    // pack multiple values into a single data parameter
    // format: neu_pack_data(byte0, byte1, byte2, byte3)
    new packed_data_1 = neu_pack_data(10, 20, 30, 40);
    neu_menu_add_item(menu, "Item A \d(4 values packed)", .callback = "@show_packed_data", .data = packed_data_1);

    new packed_data_2 = neu_pack_data(100, 150, 200, 250);
    neu_menu_add_item(menu, "Item B \d(4 values packed)", .callback = "@show_packed_data", .data = packed_data_2);

    new packed_data_3 = neu_pack_data(5, 10, 15, 20);
    neu_menu_add_item(menu, "Item C \d(4 values packed)", .callback = "@show_packed_data", .data = packed_data_3);

    neu_menu_add_separator(menu);
    neu_menu_add_label(menu, "\dOther Features");

    neu_menu_add_item(menu, "Disabled Item Example", .enabled = false);
    neu_menu_add_item(menu, "Test Custom Exit Callback", .callback = "@test_exit_callback");

    neu_menu_add_separator(menu);
    neu_menu_add_item(menu, "Back to Main Menu", .callback = "@back_to_main");

    neu_menu_display(menu, id);
}

@show_packed_data(id, packed_data)
{
    // unpack the 4 bytes from the integer
    new byte0 = neu_unpack_byte(packed_data, 0);
    new byte1 = neu_unpack_byte(packed_data, 1);
    new byte2 = neu_unpack_byte(packed_data, 2);
    new byte3 = neu_unpack_byte(packed_data, 3);

    client_print_color(id, print_team_default, "^3[Data Packing]^1 Unpacked values:");
    client_print_color(id, print_team_default, "^3[Data Packing]^1 Byte 0: ^3%d^1 | Byte 1: ^3%d^1 | Byte 2: ^3%d^1 | Byte 3: ^3%d",
                      byte0, byte1, byte2, byte3);

    client_print(id, print_console, "========================================");
    client_print(id, print_console, "Data Packing Demo");
    client_print(id, print_console, "========================================");
    client_print(id, print_console, "Packed Data: %d", packed_data);
    client_print(id, print_console, "Unpacked Values:");
    client_print(id, print_console, "  Byte 0: %d", byte0);
    client_print(id, print_console, "  Byte 1: %d", byte1);
    client_print(id, print_console, "  Byte 2: %d", byte2);
    client_print(id, print_console, "  Byte 3: %d", byte3);
    client_print(id, print_console, "========================================");
}

@test_exit_callback(id, data)
{
    new menu = neu_menu_create(
        .player_id = id,
        .title = "\yExit Callback Demo^n\dPress 0 to exit and trigger callback",
        .exit_callback = "@custom_exit_handler"
    );

    neu_menu_add_label(menu, "\dThis menu has a custom exit callback");
    neu_menu_add_label(menu, "\dPress 0 to see it in action!");

    neu_menu_display(menu, id);
}

@custom_exit_handler(id)
{
    client_print_color(id, print_team_default, "^3[Exit Callback]^1 Custom exit handler triggered!");
    client_print_color(id, print_team_default, "^3[Exit Callback]^1 You can use this for cleanup or notifications.");
}
