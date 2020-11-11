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

local Meeting_Game = Roact.Component:extend("MeetingGame")

local game_handle = nil
local game_start = false

local task_count = 0
local game_players = {
    Layout = Roact.createElement("UIGridStyleLayout",{
        SortOrder = Enum.SortOrder.LayoutOrder
    }),
}

local game_refs = {

}

local game_connections = {

}

local game_messages = {
    Layout = Roact.createElement("UIListLayout",{
        Padding = UDim.new(.025,0),
        SortOrder = Enum.SortOrder.LayoutOrder
    }),
}

local in_game = false
local can_vote = false
local is_dead = false
local player_cameras = {}

local MeetingGame = {}


local function create_player(properties)
    local name = properties.name
    local color = properties.color
    local model = properties.model
    local status = properties.status

    local player_frame = "rbxassetid://5702952619"
    local player_splash = "rbxassetid://5703253747"
    local player_window = "rbxassetid://5703253667"

    local vote_visible = false

    task_count += 1

    if player_cameras[name] == nil then
        local new_camera = Instance.new("Camera")
        new_camera.CFrame = CFrame.new(1,1.5,3)
        new_camera.Name = name
        new_camera.CFrame = CFrame.new(new_camera.CFrame.Position, Vector3.new(0,.8,0))
        player_cameras[name] = new_camera
    end
 
    local kick_box_key = #game_refs+1
    game_refs[kick_box_key] = Roact.createRef()
    local cancel_box_key = #game_refs+1
    game_refs[cancel_box_key] = Roact.createRef()
    local player_name_key = #game_refs+1
    game_refs[player_name_key] = Roact.createRef()


    local player_torso = model:FindFirstChild("Torso")
    local player_head = model:FindFirstChild("Part")
    --model:SetPrimaryPartCFrame(CFrame.new(0,0,0)) -- this will teleport players to meeting player_cameras
    
    if status == "dead" then
        
        return Roact.createElement("Frame", {
            Size = UDim2.new(.5,0,.3,0),
            BackgroundColor = BrickColor.new("Dark grey"),
            BorderSizePixel = 0,
        },{
            text = Roact.createElement("TextLabel",{
                [Roact.Ref] = game_refs[player_name_key],
                Text = name,
                TextWrapped = true,
                BackgroundTransparency = 0,
                BackgroundColor = BrickColor.new("Dark grey"),
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,1,0),
                TextXAlignment = Enum.TextXAlignment.Right,
                LayoutOrder = task_count,
                --Position = UDim2.new(0,0,.5,40),
                ZIndex = 6
            }),
            image_frame = Roact.createElement("ViewportFrame",{
                Size = UDim2.new(0.2,0,1,0),
                Position = UDim2.new(0.1,0,0,0),
                BackgroundColor = BrickColor.new("Dark grey"),
                CurrentCamera = player_cameras[name],
                BorderSizePixel = 0,
                ZIndex = 8
            },{
                player_model = Roact.createElement("Model",{},{
                    torso = Roact.createElement("Part",{
                        Size = player_torso.Size,
                        Color = player_torso.Color,
                        Position = Vector3.new(0,0,0)
                    }),
                    face = Roact.createElement("Part",{
                        Size = player_head.Size,
                        Color = player_head.Color,
                        Position = Vector3.new(0,.7,0.6)
                    })
                })
            }),
            dead_image = Roact.createElement("ImageLabel",{
                Size = UDim2.new(0.2,0,1,0),
                Position = UDim2.new(0.1,0,0,0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://5710840437",
                BorderSizePixel = 0,
                ZIndex = 9
            })
        })
    else

        return Roact.createElement("Frame", {
            Size = UDim2.new(.5,0,.3,0),
            BackgroundColor = BrickColor.new("Institutional white"),
            BorderSizePixel = 0,
        },{
            vote_confirmation = Roact.createElement("ImageLabel",{
                [Roact.Ref] = properties.ref,
                Size = UDim2.new(.1,0,.2,0),
                Image = "rbxassetid://5710840492",
                Position = UDim2.new(.1,0,.1,0),
                Visible = false,
                ZIndex = 35

            }),
            vote_container = Roact.createElement("TextButton",{
                Size = UDim2.new(1,0,1,0),
                BackgroundColor = BrickColor.new("Institutional white"),
                Transparency = 1,
                BorderSizePixel = 0,
                ZIndex = 20,

                [Roact.Event.Activated] = function(rbx)
      
                    if is_dead == true then
                        print("Cannot vote")
                    else
                        if can_vote then
                            --vote_visible = 
                            local kick = game_refs[kick_box_key]:getValue()
                            local cancel = game_refs[cancel_box_key]:getValue()
                            if kick.Visible == true then
                                kick.Visible = false
                                cancel.Visible = false
                            else
                                kick.Visible = true
                                cancel.Visible = true
                            end

                        end
                    end
                end
            },{
                kick_vote = Roact.createElement("ImageButton",{
                    [Roact.Ref] =game_refs[kick_box_key],
                    Size = UDim2.new(0.1,0,0.3,0),
                    Position = UDim2.new(0.6,0,0.7,0),
                    ZIndex = 24,
                    Visible = vote_visible,
                    Image = "rbxassetid://5710840356",
                    [Roact.Event.Activated] = function(rbx)
                        print("tried to kick")
                        local kick = game_refs[kick_box_key]:getValue()
                        local cancel = game_refs[cancel_box_key]:getValue()
                        cancel.Visible = false
                        kick.Visible = false
                        -- add kick connection here
                        Events["vote_request"]:FireServer(game_refs[player_name_key]:getValue().Text)
                    end
                }),
                cancel = Roact.createElement("ImageButton",{
                    [Roact.Ref] = game_refs[cancel_box_key],
                    Size = UDim2.new(0.1,0,0.3,0),
                    Position = UDim2.new(0.8,0,0.7,0),
                    ZIndex = 24,
                    Visible = vote_visible,
                    Image = "rbxassetid://5710840437",
                    [Roact.Event.Activated] = function(rbx)
                        print("tried to cancel")
                        local kick = game_refs[kick_box_key]:getValue()
                        local cancel = game_refs[cancel_box_key]:getValue()
                        cancel.Visible = false
                        kick.Visible = false
                    end
                }),
            }),
            text = Roact.createElement("TextLabel",{
                [Roact.Ref] = game_refs[player_name_key],
                Text = name,
                TextWrapped = true,
                BackgroundTransparency = 0,
                BackgroundColor = BrickColor.new("Institutional white"),
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,1,0),
                TextXAlignment = Enum.TextXAlignment.Right,
                LayoutOrder = task_count,
                --Position = UDim2.new(0,0,.5,40),
                ZIndex = 6
            }),
            image_frame = Roact.createElement("ViewportFrame",{
                Size = UDim2.new(0.2,0,1,0),
                Position = UDim2.new(0.1,0,0,0),
                BackgroundColor = BrickColor.new("Institutional white"),
                CurrentCamera = player_cameras[name],
                BorderSizePixel = 0,
                ZIndex = 8
            },{
                player_model = Roact.createElement("Model",{},{
                    torso = Roact.createElement("Part",{
                        Size = player_torso.Size,
                        Color = player_torso.Color,
                        Position = Vector3.new(0,0,0)
                    }),
                    face = Roact.createElement("Part",{
                        Size = player_head.Size,
                        Color = player_head.Color,
                        Position = Vector3.new(0,.7,0.6)
                    })
                })
        --  }),
    --       image_splash = Roact.createElement("ImageLabel",{
    --            Image = player_splash,
    --           ImageColor3 = color,
    --            Size = UDim2.new(0.1,0,1,0),
    --            BorderSizePixel = 0,
    --            ZIndex = 9
    --
    --        }),
    --        image_window = Roact.createElement("ImageLabel",{
    --            Image = player_window,
    --            Size = UDim2.new(0.2,0,1,0),
    --            BorderSizePixel = 0,
    --            ZIndex = 9

            })
        })
    end

     
end


local function create_message(properties)
    local name = properties.name
    local color = properties.color
    local model = properties.model

    local player_frame = "rbxassetid://5702952619"
    local player_splash = "rbxassetid://5703253747"
    local player_window = "rbxassetid://5703253667"

    task_count -= 1

    if player_cameras[name] == nil then
        local new_camera = Instance.new("Camera")
        new_camera.CFrame = CFrame.new(1,1.5,3)
        new_camera.Name = name
        new_camera.CFrame = CFrame.new(new_camera.CFrame.Position, Vector3.new(0,.8,0))
        player_cameras[name] = new_camera
    end
 
 
    local player_torso = model:FindFirstChild("Torso")
    local player_head = model:FindFirstChild("Part")
    --model:SetPrimaryPartCFrame(CFrame.new(0,0,0)) -- this will teleport players to meeting player_cameras


    return Roact.createElement("Frame", {
        Size = UDim2.new(.5,0,.1,0),
        BackgroundColor = BrickColor.new("Institutional white"),
        BorderSizePixel = 0,
        LayoutOrder = task_count
        --Rotation = 180

    },{
        text = Roact.createElement("TextLabel",{
            [Roact.Ref] = properties.ref,
            Text = name,
            TextWrapped = true,
            BackgroundTransparency = 0,
            BackgroundColor = BrickColor.new("Institutional white"),
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,1,0),
            TextXAlignment = Enum.TextXAlignment.Right,
            
           -- Rotation = 180,
            --Position = UDim2.new(0,0,.5,40),
            ZIndex = 107,
        }),
        image_frame = Roact.createElement("ViewportFrame",{
            Size = UDim2.new(0.2,0,1,0),
            Position = UDim2.new(0.1,0,0,0),
            BackgroundColor = BrickColor.new("Institutional white"),
            CurrentCamera = player_cameras[name],
            BorderSizePixel = 0,
            --Rotation = 180,
            ZIndex = 108
        },{
            player_model = Roact.createElement("Model",{},{
                torso = Roact.createElement("Part",{
                    Size = player_torso.Size,
                    Color = player_torso.Color,
                    Position = Vector3.new(0,0,0)
                }),
                face = Roact.createElement("Part",{
                    Size = player_head.Size,
                    Color = player_head.Color,
                    Position = Vector3.new(0,.7,0.6)
                })
            })
      --  }),
 --       image_splash = Roact.createElement("ImageLabel",{
--            Image = player_splash,
 --           ImageColor3 = color,
--            Size = UDim2.new(0.1,0,1,0),
--            BorderSizePixel = 0,
--            ZIndex = 9
--
--        }),
--        image_window = Roact.createElement("ImageLabel",{
--            Image = player_window,
--            Size = UDim2.new(0.2,0,1,0),
--            BorderSizePixel = 0,
--            ZIndex = 9

        })
    })

     
end


function Meeting_Game:init()
    self.chatbox_ref = Roact.createRef()
    self.message_ref = Roact.createRef()
    self.chat_ref = Roact.createRef()
    self.meeting_ref = Roact.createRef()
    self.skip_ref = Roact.createRef()
    self.status_ref = Roact.createRef()
    self.time_ref = Roact.createRef()
    self.textbox_ref = Roact.createRef()
    self.refs = game_refs
    self.default_size = UDim2.new(0.5,0,0.6,0)
    self.default_offset = UDim2.new(0.45, 0, 0.15, 0)

    self.textbox_size =UDim2.new(0.5,0,0.1,0)
    self.textbox_offset = UDim2.new(0.25, 0, 0.85, 0)

    self.visible, self.updateVisible = Roact.createBinding(true)
    self.vote_visible, self.updateVoteVisible = Roact.createBinding(false)

end

function Meeting_Game:render()
    return Roact.createElement("ScreenGui",{},{
        Container = Roact.createElement("ImageLabel",{
            [Roact.Ref] = self.meeting_ref,
            Size = self.default_size,
            BorderSizePixel = 0,
            Image = "rbxassetid://5732501568",
            BackgroundTransparency = 1,
            Visible = true,
            Position = self.default_offset
        },{
            Padding = Roact.createElement("Frame",{
                Size = UDim2.new(0.9, 0, 0.9, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.05, 0, 0.1, 0)
            },
                game_players
            )
        }),
        SkipButton = Roact.createElement("TextButton",{
            [Roact.Ref] = self.skip_ref,
            Size = UDim2.new(.1,0,.05,0),
            Position = UDim2.new(.8,0,.7,0),
            BackgroundTransparency = 0,
            Text = "Skip vote",
            BorderSizePixel = 1,
            ZIndex = 30,
            Visible = false,
            [Roact.Event.Activated] = function()
                if not(is_dead) then
                    Events["vote_request"]:FireServer("Skip")
                end
            end
        }),
        StatusContainer = Roact.createElement("Frame",{
            Size = UDim2.new(.3,0,.05,0),
            Position = UDim2.new(.45,0,.7,0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 30
        },{
            Status = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.status_ref,
                Size = UDim2.new(0.45,0,1,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 31,
                --Transparency = 1,
                BorderSizePixel = 0,
                Text = "s"
            }),
            Time = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.time_ref,
                Size = UDim2.new(0.4,0,1,0),
                Position = UDim2.new(0.5,0,0,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 32,
                --Transparency = 1,
                BorderSizePixel = 0,
                Text = "t"
            })
        }),
    })
        
end

function Meeting_Game:didMount()

    game_connections.ReceiveVote = Events["vote_request"].OnClientEvent:Connect(function(player)

        game_refs[player.Name]:getValue().Visible = true
    end)

    game_connections.UpdateTime = Events["time_request"].OnClientEvent:Connect(function(status, time)
        self.status_ref:getValue().Text = status
        self.time_ref:getValue().Text = math.floor(time)

        if status == "Vote!" then
            can_vote = true
            self.skip_ref:getValue().Visible = true
        end

    end)

    game_connections.DisableMeeting = Events["end_request"].OnClientEvent:Connect(function()
        self.meeting_ref:getValue().Visible = false 
        self.skip_ref:getValue().Visible = false
        self.status_ref:getValue().Visible = false
        self.time_ref:getValue().Visible = false
        self.textbox_ref:getValue().Visible = false
        --self.chat_ref:getValue().Visible = false
        self.message_ref:getValue().Visible = false
        self.chatbox_ref:getValue().Visible = false
    end)
    
    for _, ref in pairs(self.refs) do

    end

end

function Meeting_Game:willUnmount()

    -- if this is not here ANY interaction inside the UI will stop it from unmounting and will not throw an error
    --self.meeting_ref:getValue().Visible = false 
end


function MeetingGame.Start(type,player_list)
    game_players = nil
    local current_players = Players:GetPlayers()

    in_game = true
    is_dead = false
    if type == "dead" then
        is_dead = true
    end



    game_players = {
        Layout = Roact.createElement("UIGridLayout",{
           -- SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            FillDirectionMaxCells = 2,
            CellSize = UDim2.new(.45,0,.2,0)
        }),
    }
    
    for _, player in pairs(player_list.Crew) do
        local crew_type = "alive"
        for i, dead in pairs(player_list.Dead) do
			if dead == player then
				crew_type = "dead"
			end
		end

        game_refs[player.Name] = Roact.createRef()
        game_players[player.Name] = Roact.createElement(create_player, {
            
            color = workspace:WaitForChild(player.Name, 60):FindFirstChild("Torso").Color,
            name = player.Name,
            model = workspace:WaitForChild(player.Name, 60),
            status = crew_type,
            ref = game_refs[player.Name],

            
        })
    end

    for _, player in pairs(player_list.Imposter) do
        local crew_type = "alive"
        for i, dead in pairs(player_list.Dead) do
			if dead == player then
				crew_type = "dead"
			end
		end
        game_refs[player.Name] = Roact.createRef()
        game_players[player.Name] = Roact.createElement(create_player, {
            color = workspace:FindFirstChild(player.Name):FindFirstChild("Torso").Color,
            name = player.Name,
            model = workspace:FindFirstChild(player.Name),
            status = crew_type,
            ref = game_refs[player.Name]
        })
    end

    game_handle = Roact.mount(Roact.createElement(Meeting_Game), PlayerGui, "Meeting UI")

end

function MeetingGame.Stop()


    --game_handle = nil
    for key, value in pairs(game_refs) do
        game_refs[key] = nil
    end
    is_dead = false
    can_vote = false
    game_messages = nil
    game_messages = {
        Layout = Roact.createElement("UIListLayout",{
            Padding = UDim.new(.025,0)
        }),
    }
    game_connections.ReceiveVote:Disconnect()
    game_connections.UpdateTime:Disconnect()
    game_connections.DisableMeeting:Disconnect()
    Roact.unmount(game_handle)

end


function UpdateMessages(player, message)
    if game_handle then
        game_messages[#game_messages+1] = Roact.createElement(create_message, {
            color = workspace:FindFirstChild(player.Name):FindFirstChild("Torso").Color,
            name = message,
            model = workspace:FindFirstChild(player.Name),
            
            --ref = game_refs[player.Name]
        })

        --Roact.unmount(game_handle)

        game_handle = Roact.mount(Roact.createElement(Meeting_Game), PlayerGui, "Meeting UI")
    end

end

Events["message_request"].OnClientEvent:Connect(function(player, message)
    if in_game then
        UpdateMessages(player, message)
    end
    
end)


return MeetingGame