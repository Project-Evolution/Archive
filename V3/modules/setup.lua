--[[

	Notes:

	Yes, I know this isn't obfuscated

]]

local httpservice = game:GetService("HttpService")
local tweenservice = game:GetService("TweenService")

local requirements = {
	{
		name = "readfile",
		type = "function",
		aliases = { "fread" }
	},
	{
		name = "writefile",
		type = "function",
		aliases = { "fwrite" }
	},
	{
		name = "isfile",
		type = "function",
		backup = newcclosure and readfile and function(path)
			return select(1, pcall(readfile, path))
		end
	},
	{
		name = "listfiles",
		type = "function"
	},
	{
		name = "makefolder",
		type = "function",
		aliases = { "mkdir", "createdirectory" }
	},
	{
		name = "isfolder",
		type = "function"
	},
	{
		name = "getcustomasset",
		type = "function",
		aliases = { "getsynasset" }
	},
	{
		name = "httprequest",
		type = "function",
		aliases = { "syn.request", "request", "http_request" }
	},
	{
		name = "queueonteleport",
		type = "function",
		aliases = { "syn.queue_on_teleport", "queue_on_teleport", "queueonteleport" }
	},
	{
		name = "getconstants",
		type = "function",
		aliases = { "debug.getconstants" }
	},
	{
		name = "getconstant",
		type = "function",
		aliases = { "debug.getconstant" }
	},
	{
		name = "setconstant",
		type = "function",
		aliases = { "debug.setconstant" }
	},
	{
		name = "getupvalues",
		type = "function",
		aliases = { "debug.getupvalues" }
	},
	{
		name = "getupvalue",
		type = "function",
		aliases = { "debug.getupvalue" }
	},
	{
		name = "setupvalue",
		type = "function",
		aliases = { "debug.setupvalue" }
	},
	{
		name = "getprotos",
		type = "function",
		aliases = { "debug.getprotos" }
	},
	{
		name = "getinfo",
		type = "function",
		aliases = { "debug.getinfo" }
	},
	{
		name = "getgc",
		type = "function",
		aliases = { "get_gc_objects" }
	},
	{
		name = "getloadedmodules",
		type = "function",
		aliases = { "get_loaded_modules", "getmodules", "get_modules" }
	},
	{
		name = "require",
		type = "function"
	},
	{
		name = "islclosure",
		type = "function",
		aliases = { "is_l_closure" }
	},
	{
		name = "newcclosure",
		type = "function",
		aliases = { "new_c_closure" }
	},
	{
		name = "setclipboard",
		type = "function",
		aliases = { "Clipboard.set" }
	},
	{
		name = "setthreadidentity",
		type = "function",
		aliases = { "setidentity", "set_thread_identity", "syn.set_thread_identity", "setcontext", "setthreadcontext", "set_thread_context" }
	},
	{
		name = "Drawing.new",
		type = "function",
		aliases = { "Drawing.New" }
	},
	{
		name = "getconnections",
		type = "function"
	},
	{
		name = "getcallingscript",
		type = "function",
		aliases = { "get_calling_script", "getscriptcaller" }
	},
	{
		name = "getnamecallmethod",
		type = "function",
		aliases = "get_namecall_method"
	},
	{
		name = "hookfunction",
		type = "function",
		aliases = { "hookfunc", "hook_function", "detour_function", "replaceclosure" }
	},
	{
		name = "firesignal",
		type = "function",
		backup = getconnections and function(conn, ...)
			for i, v in next, getconnections(conn) do
				coroutine.wrap(v.Function)(...)
			end
		end
	},
	{
		name = "firetouchinterest",
		type = "function"
	},
	{
		name = "mousemoverel",
		type = "function"
	},
	{
		name = "mouse1click",
		type = "function"
	},
	{
		name = "rconsoleprint",
		type = "function"
	}
}

local quotes = {
	[["I'm gonna 69 my dad" ~ Vynixu]],
	[["The fuck is a table" ~ Spade]],
	[["Failed to locate your father..." ~ System]],
	[["game:GetService('Workspace')" ~ Bandwidth]],
	[["Ask the povery struck South African" ~ Vynixu]],
	[["Anime is homo" ~ 4151]],
	[["'Anti Ragdoll', so it's basically No Fall Damage" ~ JB36]],
	[["Ctrl+A Ctrl+C Ctrl+V" ~ Alex9]],
	[["Solaris never paid me" ~ Hazel]]
}

local cache = {
    modules = {},
    images = {},
    systems = {}
}

local links = { 
    changelog = "https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/changelog.json",
    modules = "https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/",
    images = "https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/images/",
    systems = "https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/systems/"
}

getgenv().evov3 = {
	imports = {
		fetchmodule = function(self, modulename)
			if cache.modules[modulename] == nil then
				cache.modules[modulename] = loadstring(game:HttpGetAsync(links.modules .. modulename .. ".lua", true))()
			end
			return cache.modules[modulename]
		end,
		fetchimage = function(self, imagename)
			if cache.images[imagename] == nil then
				cache.images[imagename] = getcustomasset("Evo V3/Data/Images/" .. imagename)
			end
			return cache.images[imagename]
		end,
		fetchsystem = function(self, systemname, ...)
			if cache.systems[systemname] == nil then
				cache.systems[systemname] = loadstring(readfile(string.format("Evo V3/Data/Systems/%s.lua", systemname)))()
			end
			return cache.systems[systemname].new(...)
		end
	},
}

evov3.startup = isfile and isfile("Evo V3/Data/Systems/signal.lua") and evov3.imports:fetchsystem("signal") or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/systems/signal.lua", true))().new()

local function checkdirectories(changelog)
	for i = 1, #changelog.directories do
		local path = changelog.directories[i]
		if not isfolder(path) then
			makefolder(path)
		end
		evov3.startup:fire(string.format("Checking Directories... %d/%d", i, #changelog.directories))
		task.wait()
	end
end

local function checkimages(changelog)
	for i = 1, #changelog.images do
		local path = "Evo V3/Data/Images/" .. changelog.images[i]
		if not isfile(path) then
			writefile(path, game:HttpGetAsync(links.images .. changelog.images[i], true))
		end
		evov3.startup:fire(string.format("Checking Images... %d/%d", i, #changelog.images))
		task.wait()
	end
end

local function checksystems(changelog)
	local path = "Evo V3/Data/changelog.json"
	local systems, count, checked = {}, 0, 0
	for i, v in next, changelog.systems do
		count = count + 1
	end
	if isfile(path) then
		local saved = httpservice:JSONDecode(readfile(path))
		for i, v in next, saved.systems do
			if v == changelog.systems[i] then
				systems[i] = true
			end
		end
	end
	for i, v in next, changelog.systems do
		local path = string.format("Evo V3/Data/Systems/%s.lua", i)
		if forceupdate or isfile(path) == false or systems[i] ~= true then
			writefile(path, game:HttpGetAsync(links.systems .. i .. ".lua", true))
		end
		checked = checked + 1
		evov3.startup:fire(string.format("Checking Systems... %d/%d", checked, count))
		task.wait()
	end
	writefile(path, httpservice:JSONEncode(changelog))
	evov3.utils = evov3.imports:fetchsystem("utils")
end

local function doesreqexist(funcname, target)
	local env, path = getfenv(), string.split(funcname, ".")
	for i = 1, #path do
		env = env[path[i]]
		if env == nil then
			break
		end
	end
	return type(env) == target and env or false
end

local function addreqalias(funcname, alias)
	local env, path = getgenv(), string.split(funcname, ".")
	for i = 1, #path - 1 do
		if env[path[i]] == nil then
			env[path[i]] = {}
		end
		env = env[path[i]]
	end
	env[path[#path]] = alias
end

local function checkaliases(requirement)
	if requirement.aliases then
		for i, v in next, requirement.aliases do
			local alias = doesreqexist(v, requirement.type)
			if alias then
				addreqalias(requirement.name, alias)
				return true
			end
		end
	end
	if requirement.backup then
		addreqalias(requirement.name, requirement.backup)
		return true
	end
	return false
end

local function checkcompatibility()
	local missing = {}
	for i, v in next, requirements do
		if not (doesreqexist(v.name, v.type) or checkaliases(v)) then
			missing[#missing + 1] = v.name
		end
        evov3.startup:fire(string.format("Checking Compatibility... %d/%d", i, #requirements))
		task.wait()
	end
	return #missing == 0, missing
end

local function getloginfo(self)
	local log = httpservice:JSONDecode(game:HttpGetAsync(links.changelog, true))
	local count = #requirements + #log.directories + #log.images
	for i, v in next, log.systems do
		count = count + 1
	end
	return log, count
end

local function startchecks(self, changelog)
	if checkcompatibility() then
		checkdirectories(changelog)
		checkimages(changelog)
		checksystems(changelog)
		return true
	end
	return false
end

local function spinquotes(self, label)
	while true do
		if label.Parent == nil then
			break
		end
		local t = tweenservice:Create(label, TweenInfo.new(0.25), { TextTransparency = 1 })
		t.Completed:Connect(function()
			local quote = quotes[math.random(1, #quotes)]
			while quote == label.Text do
				quote = quotes[math.random(1, #quotes)]
			end
			label.Text = quote
			tweenservice:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
		end)
		t:Play()
		task.wait(4)
	end
end

cache.modules.setup = {
	getloginfo = getloginfo,
	startchecks = startchecks,
	spinquotes = spinquotes
}

return cache.modules.setup
