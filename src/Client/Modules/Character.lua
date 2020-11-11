local Character = {}

function Character.SetCharacter(char)
    local player = char:WaitForChild("Head", 60)
    if player:FindFirstChild("face") then
        player:FindFirstChild("face"):Destroy()
    end

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
        for _, dead_player in pairs(dead) do
            for _, part in pairs(dead_player.Character:GetChildren()) do
                if part.Name == "Torso" or part.Name == "Right Foot" or part.Name == "Left Foot" or part.Name == "Part"  then
                   -- part.Transparency = 0
                   continue
                end

                if part.Name == "Character" then
                    for _, char_part in pairs(part.CharacterParts:GetChildren()) do
                        char_part.Transparency = 0.6
                    end
                    for _, char_part in pairs(part.ColoredParts:GetChildren()) do
                        char_part.Transparency = 0.6
                    end
                end

            end
        end
    elseif status == alive then
        for _, dead_player in pairs(dead) do
            for _, part in pairs(dead_player.Character:GetChildren()) do
                if part.Name == "Torso" or part.Name == "Right Foot" or part.Name == "Left Foot" or part.Name == "Part"  then
                    -- part.Transparency = 1
                    continue
                 end

                 if part.Name == "Character" then
                    for _, char_part in pairs(part.CharacterParts:GetChildren()) do
                        char_part.Transparency = 1
                    end
                    for _, char_part in pairs(part.ColoredParts:GetChildren()) do
                        char_part.Transparency = 1
                    end
                end

            end
        end
    end
end

return Character