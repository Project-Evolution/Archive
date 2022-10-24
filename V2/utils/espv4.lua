--[[ ==========  Variables  ========== ]]

local players = game:GetService("Players")

local player = players.LocalPlayer
local cam = workspace.CurrentCamera

local worldToViewportPoint = cam.WorldToViewportPoint
local getBoundingBox = Instance.new("Model").GetBoundingBox

local drawingNew = Drawing.new
local vector2New = Vector2.new
local cframeNew = CFrame.new
local mathAbs = math.abs
local mathFloor = math.floor
local mathMin = math.min
local color3New = Color3.new

local white = color3New(1, 1, 1)
local origin = vector2New(cam.ViewportSize.X / 2, cam.ViewportSize.Y - 10)

local espv4 = {
    groups = {}
}

--[[ ==========  Misc Functions  ========== ]]

local function getViewportPoint(pos)
    local screenPos, vis = worldToViewportPoint(cam, pos)
    return vector2New(screenPos.X, screenPos.Y), vis
end

local function getColour(health)
	return color3New(health < .5 and 1 or 1 - ((health - 0.5) * 2), health > .5 and 1 or health * 2, 0)
end

local function newText(size, content)
    local text = drawingNew("Text")
    text.Center = true
    text.Color = white
    text.Outline = false
    text.Size = size
    text.Text = "[ " .. (content or "") .. " ]"
    text.Visible = false
    return text
end

local function newLine(thickness)
    local line = drawingNew("Line")
    line.Color = white
    line.Thickness = thickness
    line.Visible = false
    return line
end

local function newQuad(thickness, filled)
    local quad = drawingNew("Quad")
    quad.Color = white
	quad.Filled = filled
    quad.Thickness = thickness
    quad.Visible = false
    return quad
end

local function mapCharacter(model, excluded)
    local characterMap = {}
    for i, v in next, model:GetDescendants() do
        if v.ClassName == "Motor6D" then
            if v.Part0 == nil or v.Part1 == nil then
                repeat task.wait() until v.Part0 ~= nil and v.Part1 ~= nil
            end
            if not excluded[v.Part0.Name] and not excluded[v.Part1.Name] then
                characterMap[#characterMap + 1] = { v.Part0, v.Part1 }
            end
        end
    end
    return characterMap
end

--[[ ==========  Rendering  ========== ]]

local function updatePlayers(group)
    for i, v in next, group.container do
        v.health = group:GetHealth(v)

        local cf, size = getBoundingBox(v.model)
        local radiusSize = size / 2
        local isEnemy = group.settings.teammates or group:IsEnemy(v)

        local middle, vis = getViewportPoint(cf.Position)
        local topLeft = getViewportPoint((cf * cframeNew(radiusSize.x, radiusSize.y, 0)).Position)
        local topRight = getViewportPoint((cf * cframeNew(-radiusSize.x, radiusSize.y, 0)).Position)
        local bottomLeft = getViewportPoint((cf * cframeNew(radiusSize.x, -radiusSize.y, 0)).Position)
        local bottomRight = getViewportPoint((cf * cframeNew(-radiusSize.x, -radiusSize.y, 0)).Position)

        local absoluteTopLeft = topLeft.X > topRight.X and topRight or topLeft
        local absoluteBottomLeft = bottomLeft.X > bottomRight.X and bottomRight or bottomLeft
        local barWidth = mathMin(mathAbs(topLeft.X - topRight.X) / 5, 16)
        local gradient = (topRight.Y - topLeft.Y) / (topRight.X - topLeft.X)
        local barOffset = vector2New(barWidth, barWidth * gradient)
        local bottomOffset = vector2New(absoluteBottomLeft.X - (barWidth / 4), absoluteBottomLeft.Y)
        local topOffset = bottomOffset - ((absoluteBottomLeft - absoluteTopLeft) * v.health)

        local skeleton = {}
        for idx, holder in next, v.map do
            if not skeleton[holder[1]] then
                skeleton[holder[1]] = getViewportPoint(holder[1].Position)
            end
            if not skeleton[holder[2]] then
                skeleton[holder[2]] = getViewportPoint(holder[2].Position)
            end
            v.skeleton[idx].From = skeleton[holder[1]]
            v.skeleton[idx].To = skeleton[holder[2]]
            v.skeleton[idx].Visible = group.settings.skeletons and isEnemy and vis
        end

        v.name.Position = (topLeft + (topRight - topLeft) / 2) - vector2New(0, v.name.TextBounds.Y)
        v.name.Visible = group.settings.names and isEnemy and vis

        local data = ""
        for _, info in next, group.info do
            if group.settings[info.name] then
                data = data .. "[ " .. info.func(v) .. " ]"
            end
        end

        v.data.Position = bottomLeft + (bottomRight - bottomLeft) / 2
        v.data.Text = data
        v.data.Visible = isEnemy and vis

        v.bar.PointA = topOffset
        v.bar.PointB = topOffset - barOffset
        v.bar.PointC = bottomOffset - barOffset
        v.bar.PointD = bottomOffset
        v.bar.Color = getColour(v.health)
        v.bar.Visible = group.settings.bars and isEnemy and vis

        v.box.PointA = topRight
        v.box.PointB = topLeft
        v.box.PointC = bottomLeft
        v.box.PointD = bottomRight
        v.box.Visible = group.settings.boxes and isEnemy and vis

        v.tracer.To = bottomLeft + (bottomRight - bottomLeft) / 2
        v.tracer.Visible = group.settings.tracers and isEnemy and vis
    end
end

local function updateNpcs(group)
    for i, v in next, group.container do
        v.health = group:GetHealth(v)

        local cf, size = getBoundingBox(v.model)
        local radiusSize = size / 2

        local middle, vis = getViewportPoint(cf.Position)
        local topLeft = getViewportPoint((cf * cframeNew(radiusSize.x, radiusSize.y, 0)).Position)
        local topRight = getViewportPoint((cf * cframeNew(-radiusSize.x, radiusSize.y, 0)).Position)
        local bottomLeft = getViewportPoint((cf * cframeNew(radiusSize.x, -radiusSize.y, 0)).Position)
        local bottomRight = getViewportPoint((cf * cframeNew(-radiusSize.x, -radiusSize.y, 0)).Position)

        local absoluteTopLeft = topLeft.X > topRight.X and topRight or topLeft
        local absoluteBottomLeft = bottomLeft.X > bottomRight.X and bottomRight or bottomLeft
        local barWidth = mathMin(mathAbs(topLeft.X - topRight.X) / 5, 16)
        local gradient = (topRight.Y - topLeft.Y) / (topRight.X - topLeft.X)
        local barOffset = vector2New(barWidth, barWidth * gradient)
        local bottomOffset = vector2New(absoluteBottomLeft.X - (barWidth / 4), absoluteBottomLeft.Y)
        local topOffset = bottomOffset - ((absoluteBottomLeft - absoluteTopLeft) * v.health)

        local skeleton = {}
        for _, holder in next, v.map do
            if not skeleton[holder[1]] then
                skeleton[holder[1]] = getViewportPoint(holder[1].Position)
            end
            if not skeleton[holder[2]] then
                skeleton[holder[2]] = getViewportPoint(holder[2].Position)
            end
            v.skeleton[i].From = skeleton[holder[1]]
            v.skeleton[i].To = skeleton[holder[2]]
            v.skeleton[i].Visible = group.settings.skeletons and vis
        end

        v.name.Position = (topLeft + (topRight - topLeft) / 2) - vector2New(0, v.name.TextBounds.Y)
        v.name.Visible = group.settings.names and vis

        local data = ""
        for _, info in next, group.info do
            if group.settings[info.name] then
                data = data .. "[ " .. info.func(v) .. " ]"
            end
        end

        v.data.Position = bottomLeft + (bottomRight - bottomLeft) / 2
        v.data.Text = data
        v.data.Visible = vis

        v.bar.PointA = topOffset
        v.bar.PointB = topOffset - barOffset
        v.bar.PointC = bottomOffset - barOffset
        v.bar.PointD = bottomOffset
        v.bar.Color = getColour(v.health)
        v.bar.Visible = group.settings.bars and vis

        v.box.PointA = topRight
        v.box.PointB = topLeft
        v.box.PointC = bottomLeft
        v.box.PointD = bottomRight
        v.box.Visible = group.settings.boxes and vis

        v.tracer.To = bottomLeft + (bottomRight - bottomLeft) / 2
        v.tracer.Visible = group.settings.tracers and vis
    end
end

local function updateItems(group)
    for i, v in next, group.container do
        local cf, size = getBoundingBox(v.model)
        local radiusSize = size / 2

        local middle, vis = getViewportPoint(cf.Position)

        local data = group.settings.names and "[ " .. v.name .. " ]\n" or " "
        for _, info in next, group.info do
            if group.settings[info.name] then
                data = data .. "[ " .. info.display .. ": " .. info.func(v) .. " ]\n"
            end
        end
        data = string.sub(data, 1, #data - 1)

        v.data.Text = data
        v.data.Position = middle - vector2New(0, v.data.TextBounds.Y / 2)
        v.data.Visible = vis
    end
end

game:GetService("RunService").Stepped:Connect(function(duration, interval)
    for i, v in next, espv4.groups do
        if v.mode == "players" then
            updatePlayers(v)
        elseif v.mode == "npcs" then
            updateNpcs(v)
        elseif v.mode == "items" then
            updateItems(v)
        end
    end
end)

--[[ ==========  Main Module  ========== ]]

local group = {}
group.__index = group

function group.new(mode, options)
    local inst = setmetatable({
        mode = mode,
        exclusions = options and options.exclusions or {},
        info = options and options.info or {},
        settings = {},
        container = {}
    }, group)

    if mode == "players" then
        inst.settings.names = false
        inst.settings.boxes = false
        inst.settings.skeletons = false
		inst.settings.bars = false
        inst.settings.tracers = false
        inst.settings.teammates = false
        inst.settings.size = 14
        inst.settings.boxThickness = 1
        inst.settings.skeletonThickness = 1
		inst.settings.origin = origin
    elseif mode == "npcs" then
        inst.settings.names = false
        inst.settings.boxes = false
        inst.settings.skeletons = false
		inst.settings.bars = false
        inst.settings.tracers = false
        inst.settings.size = 14
        inst.settings.boxThickness = 1
        inst.settings.skeletonThickness = 1
		inst.settings.origin = origin
    elseif mode == "items" then
        inst.settings.names = false
        inst.settings.size = 14
		inst.settings.origin = origin
    end

    for i, v in next, inst.info do
        inst.settings[v.name] = false
    end

    espv4.groups[#espv4.groups + 1] = inst
    return inst
end

function group:Add(model, options)
    local inst = {
        model = model,
        name = options and options.name or model.Name,
        health = 0
    }

    if self.mode == "players" or self.mode == "npcs" then
        inst.map = mapCharacter(model, self.exclusions)
        inst.tracer = newLine(self.settings.boxThickness)
        inst.name = newText(self.settings.size, inst.name)
        inst.data = newText(self.settings.size)
        inst.box = newQuad(self.settings.boxThickness, false)
        inst.bar = newQuad(1, true)
        inst.skeleton = {}
        for i, v in next, inst.map do
            inst.skeleton[i] = newLine(self.settings.skeletonThickness)
        end
        inst.tracer.From = self.settings.origin
    elseif self.mode == "items" then
        inst.data = newText(self.settings.size, inst.name)
    end

    self.container[#self.container + 1] = inst

    inst.conn = model.AncestryChanged:Connect(function(_, parent)
        if parent == options.removed then
            self:Remove(model)
        end
    end)
end

function group:Remove(model)
    for i, v in next, self.container do
        if v.model == model then
            v.conn:Disconnect()
            if self.mode == "players" or self.mode == "npcs" then
                v.tracer:Remove()
                v.name:Remove()
                v.data:Remove()
                v.box:Remove()
                v.bar:Remove()
                for idx, holder in next, v.map do
                    v.skeleton[idx]:Remove()
                end
            elseif self.mode == "items" then
                v.data:Remove()
            end
            self.container[i] = nil
            break
        end
    end
end

function group:GetHealth(inst)
    if not inst.model:FindFirstChild("Humanoid") then
        return 0
    end
    return mathFloor((inst.model.Humanoid.Health / inst.model.Humanoid.MaxHealth) * 100) / 100
end

function group:IsEnemy(inst)
    return players:GetPlayerFromCharacter(inst.model).Team ~= player.Team
end

function group:UpdateTextSize(value)
    self.settings.size = value
    for i, v in next, self.container do
        if self.mode == "players" or self.mode == "npcs" then
            v.name.Size = value
        end
        v.data.Size = value
    end
end

function group:UpdateBoxThickness(value)
    if self.mode == "players" or self.mode == "npcs" then
        self.settings.boxThickness = value
        for i, v in next, self.container do
            v.box.Thickness = value
        end
    end
end

function group:UpdateSkeletonThickness(value)
    if self.mode == "players" or self.mode == "npcs" then
        self.settings.skeletonThickness = value
        for _, holder in next, self.container do
            for i, v in next, holder.skeleton do
                v.Thickness = value
            end
        end
    end
end

espv4.group = group

--[[ ==========  Return  ========== ]]

return espv4