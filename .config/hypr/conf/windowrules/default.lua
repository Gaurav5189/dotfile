-- Satty Annotation Utility Layout Rules
hl.window_rule({
    match = { class = "com.gabm.satty" },
    float = true,
    center = true,
    size = "1000 650",
    max_size = { 1000, 650 }
})

-- Quickshell & SwayNC Windows Blur
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.2 })

