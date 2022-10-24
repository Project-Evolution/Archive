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
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Cam = workspace.CurrentCamera
}

local Blocks = { "BeanBoozled", "Kick", "Ban", "Ban2" }
local HitPart = Services.ReplicatedStorage.Events.HitPart
local MidScr = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y / 2)
local FOVCircle = newdrawing("Circle")
local SilentAimMode = "Torso"
local Target = nil
local IsKillAll = false

local Meta = getrawmetatable(game)
local Namecall = Meta.__namecall

local ClientEnv = {}

local Esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V1/EspModule.lua", true))()

-- Functions

function RegisterChar(char)
    Local.Char = char
    Local.Root = char:WaitForChild("HumanoidRootPart")
    Local.Hum = char:WaitForChild("Humanoid")
    Local.Hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        Local.Hum.WalkSpeed = Settings.WalkSpeed.Value
    end)
    Local.Hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        Local.Hum.JumpPower = Settings.JumpPower.Value
    end)
    Local.Hum.Died:Connect(function()
        Local.Char, Local.Root, Local.Hum = nil, nil, nil
    end)
end

function IsEligible(plr)
	if plr == Local.Player or (Local.Player.Team ~= nil and plr.Team == Local.Player.Team) or plr.Character == nil or plr.Character.Parent == nil then 
		return false
	end
	local Root = plr.Character.HumanoidRootPart
	local Pos, Vis = Local.Cam:WorldToViewportPoint(Root.Position)
    local Parts = Local.Cam:GetPartsObscuringTarget({Root.Position}, {Local.Cam, Local.Char, plr.Character, workspace.Ray_Ignore, workspace.Map.Ignore})
    if Settings.VisibleCheck.Enabled and not Vis then
        return false
    elseif Settings.WallCheck.Enabled and #Parts > 0 then
        return false
    end
	return Pos
end

function GetAimPart(parts)
    if SilentAimMode == "Torso" then
        return parts.HumanoidRootPart
    elseif SilentAimMode == "Head" then
        return parts.Head
    elseif SilentAimMode == "Random" then
        return math.random(1, 100) > 50 and parts.Head or parts.HumanoidRootPart
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
				Closest = GetAimPart(v.Character)
			end
		end
	end
	return Closest
end

function RegisterEsp(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        Esp.Add(plr, plr.Character.HumanoidRootPart, plr.TeamColor.Color)
    end
    plr.CharacterAdded:Connect(function(char)
        Esp.Add(plr, char:WaitForChild("HumanoidRootPart"), plr.TeamColor.Color)
    end)
end

function Damage(target)
    if ClientEnv.gun then
        local Name = ClientEnv.gun.Name
        if Name then
            local Weapon = Services.ReplicatedStorage.Weapons[Name]
            HitPart:FireServer(target,
                target.Position,
                Name,
                0,
                0,
                false,
                false,
                false,
                0,
                false,
                Weapon.FireRate.Value,
                Weapon.ReloadTime.Value,
                Weapon.Ammo.Value,
                Weapon.StoredAmmo.Value,
                Weapon.Bullets.Value,
                Weapon.EquipTime.Value,
                Weapon.RecoilControl.Value,
                Weapon.Auto.Value,
                Weapon["Speed%"].Value,
                Services.ReplicatedStorage.wkspc.DistributedTime.Value
            )
        end
    end
end

-- GUI

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V1/Library.lua", true))()
Lib.Init("Arsenal")

local MainTab = Lib.AddTab("Main")

MainTab.AddLabel("Kill All")

Settings.KillAll = MainTab.AddKeybind("Kill All", function()
    IsKillAll = true
    for i, v in next, Services.Players:GetPlayers() do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            coroutine.wrap(Damage)(v.Character.HumanoidRootPart)
        end
    end
    IsKillAll = false
end)

Settings.LoopKillAll = MainTab.AddToggle("Loop Kill All", function(toggle)
    if toggle then
        repeat wait(3)
            IsKillAll = true
            for i, v in next, Services.Players:GetPlayers() do
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    coroutine.wrap(Damage)(v.Character.HumanoidRootPart)
                    if not Settings.LoopKillAll then
                        break
                    end
                end
            end
            IsKillAll = false
        until Settings.LoopKillAll.Enabled == false
    end
end)

Settings.ShootKillAll = MainTab.AddToggle("Shoot Kill All")

MainTab.AddLabel("Other")

Settings.KnifeAura = MainTab.AddToggle("Knife Aura", function(toggle)
    if toggle then
        repeat wait()
            if Local.Root and ClientEnv.gun and ClientEnv.gun.Name == "Knife" then
                for i, v in next, Services.Players:GetPlayers() do
                    if (Local.Player.Team == nil or v.Team ~= Local.Player.Team) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        if (v.Character.HumanoidRootPart.Position - Local.Root.Position).Magnitude < 50 then
                            coroutine.wrap(Damage)(v.Character.HumanoidRootPart)
                        end
                    end
                end
            end
        until Settings.KnifeAura.Enabled == false
    end
end)

local SilentAim = Lib.AddTab("Silent Aim")

SilentAim.AddLabel("Silent Aim Settings")

Settings.SilentAim = SilentAim.AddToggle("Enabled")

Settings.SilentAimMode = SilentAim.AddDropdown("Target Part", { "Head", "Torso", "Random" })

Settings.VisibleCheck = SilentAim.AddToggle("Visibility Check")

Settings.WallCheck = SilentAim.AddToggle("Wall Check")

SilentAim.AddLabel("FOV Settings")

Settings.FOV = SilentAim.AddSlider("FOV", 0, 600, function(val)
	FOVCircle.Radius = val
end)

Settings.UseFOV = SilentAim.AddToggle("Use FOV")

Settings.ShowFOV = SilentAim.AddToggle("Show FOV", function(toggle)
	FOVCircle.Visible = toggle
end)

local PlayerMods = Lib.AddTab("Player Mods")

PlayerMods.AddLabel("Character Mods")

Settings.WalkSpeed = PlayerMods.AddSlider("WalkSpeed", 16, 500, function(val)
    if Local.Hum then
        Local.Hum.WalkSpeed = val
    end
end)

Settings.JumpPower = PlayerMods.AddSlider("JumpPower", 20, 500, function(val)
    if Local.Hum then
        Local.Hum.JumpPower = val
    end
end)

Settings.InfJump = PlayerMods.AddToggle("Infinite Jump")

local GunMods = Lib.AddTab("Gun Mods")

GunMods.AddLabel("Gun Mods")

Settings.Wallbang = GunMods.AddToggle("Wallbang")

Settings.OneShotKill = GunMods.AddToggle("One Shot Kill")

Settings.InfAmmo = GunMods.AddToggle("Infinite Ammo")

Settings.NoRecoil = GunMods.AddToggle("No Recoil")

Settings.NoSpread = GunMods.AddToggle("No Spread", function(toggle)
    local val = nil
    if ClientEnv.gun and ClientEnv.gun.Name then
        val = Services.ReplicatedStorage.Weapons[ClientEnv.gun.Name].Spread.Value
    end
    ClientEnv.currentspread = toggle and 0 or val
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

local MiscTab = Lib.AddTab("Miscellaneous")

Settings.AdminKick = MiscTab.AddToggle("Kick If Admin Joins", function(toggle)
    if toggle then
        for i, v in next, Services.Players:GetPlayers() do
            if v:GetRankInGroup(2613928) >= 2 then
                Local.Player:Kick("An Admin Is Already In Your Game Lmao")
            end
        end
    end
end)

local GuiSettings = Lib.AddTab("Settings")

GuiSettings.AddLabel("GUI Settings")

GuiSettings.AddDropdown("Credits", { "Kieran - Owner, Main Scripter", "john smith - Kick If Admin Joins" })

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

Settings.WalkSpeed.Set(16)
Settings.JumpPower.Set(20)
Settings.SilentAimMode.Set("Torso")
Settings.ESPTextSize.Set(16)
Settings.ESPRange.Set(2048)

if Local.Player.Character and Local.Player.Character.Parent ~= nil then
    RegisterChar(Local.Player.Character)
end

Local.Player.CharacterAdded:Connect(RegisterChar)

FOVCircle.Filled = false
FOVCircle.Position = MidScr
FOVCircle.Radius = 0
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)

makewriteable(Meta)

Meta.__namecall = newcclosure(loadstring([[
    local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q = ...
    return function(r, ...)
        local s, t = a(), {...}
        if s == b then
            if table.find(c, r.Name) then
                return
            elseif r == d then
                if e.Enabled or f or g.Enabled then
                    for _ = h, i do
                        q(r, unpack(t))
                    end
                    return
                end
            end
        elseif s == j and not k() and l.Enabled then
            m(t[n], o[p])
        end
        return q(r, unpack(t))
    end
]])(getnamecallmethod, "FireServer", Blocks, HitPart, Settings.OneShotKill, IsKillAll, Settings.KnifeAura, 1, 100, "FindPartOnRayWithIgnoreList", checkcaller, Settings.Wallbang, table.insert, 2, workspace, "Map", Namecall))

makereadonly(Meta)

for i, v in next, getgc() do
    if type(v) == "function" and islclosure(v) and tostring(getfenv(v).script) == "Client" then
        if getinfo(v).name == "firebullet" then
            ClientEnv = getfenv(v)
        end
    end
end

local Getammo = ClientEnv.getammo
ClientEnv.getammo = function(...)
    if Settings.InfAmmo.Enabled then
        return 999
    end
    return Getammo(...)
end

local Shakecam = ClientEnv.ShakeCam
ClientEnv.ShakeCam = function(...)
    if Settings.NoRecoil.Enabled then
        return
    end
    return Shakecam(...)
end

local Firebullet = ClientEnv.firebullet
ClientEnv.firebullet = function(...)
    Firebullet(...)
    if Settings.SilentAim.Enabled and Target then
        coroutine.wrap(Damage)(Target)
    end
    if Settings.ShootKillAll.Enabled then
        IsKillAll = true
        for i, v in next, Services.Players:GetPlayers() do
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                coroutine.wrap(Damage)(v.Character.HumanoidRootPart)
            end
        end
        IsKillAll = false
    end
end

for i, v in next, Services.Players:GetPlayers() do
    if v ~= Player then
        RegisterEsp(v)
    end
end

Services.Players.PlayerAdded:Connect(function(plr)
    if Settings.AdminKick.Enabled and plr:GetRankInGroup(2613928) >= 2 then
        Local.Player:Kick("Admin Joined :(")
    end
    RegisterEsp(plr)
end)

Services.RunService.Stepped:Connect(function()
    Target = GetClosest()
end)

Local.Mouse.Move:Connect(function()
    FOVCircle.Position = Services.UserInputService:GetMouseLocation()
end)

Services.UserInputService.InputBegan:Connect(function(input, isrbx)
    if not isrbx then
        if input.KeyCode == Enum.KeyCode.Space and Settings.InfJump.Enabled then
            if Local.Root and Local.Hum and Local.Hum.FloorMaterial == Enum.Material.Air then
                local Vel = Local.Root.Velocity
                Local.Root.Velocity = Vector3.new(Vel.X, Local.Hum.JumpPower, Vel.Z)
            end
        end
    end
end)
