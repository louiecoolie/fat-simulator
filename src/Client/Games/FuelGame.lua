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

local Interface = Roact.Component:extend("Hunt")

local game_handle = nil
local game_start = false
local game_connections = {}

local wheel_spring_params = {
    dampingRatio = 1;
    frequency = 4;
}

local Game = {}

function Interface:init()
    self.status_ref = Roact.createRef()
    self.score_ref = Roact.createRef()
    self.tutorial_ref = Roact.createRef()

    self.score, self.updateScore = Roact.createBinding(0)
end

function Interface:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(1,0,1,0),
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            ZIndex = 1
        },{
            Status = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.status_ref,
                Size = UDim2.new(0.2,0,0.1,0),
                Position = UDim2.new(0.6,0,.9,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 31,
                --Transparency = 1,
                BorderSizePixel = 0,
                Text = "Shovelled"
            }),
            Score = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.score_ref,
                Size = UDim2.new(0.2,0,0.1,0),
                Position = UDim2.new(0.8,0,.9,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 32,
                --Transparency = 1,
                BorderSizePixel = 0,
                Text = self.score:getValue()
            }),
            Tutorial = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.tutorial_ref,
                Size = UDim2.new(0.3,0,0.1,0),
                Position = UDim2.new(0.6,0,.1,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 31,
                --Transparency = 1,
                BorderSizePixel = 0,
                Text = "Click/press on a coal to shovel!"
            }),


        })
    })
end

function Interface:didMount()
    local score = self.score_ref:getValue()
    Modules["Generate"].GameAsset("Rock", script.Name, 5)
    game_connections.MouseScan = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
  
            local scan = Modules["Tool"].PlayMouse(input)
   
    
            if scan and scan.Name == "Rock" then
                scan:Destroy()
                
                self.updateScore(self.score:getValue() + 1)
                score.Text = 0 + self.score:getValue()

                if self.score:getValue() >= 5 then
                    Events["game_complete"]:FireServer(script.Name)
                end
            end


        end
    end)
    game_connections.MobileScan = UserInputService.TouchTap:Connect(function(input)
            local scan = Modules["Tool"].PlayMobile(input)
   
            if scan and scan.Name == "Rock" then
                scan:Destroy()
                
                self.updateScore(self.score:getValue() + 1)
                score.Text = 0 + self.score:getValue()

                if self.score:getValue() >= 5 then
                    Events["game_complete"]:FireServer(script.Name)
                end
            end
    end)
end

function Game.Start()
    if game_start == false then


        game_handle = Roact.mount(Roact.createElement(Interface), PlayerGui, "Fuel Interface")
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


Events["reset_request"].OnClientEvent:Connect(function()
    game_start = false
end)

return Game