--[[

    Changelog:

]]

--[[ ==========  Macros  ========== ]]

--local LPH_ENCSTR = function(...) return ... end

--[[ ==========  Settings  ========== ]]

local settings = {
    aimbot = {
        aimbot = {
            enabled = false,
            aimKey = "MouseButton2",
            ignoreAimKey = false,
            smoothness = 1,
            aimPart = "UpperTorso"
        },
        silentAim = {
            enabled = false,
            hitChance = 100,
            headshotChance = 0
        },
        fov = {
            enabled = false,
            radius = 100
        },
        autoFire = {
            triggerbot = false,
            autoShoot = false
        }
    },
    visuals = {
        bulletTracers = {
            enabled = false,
            colour = Color3.new(1, 0, 0)
        }
    },
    gunMods = {
        main = {
            noRecoil = false,
            noSpread = false
        },
        fireRate = {
            enabled = false,
            rate = 0
        },
        cosmetic = {
            customColour = false,
            colour = Color3.new(1, 0, 0),
            customMaterial = false,
            material = "ForceField"
        }
    },
    playerMods = {
        charMods = {
            flySpeed = 70
        }
    }
}

--[[ ==========  Variables  ========== ]]

local cache = loadstring(game:HttpGet("https://projectevo.xyz/script/utils/libraryv3.lua"))()
cache.esp = loadstring(game:HttpGet("https://projectevo.xyz/script/utils/espv3.lua"))()

local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

local network = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("NetworkModule2"))
local globalStuff = require(replicatedStorage.Modules:WaitForChild("GlobalStuff"))

local fovCircle = Drawing.new("Circle")
local beamTemplate, trajBeams = Instance.new("Beam"), {}
local connections = {}
local bulletTracers = {}
local gunMats = {}
local char, root, hum = nil, nil, nil
local target = nil
local isFlying, isAimKeyDown = false, false
local currentGun

local flyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

--[[ ==========  Custom Functions  ========== ]]

local function addConnection(name, conn)
    connections[name] = conn
end

local function stopConnection(name)
    if connections[name] then
        connections[name]:Disconnect()
        connections[name] = nil
    end
end

local function registerGunModel(model)
    currentGun = model
    if settings.gunMods.cosmetic.customColour then
        for i, v in next, currentGun:GetChildren() do
            v.Color = settings.gunMods.cosmetic.colour
        end
    end
    if settings.gunMods.cosmetic.customMaterial then
        for i, v in next, currentGun:GetChildren() do
            v.Material = Enum.Material[settings.gunMods.cosmetic.material]
        end
    end
    model.AncestryChanged:Wait()
    currentGun = nil
end

local function registerChar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    local weaponWeld = char:FindFirstChild("Head") and char.Head:FindFirstChild("WeaponWeld")
    if weaponWeld then
        coroutine.wrap(registerGunModel)(weaponWeld.Part1.Parent)
    end
    char:WaitForChild("Head").ChildAdded:Connect(function(child)
        task.wait()
        if child.Name == "WeaponWeld" then
            registerGunModel(child.Part1.Parent)
        end
    end)
    hum.Died:Connect(function()
        char, root, hum = nil, nil, nil
    end)
end

local function getTarget()
	local retPart, dist = nil, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
	for i, v in next, players:GetPlayers() do
		if v ~= player and not globalStuff:SameTeam(player, v) then
			local rootPart = v.Character and v.Character:FindFirstChild(settings.aimbot.aimbot.aimPart)
			if rootPart then
				local pos, vis = cam:WorldToScreenPoint(rootPart.Position)
				if vis and not workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, rootPart.Position - cam.CFrame.Position), { workspace.IgnoreThese, v.Character, char, cam }) then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
					if mag < dist then
						retPart, dist = rootPart, mag
					end
				end
			end
		end
	end
	return retPart
end

local function registerEsp(plr)
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        cache.esp:AddEsp(plr, plr.Character)
    end
    plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        cache.esp:AddEsp(plr, char)
    end)
end

local function registerController(controller)
    repeat task.wait() until controller.UpdateAmmoLabel
    local updateAmmoLabel = controller.UpdateAmmoLabel
    controller.UpdateAmmoLabel = newcclosure(function(...)
        updateAmmoLabel(...)
        if settings.gunMods.fireRate.enabled then
            getupvalue(updateAmmoLabel, 4).Debounce = 1 / (settings.gunMods.fireRate.rate / 60)
        end
    end)
end

local function registerShared(shared)
    repeat task.wait() until shared.Recoil
    local recoil = shared.Recoil
    shared.Recoil = newcclosure(function(...)
        if settings.gunMods.main.noRecoil then
            return
        end
        return recoil(...)
    end)
end

local function traceBullet(startPos, endPos)
	local part1 = Instance.new("Part", workspace.IgnoreThese)
	part1.Anchored = true
	part1.CanCollide = false
	part1.CFrame = CFrame.new(startPos)
	part1.Size = Vector3.new(0.1, 0.1, 0.1)
	part1.Transparency = 1
	
	local part2 = Instance.new("Part", workspace.IgnoreThese)
	part2.Anchored = true
	part2.CanCollide = false
	part2.CFrame = CFrame.new(endPos)
	part2.Size = Vector3.new(0.1, 0.1, 0.1)
	part2.Transparency = 1

	local attach1 = Instance.new("Attachment", part1)
	local attach2 = Instance.new("Attachment", part2)

	local beam = Instance.new("Beam", part1)
	beam.Attachment0 = attach1
	beam.Attachment1 = attach2
	beam.Color = ColorSequence.new(settings.visuals.bulletTracers.colour)
	beam.FaceCamera = false
	beam.LightEmission = 0
	beam.LightInfluence = 0
	beam.Transparency = NumberSequence.new(0.3)
	beam.Width0 = 0.15
	beam.Width1 = 0.15

    bulletTracers[beam] = true

	coroutine.wrap(function()
		task.wait(1.5)
		for i = 0.3, 1, 0.02 do
			task.wait(0.02)
			beam.Transparency = NumberSequence.new(i)
		end
		part1:Destroy()
		part2:Destroy()
        bulletTracers[beam] = nil
	end)()
end

local function registerGun(gun)
    local coneOfFire, shootLogic = gun.ConeOfFire, gun.ShootLogic
    if coneOfFire then -- Auto doesn't have it
        gun.ConeOfFire = newcclosure(function(...)
            local retVal = coneOfFire(...)
            if settings.aimbot.silentAim.enabled and target and math.random(1, 100) <= settings.aimbot.silentAim.hitChance then
                retVal = (math.random(1, 100) <= settings.aimbot.silentAim.headshotChance and target.Parent.Head or target).Position
            elseif settings.gunMods.main.noSpread then
                retVal = ({...})[3]
            end
            if settings.visuals.bulletTracers.enabled then
                traceBullet(({...})[2], retVal)
            end
            return retVal
        end)
    end
    getfenv(shootLogic).wait = function(...) -- newcclosure can't yield :/
        if settings.gunMods.fireRate.enabled then
            return task.wait(1 / (settings.gunMods.fireRate.rate / 60))
        end
        return getrenv().wait(...)
    end
end

--[[ ==========  Setup  ========== ]]

fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false
fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
fovCircle.Thickness = 1
fovCircle.Visible = false

beamTemplate.Color = ColorSequence.new(Color3.new(1, 0, 0))
beamTemplate.Transparency = NumberSequence.new(0)
beamTemplate.FaceCamera = true
beamTemplate.Segments = 50
beamTemplate.Width0 = 0.1
beamTemplate.Width1 = 0.1

if player.Character and player.Character:FindFirstChild("Humanoid") then
    registerChar(player.Character)
end

for i, v in next, Enum.Material:GetEnumItems() do
    gunMats[#gunMats + 1] = v.Name
end

table.sort(gunMats, function(a, b)
    return a < b
end)

cache.esp.IsEnemy = function(self, plr)
    return not globalStuff:SameTeam(player, plr)
end

cache.esp.GetHealth = function(self, model)
    if model:FindFirstChild("Humanoid") then
        return math.floor((model.Humanoid.Health / model.Humanoid.MaxHealth) * 100) / 100
    end
    return 0
end

for i, v in next, players:GetPlayers() do
    if v ~= player then
        registerEsp(v)
    end
end

if select(1, pcall(function() return player.PlayerGui.MainGui.NewLocal.Tools.Tool.Gun end)) then
    registerGun(require(player.PlayerGui.MainGui.NewLocal.Tools.Tool.Gun))
end

if select(1, pcall(function() return player.PlayerGui.MainGui.NewLocal.Tools.Tool.Gun.Auto end)) then
    registerGun(require(player.PlayerGui.MainGui.NewLocal.Tools.Tool.Gun.Auto))
end

if select(1, pcall(function() return player.PlayerGui.MainGui.NewLocal.Controller end)) then
    registerController(require(player.PlayerGui.MainGui.NewLocal.Controller))
end

if select(1, pcall(function() return player.PlayerGui.MainGui.NewLocal.Shared end)) then
    registerShared(require(player.PlayerGui.MainGui.NewLocal.Shared))
end

--[[ ==========  GUI  ========== ]]

local library = cache.library.new("Strucid")
local profile = library:AddProfile()

local aimbotTab = library:AddTab("Aimbot", "Aiming & Shooting Mods", "rbxassetid://7824873749")

local aimbot = aimbotTab:AddPanel("Aimbot", { info = "Aimbot - Automatically makes you look toward a viable target" })
aimbot:AddToggle("Enabled", function(state)
    settings.aimbot.aimbot.enabled = state
end, { flag = "aimbotenabled" })
aimbot:AddBind("Aim Key", nil, { default = "MouseButton2", set = function(bindName)
    settings.aimbot.aimbot.aimKey = bindName
    isAimKeyDown = false
end })
aimbot:AddToggle("Ignore Aim Key", function(state)
    settings.aimbot.aimbot.ignoreAimKey = state
end)
aimbot:AddDropdown("Aim Part", function(selected)
    settings.aimbot.aimbot.aimPart = selected
end, { items = { "UpperTorso", "LowerTorso", "Head" }, default = "UpperTorso" })
aimbot:AddSlider("Smoothness", function(value)
    settings.aimbot.aimbot.smoothness = value
end, { min = 1, max = 10, float = 0.1 })

local silentAim = aimbotTab:AddPanel("Silent Aim", { info = "Silent Aim - Redirects your bullets toward enemies" })
silentAim:AddToggle("Enabled", function(state)
    settings.aimbot.silentAim.enabled = state
end, { flag = "silentaimenabled" })
silentAim:AddSlider("Hit Chance", function(value)
    settings.aimbot.silentAim.hitChance = value
end, { default = 100 })
silentAim:AddSlider("Headshot Chance", function(value)
    settings.aimbot.silentAim.headshotChance = value
end)

local fov = aimbotTab:AddPanel("FOV", { info = "FOV - Decides the area in which you can target enemies" })
fov:AddToggle("Enabled", function(state)
    settings.aimbot.fov.enabled = state
end, { flag = "fovenabled" })
fov:AddToggle("Visible", function(state)
    fovCircle.Visible = state
end, { flag = "fovvisible" })
fov:AddSlider("Radius", function(value)
    settings.aimbot.fov.radius = value
    fovCircle.Radius = value
end, { max = 800, default = 100, flag = "fovradius" })

local autoFire = aimbotTab:AddPanel("Auto Firing", { info = "Auto Firing - This one's kinda self explanatory. Note: Auto Shoot requires Silent Aim to be enabled" })
autoFire:AddToggle("Triggerbot", function(state)
    settings.aimbot.autoFire.triggerbot = state
end)
autoFire:AddToggle("Auto Shoot", function(state)
    settings.aimbot.autoFire.autoShoot = state
end)

local visualsTab = library:AddTab("Visuals", "ESP, Hitbox Extender, etc", "rbxassetid://7825051458")

local esp = visualsTab:AddPanel("ESP", { info = "ESP - Allows you to see players and info about them from anywhere" })
esp:AddToggle("Show Names", function(state)
    cache.esp.settings.names = state
end)
esp:AddToggle("Show Boxes", function(state)
    cache.esp.settings.boxes = state
end)
esp:AddToggle("Show Distances", function(state)
    cache.esp.settings.distance = state
end)
esp:AddToggle("Show Health Percentages", function(state)
    cache.esp.settings.healthPercentage = state
end)
esp:AddToggle("Show Health Bars", function(state)
    cache.esp.settings.healthBar = state
end)
esp:AddToggle("Show Tracers", function(state)
    cache.esp.settings.tracers = state
end)
esp:AddToggle("Show Teammates", function(state)
    cache.esp.settings.showTeammates = state
end)
esp:AddSlider("Text Size", function(value)
    cache.esp:UpdateTextSize(value)
end, { min = 8, max = 32, default = 14 })

local tracers = visualsTab:AddPanel("Bullet Tracers", { info = "Bullet Tracers - highlights your bullet paths" })
tracers:AddToggle("Enabled", function(state)
    settings.visuals.bulletTracers.enabled = state
end, { flag = "bullettracersenabled" })
tracers:AddPicker("Trace Colour", function(colour)
    settings.visuals.bulletTracers.colour = colour
    for i, v in next, bulletTracers do
        i.Color = ColorSequence.new(colour)
    end
end, { default = table.pack(Color3.new(1, 0, 0):ToHSV()) })

local gunModsTab = library:AddTab("Gun Mods", "Cosmetic & Performance Changes", "rbxassetid://7825568616")

local gunsMain = gunModsTab:AddPanel("Main", { info = "Gun Mods - Modify several aspects of your gun's performance" })
gunsMain:AddToggle("No Recoil", function(state)
    settings.gunMods.main.noRecoil = state
end)
gunsMain:AddToggle("No Spread", function(state)
    settings.gunMods.main.noSpread = state
end)

local gunFireRate = gunModsTab:AddPanel("Fire Rate", { info = "Fire Rate - Adjusts how fast your gun fires" })
gunFireRate:AddToggle("Enabled", function(state)
    settings.gunMods.fireRate.enabled = state
end, { flag = "firerateenabled" })
gunFireRate:AddSlider("Fire Rate", function(value)
    settings.gunMods.fireRate.rate = value
end, { min = 0, max = 2500 })

local gunCosmetics = gunModsTab:AddPanel("Cosmetics", { info = "Cosmetics - Adjust how your gun looks" })
gunCosmetics:AddToggle("Custom Gun Colour", function(state)
    settings.gunMods.cosmetic.customColour = state
    if state and currentGun then
        for i, v in next, currentGun:GetChildren() do
            v.Color = settings.gunMods.cosmetic.colour
        end
    end
end)
gunCosmetics:AddPicker("Gun Colour", function(colour)
    settings.gunMods.cosmetic.colour = colour
    if settings.gunMods.cosmetic.customColour and currentGun then
        for i, v in next, currentGun:GetChildren() do
            v.Color = colour
        end
    end
end, { default = table.pack(Color3.new(1, 0, 0):ToHSV()) })
gunCosmetics:AddToggle("Custom Material", function(state)
    settings.gunMods.cosmetic.customMaterial = state
    if currentGun then
        local mat = state and Enum.Material[settings.gunMods.cosmetic.material] or Enum.Material.SmoothPlastic
        for i, v in next, currentGun:GetChildren() do
            v.Material = mat
        end
    end
end)
gunCosmetics:AddDropdown("Material", function(selected)
    settings.gunMods.cosmetic.material = selected
    if settings.gunMods.cosmetic.customMaterial and currentGun then
        for i, v in next, currentGun:GetChildren() do
            v.Material = Enum.Material[selected]
        end
    end
end, { items = gunMats, default = "ForceField" })

local playerTab = library:AddTab("Player", "Player & Character Mods", "rbxassetid://7826527270")

local charMods = playerTab:AddPanel("Character")
charMods:AddBind("Fly", function(bindName)
    stopConnection("fly")
	isFlying = not isFlying
	if isFlying then
		addConnection("fly", runService.RenderStepped:Connect(function(frameDelay)
			if root then
				local flyVec = Vector3.new()
                if flyKeys.W then
                    flyVec = flyVec + cam.CFrame.LookVector
                end
                if flyKeys.A then
                    flyVec = flyVec - cam.CFrame.RightVector
                end
                if flyKeys.S then
                    flyVec = flyVec - cam.CFrame.LookVector
                end
                if flyKeys.D then
                    flyVec = flyVec + cam.CFrame.RightVector
                end
                flyVec = Vector3.new(flyVec.X, 0.005, flyVec.Z)
                if flyKeys.Space then
                    flyVec = flyVec + Vector3.new(0, 1, 0)
                end
                if flyKeys.LeftShift then
                    flyVec = flyVec + Vector3.new(0, -1, 0)
                end
                root.Velocity = (flyVec.Magnitude < 1 and flyVec or flyVec.Unit) * settings.playerMods.charMods.flySpeed
			end
		end))
	end
end)
charMods:AddSlider("Fly Speed", function(value)
    settings.playerMods.charMods.flySpeed = value
end, { min = 16, max = 70, default = 70 })

library:AddSettings()

--[[ ==========  Hooks  ========== ]]



--[[ ==========  Connections  ========== ]]

player.CharacterAdded:Connect(registerChar)
players.PlayerAdded:Connect(registerEsp)

mouse.Move:Connect(function()
    fovCircle.Position = userInputService:GetMouseLocation()
end)

player.PlayerGui.DescendantAdded:Connect(function(desc)
    if desc.ClassName == "ModuleScript" then
        if desc.Name == "Gun" or desc.Name == "Auto" then
            registerGun(require(desc))
        elseif desc.Name == "Controller" then
            registerController(require(desc))
        elseif desc.Name == "Shared" then
            registerShared(require(desc))
        end
    end
end)

userInputService.InputBegan:Connect(function(input, isRbx)
    if not isRbx then
        if input.UserInputType.Name == settings.aimbot.aimbot.aimKey or input.KeyCode.Name == settings.aimbot.aimbot.aimKey then
            isAimKeyDown = true
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isAimKeyDown = false
                    conn:Disconnect()
                end
            end)
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and flyKeys[input.KeyCode.Name] ~= nil then
            flyKeys[input.KeyCode.Name] = true
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    flyKeys[input.KeyCode.Name] = false
                    conn:Disconnect()
                end
            end)
        end
    end
end)

runService.Heartbeat:Connect(function()
    if root then
        target = getTarget()
        if target then
            if settings.aimbot.aimbot.enabled and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey) then
                local pos = cam:WorldToScreenPoint(target.Position)
                local moveVec = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)) / (settings.aimbot.aimbot.smoothness + 0.5)
                mousemoverel(moveVec.X, moveVec.Y)
            end
            if settings.aimbot.silentAim.enabled and settings.aimbot.autoFire.autoShoot then
                mouse1click()
            elseif settings.aimbot.autoFire.triggerbot then
                local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { workspace.IgnoreThese, char, cam }, true)
                if part and players:FindFirstChild(part.Parent.Name) and not globalStuff:SameTeam(player, players[part.Parent.Name]) then
					mouse1click()
				end
            end
        end
    end
end)