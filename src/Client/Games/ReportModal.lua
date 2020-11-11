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

local Report_Modal = Roact.Component:extend("ReportModal")

local game_handle = nil
local message

local ReportModal = {}



function Report_Modal:init()

    self.default_size = UDim2.new(1,0,1,0)
    self.default_offset = UDim2.new(0,0,0,0)

    self.text_size = UDim2.new(.8, 0, 0.3, 0)
    self.text_offset = UDim2.new(0.2, 0, 0.3, 0)

end

function Report_Modal:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = self.default_size,
            Position = self.default_offset,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        },{
            Message = Roact.createElement("TextLabel", {
                Text = message,
                Size = self.text_size,
                Position = self.text_offset,
                TextScaled = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                TextColor3 = Color3.fromRGB(240, 250, 250),
            },{})


        })

    })
end


function ReportModal:didMount()
    local make_linter_happy = true
end



function ReportModal.Activate(type)
    if type == "Emergency" then
        message = "Emergency meeting!"
    elseif type == "Murder" then
        message = "Dead body reported!"
    end

    game_handle = Roact.mount(Roact.createElement(Report_Modal), PlayerGui, "Report Modal")
    wait(2)
    Roact.unmount(game_handle)
end





return ReportModal