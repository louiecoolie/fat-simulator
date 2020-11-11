local Character = {}

function Character.SetCharacter(char)
    local player = char:WaitForChild("Head", 60)
    if player:FindFirstChild("face") then
        player:FindFirstChild("face"):Destroy()
    end

    print(char.Name)
end

function Character.UpdateCharacters(dead, alive, local_player)
    local status = nil

    for _, dead_player in pairs(dead) do
        if dead_player.Name == local_player.Name then
            status = dead
        end
    end

    for _, alive_player in pairs(alive) do
        if alive_player.Name == local_player.Name then
            status = alive
        end
    end

        
    if status == dead then
        print("Local player is dead")
        for _, dead_player in pairs(dead) do
            for _, part in pairs(dead_player.Character:GetChildren()) do
                if part.Name == "Torso" then
                    part.Transparency = 0
                end
                if part.Name == "Right Foot" then
                    part.Transparency = 0
                end
                if part.Name == "Left Foot" then
                    part.Transparency = 0
                end
                if part.Name == "Part" then
                    part.Transparency = 0
                end
            end
        end
    elseif status == alive then
        print("Local player is alive")
        for _, dead_player in pairs(dead) do
            for _, part in pairs(dead_player.Character:GetChildren()) do
                if part.Name == "Torso" then
                    part.Transparency = 1
                end
                if part.Name == "Right Foot" then
                    part.Transparency = 1
                end
                if part.Name == "Left Foot" then
                    part.Transparency = 1
                end
                if part.Name == "Part" then
                    part.Transparency = 1
                end
            end
        end
    end
end

return Character