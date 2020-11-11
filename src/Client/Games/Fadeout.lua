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

local Fade = Roact.Component:extend("Fade")

local game_handle = nil
local game_start = false


local Fadeout = {}

function Fade:init()
    self.fade_frame = Roact.createRef()
end

function Fade:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Frame = Roact.createElement("Frame",{
            [Roact.Ref] = self.fade_frame,
            Size = UDim2.new(1,0,1,0),
            ZIndex = 1000,
            BackgroundColor = BrickColor.new("Really black"),
            Transparency = 1
        })
    })
end

function Fade:didMount()
    --self.fade_frame:getValue().Transparency = 0

        local tweeninfo = TweenInfo.new(1)
        local fade_tween = TweenService:Create( self.fade_frame:getValue(), tweeninfo, {Transparency = 0})
     
        fade_tween:Play()



end

function Fade:willUnmount()
    local tweeninfo = TweenInfo.new(1)
    local fade_tween = TweenService:Create( self.fade_frame:getValue(), tweeninfo, {Transparency = 1})
    
    fade_tween:Play()
    wait(1)
end

function Fadeout.Start()
    game_handle = Roact.mount(Roact.createElement(Fade), PlayerGui, "Fadeout")
end

function Fadeout.Stop()
    Roact.unmount(game_handle)
end


return Fadeout