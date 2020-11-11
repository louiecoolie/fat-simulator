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

local Wheat = Roact.Component:extend("Wheat")

local game_handle = nil
local game_start = false
local groupMotor

local wheat_params = {
    dampingRatio = 1;
    frequency = 4;
}

local WheatGame = {}

function Wheat:init()
    self.sickle = Roact.createRef()
    self.progress_ref = Roact.createRef()
    self.wheat_ref = Roact.createRef()
    self.count_ref = Roact.createRef()

    self.max_wheat = 5
    --self.current_wheat = 0
    self.current_wheat, self.updateWheat = Roact.createBinding(0)
    self.tool_image = "rbxassetid://5674423016"
    self.progress_image = ""

    self.swing, self.updateSwing = Roact.createBinding(false)

    self.game_complete, self.updateGame = Roact.createBinding(false)
end

function Wheat:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(0.304,0,0.297,0),
            Position = UDim2.new(0.347,0,0.13,0),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            BackgroundTransparency = 1,
            ZIndex = 0
        },{
            Visual = Roact.createElement("ImageButton",{
                [Roact.Ref] = self.sickle,
                Image = "rbxassetid://5854333505",
                Size = UDim2.new(0.35, 0,0.357, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.272, 0,0.217, 0),
                ZIndex = 5,
                [Roact.Event.MouseButton1Click] = function(rbx)
                
                    
                        if self.swing:getValue() == false then
                            if groupMotor then groupMotor:stop() end

                            groupMotor = Otter.createGroupMotor({
                                position_x = 0.272,
                                position_y = 0.217,
                                rotation = 0,
                                transparency = 0
                            })

                            groupMotor:setGoal({
                                position_x = Otter.spring(0.21,wheat_params),
                                position_y = Otter.spring(0.573,wheat_params),
                                rotation = Otter.spring(-90,wheat_params),
                                transparency = Otter.spring(1,wheat_params),
                            })


                            groupMotor:onStep(function(values)
                                self.sickle:getValue().Position = UDim2.new(values.position_x, 0, values.position_y, 0)
                                self.sickle:getValue().Rotation = values.rotation
                                self.wheat_ref:getValue().ImageTransparency = values.transparency
                     
                            end)



                            if self.current_wheat:getValue() < self.max_wheat then
                                self.updateWheat(self.current_wheat:getValue() + 1)
                                self.count_ref:getValue().Text = self.current_wheat:getValue()
                            end
                            
                    

                            if self.current_wheat:getValue() >= self.max_wheat then
                                if self.game_complete:getValue() == false then
                                    self.updateGame(true)
                                    Events["game_complete"]:FireServer(script.Name)
                                end
        
                            end

                            self.updateSwing(true)
                        elseif self.swing:getValue() == true then
                            if groupMotor then groupMotor:stop() end

                            groupMotor = Otter.createGroupMotor({
                                position_x = 0.21,
                                position_y = 0.573,
                                rotation = -90,
                                transparency = 1,
                            })

                            groupMotor:setGoal({
                                position_x = Otter.spring(0.272,wheat_params),
                                position_y = Otter.spring(0.217,wheat_params),
                                rotation = Otter.spring(0,wheat_params),
                                transparency = Otter.spring(0, wheat_params),

                            })


                            groupMotor:onStep(function(values)
                                self.sickle:getValue().Position = UDim2.new(values.position_x, 0, values.position_y, 0)
                                self.sickle:getValue().Rotation = values.rotation
                                self.wheat_ref:getValue().ImageTransparency = values.transparency
                            end)

                            self.updateSwing(false)

                        end


                end
            }),
            Bag = Roact.createElement("ImageLabel",{
                Image = "rbxassetid://5854333354",
                Size = UDim2.new(0.307, 0, 0.29,0),
                Position = UDim2.new(0.641, 0, 0.655,0),
                ZIndex = 5,
                BackgroundTransparency = 1,
            }),
            ProgressText = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.count_ref,
                Size = UDim2.new(0.307, 0, 0.29,0),
                Position = UDim2.new(0.641, 0, 0.655,0),
                ZIndex = 6,
                Text = 0,
                BackgroundTransparency = 1,
            }),
            Background = Roact.createElement("ImageLabel",{
                Image = "rbxassetid://5854333440",
                Size = UDim2.new(1, 0, 1,0),
                Position = UDim2.new(0, 0, 0,0),
                ZIndex = 4,
                BackgroundTransparency = 1,
            }),
            Wheat = Roact.createElement("ImageLabel",{
                [Roact.Ref] = self.wheat_ref,
                Image = "rbxassetid://5854333585",
                Size = UDim2.new(0.472, 0, 0.291,0),
                Position = UDim2.new(0.088, 0, 0.493,0),
                ZIndex = 5,
                ImageTransparency = 0,
                BackgroundTransparency = 1,
            }),
            Text = Roact.createElement("TextLabel",{
                Text = "Press the sickle to harvest!",
                Size = UDim2.new(0.389, 0, 0.2,0),
                Position = UDim2.new(0.597, 0, 0.068,0),
                TextScaled = true,
                TextWrapped = true,
                BackgroundTransparency = 3,
                ZIndex = 5,
                Font = Enum.Font.PermanentMarker,
            })
        })

    })
end



function WheatGame.Start()
    if game_start == false then

        game_handle = Roact.mount(Roact.createElement(Wheat), PlayerGui, "Wheat Game")
        game_start = true
    end
end

function WheatGame.Stop()
    if groupMotor then groupMotor:stop() end
    
    if game_handle then
        Roact.unmount(game_handle)
    end
end

Events["reset_request"].OnClientEvent:Connect(function()
    game_start = false
end)

return WheatGame