--[[ Variables ]]--

local httpservice = game:GetService("HttpService")

--[[ System ]]--

local configurator = {}
configurator.__index = configurator

function configurator.new(dir)
    return setmetatable({
        directory = "Evo V3\\Configs\\" .. dir
    }, configurator)
end

function configurator:get()
    local array = {}
    if not isfolder(self.directory) then
        makefolder(self.directory)
    end
	for i, v in next, listfiles(self.directory) do
		local filename = string.gsub(v, ".*\\", "")
		if filename and string.sub(filename, #filename - 3) == ".cfg" then
			table.insert(array, string.sub(filename, 1, #filename - 4))
		end
	end
    return array
end

function configurator:load(library, name)
	local path = string.format("%s\\%s.cfg", self.directory, name)
	if isfile(path) then
		local succ, json = pcall(httpservice.JSONDecode, httpservice, readfile(path))
		if succ then
			for i, v in next, json do
                local item = library.items[i]
                if item then
                    if item.itemtype == "toggleslider" then
                        item:set(v.value)
                        item:toggle(v.enabled)
                    elseif item.itemtype == "toggledropdown" then
                        if v.selected ~= nil then
                            item:set(v.selected)
                        end
                        item:toggle(v.enabled)
                    elseif item.itemtype == "picker" then
                        item:set(v.h, v.s, v.v)
                        item:togglerainbow(v.rainbow)
                    elseif item.itemtype == "togglepicker" then
                        item:set(v.h, v.s, v.v)
                        item:toggle(v.enabled)
                        item:togglerainbow(v.rainbow)
                    elseif item.itemtype == "checklist" then
                        for key, value in next, v do
                            item:toggle(key, value)
                        end
                    else
                        item:set(v)
                    end
                end
            end
            return true
		end
	end
    return false
end

function configurator:save(library, name)
	local path = self.directory
	if not isfolder(path) then
		makefolder(path)
	end
    local flags = {}
    for i, v in next, library.flags do
        if library.items[i] and not library.items[i].ignore then
            flags[i] = type(v) == "table" and evov3.utils:deepclone(v) or v
        end
    end
	writefile(string.format("%s/%s.cfg", path, name), httpservice:JSONEncode(flags))
end

return configurator