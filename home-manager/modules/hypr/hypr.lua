---- LOOK AND FEEL ----
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border   = "rgba(ffffffff)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing = true,

        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
    },
    animations = {
        enabled = true,
    },
    group = {
        col = {
            border_active = "rgba(ffffffff)",
            border_inactive = "rgba(595959aa)",
            border_locked_active = "rgba(00feffff)",
            border_locked_inactive = "rgba(595959aa)",
        },
        groupbar = {
            enabled = true,
            font_family = "JetBrainsMono Nerd Font",
            font_size = 10,
            gradients = false,
            rounding = 0,
            gradient_rounding = 0,
            height = 14,
            text_color = "rgba(ffffffff)",
            text_color_inactive = "rgba(595959aa)",
            text_color_locked_active = "rgba(00feffff)",
            text_color_locked_inactive = "rgba(595959aa)",
            col = {
                active = "rgba(ffffffff)",
                inactive = "rgba(595959aa)",
                locked_active = "rgba(00feffff)",
                locked_inactive = "rgba(595959aa)",
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
        preserve_split = true, -- You probably want this
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
        force_default_wallpaper = 1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})



---- INPUT ----
hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "abnt2",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = -0.5, -- -1.0 - 1.0, 0 means no modification.
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

-- Walpaper
hl.bind("SUPER + W", hl.dsp.exec_cmd([[
    wpppath=$(zenity --file-selection --title="Select a Wallpaper" --file-filter="Pictures | *.png *.jpg *.jpeg *.gif")
    wppdest="$HOME/.config/background"
    if [ -n "$wpppath" ]; then
        cp "$wpppath" "$wppdest" && awww img "$wppdest"
    fi
]]))

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("sh -c 'hyprshot -m output -o \"$(xdg-user-dir PICTURES)/Screenshots\"'"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("sh -c 'hyprshot -m window -o \"$(xdg-user-dir PICTURES)/Screenshots\"'"))
hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("sh -c 'hyprshot -m region -o \"$(xdg-user-dir PICTURES)/Screenshots\"'"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("screen-annotate"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move Windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Switch with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces on current monitor with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))

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

-- Requires playerctl
hl.bind("CONTROL + ALT + Q",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("CONTROL + ALT + W", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("CONTROL + ALT + E",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Volume OSD
hl.bind("CONTROL + ALT + A",     hl.dsp.exec_cmd("volume-osd down"), { locked = true, repeating = true })
hl.bind("CONTROL + ALT + S",     hl.dsp.exec_cmd("volume-osd mute"), { locked = true })
hl.bind("CONTROL + ALT + D",     hl.dsp.exec_cmd("volume-osd up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("volume-osd down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("volume-osd mute"), { locked = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("volume-osd up"),   { locked = true, repeating = true })



---- WINDOWS AND WORKSPACES ----
local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
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
    name  = "pinned-border",
    match = { pin = true },

    border_color = "rgba(00feffff)",
})

hl.window_rule({
    name  = "scratchpad-border",
    match = { workspace = "special:magic" },

    border_color = "rgba(00feffff)",
})

hl.layer_rule({
    name    = "rofi",
    match   = { namespace = "^rofi$" },

    no_anim = true,
})
