-- services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ClientModules = script.Parent.Parent:WaitForChild("Modules", 60)
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)
local ClientControllers =  script.Parent.Parent:WaitForChild("Controllers", 60)
local ClientGames = script.Parent.Parent:WaitForChild("Games", 60)

local Events = {}
local Modules = {}
local Controllers = {}
local Games = {}

-- event/module/game initialization
for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
	
end

for _, module in ipairs(ClientModules:GetChildren()) do
    ClientModules:WaitForChild(module.Name, 5)
 
end

for _, module in ipairs(ClientModules:GetChildren()) do
        Modules[module.Name] = require(module)

end

for _, controller in ipairs(ClientControllers:GetChildren()) do
    ClientControllers:WaitForChild(controller.Name, 5)
 
end

for _, controller in ipairs(ClientControllers:GetChildren()) do
	Controllers[controller.Name] = require(controller)
end

for _, game in ipairs(ClientGames:GetChildren()) do
    ClientGames:WaitForChild(game.Name, 5)
 
end

for _, game in ipairs(ClientGames:GetChildren()) do

    Games[game.Name] = require(game)

end

-- player data
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local game_started = false
local game_objects = {}

for _, object in pairs(workspace:GetChildren()) do
	if object:FindFirstChild("game_object") then
		game_objects[#game_objects+1] = object
	end
end

-- client system data
-- container to hold initialized connections to disconnect later at death or when necessary
local init = {}
local client = {}
local connections = {}

function init.GenerateClient()
	--Modules["Tool"].GetEvents(Events)
	client.Garbage = {}

	Modules["Character"].SetCharacter(char)
	Games["Lobby"].Start()
end

function init.CreateConnections()

	Controllers["Keyboard"].Bind("forage", Modules["Tool"].Inspect, false, Enum.UserInputType.MouseButton1)
	Controllers["TouchScreen"].Bind(Modules["Tool"].MobileInspect)
end

function init.Disconnect()
	for _, object in pairs(connections) do
		if object then
			object:Disconnect()
		end
	end
end

function init.EstablishConnections()



	connections.ReceiveEndRequest = Events["end_request"].OnClientEvent:Connect(function(result, player_list)
		Controllers["Keyboard"].Unbind("pick_player", Modules["Tool"].Inspect, false, Enum.UserInputType.MouseButton1)
		Controllers["Keyboard"].Bind("forage", Modules["Tool"].Inspect, false, Enum.UserInputType.MouseButton1)
		Controllers["TouchScreen"].Bind(Modules["Tool"].MobileInspect)

		for i, player in pairs(player_list.Crew) do
			if player == plr then
				Games["MeetingGame"].Stop(Games["Kick"], result.voted_player, result.vote_type)
			end
		end

		for i, player in pairs(player_list.Imposter) do
			if player == plr then
				Games["MeetingGame"].Stop(Games["Kick"], result.voted_player, result.vote_type)
			end
		end
	end)

	connections.PlayerResetted = char:WaitForChild("Humanoid", 60).Died:Connect(function()
		--Events["reset_request"]:FireServer()
	end)

	connections.ReceiveReportRequest = Events["report_request"].OnClientEvent:Connect(function(report_player, dead_player, player_list, type)
		local player_is_dead = false
		local player_is_crew = false
		local player_is_imposter = false

		Games["ReportModal"].Activate(type)


		for i, player in pairs(player_list.Dead) do
			if player == plr then
				player_is_dead = true
			end
		end

		for i, player in pairs(player_list.Crew) do
			if player == plr then
				player_is_crew = true
			end
		end

		for i, player in pairs(player_list.Imposter) do
			if player == plr then
				player_is_imposter = true
			end
		end

		if player_is_dead then
			Games["MeetingGame"].Start("dead",player_list)
			--wait(1)
			--Games["MeetingGame"].Stop()
		else
			Controllers["Keyboard"].Unbind("forage")
			
			Controllers["Keyboard"].Bind("pick_player", Modules["Tool"].ChoosePlayer, false, Enum.UserInputType.MouseButton1)
			Controllers["TouchScreen"].Bind(Modules["Tool"].MobileChoosePlayer)

			

			if player_is_imposter then
				Games["MeetingGame"].Start("imposter",player_list)
				--wait(1)
				--Games["MeetingGame"].Stop()
			end

			if player_is_crew then
				Games["MeetingGame"].Start("crew",player_list)
				--wait(1)
				--Games["MeetingGame"].Stop()
			end
		end



	end)
	connections.ReceiveGhostUpdate = Events["ghost_update"].OnClientEvent:Connect(function(dead, alive)
		Modules["Character"].UpdateCharacters(dead, alive, plr)
	end)

	connections.ReceiveSabotageTask = Events["sabotage_task"].OnClientEvent:Connect(function(sabotage_task)
		if sabotage_task == "end" then
			Games["ImposterTask"].Stop()
		else
			Games["ImposterTask"].Start(sabotage_task)
		end
	end)

	connections.ReceiveGameRequest = Events["game_request"].OnClientEvent:Connect(function(game_request, message, tasks, game_object, taskLocations, player_list, player_type)
		if game_request then
			if game_request == "DoorGame" then
				Games[game_request].Start(game_object)
			elseif game_request == "Imposter" then
				Games[game_request].Start(player_list, Games["EmergencyGame"])
				
			elseif game_request == "Crew" then
				Games[game_request].Start(tasks)
			else
				local is_game = false

				for _, task in pairs(game_objects) do
					if game_request == task.Name then
						is_game = true
						break
					else
						continue
					end
				end

				if is_game == true then
					if game_started == false then
						game_started = true
						Games[game_request].Start()
						--game_started = true
					end
				else
					Games[game_request].Start()
				end
			end

		end

		if message then
			if (message == "CrewModal") or (message == "ImposterModal") then
				Games["Fadeout"].Start()
				wait(1)
				Games["Logo"].Start()
				wait(4)
				Games["Logo"].Stop()
				wait(1)
				Games[message].Activate()
				wait(4)
				Games[message].Deactivate()
				Games["Fadeout"].Stop()

			else
				Games[message].Activate()
	
			end
		end
		if tasks then
			Games["Tasks"].Start(tasks, taskLocations)
			Games["Taskbar"].Start(tasks)
			Games["Map"].Start(tasks, taskLocations, player_type)
			client.Garbage = Modules["UpdateArea"].CreateTasks(tasks, client.Garbage)
		end
	end)

	connections.ReceiveCompletionConfirmation = Events["game_complete"].OnClientEvent:Connect(function(game_complete)
		game_started = false
		Games[game_complete].Stop()
		Games["Complete"].Activate()
	
	end)

	
	connections.ScanInteractables = RunService.Heartbeat:Connect(function()

		--local Scan = Modules["UpdateArea"].Scan(char, 20, spawn_points)
		-- scan was originally to load in stuff into view, but now it'll be used to sscan for interable objects in workspace

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
local success
while not success do
    success = pcall(game:GetService("StarterGui").SetCore, game:GetService("StarterGui"), "ResetButtonCallback", false)
    wait(1) --add a wait to ensure no Game script timeouts :P
end

success = nil

while not success do
	success = pcall(game:GetService("StarterGui").SetCore, game:GetService("StarterGui"), "ResetButtonCallback", false)
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    wait(1) --add a wait to ensure no Game script timeouts :P
end



client.StartClient()

Events["reset_player"].OnClientEvent:Connect(function()
	print("CLIENT RESTART")
	--client.StopClient()

	for _, garbage in pairs(client.Garbage) do
		garbage:Destroy()
	end

	for _, garbage in pairs(workspace.Garbage:GetChildren()) do
		garbage:Destroy()
	end

	--Games["Tasks"].Stop()

	plr = Players.LocalPlayer
 	char = plr.Character or plr.CharacterAdded:Wait()
	client.ResetClient()
end)

Events["chat_toggle"].OnClientEvent:Connect(function(windowEnabled, chatBarEnabled)
	print("Chat enabled:", windowEnabled, "Chatbar Enabled:", chatBarEnabled)
	game:GetService("StarterGui"):SetCore("ChatActive", windowEnabled)
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, windowEnabled)
	game:GetService("StarterGui"):SetCore("ChatBarDisabled", not chatBarEnabled)
end)

