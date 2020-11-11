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

local Imposter_Modal = Roact.Component:extend("ImposterModal")

local game_handle = nil

local ImposterModal = {}



function Imposter_Modal:init()

    self.default_size = UDim2.new(1,0,1,0)
    self.default_offset = UDim2.new(0, 0, 0, 0)

    self.text_size = UDim2.new(.5, 0, .25,0)
    self.text_offset = UDim2.new(0.25, 0, 0.125, 0)

    self.messageref = Roact.createRef()
    self.leftscroll = Roact.createRef()
    self.rightscroll = Roact.createRef()
    self.parchmentref = Roact.createRef()
    self.parchmentsize = Roact.createRef()
    self.parchmenttext = Roact.createRef() 
    self.imagesize = Roact.createRef()
    self.textsize = Roact.createRef()
    self.parchmentimage = Roact.createRef()
end

function Imposter_Modal:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("ImageLabel",{
            [Roact.Ref] = self.messageref,
            Size = self.default_size,
            Position = self.default_offset,
            Image = "rbxassetid://5772170943",
            BorderSizePixel = 0,
            Transparency = 1,
            ZIndex = 1040,
        },{
            ScrollLeft = Roact.createElement("ImageLabel", {
                [Roact.Ref] = self.leftscroll,
                Size = UDim2.new(0.1,0,.8,0),
                Position = UDim2.new(0.375,0, 0.10,0),
                Image = "rbxassetid://5825881839",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 1050,
            }),
            ScrollRight = Roact.createElement("ImageLabel", {
                [Roact.Ref] = self.rightscroll,
                Size = UDim2.new(0.1,0,.8,0),
                Position = UDim2.new(0.475,0, 0.10,0),
                Image = "rbxassetid://5825881839",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 1050,
            }),


            ParchmentMax = Roact.createElement("Frame",{
                [Roact.Ref] = self.parchmentsize,
                Size = UDim2.new(0.8,0, 0.5,0),
                Position = UDim2.new(0.05,0, 0.25, 0),
                Transparency = 1,
            },{
                ImageMax = Roact.createElement("Frame",{
                    [Roact.Ref] = self.imagesize,
                    Size = UDim2.new(0.2,0,0.2,0),
                    Position = UDim2.new(0.05,0, 0.25, 0),
                    Transparency = 1,
                    SizeConstraint = Enum.SizeConstraint.RelativeXX,
                }),
                TextMax = Roact.createElement("Frame",{
                    [Roact.Ref] = self.textsize,
                    Size = UDim2.new(0.4,0,1,0),
                    Position = UDim2.new(0.05,0, 0.25, 0),
                    Transparency = 1,
                    --SizeConstraint = Enum.SizeConstraint.RelativeXX,
                })
            }),
            
            Parchment = Roact.createElement("Frame", {
                [Roact.Ref] = self.parchmentref,
                Size = UDim2.new(0.1,0,.5,0),
                Position = UDim2.new(0.475,0, 0.25,0),
                ClipsDescendants = true,
                ZIndex = 1049,
            },{
                Message = Roact.createElement("TextLabel", {
                    [Roact.Ref] = self.parchmenttext,
                    Text = "The knights have been defeated, spy clan wins",
                    Size = UDim2.new(0.8,0,1,0),
                   -- Size = self.parchmentsize:getValue().Size,
                    TextScaled = true,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(240, 250, 250),
                    --SizeConstraint = Enum.SizeConstraint.RelativeXX,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.4,0,0,0),
                    ZIndex = 1050,
                }),
                Image = Roact.createElement("ImageLabel", {
                    [Roact.Ref] = self.parchmentimage,
                    Image = "rbxassetid://5772171146",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    SizeConstraint = Enum.SizeConstraint.RelativeXX,
                    BorderSizePixel = 0,
                    ZIndex = 1050,
                    Size = UDim2.new(0.2,0,0.2,0),
                    Position = UDim2.new(0.15, 0, 0,0),
    
                })
            })
        })
    })
end


function Imposter_Modal:didMount()
    self.parchmenttext:getValue().Size = UDim2.new(0, self.textsize:getValue().AbsoluteSize.X, 0, self.textsize:getValue().AbsoluteSize.Y)
    self.parchmentimage:getValue().Size = UDim2.new(0, self.imagesize:getValue().AbsoluteSize.X, 0, self.imagesize:getValue().AbsoluteSize.Y)

    local groupMotor = Otter.createGroupMotor({
        left_x = 0.375,
        right_x = 0.475,
        parchsize_x = 0.1,
    })
    local singleMotor = Otter.createSingleMotor(1)
    singleMotor:setGoal(Otter.spring(0))


    singleMotor:onStep(function(transparency)
        self.messageref:getValue().Transparency = transparency
    end)


    groupMotor:setGoal({
        left_x = Otter.spring(0.05),
        right_x = Otter.spring(0.85),
        parchsize_x = Otter.spring(0.80)

    })

    groupMotor:onStep(function(values)
 
        self.rightscroll:getValue().Position = UDim2.new(values.left_x, 0, 0.10, 0)

        self.leftscroll:getValue().Position = UDim2.new(values.right_x, 0, 0.10, 0)
        self.parchmentref:getValue().Size = UDim2.new(values.parchsize_x, 0, 0.5,0)
        self.parchmentref:getValue().Position = UDim2.new(values.left_x, 0, 0.25, 0)
        -- position something somewhere
    end)



 
end



function ImposterModal.Activate()
   
    game_handle = Roact.mount(Roact.createElement(Imposter_Modal), PlayerGui, "Imposter Modal")
 

end

function ImposterModal.Deactivate()

    Roact.unmount(game_handle)

end


return ImposterModal