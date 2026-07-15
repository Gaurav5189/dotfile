hl.config({
    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
        disable_splash_rendering = true,
        initial_workspace_tracking = 1,
        on_focus_under_fullscreen = 1,
        allow_session_lock_restore = true
    },
    binds = {
        -- Pass mouse events to apps even when a keybind is triggered.
        -- Required for drag-and-drop to work in native Wayland Electron apps (e.g. Antigravity IDE).
        pass_mouse_when_bound = true,
    },
})
