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

local CrewGame = Roact.Component:extend("Imposter")

local game_handle = nil
local game_tasks = {}

local Crew = {}

local disable_ui
local enable_ui
local game_points = {}
local game_connections = {}
local game_task = nil
local report = nil

function CrewGame:init()
    self.use_ref = Roact.createRef()
    self.report_ref = Roact.createRef()
    self.ui_ref = Roact.createRef()
    self.default_size = UDim2.new(.1,0,.1,0)
    self.default_offset = UDim2.new(.9, 0, 0.5, 0)

    self.text_size = UDim2.new(.1,0,.1,0)
    self.text_offset = UDim2.new(0.875, 0, 0.30, 0)
    self.use_offset = UDim2.new(.875,0,.525,0)

    
    self.emergency_ref = Roact.createRef()
    self.emergency = false
end

function CrewGame:render()
    return Roact.createElement("ScreenGui",{
        [Roact.Ref] = self.ui_ref,
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
           -- Position = self.default_offset,
            BorderSizePixel = 0
        },{
            Emergency = Roact.createElement("Frame",{
                [Roact.Ref] = self.emergency_ref,
                Size = UDim2.new(0.5,0,0.62,0),
                Position = UDim2.new(0.23,0,.19,0),
                Visible = false,
                AnchorPoint = Vector2.new(-.23,.19),
                Style = Enum.FrameStyle.RobloxRound
            },{
                Text = Roact.createElement("TextLabel",{
                    Position = UDim2.new(0.014, 0, 0.027,0),
                    Size = UDim2.new(0.8,0,0.15,0),
                    BackgroundTransparency = 1,
                    Text = "EMERGENCY MEETING",
                    TextScaled = true,
                    Font = Enum.Font.PermanentMarker
                }),
                Start = Roact.createElement("TextButton",{
                    Position = UDim2.new(0.135, 0, 0.351, 0),
                    Size = UDim2.new(0.735, 0,0.535, 0),
                    BackgroundTransparency = 1,
                    Text = "START!",
                    TextScaled = true,
                    Font = Enum.Font.PermanentMarker,
                    [Roact.Event.Activated] = function()
                        Events["report_request"]:FireServer(report)
                        self.emergency_ref:getValue().Visible = false
                    end
                }),

            }),
            Report = Roact.createElement("ImageButton", {
                Image = "rbxassetid://5742730896",
                [Roact.Ref] = self.report_ref,
                Size = self.text_size,
                ImageColor3 = Color3.fromRGB(108,108,108),
                ImageTransparency = 0.5,
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Position = self.text_offset,
                BackgroundTransparency = 1,
                [Roact.Event.MouseButton1Click] = function(rbx)
                    if report then
                        Events["report_request"]:FireServer(report)
                    end

                end
            },{}),
            Use = Roact.createElement("ImageButton", {
                -- Text = "Sabotage",
                [Roact.Ref] = self.use_ref,
                 Image = "rbxassetid://5872115206",
                 BackgroundTransparency = 1,
                 Size = self.text_size,
                 ImageColor3 = Color3.fromRGB(108,108,108),
                 ImageTransparency = 0.5,
                 SizeConstraint = Enum.SizeConstraint.RelativeXX,
                 Position = self.use_offset ,
                 [Roact.Event.MouseButton1Click] = function(rbx)
                    if game_task then
                        Events["inspect_request"]:FireServer(game_task:FindFirstChild("game_value").Value, game_task)
                    end

                 end
 
             },{}),


        })

    })
end


function CrewGame:didMount()

    game_connections.KeyBinds = game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.E then
                if game_task then
                    Events["inspect_request"]:FireServer(game_task:FindFirstChild("game_value").Value, game_task)
                end
            end
        end
	end)

    game_connections.disable_ui = Events["report_request"].OnClientEvent:Connect(function()


        self.ui_ref:getValue().Enabled = false
    
    end)

    game_connections.enable_ui = Events["end_request"].OnClientEvent:Connect(function()
        self.ui_ref:getValue().Enabled = true
    end)

    game_connections.scan_activity = game:GetService("RunService").Heartbeat:Connect(function()
  
        local low_value = math.huge
        local closest_task = nil
        local task_distance = 10

        local task_scan = {}

        for _, task in pairs(game_points) do
            if task.Name == "Door" or task.Name == "Fire" then
                print("fire or door")
                if task:FindFirstChild("game_value") then
                    local distance = (Players.LocalPlayer.Character.PrimaryPart.Position - task.PrimaryPart.Position).Magnitude
    
                    print("task found!")
                    task_scan[task] = distance
                end
            else
                local distance = (Players.LocalPlayer.Character.PrimaryPart.Position - task.PrimaryPart.Position).Magnitude
    

                task_scan[task] = distance
            end

        end

        for task, distance in pairs(task_scan) do

            if distance < low_value then
                low_value = distance
                closest_task = task
            end
        end
        if closest_task then
            if game_tasks[closest_task.Name] or closest_task:FindFirstChild("game_value") then
                if task_scan[closest_task] <= task_distance then
                    --Events["report_request"]:FireServer(closest_task)
                    self.use_ref:getValue().ImageColor3 = Color3.fromRGB(255,255,255)
                    self.use_ref:getValue().ImageTransparency = 0
                    game_task = closest_task
                else
                    self.use_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
                    self.use_ref:getValue().ImageTransparency = 0.5
                    game_task = nil
                end
            end
        else
            self.use_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
            self.use_ref:getValue().ImageTransparency = 0.5
            game_task = nil
        end
     
        
        local closest_player = nil
        local report_distance = 20




        local player_scan = {}

        for _, player in pairs(workspace.Dead:GetChildren()) do
            if player.Name == Players.LocalPlayer.Name or player == nil then
                continue
            end

            local distance = (Players.LocalPlayer.Character.PrimaryPart.Position - player.PrimaryPart.Position).Magnitude
    

            player_scan[player] = distance    

        end

        for player, distance in pairs(player_scan) do
   
            if distance < low_value then
                low_value = distance
                closest_player = player
            end
        end
        if closest_player then
            if player_scan[closest_player] <= report_distance then
                if closest_player.Name == "Emergency" then

                    self.emergency_ref:getValue().Visible = true
                    report = closest_player
                else
                    self.report_ref:getValue().ImageColor3 = Color3.fromRGB(255,255,255)
                    self.report_ref:getValue().ImageTransparency = 0
                    report = closest_player
                end
            else
                self.emergency_ref:getValue().Visible = false
                self.report_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
                self.report_ref:getValue().ImageTransparency = 0.5
                report = nil
            end
        else
            self.report_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
            self.report_ref:getValue().ImageTransparency = 0.5
            report = nil
            self.emergency_ref:getValue().Visible = false
        end


    end)
    
    game_connections.ReceiveCompletionConfirmation = Events["game_complete"].OnClientEvent:Connect(function(task_completed)
        print(task_completed)
        for k, task_model in pairs(game_points) do
            if task_model.Name == task_completed then
                print(task_completed)
                task_model:FindFirstChild("SelectionBox"):Destroy()
                game_points[k] = nil
            end
        end
	end)

end



function Crew.Start(tasks_list)
    game_tasks = {}
    for _, task_name in pairs(tasks_list.Common) do
        game_tasks[task_name] = task_name

    end

    for _, task_name in pairs(tasks_list.Short) do
        game_tasks[task_name] = task_name

    end

    for _, task_name in pairs(tasks_list.Long) do
        game_tasks[task_name] = task_name

    end

    for _, object in pairs(workspace:GetChildren()) do
        if object:FindFirstChild("game_object") then
            game_points[#game_points+1] = object
        end
    end
    
    for _, object in pairs(workspace.sabotage:GetChildren()) do
        if object:IsA("Model") then
            game_points[#game_points+1] = object
        end
    end


    game_handle = Roact.mount(Roact.createElement(CrewGame), PlayerGui, "Crew")
end

function Crew.Stop()

    for k in pairs(game_points) do
        game_points[k] = nil
    end

    for _, connection in pairs(game_connections) do
        if connection then connection:Disconnect() end
    end

    if report then
        report = nil
    end

    if game_task then
        game_task = nil
    end

    if game_handle then
        Roact.unmount(game_handle)
    end 
end



return Crew