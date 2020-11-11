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
    if kick_player then
        return Roact.createElement("ScreenGui",{},{
            Frame = Roact.createElement("ImageLabel",{
                [Roact.Ref] = self.fade_frame,
                Size = UDim2.new(1,0,1,0),
                ZIndex = 1001,
                BackgroundColor = BrickColor.new("Really black"),
                Image = "rbxassetid://5721378211",
                Transparency = 1
            },{
                Message = Roact.createElement("TextLabel",{
                    Size = UDim2.new(0.5,0,0.2,0),
                    Position = UDim2.new(0.25, 0, 0.3, 0),
                    ZIndex = 1002,
                    BorderSizePixel = 0,
                    TextSize = 20,
                    BackgroundTransparency = 1,
                    Text = self.message_text
                }),
                Player = Roact.createElement("ViewportFrame",{
                    [Roact.Ref] = self.player_frame,
                    Size = UDim2.new(0.15,0,0.198,0),
                    Position = UDim2.new(0.05,0,.2,0),
                    ZIndex = 1003,
                    CurrentCamera = ViewportCamera
                },{
                    Model = Roact.createElement("Model",{},{
                        Body = Roact.createElement("Part",{
                            Size = workspace:FindFirstChild(kick_player):FindFirstChild("Torso").Size,
                            Color = workspace:FindFirstChild(kick_player):FindFirstChild("Torso").Color,
                            Material = workspace:FindFirstChild(kick_player):FindFirstChild("Torso").Material,
                            Position = Vector3.new(0,2,0)
                        }),
                        LeftFoot = Roact.createElement("Part",{
                            Size = workspace:FindFirstChild(kick_player):FindFirstChild("Left Foot").Size,
                            Color = workspace:FindFirstChild(kick_player):FindFirstChild("Left Foot").Color,
                            Material = workspace:FindFirstChild(kick_player):FindFirstChild("Left Foot").Material,
                            Position = Vector3.new(0.5,0,0)
                        }),
                        RightFoot = Roact.createElement("Part",{
                            Size = workspace:FindFirstChild(kick_player):FindFirstChild("Right Foot").Size,
                            Color = workspace:FindFirstChild(kick_player):FindFirstChild("Right Foot").Color,
                            Material = workspace:FindFirstChild(kick_player):FindFirstChild("Right Foot").Material,
                            Position = Vector3.new(-0.5,0,0)
                        }),
                        Face = Roact.createElement("Part",{
                            Size = workspace:FindFirstChild(kick_player):FindFirstChild("Part").Size,
                            Color = workspace:FindFirstChild(kick_player):FindFirstChild("Part").Color,
                            Material = workspace:FindFirstChild(kick_player):FindFirstChild("Part").Material,
                            Position = Vector3.new(0,2.4,-0.6)
                        })
                    })
                })
            })
        })
    else
        return Roact.createElement("ScreenGui",{},{
            Frame = Roact.createElement("ImageLabel",{
                [Roact.Ref] = self.fade_frame,
                Size = UDim2.new(1,0,1,0),
                ZIndex = 1001,
                BackgroundColor = BrickColor.new("Really black"),
                Image = "rbxassetid://5721378211",
                Transparency = 1
            },{
                Message = Roact.createElement("TextLabel",{
                    Size = UDim2.new(0.5,0,0.2,0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    ZIndex = 1002,
                    BorderSizePixel = 0,
                    TextSize = 20,
                    BackgroundTransparency = 1,
                    Text = self.message_text
                })
            })
        })
    end
end

function KickScreen:didMount()
--self.fade_frame:getValue().Transparency = 0

    local tweeninfo = TweenInfo.new(1)
    local fade_tween = TweenService:Create( self.fade_frame:getValue(), tweeninfo, {Transparency = 0})
    
    fade_tween:Play()
    wait(1)
    if kick_player then
        local Y = 0

        for i = 0.1, 1, 0.1 do
            Y = 1.8*i^2 -(1.2*i) + 0.3
            print(i, Y)
            local TweenInfo = TweenInfo.new(0.1)
            local PlayerTween = TweenService:Create(self.player_frame:getValue(), TweenInfo, {Position = UDim2.new(i,0,Y,0)})
            PlayerTween:Play()
            wait(0.05)
        end

        --local XVal, YVal = Instance.new("NumberValue"), Instance.new("NumberValue")

       -- local XInfo, YInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), 
        --TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        
       -- local XTween, YTween = TweenService:Create(XVal, XInfo, {Value = .7}), 
        --TweenService:Create(YVal, YInfo, {Value = 1.5})

        --XVal:GetPropertyChangedSignal("Value"):Connect(function() -- There are better ways to do this 
            --self.player_frame:getValue().Position = UDim2.new(self.player_frame:getValue().Position.X + XVal.Value,0 , YVal.Value,0 )
        --end)
        
        --XTween:Play(); YTween:Play()

        if vote_type == "imposter" then
            local Message = (kick_player .. " was the imposter")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.2)
            end
        elseif vote_type == "innocent" then
            local Message = (kick_player .. " was not the imposter")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.2)
            end
        end
    else
        if vote_type == "tie" then
            local Message = ("No one kicked, tie")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.2)
            end
        elseif vote_type == "skip" then
            local Message = ("No one kicked, skip")
            for i = 1, #Message do
                self.updateText(string.sub(Message, 1, i))
                wait(.2)
            end
        end
    end
end

function KickScreen:willUnmount()
    local tweeninfo = TweenInfo.new(0.1)
    local fade_tween = TweenService:Create( self.fade_frame:getValue(), tweeninfo, {Transparency = 1})
    
    fade_tween:Play()
    wait(0.1)
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
            print("no vote skipping")
            vote_type = "skip"
        end
    elseif player then
        kick_player = player
        if type == "imposter" then
            print(player, " was the imposter")
            vote_type = "imposter"
        elseif type == "innocent" then
            print(player, " was not an imposter")
            vote_type = "innocent"
        end
    end
    
    game_handle = Roact.mount(Roact.createElement(KickScreen), PlayerGui, "Kickout")
end

function Kick.Stop()
    Roact.unmount(game_handle)
end


return Kick