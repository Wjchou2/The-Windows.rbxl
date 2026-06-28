local RunService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")
local ChatService = game:GetService("Chat")
local SoundService = game:GetService("SoundService")
local ModelVibrate = require(game.ReplicatedStorage.ModelVibrate)
local sounds=require(game.ReplicatedStorage.Sounds)

local maxSpeed = 50
local minSpeed = 3
local slowStartDistance = 30
local stopDistance = 1
local interact=game.Workspace.Interact
local car1: Model = workspace.Car1

local ChangeCamera = game.ReplicatedStorage:WaitForChild("ChangeCamera")
local SetPhoneMessage = game.ReplicatedStorage:WaitForChild("SetPhoneMessage")
local AskPhoneMessage = game.ReplicatedStorage:WaitForChild("AskPhoneMessage")
local AskStayLeave = game.ReplicatedStorage:WaitForChild("AskStayLeave")

local Transition = game.ReplicatedStorage:WaitForChild("Transition")
local TogglePlayerControl = game.ReplicatedStorage:WaitForChild("TogglePlayerControl")
local UpdateObjectives=game.ReplicatedStorage:WaitForChild("UpdateObjectives")

local ToggleObjectives=game.ReplicatedStorage:WaitForChild("ToggleObjectives")
local InteractionAsk=game.ReplicatedStorage:WaitForChild("InteractionAsk")


local connection
local fridgeDoorOpen=false
local fridgeDoorDebounce=true
local closedCFrame = interact.Door.PrimaryHinge.CFrame

local worker=workspace.Jake
local head = worker:WaitForChild("Head")



local prompts={
	ClosetDoor = game.Workspace.Interact.ClosetDoor.Knob.ClosetDoor,
	PizzaPlace = game.Workspace.Interact.FoodPlacePositions.Pizza.PizzaPlace,
	FridgeDoor = game.Workspace.Interact.Door.Handle.FridgeDoor,
	VodkaPick = game.Workspace.Interact.Vodka.Vodka.VodkaPick,
	VodkaPlace = game.Workspace.Interact.FoodPlacePositions.Vodka.VodkaPlace,
	PizzaPick = game.Workspace.Interact.Pizza.Pizza.PizzaPick,
	SodaPick = game.Workspace.Interact.Cans.Soda.SodaPick,
	SodaPlace = game.Workspace.Interact.FoodPlacePositions.Soda.SodaPlace,
}
local path= game.Workspace.Interact.Highlights
local highlights={
	Box1 = path.Box1,
	Box2 = path.Box2,
	Box3 = path.Box3,
	Closet = path.Closet,
	Fridge = path.Fridge
}
local player = Players:GetPlayers()[1]
if not player then
	player = Players.PlayerAdded:Wait()
	player.CharacterAdded:Wait()
end

function tweenPrimaryToX(car, targetX, time)
	local start = car.PrimaryPart.CFrame

	local goal = CFrame.new(
		targetX,
		start.Position.Y,
		start.Position.Z
	) * start.Rotation

	return TweenService:Create(
		car.PrimaryPart,
		TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{CFrame = goal}
	)
end


function moveCars(pos)
	local anim=tweenPrimaryToX(car1, pos.Position.X, 7)
	anim:Play()
	anim.Completed:Wait()
end

function movePlayer(part)
	player.Character:FindFirstChild("HumanoidRootPart"):PivotTo(part:GetPivot())
end

function enterStoreAnimation()
	Transition:FireAllClients()
	wait(1)

	TogglePlayerControl:FireAllClients(false)
	ChangeCamera:FireAllClients(game.Workspace:FindFirstChild("stopPos"),0,0)

	wait(1)

	ChangeCamera:FireAllClients(nil,0.2,3)
	wait(0.2*33)


	ChangeCamera:FireAllClients(nil,0,1)
	movePlayer(game.Workspace.MovePos:FindFirstChild("7"))
	TogglePlayerControl:FireAllClients(true)

end


interact.Door.Handle:WaitForChild("FridgeDoor").Triggered:Connect(function()
	if not fridgeDoorDebounce then return end
	fridgeDoorDebounce=false
	
	local tweenClose = TweenService:Create(interact.Door.PrimaryHinge, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = closedCFrame})
	local tweenOpen = TweenService:Create(interact.Door.PrimaryHinge, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = interact.Door.PrimaryHinge.CFrame*CFrame.Angles(0,math.rad(90),0)})
	if fridgeDoorOpen then
		sounds.playSoundFromPart(SoundService.Store.FridgeClose,interact.Door.Handle)
		tweenClose:Play()
		tweenClose.Completed:Wait()
	else
		sounds.playSoundFromPart(SoundService.Store.FridgeOpen,interact.Door.Handle)
		tweenOpen:Play()
		tweenOpen.Completed:Wait()
	end
	fridgeDoorOpen = not fridgeDoorOpen
	interact.Door.Handle.FridgeDoor.ActionText=fridgeDoorOpen and "Close" or "Open"
	wait(0.1)
	fridgeDoorDebounce=true
end)

function highlightBoxes()
	for i,v in pairs(highlights) do
		if string.sub(i,1,3)=="Box" then
			v.Enabled=true
		end
	end
end

function unhighlightAll()
	for i,v in pairs(highlights) do
		v.Enabled=false
	end
end

local function waitPrompt(x)
	if typeof(x) == "Instance" and x:IsA("ProximityPrompt") then
		x.Triggered:Wait()
	else
		local finished = false
		local connections = {}
		for _, prompt in pairs(x) do
			if (not prompt) then break end
			connections[#connections + 1] =
				prompt.Triggered:Connect(function()
					print(prompt.Parent)
					if (prompt.Parent==interact.FoodPlacePositions.Pizza) then sounds.playSoundFromPart(SoundService.Scene1.BoxPlace,prompt.Parent) end
					if (prompt.Parent==interact.FoodPlacePositions.Vodka) then sounds.playSoundFromPart(SoundService.Scene1.Glass,prompt.Parent) end
					if (prompt.Parent==interact.FoodPlacePositions.Soda) then sounds.playSoundFromPart(SoundService.Scene1.SodaCan,prompt.Parent) end
					finished = true
				end)
		end
		repeat task.wait() until finished
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end
	unhighlightAll()
end

function stockBoxes()
	ChangeCamera:FireAllClients(nil,0,1)
	movePlayer(game.Workspace.MovePos:FindFirstChild("7"))
	TogglePlayerControl:FireAllClients(true)
	ToggleObjectives:FireAllClients(true)
	UpdateObjectives:FireAllClients({"Restock the fridges"})
	highlights.Closet.Enabled=true	
	waitPrompt(prompts.ClosetDoor)
	for i=1,2 do
		highlightBoxes()
		waitPrompt({prompts.PizzaPick,prompts.SodaPick,prompts.VodkaPick})
		
		sounds.playSoundFromPart(SoundService.Scene1.BoxDrop,game.Workspace.Boxes["1"])
		highlights.Fridge.Enabled=true	
		waitPrompt({prompts.PizzaPlace,prompts.SodaPlace,prompts.VodkaPlace})

	end
	if prompts.SodaPick then prompts.SodaPick.Enabled=false end
	if prompts.PizzaPick then prompts.PizzaPick.Enabled=false end
	if prompts.VodkaPick then prompts.VodkaPick.Enabled=false end
	wait(2)
	interact.Phone.block.SurfaceGui.Enabled=true
	ChangeCamera:FireAllClients(interact.PhoneView,0.3,0)
	sounds.playSoundFromPart(SoundService.Scene1.PhoneBuzz,interact.Phone.main)
	for i=1,3 do
	
		ModelVibrate.vibrate(interact.Phone, 1.0, 0.1, 50)
		
		wait(0.3)
	end

	wait(1)
	ChangeCamera:FireAllClients(nil,0,1)
	UpdateObjectives:FireAllClients({"Check the Phone"})
end 

function phoneScene()
	interact.Phone.main.Pickup.Enabled=true
	interact.Phone:PivotTo(CFrame.new(-4.71772575, 3.27119565, -51.2425041)*CFrame.Angles(0, math.rad(90), math.rad(-90)))
	interact.Phone.main.Pickup.Triggered:Wait()
	interact.Phone.main.Pickup.Enabled=false
	ToggleObjectives:FireAllClients(false)

	SetPhoneMessage:FireAllClients("Hey Miles, are you at work?",1)

	sounds.playSound(SoundService.SpeakingFemale.FemaleMumble,1.5)
	
	wait(3)
	sounds.playSound(SoundService.SpeakingFemale.FemaleMumble,1.5)
	local response=AskPhoneMessage:InvokeClient(player,"We're having dinner tonight. Can you make it?")
	
	if (response) then
		SetPhoneMessage:FireAllClients("Thanks honey, It would mean a lot to us.")
	else
		SetPhoneMessage:FireAllClients("I understand. Just think about it, okay?")
	end
	sounds.playSound(SoundService.SpeakingFemale.FemaleMumble,1.5)

	wait(4)
	SetPhoneMessage:FireAllClients("We miss having you around.")
	sounds.playSound(SoundService.SpeakingFemale.FemaleMumble,2)

	wait(5)
	ChatService:Chat(head, "The fridge isn't gonna stock itself", Enum.ChatColor.White)
	SetPhoneMessage:FireAllClients("",2)
	interact.Phone.block.SurfaceGui.Enabled=false
	UpdateObjectives:FireAllClients({"Finish Restocking the fridges"})
	highlightBoxes()
	if prompts.SodaPick then prompts.SodaPick.Enabled=true end
	if prompts.PizzaPick then prompts.PizzaPick.Enabled=true end
	if prompts.VodkaPick then prompts.VodkaPick.Enabled=true end
	waitPrompt({prompts.PizzaPick,prompts.SodaPick,prompts.VodkaPick})

	highlights.Fridge.Enabled=true	
	while not fridgeDoorOpen do
		wait(0.1)
	end

	waitPrompt({prompts.PizzaPlace,prompts.SodaPlace,prompts.VodkaPlace})
	UpdateObjectives:FireAllClients({"Finished!"})
end


local dialogue1 = {
	"Morning.",
	"Hey.",
	"How's it going?",
	"Just these, thanks.",
	"Been busy today?",
	"Need this today.",
	"Long day ahead.",
	"Running a little late.",
	"Can't complain.",
	"Just stopping by.",
	"Thought I'd grab a few things.",
	"Another day, huh?",
	"Thanks for helping me out.",
	"Hope your shift's going alright.",
	"Glad you're open this early."
}

local dialogue2 = {
	"Thanks.",
	"Have a good one.",
	"Take care.",
	"See you around.",
	"Appreciate it.",
	"Stay safe.",
	"Have a good day.",
	"Good luck today.",
	"See you next time.",
	"Take it easy.",
	"Thanks, Miles.",
	"Enjoy the rest of your shift.",
	"Hope the day goes by fast.",
	"Have a good rest of your day.",
	"Catch you later."
}

local interactions = {
	{
		lines = {
			"My daughter starts high school today.",
			"She says she's not nervous."
		},

		choices = {
			"She'll be fine.",
			"You seem more nervous than she is."
		},

		responses = {
			"Haha. Maybe you're right.",
			"Yeah... maybe I am."
		}
	},

	{
		lines = {
			"I've got a job interview this afternoon.",
			"Trying not to think about it."
		},

		choices = {
			"Good luck.",
			"What job?"
		},

		responses = {
			"Thanks. I appreciate it.",
			"Warehouse supervisor."
		}
	},

	{
		lines = {
			"My brother moved away last month.",
			"The house feels weirdly quiet now."
		},

		choices = {
			"You'll get used to it.",
			"Have you called him?"
		},

		responses = {
			"Yeah. I guess I will eventually.",
			"Not as much as I should."
		}
	},

	{
		lines = {
			"Been taking care of my mom lately.",
			"Some days are harder than others."
		},

		choices = {
			"You're doing the right thing.",
			"That sounds exhausting."
		},

		responses = {
			"I hope so.",
			"It can be. But she's family."
		}
	},
	{
		lines = {
			"My son has a soccer game tonight.",
			"Hoping I can get off work in time."
		},

		choices = {
			"I'm sure you'll make it.",
			"How old is he?"
		},

		responses = {
			"I hope so.",
			"He's ten. Growing up too fast."
		}
	},

	{
		lines = {
			"I just moved into a new apartment.",
			"Still haven't unpacked half the boxes."
		},

		choices = {
			"Take your time.",
			"Moving is the worst."
		},

		responses = {
			"That's what everyone keeps telling me.",
			"You're not wrong."
		}
	},

	{
		lines = {
			"My dog's getting old.",
			"He doesn't move around like he used to."
		},

		choices = {
			"I'm sorry to hear that.",
			"What kind of dog?"
		},

		responses = {
			"Yeah. Just trying to enjoy the time we have.",
			"Golden retriever."
		}
	},

	{
		lines = {
			"I've been trying to quit caffeine.",
			"Clearly that's not going very well."
		},

		choices = {
			"Tomorrow's a new day.",
			"Looks like you gave up."
		},

		responses = {
			"That's what I keep saying.",
			"Just for today."
		}
	},

	{
		lines = {
			"My roommate keeps eating my food.",
			"I swear he's doing it on purpose."
		},

		choices = {
			"You should label it.",
			"Maybe he's just hungry."
		},

		responses = {
			"I've tried that.",
			"He's always hungry."
		}
	},

	{
		lines = {
			"I've been learning guitar lately.",
			"My neighbors are probably tired of hearing it."
		},

		choices = {
			"Everyone starts somewhere.",
			"What songs are you learning?"
		},

		responses = {
			"That's what I keep telling myself.",
			"Mostly old rock songs."
		}
	},

	{
		lines = {
			"My sister's visiting this weekend.",
			"First time I've seen her in almost a year."
		},

		choices = {
			"That'll be nice.",
			"Why so long?"
		},

		responses = {
			"Yeah, I'm looking forward to it.",
			"She lives on the other side of the country."
		}
	},

	{
		lines = {
			"I've been thinking about going back to school.",
			"Just not sure if I'm too old."
		},

		choices = {
			"It's never too late.",
			"What's stopping you?"
		},

		responses = {
			"Maybe you're right.",
			"Mostly fear, if I'm honest."
		}
	},

	{
		lines = {
			"My car's making a weird noise again.",
			"I'm pretending it isn't."
		},

		choices = {
			"That's usually a bad sign.",
			"Maybe it'll fix itself."
		},

		responses = {
			"Yeah, probably.",
			"That's been my strategy so far."
		}
	},

	{
		lines = {
			"I've been trying to call my dad more often.",
			"We don't talk much."
		},

		choices = {
			"I'm sure he appreciates it.",
			"Why not?"
		},

		responses = {
			"I think he does.",
			"I don't really know. We just drifted apart."
		}
	}

}
local doneInteraction=-1
function checkoutScene()
	game.Workspace.Interact.Highlights.Register.Enabled=true

	while #game.Workspace.NPCs:GetChildren()==0 or not game.Workspace.NPCs:GetChildren()[1]:GetAttribute("Ready")
	do wait(0.1) end
	wait(1)
	local npc:Model = game.Workspace.NPCs:GetChildren()[1]
	local prompt=Instance.new("ProximityPrompt")
	prompt.Parent=npc.Torso
	prompt.ActionText="Talk"
	prompt.RequiresLineOfSight=false
	prompt.Triggered:Wait()

	prompt:Destroy()
	ChangeCamera:FireAllClients(workspace.checkoutView,0.2,0)
	TogglePlayerControl:FireAllClients(false)
	local root = npc:WaitForChild("HumanoidRootPart")
	local humanoid = npc:WaitForChild("Humanoid")

	movePlayer(game.Workspace.checkoutView)
	local index = math.random(1, #dialogue1)
	local firstLine = dialogue1[index]
	local secondLine = dialogue2[index]

	local foodCart={}
	local food = npc:FindFirstChild("Food")
	while food do
		wait(0.1)
		food = npc:FindFirstChild("Food")
		table.insert(foodCart,food)

		if npc:WaitForChild("Right Arm"):FindFirstChild("WeldConstraint") then
			npc:WaitForChild("Right Arm"):FindFirstChild("WeldConstraint"):Destroy()
		end
		if food:IsA("Model") then
			for _,v in food:GetChildren() do
				v.Anchored=true
			end
		else
			food.Anchored=true
		end
		food:PivotTo(game.Workspace.foodPos:GetPivot()*CFrame.new(math.random(-1,1),0,math.random(-1,1)))
		food.Parent=workspace
		food = npc:FindFirstChild("Food")
	end
	local id=math.random(1,#interactions)
	while id==doneInteraction do
		id=math.random(1,#interactions)
	end
	local id=math.random(1,#SoundService.Speaking:GetChildren())
	ChatService:Chat(npc.Head, firstLine, Enum.ChatColor.White)
	sounds.playSound(SoundService.Speaking:GetChildren()[id],1.2)
	wait(1)
	local finishedCheckout = false
	task.spawn(function()
		for i,food in foodCart do
			waitForCheckout(food)

			wait(0.5)
		end
		finishedCheckout=true
	end)
	sounds.playSound(SoundService.Speaking:GetChildren()[id],1.2)


	ChatService:Chat(npc.Head, interactions[id]["lines"][1], Enum.ChatColor.White)
	wait(1.5)
	sounds.playSound(SoundService.Speaking:GetChildren()[id],1.2)

	ChatService:Chat(npc.Head, interactions[id]["lines"][2], Enum.ChatColor.White)
	wait(1)
	local answer= InteractionAsk:InvokeClient(player,interactions[id]["choices"][1],interactions[id]["choices"][2])
	wait(1)
	sounds.playSound(SoundService.Speaking:GetChildren()[id],1.2)

	ChatService:Chat(npc.Head, interactions[id]["responses"][answer], Enum.ChatColor.White)
	wait(1)

	while not finishedCheckout do
		wait(0.1)
	end
	sounds.playSound(SoundService.Speaking:GetChildren()[id],1.2)

	ChatService:Chat(npc.Head, secondLine, Enum.ChatColor.White)

	wait(0.5)
	npc:SetAttribute("Ready",false)
	npc:SetAttribute("done",true)
	if npc:FindFirstChildWhichIsA("Highlight") then
		npc:FindFirstChildWhichIsA("Highlight"):Destroy()
	end
	ChangeCamera:FireAllClients(nil,0,1)
	TogglePlayerControl:FireAllClients(true)

end
function waitForCheckout(food)
	local prompt= Instance.new("ProximityPrompt")
	prompt.RequiresLineOfSight=false
	prompt.ActionText="Scan"
	prompt.MaxActivationDistance=100
	prompt.Parent=food
	prompt.Triggered:Wait()
	sounds.playSound(SoundService.Scene1.Scan,1000)

	prompt:Destroy()
	if food:IsA("Model") then
		local scaleValue = Instance.new("NumberValue")
		scaleValue.Value = 1
		local connection = scaleValue:GetPropertyChangedSignal("Value"):Connect(function()
			food:ScaleTo(scaleValue.Value)
		end)

		local grow = TweenService:Create(
			scaleValue,
			TweenInfo.new(0.3),
			{Value = 1.5}
		)

		local shrink = TweenService:Create(
			scaleValue,
			TweenInfo.new(0.1),
			{Value = 0.1}
		)

		grow:Play()
		grow.Completed:Wait()

		shrink:Play()
		shrink.Completed:Wait()

		connection:Disconnect()
		scaleValue:Destroy()

	else
		local originalSize = food.Size
		local grow = TweenService:Create(food,TweenInfo.new(0.3),{Size = originalSize * 1.5})
		local shrink = TweenService:Create(food,TweenInfo.new(0.1),{Size = originalSize * 0.1})

		grow:Play()
		grow.Completed:Wait()

		shrink:Play()
		shrink.Completed:Wait()
	end
	prompt:Destroy()
	food:Destroy()
end


local isCheckingOut=false
task.spawn(function()
	while wait(2) do
		if not isCheckingOut and #game.Workspace.NPCs:GetChildren()>0 and  game.Workspace.NPCs:GetChildren()[1]:GetAttribute("Ready") then
			local npc=game.Workspace.NPCs:GetChildren()[1]
			local index = math.random(1, #dialogue1)
			local firstLine = dialogue1[index]
			ChatService:Chat(npc.Head, firstLine, Enum.ChatColor.White)
			wait(2)
			ChatService:Chat(worker.Head, dialogue2[math.random(1,#dialogue2)], Enum.ChatColor.White)
			wait(3)
			game.Workspace.NPCs:GetChildren()[1]:SetAttribute("Ready",false)

		elseif isCheckingOut and #game.Workspace.NPCs:GetChildren()>0 then
			local npc=game.Workspace.NPCs:GetChildren()[1]
			if not npc:FindFirstChild("Outline") and not npc:GetAttribute("done") then

				local outline= game.ReplicatedStorage.Outline:Clone()
				outline.Parent=npc
				outline.Adornee=npc
			end

			npc:SetAttribute("PlayerCheckout",true)
		end
	end
end)
function scalePlayers()
	local scale=1.1
	wait(1)
	for i,player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		humanoid.BodyHeightScale.Value *= scale
		humanoid.BodyWidthScale.Value *= scale
		humanoid.BodyDepthScale.Value *= scale
		humanoid.HeadScale.Value *= scale
	end
end
local ToggleDoor=game.ReplicatedStorage:WaitForChild("ToggleDoor")


function start()
	sounds.playSound(SoundService.Store.Ambience,100000)
	scalePlayers()
	
	ToggleObjectives:FireAllClients(false)
	ChangeCamera:FireAllClients(car1.CamPart,0,2)

	moveCars(workspace.stopPos)
	sounds.playSound(SoundService.Scene1.Car)

	--Enter Store
	Transition:FireAllClients()
	wait(1)
	TogglePlayerControl:FireAllClients(false)
	ChangeCamera:FireAllClients(nil,0.2,3)
	wait(0.2*6)
	ToggleDoor:Fire(true)
	

	wait(0.2*20)
	ToggleDoor:Fire(false)

	--TOGGLE TO PLAYER CONTROL
	ChangeCamera:FireAllClients(nil,0,1)
	movePlayer(game.Workspace.MovePos:FindFirstChild("7"))
	TogglePlayerControl:FireAllClients(true)
	ToggleObjectives:FireAllClients(true)
	_G.stopCustomers=false
	

	--Jake Talking
	ChatService:Chat(head, "Morning Miles", Enum.ChatColor.White)

	sounds.playSound(SoundService.Speaking.Mumble4,0.8)
	wait(1)
	
	ChatService:Chat(head, "Fridge still needs filling.", Enum.ChatColor.White)
	
	sounds.playSound(SoundService.Speaking.Mumble4,1)
	ToggleObjectives:FireAllClients(true)
	
	
	

	stockBoxes()
	game.Lighting.TimeOfDay="12:30:00"
	phoneScene()

	ToggleObjectives:FireAllClients(true)
	wait(1)
	isCheckingOut=true
	UpdateObjectives:FireAllClients({"Wait for and help customers at register 0/2"})
	for i=1,2 do
		checkoutScene()
		UpdateObjectives:FireAllClients({"Wait for and help customers at register 1/2"})
	end
	UpdateObjectives:FireAllClients({"Wait for and help customers at register 2/2"})
	isCheckingOut=false
	game.Workspace.Interact.Highlights.Register.Enabled=false
	wait(1)
	UpdateObjectives:FireAllClients({"Finished!"})

	game.Lighting.TimeOfDay="14:30:00"
	_G.stopCustomers=true
	wait(3)
	ChangeCamera:FireAllClients(workspace.workerViewPos,0.3,0)
	wait(0.5)
	ChatService:Chat(head, "Miles, It's almost the end of the day.", Enum.ChatColor.White)
	sounds.playSound(SoundService.Speaking.Mumble4,0.8)
	wait(1)
	ChatService:Chat(head, "Come real quick, I have a favor to ask", Enum.ChatColor.White)
	sounds.playSound(SoundService.Speaking.Mumble4,1.2)
	wait(2)


	ChangeCamera:FireAllClients(nil,0,1)
	local prompt=Instance.new("ProximityPrompt")
	prompt.Parent=worker.Torso
	prompt.ActionText="Talk"
	prompt.RequiresLineOfSight=false
	local go=true
	task.spawn(function()
		while go do
			task.wait(0)
			local npcPos = worker.HumanoidRootPart.Position
			local playerPos = player.Character.HumanoidRootPart.Position

			local targetCFrame = CFrame.lookAt(
				npcPos,
				Vector3.new(playerPos.X, npcPos.Y, playerPos.Z)
			)

			local tween = TweenService:Create(
				worker.HumanoidRootPart,
				TweenInfo.new(
					0.5,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				),
				{
					CFrame = targetCFrame
				}
			)

			tween:Play()
		end
	end)
	prompt.Triggered:Wait()
	prompt:Destroy()
	ChatService:Chat(head, "Paul wants to hang out with me today", Enum.ChatColor.White)
	sounds.playSound(SoundService.Speaking.Mumble4,1)
	wait(2)
	ChatService:Chat(head, "Can you cover my shift until 6?", Enum.ChatColor.White)
	sounds.playSound(SoundService.Speaking.Mumble4,1.3)
	wait(2.5)
	ToggleObjectives:FireAllClients(false)

	go=false
	game.Lighting.Blur.Size=0
	game.Lighting.Blur.Enabled=true

	TweenService:Create(game.Lighting.Blur, TweenInfo.new(1.5),{Size=35}):Play()
	game.Lighting.TimeOfDay="16:30:00"


	TogglePlayerControl:FireAllClients(false)
	ChangeCamera:FireAllClients(nil,0,4)
	local answer=AskStayLeave:InvokeClient(player)
	TogglePlayerControl:FireAllClients(true)


	TweenService:Create(game.Lighting.Blur, TweenInfo.new(1.5),{Size=0}):Play()
	wait(1.5)
	game.Lighting.Blur.Size=0
	game.Lighting.Blur.Enabled=false
	wait(1)
	ChangeCamera:FireAllClients(workspace.workerViewPos,0.3,0)
	wait(0.5)
	if answer then --stay work
		ChatService:Chat(head, "Thanks Miles, I owe you.", Enum.ChatColor.White)
		sounds.playSound(SoundService.Speaking.Mumble4,0.8)
		wait(3)
		Transition:FireAllClients()
		wait(1)
		TogglePlayerControl:FireAllClients(false)
		ChangeCamera:FireAllClients(workspace.friendsPos,0,-1)
		local jakefriend=game.Workspace.Friends.Jake
		local paulfriend=game.Workspace.Friends.Paul
		ChatService:Chat(jakefriend.Head, "Miles was so nice today.", Enum.ChatColor.White)
		sounds.playSound(SoundService.Speaking.Mumble4,1)
		wait(1.5)
		ChatService:Chat(paulfriend.Head, "Yeah you really owe him.", Enum.ChatColor.White)
		sounds.playSound(SoundService.Speaking.Mumble4,0.8)
		ChangeCamera:FireAllClients(workspace.friendsPos2,6,-1)
		wait(1)
		ChatService:Chat(jakefriend.Head, "...", Enum.ChatColor.White)

		wait(2)
		ChatService:Chat(paulfriend.Head, "...", Enum.ChatColor.White)
		wait(0.5)
		ChatService:Chat(jakefriend.Head, "...", Enum.ChatColor.White)
		wait(0.5)
		workspace.Family.Mom.Head.face.Transparency=1
		workspace.Family.Mom.Head.frown.Transparency=0
		workspace.Family.Dad.Head.face.Transparency=1
		workspace.Family.Dad.Head.frown.Transparency=0
		workspace.Family.Brother.Head.face.Transparency=1
		workspace.Family.Brother.Head.frown.Transparency=0
		Transition:FireAllClients()
		wait(1)
		ChangeCamera:FireAllClients(workspace.familyPosSad,0,-1)

		wait(2)
		ChangeCamera:FireAllClients(workspace.familyPosSad2,6,-1)
		wait(2)
		Transition:FireAllClients(false)


	else
		ChatService:Chat(head, "Alright, I'll figure something out.", Enum.ChatColor.White)
		sounds.playSound(SoundService.Speaking.Mumble4,0.8)
		wait(2)
		ChatService:Chat(head, "Have a good one, Miles.", Enum.ChatColor.White)
		sounds.playSound(SoundService.Speaking.Mumble4,1)

		ToggleObjectives:FireAllClients(false)
		wait(2)
		ChangeCamera:FireAllClients(nil,0.2,6)


		--NPC comes up
		local npc=game.ServerStorage.Char:GetChildren()[math.random(1,#game.ServerStorage.Char:GetChildren())]:Clone()
		npc.HumanoidRootPart:PivotTo(workspace.EndNPCSpawn:GetPivot())
		npc.Parent=workspace
		wait(0.2*15)

		wait(0.1)
		npc.Humanoid:MoveTo(workspace.EndNPCEnd.Position)
		npc.Humanoid.MoveToFinished:Wait()
		TweenService:Create(npc.HumanoidRootPart,TweenInfo.new(1),{CFrame=workspace.EndNPCEnd:GetPivot()*CFrame.new(0,2.5,0)}):Play()
		ChatService:Chat(npc.Head,"Is Jake still working?")
		wait(1.5)
		ChatService:Chat(npc.Head,"He's been wanting to get tonight off for a while")
		wait(2)
		ChatService:Chat(npc.Head,"I feel bad for him")
		wait(3)

		Transition:FireAllClients()
		TogglePlayerControl:FireAllClients(false)

		wait(1)
		ChangeCamera:FireAllClients(car1.CamPart,0,2)

		moveCars(workspace.stopPos2)


		wait(6)


		Transition:FireAllClients()

		wait(1)

		local npc = workspace.Family.Brother
		local humanoid = npc:WaitForChild("Humanoid")

		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end


		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://92810595838235" -- Roblox default laugh emote

		local track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped=true
		track:Play()
		local npc = workspace.Family.Mom
		local humanoid = npc:WaitForChild("Humanoid")

		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end

		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://120530619093075" -- Roblox default laugh emote

		local track = animator:LoadAnimation(anim)
		track.Looped=true
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		local npc = workspace.Family.Dad
		local humanoid = npc:WaitForChild("Humanoid")

		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end

		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://132237033687550" -- Roblox default laugh emote

		local track = animator:LoadAnimation(anim)
		track.Looped=true
		track.Priority = Enum.AnimationPriority.Action
		track:Play()

		ChangeCamera:FireAllClients(workspace.familyPos,0,-1)

		wait(1.5)
		ChatService:Chat(workspace.Family.Brother.Head, "Mom's been checking the window all afternoon.", Enum.ChatColor.White)

		wait(1.5)
		ChatService:Chat(workspace.Family.Dad.Head, "I'm glad you're here.")
		wait(1.5)
		ChatService:Chat(workspace.Family.Mom.Head, "You made it!")
		wait(3)

		Transition:FireAllClients()
		workspace.Jake.Head.Smile1.Transparency=1
		workspace.Jake.Head.Smile2.Transparency=1
		workspace.Jake.Head.Smile3.Transparency=1
		workspace.Jake.Head.Frown.Transparency=0
		worker:PivotTo(
			CFrame.new(9.351, 3.445, -47.789)
				* CFrame.Angles(0, math.rad(34.42), 0)
		)
		wait(1)
		ChangeCamera:FireAllClients(workspace.workerViewPos,0,-1)

		wait(2)
		ChangeCamera:FireAllClients(workspace.workerViewPos2,20,-1)
		wait(1.5)
		Transition:FireAllClients(false)

	end
	wait(1)
	local placeId = 133701951494104 

	for i,v in pairs(game.Players:GetPlayers()) do
		teleportService:Teleport(placeId, v)
	end

end
local ready=game.ReplicatedStorage:WaitForChild("Ready")
wait(1)
ready.OnServerEvent:Connect(start)
