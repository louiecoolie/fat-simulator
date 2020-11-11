-- class to assign a color to a player
-- players can have a preferred color
-- if their preferred color is taken, they get the first available color from the color sequence

local defaultColorSequence = {"Bright red", "Bright blue", "Bright yellow", "Institutional white", "Bright orange", "Lime green", "Black", "Cyan", "Dark green", "Brown"}

local bodyPartsToColor = {"Plumage", "Tabard"}

local ColorAssigner = {}

local assignedColors -- dictionary key = color, value = player using color

function ColorAssigner:AssignColorToPlayer(player, preferred)
    local existingColor = ColorAssigner:GetPlayerColor(player) 
    if existingColor then
        assignedColors[existingColor] = nil
    end

    if preferred and not assignedColors[preferred] then
        assignedColors[preferred] = player
        return preferred
    else
        for i = 1, #defaultColorSequence do
            local color = defaultColorSequence[i]
            if not assignedColors[color] then
                assignedColors[color] = player
                return color
            end
        end
    end
end

function ColorAssigner:GetPlayerColor(plr)
    for color, player in pairs(assignedColors) do
        if player == plr then
            return color
        end
    end
end

function ColorAssigner:UnassignColorFromPlayer(plr, color)
    if not color then
        color = ColorAssigner:GetPlayerColor()
    end
    if assignedColors[color] == plr then
        assignedColors[color] = nil
    end
end

function ColorAssigner:ColorCharacter(plr)
    if plr.Character then
        local plrColor = ColorAssigner:GetPlayerColor(plr)
        for i = 1, #bodyPartsToColor do
            plr.Character:FindFirstChild("Character"):FindFirstChild("ColoredParts"):FindFirstChild(bodyPartsToColor[i]).BrickColor = BrickColor.new(plrColor)
        end
    end
end

function ColorAssigner:Init(getColorRemote)
    assignedColors = {}

    getColorRemote.OnServerInvoke = function(client, player)
        return ColorAssigner:GetPlayerColor(player)
    end
end

return ColorAssigner