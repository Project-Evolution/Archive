--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

local LPH_ENCSTR = function(...) return ... end
local LPH_JIT_ULTRA = function(...) return ... end

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
