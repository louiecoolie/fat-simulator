print("start server")

local Resources = game:GetService("ServerStorage")
local Assets = Resources:WaitForChild("Assets", 60)
local ServerModules = Resources:WaitForChild("Modules", 60)
local ServerServices = Resources:WaitForChild("Services", 60)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--local Database = Resources:WaitForChild("Database", 60)
print("start server")

local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)


local Modules = {}
local Services = {}
print("start server")

-- module declarations
-- wait for modules to load
for _, module in ipairs(ServerModules:GetChildren()) do
    ServerModules:WaitForChild(module.Name, 30)
end
print("start server")

-- require/initialize modules
for _, module in ipairs(ServerModules:GetChildren()) do
        Modules[module.Name] = require(module)
end
print("start server")

for _, service in ipairs(ServerServices:GetChildren()) do
    Services[service.Name] = require(service)
end
print("start server")

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
    self.InventoryUpdate = Modules["Request"].RemoteEvent("inventory_update", Events)
    self.ShopRequest = Modules["Request"].RemoteEvent("request_store", Events)
    self.StatusUpdate = Modules["Request"].RemoteEvent("status_update", Events)
    self.InteractionRequest = Modules["Request"].RemoteEvent("interaction_request", Events)

    self.GrowPlayer = Modules["Request"].RemoteEvent("grow_request", Events)

end

function init:EstablishConnections()
    connections.RequestGrow = self.GrowPlayer.OnServerEvent:Connect(function(player)
        Modules["Character"].Grow(player,Modules["Calculator"], Modules["Store"], Events)
        
    end)

    connections.ReceivePlayer = Players.PlayerAdded:Connect(function(player)
        Modules["Store"].LogPlayer(player, Modules["Calculator"], Events)
    
    end)

    connections.ReceiveInteraction = self.InteractionRequest.OnServerEvent:Connect(function(player, interaction)
        if interaction == "Sell" then
            Modules["Character"].Sell(player,Modules["Calculator"], Modules["Store"], Events)
        end
        if interaction == "Shop" then
            local cost_table = {
                power = {},
                storage = {},
            }

            for i=1, 25, 1 do
                print(Modules["Calculator"].Calculate("power", "cost", i))
                cost_table.power[i] = Modules["Calculator"].Calculate("power", "cost", i)
    
            end

            self.ShopRequest:FireClient(player,cost_table , Modules["Store"])
        end
    end)


end

function init.StartServer()
    init.GenerateServer()
    init:CreateConnections()
    init:EstablishConnections()

end

init.StartServer()