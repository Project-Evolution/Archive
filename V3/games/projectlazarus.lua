--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

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
