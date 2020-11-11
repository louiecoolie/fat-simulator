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
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end

local PlayerGui = Players.LocalPlayer.PlayerGui

local Wifi = Roact.Component:extend("Wifi")

local game_handle = nil
local game_start = false

local wheel_spring_params = {
    dampingRatio = 1;
    frequency = 4;
}

local WifiGame = {}

function Wifi:init()

    self.progress_ref = Roact.createRef()
    self.max_pressure = 10

    self.wheel_motor = motor(0)                             -- rotation of wheel
    self.wheel_spring = spring(0, wheel_spring_params)      -- spring to control rotation of wheel

    self.wheel_image = "rbxassetid://5674423016"

    self.default_size = UDim2.new(0,200,0,200)
    self.default_offset = UDim2.new(0.5, -100, 0.5, -100)

    self.visual_size = UDim2.new(0,100,0,100)
    self.visual_offset = UDim2.new(0.25, -25, 0.5, -50)

    self.progress_size = UDim2.new(0, 25, 0, 100)
    self.progress_offset = UDim2.new(.75,0,.5,-50)

    self.game_complete, self.updateGame = Roact.createBinding(false)

    self.turn_state, self.updateTurn = Roact.createBinding(0) -- rotation
    self.wheel_motor:onStep(function(val)
    
        self.updateTurn(val)
    end)

    self.water_pressure, self.updatePressure = Roact.createBinding(0)
    self.progress, self.updateProgress = Roact.createBinding(UDim2.new(1,0,self.water_pressure:getValue()/self.max_pressure,0))

end

function Wifi:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = self.default_size,
            Position = self.default_offset
        },{
            Visual = Roact.createElement("ImageButton",{
                Image = self.wheel_image,
                Rotation = self.turn_state,
                Size = self.visual_size,
                Position = self.visual_offset,
                [Roact.Event.MouseButton1Click] = function(rbx)
            

                    self.wheel_spring.__goalPosition  += (360/self.max_pressure)
                    self.wheel_motor:setGoal(self.wheel_spring)

                    if self.water_pressure:getValue() < self.max_pressure then
                        self.updatePressure(self.water_pressure:getValue() + 1)
                    end
                    
                    if self.water_pressure:getValue() >= self.max_pressure then
                        if self.game_complete:getValue() == false then
                            self.updateGame(true)
                            Events["game_complete"]:FireServer(script.Name)
                        end

                    end

                    local tweeninfo = TweenInfo.new(1)
                    local progress_tween = TweenService:Create(self.progress_ref:getValue(), tweeninfo, {Size = UDim2.new(1,0,self.water_pressure:getValue()/self.max_pressure,0)})
                 
                    progress_tween:Play()
                    wait(1)
                    self.updateProgress(UDim2.new(1,0,self.water_pressure:getValue()/self.max_pressure,0))
                end
        
            }),
            ProgressContainer = Roact.createElement("Frame",{
                Size = self.progress_size,
                Position = self.progress_offset
            },{
                Progress = Roact.createElement("Frame",{
                    [Roact.Ref] = self.progress_ref,
                    Size = self.progress,
                    BackgroundColor3 = Color3.fromRGB(105, 112, 219),
                    ZIndex = 10
                },{})
            })


        })

    })
end

function Wifi:didMount()
    print("mounted")
end

function WifiGame.Start()
    if game_start == false then

        print("Started game!")
        game_handle = Roact.mount(Roact.createElement(Wifi), PlayerGui, "Wifi Game")
        game_start = true
    end
end

function WifiGame.Stop()
    if game_handle then
        Roact.unmount(game_handle)
    end
end


Events["reset_request"].OnClientEvent:Connect(function()
    game_start = false
end)

return WifiGame