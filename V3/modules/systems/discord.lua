--[[ Variables ]]--

local httpservice = game:GetService("HttpService")
local portrange = { min = 6463, max = 6472 } -- https://discord.com/developers/docs/topics/rpc#rpc-server-ports

--[[ System ]]--

local discord = {}
discord.__index = discord

function discord.new()
    return setmetatable({
        cache = {}
    }, discord)
end

function discord:formatinvite(inv)
    for i = #inv - 1, 1, -1 do
        if string.sub(inv, i, i) == "/" then
            return string.sub(inv, i + 1)
        end
    end
    return inv
end

function discord:checkinvite(inv)
    if self.cache[inv] == nil then
        local req = httprequest({
            Url = "https://discord.com/api/invites/" .. inv,
            Method = "GET"
        })
        self.cache[inv] = req.Success and httpservice:JSONDecode(req.Body).guild and true or false
    end
    return self.cache[inv]
end

function discord:promptinvite(inv)
    local formattedinv = self:formatinvite(inv)
    if self:checkinvite(formattedinv) then
        for i = portrange.min, portrange.max do
            if httprequest({
                Url = string.format("http://127.0.0.1:%d/rpc?v=1", i),
                Method = "POST",
                Headers = {
                    Origin = "https://discord.com",
                    ["Content-Type"] = "application/json"
                },
                Body = httpservice:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    nonce = string.lower(httpservice:GenerateGUID(false)),
                    args = {
                        code = formattedinv
                    }
                })
            }).Success then
                return 1 -- Success! ( Yes I still need to add a custom Enumer )
            end
        end
        return 2 -- Discord Isn't Open
    end
    return 3 -- Invalid Invite
end

return discord