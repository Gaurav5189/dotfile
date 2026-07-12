-------------------------------------------------------
-- Gestures
-------------------------------------------------------

-- 3-Finger Horizontal Swipe to Switch Workspaces
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- NOTE: The "vertical" workspace rule and "scroll_move" rule 
-- have been removed to prevent gesture shadowing.

-- Fullscreen on  
hl.gesture({ fingers = 4, direction = "pinchout", action = function ()
    hl.dispatch(hl.dsp.window.fullscreen({ action="set" })) 
end})

-- Fullscreen off  
hl.gesture({ fingers = 4, direction = "pinchin", action = function ()
    hl.dispatch(hl.dsp.window.fullscreen({ action="unset" })) 
end})
