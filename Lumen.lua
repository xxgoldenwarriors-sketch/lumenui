--[[
	 _
	| |    _   _  _ __ ___    ___  _ __
	| |   | | | || '_ ` _ \  / _ \| '_ \
	| |___| |_| || | | | | ||  __/| | | |
	|_____|\__,_||_| |_| |_| \___||_| |_|

	Lumen UI  -  a clean, quiet Roblox interface library
	Client-sided. Works in a LocalScript / ModuleScript or via loadstring.

	local Lumen = loadstring(game:HttpGet("https://raw.githubusercontent.com/xxgoldenwarriors-sketch/Lumen/main/Lumen.lua"))()
	local Window = Lumen:CreateWindow({ Title = "My Hub", Subtitle = "made with Lumen" })
	local Tab = Window:Tab({ Title = "Main", Icon = "home" })
	Tab:Toggle({ Title = "Hello", Callback = function(v) print(v) end })

	Icons: Lucide (https://lucide.dev, ISC license). Asset uploads by the Fluent project.
	License: MIT
]]

local Lumen = {
	Version = "1.0.0",
	Flags = {},
	Options = {},
	Windows = {},
	Unloaded = false,
	FontFamily = "rbxasset://fonts/families/BuilderSans.json",
	ConfigFolder = "Lumen",
}

--// Services ---------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
-- In a normal LocalScript this can come back nil (no permission), so keep it optional.
local CoreGui = (function() local ok, svc = pcall(game.GetService, game, "CoreGui") return ok and svc or nil end)()
local GuiService = game:GetService("GuiService")
local RobloxFont = Font

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

--// Icons (Lucide) ---------------------------------------------------------
-- Use any of these by name: Icon = "home". You can also pass "rbxassetid://123" or a number.
local Icons = {
	["accessibility"] = 10709751939, ["activity"] = 10709752035, ["alert-circle"] = 10709752996,
	["alert-triangle"] = 10709753149, ["anchor"] = 10709761530, ["aperture"] = 10709761813,
	["award"] = 10709769406, ["battery"] = 10709774640, ["bell"] = 10709775704,
	["bell-ring"] = 10709775560, ["bookmark"] = 10709782154, ["bot"] = 10709782230,
	["box"] = 10709782497, ["bug"] = 10709782845, ["calendar"] = 10709789505,
	["camera"] = 10709789686, ["car"] = 10709789810, ["check"] = 10709790644,
	["check-circle"] = 10709790387, ["chevron-down"] = 10709790948, ["chevron-left"] = 10709791281,
	["chevron-right"] = 10709791437, ["chevron-up"] = 10709791523, ["circle"] = 10709798174,
	["circle-dot"] = 10709797837, ["clipboard"] = 10709799288, ["clock"] = 10709805144,
	["code"] = 10709810463, ["coins"] = 10709811110, ["command"] = 10709811365,
	["compass"] = 10709811445, ["copy"] = 10709812159, ["cpu"] = 10709813383,
	["crosshair"] = 10709818534, ["crown"] = 10709818626, ["dice"] = 10709819801,
	["download"] = 10723344270, ["droplet"] = 10723344432, ["expand"] = 10723346553,
	["eye"] = 10723346959, ["eye-off"] = 10723346871, ["feather"] = 10723354671,
	["file"] = 10723374641, ["flag"] = 10723375890, ["flame"] = 10723376114,
	["folder"] = 10723387563, ["gamepad"] = 10723395215, ["gauge"] = 10723395708,
	["ghost"] = 10723396107, ["gift"] = 10723396402, ["globe"] = 10723404337,
	["grip"] = 10723405236, ["hand"] = 10723405649, ["hash"] = 10723405975,
	["heart"] = 10723406885, ["home"] = 10723407389, ["image"] = 10723415040,
	["info"] = 10723415903, ["joystick"] = 10723416527, ["key"] = 10723416652,
	["keyboard"] = 10723416765, ["layers"] = 10723424505, ["layout"] = 10723425376,
	["layout-dashboard"] = 10723424646, ["layout-grid"] = 10723424838, ["link"] = 10723426722,
	["list"] = 10723433811, ["list-checks"] = 10734884548, ["loader"] = 10723434070,
	["lock"] = 10723434711, ["log-out"] = 10723434906, ["mail"] = 10734885430,
	["map"] = 10734886202, ["map-pin"] = 10734886004, ["maximize"] = 10734886496,
	["menu"] = 10734887784, ["message"] = 10734888228, ["minimize"] = 10734895530,
	["minus"] = 10734896206, ["monitor"] = 10734896881, ["moon"] = 10734897102,
	["mountain"] = 10734897956, ["mouse-pointer"] = 10734898476, ["mouse-pointer-click"] = 10734898355,
	["move"] = 10734900011, ["move-diagonal"] = 10734898934, ["music"] = 10734905958,
	["package"] = 10734909540, ["paint-bucket"] = 10734909847, ["paintbrush"] = 10734910187,
	["palette"] = 10734910430, ["party-popper"] = 10734918735, ["person-standing"] = 10734920149,
	["pipette"] = 10734922497, ["plane"] = 10734922971, ["plus"] = 10734924532,
	["power"] = 10734930466, ["refresh"] = 10734933222, ["rocket"] = 10734934585,
	["rotate-ccw"] = 10734940376, ["save"] = 10734941499, ["scaling"] = 10734942072,
	["scan"] = 10734942565, ["search"] = 10734943674, ["settings"] = 10734950309,
	["settings-2"] = 10734950020, ["shield"] = 10734951847, ["shield-check"] = 10734951367,
	["skull"] = 10734962068, ["sliders"] = 10734963191, ["smile"] = 10734964441,
	["snowflake"] = 10734964600, ["star"] = 10734966248, ["sun"] = 10734974297,
	["sword"] = 10734975486, ["swords"] = 10734975692, ["tag"] = 10734976528,
	["target"] = 10734977012, ["terminal"] = 10734982144, ["text-cursor"] = 10734982297,
	["thumbs-up"] = 10734983629, ["timer"] = 10734984606, ["toggle-left"] = 10734984834,
	["toggle-right"] = 10734985040, ["trash"] = 10747362241, ["tree"] = 10747362748,
	["trophy"] = 10747363809, ["type"] = 10747364761, ["unlock"] = 10747366027,
	["upload"] = 10747366434, ["user"] = 10747373176, ["user-plus"] = 10747372702,
	["users"] = 10747373426, ["volume"] = 10747375679, ["wallet"] = 10747376205,
	["wand"] = 10747376349, ["wifi"] = 10747382504, ["wind"] = 10747382750,
	["wrench"] = 10747383470, ["x"] = 10747384394, ["x-circle"] = 10747383819,
}
-- friendly aliases
Icons["house"] = Icons["home"]; Icons["gamepad-2"] = Icons["gamepad"]
Icons["fun"] = Icons["party-popper"]; Icons["visual"] = Icons["eye"]; Icons["movement"] = Icons["person-standing"]
Icons["combat"] = Icons["swords"]; Icons["trash-2"] = Icons["trash"]; Icons["refresh-cw"] = Icons["refresh"]
Lumen.Icons = Icons

function Lumen:GetIcon(name)
	if name == nil or name == "" then return nil end
	if typeof(name) == "number" then return "rbxassetid://" .. name end
	name = tostring(name)
	if name:find("^rbxasset") or name:find("^rbxthumb") or name:find("^http") then return name end
	if name:find("^%d+$") then return "rbxassetid://" .. name end
	local id = Icons[name:lower():gsub("^lucide%-", "")]
	return id and ("rbxassetid://" .. id) or nil
end

--// Themes -----------------------------------------------------------------
local rgb = Color3.fromRGB
-- One accent per theme. The accent only marks state: toggles that are on, slider fill,
-- the selected tab, focused inputs and the primary dialog button. Everything else is neutral.
Lumen.Themes = {
	-- Warm graphite with an amber accent, like instrument-panel backlighting.
	-- Amber reads clearly over busy game scenes without looking like a warning.
	Graphite = {
		Background = rgb(17, 16, 15), Sidebar = rgb(23, 22, 20), Element = rgb(27, 26, 24),
		ElementHover = rgb(33, 32, 29), Input = rgb(20, 19, 18), Stroke = rgb(44, 42, 39),
		Text = rgb(237, 234, 228), SubText = rgb(160, 155, 146), Muted = rgb(108, 104, 97),
		Accent = rgb(226, 168, 76), OnAccent = rgb(28, 22, 12), ToggleOff = rgb(48, 46, 42),
		Knob = rgb(237, 234, 228), Shadow = rgb(0, 0, 0),
	},
	-- Neutral black and white. White marks what's selected, with no colour at all.
	Mono = {
		Background = rgb(12, 12, 12), Sidebar = rgb(18, 18, 18), Element = rgb(23, 23, 23),
		ElementHover = rgb(29, 29, 29), Input = rgb(15, 15, 15), Stroke = rgb(40, 40, 40),
		Text = rgb(242, 242, 242), SubText = rgb(152, 152, 152), Muted = rgb(100, 100, 100),
		Accent = rgb(238, 238, 238), OnAccent = rgb(18, 18, 18), ToggleOff = rgb(44, 44, 44),
		Knob = rgb(242, 242, 242), Shadow = rgb(0, 0, 0),
	},
	-- Cool slate with a signal blue, like a radio or nav display.
	Slate = {
		Background = rgb(14, 16, 19), Sidebar = rgb(19, 22, 26), Element = rgb(23, 27, 32),
		ElementHover = rgb(29, 33, 39), Input = rgb(17, 20, 24), Stroke = rgb(38, 44, 52),
		Text = rgb(230, 235, 241), SubText = rgb(146, 156, 168), Muted = rgb(96, 105, 117),
		Accent = rgb(92, 154, 230), OnAccent = rgb(10, 18, 30), ToggleOff = rgb(40, 46, 54),
		Knob = rgb(230, 235, 241), Shadow = rgb(0, 0, 0),
	},
	-- Light theme: off-white paper with an ink-green accent.
	Paper = {
		Background = rgb(246, 245, 241), Sidebar = rgb(238, 236, 231), Element = rgb(252, 251, 248),
		ElementHover = rgb(244, 242, 237), Input = rgb(240, 238, 233), Stroke = rgb(222, 219, 211),
		Text = rgb(28, 27, 25), SubText = rgb(98, 95, 89), Muted = rgb(146, 142, 134),
		Accent = rgb(38, 110, 84), OnAccent = rgb(246, 245, 241), ToggleOff = rgb(214, 211, 203),
		Knob = rgb(28, 27, 25), Shadow = rgb(60, 50, 30),
	},
}
Lumen.ThemeName = "Graphite"
Lumen.Theme = Lumen.Themes.Graphite

local StatusColors = {
	Info = nil, -- uses accent
	Success = rgb(34, 197, 94),
	Warning = rgb(245, 158, 11),
	Error = rgb(239, 68, 68),
}

--// Internal helpers -------------------------------------------------------
local Connections = {}
local Themed = {} -- { instance, property, key | function(theme) }
local ThemeCallbacks = {}
local UnloadCallbacks = {}
local Keybinds = {}

local function Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Connections, c)
	return c
end

local function SafeCall(fn, ...)
	if typeof(fn) ~= "function" then return end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(fn, table.unpack(args, 1, args.n))
		if not ok then warn("[Lumen] callback error: " .. tostring(err)) end
	end)
end

local function Resolve(key)
	if typeof(key) == "function" then return key(Lumen.Theme) end
	return Lumen.Theme[key]
end

local function Bind(inst, prop, key)
	table.insert(Themed, { inst, prop, key })
	inst[prop] = Resolve(key)
end

local function Tween(inst, props, time, style, dir)
	local t = TweenService:Create(inst, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Mono()
	return RobloxFont.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium)
end

local function Font(weight)
	return RobloxFont.new(Lumen.FontFamily, weight or Enum.FontWeight.Regular)
end

-- New("Frame", { props..., Theme = { BackgroundColor3 = "Element" } }, { children })
local function New(class, props, children)
	local inst = Instance.new(class)
	local parent
	if props then
		for k, v in pairs(props) do
			if k == "Theme" then
				for p, key in pairs(v) do Bind(inst, p, key) end
			elseif k == "Parent" then
				parent = v
			else
				inst[k] = v
			end
		end
	end
	if children then
		for _, c in ipairs(children) do c.Parent = inst end
	end
	if inst:IsA("GuiObject") and not (props and props.BorderSizePixel) then inst.BorderSizePixel = 0 end
	if parent then inst.Parent = parent end
	return inst
end

local function Corner(parent, r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = parent })
end

local function Stroke(parent, key, thickness, transparency)
	return New("UIStroke", {
		Thickness = thickness or 1, Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Theme = { Color = key or "Stroke" }, Parent = parent,
	})
end

local function Padding(parent, t, b, l, r)
	return New("UIPadding", {
		PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0),
		PaddingLeft = UDim.new(0, l or t or 0), PaddingRight = UDim.new(0, r or l or t or 0), Parent = parent,
	})
end

local function List(parent, pad, dir, halign, valign)
	return New("UIListLayout", {
		Padding = UDim.new(0, pad or 0), FillDirection = dir or Enum.FillDirection.Vertical,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = parent,
	})
end

local function Text(props)
	props.BackgroundTransparency = 1
	props.FontFace = props.FontFace or Font(Enum.FontWeight.Regular)
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextSize = props.TextSize or 14
	props.RichText = true
	props.Theme = props.Theme or { TextColor3 = "Text" }
	return New("TextLabel", props)
end

local function IconImage(icon, size, colorKey, props)
	props = props or {}
	props.BackgroundTransparency = 1
	props.Size = props.Size or UDim2.fromOffset(size or 18, size or 18)
	props.Image = Lumen:GetIcon(icon) or ""
	props.ScaleType = Enum.ScaleType.Fit
	props.Theme = props.Theme or { ImageColor3 = colorKey or "SubText" }
	return New("ImageLabel", props)
end

-- Solid accent fill for a frame (BackgroundColor3) or a stroke (Color).
local function AccentFill(inst)
	Bind(inst, inst:IsA("UIStroke") and "Color" or "BackgroundColor3", "Accent")
end

local function Round(n, inc)
	inc = inc or 1
	return math.floor(n / inc + 0.5) * inc
end

local function Decimals(inc)
	local s = tostring(inc)
	local d = s:find("%.")
	return d and (#s - d) or 0
end

local function IsClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function GetGuiParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	-- CoreGui only counts if we can really parent into it and read it back
	-- (parenting to a nil CoreGui would "succeed" and leave the UI nowhere).
	local canCore = CoreGui ~= nil and pcall(function()
		local probe = Instance.new("ScreenGui")
		probe.Parent = CoreGui
		assert(probe.Parent == CoreGui and CoreGui:FindFirstChild(probe.Name))
		probe:Destroy()
	end)
	if canCore then return CoreGui end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function MakeScreenGui(name)
	local parent = GetGuiParent()
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local gui = New("ScreenGui", {
		Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() if protectgui then protectgui(gui) elseif syn and syn.protect_gui then syn.protect_gui(gui) end end)
	gui.Parent = parent
	return gui
end

--// Theme API --------------------------------------------------------------
function Lumen:SetTheme(theme)
	local t = typeof(theme) == "table" and theme or self.Themes[theme]
	if not t then return warn("[Lumen] unknown theme: " .. tostring(theme)) end
	self.Theme = t
	self.ThemeName = typeof(theme) == "string" and theme or "Custom"
	for i = #Themed, 1, -1 do
		local e = Themed[i]
		local inst = e[1]
		if not inst or not inst.Parent then
			table.remove(Themed, i)
		else
			local v = Resolve(e[3])
			if typeof(v) == "Color3" then
				Tween(inst, { [e[2]] = v }, 0.3)
			else
				inst[e[2]] = v
			end
		end
	end
	for _, fn in ipairs(ThemeCallbacks) do SafeCall(fn, t) end
end

-- Register your own theme: Lumen:AddTheme("Mine", { Accent = Color3.fromRGB(...), ... }). Missing keys come from Graphite.
function Lumen:AddTheme(name, theme)
	local base = table.clone(self.Themes.Graphite)
	for k, v in pairs(theme) do base[k] = v end
	self.Themes[name] = base
	return base
end

function Lumen:GetThemes()
	local names = {}
	for name in pairs(self.Themes) do table.insert(names, name) end
	table.sort(names)
	return names
end

function Lumen:OnThemeChanged(fn) table.insert(ThemeCallbacks, fn) end
function Lumen:OnUnload(fn) table.insert(UnloadCallbacks, fn) end

-- Keybind dispatcher
Connect(UserInputService.InputBegan, function(input, processed)
	for _, kb in ipairs(Keybinds) do kb:_input(input, processed, true) end
end)
Connect(UserInputService.InputEnded, function(input, processed)
	for _, kb in ipairs(Keybinds) do kb:_input(input, processed, false) end
end)

--// Notifications ----------------------------------------------------------
local NotifyGui, NotifyHolder
local function EnsureNotifyGui()
	if NotifyHolder and NotifyHolder.Parent then return end
	NotifyGui = MakeScreenGui("Lumen_Notifications")
	NotifyHolder = New("Frame", {
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 310, 1, -40), BackgroundTransparency = 1, Parent = NotifyGui,
	})
	List(NotifyHolder, 10, nil, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
end

function Lumen:Notify(o)
	if typeof(o) == "string" then o = { Title = o } end
	o = o or {}
	EnsureNotifyGui()
	local duration = o.Duration or 5
	local statusColor = StatusColors[o.Type or "Info"]

	local wrap = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Parent = NotifyHolder,
	})
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(340, 0), Theme = { BackgroundColor3 = "Element" }, Parent = wrap,
	})
	Corner(card, 8)
	local st = Stroke(card, "Stroke")
	Padding(card, 12, 14, 14, 14)

	-- thin status bar on the left edge; colour only when the type means something
	local status = New("Frame", { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(0, 3, 1, -4), Parent = card })
	Corner(status, 2)
	if statusColor then status.BackgroundColor3 = statusColor else AccentFill(status) end

	local textCol = New("Frame", {
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -36, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = card,
	})
	List(textCol, 3)
	Text({ Text = o.Title or "Notification", TextSize = 14, FontFace = Font(Enum.FontWeight.SemiBold), Size = UDim2.new(1, 0, 0, 18), Parent = textCol })
	if o.Content then
		Text({
			Text = o.Content, TextSize = 13, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, Theme = { TextColor3 = "SubText" }, LayoutOrder = 1, Parent = textCol,
		})
	end

	local close = New("ImageButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 4, 0, -2), Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1, Image = Lumen:GetIcon("x"), Theme = { ImageColor3 = "Muted" }, Parent = card,
	})

	local bar = New("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, -14, 1, 14), Size = UDim2.new(1, 28, 0, 2),
		BackgroundColor3 = Color3.new(1, 1, 1), Parent = card,
	})
	Bind(bar, "BackgroundColor3", "Stroke")

	Tween(card, { Position = UDim2.fromOffset(0, 0) }, 0.25)
	Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	local closed = false
	local function dismiss()
		if closed then return end
		closed = true
		Tween(card, { Position = UDim2.fromOffset(340, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.wait(0.3)
		wrap.AutomaticSize = Enum.AutomaticSize.None
		wrap.Size = UDim2.new(1, 0, 0, wrap.AbsoluteSize.Y)
		Tween(wrap, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
		task.wait(0.22)
		wrap:Destroy()
	end
	close.MouseButton1Click:Connect(dismiss)
	task.delay(duration, dismiss)
	return { Dismiss = dismiss }
end

--// Elements ---------------------------------------------------------------
-- Every container (Tab or Section) gets these methods.
local Elements = {}
Elements.__index = Elements

local function RegisterOption(opt, flag)
	if flag then
		Lumen.Options[flag] = opt
		Lumen.Flags[flag] = opt.Value
	end
end

local function BaseOption(container, o, kind)
	local opt = {
		Type = kind, Flag = o.Flag, Value = nil, Callback = o.Callback,
		_changed = {}, IgnoreConfig = o.IgnoreConfig,
	}
	function opt:OnChanged(fn) table.insert(self._changed, fn) return self end
	function opt:Get() return self.Value end
	function opt:_fire(silent)
		if self.Flag then Lumen.Flags[self.Flag] = self.Value end
		if silent then return end
		SafeCall(self.Callback, self.Value)
		for _, fn in ipairs(self._changed) do SafeCall(fn, self.Value) end
	end
	return opt
end

-- Builds the standard card: title + description on the left, control on the right.
function Elements:_card(o, rightWidth)
	self._order = (self._order or 0) + 1
	-- The card is a TextButton so a click anywhere on it works without an overlay
	-- (an offset-sized overlay would feed back into AutomaticSize and stretch the card).
	local card = New("TextButton", {
		Name = o.Title or "Element", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = "", AutoButtonColor = false, LayoutOrder = self._order, Theme = { BackgroundColor3 = "Element" }, Parent = self.Holder,
	})
	Corner(card, 8)
	local stroke = Stroke(card, "Stroke")
	Padding(card, 12, 12, 14, 14)
	List(card, 10)

	local header = New("Frame", {
		Name = "Header", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Parent = card,
	})
	local textCol = New("Frame", {
		Size = UDim2.new(1, -(rightWidth or 0) - 10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Parent = header,
	})
	List(textCol, 2)
	local title = Text({
		Text = o.Title or "Element", TextSize = 15, FontFace = Font(Enum.FontWeight.Bold),
		Size = UDim2.new(1, 0, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = textCol,
	})
	local desc = Text({
		Text = o.Description or o.Desc or "", TextSize = 13, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Visible = (o.Description or o.Desc) ~= nil,
		Theme = { TextColor3 = "SubText" }, Parent = textCol,
	})
	-- minimum height so single-line rows stay consistent
	New("UISizeConstraint", { MinSize = Vector2.new(0, 22), Parent = header })

	Connect(card.MouseEnter, function() Tween(card, { BackgroundColor3 = Lumen.Theme.ElementHover }, 0.15) end)
	Connect(card.MouseLeave, function() Tween(card, { BackgroundColor3 = Lumen.Theme.Element }, 0.2) end)

	table.insert(self.Tab.Searchables, { Frame = card, Title = title, Desc = desc, Section = self.SectionFrame })

	local api = { Frame = card, Header = header, Title = title, Desc = desc, Stroke = stroke }
	return api
end

local function AttachCommon(opt, c)
	opt.Frame = c.Frame
	function opt:SetTitle(t) c.Title.Text = t end
	function opt:SetDescription(t) c.Desc.Text = t or ""; c.Desc.Visible = t ~= nil and t ~= "" end
	function opt:SetVisible(v) c.Frame.Visible = v end
	function opt:Destroy() c.Frame:Destroy() if self.Flag then Lumen.Options[self.Flag] = nil end end
end

-- fullCard: the card itself is the button. Otherwise a scale-sized overlay on the header,
-- so clicks inside an expanded panel (dropdown list, colour picker) don't toggle it.
local function ClickOverlay(parent, fullCard)
	if fullCard then return parent end
	return New("TextButton", {
		Text = "", BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 3,
		Size = UDim2.fromScale(1, 1), Parent = parent,
	})
end

-- Button -------------------------------------------------------------------
function Elements:Button(o)
	o = o or {}
	local c = self:_card(o, 24)
	local btn = { Type = "Button", Callback = o.Callback }
	AttachCommon(btn, c)
	local icon = IconImage(o.Icon or "chevron-right", 16, "Muted", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Parent = c.Header,
	})
	local overlay = ClickOverlay(c.Frame, true)
	overlay.MouseButton1Down:Connect(function() Tween(c.Frame, { BackgroundColor3 = Lumen.Theme.Stroke }, 0.08) end)
	overlay.MouseButton1Up:Connect(function() Tween(c.Frame, { BackgroundColor3 = Lumen.Theme.ElementHover }, 0.15) end)
	overlay.MouseButton1Click:Connect(function()
		SafeCall(btn.Callback)
	end)
	function btn:Fire() SafeCall(self.Callback) end
	return btn
end

-- Toggle -------------------------------------------------------------------
function Elements:Toggle(o)
	o = o or {}
	local c = self:_card(o, 44)
	local toggle = BaseOption(self, o, "Toggle")
	AttachCommon(toggle, c)
	toggle.Value = o.Default == true or o.Value == true

	local track = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(44, 24),
		Parent = c.Header,
	})
	Corner(track, 12)
	Bind(track, "BackgroundColor3", function(t) return toggle.Value and t.Accent or t.ToggleOff end)

	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, toggle.Value and 23 or 3, 0.5, 0),
		Size = UDim2.fromOffset(18, 18), Parent = track,
	})
	Corner(knob, 9)
	Bind(knob, "BackgroundColor3", function(t) return toggle.Value and t.OnAccent or t.SubText end)

	function toggle:Set(v, silent)
		v = v == true
		self.Value = v
		Tween(track, { BackgroundColor3 = v and Lumen.Theme.Accent or Lumen.Theme.ToggleOff }, 0.18)
		Tween(knob, {
			Position = UDim2.new(0, v and 23 or 3, 0.5, 0),
			BackgroundColor3 = v and Lumen.Theme.OnAccent or Lumen.Theme.SubText,
		}, 0.18)
		self:_fire(silent)
	end
	ClickOverlay(c.Frame, true).MouseButton1Click:Connect(function() toggle:Set(not toggle.Value) end)

	RegisterOption(toggle, o.Flag)
	if toggle.Value then SafeCall(toggle.Callback, true) end
	return toggle
end

-- Slider -------------------------------------------------------------------
function Elements:Slider(o)
	o = o or {}
	local min, max = o.Min or 0, o.Max or 100
	local inc = o.Increment or o.Rounding or 1
	local suffix = o.Suffix or ""
	local dec = Decimals(inc)
	local c = self:_card(o, 70)
	local slider = BaseOption(self, o, "Slider")
	AttachCommon(slider, c)
	slider.Value = math.clamp(o.Default or min, min, max)

	local valueBox = New("TextBox", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(70, 18),
		BackgroundTransparency = 1, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Right,
		FontFace = Mono(), TextSize = 14, Text = "", Theme = { TextColor3 = "Text" }, Parent = c.Header,
	})

	local hit = New("Frame", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Active = true, LayoutOrder = 1, Parent = c.Frame,
	})
	local track = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 5),
		Theme = { BackgroundColor3 = "ToggleOff" }, Parent = hit,
	})
	Corner(track, 3)
	local fill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track })
	Corner(fill, 3)
	AccentFill(fill)
	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14),
		Theme = { BackgroundColor3 = "Knob" }, ZIndex = 2, Parent = track,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	Stroke(knob, "Accent", 2)

	local function format(v) return string.format("%." .. dec .. "f", v) .. suffix end

	function slider:Set(v, silent, instant)
		v = tonumber(v) or self.Value
		v = math.clamp(Round(v, inc), min, max)
		local pct = (max == min) and 0 or (v - min) / (max - min)
		if instant then
			fill.Size = UDim2.new(pct, 0, 1, 0); knob.Position = UDim2.new(pct, 0, 0.5, 0)
		else
			Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.12)
			Tween(knob, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.12)
		end
		valueBox.Text = format(v)
		local changed = v ~= self.Value
		self.Value = v
		if changed then self:_fire(silent) end
	end
	function slider:SetMin(v) min = v self:Set(self.Value, true) end
	function slider:SetMax(v) max = v self:Set(self.Value, true) end

	local dragging = false
	local function update(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		slider:Set(min + (max - min) * rel)
	end
	hit.InputBegan:Connect(function(input)
		if IsClick(input) then
			dragging = true
			Tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.15)
			update(input.Position.X)
		end
	end)
	Connect(UserInputService.InputChanged, function(input)
		if dragging and IsMove(input) then update(input.Position.X) end
	end)
	Connect(UserInputService.InputEnded, function(input)
		if dragging and IsClick(input) then
			dragging = false
			Tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.15)
		end
	end)
	valueBox.Focused:Connect(function() valueBox.Text = string.format("%." .. dec .. "f", slider.Value) end)
	valueBox.FocusLost:Connect(function()
		local n = tonumber((valueBox.Text:gsub("[^%d%.%-]", "")))
		if n then slider:Set(n) else valueBox.Text = format(slider.Value) end
	end)

	local start = slider.Value
	slider.Value = nil
	slider:Set(start, true, true)
	RegisterOption(slider, o.Flag)
	SafeCall(slider.Callback, slider.Value)
	return slider
end

-- Dropdown -----------------------------------------------------------------
function Elements:Dropdown(o)
	o = o or {}
	local multi = o.Multi == true
	local values = o.Values or o.Options or {}
	local c = self:_card(o, 160)
	local dd = BaseOption(self, o, "Dropdown")
	AttachCommon(dd, c)
	dd.Multi = multi
	dd.Values = values
	dd.Opened = false

	if multi then
		dd.Value = {}
		if typeof(o.Default) == "table" then for _, v in ipairs(o.Default) do table.insert(dd.Value, v) end end
	else
		dd.Value = typeof(o.Default) == "number" and values[o.Default] or o.Default
	end

	local box = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(160, 32),
		Theme = { BackgroundColor3 = "Input" }, Parent = c.Header,
	})
	Corner(box, 6)
	local boxStroke = Stroke(box, "Stroke")
	local display = Text({
		Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -36, 1, 0), TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd, FontFace = Font(Enum.FontWeight.Medium), Parent = box,
	})
	local chevron = IconImage("chevron-down", 16, "SubText", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0), Parent = box,
	})

	local panel = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true,
		Visible = false, LayoutOrder = 1, Parent = c.Frame,
	})
	local search
	local useSearch = o.Search ~= false and #values > 6 or o.Search == true
	search = New("TextBox", {
		Size = UDim2.new(1, 0, 0, 30), PlaceholderText = "Search...", Text = "", ClearTextOnFocus = false,
		FontFace = Font(Enum.FontWeight.Regular), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		Visible = useSearch, Theme = { BackgroundColor3 = "Input", TextColor3 = "Text", PlaceholderColor3 = "Muted" },
		Parent = panel,
	})
	Corner(search, 6)
	Stroke(search, "Stroke")
	Padding(search, 0, 0, 30, 10)
	IconImage("search", 14, "Muted", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -20, 0.5, 0), Parent = search })

	local scroll = New("ScrollingFrame", {
		Position = UDim2.fromOffset(0, useSearch and 36 or 0), Size = UDim2.new(1, 0, 1, useSearch and -36 or 0),
		BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
		Theme = { ScrollBarImageColor3 = "Muted" }, Parent = panel,
	})
	local scrollList = List(scroll, 3)
	local optionButtons = {}

	local function isSelected(v)
		if multi then return table.find(dd.Value, v) ~= nil end
		return dd.Value == v
	end

	local function refreshDisplay()
		local txt
		if multi then
			txt = #dd.Value > 0 and table.concat(dd.Value, ", ") or (o.Placeholder or "None")
		else
			txt = dd.Value ~= nil and tostring(dd.Value) or (o.Placeholder or "Select...")
		end
		display.Text = txt
		for v, b in pairs(optionButtons) do
			local sel = isSelected(v)
			Tween(b.Label, { TextColor3 = sel and Lumen.Theme.Text or Lumen.Theme.SubText }, 0.15)
			b.Label.FontFace = Font(sel and Enum.FontWeight.Bold or Enum.FontWeight.Medium)
			Tween(b.Check, { ImageTransparency = sel and 0 or 1 }, 0.15)
			Tween(b.Bar, { BackgroundTransparency = sel and 0 or 1 }, 0.15)
		end
	end

	local function panelHeight()
		local listH = scrollList.AbsoluteContentSize.Y
		return math.min(listH, 186) + (useSearch and 36 or 0)
	end

	local function setOpen(open)
		dd.Opened = open
		Tween(chevron, { Rotation = open and 180 or 0 }, 0.25)
		Tween(boxStroke, { Color = open and Lumen.Theme.Accent or Lumen.Theme.Stroke }, 0.2)
		if open then
			panel.Visible = true
			Tween(panel, { Size = UDim2.new(1, 0, 0, panelHeight()) }, 0.25)
		else
			Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
			task.delay(0.2, function() if not dd.Opened then panel.Visible = false end end)
		end
	end

	local function buildOptions()
		for _, b in pairs(optionButtons) do b.Button:Destroy() end
		table.clear(optionButtons)
		for i, v in ipairs(dd.Values) do
			local b = New("TextButton", {
				Text = "", AutoButtonColor = false, Size = UDim2.new(1, -4, 0, 30), LayoutOrder = i,
				BackgroundTransparency = 1, Theme = { BackgroundColor3 = "ElementHover" }, Parent = scroll,
			})
			Corner(b, 6)
			local bar = New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 14),
				BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Parent = b,
			})
			Corner(bar, 2)
			AccentFill(bar)
			local label = Text({
				Text = tostring(v), Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -40, 1, 0),
				TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, Theme = { TextColor3 = "SubText" }, Parent = b,
			})
			local check = IconImage("check", 15, "Accent", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), ImageTransparency = 1, Parent = b,
			})
			b.MouseEnter:Connect(function() Tween(b, { BackgroundTransparency = 0 }, 0.12) end)
			b.MouseLeave:Connect(function() Tween(b, { BackgroundTransparency = 1 }, 0.15) end)
			b.MouseButton1Click:Connect(function()
				if multi then
					local idx = table.find(dd.Value, v)
					if idx then table.remove(dd.Value, idx) else table.insert(dd.Value, v) end
					refreshDisplay()
					dd:_fire()
				else
					dd.Value = v
					refreshDisplay()
					dd:_fire()
					setOpen(false)
				end
			end)
			optionButtons[v] = { Button = b, Label = label, Check = check, Bar = bar }
		end
		refreshDisplay()
	end

	search:GetPropertyChangedSignal("Text"):Connect(function()
		local q = search.Text:lower()
		for v, b in pairs(optionButtons) do
			b.Button.Visible = q == "" or tostring(v):lower():find(q, 1, true) ~= nil
		end
		if dd.Opened then task.defer(function() panel.Size = UDim2.new(1, 0, 0, panelHeight()) end) end
	end)

	ClickOverlay(c.Header, false).MouseButton1Click:Connect(function() setOpen(not dd.Opened) end)

	function dd:Set(v, silent)
		if multi then
			self.Value = {}
			if typeof(v) == "table" then for _, x in ipairs(v) do table.insert(self.Value, x) end end
		else
			self.Value = v
		end
		refreshDisplay()
		self:_fire(silent)
	end
	function dd:Refresh(newValues, keepSelection)
		self.Values = newValues or {}
		if not keepSelection then
			self.Value = multi and {} or nil
		end
		buildOptions()
		if self.Opened then panel.Size = UDim2.new(1, 0, 0, panelHeight()) end
	end
	function dd:Open() setOpen(true) end
	function dd:Close() setOpen(false) end

	buildOptions()
	RegisterOption(dd, o.Flag)
	if dd.Value ~= nil and (not multi or #dd.Value > 0) then SafeCall(dd.Callback, dd.Value) end
	return dd
end

-- Input --------------------------------------------------------------------
function Elements:Input(o)
	o = o or {}
	local c = self:_card(o, 170)
	local input = BaseOption(self, o, "Input")
	AttachCommon(input, c)
	input.Value = o.Default or ""

	local box = New("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(170, 32),
		Text = tostring(input.Value), PlaceholderText = o.Placeholder or "Type here...", ClearTextOnFocus = o.ClearOnFocus == true,
		FontFace = Font(Enum.FontWeight.Medium), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { BackgroundColor3 = "Input", TextColor3 = "Text", PlaceholderColor3 = "Muted" }, Parent = c.Header,
	})
	Corner(box, 6)
	local st = Stroke(box, "Stroke")
	Padding(box, 0, 0, 10, 10)

	local function clean(t)
		if o.Numeric then t = t:gsub("[^%d%.%-]", "") end
		if o.MaxLength then t = t:sub(1, o.MaxLength) end
		return t
	end
	local suppress = false
	box:GetPropertyChangedSignal("Text"):Connect(function()
		local t = clean(box.Text)
		if t ~= box.Text then box.Text = t return end
		if not o.Finished and not suppress then
			input.Value = o.Numeric and (tonumber(t) or 0) or t
			input:_fire()
		end
	end)
	box.Focused:Connect(function() Tween(st, { Color = Lumen.Theme.Accent }, 0.2) end)
	box.FocusLost:Connect(function(enter)
		Tween(st, { Color = Lumen.Theme.Stroke }, 0.2)
		if o.Finished then
			input.Value = o.Numeric and (tonumber(box.Text) or 0) or box.Text
			input:_fire()
		end
	end)

	function input:Set(v, silent)
		self.Value = v
		suppress = true
		box.Text = tostring(v)
		suppress = false
		self:_fire(silent)
	end
	RegisterOption(input, o.Flag)
	return input
end
Elements.Textbox = Elements.Input

-- Keybind ------------------------------------------------------------------
local KeyNames = {
	MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3", LeftShift = "LShift", RightShift = "RShift",
	LeftControl = "LCtrl", RightControl = "RCtrl", LeftAlt = "LAlt", RightAlt = "RAlt", Return = "Enter",
}
function Elements:Keybind(o)
	o = o or {}
	local c = self:_card(o, 90)
	local kb = BaseOption(self, o, "Keybind")
	AttachCommon(kb, c)
	kb.Mode = o.Mode or "Press" -- "Press" | "Toggle" | "Hold"
	kb.State = false
	kb.Value = o.Default and (typeof(o.Default) == "EnumItem" and o.Default.Name or tostring(o.Default)) or "None"
	kb.ChangedCallback = o.ChangedCallback
	local listening = false

	local btn = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X, AutoButtonColor = false, Text = "",
		FontFace = Mono(), TextSize = 13,
		Theme = { BackgroundColor3 = "Input", TextColor3 = "Text" }, Parent = c.Header,
	})
	Corner(btn, 6)
	local st = Stroke(btn, "Stroke")
	Padding(btn, 0, 0, 12, 12)
	New("UISizeConstraint", { MinSize = Vector2.new(46, 30), Parent = btn })

	local function render()
		btn.Text = listening and "..." or (KeyNames[kb.Value] or kb.Value)
	end
	render()

	btn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		render()
		Tween(st, { Color = Lumen.Theme.Accent }, 0.2)
	end)

	function kb:Set(key, silent)
		if typeof(key) == "EnumItem" then key = key.Name end
		self.Value = key or "None"
		render()
		if self.Flag then Lumen.Flags[self.Flag] = self.Value end
		if not silent then SafeCall(self.ChangedCallback, self.Value) end
	end

	function kb:_input(input, processed, began)
		local name
		if input.UserInputType == Enum.UserInputType.Keyboard then
			name = input.KeyCode.Name
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
			name = input.UserInputType.Name
		end
		if listening then
			if not began or not name then return end
			listening = false
			Tween(st, { Color = Lumen.Theme.Stroke }, 0.2)
			if name == "Escape" or name == "Backspace" then name = "None" end
			task.defer(function() self:Set(name) end)
			return
		end
		if processed or not name or name ~= self.Value or self.Value == "None" then return end
		if self.Mode == "Hold" then
			self.State = began
			SafeCall(self.Callback, began)
		elseif began then
			if self.Mode == "Toggle" then
				self.State = not self.State
				SafeCall(self.Callback, self.State)
			else
				SafeCall(self.Callback)
			end
		end
	end
	function kb:Destroy()
		c.Frame:Destroy()
		local i = table.find(Keybinds, self)
		if i then table.remove(Keybinds, i) end
	end

	table.insert(Keybinds, kb)
	RegisterOption(kb, o.Flag)
	return kb
end
Elements.Bind = Elements.Keybind

-- Color picker -------------------------------------------------------------
function Elements:ColorPicker(o)
	o = o or {}
	local c = self:_card(o, 48)
	local cp = BaseOption(self, o, "ColorPicker")
	AttachCommon(cp, c)
	cp.Value = o.Default or Color3.fromRGB(255, 255, 255)
	cp.Opened = false
	local h, s, v = cp.Value:ToHSV()

	local swatch = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(48, 26),
		BackgroundColor3 = cp.Value, Parent = c.Header,
	})
	Corner(swatch, 6)
	Stroke(swatch, "Stroke")

	local panel = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false,
		LayoutOrder = 1, Parent = c.Frame,
	})
	local PANEL_H = 172

	local sv = New("Frame", { Size = UDim2.new(1, -30, 0, 130), Active = true, Parent = panel })
	Corner(sv, 6)
	local white = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv })
	Corner(white, 6)
	New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
	local black = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv })
	Corner(black, 6)
	New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
	local svCursor = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, ZIndex = 3, Parent = sv,
	})
	Corner(svCursor, 6)
	New("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Parent = svCursor })

	local hue = New("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 16, 0, 130),
		BackgroundColor3 = Color3.new(1, 1, 1), Active = true, Parent = panel,
	})
	Corner(hue, 6)
	local seq = {}
	for i = 0, 6 do table.insert(seq, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))) end
	New("UIGradient", { Rotation = 90, Color = ColorSequence.new(seq), Parent = hue })
	local hueCursor = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 6, 0, 4),
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = hue,
	})
	Corner(hueCursor, 2)
	New("UIStroke", { Thickness = 1, Transparency = 0.5, Color = Color3.new(0, 0, 0), Parent = hueCursor })

	local hex = New("TextBox", {
		Position = UDim2.fromOffset(0, 140), Size = UDim2.new(0.5, -4, 0, 30), ClearTextOnFocus = false,
		FontFace = Mono(), TextSize = 13, Text = "",
		Theme = { BackgroundColor3 = "Input", TextColor3 = "Text" }, Parent = panel,
	})
	Corner(hex, 6)
	Stroke(hex, "Stroke")
	local rgbLabel = Text({
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 140), Size = UDim2.new(0.5, -4, 0, 30),
		TextSize = 13, FontFace = Mono(), TextXAlignment = Enum.TextXAlignment.Center, Theme = { TextColor3 = "SubText" },
		BackgroundTransparency = 1, Parent = panel,
	})

	local function render()
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.fromScale(s, 1 - v)
		hueCursor.Position = UDim2.new(0.5, 0, h, 0)
		swatch.BackgroundColor3 = cp.Value
		hex.Text = "#" .. cp.Value:ToHex():upper()
		rgbLabel.Text = string.format("%d, %d, %d", cp.Value.R * 255 + 0.5, cp.Value.G * 255 + 0.5, cp.Value.B * 255 + 0.5)
	end

	function cp:Set(color, silent)
		if typeof(color) == "string" then
			local ok, col = pcall(Color3.fromHex, color)
			color = ok and col or self.Value
		end
		self.Value = color
		h, s, v = color:ToHSV()
		render()
		self:_fire(silent)
	end
	local function fromHSV(silent)
		cp.Value = Color3.fromHSV(h, s, v)
		render()
		cp:_fire(silent)
	end

	local dragSV, dragHue = false, false
	sv.InputBegan:Connect(function(i) if IsClick(i) then dragSV = true end end)
	hue.InputBegan:Connect(function(i) if IsClick(i) then dragHue = true end end)
	local function updateDrag(pos)
		-- InputObject.Position and AbsolutePosition share the same origin (below the top bar), so no inset math
		pos = Vector2.new(pos.X, pos.Y)
		if dragSV then
			s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
			v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
			fromHSV()
		elseif dragHue then
			h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
			fromHSV()
		end
	end
	sv.InputBegan:Connect(function(i) if IsClick(i) then updateDrag(i.Position) end end)
	hue.InputBegan:Connect(function(i) if IsClick(i) then updateDrag(i.Position) end end)
	Connect(UserInputService.InputChanged, function(i) if (dragSV or dragHue) and IsMove(i) then updateDrag(i.Position) end end)
	Connect(UserInputService.InputEnded, function(i) if IsClick(i) then dragSV, dragHue = false, false end end)
	hex.FocusLost:Connect(function() cp:Set(hex.Text) end)

	ClickOverlay(c.Header, false).MouseButton1Click:Connect(function()
		cp.Opened = not cp.Opened
		if cp.Opened then
			panel.Visible = true
			Tween(panel, { Size = UDim2.new(1, 0, 0, PANEL_H) }, 0.25)
		else
			Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
			task.delay(0.2, function() if not cp.Opened then panel.Visible = false end end)
		end
	end)

	render()
	RegisterOption(cp, o.Flag)
	SafeCall(cp.Callback, cp.Value)
	return cp
end
Elements.Colorpicker = Elements.ColorPicker

-- Paragraph / Label / Divider ---------------------------------------------
function Elements:Paragraph(o)
	if typeof(o) == "string" then o = { Title = o } end
	o = o or {}
	local c = self:_card({ Title = o.Title, Description = o.Content or o.Description }, o.Icon and 22 or 0)
	local p = { Type = "Paragraph" }
	AttachCommon(p, c)
	if o.Icon then
		IconImage(o.Icon, 16, "SubText", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 1), Parent = c.Header })
	end
	function p:Set(title, content)
		if title then c.Title.Text = title end
		if content then self:SetDescription(content) end
	end
	return p
end

function Elements:Label(text)
	self._order = (self._order or 0) + 1
	local l = Text({
		Text = typeof(text) == "table" and (text.Text or text.Title) or tostring(text or ""),
		TextSize = 13, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._order, Theme = { TextColor3 = "SubText" }, Parent = self.Holder,
	})
	Padding(l, 2, 2, 4, 4)
	return { Frame = l, Set = function(_, t) l.Text = t end, Destroy = function() l:Destroy() end }
end

function Elements:Divider()
	self._order = (self._order or 0) + 1
	local holder = New("Frame", { Size = UDim2.new(1, 0, 0, 9), BackgroundTransparency = 1, LayoutOrder = self._order, Parent = self.Holder })
	local line = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Stroke" }, Parent = holder,
	})
	return { Frame = holder, Destroy = function() holder:Destroy() end }
end

-- Section ------------------------------------------------------------------
function Elements:Section(o)
	if typeof(o) == "string" then o = { Title = o } end
	o = o or {}
	self._order = (self._order or 0) + 1
	local wrap = New("Frame", {
		Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = self._order, Parent = self.Holder,
	})
	List(wrap, 8)
	local head = New("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = wrap })
	local x = 2
	if o.Icon then
		IconImage(o.Icon, 14, "Muted", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Parent = head })
		x = 22
	end
	local title = Text({
		Text = string.upper(o.Title or "Section"), TextSize = 12, FontFace = Font(Enum.FontWeight.Bold),
		Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x, 1, 0), Theme = { TextColor3 = "Muted" }, Parent = head,
	})
	-- thin fading line after the title
	local line = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -(title.TextBounds.X + x + 12), 0, 1),
		Theme = { BackgroundColor3 = "Stroke" }, Parent = head,
	})
	New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = line })
	title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		line.Size = UDim2.new(1, -(title.TextBounds.X + x + 12), 0, 1)
	end)

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		LayoutOrder = 1, Parent = wrap,
	})
	List(holder, 8)
	local section = setmetatable({
		Holder = holder, Tab = self.Tab, Window = self.Window, SectionFrame = wrap, Title = o.Title,
	}, Elements)
	table.insert(self.Tab.Sections, { Frame = wrap, Title = o.Title or "" })
	return section
end

--// Window -----------------------------------------------------------------
local Window = {}
Window.__index = Window

function Lumen:CreateWindow(o)
	o = o or {}
	if o.Theme then self:SetTheme(o.Theme) end
	if o.ConfigFolder then self.ConfigFolder = o.ConfigFolder end

	local size = o.Size or UDim2.fromOffset(640, 450)
	local W = setmetatable({
		Title = o.Title or "Lumen", Tabs = {}, ActiveTab = nil, Minimized = false, Visible = true,
		ToggleKey = o.ToggleKey or Enum.KeyCode.RightShift, MinSize = o.MinSize or Vector2.new(520, 360),
	}, Window)
	table.insert(self.Windows, W)

	local gui = MakeScreenGui("Lumen_" .. (o.Title or "Window"):gsub("%W", ""))
	W.Gui = gui

	local root = New("Frame", {
		Name = "Root", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = size, BackgroundTransparency = 1, Parent = gui,
	})
	W.Root = root
	local scale = New("UIScale", { Scale = 0.97, Parent = root })
	local baseScale, animScale = 1, 0.97
	local function applyScale() scale.Scale = baseScale * animScale end

	-- responsive: shrink to fit small screens (mobile)
	local function fit()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local vp = cam.ViewportSize
		baseScale = math.clamp(math.min(1, (vp.X - 24) / size.X.Offset, (vp.Y - 24) / size.Y.Offset), 0.45, 1)
		applyScale()
	end
	-- Roblox can swap CurrentCamera when the game starts, so follow camera changes too.
	local camConn
	local function hookCamera()
		if camConn then camConn:Disconnect() end
		local cam = workspace.CurrentCamera
		if cam then camConn = Connect(cam:GetPropertyChangedSignal("ViewportSize"), fit) end
		fit()
	end
	Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), hookCamera)

	-- Tween the scale through a NumberValue, then force the final value:
	-- a tween can be dropped (e.g. while the game is still starting) and must not leave the window at 97%.
	local function animateScale(from, to, time, done)
		animScale = from
		applyScale()
		local proxy = Instance.new("NumberValue")
		proxy.Value = from
		proxy.Changed:Connect(function(x) animScale = x applyScale() end)
		Tween(proxy, { Value = to }, time)
		task.delay(time + 0.05, function()
			proxy:Destroy()
			animScale = to
			applyScale()
			if done then done() end
		end)
	end

	-- soft drop shadow (stacked layers, no image needed)
	local shadow = New("Frame", { Name = "Shadow", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = root })
	for i = 1, 12 do
		local layer = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 6),
			Size = UDim2.new(1, i * 4, 1, i * 4), BackgroundTransparency = 0.955,
			Theme = { BackgroundColor3 = "Shadow" }, Parent = shadow,
		})
		Corner(layer, 10 + i * 2)
	end

	-- main body
	local main = New("Frame", {
		Name = "Main", Size = UDim2.fromScale(1, 1), ClipsDescendants = true,
		Theme = { BackgroundColor3 = "Background" }, Parent = root,
	})
	Corner(main, 10)
	W.Main = main
	Stroke(main, "Stroke")
	-- Optional: one static accent line along the top edge (AccentLine = true). No animation, no glow.
	if o.AccentLine then
		local line = New("Frame", {
			Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -32, 0, 1), Theme = { BackgroundColor3 = "Accent" }, Parent = main,
		})
		New("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.3),
				NumberSequenceKeypoint.new(0.75, 0.3), NumberSequenceKeypoint.new(1, 1),
			}), Parent = line,
		})
	end

	-- top bar
	local TOP = 58
	local topbar = New("Frame", { Name = "Topbar", Size = UDim2.new(1, 0, 0, TOP), BackgroundTransparency = 1, Active = true, Parent = main })
	local logo = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(34, 34),
		Theme = { BackgroundColor3 = "Element" }, Parent = topbar,
	})
	Corner(logo, 8)
	Stroke(logo, "Stroke")
	local logoInner = logo
	if o.Icon and Lumen:GetIcon(o.Icon) then
		IconImage(o.Icon, 20, "Text", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = logoInner })
	else
		Text({
			Text = o.Logo or string.sub(W.Title, 1, 1):upper(), TextSize = 17, FontFace = Font(Enum.FontWeight.Bold),
			TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = logoInner,
		})
	end

	Text({
		Text = W.Title, TextSize = 18, FontFace = Font(Enum.FontWeight.Bold),
		Position = UDim2.fromOffset(60, o.Subtitle and 11 or 0), Size = UDim2.new(1, -170, 0, o.Subtitle and 22 or TOP),
		Parent = topbar,
	})
	if o.Subtitle then
		Text({
			Text = o.Subtitle, TextSize = 13, Position = UDim2.fromOffset(60, 31), Size = UDim2.new(1, -170, 0, 16),
			Theme = { TextColor3 = "SubText" }, Parent = topbar,
		})
	end

	local function topButton(icon, order)
		local b = New("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14 - (order - 1) * 38, 0.5, 0),
			Size = UDim2.fromOffset(30, 30), Text = "", AutoButtonColor = false,
			Theme = { BackgroundColor3 = "Element" }, Parent = topbar,
		})
		Corner(b, 6)
		local st = Stroke(b, "Stroke")
		local img = IconImage(icon, 16, "SubText", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = b })
		b.MouseEnter:Connect(function()
			Tween(b, { BackgroundColor3 = Lumen.Theme.ElementHover }, 0.15)
			Tween(img, { ImageColor3 = Lumen.Theme.Text }, 0.15)
		end)
		b.MouseLeave:Connect(function()
			Tween(b, { BackgroundColor3 = Lumen.Theme.Element }, 0.15)
			Tween(img, { ImageColor3 = Lumen.Theme.SubText }, 0.15)
		end)
		return b, img
	end
	local closeBtn = topButton("x", 1)
	local minBtn, minImg = topButton("minus", 2)

	-- divider under the top bar
	local divider = New("Frame", {
		Position = UDim2.fromOffset(0, TOP), Size = UDim2.new(1, 0, 0, 1), Theme = { BackgroundColor3 = "Stroke" }, Parent = main,
	})

	-- body
	local FOOT = o.Footer == false and 0 or 28
	local body = New("Frame", {
		Name = "Body", Position = UDim2.fromOffset(0, TOP + 1), Size = UDim2.new(1, 0, 1, -(TOP + 1 + FOOT)),
		BackgroundTransparency = 1, Parent = main,
	})
	local SIDE = o.SidebarWidth or 190
	local sidebar = New("Frame", {
		Name = "Sidebar", Position = UDim2.fromOffset(12, 12), Size = UDim2.new(0, SIDE, 1, -12),
		Theme = { BackgroundColor3 = "Sidebar" }, Parent = body,
	})
	Corner(sidebar, 8)
	Stroke(sidebar, "Stroke", 1, 0.3)

	local searchBox = New("TextBox", {
		Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 36), Text = "", PlaceholderText = "Search...",
		ClearTextOnFocus = false, FontFace = Font(Enum.FontWeight.Medium), TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Theme = { BackgroundColor3 = "Element", TextColor3 = "Text", PlaceholderColor3 = "Muted" }, Parent = sidebar,
	})
	Corner(searchBox, 6)
	local searchStroke = Stroke(searchBox, "Stroke", 1, 0.4)
	Padding(searchBox, 0, 0, 34, 10)
	IconImage("search", 16, "Muted", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -24, 0.5, 0), Parent = searchBox })

	local showUser = o.ShowUser ~= false and LocalPlayer ~= nil
	local USER_H = showUser and 58 or 0
	local tabList = New("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 52), Size = UDim2.new(1, -16, 1, -(60 + USER_H)), BackgroundTransparency = 1,
		ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = sidebar,
	})
	List(tabList, 4)

	if showUser then
		local user = New("Frame", {
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8), Size = UDim2.new(1, -16, 0, 46),
			Theme = { BackgroundColor3 = "Element" }, Parent = sidebar,
		})
		Corner(user, 6)
		Stroke(user, "Stroke", 1, 0.4)
		local av = New("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 7, 0.5, 0), Size = UDim2.fromOffset(32, 32),
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=48&h=48",
			Theme = { BackgroundColor3 = "ToggleOff" }, Parent = user,
		})
		Corner(av, 16)
		Text({
			Text = LocalPlayer.DisplayName, TextSize = 14, FontFace = Font(Enum.FontWeight.Bold),
			Position = UDim2.fromOffset(47, 7), Size = UDim2.new(1, -52, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Parent = user,
		})
		Text({
			Text = "@" .. LocalPlayer.Name, TextSize = 12, Position = UDim2.fromOffset(47, 24), Size = UDim2.new(1, -52, 0, 14),
			TextTruncate = Enum.TextTruncate.AtEnd, Theme = { TextColor3 = "Muted" }, Parent = user,
		})
	end

	local pages = New("Frame", {
		Name = "Pages", Position = UDim2.fromOffset(SIDE + 24, 12), Size = UDim2.new(1, -(SIDE + 36), 1, -12),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = body,
	})
	W.Pages = pages

	-- footer
	if FOOT > 0 then
		local foot = New("Frame", {
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, FOOT),
			BackgroundTransparency = 1, Parent = main,
		})
		Text({
			Text = o.Footer or ("Lumen UI  ·  v" .. Lumen.Version), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1), Theme = { TextColor3 = "Muted" }, Parent = foot,
		})
		if o.Resizable ~= false then
			local grip = New("ImageButton", {
				AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -6, 1, -6), Size = UDim2.fromOffset(16, 16),
				BackgroundTransparency = 1, Image = Lumen:GetIcon("move-diagonal"), Theme = { ImageColor3 = "Muted" }, Parent = foot,
			})
			local resizing, startPos, startSize, startRoot
			grip.InputBegan:Connect(function(input)
				if IsClick(input) and not W.Minimized then
					resizing, startPos, startSize, startRoot = true, input.Position, root.AbsoluteSize / scale.Scale, root.Position
				end
			end)
			Connect(UserInputService.InputChanged, function(input)
				if resizing and IsMove(input) then
					local d = (input.Position - startPos) / scale.Scale
					local nx = math.max(W.MinSize.X, startSize.X + d.X)
					local ny = math.max(W.MinSize.Y, startSize.Y + d.Y)
					size = UDim2.fromOffset(nx, ny)
					root.Size = size
					-- root is centre-anchored, so shift it to keep the top-left corner pinned
					local k = scale.Scale / 2
					root.Position = startRoot + UDim2.fromOffset((nx - startSize.X) * k, (ny - startSize.Y) * k)
				end
			end)
			Connect(UserInputService.InputEnded, function(input) if IsClick(input) then resizing = false end end)
		end
	end

	-- dragging
	do
		local dragging, dragStart, startPos
		topbar.InputBegan:Connect(function(input)
			if IsClick(input) then
				dragging, dragStart, startPos = true, input.Position, root.Position
			end
		end)
		Connect(UserInputService.InputChanged, function(input)
			if dragging and IsMove(input) then
				local d = input.Position - dragStart
				Tween(root, { Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) }, 0.08)
			end
		end)
		Connect(UserInputService.InputEnded, function(input) if IsClick(input) then dragging = false end end)
	end

	-- search filtering (current tab's elements)
	local function applySearch()
		local tab = W.ActiveTab
		if not tab then return end
		local q = searchBox.Text:lower()
		local sectionHits = {}
		-- a section whose own name matches shows everything inside it
		local sectionMatch = {}
		for _, s in ipairs(tab.Sections) do
			if q ~= "" and s.Title:lower():find(q, 1, true) then sectionMatch[s.Frame] = true end
		end
		for _, item in ipairs(tab.Searchables) do
			if item.Frame.Parent then
				local hay = (item.Title.Text .. " " .. item.Desc.Text):lower()
				local hit = q == "" or hay:find(q, 1, true) ~= nil or (item.Section and sectionMatch[item.Section]) == true
				item.Frame.Visible = hit
				if hit and item.Section then sectionHits[item.Section] = true end
			end
		end
		for _, s in ipairs(tab.Sections) do
			s.Frame.Visible = q == "" or sectionHits[s.Frame] == true or s.Title:lower():find(q, 1, true) ~= nil
		end
		tab.Empty.Visible = q ~= "" and not next(sectionHits) and (function()
			for _, item in ipairs(tab.Searchables) do if item.Frame.Visible and not item.Section then return false end end
			return true
		end)()
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)
	searchBox.Focused:Connect(function() Tween(searchStroke, { Color = Lumen.Theme.Accent, Transparency = 0 }, 0.2) end)
	searchBox.FocusLost:Connect(function() Tween(searchStroke, { Color = Lumen.Theme.Stroke, Transparency = 0.4 }, 0.2) end)
	W._applySearch = applySearch
	W._searchBox = searchBox
	W._tabList = tabList

	-- minimize / close
	local fullSize
	function W:Minimize(state)
		if state == nil then state = not self.Minimized end
		self.Minimized = state
		-- root is centre-anchored, so move it while resizing to keep the top bar in place
		if state then
			fullSize = root.Size
			local shift = (fullSize.Y.Offset - TOP) / 2 * scale.Scale
			Tween(root, { Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, TOP), Position = root.Position - UDim2.fromOffset(0, shift) }, 0.35)
			minImg.Image = Lumen:GetIcon("plus")
		else
			local target = fullSize or size
			local shift = (target.Y.Offset - TOP) / 2 * scale.Scale
			Tween(root, { Size = target, Position = root.Position + UDim2.fromOffset(0, shift) }, 0.35)
			minImg.Image = Lumen:GetIcon("minus")
		end
	end
	minBtn.MouseButton1Click:Connect(function() W:Minimize() end)
	closeBtn.MouseButton1Click:Connect(function()
		W:Dialog({
			Title = "Close interface?", Icon = "alert-triangle",
			Content = "This will unload the UI. Any running features keep their last state.",
			Buttons = {
				{ Title = "Cancel" },
				{ Title = "Close", Primary = true, Callback = function() Lumen:Destroy() end },
			},
		})
	end)

	-- visibility toggle (keyboard + optional floating button for mobile)
	function W:SetVisible(v)
		self.Visible = v
		if v then
			gui.Enabled = true
			animateScale(0.97, 1, 0.2)
		else
			animateScale(animScale, 0.97, 0.15, function()
				if not self.Visible then gui.Enabled = false end
			end)
		end
	end
	function W:Toggle() self:SetVisible(not self.Visible) end

	Connect(UserInputService.InputBegan, function(input, processed)
		if processed then return end
		local key = W.ToggleKey
		if typeof(key) == "string" then key = Enum.KeyCode[key] end
		if input.KeyCode == key then W:Toggle() end
	end)

	local wantButton = o.MobileButton
	if wantButton == nil then wantButton = UserInputService.TouchEnabled end
	if wantButton then
		local mgui = MakeScreenGui("Lumen_Toggle_" .. W.Title:gsub("%W", ""))
		W.ToggleGui = mgui
		local mb = New("TextButton", {
			Position = UDim2.new(0, 16, 0.5, -24), Size = UDim2.fromOffset(48, 48), Text = "", AutoButtonColor = false,
			Theme = { BackgroundColor3 = "Element" }, Parent = mgui,
		})
		Corner(mb, 10)
		Stroke(mb, "Stroke")
		local inner = mb
		Text({
			Text = o.Logo or string.sub(W.Title, 1, 1):upper(), TextSize = 18, FontFace = Font(Enum.FontWeight.Bold),
			TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = inner,
		})
		local dragging, moved, ds, sp
		mb.InputBegan:Connect(function(i) if IsClick(i) then dragging, moved, ds, sp = true, false, i.Position, mb.Position end end)
		Connect(UserInputService.InputChanged, function(i)
			if dragging and IsMove(i) then
				local d = i.Position - ds
				if d.Magnitude > 6 then moved = true end
				mb.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
			end
		end)
		Connect(UserInputService.InputEnded, function(i)
			if dragging and IsClick(i) then
				dragging = false
				if not moved then W:Toggle() end
			end
		end)
	end

	-- intro animation
	task.defer(function()
		hookCamera()
		animateScale(0.97, 1, 0.22)
	end)

	return W
end

-- Tab ----------------------------------------------------------------------
function Window:Tab(o, icon)
	if typeof(o) == "string" then o = { Title = o, Icon = icon } end
	o = o or {}
	local W = self
	local index = #W.Tabs + 1

	local btn = New("TextButton", {
		Name = o.Title or "Tab", Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false,
		BackgroundTransparency = 1, LayoutOrder = index, Theme = { BackgroundColor3 = "Element" }, Parent = W._tabList,
	})
	Corner(btn, 6)
	local indicator = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.fromOffset(3, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), Parent = btn,
	})
	Corner(indicator, 2)
	AccentFill(indicator)

	local hasIcon = o.Icon and Lumen:GetIcon(o.Icon)
	local img = hasIcon and IconImage(o.Icon, 18, "SubText", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 18, 0.5, 0), Parent = btn,
	})
	local label = Text({
		Text = o.Title or "Tab", TextSize = 15, FontFace = Font(Enum.FontWeight.SemiBold),
		Position = UDim2.fromOffset(hasIcon and 46 or 18, 0), Size = UDim2.new(1, -(hasIcon and 52 or 24), 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd, Theme = { TextColor3 = "SubText" }, Parent = btn,
	})

	local page = New("ScrollingFrame", {
		Name = o.Title or "Page", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false,
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y, Theme = { ScrollBarImageColor3 = "Stroke" },
		ElasticBehavior = Enum.ElasticBehavior.Never, Parent = W.Pages,
	})
	Padding(page, 0, 12, 0, 8)
	List(page, 8)

	local empty = Text({
		Text = "No results", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 60),
		Visible = false, LayoutOrder = 99999, Theme = { TextColor3 = "Muted" }, Parent = page,
	})

	local tab = setmetatable({
		Title = o.Title, Holder = page, Window = W, TabButton = btn, Page = page, Searchables = {}, Sections = {}, Empty = empty,
	}, Elements)
	tab.Tab = tab
	table.insert(W.Tabs, tab)

	function tab:Select()
		W:SelectTab(self)
	end
	tab._setActive = function(active)
		Tween(btn, { BackgroundTransparency = active and 0 or 1 }, 0.2)
		Tween(label, { TextColor3 = active and Lumen.Theme.Text or Lumen.Theme.SubText }, 0.2)
		label.FontFace = Font(active and Enum.FontWeight.Bold or Enum.FontWeight.SemiBold)
		if img then Tween(img, { ImageColor3 = active and Lumen.Theme.Text or Lumen.Theme.SubText }, 0.2) end
		Tween(indicator, { Size = UDim2.fromOffset(3, active and 18 or 0) }, 0.2)
	end
	-- keep active colours correct after theme switches
	Lumen:OnThemeChanged(function() if W.ActiveTab == tab then tab._setActive(true) end end)

	btn.MouseEnter:Connect(function()
		if W.ActiveTab ~= tab then Tween(btn, { BackgroundTransparency = 0.5 }, 0.15) end
	end)
	btn.MouseLeave:Connect(function()
		if W.ActiveTab ~= tab then Tween(btn, { BackgroundTransparency = 1 }, 0.15) end
	end)
	btn.MouseButton1Click:Connect(function() W:SelectTab(tab) end)

	if index == 1 then W:SelectTab(tab) end
	return tab
end
Window.AddTab = Window.Tab
Window.CreateTab = Window.Tab

function Window:SelectTab(tab)
	if typeof(tab) == "number" then tab = self.Tabs[tab] end
	if not tab or self.ActiveTab == tab then return end
	local prev = self.ActiveTab
	if prev then
		prev._setActive(false)
		prev.Page.Visible = false
	end
	self.ActiveTab = tab
	tab._setActive(true)
	tab.Page.Visible = true
	tab.Page.Position = UDim2.fromOffset(0, 6)
	Tween(tab.Page, { Position = UDim2.fromOffset(0, 0) }, 0.2)
	self._applySearch()
end

-- Dialog -------------------------------------------------------------------
function Window:Dialog(o)
	o = o or {}
	local overlay = New("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, ZIndex = 50, Parent = self.Main,
	})
	Corner(overlay, 10)
	Tween(overlay, { BackgroundTransparency = 0.45 }, 0.2)

	local box = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.51), Size = UDim2.new(0, 340, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 51, Theme = { BackgroundColor3 = "Sidebar" }, Parent = overlay,
	})
	Corner(box, 8)
	Stroke(box, "Stroke")
	Padding(box, 18, 16, 18, 18)
	List(box, 12)

	local head = New("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = box })
	local tx = 0
	if o.Icon then
		IconImage(o.Icon, 20, "Accent", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Parent = head })
		tx = 30
	end
	Text({ Text = o.Title or "Dialog", TextSize = 18, FontFace = Font(Enum.FontWeight.Bold), Position = UDim2.fromOffset(tx, 0), Size = UDim2.new(1, -tx, 1, 0), Parent = head })
	if o.Content then
		Text({
			Text = o.Content, TextSize = 14, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1, Theme = { TextColor3 = "SubText" }, Parent = box,
		})
	end
	local row = New("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 2, Parent = box })
	List(row, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		Tween(overlay, { BackgroundTransparency = 1 }, 0.18)
		Tween(box, { Position = UDim2.fromScale(0.5, 0.51) }, 0.18)
		task.delay(0.18, function() overlay:Destroy() end)
	end

	for i, b in ipairs(o.Buttons or { { Title = "OK", Primary = true } }) do
		local btn = New("TextButton", {
			Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, Text = b.Title or "OK", AutoButtonColor = false,
			FontFace = Font(Enum.FontWeight.Bold), TextSize = 14, LayoutOrder = i, Parent = row,
		})
		Corner(btn, 6)
		Padding(btn, 0, 0, 16, 16)
		if b.Primary then
			Bind(btn, "BackgroundColor3", "Accent")
			Bind(btn, "TextColor3", "OnAccent")
		else
			Bind(btn, "BackgroundColor3", "Element")
			Bind(btn, "TextColor3", "Text")
			Stroke(btn, "Stroke")
		end
		btn.MouseButton1Click:Connect(function()
			close()
			SafeCall(b.Callback)
		end)
	end
	Tween(box, { Position = UDim2.fromScale(0.5, 0.5) }, 0.2)
	return { Close = close }
end

function Window:Notify(o) return Lumen:Notify(o) end

-- Ready-made settings tab: theme switcher, UI keybind, configs, unload.
function Window:BuildSettingsTab(o)
	o = o or {}
	local W = self
	local tab = self:Tab({ Title = o.Title or "Settings", Icon = o.Icon or "settings" })

	local look = tab:Section({ Title = "Appearance", Icon = "palette" })
	look:Dropdown({
		Title = "Theme", Description = "Changes the interface colours.", Values = Lumen:GetThemes(), Default = Lumen.ThemeName,
		IgnoreConfig = true, Callback = function(v) Lumen:SetTheme(v) end,
	})
	look:Keybind({
		Title = "Toggle UI", Description = "Show or hide this window.", Default = W.ToggleKey, IgnoreConfig = true,
		ChangedCallback = function(k) W.ToggleKey = Enum.KeyCode[k] or W.ToggleKey end,
	})

	local cfg = tab:Section({ Title = "Configuration", Icon = "save" })
	local nameBox = cfg:Input({ Title = "Config name", Placeholder = "my config", IgnoreConfig = true })
	local list = cfg:Dropdown({ Title = "Saved configs", Values = Lumen:ListConfigs(), IgnoreConfig = true })
	cfg:Button({
		Title = "Save config", Description = "Saves every flagged option.", Icon = "save",
		Callback = function()
			local name = nameBox.Value ~= "" and nameBox.Value or list.Value
			if not name or name == "" then return Lumen:Notify({ Title = "Config", Content = "Enter a config name first.", Type = "Warning" }) end
			local ok, err = Lumen:SaveConfig(name)
			Lumen:Notify({ Title = ok and "Config saved" or "Save failed", Content = ok and name or err, Type = ok and "Success" or "Error" })
			list:Refresh(Lumen:ListConfigs(), true)
		end,
	})
	cfg:Button({
		Title = "Load config", Description = "Loads the config selected above.", Icon = "download",
		Callback = function()
			if not list.Value then return Lumen:Notify({ Title = "Config", Content = "Pick a config first.", Type = "Warning" }) end
			local ok, err = Lumen:LoadConfig(list.Value)
			Lumen:Notify({ Title = ok and "Config loaded" or "Load failed", Content = ok and list.Value or err, Type = ok and "Success" or "Error" })
		end,
	})
	cfg:Button({
		Title = "Set as autoload", Description = "Loads this config automatically next time.", Icon = "star",
		Callback = function()
			if not list.Value then return Lumen:Notify({ Title = "Config", Content = "Pick a config first.", Type = "Warning" }) end
			local ok = Lumen:SetAutoload(list.Value)
			Lumen:Notify({ Title = ok and "Autoload set" or "Not supported", Content = ok and list.Value or "File functions are unavailable.", Type = ok and "Success" or "Error" })
		end,
	})
	cfg:Button({ Title = "Refresh list", Icon = "refresh", Callback = function() list:Refresh(Lumen:ListConfigs(), true) end })

	local misc = tab:Section({ Title = "Interface", Icon = "monitor" })
	misc:Button({
		Title = "Unload", Description = "Removes the UI and disconnects everything.", Icon = "power",
		Callback = function() Lumen:Destroy() end,
	})
	return tab
end

--// Config system ----------------------------------------------------------
local hasFS = typeof(writefile) == "function" and typeof(readfile) == "function"
local function ensureFolder()
	if not hasFS then return false end
	pcall(function() if not isfolder(Lumen.ConfigFolder) then makefolder(Lumen.ConfigFolder) end end)
	return true
end

function Lumen:SaveConfig(name)
	if not ensureFolder() then return false, "writefile is not available here" end
	local data = {}
	for flag, opt in pairs(self.Options) do
		if not opt.IgnoreConfig then
			local v = opt.Value
			if opt.Type == "ColorPicker" then v = v:ToHex() end
			data[flag] = { type = opt.Type, value = v }
		end
	end
	local ok, err = pcall(writefile, self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
	return ok, err
end

function Lumen:LoadConfig(name)
	if not hasFS then return false, "readfile is not available here" end
	local ok, raw = pcall(readfile, self.ConfigFolder .. "/" .. name .. ".json")
	if not ok then return false, "config not found" end
	local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok2 then return false, "config is corrupted" end
	for flag, entry in pairs(data) do
		local opt = self.Options[flag]
		if opt and opt.Set then
			local v = entry.value
			if opt.Type == "ColorPicker" then v = "#" .. tostring(v) end
			pcall(function() opt:Set(v) end)
		end
	end
	return true
end

function Lumen:ListConfigs()
	if not hasFS or typeof(listfiles) ~= "function" then return {} end
	ensureFolder()
	local out = {}
	local ok, files = pcall(listfiles, self.ConfigFolder)
	if not ok then return out end
	for _, f in ipairs(files) do
		local n = f:match("([^/\\]+)%.json$")
		if n then table.insert(out, n) end
	end
	return out
end

function Lumen:SetAutoload(name)
	if not ensureFolder() then return false end
	return pcall(writefile, self.ConfigFolder .. "/autoload.txt", name)
end

-- Call this AFTER you have created all your elements.
function Lumen:LoadAutoloadConfig()
	if not hasFS then return end
	local ok, name = pcall(readfile, self.ConfigFolder .. "/autoload.txt")
	if ok and name and name ~= "" then
		local loaded = self:LoadConfig(name)
		if loaded then self:Notify({ Title = "Autoload", Content = "Loaded config '" .. name .. "'", Type = "Success", Duration = 3 }) end
	end
end

--// Cleanup ----------------------------------------------------------------
function Lumen:Destroy()
	if self.Unloaded then return end
	self.Unloaded = true
	for _, fn in ipairs(UnloadCallbacks) do pcall(fn) end
	for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
	table.clear(Connections)
	for _, W in ipairs(self.Windows) do
		if W.Gui then W.Gui:Destroy() end
		if W.ToggleGui then W.ToggleGui:Destroy() end
	end
	if NotifyGui then NotifyGui:Destroy() end
	table.clear(Keybinds)
end
Lumen.Unload = Lumen.Destroy

return Lumen
