local system = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V2/utils/systems.lua"))()
local tracer = system.new("Tracer")
local discord = system.new("Discord")

local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local textService = game:GetService("TextService")
local httpService = game:GetService("HttpService")
local coreGui = game:GetService("CoreGui")
local virtualUser = game:GetService("VirtualUser")
local heartbeat = game:GetService("RunService").Heartbeat

local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()
local cam = workspace.CurrentCamera

local hugeVector2 = Vector2.new(math.huge, math.huge)

local placeholderBoxSize = textService:GetTextSize("Enter Text...", 12, Enum.Font.Gotham, hugeVector2).X + 16
local placeholderBindSize = textService:GetTextSize("[ None ]", 12, Enum.Font.Gotham, hugeVector2).X + 16
local ellipsisBindSize = textService:GetTextSize("[ ... ]", 12, Enum.Font.Gotham, hugeVector2).X + 16

local blacklistedKeys = {
	[Enum.KeyCode.Unknown] = true
}

local whitelistedTypes = { 
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true
}

local themes = {
	selected = "Default",
	Default = {
		textForeground = Color3.fromRGB(235, 235, 235),
		notifTextForeground = Color3.fromRGB(180, 180, 180),
		imageForeground = Color3.fromRGB(235, 235, 235),
		mainBackground = Color3.fromRGB(27, 27, 27),
		topBackground = Color3.fromRGB(34, 34, 34),
		panelBackground = Color3.fromRGB(34, 34, 34),
		panelItemBackground = Color3.fromRGB(27, 27, 27),
		toggleEnabled = Color3.fromRGB(15, 180, 85),
		sliderHighlight = Color3.fromRGB(64, 64, 64),
		notifTimeoutHighlight = Color3.fromRGB(72, 72, 72),
		hoverEffect = Color3.fromRGB(48, 48, 48),
		clickEffect = Color3.fromRGB(64, 64, 64)
	},
	Discord = {
		textForeground = Color3.fromRGB(220, 221, 222),
		notifTextForeground = Color3.fromRGB(185, 187, 190),
		imageForeground = Color3.fromRGB(185, 187, 190),
		mainBackground = Color3.fromRGB(47, 49, 54),
		topBackground = Color3.fromRGB(41, 43, 47),
		panelBackground = Color3.fromRGB(54, 57, 63),
		panelItemBackground = Color3.fromRGB(47, 49, 54),
		toggleEnabled = Color3.fromRGB(88, 101, 242),
		sliderHighlight = Color3.fromRGB(88, 101, 242),
		notifTimeoutHighlight = Color3.fromRGB(88, 101, 242),
		hoverEffect = Color3.fromRGB(52, 55, 60),
		clickEffect = Color3.fromRGB(57, 60, 67)
	},
	OperaGX = {
		textForeground = Color3.fromRGB(255, 255, 255),
		notifTextForeground = Color3.fromRGB(176, 175, 178),
		imageForeground = Color3.fromRGB(250, 30, 78),
		mainBackground = Color3.fromRGB(18, 16, 25),
		topBackground = Color3.fromRGB(9, 8, 13),
		panelBackground = Color3.fromRGB(28, 23, 38),
		panelItemBackground = Color3.fromRGB(18, 16, 25),
		toggleEnabled = Color3.fromRGB(250, 30, 78),
		sliderHighlight = Color3.fromRGB(250, 30, 78),
		notifTimeoutHighlight = Color3.fromRGB(250, 30, 78),
		hoverEffect = Color3.fromRGB(76, 19, 38),
		clickEffect = Color3.fromRGB(46, 39, 63)
	}
}

local themeProperties = {
	textForeground = "TextColor3",
	notifTextForeground = "TextColor3",
	imageForeground = "ImageColor3",
	mainBackground = "BackgroundColor3",
	topBackground = "BackgroundColor3",
	panelBackground = "BackgroundColor3",
	panelItemBackground = "BackgroundColor3",
	toggleEnabled = "BackgroundColor3",
	sliderHighlight = "BackgroundColor3",
	notifTimeoutHighlight = "BackgroundColor3"
}

local themeMeta = setmetatable({
	items = {}
}, {
	__index = function(t, k)
		if rawget(t, "currentItem") and not rawget(t, "items")[k][rawget(t, "currentItem")] then
			t.items[k][t.currentItem] = true
		end
		return themes[themes.selected][k]
	end
})

if not isfolder("EvoV2\\Themes") then
	pcall(makefolder, "EvoV2")
	pcall(makefolder, "EvoV2\\Themes")
end

for i, v in next, themes.Default do
	themeMeta.items[i] = {}
end

local function create(className, properties, children, round)
	local instance, properties = Instance.new(className), properties or {}
	themeMeta.currentItem = instance
	for i, v in next, properties do
		if i ~= "Parent" then
			instance[i] = type(v) == "string" and v:find("theme.") and themeMeta[v:gsub("theme.", "")] or v
		end
	end
	if children then
		for i, v in next, children do
			v.Parent = instance
		end
	end
	if round then
		create("UICorner", { Name = "uicorner", CornerRadius = round, Parent = instance })
	end
	instance.Parent = properties.Parent
	themeMeta.currentItem = nil
	return instance
end

local function doOptimalParenting(gui)
	if gethui then
		gui.Parent = gethui()
	else
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		end
		gui.Parent = coreGui
	end
end

local function tween(instance, duration, properties, style)
	local t = tweenService:Create(instance, TweenInfo.new(duration, style or Enum.EasingStyle.Sine), properties)
	t:Play()
	return t
end

local function getFlagForm(name)
	return name:gsub(" ", ""):lower()
end

local function addMouseEffects(guiObject, normalColour, hoverColour, clickColour)
	local isMouseDown, isMouseOver = false, false
	if hoverColour then
		guiObject.MouseEnter:Connect(function()
			isMouseOver = true
			tween(guiObject, 0.2, { BackgroundColor3 = themeMeta[hoverColour] })
		end)
		guiObject.MouseLeave:Connect(function()
			isMouseOver = false
			if isMouseDown == false then
				tween(guiObject, 0.2, { BackgroundColor3 = themeMeta[normalColour] })
			end
		end)
	end
	if clickColour then
		if guiObject.ClassName == "Frame" then
			guiObject.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isMouseDown = true
					tween(guiObject, 0.2, { BackgroundColor3 = themeMeta[clickColour] })
					local conn
					conn = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							conn:Disconnect()
							isMouseDown = false
							tween(guiObject, 0.2, { BackgroundColor3 = isMouseOver and themeMeta[hoverColour] or themeMeta[normalColour] })
						end
					end)
				end
			end)
		elseif guiObject.ClassName == "TextButton" then
			guiObject.MouseButton1Down:Connect(function()
				isMouseDown = true
				tween(guiObject, 0.2, { BackgroundColor3 = themeMeta[clickColour] })
			end)
			guiObject.MouseButton1Up:Connect(function()
				isMouseDown = false
				tween(guiObject, 0.2, { BackgroundColor3 = isMouseOver and themeMeta[hoverColour] or themeMeta[normalColour] })
			end)
		end
	end
end

local function makeDraggable(library, frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and library._settings.dragging == false then
			library._settings.dragging = true
			local offset = Vector2.new(frame.AbsoluteSize.X * frame.AnchorPoint.X, frame.AbsoluteSize.Y * frame.AnchorPoint.Y)
			local pos = Vector2.new(mouse.X - (frame.AbsolutePosition.X + offset.X), mouse.Y - (frame.AbsolutePosition.Y + offset.Y))
			local dragConn, conn
			dragConn = mouse.Move:Connect(function()
				tween(frame, 0.125, { Position = UDim2.new(0, mouse.X - pos.X, 0, mouse.Y - pos.Y) })
			end)
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					library._settings.dragging = false
					dragConn:Disconnect()
					conn:Disconnect()
				end
			end)
		end
	end)
end

local function autoResizeList(frame)
	local isScrollable, layout = frame.ClassName == "ScrollingFrame", frame:FindFirstChildOfClass("UIListLayout")
	local function resize()
		local size, offset = 0, layout.Padding.Offset
		for i, v in next, frame:GetChildren() do
			if v ~= layout then
				size = size + v.AbsoluteSize.Y + offset
			end
		end
		frame[isScrollable and "CanvasSize" or "Size"] = UDim2.new(0, isScrollable and 0 or frame.AbsoluteSize.X, 0, size - offset)
	end
	frame.ChildAdded:Connect(function(child)
		child:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		resize()
	end)
end

local function autoResizeGrid(frame)
	local layout = frame:FindFirstChildOfClass("UIGridLayout")
	local function resize()
		local maxSize, offset = 0, layout.CellPadding.Y.Offset
		for i, v in next, frame:GetChildren() do
			if v ~= layout then
				local size = v.AbsolutePosition.Y + frame.CanvasPosition.Y - frame.AbsolutePosition.Y + v.AbsoluteSize.Y + offset
				if size > maxSize then
					maxSize = size
				end
			end
		end
		frame.CanvasSize = UDim2.new(0, 0, 0, maxSize)
	end
	frame.ChildAdded:Connect(function(child)
		child:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		heartbeat:Wait() -- takes time for UISizeConstraints to apply because roblox is the gayest thing since your mum
		resize()
	end)
end

local function organiseNotifs(notifDir)
	local yOffset, notifs = -30, notifDir:GetChildren()
	for i = #notifs, 1, -1 do
		local v = notifs[i]
		tween(v, 0.35, { Position = UDim2.new(1, -10, 1, yOffset) })
		yOffset = yOffset - (v.AbsoluteSize.Y + 10)
	end
end

local function round(val, nearest)
	local value, remaining = math.modf(val / nearest)
	return nearest * (value + (remaining > 0.5 and 1 or 0))
end

local function jsonEncodeTheme(theme)
	local themeTxt = "{\n"
	for i, v in next, theme do
		themeTxt = themeTxt .. "\n    \"" .. i .. "\": {\n        \"R\": " .. math.floor(v.R * 255) .. ",\n        \"G\": " .. math.floor(v.G * 255) .. ",\n        \"B\": " .. math.floor(v.B * 255) .. "\n    },"
	end
	return themeTxt:sub(1, #themeTxt - 1) .. "\n}"
end

local function jsonDecodeTheme(themeTxt)
	local theme = {}
	for i, v in next, httpService:JSONDecode(themeTxt) do
		theme[i] = Color3.fromRGB(v.R, v.G, v.B)
	end
	return theme
end

for i, v in next, themes do
	if i ~= "selected" then
		writefile("EvoV2\\Themes\\" .. i .. ".json", jsonEncodeTheme(v))
	end
end

local profile = {}
profile.__index = profile

function profile.__newindex(t, k, v)
	if t._frame.stats:FindFirstChild(k) == nil then
		local item = create("TextLabel", { Name = k, BackgroundTransparency = 1, Font = Enum.Font.Gotham, Parent = t._frame.stats, Position = UDim2.new(0.5, 10, 0, 15 + (20 * #t._frame.stats:GetChildren())), Size = UDim2.new(0.5, -20, 0, 14), TextColor3 = "theme.textForeground", TextSize = 14, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right })
		tween(t._frame.uisizecon, 0.35, { MinSize = Vector2.new(515, math.max(104, 24 + (20 * #t._frame.stats:GetChildren()))) }, Enum.EasingStyle.Linear)
		tween(item, 0.35, { TextTransparency = 0 })
	end
	t._frame.stats[k].Text = k .. ": " .. tostring(v)
end

local panel = {}
panel.__index = panel

function panel:AddLabel(name, options)
	local label = {
		_class = "Label",
		_name = name,
		_frame = create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font[options and options.bold and "GothamSemibold" or "Gotham"], Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left })
	}

	function label:Update(text)
		self._frame.label.Text = text
	end

	self._items[#self._items + 1] = label
	return label
end

function panel:AddStatusLabel(name, status, options)
	local statusLabel = {
		_class = "StatusLabel",
		_name = name,
		_frame = create("Frame", { Name = name, BackgroundTransparency = 1, Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Parent = self._frame.container, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }),
			create("TextLabel", { Name = "status", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Parent = self._frame.container, Size = UDim2.new(1, -4, 0, 24), Text = status, TextColor3 = options and options.colour or "theme.textForeground", TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Right })
		})
	}

	function statusLabel:Update(status, colour)
		self._frame.status.Text = status
		if colour then
			self._frame.status.TextColor3 = colour
		end
	end

	self._items[#self._items + 1] = statusLabel
	return statusLabel
end

function panel:AddClipboardLabel(name, copyText, options)
	local clipboardLabel = {
		_class = "ClipboardLabel",
		_name = name,
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("Frame", { Name = "copy", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 24, 0, 24) }, {
				create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = "rbxassetid://7754906428", Size = UDim2.new(1, 0, 1, 0) })
			}, UDim.new(0, 4))
		}, UDim.new(0, 4))
	}

	clipboardLabel._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and setclipboard then
			setclipboard(copyText)
		end
	end)

	self._items[#self._items + 1] = clipboardLabel
	return clipboardLabel
end

function panel:AddButton(name, callback)
	local button = {
		_class = "Button",
		_name = name,
		_callback = callback or function() end,
		_frame = create("TextButton", { Name = name, AutoButtonColor = false, BackgroundColor3 = "theme.panelItemBackground", Font = Enum.Font.Gotham, Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13 }, nil, UDim.new(0, 4))
	}

	addMouseEffects(button._frame, "panelItemBackground", nil, "clickEffect")

	button._frame.MouseButton1Click:Connect(button._callback)

	self._items[#self._items + 1] = button
	return button
end

function panel:AddToggle(name, callback, options)
	local toggle = {
		_class = "Toggle",
		_name = options and options.flag or getFlagForm(name),
		_callback = callback or function() end,
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("Frame", { Name = "indicator", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 24, 0, 24) }, nil, UDim.new(0, 4))
		}, UDim.new(0, 4)),
		_status = {
			enabled = false
		}
	}

	function toggle:Set(value)
		tween(self._frame.indicator, 0.2, { BackgroundColor3 = value and themeMeta.toggleEnabled or themeMeta.panelItemBackground })
		self._status.enabled = value
		self._callback(value)
	end

	toggle._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggle:Set(not toggle._status.enabled)
		end
	end)

	if options and options.default then
		toggle:Set(true)
	end

	self._items[#self._items + 1] = toggle
	return toggle
end

function panel:AddBox(name, callback, options)
	local box = {
		_class = "Box",
		_name = options and options.flag or getFlagForm(name),
		_callback = callback or function() end,
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("Frame", { Name = "container", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, placeholderBoxSize, 1, 0) }, {
				create("TextBox", { Name = "box", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, PlaceholderText = "Enter Text...", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -16, 1, -2), Text = "", TextColor3 = "theme.textForeground", TextSize = 12, TextWrapped = true })
			}, UDim.new(0, 4))
		}, UDim.new(0, 4)),
		_status = {
			value = ""
		}
	}

	local maxBoxSize = 237 - textService:GetTextSize(name, 14, Enum.Font.Gotham, hugeVector2).X

	function box:Set(value)
		if value ~= "" and options and options.numOnly and not tonumber(value) then
			value = self._status.value
		end
		self._frame.container.box.Text = value
		self._status.value = value
		self._callback(value)
	end

	box._frame.container.box:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = box._frame.container.box.Text
		if txt == "" then
			box._frame.container.Size = UDim2.new(0, placeholderBoxSize, 1, 0)
			tween(box._frame, 0.2, { Size = UDim2.new(0, box._frame.AbsoluteSize.X, 0, 24) })
		else
			local size = textService:GetTextSize(txt, 12, Enum.Font.Gotham, Vector2.new(maxBoxSize - 16, math.huge))
			box._frame.container.Size = UDim2.new(0, size.X + 16, 1, 0)
			tween(box._frame, 0.2, { Size = UDim2.new(0, box._frame.AbsoluteSize.X, 0, size.Y + 12) })
		end
	end)

	box._frame.container.box.Focused:Connect(function()
		tween(box._frame.container, 0.2, { Size = UDim2.new(0, placeholderBoxSize, 1, 0) })
		tween(box._frame, 0.2, { Size = UDim2.new(0, box._frame.AbsoluteSize.X, 0, 24) })
	end)

	box._frame.container.box.FocusLost:Connect(function()
		box:Set(box._frame.container.box.Text)
	end)

	box._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			box._frame.container.box:CaptureFocus()
		end
	end)

	if options and options.default then
		box:Set(options.default)
	end

	self._items[#self._items + 1] = box
	return box
end

function panel:AddBind(name, callback, options)
	local bind = {
		_class = "Bind",
		_name = options and options.flag or getFlagForm(name),
		_callback = callback or function() end,
		_set = options and options.set or function() end,
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("TextLabel", { Name = "indicator", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Font = Enum.Font.Gotham, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, placeholderBindSize, 0, 24), Text = "[ None ]", TextColor3 = "theme.textForeground", TextSize = 12 }, nil, UDim.new(0, 4))
		}, UDim.new(0, 4)),
		_status = {
			value = ""
		}
	}

	function bind:Set(value)
		local escaped = (value == "Escape" or value == "")
		self._status.value = escaped and "" or value
		self._frame.indicator.Size = UDim2.new(0, escaped and placeholderBindSize or textService:GetTextSize("[ " .. (escaped and "None" or value) .. " ]", 12, Enum.Font.Gotham, hugeVector2).X + 16, 0, 24)
		self._frame.indicator.Text = "[ " .. (escaped and "None" or value) .. " ]"
		self._set(self._status.value)
	end

	bind._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self._tab._lib._settings.binding == false then
			self._tab._lib._settings.binding = true
			bind._frame.indicator.Size = UDim2.new(0, ellipsisBindSize, 0, 24)
			bind._frame.indicator.Text = "[ ... ]"
			task.wait(0.1)
			while true do
				local input = userInputService.InputBegan:Wait()
				if (input.UserInputType == Enum.UserInputType.Keyboard and not blacklistedKeys[input.KeyCode]) or whitelistedTypes[input.UserInputType] then
					bind:Set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name or input.UserInputType.Name)
					break
				end
			end
			task.wait(0.1)
			self._tab._lib._settings.binding = false
		end
	end)

	if options and options.default then
		bind:Set(options.default)
	end

	self._items[#self._items + 1] = bind
	return bind
end

function panel:AddSlider(name, callback, options)
	local min = options and options.min or 0
	local max = options and options.max or 100
	local float = options and options.float or 1

	local slider = {
		_class = "Slider",
		_name = options and options.flag or getFlagForm(name),
		_callback = callback or function() end,
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 32) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("TextLabel", { Name = "value", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Size = UDim2.new(1, -4, 0, 24), Text = tostring(min), TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right }),
			create("Frame", { Name = "background", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = "theme.panelItemBackground", ClipsDescendants = true, Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 4) }, {
				create("Frame", { Name = "indicator", BackgroundColor3 = "theme.sliderHighlight", Size = UDim2.new(0, 0, 1, 0) }, nil, UDim.new(1, 0))
			}, UDim.new(1, 0))
		}, UDim.new(0, 4)),
		_status = {
			value = min
		}
	}

	function slider:Set(value)
		value = math.clamp(round(value, float), min, max)
		if value ~= self._status.value then
			self._status.value = value
			tween(self._frame.background.indicator, 0.2, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) })
			self._frame.value.Text = tostring(value)
			self._callback(value)
		end
	end

	slider._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self._tab._lib._settings.dragging == false then
			self._tab._lib._settings.dragging = true
			local mouseConn, inputConn
			mouseConn = mouse.Move:Connect(function()
				slider:Set(min + ((max - min) * math.clamp((mouse.X - slider._frame.background.AbsolutePosition.X) / slider._frame.background.AbsoluteSize.X, 0, 1)))
			end)
			inputConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					mouseConn:Disconnect()
					inputConn:Disconnect()
					self._tab._lib._settings.dragging = false
				end
			end)
		end
	end)

	if options and options.default then
		slider:Set(options.default)
	end

	self._items[#self._items + 1] = slider
	return slider
end

function panel:AddDropdown(name, callback, options)
	local dropdown = {
		_class = "Dropdown",
		_name = options and options.flag or getFlagForm(name),
		_callback = callback or function() end,
		_items = options and options.items or {},
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, 0, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("Frame", { Name = "open", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 0), Size = UDim2.new(0, 24, 0, 24) }, {
				create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = "rbxassetid://7815253957", Size = UDim2.new(1, 0, 1, 0) })
			}, UDim.new(0, 4)),
			create("Frame", { Name = "container", BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, #self._items > 0 and 0 or 28, 0, 0) }, {
				create("ScrollingFrame", { Name = "scroll", BackgroundTransparency = 1, BorderSizePixel = 0, BottomImage = "rbxassetid://7702689828", CanvasSize = UDim2.new(), ClipsDescendants = true, MidImage = "rbxassetid://7702695076", Position = UDim2.new(0, 2, 0, 2), ScrollBarImageColor3 = "theme.panelBackground", ScrollBarThickness = 5, Size = UDim2.new(1, -4, 1, -4), TopImage = "rbxassetid://7702696403" }, {
					create("UIListLayout", { Name = "uilist" })
				})
			}, UDim.new(0, 4))
		}, UDim.new(0, 4)),
		_status = {
			value = ""
		},
		_open = false
	}

	function dropdown:Set(value)
		if value == "" or table.find(self._items, value) then
			local txt = tostring(value)
			self._frame.label.Text = (txt == "" or (options and options.noDisplay)) and name or name .. " - " .. txt
			self._status.value = txt
			self._callback(value)
		end
	end

	function dropdown:UpdateItems(items)
		for i, v in next, self._frame.container.scroll:GetChildren() do
			if v.ClassName == "TextButton" then
				v:Destroy()
			end
		end
		for i, v in next, items do
			if not self._frame.container.scroll:FindFirstChild(tostring(v)) then
				local txt = tostring(v)
				local item = create("TextButton", { Name = txt, AutoButtonColor = false, BackgroundColor3 = "theme.panelItemBackground", Font = Enum.Font.Gotham, Parent = self._frame.container.scroll, Size = UDim2.new(1, 0, 0, 20), Text = txt, TextColor3 = "theme.textForeground", TextSize = 12 }, nil, UDim.new(0, 4))
				addMouseEffects(item, "panelItemBackground", nil, "clickEffect")
				item.MouseButton1Click:Connect(function()
					self:Set(v)
				end)
			end
		end
		self._frame.container.Size = UDim2.new(0, self._frame.container.AbsoluteSize.X, 0, math.min(4 + (20 * #items), 104))
		if self._open then
			tween(self._frame, 0.35, { Size = UDim2.new(0, self._frame.AbsoluteSize.X, 0, math.min(32 + (#items * 20), 132)) })
		end
		if self._status.value ~= "" and not table.find(items, self._status.value) then
			self:Set("")
		end
		self._items = items
	end

	function dropdown:Show()
		if not self._open and #self._items > 0 then
			self._open = true
			tween(self._frame, 0.35, { Size = UDim2.new(1, 0, 0, math.min(32 + (#self._items * 20), 132)) })
		end
	end

	function dropdown:Hide()
		if self._open then
			self._open = false
			tween(self._frame, 0.35, { Size = UDim2.new(1, 0, 0, 24) })
		end
	end

	autoResizeList(dropdown._frame.container.scroll)

	dropdown._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and mouse.Y - dropdown._frame.AbsolutePosition.Y < 24 and not table.find(coreGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y), self._frame.info) then
			if dropdown._open then
				dropdown:Hide()
			else
				dropdown:Show()
			end
		end
	end)

	dropdown:UpdateItems(dropdown._items)

	if options and options.default then
		dropdown:Set(options.default)
	end

	dropdown._frame.ClipsDescendants = true -- visual glitch if u put it in create for some reason
	self._items[#self._items + 1] = dropdown
	return dropdown
end

function panel:AddPicker(name, callback, options)
	local colourPicker = {
		_class = "ColourPicker",
		_name = options and options.flag or getFlagForm(name),
		_callback = callback or function() end,
		_frame = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._frame.container, Size = UDim2.new(1, 0, 0, 24) }, {
			create("TextLabel", { Name = "label", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -4, 0, 24), Text = name, TextColor3 = "theme.textForeground", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
			create("Frame", { Name = "open", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, #self._items > 0 and 0 or -28, 0, 0), Size = UDim2.new(0, 24, 0, 24) }, {
				create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = "rbxassetid://7815253957", Size = UDim2.new(1, 0, 1, 0) })
			}, UDim.new(0, 4)),
			create("Frame", { Name = "indicator", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.new(1, 0, 0), Position = UDim2.new(1, #self._items > 0 and -28 or -56, 0, 0), Size = UDim2.new(0, 24, 0, 24) }, nil, UDim.new(0, 4)),
			create("Frame", { Name = "container", BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 88) }, {
				create("Frame", { Name = "hue", Position = UDim2.new(0, 130, 0, 8), Size = UDim2.new(0, 20, 0, 72) }, {
					create("UIGradient", { Name = "uigrad", Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
						ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
						ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
						ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
						ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
						ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
						ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
					}), Rotation = 90 }),
					create("Frame", { Name = "indicator", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = "theme.panelBackground", Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 8, 0, 4) }, nil, UDim.new(0, 4))
				}, UDim.new(0, 4)),
				create("Frame", { Name = "sat", Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(0, 110, 0, 72) }, {
					create("UIGradient", { Name = "uigrad", Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 0)) }),
					create("Frame", { Name = "indicator", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = "theme.panelBackground", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 12, 0, 12), ZIndex = 2 }, nil, UDim.new(1, 0)),
					create("Frame", { Name = "val", Size = UDim2.new(1, 0, 1, 0) }, {
						create("UIGradient", { Name = "uigrad", Color = ColorSequence.new(Color3.new(0, 0, 0)), Rotation = 270, Transparency = NumberSequence.new(0, 1) })
					}, UDim.new(0, 4))
				}, UDim.new(0, 4)),
				create("TextButton", { Name = "rainbow", AutoButtonColor = false, BackgroundColor3 = "theme.panelBackground", Font = Enum.Font.Gotham, Position = UDim2.new(0, 162, 0, 8), Size = UDim2.new(0, 73, 0, 24), Text = "Rainbow", TextColor3 = "theme.textForeground", TextSize = 12 }, nil, UDim.new(0, 4))
			}, UDim.new(0, 4))
		}, UDim.new(0, 4)),
		_status = {
			value = {
				h = 0,
				s = 1,
				v = 1
			}
		},
		_open = false
	}

	function colourPicker:Set(h, s, v)
		local colourValue = Color3.fromHSV(h, s, v)
		self._frame.indicator.BackgroundColor3 = colourValue
		self._frame.container.sat.uigrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
		tween(self._frame.container.hue.indicator, 0.2, { Position = UDim2.new(0.5, 0, h, 0) })
		tween(self._frame.container.sat.indicator, 0.2, { Position = UDim2.new(s, 0, 1 - v, 0) })
		self._status.value.h, self._status.value.s, self._status.value.v = h, s, v
		self._callback(colourValue)
	end

	function colourPicker:Show()
		if not self._open then
			self._open = true
			tween(self._frame, 0.35, { Size = UDim2.new(1, 0, 0, 116) })
		end
	end

	function colourPicker:Hide()
		if self._open then
			self._open = false
			tween(self._frame, 0.35, { Size = UDim2.new(1, 0, 0, 24) })
		end
	end

	addMouseEffects(colourPicker._frame.container.rainbow, "panelBackground", nil, "clickEffect")

	colourPicker._frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and mouse.Y - colourPicker._frame.AbsolutePosition.Y < 24 and not table.find(coreGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y), self._frame.info) then
			if colourPicker._open then
				colourPicker:Hide()
			else
				colourPicker:Show()
			end
		end
	end)

	colourPicker._frame.container.hue.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self._tab._lib._settings.dragging == false then
			if colourPicker._rainbowConn then
				colourPicker._rainbowConn:Disconnect()
				colourPicker._rainbowConn = nil
			end
			self._tab._lib._settings.dragging = true
			local mouseConn, inputConn
			mouseConn = mouse.Move:Connect(function()
				colourPicker:Set(math.clamp((mouse.Y - colourPicker._frame.container.hue.AbsolutePosition.Y) / colourPicker._frame.container.hue.AbsoluteSize.Y, 0, 1), colourPicker._status.value.s, colourPicker._status.value.v)
			end)
			inputConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					mouseConn:Disconnect()
					inputConn:Disconnect()
					self._tab._lib._settings.dragging = false
				end
			end)
		end
	end)

	colourPicker._frame.container.sat.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self._tab._lib._settings.dragging == false then
			self._tab._lib._settings.dragging = true
			local mouseConn, inputConn
			mouseConn = mouse.Move:Connect(function()
				colourPicker:Set(colourPicker._status.value.h, math.clamp((mouse.X - colourPicker._frame.container.sat.AbsolutePosition.X) / colourPicker._frame.container.sat.AbsoluteSize.X, 0, 1), 1 - math.clamp((mouse.Y - colourPicker._frame.container.sat.AbsolutePosition.Y) / colourPicker._frame.container.sat.AbsoluteSize.Y, 0, 1))
			end)
			inputConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					mouseConn:Disconnect()
					inputConn:Disconnect()
					self._tab._lib._settings.dragging = false
				end
			end)
		end
	end)

	colourPicker._frame.container.rainbow.MouseButton1Click:Connect(function()
		if colourPicker._rainbowConn == nil then
			colourPicker._rainbowConn = heartbeat:Connect(function()
				colourPicker:Set(tick() % 8 / 8, colourPicker._status.value.s, colourPicker._status.value.v)
			end)
		end
	end)

	if options and options.default then
		colourPicker:Set(unpack(options.default))
	end

	colourPicker._frame.ClipsDescendants = true -- visual glitch if u put it in create for some reason
	self._items[#self._items + 1] = colourPicker
	return colourPicker
end

local tab = {}
tab.__index = tab

function tab:AddPanel(name, options)
	local newPanel = setmetatable({
		_name = name or "panel" .. (#self._panels + 1),
		_tab = self,
		_frame = create("Frame", { Name = name or "panel" .. (#self._panels + 1), BackgroundColor3 = "theme.panelBackground", Parent = self._frame, ZIndex = 2 }, {
			create("UISizeConstraint", { Name = "uisizecon", MinSize = Vector2.new(255, 36) }),
			create("Frame", { Name = "info", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelBackground", Position = UDim2.new(1, -4, 0, 6), Size = UDim2.new(0, 24, 0, 24), ZIndex = 2 }, {
				create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = "rbxassetid://7804540742", ImageColor3 = "theme.imageForeground", Size = UDim2.new(1, 0, 1, 0) })
			}, UDim.new(0, 4)),
			create("Frame", { Name = "container", BackgroundTransparency = 1, Position = UDim2.new(0, 6, 0, 6), Size = UDim2.new(1, -12, 1, -12) }, {
				create("UIListLayout", { Name = "uilist", Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
			})
		}, UDim.new(0, 4)),
		_items = {}
	}, panel)

	addMouseEffects(newPanel._frame.info, "panelBackground", "hoverEffect", "clickEffect")
	autoResizeList(newPanel._frame.container)

	newPanel._frame.info.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self._lib:Notify(options and options.info or (name and "No Information Provided For " .. name or "No Information Provided"))
		end
	end)

	newPanel._frame.container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		newPanel._frame.uisizecon.MinSize = Vector2.new(255, newPanel._frame.container.AbsoluteSize.Y + 12)
	end)

	if name then
		newPanel:AddLabel(name, { bold = true })
	end

	self._panels[#self._panels + 1] = newPanel
	return newPanel
end

local library = {}
library.__index = library

function library.new(gameName)
	local lib = setmetatable({
		_name = gameName,
		_gui = create("ScreenGui", { Name = "evov2", ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, {
			create("Frame", { Name = "main", BackgroundColor3 = "theme.mainBackground", ClipsDescendants = true, Position = UDim2.new(0, 100, 0, 100), Size = UDim2.new(0, 535, 0, 380) }, {
				create("ScrollingFrame", { Name = "dashboard", BackgroundTransparency = 1, BorderSizePixel = 0, BottomImage = "rbxassetid://7702689828", ClipsDescendants = true, MidImage = "rbxassetid://7702695076", Position = UDim2.new(0, 5, 0, 39), ScrollBarImageColor3 = "theme.panelBackground", ScrollBarThickness = 5, Size = UDim2.new(1, -10, 0, 315), TopImage = "rbxassetid://7702696403" }, {
					create("UIGridLayout", { Name = "uigrid", CellPadding = UDim2.new(0, 5, 0, 5), CellSize = UDim2.new(0, 255, 0, 0), FillDirectionMaxCells = 2, SortOrder = Enum.SortOrder.LayoutOrder })
				}),
				create("Frame", { Name = "top", BackgroundColor3 = "theme.topBackground", Size = UDim2.new(1, 0, 0, 34), ZIndex = 2 }, {
					create("TextLabel", { Name = "title", BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0, 34, 0, 0), Size = UDim2.new(1, -68, 1, 0), Text = "EvoV2 | " .. gameName, TextColor3 = "theme.textForeground", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }),
					create("Frame", { Name = "home", BackgroundColor3 = "theme.topBackground", Position = UDim2.new(0, 5, 0, 5), Size = UDim2.new(0, 24, 0, 24) }, {
						create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = "rbxassetid://7804268020", ImageColor3 = "theme.imageForeground", Size = UDim2.new(1, 0, 1, 0) })
					}, UDim.new(0, 4)),
					create("Frame", { Name = "minimise", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.topBackground", Position = UDim2.new(1, -5, 0, 5), Size = UDim2.new(0, 24, 0, 24) }, {
						create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = "rbxassetid://7804267824", ImageColor3 = "theme.imageForeground", Rotation = 45, Size = UDim2.new(1, 0, 1, 0) })
					}, UDim.new(0, 4)),
					create("Frame", { Name = "underline", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = "theme.topBackground", BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2) })
				}, UDim.new(0, 4)),
				create("TextLabel", { Name = "tab", AnchorPoint =  Vector2.new(0.5, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, -16, 0, 26), Text = "Home", TextColor3 = "theme.textForeground", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }),
				create("TextLabel", { Name = "site", AnchorPoint =  Vector2.new(0.5, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, -16, 0, 26), Text = "https://projectevo.xyz", TextColor3 = "theme.textForeground", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right }),
				create("Folder", { Name = "container" })
			}, UDim.new(0, 4)),
			create("Folder", { Name = "notifs" })
		}),
		_settings = {
			minimised = false,
			dragging = false,
			binding = false,
			options = {}
		},
		_tabs = {}
	}, library)

	autoResizeGrid(lib._gui.main.dashboard)
	addMouseEffects(lib._gui.main.top.home, "topBackground", "hoverEffect", "clickEffect")
	addMouseEffects(lib._gui.main.top.minimise, "topBackground", "hoverEffect", "clickEffect")
	makeDraggable(lib, lib._gui.main)

	lib._gui.main.top.home.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and lib._settings.selected then
			lib._settings.selected._frame.Visible = false
			lib._settings.selected = nil
			lib._gui.main.dashboard.Visible = true
			lib._gui.main.tab.Text = "Home"
		end
	end)

	lib._gui.main.top.minimise.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			lib._settings.minimised = not lib._settings.minimised
			tween(lib._gui.main.top.minimise.icon, 0.35, { Rotation = lib._settings.minimised and 0 or 45 })
			tween(lib._gui.main, 0.35, { Size = UDim2.new(0, 535, 0, lib._settings.minimised and 34 or 380) })
		end
	end)

	userInputService.InputBegan:Connect(function(input, isProcessed)
		if not lib._settings.binding then
			local inputName = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name or input.UserInputType.Name
			for _, tab in next, lib._tabs do
				for _, panel in next, tab._panels do
					for _, item in next, panel._items do
						if item._class == "Bind" and item._status.value == inputName then
							task.spawn(item._callback, item._status.value)
						end
					end
				end
			end
		end
	end)

	coroutine.wrap(function()
		discord:PromptInvite("hjDuYYjxMP")
	end)

	tracer:Create("gui", "instance", { instance = lib._gui })
	doOptimalParenting(lib._gui)
	return lib
end

function library:AddProfile()
	local newProfile = setmetatable({
		_frame = create("Frame", { Name = "profile", BackgroundColor3 = "theme.panelBackground", Parent = self._gui.main.dashboard }, {
			create("UISizeConstraint", { Name = "uisizecon", MinSize = Vector2.new(515, 104) }),
			create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 40, 0, 40) }),
			create("TextLabel", { Name = "name", BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0, 65, 0, 15), Size = UDim2.new(1, -75, 0, 30), Text = "Welcome, " .. localPlayer.Name, TextColor3 = "theme.textForeground", TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }),
			create("TextLabel", { Name = "id", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 10, 0, 60), Size = UDim2.new(1, -20, 0, 14), Text = "ID: " .. localPlayer.UserId, TextColor3 = "theme.textForeground", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }),
			create("TextLabel", { Name = "exploit", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 10, 0, 80), Size = UDim2.new(1, -20, 0, 14), Text = "Exploit: " .. (identifyexecutor and table.concat({ identifyexecutor() }, " ") or "Unknown"), TextColor3 = "theme.textForeground", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }),
			create("Folder", { Name = "stats" })
		}, UDim.new(0, 4))
	}, profile)

	task.spawn(function()
		newProfile._frame.icon.Image = players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)

	return newProfile
end

function library:AddTab(name, desc, icon)
	local newTab = setmetatable({
		_lib = self,
		_name = name,
		_frame = create("ScrollingFrame", { Name = name, BackgroundTransparency = 1, BorderSizePixel = 0, BottomImage = "rbxassetid://7702689828", CanvasSize = UDim2.new(), ClipsDescendants = true, MidImage = "rbxassetid://7702695076", Parent = self._gui.main.container, Position = UDim2.new(0, 5, 0, 39), ScrollBarImageColor3 = "theme.panelBackground", ScrollBarThickness = 5, Size = UDim2.new(1, -10, 0, 315), TopImage = "rbxassetid://7702696403", Visible = false }, {
			create("UIGridLayout", { Name = "uigrid", CellPadding = UDim2.new(0, 5, 0, 2), CellSize = UDim2.new(0, 255, 0, 2), FillDirectionMaxCells = 2, SortOrder = Enum.SortOrder.LayoutOrder })
		}),
		_item = create("Frame", { Name = name, BackgroundColor3 = "theme.panelBackground", Parent = self._gui.main.dashboard }, {
			create("UISizeConstraint", { Name = "uisizecon", MinSize = Vector2.new(255, 70 + textService:GetTextSize(desc, 14, Enum.Font.Gotham, Vector2.new(235, math.huge)).Y) }),
			create("ImageLabel", { Name = "icon", BackgroundTransparency = 1, Image = icon, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 40, 0, 40) }),
			create("TextLabel", { Name = "title", BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0, 65, 0, 15), Size = UDim2.new(1, -75, 0, 30), Text = name, TextColor3 = "theme.textForeground", TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }),
			create("TextLabel", { Name = "description", BackgroundTransparency = 1, Font = Enum.Font.Gotham, Position = UDim2.new(0, 10, 0, 60), Size = UDim2.new(1, -20, 1, -65), Text = desc, TextColor3 = "theme.textForeground", TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }),
		}, UDim.new(0, 4)),
		_panels = {}
	}, tab)

	autoResizeGrid(newTab._frame)
	addMouseEffects(newTab._item, "panelBackground", "hoverEffect", "clickEffect")

	newTab._item.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self._gui.main.dashboard.Visible = false
			self._settings.selected = newTab
			newTab._frame.Visible = true
			self._gui.main.tab.Text = newTab._name
		end
	end)

	self._tabs[#self._tabs + 1] = newTab
	return newTab
end

function library:GetConfigs()
	local configs = {}
	if isfolder("EvoV2\\Configs\\" .. self._name) then
		for i, v in next, listfiles("EvoV2\\Configs\\" .. self._name) do
			local split = select(-1, unpack(v:split("\\")))
			if split:find(".json") then
				configs[#configs + 1] = split:gsub(".json", "")
			end
		end
	end
	return configs
end

function library:LoadConfig(name)
	local filePath = "EvoV2\\Configs\\" .. self._name .. "\\" .. name .. ".json"
	if not (isfolder("EvoV2\\Configs\\" .. self._name) and isfile(filePath)) then
		return
	end
	local config = select(2, pcall(function() return httpService:JSONDecode(readfile(filePath)) end))
	if type(config) ~= "table" then
		return
	end
	for _, tab in next, self._tabs do
		for _, panel in next, tab._panels do
			for i, v in next, panel._items do
				local value = config[v._name]
				if value ~= nil then
					if v._class == "ColourPicker" then
						coroutine.wrap(v.Set)(v, value.h, value.s, value.v)
					else
						coroutine.wrap(v.Set)(v, value)
					end
				end
			end
		end
	end
end

function library:SaveConfig(name)
	if not isfolder("EvoV2\\Configs\\" .. self._name) then
		pcall(makefolder, "EvoV2")
		pcall(makefolder, "EvoV2\\Configs")
		pcall(makefolder, "EvoV2\\Configs\\" .. self._name)
	end
	local config = {}
	for _, tab in next, self._tabs do
		for _, panel in next, tab._panels do
			for i, v in next, panel._items do
				if v._class == "Toggle" then
					config[v._name] = v._status.enabled
				elseif v._class == "Box" or v._class == "Bind" or v._class == "Slider" or v._class == "Dropdown" or v._class == "ColourPicker" then
					config[v._name] = v._status.value
				end
			end
		end
	end
	writefile("EvoV2\\Configs\\" .. self._name .. "\\" .. name .. ".json", httpService:JSONEncode(config))
end

function library:DeleteConfig(name)
	local filePath = "EvoV2\\Configs\\" .. self._name .. "\\" .. name .. ".json"
	if not (isfolder("EvoV2\\Configs\\" .. self._name) and isfile(filePath)) then
		return
	end
	delfile(filePath)
end

function library:GetThemes()
	local themeNames = {}
	if not isfolder("EvoV2\\Themes") then
		pcall(makefolder, "EvoV2")
		pcall(makefolder, "EvoV2\\Themes")
	end
	for i, v in next, listfiles("EvoV2\\Themes") do
		local split = select(-1, unpack(v:split("\\")))
		if split:find(".json") then
			themeNames[#themeNames + 1] = split:gsub(".json", "")
		end
	end
	for i, v in next, themes do
		if i ~= "selected" and not table.find(themeNames, i) then
			themeNames[#themeNames + 1] = i
		end
	end
	return themeNames
end

function library:LoadTheme(name)
	local filePath = "EvoV2\\Themes\\" .. name .. ".json"
	if not (isfolder("EvoV2\\Themes") and isfile(filePath)) then
		print("noes")
		return
	end
	local theme = select(2, pcall(function() return jsonDecodeTheme(readfile(filePath)) end))
	if type(theme) ~= "table" then
		print("errors")
		return
	end
	if not themes[name] then
		themes[name] = theme
	end
	for themePart, itemStore in next, themeMeta.items do
		for i, v in next, itemStore do
			if themePart ~= "toggleEnabled" or i[themeProperties[themePart]] == themeMeta[themePart] then
				i[themeProperties[themePart]] = theme[themePart]
			end
		end
	end
	themes.selected = name
end

function library:AddSettings()
	local tab = self:AddTab("Settings", "Configs & UI Settings", "rbxassetid://7816858338")
	local configs = tab:AddPanel("Configs")
	local configBox, configDrop, themeDrop
	configDrop = configs:AddDropdown("Configs", function(selected)
		if selected ~= "" then
			configBox:Set(selected)
		end
	end, { items = self:GetConfigs() })
	configBox = configs:AddBox("Config Name")
	configs:AddButton("Load Config", function()
		if configBox._status.value ~= "" then
			self:LoadConfig(configBox._status.value)
			if themeDrop._status.value ~= "" then
				self:LoadTheme(themeDrop._status.value)
			end
		end
	end)
	configs:AddButton("Save Config", function()
		if configBox._status.value ~= "" then
			self:SaveConfig(configBox._status.value)
		end
		configDrop:UpdateItems(self:GetConfigs())
	end)
	configs:AddButton("Delete Config", function()
		if configBox._status.value ~= "" then
			self:DeleteConfig(configBox._status.value)
		end
		configDrop:UpdateItems(self:GetConfigs())
	end)
	configs:AddButton("Refresh List", function()
		configDrop:UpdateItems(self:GetConfigs())
	end)

	local uiSettings = tab:AddPanel("UI Settings")
	uiSettings:AddBind("Toggle GUI", function(bindName)
		self._gui.Enabled = not self._gui.Enabled
	end, { default = "RightControl" })
	themeDrop = uiSettings:AddDropdown("Themes", nil, { items = self:GetThemes() })
	uiSettings:AddButton("Load Theme", function()
		if themeDrop._status.value ~= "" then
			self:LoadTheme(themeDrop._status.value)
		end
	end)
	uiSettings:AddButton("Refresh List", function()
		themeDrop:UpdateItems(self:GetThemes())
	end)

	local credits = tab:AddPanel("Credits")
	credits:AddClipboardLabel("Kieran - Owner, Scripter", "https://projectevo.xyz/discord")
	credits:AddClipboardLabel("RegularVynixu - Procrastination", "https://discord.gg/QYH4F7ks7m")
	credits:AddClipboardLabel("||4151|| - Art Weeb", "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

	local misc = tab:AddPanel("Misc")
	misc:AddToggle("Anti AFK", function(state)
		self._settings.options.antiAfk = state
	end)

	localPlayer.Idled:Connect(function()
		if self._settings.options.antiAfk then
			virtualUser:Button2Down(Vector2.new(), cam.CFrame)
   			task.wait(1)
   			virtualUser:Button2Up(Vector2.new(), cam.CFrame)
		end
	end)
end

function library:Notify(text, callback, options)
	local sizeY, called = textService:GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(260, math.huge)).Y + 10, false
	local frame = create("Frame", { Name = "notification", AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = "theme.panelItemBackground", ClipsDescendants = true, Parent = self._gui.notifs, Position = UDim2.new(1, 300, 1, -30), Size = UDim2.new(0, 280, 0, sizeY + 34) }, {
		create("TextLabel", { Name = "title", BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -66, 0, 30), Text = "EvoV2 Notification", TextColor3 = "theme.textForeground", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }),
		create("TextLabel", { Name = "content", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.new(0.5, 0, 0, 26), Size = UDim2.new(1, -20, 0, sizeY), Text = text, TextColor3 = "theme.notifTextForeground", TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }),
		create("Frame", { Name = "yes", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, -30, 0, 4), Size = UDim2.new(0, 22, 0, 22) }, {
			create("ImageLabel", { Name = "icon", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://7234543866", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0) })
		}, UDim.new(0, 4)),
		create("Frame", { Name = "no", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "theme.panelItemBackground", Position = UDim2.new(1, -4, 0, 4), Size = UDim2.new(0, 22, 0, 22) }, {
			create("ImageLabel", { Name = "icon", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://7234543609", Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45, Size = UDim2.new(1, 0, 1, 0) })
		}, UDim.new(0, 4)),
		create("Frame", { Name = "underline", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = "theme.notifTimeoutHighlight", Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(0, 0, 0, 6) }, {
			create("Frame", { Name = "overline", BackgroundColor3 = "theme.notifTimeoutHighlight", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.5, 0) })
		}, UDim.new(1, 0))
	}, UDim.new(0, 4))

	local function closeNotif(option)
		called = true
		tween(frame, 0.35, { Position = UDim2.new(1, 300, frame.Position.Y.Scale, frame.Position.Y.Offset) }).Completed:Connect(function()
			frame:Destroy()
			organiseNotifs(self._gui.notifs)
		end)
		if callback then
			callback(option)
		end
	end

	addMouseEffects(frame.yes, "panelItemBackground", nil, "clickEffect")
	addMouseEffects(frame.no, "panelItemBackground", nil, "clickEffect")

	frame.yes.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			closeNotif(true)
		end
	end)

	frame.no.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			closeNotif(false)
		end
	end)

	organiseNotifs(self._gui.notifs)

	tween(frame.underline, options and options.timeout or 10, { Size = UDim2.new(1, 0, 0, 6) }, Enum.EasingStyle.Linear).Completed:Connect(function()
		if not called then
			closeNotif(false)
		end
	end)
end

return {
	library = library,
	tracer = tracer,
	discord = discord,
	system = system
}
