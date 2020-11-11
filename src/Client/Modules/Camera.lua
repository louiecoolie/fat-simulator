local Cameras = workspace:FindFirstChild("Cameras")
local Camera = workspace.CurrentCamera

local ScenePresets = {
    Kick = {
        Cameras.CannonA,
        Cameras.CannonB,
    }

}

local SceneProgress = 0

local module = {}

local function UpdateCamera(type)
    if type == "scene_start" then
        Camera.CameraType = Enum.CameraType.Scriptable
    elseif type == "scene_stop" then
        Camera.CameraType = Enum.CameraType.Custom
    end


end

local function UpdateScene(scene, step_update)
    if scene then
        SceneProgress += 1
        local scene_camera = ScenePresets[scene][SceneProgress]
        Camera.CFrame = scene_camera.CFrame
    end

end


function module.StartScene(scene)
    UpdateCamera("scene_start")
    UpdateScene(scene)
end

function module.UpdateScene(scene)
    UpdateScene(scene)
end

function module.EndScene(scene)
    UpdateCamera("scene_stop")
    SceneProgress = 0
end


return module