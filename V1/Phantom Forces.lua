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
    Killfeed = Services.Players.LocalPlayer.PlayerGui.MainGui.GameGui.Killfeed,
    Menu = Services.Players.LocalPlayer.PlayerGui.Menu,
	Chams = Instance.new("Folder", Services.Players.LocalPlayer.PlayerGui),
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Cam = workspace.CurrentCamera
}

local CharTable
local Char, Gamelogic, Menu, Hud
local GunTable, OldLighting, FullLighting, FireModes = {}, {
    Brightness = Services.Lighting.Brightness,
    GlobalShadows = Services.Lighting.GlobalShadows,
    Ambient = Services.Lighting.Ambient
}, {
   Brightness = 10,
   GlobalShadows = false,
   Ambient = Color3.new(1, 1, 1) 
}, { 1, 3, true }
local V3 = Vector3.new()
local Trajectory
local MidScr = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y / 2)
local TracerOrigins = { Top = Vector2.new(Local.Cam.ViewportSize.X / 2, 0), Middle = MidScr, Bottom = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y) }
local FOVCircle = newdrawing("Circle")
local Target = nil
local Horizontal, Vertical = newdrawing("Line"), newdrawing("Line")
local Flying = false
local BodyParts = { "head", "torso", "lleg", "rleg", "larm", "rarm" }

local Effects = require(Services.ReplicatedFirst.ClientModules.Old.framework.effects)
local Network = require(Services.ReplicatedFirst.ClientModules.Old.framework.network)
local Camera = require(Services.ReplicatedFirst.ClientModules.Old.framework.camera)
local Modules = Services.ReplicatedStorage.GunModules

local Meta = getrawmetatable(game)
local NewIndex = Meta.__newindex

local Esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/EspModule.lua", true))()

-- Functions

function RegisterChar(char)
    Local.Char = char
    Local.Root = char:WaitForChild("HumanoidRootPart")
    Local.Hum = char:WaitForChild("Humanoid")
    Local.Hum.Died:Connect(function()
        Local.Char, Local.Root, Local.Hum = nil, nil, nil
        if Services.Lighting:FindFirstChild("Map") then
            Services.Lighting.Map.Parent = workspace
        end
    end)
	for i, v in next, Local.Chams:GetChildren() do
		if v.Adornee:IsDescendantOf(char) then
			v:Destroy()
		end
	end
end

function RegisterEsp(char)
    for i, v in next, Services.Players:GetPlayers() do
        if CharTable[v] and CharTable[v].rootpart.Parent == char then
            Esp.Add(v, char.HumanoidRootPart, v.TeamColor.Color)
            break
        end
    end
end

function IsEligible(plr)
	if plr.Team == Local.Player.Team or CharTable[plr] == nil then 
		return false
    end
    local Root = CharTable[plr].torso
    local Pos, Vis = Local.Cam:WorldToViewportPoint(Root.Position)
    local Parts = Local.Cam:GetPartsObscuringTarget({Root.Position}, {Local.Cam, workspace.Players, workspace.Ignore})
    if Settings.VisibleCheck.Enabled and not Vis then
        return false
    elseif Settings.WallCheck.Enabled and #Parts > 0 then
        return false
    end
    local ForwardRay, BackRay = Ray.new(Local.Cam.CFrame.Position, Root.Position - Local.Cam.CFrame.Position), Ray.new(Root.Position, Local.Cam.CFrame.Position - Root.Position)
    local Depth = 0
    for i, v in next, Parts do
        if v.Name ~= "Window" then
            local _, pos1 = workspace:FindPartOnRayWithWhitelist(ForwardRay, {v})
            local __, pos2 = workspace:FindPartOnRayWithWhitelist(BackRay, {v})
            Depth = Depth + (pos2 - pos1).Magnitude
        end
    end
    if Depth >= Gamelogic.currentgun.data.penetrationdepth then
        return false
    end
    return Pos
end

function GetAimPart(parts)
    if Settings.SilentAimMode.Selected == "Body" then
        return parts[BodyParts[math.random(2, #BodyParts)]]
    elseif Settings.SilentAimMode.Selected == "Head" then
        return parts.head
    elseif Settings.SilentAimMode.Selected == "Random" then
        return parts[BodyParts[math.random(1, #BodyParts)]]
    end
end

function GetClosest()
    if not Settings.SilentAim.Enabled or not Gamelogic.currentgun then return nil end
	local Closest, Part, Dist = nil, nil, Settings.UseFOV.Enabled and Settings.FOV.Value or math.huge
	for i, v in next, Services.Players:GetPlayers() do
		local Eligible = IsEligible(v)
        if Eligible then
			local Mag = (Vector2.new(Eligible.X, Eligible.Y) - MidScr).Magnitude
			if Mag < Dist then
                Dist = Mag
				Closest, Part = v, GetAimPart(CharTable[v])
			end
		end
	end
	return Closest ~= nil and { Closest, Part } or nil
end

function GetNearest()
    local Nearest, Dist = nil, math.huge
    for i, v in next, Services.Players:GetPlayers() do
        if v.Team ~= Local.Player.Team then
            local Char = CharTable[v]
            if Char and Char.torso then
                local Mag = (Char.torso.Position - Local.Root.Position).Magnitude
                if Mag < Dist then
                    Nearest, Dist = Char.torso.Parent.HumanoidRootPart, Mag
                end
            end
        end
    end
    return Nearest
end

function GetPlayerFromChar(char)
    for i, v in next, CharTable do
        if v.rootpart and v.rootpart.Parent == char then
            return i
        end
    end
end

function MakeTracer(vec)
    if Gamelogic.currentgun and Gamelogic.currentgun.barrel then
        local pos = Gamelogic.currentgun.barrel.Position
		local ray = Ray.new(pos, vec)
		local part, partpos = workspace:FindPartOnRayWithIgnoreList(ray, {Local.Cam, Local.Char, workspace.Ignore})
		if part and partpos then
			vec = vec.Unit * (partpos - pos).Magnitude
		end
        local Tracer = Instance.new("Part", workspace.Ignore)
        Tracer.Size = Vector3.new(0.15, 0.15, 0.15)
        Tracer.CFrame = CFrame.new(pos, pos + vec.Unit)
        Tracer.CanCollide = false
        Tracer.Transparency = 0.6
        Tracer.Color = Color3.fromRGB(180, 0, 255)
        Tracer.Anchored = true
        Services.TweenService:Create(Tracer, TweenInfo.new(1 / Gamelogic.currentgun.data.bulletspeed), {Position = pos + (vec / 2), Size = Vector3.new(0.15, 0.15, vec.Magnitude)}):Play()
        Services.Debris:AddItem(Tracer, 1)
    end
end

function Chams(parts, name, colour)
	for i, v in next, parts do
		if i ~= "rootpart" then
			local cham = Instance.new("BoxHandleAdornment", Local.Chams)
			cham.Adornee = v
			cham.AlwaysOnTop = true
			cham.Color3 = colour
			cham.Name = name
			cham.Size = v.Size
			cham.Transparency = 0.6
			cham.ZIndex = 10
			coroutine.wrap(function()
				repeat wait() until not v:IsDescendantOf(workspace.Players)
				cham:Destroy()
			end)()
		end
	end
end

function Backtrack(parts, colour)
    for i, v in next, parts do
        if i ~= "rootpart" then
            local part = Instance.new("Part", workspace.Ignore)
            part.Anchored = true
            part.BottomSurface = Enum.SurfaceType.Smooth
            part.CanCollide = false
            part.CFrame = v.CFrame
            part.Color = colour
            part.Material = Enum.Material.Plastic
            part.Size = v.Size
            part.TopSurface = Enum.SurfaceType.Smooth
            part.Transparency = 0.6
            Services.Debris:AddItem(part, Settings.BacktrackDuration.Value / 1000)
        end
    end
end

function GetGun(name)
    for i, v in next, Modules:GetChildren() do
        if v.Name == name or require(v).displayname == name then
            return v.Name
        end
    end
end

function GetEnemyTeam()
	for i, v in next, Services.Teams:GetChildren() do
		if v ~= Local.Player.Team then
			return v
		end	
	end
end

-- GUI

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/Library.lua", true))()
Lib.Init("Phantom Forces")

local SilentAim = Lib.AddTab("Silent Aim")

SilentAim.AddLabel("Silent Aim Settings")

Settings.SilentAim = SilentAim.AddToggle("Enabled")

Settings.SilentAimMode = SilentAim.AddDropdown("Targeting Method", { "Body", "Head", "Random" })

Settings.PredictMovement = SilentAim.AddToggle("Movement Prediction")

Settings.DropCompensation = SilentAim.AddToggle("Drop Compensation")

Settings.VisibleCheck = SilentAim.AddToggle("Visibility Check")

Settings.WallCheck = SilentAim.AddToggle("Wall Check")

Settings.AutoFire = SilentAim.AddToggle("Auto Fire")

Settings.HitChance = SilentAim.AddSlider("Hit Chance %", 0, 100)

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

Settings.WalkSpeed = PlayerMods.AddSlider("Extra WalkSpeed", 0, 100, function(val)
    if Gamelogic.currentgun then
        Char:setbasewalkspeed(Gamelogic.currentgun.data.walkspeed + val)
    end
end)

Settings.JumpPower = PlayerMods.AddSlider("Extra JumpPower", 0, 100)

Settings.FlySpeed = PlayerMods.AddSlider("Fly Speed", 0, 100)

Settings.FlyKeybind = PlayerMods.AddKeybind("Fly", function(bind)
    Flying = not Flying
    if Flying then
        repeat Services.RunService.Stepped:Wait()
            if Local.Root then
                local Vec = Vector3.new()
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Vec = Vec + Local.Cam.CFrame.LookVector
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    Vec = Vec - Local.Cam.CFrame.RightVector
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Vec = Vec - Local.Cam.CFrame.LookVector
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Vec = Vec + Local.Cam.CFrame.RightVector
                end
                if Vec.Unit.X == Vec.Unit.X then
                    Local.Root.Velocity = Vec.Unit * Settings.FlySpeed.Value
                end
                Local.Root.Anchored = Vec == V3
            end
        until not Flying
        if Local.Root then
            Local.Root.Anchored = false
        end
    end
end)

Settings.InfJump = PlayerMods.AddToggle("Infinite Jump")

Settings.BHop = PlayerMods.AddToggle("Bunny Hop", function(toggle)
	if toggle then
		repeat wait()
			if Local.Root then
				Char:jump(4)
			end
		until Settings.BHop.Enabled == false
	end
end)

Settings.AntiFallDamage = PlayerMods.AddToggle("Anti Fall Damage")

Settings.AntiAim = PlayerMods.AddToggle("Anti Aim", function(toggle)
    if toggle and Settings.AntiAimMode.Selected == "Prone" and Menu:isdeployed() then
		Network:send("stance", "prone")
    end
end)

Settings.AntiAimMode = PlayerMods.AddDropdown("Anti Aim Mode", { "Prone", "Spinbot", "Moonwalk" })

PlayerMods.AddLabel("Other")

Settings.KnifeAura = PlayerMods.AddToggle("Knife Aura", function(toggle)
    if toggle then
        repeat wait(0.25)
            if Local.Root then
                for i, v in next, Services.Players:GetPlayers() do
                    if v.Team ~= Local.Player.Team then
                        local Parts = CharTable[v]
                        if Parts and (Parts.torso.Position - Local.Root.Position).Magnitude < 16 then
                            Network:send("knifehit", v, tick(), Parts.torso)
                        end
                    end
                end
            end
        until Settings.KnifeAura.Enabled == false
    end
end)

Settings.SpotPlayers = PlayerMods.AddToggle("Auto Spot Players", function(toggle)
    if toggle then
        repeat wait()
            local Players = {}
            for i, v in next, Services.Players:GetPlayers() do
                if v.Team ~= Local.Player.Team then
                    table.insert(Players, v)
                end
            end
            Network:send("spotplayers", Players)
        until Settings.SpotPlayers.Enabled == false
    end
end)

Settings.AutoDeploy = PlayerMods.AddToggle("Auto Deploy", function(toggle)
    if toggle then
        repeat wait(1)
            if not Menu:isdeployed() then
                Menu:deploy()
            end
        until Settings.AutoDeploy.Enabled == false
    end
end)

Settings.ThirdPerson = PlayerMods.AddToggle("Third Person")

Settings.ThirdPersonDist = PlayerMods.AddSlider("Third Person Distance", 0, 50)

local GunMods = Lib.AddTab("Gun Mods")

GunMods.AddLabel("Gun Mods")

Settings.CombineMags = GunMods.AddToggle("Combine Mags", function(toggle)
    for i, v in next, Modules:GetChildren() do
        local req = require(v)
        if rawget(req, "magsize") and rawget(req, "sparerounds") then
            req.magsize = toggle and req.magsize + req.sparerounds or GunTable[v.Name].magsize
            req.sparerounds = toggle and 0 or GunTable[v.Name].sparerounds
        end
    end
end)

Settings.AllFireModes = GunMods.AddToggle("All Fire Modes", function(toggle)
    for a, b in next, Modules:GetChildren() do
        if toggle then
            local Modes = {}
            if GunTable[b.Name].firemodes then
                table.insert(Modes, GunTable[b.Name].firemodes[1])
            end
            for c, d in next, FireModes do
                if not table.find(Modes, d) then
                    table.insert(Modes, d)
                end
            end
            require(b).firemodes = Modes
        else
            require(b).firemodes = GunTable[b.Name].firemodes
        end
    end
end)

Settings.NoRecoil = GunMods.AddToggle("No Recoil", function(toggle)
    for i, v in next, Modules:GetChildren() do
        local req = require(v)
        req.camkickmin = toggle and V3 or GunTable[v.Name].camkickmin
		req.camkickmax = toggle and V3 or GunTable[v.Name].camkickmax
		req.aimcamkickmin = toggle and V3 or GunTable[v.Name].aimcamkickmin
		req.aimcamkickmax = toggle and V3 or GunTable[v.Name].aimcamkickmax
		req.aimtranskickmin = toggle and V3 or GunTable[v.Name].aimtranskickmin
		req.aimtranskickmax = toggle and V3 or GunTable[v.Name].aimtranskickmax
		req.transkickmin = toggle and V3 or GunTable[v.Name].transkickmin
		req.transkickmax = toggle and V3 or GunTable[v.Name].transkickmax
		req.rotkickmin = toggle and V3 or GunTable[v.Name].rotkickmin
		req.rotkickmax = toggle and V3 or GunTable[v.Name].rotkickmax
		req.aimrotkickmin = toggle and V3 or GunTable[v.Name].aimrotkickmin
		req.aimrotkickmax = toggle and V3 or GunTable[v.Name].aimrotkickmax
    end
end)

Settings.NoSpread = GunMods.AddToggle("No Spread", function(toggle)
    for i, v in next, Modules:GetChildren() do
        local req = require(v)
		req.hipfirespreadrecover = toggle and 100 or GunTable[v.Name].hipfirespreadrecover
		req.hipfirespread = toggle and 0 or GunTable[v.Name].hipfirespread
		req.hipfirestability = toggle and 0 or GunTable[v.Name].hipfirestability
		req.crossexpansion = toggle and 0 or GunTable[v.Name].crossexpansion
    end
end)

Settings.NoGunSway = GunMods.AddToggle("No Gun Sway", function(toggle)
	for i, v in next, Modules:GetChildren() do
		local req = require(v)
		req.swayamp = toggle and 0 or GunTable[v.Name].swayamp
        req.swayspeed = toggle and 0 or GunTable[v.Name].swayspeed
        req.steadyspeed = toggle and 0 or GunTable[v.Name].steadyspeed
		req.breathspeed = toggle and 0 or GunTable[v.Name].breathspeed
	end
end)

Settings.NoGunBob = GunMods.AddToggle("No Gun Bob")

Settings.NoFireAnim = GunMods.AddToggle("Remove On Fire Animation", function(toggle)
    for a, b in next, Modules:GetChildren() do
        local req = require(b)
        for c, d in next, req.animations do
            if string.find(c, "onfire") then
                d.timescale = toggle and 0 or GunTable[b.Name].animations[c].timescale
                d.stdtimescale = toggle and 0 or GunTable[b.Name].animations[c].stdtimescale
            end
        end
    end
end)

Settings.FastReload = GunMods.AddToggle("Fast Reload", function(toggle)
    for i, v in next, Modules:GetChildren() do
        local req = require(v)
        if rawget(req.animations, "reload") and rawget(req.animations, "tacticalreload") then
            req.animations.reload.timescale = toggle and 0 or GunTable[v.Name].animations.reload.timescale
            req.animations.reload.stdtimescale = toggle and 0 or GunTable[v.Name].animations.reload.stdtimescale
            req.animations.tacticalreload.timescale = toggle and 0 or GunTable[v.Name].animations.tacticalreload.timescale
            req.animations.tacticalreload.stdtimescale = toggle and 0 or GunTable[v.Name].animations.tacticalreload.stdtimescale
        end
		if rawget(req.animations, "pullbolt") then
			req.animations.pullbolt.timescale = toggle and 0 or GunTable[v.Name].animations.pullbolt.timescale
            req.animations.pullbolt.stdtimescale = toggle and 0 or GunTable[v.Name].animations.pullbolt.stdtimescale
		end
    end
end)

Settings.InstantEquip = GunMods.AddToggle("Instant Equip", function(toggle)
    for i, v in next, Modules:GetChildren() do
        require(v).equipspeed = toggle and 9999 or GunTable[v.Name].equipspeed
    end
end)

Settings.InstantAim = GunMods.AddToggle("Instant Aim", function(toggle)
    for i, v in next, Modules:GetChildren() do
        require(v).aimspeed = toggle and 9999 or GunTable[v.Name].aimspeed
    end
end)

Settings.InstantKnife = GunMods.AddToggle("Instant Knife", function(toggle)
    for i, v in next, Modules:GetChildren() do
        local req = require(v)
        if req.animations then
            if req.animations.quickstab then
                req.animations.quickstab.timescale = toggle and 0 or GunTable[v.Name].animations.quickstab.timescale
                req.animations.quickstab.stdtimescale = toggle and 0 or GunTable[v.Name].animations.quickstab.stdtimescale
            end
            if req.animations.stab1 then
                req.animations.stab1.timescale = toggle and 0 or GunTable[v.Name].animations.stab1.timescale
                req.animations.stab1.stdtimescale = toggle and 0 or GunTable[v.Name].animations.stab1.stdtimescale
            end
            if req.animations.stab2 then
                req.animations.stab2.timescale = toggle and 0 or GunTable[v.Name].animations.stab2.timescale
                req.animations.stab2.stdtimescale = toggle and 0 or GunTable[v.Name].animations.stab2.stdtimescale
            end
        end
    end
end)

GunMods.AddLabel("Other")

Settings.HeadshotChance = GunMods.AddSlider("Headshot Chance", 0, 100)

Settings.NadeTP = GunMods.AddToggle("Grenade TP")

Settings.RainbowGun = GunMods.AddToggle("Rainbow Guns", function(toggle)
    if toggle then
        repeat Services.RunService.Heartbeat:Wait()
            if Gamelogic.currentgun then
                local Gun = Local.Cam:FindFirstChild(Gamelogic.currentgun.name)
                if Gun then
                    for i, v in next, Gun:GetDescendants() do
                        if v:IsA("BasePart") then
                            v.Color = Color3.fromHSV(tick() % 12 / 12, 1, 1)
                        end
                    end
                end
            end
        until Settings.RainbowGun.Enabled == false
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

local Tracking = Lib.AddTab("Tracking")

Tracking.AddLabel("Tracking Options")

Settings.Chams = Tracking.AddToggle("Chams", function(toggle)
	if toggle then
		local Colour = Settings.RainbowTracking.Enabled and Color3.fromHSV(tick() % 12 / 12, 1, 1) or nil
		for i, v in next, Services.Players:GetPlayers() do
			if v ~= Local.Player and (not Settings.TrackingTeamCheck.Enabled or v.Team ~= Local.Player.Team) then
				local Parts = CharTable[v]
				if Parts then
					Chams(Parts, v.Team == Local.Player.Team and "Friendly" or "Enemy", Colour or v.Team.TeamColor.Color)
				end
			end
		end
	else
		Local.Chams:ClearAllChildren()
	end
end)

Settings.Backtracking = Tracking.AddToggle("Backtracking", function(toggle)
    if toggle then
        repeat wait(0.12)
            local Colour = Settings.RainbowTracking.Enabled and Color3.fromHSV(tick() % 12 / 12, 1, 1) or nil
            for i, v in next, Services.Players:GetPlayers() do
                if v ~= Local.Player and (not Settings.TrackingTeamCheck.Enabled or v.Team ~= Local.Player.Team) then
                    local Parts = CharTable[v]
                    if Parts then
                        Backtrack(Parts, Colour or v.Team.TeamColor.Color)
                    end
                end
            end
        until Settings.Backtracking.Enabled == false
    end
end)

Tracking.AddLabel("Tracking Settings")

Settings.BacktrackDuration = Tracking.AddSlider("Backtrack Duration (ms)", 100, 5000)

Settings.TrackingTeamCheck = Tracking.AddToggle("Only Track Enemies", function(toggle)
	if toggle then
		for i, v in next, Local.Chams:GetChildren() do
			if v.Name == "Friendly" then
				v:Destroy()
			end
		end
	elseif Settings.Chams.Enabled then
		local Colour = Settings.RainbowTracking and Color3.fromHSV(tick() % 12 / 12, 1, 1) or nil
		for i, v in next, Services.Players:GetPlayers() do
			if v ~= Local.Player and v.Team == Local.Player.Team then
				local Parts = CharTable[v]
				if Parts then
					Chams(Parts, "Friendly", Colour or v.Team.TeamColor.Color)
				end
			end
		end
	end
end)

Settings.RainbowTracking = Tracking.AddToggle("Rainbow", function(toggle)
	if toggle then
		local Connection
		Connection = Services.RunService.Heartbeat:Connect(function()
			local Colour = Color3.fromHSV(tick() % 12 / 12, 1, 1)
			for i, v in next, Local.Chams:GetChildren() do
				v.Color3 = Colour
			end
			if not Settings.RainbowTracking.Enabled then
				Connection:Disconnect()
				for i, v in next, Local.Chams:GetChildren() do
					if v.Name == "Friendly" then
						v.Color3 = Local.Player.Team.TeamColor.Color
					elseif v.Name == "Enemy" then
						v.Color3 = GetEnemyTeam().TeamColor.Color
					end
				end
			end
		end)
	end
end)

local Misc = Lib.AddTab("Miscellaneous")

Misc.AddLabel("Kill Say")

Settings.KillSay = Misc.AddToggle("Enabled")

Settings.KillMsg = Misc.AddBox("Message", false)

Misc.AddLabel("Map Mods")

Settings.MapKeybind = Misc.AddKeybind("Toggle Map", function()
    if Local.Root then
        if workspace:FindFirstChild("Map") then
            Local.Root.Anchored = true
            workspace.Map.Parent = Services.Lighting
        elseif Services.Lighting:FindFirstChild("Map") then
            Services.Lighting.Map.Parent = workspace
            Local.Root.Anchored = false
        end
    end
end)

Settings.WindowsKeybind = Misc.AddKeybind("Break Windows", function()
    for i, v in next, workspace.Map:GetDescendants() do
        if v.Name == "Window" then
            Effects:breakwindow(v)
        end
    end
end)

Settings.NoBlood = Misc.AddToggle("Remove Blood", function(toggle)
    if toggle then
        workspace.Ignore.Blood:ClearAllChildren()
    end
end)

Settings.NoShells = Misc.AddToggle("Remove Shells", function(toggle)
    if toggle then
        workspace.Ignore.Bullets:ClearAllChildren()
    end
end)

Settings.NoBodies = Misc.AddToggle("Remove Dead Bodies", function(toggle)
    if toggle then
        workspace.Ignore.DeadBody:ClearAllChildren()
    end
end)

Settings.BulletTrace = Misc.AddToggle("Trace Bullets")

Settings.ShowImpacts = Misc.AddToggle("Show Bullet Impacts")

Misc.AddLabel("Other")

Settings.Fullbright = Misc.AddToggle("Fullbright", function(toggle)
    Services.Lighting.Brightness = toggle and FullLighting.Brightness or OldLighting.Brightness
    Services.Lighting.GlobalShadows = toggle and FullLighting.GlobalShadows or OldLighting.GlobalShadows
    Services.Lighting.Ambient = toggle and FullLighting.Ambient or OldLighting.Ambient
end)

Settings.Crosshair = Misc.AddToggle("Crosshair", function(toggle)
	Horizontal.Visible = toggle
	Vertical.Visible = toggle
end)

local GuiSettings = Lib.AddTab("Settings")

GuiSettings.AddLabel("GUI Settings")

GuiSettings.AddDropdown("Credits", { "Kieran - Owner, Main Scripter", "Integer - Fly System", "Introvert - Grenade TP" })

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
Settings.AntiAimMode.Set("Prone")
Settings.ThirdPersonDist.Set(10)
Settings.ESPTextSize.Set(16)
Settings.ESPRange.Set(2048)
Settings.TracerStart.Set("Bottom")
Settings.TracerOffset.Set(25)
Settings.BacktrackDuration.Set(1000)
Settings.KillMsg.Set("{user} isn't using Project: Evo")
Settings.ToggleKey.Set(Enum.KeyCode.RightShift)

if Local.Player.Character and Local.Player.Character.Parent ~= nil then
    RegisterChar(Local.Player.Character)
end

Local.Player.CharacterAdded:Connect(RegisterChar)

FOVCircle.Filled = false
FOVCircle.Position = MidScr
FOVCircle.Radius = 0
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)

Horizontal.Color = Color3.fromRGB(255, 40, 40)
Horizontal.From = Vector2.new(MidScr.X - 40, MidScr.Y)
Horizontal.To = Vector2.new(MidScr.X + 40, MidScr.Y)
Horizontal.Thickness = 0.5

Vertical.Color = Color3.fromRGB(255, 40, 40)
Vertical.From = Vector2.new(MidScr.X, MidScr.Y - 40)
Vertical.To = Vector2.new(MidScr.X, MidScr.Y + 40)
Vertical.Thickness = 0.5

for a, b in next, Modules:GetChildren() do
    GunTable[b.Name] = {}
    for c, d in next, require(b) do
        GunTable[b.Name][c] = d
    end
end

for i, v in next, getgc() do
    if type(v) == "function" and islclosure(v) then
        local scr = tostring(getfenv(v).script)
        if scr == "physics" and getinfo(v).name == "trajectory" then
            Functions.Trajectory = v
        elseif scr == "Framework" then
            local consts = debug.getconstants(v)
            if #consts > 1 and consts[2] == "slidespring" then
                Functions.Gunbob = v
            end
            for i2, v2 in next, debug.getupvalues(v) do
                if type(v2) == "table" then
                    if rawget(v2, "setbasewalkspeed") then
                        Char = v2
                    elseif rawget(v2, "gammo") then
                        Gamelogic = v2
                    elseif rawget(v2, "deploy") then
                        Menu = v2
                    elseif rawget(v2, "getplayerhealth") then
                        Hud = v2
                    elseif rawget(v2, "getbodyparts") then
                        CharTable = getupvalue(v2.getbodyparts, 1)
                    end
                end
            end
        end
    end
    if Char and Gamelogic and Menu and Hud and CharTable and Functions.Trajectory and Functions.Gunbob then
        break
    end
end

Local.Killfeed.ChildAdded:Connect(function(child)
    repeat Services.RunService.Heartbeat:Wait() until child.Text ~= "Shedletsky"
    if Settings.KillSay.Enabled and child:FindFirstChild("Victim") and child.Text == Local.Player.Name then
        Network:send("chatted", string.gsub(Settings.KillMsg.Value, "{user}", child.Victim.Text), false)
    end
end)

Services.RunService.RenderStepped:Connect(function()
    if Gamelogic.currentgun then
        Target = GetClosest()
        if Settings.AutoFire.Enabled and Target then
            Gamelogic.currentgun:shoot(true)
            wait()
            Gamelogic.currentgun:shoot(false)
        end
    end
end)

Local.Mouse.Move:Connect(function()
    FOVCircle.Position = Services.UserInputService:GetMouseLocation()
end)

makewriteable(Meta)

Meta.__newindex = newcclosure(loadstring([[
    local a, b, c, d, e, f, g, h, i, j = ...
    return function(t, k, ...)
        if k == g and t[i] == h and a.Enabled and b(b) then
            return d(t, k, ({...})[e] * j(f, f, c.Value))
        end
        d(t, k, ...)
    end
]])(Settings.ThirdPerson, Menu.isdeployed, Settings.ThirdPersonDist, NewIndex, 1, 0, "CFrame", "Camera", "Name", CFrame.new))

makereadonly(Meta)

local Setbasewalkspeed = Char.setbasewalkspeed
Char.setbasewalkspeed = newcclosure(function(self, speed)
    speed = speed + Settings.WalkSpeed.Value
    Setbasewalkspeed(self, speed)
end)

local Jump = Char.jump
Char.jump = newcclosure(function(self, power)
    power = power + Settings.JumpPower.Value
    Jump(self, power)
end)

if Gamelogic.currentgun and Gamelogic.currentgun.step then
    for i, v in next, debug.getupvalues(Gamelogic.currentgun.step) do
        if v == Functions.Gunbob then
            debug.setupvalue(Gamelogic.currentgun.step, i, function(...)
                if Settings.NoGunBob.Enabled then
                    return CFrame.new()
                end
                return Functions.Gunbob(...)
            end)
            break
        end
    end
end

local Send = Network.send
Network.send = newcclosure(function(self, code, ...)
    local Args = {...}
    if code == "logmessage" or code == "debug" or code == "closeconnection" or code == "flaguser" or code == "forcereset" then
        return
    elseif code == "falldamage" and Settings.AntiFallDamage.Enabled then
        return
    elseif code == "stance" and Settings.AntiAim.Enabled and Settings.AntiAimMode.Value == "Prone" then
        Args[1] = "prone"
    elseif code == "repupdate" then
        if Settings.AntiAim.Enabled then
            if Settings.AntiAimMode.Selected == "Spinbot" then
                Args[2] = Vector3.new(0, math.random(-100, 100) / 10, 0)
            elseif Settings.AntiAimMode.Selected == "Moonwalk" then
                Args[2] = Args[2] * Vector3.new(0, -1, 0)
            end
        end
    elseif code == "bullethit" and (math.random(0, 100) < Settings.HeadshotChance.Value) then
        Args[3] = Args[3].Parent.Head
    elseif code == "equip" then
        for i, v in next, getupvalues(Gamelogic.currentgun.step) do
            if v == Functions.Gunbob then
                setupvalue(Gamelogic.currentgun.step, i, function(...)
                    if Settings.NoGunBob.Enabled then
                        return CFrame.new()
                    end
                    return Functions.Gunbob(...)
                end)
                break
            end
        end
    elseif code == "newbullets" then
        if Settings.SilentAim.Enabled and math.random(1, 100) <= Settings.HitChance.Value and Target then
            local Enemy, EnemyPos, Speed = Target[2], Target[2].Position, Gamelogic.currentgun.data.bulletspeed
            local Dur = (EnemyPos - Args[1].firepos).Magnitude / Speed
            if Settings.PredictMovement.Enabled then
                EnemyPos = EnemyPos + (Enemy.Parent.HumanoidRootPart.Velocity * Dur)
            end
            local Traj = Functions.Trajectory(Args[1].firepos, Vector3.new(0, -196.2, 0), EnemyPos, Speed)
            for i, v in next, Args[1].bullets do
                v[1] = Traj
            end
            if Settings.BulletTrace.Enabled then
                coroutine.wrap(MakeTracer)(Traj)
            end
            Send(self, code, unpack(Args))
            coroutine.wrap(function()
                wait(Dur)
                if Enemy and Enemy:IsDescendantOf(workspace.Players) then
                    for i, v in next, Args[1].bullets do
                        Send(self, "bullethit", Target[1], EnemyPos, Enemy, v[2])
                    end
                end
            end)()
            return
        elseif Settings.BulletTrace.Enabled then
            for i, v in next, Args[1].bullets do
                coroutine.wrap(MakeTracer)(v[1])
            end
        end
    elseif code == "newgrenade" and Args[1] == "FRAG" and Settings.NadeTP.Enabled then
        local Nearest = GetNearest()
        if Nearest then
            Args[2].blowuptime = (#Args[2].frames + 1) * 0.016666666666666666
            Args[2].frames[#Args[2].frames + 1] = {
                ["v0"] = Vector3.new(),
                ["glassbreaks"] = {},
                ["t0"] = 0,
                ["offset"] = Vector3.new(),
                ["rot0"] = CFrame.new(),
                ["a"] = Vector3.new(),
                ["p0"] = Nearest.Position + (Nearest.Velocity * Args[2].blowuptime),
                ["rotv"] = Vector3.new()
            }
        end
    end
    Send(self, code, unpack(Args))
end)

local Bloodhit = Effects.bloodhit
Effects.bloodhit = newcclosure(function(...)
    if Settings.NoBlood.Enabled then
        return
    end
    Bloodhit(...)
end)

local Ejectshell = Effects.ejectshell
Effects.ejectshell = newcclosure(function(...)
    if Settings.NoShells.Enabled then
        return
    end
    Ejectshell(...)
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

workspace.Ignore.DeadBody.ChildAdded:Connect(function(child)
    if Settings.NoBodies.Enabled then
        wait(0.2)
        child:Destroy()
    end
end)

workspace.Ignore.Misc.ChildAdded:Connect(function(child)
    if Settings.ShowImpacts.Enabled and (child.Name == "Hole" or child.Name == "DefaultImpact") then
        child.Transparency = 0.6
        child.Color = Color3.fromRGB(200, 0, 0)
    end
end)

Esp.GetHealth = newcclosure(function(plr)
    return Hud:getplayerhealth(plr) / 100
end)

for a, b in next, workspace.Players:GetChildren() do
    for c, d in next, b:GetChildren() do
        if d ~= Local.Player.Character then
            RegisterEsp(d)
        end
    end
    b.ChildAdded:Connect(function(child)
        child:WaitForChild("HumanoidRootPart")
        if child ~= Local.Player.Character then
            RegisterEsp(child)
            if Settings.Chams.Enabled and (not Settings.TrackingTeamCheck.Enabled or b.Name ~= Local.Player.Team.Name) then
                local Colour = Settings.RainbowTracking.Enabled and Color3.fromHSV(tick() % 12 / 12, 1, 1) or Services.Teams[b.Name].TeamColor.Color
                local Parts = { child:WaitForChild("Head"), child:WaitForChild("Torso"), child:WaitForChild("Left Arm"), child:WaitForChild("Right Arm"), child:WaitForChild("Left Leg"), child:WaitForChild("Right Leg") }
                Chams(Parts, b.Name == Local.Player.Team.Name and "Friendly" or "Enemy", Colour)
            end
        end
    end)
end

Services.Lighting.Changed:Connect(function(property)
    if property == "Brightness" or property == "Ambient" or property == "GlobalShadows" then
        if Services.Lighting[property] ~= FullLighting[property] then
            OldLighting[property] = Services.Lighting[property]
            if Settings.Fullbright.Enabled then
                Services.Lighting.Brightness = 10
                Services.Lighting.Ambient = Color3.new(1, 1, 1)
                Services.Lighting.GlobalShadows = false
            end
        end
    end
end)