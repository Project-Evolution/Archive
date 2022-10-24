--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

local LPH_JIT_ULTRA = function(...) return ... end

--[[ Variables ]]--

local library = evov3.imports:fetchmodule("library").new({ content = "RoBeats", version = changelog.version .. " Premium" })

local player = game:GetService("Players").LocalPlayer

local funcnames = {}
local noteholder = {}
local noteresults = {}
local notebounds = {}

local levels = { "perfect", "great", "okay" }
local boundaries = {
    perfect = { 1, 100 }
}
local total = 100

local lastsongkey
local lastcheer = 0

--[[ Garbage Collection ]]--

local notebases = {}
local client, lobby, modes
local webnpcmanager, sputil, gearstats, vipinfo, curveutil, defaultsongkey

do
    local gc = getgc(true)
    for i = 1, #gc do
        local v = gc[i]
        if type(v) == "function" and getinfo(v).name == "get_current_weekid" then
            client = getupvalue(v, 1)
        elseif type(v) == "table" then
			if rawget(v, "color3_for_slot") then
				notebases[#notebases + 1] = v
			elseif rawget(v, "songkey_opt_set_artist_event_info") then
				lobby = v
			elseif rawget(v, "MatchMaking") then
				modes = v
			end
        end
    end

    local modules = getloadedmodules()
    for i, v in next, modules do
        local req = select(2, pcall(require, modules[i]))
        if type(req) == "table" then
            if rawget(req, "hash_creator") then
                sputil = req
            elseif rawget(req, "get_note_time_obj") then
                gearstats = req
            elseif rawget(req, "playerblob_has_vip_for_current_day") then
                vipinfo = req
            elseif rawget(req, "TimescaleToDeltaTime") then
                curveutil = req
            elseif rawget(req, "invalid_songkey") then
                defaultsongkey = req:singleton():name_to_key("MondayNightMonsters1")
            end
        end
    end
end

local eventids = getupvalue(client._evt.server_generate_encodings, 1)
local gamelocal = getupvalue(client._game_join.load_game, 7)
local tracksystem = getupvalue(gamelocal.new, 18)

--[[ Functions ]]--

local function constructboundaries()
    table.clear(boundaries)
    local accum = 0
    for i = 1, #levels do
        local v = levels[i]
        local flag = library.flags[v]
        if flag > 0 then
            boundaries[v] = { accum + 1, accum + flag }
        end
        accum = accum + flag
    end
    total = math.max(accum, 100)
end

local function getwantedresult()
    local rand = math.random(1, total)
    for i, v in next, boundaries do
        if rand >= v[1] and rand <= v[2] then
            return i
        end
    end
    return "miss"
end

local function gethittime(boundary)
    if boundary == "miss" then
        return
    end
    return math.random() * math.random(notebounds[boundary].low, notebounds[boundary].high)
end

local function handlenotes(localgame, system, notes)
    for i = 1, notes:count() do
        local note = notes:get(i)
        local index = note:get_note_index()
        local noteresult = noteholder[index]
        if noteresult == nil then
            noteresult = getwantedresult()
            noteholder[index] = noteresult
        end
        local hitres, hitscore, hittime = note[funcnames.testhit](note, localgame)
        local relres, relscore, reltime = note[funcnames.testrel](note, localgame)
        if not note[funcnames.shouldremove](note, localgame) then
            local track = system[funcnames.gettrack](system, note:get_track_index())
            if hitres and hitscore == noteresults[noteresult] then
                track:press()
                note[funcnames.hit](note, localgame, hitscore, i, library.flags.randomdelta and gethittime(noteresult) or hittime)
                if not reltime then
                    track:release()
                end
            elseif relres and relscore == noteresults[noteresult] then
                track:release()
                note[funcnames.rel](note, localgame, relscore, i, reltime)
            end
        end
    end
end

local function getplayerid()
	local finished, players = false, {}
	client._evt:clear_pending_on(eventids.EVT_Players_ServerQueryPlayerListResponse)
	client._evt:wait_on_event_once(eventids.EVT_Players_ServerQueryPlayerListResponse, function(list)
		for i = 1, #list do
			local v = list[i]
			if v.Activity == modes.Match then
				table.insert(players, v)
			end
		end
		finished = true
	end)
	client._evt:fire_event_to_server(eventids.EVT_Players_ClientQueryPlayerList)
	repeat task.wait() until finished
	if #players > 0 then
		table.sort(players, function(a, b)
			return a.JoinTime > b.JoinTime
		end)
		return players[1].PlayerId
	end
end

--[[ Setup ]]--

local notetimes = gearstats:get_note_time_obj(gearstats:get_imm_statsdict_base())
notebounds.okay = {
    high = notetimes[5],
    low = notetimes[6]
}

notebounds.great = {
    high = notetimes[4],
    low = notetimes[5]
}

notebounds.perfect = {
    high = -0.01,
    low = notetimes[4]
}

for i, v in next, sputil do
    if type(v) == "function" and string.sub(i, 1, 1) == "_" and islclosure(v) then
        local consts = getconstants(v)
        if #consts == 4 and #getupvalues(v) == 1 then
            local results = getupvalue(v, 1)
            noteresults.miss, noteresults.okay = results[consts[1]], results[consts[2]]
            noteresults.great, noteresults.perfect = results[consts[3]], results[consts[4]]
            break
        end
    end
end

for i, v in next, getprotos(tracksystem.new) do
    local consts = getconstants(v)
    if table.find(consts, "TrackSystem:update") then
        funcnames.tracksystemupdate = getinfo(v).name
        funcnames.shouldremove = consts[7]
        funcnames.getslot = consts[11]
    elseif table.find(consts, "NoteIndexNone") then
        funcnames.gettrack = consts[1]
        funcnames.testhit = consts[10]
        funcnames.hit = consts[11]
    elseif table.find(consts, "release") then
        funcnames.testrel = consts[6]
        funcnames.rel = consts[7]
    elseif table.find(consts, "set_note_colors") then
        funcnames.addtotrack = getinfo(v).name
    end
end

for i, v in next, getprotos(gamelocal.new) do
    if getinfo(v).name == "update" then
        funcnames.tracks = getconstant(v, 31)
        break
    end
end

while true do
    if getupvalue(client._lobby_join.setup_lobby, 5) then
        break
    end
    task.wait(1)
end

local webnpcmanager = getupvalue(getupvalue(client._lobby_join.setup_lobby, 1)._npcs.cons, 1)

--[[ GUI ]]--

local songcat = library:addcategory({ content = "Songs" })
local playertab = songcat:addtab({ content = "Auto Player" })

local player = playertab:addsection({ content = "Player" })
player:addtoggle({ content = "Enabled", flag = "autoplayenabled" })
player:addtoggle({ content = "Delta Randomiser", flag = "randomdelta" })
player:addslider({ content = "Perfect", suffix = "%", flag = "perfect", callback = constructboundaries })
player:addslider({ content = "Great", suffix = "%", flag = "great", callback = constructboundaries })
player:addslider({ content = "Okay", suffix = "%", flag = "okay", callback = constructboundaries })

local unlocks = playertab:addsection({ content = "Unlocks", right = true })
unlocks:addtoggle({ content = "Unlock All Songs", flag = "unlockall" })
unlocks:addlabel({ content = "Note: Your score and combo will be bugged" })

local other = playertab:addsection({ content = "Other", right = true })
other:addtoggle({ content = "Block Input", flag = "blockinput" })

local visuals = library:addcategory({ content = "Visuals" })
local visualstab = visuals:addtab({ content = "Visuals" })

local notes = visualstab:addsection({ content = "Notes" })
notes:addchecklist({ content = "Note Colours", flag = "notetracks", items = { { "Track 1" }, { "Track 2" }, { "Track 3" }, { "Track 4" } } })
for i = 1, 4 do
    notes:addpicker({ content = "Track " .. i, flag = "track" .. i })
end

local othercat = library:addcategory({ content = "Other" })
local misctab = othercat:addtab({ content = "Misc" })

local cheers = misctab:addsection({ content = "Cheers" })
cheers:addtoggle({ content = "Auto Cheer", flag = "autocheer", callback = function(state)
	if state then
		repeat task.wait()
			local id = getplayerid()
			if id then
				local t
				lobby._spectate_manager:try_spectate_userid(id, function(_, __, func)
					func()
					t = tick()
				end)
				task.wait(3)
				local gamelocal = getupvalue(client._game_join.load_game, 6)
				if gamelocal then
					local manager = gamelocal:get_spectate_manager()
					if manager:can_cheer() then
						manager:cheer_focused_slot(function(success)
							if success then
								lastcheer = tick()
							end
						end)
					end 
					task.wait(1)
					manager:spectate_leave()
					repeat task.wait() until tick() - lastcheer > 18
				end
			end
		until library.flags.autocheer == false
	end
end })
cheers:addlabel({ content = "Note: Enable when in the Lobby" })

local npcrewards = misctab:addsection({ content = "NPCs", right = true })
npcrewards:addbutton({ content = "Collect NPC Rewards", callback = function()
    for i, v in next, getgc(true) do
        if type(v) == "table" and rawget(v, "WebNPCID") and webnpcmanager:webnpcid_should_trigger_reward(v.WebNPCID) then
            client._shop_local_protocol:visit_webnpc(v.WebNPCID, function() end)
        end
    end
end })

--[[ Hooks ]]--

local fireserver = client._evt.fire_event_to_server
client._evt.fire_event_to_server = newcclosure(function(self, ...)
    local args = {...}
    if args[1] == eventids.EVT_EventReport_ClientExploitDetected then
        return
    elseif args[1] == eventids.EVT_GameLoad_MatchmakingV3_ClientEnqueue and library.flags.unlockall then
        lastsongkey = args[2]
        args[2] = defaultsongkey
    end
    return fireserver(self, unpack(args))
end)

local waitonevent = client._evt.wait_on_event_once
client._evt.wait_on_event_once = newcclosure(function(self, ...)
    local args = {...}
    if args[1] == eventids.EVT_GameLoad_ServerNotifyClientDoPreload and library.flags.unlockall then
		local func = args[2]
		args[2] = newcclosure(function(...)
			local funcargs = {...}
			funcargs[5] = lastsongkey
			func(unpack(funcargs))
		end)
	end
    return waitonevent(self, unpack(args))
end)

local hasviptoday = vipinfo.playerblob_has_vip_for_current_day
vipinfo.playerblob_has_vip_for_current_day = newcclosure(function(self, ...)
	return library.flags.unlockall or hasviptoday(self, ...)
end)

local inputbegan = client._input.input_began
client._input.input_began = newcclosure(function(self, key)
    if library.flags.blockinput and type(key) ~= "number" then 
        return
    end 
    return inputbegan(self, key)
end)

local newtracksystem = tracksystem.new
tracksystem.new = newcclosure(function(self, localgame, ...)
    local system = newtracksystem(self, localgame, ...)
    local update = system[funcnames.tracksystemupdate]
    local notes = getupvalue(update, 2)

    table.clear(noteholder)
    system[funcnames.tracksystemupdate] = newcclosure(LPH_JIT_ULTRA(function(...)
        if library.flags.autoplayenabled then
            handlenotes(localgame, system, notes)
        end
        return update(...)
    end))

    return system
end)

for i = 1, #notebases do
    local color3forslot = notebases[i].color3_for_slot
    notebases[i].color3_for_slot = newcclosure(LPH_JIT_ULTRA(function(self, ...)
        local track = self:get_track_index()
        if library.flags.notetracks["Track " .. track] then
            local flag = library.flags["track" .. track]
            return Color3.fromHSV(flag.h, flag.s, flag.v)
        end
        return color3forslot(self, ...)
    end))
end

--[[ End ]]--

library.items.perfect:set(100)
library:addsettings()
