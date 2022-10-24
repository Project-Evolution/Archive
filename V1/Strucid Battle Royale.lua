-- yay queueonteleport

local Hint = Instance.new("Hint", game:GetService("CoreGui"))
Hint.Text = "Waiting For Game To Load..."
repeat wait() until game:IsLoaded()
local ContentProvider = game:GetService("ContentProvider")
if ContentProvider.RequestQueueSize > 0 then
	repeat wait() until ContentProvider.RequestQueueSize == 0
end
Hint:Destroy()

-- Anti Ban

local Meta = getrawmetatable(game)
local Namecall = Meta.__namecall
makewriteable(Meta)

Meta.__namecall = newcclosure(function(self, ...)
	local Method = getnamecallmethod()
	if Method == "FireServer" then
		local Args = {...}
		if Args[1] == 1 and Args[2] > 1 then
			return
		end
	elseif Method == "FindPartOnRayWithIgnoreList" then
		local Trace = traceback()
		if string.find(Trace, "Shoot") or string.find(Trace, "Effect") then
			local Args = {...}
			if Settings.Wallbang.Enabled or (Settings.SilentAim.Enabled and Target) then
				table.insert(Args[2], workspace.Map)
				table.insert(Args[2], workspace.BuildStuff)
			end
			if Settings.InfRange.Enabled or (Settings.SilentAim.Enabled and Target) then
				Args[1] = Ray.new(Args[1].Origin, Args[1].Direction.Unit * 2048)
			end
		end
	end
	return Namecall(self, ...)
end)

makereadonly(Meta)

if getconnections then
	pcall(function()
		for i, v in next, getconnections(game:GetService("ScriptContext").Error) do
			if type(v) == "RBXScriptConnection" then
				v:Disconnect()
			elseif type(v) == "table" then
				v:Disable()
			end
		end
	end)
end

-- Variables

local Settings = {}
local Configs, SelectedConfig, ConfigName

local Services = setmetatable({}, {
    __index = function(t, k)
        return game:GetService(k)
    end
})

local Local = {
	Player = Services.Players.LocalPlayer,
	Menu = Services.Players.LocalPlayer.PlayerGui.MenuGUI,
	Mouse = Services.Players.LocalPlayer:GetMouse(),
	Cam = workspace.CurrentCamera
}

local Godmode = false
local BodyParts = { "Head", "Neck", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "UpperTorso", "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg" }
local MidScr = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y / 2)
local TracerOrigins = { Top = Vector2.new(Local.Cam.ViewportSize.X / 2, 0), Middle = MidScr, Bottom = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y) }
local FOVCircle = newdrawing("Circle")
local SilentAimMode = "Body"
local Target = nil

local Modules = Services.ReplicatedStorage.Weapons.Modules:GetChildren()
local Network = require(Services.ReplicatedStorage.NetworkModule)
local GlobalStuff = require(Services.ReplicatedStorage.GlobalStuff)
local GunStatTable, Found, Rarities = {}, {}, {
	Common = Color3.new(0.75, 0.75, 0.75),
	Uncommon = Color3.new(0, 0.75, 0),
	Rare = Color3.new(0, 0, 0.75),
	Epic = Color3.new(0.75, 0, 0.75),
	Legendary = Color3.new(0.75, 0.75, 0)
}

local Esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/EspModule.lua", true))()

-- Functions

function RegisterChar(char)
    Local.Char = char
    Local.Root = char:WaitForChild("HumanoidRootPart")
	Local.Hum = char:WaitForChild("Humanoid")
	if Godmode then
		char:WaitForChild("Shield"):Destroy()
	end
    Local.Hum.Died:Connect(function()
		Local.Char, Local.Root, Local.Hum = nil, nil, nil
	end)
	while wait() do
		local Succ, Res = pcall(function()
			return getsenv(Local.Player.PlayerGui.MainGui.MainLocal)
		end)
		if Succ and type(Res) == "table" and rawget(Res, "CameraRecoil") then
			RegisterEnv(Res)
			break
		end
	end
end

function RegisterEnv(env)
	local Recoil = env.CameraRecoil
	env.CameraRecoil = newcclosure(function(...)
		if Settings.NoRecoil.Enabled then
			return
		end
		return Recoil(...)
	end)
	local UpdateAmmo = env.UpdateAmmoLabel
	env.UpdateAmmoLabel = newcclosure(function(...)
		for i, v in next, getupvalue(UpdateAmmo, 4) do
			if GunStatTable[v[1]] and Settings.RapidFire.Enabled then
				v[5] = 0
			end
		end
		return UpdateAmmo(...)
	end)
	local Progress = env.GetProgress
	env.GetProgress = newcclosure(function(time, func)
		if Settings.InstantActions.Enabled then
			return Progress(0, func)
		end
		return Progress(time, func)
	end)
	getfenv(env.Shoot).wait = newcclosure(function(...)
	    if Settings.RapidFire.Enabled then
	        Services.RunService.Stepped:Wait()
	        return
	    end
	    getrenv().wait(...)
	end)
end

function RegisterEsp(plr)
	if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		local Root = plr.Character:WaitForChild("HumanoidRootPart")
		Esp.Add(plr, Root, plr.TeamColor.Color)
		coroutine.wrap(function()
			repeat wait() until not (plr.Character and plr.Character.Parent == workspace)
			Esp.Remove(Root)
		end)()
	end
	plr.CharacterAdded:Connect(function(char)
		local Root = char:WaitForChild("HumanoidRootPart")
		Esp.Add(plr, Root, plr.TeamColor.Color)
		coroutine.wrap(function()
			repeat wait() until not (char and char.Parent == workspace)
			Esp.Remove(Root)
		end)()
	end)
end

function IsEligible(plr)
	if plr == Local.Player or (Local.Player.Team ~= nil and plr.Team == Local.Player.Team) or plr.Character == nil then 
		return false
	end
	if not (plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Parent == workspace) then
		return false
	end
    local Root = plr.Character.HumanoidRootPart
    local Pos, Vis = Local.Cam:WorldToViewportPoint(Root.Position)
    local Parts = Local.Cam:GetPartsObscuringTarget({Root.Position}, {Local.Cam, Local.Char, plr.Character, workspace.IgnoreThese})
	if not Vis or (Settings.WallCheck.Enabled and #Parts > 0) then
        return false
    end
    return Pos
end

function GetAimPart(parts)
    if SilentAimMode == "Body" then
        return parts[BodyParts[math.random(3, #BodyParts)]]
    elseif SilentAimMode == "Head" then
        return parts[BodyParts[math.random(1, 2)]]
    elseif SilentAimMode == "Random" then
        return parts[BodyParts[math.random(1, #BodyParts)]]
    end
end

function GetClosest()
    if not (Settings.SilentAim.Enabled and Local.Root) then return nil end
	local Closest, Dist = nil, Settings.UseFOV.Enabled and Settings.FOV.Value or math.huge
	for i, v in next, Services.Players:GetPlayers() do
		local Eligible = IsEligible(v)
		if Eligible then
			local Mag = (Vector2.new(Eligible.X, Eligible.Y) - MidScr).Magnitude
			if Mag < Dist then
				Dist = Mag
				Closest = GetAimPart(v.Character)
			end
		end
	end
	return Closest
end

-- GUI

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/Library.lua", true))()
Lib.Init("Strucid")

local SilentAim = Lib.AddTab("Silent Aim")

SilentAim.AddLabel("Silent Aim Settings")

Settings.SilentAim = SilentAim.AddToggle("Enabled")

Settings.SilentAimMode = SilentAim.AddDropdown("Targeting Method", { "Head [Bannable]", "Body", "Random" })

Settings.WallCheck = SilentAim.AddToggle("Wall Check")

SilentAim.AddLabel("FOV Settings")

Settings.FOV = SilentAim.AddSlider("FOV", 0, 600, function(val)
	FOVCircle.Radius = val
end)

Settings.UseFOV = SilentAim.AddToggle("Use FOV")

Settings.ShowFOV = SilentAim.AddToggle("Show FOV", function(toggle)
	FOVCircle.Visible = toggle
end)

local ESP = Lib.AddTab("ESP")

ESP.AddLabel("ESP Options")

Settings.ESPEnabled = ESP.AddToggle("Enabled", function(toggle)
    Esp.Settings.Enabled = toggle
end)

Settings.ShowNames = ESP.AddToggle("Show Names", function(toggle)
    Esp.Settings.Name = toggle
end)

Settings.ShowBoxes = ESP.AddToggle("Show Boxes", function(toggle)
    Esp.Settings.Box = toggle
end)

Settings.ShowHealth = ESP.AddToggle("Show Health", function(toggle)
    Esp.Settings.Health = toggle
end)

Settings.ShowDistances = ESP.AddToggle("Show Distances", function(toggle)
    Esp.Settings.Distance = toggle
end)

Settings.ShowTracers = ESP.AddToggle("Show Tracers", function(toggle)
    Esp.Settings.Tracer = toggle
end)

ESP.AddLabel("Tracer Settings")

Settings.TracerStart = ESP.AddDropdown("Tracer Origin", {"Top", "Middle", "Bottom"}, function(val)
    local Start = TracerOrigins[val]
    local Offset = val == "Top" and Settings.TracerOffset.Value or val == "Bottom" and -Settings.TracerOffset.Value or 0
    Esp.UpdateTracerStart(Start + Vector2.new(0, Offset))
end)

Settings.TracerOffset = ESP.AddSlider("Tracer Offset", 0, 100, function(val)
    local Start = TracerOrigins[Settings.TracerStart.Selected]
    local Offset = Settings.TracerStart.Selected == "Top" and val or Settings.TracerStart.Selected == "Bottom" and -val or 0
    Esp.UpdateTracerStart(Start + Vector2.new(0, Offset))
end)

ESP.AddLabel("ESP Settings")

Settings.OnlyShowEnemies = ESP.AddToggle("Only Show Enemies", function(toggle)
    Esp.Settings.TeamCheck = toggle
end)

Settings.ESPRainbow = ESP.AddToggle("Rainbow", Esp.ToggleRainbow)

Settings.ESPTextSize = ESP.AddSlider("Text Size", 10, 32, Esp.UpdateTextSize)

Settings.ESPRange = ESP.AddSlider("Range", 0, 4096, function(val)
    Esp.Settings.Range = val
end)

ESP.AddLabel("Custom Settings")

Settings.ShowItems = ESP.AddToggle("Show Dropped Items", function(toggle)
	if toggle then
		for i, v in next, workspace.GroundWeapons:GetChildren() do
			local Center = v:WaitForChild("Center")
			coroutine.wrap(function()
				repeat wait() until Center:FindFirstChildOfClass("ParticleEmitter")
				Esp.AddItem(v.Name, Center, Rarities[Center:FindFirstChildOfClass("ParticleEmitter").Name])
			end)()
		end
	else
		for i, v in next, Esp.ItemContainer do
			if i.Name == "Center" then
				Esp.RemoveItem(i)
			end
		end
	end
end)

local GunMods = Lib.AddTab("Gun Mods")

GunMods.AddLabel("Gun Mods")

Settings.Wallbang = GunMods.AddToggle("Wallbang")

Settings.RapidFire = GunMods.AddToggle("Rapid Fire")

Settings.InfRange = GunMods.AddToggle("Infinite Range")

Settings.NoRecoil = GunMods.AddToggle("No Recoil")

Settings.NoSpread = GunMods.AddToggle("No Spread")

local PlayerMods = Lib.AddTab("Player Mods")

PlayerMods.AddLabel("Character Mods")

Settings.InstantActions = PlayerMods.AddToggle("Instant Actions")

Settings.NoFallDamage = PlayerMods.AddToggle("No Fall Damage")

PlayerMods.AddButton("God Mode", function()
	Godmode = true
	if Local.Char and Local.Char:FindFirstChild("Shield") then
		Local.Char.Shield:Destroy()
	end
end)

local Misc = Lib.AddTab("Miscellaneous")

Misc.AddLabel("Misc")

Settings.WindowsKeybind = Misc.AddKeybind("Break Windows", function()
    for i, v in next, workspace:GetDescendants() do
        if v.Name == "Glass" then
            Network:FireServer("CrackGlass", v)
        end
    end
end)

Settings.KillSay = Misc.AddToggle("Kill Say")

Settings.KillMsg = Misc.AddBox("Kill Say Message", false)

local GuiSettings = Lib.AddTab("Settings")

GuiSettings.AddLabel("GUI Settings")

GuiSettings.AddDropdown("Credits", { "Kieran - Owner, Main Scripter" })

Settings.ToggleKey = GuiSettings.AddKeybind("Toggle GUI", function()
    Lib.Gui.Enabled = not Lib.Gui.Enabled
end)

GuiSettings.AddButton("Exit GUI", function()
    for i, v in next, Settings do
        if v.Enabled == false or v.Enabled then
            v.Enabled = false
        end
    end
    Lib.Gui:Destroy()
end)

GuiSettings.AddLabel("Configs")

Configs = GuiSettings.AddDropdown("Configs", Lib.GetConfigNames(), function(val)
    SelectedConfig = val
end)

GuiSettings.AddButton("Load Config", function()
    if SelectedConfig then
        for i, v in next, Lib.Configs[SelectedConfig] do
            if Settings[i] then
                if Settings[i].Type == "Keybind" then
                    if pcall(function() return Enum.KeyCode[v] end) then
                        Settings[i].Set(Enum.KeyCode[v])
                    end
                else
                    Settings[i].Set(v)
                end
            end
        end
    end
end)

GuiSettings.AddButton("Overwrite Config", function()
    if SelectedConfig then
        Lib.SaveConfig(SelectedConfig, Settings)
    end
end)

GuiSettings.AddButton("Delete Config", function()
    if SelectedConfig then
        Lib.RemoveConfig(SelectedConfig)
    end
    Configs.SetItems(Lib.GetConfigNames())
end)

GuiSettings.AddBox("New Config", false, function(val)
    ConfigName = val
end)

GuiSettings.AddButton("Save New Config", function()
    Lib.SaveConfig(ConfigName or "Config_" .. (#Lib.Configs + 1), Settings)
    Configs.SetItems(Lib.GetConfigNames())
end)

-- Setup

Settings.SilentAimMode.Set("Random")
Settings.ESPTextSize.Set(16)
Settings.ESPRange.Set(4096)
Settings.TracerStart.Set("Bottom")
Settings.TracerOffset.Set(25)
Settings.KillMsg.Set("{user} isn't using Project Evo")

Services.ReplicatedStorage.AdminRE:ClearAllChildren()

for a, b in next, Modules do
	GunStatTable[b.Name] = {}
	for c, d in next, require(b) do
		GunStatTable[b.Name][c] = d
	end
end

if Local.Player.Character and Local.Player.Character.Parent ~= nil then
    RegisterChar(Local.Player.Character)
end

Local.Player.CharacterAdded:Connect(RegisterChar)

FOVCircle.Filled = false
FOVCircle.Position = MidScr
FOVCircle.Radius = 0
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)

for i, v in next, Services.Players:GetPlayers() do
    if v ~= Local.Player then
		RegisterEsp(v)
	end
end

Services.Players.PlayerAdded:Connect(RegisterEsp)

Services.RunService.Stepped:Connect(function()
	Target = GetClosest()
end)

local FindPart
FindPart = hookfunction(workspace.FindPartOnRayWithIgnoreList, function(self, ...)
	local Trace = traceback()
	if string.find(Trace, "Shoot") or string.find(Trace, "Effect") then
		local Args = {...}
		if Settings.Wallbang.Enabled or (Settings.SilentAim.Enabled and Target) then
			table.insert(Args[2], workspace.Map)
			table.insert(Args[2], workspace.BuildStuff)
		end
		if Settings.InfRange.Enabled or (Settings.SilentAim.Enabled and Target) then
			Args[1] = Ray.new(Args[1].Origin, Args[1].Direction.Unit * 2048)
		end
		return FindPart(self, unpack(Args))
	end
	return FindPart(self, ...)
end)

local FireServer = Network.FireServer
Network.FireServer = newcclosure(function(self, ...)
    local Args = {...}
	if Args[1] == "Build" and Args[3] == 5 and Args[4] == 5 then
		return
	elseif Args[1] == "FallDamage" and Settings.NoFallDamage.Enabled then
        return
    end
    FireServer(self, ...)
end)

local ConeOfFire = GlobalStuff.ConeOfFire
GlobalStuff.ConeOfFire = newcclosure(function(...)
	if Settings.SilentAim.Enabled and Target then
		return Target.Position
	end
	if Settings.NoSpread.Enabled then
		return ({...})[3]
	end
	return ConeOfFire(...)
end)

Local.Menu.ChildAdded:Connect(function(child)
	if Settings.KillSay.Enabled and child.Name == "KillFeedFrame" then
		repeat Services.RunService.Heartbeat:Wait() until child.FirstName.Text ~= "PhoenixSigns"
		if child.FirstName.Text == Local.Player.Name then
			SendChat:FireServer(Settings.KillMsg.Value:gsub("{user}", child.SecondName.Text), "All")
		end
	end
end)

Local.Mouse.Move:Connect(function()
	FOVCircle.Position = Services.UserInputService:GetMouseLocation()
end)

workspace.GroundWeapons.ChildAdded:Connect(function(child)
	if Settings.ShowItems.Enabled then
		local Center = child:WaitForChild("Center")
		repeat wait() until Center:FindFirstChildOfClass("ParticleEmitter")
		Esp.AddItem(child.Name, Center, Rarities[Center:FindFirstChildOfClass("ParticleEmitter").Name])
	end
end)

local queueonteleport = queue_on_teleport or queue_for_teleport or (syn and syn.queue_on_teleport)

if queueonteleport then
	queueonteleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/Loader.lua"))()]])
end

Lib.Notify("If you use this obviously, you may be banned. We take no responsibility for that")