--[[ ==========  Notes  ========== ]]--

--[[

    If you have any ideas for new systems, let me know in my Discord:
    https://projectevo.xyz/discord

    Technically the Tracer system does have requirements, however you cannot correctly create a trace using those functions without having them in the first place.
    E.g. to create a hook trace, you need to have used hookfunction in order to pass the original function before it was hooked. Hence, you already know it's supported.
    ( or you're a retard, that is also a possibility. )

]]

--[[ ==========  Variables  ========== ]]--

local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")

local funcs = {
    request = syn and syn.request or request or http_request,
    hookfunction = hookfunction or hookfunc or replaceclosure,
    setupvalue = debug and debug.setupvalue or setupvalue,
    setconstant = debug and debug.setconstant or setconstant
}

--[[ ==========  Discord System  ========== ]]--

local discord = { _requirements = { "request" } }
discord.__index = discord

function discord.new()
    return setmetatable({}, discord)
end

function discord:CheckInvite(inv)
    for i = #inv, 1, -1 do
        if inv:sub(i, i) == "/" then
            inv = inv:sub(i + 1)
            break
        end
    end
    local req = funcs.request({
        Url = "https://discord.com/api/invites/" .. inv,
        Method = "GET"
    })
    return req.Success and httpService:JSONDecode(req.Body).guild and inv or false
end

function discord:PromptInvite(inv)
    inv = self:CheckInvite(inv)
    if inv then
        local s, r = pcall(funcs.request, {
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                Origin = "https://discord.com",
                ["Content-Type"] = "application/json"
            },
            Body = httpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                nonce = httpService:GenerateGUID(false),
                args = {
                    code = inv
                }
            })
        })
    end
end

--[[ ==========  Looper System  ========== ]]--

local looper = { _requirements = {} }
looper.__index = looper

function looper.new()
    return setmetatable({ _loops = {} }, looper)
end

function looper:Create(name, method, func, start)
    local loop = {
        type = type(method) == "number" and "coroutine" or "connection",
        method = method,
        status = false,
        func = func
    }
    if loop.type == "coroutine" then
        loop.coroutine = coroutine.create(function()
            while true do
                func()
                task.wait(method)
                if loop.status == false then
                    coroutine.yield()
                end
            end
        end)
    end
    self._loops[name] = loop
    if start then
        self:Resume(name)
    end
end

function looper:Resume(name)
    local loop = self._loops[name]
    if loop and loop.status == false then
        loop.status = true
        if loop.type == "coroutine" then
            coroutine.resume(loop.coroutine)
        elseif loop.type == "connection" then
            loop.connection = runService[loop.method]:Connect(loop.func)
        end
    end
end

function looper:Pause(name)
    local loop = self._loops[name]
    if loop and loop.status == true then
        loop.status = false
        if loop.type == "connection" then
            loop.connection:Disconnect()
            loop.connection = nil
        end
    end
end

function looper:Remove(name)
    local loop = self._loops[name]
    if loop then
        self:Pause(name)
        self._loops[name] = nil
    end
end

function looper:Clear()
    for i, v in next, self._loops do
        self:Remove(i)
    end
end

--[[ ==========  Tracer System  ========== ]]--

local tracer = { _requirements = {} }
tracer.__index = tracer

function tracer.new()
    return setmetatable({ _traces = {} }, tracer)
end

function tracer:Create(name, method, info)
    self._traces[name] = {
        method = method,
        info = info
    }
end

function tracer:Reset(name)
    local trace = self._traces[name]
    if trace then
        if trace.method == "table" or trace.method == "property" then
            trace.info.table[trace.info.key] = trace.info.original
        elseif trace.method == "hook" then
            funcs.hookfunction(trace.info.func, trace.info.original)
        elseif trace.method == "upvalue" then
            funcs.setupvalue(trace.info.func, trace.info.index, trace.info.original)
        elseif trace.method == "constant" then
            funcs.setconstant(trace.info.func, trace.info.index, trace.info.original)
        elseif trace.method == "instance" then
            trace.info.instance.Parent = nil
        end
    end
end

function tracer:Remove(name)
    local trace = self._traces[name]
    if trace then
        self:Reset(name)
        self._traces[name].info = nil
        self._traces[name] = nil
    end
end

function tracer:Clear()
    for i, v in next, self._traces do
        self:Remove(i)
    end
end

--[[ ==========  Misc System  ========== ]]--

local misc = { _requirements = {} }
misc.__index = misc

function misc.new()
    return setmetatable({}, misc)
end

function misc:CreateInstance(className, properties, children)
    local inst, props = Instance.new(className), properties or {}
	for i, v in next, props do
		if i ~= "Parent" then
			inst[i] = v
		end
	end
	if children then
		for i, v in next, children do
			v.Parent = inst
		end
	end
	inst.Parent = props.Parent
	return inst
end

function misc:DeepCopy(old, new, cloneSubTables)
    for i, v in next, old do
        local isTable = type(v) == "table"
        new[i] = isTable and cloneSubTables and {} or v
        if isTable and cloneSubTables then
            self:DeepCopy(v, new[i], true)
        end
    end
end

--[[ ==========  Return   ========== ]]--

local systems = {
    ["Discord"] = discord,
    ["Looper"] = looper,
    ["Tracer"] = tracer,
    ["Miscellaneous"] = misc
}

local system = {}
system.__index = system

function system.new(name)
    assert(name and systems[name], "No system with this name was found.")
    local sys = systems[name].new()

    function sys:CheckCompatibility()
        local compatible = true
        for i, v in next, sys._requirements do
            if funcs[v] == nil then
                compatible = false
            end
        end
        return compatible
    end

    return sys
end

return system