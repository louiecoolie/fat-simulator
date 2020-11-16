-- services
print("start client")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ClientModules = script.Parent.Parent:WaitForChild("Modules", 60)
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)
local ClientControllers =  script.Parent.Parent:WaitForChild("Controllers", 60)
local ClientGames = script.Parent.Parent:WaitForChild("Games", 60)
local Interactable = workspace:FindFirstChild("Interact") or Instance.new("Folder", workspace)
print("start client")
local Events = {}
local Modules = {}
local Controllers = {}
local Games = {}

while #ClientEvents:GetChildren() < 1 do
	wait()

end

-- event/module/game initialization
for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 15)

end
print("start client")
for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
	
end
print("start client")
for _, module in ipairs(ClientModules:GetChildren()) do
    ClientModules:WaitForChild(module.Name, 5)
 
end
print("start client")
for _, module in ipairs(ClientModules:GetChildren()) do
        Modules[module.Name] = require(module)

end
print("start client")
for _, controller in ipairs(ClientControllers:GetChildren()) do
    ClientControllers:WaitForChild(controller.Name, 5)
 
end
print("start client")
for _, controller in ipairs(ClientControllers:GetChildren()) do
	Controllers[controller.Name] = require(controller)
end
print("start client")
for _, game in ipairs(ClientGames:GetChildren()) do
    ClientGames:WaitForChild(game.Name, 5)
 
end
print("start client")
for _, game in ipairs(ClientGames:GetChildren()) do

    Games[game.Name] = require(game)

end
print("start client")
-- player data
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local interaction_active = false


-- client system data
-- container to hold initialized connections to disconnect later at death or when necessary
local init = {}
local client = {}
local connections = {}

function init.GenerateClient()
	--Modules["Tool"].GetEvents(Events)
	client.Garbage = {}
	Games["Status"].Start()

	for _, object in pairs(Interactable:GetChildren()) do
		object.Touched:Connect(function(touch)
			if touch.Parent.Name == char.Name then
				if interaction_active == false then
					Modules["Interact"].Touch(object.Name)
					interaction_active = true
					wait(0.1)
				end
			end
		end)
		object.TouchEnded:Connect(function(touch)
			if touch.Parent.Name == char.Name then

				interaction_active = false

			end
		end)
	end
	
end

function init.CreateConnections()
	print("creating connections")
	Controllers["Keyboard"].Bind("grow", Modules["Interact"].Grow, false, Enum.UserInputType.MouseButton1)
	Controllers["TouchScreen"].Bind(Modules["Interact"].Grow)
end

function init.Disconnect()
	for _, object in pairs(connections) do
		if object then
			object:Disconnect()
		end
	end
end

function init.EstablishConnections()
	connections.StoreRequest = Events["request_store"].OnClientEvent:Connect(function(cost_table, store)
		Games["Store"].Start(cost_table, store)
	end)

	connections.ProximitySystem = RunService.Heartbeat:Connect(function()
		for _, object in pairs(Interactable:GetChildren()) do
			Modules["ProximityCheck"].CheckProximity(char.PrimaryPart.Position, object.Position, object.Size.X/2)
		
		end
	
	end)
 
end


function client.StartClient()
    init.GenerateClient()
    init.CreateConnections()
    init.EstablishConnections()
end

function client.StopClient()
	init.Disconnect()
end

function client.ResetClient()

	init.GenerateClient()
	--init.EstablishConnections()
end


client.StartClient()
print("finish start client")

