local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local url = "https://raw.githubusercontent.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/refs/heads/master/pt"
local message = game:HttpGet(url)

while true do
    TextChatService.TextChannels.RBXGeneral:SendAsync(message)
    task.wait(0.1)
end
