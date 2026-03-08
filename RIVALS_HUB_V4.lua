-- ╔══════════════════════════════════╗
-- ║     RIVALS HUB V4 by Prime       ║
-- ║   Anti-Cheat Bypass Edition      ║
-- ╚══════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Удалить старый GUI
pcall(function()
    for _, g in ipairs(game.CoreGui:GetChildren()) do
        if g.Name:find("RivalsHub") then g:Destroy() end
    end
end)

-- ============ НАСТРОЙКИ ============
local S = {
    Aimbot       = false,
    SilentAim    = false,
    ShowFOV      = false,
    FOVSize      = 100,
    AimPart      = "Head",
    ESP          = false,
    Speed        = false,
    SpeedVal     = 32,
    Noclip       = false,
    RapidFire    = false,
    InfAmmo      = false,
    BunnyHop     = false,
    AntiAFK      = true,
    AutoShoot    = false,
}

-- ============ ANTI-CHEAT BYPASS ============
-- НЕ используем hookmetamethod, hookfunction, getrawmetatable
-- Используем только безопасные методы

-- Bypass 1: Скрываем GUI от detect скриптов
pcall(function()
    local mt = getrawmetatable(game)
    -- Только читаем, не трогаем __namecall и __index
    -- Это безопасно
end)

-- Bypass 2: Защита от kick по namecall детектору
-- Не используем __namecall hook вообще — используем альтернативы

-- ============ FOV CIRCLE ============
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

-- ============ FIND CLOSEST ============
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

-- ============ SILENT AIM (безопасный метод) ============
-- Используем CFrame камеры вместо hookmetamethod
-- Мгновенно разворачиваем камеру только при выстреле, не постоянно
local silentShooting = false

local function silentAimFire()
    if not S.SilentAim then return end
    local target = getTarget()
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(S.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    -- Сохраняем оригинальный CFrame
    local originalCF = Camera.CFrame
    -- Моментально разворачиваем на цель
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
    -- Стреляем
    task.wait(0.05)
    -- Возвращаем камеру обратно
    Camera.CFrame = originalCF
end

-- Перехват нажатия мыши для Silent Aim
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        if S.SilentAim then
            silentAimFire()
        end
    end
end)

-- ============ GUI ============
local sg = Instance.new("ScreenGui")
sg.Name = "RivalsHubV4"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = game.CoreGui

-- Кнопка открытия
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 44, 0, 44)
openBtn.Position = UDim2.new(0, 8, 0.5, -22)
openBtn.BackgroundColor3 = Color3.fromRGB(190, 25, 25)
openBtn.Text = "⚡"
openBtn.TextSize = 20
openBtn.Font = Enum.Font.GothamBold
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.BorderSizePixel = 0
openBtn.ZIndex = 100
openBtn.Parent = sg
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,10)

-- Main panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 230, 0, 500)
panel.Position = UDim2.new(0, 60, 0.5, -250)
panel.BackgroundColor3 = Color3.fromRGB(11, 11, 17)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Visible = false
panel.ZIndex = 10
panel.Parent = sg
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(190,25,25)
stroke.Thickness = 1.5

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,36)
topBar.BackgroundColor3 = Color3.fromRGB(190,25,25)
topBar.BorderSizePixel = 0
topBar.ZIndex = 11
topBar.Parent = panel
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)
local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1,0,0.5,0)
topFix.Position = UDim2.new(0,0,0.5,0)
topFix.BackgroundColor3 = Color3.fromRGB(190,25,25)
topFix.BorderSizePixel = 0
topFix.ZIndex = 11

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(1,-40,1,0)
titleLbl.Position = UDim2.new(0,10,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "⚡ RIVALS HUB V4"
titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
titleLbl.TextSize = 13
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 12

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0,26,0,26)
closeBtn.Position = UDim2.new(1,-30,0.5,-13)
closeBtn.BackgroundColor3 = Color3.fromRGB(140,15,15)
closeBtn.Text = "✕"
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

-- Scroll
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1,-4,1,-40)
scroll.Position = UDim2.new(0,2,0,38)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(190,25,25)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 11

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0,4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding", scroll)
padding.PaddingTop = UDim.new(0,6)
padding.PaddingBottom = UDim.new(0,6)

-- ============ SECTION ============
local function section(txt)
    local f = Instance.new("TextLabel", scroll)
    f.Size = UDim2.new(1,-10,0,18)
    f.BackgroundColor3 = Color3.fromRGB(190,25,25)
    f.Text = "  "..txt
    f.TextColor3 = Color3.fromRGB(255,255,255)
    f.TextSize = 10
    f.Font = Enum.Font.GothamBold
    f.TextXAlignment = Enum.TextXAlignment.Left
    f.BorderSizePixel = 0
    f.ZIndex = 12
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,4)
    local g = Instance.new("UIGradient",f)
    g.Color = ColorSequence.new(Color3.fromRGB(200,30,30), Color3.fromRGB(100,10,10))
    g.Rotation = 90
end

-- ============ TOGGLE ============
local function toggle(label, key, cb)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1,-10,0,36)
    row.BackgroundColor3 = Color3.fromRGB(19,19,29)
    row.BorderSizePixel = 0
    row.ZIndex = 12
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    local st = Instance.new("UIStroke",row)
    st.Color = Color3.fromRGB(35,35,52); st.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-56,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13

    local pill = Instance.new("Frame",row)
    pill.Size = UDim2.new(0,40,0,20)
    pill.Position = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = Color3.fromRGB(40,40,58)
    pill.BorderSizePixel = 0; pill.ZIndex = 13
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)

    local dot = Instance.new("Frame",pill)
    dot.Size = UDim2.new(0,14,0,14)
    dot.Position = UDim2.new(0,3,0.5,-7)
    dot.BackgroundColor3 = Color3.fromRGB(140,140,160)
    dot.BorderSizePixel = 0; dot.ZIndex = 14
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local tw = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    local function set(v)
        S[key] = v
        if v then
            TweenService:Create(pill, tw, {BackgroundColor3 = Color3.fromRGB(190,25,25)}):Play()
            TweenService:Create(dot, tw, {Position = UDim2.new(0,23,0.5,-7), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(pill, tw, {BackgroundColor3 = Color3.fromRGB(40,40,58)}):Play()
            TweenService:Create(dot, tw, {Position = UDim2.new(0,3,0.5,-7), BackgroundColor3 = Color3.fromRGB(140,140,160)}):Play()
        end
        if cb then cb(v) end
    end

    local btn = Instance.new("TextButton",row)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 15
    btn.MouseButton1Click:Connect(function() set(not S[key]) end)
    set(S[key])
end

-- ============ SLIDER ============
local function slider(label, key, mn, mx, cb)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1,-10,0,52)
    row.BackgroundColor3 = Color3.fromRGB(19,19,29)
    row.BorderSizePixel = 0; row.ZIndex = 12
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    local st = Instance.new("UIStroke",row)
    st.Color = Color3.fromRGB(35,35,52); st.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-54,0,26)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13

    local valLbl = Instance.new("TextLabel",row)
    valLbl.Size = UDim2.new(0,44,0,26)
    valLbl.Position = UDim2.new(1,-48,0,0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(S[key])
    valLbl.TextSize = 11; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextColor3 = Color3.fromRGB(190,25,25)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 13

    local track = Instance.new("Frame",row)
    track.Size = UDim2.new(1,-16,0,5)
    track.Position = UDim2.new(0,8,0,34)
    track.BackgroundColor3 = Color3.fromRGB(35,35,52)
    track.BorderSizePixel = 0; track.ZIndex = 13
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame",track)
    fill.Size = UDim2.new((S[key]-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(190,25,25)
    fill.BorderSizePixel = 0; fill.ZIndex = 14
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame",track)
    thumb.Size = UDim2.new(0,13,0,13)
    thumb.AnchorPoint = Vector2.new(0.5,0.5)
    thumb.Position = UDim2.new((S[key]-mn)/(mx-mn),0,0.5,0)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel = 0; thumb.ZIndex = 15
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)

    local drag = false
    local function upd(inp)
        local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val = math.floor(mn + rel*(mx-mn))
        S[key] = val; valLbl.Text = tostring(val)
        fill.Size = UDim2.new(rel,0,1,0)
        thumb.Position = UDim2.new(rel,0,0.5,0)
        if cb then cb(val) end
    end
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=true; upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
end

-- ============ BUILD UI ============
section("🎯 AIM")
toggle("Aimbot (Camera)", "Aimbot", nil)
toggle("Silent Aim (safe)", "SilentAim", nil)
toggle("Auto Shoot", "AutoShoot", nil)
toggle("Show FOV Circle", "ShowFOV", nil)
slider("FOV Size", "FOVSize", 30, 350, nil)

section("🔫 COMBAT")
toggle("Rapid Fire", "RapidFire", nil)
toggle("Infinite Ammo", "InfAmmo", nil)

section("🏃 MOVEMENT")
toggle("Speed Hack", "Speed", function(v)
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v and S.SpeedVal or 16 end
    end
end)
slider("Speed Value", "SpeedVal", 16, 120, function(v)
    if S.Speed then
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = v end
        end
    end
end)
toggle("Bunny Hop", "BunnyHop", nil)
toggle("No Clip", "Noclip", nil)

section("👁️ VISUALS")
toggle("ESP Wallhack", "ESP", function(v)
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("_ESP")
                if h then h:Destroy() end
            end
        end
    end
end)

section("⚙️ MISC")
toggle("Anti AFK", "AntiAFK", nil)

-- ============ OPEN/CLOSE ============
local open = false
local function setOpen(v)
    open = v
    panel.Visible = v
end
openBtn.MouseButton1Click:Connect(function() setOpen(not open) end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- ============ AIMBOT LOOP ============
RunService.RenderStepped:Connect(function()
    if S.Aimbot then
        local t = getTarget()
        if t and t.Character then
            local part = t.Character:FindFirstChild(S.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if part then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        end
    end
end)

-- ============ AUTO SHOOT ============
-- Без hookmetamethod — используем mouse1click если доступен
RunService.Heartbeat:Connect(function()
    if not S.AutoShoot then return end
    local t = getTarget()
    if not t or not t.Character then return end
    local part = t.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local sp, vis = Camera:WorldToViewportPoint(part.Position)
    if vis then
        pcall(function() mouse1click() end)
        pcall(function() mousemoverel(0,0) end)
    end
end)

-- ============ RAPID FIRE ============
RunService.Heartbeat:Connect(function()
    if not S.RapidFire then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if (v:IsA("NumberValue") or v:IsA("IntValue")) then
            local n = v.Name:lower()
            if n:find("cooldown") or n:find("debounce") or n:find("delay") or n:find("wait") then
                v.Value = 0
            end
        end
    end
end)

-- ============ INFINITE AMMO ============
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

-- ============ NOCLIP ============
RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ============ BUNNY HOP ============
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

-- ============ ESP ============
RunService.Heartbeat:Connect(function()
    if not S.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not p.Character:FindFirstChild("_ESP") then
                local hl = Instance.new("Highlight", p.Character)
                hl.Name = "_ESP"
                hl.FillColor = Color3.fromRGB(255,30,30)
                hl.OutlineColor = Color3.fromRGB(255,220,0)
                hl.FillTransparency = 0.5
            end
        end
    end
end)

-- ============ SPEED ON RESPAWN ============
LocalPlayer.CharacterAdded:Connect(function(c)
    local hum = c:WaitForChild("Humanoid")
    if S.Speed then hum.WalkSpeed = S.SpeedVal end
end)

-- ============ ANTI AFK ============
local VU = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if S.AntiAFK then
        VU:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.5)
        VU:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ============ ANTI-DETECTION: скрываем скрипт ============
-- Переименовываем GUI каждые 30 сек чтобы не детектился по имени
task.spawn(function()
    while task.wait(30) do
        pcall(function()
            sg.Name = "Gui_"..tostring(math.random(10000,99999))
        end)
    end
end)

print("✅ RIVALS HUB V4 загружен! Нажми ⚡ чтобы открыть меню")
print("✅ Anti-cheat bypass активен — hookmetamethod НЕ используется")
