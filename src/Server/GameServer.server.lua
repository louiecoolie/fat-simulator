local Resources = game:GetService("ServerStorage")
local Assets = Resources:WaitForChild("Assets", 60)
local ServerModules = Resources:WaitForChild("Modules", 60)
local ServerServices = Resources:WaitForChild("Services", 60)
local RunService = game:GetService("RunService")
--local Database = Resources:WaitForChild("Database", 60)

local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)
local Database = game:GetService("ReplicatedStorage"):WaitForChild("Database", 60)

local Modules = {}
local Services = {}

-- module declarations
-- wait for modules to load
for _, module in ipairs(ServerModules:GetChildren()) do
    ServerModules:WaitForChild(module.Name, 30)
end

-- require/initialize modules
for _, module in ipairs(ServerModules:GetChildren()) do
        Modules[module.Name] = require(module)
end

for _, service in ipairs(ServerServices:GetChildren()) do
    Services[service.Name] = require(service)
end

local init = {}
local time = {
    last = 0,
    current = 0
}
local connections = {}

function init.GenerateServer()
 -- whatever needs to absolutely in the server before all else will be put in here
end

function init:CreateConnections()
    self.InspectRequest = Modules["Request"].RemoteEvent("inspect_request", Events)
    self.KillRequest = Modules["Request"].RemoteEvent("kill_request", Events)
    self.GhostUpdate = Modules["Request"].RemoteEvent("ghost_update", Events)
    self.GameComplete = Modules["Request"].RemoteEvent("game_complete", Events)
    self.GameRequest = Modules["Request"].RemoteEvent("game_request", Events)
    self.InventoryUpdate = Modules["Request"].RemoteEvent("inventory_update", Events)
    self.PlantRequest = Modules["Request"].RemoteEvent("plant_request", Events)
    self.RockRequest = Modules["Request"].RemoteEvent("rock_request", Events)
    self.AnimalRequest = Modules["Request"].RemoteEvent("animal_request", Events) 
    self.ResetRequest = Modules["Request"].RemoteEvent("reset_request", Events)
    self.ReportRequest = Modules["Request"].RemoteEvent("report_request", Events)
    self.MessageRequest = Modules["Request"].RemoteEvent("message_request", Events)
    self.VoteRequest = Modules["Request"].RemoteEvent("vote_request", Events)
    self.TimeUpdate = Modules["Request"].RemoteEvent("time_request", Events)
    self.EndMeetingRequest = Modules["Request"].RemoteEvent("end_request",Events)
    self.SabotageRequest = Modules["Request"].RemoteEvent("sabotage_request", Events)
    self.DoorRequest = Modules["Request"].RemoteEvent("door_request", Events)
    self.SabotageTask = Modules["Request"].RemoteEvent("sabotage_task", Events)
    self.SabotageTimer = Modules["Request"].RemoteEvent("sabotage_timer", Events)
    self.TaskCompleted = Modules["Request"].RemoteEvent("task_completed", Events)
    self.SabotageStopped = Modules["Request"].RemoteEvent("sabotage_stopped", Events) 
    self.LobbyUpdate = Modules["Request"].RemoteEvent("lobby_update", Events)
    self.ChatToggle = Modules["Request"].RemoteEvent("chat_toggle", Events)
    self.VentRequest = Modules["Request"].RemoteEvent("vent_request", Events)
    self.ResetPlayer = Modules["Request"].RemoteEvent("reset_player", Events)

    self.GetPlayerColor = Modules["Request"].RemoteFunction("get_color", Events)
end

function init:EstablishConnections()

    Services["ColorAssignment"]:Init(Events["get_color"])

    connections.SabotageStopped = self.SabotageStopped.OnServerEvent:Connect(function(player, sabotage_game)
        Services["GameService"].StopSabotage(sabotage_game)
    end)
    
    connections.VoteRequest = self.VoteRequest.OnServerEvent:Connect(function(player, vote_player)
        Services["GameService"].RequestVote(player, vote_player)
    end)

    connections.DoorRequest = self.DoorRequest.OnServerEvent:Connect(function(player, door)
        door.PrimaryPart.CanCollide = false
        door.PrimaryPart.Transparency = 1
        door:FindFirstChild("game_value"):Destroy()
    end)

    connections.SabotageRequest = self.SabotageRequest.OnServerEvent:Connect(function(player, sabotage)

        Services["GameService"].RequestSabotage(sabotage, player)
    end)

    connections.VentRequest = self.VentRequest.OnServerEvent:Connect(function(player, vent_number, vent_active)
        Services["GameService"].RequestVent(player, vent_number, vent_active)
    end)
    
    connections.MessageRequest = self.MessageRequest.OnServerEvent:Connect(function(player, message)
        self.MessageRequest:FireAllClients(player, message)
    end)

    connections.KillRequest = self.KillRequest.OnServerEvent:Connect(function(player, kill_player)
        Services["GameService"].RequestKill(player, kill_player)
    end)

    connections.ReportRequest = self.ReportRequest.OnServerEvent:Connect(function(player, report_player)
        Services["GameService"].RequestReport(player, report_player)
    end)

    connections.InspectRequest = self.InspectRequest.OnServerEvent:Connect(function(player, forage_ray, game_object)
        Modules["Inspect"].DetectInspect(player, forage_ray, game_object)
    end)

    connections.GameComplete = self.GameComplete.OnServerEvent:Connect(function(player, game)
        Services["GameService"].GameComplete(player, game)
    end)

    connections.RunGame = RunService.Heartbeat:Connect(function(dt)
        time.current = time.current+dt
        if time.current-time.last>=1 then
            time.last += 1
            Services["GameService"].TickGame(true)
        else
            Services["GameService"].TickGame()
        end
    end)
end

function init.StartServer()
    init.GenerateServer()
    init:CreateConnections()
    init:EstablishConnections()

end

init.StartServer()