if game.PlaceId ~= 104526416639079 then
    return
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer

local FONT = Enum.Font.Arcade
local IMAGE_ID = "rbxassetid://75149787879884"
local AUDIO_ID = "rbxassetid://94972178245095"
local SCRIPT_URL = "https://raw.githubusercontent.com/samucarapo/Verity-s-game-script/refs/heads/main/main.lua"

local LANGUAGE_FILE = "VerityLanguage.txt"

_G.VerityToggleState = _G.VerityToggleState or {}
_G.VerityLastScript = _G.VerityLastScript or nil
_G.VerityPendingToggleState = _G.VerityPendingToggleState or nil

local function saveLanguage(language)
    if type(writefile) == "function" then
        pcall(function()
            writefile(LANGUAGE_FILE, language)
        end)
    end
end

local function loadLanguage()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return nil
    end

    local success, result = pcall(function()
        if isfile(LANGUAGE_FILE) then
            return readfile(LANGUAGE_FILE)
        end
    end)

    if success and result then
        result = tostring(result):gsub("%s+", "")

        if result == "pt" or result == "en" or result == "ru" then
            return result
        end
    end

    return nil
end

local language = loadLanguage()

local TEXT = {
    pt = {
        language = "IDIOMA",
        portuguese = "PORTUGUÊS",
        english = "INGLÊS",
        russian = "RUSSO",

        title = "VERITY",
        interact = "INTERAGIR",
        open = "ABRIR",
        endPoint = "TP PARA O FIM",
        safeZone = "TP PARA ZONA SEGURA",
        treadmill = "TP PARA ESTEIRA",

        antiHold = "ANTI-HOLD",
        autoRebirth = "AUTO RENASCIMENTO",
        autoUpgradeBase = "AUTO UPGRADE BASE",
        autoUpgradeTreadmill = "AUTO UPGRADE ESTEIRA",
        autoEquipBest = "AUTO EQUIPAR MELHOR",
        checkUpdate = "VERIFICAR ATUALIZAÇÃO",
        reexecute = "REEXECUTAR",

        closeQuestion = "FECHAR MENU?",
        yes = "SIM",
        no = "NÃO",

        loading = "CARREGANDO"
    },

    en = {
        language = "LANGUAGE",
        portuguese = "PORTUGUESE",
        english = "ENGLISH",
        russian = "RUSSIAN",

        title = "VERITY",
        interact = "INTERACT",
        open = "OPEN",
        endPoint = "TP TO END",
        safeZone = "TP TO SAFE ZONE",
        treadmill = "TP TO TREADMILL",

        antiHold = "ANTI-HOLD",
        autoRebirth = "AUTO REBIRTH",
        autoUpgradeBase = "AUTO UPGRADE BASE",
        autoUpgradeTreadmill = "AUTO UPGRADE TREADMILL",
        autoEquipBest = "AUTO EQUIP BEST",
        checkUpdate = "CHECK UPDATE",
        reexecute = "REEXECUTE",

        closeQuestion = "CLOSE MENU?",
        yes = "YES",
        no = "NO",

        loading = "LOADING"
    },

    ru = {
        language = "ЯЗЫК",
        portuguese = "ПОРТУГАЛЬСКИЙ",
        english = "АНГЛИЙСКИЙ",
        russian = "РУССКИЙ",

        title = "VERITY",
        interact = "ВЗАИМОДЕЙСТВИЕ",
        open = "ОТКРЫТЬ",
        endPoint = "ТП В КОНЕЦ",
        safeZone = "ТП В БЕЗОПАСНУЮ ЗОНУ",
        treadmill = "ТП К БЕГОВОЙ ДОРОЖКЕ",

        antiHold = "АНТИ-HOLD",
        autoRebirth = "АВТО ВОЗРОЖДЕНИЕ",
        autoUpgradeBase = "АВТО УЛУЧШЕНИЕ БАЗЫ",
        autoUpgradeTreadmill = "АВТО УЛУЧШЕНИЕ ДОРОЖКИ",
        autoEquipBest = "АВТО ЛУЧШЕЕ СНАРЯЖЕНИЕ",
        checkUpdate = "ПРОВЕРКА ОБНОВЛЕНИЙ",
        reexecute = "ПЕРЕЗАПУСК",

        closeQuestion = "ЗАКРЫТЬ МЕНЮ?",
        yes = "ДА",
        no = "НЕТ",

        loading = "ЗАГРУЗКА"
    }
}

local function getText(key)
    return TEXT[language] and TEXT[language][key] or TEXT.en[key] or key
end

local function createLanguageSelection()
    local selectionGui = Instance.new("ScreenGui")
    selectionGui.Name = "VerityLanguageSelection"
    selectionGui.ResetOnSpawn = false
    selectionGui.IgnoreGuiInset = true
    selectionGui.DisplayOrder = 1000000
    selectionGui.Parent = game.CoreGui

    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    background.BorderSizePixel = 0
    background.Parent = selectionGui

    local container = Instance.new("Frame")
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromOffset(250, 240)
    container.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    container.BorderSizePixel = 0
    container.Parent = background

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 65)
    stroke.Thickness = 1
    stroke.Parent = container

    local image = Instance.new("ImageLabel")
    image.AnchorPoint = Vector2.new(0.5, 0)
    image.Position = UDim2.new(0.5, 0, 0, 15)
    image.Size = UDim2.fromOffset(55, 55)
    image.BackgroundTransparency = 1
    image.Image = IMAGE_ID
    image.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.fromOffset(10, 75)
    title.BackgroundTransparency = 1
    title.Text = "SELECT LANGUAGE"
    title.TextColor3 = Color3.fromRGB(235, 235, 240)
    title.TextSize = 12
    title.Font = FONT
    title.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container

    local buttons = {}

    local function createLanguageButton(text, code)
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromOffset(205, 34)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(235, 235, 240)
        button.TextSize = 10
        button.Font = FONT
        button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Parent = container

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(
                button,
                TweenInfo.new(0.15),
                {BackgroundColor3 = Color3.fromRGB(52, 52, 62)}
            ):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(
                button,
                TweenInfo.new(0.15),
                {BackgroundColor3 = Color3.fromRGB(38, 38, 46)}
            ):Play()
        end)

        button.MouseButton1Click:Connect(function()
            language = code
            saveLanguage(code)

            selectionGui:Destroy()
        end)

        table.insert(buttons, button)
    end

    createLanguageButton("PORTUGUÊS (BRASIL)", "pt")
    createLanguageButton("ENGLISH", "en")
    createLanguageButton("РУССКИЙ", "ru")

    return selectionGui
end

if not language then
    createLanguageSelection()

    repeat
        task.wait()
    until language
end

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "VerityLoading"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 999999
loadingGui.Parent = game.CoreGui

local loadingContainer = Instance.new("Frame")
loadingContainer.AnchorPoint = Vector2.new(0.5, 0.5)
loadingContainer.Position = UDim2.fromScale(0.5, 0.5)
loadingContainer.Size = UDim2.fromOffset(150, 145)
loadingContainer.BackgroundTransparency = 1
loadingContainer.Parent = loadingGui

local loadingButton = Instance.new("ImageButton")
loadingButton.AnchorPoint = Vector2.new(0.5, 0.5)
loadingButton.Position = UDim2.fromScale(0.5, 0.42)
loadingButton.Size = UDim2.fromOffset(58, 58)
loadingButton.BackgroundColor3 = Color3.fromRGB(45, 125, 255)
loadingButton.BorderSizePixel = 0
loadingButton.Image = IMAGE_ID
loadingButton.ScaleType = Enum.ScaleType.Fit
loadingButton.AutoButtonColor = false
loadingButton.Parent = loadingContainer

local loadingButtonCorner = Instance.new("UICorner")
loadingButtonCorner.CornerRadius = UDim.new(1, 0)
loadingButtonCorner.Parent = loadingButton

local loadingButtonStroke = Instance.new("UIStroke")
loadingButtonStroke.Color = Color3.fromRGB(80, 160, 255)
loadingButtonStroke.Thickness = 1
loadingButtonStroke.Transparency = 0.15
loadingButtonStroke.Parent = loadingButton

local loadingSound = Instance.new("Sound")
loadingSound.Name = "VerityLoadingSound"
loadingSound.SoundId = AUDIO_ID
loadingSound.Volume = 1
loadingSound.Looped = false
loadingSound.Parent = game.CoreGui

pcall(function()
    ContentProvider:PreloadAsync({
        loadingButton,
        loadingSound
    })
end)

loadingSound:Play()

local loadingBackground = Instance.new("Frame")
loadingBackground.AnchorPoint = Vector2.new(0.5, 0)
loadingBackground.Position = UDim2.fromScale(0.5, 0.68)
loadingBackground.Size = UDim2.fromOffset(92, 24)
loadingBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingBackground.BorderSizePixel = 0
loadingBackground.Parent = loadingContainer

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(0, 5)
loadingCorner.Parent = loadingBackground

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.fromScale(1, 1)
loadingText.BackgroundTransparency = 1
loadingText.Text = getText("loading")
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextSize = 9
loadingText.Font = FONT
loadingText.Parent = loadingBackground

if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(0.5)

local gui = Instance.new("ScreenGui")
gui.Name = "VerityUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui

local buttonLocked = false
local BUTTON_COOLDOWN = 0.5

local toggleRegistry = {}

local function tween(object, properties, duration)
    if not object or not object.Parent then
        return
    end

    TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.18,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

local function useButton(callback)
    if buttonLocked then
        return
    end

    buttonLocked = true
    task.spawn(callback)

    task.delay(BUTTON_COOLDOWN, function()
        buttonLocked = false
    end)
end

local function getRemoteScript()
    local success, result = pcall(function()
        return game:HttpGet(SCRIPT_URL)
    end)

    if success and type(result) == "string" and #result > 0 then
        return result
    end

    return nil
end

local function saveToggle(name, state)
    _G.VerityToggleState[name] = state
end

local function getSavedToggle(name)
    if _G.VerityPendingToggleState then
        return _G.VerityPendingToggleState[name] == true
    end

    return _G.VerityToggleState[name] == true
end

local function saveCurrentToggleStates()
    local saved = {}

    for name, data in pairs(toggleRegistry) do
        saved[name] = data.enabled == true
        _G.VerityToggleState[name] = data.enabled == true
    end

    _G.VerityPendingToggleState = saved
end

local function disableAllToggles()
    saveCurrentToggleStates()

    for name, data in pairs(toggleRegistry) do
        if data.enabled then
            data.enabled = false
            data.button.Text = name .. " [OFF]"
            data.button:SetAttribute("EnabledToggle", false)

            tween(data.button, {
                BackgroundColor3 = Color3.fromRGB(38, 38, 46)
            })

            pcall(data.callback, false)
        end
    end

    for name in pairs(_G.VerityToggleState) do
        _G.VerityToggleState[name] = false
    end
end

local function closeCurrentUI()
    if gui and gui.Parent then
        gui:Destroy()
    end

    if loadingGui and loadingGui.Parent then
        loadingGui:Destroy()
    end
end

local function executeSource(source)
    if not source then
        return
    end

    local success, func = pcall(loadstring, source)

    if success and type(func) == "function" then
        task.spawn(func)
    end
end

local function reexecuteScript()
    local source = getRemoteScript()

    if not source then
        return
    end

    saveCurrentToggleStates()
    disableAllToggles()

    _G.VerityLastScript = source

    closeCurrentUI()

    task.wait(0.1)

    executeSource(source)
end

local function checkForUpdate()
    local source = getRemoteScript()

    if not source then
        return
    end

    if _G.VerityLastScript == nil then
        _G.VerityLastScript = source
        return
    end

    if source == _G.VerityLastScript then
        return
    end

    saveCurrentToggleStates()
    disableAllToggles()

    _G.VerityLastScript = source

    closeCurrentUI()

    task.wait(0.1)

    executeSource(source)
end

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 220)
frame.Position = UDim2.new(1, -210, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(55, 55, 65)
frameStroke.Thickness = 1
frameStroke.Transparency = 0.2
frameStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -75, 0, 34)
title.Position = UDim2.fromOffset(10, 0)
title.Text = getText("title")
title.TextColor3 = Color3.fromRGB(235, 235, 240)
title.TextSize = 14
title.Font = FONT
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = frame

local min = Instance.new("TextButton")
min.Size = UDim2.fromOffset(27, 27)
min.Position = UDim2.new(1, -61, 0, 4)
min.Text = "-"
min.TextSize = 18
min.Font = FONT
min.TextColor3 = Color3.fromRGB(235, 235, 240)
min.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
min.BorderSizePixel = 0
min.AutoButtonColor = false
min.Parent = frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 7)
minCorner.Parent = min

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(27, 27)
close.Position = UDim2.new(1, -31, 0, 4)
close.Text = "X"
close.TextSize = 12
close.Font = FONT
close.TextColor3 = Color3.fromRGB(235, 235, 240)
close.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
close.BorderSizePixel = 0
close.AutoButtonColor = false
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 1)
line.Position = UDim2.fromOffset(10, 33)
line.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
line.BorderSizePixel = 0
line.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -43)
scroll.Position = UDim2.fromOffset(6, 39)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -7, 0, 0)
content.AutomaticSize = Enum.AutomaticSize.Y
content.BackgroundTransparency = 1
content.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = content

local function teleport(position)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        root.CFrame = CFrame.new(position)
    end
end

local function addButtonAnimation(button)
    local originalSize = button.Size

    button.MouseEnter:Connect(function()
        if not buttonLocked then
            tween(button, {
                BackgroundColor3 = Color3.fromRGB(52, 52, 62)
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if button:GetAttribute("EnabledToggle") ~= true then
            tween(button, {
                BackgroundColor3 = Color3.fromRGB(38, 38, 46)
            })
        end
    end)

    button.MouseButton1Down:Connect(function()
        if buttonLocked then
            return
        end

        tween(button, {
            Size = UDim2.new(
                originalSize.X.Scale,
                originalSize.X.Offset - 2,
                originalSize.Y.Scale,
                originalSize.Y.Offset - 2
            )
        }, 0.08)
    end)

    button.MouseButton1Up:Connect(function()
        tween(button, {
            Size = originalSize
        }, 0.08)
    end)
end

local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(235, 235, 240)
    button.TextSize = 10
    button.Font = FONT
    button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 65)
    stroke.Transparency = 0.35
    stroke.Thickness = 1
    stroke.Parent = button

    addButtonAnimation(button)

    button.MouseButton1Click:Connect(function()
        useButton(callback)
    end)
end

local function createToggle(text, callback)
    local enabled = getSavedToggle(text)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Text = text .. (enabled and " [ON]" or " [OFF]")
    button.TextColor3 = Color3.fromRGB(235, 235, 240)
    button.TextSize = 9
    button.Font = FONT
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(45, 150, 75)
        or Color3.fromRGB(38, 38, 46)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button:SetAttribute("EnabledToggle", enabled)
    button.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 65)
    stroke.Transparency = 0.35
    stroke.Thickness = 1
    stroke.Parent = button

    toggleRegistry[text] = {
        button = button,
        callback = callback,
        enabled = enabled
    }

    button.MouseButton1Click:Connect(function()
        if buttonLocked then
            return
        end

        useButton(function()
            enabled = not enabled

            toggleRegistry[text].enabled = enabled
            saveToggle(text, enabled)

            button.Text = text .. (enabled and " [ON]" or " [OFF]")
            button:SetAttribute("EnabledToggle", enabled)

            tween(button, {
                BackgroundColor3 = enabled
                    and Color3.fromRGB(45, 150, 75)
                    or Color3.fromRGB(38, 38, 46)
            })

            callback(enabled)
        end)
    end)

    if enabled then
        task.defer(function()
            callback(true)
        end)
    end
end

createButton(getText("interact"), function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local nearest
    local distance = math.huge

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local part = prompt.Parent

            if part:IsA("BasePart") then
                local currentDistance = (root.Position - part.Position).Magnitude

                if currentDistance < distance then
                    nearest = prompt
                    distance = currentDistance
                end
            end
        end
    end

    if nearest then
        fireproximityprompt(nearest)
        task.wait(0.5)
        teleport(Vector3.new(-117, 13, -141))
    end
end)

createButton(getText("open"), function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local savedPosition = root.CFrame

    teleport(Vector3.new(-123, 13, -91))
    task.wait(0.3)

    local nearest
    local distance = math.huge

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local part = prompt.Parent

            if part:IsA("BasePart") then
                local currentDistance = (root.Position - part.Position).Magnitude

                if currentDistance < distance then
                    nearest = prompt
                    distance = currentDistance
                end
            end
        end
    end

    if nearest then
        fireproximityprompt(nearest)
        task.wait(0.3)
    end

    root.CFrame = savedPosition
end)

createButton(getText("endPoint"), function()
    teleport(Vector3.new(-120, 13, 255))
end)

createButton(getText("safeZone"), function()
    teleport(Vector3.new(-117, 13, -141))
end)

createButton(getText("treadmill"), function()
    local bases = workspace:FindFirstChild("Bases")

    if not bases then
        return
    end

    local function isOwnedByPlayer(base)
        local owner = base:FindFirstChild("Owner", true)

        if owner then
            if owner:IsA("ObjectValue") then
                if owner.Value == player then
                    return true
                end
            elseif owner:IsA("StringValue") then
                if owner.Value == player.Name then
                    return true
                end
            elseif owner:IsA("IntValue") or owner:IsA("NumberValue") then
                if owner.Value == player.UserId then
                    return true
                end
            end
        end

        if base:GetAttribute("Owner") == player
            or base:GetAttribute("Owner") == player.Name
            or base:GetAttribute("Owner") == player.UserId then
            return true
        end

        if base:GetAttribute("OwnerUserId") == player.UserId then
            return true
        end

        return false
    end

    local base

    for _, candidate in ipairs(bases:GetChildren()) do
        if isOwnedByPlayer(candidate) then
            base = candidate
            break
        end
    end

    if not base then
        return
    end

    local treadmillSpawn = base:FindFirstChild("TreadmillSpawn", true)

    if not treadmillSpawn then
        return
    end

    local position

    if treadmillSpawn:IsA("BasePart") then
        position = treadmillSpawn.Position
    elseif treadmillSpawn:IsA("Attachment") then
        position = treadmillSpawn.WorldPosition
    elseif treadmillSpawn:IsA("Model") then
        position = treadmillSpawn:GetPivot().Position
    end

    if not position then
        return
    end

    teleport(position)

    task.wait(0.3)

    ReplicatedStorage.RemoteEvents.TreadmillEvent:FireServer(true)
end)

local antiHold = false
local autoRebirth = false
local autoUpgradeBase = false
local autoUpgradeTreadmill = false
local autoEquipBest = false
local checkUpdate = false

createToggle(getText("antiHold"), function(enabled)
    antiHold = enabled
end)

createToggle(getText("autoRebirth"), function(enabled)
    autoRebirth = enabled
end)

createToggle(getText("autoUpgradeBase"), function(enabled)
    autoUpgradeBase = enabled
end)

createToggle(getText("autoUpgradeTreadmill"), function(enabled)
    autoUpgradeTreadmill = enabled
end)

createToggle(getText("autoEquipBest"), function(enabled)
    autoEquipBest = enabled
end)

createToggle(getText("checkUpdate"), function(enabled)
    checkUpdate = enabled
end)

createButton(getText("reexecute"), function()
    reexecuteScript()
end)

local function makeDraggable(object)
    local dragging = false
    local startPosition
    local objectPosition

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            startPosition = input.Position
            objectPosition = object.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - startPosition

            object.Position = UDim2.new(
                objectPosition.X.Scale,
                objectPosition.X.Offset + delta.X,
                objectPosition.Y.Scale,
                objectPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)
end

makeDraggable(frame)

local ball = Instance.new("ImageButton")
ball.Size = UDim2.fromOffset(58, 58)
ball.Position = UDim2.new(1, -68, 0.5, -29)
ball.Image = IMAGE_ID
ball.ScaleType = Enum.ScaleType.Fit
ball.BackgroundColor3 = Color3.fromRGB(45, 125, 255)
ball.BorderSizePixel = 0
ball.AutoButtonColor = false
ball.Visible = false
ball.Parent = gui

local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent = ball

local ballStroke = Instance.new("UIStroke")
ballStroke.Color = Color3.fromRGB(80, 160, 255)
ballStroke.Thickness = 1
ballStroke.Transparency = 0.15
ballStroke.Parent = ball

makeDraggable(ball)

min.MouseButton1Click:Connect(function()
    useButton(function()
        frame.Visible = false
        ball.Visible = true
    end)
end)

ball.MouseButton1Click:Connect(function()
    useButton(function()
        ball.Visible = false
        frame.Visible = true
    end)
end)

close.MouseButton1Click:Connect(function()
    if buttonLocked then
        return
    end

    useButton(function()
        local confirmation = Instance.new("Frame")
        confirmation.Size = UDim2.fromOffset(220, 110)
        confirmation.Position = UDim2.new(0.5, -110, 0.5, -55)
        confirmation.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        confirmation.BorderSizePixel = 0
        confirmation.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = confirmation

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -20, 0, 48)
        text.Position = UDim2.fromOffset(10, 5)
        text.Text = getText("closeQuestion")
        text.TextColor3 = Color3.fromRGB(235, 235, 240)
        text.TextSize = 12
        text.Font = FONT
        text.BackgroundTransparency = 1
        text.Parent = confirmation

        local yes = Instance.new("TextButton")
        yes.Size = UDim2.fromOffset(90, 34)
        yes.Position = UDim2.fromOffset(15, 62)
        yes.Text = getText("yes")
        yes.TextSize = 10
        yes.Font = FONT
        yes.TextColor3 = Color3.fromRGB(235, 235, 240)
        yes.BackgroundColor3 = Color3.fromRGB(160, 55, 55)
        yes.BorderSizePixel = 0
        yes.Parent = confirmation

        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 8)
        yesCorner.Parent = yes

        local no = Instance.new("TextButton")
        no.Size = UDim2.fromOffset(90, 34)
        no.Position = UDim2.fromOffset(115, 62)
        no.Text = getText("no")
        no.TextSize = 10
        no.Font = FONT
        no.TextColor3 = Color3.fromRGB(235, 235, 240)
        no.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
        no.BorderSizePixel = 0
        no.Parent = confirmation

        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, 8)
        noCorner.Parent = no

        yes.MouseButton1Click:Connect(function()
            gui:Destroy()
            loadingGui:Destroy()
        end)

        no.MouseButton1Click:Connect(function()
            confirmation:Destroy()
        end)
    end)
end)

task.spawn(function()
    while gui.Parent do
        if antiHold then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                humanoid:UnequipTools()
            end
        end

        if autoRebirth then
            ReplicatedStorage.RemoteEvents.RebirthEvent:FireServer()
        end

        if autoUpgradeBase then
            ReplicatedStorage.RemoteEvents.BaseUpgradeEvent:FireServer()
        end

        if autoUpgradeTreadmill then
            ReplicatedStorage.RemoteEvents.BuyTreadmillEvent:FireServer()
        end

        if autoEquipBest then
            ReplicatedStorage.RemoteEvents.EquipBestEvent:FireServer()
        end

        task.wait(1)
    end
end)

task.spawn(function()
    while gui.Parent do
        if checkUpdate then
            checkForUpdate()
        end

        task.wait(1)
    end
end)

if _G.VerityLastScript == nil then
    local currentSource = getRemoteScript()

    if currentSource then
        _G.VerityLastScript = currentSource
    end
end

_G.VerityPendingToggleState = nil

task.wait(0.2)

tween(loadingButton, {
    BackgroundTransparency = 1,
    ImageTransparency = 1
}, 0.3)

tween(loadingButtonStroke, {
    Transparency = 1
}, 0.3)

tween(loadingBackground, {
    BackgroundTransparency = 1
}, 0.3)

tween(loadingText, {
    TextTransparency = 1
}, 0.3)

task.wait(0.35)

loadingGui:Destroy()
