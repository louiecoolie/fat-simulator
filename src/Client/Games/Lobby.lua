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

local LobbyGUI = Roact.Component:extend("Lobby")


local ViewportCamera = Instance.new("Camera")
ViewportCamera.CFrame = CFrame.new(0,2,-4)
ViewportCamera.CFrame = CFrame.new(Vector3.new(0,2,-4), Vector3.new(0,2,0))

local game_handle = nil
local game_start = false
local kick_player
local vote_type
local default_lobby = "Game"
local lobby_connection

local Lobby = {}

function LobbyGUI:init()
    self.fade_frame = Roact.createRef()
    self.lobby_ref = Roact.createRef()
    self.player_frame = Roact.createRef()
    self.message_text, self.updateText = Roact.createBinding("")
end

function LobbyGUI:render()

    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Frame = Roact.createElement("Frame",{
            [Roact.Ref] = self.fade_frame,
            Size = UDim2.new(1,0,1,0),
            ZIndex = 1001,
            Transparency = 1
        },{
            Message = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.lobby_ref,
                Size = UDim2.new(0.5,0,0.2,0),
                Position = UDim2.new(0.25, 0, 0.1, 0),
                ZIndex = 1002,
                BorderSizePixel = 0,
                TextSize = 20,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 1,
                Text = default_lobby
            })
        })
    })

end

function LobbyGUI:didMount()
--self.fade_frame:getValue().Transparency = 0
    lobby_connection = Events["lobby_update"].OnClientEvent:Connect(function(update)
        self.lobby_ref:getValue().Text = (default_lobby .. " " .. update)
    end)
end

function LobbyGUI:willUnmount()
   
end

function Lobby.Start()

    
    game_handle = Roact.mount(Roact.createElement(LobbyGUI), PlayerGui, "Lobby GUI")
end

function Lobby.Stop()
    lobby_connection:Disconnect()
    Roact.unmount(game_handle)
end


Events["lobby_update"].OnClientEvent:Connect(function(update)
    if update == "begin" then
        wait(5)
        Lobby.Stop()
    end
end)

return Lobby