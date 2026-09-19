local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

if game.PlaceId ~= 104526416639079 then
    return
end

local Player = Players.LocalPlayer
local GUI_NAME = "PromptInteractor"

local LOOP_DELAY = 0.5
local INTERACT_DELAY = 0.5
local BUTTON_COOLDOWN = 0.5

local BOX_POSITION = Vector3.new(-124, 13, -134)
local END_POSITION = Vector3.new(-125, 13, 242)

-- Posição fixa usada pelo Open
local OPEN_POSITION = Vector3.new(-123, 13, -91)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local TreadmillEvent = RemoteEvents:FindFirstChild("TreadmillEvent")
local BuyTreadmillEvent = RemoteEvents:FindFirstChild("BuyTreadmillEvent")
local BaseUpgradeEvent = RemoteEvents:FindFirstChild("BaseUpgradeEvent")
local DropBoxEvent = RemoteEvents:FindFirstChild("DropBoxEvent")
local RebirthEvent = RemoteEvents:FindFirstChild("RebirthEvent")
local EquipBestEvent = RemoteEvents:FindFirstChild("EquipBestEvent")

local ForceAngerEnabled = false
local AntiHoldEnabled = false
local AutoUpgradeTreadmillEnabled = false
local AutoUpgradeBaseEnabled = false
local AutoRebirthEnabled = false
local AutoEquipBestEnabled = false
local GoTreadmillAfterInteractEnabled = false

local LastButtonPress = 0
local SavedOpenPosition = nil

local OldGui = CoreGui:FindFirstChild(GUI_NAME)
if OldGui then
    OldGui:Destroy()
end

local function GetRoot()
    local Character = Player.Character
    if not Character then
        return nil
    end

    return Character:FindFirstChild("HumanoidRootPart")
end

local function Teleport(Position)
    local Root = GetRoot()

    if not Root or not Position then
        return false
    end

    Root.CFrame = CFrame.new(Position)
    return true
end

local function UsePrompt(Prompt)
    if not Prompt or not Prompt:IsA("ProximityPrompt") then
        return false
    end

    if not Prompt.Enabled then
        return false
    end

    if fireproximityprompt then
        fireproximityprompt(Prompt)
        return true
    end

    Prompt:InputHoldBegin()
    task.wait(0.05)
    Prompt:InputHoldEnd()

    return true
end

local function GetClosestPrompt()
    local Root = GetRoot()

    if not Root then
        return nil
    end

    local ClosestPrompt = nil
    local ClosestDistance = math.huge

    for _, Object in ipairs(workspace:GetDescendants()) do
        if Object:IsA("ProximityPrompt") and Object.Enabled then
            local Parent = Object.Parent

            if Parent and Parent:IsA("BasePart") then
                local Distance = (Root.Position - Parent.Position).Magnitude

                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestPrompt = Object
                end
            end
        end
    end

    return ClosestPrompt
end

local function Interact()
    local Prompt = GetClosestPrompt()

    if Prompt then
        UsePrompt(Prompt)
        return true
    end

    return false
end

local function FindPlayerTreadmill()
    local Bases = workspace:FindFirstChild("Bases")

    if not Bases then
        return nil
    end

    for _, Base in ipairs(Bases:GetChildren()) do
        local IsMine = false

        local Owner = Base:FindFirstChild("Owner")

        if Owner then
            if Owner:IsA("ObjectValue") and Owner.Value == Player then
                IsMine = true
            elseif Owner:IsA("StringValue") and Owner.Value == Player.Name then
                IsMine = true
            end
        end

        if Base:GetAttribute("Owner") == Player.Name then
            IsMine = true
        end

        if Base:GetAttribute("OwnerUserId") == Player.UserId then
            IsMine = true
        end

        if IsMine then
            local Treadmill = Base:FindFirstChild("Treadmill", true)

            if Treadmill then
                return Treadmill
            end
        end
    end

    return nil
end

local function ActivateTreadmill()
    local Treadmill = FindPlayerTreadmill()

    if not Treadmill then
        return false
    end

    local Spawn = Treadmill:FindFirstChild("TreadmillSpawn", true)

    if not Spawn then
        Spawn = Treadmill:FindFirstChild("Spawn", true)
    end

    if Spawn and Spawn:IsA("BasePart") then
        Teleport(Spawn.Position)
    end

    if TreadmillEvent then
        TreadmillEvent:FireServer(true)
    end

    return true
end

local function Open()
    local Root = GetRoot()

    if not Root then
        return
    end

    -- Salva a posição atual antes de fazer qualquer coisa
    SavedOpenPosition = Root.Position

    -- Vai para a posição fixa do Open
    Teleport(OPEN_POSITION)

    -- Espera 0.3 antes de interagir
    task.wait(0.3)

    -- Interage com o prompt
    local Prompt = GetClosestPrompt()

    if Prompt then
        UsePrompt(Prompt)
    end

    -- Espera 0.3 depois da interação
    task.wait(0.3)

    -- Volta exatamente para a posição salva
    if SavedOpenPosition then
        Teleport(SavedOpenPosition)
    end
end

local function InteractAndTeleport()
    Interact()

    task.wait(INTERACT_DELAY)

    if GoTreadmillAfterInteractEnabled then
        ActivateTreadmill()
    else
        Teleport(BOX_POSITION)
    end
end

local function ForceAnger()
    while ForceAngerEnabled do
        local Prompt = GetClosestPrompt()

        if Prompt then
            UsePrompt(Prompt)
        end

        task.wait(0.5)

        if not ForceAngerEnabled then
            break
        end

        if DropBoxEvent then
            DropBoxEvent:FireServer()
        end

        task.wait(0.3)
    end
end

local function UpgradeTreadmill()
    if BuyTreadmillEvent then
        BuyTreadmillEvent:FireServer()
    end
end

local function UpgradeBase()
    if BaseUpgradeEvent then
        BaseUpgradeEvent:FireServer()
    end
end

local function Rebirth()
    if RebirthEvent then
        RebirthEvent:FireServer()
    end
end

local function EquipBest()
    if EquipBestEvent then
        EquipBestEvent:FireServer()
    end
end

task.spawn(function()
    while task.wait(LOOP_DELAY) do
        if AutoUpgradeTreadmillEnabled then
            UpgradeTreadmill()
        end

        if AutoUpgradeBaseEnabled then
            UpgradeBase()
        end

        if AutoRebirthEnabled then
            Rebirth()
        end

        if AutoEquipBestEnabled then
            EquipBest()
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 270)
Main.Position = UDim2.new(0.5, -110, 0.5, -135)
Main.BackgroundColor3 = Color3.fromRGB(20, 21, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 8)
HeaderFix.Position = UDim2.new(0, 0, 1, -8)
HeaderFix.BackgroundColor3 = Header.BackgroundColor3
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Verity's Game"
Title.TextColor3 = Color3.fromRGB(235, 235, 235)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 25, 0, 25)
Minimize.Position = UDim2.new(1, -58, 0, 4)
Minimize.BackgroundColor3 = Color3.fromRGB(38, 40, 46)
Minimize.BorderSizePixel = 0
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(220, 220, 220)
Minimize.TextSize = 16
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -29, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(38, 40, 46)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.TextSize = 17
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = Close

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -12, 1, -42)
Content.Position = UDim2.new(0, 6, 0, 37)
Content.BackgroundTransparency = 1
Content.Parent = Main

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = Content

local function CreateRow(Order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = Order
    Row.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Row

    return Row
end

local function CreateButton(Parent, Text)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.5, -3, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(38, 40, 46)
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(230, 230, 230)
    Button.TextSize = 10
    Button.Font = Enum.Font.GothamMedium
    Button.Parent = Parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    return Button
end

local function CreateToggle(Parent, Text)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.5, -3, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(38, 40, 46)
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Text = Text .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(230, 230, 230)
    Button.TextSize = 10
    Button.Font = Enum.Font.GothamMedium
    Button.Parent = Parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    return Button
end

local function AddButtonEffect(Button)
    local OriginalSize = Button.Size

    Button.MouseButton1Down:Connect(function()
        Button.Size = UDim2.new(
            OriginalSize.X.Scale,
            OriginalSize.X.Offset - 2,
            OriginalSize.Y.Scale,
            OriginalSize.Y.Offset - 2
        )
    end)

    Button.MouseButton1Up:Connect(function()
        Button.Size = OriginalSize
    end)

    Button.MouseLeave:Connect(function()
        Button.Size = OriginalSize
    end)
end

local function SetToggleVisual(Button, Enabled, Text)
    Button.Text = Text .. ": " .. (Enabled and "ON" or "OFF")

    Button.BackgroundColor3 = Enabled
        and Color3.fromRGB(45, 150, 80)
        or Color3.fromRGB(38, 40, 46)
end

local function StartCooldown()
    local Now = tick()

    if Now - LastButtonPress < BUTTON_COOLDOWN then
        return false
    end

    LastButtonPress = Now
    return true
end

local Row1 = CreateRow(1)
local InteractButton = CreateButton(Row1, "Interact")
local TeleportEndButton = CreateButton(Row1, "Teleport to End")

local Row2 = CreateRow(2)
local OpenButton = CreateButton(Row2, "Open")
local TreadmillButton = CreateButton(Row2, "TP Treadmill")

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(55, 57, 64)
Divider.BorderSizePixel = 0
Divider.LayoutOrder = 3
Divider.Parent = Content

local Row3 = CreateRow(4)
local ForceAngerButton = CreateToggle(Row3, "Force Anger")
local AntiHoldButton = CreateToggle(Row3, "Anti Hold")

local Row4 = CreateRow(5)
local UpgradeTreadmillButton = CreateToggle(Row4, "Upgrade Treadmill")
local UpgradeBaseButton = CreateToggle(Row4, "Upgrade Base")

local Row5 = CreateRow(6)
local AutoRebirthButton = CreateToggle(Row5, "Auto Rebirth")
local AutoEquipBestButton = CreateToggle(Row5, "Auto Equip Best")

local Row6 = CreateRow(7)
local GoTreadmillButton = CreateToggle(Row6, "Go Treadmill After")
local Empty = Instance.new("Frame")
Empty.Size = UDim2.new(0.5, -3, 1, 0)
Empty.BackgroundTransparency = 1
Empty.Parent = Row6

AddButtonEffect(InteractButton)
AddButtonEffect(TeleportEndButton)
AddButtonEffect(OpenButton)
AddButtonEffect(TreadmillButton)

InteractButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    InteractAndTeleport()
end)

TeleportEndButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    Teleport(END_POSITION)
end)

OpenButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    task.spawn(Open)
end)

TreadmillButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    ActivateTreadmill()
end)

ForceAngerButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    ForceAngerEnabled = not ForceAngerEnabled

    SetToggleVisual(
        ForceAngerButton,
        ForceAngerEnabled,
        "Force Anger"
    )

    if ForceAngerEnabled then
        task.spawn(ForceAnger)
    end
end)

AntiHoldButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    AntiHoldEnabled = not AntiHoldEnabled

    SetToggleVisual(
        AntiHoldButton,
        AntiHoldEnabled,
        "Anti Hold"
    )
end)

UpgradeTreadmillButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    AutoUpgradeTreadmillEnabled = not AutoUpgradeTreadmillEnabled

    SetToggleVisual(
        UpgradeTreadmillButton,
        AutoUpgradeTreadmillEnabled,
        "Upgrade Treadmill"
    )
end)

UpgradeBaseButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    AutoUpgradeBaseEnabled = not AutoUpgradeBaseEnabled

    SetToggleVisual(
        UpgradeBaseButton,
        AutoUpgradeBaseEnabled,
        "Upgrade Base"
    )
end)

AutoRebirthButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    AutoRebirthEnabled = not AutoRebirthEnabled

    SetToggleVisual(
        AutoRebirthButton,
        AutoRebirthEnabled,
        "Auto Rebirth"
    )
end)

AutoEquipBestButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    AutoEquipBestEnabled = not AutoEquipBestEnabled

    SetToggleVisual(
        AutoEquipBestButton,
        AutoEquipBestEnabled,
        "Auto Equip Best"
    )
end)

GoTreadmillButton.MouseButton1Click:Connect(function()
    if not StartCooldown() then
        return
    end

    GoTreadmillAfterInteractEnabled = not GoTreadmillAfterInteractEnabled

    SetToggleVisual(
        GoTreadmillButton,
        GoTreadmillAfterInteractEnabled,
        "Go Treadmill After"
    )
end)

local AntiHoldConnection

local function UpdateAntiHold()
    if not AntiHoldEnabled then
        return
    end

    local Character = Player.Character

    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid:GetState() == Enum.HumanoidStateType.Seated then
        Humanoid.Sit = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

AntiHoldConnection = game:GetService("RunService").Heartbeat:Connect(UpdateAntiHold)

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
        and Input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = Input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )
end)

local Minimized = false
local NormalSize = Main.Size

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    if Minimized then
        Content.Visible = false
        Main.Size = UDim2.new(0, 220, 0, 32)
        Minimize.Text = "+"
    else
        Content.Visible = true
        Main.Size = NormalSize
        Minimize.Text = "-"
    end
end)

Close.MouseButton1Click:Connect(function()
    ForceAngerEnabled = false
    AntiHoldEnabled = false
    AutoUpgradeTreadmillEnabled = false
    AutoUpgradeBaseEnabled = false
    AutoRebirthEnabled = false
    AutoEquipBestEnabled = false
    GoTreadmillAfterInteractEnabled = false

    if AntiHoldConnection then
        AntiHoldConnection:Disconnect()
    end

    ScreenGui:Destroy()
end)
