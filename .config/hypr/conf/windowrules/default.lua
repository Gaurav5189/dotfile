-- Satty Annotation Utility Layout Rules
hl.window_rule({
    match = { class = "com.gabm.satty" },
    float = true,
    center = true,
    size = "1000 650",
    max_size = { 1000, 650 }
})

-- Display Manager (nwg-displays) Floating Rule
hl.window_rule({
    match = { class = "nwg-displays" },
    float = true,
    center = true
})

-- Quickshell & SwayNC Windows Blur
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.2 })

