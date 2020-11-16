local Scales = {
    store = {
        growth = {
            base= 12.5, 
            rate= 0.69315
        },
        cost = {
            base=37.5,
            rate=0.6931,
        }
    },
    power = {
        growth = {
            base = 0.6316,
            rate = 0.956 
        },
        cost = {
            base = 5.151,
            rate = 1.5256
        }
    }

}



local module = {}

local function calculate(category, type, level)
    local base = Scales[category][type].base
    local rate = Scales[category][type].rate

    local result = base * math.exp(rate*level)
    return result

end



function module.Calculate(category, type, level)
    return math.ceil(calculate(category, type, level))
end

return module 