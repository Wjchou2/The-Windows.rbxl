local function setGroup(character, group)
	for _, v in character:GetDescendants() do
		if v:IsA("BasePart") then
			v.CollisionGroup = group
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		setGroup(character, "Players")
	end)
end)

