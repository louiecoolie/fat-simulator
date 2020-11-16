local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Rodux)

local module = {}

-- Action creator for the ReceivedNewPhoneNumber action
local function ReceivedNewPlayer(playerName)
    return {
        type = "ReceivedNewPlayer",
        newPlayer = playerName


    }
end

local function ReceivedNewPhoneNumber(phoneNumber)
    return {
        type = "ReceivedNewPhoneNumber",
        phoneNumber = phoneNumber,
    }
end

-- Action creator for the MadeNewFriends action
local function MadeNewFriends(listOfNewFriends)
    return {
        type = "MadeNewFriends",
        newFriends = listOfNewFriends,
    }
end

-- Reducer for the current user's phone number
local phoneNumberReducer = Rodux.createReducer("", {
    ReceivedNewPhoneNumber = function(state, action)
        return action.phoneNumber
    end,
})

-- Reducer for the current user's list of friends
local friendsReducer = Rodux.createReducer({}, {
    MadeNewFriends = function(state, action)
        local newState = {}

        -- Since state is read-only, we copy it into newState
        for index, friend in ipairs(state) do
            newState[index] = friend
        end

        for _, friend in ipairs(action.newFriends) do
            table.insert(newState, friend)
        end

        return newState
    end,
})

local playersReducer = Rodux.createReducer({},{
    ReceivedNewPlayer = function(state, action)
        local newState = {}

        for player, table in ipairs(state) do
            newState[player] = table
        end


        newState[action.newPlayer[1]] = action.newPlayer[2]


        return newState
    end,

})

local reducer = Rodux.combineReducers({
    myPhoneNumber = phoneNumberReducer,
    myFriends = friendsReducer,
    players = playersReducer,
})

local store = Rodux.Store.new(reducer, nil, {
    Rodux.loggerMiddleware,
})

store:dispatch(ReceivedNewPhoneNumber("15552345678"))
store:dispatch(MadeNewFriends({
    "Cassandra",
    "Joe",
}))






function module.GetStore()
    return store:getState()
end

function module.LogPlayer(player, calculator, event)
    store:dispatch(ReceivedNewPlayer({player.Name,{
        power = 1,
        storage = 1,
        currency = 0,
        premium_currency = 0,
    }}))
    
    event:FindFirstChild("status_update"):FireClient(player, "storage", calculator.Calculate("store", "growth", store:getState().players[player.Name].storage))

    
end

function module.UpdatePlayer(player, type, value)
    local player_file = store:getState().players[player.Name]
    
    if type == "power" then
        store:dispatch(ReceivedNewPlayer({player.Name,{
            power = value,
            storage = player_file.storage,
            currency = player_file.currency,
            premium_currency = player_file.premium_currency,
        }}))
    end

    if type == "storage" then
        store:dispatch(ReceivedNewPlayer({player.Name,{
            power = player_file.power,
            storage = value,
            currency = player_file.currency,
            premium_currency = player_file.premium_currency,
        }}))
    end

    if type == "currency" then
        store:dispatch(ReceivedNewPlayer({player.Name,{
            power = player_file.power,
            storage = player_file.storage,
            currency = value,
            premium_currency = player_file.premium_currency,
        }}))
    end
    if type == "premium_currency" then
        store:dispatch(ReceivedNewPlayer({player.Name,{
            power = player_file.power,
            storage = player_file.storage,
            currency = player_file.currency,
            premium_currency = value,
        }}))
    end  
end


--[[
    Expected output to the developer console:

    Action dispatched: {
        phoneNumber = "12345678" (string)
        type = "ReceivedNewPhoneNumber" (string)
    }
    State changed to: {
        myPhoneNumber = "12345678" (string)
        myFriends = {
        }
    }
    Action dispatched: {
        newFriends = {
            1 = "Cassandra" (string)
            2 = "Joe" (string)
        }
        type = "MadeNewFriends" (string)
    }
    State changed to: {
        myPhoneNumber = "12345678" (string)
        myFriends = {
            1 = "Cassandra" (string)
            2 = "Joe" (string)
        }
    }
]]





return module