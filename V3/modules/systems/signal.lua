--[[

    Notes:

    Taken from NevermoreEngine (https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Signal.lua)

]]

--[[ Variables ]]--

local httpservice = game:GetService("HttpService")

--[[ System ]]--

local signal = {}
signal.__index = signal

function signal.new()
	local newsignal = setmetatable({
        event = Instance.new("BindableEvent"),
        argmap = {},
        src = debug.traceback()
    }, signal)

	newsignal.event.Event:Connect(function(key)
		newsignal.argmap[key] = nil
		if not (newsignal.event or next(newsignal.argmap)) then
			newsignal.argmap = nil
		end
	end)

	return newsignal
end

function signal:fire(...)
	local args = table.pack(...)
	local key = httpservice:GenerateGUID(false)
	self.argmap[key] = args
	self.event:fire(key)
end

function signal:connect(handler)
	return self.event.Event:Connect(function(key)
		local args = self.argmap[key]
		if args then
			handler(table.unpack(args, 1, args.n))
		else
			error("Missing arg data, probably due to reentrance.")
		end
	end)
end

function signal:wait()
	local key = self.event.Event:Wait()
	local args = self.argmap[key]
	if args then
		return table.unpack(args, 1, args.n)
	else
		error("Missing arg data, probably due to reentrance.")
		return nil
	end
end

function signal:dispose()
	if self.event then
		self.event:Destroy()
		self.event = nil
	end
	setmetatable(self, nil)
end

return signal