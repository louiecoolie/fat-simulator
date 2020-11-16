local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))


local spring = Otter.spring
local motor = Otter.createSingleMotor

local Players = game:GetService("Players")
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)
local TweenService = game:GetService("TweenService")

local Events = {}
local Modules = {}

local fatness = 1

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end



local module = {}


function module.Grow()
    Events["grow_request"]:FireServer()
end

function module.Touch(interactable)
    print(interactable)
    Events["interaction_request"]:FireServer(interactable)
end

function module.Proximity(interactable)
    print(interactable)
    Events["interaction_request"]:FireServer(interactable)
end

return module