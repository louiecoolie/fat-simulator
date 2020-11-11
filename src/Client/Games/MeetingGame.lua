local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ChatService = game:GetService("Chat") -- Call ChatService

local ClientEvents = ReplicatedStorage:WaitForChild("Events", 60)
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local Otter = require(ReplicatedStorage:WaitForChild("Otter"))

local Player = Players.LocalPlayer
local ClientModules = Player:WaitForChild("PlayerScripts"):WaitForChild("Modules")
local Cutscenes = require(ClientModules:WaitForChild("Cutscenes"))

local starterCharacter = StarterPlayer:WaitForChild("EjectCharacter")

local replicatedAssets = ReplicatedStorage:WaitForChild("Assets")
local cutsceneData = replicatedAssets:WaitForChild("Cutscenes")
local MeetingCutsceneData = cutsceneData:WaitForChild("Meeting")

local worldAssets = workspace:WaitForChild("WorldAssets")
local cannonModel = worldAssets:WaitForChild("Cannon")

local ingameAtmosphere = nil

local PlayerGui = Players.LocalPlayer.PlayerGui
local Events = {}

for _, event in ipairs(ClientEvents:GetChildren()) do
    ClientEvents:WaitForChild(event.Name, 5)

end

for _, event in ipairs(ClientEvents:GetChildren()) do
	Events[event.Name] = event
end

local spring = Otter.spring
local motor = Otter.createSingleMotor
local chairs = workspace:WaitForChild("Chairs", 60)
local game_connections = {}
local voting_players = {}
local voted_started = false
local game_handle

local MeetingUI = Roact.Component:extend("Meeting UI")

local player_meeting_list

local MeetingGame = {}

function MeetingUI:init()
    self.status_ref = Roact.createRef()
    self.time_ref = Roact.createRef()
    self.tutorial_ref = Roact.createRef()
end

function MeetingUI:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true
    },{
        Container = Roact.createElement("Frame",{
            Size = UDim2.new(1,0,1,0),
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            ZIndex = 1
        },{
            Status = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.status_ref,
                Size = UDim2.new(0.2,0,0.1,0),
                Position = UDim2.new(0.6,0,.9,0),
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
                Size = UDim2.new(0.2,0,0.1,0),
                Position = UDim2.new(0.8,0,.9,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 32,
                --Transparency = 1,
                BorderSizePixel = 0,
                Text = "t"
            }),
            Tutorial = Roact.createElement("TextLabel",{
                [Roact.Ref] = self.tutorial_ref,
                Size = UDim2.new(0.3,0,0.1,0),
                Position = UDim2.new(0.6,0,.1,0),
                TextScaled = true,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(240, 250, 250),
                ZIndex = 31,
                --Transparency = 1,
                BorderSizePixel = 0,
                Visible = false,
                Text = "Click/press on a player to vote!"
            }),


        })
    })
end

function MeetingUI:didMount()

    game_connections.ReceiveVote = Events["vote_request"].OnClientEvent:Connect(function(player)
        local voted_player = workspace:FindFirstChild(player.Name)
        
    end)

    game_connections.UpdateTime = Events["time_request"].OnClientEvent:Connect(function(status, time)
        self.status_ref:getValue().Text = status
        self.time_ref:getValue().Text = math.floor(time)

        if status == "Vote!" then
            if voted_started == false then
                voted_started = true
                ShowVoters(player_meeting_list, true)
                self.tutorial_ref:getValue().Visible = true
            end
        end
    end)
end

function MeetingUI:willUnmount()

end

function ShowVoters(player_list, toggle)
    local players = {}
    
    if toggle == true then

        for _, player in pairs(player_list.Crew) do
            players[#players+1] = player
            workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Material = Enum.Material.Neon
        end

        for _, player in pairs(player_list.Imposter) do
            players[#players+1] = player
            workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Material = Enum.Material.Neon
        end

    elseif toggle == false then

        for _, player in pairs(player_list.Crew) do
            players[#players+1] = player
            workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Material = Enum.Material.Metal
            workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Color = Color3.fromRGB(163, 162, 165)
        end

        for _, player in pairs(player_list.Imposter) do
            players[#players+1] = player
            workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Material = Enum.Material.Metal
            workspace:FindFirstChild(player.Name):FindFirstChild("Character").CharacterParts.HelmMain.Color = Color3.fromRGB(163, 162, 165)
        end
    end
end

function SeatPlayers(player_list)
    local players = {}
    local chair_count = 0
    for _, player in pairs(player_list.Crew) do
        players[#players+1] = player
    end

    for _, player in pairs(player_list.Imposter) do
        players[#players+1] = player
    end

    for _, chair in pairs(chairs:GetChildren()) do
        chair_count += 1
        if players[chair_count] then
            players[chair_count].Character:SetPrimaryPartCFrame(chair.PrimaryPart.CFrame)
            players[chair_count].Character.PrimaryPart.Anchored = true
        end
    end
end

function SendOutside(player_list)
    -- return players to the map
    local playerQueue = {}
    for _, player in pairs(player_list.Crew) do
        playerQueue[#playerQueue+1] = player
    end
    for _, player in pairs(player_list.Imposter) do
        playerQueue[#playerQueue+1] = player
    end
    local terrainAttachments = workspace.Terrain:GetChildren()
    for i = 1, #playerQueue do
        local plr = playerQueue[i]
        if plr and plr.Character then
            plr.Character:SetPrimaryPartCFrame(terrainAttachments[((i-1)%(#terrainAttachments)+1)].CFrame)
            plr.Character.PrimaryPart.Anchored = false
        end
    end
end

local function colorCharacter(char, plrColor)
    local bodyPartsToColor = {"Plumage", "Tabard"}
    local coloredParts = char:WaitForChild("Character"):WaitForChild("ColoredParts")
    for i = 1, #bodyPartsToColor do
        local part = coloredParts:WaitForChild(bodyPartsToColor[i], 1)
        if part then
            part.BrickColor = BrickColor.new(plrColor)
        end
    end
end

function CannonSequence(playerVoted, callback)
    -- create a dummy character for the player who got voted off, and fire it out of the cannon
    if cannonModel and MeetingCutsceneData and cannonModel.Parent == worldAssets then
        local cannonChargeLocation = MeetingCutsceneData.CannonCloseup.Value
        local cannonFireLocation = MeetingCutsceneData.CannonFire.Value

        local fireAttachment = cannonModel.PrimaryPart and cannonModel.PrimaryPart:FindFirstChild("Fire")
        if not fireAttachment then return end

        local fireSounds = {fireAttachment.Fire1, fireAttachment.Fire2}
        local fireSound = fireSounds[math.random(1,#fireSounds)]
        local chargeSound = fireAttachment.Charge

        local particleEffect = fireAttachment.ParticleEmitter
        
        local ejectedPlayer = Players:FindFirstChild(playerVoted)
        if ejectedPlayer then
            -- get color from server
            local playerColor = Events["get_color"]:InvokeServer(ejectedPlayer)
            local ejectedChar = starterCharacter:Clone()
            if playerColor then
                colorCharacter(ejectedChar, playerColor)
            else
                warn("wasn't able to get color for", playerVoted)
            end
            
            local cannonDirection: CFrame = fireAttachment.WorldCFrame

            local initialPosition = cannonDirection*Vector3.new(0,0,-10) -- put decently in front of the cannon
            local acceleration = Vector3.new(0,-workspace.Gravity/2,0)
            local position = initialPosition
            local rotationScalar = 0
            local cannonVelocity = 500*cannonDirection.lookVector
            local rotationalVelocity = 2*math.pi
            local rotationDirection = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5) -- random spinning direction

            if rotationDirection.Magnitude ~= 0 then
                rotationDirection = rotationDirection.Unit
            end

            local trajectoryStartTime = 0
            local function characterTrajectory(delta) -- renderstep function update character position with time
                local t = tick()-trajectoryStartTime
                position = 0.5*acceleration*t^2 + cannonVelocity*t + initialPosition
                rotationScalar += delta*rotationalVelocity
                local worldCFrame = cannonDirection:ToWorldSpace(cannonDirection:ToObjectSpace(CFrame.new(position)))
                ejectedChar:SetPrimaryPartCFrame(worldCFrame*CFrame.fromAxisAngle(rotationDirection, rotationScalar))
            end

            -- set initialPosition
            ejectedChar:SetPrimaryPartCFrame(CFrame.new(initialPosition))

            -- now begin sequence
            -- set camera up at the cannon location
            local unfadeFunc = Cutscenes:FadeToBlack(0.5)
            Cutscenes:MoveCamera(cannonChargeLocation, 0)
            unfadeFunc(0.5)
            
            -- play the charging sound
            chargeSound:Play()

            -- wait a second
            wait(1)

            -- set camera up at final Position
            unfadeFunc = Cutscenes:FadeToBlack(0.5)
            Cutscenes:MoveCamera(cannonFireLocation, 0)
            unfadeFunc(0.5)

            -- wait half a second
            wait(0.5)

            -- fire effects
            fireSound:Play()
            particleEffect.Enabled = true
            spawn(function()
                wait(0.25)
                particleEffect.Enabled = false
            end)

            -- fire player model
            ejectedChar.Parent = workspace
            -- send on trajectory

            callback()
            

            trajectoryStartTime = tick()
            RunService:BindToRenderStep("CannonTrajectoryUpdate", Enum.RenderPriority.Last.Value, characterTrajectory)
            wait(5)
            RunService:UnbindFromRenderStep("CannonTrajectoryUpdate")
            ejectedChar:Destroy()
        end
    end
end

function MeetingGame.Start(type, player_list)
    ChatService:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, function()
        return {BubbleChatEnabled = true} -- Call the API to change its boolean value to true
    end)

    ingameAtmosphere = Lighting:FindFirstChild("IngameAtmosphere")
    
    local initLocation = MeetingCutsceneData.MeetingStart.Value
    local goalLocation = MeetingCutsceneData.MeetingDiscuss.Value
    local tweenTime = MeetingCutsceneData.MeetingDiscuss.Time.Value

    local unfadeFunc = Cutscenes:StartCutscene(initLocation, true)

    player_meeting_list = player_list
    SeatPlayers(player_list)

    if ingameAtmosphere then
        ingameAtmosphere.Parent = nil
    end

    if unfadeFunc then
        unfadeFunc(0.5)
    end

    local cancelFunc = Cutscenes:MoveCamera(goalLocation, tweenTime)

    -- seat players upon activation
    -- start state discuss 
    -- start state vote
    game_handle = Roact.mount(Roact.createElement(MeetingUI), PlayerGui, "Meeting UI")
end

function MeetingGame.Stop(kickSequence, voted_player, vote_type)
    ChatService:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, function()
        return {BubbleChatEnabled = false} -- Call the API to change its boolean value to false
    end)
    game_connections.ReceiveVote:Disconnect()
    game_connections.UpdateTime:Disconnect()
    voted_started = false
    ShowVoters(player_meeting_list, false)
    if voted_player then
        if vote_type == "imposter" or vote_type == "innocent" then
            -- pan camera to person who got voted off
            local playerToEject = Players:FindFirstChild(voted_player)
            if playerToEject then
                local char = playerToEject.Character
                local head = char and char:FindFirstChild("Head")
                if head then
                    Cutscenes:MoveCamera(CFrame.new(head.CFrame*Vector3.new(0, 1.5, -4), head.CFrame.p), 1.25)
                    wait(1.25)
                end
            end

            CannonSequence(voted_player, function()
                coroutine.wrap(function()
                    kickSequence.Start(voted_player, vote_type)
                end)() 
            end)
        end
    else
        kickSequence.Start(voted_player, vote_type)
        wait(4)
    end
    local unfadeFunc = Cutscenes:EndCutscene(true)

    kickSequence.Stop()
    SendOutside(player_meeting_list)
    if ingameAtmosphere then
        ingameAtmosphere.Parent = Lighting
    end

    if unfadeFunc then
        unfadeFunc(0.5)
    end
    
    wait(2)
    Roact.unmount(game_handle)
end

return MeetingGame