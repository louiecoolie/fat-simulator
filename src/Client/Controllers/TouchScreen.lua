local TouchScreen = {}

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

function TouchScreen.Bind(bound_function)
    print("binding mobile function")
    UserInputService.TouchTap:Connect(bound_function)
end

function TouchScreen.Unbind(bound_function)
    ContextActionService:UnbindAction(bound_function)
end


return TouchScreen