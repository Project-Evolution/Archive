--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

local LPH_ENCSTR = function(...) return ... end
local LPH_JIT_ULTRA = function(...) return ... end

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "JailBreak", version = changelog.version .. " Premium", storage = { "bank", "jewelry", "plant", "ignores" } })
evov3.imports:fetchmodule("esp")

local drawing = evov3.imports:fetchsystem("drawing")

local maids = {
    character = evov3.imports:fetchsystem("maid"),
    fly = evov3.imports:fetchsystem("maid"),
    nitro = evov3.imports:fetchsystem("maid"),
    flip = evov3.imports:fetchsystem("maid"),
    lights = evov3.imports:fetchsystem("maid"),
    shootcars = evov3.imports:fetchsystem("maid"),
    shoothelis = evov3.imports:fetchsystem("maid"),
    doors = evov3.imports:fetchsystem("maid")
}

local initstamp = tick()

local players = game:GetService("Players")
local replicatedstorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local collectionservice = game:GetService("CollectionService")
local httpservice = game:GetService("HttpService")
local marketplace = game:GetService("MarketplaceService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

local mainlocalscr = player:WaitForChild("PlayerScripts"):WaitForChild("LocalScript")
local moneystat = player:WaitForChild("leaderstats"):WaitForChild("Money")
local codecontainer = player:WaitForChild("PlayerGui"):WaitForChild("CodesGui"):WaitForChild("CodeContainer"):WaitForChild("Background")
local minimap = player.PlayerGui:WaitForChild("AppUI"):WaitForChild("Buttons"):WaitForChild("Minimap")
local mappoints = minimap:WaitForChild("Map"):WaitForChild("Container"):WaitForChild("Points")
local char, root, hum
local silentaimtarget
local ojtrack

local isaimkeydown = false
local isflying, isopeningsafes = false, false
local baseflyvec = Vector3.new(0, 1e-9, 0)

local flykeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local vehicletable, vehicleclasses
local timefunc, slowidx
local isholdingidx
local crawlidx

local markersystem = replicatedstorage:WaitForChild("Game"):WaitForChild("RobberyMarkerSystem")
local jetskimodule = replicatedstorage.Game:WaitForChild("VehicleSystem"):WaitForChild("JetSki")

local modules = {
    actionbuttons = require(replicatedstorage:WaitForChild("ActionButton"):WaitForChild("ActionButtonService")),
    store = require(replicatedstorage:WaitForChild("App"):WaitForChild("store")),
    boat = require(replicatedstorage.Game:WaitForChild("Boat"):WaitForChild("Boat")),
    dispenser = require(replicatedstorage.Game:WaitForChild("DartDispenser"):WaitForChild("DartDispenser")),
    defaultactions = require(replicatedstorage.Game:WaitForChild("DefaultActions")),
    falling = require(replicatedstorage.Game:WaitForChild("Falling")),
    gamepassutils = require(replicatedstorage.Game:WaitForChild("Gamepass"):WaitForChild("GamepassUtils")),
    vehicledata = require(replicatedstorage.Game:WaitForChild("Garage"):WaitForChild("VehicleData")),
    guardnpc = require(replicatedstorage:WaitForChild("GuardNPC"):WaitForChild("GuardNPCShared")),
    gunshoputils = require(replicatedstorage.Game:WaitForChild("GunShop"):WaitForChild("GunShopUtils")),
    gunshopui = require(replicatedstorage.Game.GunShop:WaitForChild("GunShopUI")),
    invconsts = require(replicatedstorage:WaitForChild("Inventory"):WaitForChild("InventoryConsts")),
    invsystem = require(replicatedstorage.Inventory:WaitForChild("InventoryItemSystem")),
    basic = require(replicatedstorage.Game:WaitForChild("Item"):WaitForChild("Basic")),
    gun = require(replicatedstorage.Game.Item:WaitForChild("Gun")),
    plasma = require(replicatedstorage.Game.Item:WaitForChild("PlasmaPistol")),
    emitter = require(replicatedstorage.Game:WaitForChild("ItemSystem"):WaitForChild("BulletEmitter")),
    itemcamera = require(replicatedstorage.Game.ItemSystem:WaitForChild("ItemCamera")),
    itemsystem = require(replicatedstorage.Game.ItemSystem:WaitForChild("ItemSystem")),
    jetpack = require(replicatedstorage.Game:WaitForChild("JetPack"):WaitForChild("JetPack")),
    jpgui = require(replicatedstorage.Game.JetPack:WaitForChild("JetPackGui")),
    jputil = require(replicatedstorage.Game.JetPack:WaitForChild("JetPackUtil")),
    militaryturret = require(replicatedstorage.Game:WaitForChild("MilitaryTurret"):WaitForChild("MilitaryTurret")),
    notification = require(replicatedstorage.Game:WaitForChild("Notification")),
    party = require(replicatedstorage.Game:WaitForChild("Party")),
    plane = require(replicatedstorage.Game:WaitForChild("Plane"):WaitForChild("BaseUserControlledPlane")),
    plrutils = require(replicatedstorage.Game:WaitForChild("PlayerUtils")),
    vehicle = require(replicatedstorage.Game:WaitForChild("Vehicle")),
    shipturret = require(replicatedstorage.Game:WaitForChild("Robbery"):WaitForChild("CargoShip"):WaitForChild("Turret")),
    puzzleflow = require(replicatedstorage.Game.Robbery:WaitForChild("PuzzleFlow")),
    robconsts = require(replicatedstorage.Game.Robbery:WaitForChild("RobberyConsts")),
    chassis = require(replicatedstorage:WaitForChild("Module"):WaitForChild("AlexChassis")),
    raycast = require(replicatedstorage.Module:WaitForChild("RayCast")),
    ui = require(replicatedstorage.Module:WaitForChild("UI")),
    settings = require(replicatedstorage:WaitForChild("Resource"):WaitForChild("Settings")),
    geometry = require(replicatedstorage:WaitForChild("Std"):WaitForChild("GeomUtils")),
    safeconsts = require(replicatedstorage:WaitForChild("Safes"):WaitForChild("SafesConsts")),
    maid = require(replicatedstorage.Std:WaitForChild("Maid")),
    vehiclelink = require(replicatedstorage:WaitForChild("VehicleLink"):WaitForChild("VehicleLinkBinder")),
    linkutils = require(replicatedstorage.VehicleLink:WaitForChild("VehicleLinkUtils"))
}

local originals = {
    boatupdate = modules.boat.UpdatePhysics,
    dispenserfire = modules.dispenser._fire,
    ragdoll = modules.falling.StartRagdolling,
    guardtarget = modules.guardnpc.canSeeTarget,
    emit = modules.emitter.Emit,
    bullethit = modules.gun.BulletEmitterOnLocalHitPlayer,
    camupdate = modules.itemcamera.Update,
    updatemousepos = modules.basic.UpdateMousePosition,
    plasmashoot = modules.plasma.ShootOther,
    isflying = modules.jetpack.IsFlying,
    militaryfire = modules.militaryturret._fire,
    haskey = modules.plrutils.hasKey,
    planepacket = modules.plane.FromPacket,
    pointintag = modules.plrutils.isPointInTag,
    entervehicle = modules.chassis.VehicleEnter,
    raynoncollide = modules.raycast.RayIgnoreNonCollide,
    rayignorelist = modules.raycast.RayIgnoreNonCollideWithIgnoreList,
    updatespec = modules.ui.CircleAction.Update,
    getvehiclepacket = modules.vehicle.GetLocalVehiclePacket,
    shipshoot = modules.shipturret.Shoot,
    vehiclehook = modules.vehiclelink._constructor._hookNearest,
    fireworks = getupvalue(modules.party.Init, 1)
}

local fakesniper = {
    __ClassName = "Sniper",
    Local = true,
    Config = {},
    IgnoreList = {},
    LastImpact = 0,
    LastImpactSound = 0,
    Maid = modules.maid.new()
}

local specs = modules.ui.CircleAction.Specs
local event = getupvalue(modules.chassis.SetEvent, 1)
local puzzle = getupvalue(modules.puzzleflow.Init, 3)
local defaultactions = getupvalue(modules.defaultactions.punchButton.onPressed, 1)

local punchidx = evov3.utils:tablefind(getconstants(defaultactions.attemptPunch), 0.5)
local boatidx = evov3.utils:tablefind(getconstants(originals.boatupdate), 0.3)

local doorstore = getupvalue(getconnections(collectionservice:GetInstanceRemovedSignal("Door"))[1].Function, 1)
local equipstore = getupvalue(modules.itemsystem.GetEquipped, 1)
local vehiclestore = {}

local robstates = {}
local roblabels = {}
local wallbanglist = {}
local guntables, gundata = {}, {}
local planetables, planedata = {}, {}
local boatdata = {}
local vehiclestats = {}
local noflyzones = {}
local carnames, helinames = {}, {}
local ammosources, ammodrop = {}, {}
local times = {}
local jptable
local crawlcondition
local invfolder

local espgroups = {
    prisoner = evov3.esp.group.new("players", {
        exclusions = { HumanoidRootPart = true },
        info = {
            equipped = function(inst)
                local store = equipstore[inst.player]
                return store and store.Model.Name or "None"
            end,
            vehicle = function(inst)
                return vehiclestore[inst.player] or "None"
            end
        }
    }),
    criminal = evov3.esp.group.new("players", {
        exclusions = { HumanoidRootPart = true },
        info = {
            equipped = function(inst)
                local store = equipstore[inst.player]
                return store and store.Model.Name or "None"
            end,
            vehicle = function(inst)
                return vehiclestore[inst.player] or "None"
            end
        }
    }),
    police = evov3.esp.group.new("players", {
        exclusions = { HumanoidRootPart = true },
        info = {
            equipped = function(inst)
                local store = equipstore[inst.player]
                return store and store.Model.Name or "None"
            end,
            vehicle = function(inst)
                return vehiclestore[inst.player] or "None"
            end
        }
    }),
    airdrop = evov3.esp.group.new("items", {})
}

espgroups.prisoner.settings.teammates = true
espgroups.criminal.settings.teammates = true
espgroups.police.settings.teammates = true

local aimbotfovcircle = drawing:add("Circle", {
    Color = Color3.new(1, 1, 1),
    Filled = false,
    Position = Vector2.new(mouse.X, mouse.Y),
    Thickness = 1,
    Visible = false
})

local silentaimfovcircle = drawing:add("Circle", {
    Color = Color3.new(1, 1, 1),
    Filled = false,
    Position = Vector2.new(mouse.X, mouse.Y),
    Thickness = 1,
    Visible = false
})

--[[ Garbage Collection ]]--

local garbage, hasbypassedac = LPH_JIT_ULTRA(function()
    local cache = {}
    local hasbypassedac = false
    for i, v in next, getgc() do
        if type(v) == "function" and islclosure(v) then
            local scr = getfenv(v).script
            if scr == mainlocalscr then
                local name, consts = getinfo(v).name, getconstants(v)
                if name == "DoorSequence" then
                    cache.opendoor = v
                elseif name == "StopNitro" then
                    cache.events = getupvalue(getupvalue(v, 1), 2)
                elseif evov3.utils:tablefind(consts, "VehicleHornId") then
                    cache.hornsound = v
                elseif evov3.utils:tablefind(consts, "FailedPcall") then
                    setupvalue(v, 2, true) -- Anticheat
                    hasbypassedac = true
                end
            elseif scr == markersystem and getinfo(v).name == "setRobberyMarkerState" then
                cache.markerstates = getupvalue(v, 1)
            elseif scr == jetskimodule and evov3.utils:tablefind(getconstants(v), "FindPartOnRay") then
                cache.jetskiupdate = v
            end
        end
    end
    return cache, hasbypassedac
end)()

local jetskiidx = evov3.utils:tablefind(getconstants(garbage.jetskiupdate), 0.3)

local clienthashes = {}

--[[ Functions ]]--

local function orangejustice()
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://3066265539"
        ojtrack = hum:LoadAnimation(anim)
        ojtrack:Play()
    end
end

local function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    if library.flags.walkspeed then
        if library.flags.orangejustice then
            orangejustice()
        end
        if library.flags.walkspeed.enabled then
            hum.WalkSpeed = library.flags.walkspeed.value
        end
        if library.flags.jumppower.enabled then
            hum.JumpPower = library.flags.jumppower.value
        end
    end
    maids.character:givetask(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum and library.flags.walkspeed.enabled then
            hum.WalkSpeed = library.flags.walkspeed.value
        end
    end))
    maids.character:givetask(hum.Died:Connect(function()
        maids.character:dispose()
        char, root, hum = nil, nil, nil
    end))
end

local function getseat(plr)
    for _, veh in next, workspace.Vehicles:GetChildren() do
        for i, v in next, veh:GetChildren() do
            if (v.Name == "Seat" or v.Name == "Passenger") and v.PlayerName.Value == plr.Name then
                return veh.Name
            end
        end
    end
end

local function registerplayercharacter(plr, team, character)
    espgroups[team]:add(character, { name = plr.Name, colour = plr.TeamColor.Color })
    if character:FindFirstChild("InVehicle") then
        vehiclestore[plr] = getseat(plr)
    end

    maids[plr.Name]:givetask(character.ChildAdded:Connect(function(child)
        if child.Name == "InVehicle" then
            vehiclestore[plr] = getseat(plr)
        end
    end))

    maids[plr.Name]:givetask(character.ChildRemoved:Connect(function(child)
        if child.Name == "InVehicle" then
            vehiclestore[plr] = nil
        end
    end))

    maids[plr.Name]:givetask(character:WaitForChild("Humanoid").Died:Connect(function()
        maids[plr.Name]:dispose()
        vehiclestore[plr] = nil
    end))
end

local function registerplayer(plr)
    maids[plr.Name] = evov3.imports:fetchsystem("maid")

    local team = string.lower(plr.Team.Name)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        registerplayercharacter(plr, team, plr.Character)
    end

    plr.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        registerplayercharacter(plr, team, character)
    end)

    plr:GetPropertyChangedSignal("Team"):Connect(function()
        local newteam = string.lower(plr.Team.Name)
        if plr.Character then
            espgroups[team]:remove(plr.Character)
            espgroups[newteam]:add(plr.Character, { name = plr.Name, colour = plr.TeamColor.Color })
        end
        team = newteam
    end)
end

local function getaimpart(hitbox, flag)
    if library.flags[flag] == "Closest Part" then
        local retpart, dist = nil, math.huge
        for i, v in next, hitbox:GetChildren() do
            if v:IsA("BasePart") then
                local pos = cam:WorldToScreenPoint(v.Position)
                local mag = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y).Magnitude
                if mag < dist then
                    retpart, dist = v, mag
                end
            end
        end
        return retpart
    end
    return hitbox:FindFirstChild(library.flags[flag])
end

local function getsilentaimtarget(equipped)
    local ret, dist = nil, library.flags.silentaimfov.enabled and silentaimfovcircle.Radius or math.huge
    local startpos = equipped.Tip.CFrame.Position
    for i, v in next, players:GetPlayers() do
        if v.Team ~= player.Team then
            local part = v.Character and getaimpart(v.Character, "silentaimaimpart")
            if part and v.Character.Humanoid.Health > 0 then
                local partpos = part.Position
                local screenpos, vis = cam:WorldToViewportPoint(partpos)
                local iswallbetween = workspace:FindPartOnRayWithIgnoreList(Ray.new(startpos, partpos - startpos), { cam, char, equipped.Model, v.Character }, true) ~= nil
                if vis and (iswallbetween == false or library.flags.silentaimwallcheck == false) then
                    local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
                    if mag < dist then
                        ret, dist = {
                            part = part,
                            iswallbetween = iswallbetween
                        }, mag
                    end
                end
            end
        end
    end
    return ret
end

local function getaimbottarget(equipped)
    local ret, dist = nil, library.flags.aimbotfov.enabled and aimbotfovcircle.Radius or math.huge
    local startpos = cam.CFrame.Position
    for i, v in next, players:GetPlayers() do
        if v.Team ~= player.Team then
            local part = v.Character and getaimpart(v.Character, "aimbotaimpart")
            if part and v.Character.Humanoid.Health > 0 then
                local partpos = part.Position
                local screenpos, vis = cam:WorldToViewportPoint(partpos)
                if vis and (library.flags.aimbotwallcheck == false or workspace:FindPartOnRayWithIgnoreList(Ray.new(startpos, partpos - startpos), { cam, char, equipped.Model, v.Character }, true) == nil) then
                    local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
                    if mag < dist then
                        ret, dist = part, mag
                    end
                end
            end
        end
    end
    return ret
end

local function getaimbotposition(aimtarget, equipped)
    local targetroot, pos = aimtarget.Parent.HumanoidRootPart, aimtarget.Position
    local speed = equipped.Config.BulletSpeed
    if speed then
        local dur = (aimtarget.Position - cam.CFrame.Position).Magnitude / speed
        if library.flags.aimbotpredictmove then
            pos = pos + (targetroot.Velocity * dur)
        end
        if library.flags.aimbotcompensatedrop then
            pos = pos + Vector3.new(0, (workspace.Gravity / 20) * dur ^ 2, 0)
        end
    end
    return pos
end

local function updaterobbery(name, pretty, val)
    local isopen = val.Value ~= modules.robconsts.ENUM_STATE.CLOSED
    robstates[name] = isopen
    if roblabels[name] then
        roblabels[name]:update(isopen and "Open" or "Closed", isopen and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36))
    end
    if val.Value == modules.robconsts.ENUM_STATE.OPENED then
        if library.flags.notifyrobberies then
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Evo V3", Text = "'" .. pretty .. "' has just opened!" })
        end
    end
end

local function registerrobbery(val)
    local name, pretty = garbage.markerstates[tonumber(val.Name)].Name, modules.robconsts.PRETTY_NAME[tonumber(val.Name)]
    updaterobbery(name, pretty, val)
    val:GetPropertyChangedSignal("Value"):Connect(function()
        updaterobbery(name, pretty, val)
    end)
end

local function updatevehicle(prop, val)
    local vehicle = originals.getvehiclepacket()
    if vehicle and vehicle[prop] and not vehicle.Passenger then
        vehicle[prop] = vehiclestats[vehicle.Model][prop] + val
        modules.chassis.UpdateStats(vehicle)
    end
end

local function solvepuzzle()
    local grid = evov3.utils:deepclone(puzzle.Grid)
	for i, v in next, grid do
		for i2, v2 in next, v do
			v[i2] = v[i2] + 1
		end
	end
	local res = httprequest({
		Url = "", -- Link redacted, the repl.co one from the previous 2 versions of Evo still works tho :)
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = httpservice:JSONEncode({
			puzzle = grid
		})
	})
    if res.Success then
        local solution = httpservice:JSONDecode(res.Body)
        for i, v in next, solution do
            for i2, v2 in next, v do
                v[i2] = v[i2] - 1
            end
        end
        puzzle.Grid = solution
        puzzle.OnConnection()
    else
        modules.notification.new({ Text = "The Puzzle Solver is not responding. Please try again later" })
    end
end

local function firetouch(part)
    if root then
        firetouchinterest(root, part, 0)
        task.wait()
        firetouchinterest(root, part, 1)
    end
end

local function opendoors()
    for i, v in next, doorstore do
        if not v.State.Open then
            garbage.opendoor(v)
        end
    end
end

local function explodewall()
    for i, v in next, specs do
        if v.Name == "Explode Wall" then
            v:Callback(true)
            break
        end
    end
end

local function liftgate()
    for i, v in next, specs do
        if v.Name == "Lift Gate" then
            v:Callback(true)
            break
        end
    end
end

local function opensewers()
    for i, v in next, specs do
        if v.Name == "Pull Open" then
            v:Callback(true)
        end
    end
end

local function hasrequiredgamepasses(name)
    local gamepasses = gundata[name].RequireAnyGamepass
    if gamepasses then
        for i = 1, #gamepasses do
            if not marketplace:UserOwnsGamePassAsync(player.UserId, modules.gamepassutils.GetGamepassFromEnum(gamepasses[i]).PassId) then
                return false
            end
        end
    end
    return true
end

local function isvehicleshootable(model, teamcheck)
    if not (model:FindFirstChild("Seat") and model.Seat:FindFirstChild("Player")) then
        return false
    end
    return model.Seat.Player.Value and model.Seat.PlayerName.Value ~= player.Name and (teamcheck == false or players[model.Seat.PlayerName.Value].Team ~= player.Team)
end

local function shootvehicle(part)
    fakesniper.LastImpact = 0
    fakesniper.BulletEmitter.OnHitSurface:Fire(part, part.Position, part.Position)
end

local function grabfromshop(category, name)
    setthreadidentity(2)
    local isopen = not select(1, pcall(modules.gunshopui.open))
    modules.gunshopui.displayList(modules.gunshoputils.getCategoryData(category))
    setthreadidentity(7)
    for i, v in next, modules.gunshopui.gui.Container.Container.Main.Container.Slider:GetChildren() do
        if v:IsA("ImageLabel") and (name == "All" or v.Name == name) and (category ~= "Held" or v.Bottom.Action.Text == "FREE" or v.Bottom.Action.Text == "EQUIP") and hasrequiredgamepasses(v.Name) then
			firesignal(v.Bottom.Action.MouseButton1Down)
		end
    end
    if isopen == false then
        modules.gunshopui.close()
    end
end

local function getremainingammo(name)
    local item = invfolder:FindFirstChild(name)
    if item then
        local attr = item:GetAttribute("AmmoCurrent")
        if attr and tonumber(attr) then
            return gundata[name].MagSize - tonumber(attr)
        end
    end
    return math.huge
end

local function getairdrops()
    local count = 0
    for i, v in next, workspace:GetChildren() do
        if v.Name == "Drop" and v.ClassName == "Model" then
            count = count + 1
        end
    end
    return tostring(count)
end

--[[ Setup ]]--

if player.Character and player.Character:FindFirstChild("Humanoid") then
    task.spawn(registerchar, player.Character)
end

for i, v in next, players:GetPlayers() do
    if v ~= player then
        task.spawn(registerplayer, v)
    end
end

for i, v in next, player:GetChildren() do
    if collectionservice:HasTag(v, modules.invconsts.TAG_NAME) then
        invfolder = v
        break
    end
end

for i, v in next, getconnections(runservice.Heartbeat) do
    if v.Function and islclosure(v.Function) then
        local consts = getconstants(v.Function)
        if evov3.utils:tablefind(consts, "Time/UI") then
            timefunc = getupvalue(v.Function, 6)
            slowidx = evov3.utils:tablefind(getconstants(timefunc), 0.5)
        elseif evov3.utils:tablefind(consts, "Vehicle Heartbeat") then
            vehicleclasses = getupvalue(v.Function, 2)
            originals.heliupdate = vehicleclasses.Heli.Update
            isholdingidx = evov3.utils:tablefind(getconstants(originals.heliupdate), 0.65)
        end
    end
end

for i, v in next, garbage.events do
    if type(v) == "function" and islclosure(v) then
        local consts = getconstants(v)
        if evov3.utils:tablefind(consts, "TiresLastPop") then
            clienthashes.tirepop = i
        elseif evov3.utils:tablefind(consts, "Stunned") then
            clienthashes.taze = i
        elseif evov3.utils:tablefind(consts, "PlusCash") then
            clienthashes.pluscash = i
        elseif evov3.utils:tablefind(consts, "FallOutOfSky") then
            clienthashes.fallfromsky = i
        elseif evov3.utils:tablefind(consts, "NitroForceUIUpdate") then
            vehicletable = getupvalue(v, 1)
        elseif evov3.utils:tablefind(consts, "StartThrust") then
            jptable = getupvalue(v, 1)
            originals.jpequip = jptable.EquipLocal
        end
    end
end

for i, v in next, modules.invsystem._equipConditions do
    if type(v) == "function" and islclosure(v) then
        local index = evov3.utils:tablefind(getconstants(v), "IsCrawling")
        if index then
            crawlcondition, crawlidx = v, index
            break
        end
    end
end

for i, v in next, workspace:GetChildren() do
    if v.Name == "Drop" and v.ClassName == "Model" then
        espgroups.airdrop:add(v, { name = "Airdrop" })
    elseif not players:GetPlayerFromCharacter(v) then
		wallbanglist[#wallbanglist + 1] = v
    end
end

for i, v in next, mappoints:GetChildren() do
	v:GetPropertyChangedSignal("Visible"):Connect(function()
		if v.Visible == false and library.flags.minimapshow then
			v.Visible = true
		end
	end)
end

for i, v in next, replicatedstorage.Game:WaitForChild("ItemConfig"):GetChildren() do
    local gun = require(v)
    guntables[v.Name], gundata[v.Name] = gun, evov3.utils:deepclone(gun)
end

for i, v in next, collectionservice:GetTagged("JetPackNoFly") do
    noflyzones[#noflyzones + 1] = v
end

for i, v in next, getupvalue(getconnections(collectionservice:GetInstanceRemovedSignal("_VSID"))[1].Function, 2) do
    if v.Plane then
        if planedata[v.Plane.Model.Name] == nil then
            planedata[v.Plane.Model.Name] = evov3.utils:deepclone(v.Plane.CONST)
        end
        planetables[#planetables + 1] = v.Plane
    end
end

for i, v in next, replicatedstorage.Game.Boat:GetChildren() do
    if v.Name ~= "Boat" then
        boatdata[v.Name] = evov3.utils:deepclone(getupvalue(require(v).new, 2))
    end
end

if originals.getvehiclepacket() then
    local vehicle = originals.getvehiclepacket()
    vehiclestats[vehicle.Model] = evov3.utils:deepclone(vehicle)
end

for i, v in next, modules.gunshoputils.getCategoryData("Projectile") do
    if v.For then
        ammosources[v.For] = v.Name
        ammodrop[#ammodrop + 1] = v.For
    end
end

for i, v in next, modules.vehicledata do
    if v.Type == "Heli" then
        helinames[v.Make] = true
    elseif v.Type == "Chassis" then
        carnames[v.Make] = true
    end
end

modules.gun.SetupBulletEmitter(fakesniper)

local emitconsts = {}
do
    local consts = getconstants(modules.emitter.Update)
    local start = evov3.utils:tablefind(consts, "Magnitude")
    local finish = evov3.utils:tablefind(consts, "OnLocalHitPlayer")
    for i, v in next, consts do
        if i > start and i < finish and type(v) == "number" then
            emitconsts[#emitconsts + 1] = v
        end
    end
end

--[[ GUI ]]--

local aimassistcat = library:addcategory({ content = "Aim Assist" })
local aimbottab = aimassistcat:addtab({ content = "Aimbot" })

local aimbot = aimbottab:addsection({ content = "Main" })
aimbot:addtoggle({ content = "Enabled", flag = "aimbotenabled" })
aimbot:addbind({ content = "Aim Key", default = "MouseButton2", flag = "aimkey" })
aimbot:addtoggle({ content = "Ignore Aim Key", flag = "ignorekey" })
aimbot:addtoggle({ content = "Wall Check", flag = "aimbotwallcheck" })
aimbot:adddropdown({ content = "Aim Part", items = { "HumanoidRootPart", "Head", "Closest Part" }, flag = "aimbotaimpart", default = "HumanoidRootPart" })

local aimbotprecision = aimbottab:addsection({ content = "Precision" })
aimbotprecision:addtoggle({ content = "Movement Prediction", flag = "aimbotpredictmove" })
aimbotprecision:addtoggle({ content = "Drop Compensation", flag = "aimbotcompensatedrop" })
aimbotprecision:addslider({ content = "Smoothness", min = 1, max = 10, float = 0.1, flag = "smoothness" })

local aimbotfov = aimbottab:addsection({ content = "FOV", right = true })
aimbotfov:addtoggleslider({ content = "Value", flag = "aimbotfov", max = 1000, default = 100 })
aimbotfov:addtoggle({ content = "Dynamic", flag = "aimbotfovdynamic" })
aimbotfov:addtoggle({ content = "Visible", flag = "aimbotfovvisible", callback = function(state)
    aimbotfovcircle.Visible = state
end })
aimbotfov:addtoggle({ content = "Filled", flag = "aimbotfovfill", callback = function(state)
    aimbotfovcircle.Filled = state
end })
aimbotfov:addpicker({ content = "Colour", flag = "aimbotfovcolour", default = Color3.fromRGB(230, 33, 237), callback = function(colour)
    aimbotfovcircle.Color = colour
end })
aimbotfov:addslider({ content = "Transparency", max = 1, float = 0.01, flag = "aimbotfovtrans", callback = function(value)
    aimbotfovcircle.Transparency = 1 - value
end })

local silentaimtab = aimassistcat:addtab({ content = "Silent Aim" })
local silentaim = silentaimtab:addsection({ content = "Main" })
silentaim:addtoggle({ content = "Enabled", flag = "silentaimenabled" })
silentaim:addslider({ content = "Hit Chance", flag = "hitchance", default = 100 })
silentaim:addslider({ content = "Headshot Chance", flag = "headshotchance" })
silentaim:addtoggle({ content = "Wall Check", flag = "silentaimwallcheck" })
silentaim:addtoggle({ content = "Movement Prediction", flag = "silentaimpredictmove" })
silentaim:addtoggle({ content = "Drop Compensation", flag = "silentaimcompensatedrop" })
silentaim:adddropdown({ content = "Aim Part", items = { "HumanoidRootPart", "Head", "Closest Part" }, flag = "silentaimaimpart", default = "HumanoidRootPart" })

local silentaimfov = silentaimtab:addsection({ content = "FOV", right = true })
silentaimfov:addtoggleslider({ content = "Value", max = 1000, default = 100, flag = "silentaimfov" })
silentaimfov:addtoggle({ content = "Dynamic", flag = "silentaimfovdynamic" })
silentaimfov:addtoggle({ content = "Visible", flag = "silentaimfovvis", callback = function(state)
    silentaimfovcircle.Visible = state
end })
silentaimfov:addtoggle({ content = "Filled", flag = "silentaimfovfill", callback = function(state)
    silentaimfovcircle.Filled = state
end })
silentaimfov:addpicker({ content = "Colour", flag = "silentaimfovcolour", default = Color3.fromRGB(45, 180, 45), callback = function(colour)
    silentaimfovcircle.Color = colour
end })
silentaimfov:addslider({ content = "Transparency", max = 1, float = 0.01, flag = "silentaimfovtrans", callback = function(value)
    silentaimfovcircle.Transparency = 1 - value
end })

local autofire = silentaimtab:addsection({ content = "Auto Firing", right = true })
autofire:addtoggle({ content = "Triggerbot", flag = "triggerbot" })
autofire:addtoggle({ content = "Auto Shoot", flag = "autoshoot" })
autofire:addtoggle({ content = "Auto Wallbang", flag = "autowall" })

local visualscat = library:addcategory({ content = "Visuals" })
local esptab = visualscat:addtab({ content = "Player ESP" })

local playeresp = esptab:addsection({ content = "Main" })
playeresp:addchecklist({ content = "Master Switches", flag = "espenabled", items = { { "Prisoner" }, { "Criminal" }, { "Police" } }, callback = function(value, state)
    espgroups[string.lower(value)].settings.enabled = state
end })
playeresp:addtoggle({ content = "Show Names", flag = "espnames", callback = function(state)
    espgroups.prisoner.settings.names = state
    espgroups.criminal.settings.names = state
    espgroups.police.settings.names = state
end })
playeresp:addtoggle({ content = "Show Boxes", flag = "espboxes", callback = function(state)
    espgroups.prisoner.settings.boxes = state
    espgroups.criminal.settings.boxes = state
    espgroups.police.settings.boxes = state
end })
playeresp:addtoggle({ content = "Show Skeletons", flag = "espskeletons", callback = function(state)
    espgroups.prisoner.settings.skeletons = state
    espgroups.criminal.settings.skeletons = state
    espgroups.police.settings.skeletons = state
end })
playeresp:addtoggle({ content = "Show Health Bars", flag = "espbars", callback = function(state)
    espgroups.prisoner.settings.bars = state
    espgroups.criminal.settings.bars = state
    espgroups.police.settings.bars = state
end })
playeresp:addtoggle({ content = "Show Distances", flag = "espdistances", callback = function(state)
    espgroups.prisoner.settings.distances = state
    espgroups.criminal.settings.distances = state
    espgroups.police.settings.distances = state
end })
playeresp:addtoggle({ content = "Show Equipped", flag = "espequipped", callback = function(state)
    espgroups.prisoner.settings.equipped = state
    espgroups.criminal.settings.equipped = state
    espgroups.police.settings.equipped = state
end })
playeresp:addtoggle({ content = "Show Vehicle", flag = "espvehicle", callback = function(state)
    espgroups.prisoner.settings.vehicle = state
    espgroups.criminal.settings.vehicle = state
    espgroups.police.settings.vehicle = state
end })
playeresp:addtoggle({ content = "Show Tracers", flag = "esptracers", callback = function(state)
    espgroups.prisoner.settings.tracers = state
    espgroups.criminal.settings.tracers = state
    espgroups.police.settings.tracers = state
end })
playeresp:addtoggle({ content = "Show Offscreen Arrows", flag = "esparrows", callback = function(state)
    espgroups.prisoner.settings.offscreenarrows = state
    espgroups.criminal.settings.offscreenarrows = state
    espgroups.police.settings.offscreenarrows = state
end })

local playerespsettings = esptab:addsection({ content = "Settings", right = true })
playerespsettings:addtoggle({ content = "Use Display Names", flag = "espdisplay", callback = function(state)
    espgroups.prisoner:updatenames(state)
    espgroups.criminal:updatenames(state)
    espgroups.police:updatenames(state)
end })
playerespsettings:addslider({ content = "Thickness", min = 1, max = 10, default = 1, flag = "espthickness", callback = function(value)
    espgroups.prisoner:updatethickness(value)
    espgroups.criminal:updatethickness(value)
    espgroups.police:updatethickness(value)
end })
playerespsettings:addslider({ content = "Text Size", min = 8, max = 32, default = 14, flag = "espsize", callback = function(value)
    espgroups.prisoner:updatetextsize(value)
    espgroups.criminal:updatetextsize(value)
    espgroups.police:updatetextsize(value)
end })

if Drawing.Fonts then
    playerespsettings:adddropdown({ content = "Font", flag = "espfont", items = evov3.utils:keytoarray(Drawing.Fonts), default = "System", callback = function(value)
        espgroups.prisoner:updatefont(Drawing.Fonts[value])
        espgroups.criminal:updatefont(Drawing.Fonts[value])
        espgroups.police:updatefont(Drawing.Fonts[value])
    end })
end

local esparrows = esptab:addsection({ content = "Arrows", right = true })
esparrows:addslider({ content = "Arrow Height", min = 1, max = 50, default = 18, flag = "arrowheight", callback = function(value)
    espgroups.prisoner.settings.arrowheight = value
    espgroups.criminal.settings.arrowheight = value
    espgroups.police.settings.arrowheight = value
end })
esparrows:addslider({ content = "Arrow Width", min = 8, max = 50, default = 12, flag = "arrowwidth", callback = function(value)
    espgroups.prisoner.settings.arrowwidth = value
    espgroups.criminal.settings.arrowwidth = value
    espgroups.police.settings.arrowwidth = value
end })
esparrows:addslider({ content = "Arrow Center Offset", min = 0, max = 250, default = 120, flag = "arrowoffset", callback = function(value)
    espgroups.prisoner.settings.arrowoffset = value
    espgroups.criminal.settings.arrowoffset = value
    espgroups.police.settings.arrowoffset = value
end })

local espcolours = esptab:addsection({ content = "Colours" })
espcolours:addtoggle({ content = "Custom Colours", flag = "espcolours", callback = function(state)
    espgroups.prisoner:togglecustomcolours(state)
    espgroups.criminal:togglecustomcolours(state)
    espgroups.police:togglecustomcolours(state)
end })
espcolours:addpicker({ content = "Friendly Colour", flag = "espfriendlycolour", default = espgroups.prisoner.settings.friendlycolour, callback = function(colour)
    espgroups.prisoner:updatecustomcolour(colour, true)
    espgroups.criminal:updatecustomcolour(colour, true)
    espgroups.police:updatecustomcolour(colour, true)
end })
espcolours:addpicker({ content = "Enemy Colour", flag = "espenemycolour", default = espgroups.prisoner.settings.enemycolour, callback = function(colour)
    espgroups.prisoner:updatecustomcolour(colour, false)
    espgroups.criminal:updatecustomcolour(colour, false)
    espgroups.police:updatecustomcolour(colour, false)
end })

local itemesptab = visualscat:addtab({ content = "Item ESP" })
local airdrops = itemesptab:addsection({ content = "Airdrops" })
airdrops:addtoggle({ content = "Master Switch", flag = "airdropenabled", callback = function(state)
    espgroups.airdrop.settings.enabled = state
end })
airdrops:addtoggle({ content = "Show Names", flag = "airdropnames", callback = function(state)
    espgroups.airdrop.settings.names = state
end })
airdrops:addtoggle({ content = "Show Distances", flag = "airdropdistances", callback = function(state)
    espgroups.airdrop.settings.distances = state
end })
airdrops:addpicker({ content = "Colour", flag = "droppedcolour", default = Color3.new(1, 1, 1), callback = function(colour)
    espgroups.airdrop:updatecustomcolour(colour)
end })

local uitab = visualscat:addtab({ content = "UI" })
local triggers = uitab:addsection({ content = "Triggers" })
triggers:addbox({ content = "Fireworks", ignore = true, numonly = true, callback = function(value)
    if value ~= "" then
        originals.fireworks(tonumber(value))
    end
end })
triggers:addbox({ content = "Give Cash", ignore = true, numonly = true, callback = function(value)
    if value ~= "" then
        garbage.events[clienthashes.pluscash](tonumber(value), "If only it was real")
    end
end })

local minimaps = uitab:addsection({ content = "Minimap", right = true })
minimaps:addtoggle({ content = "Minimap Show All", flag = "minimapshow", callback = function(state)
    for i, v in next, mappoints:GetChildren() do
		if v.Name ~= "_you" then
            v.Visible = state or players[v.Name].Team == player.Team
        end
	end
end })

local codes = uitab:addsection({ content = "Codes", right = true })
codes:addbutton({ content = "Redeem All Codes", callback = function()
    local content = game:HttpGetAsync("https://jailbreak.fandom.com/wiki/ATMs_%26_Codes", true)
    local subbedcontent = string.sub(content, 1, string.find(content, "<b>Invalid codes</b> are codes that have expired and cannot be redeemed.</i>"))
    for match in string.gmatch(subbedcontent, "<tr>[%s*]<td>(.+)</td></tr>") do
        local code = string.split(match, "\n")[1]
        if not string.find(code, "no active codes") then
            codecontainer.CodeContainer.Code.Text = code
            firesignal(codecontainer.Redeem.MouseButton1Down)
        end
    end
end })

local playercat = library:addcategory({ content = "Players" })
local playertab = playercat:addtab({ content = "Local Player" })

local charvalues = playertab:addsection({ content = "Values" })
charvalues:addtoggleslider({ content = "WalkSpeed", flag = "walkspeed", min = 16, max = 150, onstatechanged = function(state)
    if hum then
        hum.WalkSpeed = state and library.flags.walkspeed.value or 16
    end
end, onvaluechanged = function(value)
    if hum and library.flags.walkspeed.enabled then
        hum.WalkSpeed = value
    end
end })
charvalues:addtoggleslider({ content = "JumpPower", flag = "jumppower", min = 50, max = 200, onstatechanged = function(state)
    if hum then
        hum.JumpPower = state and library.flags.jumppower.value or 50
    end
end, onvaluechanged = function(value)
    if hum and library.flags.jumppower.enabled then
        hum.JumpPower = value
    end
end })
charvalues:addbind({ content = "Fly", flag = "fly", onkeydown = function()
	isflying = not isflying
	if isflying then
		maids.fly:givetask(runservice.RenderStepped:Connect(function()
			if root and not originals.getvehiclepacket() then
				local flyvec = Vector3.new()
                if flykeys.W then
                    flyvec = flyvec + cam.CFrame.LookVector
                end
                if flykeys.A then
                    flyvec = flyvec - cam.CFrame.RightVector
                end
                if flykeys.S then
                    flyvec = flyvec - cam.CFrame.LookVector
                end
                if flykeys.D then
                    flyvec = flyvec + cam.CFrame.RightVector
                end
                flyvec = flyvec == Vector3.new() and baseflyvec or flyvec
                if flykeys.Space and not flykeys.LeftShift then
                    flyvec = flyvec + Vector3.new(0, 1, 0)
                elseif flykeys.LeftShift and not flykeys.Space then
                    flyvec = flyvec + Vector3.new(0, -1, 0)
                end
                root.Velocity = flyvec.Unit * library.flags.flyspeed
                root.Anchored = flyvec == baseflyvec
			end
		end))
    else
        maids.fly:dispose()
        if root and root.Anchored then
            root.Anchored = false
            root.Velocity = baseflyvec
        end
	end
end })
charvalues:addslider({ content = "Fly Speed", min = 16, max = 150, default = 150, flag = "flyspeed" })

local charmods = playertab:addsection({ content = "Modifications", right = true })
charmods:addtoggle({ content = "Infinite Jump", flag = "infjump" })
charmods:addtoggle({ content = "Anti Ragdoll", flag = "noragdoll" })
charmods:addtoggle({ content = "Anti Fall Damage", flag = "nofalldamage" })
charmods:addtoggle({ content = "Anti Skydive", flag = "noskydive" })
charmods:addtoggle({ content = "Anti Taze", flag = "notaze" })
charmods:addtoggle({ content = "Anti Injury Slow", flag = "noinjuredslow", callback = function(state)
    setconstant(timefunc, slowidx, state and 1 or 0.5)
end })
charmods:addtoggle({ content = "No 'E' Wait", flag = "nocirclewait" })
charmods:addtoggle({ content = "No Punch Cooldown", flag = "nopunchcooldown", callback = function(state)
    setconstant(defaultactions.attemptPunch, punchidx, state and 0 or 0.5)
end })
charmods:addtoggle({ content = "No Crawl Cooldown", flag = "nocrawlcooldown" })

local plrcosmetics = playertab:addsection({ content = "Cosmetic" })
plrcosmetics:addtoggle({ content = "FE Orange Justice", flag = "orangejustice", callback = function(state)
    if state then
        orangejustice()
    elseif ojtrack then
        ojtrack:Stop()
        ojtrack = nil
    end
end })
plrcosmetics:addbutton({ content = "Give Police Uniform", callback = function()
    local uniform = { ShirtPolice = true, PantsPolice = true, HatPolice = true }
	for i, v in next, workspace.Givers:GetChildren() do
		if uniform[v.Item.Value] then
			uniform[v.Item.Value] = nil
			fireclickdetector(v.ClickDetector)
			task.wait(0.25)
		end
	end
end })
plrcosmetics:addbutton({ content = "Remove Outfit", callback = function()
    fireclickdetector(workspace.ClothingRacks.ClothingRack.Hitbox.ClickDetector)
end })

local vehiclecat = library:addcategory({ content = "Vehicles" })
local landvehicletab = vehiclecat:addtab({ content = "Land" })

local landvalues = landvehicletab:addsection({ content = "Values" })
landvalues:addslider({ content = "Engine Speed", flag = "carspeed", callback = function(value)
    updatevehicle("GarageEngineSpeed", value)
end })
landvalues:addslider({ content = "Brakes", flag = "brakes", callback = function(value)
    updatevehicle("GarageBrakes", value)
end })
landvalues:addslider({ content = "Suspension Height", flag = "suspension", callback = function(value)
    updatevehicle("Height", value)
end })
landvalues:addslider({ content = "Turn Speed", flag = "turnspeed", max = 10, float = 0.1, callback = function(value)
    updatevehicle("TurnSpeed", value)
end })

local landmods = landvehicletab:addsection({ content = "Modifications", right = true })
landmods:addtoggle({ content = "Infinite Nitro", flag = "infnitro", callback = function(state)
    if state then
        maids.nitro:givetask(runservice.Heartbeat:Connect(function()
            vehicletable.Nitro = 250
        end))
    else
        maids.nitro:dispose()
    end
end })
landmods:addtoggle({ content = "Instant Tow", flag = "instanttow" })
landmods:addtoggle({ content = "Drive on Water", flag = "driveonwater" })
landmods:addtoggle({ content = "Auto Flip Over", flag = "autoflip", callback = function(state)
    if state then
        maids.flip:givetask(runservice.Heartbeat:Connect(function()
            if originals.getvehiclepacket() then
                for i, v in next, modules.actionbuttons.active do
                    if evov3.utils:tablefind(v.keyCodes, Enum.KeyCode.V) then
                        v.onPressed()
                        break
                    end
                end
            end
        end))
    else
        maids.flip:dispose()
    end
end })
landmods:addtoggle({ content = "Anti Tire Pop", flag = "antitirepop" })
landmods:addtoggle({ content = "Injan Horn", flag = "injanhorn" })
landmods:addtoggle({ content = "Epileptic Headlights", flag = "flashlights", callback = function(state)
    if state then
        maids.lights:givetask(runservice.Heartbeat:Connect(function()
            local vehicle = originals.getvehiclepacket()
            if vehicle and vehicle.Type == "Chassis" then
                modules.chassis.toggleHeadlights()
            end
        end))
    else
        maids.lights:dispose()
    end
end })

local landoffense = landvehicletab:addsection({ content = "Offense" })
landoffense:addtoggle({ content = "Pop All Tires [250m]", flag = "poptires", callback = function(state)
    if state then
        local debounce = false
        maids.shootcars:givetask(runservice.Heartbeat:Connect(function()
            if debounce == false then
                for i, v in next, workspace.Vehicles:GetChildren() do
                    if carnames[v.Name] and isvehicleshootable(v, library.flags.tireteamcheck) and v.WheelFrontLeft.Wheel.Transparency == 0 then
                        debounce = true
                        for _ = 1, 2 do
                            shootvehicle(v.Engine)
                            task.wait(0.25)
                        end
                        debounce = false
                    end
                end
            end
        end))
    else
        maids.shootcars:dispose()
    end
end })
landoffense:addtoggle({ content = "Team Check", flag = "tireteamcheck" })

local airvehicletab = vehiclecat:addtab({ content = "Air" })

local helivalues = airvehicletab:addsection({ content = "Heli Values" })
helivalues:addslider({ content = "Engine Speed", flag = "helispeed" })

local helimods = airvehicletab:addsection({ content = "Heli Mods" })
helimods:addtoggle({ content = "Instant Pickup", flag = "instantpickup" })
helimods:addtoggle({ content = "Infinite Heli Height", flag = "infheliheight" })
helimods:addtoggle({ content = "Infinite Drone Height", flag = "infdroneheight" })
helimods:addtoggle({ content = "Anti Shoot Down", flag = "antihelicrash" })
helimods:addtoggle({ content = "Anti Carry Slow", flag = "nohelislow", callback = function(state)
    setconstant(originals.heliupdate, isholdingidx, state and 1 or 0.65)
end })

local planevalues = airvehicletab:addsection({ content = "Plane Values", right = true })
planevalues:addslider({ content = "Engine Speed", flag = "planespeed", callback = function(value)
    for i, v in next, planetables do
		v.CONST.MAX_THRUST = planedata[v.Model.Name].MAX_THRUST * (1 + (value / 2.5))
	end
end })

local planemods = airvehicletab:addsection({ content = "Plane Mods", right = true })
planemods:addtoggle({ content = "Infinite Height", flag = "infplaneheight", callback = function(state)
    for i, v in next, planetables do
		v.CONST.HEIGHT_MAX = state and math.huge or planedata[v.Model.Name].HEIGHT_MAX
	end
end })
planemods:addtoggle({ content = "No Roll Correction", flag = "norollcorrection", callback = function(state)
    for i, v in next, planetables do
		v.CONST.ROLL_ADJUSTMENT_TIMER = state and math.huge or planedata[v.Model.Name].ROLL_ADJUSTMENT_TIMER
	end
end })

local airoffense = airvehicletab:addsection({ content = "Offense", right = true })
airoffense:addtoggle({ content = "Shoot All Helis [250m]", flag = "shoothelis", callback = function(state)
    if state then
        local debounce = false
        maids.shoothelis:givetask(runservice.Heartbeat:Connect(function()
            if debounce == false then
                for i, v in next, workspace.Vehicles:GetChildren() do
                    if helinames[v.Name] and isvehicleshootable(v, library.flags.heliteamcheck) and v.Model.Body.Smoke.Enabled == false then
                        debounce = true
                        for _ = 1, 2 do
                            shootvehicle(v.Engine)
                            task.wait(0.25)
                        end
                        debounce = false
                    end
                end
            end
        end))
    else
        maids.shoothelis:dispose()
    end
end })
airoffense:addtoggle({ content = "Team Check", flag = "heliteamcheck" })

local seavehicletab = vehiclecat:addtab({ content = "Sea" })

local boatvalues = seavehicletab:addsection({ content = "Boat Values" })
boatvalues:addslider({ content = "Engine Speed", flag = "boatspeed" })

local boatmods = seavehicletab:addsection({ content = "Boat Mods", right = true })
boatmods:addtoggle({ content = "Boats on Land", flag = "boatsonland", callback = function(state)
    setconstant(originals.boatupdate, boatidx, state and 1 or 0.3)
end })
boatmods:addtoggle({ content = "JetSki on Land", flag = "jetskionland", callback = function(state)
    setconstant(garbage.jetskiupdate, jetskiidx, state and 1 or 0.3)
end })

local itemscat = library:addcategory({ content = "Items" })
local weapontab = itemscat:addtab({ content = "Weapons" })

local gunmods = weapontab:addsection({ content = "Gun Mods" })
gunmods:addtoggle({ content = "Instant Hit", flag = "instanthit" })
gunmods:addtoggle({ content = "Full Automatic", flag = "fullauto", callback = function(state)
    for i, v in next, guntables do
        v.FireAuto = state or gundata[i].FireAuto
    end
end })
gunmods:addtoggle({ content = "No Bullet Drop", flag = "nobulletdrop", callback = function(state)
    local equipped = modules.itemsystem.GetLocalEquipped()
    if equipped and equipped.BulletEmitter then
        equipped.BulletEmitter.GravityVector = not state and Vector3.new(0, -workspace.Gravity / 10, 0) or nil
    end
end })
gunmods:addtoggle({ content = "No Flintlock Knockback", flag = "noflintknock" })
gunmods:addtoggle({ content = "Wallbang", flag = "wallbang", callback = function(state)
    local equipped = modules.itemsystem.GetLocalEquipped()
    if equipped then
        if equipped.BulletEmitter then
            equipped.BulletEmitter.IgnoreList = state and wallbanglist or { char, equipped.Model, workspace.Items }
        elseif equipped.IgnoreList then -- taser being special
            equipped.IgnoreList = state and wallbanglist or { char, equipped.Model }
        end
    end
end })
gunmods:addslider({ content = "Recoil Reduction", flag = "recoilpercent", callback = function(value)
    for i, v in next, guntables do
        if v.CamShakeMagnitude then
            v.CamShakeMagnitude = gundata[i].CamShakeMagnitude * (1 - (value / 100))
        end
    end
end })
gunmods:addslider({ content = "Spread Reduction", flag = "spreadpercent", callback = function(value)
    for i, v in next, guntables do
        if v.BulletSpread then
            v.BulletSpread = gundata[i].BulletSpread * (1 - (value / 100))
        end
    end
end })

local rapidfire = weapontab:addsection({ content = "Rapid Fire" })
rapidfire:addtoggle({ content = "Enabled", flag = "rapidfire", callback = function(state)
    for i, v in next, guntables do
        if gundata[i].FireFreq then
            v.FireFreq = state and (library.flags.firerateadditive and gundata[i].FireFreq + library.flags.firerate / 60 or library.flags.firerate / 60) or gundata[i].FireFreq
        end
    end
end })
rapidfire:addtoggle({ content = "Add To Default Rate", flag = "firerateadditive", callback = function(state)
    for i, v in next, guntables do
        if gundata[i].FireFreq then
            v.FireFreq = library.flags.rapidfire and (state and gundata[i].FireFreq + library.flags.firerate / 60 or library.flags.firerate / 60) or gundata[i].FireFreq
        end
    end
end })
rapidfire:addslider({ content = "Value", max = 2500, flag = "firerate", callback = function(value)
    for i, v in next, guntables do
        if gundata[i].FireFreq then
            v.FireFreq = library.flags.rapidfire and (library.flags.firerateadditive and gundata[i].FireFreq + value / 60 or value / 60) or gundata[i].FireFreq
        end
    end
end })

local givers = weapontab:addsection({ content = "Givers", right = true })
givers:addbutton({ content = "Give All Guns", callback = function()
    grabfromshop("Held", "All")
end })
givers:adddropdown({ content = "Choose Ammo", flag = "ammochoice", items = ammodrop })
givers:addslider({ content = "Amount to Purchase", min = 1, max = 10, flag = "ammoamount" })
givers:addbutton({ content = "Purchase Ammo", callback = function()
    for i = 1, math.min(getremainingammo(library.flags.ammochoice), library.flags.ammoamount) do
        print(i)
        grabfromshop("Projectile", ammosources[library.flags.ammochoice])
    end
end })

local mobility = weapontab:addsection({ content = "Mobility", right = true })
mobility:addtoggle({ content = "Shoot While Driving", flag = "driveshoot" })
mobility:addtoggle({ content = "Shoot While Crawling", flag = "crawlshoot", callback = function(state)
    setconstant(crawlcondition, crawlidx, state and "Nope" or "IsCrawling")
end })
mobility:addtoggle({ content = "Shoot While Jetpacking", flag = "jpshoot" })

local safestab = itemscat:addtab({ content = "Safes" })
local opening = safestab:addsection({ content = "Opening" })
opening:addbutton({ content = "Open All Safes", callback = function()
    if isopeningsafes == false then
        isopeningsafes = true
        while #modules.store._state.safesInventoryItems > 0 do
            replicatedstorage[modules.safeconsts.SAFE_OPEN_REMOTE_NAME]:FireServer(modules.store._state.safesInventoryItems[1].itemOwnedId)
            task.wait(3)
        end
        isopeningsafes = false
    end
end })

local buying = safestab:addsection({ content = "Buying", right = true })
buying:addslider({ content = "Tier", min = 1, max = #modules.safeconsts.SAFE_DATA, flag = "buyrarity", callback = function(value)
    local cost = modules.safeconsts.SAFE_DATA[value].Price * library.flags.buyamount
    library.items.predictedcost:update(evov3.utils:formatmoney(cost), cost <= moneystat.Value and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36))
end })
buying:addslider({ content = "Amount", min = 0, max = 100, flag = "buyamount", callback = function(value)
    local cost = modules.safeconsts.SAFE_DATA[library.flags.buyrarity].Price * value
    library.items.predictedcost:update(evov3.utils:formatmoney(cost), cost <= moneystat.Value and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36))
end })
buying:addstatuslabel({ content = "Predicted Cost", flag = "predictedcost", status = "$0", colour = Color3.fromRGB(15, 180, 85) })
buying:addbutton({ content = "Buy Safes", callback = function()
    for i = 1, library.flags.buyamount do
        replicatedstorage[modules.safeconsts.SAFE_PURCHASE_REMOTE_NAME]:FireServer(library.flags.buyrarity)
    end
end })

local otheritemstab = itemscat:addtab({ content = "Other" })
local jetpack = otheritemstab:addsection({ content = "JetPack" })
jetpack:addtoggle({ content = "Infinite Fuel", flag = "inffuel", callback = function(state)
    repeat task.wait()
        if equippedjp then
            local fuel = modules.jputil.Fuel[library.flags.premfuel and "Rocket" or "Standard"].MaxFuel
            equippedjp.Fuel, equippedjp.MaxFuel = fuel, fuel
        end
    until library.flags.inffuel == false
end })
jetpack:addtoggle({ content = "Premium Fuel", flag = "premfuel", callback = function(state)
    if equippedjp then
        equippedjp.FuelType = state and "Rocket" or "Standard"
        local fueldata = modules.jputil.Fuel[equippedjp.FuelType]
        equippedjp.Fuel = math.min(equippedjp.Fuel, fueldata.MaxFuel)
        equippedjp.MaxFuel = fueldata.MaxFuel
        equippedjp.Model.LeftSmoke.Fire.Color = fueldata.ParticleColor
        equippedjp.Model.RightSmoke.Fire.Color = fueldata.ParticleColor
        equippedjp.LeanAngle = fueldata.LeanAngle
        modules.jpgui.SetFuelType(equippedjp.FuelType)
    end
end })
jetpack:addtoggle({ content = "Bypass No Fly Zones", flag = "bypassnofly", callback = function(state)
    for i, v in next, noflyzones do
        if state then
            collectionservice:RemoveTag(v, "JetPackNoFly")
        else
            collectionservice:AddTag(v, "JetPackNoFly")
        end
    end
end })

local robberycat = library:addcategory({ content = "Robberies" })
local robtab = robberycat:addtab({ content = "Robbery Helpers" })

local robberyindicators = robtab:addsection({ content = "Statuses" })
roblabels.Bank = robberyindicators:addstatuslabel({ content = "Bank", status = robstates.Bank and "Open" or "Closed", colour = robstates.Bank and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Jewelry = robberyindicators:addstatuslabel({ content = "Jewelry", status = robstates.Jewelry and "Open" or "Closed", colour = robstates.Jewelry and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Museum = robberyindicators:addstatuslabel({ content = "Museum", status = robstates.Museum and "Open" or "Closed", colour = robstates.Museum and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.PowerPlant = robberyindicators:addstatuslabel({ content = "Power Plant", status = robstates.PowerPlant and "Open" or "Closed", colour = robstates.PowerPlant and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Tomb = robberyindicators:addstatuslabel({ content = "Tomb", status = robstates.Tomb and "Open" or "Closed", colour = robstates.Tomb and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Casino = robberyindicators:addstatuslabel({ content = "Casino", status = robstates.Casino and "Open" or "Closed", colour = robstates.Casino and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.TrainPassenger = robberyindicators:addstatuslabel({ content = "Passenger Train", status = robstates.TrainPassenger and "Open" or "Closed", colour = robstates.TrainPassenger and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.TrainCargo = robberyindicators:addstatuslabel({ content = "Cargo Train", status = robstates.TrainCargo and "Open" or "Closed", colour = robstates.TrainCargo and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.CargoPlane = robberyindicators:addstatuslabel({ content = "Cargo Plane", status = robstates.CargoPlane and "Open" or "Closed", colour = robstates.CargoPlane and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.CargoShip = robberyindicators:addstatuslabel({ content = "Cargo Ship", status = robstates.CargoShip and "Open" or "Closed", colour = robstates.CargoShip and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.MoneyTruck = robberyindicators:addstatuslabel({ content = "Money Truck", status = robstates.MoneyTruck and "Open" or "Closed", colour = robstates.MoneyTruck and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Donut = robberyindicators:addstatuslabel({ content = "Donut Store", status = robstates.Donut and "Open" or "Closed", colour = robstates.Donut and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Gas = robberyindicators:addstatuslabel({ content = "Gas Station", status = robstates.Gas and "Open" or "Closed", colour = robstates.Gas and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
roblabels.Airdrops = robberyindicators:addstatuslabel({ content = "Airdrops", status = getairdrops() })

local robmods = robtab:addsection({ content = "Helpers", right = true })
robmods:addtoggle({ content = "Auto Solve Puzzles", flag = "solvepuzzles", callback = function(state)
    if state and puzzle.IsOpen then
        solvepuzzle()
    end
end })
robmods:addtoggle({ content = "No Museum Detection", flag = "nomuseumdetection" })
robmods:addtoggle({ content = "No Spike Damage", flag = "nospikedamage", callback = function(state)
    local spikes = collectionservice:GetTagged("TombSpike")
    for i = 1, #spikes do
        setconstant(getconnections(spikes[i].InnerModel.Door.Touched)[1].Function, 6, state and math.huge or 0.5)
    end
end })
robmods:addtoggle({ content = "Disable Ship Turrets", flag = "noshipturrets" })
robmods:addtoggle({ content = "Disable Dart Dispensers", flag = "nodarts" })
robmods:addtoggle({ content = "Disable Bandit Targeting", flag = "nobandits" })

local othercat = library:addcategory({ content = "Other" })
local maptab = othercat:addtab({ content = "Map" })

local doors = maptab:addsection({ content = "Doors" })
doors:addtoggle({ content = "Unlock All Doors", flag = "bypassdoors" })
doors:addtoggle({ content = "Loop Open Doors", flag = "opendoors", callback = function(state)
    if state then
        maids.doors:givetask(runservice.Heartbeat:Connect(opendoors))
    else
        maids.doors:dispose()
    end
end })
doors:addbutton({ content = "Open All Doors", callback = opendoors })

local wall = maptab:addsection({ content = "Wall", right = true })
wall:addtoggle({ content = "Loop Explode Wall", flag = "loopexplode" })
wall:addbutton({ content = "Explode Wall", callback = explodewall })

local gate = maptab:addsection({ content = "Gate", right = true })
gate:addtoggle({ content = "Loop Lift Gate", flag = "loopgate" })
gate:addbutton({ content = "Lift Gate", callback = liftgate })

local volcano = maptab:addsection({ content = "Volcano" })
volcano:addtoggle({ content = "Loop Erupt Volcano", flag = "loopvolcano" })
volcano:addbutton({ content = "Erupt Volcano", callback = function()
    firetouch(workspace.LavaFun.Lavatouch)
end })

local sewers = maptab:addsection({ content = "Sewers", right = true })
sewers:addtoggle({ content = "Loop Open Sewers", flag = "loopsewers" })
sewers:addbutton({ content = "Open All Sewers", callback = opensewers })

local mapmisc = maptab:addsection({ content = "Misc" })
mapmisc:addtoggle({ content = "Disable Military Turrets", flag = "nomilitaryturrets" })
mapmisc:addbutton({ content = "Score Football Goal", callback = function()
    if isnetworkowner(workspace.SoccerBall) then
        workspace.SoccerBall.CFrame = CFrame.new(1138.1, 108.2, 1106.1)
    else
        modules.notification.new({ Text = "Get closer to the ball and try again" })
    end
end })

--[[ Hooks ]]--

modules.boat.UpdatePhysics = newcclosure(function(self, ...)
	if library.flags.boatspeed > 0 then
        self.Config.SpeedForward = boatdata[self.Model.Name].SpeedForward + (library.flags.boatspeed / 20)
    end
	originals.boatupdate(self, ...)
end)

modules.dispenser._fire = newcclosure(function(...)
    if library.flags.nodarts == false then
        originals.dispenserfire(...)
    end
end)

modules.emitter.Emit = newcclosure(function(self, ...)
    if self.Local then
        local target, args = silentaimtarget, {...}
        if library.flags.rapidfire then
            self.LastImpact = 0
        end
        if library.flags.silentaimenabled and target and math.random(1, 100) <= library.flags.hitchance then
            local pos = (math.random(1, 100) <= library.flags.headshotchance and target.part.Parent.Head or target.part).Position
            local dur = (pos - args[1]).Magnitude / modules.itemsystem.GetLocalEquipped().Config.BulletSpeed
            if library.flags.silentaimpredictmove then
                pos = pos + (target.part.Parent.HumanoidRootPart.Velocity * dur)
            end
            if library.flags.silentaimcompensatedrop then
                pos = pos + Vector3.new(0, (workspace.Gravity / 20) * dur ^ 2, 0)
            end
            args[2] = (pos - args[1]).Unit
        end
        if library.flags.instanthit then
            args[3] = 9e9
        end
        originals.emit(self, unpack(args))
    end
end)

modules.gun.BulletEmitterOnLocalHitPlayer = newcclosure(function(self, ...)
    if library.flags.instanthit then
        local args = {...}
        local target = args[1].Parent.HumanoidRootPart
	    local dur = (target.Position - root.Position).Magnitude / modules.itemsystem.GetLocalEquipped().Config.BulletSpeed
        args[5] = dur * emitconsts[1]
		args[8] = dur * emitconsts[4]
		args[13] = dur * emitconsts[7]
        return originals.bullethit(self, unpack(args))
    end
    return originals.bullethit(self, ...)
end)

modules.plasma.ShootOther = newcclosure(function(self, ...)
	if self.Local then
		if library.flags.silentaimenabled and target and math.random(1, 100) <= library.flags.hitchance then
            local pos = (math.random(1, 100) <= library.flags.headshotchance and target.part.Parent.Head or target.part).Position
            local dur = (pos - self.Tip.Position).Magnitude / self.Config.BulletSpeed
            if library.flags.silentaimpredictmove then
                pos = pos + (target.part.Parent.HumanoidRootPart.Velocity * dur)
            end
            if library.flags.silentaimcompensatedrop then
                pos = pos + Vector3.new(0, (workspace.Gravity / 20) * dur ^ 2, 0)
            end
            self.MousePosition = pos
        end
	end
	originals.plasmashoot(self, ...)
end)

modules.basic.UpdateMousePosition = newcclosure(function(self, ...)
    if library.flags.silentaimenabled and target and math.random(1, 100) <= library.flags.hitchance and string.find(traceback(), "Tase") then
        self.MousePosition = (math.random(1, 100) <= library.flags.headshotchance and target.part.Parent.Head or target.part).Position
        return
    end
    return originals.updatemousepos(self, ...)
end)

modules.itemcamera.Update = newcclosure(function(...)
    originals.camupdate(...)
    if library.flags.aimbotenabled and mouse.Hit and (isaimkeydown or library.flags.ignorekey) then
        local equipped = modules.itemsystem.GetLocalEquipped()
        local aimbottarget = getaimbottarget(equipped)
        if aimbottarget then
            local pos = cam:WorldToScreenPoint(getaimbotposition(aimbottarget, equipped))
            local mousepos = cam:WorldToScreenPoint(mouse.Hit.Position)
            local movevec = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousepos.X, mousepos.Y)) / (library.flags.smoothness * 5)
            mousemoverel(movevec.X, movevec.Y)
        end
    end
end)

modules.falling.StartRagdolling = newcclosure(function(...)
    if not (isflying or library.flags.noragdoll) then
        originals.ragdoll(...)
    end
end)

modules.guardnpc.canSeeTarget = newcclosure(function(...)
    if library.flags.nobandits == false then
        return originals.guardtarget(...)
    end
    return false
end)

modules.jetpack.IsFlying = newcclosure(function()
	if library.flags.jpshoot and string.find(debug.traceback(), "InventoryItemSystem") then
		return false
	end
	return originals.isflying()
end)

modules.militaryturret._fire = newcclosure(function(...)
    if library.flags.nomilitaryturrets == false then
        originals.militaryfire(...)
    end
end)

modules.plane.FromPacket = newcclosure(function(...)
	local packet = originals.planepacket(...)
    if planedata[packet.Model.Name] == nil then
        planedata[packet.Model.Name] = evov3.utils:deepclone(packet.CONST)
    end
	planetables[#planetables + 1] = packet
	if library.flags.planespeed > 0 then
        packet.CONST.MAX_THRUST = packet.CONST.MAX_THRUST * (1 + (library.flags.planespeed / 2.5))
    end
	if library.flags.infplaneheight then
		packet.CONST.HEIGHT_MAX = math.huge
	end
    if library.flags.norollcorrection then
        packet.CONST.ROLL_ADJUSTMENT_TIMER = math.huge
    end
	return packet
end)

modules.plrutils.hasKey = newcclosure(function(...)
    return library.flags.bypassdoors or originals.haskey(...)
end)

modules.plrutils.isPointInTag = newcclosure(function(pos, tag)
    if tag == "NoRagdoll" and (isflying or library.flags.noragdoll) then
        return true
    elseif tag == "NoFallDamage" and (isflying or library.flags.nofalldamage) then
        return true
    elseif tag == "NoParachute" and (isflying or library.flags.noskydive) then
        return true
    end
    return originals.pointintag(pos, tag)
end)

modules.shipturret.Shoot = newcclosure(function(...)
    if library.flags.noshipturrets == false then
        originals.shipshoot(...)
    end
end)

modules.vehicle.GetLocalVehiclePacket = newcclosure(function()
	if library.flags.driveshoot and string.find(debug.traceback(), "InventoryItemSystem") then
		return
	end
	return originals.getvehiclepacket()
end)

modules.chassis.VehicleEnter = newcclosure(function(self, ...)
    originals.entervehicle(self, ...)
    if not self.Passenger then
        vehiclestats[self.Model] = evov3.utils:deepclone(self)
        self.GarageEngineSpeed = self.GarageEngineSpeed + library.flags.carspeed
        self.GarageBrakes = self.GarageBrakes + library.flags.brakes
        self.Height = self.Height + library.flags.suspension
        self.TurnSpeed = self.TurnSpeed + library.flags.turnspeed
    end
end)

modules.raycast.RayIgnoreNonCollide = newcclosure(function(...)
    local args, trace = {...}, debug.traceback()
    if library.flags.noflintknock and string.find(trace, "Flintlock") then
        return true
    elseif library.flags.driveonwater and type(args[6]) == "boolean" then
        args[6] = true
    end
    return originals.raynoncollide(unpack(args))
end)

modules.raycast.RayIgnoreNonCollideWithIgnoreList = newcclosure(function(...)
    local args = {...}
	if args[3] == 500 and library.flags.infdroneheight and string.find(debug.traceback(), "Heli") then
		return nil, args[1]
    end
	return originals.rayignorelist(unpack(args))
end)

modules.ui.CircleAction.Update = function(...)
    originals.updatespec(...)
    if modules.ui.CircleAction.Spec and library.flags.nocirclewait then
        modules.ui.CircleAction.Spec.PressedAt = 0
    end
end

modules.vehiclelink._constructor._hookNearest = newcclosure(function(self, ...)
    local vehicle = originals.getvehiclepacket()
    if vehicle and ((library.flags.instantpickup and vehicle.Type == "Heli") or (library.flags.instanttow and vehicle.Make == "TowTruck")) then
        local nearestobj = self.nearestObj
        local primarypart = modules.linkutils.getPrimaryPart(nearestobj)
        self.manifest.reqLinkRemote:FireServer(nearestobj, primarypart.CFrame:PointToObjectSpace(modules.geometry.closestPointInPart(primarypart, self.obj.Position)))
        return
    end
    originals.vehiclehook(self, ...)
end)

originals.fireserver = getupvalue(event.FireServer, 1)
setupvalue(event.FireServer, 1, newcclosure(function(...)
    if #({...}) == 1 and library.flags.nomuseumdetection and string.find(debug.traceback(), "Museum") then
        return
    end
    return originals.fireserver(...)
end))

originals.crawl = defaultactions.attemptToggleCrawling
defaultactions.attemptToggleCrawling = newcclosure(function(...)
    originals.crawl(...)
    if library.flags.nocrawlcooldown then
        local store = getupvalue(originals.crawl, 9)
        store[#store] = 0
    end
end)

originals.taze = garbage.events[clienthashes.taze]
garbage.events[clienthashes.taze] = newcclosure(function(...)
    if library.flags.notaze == false then
        task.spawn(originals.taze, ...)
    end
end)

originals.tirepop = garbage.events[clienthashes.tirepop]
garbage.events[clienthashes.tirepop] = newcclosure(function(...)
    if library.flags.antitirepop == false then
        return originals.tirepop(...)
    end
end)

originals.fallfromsky = garbage.events[clienthashes.fallfromsky]
garbage.events[clienthashes.fallfromsky] = newcclosure(function(...)
    if library.flags.antihelicrash == false then
        return originals.fallfromsky(...)
    end
end)

vehicleclasses.Heli.Update = newcclosure(function(self, ...)
	self.MaxHeight = library.flags.infheliheight and math.huge or 400
	originals.heliupdate(self, ...)
	if library.flags.helispeed > 0 then
        self.Velocity.Velocity = self.Velocity.Velocity * ((35 + library.flags.helispeed) / 35)
    end
end)

originals.hornsound = getupvalue(garbage.hornsound, 3)
setupvalue(garbage.hornsound, 3, function(...)
    local args = {...}
    if library.flags.injanhorn then
        args[3] = modules.settings.Sounds.InjanHorn
    end
    return originals.hornsound(unpack(args))
end)

jptable.EquipLocal = newcclosure(function(self, ...)
    equippedjp = self
    originals.jpequip(self, ...)
    if library.flags.premfuel then
        self.FuelType = "Rocket"
        local fueldata = modules.jputil.Fuel.Rocket
        self.Fuel = fueldata.MaxFuel
        self.MaxFuel = fueldata.MaxFuel
        self.Model.LeftSmoke.Fire.Color = fueldata.ParticleColor
        self.Model.RightSmoke.Fire.Color = fueldata.ParticleColor
        self.LeanAngle = fueldata.LeanAngle
        modules.jpgui.SetFuelType(self.FuelType)
    end
end)

--[[ Connections ]]--

player.CharacterAdded:Connect(registerchar)
players.PlayerAdded:Connect(registerplayer)

mouse.Move:Connect(function()
    local loc = userinputservice:GetMouseLocation()
    aimbotfovcircle.Position = loc
    silentaimfovcircle.Position = loc
end)

player.PlayerGui.ChildAdded:Connect(function(child)
	if child.Name == "FlowGui" and library.flags.solvepuzzles then
		solvepuzzle()
	end
end)

moneystat:GetPropertyChangedSignal("Value"):Connect(function()
    local cost = modules.safeconsts.SAFE_DATA[library.flags.buyrarity].Price * library.flags.buyamount
    library.items.predictedcost:update(evov3.utils:formatmoney(cost), cost <= moneystat.Value and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36))
end)

workspace.ChildAdded:Connect(function(child)
    if child.Name == "Drop" and child.ClassName == "Model" then
        espgroups.airdrop:add(child, { name = "Airdrop" })
        roblabels.Airdrops:update(getairdrops())
    elseif not players:GetPlayerFromCharacter(child) then
		wallbanglist[#wallbanglist + 1] = child
    end
end)

workspace.ChildRemoved:Connect(function(child)
	local idx = evov3.utils:tablefind(wallbanglist, child)
	if idx then
		wallbanglist[idx] = nil
	end
    if child.Name == "Drop" and child.ClassName == "Model" then
        roblabels.Airdrops:update(getairdrops())
    end
end)

replicatedstorage.RobberyState.ChildAdded:Connect(function(child)
    registerrobbery(child)
end)

mappoints.ChildAdded:Connect(function(child)
	child:GetPropertyChangedSignal("Visible"):Connect(function()
		if child.Visible == false and library.flags.minimapshow then
			child.Visible = true
		end
	end)
end)

modules.itemsystem.OnLocalItemEquipped:Connect(function(equipped)
    if equipped.BulletEmitter then
        equipped.BulletEmitter.IgnoreList = library.flags.wallbang and wallbanglist or { char, equipped.Model, workspace.Items }
        equipped.BulletEmitter.GravityVector = not library.flags.nobulletdrop and Vector3.new(0, -workspace.Gravity / 10, 0) or nil
    elseif equipped.IgnoreList then -- taser being special
        equipped.IgnoreList = library.flags.wallbang and wallbanglist or { char, equipped.Model }
    end
end)

userinputservice.InputBegan:Connect(function(input, isrbx)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            isaimkeydown = true
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and flykeys[input.KeyCode.Name] ~= nil then
            flykeys[input.KeyCode.Name] = true
        end
        if input.KeyCode == Enum.KeyCode.Space and root and hum and library.flags.infjump and hum.FloorMaterial == Enum.Material.Air then
            root.Velocity = Vector3.new(root.Velocity.X, hum.JumpPower, root.Velocity.Z)
        end
    end
end)

userinputservice.InputEnded:Connect(function(input)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            isaimkeydown = false
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and flykeys[input.KeyCode.Name] ~= nil then
            flykeys[input.KeyCode.Name] = false
        end
    end
end)

runservice.RenderStepped:Connect(function()
    local t = tick()
    if library.flags.loopexplode and (times.wall == nil or t - times.wall > 6) then
        explodewall()
        times.wall = t
    end
    if library.flags.loopgate and (times.gate == nil or t - times.gate > 4) then
        liftgate()
        times.gate = t
    end
    if library.flags.loopsewers and (times.sewers == nil or t - times.sewers > 3.65) then
        opensewers()
        times.sewers = t
    end
    if library.flags.loopvolcano and (times.volcano == nil or t - times.volcano > 3.5) then
        firetouch(workspace.LavaFun.Lavatouch)
        times.volcano = t
    end
end)

runservice.RenderStepped:Connect(function()
    aimbotfovcircle.Radius = library.flags.aimbotfov.value * (library.flags.aimbotfovdynamic and 70 / cam.FieldOfView or 1)
    silentaimfovcircle.Radius = library.flags.silentaimfov.value * (library.flags.silentaimfovdynamic and 70 / cam.FieldOfView or 1)
    if char and library.flags.silentaimenabled then
        local equipped = modules.itemsystem.GetLocalEquipped()
        if equipped and (equipped.BulletEmitter or equipped.__ClassName == "Taser") then
            silentaimtarget = getsilentaimtarget(equipped)
            if silentaimtarget then
                if library.flags.autoshoot and (library.flags.autowall or silentaimtarget.iswallbetween == false) then
                    equipped:InputBegan({
                        UserInputType = Enum.UserInputType.MouseButton1
                    })
                elseif library.flags.triggerbot then
                    local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { cam, char, equipped.Model }, true)
                    if part and part:IsDescendantOf(workspace.Characters) then
                        equipped:InputBegan({
                            UserInputType = Enum.UserInputType.MouseButton1
                        })
                    end
                end
            end
        end
    end
end)

--[[ End ]]--

for i, v in next, replicatedstorage.RobberyState:GetChildren() do
    task.spawn(registerrobbery, v)
end

library:addsettings()
modules.notification.new({ Text = string.format("Evo V3 Loaded! Time Taken: %dms", math.floor((tick() - initstamp) * 1000)) })
