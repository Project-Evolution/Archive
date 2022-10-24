--[[

	Notes:

	Yes, I know this isn't obfuscated

]]

--[[ Variables ]]--

local players = game:GetService("Players")

local player = players.LocalPlayer
local cam = workspace.CurrentCamera
local viewport = cam.ViewportSize
local centerscreen = viewport / 2

local abs = math.abs
local cos = math.cos
local rad = math.rad
local sin = math.sin

local inf = math.huge

local esp = {
	groups = {}
}

--[[ Internal Functions ]]--

local function newtext(inst, size, centered, content, font)
	local item = inst.cache:add("Text", {
		Center = centered,
		Color = Color3.new(1, 1, 1),
		Outline = false,
		Size = size,
		Text = content or "",
		Visible = false
	})
	if font then
		item.Font = font
	end
	return item
end

local function newline(inst, thickness)
	return inst.cache:add("Line", {
		Color = Color3.new(1, 1, 1),
		Thickness = thickness,
		Visible = false
	})
end

local function newsquare(inst, thickness, filled)
	return inst.cache:add("Square", {
		Color = Color3.new(1, 1, 1),
		Filled = filled,
		Thickness = thickness,
		Visible = false
	})
end

local function newtriangle(inst)
	return inst.cache:add("Triangle", {
		Color = Color3.new(1, 1, 1),
		Filled = true,
		Visible = false
	})
end

local function getboundsremake(model, desc) -- Nicked & modified from the dev forums
	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf
	local array = desc and model:GetDescendants() or model:GetChildren()
	for i = 1, #array do
		local obj = array[i]
		if obj:IsA("BasePart") then
		    local size = obj.Size
		    local sx, sy, sz = size.X, size.Y, size.Z
			local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = obj.CFrame:components()
			local wsx = 0.5 * (abs(r00) * sx + abs(r01) * sy + abs(r02) * sz)
			local wsy = 0.5 * (abs(r10) * sx + abs(r11) * sy + abs(r12) * sz)
			local wsz = 0.5 * (abs(r20) * sx + abs(r21) * sy + abs(r22) * sz)
			if minx > x - wsx then
				minx = x - wsx
			end
			if miny > y - wsy then
				miny = y - wsy
			end
			if minz > z - wsz then
				minz = z - wsz
			end
			if maxx < x + wsx then
				maxx = x + wsx
			end
			if maxy < y + wsy then
				maxy = y + wsy
			end
			if maxz < z + wsz then
				maxz = z + wsz
			end
		end
	end
	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return (omax + omin) / 2, omax - omin
end

local function rotatevector(vec, angle)
	local rad = rad(angle)
	return Vector2.new(vec.X * cos(rad) - vec.Y * sin(rad), vec.X * sin(rad) + vec.Y * cos(rad))
end

local function worldtoviewport(pos)
	local screenpos, vis = cam:WorldToViewportPoint(pos)
	return Vector2.new(screenpos.X, screenpos.Y), vis
end

local function updateplayers(espgroup, isnpc)
	local camcf = cam.CFrame
	for i = 1, #espgroup.container do
		local inst = espgroup.container[i]
		local pos, size = getboundsremake(inst.model, espgroup.settings.scandescendants)
		local cf = CFrame.new(pos, cam.CFrame.Position)

		local radius = size * 0.5
		local spos, vis = worldtoviewport(pos)
		local shouldshow = isnpc or espgroup.settings.teammates or espgroup:isenemy(inst)
		if vis and shouldshow then
			local minx, miny, maxx, maxy = inf, inf, 0, 0
			local vertexes = {
				(cf * CFrame.new(radius.X, radius.Y, 0)).Position,
				(cf * CFrame.new(radius.X, -radius.Y, 0)).Position,
				(cf * CFrame.new(-radius.X, radius.Y, 0)).Position,
				(cf * CFrame.new(-radius.X, -radius.Y, 0)).Position
			}

			for i = 1, #vertexes do
				local vpos = worldtoviewport(vertexes[i])
				if vpos.X < minx then
					minx = vpos.X
				end
				if vpos.X > maxx then
					maxx = vpos.X
				end
				if vpos.Y < miny then
					miny = vpos.Y
				end
				if vpos.Y > maxy then
					maxy = vpos.Y
				end
			end

			local topleft = Vector2.new(minx, miny)
			local topright = Vector2.new(maxx, miny)
			local bottomleft = Vector2.new(minx, maxy)
			local bottomright = Vector2.new(maxx, maxy)

			inst.box.Position = topleft
			inst.box.Size = bottomright - topleft
			inst.box.Visible = espgroup.settings.boxes

			inst.name.Position = Vector2.new(spos.X, topleft.Y - inst.name.TextBounds.Y)
			inst.name.Visible = espgroup.settings.names

			inst.dist.Position = Vector2.new(spos.X, bottomleft.Y)
			inst.dist.Text = tostring(math.round((pos - cam.CFrame.Position).Magnitude))
			inst.dist.Visible = espgroup.settings.distances

			if espgroup.settings.skeletons then
				local skeleton = {}
				for idx = 1, #inst.map do
					local holder = inst.map[idx]
					if not skeleton[holder[1]] then
						skeleton[holder[1]] = worldtoviewport(holder[1].Position)
					end
					if not skeleton[holder[2]] then
						skeleton[holder[2]] = worldtoviewport(holder[2].Position)
					end
					inst.skeleton[idx].From = skeleton[holder[1]]
					inst.skeleton[idx].To = skeleton[holder[2]]
					inst.skeleton[idx].Visible = true
				end
			else
				for idx = 1, #inst.map do
					inst.skeleton[idx].Visible = false
				end
			end

			inst.health = espgroup:gethealth(inst)
			local healthvalue = (bottomleft.Y - topleft.Y) * inst.health

			inst.bar.Position = Vector2.new(bottomleft.X - 4, bottomleft.Y - healthvalue)
			inst.bar.Size = Vector2.new(2, healthvalue)
			inst.bar.Color = Color3.new(inst.health < 0.5 and 1 or 1 - ((inst.health - 0.5) * 2), inst.health > 0.5 and 1 or inst.health * 2, 0)
			inst.bar.Visible = espgroup.settings.bars

			if inst.data then
				local data = ""
				for name, func in next, espgroup.info do
					if espgroup.settings[name] then
						data = data .. func(inst) .. "\n"
					end
				end

				inst.data.Position = Vector2.new(topright.X + 2, topright.Y)
				inst.data.Text = string.sub(data, 1, #data - 1)
				inst.data.Visible = true
			end

			inst.tracer.To = Vector2.new(spos.X, bottomleft.Y)
			inst.tracer.Visible = espgroup.settings.tracers

			inst.arrow.Visible = false
		else
			inst.cache:hide()
			if shouldshow and espgroup.settings.offscreenarrows then
				local ray = camcf:PointToObjectSpace(pos)
				local direction = -Vector2.new(ray.X, ray.Z).Unit
				local bottomcenter = direction * espgroup.settings.arrowoffset
				local widthradius = espgroup.settings.arrowwidth / 2
				inst.arrow.PointA = centerscreen - (bottomcenter + rotatevector(direction, 90) * widthradius)
				inst.arrow.PointB = centerscreen - (bottomcenter + rotatevector(direction, -90) * widthradius)
				inst.arrow.PointC = centerscreen - (direction * (espgroup.settings.arrowoffset + espgroup.settings.arrowheight))
				inst.arrow.Visible = true
			else
				inst.arrow.Visible = false
			end
		end
	end
end

local function updateitems(espgroup)
	for i = 1, #espgroup.container do
		local inst = espgroup.container[i]
		local pos, size = getboundsremake(inst.model)
		local spos, vis = worldtoviewport(pos)
		if vis then
			local data = espgroup.settings.names and inst.name .. "\n" or ""
			data = data .. (espgroup.settings.distances and math.round((pos - cam.CFrame.Position).Magnitude) .. "\n" or "")

			for name, func in next, espgroup.info do
				if espgroup.settings[name] then
					data = data .. func(inst) .. "\n"
				end
			end

			inst.data.Text = string.sub(data, 1, #data - 1)
			inst.data.Position = spos - Vector2.new(0, inst.data.TextBounds.Y / 2)
			inst.data.Visible = true
		else
			inst.data.Visible = false
		end
	end
end

--[[ Functions ]]--

function esp:createmap(model, excluded)
	local map = {}
	for i, v in next, model:GetDescendants() do
		if v.ClassName == "Motor6D" and v.Part0 ~= nil and not excluded[v.Part0.Name] and v.Part1 ~= nil and not excluded[v.Part1.Name] then
			map[#map + 1] = { v.Part0, v.Part1 }
		end
	end
	return map
end

function esp:dispose()
	self.conn:Disconnect()
	for i = 1, #self.groups do
		local espgroup = self.groups[i]
		for _, v in next, espgroup.container do
			espgroup:remove(v)
		end
	end
end

--[[ Groups ]]--

local group = {}
group.__index = group

function group.new(mode, options)
	local inst = setmetatable({
		mode = mode,
		exclusions = options and options.exclusions or {},
		info = options and options.info or {},
		settings = {
			enabled = false,
			names = false,
			distances = false,
			size = 14
		},
		container = {}
	}, group)

	if mode == "players" then
		inst.settings.boxes = false
		inst.settings.skeletons = false
		inst.settings.bars = false
		inst.settings.tracers = false
		inst.settings.teammates = false
		inst.settings.offscreenarrows = false
		inst.settings.scandescendants = false
		inst.settings.usedisplaynames = false
		inst.settings.usecustomcolours = false
		inst.settings.friendlycolour = Color3.new(0, 1, 0)
		inst.settings.enemycolour = Color3.new(1, 0, 0)
		inst.settings.thickness = 1
		inst.settings.origin = Vector2.new(centerscreen.X, viewport.Y - 10)
		inst.settings.arrowoffset = 120
		inst.settings.arrowheight = 18
		inst.settings.arrowwidth = 12
	elseif mode == "npcs" then
		inst.settings.boxes = false
		inst.settings.skeletons = false
		inst.settings.bars = false
		inst.settings.tracers = false
		inst.settings.offscreenarrows = false
		inst.settings.scandescendants = false
		inst.settings.thickness = 1
		inst.settings.colour = Color3.new(1, 1, 1)
		inst.settings.origin = Vector2.new(centerscreen.X, viewport.Y - 10)
		inst.settings.arrowoffset = 120
		inst.settings.arrowheight = 18
		inst.settings.arrowwidth = 12
	elseif mode == "items" then
		inst.settings.colour = Color3.new(1, 1, 1)
	end

	for i, v in next, inst.info do
		inst.settings[i] = false
	end

	esp.groups[#esp.groups + 1] = inst
	return inst
end

function group:add(model, options)
	local inst = {
		model = model,
		player = self:getplayerfromcharacter(model), -- it'll just be nil if there isn't one (npcs and items)
		name = options and options.name or model.Name,
		cache = evov3.imports:fetchsystem("drawing"),
		colour = options.colour
	}

	if self.mode == "players" or self.mode == "npcs" then
		inst.health = 0
		inst.map = options and options.map or esp:createmap(model, self.exclusions)
		inst.tracer = newline(inst, self.settings.thickness)
		inst.name = newtext(inst, self.settings.size, true, inst.player and inst.player[self.settings.usedisplaynames and "DisplayName" or "Name"] or inst.name, self.settings.font)
		inst.dist = newtext(inst, self.settings.size, true, nil, self.settings.font)
		inst.box = newsquare(inst, self.settings.thickness, false)
		inst.bar = newsquare(inst, 1, true)
		inst.arrow = newtriangle(inst)
		if evov3.utils:tablecount(self.info) > 0 then
			inst.data = newtext(inst, self.settings.size, false, nil, self.settings.font)
		end
		inst.skeleton = {}
		for i = 1, #inst.map do
			inst.skeleton[i] = newline(inst, self.settings.thickness)
		end
		inst.tracer.From = self.settings.origin
	elseif self.mode == "items" then
		inst.data = newtext(inst, self.settings.size, true, inst.name, self.settings.font)
	end

	inst.conn = model.AncestryChanged:Connect(function(_, parent)
		if options.alwaysremove or parent == options.removed then
			self:remove(inst)
		end
	end)

	table.insert(self.container, inst)

	if self.mode == "players" then
		self:highlight(model, self.settings.usecustomcolours and self.settings[self:isenemy(inst) and "enemycolour" or "friendlycolour"] or inst.colour)
	else
		self:highlight(model, self.settings.colour)
	end
end

function group:remove(inst)
	local index = nil
	for i = 1, #self.container do
		local v = self.container[i]
		if v == inst then
			index = i
			break
		end
	end
	if index then
		inst.cache:clear()
		inst.conn:Disconnect()
		table.remove(self.container, index)
	end
end

function group:getplayerfromcharacter(model)
	return players:GetPlayerFromCharacter(model)
end

function group:gethealth(inst)
	if not inst.model:FindFirstChild("Humanoid") then
		return 0
	end
	return math.floor((inst.model.Humanoid.Health / inst.model.Humanoid.MaxHealth) * 100) * 0.01
end

function group:isenemy(inst)
	return inst.player.Team ~= player.Team
end

function group:updatenames(display)
	self.settings.usedisplaynames = display
	for i = 1, #self.container do
		local inst = self.container[i]
		inst.name.Text = inst.player[display and "DisplayName" or "Name"]
	end
end

function group:updatetextsize(value)
	self.settings.size = value
	for i = 1, #self.container do
		local inst = self.container[i]
		if self.mode == "players" or self.mode == "npcs" then
			inst.name.Size = value
		end
		if inst.data then
			inst.data.Size = value
		end
	end
end

function group:updatethickness(value)
	if self.mode == "players" or self.mode == "npcs" then
		self.settings.thickness = value
		for i = 1, #self.container do
			local inst = self.container[i]
			inst.box.Thickness = value
			inst.tracer.Thickness = value
			for idx = 1, #inst.skeleton do
				inst.skeleton[idx].Thickness = value
			end
		end
	end
end

function group:highlight(model, colour)
	if self.mode == "players" or self.mode == "npcs" then
		for i = 1, #self.container do
			local inst = self.container[i]
			if inst.model == model then
				inst.box.Color = colour
				inst.tracer.Color = colour
				inst.arrow.Color = colour
				for idx = 1, #inst.skeleton do
					inst.skeleton[idx].Color = colour
				end
			end
		end
	else
		for i = 1, #self.container do
			local inst = self.container[i]
			if inst.model == model then
				inst.data.Color = colour
			end
		end
	end
end

function group:togglecustomcolours(bool)
	if self.mode == "players" then
		self.settings.usecustomcolours = bool
		for i = 1, #self.container do
			local inst = self.container[i]
			local colour = bool and self.settings[self:isenemy(inst) and "enemycolour" or "friendlycolour"] or inst.colour
			inst.box.Color = colour
			inst.tracer.Color = colour
			inst.arrow.Color = colour
			for idx = 1, #inst.skeleton do
				inst.skeleton[idx].Color = colour
			end
		end
	end
end

function group:updatecustomcolour(colour, friendly)
	if self.mode == "players" then
		self.settings[friendly and "friendlycolour" or "enemycolour"] = colour
		if self.settings.usecustomcolours then
			for i = 1, #self.container do
				local inst = self.container[i]
				if self:isenemy(inst) == not friendly then
					inst.box.Color = colour
					inst.tracer.Color = colour
					inst.arrow.Color = colour
					for idx = 1, #inst.skeleton do
						inst.skeleton[idx].Color = colour
					end
				end
			end
		end
	elseif self.mode == "npcs" then
		self.settings.colour = colour
		for i = 1, #self.container do
			inst.box.Color = colour
			inst.tracer.Color = colour
			inst.arrow.Color = colour
			for idx = 1, #inst.skeleton do
				inst.skeleton[idx].Color = colour
			end
		end
	else
		self.settings.colour = colour
		for i = 1, #self.container do
			self.container[i].data.Color = colour
		end
	end
end

function group:updatefont(font)
	self.settings.font = font
	for i = 1, #self.container do
		local inst = self.container[i]
		for _, v in next, { "name", "dist", "data" } do
			if inst[v] then
				inst[v].Font = font
			end
		end
	end
end

--[[ Updater ]]--

game:GetService("RunService").Heartbeat:Connect(function()
	for i = 1, #esp.groups do
		local espgroup = esp.groups[i]
		if espgroup.settings.enabled then
			if espgroup.mode == "players" then
				updateplayers(espgroup)
			elseif espgroup.mode == "npcs" then
				updateplayers(espgroup, true)
			elseif espgroup.mode == "items" then
				updateitems(espgroup)
			end
		else
			for i = 1, #espgroup.container do
				espgroup.container[i].cache:hide()
			end
		end
	end
end)

--[[ Return ]]--

esp.group = group
evov3.esp = esp
return esp