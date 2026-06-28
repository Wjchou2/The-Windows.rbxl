
local this = {}


local clock = game.Workspace.Clock
local hands = clock:WaitForChild("Hands")

local hourHand = hands:WaitForChild("Hour")
local minuteHand = hands:WaitForChild("Minute")
local hourStart = hourHand:GetPivot()
local minuteStart = minuteHand:GetPivot()
local function setTime(hour: number, minute: number)
	hour = hour % 12

	minuteHand:PivotTo(
		minuteStart * CFrame.Angles(0,math.rad(-(minute * 6)),0)
	)

	hourHand:PivotTo(
		hourStart * CFrame.Angles(0,math.rad(-((hour + minute/60) * 30)),0)
	)
end
function this.setTime(hour, min)
	setTime(hour,min)
end


return this
