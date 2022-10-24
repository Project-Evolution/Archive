--[[ Variables ]]--

local coregui = game:GetService("CoreGui")
local gethui = gethui or gethiddenui or get_hidden_ui

--[[ System ]]--

local utils = {}
utils.__index = utils

function utils.new()
    return setmetatable({
        forcefields = {
            Aquatic = 6095843264,
            ["Candy Cane"] = 6853532738,
            Checkers = 5790215150,
            Cloudy = 6838365481,
            Hexagonal = 8793660266,
            Honeycomb = 361073795,
            Scanning = 5843010904,
            Swirl = 8133639623
        },
        tracers = {
            Straight = 4595131819,
            Taser = 446111271,
            Edge = 9149045341,
            Energy = 6091341618
        }
    }, utils)
end

function utils:deepclone(tab)
    local clone = {}
    for i, v in next, tab do
        clone[i] = type(v) == "table" and self:deepclone(v) or v
    end
    return clone
end

function utils:tablefind(tab, val)
    for i, v in next, tab do
        if v == val then
            return i
        end
    end
    return false
end

function utils:tablecount(tab, val)
    local count = 0
    for i, v in next, tab do
        count += 1
    end
    return count
end

function utils:keytoarray(tab, start)
    local array = start or {}
    for i, v in next, tab do
        table.insert(array, typeof(i) == "EnumItem" and i.Name or tostring(i))
    end
    table.sort(array, function(a, b)
        return a < b
    end)
    return array
end

function utils:valuetoarray(tab, start)
    local array = start or {}
    for i, v in next, tab do
        table.insert(array, typeof(v) == "EnumItem" and v.Name or tostring(v))
    end
    table.sort(array, function(a, b)
        return a < b
    end)
    return array
end

function utils:formatmoney(amount)
    local a, b, c = string.match(amount, "^([^%d]*%d)(%d*)(.-)$")
    return string.format("$%s%s%s", a, b:reverse():gsub("(%d%d%d)", "%1,"):reverse(), c)
end

function utils:protectinstance(inst)
    if gethui then
        inst.Parent = gethui()
    else
        if syn and syn.protect_gui then
            syn.protect_gui(inst)
        end
        inst.Parent = coregui
    end
end

return utils