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

local ImposterList = Roact.Component:extend("Imposter Tasks")

local game_handle = nil
local game_start = false
local game_text = ""

local task_count = 0
local game_tasks = {
    Layout = Roact.createElement("UIListLayout",{
        SortOrder = Enum.SortOrder.LayoutOrder
    }),
}

local game_refs = {

}

local timer = nil

local ImposterTask = {}


local function create_task(properties)
    local task = properties.task

    task_count += 1
 
    return Roact.createElement("TextLabel",  {
            [Roact.Ref] = properties.ref,
            Text = task,
            TextWrapped = true,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(.8,0,0.5,0),
            TextColor3 = Color3.fromRGB(226, 226, 29),
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextScaled = true,
            LayoutOrder = task_count,
            Position = UDim2.new(0,0,-0.3,40),
            ZIndex = 6
        },
    {})
end

function ImposterList:init()

    self.refs = game_refs
    self.default_size = UDim2.new(0.2,0,0.2,0)
    self.default_offset = UDim2.new(0.05, 0, 0.15, 0)



end

function ImposterList:render()
    return Roact.createElement("ScreenGui",{
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = self.default_size,
            Position = self.default_offset,
            BackgroundTransparency = 1,
            ZIndex = 300
        },

            game_tasks
        )
    })
        
end

function ImposterList:didMount()

    timer = Events["sabotage_timer"].OnClientEvent:Connect(function(timer_update)
        print(self.refs[game_text]:getValue().Text)
        self.refs[game_text]:getValue().Text = (game_text .. " " .. timer_update)
    end)
    for _, ref in pairs(self.refs) do
        print (ref:getValue().Size)
    end

end

function ImposterList:willUnmount()

    timer:Disconnect()
    
end

function ImposterTask.Start(imposter_task)
    game_tasks = nil
    game_tasks = {
        Layout = Roact.createElement("UIListLayout",{
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
    }


    game_refs[imposter_task] = Roact.createRef()
    game_tasks[imposter_task] = Roact.createElement(create_task, {
        task = imposter_task,
        ref = game_refs[imposter_task]
    })


   
    game_text = imposter_task
    game_handle = Roact.mount(Roact.createElement(ImposterList), PlayerGui, "Imposter Tasks UI")

end

function ImposterTask.Stop()
    if game_handle then
        Roact.unmount(game_handle)
    end
end



return ImposterTask