local ContentProvider = game:GetService("ContentProvider")

local Hint = Instance.new("Hint", game:GetService("CoreGui"))
Hint.Text = "Waiting For Game To Load..."

if ContentProvider.RequestQueueSize > 0 then
	repeat wait() until ContentProvider.RequestQueueSize == 0
end

Hint:Destroy()

local Games = game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V1/Games.json", true)
Games = game:GetService("HttpService"):JSONDecode(Games)

local Functions = {
	["checkcaller"] = checkcaller,
	["fireclickdetector"] = fireclickdetector or click_detector,
	["getconstants"] = getconstants or (debug and debug.getconstants),
	["getgc"] = getgc or get_gc_objects,
	["getgenv"] = getgenv or (getrawmetatable and function()
		return getrawmetatable(getfenv()).__index
	end),
	["getinfo"] = getinfo or (debug and debug.getinfo),
	["getnamecallmethod"] = getnamecallmethod or get_namecall_method,
	["getproto"] = getproto or (debug and debug.getproto),
	["getprotos"] = getprotos or (debug and debug.getprotos),
	["getrenv"] = getrenv or (getrawmetatable and function()
		return getrawmetatable(getfenv()).__index
	end),
	["getsenv"] = getsenv or (getreg and function(scr)
		for i, v in next, getreg() do
			if type(v) == "function" and getfenv(v).script == scr then
				return getfenv(v)
			end
		end
	end),
	["getrawmetatable"] = getrawmetatable,
	["getthreadidentity"] = getidentity or getthreadidentity or get_thread_identity or getcontext or getthreadcontext or get_thread_context or (syn and syn.get_thread_identity),
	["getupvalue"] = getupvalue or (debug and debug.getupvalue),
	["getupvalues"] = getupvalues or (debug and debug.getupvalues),
	["hookfunction"] = hookfunction or hookfunc or detour_function or replaceclosure,
	["isexploitfunction"] = is_synapse_function or is_protosmasher_closure or is_sirhurt_closure or issentinelclosure or iselectronfunction or iskrnlclosure or checkclosure,
	["isfile"] = isfile or is_file or file_exists or fileexists or (readfile and function(path)
		local succ, res = pcall(readfile, path)
		return succ
	end),
	["islclosure"] = islclosure or is_l_closure,
	["makereadonly"] = make_readonly or (setreadonly and function(tab)
		setreadonly(tab, true)
	end),
	["makewriteable"] = make_writeable or make_writable or (setreadonly and function(tab)
		setreadonly(tab, false)
	end),
	["newcclosure"] = newcclosure or new_c_closure,
	["newdrawing"] = (Drawing and Drawing.new) or (Drawing and Drawing.New),
	["readfile"] = readfile or read_file or fread,
	["request"] = request or httprequest or http_request or (syn and syn.request),
	["require"] = require,
	["setconstant"] = setconstant or (debug and debug.setconstant),
	["setthreadidentity"] = setidentity or setthreadidentity or set_thread_identity or setcontext or setthreadcontext or set_thread_context or (syn and syn.set_thread_identity),
	["setupvalue"] = setupvalue or (debug and debug.setupvalue),
	["traceback"] = (debug and debug.traceback),
	["writefile"] = writefile or write_file or fwrite
}

local MissingFunctions = {}
local CurrentGame = {}

if Games[tostring(game.PlaceId)] then
	CurrentGame = Games[tostring(game.PlaceId)]
end

CurrentGame.Functions["getgenv"] = true
CurrentGame.Functions["readfile"] = true
CurrentGame.Functions["writefile"] = true
CurrentGame.Functions["isfile"] = true

for i, v in next, CurrentGame.Functions do
	if Functions[i] == nil then
		table.insert(MissingFunctions, i)
	end
end

for i, v in next, Games do
	if game.PlaceId == v then
		CurrentGame = i
	end
end

function Create(obj, props, round)
	local Obj = Instance.new(obj)
	for i, v in pairs(props) do
		if i ~= "Parent" then
			if typeof(v) == "Instance" then
				v.Parent = Obj
			else
				Obj[i] = v
			end
		end			
	end
	if round then
		local Corner = Instance.new("UICorner", Obj)
		Corner.CornerRadius = UDim.new(0, 4)
	end
	Obj.Parent = props.Parent
	return Obj
end

local Gui = Create("ScreenGui", {
	Name = "Project: Evolution",
	Parent = game:GetService("CoreGui"),
	Create("ImageLabel", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		ClipsDescendants = true,
		Image = "rbxassetid://5997008502",
		Name = "Main",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Selectable = true,
		Size = UDim2.new(0, 0, 0, 0),
		Create("ImageButton", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://5997008398",
			Name = "Close",
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(0, 35, 0, 35)
		}),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Title",
			Position = UDim2.new(0, 55, 0, 10),
			Size = UDim2.new(1, -55, 0, 35),
			Text = "Project: Evolution",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Game",
			Position = UDim2.new(0, 0, 0, 55),
			Size = UDim2.new(1, 0, 0, 35),
			Text = CurrentGame.Name,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 20
		}),
		Create("TextButton", {
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Font = Enum.Font.Gotham,
			Name = "Button",
			Position = UDim2.new(0, 87, 0, 110),
			Size = UDim2.new(1, -200, 0, 32),
			Text = "Load Script",
			TextColor3 = Color3.fromRGB(30, 30, 30),
			TextSize = 16
		}, true)
	}, true)
})

Gui.Main.Close.MouseButton1Click:Connect(function()
	Gui.Main:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Sine", 0.4, true)
	wait(0.5)
	Gui:Destroy()
end)

Gui.Main.Button.MouseButton1Click:Connect(function()
	if #MissingFunctions == 0 then
		Gui.Main:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Sine", 0.4, true)
		wait(0.5)
		Gui:Destroy()
		for i, v in next, CurrentGame.Functions do
			getgenv()[i] = Functions[i]
		end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V1/" .. string.gsub(CurrentGame.Name, " ", "") .. ".lua"))()
	else
		local Hint = Instance.new("Hint", game:GetService("CoreGui"))
		Hint.Text = "Missing Functions: " .. table.concat(MissingFunctions, ", ")
		wait(3)
		Hint:Destroy()
	end	
end)

Gui.Main:TweenSize(UDim2.new(0, 400, 0, 150), "InOut", "Sine", 0.4, true)
