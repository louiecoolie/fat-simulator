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

local ImposterGame = Roact.Component:extend("Imposter")

local game_handle = nil
local game_clock
local disable_ui
local enable_ui
local game_time = 0
local murder_activated = false
local murder_timer = 30
local player_list = nil
local kill = nil
local report = nil
local sabotagable = nil
local vent_active = false
local current_vent = nil
local emergency_meeting = nil

local Vents = {}

for _, barrel in pairs(workspace.sabotage.Vents:GetChildren()) do
    local vent_number = barrel:FindFirstChild("VentNumber").Value

    Vents[vent_number] = barrel
end

local time = {
    last = 0,
    current = 0
}

local game_connections = {}

local Imposter = {}

local camera : Camera = workspace.CurrentCamera
local function updateEmergencyLocation(obj, location)
    local cameraSpaceLocation, withinBounds = camera:WorldToScreenPoint(location)
    obj.Visible = withinBounds

    -- update Position
    obj.Position = UDim2.new(0, cameraSpaceLocation.X, 0, cameraSpaceLocation.Y)
end

function ImposterGame:init()

    self:setState({
        currentTime = 30
    })

    self.kill_ref = Roact.createRef()
    self.report_ref = Roact.createRef()
    self.sabotage_ref = Roact.createRef()
    self.buttons_ref = Roact.createRef()

    self.ui_ref = Roact.createRef()
    self.countdown_ref = Roact.createRef()
    self.default_size = UDim2.new(.1,0,.1,0)
    self.default_offset = UDim2.new(.9, 0, 0.5, 0)

    self.text_size = UDim2.new(.1,0,.1,0)
    self.text_offset = UDim2.new(0.875, 0, 0.30, 0)

    self.sabotage_offset = UDim2.new(.875,0,.525,0)
    self.kill_offset = UDim2.new(.775,0,.70,0)

    self.emergency_ref = Roact.createRef()
    self.emergency = false

end

function ImposterGame:render()
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
                --Text = "Report",
                [Roact.Ref] = self.report_ref,
                Image = "rbxassetid://5742730896",
                Size = self.text_size,
                ImageColor3 = Color3.fromRGB(108,108,108),
                ImageTransparency = 0.5,
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Position = self.text_offset,
                BackgroundTransparency = 1,
                [Roact.Event.MouseButton1Click] = function(rbx, iobj)
                    if report then
                        if report.Name == "Emergency" then
                            emergency_meeting.Start()
                            wait(1)
                            emergency_meeting.Stop()
                        else
                            Events["report_request"]:FireServer(report)
                        end
                    end
                end
            },{}),
            Sabotage = Roact.createElement("ImageButton", {
               -- Text = "Sabotage",
                [Roact.Ref] = self.sabotage_ref,
                Image = "rbxassetid://5742730975",
                BackgroundTransparency = 1,
                Size = self.text_size,
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Position = self.sabotage_offset,
                ImageColor3 = Color3.fromRGB(108,108,108),
                ImageTransparency = 0.5,
                [Roact.Event.MouseButton1Down] = function(rbx)
                    if sabotagable then
                        if sabotagable.Name == "Vent" then

                            if vent_active == false then
                                vent_active = true
                                self.buttons_ref:getValue().Visible = true
                                workspace.CurrentCamera.CameraSubject = sabotagable:FindFirstChild("Focus")
                                current_vent = sabotagable:FindFirstChild("VentNumber").Value
                                Events["vent_request"]:FireServer(sabotagable:FindFirstChild("VentNumber").Value, vent_active)
                            elseif vent_active == true then
                                vent_active = false
                                self.buttons_ref:getValue().Visible = false
                                workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                                Events["vent_request"]:FireServer(sabotagable:FindFirstChild("VentNumber").Value, vent_active)
                            end
                        else
                            Events["sabotage_request"]:FireServer(sabotagable)
                        end
                    end


                end

            },{
                Countdown = Roact.createElement("TextLabel",{
                    [Roact.Ref] = self.sabotage_count,
                    Visible = false,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    TextScaled = true,
                    BackgroundTransparency = 1,
                    ZIndex = 50,
                    TextColor3 = Color3.fromRGB(240, 250, 250),
                    Text = self.state.currentTime,
                })
            }),
            Kill = Roact.createElement("ImageButton", {
                --Text = "Kill",
                [Roact.Ref] = self.kill_ref,
                Image = "rbxassetid://5742730810",
                BackgroundTransparency = 1,
                Size = self.text_size,
                ImageColor3 = Color3.fromRGB(108,108,108),
                ImageTransparency = 0.5,
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Position = self.kill_offset,
                [Roact.Event.MouseButton1Click] = function(rbx)
                    if kill then
                        murder_activated = true
                        self.countdown_ref:getValue().Visible = true
                    -- send server kill request
                        Events["kill_request"]:FireServer(kill)
                    end
                end
            },{
                Countdown = Roact.createElement("TextLabel",{
                    [Roact.Ref] = self.countdown_ref,
                    Visible = false,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    TextScaled = true,
                    BackgroundTransparency = 1,
                    ZIndex = 50,
                    TextColor3 = Color3.fromRGB(240, 250, 250),
                    Text = self.state.currentTime,
                })
            }),
            ButtonsContainer = Roact.createElement("Frame",{
                [Roact.Ref] = self.buttons_ref,
                Size = UDim2.new(0.164, 0, .1, 0),
                Position = UDim2.new(0.418,0,0.862,0),
                BackgroundTransparency = 1,
                Visible = false,
                BorderSizePixel = 0,
                
            },{
                Left = Roact.createElement("ImageButton",{
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0,0,0,0),
                    Image = "rbxassetid://5936934878",
                    [Roact.Event.Activated] = function() 
                        print('activated left')
                        print(current_vent)
                        current_vent += 1
                        if Vents[current_vent] then
                            workspace.CurrentCamera.CameraSubject = Vents[current_vent]:FindFirstChild("Focus")
                            Events["vent_request"]:FireServer(current_vent, true)
                        else
                            current_vent -= 1
                        end
                        
                    end
                }),
                Right = Roact.createElement("ImageButton",{
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0.5,0,0,0),
                    Image = "rbxassetid://5936934796",
                    [Roact.Event.Activated] = function() 
                        print('activated right')
                        current_vent -= 1
                        print(current_vent)
                        if Vents[current_vent] then
                            workspace.CurrentCamera.CameraSubject = Vents[current_vent]:FindFirstChild("Focus")
                            Events["vent_request"]:FireServer(current_vent, true)
                        else
                            current_vent += 1
                        end
                        
                    end
                }),

            })

        })

    })
end


function ImposterGame:didMount()
    game_connections.game_clock =  game:GetService("RunService").Heartbeat:Connect(function(dt)

        time.current = time.current+dt
        if time.current-time.last>=1 then
            time.last += 1
            --game_time += 1
            if murder_activated then
                murder_timer -= 1
                
                self.countdown_ref:getValue().Text = murder_timer

                if murder_timer == 0 or murder_timer < 0 then
                    murder_timer = 30
                    murder_activated = false
                    self.countdown_ref:getValue().Text = murder_timer
                    self.countdown_ref:getValue().Visible = false
                end
            end

        end

    end)

    game_connections.update_list = Events["ghost_update"].OnClientEvent:Connect(function(dead, alive, list)
        player_list.Dead = dead
    end)

    game_connections.disable_ui = Events["report_request"].OnClientEvent:Connect(function()


        self.ui_ref:getValue().Enabled = false
        murder_timer = 30
        murder_activated = false
    
    end)

    game_connections.enable_ui = Events["end_request"].OnClientEvent:Connect(function()
        self.ui_ref:getValue().Enabled = true
        murder_activated = true
    end)

    game_connections.scan_activity = game:GetService("RunService").Heartbeat:Connect(function()
  
        local low_value = math.huge
        local closest_kill = nil
        local kill_distance = 10




        local kill_scan = {}

        for _, player in pairs(Players:GetPlayers()) do
            if player.Name == Players.LocalPlayer.Name then
                continue
            end

            local distance = (Players.LocalPlayer.Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude
    

            kill_scan[player] = distance    

        end

        for player, distance in pairs(kill_scan) do

            if distance < low_value then
                low_value = distance
                closest_kill = player
            end
        end

        if closest_kill then

            if kill_scan[closest_kill] <= kill_distance then
                local imposter_check = false
                local dead_check = false
                for _, imposter in pairs(player_list.Imposter) do
                    if imposter == closest_kill then
                        print('player is spy')
                        imposter_check = true
                    end
                end

                for _, dead in pairs(player_list.Dead) do
                    if dead == closest_kill then
                        print('player is dead')
                        dead_check = true
                    end
                end

                if player_list.Dead[closest_kill] then
                    print("Player is dead")
                elseif  imposter_check == true then
                    print("Player is a fellow spy")
                    --check if the requested kill_player is dead
                elseif not imposter_check and not dead_check then
                    if murder_activated == false then
                        kill = closest_kill
                        self.kill_ref:getValue().ImageColor3 = Color3.fromRGB(255,255,255)
                        self.kill_ref:getValue().ImageTransparency = 0
                    end
                end
            elseif kill_scan[closest_kill] > kill_distance then
                self.kill_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
                self.kill_ref:getValue().ImageTransparency = 0.5
                kill = nil
            end
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

        local closest_sabotage = nil
        local sabotage_distance = 16




        local sabotage_scan = {}

        for _, sabotage in pairs(workspace.sabotage:GetChildren()) do
            if sabotage:IsA("Folder") then
                for _, child in pairs(sabotage:GetChildren()) do
                    local sabotage_position = child:FindFirstChild(child.Name).Position
                    local player_position = Players.LocalPlayer.Character.PrimaryPart.Position
                    local distance = (player_position - sabotage_position).Magnitude
            
    
                    sabotage_scan[child] = distance  
                end
            else
                local sabotage_position = sabotage:FindFirstChild(sabotage.Name).Position
                local player_position = Players.LocalPlayer.Character.PrimaryPart.Position
                local distance = (player_position - sabotage_position).Magnitude
        

                sabotage_scan[sabotage] = distance   
            end 

        end

        for sabotage, distance in pairs(sabotage_scan) do

            if distance < low_value then
                low_value = distance
                closest_sabotage = sabotage
            end
        end
        if closest_sabotage then
            if sabotage_scan[closest_sabotage] <= sabotage_distance then
                if closest_sabotage.Name == "Vent" then
                    if vent_active == false then
                        self.sabotage_ref:getValue().Image = "rbxassetid://5897833766"
                  
                        self.sabotage_ref:getValue().ImageColor3 = Color3.fromRGB(255,255,255)
                        self.sabotage_ref:getValue().ImageTransparency = 0
                        sabotagable = closest_sabotage
                    elseif vent_active == true then
                        self.sabotage_ref:getValue().Image = "rbxassetid://5898033040"
                        self.sabotage_ref:getValue().ImageColor3 = Color3.fromRGB(255,255,255)
                        self.sabotage_ref:getValue().ImageTransparency = 0
                        sabotagable = closest_sabotage
                    end
                else
                    self.sabotage_ref:getValue().Image = "rbxassetid://5742730975"
                    self.sabotage_ref:getValue().ImageColor3 = Color3.fromRGB(255,255,255)
                    self.sabotage_ref:getValue().ImageTransparency = 0
                    sabotagable = closest_sabotage
                end

            else
                self.sabotage_ref:getValue().Image = "rbxassetid://5742730975"
                self.sabotage_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
                self.sabotage_ref:getValue().ImageTransparency = 0.5
                sabotagable = nil
            end
        else
            
            self.sabotage_ref:getValue().Image = "rbxassetid://5742730975"
            self.sabotage_ref:getValue().ImageColor3 = Color3.fromRGB(108,108,108)
            self.sabotage_ref:getValue().ImageTransparency = 0.5
            sabotagable = nil
        end
    end)

end

function ImposterGame:willUnmount()

    murder_timer = 30
    murder_activated = false

end


function Imposter.Start(list, meeting)
    player_list = list
    emergency_meeting = meeting

    game_handle = Roact.mount(Roact.createElement(ImposterGame), PlayerGui, "Imposter")
end

function Imposter.Stop()
    for _, connect in pairs(game_connections) do
        if connect then connect:Disconnect() end
    end

    if game_handle then
        Roact.unmount(game_handle)
    end
end

Events["reset_request"].OnClientEvent:Connect(function()
    Imposter.Stop()
end)

return Imposter