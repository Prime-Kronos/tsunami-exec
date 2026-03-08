local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

pcall(function()
    for _, g in ipairs(game.CoreGui:GetChildren()) do
        if tostring(g.Name):sub(1,3) == "RHB" then g:Destroy() end
    end
end)

local S = {
    Aimbot    = false,
    SilentAim = false,
    ShowFOV   = false,
    FOVSize   = 100,
    AimPart   = "Head",
    ESP       = false,
    Speed     = false,
    SpeedVal  = 32,
    Noclip    = false,
    RapidFire = false,
    InfAmmo   = false,
    BunnyHop  = false,
    AntiAFK   = true,
    AutoShoot = false,
}

-- FOV
local fovDraw = Drawing.new("Circle")
fovDraw.Visible = false
fovDraw.Color = Color3.fromRGB(255, 50, 50)
fovDraw.Thickness = 2
fovDraw.NumSides = 60
fovDraw.Filled = false
fovDraw.Radius = S.FOVSize

RunService.RenderStepped:Connect(function()
    fovDraw.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovDraw.Radius = S.FOVSize
    fovDraw.Visible = S.ShowFOV
end)

-- Target finder
local function getTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, S.FOVSize + 1
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(S.AimPart) or p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestDist then bestDist = d; best = p end
                end
            end
        end
    end
    return best
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "RHB"..tostring(math.random(1000,9999))
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = game.CoreGui

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0,44,0,44)
openBtn.Position = UDim2.new(0,8,0.5,-22)
openBtn.BackgroundColor3 = Color3.fromRGB(190,25,25)
openBtn.Text = "⚡"
openBtn.TextSize = 20
openBtn.Font = Enum.Font.GothamBold
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.BorderSizePixel = 0
openBtn.ZIndex = 100
openBtn.Parent = sg
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,10)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,230,0,500)
panel.Position = UDim2.new(0,60,0.5,-250)
panel.BackgroundColor3 = Color3.fromRGB(11,11,17)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Visible = false
panel.ZIndex = 10
panel.Parent = sg
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,10)
local ps = Instance.new("UIStroke",panel)
ps.Color = Color3.fromRGB(190,25,25); ps.Thickness = 1.5

local topBar = Instance.new("Frame",panel)
topBar.Size = UDim2.new(1,0,0,36)
topBar.BackgroundColor3 = Color3.fromRGB(190,25,25)
topBar.BorderSizePixel = 0; topBar.ZIndex = 11
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,10)
local tf = Instance.new("Frame",topBar)
tf.Size = UDim2.new(1,0,0.5,0); tf.Position = UDim2.new(0,0,0.5,0)
tf.BackgroundColor3 = Color3.fromRGB(190,25,25); tf.BorderSizePixel = 0; tf.ZIndex = 11

local titleLbl = Instance.new("TextLabel",topBar)
titleLbl.Size = UDim2.new(1,-40,1,0); titleLbl.Position = UDim2.new(0,10,0,0)
titleLbl.BackgroundTransparency = 1; titleLbl.Text = "⚡ RIVALS HUB"
titleLbl.TextColor3 = Color3.fromRGB(255,255,255); titleLbl.TextSize = 13
titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 12

local closeBtn = Instance.new("TextButton",topBar)
closeBtn.Size = UDim2.new(0,26,0,26); closeBtn.Position = UDim2.new(1,-30,0.5,-13)
closeBtn.BackgroundColor3 = Color3.fromRGB(140,15,15); closeBtn.Text = "✕"
closeBtn.TextSize = 12; closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,6)

local scroll = Instance.new("ScrollingFrame",panel)
scroll.Size = UDim2.new(1,-4,1,-40); scroll.Position = UDim2.new(0,2,0,38)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(190,25,25)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ZIndex = 11

local ll = Instance.new("UIListLayout",scroll)
ll.Padding = UDim.new(0,4); ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
local pp = Instance.new("UIPadding",scroll)
pp.PaddingTop = UDim.new(0,6); pp.PaddingBottom = UDim.new(0,6)

local function section(txt)
    local f = Instance.new("TextLabel",scroll)
    f.Size = UDim2.new(1,-10,0,18); f.BackgroundColor3 = Color3.fromRGB(190,25,25)
    f.Text = "  "..txt; f.TextColor3 = Color3.fromRGB(255,255,255)
    f.TextSize = 10; f.Font = Enum.Font.GothamBold
    f.TextXAlignment = Enum.TextXAlignment.Left; f.BorderSizePixel = 0; f.ZIndex = 12
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,4)
    local g = Instance.new("UIGradient",f)
    g.Color = ColorSequence.new(Color3.fromRGB(200,30,30),Color3.fromRGB(100,10,10))
    g.Rotation = 90
end

local function toggle(label, key, cb)
    local row = Instance.new("Frame",scroll)
    row.Size = UDim2.new(1,-10,0,36); row.BackgroundColor3 = Color3.fromRGB(19,19,29)
    row.BorderSizePixel = 0; row.ZIndex = 12
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke",row); rs.Color = Color3.fromRGB(35,35,52); rs.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-56,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13

    local pill = Instance.new("Frame",row)
    pill.Size = UDim2.new(0,40,0,20); pill.Position = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = Color3.fromRGB(40,40,58); pill.BorderSizePixel = 0; pill.ZIndex = 13
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)

    local dot = Instance.new("Frame",pill)
    dot.Size = UDim2.new(0,14,0,14); dot.Position = UDim2.new(0,3,0.5,-7)
    dot.BackgroundColor3 = Color3.fromRGB(140,140,160); dot.BorderSizePixel = 0; dot.ZIndex = 14
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local tw = TweenInfo.new(0.15,Enum.EasingStyle.Quad)
    local function set(v)
        S[key] = v
        if v then
            TweenService:Create(pill,tw,{BackgroundColor3=Color3.fromRGB(190,25,25)}):Play()
            TweenService:Create(dot,tw,{Position=UDim2.new(0,23,0.5,-7),BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(pill,tw,{BackgroundColor3=Color3.fromRGB(40,40,58)}):Play()
            TweenService:Create(dot,tw,{Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=Color3.fromRGB(140,140,160)}):Play()
        end
        if cb then cb(v) end
    end
    local btn = Instance.new("TextButton",row)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 15
    btn.MouseButton1Click:Connect(function() set(not S[key]) end)
    set(S[key])
end

local function slider(label, key, mn, mx, cb)
    local row = Instance.new("Frame",scroll)
    row.Size = UDim2.new(1,-10,0,52); row.BackgroundColor3 = Color3.fromRGB(19,19,29)
    row.BorderSizePixel = 0; row.ZIndex = 12
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke",row); rs.Color = Color3.fromRGB(35,35,52); rs.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-54,0,26); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13

    local valLbl = Instance.new("TextLabel",row)
    valLbl.Size = UDim2.new(0,44,0,26); valLbl.Position = UDim2.new(1,-48,0,0)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(S[key])
    valLbl.TextSize = 11; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextColor3 = Color3.fromRGB(190,25,25)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 13

    local track = Instance.new("Frame",row)
    track.Size = UDim2.new(1,-16,0,5); track.Position = UDim2.new(0,8,0,34)
    track.BackgroundColor3 = Color3.fromRGB(35,35,52); track.BorderSizePixel = 0; track.ZIndex = 13
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame",track)
    fill.Size = UDim2.new((S[key]-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(190,25,25); fill.BorderSizePixel = 0; fill.ZIndex = 14
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame",track)
    thumb.Size = UDim2.new(0,13,0,13); thumb.AnchorPoint = Vector2.new(0.5,0.5)
    thumb.Position = UDim2.new((S[key]-mn)/(mx-mn),0,0.5,0)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255); thumb.BorderSizePixel = 0; thumb.ZIndex = 15
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)

    local drag = false
    local function upd(inp)
        local rel = math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val = math.floor(mn+rel*(mx-mn))
        S[key]=val; valLbl.Text=tostring(val)
        fill.Size=UDim2.new(rel,0,1,0); thumb.Position=UDim2.new(rel,0,0.5,0)
        if cb then cb(val) end
    end
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true;upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
    end)
end

-- Build UI
section("🎯 AIM")
toggle("Aimbot", "Aimbot", nil)
toggle("Silent Aim", "SilentAim", nil)
toggle("Auto Shoot", "AutoShoot", nil)
toggle("Show FOV", "ShowFOV", nil)
slider("FOV Size", "FOVSize", 30, 350, nil)

section("🔫 COMBAT")
toggle("Rapid Fire", "RapidFire", nil)
toggle("Infinite Ammo", "InfAmmo", nil)

section("🏃 MOVEMENT")
toggle("Speed Hack", "Speed", function(v)
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v and S.SpeedVal or 16 end end
end)
slider("Speed Value", "SpeedVal", 16, 120, function(v)
    if S.Speed then
        local c = LocalPlayer.Character
        if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end end
    end
end)
toggle("Bunny Hop", "BunnyHop", nil)
toggle("No Clip", "Noclip", nil)

section("👁️ VISUALS")
toggle("ESP", "ESP", function(v)
    if not v then
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("_h") if h then h:Destroy() end
            end
        end
    end
end)

section("⚙️ MISC")
toggle("Anti AFK", "AntiAFK", nil)

-- Open/close
local isOpen = false
local function setOpen(v)
    isOpen = v; panel.Visible = v
end
openBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not S.Aimbot then return end
    local t = getTarget()
    if t and t.Character then
        local part = t.Character:FindFirstChild(S.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
        if part then Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position) end
    end
end)

-- Silent Aim — при клике мыши
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not S.SilentAim then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local t = getTarget()
        if not t or not t.Character then return end
        local part = t.Character:FindFirstChild(S.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
        if not part then return end
        local orig = Camera.CFrame
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        task.delay(0.06, function() Camera.CFrame = orig end)
    end
end)

-- Auto Shoot
RunService.Heartbeat:Connect(function()
    if not S.AutoShoot then return end
    local t = getTarget()
    if not t or not t.Character then return end
    local part = t.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local _, vis = Camera:WorldToViewportPoint(part.Position)
    if vis then pcall(function() mouse1click() end) end
end)

-- Rapid Fire
RunService.Heartbeat:Connect(function()
    if not S.RapidFire then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = v.Name:lower()
            if n:find("cool") or n:find("delay") or n:find("wait") or n:find("debounce") then
                v.Value = 0
            end
        end
    end
end)

-- Infinite Ammo
RunService.Heartbeat:Connect(function()
    if not S.InfAmmo then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local n = v.Name:lower()
            if n:find("ammo") or n:find("mag") or n:find("bullet") or n:find("clip") then
                v.Value = 9999
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Bunny Hop
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if S.BunnyHop and i.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ESP
RunService.Heartbeat:Connect(function()
    if not S.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not p.Character:FindFirstChild("_h") then
                local hl = Instance.new("Highlight", p.Character)
                hl.Name = "_h"
                hl.FillColor = Color3.fromRGB(255,30,30)
                hl.OutlineColor = Color3.fromRGB(255,220,0)
                hl.FillTransparency = 0.5
            end
        end
    end
end)

-- Speed on respawn
LocalPlayer.CharacterAdded:Connect(function(c)
    local hum = c:WaitForChild("Humanoid")
    if S.Speed then hum.WalkSpeed = S.SpeedVal end
end)

-- Anti AFK
local VU = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if S.AntiAFK then
        VU:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.5)
        VU:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- Рандомное имя GUI каждые 60 сек
task.spawn(function()
    while task.wait(60) do
        pcall(function() sg.Name = "RHB"..tostring(math.random(1000,9999)) end)
    end
end)
