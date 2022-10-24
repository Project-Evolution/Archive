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
	ItemsUnlocked = Services.Players.LocalPlayer.Items,
	Message = Services.Players.LocalPlayer.PlayerGui.MainGui.SimpleMessage,
	CellTime = Services.Players.LocalPlayer.PlayerGui.MainGui.CellTime,
	Minimap = Services.Players.LocalPlayer.PlayerGui.SidebarGui.Container.ContainerMinimap.Minimap.Container.Players,
	Mouse = Services.Players.LocalPlayer:GetMouse(),
	Cam = workspace.CurrentCamera
}

local Em, WallbangIgnores = {}, {}
local Doors, Sewers = {}, {}
local TelePlayers
local Flying = false

local RobberyNames = { "Bank", "Jewelry Store", "Museum", "Power Plant", "Donut Store", "Gas Station", "Cargo Train", "Passenger Train", "Plane", "Airdrop" }
local RobberyLocations = {
	["Bank"] = CFrame.new(-12, 20, 782),
	["Jewelry Store"] = CFrame.new(126, 20, 1368),
	["Museum"] = CFrame.new(1142, 104, 1247),
	["Power Plant"] = CFrame.new(636, 39, 2357),
	["Donut Store"] = CFrame.new(90, 20, -1511),
	["Gas Station"] = CFrame.new(-1526, 19, 699)
}

local PlaceNames = { "Prison Yard", "1M Dealership", "Volcano Base", "Military Base", "Secret Police Base", "City Base", "Boat Docks", "Airport", "Fire Station", "Gun Store", "JetPack Mountain", "Pirate Hideout", "Lighthouse", "Prison Island" }
local PlaceLocations = {
	["Prison Yard"] = CFrame.new(-1220, 18, -1760),
	["1M Dealership"] = CFrame.new(704, 19, -1530),
	["Volcano Base"] = CFrame.new(1641, 50, -1770),
	["Military Base"] = CFrame.new(769, 18, -306),
	["Secret Police Base"] = CFrame.new(1547, 70, 1669),
	["City Base"] = CFrame.new(-243, 18, 1601),
	["Boat Docks"] = CFrame.new(-430, 21, 2025),
	["Airport"] = CFrame.new(-1202, 41, 2846),
	["Fire Station"] = CFrame.new(-930, 32, 1349),
	["Gun Store"] = CFrame.new(391, 18, 533),
	["JetPack Mountain"] = CFrame.new(1384, 168, 2596),
	["Pirate Hideout"] = CFrame.new(1860, 31, 1885),
	["Lighthouse"] = CFrame.new(-2044, 45, 1722),
	["Prison Island"] = CFrame.new(-2917, 24, 2312)
}

local Meta = getrawmetatable(game)
local Namecall = Meta.__namecall

local Inventory = require(Services.ReplicatedStorage.Game.Inventory)
local Gun = require(Services.ReplicatedStorage.Game.Item.Gun)
local ItemSystem = require(Services.ReplicatedStorage.Game.ItemSystem.ItemSystem)
local Notification = require(Services.ReplicatedStorage.Game.Notification)
local GunShopSystem = require(Services.ReplicatedStorage.Game.GunShop.GunShopSystem)
local Vehicle = require(Services.ReplicatedStorage.Game.Vehicle)
local AlexChassis = require(Services.ReplicatedStorage.Module.AlexChassis)
local AlexRagdoll = require(Services.ReplicatedStorage.Module.AlexRagdoll)
local Maid = require(Services.ReplicatedStorage.Module.Maid)
local GameSettings = require(Services.ReplicatedStorage.Resource.Settings)

local Event = getupvalue(AlexChassis.SetEvent, 1)
local UpdatePrePhysics = AlexChassis.UpdatePrePhysics
local OnAction = AlexChassis.OnAction
local VehicleEnter = AlexChassis.VehicleEnter
local VehicleLeave = AlexChassis.VehicleLeave

local VoltPhysics = require(Services.ReplicatedStorage.Game.Vehicle.Volt).UpdatePrePhysics

local Raycast = require(Services.ReplicatedStorage.Module.RayCast)
local RayIgnoreNonCollide = Raycast.RayIgnoreNonCollide
local RayIgnoreNonCollideWithIgnoreList = Raycast.RayIgnoreNonCollideWithIgnoreList

local Boat = require(Services.ReplicatedStorage.Game.Boat.Boat)
local UpdatePhysics = Boat.UpdatePhysics

local Turret = require(Services.ReplicatedStorage.Game.Robbery.CargoShip.Turret)
local Shoot = Turret.Shoot

local Heli, HeliUpdate = {}, nil
local HeliNames = { "Heli", "LittleBird", "UFO", "BlackHawk", "Drone", "Lia" }

local Plane = require(Services.ReplicatedStorage.Game.Plane.Plane)
local FromPacket = Plane.FromPacket
local PlaneData = {}

local Grenade = require(Services.ReplicatedStorage.Game.Item.Grenade)
local ShootBegin = Grenade.ShootBegin

local CharacterUtil = require(Services.ReplicatedStorage.Game.CharacterUtil)
local Hotbar = require(Services.ReplicatedStorage.Game.Hotbar)
local Select = Hotbar.Select

local JetPack = require(Services.ReplicatedStorage.Game.JetPack.JetPack)
local IsFlying = JetPack.IsFlying
local JetPackTable = {}

local ItemConfig = Services.ReplicatedStorage.Game.ItemConfig
local GrenadeConfig = require(ItemConfig.Grenade)

local Vehicles, VehicleSpawns = {}, {}

local Emitter = require(Services.ReplicatedStorage.Game.ItemSystem.BulletEmitter)
local Emit = Emitter.Emit

local PlasmaPistol = require(Services.ReplicatedStorage.Game.Item.PlasmaPistol)
local ShootOther = PlasmaPistol.ShootOther

local MidScr = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y / 2)
local TracerOrigins = { Top = Vector2.new(Local.Cam.ViewportSize.X / 2, 0), Middle = MidScr, Bottom = Vector2.new(Local.Cam.ViewportSize.X / 2, Local.Cam.ViewportSize.Y) }
local FOVCircle = newdrawing("Circle")

local Specs = require(Services.ReplicatedStorage.Module.UI).CircleAction.Specs
local Puzzle = getupvalue(require(Services.ReplicatedStorage.Game.Robbery.PuzzleFlow).Init, 3)
local SpecStore = {}

local Lightning = require(Services.ReplicatedStorage.Game.LightningSystem)

local Esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V1/EspModule.lua", true))()

-- Replicated Game Tables

local FakeEmitter = {
    __ClassName = "Shotgun",
    Local = true,
    IgnoreList = {},
    LastImpact = 0,
    LastImpactSound = 0,
    Maid = Maid.new()
}

local PlaneConsts = {
	["Speed"] = {
		["Stunt"] = 600,
		["Jet"] = 1200
	},
	["Height"] = {
		["Stunt"] = 1100,
		["Jet"] = 2100
	}
}

local GunStatTable = {}

-- Functions

function GetXZDir(Target, Speed)
	local Vec = (Target.Position - Local.Root.Position).Unit
	return Vector3.new(Vec.X, 0, Vec.Z) * Speed
end

function GetXZMag(Target)
	local Pos = Vector3.new(Local.Root.Position.X, 0, Local.Root.Position.Z)
	local End = Vector3.new(Target.Position.X, 0, Target.Position.Z)
	return (Pos - End).Magnitude
end

function PlayerTP(Cf)
	local Vel = Instance.new("BodyVelocity", Local.Root)
	Vel.Velocity, Vel.MaxForce = Vector3.new(), Vector3.new(9e9, 9e9, 9e9)
	Local.Root.CFrame = CFrame.new(Local.Root.Position.X, -150, Local.Root.Position.Z)
	Vel.Velocity = GetXZDir(Cf, 80)
	repeat wait() until GetXZMag(Cf) < 5
	Vel:Destroy()
	Local.Root.CFrame = Cf
end

function CarTP(Cf)
	local Current = Functions.GetVehicle().Model
	local Vel = Instance.new("BodyVelocity", Local.Root)
	Vel.Velocity, Vel.MaxForce = Vector3.new(), Vector3.new(9e9, 9e9, 9e9)
	Current:SetPrimaryPartCFrame(CFrame.new(Local.Root.Position.X, -150, Local.Root.Position.Z))
	Vel.Velocity = GetXZDir(Cf, 320)
	repeat wait()
		if not Local.Char:FindFirstChild("InVehicle") then
			Vel:Destroy()
			PlayerTP(Cf)
			return
		end
	until GetXZMag(Cf) < 20
	Vel.Velocity = Vector3.new()
	wait()
	Vel:Destroy()
	Current:SetPrimaryPartCFrame(Cf)
	if Settings.EjectAfterTP.Enabled then
		wait(0.5)
		Functions.ExitVehicle()
	end
end

function Teleport(Cf)
	if not Local.Root then
		Lib.Notify("TP Failed - Not Alive")
		return
	end
	if Functions.GetVehicle() then
		CarTP(Cf)
	else
		PlayerTP(Cf)
	end
end

function RegisterChar(char)
	Local.Char = char
	Local.Root = char:WaitForChild("HumanoidRootPart")
	Local.Hum = char:WaitForChild("Humanoid")
	Local.Hum.WalkSpeed = Settings.WalkSpeed.Value
	Local.Hum.JumpPower = Settings.JumpPower.Value
	Local.Hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if Settings.WalkSpeed.Value ~= 16 then
			Local.Hum.WalkSpeed = Settings.WalkSpeed.Value
		end
	end)
	Local.Hum.Died:Connect(function()
		Local.Char, Local.Root, Local.Hum = nil, nil, nil
	end)
	Local.Char.ChildAdded:Connect(function(child)
		if child.Name == "InVehicle" and Settings.CarFly.Enabled then
			CarFly()
		end
	end)
end

function Equip(name)
	for i, v in next, Inventory.ItemStacks do
		if v.Name == name then
			local old = getthreadidentity()
			setthreadidentity(2)
			ItemSystem.Equip(Local.Player, v)
			setthreadidentity(old)
			break
		end
	end
end

function IsEquipped(name)
	local Item = ItemSystem.GetLocalEquipped()
	if Item and Item.Name == name then
		return true
	end
	return false
end

function GetRemainingAmmo(name)
	for i, v in next, Inventory.ItemStacks do
		if v.Name == name then
			return GunStatTable[name].MagSize - v.AmmoCurrent
		end
	end
	return 0
end

function IsEligible(plr, ignore)
	if Local.Root == nil or plr.Character == nil or plr.Character.Parent == nil or plr.Team == Local.Player.Team then 
		return false 
	end
	if Settings.IgnorePrisoners.Enabled and plr.Team.Name == "Prisoner" then
		return false
	end
	local RootPos = plr.Character.HumanoidRootPart.Position
	local Pos, Vis = Local.Cam:WorldToViewportPoint(RootPos)
	if Vis then
		if Settings.VisibleCheck.Enabled then
			local Unit = (RootPos - Local.Root.Position).Unit
			local VisRay = Ray.new(Local.Root.Position, Unit * 500)
			local Part = workspace:FindPartOnRayWithIgnoreList(VisRay, ignore)
			if Part and not Services.Players:GetPlayerFromCharacter(Part.Parent) then
				return false
			end
		end
		return Pos
	end
end

function GetClosest(ignore, retpos)
	local Direction, Pos, Closest = nil, nil, Settings.UseFOV.Enabled and Settings.FOV.Value or math.huge
	for i, v in next, Services.Players:GetPlayers() do
		local Eligible = IsEligible(v, ignore)
		if Eligible then
			local Dist = (Vector2.new(Eligible.X, Eligible.Y) - Services.UserInputService:GetMouseLocation()).Magnitude
			if Dist < Closest then
				Closest = Dist
				Pos = v.Character.HumanoidRootPart.Position
				Direction = (v.Character.HumanoidRootPart.Position - Local.Root.Position).Unit
			end
		end
	end
	if retpos then
		return Pos
	end
	return Direction
end

function DeepCopy(tab, output)
	for i, v in next, tab do
		output[i] = v
		if type(v) == "table" then
			DeepCopy(v, output[i])
		end
	end
end

function CompletePuzzle()
	local Grid = {}
	DeepCopy(Puzzle.Grid, Grid)
	for i, v in next, Grid do
		for i2, v2 in next, v do
			v[i2] = v2 + 1
		end
	end
	local Response = request({
		Url = "https://numberlink-solver.sagesapphire.repl.co",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = Services.HttpService:JSONEncode({
			Matrix = Grid
		})
	})
	local Solution = Services.HttpService:JSONDecode(Response.Body).Solution
	for i, v in next, Solution do
		for i2, v2 in next, v do
			v[i2] = v2 - 1
		end
	end
	Puzzle.Grid = Solution
	Puzzle.OnConnection()
end

function RegisterEsp(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        Esp.Add(plr, plr.Character.HumanoidRootPart, plr.TeamColor.Color)
    end
    plr.CharacterAdded:Connect(function(char)
        Esp.Add(plr, char:WaitForChild("HumanoidRootPart"), plr.TeamColor.Color)
    end)
end

function CarFly()
	local Gyro = Instance.new("BodyGyro", Local.Root)
	local Vel = Instance.new("BodyVelocity", Local.Root)
	Gyro.CFrame = Local.Root.CFrame
	Gyro.P, Gyro.MaxTorque = 9e4, Vector3.new(9e9, 9e9, 9e9)
	Vel.Velocity, Vel.MaxForce = Vector3.new(), Vector3.new(9e9, 9e9, 9e9)
	repeat wait()
		if not Local.Char or not Local.Char:FindFirstChild("InVehicle") then
			break
		end
		Vel.Velocity = Vector3.new()
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            Vel.Velocity = Vel.Velocity + Local.Cam.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            Vel.Velocity = Vel.Velocity - Local.Cam.CFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            Vel.Velocity = Vel.Velocity - Local.Cam.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            Vel.Velocity = Vel.Velocity + Local.Cam.CFrame.RightVector
        end
		Vel.Velocity = Vel.Velocity * Settings.CarFlySpeed.Value
		Gyro.CFrame = Local.Cam.CFrame
	until Settings.CarFly.Enabled == false
	Gyro:Destroy()
	Vel:Destroy()
end

function GetPlayersExceptMe()
	local Plrs = Services.Players:GetPlayers()
	Plrs[table.find(Plrs, Local.Player)] = nil
	return Plrs
end

-- GUI

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V1/Library.lua", true))()
Lib.Init("JailBreak")

local Teleports = Lib.AddTab("Teleports")

Teleports.AddLabel("TP Locations")

Teleports.AddDropdown("Robberies", RobberyNames, function(val)
	local Location = RobberyLocations[val]
	if Location then
		Teleport(Location)
	elseif val == "Cargo Train" then
		if workspace.Trains:FindFirstChild("BoxCar") then
			Teleport(workspace.Trains.BoxCar.Model.Box.Roof.CFrame + Vector3.new(0, 3, 0))
			return
		end
		Lib.Notify("Teleportation Failed - No Cargo Trains")
	elseif val == "Passenger Train" then
		if workspace.Trains:FindFirstChild("SteamEngine") then
			Teleport(workspace.Trains.SteamEngine.Model.Effects.Smoke.CFrame + Vector3.new(0, 3, 0))
			return
		end
		Lib.Notify("Teleportation Failed - No Passenger Trains")
	elseif val == "Plane" then
		if workspace:FindFirstChild("Plane") then
			Teleport(workspace.Plane.TopDoor.Open.CFrame + Vector3.new(0, 3, 0))
			return
		end
		Lib.Notify("Teleportation Failed - No Planes")
	elseif val == "Airdrop" then
		if workspace:FindFirstChild("Drop") then
			Teleport(workspace.Drop.Briefcase.CFrame + Vector3.new(0, 3, 0))
			return
		end
		Lib.Notify("Teleportation Failed - No Airdrops")
	end
end)

Teleports.AddDropdown("Places", PlaceNames, function(val)
	Teleport(PlaceLocations[val])
end)

Teleports.AddDropdown("Vehicles", workspace.VehicleSpawns:GetChildren(), function(val)
	Teleport(workspace.VehicleSpawns[val].Region.CFrame)
end)

TelePlayers = Teleports.AddDropdown("Players", GetPlayersExceptMe(), function(val)
	local Plr = Services.Players[val]
	if Plr and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
		Teleport(Plr.Character.HumanoidRootPart.CFrame)
	end
end)

Teleports.AddLabel("TP Settings")

Settings.EjectAfterTP = Teleports.AddToggle("Eject After Teleporting")

local Player = Lib.AddTab("Player Mods")

Player.AddLabel("Character Mods")

Settings.WalkSpeed = Player.AddSlider("WalkSpeed", 16, 80, function(val)
	if Local.Hum then
		Local.Hum.WalkSpeed = val
	end
end)

Settings.JumpPower = Player.AddSlider("JumpPower", 50, 300, function(val)
	if Local.Hum then
		Local.Hum.JumpPower = val
	end
end)

Settings.FlySpeed = Player.AddSlider("Fly Speed", 16, 80)

Settings.Fly = Player.AddKeybind("Fly", function(bind)
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
			Local.Root.Velocity = Vector3.new()
            Local.Root.Anchored = false
        end
    end
end)

Settings.InfJump = Player.AddToggle("Infinite Jump")

Settings.NoClip = Player.AddToggle("No Clip", function(toggle)
	if toggle then
		local Connection
		Connection = Services.RunService.Stepped:Connect(function()
			if Local.Char then
				for i, v in next, Local.Char:GetChildren() do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
			if Settings.NoClip.Enabled == false then
				Connection:Disconnect()
			end
		end)
	end
end)

Settings.NoWait = Player.AddToggle("No Wait", function(toggle)
	if toggle then
		repeat wait(1)
			for i, v in next, Specs do
				if not SpecStore[v] then
					SpecStore[v] = v.Duration
				end
				v.Duration = 0
			end
		until Settings.NoWait.Enabled == false
		for i, v in next, Specs do
			v.Duration = SpecStore[v] or v.Duration
		end
	end
end)

Settings.AntiRagdoll = Player.AddToggle("Anti Ragdoll")

Settings.ArrestAura = Player.AddToggle("Arrest Aura", function(toggle)
	if toggle then
		repeat wait()
			if Local.Player.Team == Services.Teams.Police and Local.Root then
				for i, v in next, Services.Teams.Criminal:GetPlayers() do
					if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and not v.Character:FindFirstChild("Handcuffs") then
						if (v.Character.HumanoidRootPart.Position - Local.Root.Position).Magnitude < 30 then
							if not IsEquipped("Handcuffs") then
								Equip("Handcuffs")
							end
							Functions.Arrest(v)
						end
					end
				end
			end
		until Settings.ArrestAura.Enabled == false
	end
end)

Player.AddLabel("Player Mods")

Settings.TeamCooldown = Player.AddToggle("No Team Switch Cooldown", function(toggle)
	GameSettings.Time.BetweenTeamChange = toggle and 0 or 24
end)

Settings.NoCellTime = Player.AddToggle("No Cell Time", function(toggle)
	GameSettings.Time.Cell = toggle and 0 or 20
end)

Player.AddDropdown("Change Team", {"Prisoner", "Police"}, function(val)
	if Local.Player.Team.Name ~= val then
		setupvalue(Functions.ChangeTeam, 1, val == "Police" and 1 or 2)
		Functions.ChangeTeam()
	end
end)

Player.AddLabel("Other")

Settings.FieldOfView = Player.AddSlider("Field Of View", 70, 120, function(val)
	Local.Cam.FieldOfView = val
end)

Settings.Freecam = Player.AddToggle("Freecam", function(toggle)
	if toggle then
		Functions.Freecam()
	else
		Functions.CloseFreecam()
		if Local.Hum then
			Local.Hum.WalkSpeed = Settings.WalkSpeed.Value
		end
	end
end)

Player.AddButton("Open All Safes", function()
	local Amount = math.huge
	repeat wait()
		Amount = #SafeData.ListSafes
		for a, b in next, SafeData.ListSafes do
			SafeData.SelectedSafe = b
			Functions.OpenSafe()
			setupvalue(Functions.SkipSlider, 4, {Frame = Instance.new("Frame")})
			Functions.SkipSlider()
			wait(1)
		end
	until Amount == 0
end)

Player.AddButton("Give Police Uniform", function()
	local Uniform = { "ShirtPolice", "PantsPolice", "HatPolice" }
	for i, v in next, workspace.Givers:GetChildren() do
		if table.find(Uniform, v.Item.Value) then
			Uniform[table.find(Uniform, v.Item.Value)] = nil
			fireclickdetector(v.ClickDetector)
			wait()
		end
	end
end)

Player.AddButton("Remove Outfit", function()
	fireclickdetector(workspace.ClothingRacks.ClothingRack.Hitbox.ClickDetector)
end)

local Cars = Lib.AddTab("Cars")

Cars.AddLabel("Car Mods")

Settings.EngineSpeed = Cars.AddSlider("Engine Speed", 1, 100)

Settings.TurnSpeed = Cars.AddSlider("Turn Speed", 1, 100)

Settings.CarHeight = Cars.AddSlider("Suspension Height", 1, 100)

Settings.CarFlySpeed = Cars.AddSlider("Car Fly Speed", 16, 300)

Settings.CarFly = Cars.AddToggle("Car Fly", function(toggle)
	if toggle and Local.Char and Local.Char:FindFirstChild("InVehicle") then
		CarFly()
	end
end)

Settings.InfNitro = Cars.AddToggle("Inf Nitro", function(toggle)
	if toggle then
		repeat wait()
			if Functions.GetVehicle() then
				Vehicles.Nitro = 250
			end
		until Settings.InfNitro.Enabled == false
	end
end)

Settings.PopAll = Cars.AddToggle("Pop All Tires", function(toggle)
	if toggle then
		repeat wait()
			for i, v in next, workspace.Vehicles:GetChildren() do
				if not table.find(HeliNames, v.Name) and v:FindFirstChild("Seat") and v.Seat:FindFirstChild("Player") and v.Seat.Player.Value == true then
					FakeEmitter.LastImpact = 0
					FakeEmitter.BulletEmitter.OnHitSurface:Fire(v.Engine, v.Engine.Position, v.Engine.Position)
					wait()
				end
			end
		until Settings.PopAll.Enabled == false
	end
end)

Settings.AntiPop = Cars.AddToggle("Anti Tire Pop")

Settings.AntiFlip = Cars.AddToggle("Anti Flip Over", function(toggle)
	if toggle then
		repeat wait()
			if Functions.GetVehicle() then
				Functions.Action({Name = "Flip"}, true)
			end
		until Settings.AntiFlip.Enabled == false
	end
end)

Settings.FloatOnWater = Cars.AddToggle("Drive On Water")

Settings.AutoPilot = Cars.AddToggle("Auto Pilot", function(toggle)
	if Functions.GetVehicle() then
		setupvalue(OnAction, 8, toggle)
	end
end)

Settings.AutoDrift = Cars.AddToggle("Auto Drift")

Settings.AutoLock = Cars.AddToggle("Auto Lock", function(toggle)
	if toggle then
		local Vehicle = Functions.GetVehicle()
		if Vehicle and Vehicle.Locked == false then
			Functions.LockVehicle()
		end
	end
end)

Settings.InjanHorn = Cars.AddToggle("Injan Horn", function(toggle)
	GameSettings.Perm.InjanHorn.Id[tostring(Local.Player.UserId)] = toggle
end)

Settings.SpamHeadlights = Cars.AddToggle("Epileptic Headlights", function(toggle)
	if toggle then
		local On = false
		repeat wait()
			if Functions.GetVehicle() then
				On = not On
				setupvalue(OnAction, 3, On)
			end
		until Settings.SpamHeadlights.Enabled == false
	end
end)

local OtherVehicles = Lib.AddTab("Other Vehicles")

OtherVehicles.AddLabel("Voltbike")

Settings.VoltSpeed = OtherVehicles.AddSlider("Volt Bike Speed", 1, 100, function(val)
	setconstant(VoltPhysics, 32, 1.4 + val)
end)

OtherVehicles.AddLabel("Boats")

Settings.BoatSpeed = OtherVehicles.AddSlider("Boat Speed", 1, 100)

Settings.BoatsOnLand = OtherVehicles.AddToggle("Boats On Land")

Settings.JetSkiOnLand = OtherVehicles.AddToggle("JetSki On Land")

Settings.DisableTurrets = OtherVehicles.AddToggle("Disable Ship Turrets", function(toggle)
	Turret.Shoot = toggle and newcclosure(function() end) or Shoot
end)

OtherVehicles.AddLabel("Helicopters")

Settings.HeliSpeed = OtherVehicles.AddSlider("Heli Speed", 1, 100)

Settings.InfHeliHeight = OtherVehicles.AddToggle("Infinite Heli Height")

Settings.InfDroneHeight = OtherVehicles.AddToggle("Infinite Drone Height")

Settings.InstantPickup = OtherVehicles.AddToggle("Instant Pickup")

Settings.TakedownHelis = OtherVehicles.AddToggle("Take Down All Helis", function(toggle)
	if toggle then
		repeat wait()
			for i, v in next, workspace.Vehicles:GetChildren() do
				if table.find(HeliNames, v.Name) and v:FindFirstChild("Seat") and v.Seat:FindFirstChild("Player") and v.Seat.Player.Value == true then
					FakeEmitter.LastImpact = 0
					FakeEmitter.BulletEmitter.OnHitSurface:Fire(v.Engine, v.Engine.Position, v.Engine.Position)
					wait()
				end
			end
		until Settings.TakedownHelis.Enabled == false
	end
end)

Settings.SpamSpotlight = OtherVehicles.AddToggle("Epileptic Spotlight", function(toggle)
	if toggle then
		repeat wait()
			if Functions.GetVehicle() then
				Heli.OnAction({Name = "Lights"}, true)
			end
		until Settings.SpamSpotlight.Enabled == false
	end
end)

OtherVehicles.AddButton("Hijack Helicopters", function()
	for i, v in next, workspace.Vehicles:GetChildren() do
		if v.Name == "Heli" then
			Functions.HijackVehicle(v)
		end
	end
end)

OtherVehicles.AddLabel("Planes")

Settings.PlaneSpeed = OtherVehicles.AddSlider("Plane Speed", 1, 100, function(val)
	for i, v in next, PlaneData do
		local Thrust = PlaneConsts.Speed[v.Model.Name] or 700
		v.CONST.MAX_THRUST = Thrust * ((val / 20) + 0.9)
	end
end)

Settings.InfPlaneHeight = OtherVehicles.AddToggle("Infinite Plane Height", function(toggle)
	for i, v in next, PlaneData do
		local Height = PlaneConsts.Height[v.Model.Name] or 5000
		v.CONST.HEIGHT_MAX = toggle and math.huge or Height
	end
end)

local Combat = Lib.AddTab("Combat")

Combat.AddLabel("Grab Items")

Combat.AddButton("Grab Weapons", function()
	Instance.new("BoolValue", Local.ItemsUnlocked).Name = "Pistol"
	Instance.new("BoolValue", Local.ItemsUnlocked).Name = "Grenade"
	Instance.new("BoolValue", Local.ItemsUnlocked).Name = "C4"
	for i, v in next, Local.ItemsUnlocked:GetChildren() do
		if not Functions.HasItem(v.Name) then
			setupvalue(Functions.GrabGun, 2, v.Name)
			Functions.GrabGun()
		end
	end
	Local.ItemsUnlocked.Pistol:Destroy()
	Local.ItemsUnlocked.Grenade:Destroy()
	Local.ItemsUnlocked.C4:Destroy()
end)

Combat.AddButton("Buy Grenade Ammo", function()
	if not Functions.HasItem("Grenade") then
		Instance.new("BoolValue", Local.ItemsUnlocked).Name = "Grenade"
		setupvalue(Functions.GrabGun, 2, "Grenade")
		Functions.GrabGun()
		Local.ItemsUnlocked.Grenade:Destroy()
	end
	setupvalue(Functions.GrabGun, 2, "GrenadeAmmo")
	for i = 1, GetRemainingAmmo("Grenade") do
		Functions.GrabGun()
	end
end)

Combat.AddButton("Buy Rocket Launcher Ammo", function()
	if not Functions.HasItem("RocketLauncher") then
		setupvalue(Functions.GrabGun, 2, "RocketLauncher")
		Functions.GrabGun()
	end
	setupvalue(Functions.GrabGun, 2, "RocketAmmo")
	for i = 1, GetRemainingAmmo("RocketLauncher") do
		Functions.GrabGun()
	end
end)

Combat.AddButton("Buy C4 Ammo", function()
	if not Functions.HasItem("Grenade") then
		Instance.new("BoolValue", Local.ItemsUnlocked).Name = "C4"
		setupvalue(Functions.GrabGun, 2, "C4")
		Functions.GrabGun()
		Local.ItemsUnlocked.C4:Destroy()
	end
	setupvalue(Functions.GrabGun, 2, "C4Ammo")
	for i = 1, GetRemainingAmmo("C4") do
		Functions.GrabGun()
	end
end)

Combat.AddLabel("Gun Mods")

Settings.FullAuto = Combat.AddToggle("Fully Automatic", function(toggle)
	for i, v in next, ItemConfig:GetChildren() do
		local req = require(v)
		req.FireAuto  = toggle and true or GunStatTable[v.Name].FireAuto
		req.ReloadTime = toggle and 0 or GunStatTable[v.Name].ReloadTime
	end
end)

Settings.RapidFire = Combat.AddToggle("Rapid Fire", function(toggle)
	for i, v in next, ItemConfig:GetChildren() do
		require(v).FireFreq = toggle and 60 or GunStatTable[v.Name].FireFreq
	end
end)

Settings.InfAmmo = Combat.AddToggle("Infinite Ammo", function(toggle)
	for i, v in next, ItemConfig:GetChildren() do
		require(v).MagSize = toggle and math.huge or GunStatTable[v.Name].MagSize
	end
end)

Settings.NoRecoil = Combat.AddToggle("No Recoil", function(toggle)
	for i, v in next, ItemConfig:GetChildren() do
		require(v).CamShakeMagnitude = toggle and 0 or GunStatTable[v.Name].CamShakeMagnitude
	end
end)

Settings.NoSpread = Combat.AddToggle("No Bullet Spread", function(toggle)
	for i, v in next, ItemConfig:GetChildren() do
		require(v).BulletSpread = toggle and 0 or GunStatTable[v.Name].BulletSpread
	end
end)

Settings.Wallbang = Combat.AddToggle("Wallbang")

Combat.AddLabel("Grenade Mods")

Settings.FuseTime = Combat.AddSlider("Grenade Fuse Time", 0, 10, function(val)
	GrenadeConfig.FuseTime = val
end)

Settings.NadeRapidFire = Combat.AddToggle("Grenade Rapid Fire")

Combat.AddLabel("Other")

Settings.DriveShoot = Combat.AddToggle("Shoot While Driving")

Settings.CrawlShoot = Combat.AddToggle("Shoot While Crawling")

Settings.JetpackShoot = Combat.AddToggle("Shoot While Jetpacking")

local SilentAim = Lib.AddTab("Silent Aim")

SilentAim.AddLabel("Silent Aim Settings")

Settings.SilentAim = SilentAim.AddToggle("Enabled")

Settings.VisibleCheck = SilentAim.AddToggle("Visibility Check")

Settings.IgnorePrisoners = SilentAim.AddToggle("Ignore Prisoners")

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

Settings.ShowAirdrops = ESP.AddToggle("Show Airdrops", function(toggle)
	if toggle then
		for i, v in next, workspace:GetChildren() do
			if v.Name == "Drop" then
				coroutine.wrap(function()
					Esp.AddItem("Airdrop", v:WaitForChild("Briefcase"), v.Briefcase.Color)
				end)()
			end
		end
	else
		for i, v in next, Esp.ItemContainer do
			Esp.Remove(i)
		end
	end
end)

Settings.MapShow = ESP.AddToggle("Minimap Show All", function(toggle)
	for i, v in next, Local.Minimap:GetChildren() do
		if toggle then
			v.Visible = true
		elseif Services.Players[v.Name].Team ~= Local.Player.Team then
			v.Visible = false
		end
	end
end)

local Equipment = Lib.AddTab("Equipment")

Equipment.AddLabel("Jetpack")

Settings.InfJetPackFuel = Equipment.AddToggle("Infinite Jetpack Fuel", function(toggle)
	local maxFuel = Settings.PremiumJetPackFuel.Enabled and 40 or 10
	JetPackTable.LocalMaxFuel = toggle and math.huge or maxFuel
	JetPackTable.LocalFuel = toggle and math.huge or maxFuel
end)

Settings.PremiumJetPackFuel = Equipment.AddToggle("Premium Jetpack Fuel", function(toggle)
	JetPackTable.LocalFuelType = toggle and "Rocket" or "Standard"
	if Settings.InfJetPackFuel.Enabled == false then
		JetPackTable.LocalMaxFuel = toggle and 40 or 10
	end
end)

Equipment.AddLabel("Other")

Equipment.AddButton("Grab Keycard", function()
	if Local.Player.Team ~= Services.Teams.Police and Local.Root and not Functions.HasItem("Key") then
		local Pos = Local.Root.CFrame
		local Cop = nil
		for i, v in next, Services.Teams.Police:GetPlayers() do
			if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				Cop = v
			end
		end
		if Cop ~= nil then
			local Connection
			Connection = Services.RunService.Stepped:Connect(function()
				Local.Root.CFrame = Cop.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
				Functions.Pickpocket(Cop)
			end)
			repeat wait() until not Local.Root or Functions.HasItem("Key")
			Connection:Disconnect()
			wait(0.5)
			Local.Root.CFrame = Pos + Vector3.new(0, 3, 0)
		end
	end
end)

local Robberies = Lib.AddTab("Robberies")

Robberies.AddLabel("Robbery Options")

Settings.NoMuseumDetection = Robberies.AddToggle("No Museum Detection")

Settings.AutoPuzzles = Robberies.AddToggle("Autocomplete Power Plant Puzzles", function(toggle)
	if toggle and Puzzle.IsOpen then
		CompletePuzzle()
	end
end)

Robberies.AddButton("Rob Small Stores", function()
	if Local.Player.Team ~= Services.Teams.Police and Local.Root then
		local Location = Local.Root.CFrame
		for i, v in next, Specs do
			if v.Name == "Rob" then
				Teleport(v.Part.CFrame + Vector3.new(0, 20, 0))
				wait(1)
				v:Callback(true)
				wait(1)
			end
		end
		Teleport(Location + Vector3.new(0, 3, 0))
	end
end)

local Misc = Lib.AddTab("Miscellaneous")

Misc.AddLabel("Serverside")

Settings.AnnoyServer = Misc.AddToggle("Annoy Server", function(toggle)
	if toggle then
		repeat wait()
			if Local.Root then
				for i, v in next, GameSettings.Sounds do
					Functions.PlaySound(i, {Source = Local.Root, Volume = math.huge, Multi = true})
				end
			end
		until Settings.AnnoyServer.Enabled == false
	end
end)

Settings.OpenDoors = Misc.AddToggle("Open All Doors", function(toggle)
	if toggle then
		repeat wait(0.5)
			for i, v in next, Doors do
				Functions.OpenDoor(v)
			end
		until Settings.OpenDoors.Enabled == false
	end
end)

Settings.OpenSewers = Misc.AddToggle("Open All Sewers", function(toggle)
	if toggle then
		repeat wait(0.5)
			for i, v in next, Sewers do
				v()
			end
		until Settings.OpenSewers.Enabled == false
	end
end)

Settings.ExplodeWall = Misc.AddToggle("Explode Wall", function(toggle)
	if toggle then
		repeat wait(0.5)
			Functions.ExplodeWall()
		until Settings.ExplodeWall.Enabled == false
	end
end)

Settings.LiftGate = Misc.AddToggle("Lift Gate", function(toggle)
	if toggle then
		repeat wait(0.5)
			Functions.LiftGate()
		until Settings.LiftGate.Enabled == false
	end
end)

Misc.AddButton("Erupt Volcano", function()
	if Local.Root then
		local Pos = workspace.LavaFun.Lavatouch.Position
		workspace.LavaFun.Lavatouch.Transparency = 1
		workspace.LavaFun.Lavatouch.Position = Local.Root.Position
		wait()
		workspace.LavaFun.Lavatouch.Position = Pos
		workspace.LavaFun.Lavatouch.Transparency = 0
	end
end)

Misc.AddLabel("Fun")

Settings.ClickDestroy = Misc.AddToggle("Click Destroy")

Settings.ClickNuke = Misc.AddToggle("Click Nuke")

Settings.ClickLightning = Misc.AddToggle("Click Lightning")

Misc.AddBox("Give Cash", true, function(val)
	Functions.GiveCash(val, "If Only It Was Real...")
end)

Misc.AddBox("Launch Fireworks", true, function(val)
	Functions.LaunchFireworks(val)
end)

Misc.AddBox("Send Notification", false, function(val)
	Notification.new({Text = val})
end)

local GuiSettings = Lib.AddTab("Settings")

GuiSettings.AddLabel("GUI Settings")

GuiSettings.AddDropdown("Credits", { "Kieran - Owner, Main Scripter", "Vynixu - Misc Epicness", "Alex9 - Gotta Be Winning Over Someone" })

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
Settings.JumpPower.Set(50)
Settings.FlySpeed.Set(16)
Settings.EngineSpeed.Set(1)
Settings.TurnSpeed.Set(1)
Settings.CarHeight.Set(1)
Settings.CarFlySpeed.Set(16)
Settings.VoltSpeed.Set(1)
Settings.BoatSpeed.Set(1)
Settings.HeliSpeed.Set(1)
Settings.PlaneSpeed.Set(1)
Settings.FuseTime.Set(GrenadeConfig.FuseTime)
Settings.ESPTextSize.Set(16)
Settings.ESPRange.Set(4096)

FOVCircle.Filled = false
FOVCircle.Position = MidScr
FOVCircle.Radius = 0
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)

Gun.SetupBulletEmitter(FakeEmitter)

for i, v in next, workspace.VehicleSpawns:GetChildren() do
	if not table.find(VehicleSpawns, v.Name) then
		VehicleSpawns[#VehicleSpawns + 1] = v.Name
	end
end

for i, v in next, ItemConfig:GetChildren() do
	local succ, res = pcall(require, v)
	if succ and type(res) == "table" then
		GunStatTable[v.Name] = {}
		for a, b in next, res do
			GunStatTable[v.Name][a] = b
		end
	end
end

for i, v in next, workspace:GetChildren() do
	if not Services.Players:GetPlayerFromCharacter(v) then
		WallbangIgnores[#WallbangIgnores + 1] = v
	end
end

for i, v in next, Specs do
	if v.Name == "Explode Wall" then
		Functions.ExplodeWall = function()
			v:Callback(true)
		end
	elseif v.Name == "Lift Gate" then
		Functions.LiftGate = function()
			v:Callback(true)
		end
	elseif v.Name == "Pull Open" then
		Sewers[#Sewers + 1] = function()
			v:Callback(true)
		end
	end
end

workspace.ChildAdded:Connect(function(child)
	if not Services.Players:GetPlayerFromCharacter(child) then
		WallbangIgnores[#WallbangIgnores + 1] = child
		if child.Name == "Drop" and Settings.ShowAirdrops.Enabled then
			Esp.AddItem("Airdrop", child:WaitForChild("Briefcase"), child.Briefcase.Color)
		end
	end
end)

workspace.ChildRemoved:Connect(function(child)
	local find = table.find(WallbangIgnores, child)
	if find then
		WallbangIgnores[find] = nil
	end
end)

Local.Player.PlayerGui.ChildAdded:Connect(function(child)
	if child.Name == "FlowGui" and Settings.AutoPuzzles.Enabled then
		CompletePuzzle()
	end
end)

Local.CellTime:GetPropertyChangedSignal("Visible"):Connect(function()
	if Settings.NoCellTime.Enabled and Local.CellTime.Visible then
		repeat Services.RunService.Heartbeat:Wait() until Local.Root
		local Door, Dist = nil, math.huge
		for i, v in next, Doors do
			local Mag = (v.ClosedCFrame.Position - Local.Root.Position).Magnitude
			if Mag < Dist then
				Dist = Mag
				Door = v
			end
		end
		for _ = 1, 200 do
			Functions.OpenDoor(Door)
			wait(0.1)
		end
	end
end)

Functions.HasItem = Inventory.hasItemName
Functions.Ragdoll = AlexRagdoll.Ragdoll
Functions.GetVehicle = Vehicle.GetLocalVehiclePacket
Functions.GrabGun = getproto(require(Services.ReplicatedStorage.Game.GunShop.GunShopUI).displayList, 1)

setupvalue(Functions.GrabGun, 1, Inventory)
setupvalue(Functions.GrabGun, 3, Event)
setupvalue(Functions.GrabGun, 4, GunShopSystem)

Services.ReplicatedStorage.StarterGui.FreeCamera:Clone().Parent = Local.Player.PlayerGui

for i, v in next, getgc() do
	if type(v) == "function" and islclosure(v) then
		local scr = tostring(getfenv(v).script)
		if scr == "LocalScript" then
			local consts = getconstants(v)
			if table.find(consts, "FailedPcall") then
				setupvalue(v, 1, function() end)
			elseif table.find(consts, "Punch") then
				Functions.Action = v
			elseif table.find(consts, "Firework") then
				Functions.LaunchFireworks = v
			elseif table.find(consts, "PlusCash") then
				Functions.GiveCash = v
			elseif table.find(consts, "SequenceRequireState") then
				Functions.OpenDoor = v
			elseif table.find(consts, "FireServer") and table.find(consts, "Locked") then
				Functions.LockVehicle = v
			elseif table.find(consts, "FireServer") and table.find(consts, "Play") and table.find(consts, "Source") then
				Functions.PlaySound = v
			elseif table.find(consts, "FireServer") and table.find(consts, "LastVehicleExit") and table.find(consts, "tick") then
				Functions.ExitVehicle = v
			elseif table.find(consts, "Nitro") and table.find(consts, "NitroForceUIUpdate") then
				Vehicles = getupvalue(v, 1)
			elseif table.find(consts, "Swing") and table.find(consts, "Slide") then
				Doors = getupvalue(v, 4)
			elseif table.find(consts, "Chassis") and table.find(consts, "UpdateHQ") then
				Heli = getupvalue(v, 3).Heli
				HeliUpdate = Heli.Update
			elseif table.find(consts, "You can't drive this. Hold to hijack it.") then
				Functions.HijackVehicle = getupvalue(v, 1)
				Functions.EnterVehicle = getupvalue(v, 3)
			elseif #consts == 3 and table.find(consts, "ShouldArrest") then
				Functions.Arrest = getupvalue(getupvalue(v, 1), 7)
				Functions.Pickpocket = getupvalue(getupvalue(v, 2), 2)
			elseif table.find(consts, "ShouldBreakout") and #getupvalues(v) >= 6 then
				Em = getupvalue(v, 6).em
			end
		elseif scr == "Inventory" then
			if table.find(getconstants(v), "GetLocalVehiclePacket") then
				Functions.UpdateInventory = v
			end
		elseif scr == "TeamChooseUI" then
			local consts = getconstants(v)
			if table.find(consts, "assert") and table.find(consts, "delay") then
				Functions.ChangeTeam = getproto(v, 6)
			end
		elseif scr == "NukeControl" then
			local consts = getconstants(v)
			if table.find(consts, "Nuke") and table.find(consts, "Shockwave") then
				Functions.Nuke = v
			end
		elseif scr == "SafesUI" then
			local consts = getconstants(v)
			if table.find(consts, "FireServer") and table.find(consts, "SelectedSafe") then
				Functions.OpenSafe = v
				SafeData = getupvalue(v, 1)
			elseif table.find(consts, "OpenSlider") and table.find(consts, "ContainerSkip") then
				Functions.SkipSlider = getproto(v, 2)
			end
		elseif scr == "FreeCamera" then
			local consts = getconstants(v)
			if table.find(consts, "Freecam") then
				if table.find(consts, "BindToRenderStep") then
					Functions.Freecam = v
				elseif table.find(consts, "UnbindFromRenderStep") then
					Functions.CloseFreecam = v
				end
			end
		end
	end
end

Vehicles.VehiclesOwned["Camaro"] = true
Vehicles.VehiclesOwned["Jeep"] = true
Vehicles.VehiclesOwned["Heli"] = true

Vehicles.VehiclesOwned.Volt = nil
Vehicles.VehiclesOwned.Patrol = nil

Local.Player.PlayerGui.FreeCamera:Destroy()

for i, v in next, Em do
	if type(v) == "function" then
		local consts = getconstants(v)
		if table.find(consts, "Stepped") then
			local old = Em[i]
			Em[i] = function(tab)
				old(tab)
				Services.RunService.Stepped:Connect(function()
					if Settings.NoMuseumDetection.Enabled then	
						for i2, v2 in next, tab do
							v2.LastDamage = tick()
						end
					end
				end)
			end
		elseif table.find(consts, "LocalMaxFuel") then
			JetPackTable = getupvalue(v, 1)
		end
	end
end

setupvalue(Functions.ChangeTeam, 1, Local.Player.Team == Services.Teams.Police and 1 or 2)
setupvalue(Functions.ChangeTeam, 2, Event)

setupvalue(Functions.SkipSlider, 1, Services.RunService.Heartbeat:Connect(function() end))
setupvalue(Functions.SkipSlider, 2, Event)
setupvalue(Functions.SkipSlider, 3, SafeData)

if Local.Player.Character then
	RegisterChar(Local.Player.Character)
end

Local.Player.CharacterAdded:Connect(RegisterChar)

for i, v in next, Services.Players:GetPlayers() do
    if v ~= Local.Player then
        RegisterEsp(v)
    end
end

Services.Players.PlayerAdded:Connect(function(plr)
	RegisterEsp(plr)
	TelePlayers.AddItem(plr.Name)
end)

Services.Players.PlayerRemoving:Connect(function(plr)
	TelePlayers.RemoveItem(plr.Name)
end)

Local.Mouse.Move:Connect(function()
	FOVCircle.Position = Services.UserInputService:GetMouseLocation()
end)

Local.Mouse.Button1Down:Connect(function()
	if Local.Mouse.Target then
		if Settings.ClickDestroy.Enabled then
			Local.Mouse.Target:Destroy()
		end
		if Settings.ClickNuke.Enabled then
			Functions.Nuke({
				Nuke = {
					Origin = Vector3.new(),
					Speed = 650,
					Duration = 10,
					Target = Local.Mouse.Hit.Position,
					TimeDilation = 1.5
				},
				Shockwave = {
					Duration = 20,
					MaxRadius = 100
				}
			})
		end
		if Settings.ClickLightning.Enabled then
			Lightning.StrikePosition(Local.Mouse.Hit.Position + Vector3.new(0, 250, 0), Local.Mouse.Hit.Position)
		end
	end
end)

AlexRagdoll.Ragdoll = newcclosure(function(...)
	if Settings.AntiRagdoll.Enabled then
		return wait(9e9)
	end
	return Functions.Ragdoll(...)
end)

AlexChassis.UpdatePrePhysics = newcclosure(function(self, ...)
	self.GarageEngineSpeed = Settings.EngineSpeed.Value == 1 and 1 or Settings.EngineSpeed.Value / 2
	self.TurnSpeed = (Settings.TurnSpeed.Value / 10) + 1
	self.Height = Settings.CarHeight.Value + 2
	if Settings.AntiPop.Enabled then
		self.TirePopDuration = 0
	end
	if Settings.AutoLock.Enabled and self.Locked == false then
		Functions.LockVehicle()
	end
	UpdatePrePhysics(self, ...)
end)

AlexChassis.VehicleEnter = newcclosure(function(...)
	VehicleEnter(...)
	if Settings.AutoPilot.Enabled then
		setupvalue(OnAction, 8, true)
	end
end)

AlexChassis.VehicleLeave = newcclosure(function(...)
	setupvalue(OnAction, 8, false)
	VehicleLeave(...)
end)

Boat.UpdatePhysics = newcclosure(function(self, ...)
	self.Config.SpeedForward = (Settings.BoatSpeed.Value / 4) + 1.5
	UpdatePhysics(self, ...)
end)

makewriteable(Meta)

Meta.__namecall = newcclosure(loadstring([[
	local a, b, c, d, e, f, g, h, i, j, k, l, m = ...
	return function(self, ...)
		if a() == b then
			local n = c()
			if (d.Enabled and e(n, f)) or (g.Enabled and e(n, h)) then
				local o, p, q, r = m(self, ...)
				return o, i(j, k, j), q, l
			end
		end
		return m(self, ...)
	end
]])(getnamecallmethod, "FindPartOnRay", traceback, Settings.BoatsOnLand, string.find, "Boat", Settings.JetSkiOnLand, "JetSki", Vector3.new, 0, math.huge, Enum.Material.Water, Namecall))

makereadonly(Meta)

Heli.Update = newcclosure(function(self, ...)
	if Settings.InstantPickup.Enabled and self.RopePickupPacket then
		self.RopePickupPacket.BornAt = 0
	end
	HeliUpdate(self, ...)
	local Velocity = self.Velocity.Velocity
	self.Velocity.Velocity = Velocity * ((Settings.HeliSpeed.Value / 40) + 0.9)
	self.MaxHeight = Settings.InfHeliHeight.Enabled and math.huge or 400
end)

Raycast.RayIgnoreNonCollide = newcclosure(function(...)
    if Settings.FloatOnWater.Enabled and string.find(traceback(), "AlexChassis") then
        local Args = {...}
        Args[6] = true
        return RayIgnoreNonCollide(unpack(Args))
    end
    return RayIgnoreNonCollide(...)
end)

Raycast.RayIgnoreNonCollideWithIgnoreList = newcclosure(function(a, b, c, d)
	if Settings.InfDroneHeight.Enabled and c == 500 and string.find(traceback(), "Heli") then
		return nil, a
	end
	return RayIgnoreNonCollideWithIgnoreList(a, b, c, d)
end)

Plane.FromPacket = newcclosure(function(...)
	local Return = FromPacket(...)
	PlaneData[#PlaneData + 1] = Return
	local Thrust = Return.CONST.MAX_THRUST
	Return.CONST.MAX_THRUST = Thrust * ((Settings.PlaneSpeed.Value / 20) + 0.9)
	if Settings.InfPlaneHeight.Enabled then
		Return.CONST.HEIGHT_MAX = math.huge
	end
	return Return
end)

Grenade.ShootBegin = newcclosure(function(self, ...)
	if Settings.NadeRapidFire.Enabled then
		self.ItemData.LastShoot = 0
	end
	ShootBegin(self, ...)
end)

Vehicle.GetLocalVehiclePacket = newcclosure(function()
	if Settings.DriveShoot.Enabled and string.find(traceback(), "Hotbar") then
		return nil
	end
	return Functions.GetVehicle()
end)

Hotbar.Select = newcclosure(function(...)
	local Old = CharacterUtil.IsCrawling
	if Settings.CrawlShoot.Enabled then
		CharacterUtil.IsCrawling = false
	end
	Select(...)
	CharacterUtil.IsCrawling = Old
end)

JetPack.IsFlying = newcclosure(function()
	if Settings.JetpackShoot.Enabled and string.find(traceback(), "Hotbar") then
		return false
	end
	return IsFlying()
end)

Emitter.Emit = newcclosure(function(self, pos, dir, ...)
	if self.Local then
		if Settings.Wallbang.Enabled then
			self.IgnoreList = WallbangIgnores
		end
		if Settings.SilentAim.Enabled then
			local Closest = GetClosest(self.IgnoreList)
			if Closest then
				dir = Closest
			end
		end
	end
	Emit(self, pos, dir, ...)
end)

PlasmaPistol.ShootOther = newcclosure(function(self)
	if self.Local then
		if Settings.Wallbang.Enabled then
			self.IgnoreList = WallbangIgnores
		end
		if Settings.SilentAim.Enabled then
			local Closest = GetClosest(self.IgnoreList, true)
			if Closest then
				self.MousePosition = Closest
			end
		end
	end
	ShootOther(self)
end)

for i, v in next, Local.Minimap:GetChildren() do
	v:GetPropertyChangedSignal("Visible"):Connect(function()
		if Settings.MapShow.Enabled then
			v.Visible = true
		end
	end)
end

Local.Minimap.ChildAdded:Connect(function(child)
	child:GetPropertyChangedSignal("Visible"):Connect(function()
		if Settings.MapShow.Enabled then
			child.Visible = true
		end
	end)
end)

Services.UserInputService.InputBegan:Connect(function(input, isrbx)
	if not isrbx then
		if Settings.InfJump.Enabled and input.KeyCode == Enum.KeyCode.Space and Local.Hum then
			Local.Hum:ChangeState("Jumping")
			wait(0.1)
			Local.Hum:ChangeState("Seated")
		elseif Settings.AutoDrift.Enabled and Functions.GetVehicle() then
			if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
				setupvalue(OnAction, 1, true)
			end
		end
	end
end)

Services.UserInputService.InputEnded:Connect(function(input, isrbx)
	if not isrbx and Settings.AutoDrift.Enabled and Functions.GetVehicle() then
		if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
			setupvalue(OnAction, 1, false)
		end
	end
end)
