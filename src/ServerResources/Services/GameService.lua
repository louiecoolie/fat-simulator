local GameService = {}

local Resources = game:GetService("ServerStorage")
local Assets = Resources:WaitForChild("Assets", 60)
local Players = game:GetService("Players")
local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)

local atmosphere = Assets:WaitForChild("Sky"):WaitForChild("IngameAtmosphere")
local ingame_atmosphere = atmosphere:Clone()

local Dead = workspace:FindFirstChild("Dead") or Instance.new("Folder", workspace)
Dead.Name = "Dead"

local ColorAssigner = require(script.Parent:WaitForChild("ColorAssignment"))

--local PlayerAssets = Assets:WaitForChild("Player")
--local DeadPlayerModel = PlayerAssets:WaitForChild("Dead")

local GameServer = {
	Garbage = {},
	GameComplete = false

}

local GameDefault = {
	discussion_time = 1000, -- time to discuss
	voting_time = 1000, -- time to vote
	lastkick_time = 15, -- delay game end to play last kick message when it results in a win condition
	minimum_players = 3, -- minimum starat players
	imposter_ratio = 1/5, -- impostor to player ratio
	minimum_tasks = 3, -- minimin tasks per player
	intermission = game:GetService("RunService"):IsStudio() and 10 or 30, -- time between games
	load_time = 5, -- downtime after a game ends
	sabotage_timer = 60, -- timer for sabotage till end game is made
	kill_cooldown = 3000, -- impostr kill ability cooldown
	sabotage_cooldown = 1500, -- imposter sabotage cooldown
}

local GameState = {
	mode = "lobby",
	state = "unloaded",
	meeting = false,
	last_kick = false,
	sabotage = false
}

local PlayerList = {
	Lobby = {},
	Game = {},
	Crew = {},
	Imposter = {},
	Dead = {},
	Uncomplete = {}
}

local Votes = {
	PlayerVoted = {},
	TotalVote = {},
	HighestVote = {}

}

local TaskList = {
	Common = {},
	Short = {},
	Long = {}
}

TaskList.Common[#TaskList.Common+1] = "TreeGame"
TaskList.Common[#TaskList.Common+1] = "ChopGame"
TaskList.Common[#TaskList.Common+1] = "FuelGame"

TaskList.Short[#TaskList.Short+1] = "WaterGame"
TaskList.Short[#TaskList.Short+1] = "PlantGame"
TaskList.Short[#TaskList.Short+1] = "HuntGame"

TaskList.Long[#TaskList.Long+1] = "WheatGame"
TaskList.Long[#TaskList.Long+1] = "AnvilGame"

local TaskProgress = {
	Uncomplete = 0,
	Complete = 0,
	Alive = 0,
	Imposter = 0
}

local GameVents = {}

for _, barrel in pairs(workspace.sabotage.Vents:GetChildren()) do
    local vent_number = barrel:FindFirstChild("VentNumber").Value

    GameVents[vent_number] = barrel
end

local ActiveGameTasks = nil

Players.PlayerAdded:Connect(function(player)
	PlayerList.Lobby[#PlayerList.Lobby+1] = player
	PlayerList.Uncomplete[player] = 0

	ColorAssigner:AssignColorToPlayer(player)

	pcall(function()
		player:LoadCharacter()
		ColorAssigner:ColorCharacter(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)

	ColorAssigner:UnassignColorFromPlayer(player)

	TaskProgress.Uncomplete = TaskProgress.Uncomplete - PlayerList.Uncomplete[player]

	for i, lobby_player in pairs(PlayerList.Lobby) do
		if lobby_player == player then
			table.remove(PlayerList.Lobby, i)
		end
	end

	for _, game_player in pairs(PlayerList.Game) do -- for every player in the game
		if game_player == player then --if this player was playing 
			if PlayerList.Dead[player] then -- and they were dead
				print("Player was already dead before leaving") -- do nothing system had already handled the death
			else -- and they are alive
				for _, imposter in pairs(PlayerList.Imposter) do -- check to see if they are an imposter
					if imposter == player then
						print("this player was an imposter") -- do not change any values imposters have no tasks and taskprogress.alive only updates on kill confirmed\
						TaskProgress.Imposter -= 1
					elseif not(imposter == player) then
						TaskProgress.Alive -= 1
						print(TaskProgress.Alive)
						print("player was an alive crew, deducated alive value")
					end
				end
			end
		end
	end

end)


local function ClearTable(tbl)
	for k in pairs (tbl) do
		tbl[k] = nil
	end
end

local function UpdateGhosts()
	local alive = {}
	local dead = {}

	for i, live_player in pairs(PlayerList.Game) do
		if PlayerList.Dead[live_player] then
			dead[live_player] =live_player
		else
			alive[live_player] = live_player
		end

	end

	Events:FindFirstChild("ghost_update"):FireAllClients(dead, alive, PlayerList)
end

local function AssignTaskToPlayer(task, player)
	
end

local function getAssignableTasks()
	local assignableTasks = {}
	for taskKey, taskType in pairs(TaskList) do
		assignableTasks[taskKey] = {}
		for i = 1, #taskType do
			assignableTasks[taskKey][i] = taskType[i]
		end
	end
	return assignableTasks
end

local function AssignTasks(playerList)
	-- go through players and divide tasks among them
	-- divide tasks evenly among crew members, starting with long, then short, then Common

	local taskLocationDict = {} -- keep track of the locations for all the tasks to send to clients

	local maxAssignedTasks = {
		Common = 3,
		Short = 2,
		Long = 1
	}

	local assignedTasks = { -- lists of all assigned tasks
		Common = {},
		Short = {},
		Long = {}
	}

	local crewAssignedTasks = {} -- dictionary of player -> tasks
	for i = 1, #playerList.Crew do
		crewAssignedTasks[playerList.Crew[i]] = {
			Common = {},
			Short = {},
			Long = {}
		}
	end

	local function getNextQueuedPlayer(taskKey, lastPlayer) -- return nextPlayer only if they can fit in another task of type taskKey
		local nextPlayer, crewMemTaskList = next(crewAssignedTasks, lastPlayer)
		if not nextPlayer then
			nextPlayer, crewMemTaskList = next(crewAssignedTasks)
		end

		if #crewMemTaskList[taskKey] < maxAssignedTasks[taskKey] then
			return nextPlayer, crewMemTaskList, true
		else
			return nextPlayer, crewMemTaskList, false
		end
	end

	local assignableTasks = getAssignableTasks()
	-- while loop through assignable tasks until every crewmate has their tasks

	local nextPlayer, crewMemTaskList = next(crewAssignedTasks)
	for taskKey, taskType in pairs(assignableTasks) do
		local canAssign = true

		while #taskType > 0 do -- break if all players meet their quota
			-- assign random task to next player, then get next player in queue
			local taskIndex = math.random(1,#taskType)
			local taskToAssign = taskType[taskIndex]
			table.remove(taskType, taskIndex)

			local attempted = {}
			local assigned = false

			while nextPlayer and (not attempted[nextPlayer]) do
				attempted[nextPlayer] = true
				if canAssign then

					-- assign task
					local crewTaskTypeList = crewMemTaskList[taskKey]
					local taskTypeList = assignedTasks[taskKey]
					crewTaskTypeList[#crewTaskTypeList+1] = taskToAssign
					taskTypeList[#taskTypeList+1] = {taskToAssign, nextPlayer}
					PlayerList.Uncomplete[nextPlayer] += 1
					TaskProgress.Uncomplete += 1

					local worldModel = workspace:FindFirstChild(taskToAssign)
					if worldModel then
						taskLocationDict[taskToAssign] = worldModel.PrimaryPart.Position
					else
						warn("task", taskToAssign, "doesn't have a world object.")
					end

					assigned = true

					print("assigned", taskToAssign, "to", nextPlayer)
					nextPlayer, crewMemTaskList, canAssign = getNextQueuedPlayer(taskKey, nextPlayer)
					break
				else
					nextPlayer, crewMemTaskList, canAssign = getNextQueuedPlayer(taskKey, nextPlayer)
				end
			end
			if not assigned then
				print("all players are full on this type of task, breaking")
				break
			end
		end
	end

	-- now assign already assigned tasks to imposters
	local imposterTasks = {}
	for i = 1, #playerList.Imposter do
		local imposter = playerList.Imposter[i]
		imposterTasks[imposter] = {}
		for taskKey, taskType in pairs(assignedTasks) do
			imposterTasks[imposter][taskKey] = {}
			for j = 1, maxAssignedTasks[taskKey] do
				-- just go through the list incrementally, we can randomize this later
				local tab = imposterTasks[imposter][taskKey]
				tab[#tab+1] = taskType[j][1]
				print("imposter task,", taskType[j][1])
			end
		end
	end

	return assignedTasks, crewAssignedTasks, imposterTasks, taskLocationDict
end

local function TallyVote()

	for _, voted_player in pairs(Votes.PlayerVoted) do
		if 	Votes.TotalVote[voted_player] then
			Votes.TotalVote[voted_player] = Votes.TotalVote[voted_player] + 1
		else
			Votes.TotalVote[voted_player] = 1
		end

	end

	local top_vote = 0
	local tie = false

	for player, vote_count in pairs(Votes.TotalVote) do 
		print(player, vote_count)
		if vote_count > top_vote then
			Votes.HighestVote[1] = player
			top_vote = vote_count
		end
	end

	for player, vote_count in pairs(Votes.TotalVote) do
		if vote_count == top_vote then
			if player == Votes.HighestVote[1] then -- if this is the same player with the most Votes
				print("this is the player who  already has the highest vote")
			else
				print(player, " has tied vote to highest vote")
				tie = true
			end
		end
	end

	local result = {
		voted_player = nil,
		vote_type = nil
	}

	ClearTable(Votes.PlayerVoted)
	ClearTable(Votes.TotalVote)

	if tie == true then
		print("game has found a tie, execute tie")
		result.voted_player = nil
		result.vote_type = "tie"
		return result
	else
		local is_imposter = false
		for _, imposter in pairs(PlayerList.Imposter) do
			if imposter.Name == Votes.HighestVote[1] then
				
				is_imposter = true
			end
		end
		if is_imposter then
			print("voted the imposter, handle imposter kick off")

			result.voted_player = Votes.HighestVote[1] 
			result.vote_type = "imposter"
			local player_value
			for _, player in pairs(game:GetService("Players"):GetPlayers()) do
				if player.name == Votes.HighestVote[1] then
					player_value = player
				end
			end

			if Votes.HighestVote[1] == nil then
				print("no one was voted")
			else
				PlayerList.Dead[player_value] = player_value
				TaskProgress.Imposter -= 1
				print("Murder player")
		
				UpdateGhosts()
			end

			if TaskProgress.Imposter == 0 then
				return result, true
			else
				return result 
			end
		else
			if Votes.HighestVote[1] == "Skip" then
				print("handle skip")
				result.voted_player = nil
				result.vote_type = "skip"
				return result
			else
				
				print("voted innocent, handle innocent kick off")
				result.voted_player = Votes.HighestVote[1]
				result.vote_type = "innocent"

				local player_value
				for _, player in pairs(game:GetService("Players"):GetPlayers()) do
					if player.name == Votes.HighestVote[1] then
						player_value = player
					end
				end

				if Votes.HighestVote[1] == nil then
					print("no one was voted")
				else
					PlayerList.Dead[player_value] = player_value
					TaskProgress.Alive -= 1
					print("Murder player")
			
					UpdateGhosts()
				end
				if TaskProgress.Alive == 0 or TaskProgress.Alive == TaskProgress.Imposter then
					return result, true
				else
					return result 
				end
			end
		end
	end
end

local function StartGame()

	local impCount = math.ceil((#PlayerList.Game-1)*GameDefault.imposter_ratio)
	local drawing = {}
	for i = 1, #PlayerList.Game do
		drawing[i] = PlayerList.Game[i]
	end

	-- grab impCount randomly from drawing list
	for i = 1, impCount do
		local chosenIndex = math.random(1,#drawing)
		local chosenPlayer = drawing[chosenIndex]
		table.remove(drawing, chosenIndex)
		PlayerList.Imposter[#PlayerList.Imposter+1] = chosenPlayer
		TaskProgress.Imposter += 1
	end

	while #drawing > 0 do -- then treat as a stack and assign rest to crew
		local size = #drawing
		local crew = drawing[size]
		drawing[size] = nil

		TaskProgress.Alive += 1
		PlayerList.Crew[#PlayerList.Crew+1] = crew
	end

	local assignedTasks, crewAssignedTasks, imposterTasks, locations = AssignTasks(PlayerList)
	ActiveGameTasks = assignedTasks

	-- go through crew and send tasks
	for crewMember, taskList in pairs(crewAssignedTasks) do
		Events:FindFirstChild("game_request"):FireClient(crewMember,"Crew","CrewModal", taskList, nil, locations,PlayerList, "crew")
	end

	-- go through imposters and send fake tasks
	for imposter, taskList in pairs(imposterTasks) do
		Events:FindFirstChild("game_request"):FireClient(imposter,"Imposter","ImposterModal", taskList, nil, locations,PlayerList, "spy")
	end

	for _, player in pairs(PlayerList.Game) do
		player.Character:SetPrimaryPartCFrame(CFrame.new(0,4,0))
	end

	-- disable chat when starting the game
	Events:FindFirstChild("chat_toggle"):FireAllClients(false, false)

	-- turn on the fog
	ingame_atmosphere.Parent = game:GetService("Lighting")

	GameState.state = "loaded"
end



function GameService.GameComplete(player, game)
	print("Confirmed" .. game .. "completed, marking task complete in master task list")

	for _, imposter in pairs(PlayerList.Imposter) do
		if imposter.Name == player.Name then
			print("Imposters tasks do not affect the game")
		else
			TaskProgress.Complete += 1
			TaskProgress.Uncomplete -= 1
			PlayerList.Uncomplete[player] = PlayerList.Uncomplete[player] - 1
			print(TaskProgress.Complete, TaskProgress.Uncomplete,PlayerList.Uncomplete[player])
			Events:FindFirstChild("task_completed"):FireAllClients(TaskProgress.Complete, TaskProgress.Complete+TaskProgress.Uncomplete)
		end
	end

	Events:FindFirstChild("game_complete"):FireClient(player, game)

end

function GameService.RequestReport(player, report_player)
	print(player, report_player)
	if PlayerList.Dead[player] then
		print("player cannot report they are dead")
		
	else
		if report_player.Name == "Emergency" then
			if GameState.meeting == false and GameServer.GameComplete == false then
				GameService.ResetSabotage()
				Events:FindFirstChild("report_request"):FireAllClients(player, report_player, PlayerList, "Emergency")
				GameState.meeting = true
				for i = 1, #PlayerList.Game do
					local plr = PlayerList.Game[i]
					if not PlayerList.Dead[plr] then
						-- alive players can see and type in the chat
						Events:FindFirstChild("chat_toggle"):FireClient(plr, true, true)
					else
						-- dead players can only see the chat, cannot communicate
						Events:FindFirstChild("chat_toggle"):FireClient(plr, true, false)
					end
				end
			end
		else

			if PlayerList.Dead[player] then
				print("Player is dead")
				--UpdateGhosts()
				--check if the requested kill_player is dead
			else
				for _, object in pairs(workspace.Dead:GetChildren()) do
					if not(object.Name == "Emergency") then
						object:Destroy()
					end
				end
				--Dead:FindFirstChild(report_player.Name):Destroy()
				if GameState.meeting == false and GameServer.GameComplete == false then
					Events:FindFirstChild("report_request"):FireAllClients(player, report_player, PlayerList, "Murder")
					GameState.meeting = true
					for i = 1, #PlayerList.Game do
						local plr = PlayerList.Game[i]
						if not PlayerList.Dead[plr] then
							-- alive players can see and type in the chat
							Events:FindFirstChild("chat_toggle"):FireClient(plr, true, true)
						else
							-- dead players can only see the chat, cannot communicate
							Events:FindFirstChild("chat_toggle"):FireClient(plr, true, false)
						end
					end
				end
			end
		end
	end
end

function GameService.StopSabotage(sabotage)
	Events:FindFirstChild("sabotage_task"):FireAllClients("end")
	print(sabotage , "was sent here")
	GameServer.Garbage[sabotage]:Destroy()
	GameState.sabotage = false
	GameDefault.sabotage_timer = 60
end

function GameService.ResetSabotage()
	Events:FindFirstChild("sabotage_task"):FireAllClients("end")
	for _, item in pairs(GameServer.Garbage) do
		item:Destroy()
	end

	GameState.sabotage = false
	GameDefault.sabotage_timer = 60
end

function GameService.RequestSabotage(sabotage)
	if sabotage.Name == "Door" then
		sabotage.PrimaryPart.CanCollide = true
		sabotage.PrimaryPart.Transparency = 0
		local DoorGame = sabotage:FindFirstChild("game_value") or Instance.new("StringValue")
		DoorGame.Name = "game_value"
		DoorGame.Value = "DoorGame"
		DoorGame.Parent = sabotage
	elseif sabotage.Name == "Fire" then
		print("tried to start a fire")
		if GameState.sabotage == false then
			local FireGame = sabotage:FindFirstChild("game_value") or Instance.new("StringValue")
			FireGame.Name = "game_value"
			FireGame.Value = "FireGame"
			FireGame.Parent = sabotage
			Events:FindFirstChild("sabotage_task"):FireAllClients("Fire has been started! Put it out before it burns the town in...", "Fire")
			GameState.sabotage = true
			GameServer.Garbage["FireGame"] = FireGame
		end

end




end

function GameService.RequestVent(player, vent_number,vent_active)
	if vent_active == true then
		print(player, "requested vent", vent_number)

		workspace:FindFirstChild(player.Name):SetPrimaryPartCFrame(GameVents[vent_number].PrimaryPart.CFrame)
		
	elseif vent_active == false then
		workspace:FindFirstChild(player.Name):SetPrimaryPartCFrame(GameVents[vent_number].PrimaryPart.CFrame*CFrame.new(0,5,0))
	end
end

function GameService.RequestKill(player, kill_player)
	print("Imposter requested a kill")
		-- server received client notification of the kill

	if PlayerList.Dead[kill_player] then
		print("Player is dead")
		UpdateGhosts()
		--check if the requested kill_player is dead
	else
		PlayerList.Dead[kill_player] = kill_player
		TaskProgress.Alive -= 1
		print("Murder player")

		local dead_player = Assets.Player.Dead:Clone()
		dead_player:SetPrimaryPartCFrame(kill_player.Character.PrimaryPart.CFrame)
		dead_player.Name = kill_player.Name -- make a dead player workspace folder

		local bodyParts = dead_player:GetChildren()
		for i = 1, #bodyParts do
			local p = bodyParts[i]
			if p:IsA("BasePart") and p.Name == "PlayerColor" then
				p.Color = BrickColor.new(ColorAssigner:GetPlayerColor(kill_player)).Color
			end
		end

		dead_player.Parent = Dead

		GameServer.Garbage[#GameServer.Garbage+1] = dead_player

		UpdateGhosts()
		--set kill_player invisible to all clients except those who are already dead
		--put kill_player in dead list in PlayerList
		--spawn a dead character model
		--remove kill_players ability to participate in meeting



	end

end


function GameService.RequestVote(player, vote_player)
	print(player, vote_player)
	local vote_player_instance = nil
	local dead_vote = false
	for i, dead in pairs(PlayerList.Dead) do
		if dead.Name == vote_player then
			dead_vote = true
			print("player voted is dead")
		end
	end

	if GameState.meeting == true then
		if GameDefault.discussion_time <= 0  then
			if PlayerList.Dead[player] then
				print("Player is dead")
				UpdateGhosts()
				--check if the requested kill_player is dead
			elseif dead_vote then
				print("Voted player is dead")
				-- check if the requested vote is dead

			else
				print(typeof(player), typeof(vote_player))

				local vote_character = workspace:FindFirstChild(vote_player):FindFirstChild("Character").ColoredParts.Plumage
				
				workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Color = vote_character.Color

				Votes.PlayerVoted[player] = vote_player
				Events:FindFirstChild("vote_request"):FireAllClients(player)
			end
		end
	end
end

function GameService.TickGame(time)
	
	if GameState.mode == "lobby" then
		if ingame_atmosphere.Parent ~= nil then
			ingame_atmosphere.Parent = nil
		end

		for _, player in pairs(PlayerList.Lobby) do
			pcall(function()
				ColorAssigner:ColorCharacter(player)
			end)
		end
		
		if #PlayerList.Lobby < GameDefault.minimum_players then
			-- create a ui hook to say waiting on x player
			Events:FindFirstChild("lobby_update"):FireAllClients("will begin once " .. GameDefault.minimum_players .. " are in the server")
		elseif #PlayerList.Lobby >= GameDefault.minimum_players then
			if GameDefault.intermission > 0 and not(GameDefault.intermission < 0) then
				if time then
					GameDefault.intermission -= 1
					Events:FindFirstChild("lobby_update"):FireAllClients("will begin in " .. GameDefault.intermission .. " seconds")
				end
		
			else
				ClearTable(PlayerList.Dead)
				GameState.mode = "game"
				for i, player in pairs(PlayerList.Lobby) do
					PlayerList.Game[#PlayerList.Game + 1] = player
					--table.remove(PlayerList.Lobby, i)
					Events:FindFirstChild("lobby_update"):FireClient(player, "begin")
				end
				StartGame()
			end
		end
	elseif GameState.mode == "reset" then
		
		Events:FindFirstChild("reset_request"):FireAllClients()


		for key, table in pairs(PlayerList) do
			ClearTable(table)
		end
	
		for key, value in pairs(TaskProgress) do
			TaskProgress[key] = 0
		end
		local new_players = Players:GetPlayers()
		for _, player in pairs(new_players) do
			PlayerList.Lobby[#PlayerList.Lobby+1] = player
			PlayerList.Uncomplete[player] = 0

			pcall(function() 
				player:LoadCharacter()
				ColorAssigner:ColorCharacter(player)
			end)
		end
		for _, garbage in pairs(GameServer.Garbage) do
			garbage:Destroy()
		end

		
		Events:FindFirstChild("reset_player"):FireAllClients()
		GameDefault.intermission = game:GetService("RunService"):IsStudio() and 10 or 30
		GameDefault.load_time = 5
		GameServer.GameComplete = false
		--GameDefault.minimum_players = 3
		GameState.mode = "lobby"
	-- empty out game related tables and variables to get ready for reassignment for next game
	elseif GameState.mode == "game" then
		if	GameState.state == "loaded" then
			
			if GameState.meeting == true then
				if GameDefault.discussion_time > 0 and not(GameDefault.discussion_time < 0) then
					GameDefault.discussion_time -= 1

					Events:FindFirstChild("time_request"):FireAllClients("Discuss!",(GameDefault.discussion_time/100)) 
				elseif GameDefault.voting_time > 0 and not (GameDefault.voting_time < 0) then
					GameDefault.voting_time -= 1

					Events:FindFirstChild("time_request"):FireAllClients("Vote!",(GameDefault.voting_time/100)) 

				elseif GameDefault.voting_time == 0 or GameDefault.voting_time < 0 then
					GameState.meeting = false
					GameDefault.discussion_time = 1000
					GameDefault.voting_time = 1000
					local result, skip_result = TallyVote()
					if skip_result then
						print("skipped to win condition")
						GameState.last_kick = true
						Events:FindFirstChild("end_request"):FireAllClients(result,PlayerList)
					else
						Events:FindFirstChild("end_request"):FireAllClients(result,PlayerList)
					end

					-- disable chat again when meeting is over
					Events:FindFirstChild("chat_toggle"):FireAllClients(false, false)
				end
			end

			if not(GameState.meeting) and GameState.sabotage then
				if time then
					GameDefault.sabotage_timer -= 1
					print(GameDefault.sabotage_timer)
					Events:FindFirstChild("sabotage_timer"):FireAllClients(GameDefault.sabotage_timer)
					if GameDefault.sabotage_timer == 0 or GameDefault.sabotage_timer < 0 then
						GameState.sabotage = false
						GameDefault.sabotage_timer = 60
						print("handle sabotage end")

						TaskProgress.Alive = 0

					end
				end
			end

			if GameState.last_kick == true then
				if GameDefault.lastkick_time > 0 and not (GameDefault.lastkick_time < 0) then
					if time then
						GameDefault.lastkick_time -= 1
					end
				else
					GameState.last_kick = false
					GameDefault.lastkick_time = 15
				end
			else
				if (TaskProgress.Uncomplete == 0 and not(TaskProgress.Alive == 0)) or TaskProgress.Imposter == 0 then

					if GameServer.GameComplete == false then
						GameServer.GameComplete = true
						Events:FindFirstChild("game_request"):FireAllClients(nil,"CrewWinModal")
						-- enable chat again for lobby
						Events:FindFirstChild("chat_toggle"):FireAllClients(true, true)
					end

					if GameDefault.load_time > 0 and not(GameDefault.load_time < 0) then
						if time then
							GameDefault.load_time -= 1
						end
				
					else
						GameState.mode = "reset"
						GameState.state = "unloaded"
					end

					-- send crew win modal
				end

				if TaskProgress.Alive == TaskProgress.Imposter and not(TaskProgress.Uncomplete == 0) then

					if GameServer.GameComplete == false then
						GameServer.GameComplete = true
						Events:FindFirstChild("game_request"):FireAllClients(nil,"ImposterWinModal")
						-- enable chat again for lobby
						Events:FindFirstChild("chat_toggle"):FireAllClients(true, true)
					end

					if GameDefault.load_time > 0 and not(GameDefault.load_time < 0) then
						if time then
							GameDefault.load_time -= 1
						end
				
					else
						GameState.mode = "reset"
						GameState.state = "unloaded"
					end
					-- send imposter win modal
				end 

				if TaskProgress.Alive == 0 then

					if GameServer.GameComplete == false then
						GameServer.GameComplete = true
						Events:FindFirstChild("game_request"):FireAllClients(nil,"ImposterWinModal")
						-- enable chat again for lobby
						Events:FindFirstChild("chat_toggle"):FireAllClients(true, true)
					end

					if GameDefault.load_time > 0 and not(GameDefault.load_time < 0) then
						if time then
							GameDefault.load_time -= 1
						end
				
					else
						GameState.mode = "reset"
						GameState.state = "unloaded"
					end
					-- send imposter win modal
				end 

				if TaskProgress.Alive == 0 and TaskProgress.Uncomplete == 0 then

					if GameServer.GameComplete == false then
						GameServer.GameComplete = true
						Events:FindFirstChild("game_request"):FireAllClients(nil,"TieWinModal") 
						-- enable chat again for lobby
						Events:FindFirstChild("chat_toggle"):FireAllClients(true, true)
					end

					if GameDefault.load_time > 0 and not(GameDefault.load_time < 0) then
						if time then
							GameDefault.load_time -= 1
						end
				
					else
						GameState.mode = "reset"
						GameState.state = "unloaded"
					end
					-- send tie lose modal
				end
			end
		end
	end
end



return GameService