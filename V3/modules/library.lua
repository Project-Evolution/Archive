--[[

    Notes:

    Yes, I know this isn't obfuscated.

]]

--[[ Compatibility ]]--

local chars = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ1234567890"

local randomstring = randomstring or syn and syn.crypt and syn.crypt.random or function(size)
	local str = ""
	for i = 1, size do
		local rand = math.random(1, 62)
		str = str .. string.sub(chars, rand, rand)
	end
	return str
end

--[[ Variables ]]--

local themes = evov3.imports:fetchsystem("themes")
local utils = evov3.imports:fetchsystem("utils")

local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local tweenservice = game:GetService("TweenService")
local textservice = game:GetService("TextService")
local httpservice = game:GetService("HttpService")
local coregui = game:GetService("CoreGui")

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()

local hugevec2 = Vector2.new(math.huge, math.huge)

local emptybindsize = textservice:GetTextSize("None", 11, Enum.Font.Gotham, hugevec2).X + 14
local ellipsisbindsize = textservice:GetTextSize("...", 11, Enum.Font.Gotham, hugevec2).X + 14
local holdertxtsize = textservice:GetTextSize("Enter Text...", 11, Enum.Font.Gotham, hugevec2).X + 14
local holdernumsize = textservice:GetTextSize("Enter Number...", 11, Enum.Font.Gotham, hugevec2).X + 14

local blacklistedkeys = {
	[Enum.KeyCode.Unknown] = true
}

local whitelistedtypes = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true
}

local theme = setmetatable({
	items = {
		mainbackground = {},
		titlebackground = {},
		leftbackground = {},
		categorybackground = {},
		sectionbackground = {},
		foreground = {},
		highlight = {},
		dynamic = {}
	},
    values = {
		mainbackground = Color3.fromRGB(16, 16, 16),
		titlebackground = Color3.fromRGB(12, 12, 12),
		leftbackground = Color3.fromRGB(20, 20, 20),
		categorybackground = Color3.fromRGB(28, 28, 28),
		sectionbackground = Color3.fromRGB(24, 24, 24),
		foreground = Color3.fromRGB(235, 235, 235),
		highlight = Color3.fromRGB(43, 79, 199)
    }
}, {
	__index = function(t, k)
		return t.values[k]
	end,
	__newindex = function(t, k, v)
		t.values[k] = v
		for inst, prop in next, t.items[k] do
			inst[prop] = v
		end
		for inst, data in next, t.items.dynamic do
			local item = data.func()
			if item == k then
				inst[data.prop] = v
			end
		end
	end
})

local uicache = {}

--[[ Functions ]]--

local function create(classname, properties, children)
	local inst = Instance.new(classname)
	for i, v in next, properties do
		if i == "Theme" then
			for prop, item in next, v do
				if type(item) == "function" then
					theme.items.dynamic[inst] = {
						prop = prop,
						func = item
					}
					inst[prop] = theme[item()]
				else
					theme.items[item][inst] = prop
					inst[prop] = theme[item]
				end
			end
	    elseif i ~= "Parent" then
	       	inst[i] = v
	    end
	end
	if children then
		for i, v in next, children do
			v.Parent = inst
		end
	end
	if inst:IsA("GuiObject") then
		table.insert(uicache, inst)
	end
	inst.Parent = properties.Parent
	return inst
end

local function tween(instance, duration, properties, style)
	local t = tweenservice:Create(instance, TweenInfo.new(duration, style or Enum.EasingStyle.Sine), properties)
	t:Play()
	return t
end

local function autoresize(layout, frame)
	frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, layout.AbsoluteContentSize.Y)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, layout.AbsoluteContentSize.Y)
	end)
end

local function autocanvasresize(layout, frame)
	frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)
end

local function customscroll(frame, scroll, jump)
    scroll.ScrollingEnabled = false
    frame.MouseWheelForward:Connect(function()
        scroll.CanvasPosition -= Vector2.new(0, math.min(jump, scroll.CanvasPosition.Y))
    end)
    frame.MouseWheelBackward:Connect(function()
        scroll.CanvasPosition += Vector2.new(0, math.min(jump, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteSize.Y - scroll.CanvasPosition.Y))
    end)
end

local function round(val, nearest)
	local mul = 1 / nearest
    return math.round(val * mul) / mul
end

local function mergetables(base, edit)
    if typeof(edit) == "table" then
        for i, v in next, edit do
            if typeof(base[i]) == typeof(v) then
				base[i] = v
            end
        end
    end
    return base
end

--[[ Label ]]--

local label = {}
label.__index = label

function label.new(options)
	local newlabel = setmetatable(mergetables({
		itemtype = "label",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false
	}, options), label)

	newlabel.frame = create("TextLabel", {
		Theme = {
			TextColor3 = "foreground"
		},
		Font = Enum.Font.Gotham,
		FontSize = Enum.FontSize.Size12,
		Text = "",
		TextSize = 12,
		TextWrapped = true,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Name = "label"
	})

	return newlabel
end

function label:update(content)
	self.content = content
	self.frame.Name = content
	self.frame.Text = content
	self.frame.Size = UDim2.new(1, 0, 0, textservice:GetTextSize(content, 12, Enum.Font.Gotham, Vector2.new(self.frame.AbsoluteSize.X, math.huge)).Y + 6)
end

--[[ Status Label ]]--

local statuslabel = {}
statuslabel.__index = statuslabel

function statuslabel.new(options)
	local newstatuslabel = setmetatable(mergetables({
		itemtype = "statuslabel",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		status = "Unknown",
		colour = Color3.new(1, 1, 1)
	}, options), statuslabel)

	newstatuslabel.frame = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Name = newstatuslabel.content
	}, {
		create("TextLabel", {
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham,
			FontSize = Enum.FontSize.Size12,
			Text = newstatuslabel.content,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Name = "label"
		}),
		create("TextLabel", {
			Font = Enum.Font.Gotham,
			FontSize = Enum.FontSize.Size12,
			Text = "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Name = "status"
		})
	})

	return newstatuslabel
end

function statuslabel:update(status, colour)
	self.frame.status.Text = status
	if colour then
		self.frame.status.TextColor3 = colour
	end
end

--[[ Clipboard Label ]]--

local clipboardlabel = {}
clipboardlabel.__index = clipboardlabel

function clipboardlabel.new(options)
	local newclipboardlabel = setmetatable(mergetables({
		itemtype = "clipboardlabel",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		callback = function() end
	}, options), clipboardlabel)

	newclipboardlabel.frame = create("Frame", { 
		Theme = {
			BackgroundColor3 = "mainbackground"
		},
		Size = UDim2.new(1, 0, 0, 22), 
		Name = newclipboardlabel.content
	}, {
		create("UICorner", { 
			CornerRadius = UDim.new(0, 3), 
			Name = "corner"
		}),
		create("ImageLabel", { 
			Image = "rbxassetid://9243581053", 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, -4, 0.5, 0), 
			Size = UDim2.new(0, 14, 0, 14), 
			Name = "icon"
		}),
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newclipboardlabel.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(1, -7, 1, 0), 
			Name = "label"
		})
	})

	newclipboardlabel.frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			newclipboardlabel:copy()
		end
	end)

	return newclipboardlabel
end

function clipboardlabel:copy()
	local content = self.callback()
	if content then
		setclipboard(content)
	end
end

--[[ Button ]]--

local button = {}
button.__index = button

function button.new(options)
	local newbutton = setmetatable(mergetables({
		itemtype = "button",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		callback = function() end
	}, options), button)
	
	newbutton.frame = create("TextButton", {
		Theme = {
			BackgroundColor3 = "highlight",
			TextColor3 = "foreground"
		},
		Font = Enum.Font.Gotham,
		FontSize = Enum.FontSize.Size12,
		Text = newbutton.content,
		TextSize = 12,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 20),
		Name = "button"
	}, {
		create("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Name = "corner"
		})
	})

	return newbutton
end

function button:fire(...)
	self.callback(...)
end

--[[ Toggle ]]--

local toggle = {}
toggle.__index = toggle

function toggle.new(options)
	local newtoggle = setmetatable(mergetables({
		itemtype = "toggle",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		callback = function() end
	}, options), toggle)
	
	newtoggle.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 18), 
		Name = newtoggle.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newtoggle.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(1, -26, 1, 0), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			AnchorPoint = Vector2.new(0, 0.5), 
			Position = UDim2.new(0, 0, 0.5, 0), 
			Size = UDim2.new(0, 18, 0, 18), 
			Name = "border"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = function()
						return newtoggle.library and newtoggle.library.flags[newtoggle.flag] and "highlight" or "sectionbackground"
					end
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				Name = "indicator"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		})
	})

	newtoggle.frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			newtoggle:switch()
		end
	end)

	return newtoggle
end

function toggle:set(bool)
	self.library.flags[self.flag] = bool
	tween(self.frame.border.indicator, 0.25, { BackgroundColor3 = bool and theme.highlight or theme.sectionbackground })
	coroutine.wrap(self.callback)(bool)
end

function toggle:switch()
	self:set(not self.library.flags[self.flag])
end

--[[ Bind ]]--

local bind = {}
bind.__index = bind

function bind.new(options)
	local newbind = setmetatable(mergetables({
		itemtype = "bind",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		onkeydown = function() end,
		onkeyup = function() end,
		onkeychanged = function() end
	}, options), bind)

	newbind.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 20), 
		Name = newbind.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newbind.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, 0, 1, 0), 
			Name = "title"
		}),
		create("TextLabel", {
			Theme = {
				BackgroundColor3 = "mainbackground",
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size11, 
			Text = "None", 
			TextSize = 11, 
			AnchorPoint = Vector2.new(1, 0.5), 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(0, emptybindsize, 1, 0), 
			Name = "display"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			})
		})
	})

	newbind.frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and newbind.library.settings.binding == false then
			newbind.library.settings.binding = true
			newbind.frame.display.Size = UDim2.new(0, ellipsisbindsize, 1, 0)
			newbind.frame.display.Text = "..."
			task.wait(0.1)
			while true do
				local input = userinputservice.InputBegan:Wait()
				if (input.UserInputType == Enum.UserInputType.Keyboard and not blacklistedkeys[input.KeyCode]) or whitelistedtypes[input.UserInputType] then
					newbind:set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name or input.UserInputType.Name)
					break
				end
			end
			task.wait(0.1)
			newbind.library.settings.binding = false
		end
	end)

	return newbind
end

function bind:set(inputname)
	local value = (inputname == "Escape" or inputname == "") and "None" or inputname
	local old = self.library.flags[self.flag]
	self.library.flags[self.flag] = value
	self.frame.display.Size = UDim2.new(0, textservice:GetTextSize(value, 11, Enum.Font.Gotham, hugevec2).X + 14, 1, 0)
	self.frame.display.Text = value
	self.onkeychanged(old, value)
end

--[[ Box ]]--

local box = {}
box.__index = box

function box.new(options)
	local newbox = setmetatable(mergetables({
		itemtype = "box",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		numonly = false,
		callback = function() end
	}, options), box)
	
	newbox.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 22), 
		Name = newbox.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newbox.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, 0, 1, 0), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(1, 0.5), 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(0, newbox.numonly and holdernumsize or holdertxtsize, 1, 0), 
			Name = "container"
		}, {
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "highlight"
				},
				AnchorPoint = Vector2.new(0.5, 1), 
				Position = UDim2.new(0.5, 0, 1, 0), 
				Size = UDim2.new(1, 0, 0, 4), 
				Name = "underline"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(1, 0), 
					Name = "corner"
				}),
				create("Frame", { 
					Theme = {
						BackgroundColor3 = "mainbackground"
					},
					AnchorPoint = Vector2.new(0.5, 0),
					BorderSizePixel = 0, 
					Position = UDim2.new(0.5, 0, 0, 0), 
					Size = UDim2.new(1, 0, 0.5, 0), 
					Name = "cover"
				})
			}),
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextBox", { 
				Theme = {
					TextColor3 = "foreground"
				},
				ClipsDescendants = true,
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				PlaceholderText = newbox.numonly and "Enter Number..." or "Enter Text...", 
				Text = "",
				TextSize = 11, 
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				AnchorPoint = Vector2.new(0.5, 0), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0, 0), 
				Size = UDim2.new(1, -14, 1, -2), 
				Name = "input"
			})
		})
	})

	newbox.frame.container.input.FocusLost:Connect(function()
		newbox:set(newbox.frame.container.input.Text)
	end)

	newbox.frame.container.input:GetPropertyChangedSignal("Text"):Connect(function()
		local sizex = math.min(textservice:GetTextSize(newbox.frame.container.input.Text == "" and newbox.frame.container.input.PlaceholderText or newbox.frame.container.input.Text, 11, Enum.Font.Gotham, hugevec2).X + 14, newbox.maxx)
		if newbox.frame.container.AbsoluteSize.X ~= sizex then
			newbox.frame.container.Size = UDim2.new(0, sizex, 1, 0)
		end
	end)

    newbox.frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            newbox.frame.container.input:CaptureFocus()
        end
    end)

	return newbox
end

function box:set(value)
	local str = tostring(value)
	if str ~= "" and self.numonly and not tonumber(str) then
		self.frame.container.input.Text = self.library.flags[self.flag] or ""
	else
		self.frame.container.input.Text = str
		self.library.flags[self.flag] = str
		coroutine.wrap(self.callback)(str)
	end
end

--[[ Slider ]]--

local slider = {}
slider.__index = slider

function slider.new(options)
	local newslider = setmetatable(mergetables({
		itemtype = "slider",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		min = 0,
		max = 100,
		float = 1,
		callback = function() end
	}, options), slider)
	
	newslider.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 34), 
		Name = newslider.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newslider.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, 0, 0, 20), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			AnchorPoint = Vector2.new(0.5, 1), 
			Position = UDim2.new(0.5, 0, 1, 0), 
			Size = UDim2.new(1, 0, 0, 12), 
			Name = "drag"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "sectionbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				Name = "inside"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					Theme = {
						BackgroundColor3 = "highlight"
					},
					AnchorPoint = Vector2.new(0, 0.5), 
					BorderSizePixel = 0, 
					Position = UDim2.new(0, 0, 0.5, 0), 
					Size = UDim2.new(0, 0, 1, 0), 
					Name = "indicator"
				})
			})
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(1, 0), 
			Position = UDim2.new(1, 0, 0, 0), 
			Size = UDim2.new(0, 23, 0, 20), 
			Name = "value"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextBox", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				PlaceholderText = "Value", 
				Text = tostring(newslider.min), 
				TextSize = 11, 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -12, 1, 0), 
				Name = "input"
			})
		})
	})

	local slidemaid = evov3.imports:fetchsystem("maid")
	newslider.frame.drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            newslider.library.settings.dragging = true
			slidemaid:givetask(mouse.Move:Connect(function()
				newslider:set(newslider.min + ((newslider.max - newslider.min) * ((mouse.X - newslider.frame.drag.inside.AbsolutePosition.X) / newslider.frame.drag.inside.AbsoluteSize.X)))
			end))
			slidemaid:givetask(input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
                    slidemaid:dispose()
					newslider.library.settings.dragging = false
				end
			end))
        end
    end)

	newslider.frame.value.input:GetPropertyChangedSignal("Text"):Connect(function()
		local value = newslider.frame.value.input.Text
		local numvalue = tonumber(value)
		newslider.frame.value.Size = UDim2.new(0, textservice:GetTextSize(value, 11, Enum.Font.Gotham, hugevec2).X + 12, 0, 20)
		if numvalue then
			if numvalue ~= newslider.library.flags[newslider.flag] then
				newslider:set(numvalue)
			end
		else
			newslider.frame.value.input.Text = tostring(newslider.library.flags[newslider.flag])
		end
	end)

	return newslider
end

function slider:set(value)
	local numvalue = math.clamp(round(value, self.float), self.min, self.max)
	if numvalue ~= self.library.flags[self.flag] then
		self.library.flags[self.flag] = numvalue
		tween(self.frame.drag.inside.indicator, 0.25, { Size = UDim2.new((numvalue - self.min) / (self.max - self.min), 0, 1, 0) })
		self.frame.value.input.Text = tostring(numvalue)
		coroutine.wrap(self.callback)(numvalue)
	end
end

--[[ Toggle Slider ]]--

local toggleslider = {}
toggleslider.__index = toggleslider

function toggleslider.new(options)
	local newtoggleslider = setmetatable(mergetables({
		itemtype = "toggleslider",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		min = 0,
		max = 100,
		float = 1,
		onstatechanged = function() end,
		onvaluechanged = function() end
	}, options), toggleslider)

	newtoggleslider.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 34), 
		Name = newtoggleslider.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newtoggleslider.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0, 0), 
			Size = UDim2.new(1, -26, 0, 18), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			Size = UDim2.new(0, 18, 0, 18), 
			Name = "border"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = function()
						return newtoggleslider.library and newtoggleslider.library.flags[newtoggleslider.flag].enabled and "highlight" or "sectionbackground"
					end
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				Name = "indicator"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			AnchorPoint = Vector2.new(0.5, 1), 
			Position = UDim2.new(0.5, 0, 1, 0), 
			Size = UDim2.new(1, 0, 0, 12), 
			Name = "drag"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "sectionbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				Name = "inside"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					Theme = {
						BackgroundColor3 = "highlight"
					},
					AnchorPoint = Vector2.new(0, 0.5), 
					BorderSizePixel = 0, 
					Position = UDim2.new(0, 0, 0.5, 0), 
					Size = UDim2.new(0, 0, 1, 0), 
					Name = "indicator"
				})
			})
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(1, 0), 
			Position = UDim2.new(1, 0, 0, 0), 
			Size = UDim2.new(0, 23, 0, 18), 
			Name = "value"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextBox", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				PlaceholderText = "Value", 
				Text = tostring(newtoggleslider.min), 
				TextSize = 11, 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -12, 1, 0), 
				Name = "input"
			})
		})
	})

	local slidemaid = evov3.imports:fetchsystem("maid")
	newtoggleslider.frame.drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            newtoggleslider.library.settings.dragging = true
			slidemaid:givetask(mouse.Move:Connect(function()
				newtoggleslider:set(newtoggleslider.min + ((newtoggleslider.max - newtoggleslider.min) * ((mouse.X - newtoggleslider.frame.drag.inside.AbsolutePosition.X) / newtoggleslider.frame.drag.inside.AbsoluteSize.X)))
			end))
			slidemaid:givetask(input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
                    slidemaid:dispose()
					newtoggleslider.library.settings.dragging = false
				end
			end))
        end
    end)

	newtoggleslider.frame.value.input:GetPropertyChangedSignal("Text"):Connect(function()
		local value = newtoggleslider.frame.value.input.Text
		local numvalue = tonumber(value)
		newtoggleslider.frame.value.Size = UDim2.new(0, textservice:GetTextSize(value, 11, Enum.Font.Gotham, hugevec2).X + 12, 0, 20)
		if numvalue then
			if numvalue ~= newtoggleslider.library.flags[newtoggleslider.flag].value then
				newtoggleslider:set(numvalue)
			end
		else
			newtoggleslider.frame.value.input.Text = tostring(newtoggleslider.library.flags[newtoggleslider.flag].value)
		end
	end)

	newtoggleslider.frame.border.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			newtoggleslider:switch()
		end
	end)

	return newtoggleslider
end

function toggleslider:set(value)
	local numvalue = math.clamp(round(value, self.float), self.min, self.max)
	if numvalue ~= self.library.flags[self.flag].value then
		self.library.flags[self.flag].value = numvalue
		tween(self.frame.drag.inside.indicator, 0.25, { Size = UDim2.new((numvalue - self.min) / (self.max - self.min), 0, 1, 0) })
		self.frame.value.input.Text = tostring(numvalue)
		coroutine.wrap(self.onvaluechanged)(numvalue)
	end
end

function toggleslider:toggle(bool)
	self.library.flags[self.flag].enabled = bool
	tween(self.frame.border.indicator, 0.25, { BackgroundColor3 = bool and theme.highlight or theme.sectionbackground })
	coroutine.wrap(self.onstatechanged)(bool)
end

function toggleslider:switch()
	self:toggle(not self.library.flags[self.flag].enabled)
end

--[[ Dropdown ]]--

local dropdown = {}
dropdown.__index = dropdown

function dropdown.new(options)
	local newdropdown = setmetatable(mergetables({
		itemtype = "dropdown",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		callback = function() end,
		settings = {
			open = false
		}
	}, options), dropdown)

	newdropdown.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 44), 
		Name = newdropdown.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newdropdown.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, 0, 0, 20), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 0), 
			Size = UDim2.new(1, 0, 0, 22), 
			Name = "bar"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("ImageLabel", { 
				Theme = {
					ImageColor3 = "foreground"
				},
				Image = "rbxassetid://9243354333", 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(1, -2, 0.5, 0), 
				Size = UDim2.new(0, 18, 0, 18), 
				Name = "arrow"
			}),
			create("TextLabel", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				Text = "", 
				TextSize = 11, 
				TextXAlignment = Enum.TextXAlignment.Left, 
				AnchorPoint = Vector2.new(0, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0, 7, 0.5, 0), 
				Size = UDim2.new(1, -29, 1, 0), 
				Name = "selected"
			})
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			ClipsDescendants = true, 
			Position = UDim2.new(0.5, 0, 1, 2), 
			Size = UDim2.new(1, 0, 0, 0), 
			ZIndex = 3, 
			Name = "drop"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextButton", {
				Font = Enum.Font.SourceSans,
				FontSize = Enum.FontSize.Size14,
				Text = "",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 14,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
				Name = "clickblock"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "mainbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				ZIndex = 3, 
				Name = "panel"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					Theme = {
						BackgroundColor3 = "sectionbackground"
					},
					AnchorPoint = Vector2.new(0.5, 0.5), 
					Position = UDim2.new(0.5, 0, 0.5, 0), 
					Size = UDim2.new(1, -4, 1, -4), 
					ZIndex = 3, 
					Name = "container"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("ScrollingFrame", { 
						CanvasSize = UDim2.new(0, 0, 0, 0), 
						ScrollBarImageColor3 = Color3.new(0, 0, 0), 
						ScrollBarThickness = 4, 
						Active = true, 
						AnchorPoint = Vector2.new(1, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						BorderSizePixel = 0, 
						Position = UDim2.new(1, 0, 0.5, 0), 
						Size = UDim2.new(1, -4, 1, -8), 
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
						ZIndex = 3, 
						Name = "holder"
					}, {
						create("UIListLayout", { 
							Padding = UDim.new(0, 2), 
							SortOrder = Enum.SortOrder.LayoutOrder, 
							Name = "list"
						})
					})
				})
			})
		})
	})
	
	autocanvasresize(newdropdown.frame.drop.panel.container.holder.list, newdropdown.frame.drop.panel.container.holder)

	newdropdown.frame.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if newdropdown.settings.open then
				newdropdown:close()
			else
				newdropdown:open()
			end
		end
	end)

	return newdropdown
end

function dropdown:open(force)
	if force or self.settings.open == false then
		self.settings.open = true
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(106, 10 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function dropdown:close()
	if self.settings.open == true then
		self.settings.open = false
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
	end
end

function dropdown:additem(value)
	local strvalue = tostring(value)
	local item = create("Frame", {
		Theme = {
			BackgroundColor3 = function()
				return self.library.flags[self.flag] == strvalue and "highlight" or "mainbackground"
			end
		},
		Parent = self.frame.drop.panel.container.holder,
		Size = UDim2.new(1, -4, 0, 22), 
		ZIndex = 3, 
		Name = strvalue
	}, {
		create("UICorner", { 
			CornerRadius = UDim.new(0, 3), 
			Name = "corner"
		}),
		create("TextLabel", { 
			Theme = {
				BackgroundColor3 = "mainbackground",
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size11, 
			Text = strvalue, 
			TextSize = 11, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, -2, 1, -2), 
			ZIndex = 3, 
			Name = "label"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			})
		})
	})

	item.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:set(value)
		end
	end)
end

function dropdown:removeitem(value)
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" and item.Name == value then
			item:Destroy()
			break
		end
	end
	if self.settings.open then
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(106, 10 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function dropdown:clear()
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" then
			item:Destroy()
		end
	end
	if self.settings.open then
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(106, 10 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function dropdown:set(value)
	local strvalue = tostring(value)
	if self.library.flags[self.flag] ~= strvalue then
		local items = self.frame.drop.panel.container.holder:GetChildren()
		for i = 1, #items do
			local item = items[i]
			if item.ClassName == "Frame" then
				if item.Name == self.library.flags[self.flag] then
					tween(item, 0.25, { BackgroundColor3 = theme.mainbackground })
				elseif item.Name == strvalue then
					tween(item, 0.25, { BackgroundColor3 = theme.highlight })
				end
			end
		end
		self.library.flags[self.flag] = strvalue
		self.frame.bar.selected.Text = strvalue
		coroutine.wrap(self.callback)(value)
	end
end

--[[ Toggle Dropdown ]]--

local toggledropdown = {}
toggledropdown.__index = toggledropdown

function toggledropdown.new(options)
	local newtoggledropdown = setmetatable(mergetables({
		itemtype = "toggledropdown",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		onvaluechanged = function() end,
		onstatechanged = function() end,
		settings = {
			open = false
		}
	}, options), toggledropdown)
	
	newtoggledropdown.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 42), 
		Name = newtoggledropdown.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newtoggledropdown.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0, 0), 
			Size = UDim2.new(1, -26, 0, 18), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			Size = UDim2.new(0, 18, 0, 18), 
			Name = "border"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = function()
						return newtoggledropdown.library and newtoggledropdown.library.flags[newtoggledropdown.flag].enabled and "highlight" or "sectionbackground"
					end
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				Name = "indicator"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 0), 
			Size = UDim2.new(1, 0, 0, 20), 
			Name = "bar"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("ImageLabel", { 
				Theme = {
					ImageColor3 = "foreground"
				},
				Image = "rbxassetid://9243354333", 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(1, -2, 0.5, 0), 
				Size = UDim2.new(0, 18, 0, 18), 
				Name = "arrow"
			}),
			create("TextLabel", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				Text = "", 
				TextSize = 11, 
				TextXAlignment = Enum.TextXAlignment.Left, 
				AnchorPoint = Vector2.new(0, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0, 7, 0.5, 0), 
				Size = UDim2.new(1, -29, 1, 0), 
				Name = "selected"
			})
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			ClipsDescendants = true, 
			Position = UDim2.new(0.5, 0, 1, 2), 
			Size = UDim2.new(1, 0, 0, 0), 
			ZIndex = 3, 
			Name = "drop"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextButton", {
				Font = Enum.Font.SourceSans,
				FontSize = Enum.FontSize.Size14,
				Text = "",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 14,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
				Name = "clickblock"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "mainbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				ZIndex = 3, 
				Name = "panel"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					Theme = {
						BackgroundColor3 = "sectionbackground"
					},
					AnchorPoint = Vector2.new(0.5, 0.5), 
					Position = UDim2.new(0.5, 0, 0.5, 0), 
					Size = UDim2.new(1, -4, 1, -4), 
					ZIndex = 3, 
					Name = "container"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("ScrollingFrame", { 
						CanvasSize = UDim2.new(0, 0, 0, 0), 
						ScrollBarImageColor3 = Color3.new(0, 0, 0), 
						ScrollBarThickness = 4, 
						Active = true, 
						AnchorPoint = Vector2.new(1, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						BorderSizePixel = 0, 
						Position = UDim2.new(1, 0, 0.5, 0), 
						Size = UDim2.new(1, -4, 1, -8), 
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
						ZIndex = 3, 
						Name = "holder"
					}, {
						create("UIListLayout", { 
							Padding = UDim.new(0, 2), 
							SortOrder = Enum.SortOrder.LayoutOrder, 
							Name = "list"
						})
					})
				})
			})
		})
	})

	autocanvasresize(newtoggledropdown.frame.drop.panel.container.holder.list, newtoggledropdown.frame.drop.panel.container.holder)

	newtoggledropdown.frame.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if newtoggledropdown.settings.open then
				newtoggledropdown:close()
			else
				newtoggledropdown:open()
			end
		end
	end)
	
	newtoggledropdown.frame.border.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			newtoggledropdown:switch()
		end
	end)

	return newtoggledropdown
end

function toggledropdown:open(force)
	if force or self.settings.open == false then
		self.settings.open = true
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(106, 10 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function toggledropdown:close()
	if self.settings.open == true then
		self.settings.open = false
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
	end
end

function toggledropdown:additem(value)
	local strvalue = tostring(value)
	local item = create("Frame", {
		Theme = {
			BackgroundColor3 = function()
				return self.library.flags[self.flag] == strvalue and "highlight" or "mainbackground"
			end
		},
		Parent = self.frame.drop.panel.container.holder,
		Size = UDim2.new(1, -4, 0, 22), 
		ZIndex = 3, 
		Name = strvalue
	}, {
		create("UICorner", { 
			CornerRadius = UDim.new(0, 3), 
			Name = "corner"
		}),
		create("TextLabel", { 
			Theme = {
				BackgroundColor3 = "mainbackground",
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size11, 
			Text = strvalue, 
			TextSize = 11, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, -2, 1, -2), 
			ZIndex = 3, 
			Name = "label"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			})
		})
	})

	item.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:set(value)
		end
	end)
end

function toggledropdown:removeitem(value)
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" and item.Name == value then
			item:Destroy()
			break
		end
	end
	if self.settings.open then
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(106, 10 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function toggledropdown:clear()
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" then
			item:Destroy()
		end
	end
	if self.settings.open then
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(106, 10 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function toggledropdown:set(value)
	local strvalue = tostring(value)
	if self.library.flags[self.flag].selected ~= strvalue then
		local items = self.frame.drop.panel.container.holder:GetChildren()
		for i = 1, #items do
			local item = items[i]
			if item.ClassName == "Frame" then
				if item.Name == self.library.flags[self.flag].selected then
					tween(item, 0.25, { BackgroundColor3 = theme.mainbackground })
				elseif item.Name == strvalue then
					tween(item, 0.25, { BackgroundColor3 = theme.highlight })
				end
			end
		end
		self.library.flags[self.flag].selected = strvalue
		self.frame.bar.selected.Text = strvalue
		self.onvaluechanged(value)
	end
end

function toggledropdown:toggle(bool)
	self.library.flags[self.flag].enabled = bool
	tween(self.frame.border.indicator, 0.25, { BackgroundColor3 = bool and theme.highlight or theme.sectionbackground })
	coroutine.wrap(self.onstatechanged)(bool)
end

function toggledropdown:switch()
	self:toggle(not self.library.flags[self.flag].enabled)
end

--[[ Colour Picker ]]--

local picker = {}
picker.__index = picker

function picker.new(options)
	local newpicker = setmetatable(mergetables({
		itemtype = "picker",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		callback = function() end,
		settings = {
			open = false
		}
	}, options), picker)
	
	newpicker.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 20), 
		Name = newpicker.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newpicker.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0, 0, 0.5, 0), 
			Size = UDim2.new(1, 0, 1, 0), 
			Name = "title"
		}),
		create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 0, 0),
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(0, 59, 1, 0), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextLabel", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				Text = "255, 0, 0", 
				TextSize = 11, 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -14, 1, 0), 
				Name = "rgb"
			})
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(0.5, 0), 
			Position = UDim2.new(0.5, 0, 1, 2), 
			Size = UDim2.new(1, 0, 0, 148), 
			Visible = false, 
			ZIndex = 3, 
			Name = "drop"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextButton", {
				Font = Enum.Font.SourceSans,
				FontSize = Enum.FontSize.Size14,
				Text = "",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 14,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
				Name = "clickblock"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "sectionbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -4, 1, -4), 
				ZIndex = 3, 
				Name = "container"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					Position = UDim2.new(0, 6, 0, 6), 
					Size = UDim2.new(0, 136, 0, 82), 
					ZIndex = 3, 
					Name = "sat"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 4), 
						Name = "corner"
					}),
					create("UIGradient", { 
						Color = ColorSequence.new({ 
							ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), 
							ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
						}), 
						Name = "gradient"
					}),
					create("Frame", { 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(1, 0, 1, 0), 
						ZIndex = 3, 
						Name = "val"
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						}),
						create("UIGradient", { 
							Color = ColorSequence.new({ 
								ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), 
								ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
							}), 
							Rotation = 270, 
							Transparency = NumberSequence.new({ 
								NumberSequenceKeypoint.new(0, 0), 
								NumberSequenceKeypoint.new(1, 1)
							}), 
							Name = "gradient"
						})
					}),
					create("ImageLabel", { 
						Theme = {
							ImageColor3 = "foreground"
						},
						Image = "rbxassetid://9240358248", 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(1, 0, 0, 0), 
						Size = UDim2.new(0, 16, 0, 16), 
						ZIndex = 4, 
						Name = "indicator"
					})
				}),
				create("TextBox", { 
					Theme = {
						BackgroundColor3 = "mainbackground",
						TextColor3 = "foreground"
					},
					Font = Enum.Font.Gotham, 
					FontSize = Enum.FontSize.Size11, 
					PlaceholderText = "Red", 
					Text = "255",  
					TextSize = 11, 
					AnchorPoint = Vector2.new(1, 0), 
					Position = UDim2.new(1, -6, 0, 6), 
					Size = UDim2.new(0, 55, 0, 25), 
					ZIndex = 4, 
					Name = "red"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					})
				}),
				create("TextBox", { 
					Theme = {
						BackgroundColor3 = "mainbackground",
						TextColor3 = "foreground"
					},
					Font = Enum.Font.Gotham, 
					FontSize = Enum.FontSize.Size11, 
					PlaceholderText = "Green", 
					Text = "0", 
					TextSize = 11, 
					AnchorPoint = Vector2.new(1, 0), 
					Position = UDim2.new(1, -6, 0, 35), 
					Size = UDim2.new(0, 55, 0, 25), 
					ZIndex = 4, 
					Name = "green"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					})
				}),
				create("TextBox", { 
					Theme = {
						BackgroundColor3 = "mainbackground",
						TextColor3 = "foreground"
					},
					Font = Enum.Font.Gotham, 
					FontSize = Enum.FontSize.Size11, 
					PlaceholderText = "Blue", 
					Text = "0", 
					TextSize = 11, 
					AnchorPoint = Vector2.new(1, 0), 
					Position = UDim2.new(1, -6, 0, 64), 
					Size = UDim2.new(0, 55, 0, 25), 
					ZIndex = 4, 
					Name = "blue"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					})
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					Position = UDim2.new(0.5, 0, 0, 94), 
					Size = UDim2.new(1, -12, 0, 18), 
					ZIndex = 3, 
					Name = "hue"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("UIGradient", { 
						Color = ColorSequence.new({ 
							ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), 
							ColorSequenceKeypoint.new(0.1666666666666666, Color3.new(1, 1, 0)), 
							ColorSequenceKeypoint.new(0.3333333333333333, Color3.new(0, 1, 0)), 
							ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)), 
							ColorSequenceKeypoint.new(0.6666666666666666, Color3.new(0, 0, 1)), 
							ColorSequenceKeypoint.new(0.8333333333333333, Color3.new(1, 0, 1)), 
							ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
						}), 
						Name = "gradient"
					}),
					create("Frame", { 
						Theme = {
							BackgroundColor3 = "sectionbackground"
						},
						AnchorPoint = Vector2.new(0.5, 0.5), 
						Position = UDim2.new(0.63, 0, 0.5, 0), 
						Size = UDim2.new(0, 4, 1, 0), 
						ZIndex = 4, 
						Name = "indicator"
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(1, 0), 
							Name = "corner"
						})
					})
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 1), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0.5, 0, 1, -6), 
					Size = UDim2.new(1, -12, 0, 20), 
					ZIndex = 3, 
					Name = "rainbow"
				}, {
					create("TextLabel", { 
						Theme = {
							TextColor3 = "foreground"
						},
						Font = Enum.Font.Gotham, 
						FontSize = Enum.FontSize.Size12, 
						Text = "Rainbow", 
						TextSize = 12, 
						TextXAlignment = Enum.TextXAlignment.Left, 
						AnchorPoint = Vector2.new(1, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(1, 0, 0.5, 0), 
						Size = UDim2.new(1, -26, 1, 0), 
						ZIndex = 3, 
						Name = "title"
					}),
					create("Frame", { 
						Theme = {
							BackgroundColor3 = "highlight"
						},
						AnchorPoint = Vector2.new(0, 0.5), 
						Position = UDim2.new(0, 0, 0.5, 0), 
						Size = UDim2.new(0, 20, 0, 20), 
						ZIndex = 3, 
						Name = "border"
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						}),
						create("Frame", { 
							Theme = {
								BackgroundColor3 = function()
									return newpicker.library and newpicker.library.flags[newpicker.flag].rainbow and "highlight" or "sectionbackground"
								end
							},
							AnchorPoint = Vector2.new(0.5, 0.5), 
							Position = UDim2.new(0.5, 0, 0.5, 0), 
							Size = UDim2.new(1, -2, 1, -2), 
							ZIndex = 3, 
							Name = "indicator"
						}, {
							create("UICorner", { 
								CornerRadius = UDim.new(0, 3), 
								Name = "corner"
							})
						})
					})
				})
			})
		})
	})
	
	newpicker.frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if newpicker.settings.open then
                newpicker:close()
            else
                newpicker:open()
            end
        end
    end)

    local pickermaid = evov3.imports:fetchsystem("maid")
	newpicker.maid = evov3.imports:fetchsystem("maid")
    newpicker.frame.drop.container.hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and newpicker.library.settings.dragging == false then
            if newpicker.library.flags[newpicker.flag].rainbow then
                newpicker:togglerainbow(false)
            end
            newpicker.library.settings.dragging = true
            pickermaid:givetask(mouse.Move:Connect(function()
                newpicker:set(math.clamp((mouse.X - newpicker.frame.drop.container.hue.AbsolutePosition.X) / newpicker.frame.drop.container.hue.AbsoluteSize.X, 0, 1), newpicker.library.flags[newpicker.flag].s, newpicker.library.flags[newpicker.flag].v)
            end))
            pickermaid:givetask(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    pickermaid:dispose()
                    newpicker.library.settings.dragging = false
                end
            end))
        end
    end)

    newpicker.frame.drop.container.sat.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not newpicker.library.settings.dragging then
            newpicker.library.settings.dragging = true
            pickermaid:givetask(mouse.Move:Connect(function()
                newpicker:set(newpicker.library.flags[newpicker.flag].h, math.clamp((mouse.X - newpicker.frame.drop.container.sat.AbsolutePosition.X) / newpicker.frame.drop.container.sat.AbsoluteSize.X, 0, 1), 1 - math.clamp((mouse.Y - newpicker.frame.drop.container.sat.AbsolutePosition.Y) / newpicker.frame.drop.container.sat.AbsoluteSize.Y, 0, 1))
            end))
            pickermaid:givetask(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    pickermaid:dispose()
                    newpicker.library.settings.dragging = false
                end
            end))
        end
    end)

    newpicker.frame.drop.container.red.FocusLost:Connect(function()
        local num = tonumber(newpicker.frame.drop.container.red.Text)
        local colour = Color3.fromHSV(newpicker.library.flags[newpicker.flag].h, newpicker.library.flags[newpicker.flag].s, newpicker.library.flags[newpicker.flag].v)
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            newpicker:set(Color3.new(num / 255, colour.G, colour.B):ToHSV())
        else
            newpicker.frame.drop.container.red.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

    newpicker.frame.drop.container.green.FocusLost:Connect(function()
        local num = tonumber(newpicker.frame.drop.container.green.Text)
        local colour = Color3.fromHSV(newpicker.library.flags[newpicker.flag].h, newpicker.library.flags[newpicker.flag].s, newpicker.library.flags[newpicker.flag].v)
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            newpicker:set(Color3.new(colour.R, num / 255, colour.B):ToHSV())
        else
            newpicker.frame.drop.container.green.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

    newpicker.frame.drop.container.blue.FocusLost:Connect(function()
        local num = tonumber(newpicker.frame.drop.container.blue.Text)
        local colour = Color3.fromHSV(newpicker.library.flags[newpicker.flag].h, newpicker.library.flags[newpicker.flag].s, newpicker.library.flags[newpicker.flag].v)
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            newpicker:set(Color3.new(colour.R, colour.G, num / 255):ToHSV())
        else
            newpicker.frame.drop.container.blue.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)
	
	newpicker.frame.drop.container.rainbow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            newpicker:switchrainbow()
        end
    end)

	return newpicker
end

function picker:open(force)
	if force or self.settings.open == false then
		self.settings.open = true
		self.frame.drop.Visible = true
	end
end

function picker:close()
	if self.settings.open == true then
		self.settings.open = false
		self.frame.drop.Visible = false
	end
end

function picker:set(h, s, v)
	local colour = Color3.fromHSV(h, s, v)
	self.library.flags[self.flag].h = h
	self.library.flags[self.flag].s = s
	self.library.flags[self.flag].v = v
	self.frame.indicator.BackgroundColor3 = colour
	local roundr, roundg, roundb = math.floor(colour.R * 255 + 0.5), math.floor(colour.G * 255 + 0.5), math.floor(colour.B * 255 + 0.5)
	self.frame.drop.container.red.Text = roundr
	self.frame.drop.container.green.Text = roundg
	self.frame.drop.container.blue.Text = roundb
	self.frame.indicator.rgb.Text = string.format("%d, %d, %d", roundr, roundg, roundb)
	self.frame.indicator.Size = UDim2.new(0, textservice:GetTextSize(self.frame.indicator.rgb.Text, 11, Enum.Font.Gotham, hugevec2).X + 14, 1, 0)
	self.frame.drop.container.sat.gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
	tween(self.frame.drop.container.sat.indicator, 0.25, { Position = UDim2.new(s, 0, 1 - v, 0) })
	if self.library.flags[self.flag].rainbow then
		self.frame.drop.container.hue.indicator.Position = UDim2.new(h, 0, 0.5, 0)
	else
		tween(self.frame.drop.container.hue.indicator, 0.25, { Position = UDim2.new(h, 0, 0.5, 0) })
	end
	coroutine.wrap(self.callback)(colour)
end

function picker:togglerainbow(bool)
	self.library.flags[self.flag].rainbow = bool
	tween(self.frame.drop.container.rainbow.border.indicator, 0.25, { BackgroundColor3 = bool and theme.highlight or theme.sectionbackground })
	if bool then
		self.maid:givetask(runservice.Heartbeat:Connect(function()
			self:set(tick() % self.library.settings.rainbowspeed / self.library.settings.rainbowspeed, self.library.flags[self.flag].s, self.library.flags[self.flag].v)
		end))
	else
		self.maid:dispose()
	end
end

function picker:switchrainbow()
	self:togglerainbow(not self.library.flags[self.flag].rainbow)
end

--[[ Toggle Colour Picker ]]--

local togglepicker = {}
togglepicker.__index = togglepicker

function togglepicker.new(options)
	local newtogglepicker = setmetatable(mergetables({
		itemtype = "togglepicker",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		oncolourchanged = function() end,
		onstatechanged = function() end,
		settings = {
			open = false
		}
	}, options), togglepicker)
	
	newtogglepicker.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 18), 
		Name = newtogglepicker.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newtogglepicker.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0, 0), 
			Size = UDim2.new(1, -26, 1, 0), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			Size = UDim2.new(0, 18, 0, 18), 
			Name = "border"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = function()
						return newtogglepicker.library and newtogglepicker.library.flags[newtogglepicker.flag].enabled and "highlight" or "sectionbackground"
					end
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				Name = "indicator"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		}),
		create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 0, 0),
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(0, 59, 1, 0), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextLabel", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				Text = "255, 0, 0", 
				TextSize = 11, 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -14, 1, 0), 
				Name = "rgb"
			})
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(0.5, 0), 
			Position = UDim2.new(0.5, 0, 1, 2), 
			Size = UDim2.new(1, 0, 0, 148), 
			Visible = false, 
			ZIndex = 3, 
			Name = "drop"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextButton", {
				Font = Enum.Font.SourceSans,
				FontSize = Enum.FontSize.Size14,
				Text = "",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 14,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
				Name = "clickblock"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "sectionbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -4, 1, -4), 
				ZIndex = 3, 
				Name = "container"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					Position = UDim2.new(0, 6, 0, 6), 
					Size = UDim2.new(0, 136, 0, 82), 
					ZIndex = 3, 
					Name = "sat"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 4), 
						Name = "corner"
					}),
					create("UIGradient", { 
						Color = ColorSequence.new({ 
							ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), 
							ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
						}), 
						Name = "gradient"
					}),
					create("Frame", { 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(1, 0, 1, 0), 
						ZIndex = 3, 
						Name = "val"
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						}),
						create("UIGradient", { 
							Color = ColorSequence.new({ 
								ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), 
								ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
							}), 
							Rotation = 270, 
							Transparency = NumberSequence.new({ 
								NumberSequenceKeypoint.new(0, 0), 
								NumberSequenceKeypoint.new(1, 1)
							}), 
							Name = "gradient"
						})
					}),
					create("ImageLabel", { 
						Theme = {
							ImageColor3 = "foreground"
						},
						Image = "rbxassetid://9240358248", 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(1, 0, 0, 0), 
						Size = UDim2.new(0, 16, 0, 16), 
						ZIndex = 4, 
						Name = "indicator"
					})
				}),
				create("TextBox", { 
					Theme = {
						BackgroundColor3 = "mainbackground",
						TextColor3 = "foreground"
					},
					Font = Enum.Font.Gotham, 
					FontSize = Enum.FontSize.Size11, 
					PlaceholderText = "Red", 
					Text = "255",  
					TextSize = 11, 
					AnchorPoint = Vector2.new(1, 0), 
					Position = UDim2.new(1, -6, 0, 6), 
					Size = UDim2.new(0, 55, 0, 25), 
					ZIndex = 4, 
					Name = "red"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					})
				}),
				create("TextBox", { 
					Theme = {
						BackgroundColor3 = "mainbackground",
						TextColor3 = "foreground"
					},
					Font = Enum.Font.Gotham, 
					FontSize = Enum.FontSize.Size11, 
					PlaceholderText = "Green", 
					Text = "0", 
					TextSize = 11, 
					AnchorPoint = Vector2.new(1, 0), 
					Position = UDim2.new(1, -6, 0, 35), 
					Size = UDim2.new(0, 55, 0, 25), 
					ZIndex = 4, 
					Name = "green"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					})
				}),
				create("TextBox", { 
					Theme = {
						BackgroundColor3 = "mainbackground",
						TextColor3 = "foreground"
					},
					Font = Enum.Font.Gotham, 
					FontSize = Enum.FontSize.Size11, 
					PlaceholderText = "Blue", 
					Text = "0", 
					TextSize = 11, 
					AnchorPoint = Vector2.new(1, 0), 
					Position = UDim2.new(1, -6, 0, 64), 
					Size = UDim2.new(0, 55, 0, 25), 
					ZIndex = 4, 
					Name = "blue"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					})
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					Position = UDim2.new(0.5, 0, 0, 94), 
					Size = UDim2.new(1, -12, 0, 18), 
					ZIndex = 3, 
					Name = "hue"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("UIGradient", { 
						Color = ColorSequence.new({ 
							ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), 
							ColorSequenceKeypoint.new(0.1666666666666666, Color3.new(1, 1, 0)), 
							ColorSequenceKeypoint.new(0.3333333333333333, Color3.new(0, 1, 0)), 
							ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)), 
							ColorSequenceKeypoint.new(0.6666666666666666, Color3.new(0, 0, 1)), 
							ColorSequenceKeypoint.new(0.8333333333333333, Color3.new(1, 0, 1)), 
							ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
						}), 
						Name = "gradient"
					}),
					create("Frame", { 
						Theme = {
							BackgroundColor3 = "sectionbackground"
						},
						AnchorPoint = Vector2.new(0.5, 0.5), 
						Position = UDim2.new(0.63, 0, 0.5, 0), 
						Size = UDim2.new(0, 4, 1, 0), 
						ZIndex = 4, 
						Name = "indicator"
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(1, 0), 
							Name = "corner"
						})
					})
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 1), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0.5, 0, 1, -6), 
					Size = UDim2.new(1, -12, 0, 20), 
					ZIndex = 3, 
					Name = "rainbow"
				}, {
					create("TextLabel", { 
						Theme = {
							TextColor3 = "foreground"
						},
						Font = Enum.Font.Gotham, 
						FontSize = Enum.FontSize.Size12, 
						Text = "Rainbow", 
						TextSize = 12, 
						TextXAlignment = Enum.TextXAlignment.Left, 
						AnchorPoint = Vector2.new(1, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(1, 0, 0.5, 0), 
						Size = UDim2.new(1, -26, 1, 0), 
						ZIndex = 3, 
						Name = "title"
					}),
					create("Frame", { 
						Theme = {
							BackgroundColor3 = "highlight"
						},
						AnchorPoint = Vector2.new(0, 0.5), 
						Position = UDim2.new(0, 0, 0.5, 0), 
						Size = UDim2.new(0, 20, 0, 20), 
						ZIndex = 3, 
						Name = "border"
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						}),
						create("Frame", { 
							Theme = {
								BackgroundColor3 = function()
									return newtogglepicker.library and newtogglepicker.library.flags[newtogglepicker.flag].rainbow and "highlight" or "sectionbackground"
								end
							},
							AnchorPoint = Vector2.new(0.5, 0.5), 
							Position = UDim2.new(0.5, 0, 0.5, 0), 
							Size = UDim2.new(1, -2, 1, -2), 
							ZIndex = 3, 
							Name = "indicator"
						}, {
							create("UICorner", { 
								CornerRadius = UDim.new(0, 3), 
								Name = "corner"
							})
						})
					})
				})
			})
		})
	})
	
	newtogglepicker.frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and mouse.X - newtogglepicker.frame.AbsolutePosition.X > 20 then
            if newtogglepicker.settings.open then
                newtogglepicker:close()
            else
                newtogglepicker:open()
            end
        end
    end)

    local pickermaid = evov3.imports:fetchsystem("maid")
	newtogglepicker.maid = evov3.imports:fetchsystem("maid")
    newtogglepicker.frame.drop.container.hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and newtogglepicker.library.settings.dragging == false then
            if newtogglepicker.library.flags[newtogglepicker.flag].rainbow then
                newtogglepicker:togglerainbow(false)
            end
            newtogglepicker.library.settings.dragging = true
            pickermaid:givetask(mouse.Move:Connect(function()
                newtogglepicker:set(math.clamp((mouse.X - newtogglepicker.frame.drop.container.hue.AbsolutePosition.X) / newtogglepicker.frame.drop.container.hue.AbsoluteSize.X, 0, 1), newtogglepicker.library.flags[newtogglepicker.flag].s, newtogglepicker.library.flags[newtogglepicker.flag].v)
            end))
            pickermaid:givetask(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    pickermaid:dispose()
                    newtogglepicker.library.settings.dragging = false
                end
            end))
        end
    end)

    newtogglepicker.frame.drop.container.sat.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not newtogglepicker.library.settings.dragging then
            newtogglepicker.library.settings.dragging = true
            pickermaid:givetask(mouse.Move:Connect(function()
                newtogglepicker:set(newtogglepicker.library.flags[newtogglepicker.flag].h, math.clamp((mouse.X - newtogglepicker.frame.drop.container.sat.AbsolutePosition.X) / newtogglepicker.frame.drop.container.sat.AbsoluteSize.X, 0, 1), 1 - math.clamp((mouse.Y - newtogglepicker.frame.drop.container.sat.AbsolutePosition.Y) / newtogglepicker.frame.drop.container.sat.AbsoluteSize.Y, 0, 1))
            end))
            pickermaid:givetask(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    pickermaid:dispose()
                    newtogglepicker.library.settings.dragging = false
                end
            end))
        end
    end)

    newtogglepicker.frame.drop.container.red.FocusLost:Connect(function()
        local num = tonumber(newtogglepicker.frame.drop.container.red.Text)
        local colour = Color3.fromHSV(newtogglepicker.library.flags[newtogglepicker.flag].h, newtogglepicker.library.flags[newtogglepicker.flag].s, newtogglepicker.library.flags[newtogglepicker.flag].v)
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            newtogglepicker:set(Color3.new(num / 255, colour.G, colour.B):ToHSV())
        else
            newtogglepicker.frame.drop.container.red.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

    newtogglepicker.frame.drop.container.green.FocusLost:Connect(function()
        local num = tonumber(newtogglepicker.frame.drop.container.green.Text)
        local colour = Color3.fromHSV(newtogglepicker.library.flags[newtogglepicker.flag].h, newtogglepicker.library.flags[newtogglepicker.flag].s, newtogglepicker.library.flags[newtogglepicker.flag].v)
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            newtogglepicker:set(Color3.new(colour.R, num / 255, colour.B):ToHSV())
        else
            newtogglepicker.frame.drop.container.green.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

    newtogglepicker.frame.drop.container.blue.FocusLost:Connect(function()
        local num = tonumber(newtogglepicker.frame.drop.container.blue.Text)
        local colour = Color3.fromHSV(newtogglepicker.library.flags[newtogglepicker.flag].h, newtogglepicker.library.flags[newtogglepicker.flag].s, newtogglepicker.library.flags[newtogglepicker.flag].v)
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            newtogglepicker:set(Color3.new(colour.R, colour.G, num / 255):ToHSV())
        else
            newtogglepicker.frame.drop.container.blue.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)
	
	newtogglepicker.frame.drop.container.rainbow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            newtogglepicker:switchrainbow()
        end
    end)
	
	newtogglepicker.frame.border.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			newtogglepicker:switch()
		end
	end)

	return newtogglepicker
end

function togglepicker:open()
	if force or self.settings.open == false then
		self.settings.open = true
		self.frame.drop.Visible = true
	end
end

function togglepicker:close()
	if self.settings.open == true then
		self.settings.open = false
		self.frame.drop.Visible = false
	end
end

function togglepicker:set(h, s, v)
	local colour = Color3.fromHSV(h, s, v)
	self.library.flags[self.flag].h = h
	self.library.flags[self.flag].s = s
	self.library.flags[self.flag].v = v
	self.frame.indicator.BackgroundColor3 = colour
	local roundr, roundg, roundb = math.floor(colour.R * 255 + 0.5), math.floor(colour.G * 255 + 0.5), math.floor(colour.B * 255 + 0.5)
	self.frame.drop.container.red.Text = roundr
	self.frame.drop.container.green.Text = roundg
	self.frame.drop.container.blue.Text = roundb
	self.frame.indicator.rgb.Text = string.format("%d, %d, %d", roundr, roundg, roundb)
	self.frame.indicator.Size = UDim2.new(0, textservice:GetTextSize(self.frame.indicator.rgb.Text, 11, Enum.Font.Gotham, hugevec2).X + 14, 1, 0)
	self.frame.drop.container.sat.gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
	tween(self.frame.drop.container.sat.indicator, 0.25, { Position = UDim2.new(s, 0, 1 - v, 0) })
	if self.library.flags[self.flag].rainbow then
		self.frame.drop.container.hue.indicator.Position = UDim2.new(h, 0, 0.5, 0)
	else
		tween(self.frame.drop.container.hue.indicator, 0.25, { Position = UDim2.new(h, 0, 0.5, 0) })
	end
	coroutine.wrap(self.oncolourchanged)(colour)
end

function togglepicker:togglerainbow(bool)
	self.library.flags[self.flag].rainbow = bool
	tween(self.frame.drop.container.rainbow.border.indicator, 0.25, { BackgroundColor3 = bool and theme.highlight or theme.sectionbackground })
	if bool then
		self.maid:givetask(runservice.Heartbeat:Connect(function()
			self:set(tick() % self.library.settings.rainbowspeed / self.library.settings.rainbowspeed, self.library.flags[self.flag].s, self.library.flags[self.flag].v)
		end))
	else
		self.maid:dispose()
	end
end

function togglepicker:switchrainbow()
	self:togglerainbow(not self.library.flags[self.flag].rainbow)
end

function togglepicker:toggle(bool)
	self.library.flags[self.flag].enabled = bool
	tween(self.frame.border.indicator, 0.25, { BackgroundColor3 = bool and theme.highlight or theme.sectionbackground })
	coroutine.wrap(self.onstatechanged)(bool)
end

function togglepicker:switch()
	self:toggle(not self.library.flags[self.flag].enabled)
end

--[[ Checklist ]]--

local checklist = {}
checklist.__index = checklist

function checklist.new(options)
	local newchecklist = setmetatable(mergetables({
		itemtype = "checklist",
		content = "No Content Provided",
		flag = randomstring(32),
		ignore = false,
		callback = function() end,
		settings = {
			open = false
		}
	}, options), checklist)

	newchecklist.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 0, 44), 
		Name = newchecklist.content
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = newchecklist.content, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, 0, 0, 20), 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "mainbackground"
			},
			AnchorPoint = Vector2.new(0.5, 1), 
			Position = UDim2.new(0.5, 0, 1, 0), 
			Size = UDim2.new(1, 0, 0, 22), 
			Name = "bar"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("ImageLabel", { 
				Theme = {
					ImageColor3 = "foreground"
				},
				Image = "rbxassetid://9243354333", 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(1, -2, 0.5, 0), 
				Size = UDim2.new(0, 18, 0, 18), 
				Name = "arrow"
			}),
			create("TextLabel", { 
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size11, 
				Text = "", 
				TextSize = 11, 
				TextWrap = true, 
				TextWrapped = true, 
				TextXAlignment = Enum.TextXAlignment.Left, 
				AnchorPoint = Vector2.new(0, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				ClipsDescendants = true, 
				Position = UDim2.new(0, 7, 0.5, 0), 
				Size = UDim2.new(1, -29, 1, 0), 
				Name = "selected"
			})
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			ClipsDescendants = true, 
			Position = UDim2.new(0.5, 0, 1, 2), 
			Size = UDim2.new(1, 0, 0, 0), 
			ZIndex = 2, 
			Name = "drop"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = "mainbackground"
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				ZIndex = 2, 
				Name = "panel"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("Frame", { 
					Theme = {
						BackgroundColor3 = "sectionbackground"
					},
					AnchorPoint = Vector2.new(0.5, 0.5), 
					Position = UDim2.new(0.5, 0, 0.5, 0), 
					Size = UDim2.new(1, -4, 1, -4), 
					ZIndex = 2, 
					Name = "container"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("ScrollingFrame", { 
						CanvasSize = UDim2.new(0, 0, 0, 164), 
						ScrollBarImageColor3 = Color3.new(0, 0, 0), 
						ScrollBarThickness = 4, 
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar, 
						Active = true, 
						AnchorPoint = Vector2.new(1, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						BorderSizePixel = 0, 
						Position = UDim2.new(1, 0, 0.5, 0), 
						Size = UDim2.new(1, -4, 1, -8), 
						ZIndex = 2, 
						Name = "holder"
					}, {
						create("UIListLayout", { 
							Padding = UDim.new(0, 4), 
							SortOrder = Enum.SortOrder.LayoutOrder, 
							Name = "list"
						})
					})
				})
			})
		})
	})

	autocanvasresize(newchecklist.frame.drop.panel.container.holder.list, newchecklist.frame.drop.panel.container.holder)

	newchecklist.frame.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if newchecklist.settings.open then
				newchecklist:close()
			else
				newchecklist:open()
			end
		end
	end)
	
	return newchecklist
end

function checklist:open(force)
	if force or self.settings.open == false then
		self.settings.open = true
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(104, 8 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function checklist:close()
	if self.settings.open == true then
		self.settings.open = false
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
	end
end

function checklist:additem(key, value)
	local item = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.drop.panel.container.holder,
		Size = UDim2.new(1, 0, 0, 20), 
		ZIndex = 2, 
		Name = key
	}, {
		create("TextLabel", { 
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = key, 
			TextSize = 12, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(1, -26, 1, 0), 
			ZIndex = 2, 
			Name = "title"
		}),
		create("Frame", { 
			Theme = {
				BackgroundColor3 = "highlight"
			},
			AnchorPoint = Vector2.new(0, 0.5), 
			Position = UDim2.new(0, 0, 0.5, 0), 
			Size = UDim2.new(0, 20, 0, 20), 
			ZIndex = 2, 
			Name = "border"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("Frame", { 
				Theme = {
					BackgroundColor3 = function()
						return self.library and self.library.flags[self.flag][key] and "highlight" or "sectionbackground"
					end
				},
				AnchorPoint = Vector2.new(0.5, 0.5), 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -2, 1, -2), 
				ZIndex = 2, 
				Name = "indicator"
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		})
	})

	self.library.flags[self.flag][key] = false
	if value then
		self:toggle(key, true)
	end

	item.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:switch(key)
		end
	end)
end

function checklist:removeitem(key)
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" and item.Name == key then
			item:Destroy()
			break
		end
	end
	self.library.flags[self.flag][key] = nil
	if self.settings.open then
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(104, 8 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function checklist:clear()
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" then
			break
		end
	end
	for i, v in next, self.library.flags[self.flag] do
		self.library.flags[self.flag][i] = nil
	end
	if self.settings.open then
		tween(self.frame.drop, 0.25, { Size = UDim2.new(1, 0, 0, math.min(104, 8 + 24 * (#self.frame.drop.panel.container.holder:GetChildren() - 1))) })
	end
end

function checklist:toggle(key, value)
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		if item.ClassName == "Frame" then
			if item.Name == key then
				tween(item.border.indicator, 0.25, { BackgroundColor3 = value and theme.highlight or theme.sectionbackground })
				break
			end
		end
	end
	self.library.flags[self.flag][key] = value
	self:updateselected()
	coroutine.wrap(self.callback)(key, value)
end

function checklist:switch(key)
	self:toggle(key, not self.library.flags[self.flag][key])
end

function checklist:updateselected()
	local str = ""
	local items = self.frame.drop.panel.container.holder:GetChildren()
	for i = 1, #items do
		local item = items[i]
		local flag = self.library.flags[self.flag][item.Name]
		if flag then
			local nextstr = str .. (#str > 0 and ", " or "") .. item.Name
			local isvalid = textservice:GetTextSize(nextstr, 12, Enum.Font.Gotham, hugevec2).X <= 180
			str = str .. (#str > 0 and ", " or "") .. (isvalid and item.Name or "...")
			if isvalid == false then
				break
			end
		end
	end
	self.frame.bar.selected.Text = str
end

--[[ Section ]]--

local section = {}
section.__index = section

function section.new(options)
	local newsection = setmetatable(mergetables({
		content = "No Content Provided",
		right = false,
		settings = {
			open = true
		}
	}, options), section)

	newsection.frame = create("Frame", {
		Theme = {
			BackgroundColor3 = "sectionbackground"
		},
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Name = newsection.content
	}, {
		create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "corner"
		}),
		create("TextLabel", {
			Font = Enum.Font.GothamSemibold,
			FontSize = Enum.FontSize.Size14,
			Text = newsection.content,
			TextColor3 = Color3.new(0.921569, 0.921569, 0.921569),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, -16, 0, 30),
			Name = "title"
		}),
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0, 32),
			Size = UDim2.new(1, -12, 0, 0),
			Name = "container"
		}, {
			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Name = "list"
			})
		})
	})

	autoresize(newsection.frame.container.list, newsection.frame.container)

	return newsection
end

function section:addlabel(options)
	local newlabel = label.new(options)

	newlabel.library = self.library
	newlabel.frame.Parent = self.frame.container
	newlabel:update(newlabel.content)
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newlabel.flag] = newlabel
	return newlabel
end

function section:addstatuslabel(options)
	local newstatuslabel = statuslabel.new(options)

	newstatuslabel.library = self.library
	newstatuslabel.frame.Parent = self.frame.container
	newstatuslabel:update(newstatuslabel.status, newstatuslabel.colour)
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newstatuslabel.flag] = newstatuslabel
	return newstatuslabel
end

function section:addclipboardlabel(options)
	local newclipboardlabel = clipboardlabel.new(options)

	newclipboardlabel.library = self.library
	newclipboardlabel.frame.Parent = self.frame.container
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newclipboardlabel.flag] = newclipboardlabel
	return newclipboardlabel
end

function section:addbutton(options)
	local newbutton = button.new(options)

	newbutton.library = self.library
	newbutton.frame.Parent = self.frame.container
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })
	
	self.library:applybuttoneffect(newbutton.frame, newbutton.callback)
	self.library.items[newbutton.flag] = newbutton
	return newbutton
end

function section:addtoggle(options)
	local newtoggle = toggle.new(options)
	self.library.flags[newtoggle.flag] = false

	newtoggle.library = self.library
	newtoggle.frame.Parent = self.frame.container
	if options.default then
		newtoggle:set(true)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newtoggle.flag] = newtoggle
	return newtoggle
end

function section:addbind(options)
	local newbind = bind.new(options)
	self.library.flags[newbind.flag] = "None"

	newbind.library = self.library
	newbind.frame.Parent = self.frame.container
	if options.default then
		newbind:set(options.default)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newbind.flag] = newbind
	return newbind
end

function section:addbox(options)
	local newbox = box.new(options)
	self.library.flags[newbox.flag] = ""

	newbox.library = self.library
	newbox.frame.Parent = self.frame.container
	newbox.maxx = newbox.frame.AbsoluteSize.X - (textservice:GetTextSize(newbox.content, 12, Enum.Font.Gotham, hugevec2).X + 6)
	if options.default then
		newbox:set(options.default)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newbox.flag] = newbox
	return newbox
end

function section:addslider(options)
	local newslider = slider.new(options)
	self.library.flags[newslider.flag] = newslider.min

	newslider.library = self.library
	newslider.frame.Parent = self.frame.container
	if options.default then
		newslider:set(options.default)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newslider.flag] = newslider
	return newslider
end

function section:addtoggleslider(options)
	local newtoggleslider = toggleslider.new(options)
	self.library.flags[newtoggleslider.flag] = { enabled = false, value = newtoggleslider.min }

	newtoggleslider.library = self.library
	newtoggleslider.frame.Parent = self.frame.container
	if options.default then
		newtoggleslider:set(options.default)
	end
	if options.enabled then
		newtoggleslider:toggle(true)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newtoggleslider.flag] = newtoggleslider
	return newtoggleslider
end

function section:adddropdown(options)
	local newdropdown = dropdown.new(options)
	self.library.flags[newdropdown.flag] = ""

	newdropdown.library = self.library
	newdropdown.frame.Parent = self.frame.container
	if options.default then
		newdropdown:set(options.default)
	end
	if options.items then
		for i = 1, #options.items do
			newdropdown:additem(options.items[i])
		end
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })
	if newdropdown.settings.open then
		newdropdown:open(true)
	end

	self.library.items[newdropdown.flag] = newdropdown
	return newdropdown
end

function section:addtoggledropdown(options)
	local newtoggledropdown = toggledropdown.new(options)
	self.library.flags[newtoggledropdown.flag] = { enabled = false }

	newtoggledropdown.library = self.library
	newtoggledropdown.frame.Parent = self.frame.container
	if options.default then
		newtoggledropdown:set(options.default)
	end
	if options.enabled then
		newtoggledropdown:toggle(true)
	end
	if options.items then
		for i = 1, #options.items do
			newtoggledropdown:additem(options.items[i])
		end
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })
	if newtoggledropdown.settings.open then
		newtoggledropdown:open(true)
	end

	self.library.items[newtoggledropdown.flag] = newtoggledropdown
	return newtoggledropdown
end

function section:addpicker(options)
	local newpicker = picker.new(options)
	self.library.flags[newpicker.flag] = { h = 1, s = 1, v = 1, rainbow = false }

	newpicker.library = self.library
	newpicker.frame.Parent = self.frame.container
	if options.default then
		newpicker:set(options.default:ToHSV())
	end
	if options.rainbow then
		newpicker:togglerainbow(true)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })
	if newpicker.settings.open then
		newpicker:open(true)
	end

	self.library.items[newpicker.flag] = newpicker
	return newpicker
end

function section:addtogglepicker(options)
	local newtogglepicker = togglepicker.new(options)
	self.library.flags[newtogglepicker.flag] = { h = 1, s = 1, v = 1, rainbow = false, enabled = false }

	newtogglepicker.library = self.library
	newtogglepicker.frame.Parent = self.frame.container
	if options.default then
		newtogglepicker:set(options.default:ToHSV())
	end
	if options.rainbow then
		newpicker:togglerainbow(true)
	end
	if options.enabled then
		newpicker:toggle(true)
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })

	self.library.items[newtogglepicker.flag] = newtogglepicker
	return newtogglepicker
end

function section:addchecklist(options)
	local newchecklist = checklist.new(options)
	self.library.flags[newchecklist.flag] = {}

	newchecklist.library = self.library
	newchecklist.frame.Parent = self.frame.container
	if options.items then
		for i = 1, #options.items do
			newchecklist:additem(unpack(options.items[i]))
		end
	end
	tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.container.list.AbsoluteContentSize.Y + 38) })
	if newchecklist.settings.open then
		newchecklist:open(true)
	end

	self.library.items[newchecklist.flag] = newchecklist
	return newchecklist
end

--[[ Tab ]]--

local tab = {}
tab.__index = tab

function tab.new(options)
	local newtab = setmetatable(mergetables({
		content = "No Content Provided",
		icon = 0,
		settings = {
			open = false
		}
	}, options), tab)

	newtab.button = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 30),
		Name = newtab.content
	}, {
		create("ImageLabel", {
			Theme = {
				ImageColor3 = "highlight"
			},
			Image = "rbxassetid://" .. tostring(newtab.icon),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.new(0, 20, 0, 20),
			Name = "icon"
		}),
		create("TextLabel", {
			Theme = {
				TextColor3 = "foreground"
			},
			Font = Enum.Font.GothamBold,
			FontSize = Enum.FontSize.Size14,
			Text = newtab.content,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(1, -36, 1, 0),
			Name = "title"
		})
	})

	newtab.frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -16, 1, -16),
		Name = newtab.content,
		Visible = false
	}, {
		create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0.5, -4, 1, 0),
			Name = "left"
		}, {
			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Name = "list"
			})
		}),
		create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0.5, -4, 1, 0),
			Name = "right"
		}, {
			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Name = "list"
			})
		})
	})

	newtab.button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and newtab.settings.open == false then
			newtab:open()
		end
	end)

	return newtab
end

function tab:open()
	local selected = self.library.settings.selected
	if selected then
		if selected == self then
			return
		end
		selected:close()
	end
	self.library.settings.selected = self
	self.settings.open = true
	self.frame.Visible = true
end

function tab:close()
	if self.library.settings.selected == self then
		self.library.settings.selected = nil
		self.settings.open = false
		self.frame.Visible = false
	end
end

function tab:addsection(options)
	local newsection = section.new(options)

	newsection.library = self.library
	newsection.frame.Parent = self.frame[options.right and "right" or "left"]

	return newsection
end

--[[ Category ]]--

local category = {}
category.__index = category

function category.new(options)
	local newcategory = setmetatable(mergetables({
		content = "No Content Provided",
		settings = {
			open = false
		}
	}, options), category)

	newcategory.frame = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 34),
		Name = newcategory.content
	}, {
		create("Frame", {
			Theme = {
				BackgroundColor3 = "categorybackground"
			},
			AnchorPoint = Vector2.new(0.5, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			Name = "top"
		}, {
			create("ImageLabel", {
				Theme = {
					ImageColor3 = "foreground"
				},
				Image = "rbxassetid://9239668142",
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -5, 0.5, 0),
				Size = UDim2.new(0, 22, 0, 22),
				ZIndex = 2,
				Name = "arrow"
			}),
			create("TextLabel", {
				Theme = {
					TextColor3 = "foreground"
				},
				Font = Enum.Font.GothamBlack,
				FontSize = Enum.FontSize.Size14,
				Text = newcategory.content,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(1, -16, 1, 0),
				ZIndex = 2,
				Name = "title"
			})
		}),
		create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Name = "list"
		})
	})

	newcategory.frame.top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if newcategory.settings.open then
				newcategory:close()
			else
				newcategory:open()
			end
		end
	end)

	return newcategory
end

function category:open(force)
	if force or self.settings.open == false then
		self.settings.open = true
		tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.list.AbsoluteContentSize.Y) })
		tween(self.frame.top.arrow, 0.25, { Rotation = 90 })
	end
end

function category:close()
	if self.settings.open == true then
		self.settings.open = false
		tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, 34) })
		tween(self.frame.top.arrow, 0.25, { Rotation = 0 })
	end
end

function category:addtab(options)
	local newtab = tab.new(options)

	newtab.library = self.library
	newtab.frame.Parent = self.library.dir.gui.main.right.container
	newtab.button.Parent = self.frame
	if newtab.settings.open then
		newtab:open()
	end

	if self.settings.open then
		tween(self.frame, 0.25, { Size = UDim2.new(1, 0, 0, self.frame.list.AbsoluteContentSize.Y) })
	end

	return newtab
end

--[[ Library ]]--

local library = {}
library.__index = library

function library.new(options)
	local newlibrary = setmetatable(mergetables({
		content = "Unknown Game",
		version = "Unknown Version",
		flags = {},
		items = {},
		tabs = {},
		storage = {},
		settings = {
			theme = theme,
			dragging = false,
			binding = false,
			istextboxfocused = userinputservice:GetFocusedTextBox() ~= nil,
			rainbowspeed = 5,
			dragleniency = 0.15
		}
	}, options), library)

	newlibrary.configs = evov3.imports:fetchsystem("configs", options.content)

	newlibrary.dir = create("Folder", {
		Name = "EvoV3"
	}, {
		create("ScreenGui", {
			DisplayOrder = 10,
			Name = "gui"
		}, {
			create("Frame", {
				Theme = {
					BackgroundColor3 = "titlebackground"
				},
				Position = UDim2.new(0, 50, 0, 50),
				Size = UDim2.new(0, 645, 0, 475),
				Name = "main"
			}, {
				create("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Name = "corner"
				}),
				create("TextButton", {
					Font = Enum.Font.SourceSans,
					FontSize = Enum.FontSize.Size14,
					Text = "",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 14,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 0,
					Name = "clickblock"
				}),
				create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(0, 170, 1, 0),
					Name = "left"
				}, {
					create("Frame", {
						Theme = {
							BackgroundColor3 = "leftbackground"
						},
						BorderSizePixel = 0,
						ClipsDescendants = true,
						Position = UDim2.new(0, 0, 0, 80),
						Size = UDim2.new(1, 0, 1, -80),
						Name = "panel"
					}, {
						create("ScrollingFrame", {
							ScrollBarImageTransparency = 1,
							ScrollBarThickness = 0,
							Active = true,
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							CanvasSize = UDim2.new(),
							Position = UDim2.new(0.5, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, -30),
							Name = "container"
						}, {
							create("UIListLayout", {
								SortOrder = Enum.SortOrder.LayoutOrder,
								Name = "list"
							})
						}),
						create("TextButton", {
							Theme = {
								TextColor3 = "foreground",
								BackgroundColor3 = "categorybackground"
							},
							Font = Enum.Font.Gotham,
							FontSize = Enum.FontSize.Size12,
							Text = "Discord",
							TextSize = 12,
							AnchorPoint = Vector2.new(1, 1),
							AutoButtonColor = false,
							Position = UDim2.new(1, -4, 1, -4),
							Size = UDim2.new(0.5, -6, 0, 24),
							Name = "discord"
						}, {
							create("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Name = "corner"
							})
						}),
						create("TextButton", {
							Theme = {
								TextColor3 = "foreground",
								BackgroundColor3 = "categorybackground"
							},
							Font = Enum.Font.Gotham,
							FontSize = Enum.FontSize.Size12,
							Text = "Website",
							TextSize = 12,
							AnchorPoint = Vector2.new(0, 1),
							AutoButtonColor = false,
							Position = UDim2.new(0, 4, 1, -4),
							Size = UDim2.new(0.5, -6, 0, 24),
							Name = "website"
						}, {
							create("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Name = "corner"
							})
						}),
						create("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Name = "corner"
						}),
						create("Frame", {
							Theme = {
								BackgroundColor3 = "leftbackground"
							},
							AnchorPoint = Vector2.new(1, 1),
							BorderSizePixel = 0,
							Position = UDim2.new(1, 0, 1, 0),
							Size = UDim2.new(0, 4, 0, 4),
							Name = "cover"
						}),
						create("Frame", {
							Theme = {
								BackgroundColor3 = "leftbackground"
							},
							AnchorPoint = Vector2.new(1, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(1, 0, 0, 0),
							Size = UDim2.new(0, 4, 0, 4),
							Name = "cover"
						})
					}),
					create("TextLabel", {
						Theme = {
							TextColor3 = "foreground"
						},
						Font = Enum.Font.GothamBlack,
						FontSize = Enum.FontSize.Size24,
						Text = "EvoV3",
						TextSize = 20,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Bottom,
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 64, 0, 16),
						Size = UDim2.new(1, -72, 0, 26),
						Name = "title"
					}),
					create("TextLabel", {
						Theme = {
							TextColor3 = "highlight"
						},
						Font = Enum.Font.GothamBold,
						FontSize = Enum.FontSize.Size14,
						Text = newlibrary.content,
						TextScaled = true,
						TextSize = 14,
						TextWrap = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 64, 0, 43),
						Size = UDim2.new(1, -72, 0, 18),
						Name = "game"
					}),
					create("ImageLabel", {
						Image = "rbxassetid://9223312631",
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 8, 0, 16),
						Size = UDim2.new(0, 48, 0, 48),
						Name = "icon"
					})
				}),
				create("Frame", {
					Theme = {
						BackgroundColor3 = "mainbackground"
					},
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, 0, 1, 0),
					Size = UDim2.new(1, -170, 1, -40),
					Name = "right"
				}, {
					create("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Name = "corner"
					}),
					create("Frame", {
						Theme = {
							BackgroundColor3 = "mainbackground"
						},
						AnchorPoint = Vector2.new(1, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.new(0, 4, 0, 4),
						Name = "cover"
					}),
					create("Frame", {
						Theme = {
							BackgroundColor3 = "mainbackground"
						},
						AnchorPoint = Vector2.new(0, 1),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 1, 0),
						Size = UDim2.new(0, 4, 0, 4),
						Name = "cover"
					}),
					create("Folder", {
						Name = "container"
					}),
				}),
				create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, 40),
					Name = "top"
				}, {
					create("TextLabel", {
						Theme = {
							TextColor3 = "foreground"
						},
						Font = Enum.Font.GothamBold,
						FontSize = Enum.FontSize.Size18,
						Text = newlibrary.version,
						TextSize = 15,
						TextXAlignment = Enum.TextXAlignment.Right,
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -12, 0.5, 0),
						Size = UDim2.new(1, -190, 1, 0),
						Name = "version"
					})
				})
			}),
			create("Folder", {
				Name = "notifications"
			})
		})
	})

	if #newlibrary.storage > 0 then
		local storage = Instance.new("Folder", newlibrary.dir)
		for i = 1, #newlibrary.storage do
			Instance.new("Folder", storage).Name = newlibrary.storage[i]
		end
		newlibrary.storage = storage
	end

	userinputservice.TextBoxFocused:Connect(function()
		newlibrary.settings.istextboxfocused = true
	end)

	userinputservice.TextBoxFocusReleased:Connect(function()
		newlibrary.settings.istextboxfocused = false
	end)

	userinputservice.InputBegan:Connect(function(input)
        if newlibrary.settings.binding == false and newlibrary.settings.istextboxfocused == false then
            local name = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name or input.UserInputType.Name
            for i, v in next, newlibrary.items do
                if v.itemtype == "bind" and newlibrary.flags[i] == name then
                    v.onkeydown()
                end
            end
        end
    end)

    userinputservice.InputEnded:Connect(function(input)
        if newlibrary.settings.binding == false and newlibrary.settings.istextboxfocused == false then
            local name = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name or input.UserInputType.Name
            for i, v in next, newlibrary.items do
                if v.itemtype == "bind" and newlibrary.flags[i] == name then
                    v.onkeyup()
                end
            end
        end
    end)

	newlibrary:makedraggable(newlibrary.dir.gui.main)
	autocanvasresize(newlibrary.dir.gui.main.left.panel.container.list, newlibrary.dir.gui.main.left.panel.container)

	newlibrary:applybuttoneffect(newlibrary.dir.gui.main.left.panel.discord, function()
		setclipboard("https://discord.gg/evov3")
	end, "categorybackground")

	newlibrary:applybuttoneffect(newlibrary.dir.gui.main.left.panel.website, function()
		setclipboard("https://projectevo.xyz")
	end, "categorybackground")

	utils:protectinstance(newlibrary.dir)
	return newlibrary
end

function library:toggle()
	self.dir.gui.Enabled = not self.dir.gui.Enabled
end

function library:makedraggable(frame)
	local dragmaid = evov3.imports:fetchsystem("maid")
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.settings.dragging == false then
			self.settings.dragging = true
			local offset = Vector2.new(frame.AbsoluteSize.X * frame.AnchorPoint.X, frame.AbsoluteSize.Y * frame.AnchorPoint.Y)
			local pos = Vector2.new(mouse.X - (frame.AbsolutePosition.X + offset.X), mouse.Y - (frame.AbsolutePosition.Y + offset.Y))
            dragmaid:givetask(mouse.Move:Connect(function()
				tween(frame, self.settings.dragleniency, { Position = UDim2.new(0, mouse.X - pos.X, 0, mouse.Y - pos.Y) })
			end))
			dragmaid:givetask(input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
                    dragmaid:dispose()
					self.settings.dragging = false
				end
			end))
		end
	end)
end

function library:applybuttoneffect(button, callback, background)
	local size = button.TextSize
	if background then
		button.MouseEnter:Connect(function()
			tween(button, 0.25, { BackgroundColor3 = self.settings.theme.highlight })
		end)
		button.MouseLeave:Connect(function()
			tween(button, 0.25, { BackgroundColor3 = self.settings.theme[background] })
		end)
	end
	button.MouseButton1Down:Connect(function()
		task.spawn(callback)
		button.TextSize = 0
		tween(button, 0.25, { TextSize = size })
	end)
end

function library:addcategory(options)
	local newcategory = category.new(options)

	newcategory.library = self
	newcategory.frame.Parent = self.dir.gui.main.left.panel.container
	if newcategory.settings.open then
		newcategory:open(true)
	end

	return newcategory
end

function library:addsettings()
	local settingscat = self:addcategory({ content = "Settings" })
	
	local uitheme = settingscat:addtab({ content = "Theme" })

	local colours = uitheme:addsection({ content = "Colours" })
	colours:addpicker({ content = "Title Background", flag = "titlebackground", ignore = true, default = theme.titlebackground, callback = function(colour)
		theme.titlebackground = colour
	end })
	colours:addpicker({ content = "Main Background", flag = "mainbackground", ignore = true, default = theme.mainbackground, callback = function(colour)
		theme.mainbackground = colour
	end })
	colours:addpicker({ content = "Section Background", flag = "sectionbackground", ignore = true, default = theme.sectionbackground, callback = function(colour)
		theme.sectionbackground = colour
	end })
	colours:addpicker({ content = "Category Background", flag = "categorybackground", ignore = true, default = theme.categorybackground, callback = function(colour)
		theme.categorybackground = colour
	end })
	colours:addpicker({ content = "Left Background", flag = "leftbackground", ignore = true, default = theme.leftbackground, callback = function(colour)
		theme.leftbackground = colour
	end })
	colours:addpicker({ content = "Foreground", flag = "foreground", ignore = true, default = theme.foreground, callback = function(colour)
		theme.foreground = colour
	end })
	colours:addpicker({ content = "Highlight", flag = "highlight", ignore = true, default = theme.highlight, callback = function(colour)
		theme.highlight = colour
	end })

	local uiother = uitheme:addsection({ content = "Other" })
	uiother:addslider({ content = "Transparency", flag = "uitransparency", ignore = true, max = 0.95, float = 0.01, callback = function(value)
		for i = 1, #uicache do
			local item = uicache[i]
			if item.BackgroundTransparency < 1 then
				item.BackgroundTransparency = value
			end
			if (item.ClassName == "TextLabel" or item.ClassName == "TextButton" or item.ClassName == "TextBox") and item.TextTransparency < 1 then
				item.TextTransparency = value
			end
			if (item.ClassName == "ImageLabel" or item.ClassName == "ImageButton") and item.ImageTransparency < 1 then
				item.ImageTransparency = value
			end
		end
	end })

	local themeloader = uitheme:addsection({ content = "Load Theme", right = true })
	themeloader:adddropdown({ content = "Themes", flag = "themelist", ignore = true, items = themes:get() })
	themeloader:addbutton({ content = "Load", flag = "loadtheme", ignore = true, callback = function()
		local loadedtheme = themes:load(self.flags.themelist)
		if loadedtheme then
			self.items.titlebackground:set(loadedtheme.titlebackground:ToHSV())
			self.items.mainbackground:set(loadedtheme.mainbackground:ToHSV())
			self.items.sectionbackground:set(loadedtheme.sectionbackground:ToHSV())
			self.items.categorybackground:set(loadedtheme.categorybackground:ToHSV())
			self.items.leftbackground:set(loadedtheme.leftbackground:ToHSV())
			self.items.foreground:set(loadedtheme.foreground:ToHSV())
			self.items.highlight:set(loadedtheme.highlight:ToHSV())
		end
	end })
	themeloader:addbutton({ content = "Refresh List", flag = "refreshthemes", ignore = true, callback = function()
		self.items.themelist:clear()
		local themelist = themes:get()
		for i = 1, #themelist do
			self.items.themelist:additem(themelist[i])
		end
	end })
	
	local themesaver = uitheme:addsection({ content = "Save Theme", right = true })
	themesaver:addbox({ content = "Theme Name", flag = "themename", ignore = true })
	themesaver:addbutton({ content = "Save", flag = "savetheme", ignore = true, callback = function()
		themes:save(theme, self.flags.themename)
		self.items.refreshthemes:fire()
	end })

	local configuration = settingscat:addtab({ content = "Configuration" })
	local uiconfig = configuration:addsection({ content = "UI" })
	uiconfig:addbind({ content = "Toggle Key", flag = "togglekey", default = "RightControl", onkeydown = function()
		self:toggle()
	end })
	uiconfig:addslider({ content = "Rainbow Cycle Duration", flag = "rainbowspeed", min = 1, max = 25, float = 0.1, default = self.settings.rainbowspeed, callback = function(value)
		self.settings.rainbowspeed = value
	end })
	uiconfig:addslider({ content = "Drag Leniency", flag = "dragleniency", min = 0, max = 1, float = 0.01, default = self.settings.dragleniency, callback = function(value)
		self.settings.dragleniency = value
	end })

	local configloader = configuration:addsection({ content = "Load Config", right = true })
	configloader:adddropdown({ content = "Configs", flag = "configlist", ignore = true, items = self.configs:get() })
	configloader:addbutton({ content = "Load", flag = "loadconfig", ignore = true, callback = function()
		self.configs:load(self, self.flags.configlist)
	end })
	configloader:addbutton({ content = "Refresh List", flag = "refreshconfigs", ignore = true, callback = function()
		self.items.configlist:clear()
		local configlist = self.configs:get()
		for i = 1, #configlist do
			self.items.configlist:additem(configlist[i])
		end
	end })

	local configsaver = configuration:addsection({ content = "Save Config", right = true })
	configsaver:addbox({ content = "Config Name", flag = "configname", ignore = true })
	configsaver:addbutton({ content = "Save", flag = "saveconfig", ignore = true, callback = function()
		self.configs:save(self, self.flags.configname)
		self.items.refreshconfigs:fire()
	end })

	if table.find(self.configs:get(), "Default") then
		self.configs:load(self, "Default")
	end
	if table.find(themes:get(), "Default") then
		local loadedtheme = themes:load("Default")
		if loadedtheme then
			self.items.titlebackground:set(loadedtheme.titlebackground:ToHSV())
			self.items.mainbackground:set(loadedtheme.mainbackground:ToHSV())
			self.items.sectionbackground:set(loadedtheme.sectionbackground:ToHSV())
			self.items.categorybackground:set(loadedtheme.categorybackground:ToHSV())
			self.items.leftbackground:set(loadedtheme.leftbackground:ToHSV())
			self.items.foreground:set(loadedtheme.foreground:ToHSV())
			self.items.highlight:set(loadedtheme.highlight:ToHSV())
		end
	end
end

--[[ Return ]]--

return library