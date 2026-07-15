-- Satty Annotation Utility Layout Rules
hl.window_rule({
    match = { class = "com.gabm.satty" },
    float = true,
    center = true,
    size = "1000 650",
    max_size = { 1000, 650 }
})

-- Quickshell Windows Blur
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true, ignore_alpha = 0.2 })

