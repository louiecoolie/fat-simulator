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

local Tie_Win_Modal = Roact.Component:extend("TieWinModal")

local game_handle = nil

local TieWinModal = {}



function Tie_Win_Modal:init()

    self.default_size = UDim2.new(0,200,0,200)
    self.default_offset = UDim2.new(0.5, -100, 0.5, -100)

    self.text_size = UDim2.new(0, 100, 0, 50)
    self.text_offset = UDim2.new(0.5, -50, 0.5, -25)

end

function Tie_Win_Modal:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = self.default_size,
            Position = self.default_offset
        },{
            Message = Roact.createElement("TextLabel", {
                Text = "Tie wins",
                Size = self.text_size,
                Position = self.text_offset
            },{})


        })

    })
end


function Tie_Win_Modal:didMount()
    local make_linter_happy = true
end



function TieWinModal.Activate()
  
    game_handle = Roact.mount(Roact.createElement(Tie_Win_Modal), PlayerGui, "Tie Win Modal")
    wait(2)
    Roact.unmount(game_handle)
end




return TieWinModal