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

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 30)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end

local PlayerGui = Players.LocalPlayer.PlayerGui

local Emergency = Roact.Component:extend("Emergency")

local game_handle = nil
local game_start = false
local game_door = nil

local wheel_spring_params = {
    dampingRatio = 1;
    frequency = 4;
}

local EmergencyGame = {}


local camera : Camera = workspace.CurrentCamera
local function updatePointerLocation(obj, location, delta)
    local cameraSpaceLocation, withinBounds = camera:WorldToScreenPoint(location)
    obj.Visible = withinBounds

    local pixelYOffset = 64
    local amplitude = 16
    local offset = pixelYOffset + amplitude*math.sin(tick()*2*math.pi)

    -- update Position
    obj.Position = UDim2.new(0, cameraSpaceLocation.X, 0, cameraSpaceLocation.Y - offset)
end


function Emergency:init()
    self.emergency_ref = Roact.createRef()

end

function Emergency:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            [Roact.Ref] = self.emergency_ref,
            Size = UDim2.new(0.4,0,0.4,0),
            Position = UDim2.new(0.3,0,0.3,0)
        },{
            Visual = Roact.createElement("TextButton",{
                Size = UDim2.new(0.8,0,0.8,0),
                Position = UDim2.new(0.1,0,0.1,0),
                [Roact.Event.MouseButton1Click] = function(rbx)
            
                    print("emergency meeting!")
                    EmergencyGame.Stop()
                end
        
            }),
        })

    })
end

function Emergency:didMount()
    print("mounted")
end

function EmergencyGame.Start(emergency_model)

    if game_start == false then

        game_handle = Roact.mount(Roact.createElement(Emergency), PlayerGui, "Emergency Game")
        game_start = true
    end
end

function EmergencyGame.Stop()
    if game_handle then
        Roact.unmount(game_handle)
        game_start = false
    end
end

Events["reset_request"].OnClientEvent:Connect(function()
    game_start = false
end)

return EmergencyGame