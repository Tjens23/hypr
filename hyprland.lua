-- ┌──────────────────────────────────────────────────────────┐
-- │  GRAPHITE  ·  Hyprland rice matched to the Quickshell    │
-- │  theme in ~/.config/quickshell/Theme.qml                 │
-- └──────────────────────────────────────────────────────────┘
-- Wiki: https://wiki.hypr.land/Configuring/Start/

-------------------
---- PALETTE   ----
-------------------
-- Mirrors Theme.qml so the compositor and the shell speak one language.
local C = {
	base = "141414", -- desktop / void
	panel = "1f1f1f", -- Qt.rgba(0.12, 0.12, 0.12) (bar + launcher)
	surface = "2c2c2c", -- islands
	surfaceHover = "363636",
	divider = "3d3d3d",
	textDim = "8a8a8a",
	text = "e6e6e6",
	accent = "ffffff",
	warn = "e5c07b",
	crit = "e06c75",
}
local function rgba(hex, alpha)
	return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

-- Slowly rotating metallic edge on the focused window.
-- Looks great, but forces a redraw every frame; set false to save power.
local shimmer = true

-- Run optional bits without taking the whole config down if an API name
-- differs on your Hyprland build. Failures land in the Hyprland log.
local function try(label, fn)
	local ok, err = pcall(fn)
	if not ok then
		print("[graphite] skipped " .. label .. ": " .. tostring(err))
	end
end

------------------
---- MONITORS ----
------------------

local primaryMonitor = "HDMI-A-1" -- 1080p @ 144Hz, primary
local secondaryMonitor = "HDMI-A-2" -- 4K @ 60Hz, secondary

local secondaryScale = 1.5

hl.monitor({
	output = secondaryMonitor,
	mode = "3840x2160@60",
	position = "0x0",
	scale = secondaryScale,
})

hl.monitor({
	output = primaryMonitor,
	mode = "1920x1080@144",
	position = "2560x0", -- Adjust X based on your scaled BenQ width (3840 / 1.5 = 2560)
	scale = 1,
})

-- Fallback for anything else that gets plugged in
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

-- Workspace 1 always opens on the primary monitor
try("primary workspace rule", function()
	hl.workspace_rule({
		workspace = "1",
		monitor = primaryMonitor,
		default = true,
	})
end)

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "ghostty"
local fileManager = "dolphin"
local launcher = "qs ipc call launcher toggle" -- your Quickshell launcher
local lock = "loginctl lock-session" -- hypridle turns this into hyprlock
local wallpaperPath = "~/.config/hypr/wallpapers/graphite.png"

-- slurp styled like the shell: dim graphite veil, thin text-coloured outline
local slurp = "slurp -b " .. C.base .. "99 -c " .. C.text .. "ff -s 00000000 -w 1"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	-- XWayland apps (Steam, many games) read the primary output from X11
	hl.exec_cmd("xrandr --output " .. primaryMonitor .. " --primary")
	hl.exec_cmd("qs -d") -- bar, launcher, wallpaper
	hl.exec_cmd("hypridle")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'FiraCode Nerd Font 11'")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- Optional, if installed:
-- hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
-- hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Geometry follows shell.qml: islands sit 6px from the screen edge and 6px
-- apart, so gaps_out = 6 lines window edges up with the islands, and
-- gaps_in = 3 (per side) gives the same 6px between windows.
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 6,
		border_size = 2,

		col = {
			-- white → graphite at 45°: reads like light catching a pencil lead
			active_border = {
				colors = { rgba(C.text, "dd"), rgba(C.divider, "aa"), rgba(C.textDim, "cc") },
				angle = 45,
			},
			inactive_border = rgba(C.surface, "aa"),
			nogroup_border = rgba(C.divider, "aa"),
			nogroup_border_active = rgba(C.textDim, "dd"),
		},

		resize_on_border = true,
		extend_border_grab_area = 12,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 12, -- Theme.radius
		rounding_power = 2.5, -- a touch squircle-y, softer than plain circles

		active_opacity = 1.0,
		inactive_opacity = 1.0,
		dim_inactive = true, -- monochrome themes rely on contrast, not colour
		dim_strength = 0.08,

		shadow = {
			enabled = true,
			range = 22,
			render_power = 3,
			color = 0x88000000,
			color_inactive = 0x55000000,
		},

		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			noise = 0.012,
			contrast = 1.0,
			brightness = 0.85,
			vibrancy = 0.0, -- graphite = no colour boost
			vibrancy_darkness = 0.0,
			popups = true,
			xray = false,
		},
	},

	group = {
		col = {
			border_active = rgba(C.text, "dd"),
			border_inactive = rgba(C.surface, "aa"),
		},
		groupbar = {
			font_family = "FiraCode Nerd Font",
			font_size = 11,
			height = 18,
			gradients = false,
			col = {
				active = rgba(C.surfaceHover),
				inactive = rgba(C.surface),
			},
		},
	},

	animations = {
		enabled = true,
	},
})

---- ANIMATIONS ----
-- Calm and precise: springs for windows, quick eases for everything else.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("graphite", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1 } } })

hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })
hl.curve("snug", { type = "spring", mass = 1, stiffness = 300, dampening = 28 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle", enabled = shimmer, speed = 90, bezier = "linear", style = "loop" })

hl.animation({ leaf = "windows", enabled = true, speed = 4.5, spring = "snug" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, spring = "easy", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.4, bezier = "linear", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, spring = "snug" })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.7, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.4, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 3, bezier = "graphite" })

hl.animation({ leaf = "layers", enabled = true, speed = 3.8, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "graphite", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.8, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.4, bezier = "almostLinear" })

-- Horizontal slide matches the 3-finger horizontal gesture below.
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "graphite", style = "slidefade 12%" })
hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 3.5,
	bezier = "graphite",
	style = "slidefadevert 15%",
})

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

---- LAYOUTS ----
hl.config({
	dwindle = {
		preserve_split = true,
		smart_split = false,
		force_split = 2,
	},
	master = {
		new_status = "master",
	},
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

----------------
----  MISC  ----
----------------
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		background_color = 0xff141414, -- C.base, shown before Quickshell paints
		focus_on_activate = true,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
	},
	cursor = {
		hide_on_key_press = true,
		inactive_timeout = 6,
	},
})

---------------
---- INPUT ----
---------------
hl.config({
	input = {
		kb_layout = "dk",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(launcher))

-- session
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lock))
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd("pkill -x qs; qs -d")) -- reload the shell
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("qs ipc call keymaps toggle"))

-- windows
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
try("fullscreen bind", function()
	hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
end)

-- focus with arrows, move the window with SHIFT + arrows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
	hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
	try("move " .. dir, function()
		hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
	end)
end

-- workspaces 1–10
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- drag / resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- screenshots (grim + slurp + wl-clipboard)
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(' .. slurp .. ')" - | wl-copy'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(
	mainMod .. " + Print",
	hl.dsp.exec_cmd(
		'mkdir -p ~/Pictures/Screenshots && grim -g "$('
			.. slurp
			.. ')" ~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png'
	)
)

-- media / hardware keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
local suppressMaximizeRule = hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

-- small utilities float centred instead of getting tiled into a sliver
try("utility rule", function()
	hl.window_rule({
		name = "graphite-utilities",
		match = {
			class = "^(org.pulseaudio.pavucontrol|pavucontrol|nm-connection-editor|blueman-manager|org.kde.kcalc|xdg-desktop-portal-gtk)$",
		},
		float = true,
		center = true,
		size = "900 600",
	})
end)

try("dialog rule", function()
	hl.window_rule({
		name = "graphite-dialogs",
		match = { title = "^(Open File|Open Folder|Save As|Save File|File Upload|Select a File|Choose Files).*" },
		float = true,
		center = true,
	})
end)

-- picture-in-picture tucks into the bottom-right corner, on every workspace
try("pip rule", function()
	hl.window_rule({
		name = "graphite-pip",
		match = { title = "^(Picture-in-Picture|Picture in picture)$" },
		float = true,
		pin = true,
		size = "640 360",
		move = "monitor_w-646 monitor_h-366",
	})
end)

---------------------
---- LAYER RULES ----
---------------------
-- Launcher: its 35% black veil gets frosted, so the whole desktop
-- softens behind the search box like a spotlight.
try("launcher layer rule", function()
	hl.layer_rule({
		name = "graphite-launcher",
		match = { namespace = "^quickshell-launcher$" },
		blur = true,
		ignore_alpha = 0.2,
		animation = "fade",
	})
end)

-- Bar: blur only where islands are drawn. Opaque islands won't show it;
-- make Theme.surface translucent (see notes) for frosted islands.
try("bar layer rule", function()
	hl.layer_rule({
		name = "graphite-bar",
		match = { namespace = "^quickshell$" },
		blur = true,
		ignore_alpha = 0.5,
	})
end)

try("wallpaper layer rule", function()
	hl.layer_rule({
		name = "graphite-wallpaper",
		match = { namespace = "^quickshell-wallpaper$" },
		no_anim = true,
	})
end)

-- slurp selection should appear instantly, not fade in
try("slurp layer rule", function()
	hl.layer_rule({
		name = "graphite-slurp",
		match = { namespace = "^selection$" },
		no_anim = true,
	})
end)
