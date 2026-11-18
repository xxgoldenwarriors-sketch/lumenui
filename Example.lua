-- Lumen UI example. Shows every element.
-- Executor:   local Lumen = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_NAME/Lumen/main/Lumen.lua"))()
-- Studio:     local Lumen = require(path.to.Lumen)
local Lumen = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_NAME/Lumen/main/Lumen.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Lumen:CreateWindow({
	Title = "Lumen Hub",
	Subtitle = "example made with Lumen UI",
	Logo = "L",                         -- or Icon = "target"
	Theme = "Graphite",                 -- Graphite, Mono, Slate, Paper
	Size = UDim2.fromOffset(640, 450),
	ToggleKey = Enum.KeyCode.RightShift,
	ConfigFolder = "LumenHub",
	Footer = "Made with Lumen UI",
	AccentLine = true,                  -- one static accent line on the top edge (optional)
})

local function Humanoid()
	local char = LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

--// Movement --------------------------------------------------------------
local Movement = Window:Tab({ Title = "Movement", Icon = "person-standing" })

local Speed = Movement:Slider({
	Title = "WalkSpeed", Description = "Run faster",
	Min = 16, Max = 120, Default = 16, Increment = 1, Flag = "WalkSpeed",
	Callback = function(v)
		local h = Humanoid()
		if h then h.WalkSpeed = v end
	end,
})

local Jump = Movement:Slider({
	Title = "Jump Power", Description = "Jump higher",
	Min = 50, Max = 200, Default = 50, Flag = "JumpPower",
	Callback = function(v)
		local h = Humanoid()
		if h then h.UseJumpPower = true h.JumpPower = v end
	end,
})

Movement:Toggle({
	Title = "Keep Speed & Jump", Description = "Re-applies speed and jump if the game resets them",
	Flag = "KeepStats",
	Callback = function(on)
		-- example of a loop that stops when the toggle goes off or the UI unloads
		task.spawn(function()
			while Lumen.Flags.KeepStats and not Lumen.Unloaded do
				local h = Humanoid()
				if h then
					h.WalkSpeed = Speed.Value
					h.JumpPower = Jump.Value
				end
				task.wait(0.25)
			end
		end)
	end,
})

local InfJump
Movement:Toggle({
	Title = "Infinite Jump", Description = "Jump again in the air", Flag = "InfJump",
	Callback = function(on)
		if InfJump then InfJump:Disconnect() InfJump = nil end
		if on then
			InfJump = game:GetService("UserInputService").JumpRequest:Connect(function()
				local h = Humanoid()
				if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		end
	end,
})

--// Visual ------------------------------------------------------------------
local Visual = Window:Tab({ Title = "Visual", Icon = "eye" })
local World = Visual:Section({ Title = "World", Icon = "sun" })

World:Toggle({
	Title = "Fullbright", Description = "Removes shadows and darkness", Flag = "Fullbright",
	Callback = function(on)
		local L = game:GetService("Lighting")
		L.GlobalShadows = not on
		L.Brightness = on and 3 or 2
	end,
})
World:Slider({
	Title = "Field of View", Min = 50, Max = 120, Default = 70, Suffix = "°", Flag = "FOV",
	Callback = function(v) workspace.CurrentCamera.FieldOfView = v end,
})
World:ColorPicker({
	Title = "Ambient colour", Description = "Tints the world", Default = Color3.fromRGB(128, 128, 128), Flag = "Ambient",
	Callback = function(c) game:GetService("Lighting").Ambient = c end,
})

local Players_ = Visual:Section({ Title = "Players", Icon = "users" })
Players_:Dropdown({
	Title = "Highlight mode", Description = "How other players are drawn",
	Values = { "Off", "Outline", "Fill", "Outline + Fill" }, Default = "Off", Flag = "HighlightMode",
	Callback = function(v) print("Highlight mode:", v) end,
})
Players_:Dropdown({
	Title = "Show info", Multi = true,
	Values = { "Name", "Distance", "Health", "Team" }, Default = { "Name" }, Flag = "EspInfo",
	Callback = function(list) print("Showing:", table.concat(list, ", ")) end,
})

--// Utility -----------------------------------------------------------------
local Utility = Window:Tab({ Title = "Utility", Icon = "wrench" })

Utility:Input({
	Title = "Teleport to player", Description = "Type part of a name and press Enter",
	Placeholder = "username", Finished = true,
	Callback = function(text)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Name:lower():find(text:lower(), 1, true) and p.Character then
				LocalPlayer.Character:PivotTo(p.Character:GetPivot())
				return Lumen:Notify({ Title = "Teleported", Content = "to " .. p.DisplayName, Type = "Success" })
			end
		end
		Lumen:Notify({ Title = "Not found", Content = "No player matches '" .. text .. "'", Type = "Warning" })
	end,
})
Utility:Keybind({
	Title = "Reset speed", Description = "Press to set WalkSpeed back to 16", Default = Enum.KeyCode.R,
	Callback = function() Speed:Set(16) end,
})
Utility:Button({
	Title = "Rejoin", Description = "Reconnect to this server", Icon = "refresh",
	Callback = function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end,
})
Utility:Paragraph({
	Title = "Tip", Icon = "info",
	Content = "Press RightShift to hide the window. Every element with a Flag is saved by the config system.",
})

--// Fun ---------------------------------------------------------------------
local Fun = Window:Tab({ Title = "Fun", Icon = "gamepad" })
Fun:Button({
	Title = "Info notification",
	Callback = function() Lumen:Notify({ Title = "Hello!", Content = "This is an info notification.", Duration = 4 }) end,
})
Fun:Button({
	Title = "Success notification", Icon = "check-circle",
	Callback = function() Lumen:Notify({ Title = "Done", Content = "Everything worked.", Type = "Success" }) end,
})
Fun:Button({
	Title = "Error notification", Icon = "x-circle",
	Callback = function() Lumen:Notify({ Title = "Uh oh", Content = "Something went wrong.", Type = "Error" }) end,
})
Fun:Button({
	Title = "Open a dialog", Icon = "message",
	Callback = function()
		Window:Dialog({
			Title = "Are you sure?", Icon = "alert-triangle",
			Content = "Dialogs can have any number of buttons.",
			Buttons = {
				{ Title = "Cancel" },
				{ Title = "Do it", Primary = true, Callback = function() Lumen:Notify({ Title = "Confirmed" }) end },
			},
		})
	end,
})

--// Settings (theme, toggle key, configs, unload) --------------------------
Window:BuildSettingsTab()

-- Undo changes when the UI is unloaded
Lumen:OnUnload(function()
	local h = Humanoid()
	if h then h.WalkSpeed = 16 h.JumpPower = 50 end
	if InfJump then InfJump:Disconnect() end
end)

Lumen:LoadAutoloadConfig()
Lumen:Notify({ Title = "Lumen loaded", Content = "Press RightShift to toggle the UI.", Type = "Success" })
