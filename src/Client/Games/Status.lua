--[[
    Status will hold the status values of the player 

    From server, this module will receive the updated Value and update the player's view

    The max amount and the incremented amount will be defined by the server.

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))
local ClientModules = script.Parent.Parent:WaitForChild("Modules", 60)

local spring = Otter.spring
local motor = Otter.createSingleMotor

local Players = game:GetService("Players")
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)

local Events = {}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end


local PlayerGui = Players.LocalPlayer.PlayerGui

local Interface = Roact.Component:extend("Status")

local game_handle = nil
local game_connections = {}

local Game = {}

function Interface:init()
    self:setState({
        value = 0,
        storage = 0,
        premium = 0
    })
end

function Interface:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true
    },{
        CurrencyContainer = Roact.createElement("Frame",{
            Size = UDim2.new(0.15,0,0.1,0),
            Position = UDim2.new(0.05,0,0.5,0),
            BackgroundTransparency = 0,
            ZIndex = 1
        },{
            Value = Roact.createElement("TextLabel",{
                Size = UDim2.new(0.5,0,1,0),
                Position = UDim2.new(0,0,0,0),
                Text = self.state.value


            }),
            Storage = Roact.createElement("TextLabel",{
                Size = UDim2.new(0.5,0,1,0),
                Position = UDim2.new(0.5,0,0,0),
                Text = self.state.storage


            })


        }),
        PremiumCurrencyContainer = Roact.createElement("Frame",{
            Size = UDim2.new(0.15,0,0.1,0),
            Position = UDim2.new(0.05,0,0.61,0),
            BackgroundTransparency = 0,
            ZIndex = 1
        },{
            Value = Roact.createElement("TextLabel",{
                Size = UDim2.new(0.5,0,1,0),
                Position = UDim2.new(0,0,0,0),
                Text = self.state.premium


            }),
            Storage = Roact.createElement("TextButton",{
                Size = UDim2.new(0.5,0,1,0),
                Position = UDim2.new(0.5,0,0,0),
                Text = "+"

            })


        })
    })
end

function Interface:didMount()
    self:setState(function(state)
        return {
            value = state.value + 1
        }
    end)
    game_connections.statusUpdate = Events["status_update"].OnClientEvent:Connect(function(status, value)
        if status == "storage" then
            self:setState(function(state)
                return {
                    storage = value
                }
            end)

        end

        if status == "currency" then
            self:setState(function(state)
                return {
                    value = value
                }
            end)

        end

        
        if status == "premium" then
            self:setState(function(state)
                return {
                    premium = value
                }
            end)

        end
    
    end)
end

function Game.Start()

    game_handle = Roact.mount(Roact.createElement(Interface), PlayerGui, "Player Status")

end

function Game.Stop()
    for _, connect in pairs(game_connections) do
        if connect then connect:Disconnect() end
    end

    if game_handle then
        Roact.unmount(game_handle)
    end
end




return Game