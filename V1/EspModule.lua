--[[

    Wow it's open source hooray now fuck off ya skid
    It's a pretty shite example anyway lmao

--]]

local Esp = {
	Container = {},
	ItemContainer = {},
	Settings = {
		Enabled = false,
        Name = false,
		Box = false,
		Health = false,
		Distance = false,
		Tracer = false,
        TeamCheck = false,
		TextSize = 16,
        Range = 0
	}
}

local Player = game:GetService("Players").LocalPlayer
local TracerStart = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y - 25)

local CheckVis = newcclosure(function(esp, inview)
	if not inview or (Esp.Settings.TeamCheck and Esp.TeamCheck(esp.Player)) or (esp.Root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > Esp.Settings.Range then
		esp.Name.Visible = false
		esp.Box.Visible = false
		esp.Health.Visible = false
		esp.Distance.Visible = false
		esp.Tracer.Visible = false
		return
	end
	esp.Name.Visible = Esp.Settings.Name
	esp.Box.Visible = Esp.Settings.Box
	esp.Health.Visible = Esp.Settings.Health
	esp.Distance.Visible = Esp.Settings.Distance
	esp.Tracer.Visible = Esp.Settings.Tracer
end)

local CheckItemVis = newcclosure(function(esp, inview)
	if not inview or (esp.Item.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > Esp.Settings.Range then
		esp.Name.Visible = false
		esp.Box.Visible = false
		esp.Distance.Visible = false
		esp.Tracer.Visible = false
		return
	end
	esp.Name.Visible = Esp.Settings.Name
	esp.Box.Visible = Esp.Settings.Box
	esp.Distance.Visible = Esp.Settings.Distance
	esp.Tracer.Visible = Esp.Settings.Tracer
end)

-- newcclosure breaks Drawing.new apparently
Esp.Add = function(plr, root, col)
	if Esp.Container[root] then
		local Container = Esp.Container[root]
		Container.Connection:Disconnect()
		Container.Name:Remove()
		Container.Box:Remove()
		Container.Health:Remove()
		Container.Distance:Remove()
		Container.Tracer:Remove()
		Esp.Container[root] = nil
	end
	local Holder = {
		Name = Drawing.new("Text"),
		Box = Drawing.new("Square"),
		Health = Drawing.new("Square"),
		Distance = Drawing.new("Text"),
		Tracer = Drawing.new("Line"),
		Player = plr,
		Root = root,
		Colour = col
	}
	Esp.Container[root] = Holder
    Holder.Name.Text = plr.Name
    Holder.Name.Size = Esp.Settings.TextSize
    Holder.Name.Center = true
	Holder.Name.Color = col
    Holder.Name.Outline = true
    Holder.Box.Thickness = 1
	Holder.Box.Color = col
	Holder.Box.Filled = false
	Holder.Health.Thickness = 1
	Holder.Health.Color = Color3.fromRGB(0, 255, 0)
    Holder.Health.Filled = true
    Holder.Distance.Size = Esp.Settings.TextSize
    Holder.Distance.Center = true
	Holder.Distance.Color = col
	Holder.Distance.Outline = true
	Holder.Tracer.From = TracerStart
	Holder.Tracer.Color = col
	Holder.Tracer.Thickness = 1
	root.AncestryChanged:Connect(function(c, p)
		if not root:IsDescendantOf(workspace) then
			Esp.Remove(root)
		end
	end)
	Holder.Connection = game:GetService("RunService").Stepped:Connect(function()
		if Esp.Settings.Enabled then
			local Pos, Vis = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
			if Vis then
				local X = 2200 / Pos.Z
				local BoxSize = Vector2.new(X, X * 1.4)
				local Health = Esp.GetHealth(plr)
				Holder.Name.Position = Vector2.new(Pos.X, Pos.Y - BoxSize.X / 2 - (4 + Esp.Settings.TextSize))
				Holder.Box.Size = BoxSize
				Holder.Box.Position = Vector2.new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)
				Holder.Health.Color = Health > 0.66 and Color3.new(0, 1, 0) or Health < 0.33 and Color3.new(1, 0, 0) or Color3.new(1, 1, 0)
				Holder.Health.Size = Vector2.new(BoxSize.X / 8, BoxSize.Y * Health)
				Holder.Health.Position = Vector2.new(Pos.X - (BoxSize.X / 2 + BoxSize.X / 8 + 4), (Pos.Y - BoxSize.Y / 2) + ((1 - Health) * BoxSize.Y))
				Holder.Distance.Text = math.floor((root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude) .. " Studs"
				Holder.Distance.Position = Vector2.new(Pos.X, Pos.Y + BoxSize.X / 2 + 4)
				Holder.Tracer.To = Vector2.new(Pos.X, Pos.Y + BoxSize.Y / 2)
			end
			CheckVis(Holder, Vis)
		elseif Holder.Name.Visible == true then
			Holder.Name.Visible = false
			Holder.Box.Visible = false
			Holder.Health.Visible = false
			Holder.Distance.Visible = false
			Holder.Tracer.Visible = false
		end
	end)
end

Esp.AddItem = function(name, item, col)
	if Esp.ItemContainer[item] then
		local Container = Esp.ItemContainer[item]
		Container.Connection:Disconnect()
		Container.Name:Remove()
		Container.Box:Remove()
		Container.Distance:Remove()
		Container.Tracer:Remove()
		Esp.ItemContainer[item] = nil
	end
	local Holder = {
		Name = Drawing.new("Text"),
		Box = Drawing.new("Square"),
		Distance = Drawing.new("Text"),
		Tracer = Drawing.new("Line"),
		Item = item,
		YMult = item.Size.Y / item.Size.X,
		Colour = col
	}
	Esp.ItemContainer[item] = Holder
    Holder.Name.Text = name
    Holder.Name.Size = Esp.Settings.TextSize
    Holder.Name.Center = true
	Holder.Name.Color = col
    Holder.Name.Outline = true
    Holder.Box.Thickness = 1
	Holder.Box.Color = col
	Holder.Box.Filled = false
    Holder.Distance.Size = Esp.Settings.TextSize
    Holder.Distance.Center = true
	Holder.Distance.Color = col
	Holder.Distance.Outline = true
	Holder.Tracer.From = TracerStart
	Holder.Tracer.Color = col
	Holder.Tracer.Thickness = 1
	item.AncestryChanged:Connect(function(c, p)
		if not item:IsDescendantOf(workspace) then
			Esp.RemoveItem(item)
		end
	end)
	Holder.Connection = game:GetService("RunService").Stepped:Connect(function()
		if Esp.Settings.Enabled then
			local Pos, Vis = workspace.CurrentCamera:WorldToViewportPoint(item.Position)
			if Vis then
				local X = 2200 / Pos.Z
				local BoxSize = Vector2.new(X, X * Holder.YMult)
				Holder.Name.Position = Vector2.new(Pos.X, Pos.Y - BoxSize.X / 2 - (4 + Esp.Settings.TextSize))
				Holder.Box.Size = BoxSize
				Holder.Box.Position = Vector2.new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)
				Holder.Distance.Text = math.floor((item.Position - workspace.CurrentCamera.CFrame.Position).Magnitude) .. " Studs"
				Holder.Distance.Position = Vector2.new(Pos.X, Pos.Y + BoxSize.X / 2 + 4)
				Holder.Tracer.To = Vector2.new(Pos.X, Pos.Y + BoxSize.Y / 2)
			end
			CheckItemVis(Holder, Vis)
		elseif Holder.Name.Visible == true then
			Holder.Name.Visible = false
			Holder.Box.Visible = false
			Holder.Distance.Visible = false
			Holder.Tracer.Visible = false
		end
	end)
end

Esp.Remove = newcclosure(function(root)
	for i, v in next, Esp.Container do
		if i == root then
			v.Connection:Disconnect()
			v.Name:Remove()
			v.Box:Remove()
			v.Health:Remove()
			v.Distance:Remove()
			v.Tracer:Remove()
		end
	end
	Esp.Container[root] = nil
end)

Esp.RemoveItem = newcclosure(function(item)
	for i, v in next, Esp.ItemContainer do
		if i == item then
			v.Connection:Disconnect()
			v.Name:Remove()
			v.Box:Remove()
			v.Distance:Remove()
			v.Tracer:Remove()
		end
	end
	Esp.ItemContainer[item] = nil
end)

Esp.TeamCheck = newcclosure(function(plr)
	return plr.Team == Player.Team
end) -- can be overwritten for games that don't use default teams

Esp.GetHealth = newcclosure(function(plr)
	if not (plr.Character and plr.Character:FindFirstChild("Humanoid")) then
		return 0
	end
	return plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
end) -- can be overwritten for games that don't use default characters

Esp.UpdateTextSize = newcclosure(function(num)
	Esp.Settings.TextSize = num
	for i, v in next, Esp.Container do
		v.Name.Size = num
		v.Distance.Size = num
	end
end)

Esp.UpdateTracerStart = newcclosure(function(pos)
    TracerStart = pos
    for i, v in next, Esp.Container do
        v.Tracer.From = pos
    end
end)

Esp.ToggleRainbow = newcclosure(function(bool)
	if Esp.RainbowConn then
		Esp.RainbowConn:Disconnect()
	end
	if bool then
		Esp.RainbowConn = game:GetService("RunService").Heartbeat:Connect(function()
			local Colour = Color3.fromHSV(tick() % 12 / 12, 1, 1)
			for i, v in next, Esp.Container do
				v.Name.Color = Colour
				v.Box.Color = Colour
				v.Distance.Color = Colour
				v.Tracer.Color = Colour
			end
			for i, v in next, Esp.ItemContainer do
				v.Name.Color = Colour
				v.Box.Color = Colour
				v.Distance.Color = Colour
				v.Tracer.Color = Colour
			end
		end)
	else
		for i, v in next, Esp.Container do
			v.Name.Color = v.Colour
			v.Box.Color = v.Colour
			v.Distance.Color = v.Colour
			v.Tracer.Color = v.Colour
		end
		for i, v in next, Esp.ItemContainer do
			v.Name.Color = v.Colour
			v.Box.Color = v.Colour
			v.Distance.Color = v.Colour
			v.Tracer.Color = v.Colour
		end
	end
end)

return Esp