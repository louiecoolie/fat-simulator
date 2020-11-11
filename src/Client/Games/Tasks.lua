--[[
    Pipe game will use mouse or tap input to spin a turn wheel to rise water pressure back up to 100%

    Upon completion of the game this component will self destruct and send out completion confirmation back into server and delete
    game binder off the corressponding object in world.
]]


local Roact = require(game:GetService("ReplicatedStorage"):WaitForChild("Roact"))
local Otter = require(game:GetService("ReplicatedStorage"):WaitForChild("Otter"))

local Players = game:GetService("Players")
local ClientEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)

local Events = {}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end

local PlayerGui = Players.LocalPlayer.PlayerGui

local TaskList = Roact.Component:extend("Tasks")

local game_handle = nil
local game_start = false
local game_connections = {}


local task_count = 0
local task_dict = {
    WheatGame = "Grab the sickle and harvest the wheat in the field",
    WaterGame = "Get the bucket and water the field",
    TreeGame = "Get the axe and chop trees at the forest",
    ChopGame = "Cut wood into planks at the forest",
    FuelGame = "Shovel coal into the furnace at the smithery",
    PlantGame = "Grab the planting tool and plant seeds at the field",
    HuntGame = "Equip the bow and hunt deer for the village at the forest",
    AnvilGame = "Get the hammer and smith tools at the smithery",
}

local pointedTask = nil

-- bind to renderstep
local camera : Camera = workspace.CurrentCamera
local function updatePointerLocation(obj, location, delta)
    local cameraSpaceLocation, withinBounds = camera:WorldToScreenPoint(location)
    obj.Visible = withinBounds

    local pixelYOffset = 64
    local amplitude = 16
    local offset = pixelYOffset + amplitude*math.sin(tick()*2*math.pi)

    -- update Position
    obj.Position = UDim2.new(0, cameraSpaceLocation.X, 0, cameraSpaceLocation.Y - offset)
end

local game_tasks = {
    Layout = Roact.createElement("UIListLayout",{
        SortOrder = Enum.SortOrder.LayoutOrder
    }),
}

local game_refs = {

}

local Tasks = {}


local function create_task(properties)
    local task = properties.task
    local task_location = properties.task_location
    task_count += 1
 
    return Roact.createElement("TextLabel",  {
            [Roact.Ref] = properties.ref,
            Text = task,
            TextWrapped = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(.8,0,0.15,0),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = task_count,
            Position = UDim2.new(0.1,0,.5,40),
            ZIndex = 6,
            [Roact.Event.InputBegan] = function(rbx, iobj)
                if iobj.UserInputType == Enum.UserInputType.MouseButton1 or iobj.UserInputType == Enum.UserInputType.Touch then
                    local arrow = game_refs["TaskPointer"]:getValue()
                    if (pointedTask and pointedTask == task) then
                        -- make invisible set pointedTask to nil make invisible
                        arrow.Visible = false
                        pointedTask = nil
                            
                        -- unbind arrow pointing
                        game:GetService("RunService"):UnbindFromRenderStep("TaskPointerOnUpdate")

                    else
                        -- make visible and setPointedTask to self
                        arrow.Visible = true
                        pointedTask = task

                        -- start binding arrow to point to the area
                        if pointedTask then
                            game:GetService("RunService"):UnbindFromRenderStep("TaskPointerOnUpdate")
                        end
                        game:GetService("RunService"):BindToRenderStep("TaskPointerOnUpdate", 0, function(delta)
                            updatePointerLocation(arrow, task_location, delta)
                        end)
                    end
                end
            end,
        },
    {})
end

function TaskList:init()
    self.refs = game_refs
    self.taskui_ref = Roact.createRef()
    self.container_ref = Roact.createRef()
    self.hide_ref = Roact.createRef()
    self.default_size = UDim2.new(0.3,0,0.3,0)
    self.default_offset = UDim2.new(0.05, 0, 0.15, 0)
    self.activated = true

end

function TaskList:render()
    game_refs["TaskPointer"] = Roact.createRef()
    return Roact.createElement("ScreenGui",{
        [Roact.Ref] = self.taskui_ref,
        IgnoreGuiInset = true
    },{
        TaskContainer = Roact.createElement("Frame", {
            [Roact.Ref] = self.container_ref,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0.3, 0, 0.5,0),
            Position = UDim2.new(0.031,0,0.111,0),
            ZIndex = 0
        },{
            Container = Roact.createElement("ImageLabel",{
                Size = UDim2.new(1,0,1,0),
                Image = "rbxassetid://5918190612",
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            },{
                TaskContainer = Roact.createElement("Frame",{
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.8, 0, 0.8,0),
                    Position = UDim2.new(0.1,0,0.1,0),
                    ZIndex = 0
                },
                    game_tasks
                ),

            }),
            Button = Roact.createElement("TextButton",{
                [Roact.Ref] = self.hide_ref,
                Text = "Hide",
                TextColor3 = Color3.fromRGB(255,255,255),
                TextScaled = true,
                Font = Enum.Font.Arcade,
                Rotation = 90,
                Position = UDim2.new(1,0,0.4,0),
                Size = UDim2.new(0.3,0,0.2,0),
                BackgroundTransparency = 1,
                [Roact.Event.Activated] = function()
                    if self.activated == true then
                        self.activated = false
                        self.hide_ref:getValue().Text = "Show"
                        local singleMotor = Otter.createSingleMotor(0.031)
                        singleMotor:setGoal(Otter.spring(-0.3))
                    
                    
                        singleMotor:onStep(function(x)
                            self.container_ref:getValue().Position = UDim2.new(x,0,.111,0)
                        end)
                    else
                        self.activated = true
                        self.hide_ref:getValue().Text = "Hide"
                        local singleMotor = Otter.createSingleMotor(-0.3)
                        singleMotor:setGoal(Otter.spring(0.031))
                    
                    
                        singleMotor:onStep(function(x)
                            self.container_ref:getValue().Position = UDim2.new(x,0,.111,0)
                        end)
                    end
                end
            }),

            
            TaskPointer = Roact.createElement("ImageLabel", {
                Image = "rbxassetid://5865868669";
                Size = UDim2.new(0, 42, 0, 73);
                Position = UDim2.new(0.5,0,0.5,0);
                AnchorPoint = Vector2.new(0.5, 0.5);
                ZIndex = 3;
                Visible = false;
                BackgroundTransparency = 1;

                [Roact.Ref] = game_refs["TaskPointer"];
            }),
     })

    })
end

function TaskList:didMount()


    game_connections.UpdateTask = Events["game_complete"].OnClientEvent:Connect(function(game_complete)
        self.refs[game_complete]:getValue().TextColor3 = Color3.fromRGB(21, 122, 66)
        self.refs[game_complete]:getValue().Text = task_dict[game_complete] .. " (Completed)"
    end)

end

function TaskList:willUnmount()
    game_connections.UpdateTask:Disconnect()
end


function Tasks.Start(tasks_list, taskLocations)
    game_tasks = nil
    game_tasks = {
        Layout = Roact.createElement("UIListLayout",{
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
    }

    for _, task_name in pairs(tasks_list.Common) do
        game_refs[task_name] = Roact.createRef()
        game_tasks[task_name] = Roact.createElement(create_task, {
            task = task_dict[task_name],
            task_location = taskLocations[task_name],
            ref = game_refs[task_name]
        })
    end

    for _, task_name in pairs(tasks_list.Short) do
        game_refs[task_name] = Roact.createRef()
        game_tasks[task_name] = Roact.createElement(create_task, {
            task = task_dict[task_name],
            task_location = taskLocations[task_name],
            ref = game_refs[task_name]
        })
    end

    for _, task_name in pairs(tasks_list.Long) do
        game_refs[task_name] = Roact.createRef()
        game_tasks[task_name] = Roact.createElement(create_task, {
            task = task_dict[task_name],
            task_location = taskLocations[task_name],
            ref = game_refs[task_name]
        })
    end

    game_handle = Roact.mount(Roact.createElement(TaskList), PlayerGui, "Tasks UI")

end

function Tasks.Stop()
    if game_handle then
        Roact.unmount(game_handle)
    end
end



return Tasks