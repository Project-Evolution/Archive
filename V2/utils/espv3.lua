--[[

    Hello, Skid!

    Feel free to use this if ur happy admitting u don't know how to make a pretty simple esp

]]

--[[ ==========  Variables  ========== ]]

local player = game:GetService("Players").LocalPlayer
local heartbeat = game:GetService("RunService").Heartbeat
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

local esp = {
    settings = {
        names = false,
        boxes = false,
        distance = false,
        healthPercentage = false,
		healthBar = false,
        tracers = false,
        showTeammates = false,
        textSize = 14,
		tracerOrigin = vector2New(cam.ViewportSize.X / 2, cam.ViewportSize.Y - 10)
    },
    container = {}
}

--[[ ==========  Internal Functions  ========== ]]

local function getViewportPoint(pos)
    local screenPos, vis = worldToViewportPoint(cam, pos)
    return vector2New(screenPos.X, screenPos.Y), vis
end

local function getColour(health)
	return color3New(health < .5 and 1 or 1 - ((health - 0.5) * 2), health > .5 and 1 or health * 2, 0)
end

local function newText(content)
    local text = drawingNew("Text")
    text.Center = true
    text.Color = white
    text.Outline = false
    text.Size = esp.settings.textSize
    text.Text = "[" .. (content or "") .. "]"
    text.Visible = false
    return text
end

local function newLine()
    local line = drawingNew("Line")
    line.Color = white
    line.Thickness = 1
    line.Visible = false
    return line
end

local function newQuad(filled)
    local quad = drawingNew("Quad")
    quad.Color = white
	quad.Filled = filled
    quad.Thickness = 1
    quad.Visible = false
    return quad
end

--[[ ==========  Main Loop  ========== ]]

heartbeat:Connect(function()
	for model, playerEsp in next, esp.container do
        local pos, size = getBoundingBox(model)
        size = size / 2

        local isEnemy = esp:IsEnemy(playerEsp.player)
		local healthValue = esp:GetHealth(model)

        local topLeft, vis = getViewportPoint((pos * cframeNew(size.x, size.y, 0)).Position)
        local topRight = getViewportPoint((pos * cframeNew(-size.x, size.y, 0)).Position)
        local bottomLeft = getViewportPoint((pos * cframeNew(size.x, -size.y, 0)).Position)
        local bottomRight = getViewportPoint((pos * cframeNew(-size.x, -size.y, 0)).Position)
		local absoluteTopLeft = topLeft.X > topRight.X and topRight or topLeft
		local absoluteBottomLeft = bottomLeft.X > bottomRight.X and bottomRight or bottomLeft
		local barWidth = mathMin(mathAbs(topLeft.X - topRight.X) / 5, 16)
		local gradient = (topRight.Y - topLeft.Y) / (topRight.X - topLeft.X)
		local barOffset = vector2New(barWidth, barWidth * gradient)
		local bottomOffset = vector2New(absoluteBottomLeft.X - (barWidth / 4), absoluteBottomLeft.Y)
		local topOffset = bottomOffset - ((absoluteBottomLeft - absoluteTopLeft) * healthValue)

        playerEsp.name.Position = (topLeft + (topRight - topLeft) / 2) - vector2New(0, playerEsp.name.TextBounds.Y)
        playerEsp.name.Visible = esp.settings.names and (isEnemy or esp.settings.showTeammates) and vis

        playerEsp.data.Position = bottomLeft + (bottomRight - bottomLeft) / 2
        local dataText = ""
        if esp.settings.distance then
            dataText = dataText .. "[" .. mathFloor((pos.Position - cam.CFrame.Position).Magnitude + 0.5) .. "]"
        end
        if esp.settings.healthPercentage then
            dataText = dataText .. "[" .. healthValue * 100 .. "%]"
        end
        playerEsp.data.Text = dataText
        playerEsp.data.Visible = (esp.settings.distance or esp.settings.healthPercentage) and (isEnemy or esp.settings.showTeammates) and vis
		
		playerEsp.healthBar.PointA = topOffset
        playerEsp.healthBar.PointB = topOffset - barOffset
        playerEsp.healthBar.PointC = bottomOffset - barOffset
        playerEsp.healthBar.PointD = bottomOffset
		playerEsp.healthBar.Color = getColour(healthValue)
        playerEsp.healthBar.Visible = esp.settings.healthBar and (isEnemy or esp.settings.showTeammates) and vis

        playerEsp.box.PointA = topRight
        playerEsp.box.PointB = topLeft
        playerEsp.box.PointC = bottomLeft
        playerEsp.box.PointD = bottomRight
        playerEsp.box.Visible = esp.settings.boxes and (isEnemy or esp.settings.showTeammates) and vis

        playerEsp.tracer.To = bottomLeft + (bottomRight - bottomLeft) / 2
        playerEsp.tracer.Visible = esp.settings.tracers and (isEnemy or esp.settings.showTeammates) and vis
	end
end)

--[[ ==========  External Functions  ========== ]]

function esp:AddEsp(plr, model)
    local container = {
		player = plr,
        tracer = newLine(),
        name = newText(plr.Name),
        data = newText(),
        box = newQuad(false),
        healthBar = newQuad(true),
		ancestryChanged = model.AncestryChanged:Connect(function()
			self:RemoveEsp(model)
		end)
    }

	container.tracer.From = self.settings.tracerOrigin
	
	self:SetupTeamChange(plr, container)
    self.container[model] = container
end

function esp:IsEnemy(plr) -- so games with custom teams can be overwritten
    return plr.Team ~= player.Team
end

function esp:SetupTeamChange(plr, container) -- so games with custom teams can be overwritten
    self:UpdateTeamColour(container, plr.TeamColor.Color)
    container.teamUpdate = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
        self:UpdateTeamColour(container, plr.TeamColor.Color)
    end)
end

function esp:GetHealth(model) -- so games with custom characters can be overwritten
    return mathFloor((model.Humanoid.Health / model.Humanoid.MaxHealth) * 100) / 100
end

function esp:UpdateTeamColour(container, colour)
    container.box.Color = colour
    container.tracer.Color = colour
end

function esp:UpdateTextSize(size)
    self.settings.textSize = size
    for i, v in next, self.container do
        v.name.Size = size
        v.data.Size = size
    end
end

function esp:UpdateTracerOrigin(vec2)
	self.settings.tracerOrigin = vec2
    for i, v in next, self.container do
        v.tracer.From = vec2
    end
end

function esp:RemoveEsp(model)
    local container = self.container[model]
    if container then
		container.ancestryChanged:Disconnect()
		if container.teamUpdate then
			container.teamUpdate:Disconnect()
		end
        container.name:Remove()
        container.data:Remove()
        container.tracer:Remove()
        container.box:Remove()
		container.healthBar:Remove()
        self.container[model] = nil
    end
end

--[[ ==========  Return  ========== ]]

return esp