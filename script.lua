local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

if not torso then
	return
end

while true do
	local part = Instance.new("Part")
	part.Size = Vector3.new(2, 2, 2)
	part.CFrame = torso.CFrame
	part.Anchored = false
	part.CanCollide = false
	part.Parent = workspace
end
