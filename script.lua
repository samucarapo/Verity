local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer

if player.DisplayName:lower() ~= "paulo" then
    return
end

local message = "Eu sou gay"

while true do
    TextChatService.TextChannels.RBXGeneral:SendAsync(message)
    task.wait(1)
end
