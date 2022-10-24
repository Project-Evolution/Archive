--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

local LPH_ENCSTR = function(...) return ... end
local LPH_JIT_ULTRA = function(...) return ... end

--[[ Anticheat ]]--

do
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
end

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

local blacklistedargs = { -- some are no longer used but keeping them anyway
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

shell.Timer.Wait = function(self, dur, ...)
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

shell.Items.GetConfig = function(self, ...)
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

local chars = workspace.Characters:GetChildren()
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
