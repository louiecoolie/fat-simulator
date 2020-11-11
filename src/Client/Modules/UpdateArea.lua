local UpdateArea = {}

local TweenService = game:GetService("TweenService")


function UpdateArea.Scan(player_character, scan_size, scan_whitelist)
    local player_position = player_character.PrimaryPart.Position
    local region_scan = 
        Region3.new(
            Vector3.new(player_position.X - scan_size, player_position.Y - scan_size, player_position.Z - scan_size),
            Vector3.new(player_position.X + scan_size, player_position.Y + scan_size, player_position.Z + scan_size)
        )

    if scan_whitelist then
        local return_scan = workspace:FindPartsInRegion3WithWhiteList(region_scan, scan_whitelist, 1000)
        
        return return_scan
    else
        local return_scan = workspace:FindPartsInRegion3(region_scan)

        return return_scan
    end

end

function UpdateArea.CreateTasks(tasks, garbage)
    for _, task_name in pairs(tasks.Common) do
        local game_point = workspace:FindFirstChild(task_name)
        local game_value = Instance.new("StringValue")
        game_value.Name = "game_value"
        local object_highlight = Instance.new("SelectionBox")
        
        game_value.Value = task_name
        game_value.Parent = game_point
        object_highlight.Parent = game_point
        object_highlight.Adornee = game_point:FindFirstChild("Collider")

        garbage[#garbage+1] = game_value
        garbage[#garbage+1] = object_highlight

    end

    for _, task_name in pairs(tasks.Short) do
        local game_point = workspace:FindFirstChild(task_name)
        local game_value = Instance.new("StringValue")
        game_value.Name = "game_value"
        local object_highlight = Instance.new("SelectionBox")
        
        game_value.Value = task_name
        game_value.Parent = game_point
        object_highlight.Parent = game_point
        object_highlight.Adornee = game_point:FindFirstChild("Collider")

        garbage[#garbage+1] = game_value
        garbage[#garbage+1] = object_highlight
    end

    for _, task_name in pairs(tasks.Long) do
        local game_point = workspace:FindFirstChild(task_name)
        local game_value = Instance.new("StringValue")
        game_value.Name = "game_value"
        local object_highlight = Instance.new("SelectionBox")
        
        game_value.Value = task_name
        game_value.Parent = game_point
        object_highlight.Parent = game_point
        object_highlight.Adornee = game_point:FindFirstChild("Collider")

        garbage[#garbage+1] = game_value
        garbage[#garbage+1] = object_highlight
    end

    return garbage

end
return UpdateArea