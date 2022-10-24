--[[

    Changelog:



]]

--[[ ==========  Macros  ========== ]]

LPH_ENCSTR = function(...) return ... end

--[[ ==========  Settings  ========== ]]

local settings = {
    aimbot = {
        aimbot = {
            enabled = false,
            aimKey = "MouseButton2",
            ignoreAimKey = false,
            wallCheck = false,
            smoothness = 1,
            aimPart = "HumanoidRootPart"
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
        }
    },
    visuals = {
        misc = {
            minimapShowAll = false
        }
    },
    teleports = {
        locations = {
            eject = false
        }
    },
    vehicleMods = {
        cars = {
            speed = 1,
            brakes = 1,
            height = 1,
            turn = 1,
            driveOnWater = false,
            autoFlip = false,
            antiTirePop = false,
            antiPitManeuver = false
        },
        helis = {
            speed = 1,
            antiFall = false,
            instantPickup = false,
            infHeliHeight = false,
            infDroneHeight = false
        },
        boats = {
            speed = 1,
            boatsOnLand = false,
            jetskiOnLand = false
        },
        offense = {
            popTires = false,
            shootDownHelis = false,
            teamCheck = false
        }
    },
    itemMods = {
        gunMods = {
            wallbang = false,
            noFlintlockKnockback = false
        },
        fireRate = {
            enabled = false,
            rate = 0
        },
        jetPack = {
            infFuel = false,
            premiumFuel = false
        },
        utility = {
            shootWhileDriving = false,
            shootWhileJetpacking = false
        },
        projectiles = {
            disableMilitary = false,
            disableTurrets = false,
            disableDispensers = false
        }
    },
    playerMods = {
        charMods = {
            walkEnabled = false,
            walkSpeed = 16,
            jumpEnabled = false,
            jumpPower = 50,
            flySpeed = 150,
            infJump = false,
            instantSpecs = false,
            noPunchCooldown = false,
            antiRagdoll = false,
            antiFallDamage = false,
            antiTaze = false,
            antiSkydive = false
        },
        cosmetic = {
            orangeJustice = false
        },
        safes = {
            autoSkip = false
        }
    },
    robbery = {
        autoRob = {
            enabled = false
        },
        robMods = {
            autoSolve = false,
            autoJewel = false,
            autoMuseum = false,
            noIconDelay = false,
            notify = false,
        }
    },
    funMods = {
        doors = {
            bypassCheck = false,
            loopOpen = false  
        },
        wall = {
            loopExplode = false
        },
        gate = {
            loopLift = false
        },
        sewers = {
            loopOpen = false
        },
        volcano = {
            loopErupt = false
        }
    }
}

--[[ ==========  Variables  ========== ]]

local cache = loadstring(game:HttpGet("https://projectevo.xyz/script/utils/libraryv3.lua"))()
cache.espv4 = loadstring(game:HttpGet("https://projectevo.xyz/script/utils/espv4.lua"))()
cache.misc = cache.system.new("Miscellaneous")
cache.library = cache.library.new("JailBreak")

local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")
local httpService = game:GetService("HttpService")
local pathfindingService = game:GetService("PathfindingService")
local virtualInputManager = game:GetService("VirtualInputManager")
local teams = game:GetService("Teams")
local players = game:GetService("Players")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local moneyValue = player:WaitForChild("leaderstats"):WaitForChild("Money")
local controls = require(player.PlayerScripts.PlayerModule):GetControls()

local storage = cache.misc:CreateInstance("Folder", { Name = "storage" }, {
    cache.misc:CreateInstance("Folder", { Name = "lasers" }, {
        cache.misc:CreateInstance("Folder", { Name = "bank" }),
        cache.misc:CreateInstance("Folder", { Name = "jewelry" }),
        cache.misc:CreateInstance("Folder", { Name = "plant" })
    }),
    cache.misc:CreateInstance("Folder", { Name = "ignores" })
})

cache.groups = {
    players = cache.espv4.group.new("players", {
        exclusions = { HumanoidRootPart = true },
        info = {
            [1] = {
                name = "distances",
                func = function(v)
                    if not v.model:FindFirstChild("HumanoidRootPart") then
                        return "DEAD"
                    end
                    return math.floor((cam.CFrame.Position - v.model.HumanoidRootPart.Position).Magnitude)
                end
            },
            [2] = {
                name = "percentages",
                func = function(v)
                    return tostring(v.health * 100) .. "%"
                end
            }
        }
    }),
    airdrops = cache.espv4.group.new("items", {
        info = {
            [1] = {
                name = "distances",
                display = "Distance",
                func = function(v)
                    if not v.model:FindFirstChild("Briefcase") then
                        return ""
                    end
                    return math.floor((cam.CFrame.Position - v.model.Briefcase.Position).Magnitude)
                end
            }
        }
    })
}

local museumPuzzle1 = workspace.Museum.Puzzle1
local museumPuzzle2 = workspace.Museum.Puzzle2.Pieces

local localScript = player.PlayerScripts:WaitForChild("LocalScript")
local robberyMarkerSys = replicatedStorage.Game.RobberyMarkerSystem

local robberyMoneyGui = player.PlayerGui:WaitForChild("RobberyMoneyGui")
local bagLabel = robberyMoneyGui.Container.Bottom.Progress.Amount
local minimap = player.PlayerGui.AppUI.Buttons.Minimap.Map.Container.Points

local branch = workspace.Switches.BranchBack
local doors = getupvalue(getconnections(collectionService:GetInstanceRemovedSignal("Door"))[1].Function, 1)

local modules = {
    bulletEmitter = require(replicatedStorage.Game.ItemSystem.BulletEmitter),
    plasmaPistol = require(replicatedStorage.Game.Item.PlasmaPistol),
    basic = require(replicatedStorage.Game.Item.Basic),
    taser = require(replicatedStorage.Game.Item.Taser),
    itemSystem = require(replicatedStorage.Game.ItemSystem.ItemSystem),
    defaultActions = require(replicatedStorage.Game.DefaultActions),
    safesUI = require(replicatedStorage.Game.SafesUI),
    museum = require(replicatedStorage.Game.Museum),
    falling = require(replicatedStorage.Game.Falling),
    playerUtils = require(replicatedStorage.Game.PlayerUtils),
    puzzleFlow = require(replicatedStorage.Game.Robbery.PuzzleFlow),
    gunShopUtils = require(replicatedStorage.Game.GunShop.GunShopUtils),
    gunShopUI = require(replicatedStorage.Game.GunShop.GunShopUI),
    characterUtil = require(replicatedStorage.Game.CharacterUtil),
    vehicle = require(replicatedStorage.Game.Vehicle),
    boat = require(replicatedStorage.Game.Boat.Boat),
    gun = require(replicatedStorage.Game.Item.Gun),
    jetPack = require(replicatedStorage.Game.JetPack.JetPack),
    jetPackGui = require(replicatedStorage.Game.JetPack.JetPackGui),
    jetPackUtil = require(replicatedStorage.Game.JetPack.JetPackUtil),
    cartSystem = require(replicatedStorage.Game.Cart.CartSystem),
    gamepassSystem = require(replicatedStorage.Game.Gamepass.GamepassSystem),
    gamepassUtils = require(replicatedStorage.Game.Gamepass.GamepassUtils),
    robberyConsts = require(replicatedStorage.Game.Robbery.RobberyConsts),
    tombSystem = require(replicatedStorage.Game.Robbery.TombRobbery.TombRobberySystem),
    turret = require(replicatedStorage.Game.Robbery.CargoShip.Turret),
    dispenser = require(replicatedStorage.Game.DartDispenser.DartDispenser),
    militaryTurret = require(replicatedStorage.Game.MilitaryTurret.MilitaryTurret),
    destructibleSpawn = require(replicatedStorage.Game.Destructible.DestructibleSpawn),
    party = require(replicatedStorage.Game.Party),
    vehicleData = require(replicatedStorage.Game.Garage.VehicleData),
    alexChassis = require(replicatedStorage.Module.AlexChassis),
    ui = require(replicatedStorage.Module.UI),
    rayCast = require(replicatedStorage.Module.RayCast),
    maid = require(replicatedStorage.Module.Maid),
    localization = require(replicatedStorage.Module.Localization),
    gameSettings = require(replicatedStorage.Resource.Settings),
    inventoryItemSystem = require(replicatedStorage.Inventory.InventoryItemSystem),
    inventoryItemUtils = require(replicatedStorage.Inventory.InventoryItemUtils)
}

local originals = {
    emit = modules.bulletEmitter.Emit,
    shootOther = modules.plasmaPistol.ShootOther,
    updateMousePosition = modules.basic.UpdateMousePosition,
    tase = modules.taser.Tase,
    setAttr = modules.inventoryItemUtils.setAttr,
    ragdoll = modules.falling.StartRagdolling,
    isPointInTag = modules.playerUtils.isPointInTag,
    getLocalVehiclePacket = modules.vehicle.GetLocalVehiclePacket,
    updatePhysics = modules.boat.UpdatePhysics,
    isJetPackFlying = modules.jetPack.IsFlying,
    doesPlayerOwn = modules.gamepassSystem.DoesPlayerOwn,
    turretShoot = modules.turret.Shoot,
    dispenserFire = modules.dispenser._fire,
    militaryFire = modules.militaryTurret._fire,
    vehicleEnter = modules.alexChassis.VehicleEnter,
    updatePrePhysics = modules.alexChassis.UpdatePrePhysics,
    rayIgnoreNonCollide = modules.rayCast.RayIgnoreNonCollide,
    rayIgnoreNonCollideWithIgnoreList = modules.rayCast.RayIgnoreNonCollideWithIgnoreList,
    launchFireworks = getupvalue(modules.party.Init, 1),
    processSpec = getupvalue(modules.ui.CircleAction.Update, 7),
    openSafe = getproto(modules.safesUI.SetupUseSafes, 4, true)[1]
}

local specs = modules.ui.CircleAction.Specs
local event = getupvalue(modules.alexChassis.SetEvent, 1)
local puzzle = getupvalue(modules.puzzleFlow.Init, 3)
local defaultActions = getupvalue(modules.defaultActions.punchButton.onPressed, 1)
local destructibleFolder = getupvalue(getproto(modules.destructibleSpawn._setup, 3, true)[1], 7)

local attemptPunch = defaultActions.attemptPunch

local jetPackTable = getupvalue(getproto(modules.jetPack.Init, 1, true)[1], 1)
originals.jetPackEquip = jetPackTable.EquipLocal
local jetPackEquipped = nil

local museumDetect = getproto(getproto(modules.museum, 9, true)[1], 1)
local museumDetectIndex = table.find(getconstants(museumDetect), 0.5)
originals.fireServer = getupvalue(event.FireServer, 1)

local orangeJusticeTrack = nil
local timeFunc, timeFuncIndex = nil, nil
local vehicleClasses, isHoldingIndex = nil, nil
local equipCondition = nil

local fovCircle = Drawing.new("Circle")
local gunTables, gunData = {}, {}
local connections, clientHashes = {}, {}
local statusLabels, robberyStates, hasRobbed = {}, {}, {}
local wallbangIgnore = {}
local ownedVehicles = {}
local carNames, heliNames = {}, {}
local char, root, hum = nil, nil, nil
local target = nil
local isAimKeyDown, isFlying, isTeleporting = false, false, false
local baseFlyVec = Vector3.new(0, 1e-10, 0)
local pickUpItem = false
local currentRobbery, doCancelTp, cancelTp = "", false, false
local noFlyAreas, noClipAllowed = {}, {}

local flyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local fakeSniper = {
    __ClassName = "Sniper",
    Local = true,
    IgnoreList = {},
    LastImpact = 0,
    LastImpactSound = 0,
    Maid = modules.maid.new()
}

local pathRotations = {
    ["2"] = Vector3.new(180, -51.94, 0),
    ["3"] = Vector3.new(-180, -51.94, -180),
    ["10"] = Vector3.new(180, -51.94, 0),
    ["11"] = Vector3.new(-180, -51.94, -180),
    ["12"] = Vector3.new(-180, -51.94, -180),
    ["19"] = Vector3.new(180, -51.94, 0),
    ["20"] = Vector3.new(-180, -51.94, 90),
    ["13"] = Vector3.new(180, -51.94, -90),
    ["14"] = Vector3.new(-180, -51.94, -180)
}

local robberyLocations = {
	["Bank"] = CFrame.new(-12, 20, 782),
	["Jewelry Store"] = CFrame.new(126, 20, 1368),
	["Museum"] = CFrame.new(1142, 104, 1247),
	["Power Plant"] = CFrame.new(636, 39, 2357),
    ["Tomb"] = CFrame.new(465, 21, -464),
	["Donut Store"] = CFrame.new(90, 20, -1511),
	["Gas Station"] = CFrame.new(-1526, 19, 699)
}

local placeLocations = {
	["Prison Yard"] = CFrame.new(-1220, 18, -1760),
	["1M Dealership"] = CFrame.new(720, 20, -1572),
	["Volcano Base"] = CFrame.new(1816, 48, -1634),
	["Military Base"] = CFrame.new(685, 19, 485),
    ["Police Headquarters"] = CFrame.new(183, 18, 1084),
	["Secret Agent Base"] = CFrame.new(1527, 86, 1551),
	["City Base"] = CFrame.new(-250, 18, 1616),
	["Boat Docks"] = CFrame.new(-430, 21, 2025),
	["Airport"] = CFrame.new(-1202, 41, 2846),
	["Fire Station"] = CFrame.new(-930, 32, 1349),
	["Gun Store"] = CFrame.new(391, 18, 533),
	["JetPack Mountain"] = CFrame.new(1384, 168, 2596),
	["Pirate Hideout"] = CFrame.new(1955, 14, 2117),
	["Lighthouse"] = CFrame.new(-2044, 45, 1722),
	["Prison Island"] = CFrame.new(-2917, 24, 2312),
    ["Season Leaderboard"] = CFrame.new(-1304, 18, -924),
    ["Hacker Cage"] = CFrame.new(-306, 20, 301),
    ["Events Room"] = CFrame.new(64, 19, 1144),
    ["Train Station"] = CFrame.new(1635, 19, 258),
    ["Glider Store"] = CFrame.new(175, 20, -1720),
    ["Dog Shelter"] = CFrame.new(252, 20, -1620)
}

local bankLayoutPaths = {
    TheMint = {
        CFrame.new(52, 20, 857),
        CFrame.new(94, 3, 858),
        CFrame.new(96, 3, 795),
        CFrame.new(65, 2, 762)
    },
    Corridor = {
        CFrame.new(50, 20, 857),
        CFrame.new(50, -7, 857),
        CFrame.new(52, -7, 861)
    },
    Presidential = {
        CFrame.new(48, 20, 857),
        CFrame.new(47, -6, 857),
        CFrame.new(72, -6, 858),
        CFrame.new(79, -6, 933),
        CFrame.new(47, -6, 933)
    },
    Remastered = {
        CFrame.new(51, 20, 857),
        CFrame.new(93, 3, 858),
        CFrame.new(95, 3, 818)
    },
    Basement = {
        CFrame.new(44, 20, 856),
        CFrame.new(75, 11, 858),
        CFrame.new(75, 1, 884),
        CFrame.new(75, 1, 905),
        CFrame.new(43, -7, 885)
    },
    Underwater = {
        CFrame.new(51, 19, 856),
        CFrame.new(93, 3, 858),
        CFrame.new(96, -12, 801)
    },
    Deductions = {
        CFrame.new(52, 20, 857),
        CFrame.new(93, 3, 858),
        CFrame.new(89, 3, 918),
        CFrame.new(37, 2, 888)
    },
    TheBlueRoom = {
        CFrame.new(48, 21, 856),
        CFrame.new(48, 2, 856)
    }
}

local tombExits = {
    CFrame.new(1283, 18, -1143),
    CFrame.new(206, 21, 234)
}

local playerSpeed = 150
local vehicleSpeed = 350
local tpHeight = 300

--[[ ==========  Garbage Collection  ========== ]]

local hasBypassedAC
local openDoor, registerDoor, clientEvents, vehicleTable, exitVehicle, formatMoney, robberyMarkerStates

for i, v in next, getgc() do
    if hasBypassedAC and openDoor and registerDoor and clientEvents and vehicleTable and exitVehicle and formatMoney and robberyMarkerStates then break end
    if type(v) == "function" and islclosure(v) then
        local scr = getfenv(v).script
        if scr == localScript then
            local name, consts = getinfo(v).name, getconstants(v)
            if name == "DoorSequence" then
                openDoor = v
            elseif name == "RegisterDoor" then
                registerDoor = v
            elseif name == "FormatMoney" then
                formatMoney = v
            elseif name == "StopNitro" then
                clientEvents = getupvalue(getupvalue(v, 1), 2)
            elseif table.find(consts, "FailedPcall") then
				setupvalue(v, 2, true) -- Anticheat
                hasBypassedAC = true
            elseif table.find(consts, "NitroLastMax") and table.find(consts, "NitroForceUIUpdate") then
                vehicleTable = getupvalue(v, 1)
                for i, v in next, vehicleTable.VehiclesOwned do
                    ownedVehicles[i] = true
                end
            elseif table.find(consts, "FireServer") and table.find(consts, "LastVehicleExit") and table.find(consts, "tick") then
                exitVehicle = v
            end
        elseif scr == robberyMarkerSys and getinfo(v).name == "setRobberyMarkerState" then
            robberyMarkerStates = getupvalue(v, 1)
        end
    end
end

local nameToId = {}
for i, v in next, robberyMarkerStates do
    nameToId[v.Name] = v.RobberyId
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

local function orangeJustice()
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "http://www.roblox.com/asset/?id=3066265539"
        orangeJusticeTrack = hum:LoadAnimation(anim)
        orangeJusticeTrack:Play()
    end
end

local function registerChar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    if settings.playerMods.cosmetic.orangeJustice then
        orangeJustice()
    end
    if settings.playerMods.charMods.walkEnabled then
        hum.WalkSpeed = settings.playerMods.charMods.walkSpeed
    end
    if settings.playerMods.charMods.jumpEnabled then
        hum.JumpPower = settings.playerMods.charMods.jumpPower
    end
    char.ChildAdded:Connect(function(child)
        if isTeleporting and child.Name == "Handcuffs" then
            cancelTp = true
        end
    end)
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum and settings.playerMods.charMods.walkEnabled then
            hum.WalkSpeed = settings.playerMods.charMods.walkSpeed
        end
    end)
    hum.Died:Connect(function()
        if isTeleporting then
            cancelTp = true
        end
        isAtAfk = false
        char, root, hum = nil, nil, nil
    end)
end

local function registerEsp(plr)
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        cache.groups.players:Add(plr.Character, {})
    end
    plr.CharacterAdded:Connect(function(character)
        cache.groups.players:Add(plr.Character, {})
    end)
end

local function getTarget()
	local retPart, dist = nil, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
	for i, v in next, players:GetPlayers() do
        if v.Team ~= player.Team then
            local rootPart = v.Character and v.Character:FindFirstChild(settings.aimbot.aimbot.aimPart)
            if rootPart then
                local pos, vis = cam:WorldToScreenPoint(rootPart.Position)
                if vis then
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

local function openDoors()
    for i, v in next, doors do
        if not v.State.Open then
            openDoor(v)
        end
    end
end

local function explodeWall()
    for i, v in next, specs do
        if v.Name == "Explode Wall" then
            v:Callback(true)
            break
        end
    end
end

local function liftGate()
    for i, v in next, specs do
        if v.Name == "Lift Gate" then
            v:Callback(true)
            break
        end
    end
end

local function openSewers()
    for i, v in next, specs do
        if v.Name == "Pull Open" then
            v:Callback(true)
        end
    end
end

local function pressKey(key)
    virtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait()
    virtualInputManager:SendKeyEvent(false, key, false, game)
end

local function fireTouchInterest(part)
    if root then
        firetouchinterest(root, part, 0)
        task.wait()
        firetouchinterest(root, part, 1)
    end
end

local function solvePuzzle()
    local grid = {}
    cache.misc:DeepCopy(puzzle.Grid, grid, true)
	for i, v in next, grid do
		for i2, v2 in next, v do
			v[i2] = v2 + 1
		end
	end
	local solution = httpService:JSONDecode(httprequest({
		Url = "https://numberlink-solver.sagesapphire.repl.co",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = httpService:JSONEncode({
			Matrix = grid
		})
	}).Body).Solution
	for i, v in next, solution do
		for i2, v2 in next, v do
			v[i2] = v2 - 1
		end
	end
	puzzle.Grid = solution
	puzzle.OnConnection()
end

local function grabAllGuns(slider)
	for i, v in next, slider:GetChildren() do
		if v:IsA("ImageLabel") and (v.Bottom.Action.Text == "FREE" or v.Bottom.Action.Text == "EQUIP") then
			firesignal(v.Bottom.Action.MouseButton1Down)
		end
	end
end

local function tableFind(tab, val)
    for i, v in next, tab do
        if v == val then
            return i
        end
    end
end

local function getXZDir(start, target)
	local xzNow = Vector3.new(start.Position.X, 0, start.Position.Z)
	local xzEnd = Vector3.new(target.Position.X, 0, target.Position.Z)
	return (xzEnd - xzNow).Unit
end

local function getXZMag(start, target)
	local xzNow = Vector3.new(start.Position.X, 0, start.Position.Z)
	local xzEnd = Vector3.new(target.Position.X, 0, target.Position.Z)
	return (xzEnd - xzNow).Magnitude
end

local function tryEnterSeat(seat)
	local success = false
	for i, v in next, specs do
		if v.Part == seat then
			if v.Name == "Hijack" then
				v:Callback(true)
				task.wait(0.5)
				success = tryEnterSeat(seat)
				break
			end
			v:Callback(true)
			task.wait(0.5)
			success = originals.getLocalVehiclePacket() ~= nil
			break
		end
	end
	return success
end

local function setupPathfinding(start)
    for i, v in next, doors do
        if v.Model then
            v.Model.Parent = start and storage.ignores or workspace
        end
    end
    for i, v in next, noClipAllowed do
        i.Parent = start and storage.ignores or v
    end
end

local function getTeleportIgnoreList()
    local ignoreList = { workspace.Vehicles, workspace.Items, workspace.Trains, destructibleFolder, workspace.Terrain.Clouds, char }
    for i, v in next, doors do
        if v.Model then
            ignoreList[#ignoreList + 1] = v.Model
        end
    end
    for i, v in next, noClipAllowed do
        ignoreList[#ignoreList + 1] = i
    end
    if workspace:FindFirstChild("Rain") then
        ignoreList[#ignoreList + 1] = workspace.Rain
    end
    return ignoreList
end

local function randomVector()
    local x, y, z = math.random(-150, 150), math.random(-150, 150), math.random(-150, 150)
    return Vector3.new(x / 1000, y / 1000, z / 1000)
end

local function getNextLocation(start, target, speed, step)
    local dir, mag = getXZDir(start, target), math.min((speed * step) + (math.random(-150, 150) / 1000), getXZMag(start, target))
    return CFrame.new(Vector3.new(start.Position.X, tpHeight, start.Position.Z) + ((dir * mag) + randomVector()), Vector3.new(target.Position.X, start.Position.Y, target.Position.Z) + target.LookVector)
end

local function getNextDirectLocation(start, target, speed, step)
    local dir, mag = (target.Position - start.Position).Unit, math.min((speed * step) + (math.random(-150, 150) / 1000), (target.Position - start.Position).Magnitude)
    return CFrame.new(start.Position + ((dir * mag) + randomVector()), Vector3.new(target.Position.X, start.Position.Y, target.Position.Z) + target.LookVector)
end

local function playerTeleportDirect(target, speed, drop)
	local success, arrived, isInstance = true, false, typeof(target) == "Instance"
	workspace.Gravity = 0
	local conn = runService.Stepped:Connect(function(dur, step)
        if char == nil or root == nil or cancelTp then
            success, arrived, cancelTp = false, true, false
        else
            for i, v in next, char:GetChildren() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            root.CFrame = getNextDirectLocation(root, isInstance and target.CFrame or target, speed, step)
            root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(root, target) < 0.5 then
                arrived = true
            end
        end
	end)
	repeat task.wait() until arrived
	conn:Disconnect()
    if success then
        root.CFrame = drop and (isInstance and target.CFrame or target) or CFrame.new((isInstance and target.CFrame or target).Position, target.Position + root.CFrame.LookVector)
        root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
        for i, v in next, char:GetChildren() do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
	workspace.Gravity = drop and 196.2 or 0
    return success
end

local function playerTeleport(target, options)
    local success, isInstance = true, typeof(target) == "Instance"
	if select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(root.Position, Vector3.new(0, tpHeight - root.Position.Y, 0)), getTeleportIgnoreList(), false, true)) ~= nil then
		local pathFound, excluded = false, {}
        setupPathfinding(true)
		repeat
            if cancelTp then
                success, cancelTp = false, false
                break
            end
			local destructibles = {}
			for i, v in next, destructibleFolder:GetChildren() do
				if excluded[v.PrimaryPart] == nil then
					destructibles[#destructibles + 1] = v.PrimaryPart
				end
			end
			table.sort(destructibles, function(a, b)
				return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
			end)
			local path = pathfindingService:CreatePath({ AgentCanJump = false, WaypointSpacing = 25 })
			path:ComputeAsync(root.Position, destructibles[1].Position)
			if path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()
				for i = 1, #waypoints do
                    local mag = (waypoints[i].Position - root.Position).Magnitude
					if playerTeleportDirect(CFrame.new(waypoints[i].Position + Vector3.new(0, 4, 0)), mag < 24 and 25 or 60, i == #waypoints) then
                        if select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(root.Position, Vector3.new(0, tpHeight - root.Position.Y, 0)), getTeleportIgnoreList(), false, true)) == nil then
                            break
                        end
                    else
                        success = false
                        break
                    end
				end
				pathFound = true
			else
				excluded[destructibles[1]] = true
			end
			task.wait(0.25)
		until success == false or pathFound == true
        setupPathfinding(false)
		task.wait(0.25)
	end
	local arrived = false
	workspace.Gravity = 0
    task.wait(0.1)
	local conn = runService.Stepped:Connect(function(dur, step)
        if root == nil or cancelTp then
            success, arrived, cancelTp = false, true, false
        else
            root.CFrame = getNextLocation(root, isInstance and target.CFrame or target, playerSpeed, step)
            root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(root, target) < 0.5 then
                arrived = true
            end
        end
	end)
	repeat task.wait() until arrived
	conn:Disconnect()
	if success then
        if options.stallDrop then
            repeat
                root.CFrame = getNextLocation(root, isInstance and target.CFrame or target, playerSpeed, 1)
                root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
                task.wait()
            until options.stallDrop()
        end
        root.CFrame = isInstance and target.CFrame or target
        root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
    end
	workspace.Gravity = 196.2
    return success
end

local function carTeleport(target, options)
    local success, isInstance = true, typeof(target) == "Instance"
	local arrived, vehicle = false, originals.getLocalVehiclePacket()
	local vehicleModel, vehiclePart, hasLift = vehicle.Model, vehicle.Model.PrimaryPart, vehicle.Lift ~= nil
	if hasLift then
		modules.alexChassis.SetGravity(vehicle, 0)
    elseif vehicle.Type ~= "Heli" then
        workspace.Gravity = 0
	end
	local conn = runService.Stepped:Connect(function(dur, step)
        if vehicleModel.Parent == nil or root == nil or cancelTp then
            success, arrived, cancelTp = false, true, false
        else
            vehicleModel:SetPrimaryPartCFrame(getNextLocation(vehiclePart, isInstance and target.CFrame or target, vehicleSpeed, step))
            vehiclePart.Velocity, vehiclePart.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(vehiclePart, target) < 0.5 then
                arrived = true
            end
        end
	end)
	repeat task.wait() until arrived
	conn:Disconnect()
	if success then
        if options.stallDrop then
            repeat
                vehicleModel:SetPrimaryPartCFrame(getNextLocation(vehiclePart, isInstance and target.CFrame or target, vehicleSpeed, 1))
                vehiclePart.Velocity, vehiclePart.RotVelocity = Vector3.new(), Vector3.new()
                task.wait()
            until options.stallDrop()
        end
        vehicleModel:SetPrimaryPartCFrame(isInstance and target.CFrame or target)
        vehiclePart.Velocity, vehiclePart.RotVelocity = Vector3.new(), Vector3.new()
        if hasLift then
            modules.alexChassis.SetGravity(vehicle, options.drop and 100 or 0)
        elseif vehicle.Type ~= "Heli" then
            workspace.Gravity = 196.2
        end
        if options.exitVehicle then
            task.wait(0.25)
            exitVehicle()
            task.wait(0.25)
        end
    else
        workspace.Gravity = 196.2
    end
    return success
end

local function teleport(target, options)
    local success = true
	if isTeleporting or root == nil or options == nil or options.mode == nil then
		return
	end
    isTeleporting = true
    tpHeight = math.random(300, 350)
    controls:Disable()
	if options.mode == "Car" then
		if originals.getLocalVehiclePacket() == nil then
			local valid = {}
			for i, v in next, workspace.Vehicles:GetChildren() do
				if ownedVehicles[v.Name] and (heliNames[v.Name] or not options.heli) and v:FindFirstChild("Seat") and v.Seat:FindFirstChild("Player") and v.Seat.Player.Value == false then
                    if select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(v.Seat.Position, Vector3.new(0, tpHeight - v.Seat.Position.Y, 0)), getTeleportIgnoreList(), false, true)) == nil then
						valid[#valid + 1] = v.Seat
                    end
				end
			end
			table.sort(valid, function(a, b)
				return getXZMag(root, a) < getXZMag(root, b)
			end)
            for i, v in next, valid do
				if playerTeleport(CFrame.new(v.Position + Vector3.new(0, 4, 0)), {}) then
                    task.wait(0.5)
                    if tryEnterSeat(v) then
                        break
                    end
                end
			end
		end
        if originals.getLocalVehiclePacket() then
            success = carTeleport(target, options)
        elseif not options.heli then
            local selected, mag = nil, math.huge
            for i, v in next, workspace.VehicleSpawns:GetChildren() do
                local region, dist = v.Region, (v.Region.Position - root.Position).Magnitude
                if v.Name == "Camaro" and dist < mag and select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(region.Position, Vector3.new(0, tpHeight - region.Position.Y, 0)), getTeleportIgnoreList(), false, true)) == nil then
                    selected, mag = region, dist
                end
            end
            if selected then
                playerTeleport(selected.CFrame * CFrame.new(-5, 0, 0), {})
                local seat = workspace.Vehicles:WaitForChild(selected.Parent.Name, 15):WaitForChild("Seat", 5)
                if seat then
                    repeat task.wait()
                        if tryEnterSeat(seat) then
                            break
                        end
                    until seat:WaitForChild("Player").Value
                    if seat.PlayerName.Value == player.Name then
                        success = carTeleport(target, options)
                    else
                        success = playerTeleport(target, options)
                    end
                else
                    success = playerTeleport(target, options)
                end
            else
                success = playerTeleport(target, options)
            end
        else
            success = false
        end
    elseif options.mode == "Player" then
        success = playerTeleport(target, options)
    elseif options.mode == "PlayerDirect" then
        success = playerTeleportDirect(target, options.customSpeed or playerSpeed, options.drop)
	end
    controls:Enable()
    isTeleporting = false
    return success
end

local function chainTeleportDirect(positions, speed)
    local success = true
    for i = 1, #positions do
        if not teleport(positions[i], { mode = "PlayerDirect", drop = i == #positions, customSpeed = speed or playerSpeed }) then
            workspace.Gravity, success = 196.2, false
            break
        end
    end
    return success
end

local function shootVehicle(part)
    fakeSniper.LastImpact = 0
    fakeSniper.BulletEmitter.OnHitSurface:Fire(part, part.Position, part.Position)
end

local function eligibleCar(model)
    if not (model:FindFirstChild("Seat") and model.Seat:FindFirstChild("Player")) then
        return false
    end
    return model.Seat.Player.Value and model.Seat.PlayerName.Value ~= player.Name and (settings.vehicleMods.offense.teamCheck == false or players[model.Seat.PlayerName.Value].Team ~= player.Team)
end

local function updateVehicle(prop, val)
    local vehicle = originals.getLocalVehiclePacket()
    if vehicle and vehicle[prop] then
        vehicle[prop] = val
        modules.alexChassis.UpdateStats(vehicle)
    end
end

local function reverseTable(tab)
    local res = {}
    for i, v in next, tab do
        res[(#tab + 1) - i] = v
    end
    return res
end

local function updateRobbery(robberyName, prettyName, robberyValue)
    local isOpen = robberyValue.Value ~= modules.robberyConsts.ENUM_STATE.CLOSED
    robberyStates[robberyName] = isOpen
    if statusLabels[robberyName] then
        statusLabels[robberyName]:Update(isOpen and "Open" or "Closed", isOpen and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36))
    end
    if not isOpen and currentRobbery == robberyName and isTeleporting and doCancelTp then
        cancelTp = true
    end
    if robberyValue.Value == modules.robberyConsts.ENUM_STATE.OPENED then
        hasRobbed[robberyName] = nil
        if settings.robbery.robMods.notify then
            cache.library:Notify("'" .. prettyName .. "' has just opened!")
        end
    end
end

local function registerRobbery(robberyValue)
    local robberyName, prettyName = robberyMarkerStates[tonumber(robberyValue.Name)].Name, modules.robberyConsts.PRETTY_NAME[tonumber(robberyValue.Name)]
    updateRobbery(robberyName, prettyName, robberyValue)
    robberyValue:GetPropertyChangedSignal("Value"):Connect(function()
        updateRobbery(robberyName, prettyName, robberyValue)
    end)
end

--[[ ==========  Auto Rob  ========== ]]

local function checkShouldAbort(checkRobberyState)
    local shouldAbort = char == nil or root == nil or player.Team ~= teams.Criminal or settings.robbery.autoRob.enabled == false or false
    if char:FindFirstChild("Handcuffs") then
        shouldAbort = true
        char.Handcuffs.AncestryChanged:Wait()
    end
    if checkRobberyState and robberyStates[currentRobbery] == false then
        shouldAbort = true
    end
    return shouldAbort
end

local function isBagFull()
    if robberyMoneyGui.Enabled == false then
        return false
    end
    local bagText = bagLabel.Text
    for i, v in next, bagText:split("") do
        if v == "/" then
            return bagText:sub(1, i - 2) == bagText:sub(i + 2)
        end
    end
    return false
end

local function getUraniumValue()
    return tonumber(table.concat({ string.match(player.PlayerGui.PowerPlantRobberyGui.Price.TextLabel.Text, "Uranium Value: $(%d),(%d+)") }, ""))
end

local function robBank()
    local layout = workspace.Banks:GetChildren()[1].Layout:GetChildren()[1]
    local path = bankLayoutPaths[layout.Name]
    if path then
        doCancelTp = true
        if not teleport(CFrame.new(-12, 20, 782), { mode = "Car", exitVehicle = true }) then return end
        if not chainTeleportDirect({
            CFrame.new(12, 19, 790),
            CFrame.new(25, 19, 854)
        }, 80) then return end
        fireTouchInterest(layout.TriggerDoor)
        if layout:FindFirstChild("Lasers") then
            layout.Lasers:Destroy()
        end
        hasRobbed.Bank = true
        if not chainTeleportDirect(path, 60) then return end
        task.wait(0.25)
        if not teleport(layout.Money.CFrame, { mode = "PlayerDirect", drop = true }) then return end
        robberyMoneyGui:GetPropertyChangedSignal("Enabled"):Wait()
        repeat task.wait() until isBagFull() or checkShouldAbort(true) or robberyMoneyGui.Enabled == false
        if not checkShouldAbort(true) then
            if not chainTeleportDirect(reverseTable(path), 60) then return end
            if not chainTeleportDirect({
                CFrame.new(25, 19, 854),
                CFrame.new(12, 19, 790)
            }, 80) then return end
        end
    else
        hasRobbed.Bank = true
        error("Unsupported Bank Layout: " .. layout.Name)
    end
end

local function robJewelry()
    doCancelTp = true
    local init, delayTime = tick(), 15
    if not teleport(CFrame.new(126, 20, 1368), { mode = "Car", exitVehicle = true, drop = true }) then return end
    if not teleport(CFrame.new(143, 19, 1352), { mode = "PlayerDirect", customSpeed = 100 }) then return end
    local jewelry = workspace.Jewelrys:GetChildren()[1]
    for i, v in next, jewelry:GetChildren() do
        if v.Name == "BarbedWire" then
            v:Destroy()
        end
    end
    if #workspace.Ringers.Jewelry:GetChildren() == 0 then
        delayTime = 20
        task.wait(3)
        if checkShouldAbort(true) then return end
        if not teleport(CFrame.new(139, 19, 1341), { mode = "PlayerDirect", drop = true }) then return end
        local children = jewelry.Boxes:GetChildren()
        table.sort(children, function(a, b)
            return getXZMag(root, a) < getXZMag(root, b)
        end)
        for i, v in next, children do
            if v.Transparency < 1 and v.Position.Y > 18 then
                if not teleport(CFrame.new((v.CFrame * CFrame.new(0, 0, 2.25)).Position, v.Position), { mode = "PlayerDirect", drop = true }) then return end
                task.wait(0.5)
                for idx = 1, 4 do
                    attemptPunch()
                    task.wait(0.5)
                    if checkShouldAbort(true) then return end
                end
                if #workspace.Ringers.Jewelry:GetChildren() > 0 then
                    break
                end
            end
        end
    else
        task.wait(0.5)
        if not teleport(CFrame.new(139, 19, 1341), { mode = "PlayerDirect", drop = true }) then return end
        task.wait(0.25)
    end
    hasRobbed.Jewelry = true
    root.CFrame = CFrame.new(root.Position.X, 32, root.Position.Z)
    root.Anchored = true
    for i, v in next, specs do
        if isBagFull() then break end
        if collectionService:HasTag(v.Part, "RobberyJewelryJewel") then
            v:Callback(true)
            task.wait(0.1)
            if checkShouldAbort(true) then return end
        end
    end
    root.Anchored = false
    if checkShouldAbort() then return end
    if not teleport(CFrame.new(139, 18, 1341), { mode = "PlayerDirect", drop = true }) then return end
    task.wait(0.5)
    doCancelTp = false
    if not teleport(CFrame.new(143, 18, 1358), { mode = "PlayerDirect", drop = true }) then return end
    task.wait(0.25)
    if robberyMoneyGui.Enabled and teleport(CFrame.new(-250, 26, 1616), { mode = "Car", stallDrop = function() return tick() - init > delayTime end }) then
        repeat task.wait() until robberyMoneyGui.Enabled == false
    end
end

local function robPassengerTrain()
    doCancelTp = false
    hasRobbed.TrainPassenger = true
    local start = tick()
    repeat
        for i, v in next, specs do
            if v.Name == "Grab briefcase" then
                v:Callback(true)
                task.wait(1)
                if isBagFull() or checkShouldAbort(true) then return end
            end
        end
        task.wait()
    until isBagFull() or tick() - start > 20
    if robberyMoneyGui.Enabled then
        if not teleport(CFrame.new(1816, 48, -1634), { mode = "Car", exitVehicle = true, drop = true }) then return end
        if not chainTeleportDirect({
            CFrame.new(1797, 51, -1663),
            CFrame.new(1753, 51, -1731),
            CFrame.new(1763, 51, -1781)
        }, 100) then return end
        repeat task.wait() until robberyMoneyGui.Enabled == false
        if checkShouldAbort() then return end
        if not chainTeleportDirect({
            CFrame.new(1753, 51, -1731),
            CFrame.new(1816, 48, -1634)
        }, 100) then return end
    end
end

local function robCargoTrain()
    doCancelTp = false
    local car = workspace.Trains:WaitForChild("BoxCar", 10)
    if car then
        local gold = car.Model.Rob.Gold
        teleport(gold, { mode = "Car", exitVehicle = true, stallDrop = function()
            return select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(gold.Position, Vector3.new(0, tpHeight - gold.Position.Y, 0)), getTeleportIgnoreList(), true)) == nil
        end })
        for i, v in next, specs do
            if v.Name == "Breach Vault" or v.Name == "Open Door" then
                v:Callback(true)
            end
        end
        local conn
        conn = runService.Heartbeat:Connect(function()
            if checkShouldAbort(true) then
                conn:Disconnect()
            end
            root.CFrame = CFrame.new(gold.Position + Vector3.new(0, 2, 0))
        end)
        if checkShouldAbort(true) then return end
        hasRobbed.TrainCargo = true
        robberyMoneyGui:GetPropertyChangedSignal("Enabled"):Wait()
        repeat task.wait() until isBagFull() or checkShouldAbort(true) or robberyMoneyGui.Enabled == false
        conn:Disconnect()
        if robberyStates.TrainCargo == false and robberyMoneyGui.Enabled then
            hum:TakeDamage(hum.MaxHealth)
            player.CharacterAdded:Wait()
        end
    end
end

local function robPowerPlant()
    doCancelTp = true
    if not teleport(CFrame.new(636, 39, 2357), { mode = "Car", exitVehicle = true, drop = true }) then return end
    if not teleport(CFrame.new(695, 39, 2359), { mode = "PlayerDirect", drop = true }) then return end
    player.PlayerGui.ChildRemoved:Wait()
    if checkShouldAbort(true) then return end
    if not chainTeleportDirect({
        CFrame.new(688, 45, 2348),
        CFrame.new(747, 44, 2327),
        CFrame.new(824, 35, 2294),
        CFrame.new(812, 13, 2155),
        CFrame.new(788, 6, 2145)
    }, 100) then return end
    player.PlayerGui.ChildRemoved:Wait()
    hasRobbed.PowerPlant = true
    if checkShouldAbort(true) then return end
    if not chainTeleportDirect({
        CFrame.new(767, 5, 2148),
        CFrame.new(729, 8, 2113),
        CFrame.new(684, 3, 2132),
        CFrame.new(698, 3, 2184),
        CFrame.new(696, 19, 2222),
        CFrame.new(714, 33, 2276),
        CFrame.new(708, 40, 2282),
        CFrame.new(663, 38, 2307)
    }, 80) and checkShouldAbort() then return end
    doCancelTp = false
    if not teleport(CFrame.new(1816, 48, -1634), { mode = "Car", exitVehicle = true, drop = true }) then return end
    if not chainTeleportDirect({
        CFrame.new(1797, 51, -1663),
        CFrame.new(1753, 51, -1731)
    }, 100) then return end
    root.CFrame = CFrame.new(root.Position.X, 71, root.Position.Z)
    root.Anchored = true
    repeat task.wait() until player.PlayerGui:FindFirstChild("PowerPlantRobberyGui") == nil or getUraniumValue() <= 6000
    task.wait(0.5)
    root.Anchored = false
    if checkShouldAbort() then return end
    if player.PlayerGui:FindFirstChild("PowerPlantRobberyGui") then
        if not teleport(CFrame.new(1763, 51, -1781), { mode = "PlayerDirect" }) then return end
        repeat task.wait() until player.PlayerGui:FindFirstChild("PowerPlantRobberyGui") == nil
        if checkShouldAbort() then return end
    end
    if not chainTeleportDirect({
        CFrame.new(1753, 51, -1731),
        CFrame.new(1816, 48, -1634)
    }, 100) then return end
end

local function robPlane()
    doCancelTp = false
    local plane = workspace:WaitForChild("Plane", 10)
    if plane then
        local done, conn = false, nil
        local car = originals.getLocalVehiclePacket()
        local latest = tick()
        conn = runService.Heartbeat:Connect(function()
            if checkShouldAbort(true) or isBagFull() then
                done = true
                conn:Disconnect()
            end
            local spec
            for i, v in next, specs do
                if v.Name == "Inspect Crate" then
                    spec = v
                    break
                end
            end
            if spec then
                if car then
                    car.Model:SetPrimaryPartCFrame(CFrame.new(spec.Part.Position + Vector3.new(0, -8, 0)))
                else
                    root.CFrame = CFrame.new(spec.Part.Position + Vector3.new(0, -8, 0))
                end
                if tick() - latest > 1 then
                    latest = tick()
                    spec:Callback(true)
                end
            end
        end)
        repeat task.wait() until done
        local start = tick()
        if isBagFull() then
            hasRobbed.CargoPlane = true
            for i, v in next, specs do
                if v.Name == "Open Door" and tostring(getfenv(v.Callback).script) == "RobberyCargoPlane" then
                    v:Callback(true)
                end
            end
            if not checkShouldAbort() then
                task.wait(1)
                teleport(CFrame.new(-400, 23, 2025), { mode = "Car", drop = true, stallDrop = function() return tick() - start > 12 end })
                repeat task.wait() until robberyMoneyGui.Enabled == false
            end
        end
    end
end

local function robShip()
    doCancelTp = false
    local currentVehicle = originals.getLocalVehiclePacket()
    if currentVehicle and not heliNames[currentVehicle.Type] then
        currentVehicle.Model.PrimaryPart.Anchored = true
        exitVehicle()
        task.wait(0.25)
        coroutine.wrap(function()
            task.wait(1)
            currentVehicle.Model.PrimaryPart.Anchored = false
        end)()
    end
    if not teleport(CFrame.new(-477, 45, 1902), { mode = "Car", heli = true }) then return end
    for i = 1, 2 do
        currentVehicle = originals.getLocalVehiclePacket()
        if currentVehicle then
            if currentVehicle.Model.Preset:FindFirstChild("RopePull") == nil then
                task.wait(0.5)
                vehicleClasses.Heli.attemptDropRope()
                task.wait(1.25)
            end
            if checkShouldAbort(true) then return end
            for _, v in next, collectionService:GetTagged("HeliPickup") do
                if v.Name == "Crate" then
                    hasRobbed.CargoShip = true
                    pickUpItem = v
                    break
                end
            end
            task.wait(1)
            if checkShouldAbort() then return end
            vehicleClasses.Heli.attemptDropRope()
            task.wait(1)
            if checkShouldAbort(true) then return end
        end
    end
end

local function robTomb()
    doCancelTp = true
    if not teleport(CFrame.new(452, 26, -454), { mode = "Car", exitVehicle = true, drop = true }) then return end
    if not chainTeleportDirect({
        CFrame.new(541, 28, -502),
        CFrame.new(546, 28, -545),
        CFrame.new(546, -58, -545),
        CFrame.new(524, -57, -359),
        CFrame.new(532, -58, -322),
        CFrame.new(544, -58, -303),
        CFrame.new(578, -71, -251),
        CFrame.new(612, -71, -231),
        CFrame.new(648, -72, -226)
    }) then return end
    local pillars = workspace.RobberyTomb.DartRoom.Pillars:GetChildren()
    table.sort(pillars, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)
    for i, v in next, pillars do
        if not teleport(CFrame.new(v.InnerModel.Platform.Position + Vector3.new(0, 2.5, 0)), { mode = "PlayerDirect", customSpeed = 80 }) then return end
    end
    if not chainTeleportDirect({
        CFrame.new(795, -89, -209),
        CFrame.new(828, -83, -204),
        CFrame.new(938, -84, -191)
    }, 100) then return end
    task.wait(4)
    if not teleport(CFrame.new(965, -84, -188), { mode = "PlayerDirect", drop = true }) then return end
    task.wait(4)
    if not teleport(CFrame.new(974, -84, -186), { mode = "PlayerDirect", drop = true }) then return end
    repeat
        for i, v in next, specs do
            if v.Name == "Collect" and v.Part.Transparency < 1 then
                v:Callback(true)
                task.wait(1)
                if isBagFull() or checkShouldAbort(true) then break end
            end
        end
        task.wait()
    until (robberyMoneyGui.Enabled and isBagFull()) or checkShouldAbort(true)
    hasRobbed.Tomb = true
    if not teleport(CFrame.new(1008, -85, -182), { mode = "PlayerDirect", drop = true }) then return end
    repeat
        for i, v in next, specs do
            if v.Name == "Sit" then
                v:Callback(true)
                task.wait(1)
                if modules.cartSystem.getCartForCharacter(char) ~= nil or checkShouldAbort(true) then break end
            end
        end
        task.wait()
    until modules.cartSystem.getCartForCharacter(char) ~= nil
    repeat task.wait()
        if modules.tombSystem._duckTrack and not modules.tombSystem._duckPromise then
            modules.tombSystem.duck()
        end
    until robberyMoneyGui.Enabled == false
    pressKey(Enum.KeyCode.Space)
    task.wait(0.5)
    root.CFrame = root.CFrame * CFrame.new(-3, 0, 0)
    local exit, dist = nil, math.huge
    for i, v in next, tombExits do
        local mag = (v.Position - root.Position).Magnitude
        if mag < dist then
            exit, dist = v, mag
        end
    end
    local path = pathfindingService:CreatePath({ AgentCanJump = false, WaypointSpacing = 25 })
	path:ComputeAsync(root.Position, exit.Position)
	local waypoints = path:GetWaypoints()
	for i = 1, #waypoints do
		if not playerTeleportDirect(CFrame.new(waypoints[i].Position + Vector3.new(0, 4, 0)), (waypoints[i].Position - root.Position).Magnitude < 24 and 25 or 60, i == #waypoints) then return end
	end
end

local function robAirdrop(drop)
    doCancelTp = true
    if not teleport(drop.CFrame * CFrame.new(0, 5, 0), { mode = "Car" }) then return end
    local spec
    for i, v in next, specs do
        if v.Part == drop then
            spec = v
            break
        end
    end
    for i = 1, 5 do
        task.wait(5)
        if checkShouldAbort() or drop.Parent == nil then
            break
        else
            spec:Callback(true)
            task.wait(1)
            if drop.Parent == nil then
                break
            end
        end
    end
end

local money, start = 0, 0
local isAtAfk = false

local robberies = {
    Bank = robBank,
    Jewelry = robJewelry,
    TrainPassenger = robPassengerTrain,
    TrainCargo = robCargoTrain,
    PowerPlant = robPowerPlant,
    CargoPlane = robPlane,
    CargoShip = robShip,
    Tomb = robTomb
}

local extraConditions = {
    CargoPlane = function()
        for i, v in next, specs do
            if v.Name == "Inspect Crate" and v.Part.Transparency < 1 then
                return true
            end
        end
        return false
    end,
    Tomb = function()
        return replicatedStorage.RobberyState[tostring(nameToId.Tomb)].Value == modules.robberyConsts.ENUM_STATE.STARTED
    end
}

local function getClosestAirdrop()
    local drop, dist = nil, math.huge
    for i, v in next, workspace:GetChildren() do
        if v.Name == "Drop" and v.ClassName == "Model" and not v:FindFirstChild("Parachute") then
            local mag = (v.Briefcase.Position - root.Position).Magnitude
            if mag < dist then
                drop, dist = v.Briefcase, mag
            end
        end
    end
    return drop
end

local function noOpenRobberies()
    for i, v in next, robberyStates do
        if robberies[i] and not hasRobbed[i] and v and (extraConditions[i] == nil or extraConditions[i]()) then
            return false
        end
    end
    return getClosestAirdrop() == nil
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

for i, v in next, players:GetPlayers() do
    if v ~= player then
        registerEsp(v)
    end
end

for _, gunFile in next, replicatedStorage.Game.ItemConfig:GetChildren() do
    local gun = require(gunFile)
    gunTables[gunFile.Name], gunData[gunFile.Name] = gun, {}
    cache.misc:DeepCopy(gun, gunData[gunFile.Name], true)
end

for i, v in next, modules.vehicleData do
    if v.Price == 0 or v.Price == nil then
        ownedVehicles[v.Make] = true
    end
    if v.Type == "Heli" then
        heliNames[v.Make] = true
    elseif v.Type == "Chassis" then
        carNames[v.Make] = true
    end
end

for i, v in next, clientEvents do
    if type(v) == "function" and islclosure(v) then
        local consts = getconstants(v)
        if consts[1] == "OpenSlider" then
            clientHashes.openSlider = i
        elseif consts[4] == "TiresLastPop" then
            clientHashes.tirePop = i
        elseif table.find(consts, "Stunned") then
            clientHashes.taze = i
        elseif table.find(consts, "PlusCash") then
            clientHashes.plusCash = i
        elseif table.find(consts, "FallOutOfSky") then
            clientHashes.fallOutOfSky = i
        elseif table.find(consts, "SpinOut") then
            clientHashes.spinOut = i
        end
    end
end

for i, v in next, getconnections(runService.Heartbeat) do
    if v.Function and islclosure(v.Function) then
        local consts = getconstants(v.Function)
        if table.find(consts, "Time/UI") then
            timeFunc = getupvalue(v.Function, 6)
            timeFuncIndex = table.find(getconstants(timeFunc), 0.5)
        elseif table.find(consts, "Vehicle Heartbeat") then
            vehicleClasses = getupvalue(v.Function, 2)
            originals.heliUpdate = vehicleClasses.Heli.Update
            originals.getClosestPickup = vehicleClasses.Heli.GetClosestPickup
            isHoldingIndex = tableFind(getconstants(originals.heliUpdate), 0.65)
        end
    end
end

for i, v in next, modules.inventoryItemSystem._equipConditions do
    if type(v) == "function" and getconstants(v)[1] == "IsCrawling" then
        equipCondition = v
        break
    end
end

for i, v in next, replicatedStorage.RobberyState:GetChildren() do
    registerRobbery(v)
end

for i, v in next, workspace:GetChildren() do
	if not players:GetPlayerFromCharacter(v) then
		wallbangIgnore[#wallbangIgnore + 1] = v
	end
    if v.Name == "Drop" and v.ClassName == "Model" then
        cache.groups.airdrops:Add(v, { name = "Airdrop" })
    end
end

for i, v in next, minimap:GetChildren() do
	v:GetPropertyChangedSignal("Visible"):Connect(function()
		if v.Visible == false and settings.visuals.misc.minimapShowAll then
			v.Visible = true
		end
	end)
end

for i, v in next, collectionService:GetTagged("JetPackNoFly") do
    noFlyAreas[#noFlyAreas + 1] = v
end

for i, v in next, collectionService:GetTagged("NoClipAllowed") do
    noClipAllowed[v] = v.Parent
end

modules.gun.SetupBulletEmitter(fakeSniper)

--[[ ==========  GUI  ========== ]]

local profile = cache.library:AddProfile()

local aimbotTab = cache.library:AddTab("Aimbot", "Aiming & Shooting Mods", "rbxassetid://7824873749")

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
end, { items = { "HumanoidRootPart", "Head" }, default = "HumanoidRootPart" })
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

local visualsTab = cache.library:AddTab("Visuals", "ESP, Hitbox Extender, etc", "rbxassetid://7825051458")

local playerEsp = visualsTab:AddPanel("Player ESP", { info = "Player ESP - Allows you to see players and info about them from anywhere" })
playerEsp:AddToggle("Show Names", function(state)
    cache.groups.players.settings.names = state
end)
playerEsp:AddToggle("Show Boxes", function(state)
    cache.groups.players.settings.boxes = state
end)
playerEsp:AddToggle("Show Skeletons", function(state)
    cache.groups.players.settings.skeletons = state
end)
playerEsp:AddToggle("Show Distances", function(state)
    cache.groups.players.settings.distances = state
end)
playerEsp:AddToggle("Show Health Percentages", function(state)
    cache.groups.players.settings.percentages = state
end)
playerEsp:AddToggle("Show Health Bars", function(state)
    cache.groups.players.settings.bars = state
end)
playerEsp:AddToggle("Show Tracers", function(state)
    cache.groups.players.settings.tracers = state
end)
playerEsp:AddToggle("Show Teammates", function(state)
    cache.groups.players.settings.teammates = state
end)
playerEsp:AddSlider("Text Size", function(value)
    cache.groups.players:UpdateTextSize(value)
end, { min = 8, max = 32, default = 14 })
playerEsp:AddSlider("Box Thickness", function(value)
    cache.groups.players:UpdateBoxThickness(value)
end, { min = 1, max = 5, default = 1 })
playerEsp:AddSlider("Skeleton Thickness", function(value)
    cache.groups.players:UpdateSkeletonThickness(value)
end, { min = 1, max = 5, default = 1 })

local playerEsp = visualsTab:AddPanel("Airdrop ESP", { info = "Airdrop ESP - Allows you to see airdrops from anywhere" })
playerEsp:AddToggle("Show Names", function(state)
    cache.groups.airdrops.settings.names = state
end, { flag = "airdropnames" })
playerEsp:AddToggle("Show Distances", function(state)
    cache.groups.airdrops.settings.distances = state
end, { flag = "airdropdistances" })
playerEsp:AddSlider("Text Size", function(value)
    cache.groups.airdrops:UpdateTextSize(value)
end, { min = 8, max = 32, default = 14 })

local visualsMisc = visualsTab:AddPanel("Misc", { info = "Misc - Random other visual mods" })
visualsMisc:AddToggle("Show Everyone On Minimap", function(state)
    settings.visuals.misc.minimapShowAll = state
	for i, v in next, minimap:GetChildren() do
		v.Visible = state or players[v.Name].Team == player.Team
	end
end)

local teleportsTab = cache.library:AddTab("Teleports", "TP Locations Across The Map", "rbxassetid://7958646775")

local locations = teleportsTab:AddPanel("Locations", { info = "Locations - TP Anywhere On The Map" })
local selectedLocation = locations:AddStatusLabel("Selected:", "None")
locations:AddDropdown("Robberies", function(value)
    if value ~= "" then
        selectedLocation:Update(value)
    end
end, { items = { "Bank", "Jewelry Store", "Museum", "Power Plant", "Tomb", "Donut Store", "Gas Station", "Airdrop" }, noDisplay = true })
locations:AddDropdown("Vehicle Spawns", function(value)
    if value ~= "" then
        selectedLocation:Update(value.Name)
    end
end, { items = workspace.VehicleSpawns:GetChildren(), noDisplay = true })
locations:AddDropdown("Places", function(value)
    if value ~= "" then
        selectedLocation:Update(value)
    end
end, { items = { "Prison Yard", "1M Dealership", "Volcano Base", "Military Base", "Police Headquarters", "Secret Agent Base", "City Base", "Boat Docks", "Airport", "Fire Station", "Gun Store", "JetPack Mountain", "Pirate Hideout", "Lighthouse", "Prison Island", "Season Leaderboard", "Hacker Cage", "Events Room", "Train Station", "Glider Store", "Dog Shelter" }, noDisplay = true })
locations:AddToggle("Eject When You Arrive", function(state)
    settings.teleports.locations.eject = state
end)
locations:AddButton("Teleport", function()
    if root then
        local selected = selectedLocation._frame.status.Text
        if selected == "Airdrop" then
            if workspace:FindFirstChild("Drop") then
                teleport(workspace.Drop.Briefcase.CFrame, { mode = "Car", exitVehicle = settings.teleports.locations.eject, drop = true })
                return
            end
            cache.library:Notify("Teleportation Failed - No Airdrops")
        elseif selected ~= "None" then
            if workspace.VehicleSpawns:FindFirstChild(selected) then
                local spawns, closest, dist = workspace.VehicleSpawns:GetChildren(), nil, math.huge
                for i, v in next, spawns do
                    if v.Name == selected then
                        local mag = (v.Region.Position - root.Position).Magnitude
                        if mag < dist then
                            closest, dist = v.Region, mag
                        end
                    end
                end
                teleport(closest.CFrame * CFrame.new(-10, 0, 0), { mode = "Car", exitVehicle = settings.teleports.locations.eject, drop = true })
                return
            end
            teleport(robberyLocations[selected] or placeLocations[selected], { mode = "Car", exitVehicle = settings.teleports.locations.eject, drop = true })
        end
    end
end)

local playerTp = teleportsTab:AddPanel("Players", { info = "Players - Teleport to other people" })
local selectedPlayer = playerTp:AddStatusLabel("Selected:", "None")
playerTp:AddBox("Player Name", function(value)
    for i, v in next, players:GetPlayers() do
        if string.find(string.lower(v.Name), string.lower(value)) then
            selectedPlayer:Update(v.Name)
            break
        end
    end
end)
playerTp:AddButton("Teleport", function()
    local plr = players:FindFirstChild(selectedPlayer._frame.status.Text) 
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        teleport(plr.Character.HumanoidRootPart, { mode = "Car", exitVehicle = settings.teleports.locations.eject, drop = true })
    end
end)

teleportsTab:AddPanel(nil, { info = "Abort - Cancel whatever TP you're currently doing" }):AddButton("Abort", function()
    if isTeleporting then
        cancelTp = true
        local vehicle = originals.getLocalVehiclePacket()
        if vehicle then
            if vehicle.Type == "Chassis" then
                modules.alexChassis.SetGravity(vehicle, 100)
            elseif vehicle.Type ~= "Heli" then
                workspace.Gravity = 196.2
            end
        end
    end
end)

local playerTab = cache.library:AddTab("Player", "Player & Character Mods", "rbxassetid://7826527270")

local charMods = playerTab:AddPanel("Character", { info = "Various modifications to your character" })
charMods:AddToggle("Custom WalkSpeed", function(state)
    settings.playerMods.charMods.walkEnabled = state
    if hum then
        hum.WalkSpeed = state and settings.playerMods.charMods.walkSpeed or 16
    end
end)
charMods:AddSlider("WalkSpeed", function(value)
    settings.playerMods.charMods.walkSpeed = value
    if hum then
        hum.WalkSpeed = settings.playerMods.charMods.walkEnabled and value or 16
    end
end, { min = 16, max = playerSpeed })
charMods:AddToggle("Custom JumpPower", function(state)
    settings.playerMods.charMods.jumpEnabled = state
    if hum then
        hum.JumpPower = state and settings.playerMods.charMods.jumpPower or 50
    end
end)
charMods:AddSlider("JumpPower", function(value)
    settings.playerMods.charMods.jumpPower = value
    if hum then
        hum.JumpPower = settings.playerMods.charMods.jumpEnabled and value or 50
    end
end, { min = 50, max = 200 })
charMods:AddBind("Fly", function(bindName)
    stopConnection("fly")
	isFlying = not isFlying
	if isFlying then
		addConnection("fly", runService.Heartbeat:Connect(function(step)
			if root and not char:FindFirstChild("InVehicle") then
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
                flyVec = Vector3.new(flyVec.X, 1e-10, flyVec.Z)
                if flyKeys.Space then
                    flyVec = flyVec + Vector3.new(0, 1, 0)
                end
                if flyKeys.LeftShift then
                    flyVec = flyVec + Vector3.new(0, -1, 0)
                end
                local isBaseVec = flyVec == baseFlyVec
                root.Velocity = (isBaseVec and flyVec or flyVec.Unit) * settings.playerMods.charMods.flySpeed
                root.Anchored = isBaseVec
			end
		end))
    elseif root and root.Anchored then
        root.Anchored = false
	end
end)
charMods:AddSlider("Fly Speed", function(value)
    settings.playerMods.charMods.flySpeed = value
end, { min = 16, max = 150, default = 150 })
charMods:AddToggle("Infinite Jump", function(state)
    settings.playerMods.charMods.infJump = state
end)
charMods:AddToggle("Instant Specs", function(state)
    settings.playerMods.charMods.instantSpecs = state
end)
charMods:AddToggle("No Punch Cooldown", function(state)
    settings.playerMods.charMods.noPunchCooldown = state
end)
charMods:AddToggle("Anti Ragdoll", function(state)
    settings.playerMods.charMods.antiRagdoll = state
end)
charMods:AddToggle("Anti Fall Damage", function(state)
    settings.playerMods.charMods.antiFallDamage = state
end)
charMods:AddToggle("Anti Taze", function(state)
    settings.playerMods.charMods.antiTaze = state
end)
charMods:AddToggle("Anti Skydive", function(state)
    settings.playerMods.charMods.antiSkydive = state
end)
charMods:AddToggle("Anti Slow When Injured", function(state)
    setconstant(timeFunc, timeFuncIndex, state and 1 or 0.5)
end)

local cosmetics = playerTab:AddPanel("Cosmetic", { info = "Visual changes to your character" })
cosmetics:AddToggle("FE Orange Justice", function(state)
    settings.playerMods.cosmetic.orangeJustice = state
    if state then
        orangeJustice()
    elseif orangeJusticeTrack then
        orangeJusticeTrack:Stop()
        orangeJusticeTrack = nil
    end
end)
cosmetics:AddButton("Give Police Uniform", function()
    local uniform = { ShirtPolice = true, PantsPolice = true, HatPolice = true }
	for i, v in next, workspace.Givers:GetChildren() do
		if uniform[v.Item.Value] then
			uniform[v.Item.Value] = nil
			fireclickdetector(v.ClickDetector)
			task.wait(0.25)
		end
	end
end)
cosmetics:AddButton("Remove Outfit", function()
    fireclickdetector(workspace.ClothingRacks.ClothingRack.Hitbox.ClickDetector)
end)

local safes = playerTab:AddPanel("Safes", { info = "Safes - Modifications to opening safes" })
safes:AddToggle("Auto Skip Slider", function(state)
    settings.playerMods.safes.autoSkip = state
end)
safes:AddButton("Open All Safes", function()
    repeat
        if not modules.safesUI.Gui.ContainerSlider.Visible then
            modules.safesUI.SelectedSafe = modules.safesUI.ListSafes[1]
            originals.openSafe()
        end
        task.wait(1)
    until #modules.safesUI.ListSafes == 0
end)

local vehicleTab = cache.library:AddTab("Vehicles", "Mods For Every Vehicle Type", "rbxassetid://7960881624")

local cars = vehicleTab:AddPanel("Cars", { info = "Cars - Vehicle Mods specific to land vehicles" })
cars:AddSlider("Engine Speed", function(value)
    settings.vehicleMods.cars.speed = value
    updateVehicle("GarageEngineSpeed", value)
end, { min = 1 })
cars:AddSlider("Brakes", function(value)
    settings.vehicleMods.cars.brakes = value
    updateVehicle("GarageBrakes", value)
end, { min = 1 })
cars:AddSlider("Suspension Height", function(value)
    settings.vehicleMods.cars.height = value
    updateVehicle("Height", value + 2)
end, { min = 1 })
cars:AddSlider("Turn Speed", function(value)
    settings.vehicleMods.cars.turn = value
    updateVehicle("TurnSpeed", value)
end, { min = 1 })
cars:AddToggle("Infinite Nitro", function(state)
    settings.vehicleMods.cars.infNitro = state
    if state then
        local nitro = vehicleTable.Nitro
        repeat task.wait()
            vehicleTable.Nitro = 250
        until settings.vehicleMods.cars.infNitro == false
        vehicleTable.Nitro = nitro
    end
end)
cars:AddToggle("Drive On Water", function(state)
    settings.vehicleMods.cars.driveOnWater = state
end)
cars:AddToggle("Auto Flip Over", function(state)
    settings.vehicleMods.cars.autoFlip = state
end)
cars:AddToggle("Anti Tire Pop", function(state)
    settings.vehicleMods.cars.antiTirePop = state
end)
cars:AddToggle("Anti Pit Maneuver", function(state)
    settings.vehicleMods.cars.antiPitManeuver = state
end)
cars:AddToggle("Injan Horn", function(state)
    modules.gameSettings.Perm.InjanHorn.Id[tostring(player.UserId)] = state or nil
end)
cars:AddToggle("Epileptic Headlights", function(state)
    settings.vehicleMods.cars.epilepsy = state
    if state then
        repeat task.wait(0.1)
            local vehicle = originals.getLocalVehiclePacket()
            if vehicle and vehicle.Type == "Chassis" then
                modules.alexChassis.toggleHeadlights()
            end
        until settings.vehicleMods.cars.epilepsy == false
    end
end)

local helis = vehicleTab:AddPanel("Helicopters", { info = "Helicopters - Vehicle Mods specific to Helis" })
helis:AddSlider("Heli Speed", function(value)
    settings.vehicleMods.helis.speed = value
end, { min = 1 })
helis:AddToggle("Anti Fall Out Of Sky", function(state)
    settings.vehicleMods.helis.antiFall = state
end)
helis:AddToggle("Instant Pickup", function(state)
    settings.vehicleMods.helis.instantPickup = state
end)
helis:AddToggle("Infinite Heli Height", function(state)
    settings.vehicleMods.helis.infHeliHeight = state
end)
helis:AddToggle("Infinite Drone Height", function(state)
    settings.vehicleMods.helis.infDroneHeight = state
end)
helis:AddToggle("No Slow When Carrying Object", function(state)
    setconstant(originals.heliUpdate, isHoldingIndex, state and 1 or 0.65)
end)

local boats = vehicleTab:AddPanel("Boats", { info = "Boats - Vehicle Mods specific to water vehicles" })
helis:AddSlider("Boat Speed", function(value)
    settings.vehicleMods.boats.speed = value
end, { min = 1 })
boats:AddToggle("Boats On Land", function(state)
    settings.vehicleMods.boats.boatsOnLand = state
end)
boats:AddToggle("JetSki On Land", function(state)
    settings.vehicleMods.boats.jetskiOnLand = state
end)

local offense = vehicleTab:AddPanel("Offense", { info = "Offense - Mods that work against other vehicles" })
offense:AddToggle("Pop All Tires [250m Range]", function(state)
    settings.vehicleMods.offense.popTires = state
    if state then
        repeat task.wait(0.25)
            for i, v in next, workspace.Vehicles:GetChildren() do
                if carNames[v.Name] and eligibleCar(v) and v.WheelFrontLeft.Wheel.Transparency == 0 then
                    shootVehicle(v.Engine)
                    task.wait(0.25)
                end
            end
        until settings.vehicleMods.offense.popTires == false
    end
end)
offense:AddToggle("Shoot Down Helis [250m Range]", function(state)
    settings.vehicleMods.offense.shootDownHelis = state
    if state then
        repeat task.wait(0.25)
            for i, v in next, workspace.Vehicles:GetChildren() do
                if heliNames[v.Name] and eligibleCar(v) and v.Model.Body.Smoke.Enabled == false then
                    for _ = 1, 2 do
                        shootVehicle(v.Engine)
                        task.wait(0.25)
                    end
                end
            end
        until settings.vehicleMods.offense.shootDownHelis == false
    end
end)
offense:AddToggle("Team Check", function(state)
    settings.vehicleMods.offense.teamCheck = state
end)

local itemModsTab = cache.library:AddTab("Item Mods", "Cosmetic & Performance Changes", "rbxassetid://7825568616")

local gunsMain = itemModsTab:AddPanel("Gun Mods", { info = "Gun Mods - Modify several aspects of your gun's performance. Note: Wallbang only works close up, cross-map hits won't register" })
gunsMain:AddToggle("Wallbang", function(state)
    settings.itemMods.gunMods.wallbang = state
end)
gunsMain:AddToggle("Full Automatic", function(state)
    for i, v in next, gunTables do
        v.FireAuto = state and true or gunData[i].FireAuto
    end
end)
gunsMain:AddToggle("No Recoil", function(state)
    for i, v in next, gunTables do
        v.CamShakeMagnitude = state and 0 or gunData[i].CamShakeMagnitude
    end
end)
gunsMain:AddToggle("No Spread", function(state)
    for i, v in next, gunTables do
        v.BulletSpread = state and 0 or gunData[i].BulletSpread
    end
end)
gunsMain:AddToggle("No Flintlock Knockback", function(state)
    settings.itemMods.gunMods.noFlintlockKnockback = state
end)
gunsMain:AddButton("Grab All Guns", function()
    setthreadidentity(2)
    local isGunShopOpen = not select(1, pcall(modules.gunShopUI.open))
    modules.gunShopUI.displayList(modules.gunShopUtils.getCategoryData("Held"))
    setthreadidentity(7)
    for i, v in next, player.PlayerGui.GunShopGui.Container.Container.Main.Container:GetChildren() do
        if v.Name == "Slider" then
            grabAllGuns(v)
        end
    end
    if isGunShopOpen == false then
        modules.gunShopUI.close()
    end
end)

local gunFireRate = itemModsTab:AddPanel("Fire Rate", { info = "Fire Rate - Adjusts how fast your gun fires" })
gunFireRate:AddToggle("Enabled", function(state)
    settings.itemMods.fireRate.enabled = state
    for i, v in next, gunTables do
        v.FireFreq = state and settings.itemMods.fireRate.rate / 60 or gunData[i].FireFreq
    end
end, { flag = "firerateenabled" })
gunFireRate:AddSlider("Fire Rate", function(value)
    settings.itemMods.fireRate.rate = value
    for i, v in next, gunTables do
        v.FireFreq = settings.itemMods.fireRate.enabled and value / 60 or gunData[i].FireFreq
    end
end, { min = 0, max = 2500 })

local jetPack = itemModsTab:AddPanel("JetPack", { info = "JetPack - Mods and bypasses for your JetPack" })
jetPack:AddToggle("Infinite Fuel", function(state)
    settings.itemMods.jetPack.infFuel = state
    local maxFuel = modules.jetPackUtil.Fuel[settings.itemMods.jetPack.premiumFuel and "Rocket" or "Standard"].MaxFuel
    repeat task.wait()
        if jetPackEquipped then
            jetPackEquipped.Fuel, jetPackEquipped.MaxFuel = maxFuel, maxFuel
        end
    until settings.itemMods.jetPack.infFuel == false
end)
jetPack:AddToggle("Premium Fuel", function(state)
    settings.itemMods.jetPack.premiumFuel = state
    if jetPackEquipped then
        jetPackEquipped.FuelType = state and "Rocket" or "Standard"
        local fuelTable = modules.jetPackUtil.Fuel[jetPackEquipped.FuelType]
        jetPackEquipped.Fuel = math.min(jetPackEquipped.Fuel, fuelTable.MaxFuel)
        jetPackEquipped.MaxFuel = fuelTable.MaxFuel
        jetPackEquipped.Model.LeftSmoke.Fire.Color = fuelTable.ParticleColor
        jetPackEquipped.Model.RightSmoke.Fire.Color = fuelTable.ParticleColor
        jetPackEquipped.LeanAngle = fuelTable.LeanAngle
        modules.jetPackGui.SetFuelType(jetPackEquipped.FuelType)
    end
end)
jetPack:AddToggle("Bypass No Fly Zones", function(state)
    for i, v in next, noFlyAreas do
        if state then
            collectionService:RemoveTag(v, "JetPackNoFly")
        else
            collectionService:AddTag(v, "JetPackNoFly")
        end
    end
end)

local gunUtility = itemModsTab:AddPanel("Utility", { info = "Utility - Mods based around using your weapons" })
gunUtility:AddToggle("Shoot While Driving", function(state)
    settings.itemMods.utility.shootWhileDriving = state
end)
gunUtility:AddToggle("Shoot While Crawling", function(state)
    setconstant(equipCondition, 1, state and "Nope" or "IsCrawling")
end)
gunUtility:AddToggle("Shoot While Jetpacking", function(state)
    settings.itemMods.utility.shootWhileJetpacking = state
end)

local projectiles = itemModsTab:AddPanel("Projectiles", { info = "Projectiles - Disable things the game shoots at you"})
projectiles:AddToggle("Disable Military Turrets", function(state)
    settings.itemMods.projectiles.disableMilitary = state
end)
projectiles:AddToggle("Disable Ship Turrets", function(state)
    settings.itemMods.projectiles.disableTurrets = state
end)
projectiles:AddToggle("Disable Dart Dispensers", function(state)
    settings.itemMods.projectiles.disableDispensers = state
end)

local robberyTab = cache.library:AddTab("Robbery", "Robbery mods and statuses", "rbxassetid://7882303217")

local autoRob = robberyTab:AddPanel("Auto Rob", { info = "Auto Rob - AFK money farm. Robs:\n\nJewelry Store\nPassenger Train\nPower Plant" })
local hourlyRate = autoRob:AddStatusLabel("Money/hr:", "$0")
local elapsed = autoRob:AddStatusLabel("Elapsed:", "0 mins")
autoRob:AddToggle("Enabled", function(state)
    settings.robbery.autoRob.enabled = state
    if state == false then
        if isTeleporting then
            cancelTp = true
        end
        local vehicle = originals.getLocalVehiclePacket()
        if vehicle and vehicle.Type == "Chassis" then
            modules.alexChassis.SetGravity(vehicle, 100)
        end
        isAtAfk = false
    else
        money, start = moneyValue.Value, tick()
        if branch.Rail.Transparency < 1 then
            fireclickdetector(branch.Lever.Click.ClickDetector)
        end
        repeat task.wait()
            if settings.robbery.autoRob.enabled and player.Team ~= teams.Police then
                if player.Team == teams.Criminal and root and not char:FindFirstChild("Handcuffs") then
                    for i, v in next, robberyStates do
                        if robberies[i] and v and not hasRobbed[i] and not checkShouldAbort() and (extraConditions[i] == nil or extraConditions[i]()) then
                            isAtAfk, currentRobbery = false, i
                            local s, r = pcall(robberies[i])
                            if rconsoleprint and not s then
                                rconsoleprint("\n========  AUTOROB ERROR  ========\n" .. r .. "\n")
                            end
                            currentRobbery = ""
                            if settings.robbery.autoRob.enabled == false then
                                break
                            end
                        end
                    end
                    local airdrop = getClosestAirdrop()
                    if settings.robbery.autoRob.enabled and airdrop then
                        isAtAfk, currentRobbery = false, "Airdrop"
                        pcall(robAirdrop, airdrop)
                    end
                end
                if isAtAfk == false and settings.robbery.autoRob.enabled and (player.Team == teams.Prisoner or noOpenRobberies()) then
                    if teleport(CFrame.new(math.random(-50, 50), math.random(425, 500), math.random(-50, 50)), { mode = "Car" }) then
                        isAtAfk = true
                    end
                end
            end
        until settings.robbery.autoRob.enabled == false
        hourlyRate:Update("$0")
        elapsed:Update("0 mins")
    end
end, { flag = "autorobenabled" })

local robIndicators = robberyTab:AddPanel("Statuses", { info = "Statuses - Tells you when each robbery is open or closed" })
statusLabels.Bank = robIndicators:AddStatusLabel("Bank", robberyStates.Bank and "Open" or "Closed", { colour = robberyStates.Bank and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.Jewelry = robIndicators:AddStatusLabel("Jewelry", robberyStates.Jewelry and "Open" or "Closed", { colour = robberyStates.Jewelry and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.Museum = robIndicators:AddStatusLabel("Museum", robberyStates.Museum and "Open" or "Closed", { colour = robberyStates.Museum and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.PowerPlant = robIndicators:AddStatusLabel("Power Plant", robberyStates.PowerPlant and "Open" or "Closed", { colour = robberyStates.PowerPlant and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.Tomb = robIndicators:AddStatusLabel("Tomb", robberyStates.Tomb and "Open" or "Closed", { colour = robberyStates.Tomb and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.TrainPassenger = robIndicators:AddStatusLabel("Passenger Train", robberyStates.TrainPassenger and "Open" or "Closed", { colour = robberyStates.TrainPassenger and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.TrainCargo = robIndicators:AddStatusLabel("Cargo Train", robberyStates.TrainCargo and "Open" or "Closed", { colour = robberyStates.TrainCargo and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.CargoPlane = robIndicators:AddStatusLabel("Cargo Plane", robberyStates.CargoPlane and "Open" or "Closed", { colour = robberyStates.CargoPlane and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.CargoShip = robIndicators:AddStatusLabel("Cargo Ship", robberyStates.CargoShip and "Open" or "Closed", { colour = robberyStates.CargoShip and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.MoneyTruck = robIndicators:AddStatusLabel("Money Truck", robberyStates.MoneyTruck and "Open" or "Closed", { colour = robberyStates.MoneyTruck and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.Donut = robIndicators:AddStatusLabel("Donut Store", robberyStates.Donut and "Open" or "Closed", { colour = robberyStates.Donut and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })
statusLabels.Gas = robIndicators:AddStatusLabel("Gas Station", robberyStates.Gas and "Open" or "Closed", { colour = robberyStates.Gas and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36) })

local robMods = robberyTab:AddPanel("Mods", { info = "Mods - Different modifications to robberies" })
robMods:AddToggle("Auto Solve Puzzles", function(state)
    settings.robbery.robMods.autoSolve = state
    if state and puzzle.IsOpen then
        solvePuzzle()
    end
end)
robMods:AddToggle("Auto Fill Jewelry Bag", function(state)
    settings.robbery.robMods.autoJewel = state
end)
robMods:AddToggle("Auto Fill Museum Bag", function(state)
    settings.robbery.robMods.autoMuseum = state
end)
robMods:AddToggle("No Museum Detection", function(state)
    setconstant(museumDetect, museumDetectIndex, state and math.huge or 0.5)
end)
robMods:AddToggle("No Robbery Marker Delay", function(state)
    settings.robbery.robMods.noIconDelay = state
end)
robMods:AddToggle("Notify When A Store Opens", function(state)
    settings.robbery.robMods.notify = state
end)
robMods:AddButton("Solve Museum Laser Puzzle", function()
    for i, v in next, museumPuzzle1.Background:GetChildren() do
        coroutine.wrap(function()
            local spinner = museumPuzzle1.Spinners[v.Name:gsub("Part", "")]
            if spinner.Rotation ~= Vector3.new(180, -51.94, 0) then
                repeat
                    fireclickdetector(v.ClickDetector)
                    task.wait(0.1)
                until spinner.Rotation == Vector3.new(180, -51.94, 0)
            end
        end)()
    end
end)
robMods:AddButton("Solve Museum Path Puzzle", function()
    for i, v in next, pathRotations do
        coroutine.wrap(function()
            local puzzlePiece = museumPuzzle2[i]
            if puzzlePiece.Rotation ~= v then
                repeat
                    fireclickdetector(puzzlePiece.ClickDetector)
                    task.wait(0.1)
                until puzzlePiece.Rotation == v
            end
        end)()
    end
end)

local funTab = cache.library:AddTab("Fun", "Random / Trolling Mods", "rbxassetid://7958602499")

local door = funTab:AddPanel("Doors", { info = "Doors - Open every door on the map" })
door:AddToggle("Bypass Doors", function(state)
    settings.funMods.doors.bypassCheck = state
end)
door:AddToggle("Loop Open All Doors", function(state)
    settings.funMods.doors.loopOpen = state
    if state then
        repeat
            openDoors()
            task.wait(1)
        until settings.funMods.doors.loopOpen == false
    end
end)
door:AddButton("Open All Doors", openDoors)

local wall = funTab:AddPanel("Wall", { info = "Wall - Explode the wall at the far side of the prison" })
wall:AddToggle("Loop Explode Wall", function(state)
    settings.funMods.wall.loopExplode = state
    if state then
        repeat
            explodeWall()
            task.wait(6.05)
        until settings.funMods.wall.loopExplode == false
    end
end)
wall:AddButton("Explode Wall", explodeWall)

local gate = funTab:AddPanel("Gate", { info = "Gate - Lift the gate next to the prison helipad" })
gate:AddToggle("Loop Lift Gate", function(state)
    settings.funMods.gate.loopLift = state
    if state then
        repeat
            liftGate()
            task.wait(4.05)
        until settings.funMods.gate.loopLift == false
    end
end)
gate:AddButton("Lift Gate", liftGate)

local sewers = funTab:AddPanel("Sewers", { info = "Sewers - Open every escape sewer on the map" })
sewers:AddToggle("Loop Open All Sewers", function(state)
    settings.funMods.sewers.loopOpen = state
    if state then
        repeat
            openSewers()
            task.wait(3.7)
        until settings.funMods.sewers.loopOpen == false
    end
end)
sewers:AddButton("Open All Sewers", openSewers)

local volcano = funTab:AddPanel("Volcano", { info = "Volcano - Trigger the Volcano base eruption" })
volcano:AddToggle("Loop Erupt Volcano", function(state)
    settings.funMods.volcano.loopErupt = state
    if state then
        repeat
            fireTouchInterest(workspace.LavaFun.Lavatouch)
            task.wait(3.55)
        until settings.funMods.volcano.loopErupt == false
    end
end)
volcano:AddButton("Erupt Volcano", function()
    fireTouchInterest(workspace.LavaFun.Lavatouch)
end)

local otherFun = funTab:AddPanel("Other", { info = "Other - Miscellaneous Fun Mods" })
otherFun:AddBox("Launch Fireworks", function(value)
    if value ~= "" then
        launchFireworks(tonumber(value))
    end
end, { numOnly = true })
otherFun:AddBox("Give Cash", function(value)
    if value ~= "" then
        clientEvents[clientHashes.plusCash](tonumber(value), "If only it was real")
    end
end, { numOnly = true })

cache.library:AddSettings()

--[[ ==========  Hooks  ========== ]]

for i, v in next, getproto(registerDoor, 1, true) do
    local old = getupvalue(v, 4)
    setupvalue(v, 4, function(...)
        if settings.funMods.doors.bypassCheck then
            return true
        end
        return old(...)
    end)
end

originals.openSlider = clientEvents[clientHashes.openSlider]
clientEvents[clientHashes.openSlider] = newcclosure(function(...)
    originals.openSlider(...)
    if settings.playerMods.safes.autoSkip then
        firesignal(modules.safesUI.Gui.ContainerSlider.ContainerSkip.MouseButton1Down)
    end
end)

originals.taze = clientEvents[clientHashes.taze]
clientEvents[clientHashes.taze] = newcclosure(function(...)
    if settings.playerMods.charMods.antiTaze == false then
        return originals.taze(...)
    end
end)

originals.fallOutOfSky = clientEvents[clientHashes.fallOutOfSky]
clientEvents[clientHashes.fallOutOfSky] = newcclosure(function(...)
    if isTeleporting == false and settings.vehicleMods.helis.antiFall == false and settings.robbery.autoRob.enabled == false then
        return originals.fallOutOfSky(...)
    end
end)

originals.tirePop = clientEvents[clientHashes.tirePop]
clientEvents[clientHashes.tirePop] = newcclosure(function(...)
    if settings.vehicleMods.cars.antiTirePop == false then
        return originals.tirePop(...)
    end
end)

originals.spinOut = clientEvents[clientHashes.spinOut]
clientEvents[clientHashes.spinOut] = newcclosure(function(...)
    if settings.vehicleMods.cars.antiPitManeuver == false then
        return originals.spinOut(...)
    end
end)

defaultActions.attemptPunch = newcclosure(function(...)
    if settings.playerMods.charMods.noPunchCooldown then
        setupvalue(attemptPunch, 1, 0)
    end
    return attemptPunch(...)
end)

modules.bulletEmitter.Emit = newcclosure(function(self, ...)
    if self.Local then
        local args = {...}
        if settings.itemMods.fireRate.enabled then
            self.LastImpact = 0
        end
        if settings.itemMods.gunMods.wallbang then
            self.IgnoreList = wallbangIgnore
        end
        if settings.aimbot.silentAim.enabled and target and math.random(1, 100) <= settings.aimbot.silentAim.hitChance then
            args[2] = ((math.random(1, 100) <= settings.aimbot.silentAim.headshotChance and target.Parent.Head or target).Position - args[1]).Unit
        end
        originals.emit(self, unpack(args))
    end
end)

modules.plasmaPistol.ShootOther = newcclosure(function(self, ...)
	if self.Local then
		if settings.itemMods.gunMods.wallbang then
			self.IgnoreList = wallbangIgnore
		end
		if settings.aimbot.silentAim.enabled and target and math.random(1, 100) <= settings.aimbot.silentAim.hitChance then
			self.MousePosition = (math.random(1, 100) <= settings.aimbot.silentAim.headshotChance and target.Parent.Head or target).Position
		end
	end
	originals.shootOther(self, ...)
end)

modules.taser.Tase = newcclosure(function(self, ...)
	if self.Local and settings.itemMods.gunMods.wallbang then
		self.IgnoreList = wallbangIgnore
	end
	originals.tase(self, ...)
end)

modules.inventoryItemUtils.setAttr = newcclosure(function(t, k, v)
    if t.Name == "Taser" and k == "NextUse" and settings.itemMods.fireRate.enabled then
        v = tick() + 1 / (settings.itemMods.fireRate.rate / 60)
    end
    originals.setAttr(t, k, v)
end)

modules.basic.UpdateMousePosition = newcclosure(function(self, ...)
    if settings.aimbot.silentAim.enabled and target and math.random(1, 100) <= settings.aimbot.silentAim.hitChance and string.find(traceback(), "Tase") then
        self.MousePosition = (math.random(1, 100) <= settings.aimbot.silentAim.headshotChance and target.Parent.Head or target).Position
        return
    end
    return originals.updateMousePosition(self, ...)
end)

modules.falling.StartRagdolling = newcclosure(function(...)
    if isTeleporting == false and settings.playerMods.charMods.antiRagdoll == false and settings.robbery.autoRob.enabled == false then
        originals.ragdoll(...)
    end
end)

modules.playerUtils.isPointInTag = newcclosure(function(pos, tag)
    if tag == "NoFallDamage" and (isTeleporting or settings.robbery.autoRob.enabled or settings.playerMods.charMods.antiFallDamage) then
        return true
    elseif tag == "NoRagdoll" and (isTeleporting or settings.robbery.autoRob.enabled or settings.playerMods.charMods.antiRagdoll) then
        return true
    elseif tag == "NoParachute" and (isTeleporting or settings.robbery.autoRob.enabled or settings.playerMods.charMods.antiSkydive) then
        return true
    end
    return originals.isPointInTag(pos, tag)
end)

modules.vehicle.GetLocalVehiclePacket = newcclosure(function()
	if settings.itemMods.utility.shootWhileDriving and traceback():find("InventoryItemSystem") then
		return
	end
	return originals.getLocalVehiclePacket()
end)

modules.jetPack.IsFlying = newcclosure(function()
	if settings.itemMods.utility.shootWhileJetpacking and traceback():find("InventoryItemSystem") then
		return false
	end
	return originals.isJetPackFlying()
end)

modules.gamepassSystem.DoesPlayerOwn = newcclosure(function(id)
	if id == modules.gamepassUtils.EnumGamepass.BOSS and settings.robbery.robMods.noIconDelay and traceback():find("RobberyMarkerSystem") then
		return true
	end
	return originals.doesPlayerOwn(id)
end)

modules.turret.Shoot = newcclosure(function(...)
    if not (isTeleporting or settings.robbery.autoRob.enabled or settings.itemMods.projectiles.disableTurrets) then
        originals.turretShoot(...)
    end
end)

modules.dispenser._fire = newcclosure(function(...)
    if not (isTeleporting or settings.robbery.autoRob.enabled or settings.itemMods.projectiles.disableDispensers) then
        originals.dispenserFire(...)
    end
end)

modules.militaryTurret._fire = newcclosure(function(...)
    if not (isTeleporting or settings.robbery.autoRob.enabled or settings.itemMods.projectiles.disableMilitary) then
        originals.militaryFire(...)
    end
end)

modules.alexChassis.VehicleEnter = newcclosure(function(self, ...)
    originals.vehicleEnter(self, ...)
    self.GarageEngineSpeed = settings.vehicleMods.cars.speed
    self.GarageBrakes = settings.vehicleMods.cars.brakes
    self.Height = settings.vehicleMods.cars.height + 2
    self.TurnSpeed = settings.vehicleMods.cars.turn
end)

modules.alexChassis.UpdatePrePhysics = newcclosure(function(self, ...)
    if self.UpsideDownTime and settings.vehicleMods.cars.autoFlip then
        self.UpsideDownTime = 0
    end
    return originals.updatePrePhysics(self, ...)
end)

setupvalue(modules.ui.CircleAction.Update, 7, newcclosure(function(...)
    local spec = modules.ui.CircleAction.Spec
    if spec and settings.playerMods.charMods.instantSpecs then
        local dur = spec.Duration
        spec.Duration = 0
        originals.processSpec(...)
        spec.Duration = dur
        return
    end
    originals.processSpec(...)
end))

modules.rayCast.RayIgnoreNonCollide = newcclosure(function(...)
    local args, trace = {...}, traceback()
    if settings.itemMods.gunMods.noFlintlockKnockback and string.find(trace, "Flintlock") then
        return true
    elseif settings.vehicleMods.cars.driveOnWater and string.find(trace, "AlexChassis") then
        args[6] = true
    end
    return originals.rayIgnoreNonCollide(unpack(args))
end)

modules.rayCast.RayIgnoreNonCollideWithIgnoreList = newcclosure(function(...)
    local args = {...}
	if args[3] == 500 and settings.vehicleMods.helis.infDroneHeight and string.find(traceback(), "Heli") then
		return nil, args[1]
    end
	return originals.rayIgnoreNonCollideWithIgnoreList(unpack(args))
end)

jetPackTable.EquipLocal = newcclosure(function(self, ...)
    jetPackEquipped = self
    originals.jetPackEquip(self, ...)
    if settings.itemMods.jetPack.premiumFuel then
        self.FuelType = "Rocket"
        local fuelTable = modules.jetPackUtil.Fuel.Rocket
        self.Fuel = fuelTable.MaxFuel
        self.MaxFuel = fuelTable.MaxFuel
        self.Model.LeftSmoke.Fire.Color = fuelTable.ParticleColor
        self.Model.RightSmoke.Fire.Color = fuelTable.ParticleColor
        self.LeanAngle = fuelTable.LeanAngle
        modules.jetPackGui.SetFuelType(self.FuelType)
    end
end)

vehicleClasses.Heli.Update = newcclosure(function(self, ...)
    if self.RopePickupPacket and (settings.vehicleMods.helis.instantPickup or pickUpItem) then
		self.RopePickupPacket.BornAt = 0
	end
	self.MaxHeight = (settings.vehicleMods.helis.infHeliHeight or settings.robbery.autoRob.enabled) and math.huge or 400
	originals.heliUpdate(self, ...)
    local vel = self.Velocity.Velocity
	self.Velocity.Velocity = vel * ((settings.vehicleMods.helis.speed / 35) + (34 / 35))
end)

vehicleClasses.Heli.GetClosestPickup = newcclosure(function(heli)
    if pickUpItem then
        return pickUpItem
    end
    return originals.getClosestPickup(heli)
end)

modules.boat.UpdatePhysics = newcclosure(function(self, ...)
	self.Config.SpeedForward = (settings.vehicleMods.boats.speed / 5) + 1.55
	originals.updatePhysics(self, ...)
end)

setupvalue(event.FireServer, 1, function(...)
    local args = {...}
    if pickUpItem ~= nil and args[2] == pickUpItem then
        args[3] = Vector3.new()
    end
    originals.fireServer(unpack(args))
    if pickUpItem ~= nil and args[2] == pickUpItem then
        coroutine.wrap(function()
            task.wait(0.25)
            pickUpItem:SetPrimaryPartCFrame(originals.getLocalVehiclePacket().Model.Preset.RopePull.CFrame)
            pickUpItem = nil
        end)()
    end
end)

getgenv().oldNamecall = hookmetamethod(game, "__namecall", loadstring(LPH_ENCSTR([[
	local settings = ...
	return function(self, ...)
		if getnamecallmethod() == "FindPartOnRay" then
			local trace = traceback()
			if ((settings.vehicleMods.boats.boatsOnLand and trace:find("Boat")) or (settings.vehicleMods.boats.jetskiOnLand and trace:find("JetSki"))) then
				local part, _, normal, __ = oldNamecall(self, ...)
				return part, Vector3.new(0, math.huge, 0), normal, Enum.Material.Water
			end
		end
		return oldNamecall(self, ...)
	end
]]))(settings))

--[[ ==========  Connections  ========== ]]

player.CharacterAdded:Connect(registerChar)
players.PlayerAdded:Connect(registerEsp)

mouse.Move:Connect(function()
    fovCircle.Position = userInputService:GetMouseLocation()
end)

workspace.ChildAdded:Connect(function(child)
	if not players:GetPlayerFromCharacter(child) then
		wallbangIgnore[#wallbangIgnore + 1] = child
	end
    if child.Name == "Drop" and child.ClassName == "Model" then
        cache.groups.airdrops:Add(child, { name = "Airdrop" })
    end
end)

workspace.ChildRemoved:Connect(function(child)
	local idx = table.find(wallbangIgnore, child)
	if idx then
		wallbangIgnore[idx] = nil
	end
end)

replicatedStorage.RobberyState.ChildAdded:Connect(function(robberyValue)
    registerRobbery(robberyValue)
end)

player.PlayerGui.ChildAdded:Connect(function(child)
	if child.Name == "FlowGui" and (settings.robbery.autoRob.enabled or settings.robbery.robMods.autoSolve) then
		solvePuzzle()
	end
end)

minimap.ChildAdded:Connect(function(child)
	child:GetPropertyChangedSignal("Visible"):Connect(function()
		if child.Visible == false and settings.visuals.misc.minimapShowAll then
			child.Visible = true
		end
	end)
end)

branch.Rail:GetPropertyChangedSignal("Transparency"):Connect(function()
    if settings.robbery.autoRob.enabled and branch.Rail.Transparency < 1 then
        fireclickdetector(branch.Lever.Click.ClickDetector)
    end
end)

robberyMoneyGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if robberyMoneyGui.Enabled and robberyMoneyGui.Container.Message.Visible then
        task.wait(0.5)
        if string.find(robberyMoneyGui.Container.Message.Text, "$") and settings.robbery.robMods.autoJewel then
            for i, v in next, specs do
                if isBagFull() then break end
                if v.Name == "Grab Jewel" then
                    v:Callback(true)
                    task.wait(0.1)
                end
            end
        elseif string.find(robberyMoneyGui.Container.Message.Text, "kg") and settings.robbery.robMods.autoMuseum then
            for i, v in next, specs do
                if isBagFull() then break end
                if v.Name == "Grab Bone" then
                    v:Callback(true)
                    task.wait(0.5)
                end
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
        if input.KeyCode == Enum.KeyCode.Space and settings.playerMods.charMods.infJump and root and hum and hum.FloorMaterial == Enum.Material.Air then
            local vel = root.Velocity
            root.Velocity = Vector3.new(vel.X, hum.JumpPower, vel.Z)
        end
    end
end)

runService.Heartbeat:Connect(function()
    if root then
        target = getTarget()
        if target then
            local isVisible = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, target.Position - cam.CFrame.Position), { cam, char, target.Parent }) == nil
            if settings.aimbot.aimbot.enabled and (isVisible or not settings.aimbot.aimbot.wallCheck) and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey) then
                local pos, vis = cam:WorldToScreenPoint(target.Position)
                local moveVec = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)) / (settings.aimbot.aimbot.smoothness + 0.5)
                mousemoverel(moveVec.X, moveVec.Y)
            end
            if settings.aimbot.silentAim.enabled and settings.aimbot.autoFire.autoShoot and (settings.aimbot.autoFire.autoWall or isVisible) then
				mouse1click()
            elseif settings.aimbot.autoFire.triggerbot then
                local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { cam, char })
                if part and players:FindFirstChild(part.Parent.Name) and players[part.Parent.Name].Team ~= player.Team then
                    mouse1click()
                end
			end
        end
    end
end)

while task.wait(1) do
    if settings.robbery.autoRob.enabled then
        local mins = (tick() - start) / 60
        elapsed:Update(math.floor(mins) .. " mins")
        hourlyRate:Update(formatMoney(math.floor((moneyValue.Value - money) / (mins / 60))))
    end
end