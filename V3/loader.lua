--[[ Macros ]]--

-- local LPH_ENCSTR = function(...) return ... end
-- local LPH_JIT_ULTRA = function(...) return ... end

--[[ Anticheat ]]--

for i, v in next, getconnections(game:GetService("LogService").MessageOut) do
    v:Disable()
end

for i, v in next, getconnections(game:GetService("ScriptContext").Error) do
    v:Disable()
end

if game.PlaceId == 3233893879 then -- Bad Business
    local conns = getconnections(game:GetService("RunService").Stepped)
    for i = 1, #conns do
        local conn = conns[i]
        if tostring(getfenv(conn.Function).script) == "ItemReplicatorScript" then
            conn:Disable()
            break
        end
    end

    LPH_JIT_ULTRA(function()
        local ts = game:GetService("ReplicatedStorage"):WaitForChild("TS")
        local gc = getgc()
        for i = 1, #gc do
            local v = gc[i]
            if type(v) == "function" and islclosure(v) and getfenv(v).script == ts and table.find(getconstants(v), "Unsafe function: %s.%s") then
                setupvalue(v, 1, {})
                break
            end
        end
    end)()

    loadstring(LPH_ENCSTR([[
        hookfunction(getrenv().PluginManager, function()
            return {
                CreatePlugin = function()
                    return {
                        Deactivate = function() end
                    }
                end
            }
        end)

        local taskspawn; taskspawn = hookfunction(getrenv().task.spawn, function(func, ...)
            if checkcaller() == false then
                local consts = getconstants(func)
                if table.find(consts, "task") and table.find(consts, "wait") then
                    return
                end
            end
            return taskspawn(func, ...)
        end)
    ]]))()
elseif game.PlaceId == 443406476 then -- Project Lazarus
    hookfunction(getrenv().gcinfo, function()
        return math.random(1000, 2000)
    end)
elseif game.PlaceId == 2788229376 then -- Da Hood
    local g = getrenv()._G
    local old; old = hookmetamethod(game, "__index", LPH_JIT_ULTRA(function(t, k)
        if k == "WalkSpeed" and not checkcaller() then
            return g.CurrentWS
        end
        return old(t, k)
    end))
end

--[[ UI ]]--

local function create(classname, properties, children)
	local inst = Instance.new(classname)
	for i, v in next, properties do
	    if i ~= "Parent" then
	       	inst[i] = v
	    end
	end
	if children then
		for i, v in next, children do
			v.Parent = inst
		end
	end
	inst.Parent = properties.Parent
	return inst
end

local ui = create("ScreenGui", { 
    ResetOnSpawn = false, 
    Name = "startup", 
    Parent = game:GetService("CoreGui")
}, {
    create("Frame", { 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392), 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        Size = UDim2.new(0, 425, 0, 160), 
        Name = "main"
    }, {
        create("TextButton", { 
            Font = Enum.Font.SourceSans, 
            FontSize = Enum.FontSize.Size14, 
            TextColor3 = Color3.new(0, 0, 0), 
            TextSize = 14, 
            BackgroundColor3 = Color3.new(1, 1, 1), 
            BackgroundTransparency = 1, 
            Size = UDim2.new(1, 0, 1, 0), 
            ZIndex = 0, 
            Name = "clickblock"
        }),
        create("UICorner", { 
            CornerRadius = UDim.new(0, 4), 
            Name = "corner"
        }),
        create("ImageLabel", { 
            Image = "rbxassetid://8451258844", 
            ImageColor3 = Color3.new(0, 0, 0), 
            ScaleType = Enum.ScaleType.Slice, 
            SliceCenter = Rect.new(10, 10, 502, 502), 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundColor3 = Color3.new(1, 1, 1), 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0.5, 0, 0.5, 0), 
            Size = UDim2.new(1, 8, 1, 8), 
            ZIndex = 0, 
            Name = "blur"
        }),
        create("Frame", { 
            BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882), 
            Size = UDim2.new(1, 0, 0, 34), 
            Name = "top"
        }, {
            create("UICorner", { 
                CornerRadius = UDim.new(0, 4), 
                Name = "corner"
            }),
            create("Frame", { 
                AnchorPoint = Vector2.new(0, 1), 
                BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882), 
                BorderSizePixel = 0, 
                Position = UDim2.new(0, 0, 1, 0), 
                Size = UDim2.new(1, 0, 0, 2), 
                Name = "underline"
            }),
            create("TextLabel", { 
                Font = Enum.Font.GothamSemibold, 
                FontSize = Enum.FontSize.Size14, 
                Text = "EvoV3 |", 
                TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
                TextSize = 14, 
                TextXAlignment = Enum.TextXAlignment.Left, 
                BackgroundColor3 = Color3.new(1, 1, 1), 
                BackgroundTransparency = 1, 
                Position = UDim2.new(0, 15, 0, 0), 
                Size = UDim2.new(0, 59, 1, 0), 
                Name = "title"
            }),
            create("Frame", { 
                AnchorPoint = Vector2.new(1, 0.5), 
                BackgroundColor3 = Color3.new(1, 1, 1), 
                BackgroundTransparency = 1, 
                Position = UDim2.new(1, -4, 0.5, 0), 
                Size = UDim2.new(0, 26, 0, 26), 
                ZIndex = 2, 
                Name = "minimise"
            }, {
                create("UICorner", { 
                    CornerRadius = UDim.new(0, 4), 
                    Name = "corner"
                }),
                create("ImageLabel", { 
                    Image = "rbxassetid://8452408280", 
                    AnchorPoint = Vector2.new(0.5, 0.5), 
                    BackgroundColor3 = Color3.new(1, 1, 1), 
                    BackgroundTransparency = 1, 
                    BorderSizePixel = 0, 
                    Position = UDim2.new(0.5, 0, 0.5, 0), 
                    Rotation = 45, 
                    Size = UDim2.new(1, 0, 1, 0), 
                    ZIndex = 2, 
                    Name = "icon"
                })
            }),
            create("TextLabel", { 
                Font = Enum.Font.GothamSemibold, 
                FontSize = Enum.FontSize.Size14, 
                Text = "Loader", 
                TextColor3 = Color3.new(0.0862745, 0.380392, 0.843137), 
                TextSize = 14, 
                TextXAlignment = Enum.TextXAlignment.Left, 
                BackgroundColor3 = Color3.new(1, 1, 1), 
                BackgroundTransparency = 1, 
                Position = UDim2.new(0, 70, 0, 0), 
                Size = UDim2.new(1, -104, 1, 0), 
                Name = "loader"
            })
        }),
        create("Frame", { 
            AnchorPoint = Vector2.new(0.5, 1), 
            BackgroundColor3 = Color3.new(1, 1, 1), 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0.5, 0, 1, 0), 
            Size = UDim2.new(1, 0, 1, -34), 
            Visible = false, 
            Name = "loader"
        }, {
            create("TextLabel", { 
                Font = Enum.Font.Gotham, 
                FontSize = Enum.FontSize.Size14, 
                Text = "Setting Up...", 
                TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
                TextSize = 14, 
                TextWrap = true, 
                TextWrapped = true, 
                AnchorPoint = Vector2.new(0.5, 0), 
                BackgroundColor3 = Color3.new(1, 1, 1), 
                BackgroundTransparency = 1, 
                Position = UDim2.new(0.5, 0, 0, 20), 
                Size = UDim2.new(1, -60, 0, 40), 
                Name = "label"
            }),
            create("Frame", { 
                AnchorPoint = Vector2.new(0.5, 1), 
                BackgroundColor3 = Color3.new(0.172549, 0.172549, 0.172549), 
                ClipsDescendants = true, 
                Position = UDim2.new(0.5, 0, 1, -34), 
                Size = UDim2.new(1, -76, 0, 6), 
                Name = "background"
            }, {
                create("UICorner", { 
                    CornerRadius = UDim.new(1, 0), 
                    Name = "corner"
                }),
                create("Frame", { 
                    AnchorPoint = Vector2.new(0, 0.5), 
                    BackgroundColor3 = Color3.new(0.0862745, 0.380392, 0.843137), 
                    Position = UDim2.new(0, 0, 0.5, 0), 
                    Size = UDim2.new(0, 0, 1, 0), 
                    Name = "progress"
                }, {
                    create("UICorner", { 
                        CornerRadius = UDim.new(1, 0), 
                        Name = "corner"
                    })
                })
            })
        })
    })
})

ui.main.top.minimise.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ui:Destroy()
    end
end)

--[[ Load ]]--

ui.main.loader.Visible = true

local tweenservice = game:GetService("TweenService")

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog, steps = setup:getloginfo()
local incr = 0

local function updateprogress(str, amount)
    ui.main.loader.label.Text = str
    if amount then
        tweenservice:Create(ui.main.loader.background.progress, TweenInfo.new(0.2), { Size = UDim2.new(amount, 0, 1, 0) }):Play()
    else
        incr = incr + 1
        tweenservice:Create(ui.main.loader.background.progress, TweenInfo.new(0.2), { Size = UDim2.new(incr / steps, 0, 1, 0) }):Play()
    end
end

evov3.startup:connect(updateprogress)

if setup:startchecks(changelog) then
    repeat task.wait() until incr == steps
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Text = "Your exploit does not support this script"
    })
    return
end

updateprogress("Success!", 1)
task.wait(2)

local thisgame = "universal"

for i, v in next, changelog.games do
    for idx = 1, #v do
        local id = v[idx]
        if game.PlaceId == id then
            thisgame = i
        end
    end
end

evov3.startup:dispose()
evov3.startup = nil
ui:Destroy()

--[[ Phantom Forces ]]--

local function phantomforces()

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
                    if modules.bulletcheck(origin, partpos, path, acceleration, data.penetrationdepth) then
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

end

--[[ Bad Business ]]--

local function badbusiness()

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "Bad Business", version = changelog.version .. " Premium" })
evov3.imports:fetchmodule("esp")

local drawing = evov3.imports:fetchsystem("drawing")

local maids = {
    character = evov3.imports:fetchsystem("maid"),
    radar = evov3.imports:fetchsystem("maid"),
    knifeaura = evov3.imports:fetchsystem("maid"),
    noclip = evov3.imports:fetchsystem("maid"),
    fly = evov3.imports:fetchsystem("maid")
}

local runservice = game:GetService("RunService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local userinputservice = game:GetService("UserInputService")
local collectionservice = game:GetService("CollectionService")
local players = game:GetService("Players")
local teams = game:GetService("Teams")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

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

local charsizes, codenames = {}, {}
local skindata, charmdata, stickerdata, weapondata = {}, {}, {}, {}
local uicolours = {}
local nadetpmodes = {}
local highlighted = {}
local classes = { "Primary", "Secondary", "Melee" }
local char, root
local aimbottarget, silentaimtarget, currentgun
local isaimkeydown = false
local isflying, isbhopping, isknifing = false, false, false

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
    "thawed"
}

local flykeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local shell = require(replicatedstorage:WaitForChild("TS"))

local netfire = shell.Network.Fire
local recoilfire = shell.Camera.Recoil.Fire
local lookvector = shell.Input.Reticle.LookVector
local camshove = shell.Items.FirstPerson.CameraSpring.Shove
local timerwait = shell.Timer.Wait
local paint = shell.Skins.Paint
local attach = shell.Charms.Attach
local apply = shell.Stickers.Apply
local getconfig = shell.Items.GetConfig

local datafolder = replicatedstorage.PlayerData:WaitForChild(player.Name)
local skinfolder = replicatedstorage:FindFirstChild("CamoColors", true).Parent
local charmfolder = replicatedstorage:FindFirstChild("_deprecated", true).Parent
local stickerfolder = replicatedstorage:FindFirstChild("_unused", true).Parent
local challenges = player.PlayerGui:WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("Challenges")
local hitmarker = player.PlayerGui:WaitForChild("MainGui"):WaitForChild("HitmarkerScript"):WaitForChild("Hitmarker")

local guntypestats = getupvalue(shell.Projectiles.InitProjectile, 1)
local controlfunc = getupvalue(shell.Timer.BindToHeartbeat, 1).Control
local firstperson = getupvalue(shell.Timer.BindToRenderStep, 1).FirstPerson
local chartable = getupvalue(shell.Characters.GetCharacter, 1)
local hitmarkfunc = getconnections(shell.UI.Events.Hitmarker.Event)[2].Function
local radars = getupvalue(getconnections(shell.UI.Events.RadarEnemy.Event)[1].Function, 1)

local effects = shell.Effects
local effectstable = getupvalue(effects.Effect, 1)
local effectsfolder = getupvalue(effects.Effect, 2)
local flash, smoke, quicklime

local speedidx = evov3.utils:tablefind(getconstants(controlfunc), 1.8)
local bobidx = evov3.utils:tablefind(getconstants(firstperson), 0.3)
local hitidx = evov3.utils:tablefind(getconstants(hitmarkfunc), 1.5)

local clonedtypestats = evov3.utils:deepclone(guntypestats)

local baseflyvec = Vector3.new(0, 1e-9, 0)

local espgroup = evov3.esp.group.new("players", {
    info = {
        equipped = function(container)
            return tostring(container.model.Parent.Backpack.Equipped.Value or "None")
        end
    }
})

local gunconfigs = {}

--[[ Functions ]]--

local function automateinput(name)
    shell.Input:AutomateBegan(name)
	runservice.Heartbeat:Wait()
	shell.Input:AutomateEnded(name)
end

local function registerchar(character)
    char, root = character, character:WaitForChild("Root")
    local grounded, sprinting, conn = char:WaitForChild("State"):WaitForChild("Grounded"), char.State:WaitForChild("SuperSprinting"), nil
    while true do
        local conns = getconnections(grounded.Changed)
        for i = 1, #conns do
            local v = conns[i]
            if tostring(getfenv(v.Function).script) == "ControlScript" then
                conn = v
                break
            end
        end
        if conn then
            conn:Disable()
            break
        end
        task.wait(0.1)
    end

    maids.character:givetask(root:GetPropertyChangedSignal("Velocity"):Connect(function()
        local vel = root.Velocity
        if (vel.Y == 25 or vel.Y == 36) and library.flags.jumppower.enabled then
			root.Velocity = Vector3.new(vel.X, library.flags.jumppower.value, vel.Z)
		end
    end))
    maids.character:givetask(grounded:GetPropertyChangedSignal("Value"):Connect(function()
        if isbhopping and char and grounded.Value then
            shell.Input:AutomateBegan("Jump")
        end
    end))
    maids.character:givetask(sprinting:GetPropertyChangedSignal("Value"):Connect(function()
        if library.flags.autosprint and char and not sprinting.Value then
            shell.Input:AutomateBegan("Sprint")
        end
    end))
    maids.character:givetask(char:WaitForChild("Health"):GetPropertyChangedSignal("Value"):Connect(function()
        if not char:FindFirstChild("Health") or char.Health.Value <= 0 then
            maids.character:dispose()
            table.clear(gunconfigs)
            char, root = nil, nil
        end
    end))
    if library.flags.fakestance.enabled then
        netfire(shell.Network, "Character", "State", "Stance", library.flags.fakestance.selected)
    end
end

local function registergun(model)
    currentgun = model
    local parts = model:WaitForChild("Body"):GetDescendants()
    for i = 1, #parts do
        local v = parts[i]
        if v:IsA("BasePart") then
            if library.flags.guncolour.enabled then
                v.Color = uicolours.guncolour
            end
            if library.flags.gunmat.enabled then
                v.Material = Enum.Material[library.flags.gunmat.selected]
            end
        end
    end
    local conn; conn = model.AncestryChanged:Connect(function(_, parent)
        if parent ~= workspace then
            conn:Disconnect()
            currentgun = nil
        end
    end)
end

local function getplayer(character)
    local plr
    while true do
        plr = shell.Characters:GetPlayerFromCharacter(character)
        if plr or character.Parent ~= workspace.Characters then
            break
        end
        runservice.Heartbeat:Wait()
    end
    return plr
end

local function getaimpart(hitbox, flag)
    if library.flags[flag] == "Closest Part" then
        local retpart, dist = nil, math.huge
        local hitboxes = hitbox:GetChildren()
        for i = 1, #hitboxes do
            local v = hitboxes[i]
            local pos = cam:WorldToScreenPoint(v.Position)
            local mag = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y).Magnitude
            if mag < dist then
                retpart, dist = v, mag
            end
        end
        return retpart
    end
    return hitbox:FindFirstChild(codenames[library.flags[flag]])
end

local function canwallbang(start, vel, flag)
    local depth, max = 0, library.flags[flag] and 0 or 1
    local ignore = { workspace.Characters, workspace.NonGeometry }
    while true do
        local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(start, vel), ignore, true)
        if part then
            depth = depth + 1
            if depth > max then
                return false
            end
            table.insert(ignore, part)
        else
            break
        end
    end
    return true, depth ~= 0
end

local function getsilentaimtarget()
    local ret, dist = nil, library.flags.silentaimfov.enabled and silentaimfovcircle.Radius or math.huge
    local startpos = shell.Input.Reticle:GetPosition()
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local v = plrs[i]
        if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
            local character = chartable[v]
            if character and character.Parent == workspace.Characters and character:FindFirstChild("Health") and character.Health.Value > 0 then
                local part = character:FindFirstChild("Hitbox") and getaimpart(character.Hitbox, "silentaimaimpart")
                if part and character.Root.ShieldEmitter.Enabled == false then
                    local partpos = part.Position
                    local screenpos, vis = cam:WorldToViewportPoint(partpos)
                    if (vis or library.flags.silentaimscreencheck == false) then
                        local canhit, iswallbetween = canwallbang(partpos, startpos - partpos, "silentaimwallcheck")
                        if canhit then
                            local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
                            if mag < dist then
                                ret, dist = {
                                    player = v,
                                    part = part,
                                    pos = partpos,
                                    start = startpos,
                                    iswallbetween = iswallbetween
                                }, mag
                            end
                        end
                    end
                end
            end
        end
    end
    return ret
end

local function getaimbottarget()
    local ret, dist = nil, library.flags.aimbotfov.enabled and aimbotfovcircle.Radius or math.huge
    local startpos = shell.Input.Reticle:GetPosition()
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local v = plrs[i]
        if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
            local character = chartable[v]
            if character and character.Parent == workspace.Characters and character:FindFirstChild("Health") and character.Health.Value > 0 then
                local part = character:FindFirstChild("Hitbox") and getaimpart(character.Hitbox, "aimbotaimpart")
                if part and character.Root.ShieldEmitter.Enabled == false then
                    local partpos = part.Position
                    local screenpos, vis = cam:WorldToViewportPoint(partpos)
                    if vis and canwallbang(partpos, startpos - partpos, "aimbotwallcheck") then
                        local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
                        if mag < dist then
                            ret, dist = {
                                player = v,
                                part = part,
                                pos = partpos,
                                start = startpos
                            }, mag
                        end
                    end
                end
            end
        end
    end
    return ret
end

local function getaimbotposition(aimtarget)
    local targetroot, pos = aimtarget.part.Parent.Parent.Root, aimtarget.pos
    local data = guntypestats[weapondata[currentgun.Name].Controller]
    if data then
        local dur = (targetroot.Position - cam.CFrame.Position).Magnitude / data.Speed
        if library.flags.predictmove then
            pos = pos + (targetroot.Velocity * dur)
        end
        if library.flags.compensatedrop then
            pos = pos + Vector3.new(0, 0.2 * data.Gravity * dur ^ 2, 0)
        end
    end
    return pos
end

local function getequipped()
    local item = char.Backpack.Equipped.Value
    for i = 1, #classes do
        local v = classes[i]
        if char.Backpack[v].Value == item then
            return v
        end
    end
end

local function checkadmin(plr)
    local succ, res
    while succ ~= true do
        succ, res = pcall(plr.IsInGroup, plr, 5284251)
        if succ then
            break
        end
        task.wait()
    end
    if res then
        if library.flags.onstaffjoin.Kick then
            player:Kick("Evo V3 has kicked you: A staff member is in your game\nName: " .. plr.Name .. "\nID: " .. plr.UserId)
        end
        if library.flags.onstaffjoin.Notify then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Evo V3",
                Text = "A staff member is in your game\nName: " .. plr.Name .. "\nID: " .. plr.UserId
            })
        end
    end
end

nadetpmodes.Closest = function()
    local retpart, dist = nil, math.huge
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local v = plrs[i]
        if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
            local character = chartable[v]
            if character and character.Parent == workspace.Characters and character:FindFirstChild("Health") and character.Health.Value > 0 and not character.Root.ShieldEmitter.Enabled then
                local part = character:FindFirstChild("Root")
                if part then
                    local mag = (part.Position - cam.CFrame.Position).Magnitude
                    if mag < dist then
                        retpart, dist = part, mag
                    end
                end
            end
        end
    end
    return retpart
end

nadetpmodes["Most Health"] = function()
    local retpart, value = nil, 0
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local v = plrs[i]
        if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
            local character = chartable[v]
            if character and character.Parent == workspace.Characters and character:FindFirstChild("Health") and character.Health.Value > 0 then
                local part = character:FindFirstChild("Root")
                if part and character.Root.ShieldEmitter.Enabled == false then
                    local health = character.Health.Value
                    if health > value then
                        retpart, value = part, health
                    end
                end
            end
        end
    end
    return retpart
end

nadetpmodes["Least Health"] = function()
    local retpart, value = nil, math.huge
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local v = plrs[i]
        if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
            local character = chartable[v]
            if character and character.Parent == workspace.Characters and character:FindFirstChild("Health") and character.Health.Value > 0 then
                local part = character:FindFirstChild("Root")
                if part and character.Root.ShieldEmitter.Enabled == false then
                    local health = character.Health.Value
                    if health < value then
                        retpart, value = part, health
                    end
                end
            end
        end
    end
    return retpart
end

--[[ Setup ]]--

function espgroup:getplayerfromcharacter(model)
    for i, v in next, chartable do
        if v == model.Parent then
            return i
        end
    end
end

function espgroup:isenemy(inst)
    return not shell.Teams:ArePlayersFriendly(player, inst.player)
end

function espgroup:gethealth(inst)
    local model = inst.model.Parent
    if not (model and model:FindFirstChild("Health")) then
        return 0
    end
    return math.floor((model.Health.Value / model.Health.MaxHealth.Value) * 100) / 100
end

do
    local clockidx = evov3.utils:tablefind(getconstants(controlfunc), 90)
    if clockidx then
        setconstant(controlfunc, clockidx, math.huge)
    end

    local hitboxconn = getconnections(workspace.Characters.ChildAdded)[1].Function
    local rawlist, codelist = getupvalue(hitboxconn, 5), getupvalue(hitboxconn, 6)
    for i = 1, #rawlist do
        codenames[rawlist[i]] = codelist[i]
    end

    local chars = workspace.Characters:GetChildren()
    for i = 1, #chars do
        local v = chars[i]
        task.spawn(function()
            local plr = getplayer(v)
            if plr ~= player and v:FindFirstChild("Hitbox") then
                v.Hitbox.PrimaryPart = v.Hitbox:WaitForChild(codenames.Hips)
                espgroup:add(v.Hitbox, { name = plr.Name, colour = shell.Teams.Colors[shell.Teams:GetPlayerTeam(plr)], map = evov3.esp:createmap(v.Body, { Root = true }) })
            end
        end)
    end

    local challengeitems = challenges:GetChildren()
    for i = 1, #challengeitems do
        local v = challengeitems[i]
        if v:FindFirstChild("PointsLabel") and v.PointsLabel.Text:lower() ~= "completed" then
            v.PointsLabel:GetPropertyChangedSignal("Text"):Connect(function()
                if library.flags.autoclaim and v.PointsLabel.Text:lower() == "completed" then
                    firesignal(v.ClaimButton.MouseButton1Click)
                end
            end)
        end
    end

    local skins = datafolder.Skins:GetChildren()
    for i = 1, #skins do
        skindata[skins[i].Name] = true
    end

    local charms = datafolder.Charms:GetChildren()
    for i = 1, #charms do
        charmdata[charms[i].Name] = true
    end

    local stickers = datafolder.Stickers:GetChildren()
    for i = 1, #stickers do
        stickerdata[stickers[i].Name] = true
    end

    local categories = replicatedstorage.Items.Base:GetChildren()
    for i = 1, #categories do
        local items = categories[i]:GetChildren()
        for i2 = 1, #items do
            local v = items[i2]
            if v:FindFirstChild("Config") then
                weapondata[v.Name] = evov3.utils:deepclone(require(v.Config))
            end
        end
    end

    local bodyparts = game:GetService("StarterPlayer").StarterCharacter.Body:GetChildren()
    for i = 1, #bodyparts do
        local v = bodyparts[i]
        local size = v.Size + Vector3.new(0.6, ((v.Name == "Chest" or v.Name == "Hips") and 0 or 0.6), 0.6)
        charsizes[v.Name], charsizes[codenames[v.Name]] = size, size
    end

    local effecttypes = { "Flashbang", "Smoke", "Quicklime" }
    for i = 1, #effecttypes do
        local v = effecttypes[i]
        if effectsfolder:FindFirstChild(v) and not effectstable[v] then
            effectstable[v] = require(effectsfolder[v])
        end
    end
end

flash, smoke, quicklime = effectstable.Flashbang, effectstable.Smoke, effectstable.Quicklime

--[[ GUI ]]--

local aimassistcat = library:addcategory({ content = "Aim Assist" })
local aimbottab = aimassistcat:addtab({ content = "Aimbot" })

local aimbot = aimbottab:addsection({ content = "Main" })
aimbot:addtoggle({ content = "Enabled", flag = "aimbotenabled" })
aimbot:addbind({ content = "Aim Key", default = "MouseButton2", flag = "aimkey" })
aimbot:addtoggle({ content = "Ignore Aim Key", flag = "ignorekey" })
aimbot:addtoggle({ content = "Wall Check", flag = "aimbotwallcheck" })
aimbot:addtogglepicker({ content = "Highlight Target", flag = "aimbothighlight", default = Color3.fromRGB(230, 33, 237), onstatechanged = function(state)
    if highlighted.aimbot and chartable[highlighted.aimbot] and not state then
        espgroup:highlight(chartable[highlighted.aimbot].Hitbox, espgroup.settings.usecustomcolours and espgroup.settings.enemycolour or shell.Teams.Colors[shell.Teams:GetPlayerTeam(highlighted.aimbot)])
        highlighted.aimbot = nil
    end
end, oncolourchanged = function(colour)
    uicolours.aimbothighlight = colour
    if highlighted.aimbot and chartable[highlighted.aimbot] then
        espgroup:highlight(chartable[highlighted.aimbot].Hitbox, colour)
    end
end })
aimbot:adddropdown({ content = "Aim Part", items = { "Abdomen", "Head", "Closest Part" }, flag = "aimbotaimpart", default = "Abdomen" })

local aimbotprecision = aimbottab:addsection({ content = "Precision" })
aimbotprecision:addtoggle({ content = "Movement Prediction", flag = "predictmove" })
aimbotprecision:addtoggle({ content = "Drop Compensation", flag = "compensatedrop" })
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

local hitboxes = aimbottab:addsection({ content = "Hitbox Expander", right = true })
hitboxes:addtoggle({ content = "Enabled", flag = "hitboxenabled", callback = function(state)
    local chars = workspace.Characters:GetChildren()
    for i = 1, #chars do
        local v = chars[i]
        if not shell.Teams:ArePlayersFriendly(player, getplayer(v)) then
            for _, part in next, v.Hitbox:GetChildren() do
                part.Size = state and charsizes[part.Name] * library.flags.hitboxmult or charsizes[part.Name]
            end
        end
    end
end })
hitboxes:addtoggle({ content = "Visible", flag = "hitboxvisible", callback = function(state)
    local chars = workspace.Characters:GetChildren()
    for i = 1, #chars do
        local v = chars[i]
        if not shell.Teams:ArePlayersFriendly(player, getplayer(v)) then
            for _, part in next, v.Hitbox:GetChildren() do
                part.Transparency = state and 0.5 or 1
            end
        end
    end
end })
hitboxes:addslider({ content = "Multiplier", min = 1, max = 10, float = 0.1, flag = "hitboxmult", callback = function(value)
    if library.flags.hitboxenabled then
        local chars = workspace.Characters:GetChildren()
        for i = 1, #chars do
            local v = chars[i]
            if not shell.Teams:ArePlayersFriendly(player, getplayer(v)) then
                for _, part in next, v.Hitbox:GetChildren() do
                    part.Size = charsizes[part.Name] * value
                end
            end
        end
    end
end })

local silentaimtab = aimassistcat:addtab({ content = "Silent Aim" })
local silentaim = silentaimtab:addsection({ content = "Main" })
silentaim:addtoggle({ content = "Enabled", flag = "silentaimenabled" })
silentaim:addtoggle({ content = "On Screen Check", flag = "silentaimscreencheck" })
silentaim:addtoggle({ content = "Wall Check", flag = "silentaimwallcheck" })
silentaim:addslider({ content = "Hit Chance", flag = "hitchance", default = 100 })
silentaim:addslider({ content = "Headshot Chance", flag = "headshotchance" })
silentaim:addtogglepicker({ content = "Highlight Target", flag = "silentaimhighlight", default = Color3.fromRGB(45, 180, 45), onstatechanged = function(state)
    if highlighted.silentaim and chartable[highlighted.silentaim] and not state then
        espgroup:highlight(chartable[highlighted.silentaim].Hitbox, espgroup.settings.usecustomcolours and espgroup.settings.enemycolour or shell.Teams.Colors[shell.Teams:GetPlayerTeam(highlighted.silentaim)])
        highlighted.silentaim = nil
    end
end, oncolourchanged = function(colour)
    uicolours.silentaimhighlight = colour
    if highlighted.silentaim and chartable[highlighted.silentaim] then
        espgroup:highlight(chartable[highlighted.silentaim].Hitbox, colour)
    end
end })
silentaim:adddropdown({ content = "Aim Part", items = { "Abdomen", "Head", "Closest Part" }, flag = "silentaimaimpart", default = "Abdomen" })

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
autofire:addtoggle({ content = "Interrupt Reload", flag = "interruptreload" })

local visualscat = library:addcategory({ content = "Visuals" })
local esptab = visualscat:addtab({ content = "ESP" })

local espmain = esptab:addsection({ content = "Main" })
espmain:addtoggle({ content = "Master Switch", flag = "espenabled", callback = function(state)
    espgroup.settings.enabled = state
end })
espmain:addtoggle({ content = "Show Names", flag = "espnames", callback = function(state)
    espgroup.settings.names = state
end })
espmain:addtoggle({ content = "Show Boxes", flag = "espboxes", callback = function(state)
    espgroup.settings.boxes = state
end })
espmain:addtoggle({ content = "Show Skeletons", flag = "espskeletons", callback = function(state)
    espgroup.settings.skeletons = state
end })
espmain:addtoggle({ content = "Show Health Bars", flag = "espbars", callback = function(state)
    espgroup.settings.bars = state
end })
espmain:addtoggle({ content = "Show Distances", flag = "espdistances", callback = function(state)
    espgroup.settings.distances = state
end })
espmain:addtoggle({ content = "Show Equipped", flag = "espequipped", callback = function(state)
    espgroup.settings.equipped = state
end })
espmain:addtoggle({ content = "Show Tracers", flag = "esptracers", callback = function(state)
    espgroup.settings.tracers = state
end })
espmain:addtoggle({ content = "Show Offscreen Arrows", flag = "esparrows", callback = function(state)
    espgroup.settings.offscreenarrows = state
end })

local espsettings = esptab:addsection({ content = "Settings", right = true })
espsettings:addtoggle({ content = "Show Teammates", flag = "espteam", callback = function(state)
    espgroup.settings.teammates = state
end })
espsettings:addtoggle({ content = "Use Display Names", flag = "espdisplay", callback = function(state)
    espgroup:updatenames(state)
end })
espsettings:addslider({ content = "Thickness", min = 1, max = 10, default = 1, flag = "espthickness", callback = function(value)
    espgroup:updatethickness(value)
end })
espsettings:addslider({ content = "Text Size", min = 8, max = 32, default = 14, flag = "espsize", callback = function(value)
    espgroup:updatetextsize(value)
end })

if Drawing.Fonts then
    espsettings:adddropdown({ content = "Font", flag = "espfont", items = evov3.utils:keytoarray(Drawing.Fonts), default = "System", callback = function(value)
        espgroup:updatefont(Drawing.Fonts[value])
    end })
end

local esparrows = esptab:addsection({ content = "Arrows", right = true })
esparrows:addslider({ content = "Arrow Height", min = 1, max = 50, default = 18, flag = "arrowheight", callback = function(value)
    espgroup.settings.arrowheight = value
end })
esparrows:addslider({ content = "Arrow Width", min = 8, max = 50, default = 12, flag = "arrowwidth", callback = function(value)
    espgroup.settings.arrowwidth = value
end })
esparrows:addslider({ content = "Arrow Center Offset", min = 0, max = 250, default = 120, flag = "arrowoffset", callback = function(value)
    espgroup.settings.arrowoffset = value
end })

local espcolours = esptab:addsection({ content = "Colours" })
espcolours:addtoggle({ content = "Custom Colours", flag = "espcolours", callback = function(state)
    espgroup:togglecustomcolours(state)
end })
espcolours:addpicker({ content = "Friendly Colour", flag = "espfriendlycolour", default = espgroup.settings.friendlycolour, callback = function(colour)
    espgroup:updatecustomcolour(colour, true)
end })
espcolours:addpicker({ content = "Enemy Colour", flag = "espenemycolour", default = espgroup.settings.enemycolour, callback = function(colour)
    espgroup:updatecustomcolour(colour, false)
end })

local visualcosmeticstab = visualscat:addtab({ content = "Cosmetics" })

local impactpoints = visualcosmeticstab:addsection({ content = "Impact Points" })
impactpoints:addtogglepicker({ content = "Enabled", flag = "impacts", default = Color3.new(1, 0, 0), onstatechanged = function(state)
    local effectitems = workspace.Effects:GetChildren()
    for i = 1, #effectitems do
        local v = effectitems[i]
        if v.Name == "BulletHole" then
            v.Material = state and Enum.Material.Neon or Enum.Material.SmoothPlastic
            v.Transparency = state and 0 or 1
        end
    end
end, oncolourchanged = function(colour)
    uicolours.impactcolour = colour
    local effectitems = workspace.Effects:GetChildren()
    for i = 1, #effectitems do
        local v = effectitems[i]
        if v.Name == "BulletHole" then
            v.Color = colour
        end
    end
end })

local radarmods = visualcosmeticstab:addsection({ content = "Radar", right = true })
radarmods:addtoggle({ content = "Always Radar Enemies", flag = "alwaysradar", callback = function(state)
    if state then
        maids.radar:givetask(runservice.Stepped:Connect(function()
            local plrs = players:GetPlayers()
            for i = 1, #plrs do
                local v = plrs[i]
                if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
                    local character = chartable[v]
                    if character and character.Parent == workspace.Characters and character:FindFirstChild("Root") then
                        shell.UI.Events.RadarEnemy:Fire(v, character.Root.Position)
                    end
                end
            end
        end))
    else
        maids.radar:dispose()
    end
end })
radarmods:addtoggle({ content = "Cleanup Radar", flag = "cleanupradar" })
radarmods:addtoggle({ content = "Radar Silenced Guns", flag = "radarsilenced" })

local xray = visualcosmeticstab:addsection({ content = "X-Ray" })
xray:addtoggleslider({ content = "Enabled", max = 1, float = 0.01, default = 0.75, flag = "xray", onstatechanged = function(state)
    local geometry = workspace.Geometry:GetDescendants()
    for i = 1, #geometry do
        local v = geometry[i]
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = state and library.flags.xray.value or 0
        end
    end
end, onvaluechanged = function(value)
    if library.flags.xray.enabled then
        local geometry = workspace.Geometry:GetDescendants()
        for i = 1, #geometry do
            local v = geometry[i]
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = value
            end
        end
    end
end })

local gunmods = library:addcategory({ content = "Weapons" })
local gunmodstab = gunmods:addtab({ content = "Guns" })

local gununlocks = gunmodstab:addsection({ content = "Unlocks" })
gununlocks:addtoggle({ content = "Unlock All Skins", flag = "unlockskins", callback = function(state)
    if state then
        local skins = skinfolder:GetDescendants()
        for i = 1, #skins do
            local v = skins[i]
            if v.ClassName == "ModuleScript" and not skindata[v.Name] then
                local f = Instance.new("Folder")
                f.Name = v.Name
                f.Parent = datafolder.Skins
            end
        end
    else
        local skins = datafolder.Skins:GetChildren()
        for i = 1, #skins do
            local v = skins[i]
            if not skindata[v.Name] then
                v:Destroy()
            end
        end
    end
end })
gununlocks:addtoggle({ content = "Unlock All Charms", flag = "unlockcharms", callback = function(state)
    if state then
        local charms = charmfolder:GetDescendants()
        for i = 1, #charms do
            local v = charms[i]
            if v.ClassName == "Model" and not charmdata[v.Name] then
                local f = Instance.new("Folder")
                f.Name = v.Name
                f.Parent = datafolder.Charms
            end
        end
    else
        local charms = datafolder.Charms:GetChildren()
        for i = 1, #charms do
            local v = charms[i]
            if not charmdata[v.Name] then
                v:Destroy()
            end
        end
    end
end })
gununlocks:addtoggle({ content = "Unlock All Stickers", flag = "unlockstickers", callback = function(state)
    if state then
        local stickers = stickerfolder:GetDescendants()
        for i = 1, #stickers do
            local v = stickers[i]
            if v.ClassName == "ModuleScript" and not stickerdata[v.Name] then
                local f = Instance.new("Folder")
                f.Name = v.Name
                f.Parent = datafolder.Stickers
            end
        end
    else
        local stickers = datafolder.Stickers:GetChildren()
        for i = 1, #stickers do
            local v = stickers[i]
            if not stickerdata[v.Name] then
                v:Destroy()
            end
        end
    end
end })

local rapidfire = gunmodstab:addsection({ content = "Rapid Fire" })
rapidfire:addtoggle({ content = "Enabled", flag = "rapidfire" })
rapidfire:addtoggle({ content = "Add To Default Rate", flag = "firerateadditive" })
rapidfire:addslider({ content = "Value", max = 1800, flag = "firerate" })

local recoil = gunmodstab:addsection({ content = "Recoil" })
recoil:addslider({ content = "Horizontal Reduction", flag = "recoilx" })
recoil:addslider({ content = "Vertical Reduction", flag = "recoily" })

local gunsother = gunmodstab:addsection({ content = "Other", right = true })
gunsother:addtoggle({ content = "Always Headshot", flag = "alwaysheadshot", callback = function(state)
    local hitmarkers = hitmarker:GetChildren()
    for i = 1, #hitmarkers do
        hitmarkers[i].BackgroundColor3 = state and Color3.fromRGB(255, 14, 14) or Color3.new(1, 1, 1)
    end
    setconstant(hitmarkfunc, hitidx, state and 2 or 1.5)
end })
gunsother:addtoggle({ content = "Full Automatic", flag = "fullauto", callback = function(state)
    for i = 1, #gunconfigs do
        local config = gunconfigs[i]
        config.FireModes = state and {
            Auto = { FireRate = config.FireModes[config.FireModeList[1]].FireRate }
        } or weapondata[config.Model].FireModes
        config.FireModeList = state and { "Auto" } or weapondata[config.Model].FireModeList
    end
end })
gunsother:addtoggle({ content = "Auto Reload", flag = "autoreload" })
gunsother:addtoggle({ content = "No Spread", flag = "nospread" })
gunsother:addtoggle({ content = "No Bullet Drop", flag = "nodrop", callback = function(state)
    for i, v in next, guntypestats do
        v.Gravity = state and 0 or clonedtypestats[i].Gravity
    end
end })
gunsother:addtoggle({ content = "No Camera Shake", flag = "nocamshake" })
gunsother:addtoggle({ content = "No Gun Bob", flag = "nogunbob", callback = function(state)
    setconstant(firstperson, bobidx, state and 0 or 0.3)
end })
gunsother:addtoggle({ content = "Wallbang", flag = "wallbang", callback = function(state)
    setupvalue(shell.Raycast.CastGeometryAndEnemies, 1, not state and workspace.Geometry or nil)
    setupvalue(shell.Raycast.CastGeometryAndEnemies, 2, not state and workspace.Terrain or nil)
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Evo V3",
            Text = "Note: Shots will not deal damage if you shoot through too many walls"
        })
    end
end })

local guncosmetics = gunmodstab:addsection({ content = "Cosmetics", right = true })
guncosmetics:addtogglepicker({ content = "Weapon Colour", flag = "guncolour", default = Color3.new(1, 0, 0), onstatechanged = function(state)
    if state and currentgun then
        local bodyparts = currentgun.Body:GetDescendants()
        for i = 1, #bodyparts do
            local v = bodyparts[i]
            if v:IsA("BasePart") then
                v.Color = uicolours.guncolour
            end
        end
    end
end, oncolourchanged = function(colour)
    uicolours.guncolour = colour
    if library.flags.guncolour.enabled and currentgun then
        local bodyparts = currentgun.Body:GetDescendants()
        for i = 1, #bodyparts do
            local v = bodyparts[i]
            if v:IsA("BasePart") then
                v.Color = colour
            end
        end
    end
end })
guncosmetics:addtoggledropdown({ content = "Weapon Material", flag = "gunmat", items = evov3.utils:valuetoarray(Enum.Material:GetEnumItems()), default = "ForceField", onstatechanged = function(state)
    if currentgun then
        local bodyparts = currentgun.Body:GetDescendants()
        for i = 1, #bodyparts do
            local v = bodyparts[i]
            if v:IsA("BasePart") then
                v.Material = Enum.Material[state and library.flags.gunmat.selected or "SmoothPlastic"]
            end
        end
    end
end, onvaluechanged = function(selected)
    if library.flags.gunmat.enabled and currentgun then
        local mat = Enum.Material[selected]
        local bodyparts = currentgun.Body:GetDescendants()
        for i = 1, #bodyparts do
            local v = bodyparts[i]
            if v:IsA("BasePart") then
                v.Material = mat
            end
        end
    end
end })

local itemmodstab = gunmods:addtab({ content = "Items" })

local nademods = itemmodstab:addsection({ content = "Grenades" })
nademods:addtoggle({ content = "Teleport Grenades", flag = "tpnades" })
nademods:addtoggle({ content = "Sticky Grenades", flag = "stickynades" })
nademods:adddropdown({ content = "Targeting Mode", flag = "nadetpmode", items = { "Closest", "Most Health", "Least Health" }, default = "Closest" })

local immunity = itemmodstab:addsection({ content = "Immunity" })
immunity:addtoggle({ content = "Anti Flashbang", flag = "noflashbang" })
immunity:addtoggle({ content = "Anti Smoke", flag = "nosmoke" })
immunity:addtoggle({ content = "Anti Quicklime", flag = "noquicklime" })

local knifeaura = itemmodstab:addsection({ content = "Knife Aura", right = true })
knifeaura:addtoggle({ content = "Enabled", flag = "knifeauraenabled", callback = function(state)
    if state then
        maids.knifeaura:givetask(runservice.Heartbeat:Connect(function()
            if char and char.Backpack.Equipped.Value and isknifing == false then
                local knifetarget
                local plrs = players:GetPlayers()
                for i = 1, #plrs do
                    local v = plrs[i]
                    if v ~= player and not shell.Teams:ArePlayersFriendly(player, v) then
                        local character = chartable[v]
                        if character and character.Parent == workspace.Characters and character:FindFirstChild("Health") and character.Health.Value > 0 then
                            local part = character:FindFirstChild("Root")
                            local partpos = part.Position
                            if part and part.ShieldEmitter.Enabled == false and (library.flags.knifescreencheck == false or select(2, cam:WorldToViewportPoint(partpos))) and (library.flags.knifewallcheck == false or select(1, workspace:FindPartOnRayWithWhitelist(Ray.new(root.Position, partpos - root.Position), { workspace.Geometry, workspace.Terrain }, true)) == nil) then
                                if (partpos - root.Position).Magnitude <= library.flags.knifeaurarange then
                                    knifetarget = character
                                    break
                                end
                            end
                        end
                    end
                end
                if knifetarget then
                    local equipped, targetpart = getequipped(), knifetarget.Hitbox[codenames.Head]
                    if equipped and (equipped == "Melee" or not library.flags.requireknife) then
                        isknifing = true
                        local currconf, knifeconf = weapondata[char.Backpack.Equipped.Value.Name].Handling, weapondata[char.Backpack.Melee.Value.Name]
                        if equipped ~= "Melee" then
                            automateinput("Melee")
                            task.wait((currconf.UnequipTime / currconf.Speed) + (knifeconf.Handling.EquipTime / knifeconf.Handling.Speed))
                        end
                        for i = 1, library.flags.instantkill and math.ceil(knifetarget.Health.Value / 75) or 1 do
                            netfire(shell.Network, "Item_Melee", "StabBegin", char.Backpack.Items[char.Backpack.Melee.Value.Name])
                            netfire(shell.Network, "Item_Melee", "Stab", char.Backpack.Items[char.Backpack.Melee.Value.Name], targetpart, targetpart.Position, Vector3.new())
                            task.wait(equipped == "Melee" and library.flags.instantkill == false and (knifeconf.Melee.Delay + knifeconf.Melee.Time + 1 / knifeconf.Melee.Speed) or 0)
                        end
                        if equipped ~= "Melee" then
                            automateinput(equipped)
                            task.wait((knifeconf.Handling.UnequipTime / knifeconf.Handling.Speed) + (currconf.EquipTime / currconf.Speed))
                        end
                        isknifing = false
                    end
                end
            end
        end))
    else
        maids.knifeaura:dispose()
    end
end })
knifeaura:addtoggle({ content = "On Screen Check", flag = "knifescreencheck" })
knifeaura:addtoggle({ content = "Wall Check", flag = "knifewallcheck" })
knifeaura:addtoggle({ content = "Instant Kill", flag = "instantkill" })
knifeaura:addtoggle({ content = "Require Knife Equipped", flag = "requireknife" })
knifeaura:addslider({ content = "Range", max = 20, default = 20, float = 0.1, flag = "knifeaurarange" })

local playercat = library:addcategory({ content = "Players" })
local playertab = playercat:addtab({ content = "Local Player" })

local charvalues = playertab:addsection({ content = "Values" })
charvalues:addtoggleslider({ content = "Sprint Speed", min = 40, max = 140, flag = "sprintspeed", onstatechanged = function(state)
    setconstant(controlfunc, speedidx, state and library.flags.sprintspeed.value / 22 or 1.8)
end, onvaluechanged = function(value)
    if library.flags.sprintspeed.enabled then
        setconstant(controlfunc, speedidx, value / 22)
    end
end })
charvalues:addtoggleslider({ content = "JumpPower", min = 36, max = 140, flag = "jumppower" })

local charmods = playertab:addsection({ content = "Modifications", right = true })
charmods:addtoggle({ content = "Auto Sprint", flag = "autosprint", callback = function(state)
    shell.Input[state and "AutomateBegan" or "AutomateEnded"](shell.Input, "Sprint")
end })
charmods:addtoggle({ content = "No Clip", flag = "noclip", callback = function(state)
    if state then
        maids.noclip:givetask(runservice.Stepped:Connect(function()
            if root then
                root.CanCollide = false
            end
        end))
    else
        maids.noclip:dispose()
        if root and not root.CanCollide then
            root.CanCollide = true
        end
    end
end })
charmods:addbind({ content = "Bunny Hop", flag = "bhop", onkeydown = function()
    isbhopping = not isbhopping
    if isbhopping and char and char.State.Grounded.Value then
        shell.Input:AutomateBegan("Jump")
    end
end, onchanged = function(key)
    if key == "None" then
        isbhopping = false
    end
end })
charmods:addbind({ content = "Fly", flag = "fly", onkeydown = function()
	isflying = not isflying
	if isflying then
        maids.fly:givetask(runservice.RenderStepped:Connect(function()
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
end, onchanged = function(key)
    if key == "None" and isflying then
        library.items.fly.options.onkeydown()
    end
end })
charmods:addslider({ content = "Fly Speed", min = 22, max = 140, default = 140, flag = "flyspeed" })

local stancemods = playertab:addsection({ content = "Stances" })
stancemods:addtoggledropdown({ content = "Fake Stance", flag = "fakestance", items = { "Stand", "Crouch", "Prone" }, default = "Prone", onstatechanged = function(state)
    if root and state then
        netfire(shell.Network, "Character", "State", "Stance", library.flags.fakestance.selected)
    end
end, onvaluechanged = function(selected)
    if root and library.flags.fakestance.enabled then
        netfire(shell.Network, "Character", "State", "Stance", selected)
    end
end })

local guimods = playertab:addsection({ content = "Gui Mods", right = true })
guimods:addtoggle({ content = "Auto Claim Challenges", flag = "autoclaim", callback = function(state)
    if state then
        local challengeitems = challenges:GetChildren()
        for i = 1, #challengeitems do
            local v = challengeitems[i]
            if v:FindFirstChild("PointsLabel") and v.PointsLabel.Text:lower() == "completed" then
                firesignal(v.ClaimButton.MouseButton1Click)
            end
        end
    end
end })
guimods:addbutton({ content = "Redeem All Codes", callback = function()
    local page = game:HttpGetAsync("https://roblox-bad-business.fandom.com/wiki/Codes")
    for word in page:gmatch("<td>([%w\n_]*)</td>") do
        shell.Network:Invoke("Codes", "Redeem", word:gsub("\n", ""))
        task.wait(0.25)
    end
end })

local admincheck = playertab:addsection({ content = "Admins" })
admincheck:addchecklist({ content = "Staff Join Actions", flag = "onstaffjoin", items = { { "Kick" }, { "Notify" } }, callback = function(value, state)
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local v = plrs[i]
        if v ~= player then
            checkadmin(v)
        end
    end
end })

--[[ Hooks ]]--

local editedtables = {}

for i, v in next, getupvalue(getmetatable(shell).__index, 1) do
    if table.isfrozen(v) then
        table.insert(editedtables, v)
        setreadonly(v, false)
    end
end

shell.Network.Fire = newcclosure(LPH_JIT_ULTRA(function(self, ...)
    local args = {...}
    if args[2] == "OnError" then
        return
    elseif args[3] == "Stance" and library.flags.fakestance.enabled then
        args[4] = library.flags.fakestance.selected
    elseif args[2] == "__Hit" and (library.flags.alwaysheadshot or (library.flags.silentaimenabled and math.random(1, 100) <= library.flags.headshotchance)) and args[5]:IsDescendantOf(workspace.Characters) then
        args[5] = args[5].Parent:FindFirstChild(codenames.Head) or args[5]
    elseif args[2] == "EquipSkin" and library.flags.unlockskins and not skindata[args[4]] then
	    datafolder.Weapons[args[3]].Customization.Skin.Value = args[4]
		return
    elseif args[2] == "EquipCharm" and library.flags.unlockcharms and not charmdata[args[4]] then
	    datafolder.Weapons[args[3]].Customization.Charm.Value = args[4]
		return
    elseif args[2] == "EquipSticker" and library.flags.unlockstickers and not stickerdata[args[5]] then
	    datafolder.Weapons[args[3]].Customization["Sticker" .. args[4]].Value = args[5]
		return
    elseif args[2] == "Shoot" then
        local target = silentaimtarget
        if target and library.flags.silentaimenabled and math.random(1, 100) <= library.flags.hitchance then
            local vec, data = target.pos - target.start, weapondata[args[3].Name]
            local bullets = evov3.utils:deepclone(args[5])
            for i = 1, #bullets do
                bullets[i][1] = vec.Unit
            end
            netfire(self, args[1], args[2], args[3], target.start, bullets)
            table.clear(args[5])
            task.delay(vec.Magnitude / guntypestats[data.Controller].Speed, function()
                for i = 1, #bullets do
                    netfire(self, "Projectiles", "__Hit", bullets[i][2], target.pos, target.part)
                end
                if select(2, cam:WorldToViewportPoint(target.pos)) then
                    shell.UI.Events.Hitmarker:Fire(target.part, target.pos, data.Projectile.Amount and data.Projectile.Amount > 3)
                end
            end)
            return
        end
    elseif type(args[3]) == "string" then
        local arg = string.lower(args[3])
        for i = 1, #blacklistedargs do
            local v = blacklistedargs[i]
            if string.find(arg, v) then
                return wait(9e9)
            end
        end
    end
    return netfire(self, unpack(args))
end))

shell.Camera.Recoil.Fire = newcclosure(function(self, vec, ...)
    return recoilfire(self, Vector2.new(vec.X * (1 - library.flags.recoilx / 100), vec.Y * (1 - library.flags.recoily / 100)), ...)
end)
setupvalue(shell.Camera.Recoil.Update, 2, shell.Camera.Recoil.Fire)

shell.Input.Reticle.LookVector = newcclosure(function(self, ...)
    return library.flags.nospread and cam.CFrame.LookVector or lookvector(self, ...)
end)
setupvalue(lookvector, 1, shell.Input.Reticle.LookVector)

shell.Timer.Wait = function(self, dur, ...) -- newcclosure doesn't yield on anything but proto :(
    if library.flags.rapidfire and string.find(debug.traceback(), "Paintball") then
        return timerwait(self, library.flags.firerateadditive and 60 / ((60 / dur) + library.flags.firerate) or 60 / library.flags.firerate)
    end
    return timerwait(self, dur, ...)
end

shell.Items.FirstPerson.CameraSpring.Shove = newcclosure(function(...)
    if library.flags.nocamshake then
        return
    end
    return camshove(...)
end)

shell.Skins.Paint = newcclosure(function(self, ...)
	local args = {...}
	if library.flags.unlockskins and string.find(debug.traceback(), "ItemAnimateScript") and datafolder.Weapons:FindFirstChild(args[1].Name) then
		args[2] = datafolder.Weapons[args[1].Name].Customization.Skin.Value
	end
	return paint(self, unpack(args))
end)

shell.Charms.Attach = newcclosure(function(self, ...)
	local args = {...}
	if string.find(debug.traceback(), "ItemAnimateScript") and datafolder.Weapons:FindFirstChild(args[1].Name) then
		args[2] = datafolder.Weapons[args[1].Name].Customization.Charm.Value
	end
	return attach(self, unpack(args))
end)

shell.Stickers.Apply = newcclosure(function(self, ...)
	local args = {...}
	if string.find(debug.traceback(), "ItemAnimateScript") and datafolder.Weapons:FindFirstChild(args[1].Name) then
		args[2] = datafolder.Weapons[args[1].Name].Customization["Sticker" .. args[3]].Value
	end
	return apply(self, unpack(args))
end)

shell.Items.GetConfig = function(self, ...) -- newcclosure doesn't yield on anything but proto :(
    local config = getconfig(self, ...)
    local trace = debug.traceback()
    if string.find(trace, "Paintball") then
        table.insert(gunconfigs, config)
        if library.flags.fullauto then
            config.FireModes = {
                Auto = { FireRate = config.FireModes[config.FireModeList[1]].FireRate }
            }
            config.FireModeList = { "Auto" }
        end
    elseif library.flags.radarsilenced and config.Projectile and config.Projectile.Silenced and string.find(trace, "ItemReplicatorScript") then
        config.Projectile.Silenced = false
    end
    return config
end

effectstable.Flashbang = newcclosure(function(...)
    if library.flags.noflashbang then
        return
    end
    task.spawn(flash, ...)
end)

effectstable.Smoke = newcclosure(function(...)
    if library.flags.nosmoke then
        return
    end
    task.spawn(smoke, ...)
end)

effectstable.Quicklime = newcclosure(function(...)
    if library.flags.noquicklime then
        return
    end
    task.spawn(quicklime, ...)
end)

for i = 1, #editedtables do
    setreadonly(editedtables[i], true)
end

--[[ Connections ]]--

players.PlayerAdded:Connect(checkadmin)

mouse.Move:Connect(function()
    local loc = userinputservice:GetMouseLocation()
    aimbotfovcircle.Position = loc
    silentaimfovcircle.Position = loc
end)

workspace.ChildAdded:Connect(function(child)
    if child:FindFirstChild("AnimationController") then
        registergun(child)
    end
end)

workspace.Effects.ChildAdded:Connect(function(child)
    if child.Name == "BulletHole" then
        child.Color = uicolours.impactcolour
        if library.flags.impacts.enabled then
            child.Material = Enum.Material.Neon
            child.Transparency = 0
        end
    end
end)

workspace.Characters.ChildAdded:Connect(function(child)
    local plr = getplayer(child)
    if plr == player then
        registerchar(child)
    else
        child:WaitForChild("Hitbox").PrimaryPart = child.Hitbox:WaitForChild(codenames.Hips)
        espgroup:add(child.Hitbox, { name = plr.Name, colour = shell.Teams.Colors[shell.Teams:GetPlayerTeam(plr)], map = evov3.esp:createmap(child.Body, { Root = true }) })
        if not shell.Teams:ArePlayersFriendly(player, plr) then
            for _, part in next, child.Hitbox:GetChildren() do
                local size = charsizes[part.Name]
                part.Size = library.flags.hitboxenabled and size * library.flags.hitboxmult or size
                part.Transparency = library.flags.hitboxvisible and 0.5 or 1
            end
        end
    end
end)

workspace.Characters.ChildRemoved:Connect(function(child)
    if library.flags.cleanupradar then
        local radar = radars[shell.Characters:GetPlayerFromCharacter(child)]
        if radar then
            radar.Init = 0
        end
    end
end)

workspace.Geometry.DescendantAdded:Connect(function(descendant)
    if library.flags.xray.enabled and descendant:IsA("BasePart") then
        descendant.LocalTransparencyModifier = library.flags.xray.value
    end
end)

workspace.Throwables.ChildAdded:Connect(function(child)
    if child:WaitForChild("Owner").Value == player then
        if library.flags.tpnades then
			local body = child:WaitForChild("Body"):WaitForChild("BodyPrimary")
            repeat
                local nadetarget = nadetpmodes[library.flags.nadetpmode]()
                if nadetarget then
                    body.Position = nadetarget.Position
                end
                task.wait()
            until not (child and child.Parent)
        elseif library.flags.stickynades then
            local body = child:WaitForChild("Body"):WaitForChild("BodyPrimary")
            body.Touched:Wait()
            local stickpos = body.Position
            repeat
                body.Position = stickpos
                runservice.Heartbeat:Wait()
            until not (child and child.Parent)
        end
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

shell.Input.Ended:Connect(function(arg, ...)
    if arg == "Shoot" and library.flags.autoreload then
        shell.Input:AutomateBegan("Reload")
    end
end)

runservice.RenderStepped:Connect(function()
    aimbotfovcircle.Radius = library.flags.aimbotfov.value * (library.flags.aimbotfovdynamic and cam.FieldOfView > 1 and (shell.Camera.FieldOfView / cam.FieldOfView) or 1)
    silentaimfovcircle.Radius = library.flags.silentaimfov.value * (library.flags.silentaimfovdynamic and cam.FieldOfView > 1 and (shell.Camera.FieldOfView / cam.FieldOfView) or 1)
    if char and currentgun then
        if library.flags.aimbotenabled and mouse.Hit and (isaimkeydown or library.flags.ignorekey) then
            local target = getaimbottarget()
            if target then
                local pos = cam:WorldToScreenPoint(getaimbotposition(target))
                local mousepos = cam:WorldToScreenPoint(mouse.Hit.Position)
                local movevec = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousepos.X, mousepos.Y)) / (library.flags.smoothness + 1)
                mousemoverel(movevec.X, movevec.Y)
                if library.flags.aimbothighlight.enabled and target.player ~= highlighted.aimbot then
                    if highlighted.aimbot and chartable[highlighted.aimbot] then
                        espgroup:highlight(chartable[highlighted.aimbot].Hitbox, espgroup.settings.usecustomcolours and espgroup.settings.enemycolour or shell.Teams.Colors[shell.Teams:GetPlayerTeam(highlighted.aimbot)])
                    end
                    highlighted.aimbot = target.player
                    espgroup:highlight(target.part.Parent, uicolours.aimbothighlight)
                end
            elseif highlighted.aimbot and chartable[highlighted.aimbot] then
                espgroup:highlight(chartable[highlighted.aimbot].Hitbox, espgroup.settings.usecustomcolours and espgroup.settings.enemycolour or shell.Teams.Colors[shell.Teams:GetPlayerTeam(highlighted.aimbot)])
                highlighted.aimbot = nil
            end
        end
        if library.flags.silentaimenabled and weapondata[currentgun.Name].Controller ~= "Melee" and not char.State.Swapping.Value then
            silentaimtarget = getsilentaimtarget()
            if silentaimtarget then
                if library.flags.interruptreload or char.Backpack.Items[currentgun.Name].State.Reloading.Value == false then
                    if library.flags.autoshoot and (library.flags.autowall or silentaimtarget.iswallbetween == false) then
                        task.spawn(automateinput, "Shoot")
                    elseif library.flags.triggerbot then
                        local part = workspace:FindPartOnRayWithWhitelist(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { workspace.Terrain, workspace.Geometry, workspace.Characters }, true)
                        if part and part:IsDescendantOf(workspace.Characters) then
                            task.spawn(automateinput, "Shoot")
                        end
                    end
                end
                if library.flags.silentaimhighlight.enabled and silentaimtarget.player ~= highlighted.silentaim then
                    if highlighted.silentaim and chartable[highlighted.silentaim] then
                        espgroup:highlight(chartable[highlighted.silentaim].Hitbox, espgroup.settings.usecustomcolours and espgroup.settings.enemycolour or shell.Teams.Colors[shell.Teams:GetPlayerTeam(highlighted.silentaim)])
                    end
                    highlighted.silentaim = silentaimtarget.player
                    espgroup:highlight(silentaimtarget.part.Parent, uicolours.silentaimhighlight)
                end
            elseif highlighted.silentaim and chartable[highlighted.silentaim] then
                espgroup:highlight(chartable[highlighted.silentaim].Hitbox, espgroup.settings.usecustomcolours and espgroup.settings.enemycolour or shell.Teams.Colors[shell.Teams:GetPlayerTeam(highlighted.silentaim)])
                highlighted.silentaim = nil
            end
        end
    end
end)

--[[ End ]]--

local chars = workspace.Characters:GetChildren() -- both need to be done after flags have been made
for i = 1, #chars do
    local v = chars[i]
    if getplayer(v) == player then
        task.spawn(registerchar, v)
        break
    end
end

local workspaceitems = workspace:GetChildren()
for i = 1, #workspaceitems do
    local v = workspaceitems[i]
    if v:FindFirstChild("AnimationController") then
        task.spawn(registergun, v)
        break
    end
end

library:addsettings()

end

--[[ RoBeats ]]--

local function robeats()

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "RoBeats", version = changelog.version .. " Premium" })

local player = game:GetService("Players").LocalPlayer

local funcnames = {}
local noteholder = {}
local noteresults = {}
local notebounds = {}

local levels = { "perfect", "great", "okay" }
local boundaries = {
    perfect = { 1, 100 }
}
local total = 100

local lastsongkey
local lastcheer = 0

--[[ Garbage Collection ]]--

local notebases = {}
local client, lobby, modes
local webnpcmanager, sputil, gearstats, vipinfo, curveutil, defaultsongkey

do
    local gc = getgc(true)
    for i = 1, #gc do
        local v = gc[i]
        if type(v) == "function" and getinfo(v).name == "get_current_weekid" then
            client = getupvalue(v, 1)
        elseif type(v) == "table" then
			if rawget(v, "color3_for_slot") then
				notebases[#notebases + 1] = v
			elseif rawget(v, "songkey_opt_set_artist_event_info") then
				lobby = v
			elseif rawget(v, "MatchMaking") then
				modes = v
			end
        end
    end

    local modules = getloadedmodules()
    for i, v in next, modules do
        local req = select(2, pcall(require, modules[i]))
        if type(req) == "table" then
            if rawget(req, "hash_creator") then
                sputil = req
            elseif rawget(req, "get_note_time_obj") then
                gearstats = req
            elseif rawget(req, "playerblob_has_vip_for_current_day") then
                vipinfo = req
            elseif rawget(req, "TimescaleToDeltaTime") then
                curveutil = req
            elseif rawget(req, "invalid_songkey") then
                defaultsongkey = req:singleton():name_to_key("MondayNightMonsters1")
            end
        end
    end
end

local eventids = getupvalue(client._evt.server_generate_encodings, 1)
local gamelocal = getupvalue(client._game_join.load_game, 7)
local tracksystem = getupvalue(gamelocal.new, 18)

--[[ Functions ]]--

local function constructboundaries()
    table.clear(boundaries)
    local accum = 0
    for i = 1, #levels do
        local v = levels[i]
        local flag = library.flags[v]
        if flag > 0 then
            boundaries[v] = { accum + 1, accum + flag }
        end
        accum = accum + flag
    end
    total = math.max(accum, 100)
end

local function getwantedresult()
    local rand = math.random(1, total)
    for i, v in next, boundaries do
        if rand >= v[1] and rand <= v[2] then
            return i
        end
    end
    return "miss"
end

local function gethittime(boundary)
    if boundary == "miss" then
        return
    end
    return math.random() * math.random(notebounds[boundary].low, notebounds[boundary].high)
end

local function handlenotes(localgame, system, notes)
    for i = 1, notes:count() do
        local note = notes:get(i)
        local index = note:get_note_index()
        local noteresult = noteholder[index]
        if noteresult == nil then
            noteresult = getwantedresult()
            noteholder[index] = noteresult
        end
        local hitres, hitscore, hittime = note[funcnames.testhit](note, localgame)
        local relres, relscore, reltime = note[funcnames.testrel](note, localgame)
        if not note[funcnames.shouldremove](note, localgame) then
            local track = system[funcnames.gettrack](system, note:get_track_index())
            if hitres and hitscore == noteresults[noteresult] then
                track:press()
                note[funcnames.hit](note, localgame, hitscore, i, library.flags.randomdelta and gethittime(noteresult) or hittime)
                if not reltime then
                    track:release()
                end
            elseif relres and relscore == noteresults[noteresult] then
                track:release()
                note[funcnames.rel](note, localgame, relscore, i, reltime)
            end
        end
    end
end

local function getplayerid()
	local finished, players = false, {}
	client._evt:clear_pending_on(eventids.EVT_Players_ServerQueryPlayerListResponse)
	client._evt:wait_on_event_once(eventids.EVT_Players_ServerQueryPlayerListResponse, function(list)
		for i = 1, #list do
			local v = list[i]
			if v.Activity == modes.Match then
				table.insert(players, v)
			end
		end
		finished = true
	end)
	client._evt:fire_event_to_server(eventids.EVT_Players_ClientQueryPlayerList)
	repeat task.wait() until finished
	if #players > 0 then
		table.sort(players, function(a, b)
			return a.JoinTime > b.JoinTime
		end)
		return players[1].PlayerId
	end
end

--[[ Setup ]]--

local notetimes = gearstats:get_note_time_obj(gearstats:get_imm_statsdict_base())
notebounds.okay = {
    high = notetimes[5],
    low = notetimes[6]
}

notebounds.great = {
    high = notetimes[4],
    low = notetimes[5]
}

notebounds.perfect = {
    high = -0.01,
    low = notetimes[4]
}

for i, v in next, sputil do
    if type(v) == "function" and string.sub(i, 1, 1) == "_" and islclosure(v) then
        local consts = getconstants(v)
        if #consts == 4 and #getupvalues(v) == 1 then
            local results = getupvalue(v, 1)
            noteresults.miss, noteresults.okay = results[consts[1]], results[consts[2]]
            noteresults.great, noteresults.perfect = results[consts[3]], results[consts[4]]
            break
        end
    end
end

for i, v in next, getprotos(tracksystem.new) do
    local consts = getconstants(v)
    if table.find(consts, "TrackSystem:update") then
        funcnames.tracksystemupdate = getinfo(v).name
        funcnames.shouldremove = consts[7]
        funcnames.getslot = consts[11]
    elseif table.find(consts, "NoteIndexNone") then
        funcnames.gettrack = consts[1]
        funcnames.testhit = consts[10]
        funcnames.hit = consts[11]
    elseif table.find(consts, "release") then
        funcnames.testrel = consts[6]
        funcnames.rel = consts[7]
    elseif table.find(consts, "set_note_colors") then
        funcnames.addtotrack = getinfo(v).name
    end
end

for i, v in next, getprotos(gamelocal.new) do
    if getinfo(v).name == "update" then
        funcnames.tracks = getconstant(v, 31)
        break
    end
end

while true do
    if getupvalue(client._lobby_join.setup_lobby, 5) then
        break
    end
    task.wait(1)
end

local webnpcmanager = getupvalue(getupvalue(client._lobby_join.setup_lobby, 1)._npcs.cons, 1)

--[[ GUI ]]--

local songcat = library:addcategory({ content = "Songs" })
local playertab = songcat:addtab({ content = "Auto Player" })

local player = playertab:addsection({ content = "Player" })
player:addtoggle({ content = "Enabled", flag = "autoplayenabled" })
player:addtoggle({ content = "Delta Randomiser", flag = "randomdelta" })
player:addslider({ content = "Perfect", suffix = "%", flag = "perfect", callback = constructboundaries })
player:addslider({ content = "Great", suffix = "%", flag = "great", callback = constructboundaries })
player:addslider({ content = "Okay", suffix = "%", flag = "okay", callback = constructboundaries })

local unlocks = playertab:addsection({ content = "Unlocks", right = true })
unlocks:addtoggle({ content = "Unlock All Songs", flag = "unlockall" })
unlocks:addlabel({ content = "Note: Your score and combo will be bugged" })

local other = playertab:addsection({ content = "Other", right = true })
other:addtoggle({ content = "Block Input", flag = "blockinput" })

local visuals = library:addcategory({ content = "Visuals" })
local visualstab = visuals:addtab({ content = "Visuals" })

local notes = visualstab:addsection({ content = "Notes" })
notes:addchecklist({ content = "Note Colours", flag = "notetracks", items = { { "Track 1" }, { "Track 2" }, { "Track 3" }, { "Track 4" } } })
for i = 1, 4 do
    notes:addpicker({ content = "Track " .. i, flag = "track" .. i })
end

local othercat = library:addcategory({ content = "Other" })
local misctab = othercat:addtab({ content = "Misc" })

local cheers = misctab:addsection({ content = "Cheers" })
cheers:addtoggle({ content = "Auto Cheer", flag = "autocheer", callback = function(state)
	if state then
		repeat task.wait()
			local id = getplayerid()
			if id then
				local t
				lobby._spectate_manager:try_spectate_userid(id, function(_, __, func)
					func()
					t = tick()
				end)
				task.wait(3)
				local gamelocal = getupvalue(client._game_join.load_game, 6)
				if gamelocal then
					local manager = gamelocal:get_spectate_manager()
					if manager:can_cheer() then
						manager:cheer_focused_slot(function(success)
							if success then
								lastcheer = tick()
							end
						end)
					end 
					task.wait(1)
					manager:spectate_leave()
					repeat task.wait() until tick() - lastcheer > 18
				end
			end
		until library.flags.autocheer == false
	end
end })
cheers:addlabel({ content = "Note: Enable when in the Lobby" })

local npcrewards = misctab:addsection({ content = "NPCs", right = true })
npcrewards:addbutton({ content = "Collect NPC Rewards", callback = function()
    for i, v in next, getgc(true) do
        if type(v) == "table" and rawget(v, "WebNPCID") and webnpcmanager:webnpcid_should_trigger_reward(v.WebNPCID) then
            client._shop_local_protocol:visit_webnpc(v.WebNPCID, function() end)
        end
    end
end })

--[[ Hooks ]]--

local fireserver = client._evt.fire_event_to_server
client._evt.fire_event_to_server = newcclosure(function(self, ...)
    local args = {...}
    if args[1] == eventids.EVT_EventReport_ClientExploitDetected then
        return
    elseif args[1] == eventids.EVT_GameLoad_MatchmakingV3_ClientEnqueue and library.flags.unlockall then
        lastsongkey = args[2]
        args[2] = defaultsongkey
    end
    return fireserver(self, unpack(args))
end)

local waitonevent = client._evt.wait_on_event_once
client._evt.wait_on_event_once = newcclosure(function(self, ...)
    local args = {...}
    if args[1] == eventids.EVT_GameLoad_ServerNotifyClientDoPreload and library.flags.unlockall then
		local func = args[2]
		args[2] = newcclosure(function(...)
			local funcargs = {...}
			funcargs[5] = lastsongkey
			func(unpack(funcargs))
		end)
	end
    return waitonevent(self, unpack(args))
end)

local hasviptoday = vipinfo.playerblob_has_vip_for_current_day
vipinfo.playerblob_has_vip_for_current_day = newcclosure(function(self, ...)
	return library.flags.unlockall or hasviptoday(self, ...)
end)

local inputbegan = client._input.input_began
client._input.input_began = newcclosure(function(self, key)
    if library.flags.blockinput and type(key) ~= "number" then 
        return
    end 
    return inputbegan(self, key)
end)

local newtracksystem = tracksystem.new
tracksystem.new = newcclosure(function(self, localgame, ...)
    local system = newtracksystem(self, localgame, ...)
    local update = system[funcnames.tracksystemupdate]
    local notes = getupvalue(update, 2)

    table.clear(noteholder)
    system[funcnames.tracksystemupdate] = newcclosure(LPH_JIT_ULTRA(function(...)
        if library.flags.autoplayenabled then
            handlenotes(localgame, system, notes)
        end
        return update(...)
    end))

    return system
end)

for i = 1, #notebases do
    local color3forslot = notebases[i].color3_for_slot
    notebases[i].color3_for_slot = newcclosure(LPH_JIT_ULTRA(function(self, ...)
        local track = self:get_track_index()
        if library.flags.notetracks["Track " .. track] then
            local flag = library.flags["track" .. track]
            return Color3.fromHSV(flag.h, flag.s, flag.v)
        end
        return color3forslot(self, ...)
    end))
end

--[[ End ]]--

library.items.perfect:set(100)
library:addsettings()

end

--[[ Piggy ]]--

local function piggy()

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "Piggy", version = changelog.version .. " Premium", storage = { "doors", "safes", "triggers", "traps" } })

local maids = {
    character = evov3.imports:fetchsystem("maid"),
    noclip = evov3.imports:fetchsystem("maid"),
    fly = evov3.imports:fetchsystem("maid"),
    loopdoors = evov3.imports:fetchsystem("maid"),
    autokill = evov3.imports:fetchsystem("maid")
}

local players = game:GetService("Players")
local replicatedstorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local char, root, hum
local isflying = false
local lastdooropen = 0

local baseflyvec = Vector3.new(0, 1e-9, 0)

local flykeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local remotes = replicatedstorage.Remotes
local gamefolder = workspace.GameFolder
local itemfolder = workspace:FindFirstChild("ItemFolder")

local maps, modes = {}, {}
local trapnames = {}

--[[ Functions ]]--

function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    maids.character:givetask(root:GetPropertyChangedSignal("Anchored"):Connect(function()
        if root.Anchored and library.flags.noslow and not isflying then
            root.Anchored = false
        end
    end))
    maids.character:givetask(hum.Died:Connect(function()
        maids.character:dispose()
        char, root, hum = nil, nil, nil
    end))
end

function getmap()
    for i, v in next, maps do
        local map = workspace:FindFirstChild(v)
        if map then
            return map
        end
    end
end

function getdoors()
    local map, doors = getmap(), {}
    if map and map:FindFirstChild("Doors") then
        for i, v in next, map.Doors:GetChildren() do
            if v:FindFirstChild("MainDoor") and v.MainDoor:FindFirstChild("ClickDetector") then
                doors[#doors + 1] = v
            end
        end
    end
    return doors
end

function gettraps()
    local traps = {}
    for i, v in next, itemfolder:GetChildren() do
        if string.find(v.Name, "Trap") then
            traps[#traps + 1 ] = v
        end
    end
    return traps
end

function gettriggers()
    local map, triggers = getmap(), {}
    if map then
        for i, v in next, map:GetDescendants() do
            if v:IsA("BasePart") and v.Transparency == 1 and string.find(v.Name, "Trigger") then
                triggers[#triggers + 1] = v
            end
        end
    end
    return triggers
end

function getsafes()
    local map, safes = getmap(), {}
    if map and map:FindFirstChild("Events") then
        for i, v in next, map.Events:GetChildren() do
            if string.find(v.Name, "Safe") and v:FindFirstChild("Door") then
                safes[#safes + 1] = v
            end
        end
    end
    return safes
end

function getlivingplayers()
    local plrs = {}
    for i, v in next, players:GetPlayers() do
        if v ~= player and v.Character and v.Character:FindFirstChild("Energy") and not plr.Character:FindFirstChild("Enemy") then
            plrs[#plrs + 1] = v
        end
    end
    return plrs
end

function dovote(votetype, name)
    remotes.NewVote:FireServer(votetype, name)
end

--[[ Setup ]]--

if itemfolder == nil then
    for i, v in next, workspace:GetChildren() do
        if v.ClassName == "Folder" and tonumber(v.Name) then
            itemfolder = v
            break
        end
    end
end

if player.Character and player.Character:FindFirstChild("Humanoid") then
    registerchar(player.Character)
end

for i, v in next, player.PlayerGui.MainMenu.PlayMenu.VotingMenu.MapVoting:GetChildren() do
    if v:IsA("ImageButton") then
        maps[#maps + 1] = v.Name
    end
end

for i, v in next, player.PlayerGui.MainMenu.PlayMenu.VotingMenu.ModeVoting:GetChildren() do
    if v:IsA("ImageButton") then
        modes[#modes + 1] = v.Name
    end
end

for i, v in next, player.PlayerGui.MainMenu.ItemsFrame.ItemMenu.PiggyAbilityList:GetChildren() do
    if v:IsA("Frame") then
        trapnames[#trapnames + 1] = v.Name
    end
end

--[[ GUI ]]--

local playercat = library:addcategory({ content = "Players" })
local playertab = playercat:addtab({ content = "Local Player" })

local character = playertab:addsection({ content = "Character" })
character:addtoggle({ content = "WalkSpeed", flag = "speedenabled", callback = function(state)
    if hum then
        hum.WalkSpeed = state and library.flags.speedvalue or 16
    end
end })
character:addslider({ content = "Value", min = 16, flag = "speedvalue", callback = function(value)
    if hum and library.flags.speedenabled then
        hum.WalkSpeed = value
    end
end })
character:addtoggle({ content = "JumpPower", flag = "jumpenabled", callback = function(state)
    if hum then
        hum.JumpPower = state and library.flags.jumpvalue or 50
    end
end })
character:addslider({ content = "Value", min = 25, max = 200, flag = "jumpvalue", callback = function(value)
    if hum and library.flags.jumpenabled then
        hum.JumpPower = value
    end
end })
character:addtoggle({ content = "Gravity", flag = "gravenabled", callback = function(state)
    workspace.Gravity = state and library.flags.gravvalue or 196.2
end })
character:addslider({ content = "Value", max = 196.2, default = 196.2, float = 0.1, flag = "gravvalue", callback = function(value)
    if library.flags.gravenabled then
        workspace.Gravity = value
    end
end })
character:addtoggle({ content = "Field Of View", flag = "fovenabled", callback = function(state)
    cam.FieldOfView = state and library.flags.fovvalue or 70
end })
character:addslider({ content = "Value", min = 50, max = 120, default = 70, flag = "fovvalue", callback = function(value)
    if library.flags.fovenabled then
	    cam.FieldOfView = value
    end
end })

local movement = playertab:addsection({ content = "Movement", right = true })
movement:addtoggle({ content = "No Clip", flag = "noclip", callback = function(state)
    if state then
        evo3.maids.noclip:givetask(runservice.Stepped:Connect(function()
            if char then
                for i, v in next, char:GetDescendants() do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end))
    else
        maids.noclip:dispose()
    end
end })
movement:addtoggle({ content = "Infinite Jump", flag = "infjump" })
movement:addbind({ content = "Fly", flag = "fly", onkeydown = function()
	isflying = not isflying
	if isflying then
        maids.fly:givetask(runservice.RenderStepped:Connect(function()
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
            root.Velocity = Vector3.new()
        end
	end
end, onchanged = function(key)
    if key == "None" and isflying then
        library.items.fly.options.onkeydown()
    end
end })
movement:addslider({ content = "Fly Speed", min = 16, default = 100, flag = "flyspeed" })

local utilities = library:addcategory({ content = "Utilities" })
local utilitiestab = utilities:addtab({ content = "Utilities" })

local items = utilitiestab:addsection({ content = "Items" })
items:addbutton({ content = "Pick Up Blueprints", callback = function()
    local map = getmap()
    if map and root then
        local oldcf = root.CFrame
        for i, v in next, map:GetChildren() do
            if v.Name == "BlueprintItem" then
                root.CFrame = CFrame.new(v.Position)
                task.wait(0.5)
                firetouchinterest(root, v, 0)
                task.wait()
                firetouchinterest(root, v, 1)
            end
        end
        root.CFrame = oldcf
    end
end })
items:addbutton({ content = "Pick Up Pages", callback = function()
    local map = getmap()
    if map and map:FindFirstChild("Pages") and root then
        local oldcf = root.CFrame
        for i, v in next, map.Pages:GetChildren() do
            if v:IsA("BasePart") then
                root.CFrame = CFrame.new(v.Position)
                task.wait(0.5)
                firetouchinterest(root, v, 0)
                task.wait()
                firetouchinterest(root, v, 1)
            end
        end
        root.CFrame = oldcf
    end
end })

local doors = utilitiestab:addsection({ content = "Doors", right = true })
doors:addtoggle({ content = "Remove Doors", flag = "nodoors", callback = function(state)
    if state then
        for i, v in next, getdoors() do
            v.Model.Parent = library.storage.doors
        end
    else
        local map = getmap()
        if map then
            for i, v in next, lib.storage.doors:GetChildren() do
                v.Parent = map.Doors
            end
        end
    end
end })
doors:addtoggle({ content = "Remove Safe Doors", flag = "nosafes", callback = function(state)
    if state then
        for i, v in next, getsafes() do
            v.Parent = library.storage.safes
        end
    else
        local map = getmap()
        if map then
            for i, v in next, library.storage.safes do
                v.Parent = map.Events
            end
        end
    end
end })
doors:addtoggle({ content = "Loop Toggle All Doors", flag = "loopdoors", callback = function(state)
    if state then
        maids.loopdoors:givetask(runservice.Heartbeat:Connect(function()
            local t = tick()
            if t - lastdooropen > 1.5 then
                library.items.toggledoors.options.callback()
                lastdooropen = t
            end
        end))
    else
        maids.loopdoors:dispose()
    end
end })
doors:addbutton({ content = "Toggle All Doors", flag = "toggledoors", callback = function()
    for i, v in next, getdoors() do
        fireclickdetector(v.MainDoor.ClickDetector)
    end
end })

local traps = utilitiestab:addsection({ content = "Traps" })
traps:addtoggle({ content = "Remove Death Triggers", flag = "notriggers", callback = function(state)
    if state then
        for i, v in next, gettriggers() do
            v.Parent = library.storage.triggers
        end
    else
        local map = getmap()
        if map then
            for i, v in next, library.storage.triggers do
                v.Parent = map.Events
            end
        end
    end
end })
traps:addtoggle({ content = "Remove Traps", flag = "notraps", callback = function(state)
    if state then
        for i, v in next, gettraps() do
            v.Parent = library.storage.traps
        end
    else
        for i, v in next, library.storage.traps do
            v.Parent = itemfolder
        end
    end
end })
traps:addtoggle({ content = "No Trap Slow Effect", flag = "noslow" })

local piggy = utilitiestab:addsection({ content = "Piggy", right = true })
piggy:addtoggle({ content = "Kill Players", flag = "autokill", callback = function(state)
    if state then
        maids.autokill:givetask(runservice.Heartbeat:Connect(function()
            if root then
                local target = getlivingplayers()[1]
                if target then
                    local targetroot = target.Char.HumanoidRootPart
                    if targetroot then
                        root.CFrame = targetroot.CFrame * CFrame.new(0, 0, -1)
                    end
                end
            end
        end))
    else
        maids.autokill:dispose()
    end
end })
piggy:addtoggle({ content = "Force Trap Type", flag = "forcetrap" })
piggy:adddropdown({ content = "Trap Type", flag = "traptype", items = trapnames, default = trapnames[1] })

local autovote = utilitiestab:addsection({ content = "Auto Voting" })
autovote:addtoggle({ content = "Vote For Map", flag = "autovotemap", callback = function(state)
    if state and gamefolder.Phase.Value == "Map Voting" then
        dovote("Map", library.flags.votemap)
    end
end })
autovote:addtoggle({ content = "Vote For Mode", flag = "autovotemode", callback = function(state)
    if state and gamefolder.Phase.Value == "Piggy Voting" then
        dovote("Piggy", library.flags.votemode)
    end
end })
autovote:adddropdown({ content = "Selected Map", items = maps, selected = maps[1], flag = "votemap", callback = function(selected)
    if library.flags.autovotemap and gamefolder.Phase.Value == "Map Voting" then
        dovote("Map", selected)
    end
end })
autovote:adddropdown({ content = "Selected Mode", items = modes, default = modes[1], flag = "votemode", callback = function(selected)
    if library.flags.autovotemode and gamefolder.Phase.Value == "Piggy Voting" then
        dovote("Piggy", selected)
    end
end })

local teleportscat = library:addcategory({ content = "Teleports" })
local tptab = teleportscat:addtab({ content = "Teleports" })

local playertps = tptab:addsection({ content = "Players" })
playertps:addbox({ content = "Player Name", ignore = true, callback = function(value)
    if root then
        local val, plr = string.lower(value), nil
        for i, v in next, players:GetPlayers() do
            if string.find(string.lower(v.Name), val) then
                plr = v
                break
            end
        end
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = plr.Character.HumanoidRootPart.CFrame
        end
    end
end })

local othertps = tptab:addsection({ content = "Other", right = true })
othertps:addtoggle({ content = "Click Teleport", flag = "clicktp" })

--[[ Hooks ]]--

local newidx
newidx = hookmetamethod(game, "__newindex", function(t, k, v)
    if checkcaller() == false and tostring(getcallingscript()) == "DoorScript" then
        return
    end
    return newidx(t, k, v)
end)

local namecall
namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if checkcaller() == false and getnamecallmethod() == "InvokeServer" and self.Name == "TrapRemote" and library.flags.forcetrap then
        args[1] = library.flags.traptype
    end
    return namecall(self, unpack(args))
end)

--[[ Connections ]]--

player.CharacterAdded:Connect(registerchar)

userinputservice.InputBegan:Connect(function(input, processed)
    if not processed then
        if hum and input.KeyCode == Enum.KeyCode.Space and library.flags.infjump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif root and input.UserInputType == Enum.UserInputType.MouseButton1 and mouse.Hit and library.flags.clicktp then
            root.CFrame = mouse.Hit
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and flykeys[input.KeyCode.Name] ~= nil then
            flykeys[input.KeyCode.Name] = true
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    conn:Disconnect()
                    flykeys[input.KeyCode.Name] = false
                end
            end)
        end
    end
end)

gamefolder.Phase:GetPropertyChangedSignal("Value"):Connect(function()
    if gamefolder.Phase.Value == "Map Voting" and library.flags.autovotemap then
        dovote("Map", library.flags.votemap)
    elseif gamefolder.Phase.Value == "Piggy Voting" and library.flags.autovotemode then
        dovote("Piggy", library.flags.votemode)
    end
end)

workspace.ChildAdded:Connect(function(child)
    local map = getmap()
    if map and child == map then
        for _, store in next, library.storage:GetChildren() do
            store:ClearAllChildren()
        end
        for i, v in next, { "nodoors", "nosafes", "notriggers" } do
            if library.flags[v] then
                library.items[v].options.callback(true)
            end
        end
    end
end)

itemfolder.ChildAdded:Connect(function(child)
    if string.find(child.Name, "Trap") and library.flags.notraps then
        task.wait()
        child.Parent = library.storage.traps
    end
end)

--[[ End ]]--

library:addsettings()

end

--[[ Bloxburg ]]--

local function bloxburg()

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "Bloxburg", version = changelog.version .. " Premium" })

local maids = {
    tp = evov3.imports:fetchsystem("maid"),
    vehicletp = evov3.imports:fetchsystem("maid"),
    autofarm = evov3.imports:fetchsystem("maid")
}

local replicatedstorage = game:GetService("ReplicatedStorage")
local httpservice = game:GetService("HttpService")
local lighting = game:GetService("Lighting")
local stepped = game:GetService("RunService").Stepped
local player = game:GetService("Players").LocalPlayer

local datamanager = require(replicatedstorage.Modules.DataService)
local jobdata = require(replicatedstorage.Modules.Data.JobData)
local jobhandler = require(player.PlayerGui.MainGUI.Scripts.JobHandler)
local guihandler = require(player.PlayerGui.MainGUI.Scripts.Utilities.GUIHandler)
local translater = require(player.PlayerGui.MainGUI.Scripts.Utilities.TranslationHandler)

repeat wait() until jobhandler.JobsLoaded == true

local jobmodules = {
    Hairdresser = jobhandler:GetJobModule("StylezHairdresser"),
    ["BloxyBurgers Cashier"] = jobhandler:GetJobModule("BloxyBurgersCashier"),
    ["Ice Cream Seller"] = jobhandler:GetJobModule("BensIceCreamSeller"),
    ["Pizza Planet Baker"] = jobhandler:GetJobModule("PizzaPlanetBaker"),
    ["Delivery Person"] = jobhandler:GetJobModule("PizzaPlanetDelivery"),
    Mechanic = jobhandler:GetJobModule("MikesMechanic"),
    Fisherman = jobhandler:GetJobModule("HutFisherman"),
    Woodcutter = jobhandler:GetJobModule("LumberWoodcutter"),
    Stocker = jobhandler:GetJobModule("SupermarketStocker"),
    ["Supermarket Cashier"] = jobhandler:GetJobModule("SupermarketCashier"),
    Stocker = jobhandler:GetJobModule("SupermarketStocker"),
    Janitor = jobhandler:GetJobModule("CleanJanitor"),
    Miner = jobhandler:GetJobModule("CaveMiner")
}

local jobnames = {
    Hairdresser = "StylezHairdresser",
    ["BloxyBurgers Cashier"] = "BloxyBurgersCashier",
    ["Ice Cream Seller"] = "BensIceCreamSeller",
    ["Pizza Planet Baker"] = "PizzaPlanetBaker",
    ["Delivery Person"] = "PizzaPlanetDelivery",
    Mechanic = "MikesMechanic",
    Fisherman = "HutFisherman",
    Woodcutter = "LumberWoodcutter",
    Stocker = "SupermarketStocker",
    ["Supermarket Cashier"] = "SupermarketCashier",
    Janitor = "CleanJanitor",
    Miner = "CaveMiner"
}

local jobhandlers, fallentrees = {}, {}
local wheellocations = {
    Bloxster = CFrame.new(1155, 14, 411),
    Classic = CFrame.new(1156, 14, 397),
    Moped = CFrame.new(1154, 14, 402)
}

local isdoingjob = false

local getremote = getupvalue(datamanager.WaitEvent, 1)

local playerstats = replicatedstorage.Stats:WaitForChild(player.Name)
local itemdir = replicatedstorage:WaitForChild("GameObjects"):WaitForChild("EquipAssets")

local styledir = replicatedstorage.GameObjects.JobAssets.StylezHairAssets.Styles
local styles = styledir:GetChildren()

local colourdir = replicatedstorage.GameObjects.JobAssets.StylezHairAssets.Colors
local colours = colourdir:GetChildren()

local weatherval = lighting:WaitForChild("Weather")
local timeval = lighting:WaitForChild("TimeOfDay")
local density = lighting:WaitForChild("WeatherProperties"):WaitForChild("AtmosphereDensity")
local densityval = density.Value

local char, root, hum

--[[ Functions ]]--

local function fireserver(name, args)
	getremote(name):FireServer(args)
end

local function invokeserver(name, args)
	return getremote(name, true):InvokeServer(args)
end

local function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        char, root, hum = nil
    end)
end

local function teleport(target)
	local success, arrived = true, false
	workspace.Gravity = 0
	maids.tp:givetask(stepped:Connect(function(t, step)
        if char == nil or root == nil then
            success, arrived = false, true
        else
            for i, v in next, char:GetDescendants() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            local stepdir = target.Position + root.CFrame.LookVector
            root.CFrame = CFrame.new(root.Position + (target.Position - root.Position).Unit * math.min(12 * step, (target.Position - root.Position).Magnitude), Vector3.new(stepdir.X, root.Position.Y, stepdir.Z))
            root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
            if (target.Position - root.Position).Magnitude < 2 then
                arrived = true
            end
        end
	end))
	repeat task.wait() until arrived
    maids.tp:dispose()
    if success then
        root.CFrame = CFrame.new(target.Position, target.Position + root.CFrame.LookVector)
        root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
        for i, v in next, char:GetDescendants() do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
	workspace.Gravity = 196.2
    return success
end

local function vehicleteleport(vehicle, target)
	local success, arrived = true, false
	workspace.Gravity = 0
    vehicle.CFrame = CFrame.new(vehicle.Position.X, -15, vehicle.Position.Z)
    local xztarget = CFrame.new(target.Position.X, -15, target.Position.Z)
	maids.vehicletp:givetask(stepped:Connect(function(t, step)
        if char == nil or vehicle == nil then
            success, arrived = false, true
        else
            for i, v in next, char:GetDescendants() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            local stepdir = xztarget.Position + root.CFrame.LookVector
            vehicle.CFrame = CFrame.new(vehicle.Position + (xztarget.Position - vehicle.Position).Unit * math.min(35 * step, (xztarget.Position - vehicle.Position).Magnitude), Vector3.new(stepdir.X, vehicle.Position.Y, stepdir.Z))
            vehicle.Velocity, vehicle.RotVelocity = Vector3.new(), Vector3.new()
            if (xztarget.Position - vehicle.Position).Magnitude < 2 then
                arrived = true
            end
        end
	end))
	repeat task.wait() until arrived
    maids.vehicletp:dispose()
    if success then
        vehicle.CFrame = CFrame.new(target.Position, target.Position + vehicle.CFrame.LookVector)
        vehicle.Velocity, vehicle.RotVelocity = Vector3.new(), Vector3.new()
        for i, v in next, char:GetDescendants() do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
	workspace.Gravity = 196.2
    return success
end

local function getnearestcrate()
    local crate, dist = nil, math.huge
    for i, v in next, jobmodules["Pizza Planet Baker"].Model.IngredientCrates:GetChildren() do
        local mag = (v.Position - root.Position).Magnitude
        if mag < dist then
            crate, dist = v, mag
        end
    end
    return crate
end

local function getnearestbags()
    local crate, dist = nil, math.huge
    for i, v in next, jobmodules["Supermarket Cashier"].Model.Crates:GetChildren() do
        if v.Name == "BagCrate" then
            local mag = (v.Position - root.Position).Magnitude
            if mag < dist then
                crate, dist = v, mag
            end
        end
    end
    return crate
end

jobhandlers.Hairdresser = function()
    if jobhandler:GetJob() == "StylezHairdresser" and char then
        local workstation, customer
        for i, v in next, jobmodules.Hairdresser.Model.HairdresserWorkstations:GetChildren() do
			if (v.Mirror:FindFirstChild("HairdresserGUI") and not v.Mirror.HairdresserGUI.Used.Visible) or v.InUse.Value == player then
				local occupant = v.Occupied.Value
				if occupant and occupant.Head:FindFirstChild("ChatBubble") then
                    workstation, customer = v, occupant
                    break
                end
            end
        end
        if workstation and customer then
            local update = getupvalue(getconnections(workstation.Mirror.HairdresserGUI.Frame.Done.Activated)[1].Function, 1)
            local style = table.find(styles, styledir[customer.Order.Style.Value])
            local colour = table.find(colours, colourdir[customer.Order.Color.Value])
            local selected = getupvalue(update, 4)
            if selected[1] ~= style then
                repeat update("Style_Next") until selected[1] == style
            end
            if selected[2] ~= colour then
                repeat update("Color_Next") until selected[2] == colour
            end
            update("Done")
            task.wait(2.5)
        end
    end
end

jobhandlers["BloxyBurgers Cashier"] = function()
    if jobhandler:GetJob() == "BloxyBurgersCashier" and char then
        local workstation, customer
        for i, v in next, jobmodules["BloxyBurgers Cashier"].Model.CashierWorkstations:GetChildren() do
			if (v.OrderDisplay.DisplayMain:FindFirstChild("CashierGUI") and not v.OrderDisplay.DisplayMain.CashierGUI.Used.Visible) or v.InUse.Value == player then
				local occupant = v.Occupied.Value
				if occupant and occupant.Head:FindFirstChild("ChatBubble") then
                    workstation, customer = v, occupant
                    break
                end
            end
        end
        if workstation and customer then
            local update = getupvalue(getconnections(workstation.OrderDisplay.DisplayMain.CashierGUI.Frame.Classic.Activated)[1].Function, 1)
            local menu = getupvalue(update, 4)
            update(customer.Order.Burger.Value)
            if customer.Order.Fries.Value ~= menu[2] then
                update("Fries")
            end
            if customer.Order.Cola.Value ~= menu[3] then
                update("Cola")
            end
            update("Done")
            task.wait(2.5)
        end
    end
end

jobhandlers["Ice Cream Seller"] = function()
    if jobhandler:GetJob() == "BensIceCreamSeller" and char then
		for i, v in next, jobmodules["Ice Cream Seller"].Model.CustomerTargets:GetChildren() do
            local customer = v.Occupied.Value
			if customer and customer.Head:FindFirstChild("ChatBubble") then
                local cup
                repeat fireserver("TakeIceCreamCup", {})
                    cup = char:WaitForChild("Ice Cream Cup", 1)
                until cup
                for _, item in next, customer.Order:GetChildren() do
                    if item.Name:find("Flavor") then
                        fireserver("AddIceCreamScoop", {
                            Taste = item.Value,
                            Ball = cup:WaitForChild("Ball" .. item.Name:sub(7))
                        })
                    elseif item.Name:find("Topping") then
                        fireserver("AddIceCreamTopping", {
                            Taste = item.Value
                        })
                    end
                end
                task.wait(0.1)
                fireserver("JobCompleted", {
                    Workstation = v
                })
                local t = tick()
				repeat task.wait() until v.Occupied.Value ~= customer or tick() - t > 3
				break
            end
        end
    end
end

jobhandlers.Woodcutter = function()
    if jobhandler:GetJob() == "LumberWoodcutter" and char then
        local mag, tree = math.huge
        for i, v in next, workspace.Environment.Trees:GetChildren() do
            if v.PrimaryPart and not fallentrees[v] then
                local dist = (v.PrimaryPart.Position - root.Position).Magnitude
                if dist < mag then
                    mag, tree = dist, v
                end
            end
        end
        if tree then
            local vec = tree.PrimaryPart.Position - root.Position
            if vec.Magnitude > 5 then
                teleport(CFrame.new(root.Position + (vec.Unit * (vec.Magnitude - 5)) + Vector3.new(0, -1, 0)))
            end
            local rotation = tree.PrimaryPart.Rotation
            while true do
                fireserver("UseHatchet", {
                    Tree = tree
                })
                task.wait(0.25)
                if tree.PrimaryPart.Rotation ~= rotation then
                    break
                end
            end
        end
    end
end

jobhandlers["Pizza Planet Baker"] = function()
    if jobhandler:GetJob() == "PizzaPlanetBaker" and char then
        local workstation
        for i, v in next, jobmodules["Pizza Planet Baker"].Model.BakerWorkstations:GetChildren() do
            if (v.OrderDisplay.DisplayMain:FindFirstChild("BakerGUI") and not v.OrderDisplay.DisplayMain.BakerGUI.Used.Visible) or v.InUse.Value == player then
                workstation = v
                break
            end
        end
        if workstation then
            if workstation.Order.IngredientsLeft.Value == 0 then
                teleport(CFrame.new(1165, 14, 258))
                task.wait(0.25)
                fireserver("TakeIngredientCrate", {
                    Object = getnearestcrate()
                })
                teleport(workstation.CounterTop.CFrame * CFrame.new(0, 0, 6))
                task.wait(0.25)
                fireserver("RestockIngredients", {
                    Workstation = workstation
                })
            end
            if workstation.Order.Value then
                fireserver("JobCompleted", {
                    Workstation = workstation, 
                    Order = { true, true, true, workstation.Order.Value }
                })
            end
            task.wait(1)
        end
    end
end

jobhandlers.Fisherman = function()
    if jobhandler:GetJob() == "HutFisherman" and char then
        local start = tick()
        fireserver("UseFishingRod", {
            State = true,
            Pos = Vector3.new(1037.33203, 8.0226841, 1110.54602)
        })
        char["Fishing Rod"]:WaitForChild("Pos"):GetPropertyChangedSignal("Value"):Wait()
        char["Fishing Rod"].Pos:GetPropertyChangedSignal("Value"):Wait()
        fireserver("UseFishingRod", {
            State = false,
            Time = tick() - start
        })
        task.wait(0.5)
    end
end

jobhandlers["Delivery Person"] = function()
    if jobhandler:GetJob() == "PizzaPlanetDelivery" then
        local moped = char:FindFirstChild("Vehicle_Delivery Moped")
        if not moped then
            teleport(CFrame.new(1176, 14, 290))
            invokeserver("UsePizzaMoped", {})
            moped = char:WaitForChild("Vehicle_Delivery Moped")
            setupvalue(jobmodules["Delivery Person"].ShiftLoop, 3, moped)
        end
        repeat task.wait() until moped.PrimaryPart
        vehicleteleport(moped.PrimaryPart, CFrame.new(1169, 14, 273))
        local customer
        repeat
            customer = invokeserver("TakePizzaBox", {
                Box = jobmodules["Delivery Person"].Model:WaitForChild("Conveyor"):WaitForChild("MovingBoxes"):FindFirstChildOfClass("UnionOperation")
            })
        until customer
        vehicleteleport(moped.PrimaryPart, customer:WaitForChild("HumanoidRootPart").CFrame * CFrame.new(0, 0, -2.5))
        repeat
            fireserver("DeliverPizza", {
                Customer = customer
            })
            task.wait(0.25)
        until not char:FindFirstChild("Pizza Box")
    end
end

jobhandlers.Mechanic = function()
    if jobhandler:GetJob() == "MikesMechanic" and char then
        local workstation, customer
        for i, v in next, jobmodules.Mechanic.Model.MechanicWorkstations:GetChildren() do
            if (v.Display.Screen:FindFirstChild("MechanicGUI") and not v.Display.Screen.MechanicGUI.Used.Visible) or v.InUse.Value == player then
                local occupant = v.Occupied.Value
				if occupant and occupant.Head:FindFirstChild("ChatBubble") then
                    workstation, customer = v, occupant
                    break
                end
            end
        end
        if workstation and customer then
            if customer.Order:FindFirstChild("Oil") and customer.Order.Oil.Value then
                teleport(CFrame.new(1195, 14, 388))
                repeat
                    fireserver("TakeOil", {
                        Object = jobmodules.Mechanic.Model.OilCans:FindFirstChildOfClass("Model")
                    })
                    task.wait(0.25)
                until char:FindFirstChild("Oil Can")
                teleport(workstation.Display.Screen.CFrame * CFrame.new(0, 1, -5))
                fireserver("FixBike", {
                    Workstation = workstation
                })
                repeat task.wait() until not char:FindFirstChild("Oil Can")
            elseif customer.Order:FindFirstChild("Color") and customer.Order.Color.Value then
                teleport(CFrame.new(1175, 14, 388))
                repeat
                    fireserver("TakePainter", {
                        Object = jobmodules.Mechanic.Model.PaintingEquipment:FindFirstChild(customer.Order.Color.Value)
                    })
                    task.wait(0.25)
                until char:FindFirstChild("Spray Painter")
                teleport(workstation.Display.Screen.CFrame * CFrame.new(0, 1, -5))
                fireserver("FixBike", {
                    Workstation = workstation
                })
                repeat task.wait() until not char:FindFirstChild("Spray Painter")
            elseif customer.Order:FindFirstChild("Wheels") and customer.Order.Wheels.Value then
                for i = 1, 2 do
                    teleport(wheellocations[customer.Order.Wheels.Value])
                    repeat
                        fireserver("TakeWheel", {
                            Object = jobmodules.Mechanic.Model.TireRacks:FindFirstChild(customer.Order.Wheels.Value)
                        })
                        task.wait(0.25)
                    until char:FindFirstChild("Motorcycle Wheel")
                    teleport(workstation.Display.Screen.CFrame * CFrame.new(0, 1, -5))
                    fireserver("FixBike", {
                        Workstation = workstation,
                        Front = i == 1 or nil
                    })
                    repeat task.wait() until not char:FindFirstChild("Motorcycle Wheel")
                end
            end
            fireserver("JobCompleted", {
                Workstation = workstation
            })
            task.wait(2)
        end
    end
end

jobhandlers["Supermarket Cashier"] = function()
    if jobhandler:GetJob() == "SupermarketCashier" and char then
        local workstation, customer
        for i, v in next, jobmodules["Supermarket Cashier"].Model.CashierWorkstations:GetChildren() do
            if (v.Display.Screen:FindFirstChild("CashierGUI") and not v.Display.Screen.CashierGUI.Used.Visible) or v.InUse.Value == player then
                local occupant = v.Occupied.Value
				if occupant and occupant.Head:FindFirstChild("ChatBubble") then
                    workstation, customer = v, occupant
                    break
                end
            end
        end
        if customer then
            local status = customer:WaitForChild("Status")
            local scanned = 0
            while true do
                repeat task.wait() until #workstation.DroppedFood:GetChildren() > 0 or status.Value == "placed"
                if status.Value == "placed" and #workstation.DroppedFood:GetChildren() == 0 then
                    break
                end
                if scanned % 3 == 0 then
                    if workstation.BagsLeft.Value == 0 then
                        teleport(CFrame.new(838, 14, 117))
                        fireserver("TakeNewBags", {
                            Object = getnearestbags()
                        })
                        teleport(CFrame.new(workstation.Scanner.Position + Vector3.new(-3, 0, 0)))
                        fireserver("RestockBags", {
                            Workstation = workstation
                        })
                        task.wait(0.5)
                    end
                    fireserver("TakeNewBag", {
                        Workstation = workstation
                    })
                end
                fireserver("ScanDroppedItem", {
                    Item = workstation.DroppedFood:GetChildren()[1]
                })
                scanned = scanned + 1
                task.wait(0.5)
            end
            fireserver("JobCompleted", {
                Workstation = workstation
            })
            repeat task.wait() until workstation.Occupied.Value ~= customer
        end
    end
end

jobhandlers.Stocker = function()
    if jobhandler:GetJob() == "SupermarketStocker" and char then
        local mag, crate = math.huge
        for i, v in next, jobmodules.Stocker.Model.Crates:GetChildren() do
            if v.Name == "Crate" then
                local dist = (v.Position - root.Position).Magnitude
                if dist < mag then
                    mag, crate = dist, v
                end
            end
        end
        if crate then
            teleport(crate.CFrame)
            fireserver("TakeFoodCrate", {
				Object = crate
			})
            local mag2, shelf = math.huge
            for i, v in next, jobmodules.Stocker.Model.Shelves:GetChildren() do
                if v:FindFirstChild("IsEmpty") and v.IsEmpty.Value then
                    local dist = (v.PrimaryPart.Position - root.Position).Magnitude
                    if dist < mag2 then
                        mag2, shelf = dist, v
                    end
                end
            end
            if shelf then
                teleport(shelf.PrimaryPart.CFrame * CFrame.new(-2, 5, 0))
                fireserver("RestockShelf", {
                    Shelf = shelf
                })
            end
        end
    end
end

jobhandlers.Janitor = function()
    if jobhandler:GetJob() == "CleanJanitor" and char then
        local mag, trash = math.huge
        for i, v in next, jobmodules.Janitor.Model.Spawns:GetChildren() do
            if v:FindFirstChild("Object") then
                local dist = ((v.Object.ClassName == "Model" and v.Object.PrimaryPart or v.Object).Position - root.Position).Magnitude
                if dist < mag then
                    mag, trash = dist, v
                end
            end
        end
        if trash then
            local object = trash.Object.ClassName == "Model" and trash.Object.PrimaryPart or trash.Object
            teleport(trash.Name == "GroundSpawn" and CFrame.new(object.Position + Vector3.new(0, 3.5, 0)) or object.CFrame)
            invokeserver("CleanJanitorObject", {
                Spawn = trash
            })
        end
    end
end

jobhandlers.Miner = function()
    if jobhandler:GetJob() == "CaveMiner" and char then
        local mag, ore = math.huge
        for i, v in next, workspace.Environment.Locations.Static_MinerCave.Folder:GetChildren() do
            if v.PrimaryPart and v.PrimaryPart.ClassName == "Part" then
                local dist = (v.PrimaryPart.Position - root.Position).Magnitude
                if dist < mag then
                    mag, ore = dist, v
                end
            end
        end
        if ore then
            teleport(CFrame.new(ore.PrimaryPart.Position + Vector3.new(0, 5.5, 0)))
			invokeserver("MineBlock", {
				P = Vector3.new(string.match(ore.Name, "(.+):(.+):(.+)"))
			})
        end
    end
end

--[[ Setup ]]--

if player.Character and player.Character:FindFirstChild("Humanoid") then
    registerchar(player.Character)
end

--[[ GUI ]]--

local jobscat = library:addcategory({ content = "Jobs" })
local farmtab = jobscat:addtab({ content = "Auto Farm" })

local autofarm = farmtab:addsection({ content = "Farming" })
autofarm:addtoggledropdown({ content = "Enabled", flag = "autofarm", items = { "Hairdresser", "BloxyBurgers Cashier", "Ice Cream Seller", "Pizza Planet Baker", "Delivery Person", "Supermarket Cashier", "Stocker", "Mechanic", "Fisherman", "Janitor", "Miner", "Woodcutter" }, default = "Hairdresser", onstatechanged = function(state)
    if state then
        maids.autofarm:givetask(stepped:Connect(function()
            if isdoingjob == false then
                isdoingjob = true
                if library.flags.stoponamount and math.floor(playerstats.Job.ShiftEarnings.Value) >= tonumber(library.flags.stopamount) then
                    library.items.autofarm:toggle(false)
                    jobmodules[library.flags.autofarm.selected].EndShift()
                end
                jobhandlers[library.flags.autofarm.selected]()
                isdoingjob = false
            end
        end))
    else
        maids.autofarm:dispose()
    end
end })
autofarm:addbutton({ content = "Go To Work", callback = function()
    jobhandler:GoToWork(jobnames[library.flags.autofarm.selected])
end })

local farmsettings = farmtab:addsection({ content = "Settings", right = true })
farmsettings:addtoggle({ content = "Stop After Amount", flag = "stoponamount" })
farmsettings:addbox({ content = "Amount", numonly = true, flag = "stopamount", prefix = "$", default = "0" })
farmsettings:addtoggle({ content = "Stop After Time", flag = "stopontime" })
farmsettings:addbox({ content = "Time (Minutes)", numonly = true, flag = "stoptime", default = "0" })

local buildcat = library:addcategory({ content = "Buildings" })
local buildtab = buildcat:addtab({ content = "Base Copier" })

local loadbuild = buildtab:addsection({ content = "Load Build" })
loadbuild:addbox({ content = "File Name", flag = "buildid" })
loadbuild:addstatuslabel({ content = "Cost (Money)", flag = "moneycost", content = "N/A", colour = Color3.fromRGB(225, 225, 225) })
loadbuild:addstatuslabel({ content = "Cost (Blockbux)", flag = "buxcost", content = "N/A", colour = Color3.fromRGB(170, 0, 255) })
loadbuild:addbutton({ content = "Load Data", callback = function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Evo V3", Text = "This feature has been removed due to bugs in building certain structures" })
end })
loadbuild:addstatuslabel({ content = "Build Progress", flag = "buildprogress", content = "0 / 0", colour = Color3.new(1, 0, 0) })
loadbuild:addbutton({ content = "Build House", callback = function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Evo V3", Text = "This feature has been removed due to bugs in building certain structures" })
end })

local savebuild = buildtab:addsection({ content = "Save Build", right = true })
savebuild:addbox({ content = "Player Name", flag = "saveplayer" })
savebuild:addbutton({ content = "Save House", callback = function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Evo V3", Text = "This feature has been removed due to bugs in building certain structures" })
end })

local visualscat = library:addcategory({ content = "Visuals" })
local uitab = visualscat:addtab({ content = "UI" })

local fakepaycheck = uitab:addsection({ content = "Fake Paycheck" })
fakepaycheck:addbox({ content = "Amount", flag = "paycheckamount", numonly = true, callback = function(value)
    local num = tonumber(value)
    if num and math.floor(num) ~= num then
        library.items.paycheckamount:set(tostring(math.floor(num)))
    end
end })
fakepaycheck:addbox({ content = "Job", flag = "paycheckjob" })
fakepaycheck:addbutton({ content = "Trigger Paycheck", callback = function()
    jobhandler:ShowPaycheck(tonumber(library.flags.paycheckamount) or 0, library.flags.paycheckjob)
end })

local maptab = visualscat:addtab({ content = "Map" })

local timeofday = maptab:addsection({ content = "Time of Day" })
timeofday:adddropdown({ content = "Set Time", flag = "time", default = "Normal", items = { "Day", "Night", "Normal" } })

local weather = maptab:addsection({ content = "Weather", right = true })
weather:addtoggle({ content = "No Fog", flag = "nofog", callback = function(state)
    density.Value = state and 0 or densityval
end })
weather:adddropdown({ content = "Set Weather", mode = "repeat", callback = function(value)
    weatherval.Value = value == "Clear" and "" or value
end, items = { "Clear", "Rain", "Thunderstorm", "Fog", "Snow" } })

--[[ Hooks ]]--

local endpizzaboy = jobmodules["Delivery Person"].EndShift
jobmodules["Delivery Person"].EndShift = newcclosure(function(...)
    if library.flags.autofarm and char and char:FindFirstChild("Vehicle_Delivery Moped") then
        return
    end
    return endpizzaboy(...)
end)

local alertbox = guihandler.AlertBox
guihandler.AlertBox = function(...)
    if library.flags.autofarm and char and char:FindFirstChild("Vehicle_Delivery Moped") and ({...})[2] == "E_LeftWorkplace" then
        return
    end
    return alertbox(...)
end

local onevent = datamanager.OnEvent
datamanager.OnEvent = newcclosure(function(tab)
    if tab.Type == "TreeFalling" then
        fallentrees[tab.Tree] = true
    elseif tab.Type == "TreeRespawning" then
        coroutine.wrap(function()
            task.wait(5)
            fallentrees[tab.Tree] = nil
        end)()
    end
    return onevent(tab)
end)

local format = translater.Format
translater.Format = newcclosure(function(self, id, ...)
    if id == "T_Job" .. library.flags.paycheckjob then
        return library.flags.paycheckjob
    end
    return format(self, id, ...)
end)

local displaydur = translater.DisplayExactDuration
translater.DisplayExactDuration = newcclosure(function(self, dur, ...)
    if library.flags.autofarm and string.find(debug.traceback(), "JobHandler") and library.flags.stopontime and math.floor(dur) >= tonumber(library.flags.stoptime) * 60 then
        setthreadidentity(7)
        library.items.autofarm:toggle(false)
        jobmodules[library.flags.autofarm.selected]:EndShift()
        setthreadidentity(2)
    end
    return displaydur(self, dur, ...)
end)

local getjob = jobdata.GetJob
jobdata.GetJob = newcclosure(function(self, ...)
    return getjob(self, ...) or { Title = library.flags.paycheckjob, ID = 1 }
end)

--[[ Connections ]]--

player.CharacterAdded:Connect(registerchar)

timeval:GetPropertyChangedSignal("Value"):Connect(function()
    if library.flags.time ~= "Normal" then
        timeval.Value = library.flags.time == "Day" and 720 or 1440
    end
end)

density:GetPropertyChangedSignal("Value"):Connect(function()
    if density.Value ~= 0 then
        densityval = density.Value
        if library.flags.nofog then
            density.Value = 0
        end
    end
end)

--[[ End ]]--

library:addsettings()

end

--[[ Project Lazarus ]]--

local function projectlazarus()

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "Project Lazarus", version = changelog.version .. " Premium", storage = { "chams", "effects" } })
evov3.imports:fetchmodule("esp")

local drawing = evov3.imports:fetchsystem("drawing")

local maids = {
    character = evov3.imports:fetchsystem("maid"),
    boxadded = evov3.imports:fetchsystem("maid"),
    killaura = evov3.imports:fetchsystem("maid"),
    spinbox = evov3.imports:fetchsystem("maid"),
    farmpoints = evov3.imports:fetchsystem("maid"),
    freezeround = evov3.imports:fetchsystem("maid"),
    rebuild = evov3.imports:fetchsystem("maid")
}

local replicatedstorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local char, root, hum
local weapon, damagekey

local papmodule = require(replicatedstorage:WaitForChild("PaPWeaponsModule"))
local points = player:WaitForChild("leaderstats"):WaitForChild("Points")
local chamsholder = Instance.new("ScreenGui", library.storage.chams)

local fovcircle = drawing:add("Circle", {
    Color = Color3.new(1, 1, 1),
    Filled = false,
    Position = Vector2.new(mouse.X, mouse.Y),
    Thickness = 1,
    Visible = false
})

local guntables, gundata = {}, {}
local zombiecache, maps = {}, {}
local isaimkeydown = false
local renderstepfunc, renderstepidx
local target

local perktable = {
    "Quick Revive",
    "Double Tap Root Beer",
    "Juggernog",
    "Speed Cola",
    "Mule Kick"
}

local playergroup = evov3.esp.group.new("players", {
    exclusions = { HumanoidRootPart = true },
    info = {
        equipped = function(container)
            local equipped = container.player.Backpack:FindFirstChild("Weapon" .. container.player.Backpack.EquippedSlot.Value)
            if equipped and equipped:FindFirstChild("WeaponName") then
                return equipped.WeaponName.Value
            end
            return "None"
        end
    }
})

local zombiegroup = evov3.esp.group.new("npcs", {
    exclusions = { HumanoidRootPart = true }
})

playergroup.settings.teammates = true
playergroup:togglecustomcolours(true)

local gameglobals = getrenv()._G

--[[ Anticheat ]]--

hookfunction(getrenv().gcinfo, function()
    return math.random(1000, 2000)
end)

--[[ Functions ]]--

local function registerweaponscript(weaponscr)
    while true do
        local succ, res = pcall(getsenv, weaponscr)
        if succ and type(res) == "table" and rawget(res, "Knife") then
            weapon = res
            break
        end
        task.wait()
    end

    local upvs = getupvalues(weapon.Knife)
    for i = 1, #upvs do
        local upv = upvs[i]
        if type(upv) == "number" and upv >= 0 and upv <= 1 then
            damagekey = upv
            break
        end
    end

    for i, v in next, getconnections(runservice.RenderStepped) do
        if getfenv(v.Function).script == weaponscr then
            renderstepfunc = getupvalue(v.Function, 6)
            renderstepidx = evov3.utils:tablefind(getconstants(renderstepfunc), "Slow")
            if library.flags.nosloweffects then
                setconstant(renderstepfunc, renderstepidx, "")
            end
            break
        end
    end

    local drinkbottle = weapon.DrinkBottle
    weapon.DrinkBottle = function(...)
        if library.flags.skipperkanims then
            return char.ServerScript.NewPerk:FireServer(({...})[2])
        end
        return drinkbottle(...)
    end

    local sprint = weapon.Sprint
    weapon.Sprint = function(...)
        if library.flags.infstamina then
            setupvalue(sprint, 10, math.huge)
        end
        return sprint(...)
    end

    local conn; conn = weaponscr.AncestryChanged:Connect(function()
        conn:Disconnect()
        weapon = nil
    end)
end

local function registerweapon(modulescr)
    local gunmodule = require(modulescr)
    if not gundata[gunmodule.WeaponName] then
        gundata[gunmodule.WeaponName] = evov3.utils:deepclone(gunmodule)
    end
    local data = gundata[gunmodule.WeaponName]
    if library.flags.firerateenabled then
        gunmodule.FireTime = 60 / library.flags.fireratevalue
    end
    if library.flags.fullauto then
        gunmodule.Semi = false
        gunmodule.SingleAction = false
        gunmodule.Burst = false
    end
    if library.flags.infammo then
        gunmodule.MagSize = math.huge
        gunmodule.MaxAmmo = math.huge
        gunmodule.StoredAmmo = math.huge
    end
    if library.flags.recoilx and library.flags.recoilx > 0 then
        gunmodule.ViewKick.Yaw.Min = data.ViewKick.Yaw.Min * (1 - library.flags.recoilx / 100)
        gunmodule.ViewKick.Yaw.Max = data.ViewKick.Yaw.Max * (1 - library.flags.recoilx / 100)
    end
    if library.flags.recoily and library.flags.recoily > 0 then
        gunmodule.ViewKick.Pitch.Min = data.ViewKick.Pitch.Min * (1 - library.flags.recoily / 100)
        gunmodule.ViewKick.Pitch.Max = data.ViewKick.Pitch.Max * (1 - library.flags.recoily / 100)
    end
    if library.flags.recoilkick and library.flags.recoilkick > 0 then
        gunmodule.GunKick = data.GunKick * (1 - library.flags.recoilkick / 100)
    end
    if library.flags.spreadreduce and library.flags.spreadreduce > 0 then
        gunmodule.Spread.Min = data.Spread.Min * (1 - library.flags.spreadreduce / 100)
        gunmodule.Spread.Max = data.Spread.Max * (1 - library.flags.spreadreduce / 100)
    end
    if library.flags.noaimslow then
        gunmodule.AimMoveSpeed = data.MoveSpeed
    end
	if library.flags.instantreload and gunmodule.ReloadSequence then
		for i = 1, #gunmodule.ReloadSequence do
			gunmodule.ReloadSequence[i] = function() end
		end
	end
    if library.flags.instantaim then
        gunmodule.AimTime = 0.01
    end
    if library.flags.instantequip then
        gunmodule.RaiseSpeed = 0.01
    end
    if library.flags.instanthit and gunmodule.Projectile then
        gunmodule.ProjectileSpeed = 9e9
    end
    if library.flags.nodrop and gunmodule.Projectile then
        gunmodule.ProjectileGravity = nil
    end
    guntables[modulescr.Name] = gunmodule
end

local function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    
    if library.flags.speedenabled then
        hum.WalkSpeed = library.flags.speedvalue
    end
    if library.flags.jumpenabled then
        hum.JumpHeight = workspace:CalculateJumpHeight(workspace.Gravity, library.flags.jumpvalue)
    end

    if char:FindFirstChild("WeaponScript") then
        coroutine.wrap(registerweaponscript)(char.WeaponScript)
    end
    
    for i, v in next, player.Backpack:GetChildren() do
        if string.sub(v.Name, 1, 6) == "Weapon" then
            coroutine.wrap(registerweapon)(v)
        end
    end

    maids.character:givetask(char.ChildAdded:Connect(function(child)
        if child.Name == "WeaponScript" then
            registerweaponscript(child)
        end
    end))

    maids.character:givetask(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if library.flags.speedenabled then
            hum.WalkSpeed = library.flags.speedvalue
        end
    end))

    maids.character:givetask(player.Backpack.ChildAdded:Connect(function(child)
        if string.sub(child.Name, 1, 6) == "Weapon" then
            registerweapon(child)
        end
    end))

    maids.character:givetask(hum.Died:Connect(function()
        char, root, hum, renderstepfunc = nil, nil, nil, nil
        maids.character:dispose()
    end))
end

local function registeresp(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        playergroup:add(plr.Character, { name = plr.Name })
    end
    plr.CharacterAdded:Connect(function(child)
        child:WaitForChild("HumanoidRootPart")
        playergroup:add(child, { name = plr.Name })
    end)
end

local function gettarget()
	local retpart, dist = nil, library.flags.fovenabled and library.flags.fovvalue or math.huge
	for i, v in next, workspace.Baddies:GetChildren() do
		local part = v:FindFirstChild(library.flags.aimpart)
		if part then
            local partpos = part.Position
			local screenpos, vis = cam:WorldToScreenPoint(partpos)
			if vis and (library.flags.wallcheck == false or #cam:GetPartsObscuringTarget({ partpos }, { workspace.Baddies, workspace.Ignore, workspace.Interact, cam, char }) == 0) then
				local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
				if mag < dist then
					retpart, dist = part, mag
				end
			end
		end
	end
	return retpart
end

local function applyfreeze(zombie)
    if zombie:FindFirstChild("Humanoid") and zombie.Humanoid:FindFirstChild("ApplySlow") then
        zombiecache[zombie].lastfrozen = tick()
        zombie.Humanoid.ApplySlow:FireServer({
            Value = 0,
            Duration = 3
        })
    end
end

local function damage(zombie, dmg)
    if damagekey and zombie:FindFirstChild("Humanoid") and zombie.Humanoid.Health > 0 and zombie.Humanoid:FindFirstChild("Damage") then
        if dmg == nil then
            zombiecache[zombie].killed = true
        end
        zombie.Humanoid.Damage:FireServer({
            Damage = dmg or zombie.Humanoid.Health,
            BodyPart = zombie.HeadBox,
            GibPower = 0,
            Force = 0
        }, damagekey)
    end
end

local function killall()
    for i, v in next, zombiecache do
        if v.killed == false then
            damage(i)
        end
    end
end

local function fireinteraction(interaction)
    local origin = root.CFrame
    root.CFrame = interaction.PrimaryPart.CFrame
    task.wait(0.2)
    interaction.Activate:FireServer()
    task.wait(0.2)
    root.CFrame = origin
end

local function papweapon()
    local machine = workspace.Interact:FindFirstChild("Pack-a-Punch")
    if machine and machine:FindFirstChild("Enabled") and machine.Enabled.Value then
        local activate = machine:FindFirstChild("Activate")
        if activate then
            local conn; conn = activate:GetPropertyChangedSignal("Name"):Connect(function()
                if activate.Name == "Activate" then
                    conn:Disconnect()
                    fireinteraction(machine)
                end
            end)
            fireinteraction(machine)
        end
    end
end

local function chamobj(obj, name)
    local adorn = Instance.new("BoxHandleAdornment", library.storage.chams)
    adorn.Adornee = obj
    adorn.AlwaysOnTop = true
    adorn.Color3 = obj.Color
    adorn.Name = name
    adorn.Parent = chamsholder
    adorn.Size = obj.Size + Vector3.new(0.1, 0.1, 0.1)
    adorn.Transparency = 0.6
    adorn.ZIndex = 10

    local conn; conn = obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            conn:Disconnect()
            adorn:Destroy()
        end
    end)
end

local function chammodel(model, name, exclusions, maid)
    for i, v in next, model:GetDescendants() do
        if v:IsA("BasePart") and not (exclusions[v] or exclusions[v.Name]) then
            chamobj(v, name)
        end
    end
    if maid then
        maid:givetask(model.DescendantAdded:Connect(function(desc)
            if desc:IsA("BasePart") and not exclusions[desc.Name] then
                chamobj(desc, name)
            end
        end))
    end
end

local function getbaseparts(model)
    local count = 0
    for i, v in next, model:GetDescendants() do
        if v:IsA("BasePart") then
            count = count + 1
        end
    end
    return count
end

local function getpapdoor()
    for i, v in next, workspace.Interact:GetChildren() do
        if v:FindFirstChild("Prompt") and v.Prompt.Value == "Hold F to Unlock Door" then
            return v
        end
    end
end

--[[ Setup ]]--

if player.Character and player.Character:FindFirstChild("Humanoid") then
    registerchar(player.Character)
end

for i, v in next, players:GetPlayers() do
    if v ~= player then
        coroutine.wrap(registeresp)(v)
    end
end

for i, v in next, workspace.Baddies:GetChildren() do
    if v:FindFirstChild("Humanoid") then
        zombiecache[v] = {
            killed = false,
            lastfrozen = 0
        }
        zombiegroup:add(v, { name = "Zombie" })
    end
end

for i, v in next, replicatedstorage.MapVote:GetChildren() do
    if v:FindFirstChild("MapName") then
        maps[#maps + 1] = v.MapName.Value
    end
end

--[[ ==========  GUI  ========== ]]

local aimassist = library:addcategory({ content = "Aim Assist" })
local aimbottab = aimassist:addtab({ content = "Aimbot" })

local aimbot = aimbottab:addsection({ content = "Aimbot" })
aimbot:addtoggle({ content = "Enabled", flag = "aimbotenabled" })
aimbot:addbind({ content = "Aim Key", default = "MouseButton2", flag = "aimkey" })
aimbot:addtoggle({ content = "Ignore Aim Key", flag = "ignorekey" })
aimbot:addslider({ content = "Smoothness", min = 1, max = 10, float = 0.1, flag = "smoothness" })

local silentaim = aimbottab:addsection({ content = "Silent Aim", right = true })
silentaim:addtoggle({ content = "Enabled", flag = "silentaimenabled" })
silentaim:addslider({ content = "Hit Chance", suffix = "%", default = 100, flag = "hitchance" })
silentaim:addslider({ content = "Headshot Chance", suffix = "%", flag = "headshotchance" })

local fov = aimbottab:addsection({ content = "FOV" })
fov:addtoggle({ content = "Enabled", flag = "fovenabled" })
fov:addtoggle({ content = "Visible", flag = "fovvisible", callback = function(state)
    fovcircle.Visible = state
end })
fov:addslider({ content = "Radius", max = 800, default = 100, flag = "fovvalue", callback = function(value)
    fovcircle.Radius = value
end })

local aimsettings = aimbottab:addsection({ content = "Settings", right = true })
aimsettings:addtoggle({ content = "Wall Check", flag = "wallcheck" })
aimsettings:adddropdown({ content = "Aim Part", flag = "aimpart", items = { "Torso", "Head" }, default = "Torso" })

local autofire = aimbottab:addsection({ content = "Auto Firing" })
autofire:addtoggle({ content = "Triggerbot", flag = "triggerbot" })
autofire:addtoggle({ content = "Auto Shoot", flag = "autoshoot" })
autofire:addtoggle({ content = "Auto Wallbang", flag = "autowall" })

local autokill = aimbottab:addsection({ content = "Auto Kill", right = true })
autokill:addtoggle({ content = "Loop Kill All", flag = "loopkill", callback = function(state)
    if state and root and weapon then
        killall()
    end
end })
autokill:addbutton({ content = "Kill All", callback = function()
    if root and weapon then
        killall()
    end
end })
autokill:addtoggle({ content = "Kill Aura", flag = "killaura", callback = function(state)
    if state then
        maids.killaura:givetask(runservice.Heartbeat:Connect(function()
            if root and weapon then
                for i, v in next, zombiecache do
                    if v.killed == false and i:FindFirstChild("Humanoid") and i.Humanoid.Health > 0 and i:FindFirstChild("HumanoidRootPart") and (i.HumanoidRootPart.Position - root.Position).Magnitude <= library.flags.killaurarange then
                        damage(i)
                    end
                end
            end
        end))
    else
        maids.killaura:dispose()
    end
end })
autokill:addslider({ content = "Aura Range", max = 50, default = 25, float = 0.1, suffix = " Studs", flag = "killaurarange" })

local visualscat = library:addcategory({ content = "Visuals" })
local esptab = visualscat:addtab({ content = "Player ESP" })

local playeresp = esptab:addsection({ content = "Main" })
playeresp:addtoggle({ content = "Enabled", flag = "espenabled", callback = function(state)
    playergroup.settings.enabled = state
end })
playeresp:addtoggle({ content = "Show Names", flag = "espnames", callback = function(state)
    playergroup.settings.names = state
end })
playeresp:addtoggle({ content = "Show Boxes", flag = "espboxes", callback = function(state)
    playergroup.settings.boxes = state
end })
playeresp:addtoggle({ content = "Show Skeletons", flag = "espskeletons", callback = function(state)
    playergroup.settings.skeletons = state
end })
playeresp:addtoggle({ content = "Show Health Bars", flag = "espbars", callback = function(state)
    playergroup.settings.bars = state
end })
playeresp:addtoggle({ content = "Show Distances", flag = "espdistances", callback = function(state)
    playergroup.settings.distances = state
end })
playeresp:addtoggle({ content = "Show Equipped", flag = "espequipped", callback = function(state)
    playergroup.settings.equipped = state
end })
playeresp:addtoggle({ content = "Show Tracers", flag = "esptracers", callback = function(state)
    playergroup.settings.tracers = state
end })
playeresp:addtoggle({ content = "Show Offscreen Arrows", flag = "esparrows", callback = function(state)
    playergroup.settings.offscreenarrows = state
end })
playeresp:addpicker({ content = "Colour", flag = "espcolour", default = playergroup.settings.friendlycolour, callback = function(colour)
    playergroup:updatecustomcolour(colour, true)
end })

local playerespsettings = esptab:addsection({ "Settings", right = true })
playerespsettings:addtoggle({ content = "Use Display Names", flag = "espdisplay", callback = function(state)
    playergroup:updatenames(state)
end })
playerespsettings:addslider({ content = "Thickness", min = 1, max = 10, default = 1, flag = "espthickness", callback = function(value)
    playergroup:updatethickness(value)
end })
playerespsettings:addslider({ content = "Text Size", min = 8, max = 32, default = 14, flag = "espsize", callback = function(value)
    playergroup:updatetextsize(value)
end })

if Drawing.Fonts then
    playerespsettings:adddropdown({ content = "Font", flag = "espfont", items = evov3.utils:keytoarray(Drawing.Fonts), default = "System", callback = function(value)
        playergroup:updatefont(Drawing.Fonts[value])
    end })
end

local playeresparrows = esptab:addsection({ content = "Arrows", right = true })
playeresparrows:addslider({ content = "Arrow Height", min = 1, max = 50, default = 18, flag = "arrowheight", callback = function(value)
    playergroup.settings.arrowheight = value
end })
playeresparrows:addslider({ content = "Arrow Width", min = 8, max = 50, default = 12, flag = "arrowwidth", callback = function(value)
    playergroup.settings.arrowwidth = value
end })
playeresparrows:addslider({ content = "Arrow Center Offset", min = 0, max = 250, default = 120, flag = "arrowoffset", callback = function(value)
    playergroup.settings.arrowoffset = value
end })

local zombiesptab = visualscat:addtab({ content = "Zombie ESP" })
local zombiesp = zombiesptab:addsection({ content = "Main" })
zombiesp:addtoggle({ content = "Enabled", flag = "zombieenabled", callback = function(state)
    zombiegroup.settings.enabled = state
end })
zombiesp:addtoggle({ content = "Show Names", flag = "zombienames", callback = function(state)
    zombiegroup.settings.names = state
end })
zombiesp:addtoggle({ content = "Show Boxes", flag = "zombieboxes", callback = function(state)
    zombiegroup.settings.boxes = state
end })
zombiesp:addtoggle({ content = "Show Skeletons", flag = "zombieskeletons", callback = function(state)
    zombiegroup.settings.skeletons = state
end })
zombiesp:addtoggle({ content = "Show Health Bars", flag = "zombiebars", callback = function(state)
    zombiegroup.settings.bars = state
end })
zombiesp:addtoggle({ content = "Show Distances", flag = "zombiedistances", callback = function(state)
    zombiegroup.settings.distances = state
end })
zombiesp:addtoggle({ content = "Show Tracers", flag = "zombietracers", callback = function(state)
    zombiegroup.settings.tracers = state
end })
zombiesp:addtoggle({ content = "Show Offscreen Arrows", flag = "zombiearrows", callback = function(state)
    zombiegroup.settings.offscreenarrows = state
end })
zombiesp:addpicker({ content = "Colour", flag = "zombiecolour", default = Color3.new(1, 0, 0), callback = function(colour)
    zombiegroup:updatecustomcolour(colour)
end })

local zombiespsettings = zombiesptab:addsection({ "Settings", right = true })
zombiespsettings:addslider({ content = "Thickness", min = 1, max = 10, default = 1, flag = "espthickness", callback = function(value)
    zombiegroup:updatethickness(value)
end })
zombiespsettings:addslider({ content = "Text Size", min = 8, max = 32, default = 14, flag = "espsize", callback = function(value)
    zombiegroup:updatetextsize(value)
end })

if Drawing.Fonts then
    zombiespsettings:adddropdown({ content = "Font", flag = "espfont", items = evov3.utils:keytoarray(Drawing.Fonts), default = "System", callback = function(value)
        zombiegroup:updatefont(Drawing.Fonts[value])
    end })
end

local zombiesparrows = zombiesptab:addsection({ content = "Arrows", right = true })
zombiesparrows:addslider({ content = "Arrow Height", min = 1, max = 50, default = 18, flag = "arrowheight", callback = function(value)
    zombiegroup.settings.arrowheight = value
end })
zombiesparrows:addslider({ content = "Arrow Width", min = 8, max = 50, default = 12, flag = "arrowwidth", callback = function(value)
    zombiegroup.settings.arrowwidth = value
end })
zombiesparrows:addslider({ content = "Arrow Center Offset", min = 0, max = 250, default = 120, flag = "arrowoffset", callback = function(value)
    zombiegroup.settings.arrowoffset = value
end })

local visualstab = visualscat:addtab({ content = "Other" })
local chams = visualstab:addsection({ content = "Chams" })
chams:addtoggle({ content = "Zombies", flag = "chamzombies", callback = function(state)
    if state then
        for i, v in next, zombiecache do
            chammodel(i, "Zombie", { EyeL = true, EyeR = true, HeadBox = true })
        end
    else
        for i, v in next, chamsholder:GetChildren() do
            if v.Name == "Zombie" then
                v:Destroy()
            end
        end
    end
end })
chams:addtoggle({ content = "Mystery Box", flag = "chambox", callback = function(state)
    if state then
        if workspace.Interact:FindFirstChild("MysteryBox") then
            chammodel(workspace.Interact.MysteryBox, "MysteryBox", { [workspace.Interact.MysteryBox.Part] = true, MainPart = true }, maids.boxadded)
        end
    else
        maids.boxadded:dispose()
        for i, v in next, chamsholder:GetChildren() do
            if v.Name == "MysteryBox" then
                v:Destroy()
            end
        end
    end
end })
chams:addtoggle({ content = "Perk Machines", flag = "champerks", callback = function(state)
    if state then
        for i, v in next, workspace.Interact:GetChildren() do
            if v:FindFirstChild("PerkScript") then
                chammodel(v, "PerkMachine", {})
            end
        end
    else
        for i, v in next, chamsholder:GetChildren() do
            if v.Name == "PerkMachine" then
                v:Destroy()
            end
        end
    end
end })

local weaponscat = library:addcategory({ content = "Weapons" })
local gunmodstab = weaponscat:addtab({ content = "Gun Mods" })

local gunsmain = gunmodstab:addsection({ content = "Main" })
gunsmain:addtoggle({ content = "Infinite Ammo", flag = "infammo", callback = function(state)
    if gameglobals.Weapons then
        for i = 1, #gameglobals.Weapons do
            gameglobals.Weapons[i].Ammo = state and math.huge or gundata[gameglobals.Weapons[i].WeaponName].MagSize
        end
    end
    for i, v in next, guntables do
        v.MaxAmmo = state and math.huge or gundata[v.WeaponName].MaxAmmo
        v.StoredAmmo = state and math.huge or gundata[v.WeaponName].StoredAmmo
        v.MagSize = state and math.huge or gundata[v.WeaponName].MagSize
    end
end })
gunsmain:addtoggle({ content = "Full Automatic", flag = "fullauto", callback = function(state)
    for i, v in next, guntables do
        v.Semi = not state and gundata[v.WeaponName].Semi or false
        v.SingleAction = not state and gundata[v.WeaponName].SingleAction or false
        v.Burst = not state and gundata[v.WeaponName].Burst or false
    end
end })
gunsmain:addtoggle({ content = "One Shot Kill", flag = "oneshotkill" })
gunsmain:addtoggle({ content = "Always Headshot", flag = "alwaysheadshot" })
gunsmain:addtoggle({ content = "Wallbang", flag = "wallbang" })
gunsmain:addtoggle({ content = "No Projectile Drop", flag = "nodrop", callback = function(state)
    for i, v in next, guntables do
        if v.Projectile then
            v.ProjectileGravity = not state and gundata[v.WeaponName].ProjectileGravity or nil
        end
    end
end })
gunsmain:addtoggle({ content = "No Aim Slow", flag = "noaimslow", callback = function(state)
    for i, v in next, guntables do
        v.AimMoveSpeed = state and gundata[v.WeaponName].MoveSpeed or gundata[v.WeaponName].AimMoveSpeed
    end
end })
gunsmain:addtoggle({ content = "Instant Hit", flag = "instanthit", callback = function(state)
    for i, v in next, guntables do
        if v.Projectile then
            v.ProjectileSpeed = state and 9e9 or gundata[v.WeaponName].ProjectileSpeed
        end
    end
end })
gunsmain:addtoggle({ content = "Instant Reload", flag = "instantreload", callback = function(state)
    for _, v in next, guntables do
        if rawget(v, "ReloadSequence") then
			for i = 1, #v.ReloadSequence do
				v.ReloadSequence[i] = state and function() end or gundata[v.WeaponName].ReloadSequence[i]
			end
		end
    end
end })
gunsmain:addtoggle({ content = "Instant Aim", flag = "instantaim", callback = function(state)
    for i, v in next, guntables do
        v.AimTime = state and 0.01 or gundata[v.WeaponName].AimTime
    end
end })
gunsmain:addtoggle({ content = "Instant Equip", flag = "instantequip", callback = function(state)
    for i, v in next, guntables do
        v.RaiseSpeed = state and 0.01 or gundata[v.WeaponName].RaiseSpeed
    end
end })

local gunfirerate = gunmodstab:addsection({ content = "Fire Rate", right = true })
gunfirerate:addtoggle({ content = "Enabled", flag = "firerateenabled", callback = function(state)
    for i, v in next, guntables do
        v.FireTime = state and 60 / library.flags.fireratevalue or gundata[v.WeaponName].FireTime
    end
end })
gunfirerate:addslider({ content = "Fire Rate", min = 1, max = 2500, suffix = " RPM", flag = "fireratevalue", callback = function(value)
    for i, v in next, guntables do
        v.FireTime = library.flags.firerateenabled and 60 / value or gundata[v.WeaponName].FireTime
    end
end })

local spread = gunmodstab:addsection({ content = "Spread" })
spread:addslider({ content = "Spread Reduction", suffix = "%", flag = "spreadreduce", callback = function(value)
    for i, v in next, guntables do
        v.Spread.Min = gundata[v.WeaponName].Spread.Min * (1 - value / 100)
        v.Spread.Max = gundata[v.WeaponName].Spread.Max * (1 - value / 100)
    end
end })

local recoil = gunmodstab:addsection({ content = "Recoil", right = true })
recoil:addslider({ content = "Horizontal Reduction", suffix = "%", flag = "recoilx", callback = function(value)
    for i, v in next, guntables do
        v.ViewKick.Yaw.Min = gundata[v.WeaponName].ViewKick.Yaw.Min * (1 - value / 100)
        v.ViewKick.Yaw.Max = gundata[v.WeaponName].ViewKick.Yaw.Max * (1 - value / 100)
    end
end })
recoil:addslider({ content = "Vertical Reduction", suffix = "%", flag = "recoily", callback = function(value)
    for i, v in next, guntables do
        v.GunKick = gundata[v.WeaponName].GunKick * (1 - value / 100)
        v.ViewKick.Pitch.Min = gundata[v.WeaponName].ViewKick.Pitch.Min * (1 - value / 100)
        v.ViewKick.Pitch.Max = gundata[v.WeaponName].ViewKick.Pitch.Max * (1 - value / 100)
    end
end })
recoil:addslider({ content = "Kick Reduction", suffix = "%", flag = "recoilkick", callback = function(value)
    for i, v in next, guntables do
        v.GunKick = gundata[v.WeaponName].GunKick * (1 - value / 100)
    end
end })

local gunautomation = gunmodstab:addsection({ content = "Automation", right = true })
gunautomation:addtoggle({ content = "Auto Pack-a-Punch", flag = "autopap", callback = function(state)
    local equipped = gameglobals.Equipped and gameglobals.Equipped.WeaponName
    if state and equipped and papmodule:GetPaPName(equipped) and points.Value >= 5000 then
        papweapon()
    end
end })
gunautomation:addbind({ content = "Spin Mystery Box", flag = "spinbox", onkeydown = function()
    local box = workspace.Interact:FindFirstChild("MysteryBox")
    if box and root and weapon then
        local activate = box:FindFirstChild("Activate")
        if activate then
            maids.spinbox:givetask(activate:GetPropertyChangedSignal("Name"):Connect(function()
                if activate.Name == "Activate" then
                    maids.spinbox:dispose()
                    fireinteraction(box)
                end
            end))
            maids.spinbox:givetask(box.ChildAdded:Connect(function(child)
                if child.Name == "Joker" then
                    maids.spinbox:dispose()
                end
            end))
            fireinteraction(box)
        end
    end
end })

local playercat = library:addcategory({ content = "Players" })
local playertab = playercat:addtab({ content = "Local Player" })

local values = playertab:addsection({ content = "Values" })
values:addtoggle({ content = "WalkSpeed", flag = "speedenabled", callback = function(state)
    if hum then
        hum.WalkSpeed = state and library.flags.speedvalue or 16
    end
end })
values:addslider({ content = "Value", flag = "speedvalue", min = 16, max = 250, callback = function(value)
    if library.flags.speedenabled and hum then
        hum.WalkSpeed = value
    end
end })
values:addtoggle({ content = "JumpPower", flag = "jumpenabled", callback = function(state)
    if hum then
        hum.JumpHeight = state and workspace:CalculateJumpHeight(workspace.Gravity, library.flags.jumpvalue) or 0
    end
end })
values:addslider({ content = "Value", flag = "jumpvalue", min = 50, max = 250, callback = function(value)
    if library.flags.jumpenabled and hum then
        hum.JumpHeight = workspace:CalculateJumpHeight(workspace.Gravity, value)
    end
end })

local movement = playertab:addsection({ content = "Movement", right = true })
movement:addtoggle({ content = "Infinite Stamina", flag = "infstamina", callback = function(state)
    if weapon then
        setupvalue(weapon.Sprint, 10, state and math.huge or 4.5)
    end
end })
movement:addtoggle({ content = "No Slow Effects", flag = "nosloweffects", callback = function(state)
    if renderstepfunc and renderstepidx then
        setconstant(renderstepfunc, renderstepidx, state and "" or "Slow")
    end
end })

local perks = playertab:addsection({ content = "Perks", right = true })
perks:addchecklist({ content = "Perk List", flag = "autoperks", items = {
    { "Quick Revive" },
    { "Double Tap Root Beer" },
    { "Juggernog" },
    { "Speed Cola" },
    { "Mule Kick" }
} })
perks:addtoggle({ content = "Auto Buy Perks", flag = "autobuyperks" })
perks:addtoggle({ content = "Skip Buy Animation", flag = "skipperkanims" })

local othercat = library:addcategory({ content = "Other" })
local misctab = othercat:addtab({ content = "Misc" })

local givepoints = misctab:addsection({ content = "Points" })
givepoints:addtoggle({ content = "Farm Points", flag = "farmpoints", callback = function(state)
    if state then
        maids.farmpoints:givetask(runservice.RenderStepped:Connect(function()
            if root and weapon then
                local donethisframe = 0
                for i, v in next, zombiecache do
                    if v.killed == false and i:FindFirstChild("Humanoid") and i.Humanoid.Health > 0 then
                        damage(i, 0)
                        donethisframe = donethisframe + 1
                        if donethisframe >= library.flags.concurrentpoints then
                            break
                        end
                    end
                end
            end
        end))
    else
        maids.farmpoints:dispose()
    end
end })
givepoints:addbox({ content = "Give Points", ignore = true, numonly = true, callback = function(value)
    local num = tonumber(value)
    if root and weapon and num and damagekey then
        local count, max = 0, math.floor(num / 10)
        local lastfound = tick()
        local powerups = player.PlayerGui.HUD.PowerUps
        while task.wait() do
            if count == max or tick() - lastfound > 5 then
                break
            end
            local donethisframe = 0
            for i, v in next, zombiecache do
                if v.killed == false and i:FindFirstChild("Humanoid") and i.Humanoid.Health > 0 then
                    damage(i, 0)
                    lastfound = tick()
                    count = count + (powerups:FindFirstChild("DoublePoints") and 2 or 1)
                    donethisframe = donethisframe + 1
                    if count == max or donethisframe >= library.flags.concurrentpoints then
                        break
                    end
                end
            end
        end
    end
end })
givepoints:addslider({ content = "Concurrent Fires", min = 1, max = 25, default = 25, flag = "concurrentpoints" })
givepoints:addlabel({ content = "Lower this if you're having ping issues" })

local freezing = misctab:addsection({ content = "Freeze", right = true })
freezing:addtoggle({ content = "Freeze Round", flag = "freezeround", callback = function(state)
    if state then
        maids.freezeround:givetask(runservice.RenderStepped:Connect(function()
            for i, v in next, zombiecache do
                if tick() - v.lastfrozen > 2.5 then
                    applyfreeze(i)
                end
            end
        end))
    else
        maids.freezeround:dispose()
    end
end })

local map = misctab:addsection({ content = "Map", right = true })
map:addtoggle({ content = "Auto Rebuild Barriers", flag = "autorebuild", callback = function(state)
    if state then
        maids.rebuild:givetask(runservice.Heartbeat:Connect(function()
            if root and weapon then
                for i, v in next, workspace.Interact:GetChildren() do
                    if v.Name == "Barricade" and (root.Position - v.PrimaryPart.Position).Magnitude < 10 then
                        v.Activate:FireServer()
                    end
                end
            end
        end))
    else
        maids.rebuild:dispose()
    end
end })
map:addbutton({ content = "Open All Doors", callback = function()
    for i, v in next, workspace.Interact:GetChildren() do
        if v:FindFirstChild("Prompt") and (v.Prompt.Value == "Door" or v.Prompt.Value == "Debris") and v:FindFirstChild("Activate") and v:FindFirstChild("Cost") and points.Value >= v.Cost.Value then
            v.Activate:FireServer()
        end
    end
end })
map:addbutton({ content = "Turn On The Power", flag = "enablepower", callback = function()
    local switch = workspace:FindFirstChild("PowerSwitch", true)
    if switch and switch:FindFirstChild("Activate") then
        fireinteraction(switch)
    end
end })
map:addbutton({ content = "Unlock Pack-a-Punch", callback = function()
    if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MapName") then
        library.items.enablepower.callback()
        local map = workspace.Map.MapName.Value
        if map == "Graduation" then
            local door = getpapdoor()
            if workspace.Interact:FindFirstChild("Key") and workspace.Interact.Key:FindFirstChild("Activate") then
                workspace.Interact.Key.Activate:FireServer()
                repeat task.wait()
                    door = getpapdoor()
                until door
            end
            if door then
                door.Activate:FireServer()
                workspace.Interact:WaitForChild("PaPJar"):WaitForChild("Activate")
            end
            if workspace.Interact:FindFirstChild("PaPJar") and workspace.Interact.PaPJar:FindFirstChild("Activate") then
                workspace.Interact.PaPJar.Activate:FireServer()
            end
        elseif map == "Research" then
            for i, v in next, workspace.Interact:GetChildren() do
                if v.Name == "Controls" and v:FindFirstChild("Activate") then
                    v.Activate:FireServer()
                end
            end
        else
            library:notify({ type = "error", content = "Unrecognised Map", message = library:formaterror({ error = "lazarus_map_not_found", name = map }) })
        end
    end
end })
map:addbutton({ content = "Complete Music Easter Egg", callback = function()
    for i, v in next, workspace.Interact:GetChildren() do
        if v.Name == "MusicEasterEgg" and v:FindFirstChild("Activate") then
            fireinteraction(v)
        end
    end
end })

local voting = misctab:addsection({ content = "Voting" })
voting:addtoggle({ content = "Auto Vote", flag = "autovoteenabled", callback = function(state)
    if state and player.PlayerGui:FindFirstChild("LobbyGui") and player.PlayerGui.LobbyGui.Menu.Map.Vote.Visible then
        for i, v in next, replicatedstorage.MapVote:GetChildren() do
            if v:FindFirstChild("MapName") and v.MapName.Value == library.flags.autovotevalue then
                firesignal(player.PlayerGui.LobbyGui.Menu.Map.Vote[v.Name].Activated, 1)
                break
            end
        end
    end
end })
voting:adddropdown({ content = "Maps", flag = "autovotevalue", items = maps, default = maps[1], callback = function(value)
    if library.flags.autovoteenabled and player.PlayerGui:FindFirstChild("LobbyGui") and player.PlayerGui.LobbyGui.Menu.Map.Vote.Visible then
        for i, v in next, replicatedstorage.MapVote:GetChildren() do
            if v:FindFirstChild("MapName") and v.MapName.Value == value then
                firesignal(player.PlayerGui.LobbyGui.Menu.Map.Vote[v.Name].Activated, 1)
                break
            end
        end
    end
end })

--[[ Hooks ]]--

local namecall
namecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" then
            local args = {...}
            if tostring(self) == "SendData" then -- anticheat yes
                return
            elseif tostring(self) == "Damage" then
                if library.flags.alwaysheadshot and args[1].BodyPart and args[1].Damage and not args[1].Knifed then
                    args[1].BodyPart = args[1].BodyPart.Parent.HeadBox
                    args[1].Damage = gameglobals.Equipped.Damage.Max * (gameglobals.Equipped.HeadShot or 1)
                end
                if library.flags.oneshotkill then
                    args[1].Damage = self.Parent.Health
                end
                return namecall(self, unpack(args))
            end
        elseif method == "InvokeServer" and tostring(self) == "UpdateDamageKey" then
            damagekey = ({...})[1]
        elseif method == "FindPartOnRayWithIgnoreList" and weapon then
            local args = {...}
            if library.flags.silentaimenabled and target and math.random(1, 100) <= library.flags.hitchance then
                args[1] = Ray.new(args[1].Origin, (math.random(1, 100) <= library.flags.headshotchance and target.Parent:FindFirstChild("HeadBox") or target).Position - args[1].Origin)
                args[2][#args[2] + 1] = workspace.Map
                args[2][#args[2] + 1] = workspace.Interact
            elseif library.flags.wallbang then
                args[2][#args[2] + 1] = workspace.Map
                args[2][#args[2] + 1] = workspace.Interact
            end
            return namecall(self, unpack(args))
        end
    end
    return namecall(self, ...)
end)

--[[ Connections ]]--

coroutine.wrap(function()
    while task.wait(1) do
        if root and weapon and library.flags.autobuyperks and player.Backpack:FindFirstChild("Perks") and not char:FindFirstChild("Activate") then
            for i = 1, #perktable do
                local perk = perktable[i]
                if library.flags.autoperks[perk] and not player.Backpack.Perks:FindFirstChild(perk) then
                    local perkinteract = workspace.Interact:FindFirstChild(perk)
                    if perkinteract and perkinteract:FindFirstChild("Activate") and points.Value >= perkinteract.Cost.Value then
                        fireinteraction(perkinteract)
                        break
                    end
                end
            end
        end
        if library.flags.autopap then
            local equipped = gameglobals.Equipped and gameglobals.Equipped.WeaponName
            if equipped and papmodule:GetPaPName(equipped) and points.Value >= 5000 then
                papweapon()
            end
        end
    end
end)()

player.CharacterAdded:Connect(registerchar)
players.PlayerAdded:Connect(registeresp)

mouse.Move:Connect(function()
    fovcircle.Position = userinputservice:GetMouseLocation()
end)

player.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "LobbyGui" then
        child:WaitForChild("Menu"):WaitForChild("Map"):WaitForChild("Vote")
        repeat task.wait() until child.Menu.Map.Vote.Visible
        if library.flags.autovoteenabled then
            for i, v in next, replicatedstorage.MapVote:GetChildren() do
                if v:FindFirstChild("MapName") and v.MapName.Value == library.flags.autovotevalue then
                    firesignal(player.PlayerGui.LobbyGui.Menu.Map.Vote[v.Name].Activated, 1)
                    break
                end
            end
        end
    end
end)

workspace.Baddies.ChildAdded:Connect(function(child)
    zombiecache[child] = {
        killed = false,
        lastfrozen = 0
    }
    repeat task.wait() until getbaseparts(child) >= 6
    zombiegroup:add(child, { name = "Zombie" })
    if library.flags.chamzombies then
        chammodel(child, "Zombie", { EyeL = true, EyeR = true, HeadBox = true })
    end
    if library.flags.loopkill then
        child:WaitForChild("Humanoid"):WaitForChild("Damage")
        damage(child)
    elseif library.flags.freezeround then
        child:WaitForChild("Humanoid"):WaitForChild("ApplySlow")
        applyfreeze(child)
    end
end)

workspace.Baddies.ChildRemoved:Connect(function(child)
    zombiecache[child] = nil
end)

workspace.Interact.ChildAdded:Connect(function(child)
    task.wait()
    if library.flags.chambox and child.Name == "MysteryBox" then
        chammodel(child, "MysteryBox", { [workspace.Interact.MysteryBox:WaitForChild("Part")] = true, MainPart = true }, maids.boxadded)
    elseif library.flags.champerks and child:FindFirstChild("PerkScript") then
        chammodel(child, "PerkMachine", {})
    end
end)

userinputservice.InputBegan:Connect(function(input, isrbx)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            isaimkeydown = true
        end
    end
end)

userinputservice.InputEnded:Connect(function(input)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            isaimkeydown = false
        end
    end
end)

runservice.Heartbeat:Connect(function()
    if root and weapon then
        target = gettarget()
        if target then
            if library.flags.aimbotenabled and (isaimkeydown or library.flags.ignorekey) then
                cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + cam.CFrame.LookVector + (((target.Position - cam.CFrame.Position).Unit - cam.CFrame.LookVector) / library.flags.smoothness))
            end
            if library.flags.silentaimenabled and library.flags.autoshoot and (library.flags.autowall or #cam:GetPartsObscuringTarget({ partpos }, { workspace.Baddies, workspace.Ignore, workspace.Interact, cam, char }) == 0) then
				mouse1click()
            elseif library.flags.triggerbot then
                local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(cam.CFrame.Position, cam.CFrame.LookVector * 1000), { workspace.Baddies, workspace.Ignore, workspace.Interact, cam, char })
                if part and part.Parent.Parent == workspace.Baddies then
                    mouse1click()
                end
			end
        end
    end
end)

--[[ End ]]--

library:addsettings()

end

--[[ JailBreak ]]--

local function jailbreak()

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
		Url = "", -- Link redacted, the repl.co version from the previous 2 versions of Evo still works tho :)
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

end

--[[ Universal ]]--

local function universal()

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "Universal", version = changelog.version .. " Premium" })
evov3.imports:fetchmodule("esp")

local maids = {
    character = evov3.imports:fetchsystem("maid"),
    fly = evov3.imports:fetchsystem("maid")
}

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

local char, root, hum
local isaimkeydown = false
local isflying = false

local espgroup = evov3.esp.group.new("players", { exclusions = { HumanoidRootPart = true } })

--[[ Functions ]]--

local function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    if library.flags.speedenabled then
        hum.WalkSpeed = library.flags.speedvalue
    end
    if library.flags.jumpenabled then
        hum.JumpPower = library.flags.jumpvalue
    end
    maids.character:givetask(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum and library.flags.speedenabled then
            hum.WalkSpeed = library.flags.speedvalue
        end
    end))
    maids.character:givetask(hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if hum and library.flags.jumpenabled then
            hum.JumpPower = library.flags.jumpvalue
        end
    end))
    maids.character:givetask(hum.Died:Connect(function()
        maids.character:dispose()
        char, root, hum = nil, nil, nil
    end))
end

local function registerplayer(plr)
    maids[plr.Name] = evov3.imports:fetchsystem("maid")
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        espgroup:add(plr.Character, { name = plr.Name, colour = plr.TeamColor.Color })
    end
    maids[plr.Name]:givetask(plr.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        espgroup:add(character, { name = plr.Name, colour = plr.TeamColor.Color })
    end))
end

local customregistries = {}

customregistries[5938036553] = function() -- Frontlines DEMO
    espgroup.exclusions.tpv_model = true

    local client, characters
    for i, v in next, getgc(true) do
        if type(v) == "table" then
            if rawget(v, "gbus") then
                client = v
                if characters then
                    break
                end
            elseif rawget(v, "sol_root_parts") then
                characters = v
                if client then
                    break
                end
            end
        end
    end

    function espgroup:isenemy(inst)
        return characters.cli_teams[characters.cli_state.id] ~= characters.cli_teams[evov3.utils:tablefind(characters.cli_names, inst.player.Name)]
    end

    function espgroup:gethealth(inst)
        return math.round(characters.gbl_sol_healths[evov3.utils:tablefind(characters.cli_names, inst.player.Name)] or 0) / 100
    end

    function espgroup:getplayerfromcharacter(model)
        for i, v in next, characters.gbl_sol_state.r15_models do
            if v == model then
                return players:FindFirstChild(characters.cli_names[i])
            end
        end
    end

    for i, v in next, characters.cli_names do
        local plr = players:FindFirstChild(v)
        if plr then
            local character = characters.gbl_sol_state.r15_models[i]
            if character then
                espgroup:add(character, { name = plr.Name, colour = characters.cli_teams[characters.cli_state.id] ~= characters.cli_teams[i] and Color3.new(1, 0, 0) or Color3.new(0, 1, 0) })
            end
        end
    end

    workspace.ChildAdded:Connect(function(child)
        if child.Name == "r15_rig" and child.ClassName == "Model" then
            local index
            repeat
                for i, v in next, characters.gbl_sol_state.r15_models do
                    if v == child then
                        index = i
                        break
                    end
                end
                task.wait()
            until index
            local plr = players:FindFirstChild(characters.cli_names[index])
            if plr and plr ~= player then
                espgroup:add(child, { name = plr.Name, colour = characters.cli_teams[characters.cli_state.id] ~= characters.cli_teams[evov3.utils:tablefind(characters.cli_names, plr.Name)] and Color3.new(1, 0, 0) or Color3.new(0, 1, 0) })
            end
        end
    end)
end

--[[ Setup ]]--

if player.Character and player.Character:FindFirstChild("Humanoid") then
    task.spawn(registerchar, player.Character)
end

local customregistry = customregistries[game.PlaceId]
if customregistry then
    customregistry()
else
    for i, v in next, players:GetPlayers() do
        if v ~= player then
            task.spawn(registerplayer, v)
        end
    end
end

--[[ GUI ]]--

local visuals = library:addcategory({ content = "Visuals" })
local esptab = visuals:addtab({ content = "ESP" })

local espmain = esptab:addsection({ content = "Main" })
espmain:addtoggle({ content = "Enabled", flag = "espenabled", callback = function(state)
    espgroup.settings.enabled = state
end })
espmain:addtoggle({ content = "Show Names", flag = "espnames", callback = function(state)
    espgroup.settings.names = state
end })
espmain:addtoggle({ content = "Show Boxes", flag = "espboxes", callback = function(state)
    espgroup.settings.boxes = state
end })
espmain:addtoggle({ content = "Show Skeletons", flag = "espskeletons", callback = function(state)
    espgroup.settings.skeletons = state
end })
espmain:addtoggle({ content = "Show Health Bars", flag = "espbars", callback = function(state)
    espgroup.settings.bars = state
end })
espmain:addtoggle({ content = "Show Distances", flag = "espdistances", callback = function(state)
    espgroup.settings.distances = state
end })
espmain:addtoggle({ content = "Show Tracers", flag = "esptracers", callback = function(state)
    espgroup.settings.tracers = state
end })
espmain:addtoggle({ content = "Show Offscreen Arrows", flag = "esparrows", callback = function(state)
    espgroup.settings.offscreenarrows = state
end })

local espsettings = esptab:addsection({ content = "Settings", right = true })
espsettings:addtoggle({ content = "Show Teammates", flag = "espteam", callback = function(state)
    espgroup.settings.teammates = state
end })
espsettings:addtoggle({ content = "Use Display Names", flag = "espdisplay", callback = function(state)
    espgroup:updatenames(state)
end })
espsettings:addslider({ content = "Thickness", min = 1, max = 10, default = 1, flag = "espthickness", callback = function(value)
    espgroup:updatethickness(value)
end })
espsettings:addslider({ content = "Text Size", min = 8, max = 32, default = 14, flag = "espsize", callback = function(value)
    espgroup:updatetextsize(value)
end })

if Drawing.Fonts then
    espsettings:adddropdown({ content = "Font", flag = "espfont", items = evov3.utils:keytoarray(Drawing.Fonts), default = "System", callback = function(value)
        espgroup:updatefont(Drawing.Fonts[value])
    end })
end

local esparrows = esptab:addsection({ content = "Arrows", right = true })
esparrows:addslider({ content = "Arrow Height", min = 1, max = 50, default = 18, flag = "arrowheight", callback = function(value)
    espgroup.settings.arrowheight = value
end })
esparrows:addslider({ content = "Arrow Width", min = 8, max = 50, default = 12, flag = "arrowwidth", callback = function(value)
    espgroup.settings.arrowwidth = value
end })
esparrows:addslider({ content = "Arrow Center Offset", min = 0, max = 250, default = 120, flag = "arrowoffset", callback = function(value)
    espgroup.settings.arrowoffset = value
end })

local espcolours = esptab:addsection({ content = "Colours" })
espcolours:addtoggle({ content = "Custom Colours", flag = "espcolours", callback = function(state)
    espgroup:togglecustomcolours(state)
end })
espcolours:addpicker({ content = "Friendly Colour", flag = "espfriendlycolour", default = espgroup.settings.friendlycolour, callback = function(colour)
    espgroup:updatecustomcolour(colour, true)
end })
espcolours:addpicker({ content = "Enemy Colour", flag = "espenemycolour", default = espgroup.settings.enemycolour, callback = function(colour)
    espgroup:updatecustomcolour(colour, false)
end })

local playercat = library:addcategory({ content = "Players" })
local playertab = playercat:addtab({ content = "Local Player" })

local charvalues = playertab:addsection({ content = "Values" })
charvalues:addtoggle({ content = "WalkSpeed", flag = "speedenabled", callback = function(state)
    if hum then
        hum.WalkSpeed = state and library.flags.speedvalue or 16
    end
end })
charvalues:addslider({ content = "Value", min = 16, max = 500, flag = "speedvalue", callback = function(value)
    if hum and library.flags.speedenabled then
        hum.WalkSpeed = value
    end
end })
charvalues:addtoggle({ content = "JumpPower", flag = "jumpenabled", callback = function(state)
    if hum then
        hum.JumpPower = state and library.flags.jumpvalue or 50
    end
end })
charvalues:addslider({ content = "Value", min = 50, max = 500, flag = "jumpvalue", callback = function(value)
    if hum and library.flags.jumpenabled then
        hum.JumpPower = value
    end
end })

--[[ Hooks ]]--

-- None! It's a universal, fuckwit

--[[ Traces ]]--

-- None! It's a universal, fuckwit

--[[ Connections ]]--

if customregistry == nil then
    players.PlayerAdded:Connect(registerplayer)
end

players.PlayerRemoving:Connect(function(plr)
    local maid = maids[plr.Name]
    if maid then
        maid:dispose()
        maids[plr.Name] = nil
    end
end)

userinputservice.InputBegan:Connect(function(input, isrbx)
    if not isrbx then
        if input.UserInputType.Name == library.flags.aimkey or input.KeyCode.Name == library.flags.aimkey then
            isaimkeydown = true
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    conn:Disconnect()
                    isaimkeydown = false
                end
            end)
        end--[[
        if input.UserInputType == Enum.UserInputType.Keyboard and flykeys[input.KeyCode.Name] ~= nil then
            flykeys[input.KeyCode.Name] = true
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    conn:Disconnect()
                    flykeys[input.KeyCode.Name] = false
                end
            end)
        end]]
    end
end)
--[[
runservice.RenderStepped:Connect(function()

end)
]]
--[[ End ]]--

library:addsettings()

end

--[[ Load Game ]]--

({
    phantomforces = phantomforces,
    badbusiness = badbusiness,
    robeats = robeats,
    piggy = piggy,
    bloxburg = bloxburg,
    projectlazarus = projectlazarus,
    jailbreak = jailbreak,
    universal = universal
})[thisgame]()
