--[[
    Pipe game will use mouse or tap input to spin a turn wheel to rise water pressure back up to 100%

    Upon completion of the game this component will self destruct and send out completion confirmation back into server and delete
    game binder off the corressponding object in world.
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
local TweenService = game:GetService("TweenService")

local Events = {}
local Modules = {}

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

local PlayerGui = Players.LocalPlayer.PlayerGui

local Interface = Roact.Component:extend("Shop")

local game_handle = nil
local game_start = false
local game_connections = {}

local wheel_spring_params = {
    dampingRatio = 1;
    frequency = 4;
}

local Game = {}

function Interface:init()
 
end

function Interface:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(0.5,0,0.5,0),
            Position = UDim2.new(0.25,0,0.25,0),
            BackgroundTransparency = 0.9,
            ZIndex = 1
        },{


        })
    })
end

function Interface:didMount()

end

function Game.Start(cost_table, store)

    if game_start == false then


        game_handle = Roact.mount(Roact.createElement(Interface), PlayerGui, "Shop Interface")
        game_start = true
    end
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