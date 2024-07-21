--!nonstrict
local Players = game:GetService("Players")

local saveChar = {}
local savePlr = {}

local function check(save, v): ()
	for _, q in v:GetChildren() do
		if q:IsA("Folder") then
			check(save, q)
			continue
		end
		table.insert(save, require(q))
	end
end

check(savePlr, script.PlayerAdded)
check(saveChar, script.CharacterAdded)

Players.PlayerAdded:Connect(function(plr)
	for _, v in savePlr do
		task.defer(function()
			if v.Added then
				v.Added(plr)
			end
		end)
	end
	plr.CharacterAdded:Connect(function(char)
		for _, v in saveChar do
			task.defer(function()
				if v.Added then
					v.Added(plr, char)
				end
			end)
		end
	end)
	plr.CharacterRemoving:Connect(function(char)
		for _, v in saveChar do
			task.defer(function()
				if v.Removing then
					v.Removing(plr, char)
				end
			end)
		end
	end)
	plr.CharacterAppearanceLoaded:Connect(function(char)
		for _, v in saveChar do
			task.defer(function()
				if v.AddedLoaded then
					v.AddedLoaded(plr, char)
				end
			end)
		end
	end)
end)
Players.PlayerRemoving:Connect(function(plr)
	for _, v in savePlr do
		task.defer(function()
			if v.Removing then
				v.Removing(plr)
			end
		end)
	end
end)
