--[[

    Changelog:

    

]]

--[[ ==========  Macros  ========== ]]

LPH_ENCSTR = function(...) return ... end
LPH_JIT = function(...) return ... end

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
            wallCheck = false,
            hitChance = 100,
            headshotChance = 0,
            minDamagePercent = 0
        },
        positionScan = {
            enabled = false,
            scanRadius = 8,
            maxScanAngle = 120,
            angleInterval = 15
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
        bulletTracers = {
            enabled = false,
            colour = Color3.new(1, 0, 0)
        },
        impactPoints = {
            enabled = false,
            colour = Color3.new(1, 0, 0)
        },
        xRay = {
            enabled = false,
            transparency = 0.75
        },
        guiMods = {
            fullBright = false
        }
    },
    gunMods = {
        main = {
            combineMags = false,
            allFireModes = false,
            alwaysHeadshot = false,
            noSway = false,
            noCamShake = false,
            noBolt = false,
            antiSuppress = false,
            instantReload = false,
            instantAim = false,
            instantEquip = false
        },
        variable = {
            rapidFire = false,
            fireRate = 0,
            reduceRecoil = false,
            recoilPercent = 0,
            reduceSpread = false,
            spreadPercent = 0
        },
        cosmetic = {
            customColour = false,
            colour = Color3.new(1, 0, 0),
            customMaterial = false,
            material = "ForceField"
        }
    },
    itemMods = {
        knifeMods = {
            instantKnife = false,
            requireKnife = false,
            range = 25
        },
        nadeMods = {
            instantThrow = false,
            tpNades = false,
            impactNades = false,
            stickyNades = false,
            trajWhenThrowing = false,
            revengeNade = false,
            revengeMode = "On Death"
        }
    },
    playerMods = {
        charMods = {
            walkEnabled = false,
            walkSpeed = 16,
            jumpEnabled = false,
            jumpPower = 4,
            flySpeed = 70,
            noFallDamage = false,
            noJumpCooldown = false,
            noSlideCooldown = false,
            infJump = false,
            bHop = false,
            camOffset = 0
        },
        antiAim = {
            customPitch = false,
            pitch = "Up",
            customYaw = false,
            yaw = "Spinbot",
            fakeStance = false,
            stance = "Prone"
        },
        playerMods = {
            autoDeploy = false,
            autoSpot = false
        },
        otherPlayers = {
            forceStance = false,
            stance = "Stand",
            deathEffect = "None"
        }
    },
    misc = {
        killSay = {
            enabled = false,
            message = "$victim hasn't been to projectevo.xyz"
        },
        cases = {
            buyKeys = false
        },
        skins = {
            rarity = "Common"
        }
    }
}

--[[ ==========  Variables  ========== ]]

local cache = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V2/utils/libraryv3.lua"))()
cache.esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V2/utils/espv3.lua"))()
cache.misc = cache.system.new("Miscellaneous")

local startTick = tick()

local replicatedFirst = game:GetService("ReplicatedFirst")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

local framework = replicatedFirst:WaitForChild("Framework")
local msgTemplate = replicatedStorage.Misc.Msger
local chat = player.PlayerGui.ChatGame.GlobalChat

local fovCircle = Drawing.new("Circle")
local crossHairX, crossHairY = Drawing.new("Line"), Drawing.new("Line")
local beamTemplate, trajBeams = Instance.new("Beam"), {}
local gunData = {}
local connections, clientKeys, oldStances = {}, {}, {}
local bulletTracers, impactPoints = {}, {}
local gunMats, idCache = {}, {}
local springs, bypassTables = {}, {}
local char, root, hum = nil, nil, nil
local aimbotTarget, silentAimTarget, revengeNadeTarget = nil, { success = false }, nil
local isFlying, isAimKeyDown = false, false
local spinYaw = 0
local everyFireMode = { 1, 2, true }
local deathEffects = {}

local flyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local blacklistedArgs = {
    ["logmessage"] = true,
    ["debug"] = true,
    ["closeconnection"] = true,
    ["flaguser"] = true
}

local oldLighting, brightLighting = {
    Brightness = lighting.Brightness,
    GlobalShadows = lighting.GlobalShadows,
    Ambient = lighting.Ambient
}, {
   Brightness = 10,
   GlobalShadows = false,
   Ambient = Color3.new(1, 1, 1) 
}

local camoRarities = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Very Rare",
    [5] = "Legendary"
}

local bulletAccel = Vector3.new(0, -196.2, 0)

--[[ ==========  Optimization  ========== ]]

local getPlayers = players.GetPlayers
local worldToScreenPoint = cam.WorldToScreenPoint
local findPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
local findPartOnRayWithWhitelist = workspace.FindPartOnRayWithWhitelist

local cframeNew = CFrame.new
local udim2New = UDim2.new
local vector2New = Vector2.new
local vector3New = Vector3.new
local rayNew = Ray.new

local taskWait = task.wait
local color3FromHSV = Color3.fromHSV
local cframeAngles = CFrame.Angles
local coroutineWrap = coroutine.wrap

local mathRandom = math.random
local mathRad = math.rad
local mathSin = math.sin
local mathCos = math.cos
local mathFloor = math.floor

--[[ ==========  Anticheat  ========== ]]

for i, v in next, getconnections(game:GetService("LogService").MessageOut) do
    if getfenv(v.Function).script == framework then
        v:Disable()
    end
end

--[[ ==========  Chat  ========== ]]

local rainbowMessages = {}

local function sendClientChat(txt, shouldWait) -- nicked from network:add("announce" function
    local msg = msgTemplate:Clone()
    msg.Text = "[EvoV2]: "
	msg.TextColor3 = color3FromHSV(tick() % 10 / 10, 1, 1)
    msg.Msg.Text = txt
    msg.Parent = chat
    msg.Msg.Position = udim2New(0, msg.TextBounds.X, 0, 0)
	rainbowMessages[#rainbowMessages + 1] = msg
    if shouldWait then
        taskWait(0.2)
    end
end

runService.Heartbeat:Connect(function()
	local colour = color3FromHSV(tick() % 10 / 10, 1, 1)
	for i, v in next, rainbowMessages do
		if v.Parent == chat then
			v.TextColor3 = colour
		else
			rainbowMessages[i] = nil
		end
	end
end)

sendClientChat("Loading Script...", true)

--[[ ==========  Garbage Collection  ========== ]]

local camera, network, screenCull, input, effects, animation, vector, camoDatabase, playerData

for i, v in next, getloadedmodules() do
    if camera and network and screenCull and input and effects and animation and vector and camoDatabase and playerData then break end
    local name = v.Name
    if name == "camera" then
        camera = require(v)
    elseif name == "network" then
        network = require(v)
    elseif name == "ScreenCull" then
        screenCull = require(v)
    elseif name == "input" then
        input = require(v)
    elseif name == "effects" then
        effects = require(v)
    elseif name == "animation" then
        animation = require(v)
    elseif name == "vector" then
        vector = require(v)
    elseif name == "CamoDatabase" then
        camoDatabase = require(v)
    elseif name == "playerdata" then
        playerData = getupvalue(require(v).getattloadoutdata, 2)
    end
end

local setLookVector, trajectory, bulletCheck, gunBob = loadstring(LPH_ENCSTR([[
    local setLookVector, trajectory, bulletCheck, gunBob
    for i, v in next, getgc() do
        if setLookVector and trajectory and bulletCheck and gunBob then break end
        if type(v) == "function" and islclosure(v) then
            local name = getinfo(v).name
            if name == "setlookvector" then
                setLookVector = v
            elseif name == "trajectory" then
                trajectory = v
            elseif name == "bulletcheck" then
                bulletCheck = v
            elseif name == "gunbob" then
                gunBob = v
            end
        end
    end
    return setLookVector, trajectory, bulletCheck, gunBob
]]))()

local suppress = camera.suppress
local hit = camera.hit
local setSway = camera.setsway
local setSwaySpeed = camera.setswayspeed
local shake = camera.shake
local send = network.send
local cullStep = screenCull.step
local play = animation.player

local replication = getupvalue(camera.setspectate, 1)
local gameChar = getupvalue(camera.step, 7)
local hud = getupvalue(camera.step, 20)

local getUpdater = replication.getupdater
local setBaseWalkSpeed = gameChar.setbasewalkspeed
local jump = gameChar.jump
local updateFireMode = hud.updatefiremode
local getPlayerHealth = getupvalue(hud.getplayerhealth, 1)
local menu = getupvalue(hud.gundrop, 4)
local gameLogic = getupvalue(hud.updateammo, 4)
local charTable = getupvalue(replication.getbodyparts, 1)
local plrTable = getupvalue(replication.getplayerhit, 1)
local roundSystem = getupvalue(getupvalue(getupvalue(effects.bloodhit, 1), 4), 5)

local event = getupvalue(network.send, 1)
local nadeLabel = getupvalue(hud.updateammo, 3)
local clientEvents = getupvalue(getconnections(event.OnClientEvent)[1].Function, 1)

local gunBobIndex = table.find(getupvalues(gunBob), math.pi * 2)
local loadGun

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
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    hum:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
        if hum.FloorMaterial ~= Enum.Material.Air and settings.playerMods.charMods.bHop then
            while true do
                gameChar:jump(4)
                if hum.FloorMaterial == Enum.Material.Air then
                    break
                end
                runService.Heartbeat:Wait()
            end
        end
    end)
    hum.Died:Connect(function()
        char, root, hum = nil, nil, nil
    end)
end

local function damageCalc(startPos, targetPos)
    local range0, range1 = gameLogic.currentgun.data.range0, gameLogic.currentgun.data.range1
    local dist = (targetPos - startPos).Magnitude
    if dist < range0 then
        return 1
    elseif dist < range1 then
        return 1 - ((dist - range0) / (range1 - range0))
    end
    return 0
end

local getAimbotTarget = LPH_JIT(function()
	local origin, bulletSpeed, penDepth = gameLogic.currentgun.barrel.Position, gameLogic.currentgun.data.bulletspeed, gameLogic.currentgun.data.penetrationdepth
    local retTarget, dist = nil, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
	for i, v in next, getPlayers(players) do
		if v.Team ~= player.Team and hud:isplayeralive(v) then
			local rootPart = charTable[v] and charTable[v][settings.aimbot.aimbot.aimPart]
			if rootPart then
				local rootPos = rootPart.Position
				local pos, vis = worldToScreenPoint(cam, rootPos)
				if vis then
                    if not settings.aimbot.aimbot.wallCheck then
                        local traj = trajectory(origin, bulletAccel, rootPos, bulletSpeed)
                        if traj and bulletCheck(origin, rootPos, traj, bulletAccel, penDepth) then
                            local mag = (vector2New(pos.X, pos.Y) - vector2New(mouse.X, mouse.Y)).Magnitude
                            if mag < dist then
                                retTarget, dist = rootPos, mag
                            end
                        end
                    elseif findPartOnRayWithIgnoreList(workspace, rayNew(cam.CFrame.Position, rootPos - cam.CFrame.Position), { workspace.Terrain, workspace.Players, workspace.Ignore, cam }, true) == nil then
                        local mag = (vector2New(pos.X, pos.Y) - vector2New(mouse.X, mouse.Y)).Magnitude
                        if mag < dist then
                            retTarget, dist = rootPos, mag
                        end
                    end
				end
			end
		end
	end
	return retTarget
end)

local getSilentAimTarget = LPH_JIT(function()
	local origin, bulletSpeed, penDepth = settings.aimbot.positionScan.enabled and camera.basecframe or gameLogic.currentgun.barrel.Position, gameLogic.currentgun.data.bulletspeed, gameLogic.currentgun.data.penetrationdepth
    local retTarget, dist = {}, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
    local aimPart = mathRandom(1, 100) <= settings.aimbot.silentAim.headshotChance and "head" or "torso"
    local scanPositions, radius = {}, settings.aimbot.positionScan.scanRadius
    if settings.aimbot.positionScan.enabled then
        for i = -settings.aimbot.positionScan.maxScanAngle, settings.aimbot.positionScan.maxScanAngle, settings.aimbot.positionScan.angleInterval do
            local radians = mathRad(i)
            scanPositions[#scanPositions + 1] = (origin * cframeNew(mathSin(radians) * radius, 0, -mathCos(radians) * radius)).Position
        end
    end
	for i, v in next, getPlayers(players) do
		if v.Team ~= player.Team and hud:isplayeralive(v) then
			local rootPart = charTable[v] and charTable[v][aimPart]
			if rootPart then
				local rootPos = rootPart.Position
				local pos, vis = worldToScreenPoint(cam, rootPos)
				if vis then
                    if settings.aimbot.positionScan.enabled then
                        for i, v in next, scanPositions do
                            local traj, dur = trajectory(v, bulletAccel, rootPos, bulletSpeed)
                            local isVisible = findPartOnRayWithIgnoreList(workspace, rayNew(cam.CFrame.Position, rootPos - cam.CFrame.Position), { workspace.Terrain, workspace.Players, workspace.Ignore, cam }, true) == nil
                            if isVisible or (not settings.aimbot.silentAim.wallCheck and bulletCheck(v, rootPos, traj, bulletAccel, penDepth)) then
                                local mag = (vector2New(pos.X, pos.Y) - vector2New(mouse.X, mouse.Y)).Magnitude
                                if mag < dist then
                                    retTarget, dist = {
                                        success = true,
                                        part = rootPart,
                                        isVisible = isVisible,
                                        origin = v,
                                        trajectory = traj,
                                        duration = dur,
                                        hitPos = rootPos
                                    }, mag
                                    break
                                end
                            end
                        end
                    else
                        local traj, dur = trajectory(origin, bulletAccel, rootPos, bulletSpeed)
                        local isVisible = findPartOnRayWithIgnoreList(workspace, rayNew(cam.CFrame.Position, rootPos - cam.CFrame.Position), { workspace.Terrain, workspace.Players, workspace.Ignore, cam }, true) == nil
                        if isVisible or (not settings.aimbot.silentAim.wallCheck and bulletCheck(origin, rootPos, traj, bulletAccel, penDepth)) then
                            local mag = (vector2New(pos.X, pos.Y) - vector2New(mouse.X, mouse.Y)).Magnitude
                            if mag < dist then
                                retTarget, dist = {
                                    success = true,
                                    part = rootPart,
                                    isVisible = isVisible,
                                    origin = origin,
                                    trajectory = traj,
                                    duration = dur,
                                    hitPos = rootPos
                                }, mag
                            end
                        end
                    end
				end
			end
		end
	end
	return retTarget
end)

local function shoot()
    gameLogic.currentgun:shoot(true)
    runService.Stepped:Wait()
    if gameLogic.currentgun and gameLogic.currentgun.shoot then
        gameLogic.currentgun:shoot(false)
    end
end

local function registerEsp(plr)
    local updater = getUpdater(plr)
    if updater.alive then
        cache.esp:AddEsp(plr, charTable[plr].torso.Parent)
    end
    local oldSpawn = updater.spawn
    updater.spawn = newcclosure(function(...)
        oldSpawn(...)
        cache.esp:AddEsp(plr, charTable[plr].torso.Parent)
    end)
end

local function teleport(target, replicateLocal)
    local start, vel = root.Position, target - root.Position
    local unit, mag = vel.Unit, vel.Magnitude
    local angles = Vector2.new(camera.angles.x, camera.angles.y)
    for i = 0, mag, 9.75 do
        local pos = start + (unit * i)
        send(network, "repupdate", pos, angles, tick())
        if replicateLocal then
            root.Position = pos
        end
    end
    send(network, "repupdate", target, angles, tick())
    if replicateLocal then
        root.Position = target
    end
end

local function nadePathCalc()
	local u162 = vector3New()
	local u194 = (camera.cframe * cframeAngles(mathRad(gunData.FRAG.throwangle and 0), 0, 0)).lookVector * gunData.FRAG.throwspeed + root.Velocity
	local u198 = (camera.cframe - camera.cframe.p) * vector3New(19.539, -5, 0)
	local u202 = vector3New(0, -80, 0)
	local u203 = vector3New()
	local u204 = false                   -- rough estimate of cframe it starts at, it's based on the actual nade cframe so it's not the same each time
	local startPos = (camera.cframe * cframeNew(1.85, -0.26, -1.35) * cframeAngles(-46 * (math.pi / 180), -164 * (math.pi / 180), -22 * (math.pi / 180))).Position
	local frames = {{
		t0 = 0,
		p0 = startPos,
		v0 = u194,
		a = u202
	}}
	for v771 = 1, gunData.FRAG.fusetime / 0.016666666666666666 + 1 do
		local v772 = startPos + 0.016666666666666666 * u194 + 0.0001388888888888889 * u202
		local v773, v774, v775 = findPartOnRayWithWhitelist(workspace, rayNew(startPos, v772 - startPos - 0.05 * u203), roundSystem.raycastwhitelist, true)
		local v776 = 0.016666666666666666 * v771
		if v773 and v773.Name ~= "Window" and v773.Name ~= "Col" then
			u203 = 0.2 * v775
			u198 = v775:Cross(u194) / 0.2
			local v777 = v774 - startPos
			local v778 = 1 - 0.001 / v777.magnitude
			local v779 = v778 < 0 and 0 or v778
			startPos = startPos + v779 * v777 + 0.05 * v775
			local v780 = v775:Dot(u194) * v775
			local v781 = u194 - v780
			local v782 = -v775:Dot(u202)
			local v783 = -1.2 * v775:Dot(u194)
			local v784 = v782 < 0 and 0 or v782
			local v785 = v783 < 0 and 0 or v783
			local v786 = 1 - 0.08 * (10 * v784 * 0.016666666666666666 + v785) / v781.magnitude
			local v787 = v786 < 0 and 0 or v786
			u194 = v787 * v781 - 0.2 * v780
			if u194.magnitude < 1 then
				frames[#frames + 1] = {
					t0 = v776 - 0.016666666666666666 * (v772 - v774).magnitude / (v772 - startPos).magnitude, 
					p0 = startPos, 
					v0 = u162, 
					a = u162
				}
				break
			end
			frames[#frames + 1] = {
				t0 = v776 - 0.016666666666666666 * (v772 - v774).magnitude / (v772 - startPos).magnitude, 
				p0 = startPos, 
				v0 = u194, 
				a = u204 and u162 or u202
			}
			u204 = true
		else
			startPos = v772
			u194 = u194 + 0.016666666666666666 * u202
			u204 = false
		end
	end
	return frames
end

local function traceBullet(startPos, vel)
	local part1 = Instance.new("Part", workspace.Ignore)
	part1.Anchored = true
	part1.CanCollide = false
	part1.CFrame = cframeNew(startPos)
	part1.Size = vector3New(0.1, 0.1, 0.1)
	part1.Transparency = 1
	
	local part2 = Instance.new("Part", workspace.Ignore)
	part2.Anchored = true
	part2.CanCollide = false
	part2.CFrame = cframeNew(startPos + vel)
	part2.Size = vector3New(0.1, 0.1, 0.1)
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

	coroutineWrap(function()
		taskWait(1.5)
		for i = 0.3, 1, 0.02 do
			taskWait(0.02)
			beam.Transparency = NumberSequence.new(i)
		end
		part1:Destroy()
		part2:Destroy()
        bulletTracers[beam] = nil
	end)()
end

local function registerSpring(name, spr, ...)
    local spring = {
        meta = getmetatable(spr)
    }
    for i, v in next, {...} do
        spring[v] = spring.meta[v]
    end
    springs[name] = spring
end

local function registerGun(gun)
    local data = gunData[gun.name]
    local gunTable = getupvalue(gun.toggleattachment, 2)
    for i, v in next, gunTable do
        local meta = setmetatable({}, {
            __index = function(t, k)
                if k == "aimspeed" and settings.gunMods.main.instantAim then
                    return 9999
                end
                return rawget(v, k)
            end
        })
        bypassTables[meta] = true
        gunTable[i] = meta
    end
    local spreadNewIndex = getmetatable(getupvalue(gun.step, 36)).__newindex
    getmetatable(getupvalue(gun.step, 36)).__newindex = newcclosure(function(t, k, v)
        if k == "a" and settings.gunMods.variable.reduceSpread then
            v = v * (1 - (settings.gunMods.variable.spreadPercent / 100))
        end
        spreadNewIndex(t, k, v)
    end)
    local recoil1NewIndex = getmetatable(getupvalue(gun.step, 37)).__newindex
    getmetatable(getupvalue(gun.step, 37)).__newindex = newcclosure(function(t, k, v)
        if k == "a" and settings.gunMods.variable.reduceRecoil then
            v = v * (1 - (settings.gunMods.variable.recoilPercent / 100))
        end
        recoil1NewIndex(t, k, v)
    end)
    local recoil2NewIndex = getmetatable(getupvalue(gun.step, 38)).__newindex
    getmetatable(getupvalue(gun.step, 38)).__newindex = newcclosure(function(t, k, v)
        if k == "a" and settings.gunMods.variable.reduceRecoil then
            v = v * (1 - (settings.gunMods.variable.recoilPercent / 100))
        end
        recoil2NewIndex(t, k, v)
    end)
    if not islclosure(gun.setaim) then -- duplicate register
        return
    end
    local setEquipped, setAim, toggleAttachment = gun.setequipped, gun.setaim, gun.toggleattachment
    gun.setequipped = newcclosure(function(...)
        setEquipped(...)
        if settings.gunMods.variable.rapidFire then
            setupvalue(gun.memes, 4, settings.gunMods.variable.fireRate)
        end
        if settings.gunMods.main.allFireModes then
            setupvalue(gun.memes, 5, { true, 1, 2 })
        end
        if settings.gunMods.main.combineMags then
            local currAmmo, spareAmmo = getupvalue(gun.reload, 5), getupvalue(gun.reload, 4)
            setupvalue(gun.reload, 7, spareAmmo + currAmmo)
            setupvalue(gun.reload, 5, spareAmmo + currAmmo)
            setupvalue(gun.reload, 4, 0)
            hud:updateammo(spareAmmo + currAmmo, 0)
        end
    end)
    gun.setaim = newcclosure(function(...)
        setAim(...)
        if settings.gunMods.variable.rapidFire then
            setupvalue(gun.memes, 4, settings.gunMods.variable.fireRate)
        end
    end)
    gun.toggleattachment = newcclosure(function(...)
        toggleAttachment(...)
        if settings.gunMods.variable.rapidFire then
            setupvalue(gun.memes, 4, settings.gunMods.variable.fireRate)
        end
    end)
    if settings.gunMods.variable.rapidFire then
        setupvalue(gun.memes, 4, settings.gunMods.variable.fireRate)
    end
    if settings.gunMods.main.allFireModes then
        setupvalue(gun.memes, 5, { true, 1, 2 })
    end
    if settings.gunMods.main.combineMags then
        local currAmmo, spareAmmo = getupvalue(gun.reload, 5), getupvalue(gun.reload, 4)
        setupvalue(gun.reload, 7, spareAmmo + currAmmo)
        setupvalue(gun.reload, 5, spareAmmo + currAmmo)
        setupvalue(gun.reload, 4, 0)
        hud:updateammo(spareAmmo + currAmmo, 0)
    end
end

local function fakeNade(pos)
    send(network, "newgrenade", "FRAG", {
        time = tick(),
        blowuptime = 0,
        frames = { {
            t0 = 0,
            p0 = camera.basecframe.p,
            v0 = Vector3.new(),
            offset = pos - camera.basecframe.p,
            a = Vector3.new(0, -80, 0),
            rot0 = CFrame.new(),
            rotv = Vector3.new(),
            glassbreaks = {}
        } }
    })
end

local function getAnimationName(animation)
    for i, v in next, gunData do
        if rawget(v, "animations") then
            for name, anim in next, v.animations do
                if anim == animation then
                    return name
                end
            end
        end
    end
    return false
end

local function getKey(caseName, buy)
	for i, v in next, playerData.settings.inventorydata do
		if v.Type == "Case Key" and v.Name == caseName then
			return true
		end
	end
	if buy and settings.misc.cases.buyKeys then
		send(network, "purchasekeyrequest", caseName, 1)
        task.wait(0.5)
		return getKey(caseName)
	end
end

local function makeKillSayMessage(victim, dist, gun)
    local msg = settings.misc.killSay.message
    for i, v in next, { ["$victim"] = victim.Name, ["$dist"] = tostring(dist), ["$gun"] = gun } do
        msg = string.gsub(msg, i, v)
    end
    return msg
end

deathEffects["Anti-Gravity"] = function(model)
	local start, diff = tick(), 0
	local vel = Instance.new("BodyVelocity", model.Torso)
	vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	repeat
		diff = tick() - start
		for i, v in next, model:GetChildren() do
			v.Anchored = false
		end
		vel.Velocity = Vector3.new(0, 0.6 + diff / 6, 0)
		runService.Heartbeat:Wait()
	until model.Parent == nil
end

function deathEffects.Tornado(model)
	local start, diff = tick(), 0
	local vel = Instance.new("BodyVelocity", model.Torso)
	local gyro = Instance.new("BodyGyro", model.Torso)
	vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	repeat
		local now = tick()
		diff = now - start
		for i, v in next, model:GetChildren() do
			v.Anchored = false
		end
		vel.Velocity = Vector3.new(math.sin(diff * 4) * diff * 5, 5 + diff * 2, math.cos(diff * 4) * diff * 5)
		runService.Heartbeat:Wait()
	until model.Parent == nil
end

function deathEffects.Explosion(model)
	for i, v in next, model:GetChildren() do
		if v:FindFirstChild("Attachment") then
			v.Attachment:Destroy()
		end
	end
	for i, v in next, model:GetChildren() do
		local name = v.Name
		if name == "Head" then
			v.Velocity = v.CFrame.UpVector * 75
		elseif name == "Left Arm" or name == "Left Leg" then
			v.Velocity = v.CFrame.RightVector * -75 + Vector3.new(0, name == "Left Arm" and 50 or -25, 0)
		elseif name == "Right Arm" or name == "Right Leg" then
			v.Velocity = v.CFrame.RightVector * 75 + Vector3.new(0, name == "Right Arm" and 50 or -25, 0)
		end
	end
end

--[[ ==========  Setup  ========== ]]

fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false
fovCircle.Position = vector2New(mouse.X, mouse.Y)
fovCircle.Thickness = 1
fovCircle.Visible = false

beamTemplate.Color = ColorSequence.new(Color3.new(1, 0, 0))
beamTemplate.Transparency = NumberSequence.new(0)
beamTemplate.FaceCamera = true
beamTemplate.Segments = 50
beamTemplate.Width0 = 0.1
beamTemplate.Width1 = 0.1

crossHairX.Color = Color3.new(1, 0, 0)
crossHairX.Thickness = 1
crossHairX.Visible = false

crossHairY.Color = Color3.new(1, 0, 0)
crossHairY.Thickness = 1
crossHairY.Visible = false

if player.Character and player.Character:FindFirstChild("Humanoid") then
    coroutineWrap(registerChar)(player.Character)
end

for _, gunFile in next, replicatedStorage.GunModules:GetChildren() do
    gunData[gunFile.Name] = require(gunFile)
end

for key, func in next, clientEvents do
    if type(func) == "function" and islclosure(func) then
        local consts = getconstants(func) 
        if table.find(consts, "setstance") then
            clientKeys.setStance = key
        elseif table.find(consts, "killfeed") then
            clientKeys.killfeed = key
        elseif table.find(consts, "updatecharacter") then
            clientKeys.spawn = key
            loadGun = getupvalue(func, 6)
        end
    end
end

for key, func in next, clientEvents do
    if type(func) == "function" and select(2, pcall(getupvalue, func, 5)) == loadGun and key ~= clientKeys.spawn then
        clientKeys.swapGun = key
        break
    end
end

for i, v in next, Enum.Material:GetEnumItems() do
    gunMats[#gunMats + 1] = v.Name
end

table.sort(gunMats, function(a, b)
    return a < b
end)

cache.esp.GetHealth = function(self, model)
    local health, maxHealth = getPlayerHealth(plrTable[model])
    return mathFloor((health / maxHealth) * 100) / 100
end

for i, v in next, getPlayers(players) do
    if v ~= player then
        registerEsp(v)
    end
end

for i, v in next, input.keyboard.onkeydown._funcs do
    if table.find(getconstants(i), "streamermodetoggle") then
        local inputKeyDown = i
        input.keyboard.onkeydown._funcs[i] = nil
        input.keyboard.onkeydown._funcs[function(key)
            if (key == "c" or key == "leftcontrol") and settings.playerMods.charMods.noSlideCooldown then
                setupvalue(inputKeyDown, 8, false)
            end
            inputKeyDown(key)
            if key == "space" and settings.playerMods.charMods.noJumpCooldown then
                setupvalue(inputKeyDown, 7, tick())
            end
        end] = true
        break
    end
end

registerSpring("equip", getupvalue(gameChar.reloadsprings, 3), "__newindex")

--[[ ==========  GUI  ========== ]]

local library = cache.library.new("Phantom Forces")
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
end, { flag = "aimbotwallcheck" })
aimbot:AddDropdown("Aim Part", function(selected)
    settings.aimbot.aimbot.aimPart = selected:lower()
end, { items = { "Torso", "Head" }, default = "Torso" })
aimbot:AddSlider("Smoothness", function(value)
    settings.aimbot.aimbot.smoothness = value
end, { min = 1, max = 10, float = 0.1 })

local silentAim = aimbotTab:AddPanel("Silent Aim", { info = "Silent Aim - Redirects your bullets toward enemies" })
silentAim:AddToggle("Enabled", function(state)
    settings.aimbot.silentAim.enabled = state
end, { flag = "silentaimenabled" })
silentAim:AddToggle("Wall Check", function(state)
    settings.aimbot.silentAim.wallCheck = state
end, { flag = "silentaimwallcheck" })
silentAim:AddSlider("Hit Chance", function(value)
    settings.aimbot.silentAim.hitChance = value
end, { default = 100 })
silentAim:AddSlider("Headshot Chance", function(value)
    settings.aimbot.silentAim.headshotChance = value
end)
silentAim:AddSlider("Minimum Damage %", function(value)
    settings.aimbot.silentAim.minDamagePercent = value / 100
end)

local positionScanning = aimbotTab:AddPanel("Position Scanning", { info = "Position Scanning - Scans around you for the best position to hit a target from" })
positionScanning:AddToggle("Enabled", function(state)
    settings.aimbot.positionScan.enabled = state
end)
positionScanning:AddSlider("Scan Radius", function(value)
    settings.aimbot.positionScan.scanRadius = value
end, { max = 9.5, default = 8, float = 0.5 })
positionScanning:AddSlider("Max Scan Angle", function(value)
    settings.aimbot.positionScan.maxScanAngle = value / 2
end, { max = 180, default = 120, float = 15 })
positionScanning:AddSlider("Angle Interval", function(value)
    settings.aimbot.positionScan.angleInterval = value
end, { min = 15, max = 180, default = 15, float = 5 })

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

local autoFire = aimbotTab:AddPanel("Auto Firing", { info = "Auto Firing - This one's kinda self explanatory\nNote: Auto Shoot requires Silent Aim to be enabled" })
autoFire:AddToggle("Triggerbot", function(state)
    settings.aimbot.autoFire.triggerbot = state
end)
autoFire:AddToggle("Auto Shoot", function(state)
    settings.aimbot.autoFire.autoShoot = state
end)
autoFire:AddToggle("Auto Wallbang", function(state)
    settings.aimbot.autoFire.autoWall = state
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

local points = visualsTab:AddPanel("Impact Points", { info = "Impact Points - Highlights bullet holes on the map" })
points:AddToggle("Enabled", function(state)
    settings.visuals.impactPoints.enabled = state
    for i, v in next, impactPoints do
        if i.Parent ~= workspace.Ignore.Misc then
            impactPoints[i] = nil
        else
            i.Transparency = state and 0.6 or 1
            i.Color = settings.visuals.impactPoints.colour
        end
    end
end, { flag = "impactpointsenabled" })
points:AddPicker("Impact Colour", function(colour)
    settings.visuals.impactPoints.colour = colour
    for i, v in next, impactPoints do
        if i.Parent ~= workspace.Ignore.Misc then
            impactPoints[i] = nil
        else
            i.Color = colour
        end
    end
end, { default = table.pack(Color3.new(1, 0, 0):ToHSV()) })

local guiMods = visualsTab:AddPanel("GUI", { info = "Modifications to the GUIs and overall visuals of your game" })
guiMods:AddToggle("Fullbright", function(state)
    settings.visuals.guiMods.fullBright = state
    lighting.Brightness = state and brightLighting.Brightness or oldLighting.Brightness
    lighting.GlobalShadows = state and brightLighting.GlobalShadows or oldLighting.GlobalShadows
    lighting.Ambient = state and brightLighting.Ambient or oldLighting.Ambient
end)
guiMods:AddToggle("Crosshair", function(state)
    crossHairX.Visible, crossHairY.Visible = state, state
end)

local gunModsTab = library:AddTab("Gun Mods", "Cosmetic & Performance Changes", "rbxassetid://7825568616")

local gunsMain = gunModsTab:AddPanel("Main", { info = "Gun Mods - Modify several aspects of your gun's performance" })
gunsMain:AddToggle("Combine Mags", function(state)
    settings.gunMods.main.combineMags = state
    if gameLogic.currentgun and gameLogic.currentgun.reload then
        local reload = gameLogic.currentgun.reload
        local currAmmo, spareAmmo = getupvalue(reload, 5), getupvalue(reload, 4)
        setupvalue(reload, 7, state and spareAmmo + currAmmo or gameLogic.currentgun.magsize)
        setupvalue(reload, 5, state and spareAmmo + currAmmo or math.min(gameLogic.currentgun.magsize, currAmmo))
        setupvalue(reload, 4, state and 0 or (spareAmmo + currAmmo) - math.min(gameLogic.currentgun.magsize, currAmmo))
        hud:updateammo(getupvalue(reload, 5), getupvalue(reload, 4))
    end
end)
gunsMain:AddToggle("All Fire Modes", function(state)
    settings.gunMods.main.allFireModes = state
    if gameLogic.currentgun and gameLogic.currentgun.memes then
        setupvalue(gameLogic.currentgun.memes, 5, state and { true, 1, 2 } or gunData[gameLogic.currentgun.name].firemodes)
    end
end)
gunsMain:AddToggle("Always Headshot", function(state)
    settings.gunMods.main.alwaysHeadshot = state
end)
gunsMain:AddToggle("No Sway", function(state)
    settings.gunMods.main.noSway = state
    if gameLogic.currentgun and gameLogic.currentgun.data then
        setSway(camera, state and 0 or gameLogic.currentgun.data.swayamp)
        setSwaySpeed(camera, state and 0 or gameLogic.currentgun.data.swayspeed)
    end
end)
gunsMain:AddToggle("No Gun Bob", function(state)
    setupvalue(gunBob, gunBobIndex, state and 0 or math.pi * 2)
end)
gunsMain:AddToggle("No Camera Shake", function(state)
    settings.gunMods.main.noCamShake = state
end)
gunsMain:AddToggle("No Bolt", function(state)
    settings.gunMods.main.noBolt = state
end)
gunsMain:AddToggle("Anti Suppress", function(state)
    settings.gunMods.main.antiSuppress = state
end)
gunsMain:AddToggle("Instant Reload", function(state)
    settings.gunMods.main.instantReload = state
end)
gunsMain:AddToggle("Instant Aim", function(state)
    settings.gunMods.main.instantAim = state
end)
gunsMain:AddToggle("Instant Equip", function(state)
    settings.gunMods.main.instantEquip = state
end)

local gunVariables = gunModsTab:AddPanel("Variable Mods", { info = "Variable Mods - Gun mods that you can vary the effects of" })
gunVariables:AddToggle("Rapid Fire", function(state)
    settings.gunMods.variable.rapidFire = state
    if gameLogic.currentgun and gameLogic.currentgun.memes then
        local data = gunData[gameLogic.currentgun.name]
        setupvalue(gameLogic.currentgun.memes, 4, state and settings.gunMods.variable.fireRate or type(data.firerate) == "number" and data.firerate or data.firerate[getupvalue(gameLogic.currentgun.shoot, 7)])
    end
end)
gunVariables:AddSlider("Fire Rate", function(value)
    settings.gunMods.variable.fireRate = value
    if gameLogic.currentgun and gameLogic.currentgun.memes and settings.gunMods.variable.rapidFire then
        setupvalue(gameLogic.currentgun.memes, 4, value)
    end
end, { min = 0, max = 2500 })
gunVariables:AddToggle("Reduce Recoil", function(state)
    settings.gunMods.variable.reduceRecoil = state
end)
gunVariables:AddSlider("Reduction %", function(value)
    settings.gunMods.variable.recoilPercent = value
end, { flag = "recoilreduction" })
gunVariables:AddToggle("Reduce Spread", function(state)
    settings.gunMods.variable.reduceSpread = state
end)
gunVariables:AddSlider("Reduction %", function(value)
    settings.gunMods.variable.spreadPercent = value
end, { flag = "spreadreduction" })

local gunCosmetics = gunModsTab:AddPanel("Cosmetics", { info = "Cosmetics - Adjust how your gun looks" })
gunCosmetics:AddToggle("Custom Gun Colour", function(state)
    settings.gunMods.cosmetic.customColour = state
    if state and gameLogic.currentgun then
        local gun = cam:FindFirstChild(gameLogic.currentgun.name)
        if gun then
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Color = settings.gunMods.cosmetic.colour
                end
            end
        end
    end
end)
gunCosmetics:AddPicker("Gun Colour", function(colour)
    settings.gunMods.cosmetic.colour = colour
    if settings.gunMods.cosmetic.customColour and gameLogic.currentgun then
        local gun = cam:FindFirstChild(gameLogic.currentgun.name)
        if gun then
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Color = colour
                end
            end
        end
    end
end, { default = table.pack(Color3.new(1, 0, 0):ToHSV()) })
gunCosmetics:AddToggle("Custom Material", function(state)
    settings.gunMods.cosmetic.customMaterial = state
    if gameLogic.currentgun then
        local gun = cam:FindFirstChild(gameLogic.currentgun.name)
        if gun then
            local mat = state and Enum.Material[settings.gunMods.cosmetic.material] or Enum.Material.SmoothPlastic
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = mat
                end
            end
        end
    end
end)
gunCosmetics:AddDropdown("Material", function(selected)
    settings.gunMods.cosmetic.material = selected
    if settings.gunMods.cosmetic.customMaterial and gameLogic.currentgun then
        local gun = cam:FindFirstChild(gameLogic.currentgun.name)
        if gun then
            local mat = Enum.Material[selected]
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = mat
                end
            end
        end
    end
end, { items = gunMats, default = "ForceField" })

local itemModsTab = library:AddTab("Item Mods", "Knives, Grenades", "rbxassetid://7826196058")

local knifeMods = itemModsTab:AddPanel("Knives", { info = "Knives - Various knife modifications" })
knifeMods:AddToggle("Instant Knife", function(state)
    settings.itemMods.knifeMods.instantKnife = state
end)
knifeMods:AddToggle("Knife Aura", function(state)
    stopConnection("knifeAura")
    if state then
        addConnection("knifeAura", runService.Heartbeat:Connect(function()
            if gameLogic.currentgun and (gameLogic.currentgun.gunnumber or not settings.itemMods.knifeMods.requireKnife) then
                for i, v in next, getPlayers(players) do
                    if v.Team ~= player.Team then
                        local torso = charTable[v] and charTable[v].torso
                        if torso and (torso.Position - root.Position).Magnitude < settings.itemMods.knifeMods.range then
                            local gunNumber = gameLogic.currentgun.gunnumber
                            if gunNumber then
                                send(network, "equip", 3)
                            end
                            send(network, "knifehit", v, tick(), torso.Name)
                            if gunNumber then
                                send(network, "equip", gunNumber)
                            end
                            break
                        end
                    end
                end
            end
        end))
    end
end)
knifeMods:AddToggle("Require Knife Equipped", function(state)
    settings.itemMods.knifeMods.requireKnife = state
end)
knifeMods:AddSlider("Range", function(value)
    settings.itemMods.knifeMods.range = value
end, { max = 25, default = 25, float = 0.1, flag = "knifeaurarange" })

local nadeMods = itemModsTab:AddPanel("Grenades", { info = "Grenades - Various grenade modifications" })
nadeMods:AddToggle("Instant Throw", function(state)
    settings.itemMods.nadeMods.instantThrow = state
end)
nadeMods:AddToggle("Teleport Grenades", function(state)
    settings.itemMods.nadeMods.tpNades = state
end)
nadeMods:AddToggle("Impact Grenades", function(state)
    settings.itemMods.nadeMods.impactNades = state
end)
nadeMods:AddToggle("Sticky Grenades", function(state)
    settings.itemMods.nadeMods.stickyNades = state
end)
nadeMods:AddToggle("Revenge Grenade", function(state)
    settings.itemMods.nadeMods.revengeNade = state
    if state == false and revengeNadeTarget then
        revengeNadeTarget = nil
    end
end)
nadeMods:AddDropdown("Revenge Mode", function(value)
    settings.itemMods.nadeMods.revengeMode = value
end, { items = { "On Death", "On Respawn" }, default = "On Death" })
nadeMods:AddToggle("Show Grenade Trajectory", function(state)
    stopConnection("nadeTrajectory")
    if state then
        addConnection("nadeTrajectory", runService.Heartbeat:Connect(function()
            if root and (gameChar.grenadehold or not settings.itemMods.nadeMods.trajWhenThrowing) then
                local frames = nadePathCalc()
                for i = 1, #frames - 1 do
                    if not trajBeams[i] then
                        trajBeams[i] = {
                            attach0 = Instance.new("Attachment", workspace.Terrain),
                            attach1 = Instance.new("Attachment", workspace.Terrain),
                            beam = beamTemplate:Clone()
                        }
                        trajBeams[i].beam.Attachment0 = trajBeams[i].attach0
                        trajBeams[i].beam.Attachment1 = trajBeams[i].attach1
                        trajBeams[i].beam.Parent = workspace.Terrain
                    end
                    local frame, nextFrame = frames[i], frames[i + 1]
                    local timeDiff = nextFrame.t0 - frame.t0
                    local time1, time2 = timeDiff / 4, (timeDiff * 3) / 4

                    local point1, point2 = frame.p0 + (frame.v0 * time1 + 0.5 * frame.a * time1 * time1), frame.p0 + (frame.v0 * time2 + 0.5 * frame.a * time2 * time2)
                    local curve1, curve2 = (frame.v0 * (timeDiff / 2.75)).Magnitude, -((frame.v0 + (frame.a * timeDiff)) * (timeDiff / 2.75)).Magnitude
                    -- this is absolutely not the right maths but it's quite coincidentally accurate ^
                    local b = (nextFrame.p0 - frame.p0).Unit
                    local r1 = (point1 - frame.p0).Unit
                    local u1 = r1:Cross(b).Unit
                    local r2 = (point2 - nextFrame.p0).Unit
                    local u2 = r2:Cross(b).Unit
                    b = u1:Cross(r1).Unit

                    trajBeams[i].beam.CurveSize0 = curve1
	                trajBeams[i].beam.CurveSize1 = curve2
                    trajBeams[i].attach0.CFrame = workspace.Terrain.CFrame:inverse() * CFrame.fromMatrix(frame.p0, r1, u1, b)
                    trajBeams[i].attach1.CFrame = workspace.Terrain.CFrame:inverse() * CFrame.fromMatrix(nextFrame.p0, r2, u2, b)
                end
            elseif #trajBeams > 0 then
                for i, v in next, trajBeams do
                    v.attach0:Destroy()
                    v.attach1:Destroy()
                    v.beam:Destroy()
                    trajBeams[i] = nil
                end
            end
        end))
    elseif #trajBeams > 0 then
        for i, v in next, trajBeams do
            v.attach0:Destroy()
            v.attach1:Destroy()
            v.beam:Destroy()
            trajBeams[i] = nil
        end
    end
end)
nadeMods:AddToggle("Only Show When Throwing", function(state)
    settings.itemMods.nadeMods.trajWhenThrowing = state
end)

local playerTab = library:AddTab("Player", "Player & Character Mods", "rbxassetid://7826527270")

local charMods = playerTab:AddPanel("Character")
charMods:AddToggle("Custom WalkSpeed", function(state)
    settings.playerMods.charMods.walkEnabled = state
    if gameChar.alive then
        setBaseWalkSpeed(gameChar, state and settings.playerMods.charMods.walkSpeed or gameLogic.currentgun.data.walkspeed)
    end
end)
charMods:AddSlider("WalkSpeed", function(value)
    settings.playerMods.charMods.walkSpeed = value
    if gameChar.alive then
        setBaseWalkSpeed(gameChar, settings.playerMods.charMods.walkEnabled and value or gameLogic.currentgun.data.walkspeed)
    end
end, { min = 16, max = 250 })
charMods:AddToggle("Custom JumpPower", function(state)
    settings.playerMods.charMods.jumpEnabled = state
end)
charMods:AddSlider("JumpPower", function(value)
    settings.playerMods.charMods.jumpPower = value
end, { min = 4, max = 250 })
charMods:AddBind("Fly", function(bindName)
    stopConnection("fly")
	isFlying = not isFlying
	if isFlying then
		addConnection("fly", runService.RenderStepped:Connect(function(frameDelay)
			if root then
				local flyVec = vector3New()
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
                flyVec = vector3New(flyVec.X, 0.005, flyVec.Z)
                if flyKeys.Space then
                    flyVec = flyVec + vector3New(0, 1, 0)
                end
                if flyKeys.LeftShift then
                    flyVec = flyVec + vector3New(0, -1, 0)
                end
                root.Velocity = (flyVec.Magnitude < 1 and flyVec or flyVec.Unit) * settings.playerMods.charMods.flySpeed
			end
		end))
	end
end)
charMods:AddSlider("Fly Speed", function(value)
    settings.playerMods.charMods.flySpeed = value
end, { min = 16, max = 250, default = 125 })
charMods:AddToggle("No Fall Damage", function(state)
    settings.playerMods.charMods.noFallDamage = state
end)
charMods:AddToggle("No Jump Cooldown", function(state)
    settings.playerMods.charMods.noJumpCooldown = state
end)
charMods:AddToggle("No Slide Cooldown", function(state)
    settings.playerMods.charMods.noSlideCooldown = state
end)
charMods:AddToggle("Infinite Jump", function(state)
    settings.playerMods.charMods.infJump = state
end)
charMods:AddToggle("Bunny Hop", function(state)
    settings.playerMods.charMods.bHop = state
    if state and gameChar.alive then
        gameChar:jump(4)
    end
end)
charMods:AddBind("Click TP", function(bindName)
    if gameChar.alive then
        local pos, hit = root.Position, mouse.Hit.Position
        local _, rayHit, normal = findPartOnRayWithIgnoreList(workspace, Ray.new(pos, hit - pos), { workspace.Terrain, workspace.Ignore, cam, char })
        if rayHit then
            teleport(rayHit + normal + Vector3.new(0, 1.5, 0), true)
        else
            teleport(hit, true)
        end
    end
end)
charMods:AddSlider("Camera Offset", function(value)
    settings.playerMods.charMods.camOffset = value
end, { max = 25, float = 0.1 })

local antiAim = playerTab:AddPanel("Anti Aim", { info = "Anti Aim - Different ways to adjust how your character looks on the server, making you harder to hit" })
antiAim:AddToggle("Fake Stance", function(state)
    settings.playerMods.antiAim.fakeStance = state
    if gameChar.alive then
        send(network, "stance", state and settings.playerMods.antiAim.stance or gameChar.movementmode or "stand")
    end
end)
antiAim:AddDropdown("Stance", function(selected)
    settings.playerMods.antiAim.stance = selected:lower()
    if gameChar.alive then
        send(network, "stance", settings.playerMods.antiAim.fakeStance and selected:lower() or gameChar.movementmode or "stand")
    end
end, { items = { "Stand", "Crouch", "Prone" }, default = "Prone", flag = "fakestancedrop" })
antiAim:AddToggle("Custom Pitch", function(state)
    settings.playerMods.antiAim.customPitch = state
end)
antiAim:AddDropdown("Pitch", function(selected)
    settings.playerMods.antiAim.pitch = selected
end, { items = { "Up", "Down", "Forward" }, default = "Down" })
antiAim:AddToggle("Custom Yaw", function(state)
    settings.playerMods.antiAim.customYaw = state
end)
antiAim:AddDropdown("Yaw", function(selected)
    settings.playerMods.antiAim.yaw = selected
end, { items = { "Left", "Right", "Backward", "Spinbot" }, default = "Spinbot" })

local playerMods = playerTab:AddPanel("Player")
playerMods:AddToggle("Auto Deploy", function(state)
    settings.playerMods.playerMods.autoDeploy = state
    if state then
        repeat taskWait(1)
            if not menu:isdeployed() then
                menu:deploy()
            end
        until not settings.playerMods.playerMods.autoDeploy
    end
end)
playerMods:AddToggle("Auto Spot Players", function(state)
    settings.playerMods.playerMods.autoSpot = state
    if state then
        repeat taskWait(0.1)
            hud:spot()
        until not settings.playerMods.playerMods.autoSpot
    end
end)

local otherPlayers = playerTab:AddPanel("Other Players", { info = "Other Players - Adjust how other players' characters look on your client" })
otherPlayers:AddToggle("Force Stance", function(state)
    settings.playerMods.otherPlayers.forceStance = state
    for i, v in next, getPlayers(players) do
        if v ~= player then
            local updater = getUpdater(v)
            if updater then
                updater.setstance(state and settings.playerMods.antiAim.stance or oldStances[v] or "stand")
            end
        end
    end
end)
otherPlayers:AddDropdown("Stance", function(selected)
    settings.playerMods.otherPlayers.stance = selected:lower()
    for i, v in next, getPlayers(players) do
        if v ~= player then
            local updater = getUpdater(v)
            if updater then
                updater.setstance(settings.playerMods.otherPlayers.forceStance and selected:lower() or oldStances[v] or "stand")
            end
        end
    end
end, { items = { "Stand", "Crouch", "Prone" }, default = "Prone", flag = "forcestancedrop" })
otherPlayers:AddDropdown("Death Effects", function(selected)
    settings.playerMods.otherPlayers.deathEffect = selected
end, { items = { "None", "Explosion", "Tornado", "Anti-Gravity" }, default = "None" })

local miscTab = library:AddTab("Misc", "Map & Inventory Mods", "rbxassetid://7834826106")

local killSay = miscTab:AddPanel("KillSay", { info = "KillSay - Sends a message in chat when you kill somebody" })
killSay:AddToggle("Enabled", function(state)
    settings.misc.killSay.enabled = state
end, { flag = "killsayenabled" })
killSay:AddBox("Message", function(value)
    settings.misc.killSay.message = value
end, { default = "$victim hasn't been to projectevo.xyz" })
killSay:AddLabel("Codes: $victim, $dist, $gun")

local cases = miscTab:AddPanel("Cases", { info = "Cases - Auto buy cases and case keys" })
cases:AddToggle("Buy Necessary Keys", function(state)
    settings.misc.cases.buyKeys = state
end)
cases:AddButton("Open All Cases", function(state)
    for i, v in next, playerData.settings.inventorydata do
        if v.Type == "Case" and getKey(v.Name, true) then
            send(network, "startrollrequest", v.Name, v.Wep)
        end
    end
end)

local skins = miscTab:AddPanel("Skins", { info = "Skins - Sell all skins of a selected rarity in your inventory" })
skins:AddDropdown("Selected Rarity", function(selected)
    settings.misc.skins.rarity = selected
end, { items = camoRarities, default = "Common" })
skins:AddButton("Sell All Skins", function()
    local rarityIndex = table.find(camoRarities, settings.misc.skins.rarity)
    for i, v in next, playerData.settings.inventorydata do
        if v.Type == "Skin" and camoDatabase[v.Name].Rarity == rarityIndex then
            network:send("sellskinrequest", v.Name, v.Wep)
        end
    end
end)

local map = miscTab:AddPanel("Map", { info = "Map - All the map modifications" })
map:AddBind("Break All Windows", function(bindName)
    for i, v in next, workspace.Map:GetDescendants() do
        if v.Name == "Window" then
            effects:breakwindow(v, (v.Position - root.Position).Unit)
        end
    end
end)

library:AddSettings()

--[[ ==========  Hooks  ========== ]]

network.send = newcclosure(function(self, ...)
    local args = {...}
    if blacklistedArgs[args[1]] then
        return
    elseif args[1] == "bullethit" then
        if idCache[args[5]] then
            idCache[args[5]] = nil
            return 
        elseif settings.gunMods.main.alwaysHeadshot then
            args[4] = "Head"
        end
    elseif args[1] == "stance" and settings.playerMods.antiAim.fakeStance then
        args[2] = settings.playerMods.antiAim.stance
    elseif args[1] == "falldamage" and (settings.playerMods.charMods.noFallDamage or isFlying) then
        return
    elseif args[1] == "repupdate" then
        local pitch, yaw = args[3].X, args[3].Y
        if settings.playerMods.antiAim.customPitch then
            pitch = mathRad(settings.playerMods.antiAim.pitch == "Up" and 85 or settings.playerMods.antiAim.pitch == "Down" and -85 or settings.playerMods.antiAim.pitch == "Forward" and 0)
        end
        if settings.playerMods.antiAim.customYaw then
            if settings.playerMods.antiAim.yaw == "Spinbot" then
                spinYaw = spinYaw > math.pi and -math.pi or spinYaw + mathRandom() / 5
                yaw = spinYaw
            else
                local vec = settings.playerMods.antiAim.yaw == "Left" and cam.CFrame.RightVector * -1 or settings.playerMods.antiAim.yaw == "Right" and cam.CFrame.RightVector or settings.playerMods.antiAim.yaw == "Backward" and cam.CFrame.LookVector * -1
                yaw = select(2, vector.toanglesyx(vec))
            end
        end
        args[3] = vector2New(pitch, yaw)
    elseif args[1] == "newbullets" then
        if settings.aimbot.silentAim.enabled and silentAimTarget.success and mathRandom(1, 100) <= settings.aimbot.silentAim.hitChance then
            local target = silentAimTarget
            args[2].firepos = target.origin
            for i, v in next, args[2].bullets do
				v[1] = target.trajectory
                idCache[v[2]] = true
			end
			send(network, unpack(args))
            if settings.visuals.bulletTracers.enabled then
                traceBullet(args[2].firepos, target.trajectory)
            end
            coroutineWrap(function()
                taskWait(target.duration)
                if target.part.Parent ~= nil and plrTable[target.part.Parent] then
                    for i = 1, #args[2].bullets do
                        send(network, "bullethit", plrTable[target.part.Parent], target.hitPos, settings.gunMods.main.alwaysHeadshot and "Head" or target.part.Name, args[2].bullets[i][2])
                    end
                end
                taskWait(1.5 - target.duration)
                for i = 1, #args[2].bullets do
                    idCache[args[2].bullets[i][2]] = nil
                end
            end)()
			return
        elseif settings.visuals.bulletTracers.enabled then
            for i, v in next, args[2].bullets do
				traceBullet(args[2].firepos, v[1])
			end
        end
    elseif args[1] == "newgrenade" then
        local didFindTarget = false
        if settings.itemMods.nadeMods.tpNades then
            local target, dist = nil, math.huge
            for i, v in next, game:GetService("Players"):GetPlayers() do
                if v.Team ~= player.Team then
                    local pos = charTable[v] and charTable[v].torso and charTable[v].torso.Position
                    if pos then
                        local mag = (camera.basecframe.Position - pos).Magnitude
                        if mag < dist then
                            target, dist = pos, mag
                        end
                    end
                end
            end
            if target then
                didFindTarget = true
                args[3].frames[#args[3].frames].offset = target - args[3].frames[#args[3].frames].p0
                args[3].blowuptime = 0
            end
        end
        if didFindTarget == false then
            if settings.itemMods.nadeMods.impactNades then
                args[3].blowuptime = args[3].frames[2].t0
                args[3].frames[#args[3].frames].p0 = args[3].frames[2].p0
            elseif settings.itemMods.nadeMods.stickyNades then
                for i = 2, #args[3].frames do
                    args[3].frames[i].a = vector3New()
                    args[3].frames[i].v0 = vector3New()
                    args[3].frames[i].p0 = args[3].frames[2].p0
                end
            end
        end
    elseif args[1] == "spawn" and revengeNadeTarget and settings.itemMods.nadeMods.revengeMode == "On Respawn" then
        coroutineWrap(function()
            taskWait(1)
            local updater = getUpdater(revengeNadeTarget)
            if updater.alive then
                fakeNade(updater.getpos())
            end
        end)()
    end
    return send(self, unpack(args))
end)

local setStance = clientEvents[clientKeys.setStance]
clientEvents[clientKeys.setStance] = newcclosure(function(...)
    local args = {...}
    oldStances[args[1]] = args[2]
    if settings.playerMods.otherPlayers.forceStance then
        args[2] = settings.playerMods.otherPlayers.stance
    end
    setStance(unpack(args))
end)

local killfeed = clientEvents[clientKeys.killfeed]
clientEvents[clientKeys.killfeed] = newcclosure(function(killer, victim, dist, gun, ...)
    if victim == player then
        if settings.itemMods.nadeMods.revengeNade then
            revengeNadeTarget = killer
            if gameLogic.gammo > 0 and settings.itemMods.nadeMods.revengeMode == "On Death" then
                fakeNade(getUpdater(killer).getpos())
            end
        end
    elseif killer == player and settings.misc.killSay.enabled then
        send(network, "chatted", makeKillSayMessage(victim, dist, gun), false)
    end
    killfeed(killer, victim, dist, gun, ...)
end)

setupvalue(clientEvents[clientKeys.spawn], 6, newcclosure(function(...)
    local gun = loadGun(...)
    registerGun(gun)
    return gun
end))

setupvalue(clientEvents[clientKeys.swapGun], 5, newcclosure(function(...)
    local gun = loadGun(...)
    registerGun(gun)
    return gun
end))

camera.suppress = newcclosure(function(...)
    if settings.gunMods.main.antiSuppress == false then
        return suppress(...)
    end
end)

camera.hit = newcclosure(function(...)
    if settings.gunMods.main.antiSuppress == false then
        return hit(...)
    end
end)

camera.setsway = newcclosure(function(self, ...)
    return setSway(self, (settings.gunMods.main.noSway or (aimbotTarget and settings.aimbot.aimbot.enabled and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey))) and 0 or ...)
end)

camera.setswayspeed = newcclosure(function(self, ...)
    return setSwaySpeed(self, (settings.gunMods.main.noSway or (aimbotTarget and settings.aimbot.aimbot.enabled and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey))) and 0 or ...)
end)

camera.shake = newcclosure(function(self, shakeMag)
    if settings.gunMods.main.noCamShake then
        return
    end
    if aimbotTarget and settings.aimbot.aimbot.enabled and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey) then
        shakeMag = Vector3.new(0, shakeMag.Y, shakeMag.Z)
    end
    if settings.gunMods.variable.reduceRecoil then
        shakeMag = shakeMag * (1 - (settings.gunMods.variable.recoilPercent / 100))
    end
    return shake(self, shakeMag)
end)

screenCull.step = newcclosure(function(cf, ...)
    if camera.type == "firstperson" and settings.playerMods.charMods.camOffset > 0 then
        cam.CFrame = cf * cframeNew(0, 0, settings.playerMods.charMods.camOffset)
    end
    cullStep(cf, ...)
end)

gameChar.setbasewalkspeed = newcclosure(function(self, speed)
    if settings.playerMods.charMods.walkEnabled then
        speed = settings.playerMods.charMods.walkSpeed
    end
    setBaseWalkSpeed(self, speed)
end)

gameChar.jump = newcclosure(function(self, power)
    if settings.playerMods.charMods.jumpEnabled then
        power = settings.playerMods.charMods.jumpPower
    end
    jump(self, power)
end)

animation.player = newcclosure(function(model, anim)
    local hasFound = false
    if gameLogic.currentgun and gameLogic.currentgun.data and gameLogic.currentgun.data.animations then
        local anims = gameLogic.currentgun.data.animations
        if anim == anims.onfire and settings.gunMods.main.noBolt then
            hasFound = true
            return function() end
        elseif (anim == anims.reload or anim == anims.tacticalreload or anim == anims.pullbolt) and settings.gunMods.main.instantReload then
            hasFound = true
            return function() end
        end
    end
    if hasFound == false then
        local name = getAnimationName(anim)
        if settings.itemMods.knifeMods.instantKnife and (name == "stab1" or name == "stab2" or name == "quickstab") then
            return function() end
        elseif settings.itemMods.nadeMods.instantThrow and name == "pull" then
            return function() end
        end
    end
    return play(model, anim)
end)

hud.updatefiremode = newcclosure(function(...)
    updateFireMode(...)
    coroutineWrap(function()
        task.wait()
        if gameLogic.currentgun.memes and settings.gunMods.variable.rapidFire then
            setupvalue(gameLogic.currentgun.memes, 4, settings.gunMods.variable.fireRate)
        end
    end)()
end)

springs.equip.meta.__newindex = newcclosure(function(t, k, v)
    if k == "s" and gameLogic.currentgun and gameLogic.currentgun.gunnumber and v == gameLogic.currentgun.data.equipspeed and settings.gunMods.main.instantEquip then
        v = 9999
    end
    springs.equip.__newindex(t, k, v)
end)

local renvGet = getrenv().getmetatable
getrenv().getmetatable = newcclosure(function(tab)
    if bypassTables[tab] then
        return nil
    end
    return renvGet(tab)
end)

--[[ ==========  Connections  ========== ]]

player.CharacterAdded:Connect(registerChar)
players.PlayerAdded:Connect(registerEsp)

cam.ChildAdded:Connect(function(child)
    if replicatedStorage.GunModules:FindFirstChild(child.Name) then
        taskWait(0.1)
        if settings.gunMods.cosmetic.customColour then
            for i, v in next, child:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Color = settings.gunMods.cosmetic.colour
                end
            end
        end
        if settings.gunMods.cosmetic.customMaterial then
            for i, v in next, child:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material[settings.gunMods.cosmetic.material]
                end
            end
        end
    end
end)

workspace.Ignore.Misc.ChildAdded:Connect(function(child)
    if child.Name == "Hole" or child.Name == "DefaultImpact" then
        impactPoints[child] = true
        if settings.visuals.impactPoints.enabled then
            child.Transparency = 0.6
            child.Color = settings.visuals.impactPoints.colour
        end
    end
end)

workspace.Ignore.DeadBody.ChildAdded:Connect(function(child)
    local effect = deathEffects[settings.playerMods.otherPlayers.deathEffect]
    if effect then
        child:WaitForChild("Torso")
        effect(child)
    end
end)

mouse.Move:Connect(function()
    local location = userInputService:GetMouseLocation()
    fovCircle.Position = location
    crossHairX.From = location - vector2New(20, 0)
    crossHairX.To = location + vector2New(20, 0)
    crossHairY.From = location - vector2New(0, 20)
    crossHairY.To = location + vector2New(0, 20)
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
    if not isrbx then
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
            root.Velocity = vector3New(vel.X, hum.JumpPower, vel.Z)
        end
    end
end)

runService.Heartbeat:Connect(function()
    if gameChar.alive and gameLogic.currentgun and gameLogic.currentgun.barrel then
        local hasShot = false
        if settings.aimbot.aimbot.enabled and (isAimKeyDown or settings.aimbot.aimbot.ignoreAimKey) then
            aimbotTarget = getAimbotTarget()
            if aimbotTarget then
                local y, x = vector.toanglesyx(cam.CFrame.LookVector + ((aimbotTarget - cam.CFrame.Position).Unit - cam.CFrame.LookVector) / settings.aimbot.aimbot.smoothness)
                camera.angles = Vector3.new(y, x, 0)
            end
        end
        if settings.aimbot.silentAim.enabled then
            silentAimTarget = getSilentAimTarget()
            if silentAimTarget.success and settings.aimbot.autoFire.autoShoot and (settings.aimbot.autoFire.autoWall or silentAimTarget.isVisible) and damageCalc(gameLogic.currentgun.barrel.Position, silentAimTarget.hitPos) >= settings.aimbot.silentAim.minDamagePercent then
                hasShot = true
                shoot()
            end
        end
        if hasShot == false and settings.aimbot.autoFire.triggerbot then
            local part = findPartOnRayWithIgnoreList(workspace, rayNew(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { workspace.Terrain, workspace.Ignore, cam, char }, true)
            if part and plrTable[part.Parent] and plrTable[part.Parent].Team ~= player.Team then
                shoot()
            end
        end
    end
end)

--[[ ==========  Finish  ========== ]]

sendClientChat("Loaded! Took " .. mathFloor((tick() - startTick) * 1000) .. "ms")
