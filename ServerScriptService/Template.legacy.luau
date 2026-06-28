local RunService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")
local ChatService = game:GetService("Chat")
local ChangeCamera = game.ReplicatedStorage:WaitForChild("ChangeCamera")

local player = Players:GetPlayers()[1]

local car1: Model = workspace.Car1


if not player then
	player = Players.PlayerAdded:Wait()
	player.CharacterAdded:Wait()
end

function tweenPrimaryToX(car, targetX, time)
	local start = car.PrimaryPart.CFrame
	local goal = CFrame.new(targetX,start.Position.Y,start.Position.Z) * start.Rotation
	return TweenService:Create(
		car.PrimaryPart,
		TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{CFrame = goal}
	)
end

function moveCars()
	local anim=tweenPrimaryToX(car1, workspace.stopPos.Position.X, 7)
	anim:Play()
	anim.Completed:Wait()
end

function movePlayer(part)
	player.Character:FindFirstChild("HumanoidRootPart"):PivotTo(part:GetPivot())
end
