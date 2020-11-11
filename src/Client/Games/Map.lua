



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

local Map = Roact.Component:extend("Map")

local game_handle
local game_connections = {}
local corners = workspace.WorldCorners
local time = {
    last = 0,
    current = 0
}
local icons = {}
local icon_refs = {}
local sabotage_icons = {}
local sabotage_refs = {}
local sabotage_table = {}
local player_type
local map_length = corners.TopRight.Position.X - corners.BottomLeft.Position.X
local map_height = corners.TopRight.Position.Z - corners.BottomLeft.Position.Z

local sabotage_state = {}
local MapModule = {}


local function sabotage_tracker(sabotage_model, sabotage_button, sabotage_key)
    print(sabotage_key, sabotage_state[sabotage_key])
    if sabotage_state[sabotage_key] == 0 then
        sabotage_state[sabotage_key] = 100
        Events["sabotage_request"]:FireServer(sabotage_model)
    end

end



local function create_task(properties)
    local task_location = properties.task_location

    local y = ((corners.TopRight.Position.X - task_location.X)/map_length)
    local x = ((corners.TopRight.Position.Z - task_location.Z)/map_height) 
    --print(x,y, (1-x), (1-y))


    
    return Roact.createElement("ImageLabel", {
            [Roact.Ref] = properties.ref,
            Image = "rbxassetid://5923618693",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(.08,0,0.08,0),
            Position = UDim2.new(x, 0, y, 0),
            ZIndex = 600,
    })
end

local function create_sabotage(properties)
    local task_location = properties.task_location
    local name = properties.name
    local y = ((corners.TopRight.Position.X - task_location.X)/map_length)
    local x = ((corners.TopRight.Position.Z - task_location.Z)/map_height) 
    local icon 
    sabotage_state[properties.key] = 0
    --print(x,y, (1-x), (1-y))
    if name == "Fire" then
        icon = "rbxassetid://5929502528"
    else
        icon = "rbxassetid://5929191875"
    end
    
    return Roact.createElement("ImageButton", {
            [Roact.Ref] = properties.ref,
            Image = icon,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = player_type,
            Size = UDim2.new(.08,0,0.08,0),
            Position = UDim2.new(x, 0, y, 0),
            ZIndex = 610,
            [Roact.Event.Activated] = function()
                sabotage_tracker(properties.sabotagable, properties.ref,properties.key)

            end
    })
end

function Map:init()
    self.player_ref = Roact.createRef()
    self.map_ref = Roact.createRef()

    self.map_icons = icons
    self.map_refs = icon_refs
    self.sabotage_refs = sabotage_refs

end

function Map:render()
    return Roact.createElement("ScreenGui",{
        [Roact.Ref] = self.ui_ref,
        IgnoreGuiInset = true
    },{
        MapButton = Roact.createElement("ImageButton",{
            BackgroundTransparency = 1,
            Image = "rbxassetid://5918185677",
            BorderSizePixel = 0,
            Size = UDim2.new(0.1,0,0.1,0),
            Position = UDim2.new(0.889,0,0.1,0),
            ZIndex = 2000,
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            [Roact.Event.Activated] = function()
                print("map hit")
                if self.map_ref:getValue().Visible == false then
                    self.map_ref:getValue().Visible = true
                else
                    self.map_ref:getValue().Visible = false
                end
            end
        }),
        MapContainer = Roact.createElement("Frame",{
            [Roact.Ref] = self.map_ref,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0,0,0,0),
            Visible = false,
            Size = UDim2.new(1,0,1,0)
        },{
            Map = Roact.createElement("Frame",{
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0.2, 0, 0,0),
                Size = UDim2.new(1,0,1,0),
                SizeConstraint = Enum.SizeConstraint.RelativeYY
            },{
                MapImage = Roact.createElement("ImageLabel",{
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1,0,1,0),
                    Image = "rbxassetid://5918190706",
                    ScaleType = Enum.ScaleType.Stretch,
                    ImageColor3 = Color3.fromRGB(233,233,233),
                    ZIndex = 100
                }),
                PlayerIcon = Roact.createElement("ImageLabel",{
                    [Roact.Ref] = self.player_ref,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.05,0,0.05,0),
                    Image = "rbxassetid://5918190466",
                    ZIndex = 800
                }),
                IconContainer = Roact.createElement("Frame",{
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0,0),
                    Size = UDim2.new(1,0,1,0),
                },
                    icons
                ),
                SabotageContainer = Roact.createElement("Frame",{
                    Visible = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0,0),
                    Size = UDim2.new(1,0,1,0),
                },
                    sabotage_icons
                )
            }),

        })

    })
end

function Map:didMount()
    game_connections.TrackPlayer = game:GetService("RunService").Heartbeat:Connect(function(dt)
        
        time.current = time.current+dt
        if time.current-time.last>= 0.1 then
            time.last += 0.1
            --game_time += 1
            local y = ((corners.TopRight.Position.X - Players.LocalPlayer.Character.PrimaryPart.Position.X)/map_length)
            local x = ((corners.TopRight.Position.Z - Players.LocalPlayer.Character.PrimaryPart.Position.Z)/map_height) 
            --print(x,y, (1-x), (1-y))
            self.player_ref:getValue().Position = UDim2.new(x, 0, y, 0)

            for key, value in pairs(sabotage_state) do
                if value > 0 then
                    sabotage_state[key] = value - 1
                    self.sabotage_refs[key]:getValue().ImageTransparency = value / 100
        
                end
            end

        end

    end)


    
    game_connections.UpdateTask = Events["game_complete"].OnClientEvent:Connect(function(game_complete)
        self.map_refs[game_complete]:getValue().Visible = false
    end)

    game_connections.UpdateTask = Events["sabotage_task"].OnClientEvent:Connect(function(msg, type)
        if type then
            self.sabotage_refs[sabotage_table[type]]:getValue().Visible = true
        end

        print(sabotage_table[type])

        if msg == "end" then
            if player_type == false then
                for _, ref in pairs(self.sabotage_refs) do
                    ref:getValue().Visible = false
                end
            end
        end

    end)
    
end


function MapModule.Start(tasks_list, taskLocations, type)
    icons = nil
    icons = {}
    if type == "spy" then
        player_type = true
    else
        player_type = false
    end

    if type then
        for _, sabotage in pairs(workspace.sabotage:GetChildren()) do
            if sabotage:IsA("Folder") then
                continue
            else
                local sabotage_position = sabotage:FindFirstChild(sabotage.Name).Position
                sabotage_refs[#sabotage_icons+1] = Roact.createRef()
                sabotage_table[sabotage.Name] = #sabotage_icons+1
                sabotage_icons[#sabotage_icons+1] = Roact.createElement(create_sabotage, {
                    task_location = sabotage_position,
                    ref = sabotage_refs[#sabotage_icons+1],
                    name = sabotage.Name,
                    key = (#sabotage_icons+1),
                    sabotagable = sabotage

                })
            end 

        end
    end

    for _, task_name in pairs(tasks_list.Common) do
        icon_refs[task_name] = Roact.createRef()
        icons[task_name] = Roact.createElement(create_task, {
            task_location = taskLocations[task_name],
            ref = icon_refs[task_name]
        })
    end

    for _, task_name in pairs(tasks_list.Short) do
        icon_refs[task_name] = Roact.createRef()
        icons[task_name] = Roact.createElement(create_task, {
            task_location = taskLocations[task_name],
            ref = icon_refs[task_name]
        })
    end

    for _, task_name in pairs(tasks_list.Long) do
        icon_refs[task_name] = Roact.createRef()
        icons[task_name] = Roact.createElement(create_task, {
            task_location = taskLocations[task_name],
            ref = icon_refs[task_name]
        })
    end

    game_handle = Roact.mount(Roact.createElement(Map), PlayerGui, "Map")
end

function MapModule.Stop()
    for _, connect in pairs(game_connections) do
        if connect then connect:Disconnect() end
    end

    if game_handle then
        Roact.unmount(game_handle)
    end
end

Events["reset_request"].OnClientEvent:Connect(function()
    MapModule.Stop()
end)

return MapModule