--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

local LPH_JIT_ULTRA = LPH_JIT_ULTRA or function(...) return ... end

--[[ Anticheat ]]--

for i, v in next, getconnections(game:GetService("LogService").MessageOut) do
    v:Disable()
end

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "Phantom Forces", version = changelog.version .. " Premium", storage = { "highlights" } })
evov3.imports:fetchmodule("esp")

local client = {
    drawing = evov3.imports:fetchsystem("drawing"),
    maids = {
        knifeaura = evov3.imports:fetchsystem("maid"),
        fly = evov3.imports:fetchsystem("maid"),
        bhop = evov3.imports:fetchsystem("maid"),
        deploy = evov3.imports:fetchsystem("maid"),
        spot = evov3.imports:fetchsystem("maid")
    },
    services = {
        runservice = game:GetService("RunService"),
        httpservice = game:GetService("HttpService"),
        replicatedstorage = game:GetService("ReplicatedStorage"),
        userinputservice = game:GetService("UserInputService"),
        teleportservice = game:GetService("TeleportService"),
        players = game:GetService("Players")
    },
    states = {
        isaimkeydown = false,
        isflying = false,
        isthirdperson = false,
        blockreplication = false,
        baseflyvec = Vector3.new(0, 1e-9, 0),
        currentclass = "Assault",
        lastshot = 0,
        spinyaw = 0,
        serverhopped = false,
        updatesafterspawn = 0,
        time = 0
    },
	independencedaybullets = {
		colours = {
			Color3.new(1, 0, 0),
			Color3.new(1, 1, 1),
			Color3.new(0, 0, 1)
		},
		index = 1
	}
}

local initstamp = tick()

local player = client.services.players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local char, root, hum = nil, nil, nil
local localupdater, localmodel, replicationspring
local aimbottarget, silentaimtarget = nil, nil

local blacklistedargs = {
    logmessage = true,
    debug = true,
    closeconnection = true,
    flaguser = true--,
    --ping = true
}

local flykeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local aimbotfovcircle = client.drawing:add("Circle", {
    Color = Color3.new(1, 1, 1),
    Filled = false,
    Position = Vector2.new(mouse.X, mouse.Y),
    Thickness = 1,
    Visible = false
})

local silentaimfovcircle = client.drawing:add("Circle", {
    Color = Color3.new(1, 1, 1),
    Filled = false,
    Position = Vector2.new(mouse.X, mouse.Y),
    Thickness = 1,
    Visible = false
})

local crosshair = {
    xleft = client.drawing:add("Line", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Visible = false
    }),
    xright = client.drawing:add("Line", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Visible = false
    }),
    ytop = client.drawing:add("Line", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Visible = false
    }),
    ybottom = client.drawing:add("Line", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Visible = false
    }),
    image = client.drawing:add("Image", {
        Visible = false
    })
}

local content = client.services.replicatedstorage:WaitForChild("Content"):WaitForChild("ProductionContent")
local weapondb = content:WaitForChild("WeaponDatabase")
local messagetemplate = client.services.replicatedstorage:WaitForChild("Misc"):WaitForChild("Msger")
local gamegui = player:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("GameGui")
local crosshud = gamegui:WaitForChild("CrossHud")
local chatframe = player.PlayerGui:WaitForChild("ChatGame")
local globalchat = chatframe:WaitForChild("GlobalChat")
local scope = player.PlayerGui:WaitForChild("NonScaled"):WaitForChild("ScopeFrame")

local customignores = { cam, workspace:WaitForChild("Ignore"), workspace:WaitForChild("Terrain"), workspace:WaitForChild("Players") }

local charactersizes = {}
local gundata, bullets = {}, {}
local updatedata = {}
local clientkeys, clientfuncs = {}, {}
local bullettracers, impactpoints = {}, {}
local highlighted = {}
local uicolours = {}
local silentaimignore = {}
local registered = {}

local lastpos = nil

--[[ Loading Note ]]--

local clientmessages = {}

local function sendclientchat(txt)
    local msg = messagetemplate:Clone()
    msg.Text = "[EvoV3]: "
	msg.TextColor3 = Color3.fromHSV(tick() % 10 / 10, 1, 1)
    msg.Msg.Text = txt
    msg.Parent = globalchat
    msg.Msg.Position = UDim2.new(0, msg.TextBounds.X, 0, 0)
	clientmessages[#clientmessages + 1] = msg
end

client.services.runservice.Heartbeat:Connect(function()
	local colour = Color3.fromHSV(tick() % 10 / 10, 1, 1)
	for i, v in next, clientmessages do
		if v.Parent == globalchat then
			v.TextColor3 = colour
		else
			table.remove(clientmessages, i)
            break
        end
	end
end)

sendclientchat("Loading Evo V3...")

--[[ Garbage Collection ]]--

local modules = {}
local plrdata = {}
local isbanland = false

for i, v in next, getloadedmodules() do
    local name = v.Name
    if name == "camera" then
        modules.camera = require(v)
    elseif name == "network" then
        modules.network = require(v)
    elseif name == "BulletCheck" then
        modules.bulletcheck = require(v)
    elseif name == "ScreenCull" then
        modules.screencull = require(v)
    elseif name == "input" then
        modules.input = require(v)
    elseif name == "particle" then
        modules.particle = require(v)
    elseif name == "effects" then
        modules.effects = require(v)
    elseif name == "animation" then
        modules.animation = require(v)
    elseif name == "sound" then
        modules.sound = require(v)
    elseif name == "vector" then
        modules.vector = require(v)
    elseif name == "cframe" then
        modules.cframe = require(v)
    elseif name == "spring" then
        modules.spring = require(v)
    elseif name == "Raycast" then
        modules.raycast = require(v)
    elseif name == "GameClock" then
        modules.gameclock = require(v)
    elseif name == "CamoDatabase" then
        modules.camodb = require(v)
    elseif name == "PlayerDataUtils" then
        modules.playerdata = require(v)
    elseif name == "MenuScreenGui" then
        modules.menuscreen = require(v)
    elseif name == "InstanceType" then
        isbanland = require(v).IsBanland()
    elseif name == "PlayerDataStoreClient" then
        plrdata = require(v).getPlayerData()
        client.states.currentclass = plrdata.settings.classdata.curclass
    end
end

local replication = getupvalue(modules.camera.setspectate, 1)
local gamechar = getupvalue(modules.camera.step, 7)
local hud = getupvalue(modules.camera.step, 20)
local camspring = getupvalue(modules.camera.suppress, 1)
local soundtable = getupvalue(modules.sound.CreateSubset, 1)

local originals = {
    suppress = modules.camera.suppress,
    hit = modules.camera.hit,
    setsway = modules.camera.setsway,
    setswayspeed = modules.camera.setswayspeed,
    shake = modules.camera.shake,
    send = modules.network.send,
    cullstep = modules.screencull.step,
	newparticle = modules.particle.new,
    animplayer = modules.animation.player,
    springindex = modules.spring.__index,
    springnewindex = modules.spring.__newindex,
    ownsweapon = modules.playerdata.ownsWeapon,
    ownsatt = modules.playerdata.ownsAttachment,
    getcamolist = modules.playerdata.getCamoList,
    setbasewalkspeed = gamechar.setbasewalkspeed,
    jump = gamechar.jump,
    updatecharacter = gamechar.updatecharacter,
    getsteadysize = hud.getsteadysize,
    setsprint = gamechar.setsprint
}

local loadplayer = getupvalue(replication.getupdater, 2)
local getplayerhealth = getupvalue(hud.getplayerhealth, 1)
local menu = getupvalue(hud.gundrop, 4)
local gamelogic = getupvalue(hud.updateammo, 4)
local chartable = getupvalue(replication.getbodyparts, 1)
local plrtable = getupvalue(replication.getplayerhit, 1)
local acceleration = getupvalue(modules.effects.bullethit, 6)
local roundsystem = getupvalue(getupvalue(getupvalue(modules.effects.bloodhit, 1), 4), 5)

local swingspring = getupvalue(gamechar.reloadsprings, 6)
local spreadspring = gamelogic.currentgun and gamelogic.currentgun.nextfiremode and getupvalue(gamelogic.currentgun.step, 36)

local cambobindex = evov3.utils:tablefind(getconstants(modules.camera.step), 0.5)

local garbage = LPH_JIT_ULTRA(function()
    local cache = {}
    local gc = getgc(true)
    for i = 1, #gc do
        local v = gc[i]
        if type(v) == "function" then
            local scr = tostring(getfenv(v).script)
            if scr == "Framework" then
                local name = getinfo(v).name
                if name == "gunbob" or name == "gunsway" then
                    cache[name] = v
                end
            elseif scr == "physics" and getinfo(v).name == "trajectory" then
                cache.trajectory = v
            elseif scr == "network" and evov3.utils:tablefind(getconstants(v), "Tried to call a unregistered network event %s") then
                cache.clientevents = getupvalue(v, 1)
            end
        elseif type(v) == "table" and rawget(v, "name") and weapondb:FindFirstChild(v.name, true) then
            gundata[v.name] = v
        end
    end
    return cache
end)()

local trackindex = evov3.utils:tablefind(getconstants(gamechar.animstep), "Ballistics Tracker")
local bobindex = evov3.utils:tablefind(getupvalues(garbage.gunbob), math.pi * 2)
--local swayindex1 = evov3.utils:tablefind(getconstants(garbage.gunsway), 64)
--local swayindex2 = evov3.utils:tablefind(getconstants(garbage.gunsway), 128)

local originalsounds = evov3.utils:deepclone(soundtable)
local previousequipped = {}

client.states.time = modules.network:getTime()

--[[ Functions ]]--

local espgroups =  {
    players = evov3.esp.group.new("players", {
        exclusions = { Slot1 = true, Slot2 = true },
        info = {
            equipped = function(container)
                return updatedata[container.player] and updatedata[container.player].equipped or "None"
            end
        }
    }),
    dropped = evov3.esp.group.new("items", {
        info = {
            cangrabammo = function(container)
                return gamelogic.currentgun and gundata[container.model.Gun.Value].ammotype == gamelogic.currentgun.data.ammotype and container.model.Spare.Value .. " Rounds" or "Incompatible"
            end
        }
    })
}

local function getrandomname()
    local plrs = {}
    for i, v in next, client.services.players:GetPlayers() do
        if v ~= player then
            plrs[#plrs + 1] = v
        end
    end
    local res = false
    if #plrs > 0 then
        res = plrs[math.random(1, #plrs)].Name
    end
    return res
end

local function queuemessage(msg)
    originals.send(modules.network, "chatted", msg, false)
    task.wait(2.5 + math.random())
end

local chatmessages = {
    "Doesn't ehub suck? Yes. Yes it does.",
    "lol projectevo.xyz still isn't tagged, u should go there",
    "Fun fact; EvoV3 isn't pasted. No hints there yk",
    "Who's hacking? I think someone's destroying us",
    "UNBELIEVABLE, JEFF",
    function()
        local name = getrandomname()
        return name and "I think " .. name .. " is hacking. They kinda sus" or "I think I'm hacking guys"
    end,
    function()
        local name = getrandomname()
        return name and "Yo " .. name .. " just one tapped me with an M9 wth" or "I'm all alone :("
    end,
    function()
        queuemessage("Dragostea Din Tei")
        queuemessage("Numa numa iei")
        queuemessage("Numa numa íei")
        return "Numa numa numa iei"
    end,
    function()
        queuemessage("A mexican and a black guy are in a car together. Who's driving?")
        return "The cops"
    end
}

local function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart", 3), character:WaitForChild("Humanoid", 3)
    local conn; conn = hum.Died:Connect(function()
        conn:Disconnect()
        char, root, hum = nil, nil, nil
    end)
end

local function getexternalmodel(model)
    local m1, m2 = model:FindFirstChild("Slot1") and model.Slot1:FindFirstChildOfClass("SpecialMesh"), model:FindFirstChild("Slot2") and model.Slot2:FindFirstChildOfClass("SpecialMesh")
    for i, v in next, weapondb:GetDescendants() do
        if v.ClassName == "Model" and v.Name == "Main" then
            local v1, v2 = v:FindFirstChild("Slot1") and v.Slot1:FindFirstChildOfClass("SpecialMesh"), v:FindFirstChild("Slot2") and v.Slot2:FindFirstChildOfClass("SpecialMesh")
            if (not ((m1 and not v1) or (m2 and not v2) or (v1 and not m1) or (v2 and not m2))) and (not m1 or m1.MeshId == v1.MeshId) and (not m2 or m2.MeshId == v2.MeshId) then
                return v.Parent.Name
            end
        end
    end
end

local function registerplayer(plr)
    local updater = replication.getupdater(plr)
    local equipped = getupvalue(updater.equip, 2)
    updatedata[plr] = {
        replicationspring = getupvalue(updater.updateReplication, 7),
        equipped = equipped and getexternalmodel(equipped) or nil
    }
end

local function getaimbotpart(container)
    if library.flags.aimbotpart == "Closest Part" then
        local retpart, dist = nil, math.huge
        for i, v in next, container do
            local pos = cam:WorldToScreenPoint(v.Position)
            local mag = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y).Magnitude
            if mag < dist then
                retpart, dist = v, mag
            end
        end
        return retpart
    end
    return container[string.lower(library.flags.aimbotpart)]
end

local function shouldignore(part)
    return part.Name == "Window" or part.CanCollide == false or part.Transparency == 1
end

local getaimbottarget = LPH_JIT_ULTRA(function()
	local retinfo, dist = nil, library.flags.aimbotfov.enabled and aimbotfovcircle.Radius or math.huge
	local origin = modules.camera.basecframe.Position
	local data = library.flags.unlockallguns and gundata[previousequipped[client.states.currentclass][gamelogic.currentgun.gunnumber == 1 and "Primary" or "Secondary"].Name] or gamelogic.currentgun.data
	for i, v in next, client.services.players:GetPlayers() do
		if v.Team ~= player.Team then
			local part = chartable[v] and getaimbotpart(chartable[v])
			if part and (origin - part.Position).Magnitude <= library.flags.aimbotrange then
				local partpos = part.Position
				local viewpos, onscreen = cam:WorldToScreenPoint(partpos)
				if onscreen and not (library.flags.aimbotwallcheck and modules.raycast.raycast(origin, partpos - origin, customignores, shouldignore) ~= nil) then
                    local path, dur = garbage.trajectory(origin, acceleration, partpos, data.bulletspeed)
                    if path == nil then
                        print(origin, acceleration, partpos, data.bulletspeed)
                    elseif modules.bulletcheck(origin, partpos, path, acceleration, data.penetrationdepth) then
                        local mag = Vector2.new(viewpos.X - mouse.X, viewpos.Y - mouse.Y).Magnitude
                        if mag < dist then
                            retinfo, dist = {
                                part = part,
                                pos = partpos,
                                dur = dur,
                                player = v
                            }, mag
                        end
                    end
				end
			end
		end
	end
	return retinfo
end)

local function getsilentaimpart(container)
    if library.flags.alwaysheadshot or math.random(1, 100) <= library.flags.headshotchance then
        return container.head
    elseif library.flags.silentaimpart == "Closest Part" then
        local retpart, dist = nil, math.huge
        for i, v in next, container do
            local pos = cam:WorldToScreenPoint(v.Position)
            local mag = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y).Magnitude
            if mag < dist then
                retpart, dist = v, mag
            end
        end
        return retpart
    end
    return container[string.lower(library.flags.silentaimpart)]
end

local function calcdamage(startpos, targetpos, part)
    local damage0 = gamelogic.currentgun.data.damage0
    local range0, range1 = gamelogic.currentgun.data.range0, gamelogic.currentgun.data.range1
    local dist = (targetpos - startpos).Magnitude
    local dmg = gamelogic.currentgun.data.damage1
    if dist < range0 then
        dmg = damage0
    elseif dist < range1 then
        dmg = damage0 - ((dist - range0) / (range1 - range0))
    end
    return part == "Head" and dmg * gamelogic.currentgun.data.multhead or part == "Torso" and dmg * gamelogic.currentgun.data.multtorso or dmg
end

local function calcdamagepercent(startpos, targetpos)
    local range0, range1 = gamelogic.currentgun.data.range0, gamelogic.currentgun.data.range1
    local dist = (targetpos - startpos).Magnitude
    if dist < range0 then
        return 1
    elseif dist < range1 then
        return 1 - ((dist - range0) / (range1 - range0))
    end
    return 0
end

local function getorigin()
    local origin = lastpos
    if library.flags.targetorigin == "Barrel" then
        origin = gamelogic.currentgun.barrel.Position
    elseif library.flags.targetorigin == "Camera" then
        origin = modules.camera.basecframe.Position
    end
    --[[if library.flags.tpscanning.enabled then
        local _, endpos = workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000)).Unit * math.random(library.flags.tpscanning.value / 2, library.flags.tpscanning.value)), { workspace.Players, cam, workspace.Ignore }, false, true)
        local vec = endpos - origin
        origin = origin + vec.Unit * (vec.Magnitude - 0.5)
    end]]
    return origin
end

local function getoffsets(pos, flag)
    if flag.enabled then
        local offsets = { pos }
        for i = 1, library.flags.concurrentscans do
            table.insert(offsets, pos + Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000)).Unit * math.random(flag.value * 50, flag.value * 100) / 100)
        end
        return offsets
    end
    return { pos }
end

local function scantargets(origin, targets)
	local data = library.flags.unlockallguns and gundata[previousequipped[client.states.currentclass][gamelogic.currentgun.gunnumber == 1 and "Primary" or "Secondary"].Name] or gamelogic.currentgun.data
    for i = 1, #targets do
        local target = targets[i]
        if calcdamagepercent(origin, target) >= library.flags.damagecalc then
            local iswallbetween = modules.raycast.raycast(origin, target - origin, customignores, shouldignore) ~= nil
            if not (iswallbetween and library.flags.silentaimwallcheck) then
                local path, dur = garbage.trajectory(origin, acceleration, target, data.bulletspeed)
                if modules.bulletcheck(origin, target, path, acceleration, data.penetrationdepth) then
                    return target, iswallbetween, path, dur
                end
            end
        end
    end
end

local getsilentaimtarget = LPH_JIT_ULTRA(function()
	local retinfo, dist = nil, library.flags.silentaimfov.enabled and silentaimfovcircle.Radius or math.huge
	local origins = getoffsets(getorigin(), library.flags.originscanning)
	for i, v in next, client.services.players:GetPlayers() do
		if v.Team ~= player.Team and silentaimignore[v] == nil then
            local updater = replication.getupdater(v)
            if updater and updater.alive and updater.receivedPosition then
                local targets = getoffsets(updater.receivedPosition, library.flags.targetscanning)
                local viewpos, onscreen = cam:WorldToScreenPoint(updater.receivedPosition)
                if onscreen or not library.flags.silentaimscreencheck then
                    for idx = 1, #origins do
                        local origin = origins[idx]
                        local enemypos, iswallbetween, path, dur = scantargets(origin, targets)
                        if enemypos then
                            local mag = Vector2.new(viewpos.X - mouse.X, viewpos.Y - mouse.Y).Magnitude
                            if mag < dist then
                                retinfo, dist = {
                                    origin = origin,
                                    part = getsilentaimpart(chartable[v]),
                                    pos = enemypos,
                                    path = path,
                                    iswallbetween = iswallbetween,
                                    dur = dur,
                                    player = v
                                }, mag
                                break
                            end
                        end
                    end
                end
            end
		end
	end
	return retinfo
end)

local function shoot()
    gamelogic.currentgun:shoot(true)
    task.wait()
    if gamelogic.currentgun and gamelogic.currentgun.shoot then
        gamelogic.currentgun:shoot(false)
    end
end

local function updateammo(gun, takeaway)
    if gun.nextfiremode then
        local currammo, spareammo = getupvalue(gun.reload, 5), getupvalue(gun.reload, 4)
        local total = (currammo + spareammo) - (takeaway or 0)
        local ammo = library.flags.magstack and total or math.min(total, gun.data.magsize)
        local spare = library.flags.magstack and 0 or total - math.min(total, gun.data.magsize)
        if currammo ~= ammo or spareammo ~= spare then
            setupvalue(gun.reload, 7, library.flags.magstack and gun.data.magsize + gun.data.sparerounds or gun.data.magsize)
            setupvalue(gun.reload, 5, ammo)
            setupvalue(gun.reload, 4, spare)
            hud:updateammo(ammo, spare)
        end
    end
end

local function modifyfiremodes(modes, default)
    if library.flags.allfiremodes then
        for i, v in next, { true, 1, 2 } do
            if not evov3.utils:tablefind(modes, v) then
                table.insert(modes, v)
            end
        end
    else
        for i, v in next, modes do
            if not evov3.utils:tablefind(default, v) then
                table.remove(modes, i)
            end
        end
    end
end

local function modifygunstat(data1, data2, stat, val)
    if data1[stat] ~= nil then
        data1[stat] = val
    end
    if data2[stat] ~= nil then
        data2[stat] = val
    end
end

local function modifyguns()
    for _, gun in next, getupvalue(clientfuncs.spawn, 1) do
        if gun.data and gun.nextfiremode and library.flags.spready then
            local data1, data2 = getupvalue(gun.nextfiremode, 2), getupvalue(gun.nextfiremode, 3)
            local default = gundata[gun.name]

            for i, v in next, data2.animations do
                if typeof(v) == "table" then
                    if string.find(i, "reload") then
                        v.timescale = library.flags.reloadtime == 0 and 0.001 or default.animations[i].timescale * (library.flags.reloadtime / 100)
                        v.stdtimescale = library.flags.reloadtime == 0 and 0.001 or default.animations[i].stdtimescale * (library.flags.reloadtime / 100)
                    elseif i == "onfire" then
                        v.timescale = library.flags.nofireanim and 0.001 or default.animations[i].timescale
                        v.stdtimescale = library.flags.nofireanim and 0.001 or default.animations[i].stdtimescale
                    end
                end
            end

            modifygunstat(data1, data2, "equipspeed", library.flags.equiptime == 0 and 9999 or default.equipspeed / (library.flags.equiptime / 100))

            modifygunstat(data1, data2, "rotkickmin", default.rotkickmin * (1 - library.flags.recoilx / 100))
            modifygunstat(data1, data2, "rotkickmax", default.rotkickmax * (1 - library.flags.recoilx / 100))
            modifygunstat(data1, data2, "aimrotkickmin", default.aimrotkickmin * (1 - library.flags.recoilx / 100))
            modifygunstat(data1, data2, "aimrotkickmax", default.aimrotkickmax * (1 - library.flags.recoilx / 100))

            modifygunstat(data1, data2, "transkickmin", default.transkickmin * (1 - library.flags.recoily / 100))
            modifygunstat(data1, data2, "transkickmax", default.transkickmax * (1 - library.flags.recoily / 100))
            modifygunstat(data1, data2, "aimtranstkickmin", default.aimtranskickmin * (1 - library.flags.recoily / 100))
            modifygunstat(data1, data2, "aimtranskickmax", default.aimtranskickmax * (1 - library.flags.recoily / 100))
            
            modifygunstat(data1, data2, "camkickmin", default.camkickmin * (1 - library.flags.recoilkick / 100))
            modifygunstat(data1, data2, "camkickmax", default.camkickmax * (1 - library.flags.recoilkick / 100))
            modifygunstat(data1, data2, "aimcamtkickmin", default.aimcamkickmin * (1 - library.flags.recoilkick / 100))
            modifygunstat(data1, data2, "aimcamkickmax", default.aimcamkickmax * (1 - library.flags.recoilkick / 100))

            modifygunstat(data1, data2, "firesoundid", library.flags.usefiresound and "rbxassetid://" .. library.flags.firesound or default.firesoundid)

            if getupvalue(gun.reload, 5) > data2.magsize or (library.flags.magstack and getupvalue(gun.reload, 4) > 0) then
                updateammo(gun)
            end

            modifyfiremodes(data2.firemodes, default.firemodes)

            if library.flags.rapidfire then
                local firerate = type(data2.firerate) == "number" and data2.firerate or data2.firerate[getupvalue(gun.shoot, 10)]
                setupvalue(gun.memes, 4, library.flags.firerateadditive and firerate + library.flags.firerate or library.flags.firerate)
            else
                setupvalue(gun.memes, 4, type(data2.firerate) == "number" and data2.firerate or data2.firerate[getupvalue(gun.shoot, 10)])
            end

            if registered[gun] == nil then
                local setaim = gun.setaim
                gun.setaim = newcclosure(function(self, ...)
                    setaim(self, ...)
                    if library.flags.rapidfire then
                        local firerate = type(data2.firerate) == "number" and data2.firerate or data2.firerate[getupvalue(gun.shoot, 10)]
                        setupvalue(gun.memes, 4, library.flags.firerateadditive and firerate + library.flags.firerate or library.flags.firerate)
                    end
                end)

                local toggleattachment = gun.toggleattachment
                gun.toggleattachment = newcclosure(function(self, ...)
                    toggleattachment(self, ...)
                    if library.flags.rapidfire then
                        local firerate = type(data2.firerate) == "number" and data2.firerate or data2.firerate[getupvalue(gun.shoot, 10)]
                        setupvalue(gun.memes, 4, library.flags.firerateadditive and firerate + library.flags.firerate or library.flags.firerate)
                    end
                end)
            end

            registered[gun] = true
        end
    end
end

local function getanimationname(animation)
    for i, v in next, gundata do
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

local function tracepath(pos, vel)
	local part1 = Instance.new("Part", workspace.Ignore)
	part1.Anchored = true
	part1.CanCollide = false
	part1.CFrame = CFrame.new(pos)
	part1.Size = Vector3.new(0.1, 0.1, 0.1)
	part1.Transparency = 1

	local part2 = Instance.new("Part", workspace.Ignore)
	part2.Anchored = true
	part2.CanCollide = false
	part2.CFrame = CFrame.new(pos + vel)
	part2.Size = Vector3.new(0.1, 0.1, 0.1)
	part2.Transparency = 1

	local attach1 = Instance.new("Attachment", part1)
	local attach2 = Instance.new("Attachment", part2)

	local beam = Instance.new("Beam", part1)
	beam.Attachment0 = attach1
	beam.Attachment1 = attach2
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, uicolours.tracers0),
		ColorSequenceKeypoint.new(1, uicolours.tracers1)
    })
	beam.FaceCamera = library.flags.tracersfacecamera
	beam.LightEmission = library.flags.traceremission
	beam.LightInfluence = library.flags.tracerinfluence
    if library.flags.tracerstextured.enabled then
        beam.Texture = "rbxassetid://" .. library.flags.tracertexture
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureLength = library.flags.tracertexturelength
        beam.TextureSpeed = library.flags.tracertexturespeed
    end
	beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, library.flags.tracertransparency0),
        NumberSequenceKeypoint.new(1, library.flags.tracertransparency1)
    })
	beam.Width0 = library.flags.tracerwidth0
	beam.Width1 = library.flags.tracerwidth1

    table.insert(bullettracers, beam)

	task.spawn(function()
		task.wait(library.flags.tracerduration)
		for i = 0.3, 1, 0.02 do
			task.wait(0.02)
			beam.Transparency = NumberSequence.new(i)
		end
		part1:Destroy()
		part2:Destroy()
        table.remove(bullettracers, table.find(bullettracers, beam))
	end)
end

local function teleport(pos, exact, replicate)
    client.states.blockreplication = true
    local origin = lastpos
    local vec = pos - origin
    for i = 0, math.floor(vec.Magnitude / 9.9) do
        local updatepos = origin + vec.Unit * i
        modules.network:send("repupdate", updatepos, Vector2.new(modules.camera.angles.X, modules.camera.angles.Y), client.states.time)
        if replicate then
            root.Position = updatepos
        end
    end
    if exact then
        modules.network:send("repupdate", pos, Vector2.new(modules.camera.angles.X, modules.camera.angles.Y), client.states.time)
        if replicate then
            root.Position = pos
        end
    end
    client.states.blockreplication = false
end

local function fakeshoot(target)
    local gun = gamelogic.currentgun
    if tick() - client.states.lastshot > 60 / getupvalue(gun.memes, 4) and getupvalue(gun.reload, 4) + getupvalue(gun.reload, 5) > 0 then
        client.states.lastshot = tick()
        if library.flags.conserveammo and calcdamage(target.origin, target.pos, target.part.Name) >= getplayerhealth(target.player) then
            silentaimignore[target.player] = 0
        end
        local shoot = getupvalue(gun.step, #getupvalues(gun.step))
        local id = getupvalue(shoot, 45)
        local fakebullets = {}
        for i = 1, gun.data.pelletcount or 1 do
            id = id + 1
            fakebullets[i] = { target.path, id }
        end
        local startpos = lastpos
        --[[local shouldtp = (startpos - target.origin).Magnitude > 10
        if shouldtp then
            teleport(target.origin, true)
        end]]
        originals.send(modules.network, "newbullets", {
            camerapos = lastpos,
            firepos = target.origin,
            bullets = fakebullets
        }, modules.gameclock.getTime())
        setupvalue(shoot, 45, id)
        updateammo(gun, 1)
        --[[if shouldtp then
            teleport(startpos, true)
        end]]
        task.delay(isbanland and 0 or target.dur, function()
            for i = 1, #fakebullets do
                originals.send(modules.network, "bullethit", target.player, target.pos, target.part.Name, fakebullets[i][2])
            end
        end)
        if library.flags.bullettracers then
            tracepath(target.origin, target.path)
        end
    end
end

local function getcrosshairimages()
    if not isfolder("Evo V3\\Crosshairs") then
        makefolder("Evo V3\\Crosshairs")
    end
    local images = {}
    local files = listfiles("Evo V3\\Crosshairs")
    for i = 1, #files do
        local filename = string.gsub(files[i], ".*\\", "")
        local ext = string.gsub(filename, ".*%.", "")
		if filename and (ext == "png" or ext == "bmp" or ext == "jpeg" or ext == "webp" or ext == "gif") then
			table.insert(images, filename)
		end
    end
    return images
end

local function rescalecrosshair()
    local location = client.services.userinputservice:GetMouseLocation()
    crosshair.xleft.From = location - Vector2.new(library.flags.crosshairradius + library.flags.crosshairseparation, 0)
    crosshair.xleft.To = location - Vector2.new(library.flags.crosshairseparation, 0)
    crosshair.xright.From = location + Vector2.new(library.flags.crosshairseparation, 0)
    crosshair.xright.To = location + Vector2.new(library.flags.crosshairradius + library.flags.crosshairseparation, 0)
    crosshair.ytop.From = location - Vector2.new(0, library.flags.crosshairradius + library.flags.crosshairseparation)
    crosshair.ytop.To = location - Vector2.new(0, library.flags.crosshairseparation)
    crosshair.ybottom.From = location + Vector2.new(0, library.flags.crosshairseparation)
    crosshair.ybottom.To = location + Vector2.new(0, library.flags.crosshairradius + library.flags.crosshairseparation)
    crosshair.image.Position = location - Vector2.new(library.flags.crosshairradius, library.flags.crosshairradius)
    crosshair.image.Size = Vector2.new(library.flags.crosshairradius * 2, library.flags.crosshairradius * 2)
    return location
end

local function highlight(plr, model)
    local item = Instance.new("Highlight", library.storage.highlights)
    item.DepthMode = library.flags.showhiddenchams and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    item.Enabled = library.flags.chams and (library.flags.chamfriendlies or plr.Team ~= player.Team)
    item.FillColor = library.flags.showhiddenchams and uicolours.visiblechamcolour or uicolours.hiddenchamcolour
    item.FillTransparency = library.flags.chamtransparency
    item.Name = plr.Name
    item.OutlineColor = uicolours.outlinechamcolour
    item.OutlineTransparency = library.flags.outlinechamtransparency
    item.Adornee = model
    local conn; conn = model.AncestryChanged:Connect(function()
        setthreadidentity(7)
        conn:Disconnect()
        item:Destroy()
        setthreadidentity(2)
    end)
end

local function serverhop()
    client.states.serverhopped = true
    local valid = {}
    local log = isfile("Evo V3/Data/Votekick Logs/Phantom Forces.json") and client.services.httpservice:JSONDecode(readfile("Evo V3/Data/Votekick Logs/Phantom Forces.json")) or {}
    for i, v in next, log do
        if tick() - v > 604800 then
            log[i] = nil
        end
    end
    local data = client.services.httpservice:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    for i = 1, #data do
        local v = data[i]
        if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId and log[v.id] == nil then
            valid[#valid + 1] = v.id
        end
    end
    if #valid > 0 then
        log[game.JobId] = tick()
        writefile("Evo V3/Data/Votekick Logs/Phantom Forces.json", client.services.httpservice:JSONEncode(log))
        if library.flags.executeonhop then
            queueonteleport("repeat task.wait() until game:GetService(\"ContentProvider\").RequestQueueSize == 0\nloadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/loader.lua\", true))()")
        end
        client.services.teleportservice:TeleportToPlaceInstance(game.PlaceId, valid[math.random(1, #valid)])
    else
        client.states.serverhopped = false
    end
end

--[[ Setup ]]--

for i, v in next, garbage.clientevents do
    if type(v) == "function" and islclosure(v) then
        local consts = getconstants(v)
        if evov3.utils:tablefind(consts, "equipknife") then
            clientkeys.equip = i
        elseif evov3.utils:tablefind(consts, "killfeed") then
            clientkeys.killfeed = i
        elseif evov3.utils:tablefind(consts, "setstance") then
            clientkeys.stance = i
        elseif evov3.utils:tablefind(consts, "addammo") then
            clientkeys.addammo = i
        elseif evov3.utils:tablefind(consts, "updateReplication") then
            clientkeys.bulkplayerupdate = i
        elseif #consts == 1 and consts[1] == "spawn" then
            clientkeys.newspawn = i
        elseif evov3.utils:tablefind(consts, "updatecharacter") then
            clientkeys.spawn, clientfuncs.spawn = i, v
        end
    end
end

local loadgun = getupvalue(clientfuncs.spawn, 6)

function espgroups.players:getplayerfromcharacter(model)
    return plrtable[model]
end

function espgroups.players:gethealth(inst)
    local health, maxhealth = getplayerhealth(inst.player)
    return math.round((health / maxhealth) * 100) / 100
end

for i, v in next, client.services.players:GetPlayers() do
    if v ~= player then
        task.spawn(registerplayer, v)
    end
end

if player.Character and player.Character:FindFirstChild("Humanoid") then
    task.spawn(registerchar, player.Character)
end

for i, v in next, client.services.replicatedstorage:WaitForChild("Character", 3):WaitForChild("Bodies", 3):WaitForChild("Ghosts", 3):GetChildren() do
    if v:IsA("BasePart") then
        charactersizes[v.Name] = v.Size
    end
end

for i, v in next, modules.input.keyboard.onkeydown._funcs do
    if evov3.utils:tablefind(getconstants(i), "streamermodetoggle") then
        function func(key, ...)
            if (key == "c" or key == "leftcontrol") and library.flags.noslidecooldown then
                setupvalue(i, 9, false)
            end
			if key == "space" and library.flags.nojumpcooldown then
                setupvalue(i, 7, 0)
            end
            i(key, ...)
        end
        modules.input.keyboard.onkeydown._funcs[i] = nil
        modules.input.keyboard.onkeydown._funcs[func] = true
        break
    end
end

for i, v in next, workspace.Ignore.GunDrop:GetChildren() do
    task.spawn(function()
        if v.Name == "Dropped" and v:WaitForChild("Gun", 3) then
            espgroups.dropped:add(v, { name = v.Gun.Value, root = v.PrimaryPart.Name, alwaysremove = true })
        end
    end)
end

task.spawn(function()
    while task.wait(0.1) do
        for i, v in next, silentaimignore do
            if v >= 10 then
                silentaimignore[i] = nil
                continue
            end
            silentaimignore[i] += 1
        end
    end
end)

--[[ GUI ]]--

local aimassistcat = library:addcategory({ content = "Aim Assist" })
local aimbottab = aimassistcat:addtab({ content = "Aimbot" })

local aimbotmain = aimbottab:addsection({ content = "Main" })
aimbotmain:addtoggle({ content = "Enabled", flag = "aimbotenabled", callback = function(state)
    if aimbottarget and not state then
        aimbottarget = nil
        if highlighted.aimbot and chartable[highlighted.aimbot] then
            espgroups.players:highlight(chartable[highlighted.aimbot].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.aimbot.TeamColor.Color)
            highlighted.aimbot = nil
        end
    end
end })
aimbotmain:addbind({ content = "Aim Key", default = "MouseButton2", flag = "aimkey", onchanged = function()
    client.states.isaimkeydown = false
end })
aimbotmain:addtoggle({ content = "Ignore Key", flag = "ignorekey" })
aimbotmain:addtoggle({ content = "Wall Check", flag = "aimbotwallcheck" })
aimbotmain:addtogglepicker({ content = "Highlight Target", flag = "aimbothighlight", default = Color3.fromRGB(230, 33, 237), onstatechanged = function(state)
    if highlighted.aimbot and chartable[highlighted.aimbot] and not state then
        espgroups.players:highlight(chartable[highlighted.aimbot].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.aimbot.TeamColor.Color)
        highlighted.aimbot = nil
    end
end, oncolourchanged = function(colour)
    uicolours.aimbothighlight = colour
    if highlighted.aimbot and chartable[highlighted.aimbot] then
        espgroups.players:highlight(chartable[highlighted.aimbot].torso.Parent, colour)
    end
end })
aimbotmain:adddropdown({ content = "Aim Part", flag = "aimbotpart", default = "Torso", items = { "Head", "Torso", "Closest Part" } })
aimbotmain:addslider({ content = "Smoothness", min = 1, max = 25, flag = "smoothness" })

local precision = aimbottab:addsection({ content = "Precision", right = true })
precision:addtoggle({ content = "Drop Compensation", flag = "compensatedrop" })
precision:addtoggle({ content = "Movement Prediction", flag = "predictmovement" })
precision:addslider({ content = "Max Range", max = 1500, default = 1500, flag = "aimbotrange" })

local aimbotfov = aimbottab:addsection({ content = "FOV", right = true })
aimbotfov:addtoggleslider({ content = "Value", max = 800, default = 100, flag = "aimbotfov" })
aimbotfov:addtoggle({ content = "Dynamic", flag = "aimbotfovdynamic" })
aimbotfov:addtoggle({ content = "Visible", flag = "aimbotfovvis", callback = function(state)
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

local silentmain = silentaimtab:addsection({ content = "Main" })
silentmain:addtoggle({ content = "Enabled", flag = "silentaimenabled", callback = function(state)
    if silentaimtarget and not state then
        silentaimtarget = nil
        if highlighted.silentaim and chartable[highlighted.silentaim] then
            espgroups.players:highlight(chartable[highlighted.silentaim].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.silentaim.TeamColor.Color)
            highlighted.silentaim = nil
        end
    end
end })
silentmain:addtoggle({ content = "On Screen Check", flag = "silentaimscreencheck" })
silentmain:addtoggle({ content = "Wall Check", flag = "silentaimwallcheck" })
silentmain:addtoggle({ content = "Conserve Ammo", flag = "conserveammo" })
silentmain:addtogglepicker({ content = "Highlight Target", flag = "silentaimhighlight", default = Color3.fromRGB(45, 180, 45), onstatechanged = function(state)
    if highlighted.silentaim and chartable[highlighted.silentaim] and not state then
        espgroups.players:highlight(chartable[highlighted.silentaim].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.silentaim.TeamColor.Color)
        highlighted.silentaim = nil
    end
end, oncolourchanged = function(colour)
    uicolours.silentaimhighlight = colour
    if highlighted.silentaim and chartable[highlighted.silentaim] then
        espgroups.players:highlight(chartable[highlighted.silentaim].torso.Parent, colour)
    end
end })
silentmain:adddropdown({ content = "Aim Part", flag = "silentaimpart", default = "Torso", items = { "Head", "Torso", "Closest Part" } })

local silentprecision = silentaimtab:addsection({ content = "Precision", right = true })
silentprecision:addslider({ content = "Hit Chance", default = 100, flag = "hitchance" })
silentprecision:addslider({ content = "Headshot Chance", flag = "headshotchance" })
silentprecision:addslider({ content = "Minimum Damage Dropoff", flag = "damagecalc" })
silentprecision:adddropdown({ content = "Targeting Origin", flag = "targetorigin", default = "Server Position", items = { "Barrel", "Camera", "Server Position" } })

local hitscanning = silentaimtab:addsection({ content = "Hit Scanning" })
hitscanning:addtoggleslider({ content = "Origin Scanning", min = 1, max = 10, float = 0.1, flag = "originscanning" })
hitscanning:addtoggleslider({ content = "Target Scanning", min = 1, max = 5, float = 0.1, flag = "targetscanning" })
--hitscanning:addtoggleslider({ content = "Teleport Scanning", min = 1, max = 1500, float = 1, flag = "tpscanning" })
hitscanning:addslider({ content = "Concurrent Scans [Lowers FPS]", min = 1, max = 10, flag = "concurrentscans" })

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

local aimassistother = aimassistcat:addtab({ content = "Other" })
local autofiring = aimassistother:addsection({ content = "Auto Firing" })
autofiring:addtoggledropdown({ content = "Fire Mode", flag = "autofire", items = { "Triggerbot", "Auto Shoot", "Auto Wallbang" } })
autofiring:addtoggle({ content = "Simulate Shots", flag = "simulateshots" })
autofiring:addtoggle({ content = "Interrupt Reloading", flag = "interruptreload" })

local extender = aimassistother:addsection({ content = "Hitbox Expander", right = true })
extender:addtoggleslider({ content = "Size", flag = "expandhitboxes", min = 1, max = 8, float = 0.1, onstatechanged = function(state)
    for model, plr in next, plrtable do
        if plr.Team ~= player.Team then
            for i, v in next, model:GetChildren() do
                if v:IsA("BasePart") then
                    v.Size = state and v.Size.Unit * library.flags.expandhitboxes.value or charactersizes[v.Name]
                end
            end
        end
    end
end, onvaluechanged = function(value)
    if library.flags.expandhitboxes.enabled then
        for model, plr in next, plrtable do
            if plr.Team ~= player.Team then
                for i, v in next, model:GetChildren() do
                    if v:IsA("BasePart") then
                        v.Size = v.Size.Unit * value
                    end
                end
            end
        end
    end
end })

local visualscat = library:addcategory({ content = "Visuals" })
local esptab = visualscat:addtab({ content = "Player ESP" })

local espmain = esptab:addsection({ content = "Main" })
espmain:addtoggle({ content = "Master Switch", flag = "espenabled", callback = function(state)
    espgroups.players.settings.enabled = state
end })
espmain:addtoggle({ content = "Show Names", flag = "espnames", callback = function(state)
    espgroups.players.settings.names = state
end })
espmain:addtoggle({ content = "Show Boxes", flag = "espboxes", callback = function(state)
    espgroups.players.settings.boxes = state
end })
espmain:addtoggle({ content = "Show Skeletons", flag = "espskeletons", callback = function(state)
    espgroups.players.settings.skeletons = state
end })
espmain:addtoggle({ content = "Show Health Bars", flag = "espbars", callback = function(state)
    espgroups.players.settings.bars = state
end })
espmain:addtoggle({ content = "Show Distances", flag = "espdistances", callback = function(state)
    espgroups.players.settings.distances = state
end })
espmain:addtoggle({ content = "Show Equipped", flag = "espequipped", callback = function(state)
    espgroups.players.settings.equipped = state
end })
espmain:addtoggle({ content = "Show Tracers", flag = "esptracers", callback = function(state)
    espgroups.players.settings.tracers = state
end })
espmain:addtoggle({ content = "Show Offscreen Arrows", flag = "esparrows", callback = function(state)
    espgroups.players.settings.offscreenarrows = state
end })

local espsettings = esptab:addsection({ content = "Settings", right = true })
espsettings:addtoggle({ content = "Show Teammates", flag = "espteam", callback = function(state)
    espgroups.players.settings.teammates = state
end })
espsettings:addtoggle({ content = "Include Weapons In Boxes", flag = "espscandescendants", callback = function(state)
    espgroups.players.settings.scandescendants = state
end })
espsettings:addtoggle({ content = "Use Display Names", flag = "espdisplay", callback = function(state)
    espgroups.players:updatenames(state)
end })
espsettings:addslider({ content = "Thickness", min = 1, max = 10, default = 1, flag = "espthickness", callback = function(value)
    espgroups.players:updatethickness(value)
end })
espsettings:addslider({ content = "Text Size", min = 8, max = 32, default = 14, flag = "espsize", callback = function(value)
    espgroups.players:updatetextsize(value)
end })

if Drawing.Fonts then
    espsettings:adddropdown({ content = "Font", flag = "espfont", items = evov3.utils:keytoarray(Drawing.Fonts), default = "System", callback = function(value)
        espgroups.players:updatefont(Drawing.Fonts[value])
    end })
end

local esparrows = esptab:addsection({ content = "Arrows", right = true })
esparrows:addslider({ content = "Arrow Height", min = 1, max = 50, default = 18, flag = "arrowheight", callback = function(value)
    espgroups.players.settings.arrowheight = value
end })
esparrows:addslider({ content = "Arrow Width", min = 8, max = 50, default = 12, flag = "arrowwidth", callback = function(value)
    espgroups.players.settings.arrowwidth = value
end })
esparrows:addslider({ content = "Arrow Center Offset", min = 0, max = 250, default = 120, flag = "arrowoffset", callback = function(value)
    espgroups.players.settings.arrowoffset = value
end })

local espcolours = esptab:addsection({ content = "Colours" })
espcolours:addtoggle({ content = "Custom Colours", flag = "espcolours", callback = function(state)
    espgroups.players:togglecustomcolours(state)
end })
espcolours:addpicker({ content = "Friendly Colour", flag = "espfriendlycolour", default = espgroups.players.settings.friendlycolour, callback = function(colour)
    espgroups.players:updatecustomcolour(colour, true)
end })
espcolours:addpicker({ content = "Enemy Colour", flag = "espenemycolour", default = espgroups.players.settings.enemycolour, callback = function(colour)
    espgroups.players:updatecustomcolour(colour, false)
end })

local itemesptab = visualscat:addtab({ content = "Item ESP" })
local dropsettings = itemesptab:addsection({ content = "Dropped Guns" })
dropsettings:addtoggle({ content = "Master Switch", flag = "droppedenabled", callback = function(state)
    espgroups.dropped.settings.enabled = state
end })
dropsettings:addtoggle({ content = "Show Names", flag = "droppednames", callback = function(state)
    espgroups.dropped.settings.names = state
end })
dropsettings:addtoggle({ content = "Show Distances", flag = "droppeddistances", callback = function(state)
    espgroups.dropped.settings.distances = state
end })
dropsettings:addtoggle({ content = "Show Ammo Count", flag = "droppedammo", callback = function(state)
    espgroups.dropped.settings.cangrabammo = state
end })
dropsettings:addpicker({ content = "Colour", flag = "droppedcolour", default = Color3.new(1, 1, 1), callback = function(colour)
    espgroups.dropped:updatecustomcolour(colour)
end })

local nadesettings = itemesptab:addsection({ content = "Grenades", right = true })
nadesettings:addlabel({ content = "Coming Soon!" })

local chamstab = visualscat:addtab({ content = "Chams" })
local chamsmain = chamstab:addsection({ content = "Main" })
chamsmain:addtoggle({ content = "Enabled", flag = "chams", callback = function(state)
    local items = library.storage.highlights:GetChildren()
    for i = 1, #items do
        local v = items[i]
        v.Enabled = state and (library.flags.chamfriendlies or client.services.players[v.Name].Team ~= player.Team)
    end
end })
chamsmain:addtoggle({ content = "Show Teammates", flag = "chamfriendlies", callback = function(state)
    local items = library.storage.highlights:GetChildren()
    for i = 1, #items do
        local v = items[i]
        v.Enabled = library.flags.chams and (state or client.services.players[v.Name].Team ~= player.Team)
    end
end })
chamsmain:addtoggle({ content = "Show Hidden", flag = "showhiddenchams", callback = function(state)
    local items = library.storage.highlights:GetChildren()
    for i = 1, #items do
        local v = items[i]
        v.DepthMode = state and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        if state == false then
            v.FillColor = uicolours.visiblechamcolour
        end
    end
end })
chamsmain:adddropdown({ content = "Visibility Check Part", flag = "chamvisiblecheck", items = { "Head", "Torso" }, default = "Torso" })

local chamsfill = chamstab:addsection({ content = "Fill Settings", right = true })
chamsfill:addpicker({ content = "Hidden Colour", flag = "hiddenchamcolour", default = Color3.new(1, 0, 0), callback = function(colour)
    uicolours.hiddenchamcolour = colour
end })
chamsfill:addpicker({ content = "Visible Colour", flag = "visiblechamcolour", default = Color3.new(0, 1, 0), callback = function(colour)
    uicolours.visiblechamcolour = colour
end })
chamsfill:addslider({ content = "Transparency", flag = "chamtransparency", max = 1, float = 0.01, callback = function(value)
    local items = library.storage.highlights:GetChildren()
    for i = 1, #items do
        items[i].FillTransparency = value
    end
end })

local chamsoutline = chamstab:addsection({ content = "Outline Settings", right = true })
chamsoutline:addpicker({ content = "Colour", flag = "outlinechamcolour", default = Color3.new(), callback = function(colour)
    uicolours.outlinechamcolour = colour
end })
chamsoutline:addslider({ content = "Transparency", flag = "outlinechamtransparency", max = 1, float = 0.01, callback = function(value)
    local items = library.storage.highlights:GetChildren()
    for i = 1, #items do
        items[i].OutlineTransparency = value
    end
end })

local cameravisualstab = visualscat:addtab({ content = "Camera" })
local cammods = cameravisualstab:addsection({ content = "Main" })
cammods:addtoggle({ content = "No Camera Bob", flag = "nocambob", callback = function(state)
    setconstant(modules.camera.step, cambobindex, state and 0 or 0.5)
end })
cammods:addtoggle({ content = "No Camera Sway", flag = "nosway", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.data then
        originals.setsway(modules.camera, state and 0 or gamelogic.currentgun.data.swayamp or 0)
        originals.setswayspeed(modules.camera, state and 0 or gamelogic.currentgun.data.swayspeed or 0)
    end
end })
cammods:addtoggle({ content = "No Camera Shake", flag = "nocamshake" })

local camoffset = cameravisualstab:addsection({ content = "Offset", right = true })
camoffset:addslider({ content = "X Offset", min = -25, max = 25, float = 0.5, default = 0, flag = "camoffsetx" })
camoffset:addslider({ content = "Y Offset", min = -25, max = 25, float = 0.5, default = 0, flag = "camoffsety" })
camoffset:addslider({ content = "Z Offset", min = 0, max = 50, float = 0.5, default = 0, flag = "camoffset" })

local tracerstab = visualscat:addtab({ content = "Bullet Tracers" })
local tracers = tracerstab:addsection({ content = "Main" })
tracers:addtoggle({ content = "Enabled", flag = "bullettracers", callback = function(state)
    uicolours.tracers = colour
    for i = 1, #bullettracers do
        bullettracers[i].Color = ColorSequence.new(colour)
    end
end })
tracers:addtoggle({ content = "Face Camera", flag = "tracersfacecamera", callback = function(state)
    for i = 1, #bullettracers do
        bullettracers[i].FaceCamera = state
    end
end })
tracers:addslider({ content = "Duration", flag = "tracerduration", max = 10, float = 0.05, default = 1.5 })
tracers:addslider({ content = "Light Emission", flag = "traceremission", max = 1, float = 0.01, default = 1, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].LightEmission = value
    end
end })
tracers:addslider({ content = "Light Influence", flag = "tracerinfluence", max = 1, float = 0.01, default = 1, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].LightInfluence = value
    end
end })

local tracertexture = tracerstab:addsection({ content = "Textures" })
tracertexture:addtoggledropdown({ content = "Custom Texture", flag = "tracerstextured", items = evov3.utils:keytoarray(evov3.utils.tracers), onstatechanged = function(state)
    if state then
        for i = 1, #bullettracers do
            bullettracers[i].Texture = "rbxassetid://" .. library.flags.tracertexture
        end
    end
end, onvaluechanged = function(value)
    library.items.tracertexture:set(evov3.utils.tracers[value])
end })
tracertexture:addbox({ content = "Texture ID", flag = "tracertexture", numonly = true, function(value)
    if library.flags.tracerstextured.enabled then
        for i = 1, #bullettracers do
            bullettracers[i].Texture = "rbxassetid://" .. value
        end
    end
end })
tracertexture:addslider({ content = "Texture Length", flag = "tracertexturelength", max = 10, float = 0.05, default = 3, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].TextureLength = value
    end
end })
tracertexture:addslider({ content = "Texture Speed", flag = "tracertexturespeed", max = 10, float = 0.05, default = 3, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].TextureSpeed = value
    end
end })

local tracercolour = tracerstab:addsection({ content = "Colour", right = true })
tracercolour:addpicker({ content = "Start Colour", flag = "tracercolour0", default = Color3.new(1, 0, 0), callback = function(colour)
    uicolours.tracers0 = colour
    for i = 1, #bullettracers do
        bullettracers[i].Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colour),
            ColorSequenceKeypoint.new(1, uicolours.tracers1)
        })
    end
end })
tracercolour:addpicker({ content = "End Colour", flag = "tracercolour1", default = Color3.new(1, 0, 0), callback = function(colour)
    uicolours.tracers1 = colour
    for i = 1, #bullettracers do
        bullettracers[i].Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, uicolours.tracers0),
            ColorSequenceKeypoint.new(1, colour)
        })
    end
end })

local tracerwidth = tracerstab:addsection({ content = "Width", right = true })
tracerwidth:addslider({ content = "Start Width", flag = "tracerwidth0", max = 2.5, float = 0.01, default = 0.15, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].Width0 = value
    end
end })
tracerwidth:addslider({ content = "End Width", flag = "tracerwidth1", max = 2.5, float = 0.01, default = 0.15, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].Width1 = value
    end
end })

local tracertransparency = tracerstab:addsection({ content = "Transparency", right = true })
tracertransparency:addslider({ content = "Start Transparency", flag = "tracertransparency0", max = 1, float = 0.01, default = 0.3, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, value),
            NumberSequenceKeypoint.new(1, library.flags.tracertransparency1)
        })
    end
end })
tracertransparency:addslider({ content = "End Transparency", flag = "tracertransparency1", max = 1, float = 0.01, default = 0.3, callback = function(value)
    for i = 1, #bullettracers do
        bullettracers[i].Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, library.flags.tracertransparency0),
            NumberSequenceKeypoint.new(1, value)
        })
    end
end })

local visualcosmeticstab = visualscat:addtab({ content = "Cosmetics" })
local crosshairs = visualcosmeticstab:addsection({ content = "Crosshair" })
crosshairs:addtogglepicker({ content = "Enabled", flag = "crosshairenabled", default = Color3.new(1, 0, 0), onstatechanged = function(state)
    crosshair.xleft.Visible = state and not library.flags.crosshairimage.enabled
    crosshair.xright.Visible = state and not library.flags.crosshairimage.enabled
    crosshair.ytop.Visible = state and not library.flags.crosshairimage.enabled
    crosshair.ybottom.Visible = state and not library.flags.crosshairimage.enabled
    crosshair.image.Visible = state and library.flags.crosshairimage.enabled
end, oncolourchanged = function(colour)
    crosshair.xleft.Color = colour
    crosshair.xright.Color = colour
    crosshair.ytop.Color = colour
    crosshair.ybottom.Color = colour
end })
crosshairs:addslider({ content = "Radius", min = 10, flag = "crosshairradius", callback = rescalecrosshair })
crosshairs:addslider({ content = "Separation", flag = "crosshairseparation", callback = rescalecrosshair })
crosshairs:addslider({ content = "Thickness", min = 1, max = 10, flag = "crosshairthickness", callback = function(value)
    crosshair.xleft.Thickness = value
    crosshair.xright.Thickness = value
    crosshair.ytop.Thickness = value
    crosshair.ybottom.Thickness = value
end })
crosshairs:addslider({ content = "Transparency", max = 1, float = 0.01, flag = "crosshairtransparency", callback = function(value)
    crosshair.xleft.Transparency = 1 - value
    crosshair.xright.Transparency = 1 - value
    crosshair.ytop.Transparency = 1 - value
    crosshair.ybottom.Transparency = 1 - value
    crosshair.image.Transparency = 1 - value
end })
crosshairs:addtoggledropdown({ content = "Crosshair Image", flag = "crosshairimage", items = getcrosshairimages(), onstatechanged = function(state)
    crosshair.xleft.Visible = library.flags.crosshairenabled.enabled and not state
    crosshair.xright.Visible = library.flags.crosshairenabled.enabled and not state
    crosshair.ytop.Visible = library.flags.crosshairenabled.enabled and not state
    crosshair.ybottom.Visible = library.flags.crosshairenabled.enabled and not state
    crosshair.image.Visible = library.flags.crosshairenabled.enabled and state
end, onvaluechanged = function(value)
    crosshair.image.Data = readfile("Evo V3\\Crosshairs\\" .. value)
end })

local reticles = visualcosmeticstab:addsection({ content = "Reticles", right = true })
reticles:addtoggle({ content = "No Blackscope Border", flag = "noscopeborder", callback = function(state)
    for i, v in next, scope:GetDescendants() do
        if v.Name ~= "ReticleImage" then
            v[v.ClassName == "ImageLabel" and "ImageTransparency" or "BackgroundTransparency"] = state and 1 or 0
        end
    end
end })
reticles:addtoggle({ content = "No Blackscope Reticle", flag = "noscopereticle", callback = function(state)
    for i, v in next, scope:GetDescendants() do
        if v.Name == "ReticleImage" then
            v.ImageTransparency = state and 1 or 0
        end
    end
end })
reticles:addtoggle({ content = "No Sight Reticle", flag = "nosightreticle", callback = function(state)
    if gamelogic.currentgun then
        local gun = cam:FindFirstChild(gamelogic.currentgun.name)
        if gun then
            for i, v in next, gun:GetDescendants() do
                if string.sub(v.Name, 1, 9) == "SightMark" and v:FindFirstChild("SurfaceGui") then
                    v.SurfaceGui.Enabled = not state
                end
            end
        end
    end
end })
reticles:addtoggle({ content = "No Crosshair", flag = "nocrosshair", callback = function(state)
    for i, v in next, crosshud:GetChildren() do
        v.Visible = not state
    end
end })

local points = visualcosmeticstab:addsection({ content = "Impact Points", right = true })
points:addtogglepicker({ content = "Enabled", flag = "impactpoints", default = Color3.new(1, 0, 0), onstatechanged = function(state)
    for i = 1, #impactpoints do
        local point = impactpoints[i]
        point.Transparency = state and library.flags.impacttransparency or 1
        point.Color = uicolours.impacts
    end
end, oncolourchanged = function(colour)
    uicolours.impacts = colour
    for i = 1, #impactpoints do
        impactpoints[i].Color = colour
    end
end })
points:adddropdown({ content = "Material", flag = "impactmaterial", items = evov3.utils:valuetoarray(Enum.Material:GetEnumItems()), default = "SmoothPlastic", callback = function(value)
    for i = 1, #impactpoints do
        impactpoints[i].Material = Enum.Material[value]
    end
end })
points:addslider({ content = "Transparency", flag = "impacttransparency", max = 1, float = 0.01, default = 0.6, callback = function(value)
    if library.flags.impactpoints then
        for i = 1, #impactpoints do
            impactpoints[i].Transparency = value
        end
    end
end })

local weaponscat = library:addcategory({ content = "Weapons" })
local guntab = weaponscat:addtab({ content = "Guns" })

local firerate = guntab:addsection({ content = "Rapid Fire", right = true })
firerate:addtoggle({ content = "Enabled", flag = "rapidfire", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
firerate:addtoggle({ content = "Add To Default Rate", flag = "firerateadditive", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
firerate:addslider({ content = "Value", min = 1, max = 2500, flag = "firerate", callback = function(value)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })

local gunmods = guntab:addsection({ content = "Gun Mods" })
gunmods:addtoggle({ content = "Always Headshot", flag = "alwaysheadshot" })
gunmods:addtoggle({ content = "Mag Stack", flag = "magstack", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        updateammo(gamelogic.currentgun)
    end
end })
gunmods:addtoggle({ content = "All Fire Modes", flag = "allfiremodes", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
gunmods:addtoggle({ content = "Run and Gun", flag = "runandgun" })
gunmods:addtoggle({ content = "Ballistic Tracking", flag = "ballistictracking", callback = function(state)
    if state then
        if gamelogic.currentgun and gamelogic.currentgun.attachments then
			if gamelogic.currentgun.attachments.Other == nil then
				gamelogic.currentgun.attachments.Other = ""
			end
            setconstant(gamechar.animstep, trackindex, gamelogic.currentgun.attachments.Other)
        end
    else
        setconstant(gamechar.animstep, trackindex, "Ballistics Tracker")
    end
end })
gunmods:addtoggle({ content = "No Gun Bob", flag = "nogunbob", callback = function(state)
    setupvalue(garbage.gunbob, bobindex, state and 0 or math.pi * 2)
end })
gunmods:addtoggle({ content = "No Gun Sway", flag = "nogunsway", callback = function(state)
    --setconstant(garbage.gunsway, swayindex1, state and 9e9 or 64)
    --setconstant(garbage.gunsway, swayindex2, state and 9e9 or 128)
end })
gunmods:addtoggle({ content = "No Gun Swing", flag = "nogunswing" })
gunmods:addtoggle({ content = "No Suppression", flag = "nosuppression" })
gunmods:addtoggle({ content = "No On-Fire Animation", flag = "nofireanim", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
gunmods:addtoggle({ content = "No Steady Scope Limit", flag = "nosteadylimit" })
gunmods:addslider({ content = "Equip Time", default = 100, flag = "equiptime", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
gunmods:addslider({ content = "Reload Time", default = 100, flag = "reloadtime", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })

local recoil = guntab:addsection({ content = "Recoil", right = true })
recoil:addslider({ content = "Horizontal Reduction", flag = "recoilx", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
recoil:addslider({ content = "Vertical Reduction", flag = "recoily", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
recoil:addslider({ content = "Kick Reduction", flag = "recoilkick", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })

local spread = guntab:addsection({ content = "Spread", right = true })
spread:addslider({ content = "Horizontal Reduction", flag = "spreadx" })
spread:addslider({ content = "Vertical Reduction", flag = "spready" })

local nadetab = weaponscat:addtab({ content = "Grenades" })
local nademods = nadetab:addsection({ content = "Modifications" })
nademods:addslider({ content = "Throw Time", default = 100, flag = "throwtime" })

local knifetab = weaponscat:addtab({ content = "Knives" })

local knifeaura = knifetab:addsection({ content = "Knife Aura" })
knifeaura:addtoggle({ content = "Enabled", flag = "knifeaura", callback = function(state)
    if state then
        client.maids.knifeaura:givetask(client.services.runservice.Heartbeat:Connect(function()
            if gamelogic.currentgun and (gamelogic.currentgun.gunnumber == nil or not library.flags.requireknife) then
                local origin = modules.camera.basecframe.Position
                for i, v in next, client.services.players:GetPlayers() do
                    if v.Team ~= player.Team then
                        local torso = chartable[v] and chartable[v].torso
                        if torso then
                            local partpos = torso.Position
                            local iswallbetween = workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, partpos - origin), customignores, false, true) ~= nil
                            if (library.flags.knifecheck == false or iswallbetween == false) and (partpos - origin).Magnitude < library.flags.kniferange then
                                local gunnumber = gamelogic.currentgun.gunnumber
                                if gunnumber then
                                    originals.send(modules.network, "equip", 3)
                                end
                                originals.send(modules.network, "knifehit", v, torso.Name)
                                if gunnumber then
                                    originals.send(modules.network, "equip", gunnumber)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end))
    else
        client.maids.knifeaura:dispose()
    end
end })
knifeaura:addtoggle({ content = "Wall Check", flag = "knifecheck" })
knifeaura:addtoggle({ content = "Require Knife Equipped", flag = "requireknife" })
knifeaura:addslider({ content = "Range", max = 25, default = 25, float = 0.1, flag = "kniferange" })

local knifemods = knifetab:addsection({ content = "Modifications", right = true })
knifemods:addslider({ content = "Knife Time", default = 100, flag = "knifetime" })

local weaponcosmeticstab = weaponscat:addtab({ content = "Cosmetics" })
local bulletvisuals = weaponcosmeticstab:addsection({ content = "Bullet Visuals" })
bulletvisuals:addtoggle({ content = "Anti Traceless", flag = "antitraceless" })
bulletvisuals:addtoggle({ content = "4th July Bullets", flag = "independencedaybullets" })

local sounds = weaponcosmeticstab:addsection({ content = "Sounds", right = true })
sounds:addtoggle({ content = "Use Fire Sound", flag = "usefiresound", callback = function(state)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
sounds:addbox({ content = "Fire Sound ID", numonly = true, flag = "firesound", callback = function(value)
    if gamelogic.currentgun and gamelogic.currentgun.nextfiremode then
        modifyguns()
    end
end })
sounds:addtoggle({ content = "Use Hit Sound", flag = "usehitsound", callback = function(state)
    soundtable.hitmarker = state and { "rbxassetid://" .. library.flags.hitsound } or originalsounds.hitmarker
end })
sounds:addbox({ content = "Hit Sound ID", numonly = true, flag = "hitsound", callback = function(value)
    soundtable.hitmarker = library.flags.usehitsound and { "rbxassetid://" .. value } or originalsounds.hitmarker
end })
sounds:addtoggle({ content = "Use Kill Sound", flag = "usekillsound", callback = function(state)
    soundtable.killshot = state and { "rbxassetid://" .. library.flags.killsound } or originalsounds.killshot
end })
sounds:addbox({ content = "Kill Sound ID", numonly = true, flag = "killsound", callback = function(value)
    soundtable.killshot = library.flags.usekillsound and { "rbxassetid://" .. value } or originalsounds.killshot
end })

local cosmetics = weaponcosmeticstab:addsection({ content = "Gun Design" })
cosmetics:addtogglepicker({ content = "Colour", flag = "guncolour", default = Color3.new(1, 0, 0), onstatechanged = function(state)
    if state and gamelogic.currentgun then
        local gun = cam:FindFirstChild(gamelogic.currentgun.name)
        if gun then
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Color = uicolours.gun
                end
            end
        end
    end
end, oncolourchanged = function(colour)
    uicolours.gun = colour
    if library.flags.guncolour.enabled and gamelogic.currentgun then
        local gun = cam:FindFirstChild(gamelogic.currentgun.name)
        if gun then
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Color = colour
                end
            end
        end
    end
end })
cosmetics:addtoggledropdown({ content = "Material", flag = "gunmat", items = evov3.utils:valuetoarray(Enum.Material:GetEnumItems()), default = "ForceField", onstatechanged = function(state)
    if gamelogic.currentgun then
        local gun = cam:FindFirstChild(gamelogic.currentgun.name)
        if gun then
            local mat = Enum.Material[state and library.flags.gunmat.selected or "SmoothPlastic"]
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = mat
                    if v.ClassName == "MeshPart" and library.flags.fieldeffect ~= "None" then
                        v.TextureID = state and library.flags.gunmat.selected == "ForceField" and "rbxassetid://" .. evov3.utils.forcefields[library.flags.fieldeffect] or ""
                    end
                end
            end
        end
    end
end, onvaluechanged = function(selected)
    if gamelogic.currentgun and library.flags.gunmat.enabled then
        local gun = cam:FindFirstChild(gamelogic.currentgun.name)
        if gun then
            local mat = Enum.Material[selected]
            for i, v in next, gun:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = mat
                    if v.ClassName == "MeshPart" and library.flags.fieldeffect ~= "None" then
                        v.TextureID = selected == "ForceField" and "rbxassetid://" .. evov3.utils.forcefields[library.flags.fieldeffect] or ""
                    end
                end
            end
        end
    end
end })
cosmetics:adddropdown({ content = "ForceField Effect", flag = "fieldeffect", items = evov3.utils:keytoarray(evov3.utils.forcefields, { "None" }), default = "None", callback = function(selected)
    if gamelogic.currentgun and library.flags.gunmat.enabled and library.flags.gunmat.selected == "ForceField" then
        local gun = cam:FindFirstChild(gamelogic.currentgun.name)
        if gun then
            for i, v in next, gun:GetDescendants() do
                if v.ClassName == "MeshPart" then
                    v.TextureID = selected == "None" and "" or "rbxassetid://" .. evov3.utils.forcefields[selected]
                end
            end
        end
    end
end })

local playercat = library:addcategory({ content = "Players" })
local charactertab = playercat:addtab({ content = "Character" })

local charvalues = charactertab:addsection({ content = "Values" })
charvalues:addtoggleslider({ content = "WalkSpeed", flag = "walkspeed", min = 16, max = 36, onstatechanged = function(state)
    if gamechar.alive then
        originals.setbasewalkspeed(gamechar, state and library.flags.walkspeed.value or gamelogic.currentgun.data.walkspeed)
    end
end, onvaluechanged = function(value)
    if gamechar.alive then
        originals.setbasewalkspeed(gamechar, library.flags.walkspeed.enabled and value or gamelogic.currentgun.data.walkspeed)
    end
end })
charvalues:addtoggleslider({ content = "JumpPower", flag = "jumppower", min = 4, max = 250 })--[[
charvalues:addbind({ content = "Fly", flag = "fly", onkeydown = function()
	client.states.isflying = not client.states.isflying
	if client.states.isflying then
		client.maids.fly:givetask(client.services.runservice.RenderStepped:Connect(function(frameDelay)
			if root then
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
                flyvec = flyvec == Vector3.new() and client.states.baseflyvec or flyvec
                if flykeys.Space and not flykeys.LeftShift then
                    flyvec = flyvec + Vector3.new(0, 1, 0)
                elseif flykeys.LeftShift and not flykeys.Space then
                    flyvec = flyvec + Vector3.new(0, -1, 0)
                end
                root.Velocity = flyvec.Unit * library.flags.flyspeed
                root.Anchored = flyvec == client.states.baseflyvec
			end
		end))
    else
        client.maids.fly:dispose()
        if root and root.Anchored then
            root.Anchored = false
            root.Velocity = Vector3.new()
        end
	end
end })
charvalues:addslider({ content = "Fly Speed", min = 16, max = 250, default = 125, flag = "flyspeed" })
]]
local movement = charactertab:addsection({ content = "Movement", right = true })
movement:addtoggle({ content = "No Jump Cooldown", flag = "nojumpcooldown" })
movement:addtoggle({ content = "No Slide Cooldown", flag = "noslidecooldown" })
movement:addslider({ content = "Fall Damage Reduction", flag = "falldamage" })

local bhop = charactertab:addsection({ content = "Bunny Hop", right = true })
bhop:addtoggle({ content = "Enabled", flag = "bhop", callback = function(state)
    if state then
        client.maids.bhop:givetask(client.services.runservice.Heartbeat:Connect(function()
            if gamechar.alive and hum and hum.FloorMaterial ~= Enum.Material.Air and (library.flags.bhopspace == false or client.services.userinputservice:IsKeyDown(Enum.KeyCode.Space)) then
                local vel = hum.MoveDirection * (getupvalue(originals.setbasewalkspeed, 1) + library.flags.bhopstrafe)
                hum.JumpPower = (2 * workspace.Gravity * (library.flags.jumpenabled and library.flags.jumpvalue or 4)) ^ 0.5
                hum.Jump = true
                root.Velocity = Vector3.new(vel.X, root.Velocity.Y, vel.Z)
            end
        end))
    else
        client.maids.bhop:dispose()
    end
end })
bhop:addtoggle({ content = "When Space Is Down", flag = "bhopspace" })
bhop:addslider({ content = "Strafe Speed", flag = "bhopstrafe", max = 36 })

local thirdperson = charactertab:addsection({ content = "Third Person" })
thirdperson:addbind({ content = "Enabled", flag = "thirdpersonbind", onkeydown = function()
    client.states.isthirdperson = not client.states.isthirdperson
    if localmodel then
        for i, v in next, localmodel:GetDescendants() do
            if v:IsA("BasePart") or v:IsA("Texture") then
                v.Transparency = client.states.isthirdperson and library.flags.thirdtransparency or 1
            end
        end
    end
end })
thirdperson:addtoggle({ content = "Faster Movement", flag = "thirdpersonfastmove", callback = function(state)
    local springs = getupvalues(localupdater.resetSprings)
    springs[2].s = state and 9e9 or 32
    springs[3].s = state and 9e9 or 6
    springs[4]._r = state and 9e9 or 12
end })
thirdperson:addslider({ content = "Transparency", max = 1, float = 0.01, flag = "thirdtransparency", callback = function(value)
    if localmodel and client.states.isthirdperson then
        for i, v in next, localmodel:GetDescendants() do
            if v:IsA("BasePart") or v:IsA("Texture") then
                v.Transparency = client.states.isthirdperson and library.flags.thirdtransparency or 1
            end
        end
    end
end })

local playermods = charactertab:addsection({ content = "Other", right = true })
playermods:addtoggle({ content = "Auto Deploy", flag = "autodeploy", callback = function(state)
    if state then
        local debounce = false
        client.maids.deploy:givetask(client.services.runservice.Heartbeat:Connect(function()
            if modules.menuscreen.isEnabled() and debounce == false then
                debounce = true
                modules.network:send("spawn")
                task.wait(1)
                debounce = false
            end
        end))
    else
        client.maids.deploy:dispose()
    end
end })
playermods:addtoggle({ content = "Auto Spot Players", flag = "autospot", callback = function(state)
    if state then
        client.maids.spot:givetask(client.services.runservice.Heartbeat:Connect(function()
            if gamechar.alive then
                hud:spot()
            end
        end))
    else
        client.maids.spot:dispose()
    end
end })

local antiaimtab = playercat:addtab({ content = "Anti Aim" })

local antiangles = antiaimtab:addsection({ content = "Fake Angles" })
antiangles:addtoggledropdown({ content = "Custom Pitch", flag = "custompitch", items = { "Up", "Down", "Forward" }, default = "Down" })
antiangles:addtoggledropdown({ content = "Custom Yaw", flag = "customyaw", items = { "Left", "Right", "Backward", "Spinbot" }, default = "Spinbot", onstatechanged = function(state)
    client.states.spinyaw = 0
end })
antiangles:addslider({ content = "Spinbot Speed", min = 1, max = 180, flag = "spinbotspeed" })

local antistance = antiaimtab:addsection({ content = "Fake Stance", right = true })
antistance:addtoggledropdown({ content = "Enabled", flag = "fakestance", items = { "Stand", "Crouch", "Prone" }, default = "Prone", onstatechanged = function(state)
    if gamechar.alive then
        modules.network:send("stance", state and string.lower(library.flags.fakestance.value) or gamechar.movementmode or "stand")
    end
end, onvaluechanged = function(selected)
    if gamechar.alive then
        modules.network:send("stance", library.flags.fakestance.enabled and string.lower(selected) or gamechar.movementmode or "stand")
    end
end })

local antilols = antiaimtab:addsection({ content = "Other", right = true })
antilols:addtoggleslider({ content = "Spaz", flag = "spaz", max = 8, float = 0.01 })

local inventorytab = playercat:addtab({ content = "Inventory" })
local unlocks = inventorytab:addsection({ content = "Unlocks" })
unlocks:addtoggle({ content = "Unlock All Weapons", flag = "unlockallguns", callback = function(state)
    if state and library.flags.unlockallatts == false and library.flags.unlockallcamos == false then
        previousequipped = evov3.utils:deepclone(plrdata.settings.classdata)
    end
end })
unlocks:addtoggle({ content = "Unlock All Attachments", flag = "unlockallatts", callback = function(state)
    if state and library.flags.unlockallguns == false and library.flags.unlockallcamos == false then
        previousequipped = evov3.utils:deepclone(plrdata.settings.classdata)
    end
end })
unlocks:addtoggle({ content = "Unlock All Camos", flag = "unlockallcamos", callback = function(state)
    if state and library.flags.unlockallguns == false and library.flags.unlockallatts == false then
        previousequipped = evov3.utils:deepclone(plrdata.settings.classdata)
    end
end })

local otherplayers = playercat:addtab({ content = "Other Players" })
local resolver = otherplayers:addsection({ content = "Resolve Stances" })
resolver:addtoggledropdown({ content = "Enabled", flag = "resolvestances", items = { "Stand", "Crouch", "Prone" }, default = "Stand", onstatechanged = function(state)
    for i, v in next, client.services.players:GetPlayers() do
        if v ~= player then
            local updater = replication.getupdater(v)
            if updater then
                updater.setstance(state and string.lower(library.flags.resolvestances.selected) or (updatedata[v] and updatedata[v].stance) or "stand")
            end
        end
    end
end, onvaluechanged = function(selected)
    for i, v in next, client.services.players:GetPlayers() do
        if v ~= player then
            local updater = replication.getupdater(v)
            if updater then
                updater.setstance(library.flags.resolvestances.enabled and string.lower(selected) or (updatedata[v] and updatedata[v].stance) or "stand")
            end
        end
    end
end })

local resolvelols = otherplayers:addsection({ content = "Other", right = true })
resolvelols:addtoggle({ content = "Resolve Positions", flag = "resolvepositions" })

local othercat = library:addcategory({ content = "Other" })
local misctab = othercat:addtab({ content = "Misc" })

local hopper = misctab:addsection({ content = "Server Hop" })
hopper:addtoggle({ content = "Enabled", flag = "serverhop" })
hopper:addtoggle({ content = "Re-execute Evo", flag = "executeonhop" })
hopper:adddropdown({content = "Hop Mode", flag = "hopmode", items = { "On Votekick Started", "On Votekicked" }, default = "On Votekick Started" })

local chat = misctab:addsection({ content = "Chat", right = true })
chat:addtoggle({ content = "Chat Bot", flag = "chatbot", callback = function(state)
    if state then
        repeat task.wait(2.5 + math.random())
            local msg = chatmessages[math.random(1, #chatmessages)]
            originals.send(modules.network, "chatted", type(msg) == "function" and msg() or msg, false)
        until library.flags.chatbot == false
    end
end })

local map = misctab:addsection({ content = "Map", right = true })
map:addbind({ content = "Break All Windows", flag = "breakwindows", onkeydown = function()
    if gamechar.alive then
        for i, v in next, workspace.Map:GetDescendants() do
            if v.Name == "Window" then
                modules.effects:breakwindow(v, (v.Position - modules.camera.basecframe.Position).Unit)
            end
        end
    end
end })

--[[ Hooks ]]--

modules.network.send = newcclosure(function(self, key, ...)
    local args = {...}
    if blacklistedargs[key] or (key == "state" and args[1] == player) or (key == "forcereset" and not string.find(debug.traceback(), "despawn")) then
        return
	elseif key == "newbullets" then
		local target = silentaimtarget
        if target and math.random(1, 100) <= library.flags.hitchance then
            if library.flags.conserveammo and calcdamage(target.origin, target.pos, target.part.Name) >= getplayerhealth(target.player) then
                silentaimignore[target.player] = 0
            end
			args[1].firepos = target.origin
			for i = 1, #args[1].bullets do
				local bullet = args[1].bullets[i]
				bullet[1] = target.path
				table.insert(bullets, bullet[2])
			end
            if library.flags.bullettracers then
                tracepath(target.origin, target.path)
            end
            args[1].camerapos = lastpos
            local startpos = lastpos
            --[[local shouldtp = (startpos - target.origin).Magnitude > 10
            if shouldtp then
                teleport(target.origin, true)
            end]]
            originals.send(modules.network, "newbullets", args[1], args[2])
            --[[if shouldtp then
                teleport(startpos, true)
            end]]
            task.delay(isbanland and 0 or target.dur, function()
                for i = 1, #args[1].bullets do
                    originals.send(modules.network, "bullethit", target.player, target.pos, target.part.Name, args[1].bullets[i][2])
                end
            end)
            return
        else
			if library.flags.unlockallguns then
				for i = 1, #args[1].bullets do
					local bullet = args[1].bullets[i]
					bullet[1] = bullet[1].Unit * gundata[previousequipped[client.states.currentclass][gamelogic.currentgun.gunnumber == 1 and "Primary" or "Secondary"].Name].bulletspeed
				end
			end
			if library.flags.bullettracers then
				for i = 1, #args[1].bullets do
					tracepath(args[1].firepos, args[1].bullets[i][1])
				end
			end
		end
	elseif key == "bullethit" then
        if table.find(bullets, args[4]) then
            return
        elseif library.flags.alwaysheadshot then
            args[3] = "Head"
        end
    elseif key == "repupdate" then
        if client.states.blockreplication then
            return
        end
        client.states.updatesafterspawn += 1
        local pitch, yaw = args[2].X, args[2].Y
        if library.flags.spaz.enabled and client.states.updatesafterspawn > 15 then
            local spazvec = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)).Unit * library.flags.spaz.value
            local _, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(args[1], spazvec), customignores, false, true)
            local movevec = pos - pos.Unit
            if lastpos and (movevec - lastpos).Magnitude > 9.75 then
                movevec = lastpos + (movevec - lastpos).Unit * 9.75
            end
            if lastpos == nil or workspace:FindPartOnRayWithIgnoreList(Ray.new(lastpos, movevec - lastpos), customignores, false, true) == nil then
                args[1] = movevec
            end
        end
        if library.flags.custompitch.enabled then
            pitch = math.rad(library.flags.custompitch.selected == "Up" and 85 or library.flags.custompitch.selected == "Down" and -85 or library.flags.custompitch.selected == "Forward" and 0)
        end
        if library.flags.customyaw.enabled then
            if library.flags.customyaw.selected == "Spinbot" then
                client.states.spinyaw = client.states.spinyaw + math.rad(library.flags.spinbotspeed - 0.5 + math.random())
                yaw = client.states.spinyaw
            else
                local vec = library.flags.customyaw.selected == "Left" and cam.CFrame.RightVector * -1 or library.flags.customyaw.selected == "Right" and cam.CFrame.RightVector or library.flags.customyaw.selected == "Backward" and cam.CFrame.LookVector * -1
                yaw = select(2, modules.vector.toanglesyx(vec))
            end
        end
        args[2] = Vector2.new(pitch, yaw)
        if client.states.isthirdperson then
            local newtick, reset = modules.gameclock.getTime(), false
            if localupdater.lastPacketTime and newtick - localupdater.lastPacketTime > 0.5 then
                reset = true
                localupdater.breakcount = localupdater.breakcount + 1
            end
            replicationspring:receive(newtick, args[3], {
                t = args[3],
                position = args[1],
                velocity = localupdater.receivedPosition and localupdater.receivedFrameTime and (args[1] - localupdater.receivedPosition) / (args[3] - localupdater.receivedFrameTime) or Vector3.new(),
                angles = args[2],
                breakcount = localupdater.breakcount
            }, reset)
            localupdater.updaterecieved = true
            localupdater.receivedPosition = args[1]
            localupdater.receivedFrameTime = args[3]
            localupdater.lastPacketTime = newtick
        end
        lastpos = args[1]
        --args[3] = client.states.time
    elseif key == "changeWeapon" and not originals.ownsweapon(plrdata, args[2]) then
		return
	elseif key == "changeAttachment" and not originals.ownsatt(plrdata, args[3], plrdata.settings.classdata[client.states.currentclass][args[1]].Name, args[2]) then
		return
	elseif key == "changeCamo" and not table.find(originals.getcamolist(plrdata, plrdata.settings.classdata[client.states.currentclass][args[1]].Name), args[3]) then
		return
    elseif key == "falldamage" then
        if library.flags.falldamage == 100 then
            return
        end
        args[1] = math.max(args[1] * (1 - library.flags.falldamage / 100), 16.001)
    elseif key == "stance" then
        if library.flags.fakestance.enabled then
            args[1] = string.lower(library.flags.fakestance.value)
        end
        localupdater.setstance(args[1])
    elseif key == "aim" then
        localupdater.setaim(args[1])
    elseif key == "sprint" then
        localupdater.setsprint(args[1])
    elseif key == "stab" then
        localupdater.stab()
    elseif key == "equip" and localmodel then
        local currentname = gamelogic.currentgun.name
        localupdater[gamelogic.currentgun.type == "KNIFE" and "equipknife" or "equip"](gundata[currentname], weapondb:FindFirstChild(currentname, true).External)
        modifyguns()
        if gamelogic.currentgun.attachments then
            spreadspring = getupvalue(gamelogic.currentgun.step, 36)
            if library.flags.ballistictracking then
				if gamelogic.currentgun.attachments.Other == nil then
					gamelogic.currentgun.attachments.Other = ""
				end
                setconstant(gamechar.animstep, trackindex, gamelogic.currentgun.attachments.Other)
            end
        end
        task.spawn(function()
            local hadmodel = localmodel:FindFirstChild("Model")
            if hadmodel then
                localmodel.ChildRemoved:Wait()
            end
            localmodel:WaitForChild("Model", 3)
            if not hadmodel then
                task.wait(0.05)
            end
            for i, v in next, localmodel:GetDescendants() do
                if v.ClassName == "Texture" or v.ClassName == "Decal" or v:IsA("BasePart") then
                    v.Transparency = client.states.isthirdperson and library.flags.thirdtransparency or 1
                end
            end
        end)
	elseif key == "changeClass" then
		client.states.currentclass = args[1]
    elseif key == "spawn" then
        client.states.time = self:getTime()
	end
	originals.send(self, key, unpack(args))
end)

modules.camera.suppress = newcclosure(function(...)
    if not library.flags.nosuppression then
        return originals.suppress(...)
    end
end)

modules.camera.hit = newcclosure(function(...)
    if not library.flags.nosuppression then
        return originals.hit(...)
    end
end)

modules.camera.setsway = newcclosure(function(self, ...)
    if library.flags.nosway or (aimbottarget and (client.states.isaimkeydown or library.flags.ignorekey)) then
        return originals.setsway(self, 0)
    end
    return originals.setsway(self, ...)
end)

modules.camera.setswayspeed = newcclosure(function(self, ...)
    if library.flags.nosway or (aimbottarget and (client.states.isaimkeydown or library.flags.ignorekey)) then
        return originals.setswayspeed(self, 0)
    end
    return originals.setswayspeed(self, ...)
end)

modules.camera.shake = newcclosure(function(self, shakevec)
    if library.flags.nocamshake then
        return
    end
    if aimbottarget and (client.states.isaimkeydown or library.flags.ignorekey) then
        shakevec = Vector3.new(0, shakevec.Y, shakevec.Z)
    end -- yes the calc below is supposed to be backwards
    return originals.shake(self, Vector3.new(shakevec.X * (1 - library.flags.recoily / 100), shakevec.Y * (1 - library.flags.recoilx / 100), shakevec.Z * (1 - library.flags.recoilkick / 100)))
end)

modules.animation.player = newcclosure(function(model, anim)
    if library.flags.knifetime < 100 then
        local name = getanimationname(anim)
        if name == "stab1" or name == "stab2" or name == "quickstab" then
            if library.flags.knifetime == 0 then
                return function() end
            end
            local clone = evov3.utils:deepclone(anim)
            clone.timescale = anim.timescale * (library.flags.knifetime / 100)
            clone.stdtimescale = anim.stdtimescale * (library.flags.knifetime / 100)
            return originals.animplayer(model, clone)
        end
    elseif library.flags.throwtime < 100 and string.find(debug.traceback(), "throw") then
        if library.flags.throwtime == 0 then
            return function() end
        end
        local clone = evov3.utils:deepclone(anim)
        clone.timescale = anim.timescale * (library.flags.throwtime / 100)
        clone.stdtimescale = anim.stdtimescale * (library.flags.throwtime / 100)
        return originals.animplayer(model, clone)
    end
    return originals.animplayer(model, anim)
end)

modules.playerdata.ownsWeapon = newcclosure(function(...)
    return library.flags.unlockallguns or originals.ownsweapon(...)
end)

modules.playerdata.ownsAttachment = newcclosure(function(...)
    return library.flags.unlockallatts or originals.ownsatt(...)
end)

modules.playerdata.getCamoList = newcclosure(function(...)
    local list = originals.getcamolist(...)
    if library.flags.unlockallcamos then
        for i, v in next, modules.camodb do
            if not table.find(list, i) then
                table.insert(list, i)
            end
        end
    end
    return list
end)

hud.getsteadysize = newcclosure(function(self, ...)
    return library.flags.nosteadylimit and 0 or originals.getsteadysize(self, ...)
end)

gamechar.setbasewalkspeed = newcclosure(function(self, speed)
    if library.flags.walkspeed.enabled then
        speed = library.flags.walkspeed.value
    end
    return originals.setbasewalkspeed(self, speed)
end)

gamechar.jump = newcclosure(function(self, power)
    if library.flags.jumppower.enabled then
        power = library.flags.jumppower.value
    end
    return originals.jump(self, power)
end)

gamechar.updatecharacter = newcclosure(function(pos)
    local res = originals.updatecharacter(pos)
    localupdater.spawn(pos)
    localmodel = getupvalue(localupdater.spawn, 3)
    return res
end)

gamechar.setsprint = newcclosure(function(self, ...)
    if library.flags.runandgun and string.find(debug.traceback(), "function shoot") then
        return
    end
    return originals.setsprint(self, ...)
end)

modules.screencull.step = newcclosure(function(cf, ...)
    if modules.camera.type == "firstperson" and not gamelogic.currentgun.isaiming() then
        cam.CFrame = cf * CFrame.new(library.flags.camoffsetx, library.flags.camoffsety, library.flags.camoffset)
    end
    return originals.cullstep(cf, ...)
end)

setreadonly(modules.particle, false)
modules.particle.new = newcclosure(function(data)
	if data.thirdperson then
		if library.flags.antitraceless and data.traceless then
			data.traceless = false
		end
	else
		if library.flags.independencedaybullets then
			client.independencedaybullets.index += 1
			if client.independencedaybullets.index > #client.independencedaybullets.colours then
				client.independencedaybullets.index = 1
			end
			data.color = client.independencedaybullets.colours[client.independencedaybullets.index]
		end
		if library.flags.unlockallguns then
			local unlockdata = gundata[previousequipped[client.states.currentclass][gamelogic.currentgun.gunnumber == 1 and "Primary" or "Secondary"].Name]
			data.penetrationdepth = unlockdata.penetrationdepth
			data.velocity = data.velocity.Unit * unlockdata.bulletspeed
		end
	end
	return originals.newparticle(data)
end)
setreadonly(modules.particle, true)

originals.clientequip = garbage.clientevents[clientkeys.equip]
garbage.clientevents[clientkeys.equip] = newcclosure(function(plr, weapon, ...)
    originals.clientequip(plr, weapon, ...)
    updatedata[plr].equipped = weapon
end)

originals.clientstance = garbage.clientevents[clientkeys.stance]
garbage.clientevents[clientkeys.stance] = newcclosure(function(plr, stance, ...)
    if plr ~= player then
        stance = library.flags.resolvestances.enabled and string.lower(library.flags.resolvestances.selected) or stance
        updatedata[plr].stance = stance
    end
    originals.clientstance(plr, stance, ...)
end)

originals.clientaddammo = garbage.clientevents[clientkeys.addammo]
garbage.clientevents[clientkeys.addammo] = newcclosure(function(...)
    originals.clientaddammo(...)
    updateammo(gamelogic.currentgun)
end)

originals.clientbulkupdate = garbage.clientevents[clientkeys.bulkplayerupdate]
garbage.clientevents[clientkeys.bulkplayerupdate] = newcclosure(function(data)
    originals.clientbulkupdate(data)
    if data.packets and library.flags.resolvepositions then
        for i, v in next, client.services.players:GetPlayers() do
            if v ~= player then
                local updater = replication.getupdater(v)
                if updater and updater.alive then
                    updater.resetSprings(updater.receivedPosition)
                end
            end
        end
    end
end)

originals.clientkillfeed = garbage.clientevents[clientkeys.killfeed]
garbage.clientevents[clientkeys.killfeed] = newcclosure(function(killer, victim, dist, gun, ...)
    originals.clientkillfeed(killer, victim, dist, gun, ...)
    task.spawn(function()
        if silentaimignore[victim] then
            repeat task.wait() until chartable[victim] == nil
            silentaimignore[victim] = nil
        end
    end)
end)

garbage.clientevents[clientkeys.spawn] = newcclosure(function(...)
    local args = {...}
    if library.flags.unlockallguns then
        args[3].Name = plrdata.settings.classdata[client.states.currentclass].Primary.Name
        args[4].Name = plrdata.settings.classdata[client.states.currentclass].Secondary.Name
        args[7].Name = plrdata.settings.classdata[client.states.currentclass].Knife.Name
    end
    if library.flags.unlockallatts then
        args[3].Attachments = plrdata.settings.classdata[client.states.currentclass].Primary.Attachments
        args[4].Attachments = plrdata.settings.classdata[client.states.currentclass].Secondary.Attachments
    end
    if library.flags.unlockallcamos then
        args[3].Camo = plrdata.settings.classdata[client.states.currentclass].Primary.Camo
        args[4].Camo = plrdata.settings.classdata[client.states.currentclass].Secondary.Camo
        args[7].Camo = plrdata.settings.classdata[client.states.currentclass].Knife.Camo
    end
    clientfuncs.spawn(...)
end)

originals.clientnewspawn = garbage.clientevents[clientkeys.newspawn]
garbage.clientevents[clientkeys.newspawn] = newcclosure(function(plr, ...)
    originals.clientnewspawn(plr, ...)
    task.spawn(function()
        local plrchar = chartable[plr].torso.Parent
        repeat task.wait() until plrchar.Parent and plrchar.Parent.Parent == workspace.Players
        setthreadidentity(7)
        espgroups.players:add(plrchar, { name = plr.Name, colour = plr.TeamColor.Color, alwaysremove = true })
        highlight(plr, plrchar)
        for i, v in next, plrchar:GetChildren() do
            if v:IsA("BasePart") then
                v.Size = library.flags.expandhitboxes.enabled and v.Size.Unit * library.flags.expandhitboxes.value or charactersizes[v.Name]
            end
        end
        setthreadidentity(2)
    end)
end)

modules.spring.__index = newcclosure(function(t, k)
    if library.flags.nogunswing and t == swingspring then
        if k == "s" then
            return 0.001
        elseif k == "v" then
            return Vector3.new()
        end
    end
    return originals.springindex(t, k)
end)

modules.spring.__newindex = newcclosure(function(t, k, v)
    if t == spreadspring and k == "a" then
        v = v * Vector3.new(1 - (library.flags.spready / 100), 1 - (library.flags.spreadx / 100), 1)
    end
    return originals.springnewindex(t, k, v)
end)

--[[ Connections ]]--

gamechar.ondied:connect(function()
    lastpos = nil
    client.states.spinyaw = 0
    client.states.updatesafterspawn = 0
    local body = localupdater.died()
    if body then
        body:Destroy()
    end
    for i = 1, #bullets do
        bullets[i] = nil
    end
end)

player.CharacterAdded:Connect(registerchar)
client.services.players.PlayerAdded:Connect(registerplayer)

client.services.players.PlayerRemoving:Connect(function(plr)
    if updatedata[plr] then
        updatedata[plr] = nil
    end
end)

mouse.Move:Connect(function()
    local location = rescalecrosshair()
    aimbotfovcircle.Position = location
    silentaimfovcircle.Position = location
end)

cam.ChildAdded:Connect(function(child)
    if weapondb:FindFirstChild(child.Name, true) and (library.flags.guncolour.enabled or library.flags.gunmat.enabled or library.flags.nosightreticle) then
        task.wait(0.1)
        for i, v in next, child:GetDescendants() do
            if v:IsA("BasePart") then
                if library.flags.guncolour.enabled then
                    v.Color = uicolours.gun
                end
                if library.flags.gunmat.enabled then
                    v.Material = Enum.Material[library.flags.gunmat.selected]
                    if v.ClassName == "MeshPart" and library.flags.fieldeffect ~= "None" then
                        v.TextureID = library.flags.gunmat.selected == "ForceField" and "rbxassetid://" .. evov3.utils.forcefields[library.flags.fieldeffect] or ""
                    end
                end
            end
            if string.sub(v.Name, 1, 9) == "SightMark" and v:FindFirstChild("SurfaceGui") then
                v.SurfaceGui.Enabled = not library.flags.nosightreticle
            end
        end
    end
end)

workspace.Ignore.GunDrop.ChildAdded:Connect(function(child)
    if child.Name == "Dropped" and child:WaitForChild("Gun", 3) then
        espgroups.dropped:add(child, { name = child.Gun.Value, root = child.PrimaryPart.Name, alwaysremove = true })
    end
end)

workspace.Ignore.Misc.ChildAdded:Connect(function(child)
    if child.Name == "Hole" or child.Name == "DefaultImpact" then
        table.insert(impactpoints, child)
        if library.flags.impactpoints.enabled then
            child.Color = uicolours.impacts
            child.Material = Enum.Material[library.flags.impactmaterial]
            child.Transparency = library.flags.impacttransparency
        end
    end
end)

workspace.Ignore.Misc.ChildRemoved:Connect(function(child)
    local idx = table.find(impactpoints, child)
    if idx then
        table.remove(impactpoints, idx)
    end
end)

client.services.userinputservice.InputBegan:Connect(function(input, isrbx)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            client.states.isaimkeydown = true
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and flykeys[input.KeyCode.Name] ~= nil then
            flykeys[input.KeyCode.Name] = true
        end
        if input.KeyCode == Enum.KeyCode.Space and root and hum and library.flags.infjump and hum.FloorMaterial == Enum.Material.Air then
            root.Velocity = Vector3.new(root.Velocity.X, hum.JumpPower, root.Velocity.Z)
        end
    end
end)

client.services.userinputservice.InputEnded:Connect(function(input)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            client.states.isaimkeydown = false
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and flykeys[input.KeyCode.Name] ~= nil then
            flykeys[input.KeyCode.Name] = false
        end
    end
end)

client.services.runservice:BindToRenderStep("xxx", Enum.RenderPriority.Camera.Value + 3, LPH_JIT_ULTRA(function()
    if client.states.isthirdperson and localmodel and localupdater.alive then
        localupdater.step(3, true)
    end
    if client.states.serverhopped == false and chatframe.Votekick.Visible and library.flags.serverhop and string.find(chatframe.Votekick.Title.Text, player.Name) then
        if library.flags.hopmode == "On Votekick Started" then
            serverhop()
        elseif library.flags.hopmode == "On Votekicked" and getupvalue(hud.votestep, 8) == getupvalue(hud.votestep, 9) then
            serverhop()
        end
    end
end))

client.services.runservice:BindToRenderStep("xxxx", Enum.RenderPriority.Camera.Value + 2, LPH_JIT_ULTRA(function()
    if library.flags.chams and library.flags.showhiddenchams then
        local origin = cam.CFrame.Position
        local items = library.storage.highlights:GetChildren()
        for i = 1, #items do
            local v = items[i]
            v.FillColor = workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, v.Adornee[library.flags.chamvisiblecheck].Position - origin), { cam, workspace.Terrain, workspace.Ignore, workspace.Players }, false, true) == nil and uicolours.visiblechamcolour or uicolours.hiddenchamcolour
        end
    end
end))

client.services.runservice:BindToRenderStep("xxxxx", Enum.RenderPriority.Camera.Value + 1, LPH_JIT_ULTRA(function()
    aimbotfovcircle.Radius = library.flags.aimbotfov.value * (library.flags.aimbotfovdynamic and (modules.camera.basefov / cam.FieldOfView) or 1)
    silentaimfovcircle.Radius = library.flags.silentaimfov.value * (library.flags.silentaimfovdynamic and (modules.camera.basefov / cam.FieldOfView) or 1)
	if gamelogic.currentgun and gamelogic.currentgun.barrel then
        local hasshot = false
        if lastpos and library.flags.silentaimenabled then
            silentaimtarget = getsilentaimtarget()
            if silentaimtarget then
                if library.flags.autofire.enabled and (library.flags.autofire.selected == "Auto Wallbang" or (library.flags.autofire.selected == "Auto Shoot" and not silentaimtarget.iswallbetween)) and (library.flags.interruptreload or getupvalue(gamelogic.currentgun.reloadcancel, 1) == false) then
                    hasshot = true
                    (library.flags.simulateshots and fakeshoot or shoot)(silentaimtarget)
                end
                if library.flags.silentaimhighlight.enabled and silentaimtarget.player ~= highlighted.silentaim then
                    if highlighted.silentaim and chartable[highlighted.silentaim] then
                        espgroups.players:highlight(chartable[highlighted.silentaim].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.silentaim.TeamColor.Color)
                    end
                    highlighted.silentaim = silentaimtarget.player
                    espgroups.players:highlight(silentaimtarget.part.Parent, uicolours.silentaimhighlight)
                end
            elseif highlighted.silentaim and chartable[highlighted.silentaim] then
                espgroups.players:highlight(chartable[highlighted.silentaim].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.silentaim.TeamColor.Color)
                highlighted.silentaim = nil
            end
        end
        if library.flags.aimbotenabled then
            aimbottarget = getaimbottarget()
            if aimbottarget then
                if client.states.isaimkeydown or library.flags.ignorekey then
                    local pos = aimbottarget.pos
                    if library.flags.compensatedrop then
                        pos = pos + Vector3.new(0, (-acceleration.Y / 2) * (aimbottarget.dur ^ 2), 0)
                    end
                    if library.flags.predictmovement then
                        local data = updatedata[aimbottarget.player].replicationspring._frameDataList
                        pos = pos + data[#data].velocity * aimbottarget.dur
                    end
                    local screenpos = cam:WorldToScreenPoint(pos)
                    modules.input.mouse.onmousemove:fire(Vector3.new((screenpos.X - mouse.X) / library.flags.smoothness, (screenpos.Y - mouse.Y) / library.flags.smoothness, 0) / 5)
                end
                if library.flags.aimbothighlight.enabled and aimbottarget.player ~= highlighted.aimbot then
                    if highlighted.aimbot and chartable[highlighted.aimbot] then
                        espgroups.players:highlight(chartable[highlighted.aimbot].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.aimbot.TeamColor.Color)
                    end
                    highlighted.aimbot = aimbottarget.player
                    espgroups.players:highlight(aimbottarget.part.Parent, uicolours.aimbothighlight)
                end
            elseif highlighted.aimbot and chartable[highlighted.aimbot] then
                espgroups.players:highlight(chartable[highlighted.aimbot].torso.Parent, espgroups.players.settings.usecustomcolours and espgroups.players.settings.enemycolour or highlighted.aimbot.TeamColor.Color)
                highlighted.aimbot = nil
            end
        end
        if hasshot == false and library.flags.autofire.enabled and library.flags.autofire.selected == "Triggerbot" and (library.flags.interruptreload or getupvalue(gamelogic.currentgun.reloadcancel, 1) == false) then
            local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { cam, workspace.Terrain, workspace.Ignore }, false, true)
            if part and plrtable[part.Parent] and plrtable[part.Parent].Team ~= player.Team then
                shoot()
            end
        end
	end
end))

--[[ End ]]--

for _, folder in next, workspace.Players:GetChildren() do
    for i, v in next, folder:GetChildren() do
        local plr = plrtable[v]
        if plr and plr ~= player then
            espgroups.players:add(v, { name = plr.Name, colour = plr.TeamColor.Color, alwaysremove = true })
            highlight(plr, v)
        end
    end
end

setupvalue(loadplayer, 1, "")
localupdater = loadplayer(player)
setupvalue(loadplayer, 1, player)

replicationspring = getupvalue(localupdater.step, 3)
localmodel = getupvalue(localupdater.spawn, 3)

for i, v in next, getupvalues(localupdater.step) do
    if type(v) == "table" and rawget(v, "makesound") then
        v.makesound = false
        break
    end
end

library:addsettings()
sendclientchat(string.format("Evo V3 Loaded! Time Taken: %dms", math.round((tick() - initstamp) * 1000)))
