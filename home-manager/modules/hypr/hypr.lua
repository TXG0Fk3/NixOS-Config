---- LOOK AND FEEL ----
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border   = rgba(colors.fg),
            inactive_border = rgba(colors.dim, "aa"),
        },

        resize_on_border = false,
        allow_tearing = true,

        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
    },
    animations = {
        enabled = true,
    },
    group = {
        col = {
            border_active = rgba(colors.fg),
            border_inactive = rgba(colors.dim, "aa"),
            border_locked_active = rgba(colors.accent),
            border_locked_inactive = rgba(colors.dim, "aa"),
        },
        groupbar = {
            enabled = true,
            font_family = "JetBrainsMono Nerd Font",
            font_size = 10,
            gradients = false,
            rounding = 0,
            gradient_rounding = 0,
            height = 14,
            indicator_height = 2,
            text_color = rgba(colors.fg),
            text_color_inactive = rgba(colors.dim, "aa"),
            text_color_locked_active = rgba(colors.accent),
            text_color_locked_inactive = rgba(colors.dim, "aa"),
            col = {
                active = rgba(colors.fg),
                inactive = rgba(colors.dim, "aa"),
                locked_active = rgba(colors.accent),
                locked_inactive = rgba(colors.dim, "aa"),
            },
        },
    },
})

hl.curve("snappy", { type = "bezier", points = { {0.2, 1}, {0.25, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "border",        enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "windows",       enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 2,   bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.5, bezier = "snappy", style = "popin 95%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5, bezier = "snappy" })
hl.animation({ leaf = "layers",        enabled = true, speed = 2,   bezier = "snappy", style = "fade" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2,   bezier = "snappy", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5, bezier = "snappy", style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2,   bezier = "snappy", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 2,   bezier = "snappy", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2,   bezier = "snappy", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 2,   bezier = "snappy" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})



----  MISC  ----
hl.config({
    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo   = true,
    },
    render = {
        direct_scanout = 2,
    },
})



---- INPUT ----
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "altgr-intl",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = -0.5,
    },
})



---- KEYBINDINGS ----
local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("power-menu"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- nautilus"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("rofimoji --action type"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("wl-copy --clear && wl-copy --primary --clear && cliphist wipe"))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + CONTROL + F", hl.dsp.window.fullscreen_state({ action = "toggle", internal = 0, client = 2 }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("edged"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("screen-ocr"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + Y", hl.dsp.window.pin())
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit"))

-- Groups
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mainMod .. " + CONTROL + G", hl.dsp.group.lock({ action = "toggle" }))
hl.bind(mainMod .. " + CONTROL + H", hl.dsp.window.move({ into_group = "left" }))
hl.bind(mainMod .. " + CONTROL + J", hl.dsp.window.move({ into_group = "down" }))
hl.bind(mainMod .. " + CONTROL + K", hl.dsp.window.move({ into_group = "up" }))
hl.bind(mainMod .. " + CONTROL + L", hl.dsp.window.move({ into_group = "right" }))
hl.bind(mainMod .. " + CONTROL + Left", hl.dsp.window.move({ into_group = "left" }))
hl.bind(mainMod .. " + CONTROL + Down", hl.dsp.window.move({ into_group = "down" }))
hl.bind(mainMod .. " + CONTROL + Up", hl.dsp.window.move({ into_group = "up" }))
hl.bind(mainMod .. " + CONTROL + Right", hl.dsp.window.move({ into_group = "right" }))
hl.bind(mainMod .. " + CONTROL + U", hl.dsp.window.move({ out_of_group = true }))

-- Wallpaper
hl.bind("SUPER + W", hl.dsp.exec_cmd([[
    wpppath=$(zenity --file-selection --title="Select a Wallpaper" --file-filter="Pictures | *.png *.jpg *.jpeg *.gif")
    wppdest="$HOME/.config/background"
    if [ -n "$wpppath" ]; then
        cp "$wpppath" "$wppdest" && awww img "$wppdest"
    fi
]]))

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("sh -c 'hyprshot -m output -z -o \"$(xdg-user-dir PICTURES)/Screenshots\"'"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("sh -c 'hyprshot -m window -z -o \"$(xdg-user-dir PICTURES)/Screenshots\"'"))
hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("sh -c 'hyprshot -m region -z -o \"$(xdg-user-dir PICTURES)/Screenshots\"'"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("screen-annotate"))

-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move Windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces on current monitor with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + Z",          hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + C",          hl.dsp.focus({ workspace = "m+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize submap
hl.bind(mainMod .. " + R", hl.dsp.submap("RESIZE"))

hl.define_submap("RESIZE", function()
    hl.bind("H",     hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
    hl.bind("J",     hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
    hl.bind("K",     hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
    hl.bind("L",     hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })
    hl.bind("Left",  hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
    hl.bind("Down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
    hl.bind("Up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
    hl.bind("Right", hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })

    hl.bind("Escape",          hl.dsp.submap("reset"))
    hl.bind("RETURN",          hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- Media
hl.bind("CONTROL + ALT + Q",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("CONTROL + ALT + W", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("CONTROL + ALT + E",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Notifications
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dunstctl history-pop"))

-- Focus & utilities (F1–F4)
hl.bind(mainMod .. " + F1",           hl.dsp.exec_cmd("focus-mode toggle"))
hl.bind(mainMod .. " + SHIFT + F1",   hl.dsp.exec_cmd("focus-mode next"))
hl.bind(mainMod .. " + CONTROL + F1", hl.dsp.exec_cmd("focus-mode long-break"))
hl.bind(mainMod .. " + F2",           hl.dsp.exec_cmd("sh -c 'dunstctl set-paused toggle && pkill -RTMIN+8 waybar'"))
hl.bind(mainMod .. " + F3",           hl.dsp.exec_cmd("sh -c 'if pkill -x hyprsunset; then while pgrep -x hyprsunset >/dev/null; do sleep 0.01; done; else hyprsunset -t 3500 </dev/null >/dev/null 2>&1 & fi && pkill -RTMIN+9 waybar'"))
hl.bind(mainMod .. " + F4",           hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

-- Volume OSD
hl.bind("CONTROL + ALT + A",     hl.dsp.exec_cmd("volume-osd down"), { locked = true, repeating = true })
hl.bind("CONTROL + ALT + S",     hl.dsp.exec_cmd("volume-osd mute"), { locked = true })
hl.bind("CONTROL + ALT + D",     hl.dsp.exec_cmd("volume-osd up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("volume-osd down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("volume-osd mute"), { locked = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("volume-osd up"),   { locked = true, repeating = true })



---- WINDOWS AND WORKSPACES ----
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "pip",
    match = { title = "^Picture-in-Picture$" },

    size  = {480, 270},
    float = true,
    pin   = true,
})

hl.window_rule({
    name  = "file-picker-portal",
    match = { class = "^(xdg-desktop-portal-gtk|org\\.freedesktop\\.impl\\.portal\\.desktop\\.gtk|zenity)$" },

    size   = {900, 600},
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "file-picker-dialog",
    match = { title = "^(Open File|Open Files|Open Folder|Save File|Save As|Select a Wallpaper|Choose Files).*$" },

    size   = {900, 600},
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "pinned-border",
    match = { pin = true },

    border_color = rgba(colors.accent),
})

hl.window_rule({
    name  = "scratchpad-border",
    match = { workspace = "special:magic" },

    border_color = rgba(colors.accent),
})

hl.layer_rule({
    name    = "rofi",
    match   = { namespace = "^rofi$" },

    no_anim = true,
})

hl.window_rule({
    name  = "no-screen-share-sensitive",
    match = { class = "^(hyprpolkitagent|org\\.cryptomator\\.Cryptomator|Bitwarden|org\\.keepassxc\\.KeePassXC|1Password)$" },

    no_screen_share = true,
})

hl.layer_rule({
    name    = "no-screen-share-dunst",
    match   = { namespace = "^(notifications|dunst)$" },

    no_screen_share = true,
})
