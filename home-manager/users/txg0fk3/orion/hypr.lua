---- MONITORS ----
hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = "1",
    vrr      = 2,
})
local secondary = {
    output    = "HDMI-A-1",
    mode      = "1920x1080@100",
    position  = "-1080x-600",
    scale     = "1",
    transform = 1,
}
hl.monitor(secondary)

---- WINDOWS AND WORKSPACES ----
for i = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "DP-1",
        default = (i == 1)
    })
end

hl.workspace_rule({
    workspace = "11",
    monitor = "HDMI-A-1",
    default = true
})

hl.window_rule({
    name  = "calculator",
    match = { class = "org.gnome.Calculator" },

    size  = {380, 520},
    float = true,
})

hl.window_rule({
    name  = "file-roller",
    match = { class = "org.gnome.FileRoller" },

    size  = {800, 560},
    float = true,
})

hl.window_rule({
    name  = "cryptomator",
    match = { class = "org.cryptomator.Cryptomator" },

    size  = {760, 520},
    float = true,
})

hl.window_rule({
    name  = "localsend",
    match = { class = "^(org\\.localsend\\.localsend_app|localsend)$" },

    size  = {800, 600},
    float = true,
})

hl.window_rule({
    name  = "mousai",
    match = { class = "io.github.seadve.Mousai" },

    size  = {400, 480},
    float = true,
})

hl.window_rule({
    name  = "satty",
    match = { class = "com.gabm.satty" },

    size  = {1280, 720},
    float = true,
})

---- KEYBINDINGS ----
local secondaryOff = string.format(
    'hl.monitor({ output = \\"%s\\", disabled = true })',
    secondary.output
)
hl.bind("ALT + Z",            hl.dsp.exec_cmd("gsr-ui-cli toggle-show"))
hl.bind("SUPER + F7",         hl.dsp.exec_cmd("kitty bluetui", { float = true, size = {800, 560} }))
hl.bind("SUPER + SHIFT + F7", hl.dsp.exec_cmd("kitty nmtui",   { float = true, size = {512, 512} }))
hl.bind("SUPER + F8",         hl.dsp.exec_cmd(
    "sh -c 'if hyprctl monitors | grep -q \"^Monitor " .. secondary.output .. " \"; then hyprctl eval \"" .. secondaryOff .. "\"; else hyprctl reload; fi'"
))
hl.bind("SUPER + F9",         hl.dsp.exec_cmd("sh -c 'if systemctl --user is-active --quiet syncthing.service; then systemctl --user stop syncthing.service; else systemctl --user start syncthing.service; fi && pkill -RTMIN+11 waybar'"))
