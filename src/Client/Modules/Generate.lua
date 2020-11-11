local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage:WaitForChild("Assets", 60).Game
local GameCenters = workspace:FindFirstChild("GameSpawns")
local Garbage = workspace:FindFirstChild("Garbage") or Instance.new("Folder"); Garbage.Name = "Garbage"; Garbage.Parent = workspace;

local Generate = {}

local radius = 30

local function isAreaOccupied(position : Vector3, minRad : number, occupiedList : Array)
    for i = 1, #occupiedList do
        local otherP : Vector3 = occupiedList[i]
        if (position-otherP).Magnitude < minRad then
            return true
        end
    end
    return false
end

function Generate.GameAsset(game_asset, nameof_center, numberof_spawn)
    local asset : Model = GameAssets:FindFirstChild(game_asset) -- example HuntGame sends "Buck"
    local center : BasePart = GameCenters:FindFirstChild(nameof_center) -- example HuntGame
    
    if not asset then 
        warn("asset does not exist: ", game_asset)
        return
    end

    local occupiedAreas = {}

    for i=1, numberof_spawn, 1 do
        
        local spawn_asset : Model = asset:Clone()
        local hasPlaced : boolean = false

        repeat 
            local theta : number = math.random()*2*math.pi
            local r : number = math.random()*radius
            local position : Vector3 = center.Position + Vector3.new(r*math.sin(theta), 0, r*math.cos(theta))
            local result : RaycastResult = workspace:Raycast(position, Vector3.new(0,-100,0))
            
            if not isAreaOccupied(position, 5, occupiedAreas) then
                hasPlaced = true
                table.insert(occupiedAreas, position)

                local object_rotation : number = math.random()*2*math.pi
                spawn_asset:SetPrimaryPartCFrame(CFrame.new(result.Position+Vector3.new(0,spawn_asset:GetExtentsSize().Y/2,0))*CFrame.Angles(0, object_rotation, 0))
            end
        until hasPlaced
        spawn_asset.Parent = Garbage
    end
end

function Generate.SingleSpawn(game_asset, nameof_center)
        local asset : Model = GameAssets:FindFirstChild(game_asset) -- example HuntGame sends "Buck"
        local center : BasePart = GameCenters:FindFirstChild(nameof_center) 
        local spawn_asset : Model = asset:Clone()


        local result : RaycastResult = workspace:Raycast(center.Position , Vector3.new(0,-100,0))
        spawn_asset:SetPrimaryPartCFrame(CFrame.new(result.Position+Vector3.new(0,spawn_asset:GetExtentsSize().Y/2,0)))
        spawn_asset.Parent = Garbage
end

function Generate.SinglePoint(game_asset, cframe)
    local asset : Model = GameAssets:FindFirstChild(game_asset) -- example HuntGame sends "Buck"
    local spawn_asset : Model = asset:Clone()

    spawn_asset:SetPrimaryPartCFrame(cframe)
    
    --spawn_asset:SetPrimaryPartCFrame(cframe.new(cframe.position))
    spawn_asset.Parent = Garbage
end


return Generate