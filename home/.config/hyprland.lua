------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "DP-1", mode = "1920x1080@239.76Hz", position = "auto", scale = "1" })
hl.monitor({ output = "DP-2", mode = "preffered", position = "auto-left", scale = "1" })


---------------------
---- MY PROGRAMS ----
---------------------

local mainMod     = "SUPER"
local terminal    = "ghostty"
local fileManager = "dolphin"
local menu        = "wofi --show drun"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 3,

        col = {
            --active_border   = "rgba(6b9e78ff)",
            active_border =  "rgba(d8b64aff)",
            inactive_border = "rgba(595959ff)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 0,
        rounding_power = 0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = false,
    },
})

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
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "eu",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:escape",
        kb_rules   = "",

        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = false,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})

hl.env("XCURSOR_THEME", "Adwaita")

-- Per-device config
hl.device({
    name        = "iwm-5000-mouse",
    sensitivity = 0,
    natural_scroll = true,
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Core
hl.bind(mainMod .. " + RETURN",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim ~/Pictures/Screenshots/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"))
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Colorpick
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("hyprpicker"))

-- Focus movement (vim-style)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize with keyboard
hl.bind(mainMod .. " + SHIFT + L", function() hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch resizeactive 10 0"))   end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + H", function() hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch resizeactive -10 0"))  end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", function() hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -10"))  end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", function() hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 10"))   end, { repeating = true })

-- Volume & brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                   { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

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
    name      = "hyprlauncher-border",
    match     = { class = "^(hyprlauncher)$" },
    border_size = 5,
})

hl.window_rule({
    name      = "discord-workspace",
    match     = { class = "^(discord)$" },
    workspace = 5,
})

hl.window_rule({
    name      = "steam-workspace",
    match     = { class = "^(steam)$" },
    workspace = 6,
})
