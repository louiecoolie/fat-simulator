--[[
    Pipe game will use mouse or tap input to spin a turn wheel to rise water pressure back up to 100%

    Upon completion of the game this component will self destruct and send out completion confirmation back into server and delete
    game binder off the corressponding object in world.
]]





local Roact = require(game:GetService("ReplicatedStorage"):WaitForChild("Roact"))
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

local CompleteModal = Roact.Component:extend("Complete")

local game_handle = nil

local Complete = {}



function CompleteModal:init()

    self.default_size = UDim2.new(0,200,0,200)
    self.default_offset = UDim2.new(0.5, -100, 0.5, -100)

    self.text_size = UDim2.new(0, 100, 0, 50)
    self.text_offset = UDim2.new(0.5, -50, 0.5, -25)

end

function CompleteModal:render()
    return Roact.createElement("ScreenGui",{},{
        Container = Roact.createElement("Frame",{
            Size = self.default_size,
            Position = self.default_offset
        },{
            Message = Roact.createElement("TextLabel", {
                Text = "Task completed!",
                Size = self.text_size,
                Position = self.text_offset
            },{})


        })

    })
end


function CompleteModal:didMount()
   -- print("mounted")
end



function Complete.Activate()
    print("Completed Game!")
    game_handle = Roact.mount(Roact.createElement(CompleteModal), PlayerGui, "Completion Modal")
    wait(2)
    Roact.unmount(game_handle)
end




return Complete