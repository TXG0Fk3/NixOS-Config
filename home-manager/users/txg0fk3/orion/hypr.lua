---- MONITORS ----
hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = "1",
    vrr      = 2,
})
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@100",
    position = "-1080x-600",
    scale    = "1",
    transform = 1,
})

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
    name  = "steam-tearing",
    match = { class = "^steam_app_[0-9]+$" },

    immediate = true,
})

hl.window_rule({
    name  = "calculator",
    match = { class = "org.gnome.Calculator" },

    size  = {380, 520},
    float = true,
})

hl.window_rule({
    name  = "solanum",
    match = { class = "org.gnome.Solanum" },

    size  = {360, 420},
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
