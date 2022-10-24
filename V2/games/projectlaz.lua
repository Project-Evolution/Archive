--[[

    Changelog:

]]

--[[ ==========  Macros  ========== ]]

local LPH_ENCSTR = function(...) return ... end

--[[ ==========  Settings  ========== ]]

local settings = {
    aimbot = {
        aimbot = {
            enabled = false,
            aimKey = "MouseButton2",
            ignoreAimKey = false,
            wallCheck = false,
            smoothness = 1,
            aimPart = "Torso"
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
            autoShoot = false,
            autoWall = false
        },
        autoKill = {
            loopKill = false,
            range = 25
        }
    },
    visuals = {
        xRay = {
            enabled = false,
            transparency = 0.75
        },
        impactPoints = {
            enabled = false,
            colour = Color3.new(1, 0, 0)
        },
        guiMods = {
            fullBright = false
        }
    },
    gunMods = {
        main = {
            wallbang = false,
            infAmmo = false,
            fullAuto = false,
            oneShotKill = false,
            alwaysHeadshot = false,
            noRecoil = false,
            noSpread = false,
            noAimSlow = false,
            instantReload = false,
            instantAim = false,
            instantEquip = false
        },
        fireRate = {
            enabled = false,
            rate = 0
        },
        automation = {
            autoPap = false
        }
    },
    playerMods = {
        perks = {
            quickRevive = false,
            doubleTap = false,
            juggernog = false,
            speedCola = false,
            muleKick = false
        }
    },
    mapMods = {
        main = {
            autoRebuild = false
        }
    }
}

--[[ ==========  Variables  ========== ]]

local cache = loadstring(game:HttpGet("https://projectevo.xyz/script/utils/libraryv3.lua"))()
cache.esp = loadstring(game:HttpGet("https://projectevo.xyz/script/utils/espv3.lua"))()
cache.misc = cache.system.new("Miscellaneous")

local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

local papModule = require(replicatedStorage:WaitForChild("PaPWeaponsModule"))
local points = player:WaitForChild("leaderstats"):WaitForChild("Points")

local fovCircle = Drawing.new("Circle")
local gunTables, gunData = {}, {}
local connections = {}
local char, root, hum = nil, nil, nil
local target = nil
local isAimKeyDown = false

local oldLighting, brightLighting = {
    Brightness = lighting.Brightness,
    GlobalShadows = lighting.GlobalShadows,
    Ambient = lighting.Ambient
}, {
   Brightness = 10,
   GlobalShadows = false,
   Ambient = Color3.new(1, 1, 1) 
}

--[[ ==========  Anticheat  ========== ]]

hookfunction(getrenv().gcinfo, function() return math.random(1000, 2000) end)

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

local function registerWeaponScript(weaponScript)
    while true do
        local succ, res = pcall(function()
            return getsenv(weaponScript)
        end)
        if succ and type(res) == "table" and rawget(res, "Knife") then
            weaponEnv = res
            break
        end
        task.wait()
    end
    weaponScript.AncestryChanged:Wait()
    weaponEnv = nil
end

local function registerGun(moduleScript)
    local gunModule = require(moduleScript)
    if not gunData[gunModule.WeaponName] then
        gunData[gunModule.WeaponName] = {}
        cache.misc:DeepCopy(gunModule, gunData[gunModule.WeaponName], true)
    end
    gunModule.FireTime = settings.gunMods.fireRate.enabled and 1 / (settings.gunMods.fireRate.rate / 60) or gunModule.FireTime
    gunModule.Semi = not settings.gunMods.main.fullAuto and gunModule.Semi or false
    gunModule.SingleAction = not settings.gunMods.main.fullAuto and gunModule.SingleAction or false
    gunModule.Burst = not settings.gunMods.main.fullAuto and gunModule.Burst or false
    gunModule.MagSize = settings.gunMods.main.infAmmo and math.huge or gunModule.MagSize
    gunModule.MaxAmmo = settings.gunMods.main.infAmmo and math.huge or gunModule.MaxAmmo
    gunModule.StoredAmmo = settings.gunMods.main.infAmmo and math.huge or gunModule.StoredAmmo
    gunModule.Damage.Min = settings.gunMods.main.oneShotKill and math.huge or gunModule.Damage.Min
    gunModule.Damage.Max = settings.gunMods.main.oneShotKill and math.huge or gunModule.Damage.Max
    gunModule.GunKick = settings.gunMods.main.noRecoil and 0 or gunModule.GunKick
    gunModule.ViewKick.Pitch.Min = settings.gunMods.main.noRecoil and 0 or gunModule.ViewKick.Pitch.Min
    gunModule.ViewKick.Pitch.Max = settings.gunMods.main.noRecoil and 0 or gunModule.ViewKick.Pitch.Max
    gunModule.ViewKick.Yaw.Min = settings.gunMods.main.noRecoil and 0 or gunModule.ViewKick.Yaw.Min
    gunModule.ViewKick.Yaw.Max = settings.gunMods.main.noRecoil and 0 or gunModule.ViewKick.Yaw.Max
    gunModule.Spread.Min = settings.gunMods.main.noSpread and 0 or gunModule.Spread.Min
    gunModule.Spread.Max = settings.gunMods.main.noSpread and 0 or gunModule.Spread.Max
    gunModule.AimMoveSpeed = settings.gunMods.main.noAimSlow and gunModule.MoveSpeed or gunModule.AimMoveSpeed
	if gunModule.ReloadSequence then
		for i, v in next, gunModule.ReloadSequence do
			gunModule.ReloadSequence[i] = settings.gunMods.main.instantReload and function() end or gunModule.ReloadSequence[i]
		end
	end
    gunModule.AimTime = settings.gunMods.main.instantAim and 0.01 or gunModule.AimTime
    gunModule.RaiseSpeed = settings.gunMods.main.instantEquip and 0.01 or gunModule.RaiseSpeed
    gunTables[moduleScript.Name] = gunModule
end

local function registerChar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        char, root, hum = nil, nil, nil
    end)
    if char:FindFirstChild("WeaponScript") then
        coroutine.wrap(registerWeaponScript)(char.WeaponScript)
    end
    char.ChildAdded:Connect(function(child)
        if child.Name == "WeaponScript" then
            registerWeaponScript(child)
        end
    end)
end

local function getTarget()
	local retPart, dist = nil, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
	for i, v in next, workspace.Baddies:GetChildren() do
		local rootPart = v:FindFirstChild(settings.aimbot.aimbot.aimPart)
		if rootPart then
            local rootPos = rootPart.Position
			local pos, vis = cam:WorldToScreenPoint(rootPos)
			if vis then
				local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
				if mag < dist then
					retPart, dist = rootPart, mag
				end
			end
		end
	end
	return retPart
end

local function kill(zombie)
    local gunId = getupvalue(weaponEnv.Knife, 19)
    if gunId then
        zombie.Humanoid.Damage:FireServer({
            Damage = zombie.Humanoid.Health,
            BodyPart = zombie.HeadBox,
            GibPower = 0,
            Force = 0,
            Source = zombie.HeadBox.Position
        }, gunId)
    end
end

local function killAll()
    for i, v in next, workspace.Baddies:GetChildren() do
        pcall(kill, v)
    end
end

local function packAPunch()
    local machine = workspace.Interact:FindFirstChild("Pack-a-Punch")
    if machine and machine:FindFirstChild("Enabled") and machine.Enabled.Value then
        local activate = machine:FindFirstChild("Activate")
        if activate then
            local conn
            conn = activate:GetPropertyChangedSignal("Name"):Connect(function()
                if activate.Name == "Activate" then
                    conn:Disconnect()
                    activate:FireServer()
                end
            end)
            activate:FireServer()
        end
    end
end

local function spinBox()
    local box = workspace.Interact:FindFirstChild("MysteryBox")
    if box then
        local activate = box:FindFirstChild("Activate")
        if activate then
            local conn
            conn = activate:GetPropertyChangedSignal("Name"):Connect(function()
                if activate.Name == "Activate" then
                    conn:Disconnect()
                    activate:FireServer()
                end
            end)
            activate:FireServer()
        end
    end
end

--[[ ==========  Setup  ========== ]]

fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false
fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
fovCircle.Thickness = 1
fovCircle.Visible = false

if player.Character and player.Character:FindFirstChild("Humanoid") then
    registerChar(player.Character)
end

cache.esp.GetHealth = function(self, model)
    if model:FindFirstChild("Humanoid") then
        return math.floor((model.Humanoid.Health / model.Humanoid.MaxHealth) * 100) / 100
    end
    return 0
end

cache.esp.IsEnemy = function(self, plr)
    return true
end

cache.esp.SetupTeamChange = function(self, plr, container)
    self:UpdateTeamColour(container, Color3.new(1, 1, 1))
end

for i, v in next, workspace.Baddies:GetChildren() do
    cache.esp:AddEsp({ Name = "Zombie" }, v)
end

for i, v in next, player.Backpack:GetChildren() do
    if v.Name:sub(1, 6) == "Weapon" then
        registerGun(v)
    end
end

--[[ ==========  GUI  ========== ]]

local library = cache.library.new("Project Lazarus")
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
aimbot:AddToggle("Wall Check", function(state)
    settings.aimbot.aimbot.wallCheck = state
end)
aimbot:AddDropdown("Aim Part", function(selected)
    settings.aimbot.aimbot.aimPart = selected
end, { items = { "Torso", "Head" }, default = "Torso" })
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

local autoFire = aimbotTab:AddPanel("Auto Firing", { info = "Auto Firing - This one's kinda self explanatory. Note: Auto Shoot and Auto Wallbang require Silent Aim to be enabled" })
autoFire:AddToggle("Triggerbot", function(state)
    settings.aimbot.autoFire.triggerbot = state
end)
autoFire:AddToggle("Auto Shoot", function(state)
    settings.aimbot.autoFire.autoShoot = state
end)
autoFire:AddToggle("Auto Wallbang", function(state)
    settings.aimbot.autoFire.autoWall = state
end)

local autoKill = aimbotTab:AddPanel("Auto Kill", { info = "Auto Kill - Pretty self explanatory" })
autoKill:AddToggle("Loop Kill All", function(state)
    settings.aimbot.autoKill.loopKill = state
    if state and root and weaponEnv then
        killAll()
    end
end)
autoKill:AddButton("Kill All", function()
    if root and weaponEnv then
        killAll()
    end
end)
autoKill:AddToggle("Kill Aura", function(state)
    stopConnection("killAura")
    if state then
        addConnection("killAura", runService.Heartbeat:Connect(function()
            if root and weaponEnv then
                for i, v in next, workspace.Baddies:GetChildren() do
                    if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - root.Position).Magnitude <= settings.aimbot.autoKill.range then
                        pcall(kill, v)
                    end
                end
            end
        end))
    end
end)
autoKill:AddSlider("Range", function(value)
    settings.aimbot.autoKill.range = value
end,  { max = 50, default = 25, float = 0.1, flag = "killaurarange" })

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
esp:AddSlider("Text Size", function(value)
    cache.esp:UpdateTextSize(value)
end, { min = 8, max = 32, default = 14 })

local guiMods = visualsTab:AddPanel("GUI")
guiMods:AddToggle("Fullbright", function(state)
    settings.visuals.guiMods.fullBright = state
    lighting.Brightness = state and brightLighting.Brightness or oldLighting.Brightness
    lighting.GlobalShadows = state and brightLighting.GlobalShadows or oldLighting.GlobalShadows
    lighting.Ambient = state and brightLighting.Ambient or oldLighting.Ambient
end)

local gunModsTab = library:AddTab("Gun Mods", "Cosmetic & Performance Changes", "rbxassetid://7825568616")

local gunsMain = gunModsTab:AddPanel("Main", { info = "Gun Mods - Modify several aspects of your gun's performance. Note: Wallbang only works close up, cross-map hits won't register" })
gunsMain:AddToggle("Wallbang", function(state)
    settings.gunMods.main.wallbang = state
end)
gunsMain:AddToggle("Infinite Ammo", function(state)
    settings.gunMods.main.infAmmo = state
    if getrenv()._G.Equipped then
        getrenv()._G.Equipped.Ammo = state and math.huge or 0
    end
    for i, v in next, gunTables do
        v.MaxAmmo = state and math.huge or gunData[v.WeaponName].MaxAmmo
        v.StoredAmmo = state and math.huge or gunData[v.WeaponName].StoredAmmo
        v.MagSize = state and math.huge or gunData[v.WeaponName].MagSize
    end
end)
gunsMain:AddToggle("Full Automatic", function(state)
    settings.gunMods.main.fullAuto = state
    for i, v in next, gunTables do
        v.Semi = not state and gunData[v.WeaponName].Semi or false
        v.SingleAction = not state and gunData[v.WeaponName].SingleAction or false
        v.Burst = not state and gunData[v.WeaponName].Burst or false
    end
end)
gunsMain:AddToggle("One Shot Kill", function(state)
    settings.gunMods.main.oneShotKill = state
    for i, v in next, gunTables do
        v.Damage.Min = state and math.huge or gunData[v.WeaponName].Damage.Min
        v.Damage.Max = state and math.huge or gunData[v.WeaponName].Damage.Max
    end
end)
gunsMain:AddToggle("Always Headshot", function(state)
    settings.gunMods.main.alwaysHeadshot = state
end)
gunsMain:AddToggle("No Recoil", function(state)
    settings.gunMods.main.noRecoil = state
    for i, v in next, gunTables do
        v.GunKick = state and 0 or gunData[v.WeaponName].GunKick
        v.ViewKick.Pitch.Min = state and 0 or gunData[v.WeaponName].ViewKick.Pitch.Min
        v.ViewKick.Pitch.Max = state and 0 or gunData[v.WeaponName].ViewKick.Pitch.Max
        v.ViewKick.Yaw.Min = state and 0 or gunData[v.WeaponName].ViewKick.Yaw.Min
        v.ViewKick.Yaw.Max = state and 0 or gunData[v.WeaponName].ViewKick.Yaw.Max
    end
end)
gunsMain:AddToggle("No Spread", function(state)
    settings.gunMods.main.noSpread = state
    for i, v in next, gunTables do
        v.Spread.Min = state and 0 or gunData[v.WeaponName].Spread.Min
        v.Spread.Max = state and 0 or gunData[v.WeaponName].Spread.Max
    end
end)
gunsMain:AddToggle("No Aim Slow", function(state)
    settings.gunMods.main.noAimSlow = state
    for i, v in next, gunTables do
        v.AimMoveSpeed = state and gunData[v.WeaponName].MoveSpeed or gunData[v.WeaponName].AimMoveSpeed
    end
end)
gunsMain:AddToggle("Instant Reload", function(state)
    settings.gunMods.main.instantReload = state
    for _, v in next, gunTables do
        if rawget(v, "ReloadSequence") then
			for i, __ in next, v.ReloadSequence do
				v.ReloadSequence[i] = state and function() end or gunData[v.WeaponName].ReloadSequence[i]
			end
		end
    end
end)
gunsMain:AddToggle("Instant Aim", function(state)
    settings.gunMods.main.instantAim = state
    for i, v in next, gunTables do
        v.AimTime = state and 0.01 or gunData[v.WeaponName].AimTime
    end
end)
gunsMain:AddToggle("Instant Equip", function(state)
    settings.gunMods.main.instantEquip = state
    for i, v in next, gunTables do
        v.RaiseSpeed = state and 0.01 or gunData[v.WeaponName].RaiseSpeed
    end
end)

local gunFireRate = gunModsTab:AddPanel("Fire Rate", { info = "Fire Rate - Adjusts how fast your gun fires" })
gunFireRate:AddToggle("Enabled", function(state)
    settings.gunMods.fireRate.enabled = state
    for i, v in next, gunTables do
        v.FireTime = state and 1 / (settings.gunMods.fireRate.rate / 60) or gunData[v.WeaponName].FireTime
    end
end, { flag = "firerateenabled" })
gunFireRate:AddSlider("Fire Rate", function(value)
    settings.gunMods.fireRate.rate = value
    for i, v in next, gunTables do
        v.FireTime = settings.gunMods.fireRate.enabled and 1 / (value / 60) or gunData[v.WeaponName].FireTime
    end
end, { min = 0, max = 2500 })

local gunAutomation = gunModsTab:AddPanel("Automation", { info = "Automation - Things you can do automatically without being where you need to be" })
gunAutomation:AddToggle("Auto Pack-a-Punch", function(state)
    settings.gunMods.automation.autoPap = state
    if state and papModule:GetPaPName(getrenv()._G.Equipped and getrenv()._G.Equipped.WeaponName or "") and points.Value >= 5000 then
        packAPunch()
    end
end)
gunAutomation:AddBind("Spin Mystery Box", spinBox)

local playerTab = library:AddTab("Player", "Player & Character Mods", "rbxassetid://7826527270")

local perks = playerTab:AddPanel("Auto Perks", { info = "Auto Perks - Auto buys the selected perks when you have enough money" })
perks:AddToggle("Quick Revive", function(state)
    settings.aimbot.autoFire.quickRevive = state
    if state and weaponEnv and points.Value >= workspace.Interact["Quick Revive"].Cost.Value and workspace.Interact["Quick Revive"]:FindFirstChild("Activate") then
        workspace.Interact["Quick Revive"].Activate:FireServer()
    end
end)
perks:AddToggle("Double Tap", function(state)
    settings.aimbot.autoFire.doubleTap = state
    if state and weaponEnv and points.Value >= workspace.Interact["Double Tap Root Beer"].Cost.Value and workspace.Interact["Double Tap Root Beer"]:FindFirstChild("Activate") then
        workspace.Interact["Double Tap Root Beer"].Activate:FireServer()
    end
end)
perks:AddToggle("Juggernog", function(state)
    settings.aimbot.autoFire.juggernog = state
    if state and weaponEnv and points.Value >= workspace.Interact["Juggernog"].Cost.Value and workspace.Interact["Juggernog"]:FindFirstChild("Activate") then
        workspace.Interact["Juggernog"].Activate:FireServer()
    end
end)
perks:AddToggle("Speed Cola", function(state)
    settings.aimbot.autoFire.speedCola = state
    if state and weaponEnv and points.Value >= workspace.Interact["Speed Cola"].Cost.Value and workspace.Interact["Speed Cola"]:FindFirstChild("Activate") then
        workspace.Interact["Speed Cola"].Activate:FireServer()
    end
end)
perks:AddToggle("Mule Kick", function(state)
    settings.aimbot.autoFire.muleKick = state
    if state and weaponEnv and points.Value >= workspace.Interact["Mule Kick"].Cost.Value and workspace.Interact["Mule Kick"]:FindFirstChild("Activate") then
        workspace.Interact["Mule Kick"].Activate:FireServer()
    end
end)

local mapTab = library:AddTab("Map", "Automated Map Tasks", "rbxassetid://7834826106")

local map = mapTab:AddPanel("Main", { info = "Map Main - Automates certain map tasks" })
map:AddButton("Turn On The Power", function()
    if workspace.Interact:FindFirstChild("PowerSwitch") and workspace.Interact.PowerSwitch:FindFirstChild("Activate") then
        workspace.Interact.PowerSwitch.Activate:FireServer()
    end
end)
map:AddButton("Unlock Pack-a-Punch", function()
    if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MapName") then
        if workspace.Interact:FindFirstChild("PowerSwitch") then
            workspace.Interact.PowerSwitch.Activate:FireServer()
        end
        local Map = workspace.Map.MapName.Value
        if Map == "Graduation" then
            if workspace.Interact:FindFirstChild("Key") and workspace.Interact.Key:FindFirstChild("Activate") then
                workspace.Interact.Key.Activate:FireServer()
                workspace.Interact:WaitForChild("StorageDoor"):WaitForChild("Activate")
            end
            if workspace.Interact:FindFirstChild("StorageDoor") and workspace.Interact.StorageDoor:FindFirstChild("Activate") then
                workspace.Interact.StorageDoor.Activate:FireServer()
                workspace.Interact:WaitForChild("PaPJar"):WaitForChild("Activate")
            end
            if workspace.Interact:FindFirstChild("PaPJar") and workspace.Interact.PaPJar:FindFirstChild("Activate") then
                workspace.Interact.PaPJar.Activate:FireServer()
            end
        elseif Map == "Research" then
            for i, v in next, workspace.Interact:GetChildren() do
                if v.Name == "Controls" and v:FindFirstChild("Activate") then
                    v.Activate:FireServer()
                end
            end
        end
    end
end)
map:AddButton("Complete Music Easter Egg", function()
    for i, v in next, workspace.Interact:GetChildren() do
        if v.Name == "MusicEasterEgg" and v:FindFirstChild("Activate") then
            v.Activate:FireServer()
        end
    end
end)
map:AddToggle("Auto Rebuild Barriers", function(state)
    settings.mapMods.main.autoRebuild = state
    if state then
        repeat task.wait(1)
            if root and weaponEnv then
                for i, v in next, workspace.Interact:GetChildren() do
                    if v.Name == "Barricade" and (root.Position - v.PrimaryPart.Position).Magnitude < 10 then
                        v.Activate:FireServer()
                    end
                end
            end
        until not settings.mapMods.main.autoRebuild
    end
end)

library:AddSettings()

--[[ ==========  Hooks  ========== ]]

local metaNamecall
metaNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" then
            local args = {...}
            if tostring(self) == "SendData" then -- anticheat yes
                return
            elseif tostring(self) == "Damage" and settings.gunMods.main.alwaysHeadshot and not args[1].Knifed then
                args[1].BodyPart = args[1].BodyPart.Parent.HeadBox
                args[1].Damage = getrenv()._G.Equipped.Damage.Max * (getrenv()._G.Equipped.HeadShot or 1)
                return metaNamecall(self, unpack(args))
            end
        elseif method == "FindPartOnRayWithIgnoreList" and weaponEnv then
            local args = {...}
            if settings.aimbot.silentAim.enabled and target and math.random(1, 100) <= settings.aimbot.silentAim.hitChance then
                args[1] = Ray.new(args[1].Origin, (math.random(1, 100) <= settings.aimbot.silentAim.headshotChance and target.Parent.Head or target).Position - args[1].Origin)
                args[2][#args[2] + 1] = workspace.Map
                args[2][#args[2] + 1] = workspace.Interact
            elseif settings.gunMods.main.wallbang then
                args[2][#args[2] + 1] = workspace.Map
                args[2][#args[2] + 1] = workspace.Interact
            end
            return metaNamecall(self, unpack(args))
        end
    end
    return metaNamecall(self, ...)
end)

--[[ ==========  Connections  ========== ]]

player.CharacterAdded:Connect(registerChar)

mouse.Move:Connect(function()
    fovCircle.Position = userInputService:GetMouseLocation()
end)

player.Backpack.ChildAdded:Connect(function(child)
    if child.Name:sub(1, 6) == "Weapon" then
        registerGun(child)
    end
end)

workspace.Baddies.ChildAdded:Connect(function(child)
    child:WaitForChild("HumanoidRootPart")
    cache.esp:AddEsp({ Name = "Zombie" }, child)
    if settings.aimbot.autoKill.loopKill then
        child:WaitForChild("Humanoid"):WaitForChild("Damage")
        pcall(kill, child)
    end
end)

points:GetPropertyChangedSignal("Value"):Connect(function()
    if settings.playerMods.perks.quickRevive and points.Value >= workspace.Interact["Quick Revive"].Cost.Value and workspace.Interact["Quick Revive"]:FindFirstChild("Activate") then
        workspace.Interact["Quick Revive"].Activate:FireServer()
    end
    if settings.playerMods.perks.doubleTap and points.Value >= workspace.Interact["Double Tap Root Beer"].Cost.Value and workspace.Interact["Double Tap Root Beer"]:FindFirstChild("Activate") then
        workspace.Interact["Double Tap Root Beer"].Activate:FireServer()
    end
    if settings.playerMods.perks.juggernog and points.Value >= workspace.Interact["Juggernog"].Cost.Value and workspace.Interact["Juggernog"]:FindFirstChild("Activate") then
        workspace.Interact["Juggernog"].Activate:FireServer()
    end
    if settings.playerMods.perks.speedCola and points.Value >= workspace.Interact["Speed Cola"].Cost.Value and workspace.Interact["Speed Cola"]:FindFirstChild("Activate") then
        workspace.Interact["Speed Cola"].Activate:FireServer()
    end
    if settings.playerMods.perks.multKick and points.Value >= workspace.Interact["Mule Kick"].Cost.Value and workspace.Interact["Mule Kick"]:FindFirstChild("Activate") then
        workspace.Interact["Mule Kick"].Activate:FireServer()
    end
    if settings.gunMods.automation.autoPap and papModule:GetPaPName(getrenv()._G.Equipped and getrenv()._G.Equipped.WeaponName or "") and points.Value >= 5000 then
        packAPunch()
    end
end)

lighting.Changed:Connect(function(property)
    if property == "Brightness" or property == "Ambient" or property == "GlobalShadows" then
        if lighting[property] ~= brightLighting[property] then
            oldLighting[property] = lighting[property]
            if settings.visuals.guiMods.fullBright then
                lighting.Brightness = 10
                lighting.Ambient = Color3.new(1, 1, 1)
                lighting.GlobalShadows = false
            end
        end
    end
end)

userInputService.InputBegan:Connect(function(input, isrbx)
    if not isrbx and (input.UserInputType.Name == settings.aimbot.aimbot.aimKey or input.KeyCode.Name == settings.aimbot.aimbot.aimKey) then
        isAimKeyDown = true
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isAimKeyDown = false
                conn:Disconnect()
            end
        end)
    end
end)

runService.Heartbeat:Connect(function()
    if root then
        target = getTarget()
        if target then
            local isVisible = #cam:GetPartsObscuringTarget({ target.Position }, { workspace.Baddies, workspace.Ignore, workspace.Interact, cam, char }) == 0
            if settings.aimbot.aimbot.enabled and (isVisible or not settings.aimbot.aimbot.wallCheck) and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey) then
                cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + cam.CFrame.LookVector + (((target.Position - cam.CFrame.Position).Unit - cam.CFrame.LookVector) / settings.aimbot.aimbot.smoothness))
            end
            if settings.aimbot.silentAim.enabled and settings.aimbot.autoFire.autoShoot and (settings.aimbot.autoFire.autoWall or isVisible) then
				mouse1click()
            elseif settings.aimbot.autoFire.triggerbot then
                local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { workspace.Baddies, workspace.Ignore, workspace.Interact, cam, char })
                if part and part.Parent.Parent == workspace.Baddies then
                    mouse1click()
                end
			end
        end
    end
end)