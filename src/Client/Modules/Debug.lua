local Debug = {}

local Roact = require(game:GetService("ReplicatedStorage"):WaitForChild("Roact"))
local Players = game:GetService("Players")
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)

local Events = {}

local ui_handles = {
    inventory_handle = nil
}

local ui_connections = {
    update_inventory = nil
}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
	
end

local PlayerGui = Players.LocalPlayer.PlayerGui

local Inventory = Roact.Component:extend("Inventory")

local output_count = 1

function Inventory:init()
    self.inventoryRef = Roact.createRef()
  
    self:setState({
        name = "Inventory",
        count = 0,
        inventory = {},
        splash = "rbxassetid://5667517917",
        background = "rbxassetid://5667517869",
        default_size = 200,
        default_offset = (200/2),

    })
end

local function create_element(properties)
    local message = properties.message

    output_count += 1
 
    return Roact.createElement("TextLabel",  {
            Text = message,
            TextWrapped = true,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(.8,0,0,100),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = output_count,
           -- Position = UDim2.new(0,0,.5,40),
            ZIndex = 6
        },
    {})
end

local inventory_dictionary = {
    Layout = Roact.createElement("UIListLayout",{
        SortOrder = Enum.SortOrder.LayoutOrder
    }),
}

function Inventory:render()
    local size = self.state.default_size
    local offset = self.state.default_offset

    return Roact.createElement("ScreenGui",{},{
        inventory_container = Roact.createElement("Frame",{
            Size = UDim2.new(0.2,0, 0.2, 0),
            Position = UDim2.new(0.8,0,.1,0),
            Transparency = 1
        },{
            ErrorLog = Roact.createElement("ImageLabel", {
               
                Size = UDim2.new(0, size*2, 0, size),
                Image = self.state.background,
                Transparency = 1,
                Position = UDim2.new(.5,-offset*2,.5,-offset),
                BackgroundTransparency = 1,
                ZIndex = 1
            },{
                inventory = Roact.createElement("ScrollingFrame",{
                    [Roact.Ref] = self.inventoryRef,
                    Size = UDim2.new(0,size/1.1, 0, size/1.8),
                    Position = UDim2.new(.5,-offset/1.1,.5,-offset/1.7),
                    Transparency = 1,
                    CanvasSize = UDim2.new(1,0,10,0),
                    ZIndex = 2,
                }, 
                  inventory_dictionary
                )
            })
        })
    })

end

--ui_handles.toolbar_handle = Roact.mount(Roact.createElement(Toolbar), PlayerGui, "Toolbar UI")
--ui_handles.inventory_handle = Roact.mount(Roact.createElement(Inventory), PlayerGui, "Inventory UI")

ui_connections.update_inventory = game:GetService("LogService").MessageOut:Connect(function(log_message, type)

    inventory_dictionary[log_message] = Roact.createElement(create_element, {
        message = log_message
    })
    --Roact.unmount(ui_handles.inventory_handle)
    --ui_handles.inventory_handle = Roact.mount(Roact.createElement(Inventory), PlayerGui, "Inventory UI")
end)
 

return Debug