local TextChatService = game:GetService("TextChatService")

local message = "Eu sou gay"

while true do
    TextChatService.TextChannels.RBXGeneral:SendAsync(message)
    task.wait(1)
end
