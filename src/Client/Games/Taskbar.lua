--[[
    Pipe game will use mouse or tap input to spin a turn wheel to rise water pressure back up to 100%

    Upon completion of the game this component will self destruct and send out completion confirmation back into server and delete
    game binder off the corressponding object in world.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))

local spring = Otter.spring
local motor = Otter.createSingleMotor

local Players = game:GetService("Players")
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)
local TweenService = game:GetService("TweenService")

local Events = {}
local Connections = {}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end

local PlayerGui = Players.LocalPlayer.PlayerGui

local Bar = Roact.Component:extend("Bar")

local game_handle = nil
local game_start = false
local game_connections = {}

local total_tasks = 0
local completed_tasks = 0
local groupMotor

local Taskbar = {}

function Bar:init()
    self.progress = Roact.createRef()

end

function Bar:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(0.4,0,0.05,0),
           -- SizeConstraint = Enum.SizeConstraint.RelativeXX,
            Position = UDim2.new(0.05,0,0.05,0),
            ZIndex = 1030,
            BorderSizePixel = 2,
            BackgroundTransparency = 1,
            ClipsDescendants = true
        },{
            Progress = Roact.createElement("Frame",{
                [Roact.Ref] = self.progress,
                Position = UDim2.new(0,0,0,0),
                ZIndex = 1030,
                BorderSizePixel = 0,
                BackgroundTransparency = 0,
                Size = UDim2.new(0,0,1,0),
            })
        }),
    })
end

function Bar:didMount()

    groupMotor = Otter.createGroupMotor({
        bar_x = 0
    })
    game_connections.UpdateTime = Events["task_completed"].OnClientEvent:Connect(function(tasksCompleted, totalTasks)
        completed_tasks = tasksCompleted
        total_tasks = totalTasks
        groupMotor:setGoal({
            bar_x = Otter.spring(completed_tasks/total_tasks)
        })
    end)

    groupMotor:onStep(function(values)
        self.progress:getValue().Size = UDim2.new(values.bar_x, 0, 1, 0)
    end)

end

function Bar:willUnmount()
    groupMotor:stop()
    game_connections.UpdateTime:Disconnect()
    --wait(2.1)
end

function Taskbar.Start(tasks)
    completed_tasks = 0
    game_handle = Roact.mount(Roact.createElement(Bar), PlayerGui, "Bar UI")
end

function Taskbar.Stop()
    Roact.unmount(game_handle)
end

return Taskbar