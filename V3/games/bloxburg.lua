--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

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
