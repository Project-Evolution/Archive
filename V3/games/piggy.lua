--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

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
