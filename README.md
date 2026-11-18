# Lumen UI

A clean, quiet interface library for Roblox. It runs on the client and is a single file: load it with `loadstring` or `require` it as a ModuleScript.

- A sidebar with tabs and a search box that filters the current tab
- Toggles, sliders, dropdowns (single, multi, searchable), inputs, keybinds, colour pickers, buttons, paragraphs, labels and dividers
- Sections, notifications, dialogs and a ready-made settings tab
- Configs that save and load every element with a `Flag`, plus an autoload config
- 4 themes that you can switch while the UI is open, and you can add your own
- Lucide icons by name (`Icon = "eye"`)
- Drag, resize, minimise, a toggle key, and a draggable button on phones and tablets
- A soft drop shadow drawn from frames, so there are no image assets to break

## Install

**Executor / loadstring**

```lua
local Lumen = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_NAME/Lumen/main/Lumen.lua"))()
```

**Studio**: put `Lumen.lua` in a ModuleScript (for example `ReplicatedStorage.Lumen`) and require it from a LocalScript:

```lua
local Lumen = require(game.ReplicatedStorage.Lumen)
```

The UI goes into `gethui()` when it exists, then `CoreGui`, then `PlayerGui`.

## Quick start

```lua
local Window = Lumen:CreateWindow({
	Title = "My Hub",
	Subtitle = "v1.0",
	Theme = "Graphite",
})

local Main = Window:Tab({ Title = "Main", Icon = "home" })

Main:Toggle({
	Title = "Auto farm",
	Description = "Collects coins near you",
	Flag = "AutoFarm",
	Callback = function(on) print("Auto farm:", on) end,
})

Main:Slider({
	Title = "WalkSpeed", Min = 16, Max = 100, Default = 16, Flag = "Speed",
	Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end,
})

Window:BuildSettingsTab()
```

See [Example.lua](Example.lua) for an example that uses every element.

## Window

```lua
local Window = Lumen:CreateWindow({
	Title = "My Hub",                    -- required
	Subtitle = "example",                -- optional second line
	Logo = "M",                          -- letter in the logo square (defaults to the title's first letter)
	Icon = "target",                     -- or an icon instead of a letter
	Theme = "Graphite",                  -- Graphite, Mono, Slate, Paper
	Size = UDim2.fromOffset(640, 450),
	MinSize = Vector2.new(520, 360),
	SidebarWidth = 190,
	ToggleKey = Enum.KeyCode.RightShift,
	Footer = "Made with Lumen UI",       -- false hides the footer
	Resizable = true,
	ShowUser = true,                     -- avatar + name at the bottom of the sidebar
	MobileButton = nil,                  -- nil = only on touch devices, true/false to force
	AccentLine = false,                  -- one static accent line along the top edge
	ConfigFolder = "MyHub",
})

Window:Tab({ Title = "Main", Icon = "home" })  -- also Window:Tab("Main", "home")
Window:SelectTab(1)
Window:Minimize()                            -- toggles
Window:SetVisible(false)
Window:Toggle()
Window:Dialog({ ... })
Window:BuildSettingsTab({ Title = "Settings", Icon = "settings" })
```

## Sections

Tabs and sections have the same element methods.

```lua
local World = Tab:Section({ Title = "World", Icon = "sun" })  -- or Tab:Section("World")
World:Toggle({ ... })
```

## Elements

Every element that takes a value returns an object with `.Value`, `:Set(value)`, `:OnChanged(fn)`, `:SetTitle(text)`, `:SetDescription(text)`, `:SetVisible(bool)` and `:Destroy()`. If you give it a `Flag`, its value is kept in `Lumen.Flags[flag]` and saved with configs. Pass `IgnoreConfig = true` to leave an element out of configs.

### Button
```lua
Tab:Button({ Title = "Rejoin", Description = "Reconnect", Icon = "refresh", Callback = function() end })
```

### Toggle
```lua
local T = Tab:Toggle({ Title = "Fly", Default = false, Flag = "Fly", Callback = function(on) end })
T:Set(true)
```

### Slider
```lua
local S = Tab:Slider({
	Title = "FOV", Min = 50, Max = 120, Default = 70,
	Increment = 1,        -- 0.1 for one decimal place
	Suffix = "°",
	Flag = "FOV", Callback = function(v) end,
})
```
You can click the number and type in a value.

### Dropdown
```lua
local D = Tab:Dropdown({
	Title = "Mode", Values = { "A", "B", "C" }, Default = "A",
	Multi = false,        -- true: Value is a table of the selected items
	Search = nil,         -- nil = automatic when there are more than 6 options
	Placeholder = "Select...",
	Flag = "Mode", Callback = function(v) end,
})
D:Refresh({ "X", "Y" }, keepSelection)
D:Open() D:Close()
```

### Input
```lua
Tab:Input({
	Title = "Target", Placeholder = "username",
	Numeric = false, MaxLength = nil,
	Finished = true,      -- true: callback runs on Enter / when the box loses focus; false: on every keystroke
	ClearOnFocus = false,
	Flag = "Target", Callback = function(text) end,
})
```

### Keybind
```lua
Tab:Keybind({
	Title = "Dash", Default = Enum.KeyCode.Q,
	Mode = "Press",        -- "Press" | "Toggle" (callback gets on/off) | "Hold" (true on press, false on release)
	Callback = function(state) end,
	ChangedCallback = function(newKeyName) end,
})
```
Click the box, then press a key. Escape or Backspace clears the bind. MB2 and MB3 work too.

### ColorPicker
```lua
Tab:ColorPicker({ Title = "Colour", Default = Color3.fromRGB(255, 255, 255), Flag = "Col", Callback = function(c) end })
```
It has a saturation/value square, a hue bar and a hex box.

### Paragraph, Label, Divider
```lua
local P = Tab:Paragraph({ Title = "Tip", Content = "Text that wraps.", Icon = "info" })
P:Set("New title", "New content")
Tab:Label("Small muted text")
Tab:Divider()
```

## Notifications

```lua
Lumen:Notify({
	Title = "Saved",
	Content = "Config 'pvp' saved.",
	Type = "Success",     -- Info (accent), Success, Warning, Error
	Duration = 5,
})
```

## Dialogs

```lua
Window:Dialog({
	Title = "Reset everything?", Icon = "alert-triangle",
	Content = "This turns every toggle off.",
	Buttons = {
		{ Title = "Cancel" },
		{ Title = "Reset", Primary = true, Callback = function() end },
	},
})
```

## Themes

```lua
Lumen:SetTheme("Mono")        -- Graphite, Mono, Slate, Paper
Lumen:GetThemes()             -- { "Graphite", "Mono", "Paper", "Slate" }

Lumen:AddTheme("Mine", {      -- missing keys come from Graphite
	Accent = Color3.fromRGB(120, 200, 160),
	OnAccent = Color3.fromRGB(10, 20, 15),
})
```

Theme keys: `Background`, `Sidebar`, `Element`, `ElementHover`, `Input`, `Stroke`, `Text`, `SubText`, `Muted`, `Accent`, `OnAccent`, `ToggleOff`, `Knob`, `Shadow`.

There is one accent per theme. It's only used for state: a toggle that's on, slider fill, the selected tab, a focused input and the primary dialog button. Everything else is neutral, so the accent always means something.

## Configs

Configs need an executor with `writefile`, `readfile`, `listfiles` and `makefolder`. Without them the config buttons show an error notification and do nothing else.

```lua
Lumen:SaveConfig("pvp")
Lumen:LoadConfig("pvp")
Lumen:ListConfigs()
Lumen:SetAutoload("pvp")
Lumen:LoadAutoloadConfig()    -- call after creating all your elements
```

`Window:BuildSettingsTab()` adds all of this as UI: a theme picker, the toggle key, save, load, autoload, and Unload.

## Icons

Use [Lucide](https://lucide.dev) names: `home`, `eye`, `wrench`, `settings`, `swords`, `crosshair`, `target`, `shield`, `user`, `users`, `map`, `palette`, `keyboard`, `gamepad`, `bell`, `info`, `save` and about 150 more. The full list is the `Icons` table at the top of `Lumen.lua`. You can also pass `"rbxassetid://123"` or a number.

```lua
Lumen.Icons["my-icon"] = 1234567890   -- add your own
```

## Unloading

```lua
Lumen:OnUnload(function()
	-- undo whatever your script changed
end)
Lumen:Destroy()  -- also Lumen:Unload()
```

`Lumen.Unloaded` turns `true` after unloading, so loops can stop:

```lua
while Lumen.Flags.AutoFarm and not Lumen.Unloaded do ... task.wait() end
```

## Design notes

Lumen leaves out the effects that make a UI look generated: purple-to-cyan gradients, glow that orbits the window, pulsing borders, a tinted icon tile on every card and bouncy animations. Instead it uses:

- flat surfaces separated by 1px hairlines, plus one neutral drop shadow
- one radius family: window 10, cards 8, controls 6; only toggles, knobs and avatars are round
- Builder Sans for UI text and Roboto Mono for numbers and key names
- motion of 250 ms or less, with no looping animation

## Credits

- Icons: [Lucide](https://lucide.dev) (ISC). Roblox asset uploads from the [Fluent](https://github.com/dawid-scripts/Fluent) project.

## License

MIT
