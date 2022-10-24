-- yay queueonteleport

local Hint = Instance.new("Hint", game:GetService("CoreGui"))
Hint.Text = "Waiting For Game To Load..."
repeat wait() until game:IsLoaded()
local ContentProvider = game:GetService("ContentProvider")
if ContentProvider.RequestQueueSize > 0 then
	repeat wait() until ContentProvider.RequestQueueSize == 0
end
Hint:Destroy()

-- Actual shit

local queueonteleport = queue_on_teleport or queue_for_teleport or (syn and syn.queue_on_teleport)

if queueonteleport then
	queueonteleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/Loader.lua"))()]])
    local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Project-Evolution/Main/main/Library.lua", true))()
    Lib.Notify("Project: Evolution will load when you join the Battle Royale")
end