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

local KickScreen = Roact.Component:extend("Kick")


local ViewportCamera = Instance.new("Camera")
ViewportCamera.CFrame = CFrame.new(0,2,-4)
ViewportCamera.CFrame = CFrame.new(Vector3.new(0,2,-4), Vector3.new(0,2,0))

local game_handle = nil
local game_start = false
local kick_player
local vote_type

local Kick = {}

function KickScreen:init()
    self.fade_frame = Roact.createRef()
    self.player_frame = Roact.createRef()
    self.message_text, self.updateText = Roact.createBinding("")
end

function KickScreen:render()

    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Message = Roact.createElement("TextLabel",{
            Size = UDim2.new(0.5,0,0.2,0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            ZIndex = 1002,
            BorderSizePixel = 0,
            TextSize = 20,
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = self.message_text
        })
    })

end

function KickScreen:didMount()
--self.fade_frame:getValue().Transparency = 0

    spawn(function()
        if vote_type == "imposter" then
            local Message = (kick_player .. " was the spy")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.1)
            end
        elseif vote_type == "innocent" then
            local Message = (kick_player .. " was not the spy")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.1)
            end
        end
    
        if vote_type == "tie" then
            local Message = ("No one kicked, tie")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.1)
            end
        elseif vote_type == "skip" then
            local Message = ("No one kicked, skip")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.1)
            end
        end
    end)
end

function KickScreen:willUnmount()

end

function Kick.Start(player, type)
    print(player, type)
    if player == nil then
        kick_player = nil
        if type == "tie" then
            print("tie")
            vote_type = "tie"
        elseif type == "skip" then
            print("skip")
            vote_type = "skip"
        elseif type == "innocent" then
            print("no vote (skipping)")
            vote_type = "skip"
        end
    elseif player then
        kick_player = player
        if type == "imposter" then
            print(player, " was the spy")
            vote_type = "imposter"
        elseif type == "innocent" then
            print(player, " was not a spy")
            vote_type = "innocent"
        end
    end
    
    game_handle = Roact.mount(Roact.createElement(KickScreen), PlayerGui, "Kickout")
end

function Kick.Stop()
    Roact.unmount(game_handle)
end


return Kick