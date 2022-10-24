-- Variables

local Settings, Functions = {}, {}
local Configs, SelectedConfig, ConfigName

local Services = setmetatable({}, {
    __index = function(t, k)
        return game:GetService(k)
    end
})

local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    ControlScript = Services.Players.LocalPlayer.PlayerScripts.ControlScript,
    Cam = workspace.CurrentCamera
}

local Flying, Target = false, nil
local Vectors = { Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1) }
local CharParts, GunStats = { "Head", "Abdomen", "Chest", "Hips", "LeftArm", "LeftForearm", "LeftForeleg", "LeftLeg", "RightArm", "RightForearm", "RightForeleg", "RightLeg" }, {}
local FOVCircle = newdrawing("Circle")
local MidScr = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y / 2)
local TracerOrigins = { Top = Vector2.new(Local.Cam.ViewportSize.X / 2, 0), Middle = MidScr, Bottom = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y) }
local Shell = require(Services.ReplicatedStorage.TS)
local Esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/EspModule.lua", true))()

-- Functions

function GetMovementVector()
    local Vector = Vector3.new()
    if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
        Vector = Vector + Local.Cam.CFrame.LookVector
    end
    if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
        Vector = Vector - Local.Cam.CFrame.RightVector
    end
    if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
        Vector = Vector - Local.Cam.CFrame.LookVector
    end
    if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
        Vector = Vector + Local.Cam.CFrame.RightVector
    end
    return Vector
end

function RegisterChar(char)
    Local.Char = char
    Local.Root = char:WaitForChild("Root")
    char.Root:GetPropertyChangedSignal("Velocity"):Connect(function()
        local Vel, Speed, Jump = char.Root.Velocity, Settings.WalkSpeed.Value, Settings.JumpPower.Value
        local Dir = GetMovementVector()
        local X, Z = Speed > 22 and Dir.X * Speed or Vel.X, Speed > 22 and Dir.Z * Speed or Vel.Z
        char.Root.Velocity = Vector3.new(X, Vel.Y == 36 and Jump or Vel.Y, Z)
    end)
end

function DeepCopy(old, new)
    for i, v in next, old do
        new[i] = type(v) == "table" and {} or v
        if type(v) == "table" then
            DeepCopy(v, new[i])
        end
    end
end

function IsEligible(plr)
	if plr == Local.Player or Shell.Teams:ArePlayersFriendly(Local.Player, plr) then 
		return false
    end
    local Char = Shell.Characters:GetCharacter(plr)
    if Char == nil or not Char:FindFirstChild("Root") then
        return false
    end
    local Pos, Vis = Local.Cam:WorldToViewportPoint(Char.Root.Position)
	local VisRay = Ray.new(Local.Root.Position, Char.Root.Position - Local.Root.Position)
	local Part = workspace:FindPartOnRayWithWhitelist(VisRay, {workspace.Terrain, workspace.Geometry}, true)
    if Part ~= nil or (Settings.VisibleCheck.Enabled and not Vis) then
        return false
    end
	return Pos
end

function GetAimPart(char)
    if Settings.SilentAimMode.Selected == "Head" then
        return char.Body.Head
    elseif Settings.SilentAimMode.Selected == "Body" then
        return char.Body[CharParts[math.random(2, #CharParts)]]
    elseif Settings.SilentAimMode.Selected == "Random" then
        return char.Body[CharParts[math.random(1, #CharParts)]]
    end
end

function GetClosest()
    if not (Settings.SilentAim.Enabled and Local.Root) then return nil end
	local Closest, Dist = nil, Settings.UseFOV.Enabled and Settings.FOV.Value or math.huge
	for i, v in next, Services.Players:GetPlayers() do
		local Eligible = IsEligible(v)
		if Eligible then
			local Mag = (Vector2.new(Eligible.X, Eligible.Y) - Services.UserInputService:GetMouseLocation()).Magnitude
			if Mag < Dist then
				Dist = Mag
				Closest = GetAimPart(Shell.Characters:GetCharacter(v)).Position
			end
		end
	end
	return Closest
end

function GetNearest()
    local Nearest, Dist = nil, math.huge
    for i, v in next, Services.Players:GetPlayers() do
        if not Shell.Teams:ArePlayersFriendly(Local.Player, v) then
            local Char = Shell.Characters:GetCharacter(v)
            if Char and Char:FindFirstChild("Root") then
                local Mag = (Char.Root.Position - Local.Cam.CFrame.Position).Magnitude
                if Mag < Dist then
                    Nearest, Dist = Char.Root, Mag
                end
            end
        end
    end
    return Nearest
end

-- GUI

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/Library.lua", true))()
Lib.Init("Bad Business")

local SilentAim = Lib.AddTab("Silent Aim")

SilentAim.AddLabel("Silent Aim Settings")

Settings.SilentAim = SilentAim.AddToggle("Enabled")

Settings.SilentAimMode = SilentAim.AddDropdown("Targeting Method", { "Body", "Head", "Random" })

Settings.VisibleCheck = SilentAim.AddToggle("Visibility Check")

Settings.Triggerbot = SilentAim.AddToggle("Triggerbot")

SilentAim.AddLabel("FOV Settings")

Settings.FOV = SilentAim.AddSlider("FOV", 0, 800, function(val)
	FOVCircle.Radius = val
end)

Settings.UseFOV = SilentAim.AddToggle("Use FOV")

Settings.ShowFOV = SilentAim.AddToggle("Show FOV", function(toggle)
	FOVCircle.Visible = toggle
end)

local WeaponMods = Lib.AddTab("Weapon Mods")

WeaponMods.AddLabel("Gun Mods")

Settings.RapidFire = WeaponMods.AddToggle("Rapid Fire")

Settings.NoRecoil = WeaponMods.AddToggle("No Recoil", function(toggle)
    for i, v in next, Services.ReplicatedStorage.Items:GetChildren() do
        if v:FindFirstChild("Config") then
            local Config = require(v.Config)
            if Config.Recoil and Config.Recoil.Default then
                Config.Recoil.Default.CameraSpeed = toggle and 0 or GunStats[v.Name].Recoil.Default.CameraSpeed
                Config.Recoil.Default.RecoilSpeed = toggle and 0 or GunStats[v.Name].Recoil.Default.RecoilSpeed
                Config.Recoil.Default.WeaponMovementSpeed = toggle and 0 or GunStats[v.Name].Recoil.Default.WeaponMovementSpeed
                Config.Recoil.Default.WeaponRotationSpeed = toggle and 0 or GunStats[v.Name].Recoil.Default.WeaponRotationSpeed
            end
        end
    end
end)

Settings.NoSpread = WeaponMods.AddToggle("No Spread")

Settings.InstantAim = WeaponMods.AddToggle("Instant Aim", function(toggle)
    for i, v in next, Services.ReplicatedStorage.Items:GetChildren() do
        if v:FindFirstChild("Config") then
            local Config = require(v.Config)
            if Config.Aim then
                Config.Aim.AimTime = toggle and 0 or GunStats[v.Name].Aim.AimTime
            end
        end
    end
end)

WeaponMods.AddLabel("Grenade Mods")

Settings.NadeTP = WeaponMods.AddToggle("Grenade TP")

local PlayerMods = Lib.AddTab("Player Mods")

Settings.WalkSpeed = PlayerMods.AddSlider("WalkSpeed", 22, 140)

Settings.JumpPower = PlayerMods.AddSlider("JumpPower", 36, 140)

Settings.FlySpeed = PlayerMods.AddSlider("Fly Speed", 16, 140)

Settings.Fly = PlayerMods.AddKeybind("Fly", function()
    Flying = not Flying
    if Flying then
        repeat Services.RunService.Stepped:Wait()
            if Local.Root then
                local Vector = Vector3.new()
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Vector = Vector + Local.Cam.CFrame.LookVector
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    Vector = Vector - Local.Cam.CFrame.RightVector
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Vector = Vector - Local.Cam.CFrame.LookVector
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Vector = Vector + Local.Cam.CFrame.RightVector
                end
                if Vector.Unit.X == Vector.Unit.X then
                    Local.Root.Velocity = Vector.Unit * Settings.FlySpeed.Value
                end
                Local.Root.Anchored = Vector == Vector3.new()
            end
        until not Flying
        if Local.Root then
            Local.Root.Anchored = false
        end
    end
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

Settings.ESPRange = ESP.AddSlider("Range", 0, 2048, function(val)
    Esp.Settings.Range = val
end)

ESP.AddLabel("Custom Settings")

Settings.ShowNades = ESP.AddToggle("Show Grenades", function(toggle)
    for i, v in next, workspace.Throwables:GetChildren() do
        local Body = v:WaitForChild("Body"):WaitForChild("BodyPrimary")
        Esp.AddItem(v.Name, Body, Body.Color)
    end
end)

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

Settings.SilentAimMode.Set("Body")
Settings.ESPTextSize.Set(16)
Settings.ESPRange.Set(2048)
Settings.TracerStart.Set("Bottom")
Settings.TracerOffset.Set(25)

FOVCircle.Filled = false
FOVCircle.Position = MidScr
FOVCircle.Radius = 0
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)

Esp.TeamCheck = function(plr)
    return Shell.Teams:ArePlayersFriendly(Local.Player, plr)
end

Esp.GetHealth = function(plr)
    local Char = Shell.Characters:GetCharacter(plr)
    if not Char then return 0 end
    return Char:WaitForChild("Health").Value / Char.Health:WaitForChild("MaxHealth").Value
end

for i, v in next, Services.ReplicatedStorage.Items:GetChildren() do
    if v:FindFirstChild("Config") then
        GunStats[v.Name] = {}
        DeepCopy(require(v.Config), GunStats[v.Name])
    end
end

Functions.Fire = Shell.Network.Fire
Shell.Network.Fire = newcclosure(function(self, ...)
    local Args = {...}
    if Args[2] == "OnError" then
        return
    elseif Args[2] == "Shoot" and Settings.SilentAim.Enabled and Target then
        local Dir = (Target - Local.Cam.CFrame.Position).Unit + Vector3.new(0, GunStats[Args[3].Name].Projectile.GravityCorrection / 1000, 0)
        for i, v in next, Args[5] do
            v[1] = Dir
        end
    end
    Functions.Fire(self, unpack(Args))
end)

Functions.Wait = Shell.Timer.Wait
Shell.Timer.Wait = newcclosure(function(self, ...)
    if Settings.RapidFire.Enabled and tostring(getfenv(2).script) == "Paintball" then
        Services.RunService.Stepped:Wait()
        return
    end
    Functions.Wait(self, ...)
end)

Functions.LookVector = Shell.Input.Reticle.LookVector
Shell.Input.Reticle.LookVector = newcclosure(function(...)
    if Settings.NoSpread.Enabled then
        return Local.Cam.CFrame.LookVector
    end
    return Functions.LookVector(...)
end)

Services.RunService.Stepped:Connect(function()
    if Settings.SilentAim.Enabled then
        Target = GetClosest()
        if Settings.Triggerbot.Enabled and Target then
            Shell.Input:AutomateBegan("Shoot")
            wait()
            Shell.Input:AutomateEnded("Shoot")
        end
    end
end)

for i, v in next, workspace.Characters:GetChildren() do
    local Plr = nil
    repeat wait()
        Plr = Shell.Characters:GetPlayerFromCharacter(v)
    until Plr ~= nil
    if Plr == Local.Player then
        RegisterChar(v)
    else
        Esp.Add(Plr, v:WaitForChild("Root"), Services.Teams[Shell.Teams:GetPlayerTeam(Plr)].Color.Value)
    end
end

workspace.Characters.ChildAdded:Connect(function(child)
    local Plr = nil
    repeat wait()
        Plr = Shell.Characters:GetPlayerFromCharacter(child)
    until Plr ~= nil
    if Plr == Local.Player then
        RegisterChar(child)
    else
        Esp.Add(Plr, child:WaitForChild("Root"), Services.Teams[Shell.Teams:GetPlayerTeam(Plr)].Color.Value)
    end
end)

workspace.Characters.ChildRemoved:Connect(function(child)
    if child == Local.Char then
        Local.Char, Local.Root = nil, nil
    else
        for i, v in next, Esp.Container do
            if v.Root == nil or not v.Root:IsDescendantOf(workspace.Characters) then
                Esp.Remove(i)
            end
        end
    end
end)

workspace.Throwables.ChildAdded:Connect(function(child)
    local Body = child:WaitForChild("Body"):WaitForChild("BodyPrimary")
    if Settings.ShowNades.Enabled then
        Esp.AddItem(child.Name, Body, Body.Color)
    end
    if Settings.NadeTP.Enabled then
        repeat wait()
            local Nearest = GetNearest()
            if Nearest then
                Body.CFrame = Nearest.CFrame
            end
        until child == nil or not child:IsDescendantOf(workspace)
    end
end)

workspace.Throwables.ChildRemoved:Connect(function(child)
    Esp.RemoveItem(child.Body.BodyPrimary)
end)
