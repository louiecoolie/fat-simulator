local Inspect = {}

local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events", 60)

local Inventories = game:GetService("ServerStorage"):FindFirstChild("Inventories") or Instance.new("Folder", game:GetService("ServerStorage"))
Inventories.Name = "Inventories"

local function AddItem(player_inventory, item, player)
    local player_item = player_inventory:FindFirstChild(item.Name)
    if player_item then
        local itemCount = player_item:FindFirstChild("Count")
        assert(itemCount, "item lacks a count value")

        itemCount.Value = itemCount.Value + 1
        Events:FindFirstChild("inventory_update"):FireClient(player, itemCount.Value, item)
        item:Destroy()
    else
        local new_item = Instance.new("Folder", player_inventory)
        new_item.Name = item.Name
        local item_value = Instance.new("ObjectValue")
        local count_value = Instance.new("NumberValue")
        
        item_value.Name = item.Name
        count_value.Name = "Count"

        item_value.Value = item
        count_value.Value = 1

        item_value.Parent = new_item 
        count_value.Parent = new_item
        Events:FindFirstChild("inventory_update"):FireClient(player, count_value.Value, item)
        item:Destroy()
    end

end

local function GetMousePoint(mouse_ray)
	local RayMag1 = mouse_ray
	local NewRay = Ray.new(RayMag1.Origin, RayMag1.Direction * 1000)
	local Target, Position = workspace:FindPartOnRay(NewRay)
	return Target, Position
end

function Inspect.DetectInspect(player, game_value, game_holder)

    print(game_holder)
    Events:FindFirstChild("game_request"):FireClient(player, game_value, nil, nil, game_holder)

end


return Inspect