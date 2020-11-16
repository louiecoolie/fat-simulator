local module = {}

function module.Grow(player, calculator, store, event)
    print("tried to grow")
    local player_data = store.GetStore().players[player.Name]

    local Character = player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    local BodyDepthScale = Humanoid:FindFirstChild("BodyDepthScale")
    local BodyHeightScale = Humanoid:FindFirstChild("BodyHeightScale")
    local BodyWidthScale = Humanoid:FindFirstChild("BodyWidthScale")
    local HeadScale = Humanoid:FindFirstChild("HeadScale")

    local point = calculator.Calculate("power", "growth", player_data.power)
    local value =  (player_data.currency + point) 


    if value < calculator.Calculate("store", "growth", player_data.storage) then
        store.UpdatePlayer(player, "currency", player_data.currency + point)
        BodyHeightScale.Value =  BodyHeightScale.Value * (1.003 + (point/1000))
        HeadScale.Value = HeadScale.Value * (1.003 + (point/1000))
        BodyWidthScale.Value =  BodyWidthScale.Value * (1.004 + (point/1000))
        BodyDepthScale.Value = BodyDepthScale.Value * (1.005 + (point/1000))
    elseif value > calculator.Calculate("store", "growth", player_data.storage) then
        store.UpdatePlayer(player, "currency", calculator.Calculate("store", "growth", player_data.storage))
    end

    event:FindFirstChild("status_update"):FireClient(player, "currency", value)

    --player.Character:FindFirstChild("LowerTorso").Size =  player.Character:FindFirstChild("LowerTorso").Size * 1.01
    
end


function module.Sell(player, calculator, store, event)
    print("tried to sell")
    local player_data = store.GetStore().players[player.Name]

    local Character = player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    local BodyDepthScale = Humanoid:FindFirstChild("BodyDepthScale")
    local BodyHeightScale = Humanoid:FindFirstChild("BodyHeightScale")
    local BodyWidthScale = Humanoid:FindFirstChild("BodyWidthScale")
    local HeadScale = Humanoid:FindFirstChild("HeadScale")

    local value =  player_data.currency


    BodyHeightScale.Value =  1
    HeadScale.Value = 1
    BodyWidthScale.Value =  1
    BodyDepthScale.Value = 1

    store.UpdatePlayer(player, "premium_currency", player_data.premium_currency + value)
    store.UpdatePlayer(player, "currency", 0)


    event:FindFirstChild("status_update"):FireClient(player, "currency", value)
    event:FindFirstChild("status_update"):FireClient(player, "premium", player_data.premium_currency)
    --player.Character:FindFirstChild("LowerTorso").Size =  player.Character:FindFirstChild("LowerTorso").Size * 1.01
    
end

return module