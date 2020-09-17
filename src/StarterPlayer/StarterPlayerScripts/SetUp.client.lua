local startGui = game.StarterGui
local cam = workspace.CurrentCamera

local camPos = Vector3.new(-40, 70, -40)

--replicate the guis, because the character not loading in doesn't replicate them :/
for _, gui in pairs(startGui:GetChildren()) do
	local cop = gui:Clone()
	cop.Parent = script.Parent.Parent.PlayerGui
end

--set up the camera
wait(1)
cam.CameraType = Enum.CameraType.Scriptable
cam.CFrame = CFrame.new(camPos, Vector3.new(90,2,90))
