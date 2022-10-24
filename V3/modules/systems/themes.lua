--[[ Variables ]]--

local httpservice = game:GetService("HttpService")

--[[ Functions ]]--

local function parsecolour(color3)
	return { R = math.round(color3.R * 255), G = math.round(color3.G * 255), B = math.round(color3.B * 255) }
end

local function parsetheme(theme)
	local parsedtheme = {}
	for i, v in next, theme do
		parsedtheme[i] = Color3.fromRGB(v.R, v.G, v.B)
	end
	return parsedtheme
end

--[[ System ]]--

local customiser = {}
customiser.__index = customiser

function customiser.new()
    return setmetatable({}, customiser)
end

function customiser:get()
	local array = {}
    if isfolder("Evo V3\\Themes") then
		for i, v in next, listfiles("Evo V3\\Themes") do
			local filename = string.gsub(v, ".*\\", "")
			if filename and string.sub(filename, #filename - 4) == ".json" then
				table.insert(array, string.sub(filename, 1, #filename - 5))
			end
		end
	end
    return array
end

function customiser:load(name)
	local path = "Evo V3/Themes/" .. name .. ".json"
	if isfile(path) then
		local succ, json = pcall(httpservice.JSONDecode, httpservice, readfile(path))
		if succ then
			return parsetheme(json)
		end
	end
    return false
end

function customiser:save(theme, name)
	local themecopy = {}
	for i, v in next, theme.values do
		themecopy[i] = parsecolour(v)
	end
	local succ, json = pcall(httpservice.JSONEncode, httpservice, themecopy)
	if succ then
		writefile("Evo V3/Themes/" .. name .. ".json", json)
	end
end

return customiser