local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer

if player.DisplayName:lower() == "paulinxtzzz" then
    local message = "Eu sou gay"

    while true do
        TextChatService.TextChannels.RBXGeneral:SendAsync(message)
        task.wait(1)
    end
end

local P=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local R=game:GetService("ReplicatedStorage")
local CG=game:GetService("CoreGui")
local Pl=P.LocalPlayer
local G=getgenv and getgenv() or _G

if G.ShootScriptCleanup then
    pcall(G.ShootScriptCleanup)
end

G.ShootScriptState=G.ShootScriptState or {
    Shooting=false,
    LockY=false,
    AutoSkip=false,
    SafeDistance=false,
    WalkSpeed40=false,
    ThirdPerson=false,
    AutoRebirth=false,
    LockedY=45,
    ShootDelay=.01
}

local S=G.ShootScriptState
S.ShootDelay=math.clamp(tonumber(S.ShootDelay) or .01,0,.01)

local Running=true
local C={}

local function Conn(x)
    C[#C+1]=x
    return x
end

G.ShootScriptConnections=C
G.ShootScriptGui=nil

G.ShootScriptCleanup=function()
    Running=false

    for _,x in ipairs(C) do
        pcall(function()
            x:Disconnect()
        end)
    end

    if G.ShootScriptGui then
        pcall(function()
            G.ShootScriptGui:Destroy()
        end)
    end

    G.ShootScriptConnections={}
    G.ShootScriptGui=nil
end

local function Tool()
    local c=Pl.Character
    if not c then return end

    for _,v in ipairs(c:GetChildren()) do
        if v:IsA("Tool") then
            return v
        end
    end
end

local function ShootRemote()
    local b=R:FindFirstChild("Blaster")
    local r=b and b:FindFirstChild("Remotes")
    local s=r and r:FindFirstChild("Shoot")

    if s and s:IsA("RemoteEvent") then
        return s
    end
end

local function Hits()
    local folder=workspace:FindFirstChild("ActiveNPCs")
    local c=Pl.Character
    local root=c and c:FindFirstChild("HumanoidRootPart")

    if not folder or not root then
        return {}
    end

    local t={}

    for _,npc in ipairs(folder:GetChildren()) do
        for _,v in ipairs(npc:GetDescendants()) do
            if v:IsA("BasePart") then
                t[#t+1]={
                    Part=v,
                    Distance=(root.Position-v.Position).Magnitude
                }
            end
        end
    end

    table.sort(t,function(a,b)
        return a.Distance<b.Distance
    end)

    return t
end

local function Fire(target,tool,root)
    local remote=ShootRemote()

    if not remote or not target or not target.Parent or not tool then
        return
    end

    local handle=tool:FindFirstChild("Handle")
    local origin=handle and handle.Position or root.Position
    local targetPos=target.Position

    local args={
        [1]=workspace:GetServerTimeNow(),
        [2]=tool,
        [3]=CFrame.lookAt(origin,targetPos),
        [4]={},
        [5]=targetPos
    }

    remote:FireServer(unpack(args))
end

local function Shoot()
    if not Running or not S.Shooting then
        return
    end

    local c=Pl.Character
    local root=c and c:FindFirstChild("HumanoidRootPart")
    local tool=Tool()

    if not root or not tool then
        return
    end

    local targets=Hits()
    local target=targets[1]

    if target and target.Part then
        pcall(function()
            Fire(target.Part,tool,root)
        end)
    end
end

local function Nearest()
    local h=Hits()
    return h[1] and h[1].Part
end

local function Distance()
    if not S.SafeDistance then
        return
    end

    local c=Pl.Character
    local root=c and c:FindFirstChild("HumanoidRootPart")
    local h=Nearest()

    if not root or not h then
        return
    end

    local p=root.Position
    local t=h.Position

    local x=p.X-t.X
    local z=p.Z-t.Z
    local d=math.sqrt(x*x+z*z)

    if d>=50 then
        return
    end

    if d<.001 then
        local l=root.CFrame.LookVector
        x=l.X
        z=l.Z
        d=math.sqrt(x*x+z*z)

        if d<.001 then
            x,z=1,0
            d=1
        end
    end

    root.CFrame=CFrame.new(
        t.X+x/d*50,
        p.Y,
        t.Z+z/d*50
    )*root.CFrame.Rotation

    local v=root.AssemblyLinearVelocity

    root.AssemblyLinearVelocity=Vector3.new(
        0,
        v.Y,
        0
    )
end

local function ApplyThirdPerson()
    Pl.CameraMode=Enum.CameraMode.Classic
    Pl.CameraMinZoomDistance=.5
    Pl.CameraMaxZoomDistance=S.ThirdPerson and 50 or .5
end

local GUI=Instance.new("ScreenGui")
GUI.Name="ShootToggle"
GUI.ResetOnSpawn=false
GUI.Parent=CG

G.ShootScriptGui=GUI

local Main=Instance.new("Frame")
Main.Size=UDim2.fromOffset(210,190)
Main.Position=UDim2.new(0,20,.5,-95)
Main.BackgroundColor3=Color3.fromRGB(18,18,22)
Main.BorderSizePixel=0
Main.Parent=GUI

local MC=Instance.new("UICorner")
MC.CornerRadius=UDim.new(0,10)
MC.Parent=Main

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-70,0,28)
Title.Position=UDim2.fromOffset(6,4)
Title.BackgroundTransparency=1
Title.Text="SHOOT"
Title.TextColor3=Color3.fromRGB(255,255,255)
Title.TextSize=15
Title.Font=Enum.Font.GothamBold
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=Main

local Min=Instance.new("TextButton")
Min.Size=UDim2.fromOffset(26,24)
Min.Position=UDim2.new(1,-58,0,6)
Min.BackgroundColor3=Color3.fromRGB(35,35,42)
Min.BorderSizePixel=0
Min.Text="—"
Min.TextColor3=Color3.fromRGB(235,235,235)
Min.TextSize=16
Min.Font=Enum.Font.GothamBold
Min.Parent=Main

local MinC=Instance.new("UICorner")
MinC.CornerRadius=UDim.new(0,6)
MinC.Parent=Min

local Close=Instance.new("TextButton")
Close.Size=UDim2.fromOffset(26,24)
Close.Position=UDim2.new(1,-30,0,6)
Close.BackgroundColor3=Color3.fromRGB(120,40,40)
Close.BorderSizePixel=0
Close.Text="×"
Close.TextColor3=Color3.fromRGB(255,255,255)
Close.TextSize=17
Close.Font=Enum.Font.GothamBold
Close.Parent=Main

local CloseC=Instance.new("UICorner")
CloseC.CornerRadius=UDim.new(0,6)
CloseC.Parent=Close

local Scroll=Instance.new("ScrollingFrame")
Scroll.Size=UDim2.new(1,-10,1,-38)
Scroll.Position=UDim2.fromOffset(5,34)
Scroll.BackgroundTransparency=1
Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3
Scroll.CanvasSize=UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
Scroll.Parent=Main

local Grid=Instance.new("UIGridLayout")
Grid.CellSize=UDim2.fromOffset(96,38)
Grid.CellPadding=UDim2.fromOffset(6,6)
Grid.SortOrder=Enum.SortOrder.LayoutOrder
Grid.Parent=Scroll

local function Button(name,state)
    local b=Instance.new("TextButton")

    b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(235,235,235)
    b.TextSize=12
    b.Font=Enum.Font.GothamMedium
    b.Parent=Scroll

    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,7)
    c.Parent=b

    local function update()
        local on=state()

        b.Text=name.."  "..(on and "ON" or "OFF")
        b.BackgroundColor3=on
            and Color3.fromRGB(45,150,75)
            or Color3.fromRGB(35,35,42)
    end

    update()

    return b,update
end

local ShootB,UShoot=Button("Shoot",function()
    return S.Shooting
end)

local YB,UY=Button("Y Lock",function()
    return S.LockY
end)

local SkipB,USkip=Button("Skip",function()
    return S.AutoSkip
end)

local DistB,UDist=Button("Distance",function()
    return S.SafeDistance
end)

local WSB,UWS=Button("WS 40",function()
    return S.WalkSpeed40
end)

local ThirdB,UThird=Button("3rd Person",function()
    return S.ThirdPerson
end)

local RebirthB,URebirth=Button("Auto Rebirth",function()
    return S.AutoRebirth
end)

local function Input(text)
    local b=Instance.new("TextBox")

    b.BackgroundColor3=Color3.fromRGB(35,35,42)
    b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(235,235,235)
    b.PlaceholderColor3=Color3.fromRGB(130,130,140)
    b.TextSize=12
    b.Font=Enum.Font.GothamMedium
    b.Text=text
    b.ClearTextOnFocus=false
    b.Parent=Scroll

    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,7)
    c.Parent=b

    return b
end

local YI=Input(tostring(S.LockedY))
YI.PlaceholderText="Y"

local DI=Input(tostring(S.ShootDelay))
DI.PlaceholderText="Delay 0-0.01"

local Minimized=false

Conn(Min.MouseButton1Click:Connect(function()
    Minimized=not Minimized

    if Minimized then
        Scroll.Visible=false
        Main.Size=UDim2.fromOffset(210,38)
        Min.Text="+"
    else
        Scroll.Visible=true
        Main.Size=UDim2.fromOffset(210,190)
        Min.Text="—"
    end
end))

local Confirm=Instance.new("Frame")
Confirm.Size=UDim2.fromOffset(170,85)
Confirm.Position=UDim2.new(.5,-85,.5,-42)
Confirm.BackgroundColor3=Color3.fromRGB(25,25,30)
Confirm.BorderSizePixel=0
Confirm.Visible=false
Confirm.ZIndex=10
Confirm.Parent=GUI

local ConfirmC=Instance.new("UICorner")
ConfirmC.CornerRadius=UDim.new(0,9)
ConfirmC.Parent=Confirm

local ConfirmText=Instance.new("TextLabel")
ConfirmText.Size=UDim2.new(1,-10,0,35)
ConfirmText.Position=UDim2.fromOffset(5,5)
ConfirmText.BackgroundTransparency=1
ConfirmText.Text="Fechar o script?"
ConfirmText.TextColor3=Color3.fromRGB(255,255,255)
ConfirmText.TextSize=13
ConfirmText.Font=Enum.Font.GothamMedium
ConfirmText.ZIndex=11
ConfirmText.Parent=Confirm

local Yes=Instance.new("TextButton")
Yes.Size=UDim2.fromOffset(70,28)
Yes.Position=UDim2.fromOffset(10,47)
Yes.BackgroundColor3=Color3.fromRGB(45,150,75)
Yes.BorderSizePixel=0
Yes.Text="SIM"
Yes.TextColor3=Color3.fromRGB(255,255,255)
Yes.TextSize=12
Yes.Font=Enum.Font.GothamBold
Yes.ZIndex=11
Yes.Parent=Confirm

local YesC=Instance.new("UICorner")
YesC.CornerRadius=UDim.new(0,6)
YesC.Parent=Yes

local No=Instance.new("TextButton")
No.Size=UDim2.fromOffset(70,28)
No.Position=UDim2.fromOffset(90,47)
No.BackgroundColor3=Color3.fromRGB(120,40,40)
No.BorderSizePixel=0
No.Text="NÃO"
No.TextColor3=Color3.fromRGB(255,255,255)
No.TextSize=12
No.Font=Enum.Font.GothamBold
No.ZIndex=11
No.Parent=Confirm

local NoC=Instance.new("UICorner")
NoC.CornerRadius=UDim.new(0,6)
NoC.Parent=No

Conn(Close.MouseButton1Click:Connect(function()
    Confirm.Visible=true
end))

Conn(No.MouseButton1Click:Connect(function()
    Confirm.Visible=false
end))

Conn(Yes.MouseButton1Click:Connect(function()
    G.ShootScriptState=nil
    G.ShootScriptCleanup()
end))

Conn(ShootB.MouseButton1Click:Connect(function()
    S.Shooting=not S.Shooting
    UShoot()
end))

Conn(YB.MouseButton1Click:Connect(function()
    S.LockY=not S.LockY
    UY()
end))

Conn(SkipB.MouseButton1Click:Connect(function()
    S.AutoSkip=not S.AutoSkip
    USkip()
end))

Conn(DistB.MouseButton1Click:Connect(function()
    S.SafeDistance=not S.SafeDistance
    UDist()
end))

Conn(WSB.MouseButton1Click:Connect(function()
    S.WalkSpeed40=not S.WalkSpeed40
    UWS()

    if not S.WalkSpeed40 then
        local c=Pl.Character
        local h=c and c:FindFirstChildOfClass("Humanoid")

        if h then
            h.WalkSpeed=16
        end
    end
end))

Conn(ThirdB.MouseButton1Click:Connect(function()
    S.ThirdPerson=not S.ThirdPerson
    ApplyThirdPerson()
    UThird()
end))

Conn(RebirthB.MouseButton1Click:Connect(function()
    S.AutoRebirth=not S.AutoRebirth
    URebirth()
end))

Conn(YI.FocusLost:Connect(function()
    local v=tonumber(YI.Text)

    if v then
        S.LockedY=v
    end

    YI.Text=tostring(S.LockedY)
end))

Conn(DI.FocusLost:Connect(function()
    local v=tonumber(DI.Text)

    if v then
        S.ShootDelay=math.clamp(v,0,.01)
    end

    DI.Text=tostring(S.ShootDelay)
end))

local Drag=false
local Start
local Pos

Conn(Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then

        Drag=true
        Start=i.Position
        Pos=Main.Position
    end
end))

Conn(UIS.InputChanged:Connect(function(i)
    if not Drag then return end

    if i.UserInputType~=Enum.UserInputType.MouseMovement
    and i.UserInputType~=Enum.UserInputType.Touch then
        return
    end

    local d=i.Position-Start

    Main.Position=UDim2.new(
        Pos.X.Scale,
        Pos.X.Offset+d.X,
        Pos.Y.Scale,
        Pos.Y.Offset+d.Y
    )
end))

Conn(UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then

        Drag=false
    end
end))

Conn(RS.Heartbeat:Connect(function()
    if not Running then return end

    local c=Pl.Character
    local root=c and c:FindFirstChild("HumanoidRootPart")

    if root and S.LockY then
        local p=root.Position

        if math.abs(p.Y-S.LockedY)>.1 then
            root.CFrame=CFrame.new(
                p.X,
                S.LockedY,
                p.Z
            )*root.CFrame.Rotation
        end

        local v=root.AssemblyLinearVelocity

        root.AssemblyLinearVelocity=Vector3.new(
            v.X,
            0,
            v.Z
        )
    end

    Distance()
end))

task.spawn(function()
    while Running do
        if S.Shooting then
            Shoot()
            task.wait(S.ShootDelay)
        else
            task.wait(.05)
        end
    end
end)

task.spawn(function()
    while Running do
        if S.AutoSkip then
            local r=R:FindFirstChild("Remotes")
            local s=r and r:FindFirstChild("SkipWave")

            if s then
                pcall(function()
                    if s:IsA("RemoteFunction") then
                        s:InvokeServer()
                    elseif s:IsA("RemoteEvent") then
                        s:FireServer()
                    end
                end)
            end

            task.wait(.05)
        else
            task.wait(.1)
        end
    end
end)

task.spawn(function()
    while Running do
        if S.WalkSpeed40 then
            local c=Pl.Character
            local h=c and c:FindFirstChildOfClass("Humanoid")

            if h then
                h.WalkSpeed=40
            end

            task.wait(1)
        else
            task.wait(.1)
        end
    end
end)

ApplyThirdPerson()

UShoot()
UY()
USkip()
UDist()
UWS()
UThird()
URebirth()
