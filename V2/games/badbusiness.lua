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
            smoothness = 1,
            aimPart = "Abdomen"
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
        hitboxes = {
            enabled = false,
            visible = false,
            multiplier = 1
        },
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
            alwaysHeadshot = false,
            noRecoil = false,
            noSpread = false,
            noCamShake = false
        },
        fireRate = {
            enabled = false,
            rate = 0
        },
        cosmetic = {
            skin = "",
            customColour = false,
            colour = Color3.new(1, 0, 0),
            customMaterial = false,
            material = "ForceField"
        }
    },
    itemMods = {
        knifeAura = {
            requireKnife = false,
            range = 20
        },
        nadeMods = {
            tpNades = false,
            stickyNades = false,
            antiFlash = false,
            antiSmoke = false
        }
    },
    playerMods = {
        charMods = {
            fastSprint = false,
            jumpBoost = false,
            power = 36,
            flySpeed = 140,
            fakeStance = false,
            stance = "Prone"
        }
    }
}

--[[ ==========  Variables  ========== ]]

local cache = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V2/utils/libraryv3.lua"))()
cache.esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V2/utils/espv3.lua"))()

local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local teams = game:GetService("Teams")
local lighting = game:GetService("Lighting")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local fovCircle = Drawing.new("Circle")
local connections, charSizes, gunMats, idCache = {}, {}, {}, {}
local char, root
local target, currentGun
local isAimKeyDown, isFlying = false, false

local oldLighting, brightLighting = {
    Brightness = lighting.Brightness,
    GlobalShadows = lighting.GlobalShadows,
    Ambient = lighting.Ambient
}, {
   Brightness = 10,
   GlobalShadows = false,
   Ambient = Color3.new(1, 1, 1) 
}

local blacklistedargs = { -- some are no longer used but keeping it anyway
    "geometry deleted",
    "deleted remote",
    "unbound gloop",
    "_g",
    "hitbox extender",
    "projectile hook",
	"alternate mode",
	"shooting hard",
	"looking hard",
    "int check",
    "fallback config",
    "floating",
    "root",
    "camera object",
    "coregui instance",
    "unsafe function"
}

local flyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local shell = require(replicatedStorage:WaitForChild("TS"))

local netFire = shell.Network.Fire
local recoilFire = shell.Camera.Recoil.Fire
local lookVector = shell.Input.Reticle.LookVector
local initProjectile = shell.Projectiles.InitProjectile
local killProjectile = shell.Projectiles.KillProjectile
local camShove = shell.Items.FirstPerson.CameraSpring.Shove
local timerWait = shell.Timer.Wait
local enemyCast = shell.Raycast.CastGeometryAndEnemies

local challenges = player.PlayerGui:WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("Challenges")
local hitmarker = player.PlayerGui:WaitForChild("MainGui"):WaitForChild("HitmarkerScript"):WaitForChild("Hitmarker")
local skinFolder = replicatedStorage:FindFirstChild("CamoColors", true).Parent

local controlFunc = getupvalue(shell.Timer.BindToHeartbeat, 1).Control
local firstPerson = getupvalue(shell.Timer.BindToRenderStep, 1).FirstPerson
local gunTypeStats = getupvalue(initProjectile, 1)
local bulletStats = getupvalue(initProjectile, 5)
local charTable = getupvalue(shell.Characters.GetCharacter, 1)
local hitmarkFunc = getconnections(shell.UI.Events.Hitmarker.Event)[2].Function

local effects = shell.Effects
local effectsTable = getupvalue(effects.Effect, 1)
local effectsFolder = getupvalue(effects.Effect, 2)
local flash, smoke

local speedIndex = table.find(getconstants(controlFunc), 1.8)
local bobIndex = table.find(getconstants(firstPerson), 0.3)
local hitIndex = table.find(getconstants(hitmarkFunc), 1.5)

--[[ ==========  Anticheat  ========== ]]

for i, v in next, getconnections(game:GetService("LogService").MessageOut) do
    v:Disable()
end

for i, v in next, getconnections(game:GetService("ScriptContext").Error) do
    v:Disable()
end

for i, v in next, getconnections(runService.Stepped) do
    if type(v.Function) == "function" and islclosure(v.Function) and table.find(getconstants(v.Function), "integrity check") then
        v:Disable()
    end
end

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

local function registerChar(character)
    char, root = character, character:WaitForChild("Root")
    --[[if settings.fakestance.enabled then
        netFire(shell.Network, "Character", "State", "Stance", settings.fakestance.value)
    end]]
    char:WaitForChild("Health"):GetPropertyChangedSignal("Value"):Connect(function()
        if not char:FindFirstChild("Health") or char.Health.Value <= 0 then
            char, root = nil, nil
        end
    end)
end

local function getPlr(character)
    local plr
    while true do
        for i, v in next, charTable do
            if v == character then
                plr = i
                break
            end
        end
        if plr then
            break
        end
        runService.Heartbeat:Wait()
    end
    return plr
end

local function getTarget()
    local retPart, dist = nil, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
    local startPos = cam.CFrame.Position
    for i, v in next, players:GetPlayers() do
        if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
            local character = charTable[v]
            if character and character:FindFirstChild("Health") and character.Parent then
                local part = character:FindFirstChild("Hitbox") and character.Hitbox:FindFirstChild(settings.aimbot.aimbot.aimPart)
                if part then
                    local partPos = part.Position
                    local screenPos, vis = cam:WorldToScreenPoint(partPos)
                    if vis and not workspace:FindPartOnRayWithWhitelist(Ray.new(startPos, partPos - startPos), { workspace.Terrain, workspace.Geometry }, true) then
                        local mag = (Vector2.new(screenPos.X, screenPos.Y) - fovCircle.Position).Magnitude
                        if mag < dist then
                            retPart, dist = part, mag
                        end
                    end
                end
            end
        end
    end
    return retPart
end

local function applySkinCS(model, camo)
    for i, v in next, model.Body:GetDescendants() do
        if v:IsA("Texture") then
            v:Destroy()
        end
    end
    setthreadidentity(2) -- require go brr
    shell.Skins:Paint(model, camo)
    setthreadidentity(7)
end

local function getEquipped()
    local item = char.Backpack.Equipped.Value
    for i, v in next, { "Primary", "Secondary", "Melee" } do
        if char.Backpack[v].Value == item then
            return v
        end
    end
end

local function automateInput(name)
    shell.Input:AutomateBegan(name)
	runService.Heartbeat:Wait()
	shell.Input:AutomateEnded(name)
end

--[[ ==========  Setup  ========== ]]

fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false
fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
fovCircle.Thickness = 1
fovCircle.Visible = false

cache.esp.IsEnemy = function(self, plr)
    return not shell.Teams:ArePlayersFriendly(player, plr)
end

cache.esp.SetupTeamChange = function(self, plr, container)
    cache.esp:UpdateTeamColour(container, teams[shell.Teams:GetPlayerTeam(plr)].Color.Value)
end

cache.esp.GetHealth = function(self, model)
    if model:FindFirstChild("Health") then
        return math.floor((model.Health.Value / model.Health.MaxHealth.Value) * 100) / 100
    end
    return 0
end

for i, v in next, workspace.Characters:GetChildren() do
    coroutine.wrap(function()
        local plr = getPlr(v)
        if plr == player then
            registerChar(v)
        else
            cache.esp:AddEsp(plr, v)
        end
    end)()
end

for i, v in next, challenges:GetChildren() do
    if v:FindFirstChild("PointsLabel") and v.PointsLabel.Text:lower() ~= "completed" then
        local conn
        conn = v.PointsLabel:GetPropertyChangedSignal("Text"):Connect(function()
            if settings.autoclaim and v.PointsLabel.Text:lower() == "completed" then
                getconnections(v.ClaimButton.MouseButton1Click)[1].Function()
                conn:Disconnect()
            end
        end)
    end
end

for i, v in next, Enum.Material:GetEnumItems() do
    gunMats[#gunMats + 1] = v.Name
end

table.sort(gunMats, function(a, b)
    return a < b
end)

for i, v in next, game:GetService("StarterPlayer").StarterCharacter.Body:GetChildren() do
    charSizes[v.Name] = v.Size + Vector3.new(0.6, (v.Name == "Chest" or v.Name == "Hips" and 0 or 0.6), 0.6)
end

for i, v in next, workspace:GetChildren() do
    if v:FindFirstChild("AnimationController") then
        currentGun = v
        v.AncestryChanged:Wait()
        currentGun = nil
        break
    end
end

for i, v in next, { "Flashbang", "Smoke" } do
    if effectsFolder:FindFirstChild(v) and not effectsTable[v] then
        effectsTable[v] = require(effectsFolder[v])
    end
end

flash, smoke = effectsTable.Flashbang, effectsTable.Smoke

--[[ ==========  GUI  ========== ]]

local library = cache.library.new("Bad Business")
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
end, { items = { "Abdomen", "Chest", "Head" }, default = "Abdomen" })
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

local hitboxes = visualsTab:AddPanel("Hitbox Extender", { info = "Hitbox Extender - Makes enemies' body parts larger, so they're easier to hit" })
hitboxes:AddToggle("Enabled", function(state)
    settings.visuals.hitboxes.enabled = state
    for i, v in next, workspace.Characters:GetChildren() do
        if not shell.Teams:ArePlayersFriendly(player, getPlr(v)) then
            for _, part in next, v.Hitbox:GetChildren() do
                part.Size = state and charSizes[part.Name] * settings.visuals.hitboxes.multiplier or charSizes[part.Name]
            end
        end
    end
end, { flag = "hitboxesenabled" })
hitboxes:AddToggle("Visible", function(state)
    settings.visuals.hitboxes.visible = state
    for i, v in next, workspace.Characters:GetChildren() do
        if not shell.Teams:ArePlayersFriendly(player, getPlr(v)) then
            for _, part in next, v.Hitbox:GetChildren() do
                part.Transparency = state and 0.5 or 1
            end
        end
    end
end, { flag = "hitboxesvisible" })
hitboxes:AddSlider("Size Multiplier", function(value)
    settings.visuals.hitboxes.multiplier = value
    for i, v in next, workspace.Characters:GetChildren() do
        if not shell.Teams:ArePlayersFriendly(player, getPlr(v)) then
            for _, part in next, v.Hitbox:GetChildren() do
                part.Size = settings.visuals.hitboxes.enabled and charSizes[part.Name] * value or charSizes[part.Name]
            end
        end
    end
end, { min = 1, max = 20, float = 0.1 })

local xRay = visualsTab:AddPanel("X-Ray", { info = "X-Ray - Makes walls transparent, so you can see through them" })
xRay:AddToggle("Enabled", function(state)
    settings.visuals.xRay.enabled = state
    for i, v in next, workspace.Geometry:GetDescendants() do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = state and settings.visuals.xRay.transparency or 0
        end
    end
end)
xRay:AddSlider("Transparency", function(value)
    settings.visuals.xRay.transparency = value
    for i, v in next, workspace.Geometry:GetDescendants() do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = settings.visuals.xRay.enabled and value or 0
        end
    end
end, { max = 1, float = 0.01, default = 0.75, flag = "xraytransparency" })

local impactPoints = visualsTab:AddPanel("Impact Points", { info = "Impact Points - Highlights bullet holes on the map" })
impactPoints:AddToggle("Enabled", function(state)
    settings.visuals.impactPoints.enabled = state
    for i, v in next, workspace.Effects:GetChildren() do
        if v.Name == "BulletHole" then
            v.Material = state and Enum.Material.Neon or Enum.Material.SmoothPlastic
            v.Transparency = state and 0 or 1
        end
    end
end, { flag = "impactenabled" })
impactPoints:AddPicker("Impact Colour", function(colour)
    settings.visuals.impactPoints.colour = colour
    for i, v in next, impactPoints do
        for i, v in next, workspace.Effects:GetChildren() do
            if v.Name == "BulletHole" then
                v.Color = colour
            end
        end
    end
end, { default = table.pack(settings.visuals.impactPoints.colour:ToHSV()) })

local guiMods = visualsTab:AddPanel("GUI", { info = "Modifications to the GUIs and overall visuals of your game" })
guiMods:AddToggle("Fullbright", function(state)
    settings.visuals.guiMods.fullBright = state
    lighting.Brightness = state and brightLighting.Brightness or oldLighting.Brightness
    lighting.GlobalShadows = state and brightLighting.GlobalShadows or oldLighting.GlobalShadows
    lighting.Ambient = state and brightLighting.Ambient or oldLighting.Ambient
end)
guiMods:AddToggle("Auto Claim Challenges", function(state)
    if state then
        for i, v in next, challenges:GetChildren() do
            if v:FindFirstChild("PointsLabel") and v.PointsLabel.Text:lower() == "completed" then
                getconnections(v.ClaimButton.MouseButton1Click)[1].Function()
            end
        end
    end
end)
guiMods:AddButton("Redeem All Codes", function()
    local page = game:HttpGet("https://roblox-bad-business.fandom.com/wiki/Codes")
    for word in page:gmatch("<td>([%w\n_]*)</td>") do
        shell.Network:Invoke("Codes", "Redeem", word:gsub("\n", ""))
        task.wait(0.25)
    end
end)

local gunModsTab = library:AddTab("Gun Mods", "Cosmetic & Performance Changes", "rbxassetid://7825568616")

local gunsMain = gunModsTab:AddPanel("Main", { info = "Gun Mods - Modify several aspects of your gun's performance. Note: Wallbang only works close up, cross-map hits won't register" })
gunsMain:AddToggle("Always Headshot", function(state)
    settings.gunMods.main.alwaysHeadshot = state
    for i, v in next, hitmarker:GetChildren() do
        v.BackgroundColor3 = state and Color3.fromRGB(255, 14, 14) or Color3.new(1, 1, 1)
    end
    setconstant(hitmarkFunc, hitIndex, state and 2 or 1.5)
end)
gunsMain:AddToggle("No Recoil", function(state)
    settings.gunMods.main.noRecoil = state
end)
gunsMain:AddToggle("No Spread", function(state)
    settings.gunMods.main.noSpread = state
end)
gunsMain:AddToggle("No Camera Shake", function(state)
    settings.gunMods.main.noCamShake = state
end)
gunsMain:AddToggle("No Gun Bob", function(state)
    setconstant(firstPerson, bobIndex, state and 0 or 0.3)
end)
gunsMain:AddToggle("Wallbang", function(state)
    setupvalue(enemyCast, 1, not state and workspace.Geometry or nil)
    setupvalue(enemyCast, 2, not state and workspace.Terrain or nil)
end)

local gunFireRate = gunModsTab:AddPanel("Fire Rate", { info = "Fire Rate - Adjusts how fast your gun fires" })
gunFireRate:AddToggle("Enabled", function(state)
    settings.gunMods.fireRate.enabled = state
end, { flag = "firerateenabled" })
gunFireRate:AddSlider("Fire Rate", function(value)
    settings.gunMods.fireRate.rate = value
end, { min = 0, max = 2500 })

local gunCosmetics = gunModsTab:AddPanel("Cosmetics", { info = "Cosmetics - Adjust how your gun looks" })
gunCosmetics:AddBox("Apply Any Skin", function(value)
    local skin = skinFolder:FindFirstChild(value, true)
    if skin then
        settings.gunMods.cosmetic.skin = value
        if currentGun then
            applySkinCS(currentGun, value)
        end
    else
        settings.gunMods.cosmetic.skin = ""
        library:Notify("Skin: '" .. value .. "' was not found.")
    end
end)
gunCosmetics:AddToggle("Custom Gun Colour", function(state)
    settings.gunMods.cosmetic.customColour = state
    if state and currentGun then
        for i, v in next, currentGun.Body:GetDescendants() do
            if v:IsA("BasePart") then
                v.Color = settings.gunMods.cosmetic.colour
            end
        end
    end
end)
gunCosmetics:AddPicker("Gun Colour", function(colour)
    settings.gunMods.cosmetic.colour = colour
    if settings.gunMods.cosmetic.customColour and currentGun then
        for i, v in next, currentGun.Body:GetDescendants() do
            if v:IsA("BasePart") then
                v.Color = colour
            end
        end
    end
end, { default = table.pack(Color3.new(1, 0, 0):ToHSV()) })
gunCosmetics:AddToggle("Custom Material", function(state)
    settings.gunMods.cosmetic.customMaterial = state
    if currentGun then
        for i, v in next, currentGun.Body:GetDescendants() do
            if v:IsA("BasePart") then
                v.Material = state and Enum.Material[settings.gunMods.cosmetic.material] or Enum.Material.SmoothPlastic
            end
        end
    end
end)
gunCosmetics:AddDropdown("Material", function(selected)
    settings.gunMods.cosmetic.material = selected
    if settings.gunMods.cosmetic.customMaterial and currentGun then
        local mat = Enum.Material[selected]
        for i, v in next, currentGun.Body:GetDescendants() do
            if v:IsA("BasePart") then
                v.Material = mat
            end
        end
    end
end, { items = gunMats, default = "ForceField" })

local itemModsTab = library:AddTab("Item Mods", "Knives, Grenades", "rbxassetid://7826196058")

local knifeAura = itemModsTab:AddPanel("Knife Aura", { info = "Automatically knifes people in range of you" })
knifeAura:AddToggle("Enabled", function(state)
    stopConnection("killAura")
    if state then
        addConnection("killAura", runService.Heartbeat:Connect(function()
            for i, v in next, players:GetPlayers() do
                if not root then break end
                if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
                    local character = charTable[v]
                    if character and character:FindFirstChild("Health") and character.Health.Value > 0 then
                        local part = character:FindFirstChild("Hitbox")
                        if part and part:FindFirstChild("Head") then
                            if (part.Head.Position - root.Position).Magnitude < settings.itemMods.knifeAura.range then
                                local equipped = getEquipped()
                                if equipped and (equipped == "Melee" or not settings.itemMods.knifeAura.requireKnife) then
                                    local current, knife = char.Backpack.Items[char.Backpack.Equipped.Value.Name], char.Backpack.Items[char.Backpack.Melee.Value.Name]
                                    local currentConf, knifeConf = require(current.Config), require(knife.Config)
                                    if equipped ~= "Melee" then
                                        automateInput("Melee")
                                        task.wait((currentConf.Handling.UnequipTime / currentConf.Handling.Speed) + (knifeConf.Handling.EquipTime / knifeConf.Handling.Speed) + 0.1)
                                    end
                                    shell.Network:Fire("Item_Melee", "Stab", knife, part.Head, part.Head.Position, Vector3.new());
                                    if equipped ~= "Melee" then
                                        task.wait(0.1)
                                        automateInput(equipped)
                                        task.wait(knifeConf.Handling.UnequipTime / knifeConf.Handling.Speed)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end))
    end
end, { flag = "knifeauraenabled" })
knifeAura:AddToggle("Require Knife Equipped", function(state)
    settings.itemMods.knifeAura.requireKnife = state
end)
knifeAura:AddSlider("Range", function(value)
    settings.itemMods.knifeAura.range = value
end, { max = 20, default = 20, float = 0.1, flag = "knifeaurarange" })

local nadeMods = itemModsTab:AddPanel("Grenades", { info = "Various grenade modifications and immunities" })
nadeMods:AddToggle("Teleport Grenades", function(state)
    settings.itemMods.nadeMods.tpNades = state
end)
nadeMods:AddToggle("Sticky Grenades", function(state)
    settings.itemMods.nadeMods.stickyNades = state
end)
nadeMods:AddToggle("Anti Flashbang", function(state)
    settings.itemMods.nadeMods.antiFlash = state
end)
nadeMods:AddToggle("Anti Smoke", function(state)
    settings.itemMods.nadeMods.antiSmoke = state
end)

local playerTab = library:AddTab("Player", "Player & Character Mods", "rbxassetid://7826527270")

local charMods = playerTab:AddPanel("Character")
charMods:AddToggle("Custom Sprint Speed", function(state)
    settings.playerMods.charMods.fastSprint = state
end)
charMods:AddSlider("Sprint Speed", function(value)
    setconstant(controlFunc, speedIndex, settings.playerMods.charMods.fastSprint and value / 22 or 1.8)
end, { min = 40, max = 140 })
charMods:AddToggle("Custom JumpPower", function(state)
    settings.playerMods.charMods.jumpBoost = state
end)
charMods:AddSlider("JumpPower", function(value)
    settings.playerMods.charMods.power = value
end, { min = 36, max = 140 })
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
end, { min = 22, max = 140, default = 140 })
charMods:AddToggle("No Clip", function(enabled)
    stopConnection("noClip")
    if enabled then
        addConnection("noClip", runService.Stepped:Connect(function()
            if root then
                root.CanCollide = false
            end
        end))
    elseif root then
        root.CanCollide = true
    end
end)
charMods:AddToggle("Fake Stance", function(state)
    settings.playerMods.charMods.fakeStance = state
    if root and state then
        netFire(shell.Network, "Character", "State", "Stance", settings.playerMods.charMods.stance)
    end
end)
charMods:AddDropdown("Stance", function(selected)
    settings.playerMods.charMods.stance = selected
    if root and settings.playerMods.charMods.fakeStance then
        netFire(shell.Network, "Character", "State", "Stance", selected)
    end
end, { items = { "Stand", "Crouch", "Prone" }, default = "Prone" })

local playerMods = playerTab:AddPanel("Player")
playerMods:AddToggle("Always Radar Enemies", function(state)
    stopConnection("alwaysRadar")
    if state then
        addConnection("alwaysRadar", runService.Stepped:Connect(function()
            for i, v in next, players:GetPlayers() do
                if not shell.Teams:ArePlayersFriendly(player, v) then
                    local character = charTable[v]
                    if character and character:FindFirstChild("Root") then
                        shell.Effects:Effect("RadarEnemy", v, character.Root.Position)
                    end
                end
            end
        end))
    end
end)

library:AddSettings()

--[[ ==========  Hooks  ========== ]]

local data = { blacklist = blacklistedargs }
data.metanamecall = hookmetamethod(game, "__namecall", loadstring(LPH_ENCSTR([[
    local data = ...
    return function(self, ...)
        if getnamecallmethod() == "FireServer" then
            local args = {...}
            if type(args[2]) == "string" then
                local s = string.lower(args[2])
                for i, v in next, data.blacklist do
                    if string.find(s, v) then
                        return
                    end
                end
            end
        end
        return data.metanamecall(self, ...)
    end
]]))(data))

shell.Network.Fire = newcclosure(function(self, ...)
    local args = {...}
    if args[2] == "OnError" then
        return
    elseif args[3] == "Stance" and settings.playerMods.charMods.fakeStance then
        args[4] = settings.playerMods.charMods.stance
    elseif args[2] == "__Hit" then
        if idCache[args[3]] then
            idCache[args[3]] = nil
            return
        elseif settings.gunMods.main.alwaysHeadshot and args[4]:IsDescendantOf(workspace.Characters) then
            args[4] = args[4].Parent.Head
        end
    end
    netFire(self, unpack(args))
end)

shell.Input.Reticle.LookVector = newcclosure(function(self, ...)
    return settings.gunMods.main.noSpread and cam.CFrame.LookVector or lookVector(self, ...)
end)

shell.Camera.Recoil.Fire = newcclosure(function(...)
    if settings.gunMods.main.noRecoil then
        return
    end
    recoilFire(...)
end)

shell.Projectiles.InitProjectile = newcclosure(function(self, ...)
    initProjectile(self, ...)
    local args = {...}
    if args[4] == player then
        if settings.aimbot.silentAim.enabled and target and math.random(1, 100) <= settings.aimbot.silentAim.hitChance then
            idCache[args[5]] = true
            coroutine.wrap(function()
                local part = math.random(1, 100) <= settings.aimbot.silentAim.headshotChance and target.Parent.Head or target
                task.wait((part.Position - root.Position).Magnitude / gunTypeStats[args[1]].Speed)
                if part and part.Parent then
                    killProjectile(shell.Projectiles, args[5], part, part.Position, Vector3.new(), part.Parent.Parent)
                    netFire(shell.Network, "Projectiles", "__Hit", args[5], part.Position, part, Vector3.new())
                end
            end)()
        end
    end
end)

shell.Projectiles.KillProjectile = newcclosure(function(self, ...)
    local args = {...}
    if idCache[args[1]] then
        idCache[args[1]] = nil
        return
    end
    killProjectile(self, ...)
end)

shell.Timer.Wait = function(...) -- newcclosure doesn't yield on anything but proto :(
    if settings.gunMods.fireRate.enabled and tostring(getfenv(2).script) == "Paintball" then
        return task.wait(1 / (settings.gunMods.fireRate.rate / 60))
    end
    return timerWait(...)
end

shell.Items.FirstPerson.CameraSpring.Shove = newcclosure(function(...)
    if settings.gunMods.main.noCamShake then
        return
    end
    return camShove(...)
end)

effectsTable.Flashbang = newcclosure(function(...)
    if settings.itemMods.nadeMods.antiFlash then
        return
    end
    return flash(...)
end)

effectsTable.Smoke = newcclosure(function(...)
    if settings.itemMods.nadeMods.antiSmoke then
        return
    end
    return smoke(...)
end)

local metaNewIndex
metaNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
	if t == root and k == "Velocity" then
		if (v.Y == 25 or v.Y == 36) and settings.playerMods.charMods.jumpBoost then
			return metaNewIndex(t, k, Vector3.new(v.X, settings.playerMods.charMods.power, v.Z))
		end
	end
	metaNewIndex(t, k, v)
end)

--[[ ==========  Connections  ========== ]]

mouse.Move:Connect(function()
    fovCircle.Position = userInputService:GetMouseLocation()
end)

workspace.ChildAdded:Connect(function(child)
    if child:FindFirstChild("AnimationController") then
        task.wait(0.1)
        currentGun = child
        if settings.gunMods.cosmetic.customColour then
            for i, v in next, child:WaitForChild("Body"):GetDescendants() do
                if v:IsA("BasePart") then
                    v.Color = settings.gunMods.cosmetic.colour
                end
            end
        end
        if settings.gunMods.cosmetic.customMaterial then
            for i, v in next, child:WaitForChild("Body"):GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material[settings.gunMods.cosmetic.material]
                end
            end
        end
        if skinFolder:FindFirstChild(settings.gunMods.cosmetic.skin, true) then
            applySkinCS(child, settings.gunMods.cosmetic.skin)
        end
        child.AncestryChanged:Wait()
        currentGun = nil
    end
end)

workspace.Effects.ChildAdded:Connect(function(child)
    if child.Name == "BulletHole" then
        child.Color = settings.visuals.impactPoints.colour
        if settings.visuals.impactPoints.enabled then
            child.Material = Enum.Material.Neon
            child.Transparency = 0
        end
    end
end)

workspace.Characters.ChildAdded:Connect(function(child)
    local plr = getPlr(child)
    if plr == player then
        registerChar(child)
    else
        cache.esp:AddEsp(plr, child)
        if not shell.Teams:ArePlayersFriendly(player, plr) then
            for _, part in next, child:WaitForChild("Hitbox"):GetChildren() do
                local size = charSizes[part.Name]
                part.Size = settings.visuals.hitboxes.enabled and size * settings.visuals.hitboxes.multiplier or size
                part.Transparency = settings.visuals.hitboxes.visible and 0.5 or 1
            end
        end
    end
end)

workspace.Geometry.DescendantAdded:Connect(function(descendant)
    if settings.visuals.xRay.enabled and descendant:IsA("BasePart") then
        descendant.LocalTransparencyModifier = settings.visuals.xRay.transparency
    end
end)

workspace.Throwables.ChildAdded:Connect(function(child)
    if child:WaitForChild("Owner").Value == player then
        if settings.itemMods.nadeMods.tpNades then
			local body = child:WaitForChild("Body"):WaitForChild("BodyPrimary")
            repeat
                for i, v in next, players:GetPlayers() do
                    if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
                        local character = charTable[v]
                        if character then
                            local part = character:FindFirstChild("Root")
                            if part then
                                body.Position = part.Position
                                break
                            end
                        end
                    end
                end
                runService.Heartbeat:Wait()
            until not (child and child.Parent)
        elseif settings.itemMods.nadeMods.stickyNades then
            local body = child:WaitForChild("Body"):WaitForChild("BodyPrimary")
            body.Touched:Wait()
            local stickpos = body.Position
            repeat
                body.Position = stickpos
                runService.Heartbeat:Wait()
            until not (child and child.Parent)
        end
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
                local pos = cam:WorldToViewportPoint(target.Position)
                local moveVec = (Vector2.new(pos.X, pos.Y) - fovCircle.Position) / (settings.aimbot.aimbot.smoothness + 0.5)
                mousemoverel(moveVec.X, moveVec.Y)
            end
            if settings.aimbot.silentAim.enabled and settings.aimbot.autoFire.autoShoot then
                automateInput("Shoot")
            elseif settings.aimbot.autoFire.triggerbot then
				local part = workspace:FindPartOnRayWithWhitelist(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { workspace.Terrain, workspace.Geometry, workspace.Characters }, true)
                if part and part:IsDescendantOf(workspace.Characters) then
					automateInput("Shoot")
				end
            end
        end
    end
end)

--[[ ==========  Temporary Gethui Patch  ========== ]]

if identifyexecutor and (identifyexecutor():find("Oxygen") or identifyexecutor():find("Fluxus")) then
	library._gui.Parent = game:GetService("CoreGui")
end
