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
    Aimbot        = false,
    AimbotSmooth  = 5,
    SilentAim     = false,
    ShowFOV       = false,
    FOVSize       = 120,
    AimPart       = "Head",
    ESP           = false,
    ESPNames      = false,
    ESPHealth     = false,
    Speed         = false,
    SpeedVal      = 35,
    Noclip        = false,
    RapidFire     = false,
    InfAmmo       = false,
    BunnyHop      = false,
    AntiAFK       = true,
    AutoShoot     = false,
    HighJump      = false,
    JumpVal       = 80,
    Fullbright    = false,
    InfStamina    = false,
}

-- FOV Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255, 60, 60)
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Radius = S.FOVSize

-- Crosshair dot
local crossDot = Drawing.new("Circle")
crossDot.Visible = true
crossDot.Color = Color3.fromRGB(255, 60, 60)
crossDot.Thickness = 1
crossDot.NumSides = 16
crossDot.Filled = true
crossDot.Radius = 3

RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X/2
    local cy = Camera.ViewportSize.Y/2
    fovCircle.Position = Vector2.new(cx, cy)
    fovCircle.Radius = S.FOVSize
    fovCircle.Visible = S.ShowFOV
    crossDot.Position = Vector2.new(cx, cy)
end)

-- Find closest target
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

-- ========== GUI ==========
local sg = Instance.new("ScreenGui")
sg.Name = "RHB"..tostring(math.random(1000,9999))
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = game.CoreGui

-- Open button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0,44,0,44)
openBtn.Position = UDim2.new(0,8,0.5,-22)
openBtn.BackgroundColor3 = Color3.fromRGB(180,20,20)
openBtn.Text = "⚡"
openBtn.TextSize = 20
openBtn.Font = Enum.Font.GothamBold
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.BorderSizePixel = 0
openBtn.ZIndex = 100
openBtn.Parent = sg
Instance.new("UICorner",openBtn).CornerRadius = UDim.new(0,10)

-- Shadow under open button
local btnShadow = Instance.new("ImageLabel")
btnShadow.Size = UDim2.new(1,14,1,14)
btnShadow.Position = UDim2.new(0,-7,0,-7)
btnShadow.BackgroundTransparency = 1
btnShadow.Image = "rbxassetid://6014261993"
btnShadow.ImageColor3 = Color3.fromRGB(0,0,0)
btnShadow.ImageTransparency = 0.5
btnShadow.ScaleType = Enum.ScaleType.Slice
btnShadow.SliceCenter = Rect.new(49,49,450,450)
btnShadow.ZIndex = 99
btnShadow.Parent = openBtn

-- Main panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,240,0,520)
panel.Position = UDim2.new(0,60,0.5,-260)
panel.BackgroundColor3 = Color3.fromRGB(10,10,16)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Visible = false
panel.ZIndex = 10
panel.Parent = sg
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

-- Glow border
local glow = Instance.new("ImageLabel",panel)
glow.Size = UDim2.new(1,24,1,24)
glow.Position = UDim2.new(0,-12,0,-12)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://6014261993"
glow.ImageColor3 = Color3.fromRGB(200,20,20)
glow.ImageTransparency = 0.6
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(49,49,450,450)
glow.ZIndex = 9

local stroke = Instance.new("UIStroke",panel)
stroke.Color = Color3.fromRGB(180,20,20)
stroke.Thickness = 1.5

-- Top bar
local topBar = Instance.new("Frame",panel)
topBar.Size = UDim2.new(1,0,0,40)
topBar.BackgroundColor3 = Color3.fromRGB(180,20,20)
topBar.BorderSizePixel = 0; topBar.ZIndex = 11
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,12)
local topFix = Instance.new("Frame",topBar)
topFix.Size = UDim2.new(1,0,0.5,0); topFix.Position = UDim2.new(0,0,0.5,0)
topFix.BackgroundColor3 = Color3.fromRGB(180,20,20); topFix.BorderSizePixel = 0; topFix.ZIndex = 11

-- Gradient on top bar
local topGrad = Instance.new("UIGradient",topBar)
topGrad.Color = ColorSequence.new(Color3.fromRGB(220,30,30), Color3.fromRGB(130,10,10))
topGrad.Rotation = 90

local titleLbl = Instance.new("TextLabel",topBar)
titleLbl.Size = UDim2.new(1,-44,1,0); titleLbl.Position = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1; titleLbl.Text = "⚡  RIVALS HUB"
titleLbl.TextColor3 = Color3.fromRGB(255,255,255); titleLbl.TextSize = 14
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 12

local closeBtn = Instance.new("TextButton",topBar)
closeBtn.Size = UDim2.new(0,26,0,26); closeBtn.Position = UDim2.new(1,-32,0.5,-13)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 0.85
closeBtn.Text = "✕"; closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BorderSizePixel = 0; closeBtn.ZIndex = 13
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,6)

-- Tab buttons
local tabBar = Instance.new("Frame",panel)
tabBar.Size = UDim2.new(1,-12,0,28); tabBar.Position = UDim2.new(0,6,0,44)
tabBar.BackgroundColor3 = Color3.fromRGB(18,18,28); tabBar.BorderSizePixel = 0; tabBar.ZIndex = 11
Instance.new("UICorner",tabBar).CornerRadius = UDim.new(0,7)

local tabList = Instance.new("UIListLayout",tabBar)
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.VerticalAlignment = Enum.VerticalAlignment.Center
tabList.Padding = UDim.new(0,2)

local tabs = {"AIM","COMBAT","MOVE","VIS","MISC"}
local tabFrames = {}
local tabBtns = {}
local activeTab = "AIM"

-- Scroll container
local scrollContainer = Instance.new("Frame",panel)
scrollContainer.Size = UDim2.new(1,0,1,-78); scrollContainer.Position = UDim2.new(0,0,0,78)
scrollContainer.BackgroundTransparency = 1; scrollContainer.ZIndex = 11

for _, tabName in ipairs(tabs) do
    -- Tab button
    local tb = Instance.new("TextButton",tabBar)
    tb.Size = UDim2.new(0,40,0,22); tb.BackgroundTransparency = 1
    tb.Text = tabName; tb.TextSize = 9; tb.Font = Enum.Font.GothamBold
    tb.TextColor3 = Color3.fromRGB(130,130,150); tb.BorderSizePixel = 0; tb.ZIndex = 12
    tabBtns[tabName] = tb

    -- Tab scroll frame
    local sf = Instance.new("ScrollingFrame",scrollContainer)
    sf.Size = UDim2.new(1,0,1,0); sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0; sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = Color3.fromRGB(180,20,20)
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = (tabName == "AIM"); sf.ZIndex = 11
    local ll = Instance.new("UIListLayout",sf)
    ll.Padding = UDim.new(0,4); ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pp = Instance.new("UIPadding",sf)
    pp.PaddingTop = UDim.new(0,6); pp.PaddingBottom = UDim.new(0,6)
    tabFrames[tabName] = sf
end

local function switchTab(name)
    activeTab = name
    for t, sf in pairs(tabFrames) do
        sf.Visible = (t == name)
    end
    for t, tb in pairs(tabBtns) do
        if t == name then
            tb.TextColor3 = Color3.fromRGB(255,80,80)
            tb.BackgroundTransparency = 0.85
            tb.BackgroundColor3 = Color3.fromRGB(180,20,20)
        else
            tb.TextColor3 = Color3.fromRGB(130,130,150)
            tb.BackgroundTransparency = 1
        end
    end
end

for _, tabName in ipairs(tabs) do
    tabBtns[tabName].MouseButton1Click:Connect(function() switchTab(tabName) end)
end
switchTab("AIM")

-- ===== UI COMPONENTS =====
local function mkSection(parent, txt)
    local f = Instance.new("TextLabel",parent)
    f.Size = UDim2.new(1,-12,0,16); f.BackgroundColor3 = Color3.fromRGB(180,20,20)
    f.Text = "  "..txt; f.TextColor3 = Color3.fromRGB(255,255,255)
    f.TextSize = 9; f.Font = Enum.Font.GothamBold
    f.TextXAlignment = Enum.TextXAlignment.Left; f.BorderSizePixel = 0; f.ZIndex = 12
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,4)
    local g = Instance.new("UIGradient",f)
    g.Color = ColorSequence.new(Color3.fromRGB(210,25,25),Color3.fromRGB(110,8,8)); g.Rotation = 90
end

local function mkToggle(parent, label, key, cb)
    local row = Instance.new("Frame",parent)
    row.Size = UDim2.new(1,-12,0,36); row.BackgroundColor3 = Color3.fromRGB(17,17,26)
    row.BorderSizePixel = 0; row.ZIndex = 12
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
    local rs = Instance.new("UIStroke",row); rs.Color = Color3.fromRGB(30,30,46); rs.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-56,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(210,210,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13

    local pill = Instance.new("Frame",row)
    pill.Size = UDim2.new(0,40,0,20); pill.Position = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = Color3.fromRGB(38,38,55); pill.BorderSizePixel = 0; pill.ZIndex = 13
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame",pill)
    dot.Size = UDim2.new(0,14,0,14); dot.Position = UDim2.new(0,3,0.5,-7)
    dot.BackgroundColor3 = Color3.fromRGB(120,120,140); dot.BorderSizePixel = 0; dot.ZIndex = 14
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local tw = TweenInfo.new(0.14,Enum.EasingStyle.Quad)
    local function set(v)
        S[key] = v
        if v then
            TweenService:Create(pill,tw,{BackgroundColor3=Color3.fromRGB(180,20,20)}):Play()
            TweenService:Create(dot,tw,{Position=UDim2.new(0,23,0.5,-7),BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
            TweenService:Create(row,tw,{BackgroundColor3=Color3.fromRGB(25,10,10)}):Play()
        else
            TweenService:Create(pill,tw,{BackgroundColor3=Color3.fromRGB(38,38,55)}):Play()
            TweenService:Create(dot,tw,{Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=Color3.fromRGB(120,120,140)}):Play()
            TweenService:Create(row,tw,{BackgroundColor3=Color3.fromRGB(17,17,26)}):Play()
        end
        if cb then cb(v) end
    end
    local btn = Instance.new("TextButton",row)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 15
    btn.MouseButton1Click:Connect(function() set(not S[key]) end)
    set(S[key])
end

local function mkSlider(parent, label, key, mn, mx, cb)
    local row = Instance.new("Frame",parent)
    row.Size = UDim2.new(1,-12,0,54); row.BackgroundColor3 = Color3.fromRGB(17,17,26)
    row.BorderSizePixel = 0; row.ZIndex = 12
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
    local rs = Instance.new("UIStroke",row); rs.Color = Color3.fromRGB(30,30,46); rs.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-54,0,26); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(210,210,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13

    local valLbl = Instance.new("TextLabel",row)
    valLbl.Size = UDim2.new(0,44,0,26); valLbl.Position = UDim2.new(1,-48,0,0)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(S[key]); valLbl.TextSize = 11
    valLbl.Font = Enum.Font.GothamBold; valLbl.TextColor3 = Color3.fromRGB(200,40,40)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 13

    local track = Instance.new("Frame",row)
    track.Size = UDim2.new(1,-18,0,5); track.Position = UDim2.new(0,9,0,36)
    track.BackgroundColor3 = Color3.fromRGB(32,32,48); track.BorderSizePixel = 0; track.ZIndex = 13
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame",track)
    fill.Size = UDim2.new((S[key]-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(180,20,20); fill.BorderSizePixel = 0; fill.ZIndex = 14
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

-- ===== BUILD TABS =====
local aim = tabFrames["AIM"]
mkSection(aim,"AIMBOT")
mkToggle(aim,"🎯 Aimbot","Aimbot",nil)
mkSlider(aim,"Smoothness","AimbotSmooth",1,20,nil)
mkToggle(aim,"👻 Silent Aim","SilentAim",nil)
mkToggle(aim,"🤖 Auto Shoot","AutoShoot",nil)
mkSection(aim,"FOV")
mkToggle(aim,"⭕ Show FOV Circle","ShowFOV",nil)
mkSlider(aim,"FOV Size","FOVSize",30,400,nil)

local combat = tabFrames["COMBAT"]
mkSection(combat,"WEAPONS")
mkToggle(combat,"🔫 Rapid Fire","RapidFire",nil)
mkToggle(combat,"♾️ Infinite Ammo","InfAmmo",nil)

local move = tabFrames["MOVE"]
mkSection(move,"MOVEMENT")
mkToggle(move,"🏃 Speed Hack","Speed",function(v)
    local c = LocalPlayer.Character
    if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=v and S.SpeedVal or 16 end end
end)
mkSlider(move,"Speed Value","SpeedVal",16,150,function(v)
    if S.Speed then
        local c=LocalPlayer.Character
        if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=v end end
    end
end)
mkToggle(move,"🦘 High Jump","HighJump",function(v)
    local c=LocalPlayer.Character
    if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=v and S.JumpVal or 50 end end
end)
mkSlider(move,"Jump Power","JumpVal",50,300,function(v)
    if S.HighJump then
        local c=LocalPlayer.Character
        if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=v end end
    end
end)
mkToggle(move,"🐇 Bunny Hop","BunnyHop",nil)
mkToggle(move,"👻 No Clip","Noclip",nil)
mkToggle(move,"💪 Inf Stamina","InfStamina",nil)

local vis = tabFrames["VIS"]
mkSection(vis,"VISUALS")
mkToggle(vis,"👁️ ESP Boxes","ESP",function(v)
    if not v then
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h=p.Character:FindFirstChild("_h") if h then h:Destroy() end
            end
        end
    end
end)
mkToggle(vis,"📛 ESP Names","ESPNames",nil)
mkToggle(vis,"❤️ ESP Health","ESPHealth",nil)
mkToggle(vis,"☀️ Fullbright","Fullbright",function(v)
    game:GetService("Lighting").Brightness = v and 10 or 1
    game:GetService("Lighting").ClockTime = v and 14 or 14
    game:GetService("Lighting").FogEnd = v and 1e6 or 1e4
end)

local misc = tabFrames["MISC"]
mkSection(misc,"MISC")
mkToggle(misc,"🚫 Anti AFK","AntiAFK",nil)

-- ===== OPEN/CLOSE =====
local isOpen = false
local function setOpen(v)
    isOpen = v
    if v then
        panel.Visible = true
        panel.Size = UDim2.new(0,0,0,0)
        TweenService:Create(panel,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,240,0,520)}):Play()
    else
        local t = TweenService:Create(panel,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Size=UDim2.new(0,240,0,0)})
        t:Play(); t.Completed:Connect(function() panel.Visible=false end)
    end
end
openBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- ===== AIMBOT (улучшенный с плавностью) =====
RunService.RenderStepped:Connect(function()
    if not S.Aimbot then return end
    local t = getTarget()
    if not t or not t.Character then return end
    local part = t.Character:FindFirstChild(S.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    -- Предсказание движения
    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
    local predictedPos = part.Position
    if hrp then
        predictedPos = part.Position + hrp.Velocity * 0.08
    end
    local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
    -- Плавное наведение (smoothness)
    local smooth = math.clamp(S.AimbotSmooth, 1, 20)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1/smooth)
end)

-- ===== SILENT AIM =====
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
        task.delay(0.07, function() Camera.CFrame = orig end)
    end
end)

-- ===== AUTO SHOOT =====
RunService.Heartbeat:Connect(function()
    if not S.AutoShoot then return end
    local t = getTarget()
    if not t or not t.Character then return end
    local part = t.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local _, vis = Camera:WorldToViewportPoint(part.Position)
    if vis then pcall(function() mouse1click() end) end
end)

-- ===== RAPID FIRE =====
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

-- ===== INFINITE AMMO =====
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

-- ===== NOCLIP =====
RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ===== BUNNY HOP =====
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

-- ===== INFINITE STAMINA =====
RunService.Heartbeat:Connect(function()
    if not S.InfStamina then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = v.Name:lower()
            if n:find("stamina") or n:find("energy") or n:find("endurance") then
                v.Value = v.MaxValue or 100
            end
        end
    end
end)

-- ===== ESP =====
-- ESP Names drawing
local espLabels = {}
RunService.RenderStepped:Connect(function()
    -- Highlight ESP
    if S.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("_h") then
                    local hl = Instance.new("Highlight",p.Character)
                    hl.Name = "_h"
                    hl.FillColor = Color3.fromRGB(255,30,30)
                    hl.OutlineColor = Color3.fromRGB(255,220,0)
                    hl.FillTransparency = 0.55
                end
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("_h")
                if h then h:Destroy() end
            end
        end
    end

    -- ESP Names (Drawing)
    for _, lbl in pairs(espLabels) do lbl.Visible = false end
    if S.ESPNames then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local sp, vis = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                    if vis then
                        if not espLabels[p.Name] then
                            local txt = Drawing.new("Text")
                            txt.Size = 14; txt.Font = 2
                            txt.Color = Color3.fromRGB(255,255,255)
                            txt.Outline = true; txt.OutlineColor = Color3.fromRGB(0,0,0)
                            txt.Center = true
                            espLabels[p.Name] = txt
                        end
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local hp = hum and math.floor(hum.Health) or 0
                        espLabels[p.Name].Text = p.Name .. (S.ESPHealth and (" ["..hp.."]") or "")
                        espLabels[p.Name].Position = Vector2.new(sp.X, sp.Y)
                        espLabels[p.Name].Visible = true
                    end
                end
            end
        end
    end
end)

-- ===== SPEED / JUMP ON RESPAWN =====
LocalPlayer.CharacterAdded:Connect(function(c)
    local hum = c:WaitForChild("Humanoid")
    if S.Speed then hum.WalkSpeed = S.SpeedVal end
    if S.HighJump then hum.JumpPower = S.JumpVal end
end)

-- ===== ANTI AFK =====
local VU = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if S.AntiAFK then
        VU:Button2Down(Vector2.new(0,0),Camera.CFrame)
        task.wait(0.5)
        VU:Button2Up(Vector2.new(0,0),Camera.CFrame)
    end
end)

-- ===== GUI RENAME =====
task.spawn(function()
    while task.wait(45) do
        pcall(function() sg.Name = "RHB"..tostring(math.random(1000,9999)) end)
    end
end)
