--[[ System ]]--

local drawing = {}
drawing.__index = drawing

function drawing.new()
    return setmetatable({
        cache = {}
    }, drawing)
end

function drawing:add(drawtype, props)
    local item = Drawing.new(drawtype)
    for i, v in next, props do
        item[i] = v
    end
    table.insert(self.cache, item)
    return item
end

function drawing:hide()
    for i = 1, #self.cache do
        local item = self.cache[i]
        if item then
            item.Visible = false
        end
    end
end

function drawing:clear()
    for i = 1, #self.cache do
        self.cache[i]:Remove()
    end
    setmetatable(self, nil)
end

return drawing