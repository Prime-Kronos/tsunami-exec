-- ██████╗ ██████╗ ██╗███╗   ███╗███████╗
-- ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝
-- ██████╔╝██████╔╝██║██╔████╔██║█████╗
-- ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝
-- ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗
-- ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝
--   PrimejTsuHub | MM2 | @Primejtsu

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- ══════════════════════════════════════
--            GAME STATE
-- ══════════════════════════════════════
local CFG = {
    speed     = false,
    noclip    = false,
    god       = false,
    esp       = false,
    bhop      = false,
    coinFarm  = false,
    knife     = false,
    fullbright= false,
    antiAfk   = true,
    hide      = false,
    antiKnock = false,
    infAmmo   = false,
    autoReward= false,
    antiTsunami=false,
}

local coinCount = 0

-- ══ HELPERS ══
local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══ ANTI AFK ══
pcall(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if CFG.antiAfk then
            vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end
    end)
end)

-- ══ GOD MODE ══
RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h = getHum() if not h then return end
    h.MaxHealth = math.huge
    h.Health    = math.huge
    h.BreakJointsOnDeath = false
end)

-- ══ SPEED ══
RunService.Heartbeat:Connect(function()
    local h = getHum() if not h then return end
    if CFG.speed then
        if h.WalkSpeed < 30 then h.WalkSpeed = h.WalkSpeed + 1 end
    elseif not CFG.bhop then
        if h.WalkSpeed ~= 16 then h.WalkSpeed = 16 end
    end
    if CFG.bhop then
        h.WalkSpeed = 28
        if h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
    end
end)

-- ══ NOCLIP ══
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c = getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ══ COIN FARM (без подъёма вверх) ══
local coinNames = {Coin=true,DropCoin=true,GoldCoin=true,SilverCoin=true,coin=true}
local lastTP = 0
local cidx   = 1

RunService.Heartbeat:Connect(function()
    if not CFG.coinFarm then return end
    if tick()-lastTP < 0.45 then return end
    lastTP = tick()
    local hrp = getHRP() if not hrp then return end
    local coins = {}
    for _,o in ipairs(workspace:GetDescendants()) do
        if coinNames[o.Name] and o:IsA("BasePart") then
            table.insert(coins, o)
        end
    end
    if #coins == 0 then return end
    if cidx > #coins then cidx = 1 end
    local t = coins[cidx] cidx = cidx + 1
    if t and t.Parent then
        hrp.CFrame = CFrame.new(t.Position.X, hrp.Position.Y, t.Position.Z)
    end
end)

-- ══ KNIFE AURA ══
local lastKnife = 0
RunService.Heartbeat:Connect(function()
    if not CFG.knife then return end
    if tick()-lastKnife < 0.4 then return end lastKnife = tick()
    local hrp = getHRP() if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local t   = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if t and hum and hum.Health>0 and (hrp.Position-t.Position).Magnitude<=10 then
                hrp.CFrame = t.CFrame + Vector3.new(0,0,2)
                task.wait(0.3)
            end
        end
    end
end)

-- ══ FULLBRIGHT ══
local function setFB(v)
    if v then
        Lighting.Brightness=2.5 Lighting.ClockTime=14
        Lighting.GlobalShadows=false Lighting.FogEnd=1e5
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else
        Lighting.Brightness=1 Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    end
end

-- ══ ANTI KNOCK ══
local function setAntiKnock(v)
    pcall(function()
        local hrp = getHRP() if not hrp then return end
        hrp.CustomPhysicalProperties = v
            and PhysicalProperties.new(0,0,0,0,0)
            or  PhysicalProperties.new(0.7,0.3,0.5)
    end)
end

-- ══ HIDE PLAYER ══
local function setHide(v)
    pcall(function()
        local c = getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier = v and 1 or 0
            end
        end
    end)
end

-- ══ AUTO REWARD ══
RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t = g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again")
                or t:find("ok") or t:find("ready") then
                    g.MouseButton1Click:Fire()
                end
            end
        end
    end)
end)

-- ══ ANTI TSUNAMI ══
RunService.Heartbeat:Connect(function()
    if not CFG.antiTsunami then return end
    pcall(function()
        local h = getHum() if not h then return end
        if h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
    end)
end)

-- ══ COIN COUNTER ══
local function trackCoins(char)
    local hrp = char:WaitForChild("HumanoidRootPart",5) if not hrp then return end
    hrp.Touched:Connect(function(hit)
        if CFG.coinFarm and coinNames[hit.Name] then
            coinCount = coinCount + 1
        end
    end)
end
LP.CharacterAdded:Connect(function(c) task.wait(0.5) trackCoins(c) end)
if LP.Character then trackCoins(LP.Character) end

-- ════════════════════════════════════════════════
--                    GUI
-- ════════════════════════════════════════════════
if game.CoreGui:FindFirstChild("PRIME_HUB") then
    game.CoreGui.PRIME_HUB:Destroy()
end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "PRIME_HUB"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999

-- COLORS
local C = {
    bg     = Color3.fromRGB(8,  8,  8),
    panel  = Color3.fromRGB(14, 14, 14),
    card   = Color3.fromRGB(18, 18, 18),
    border = Color3.fromRGB(35, 35, 35),
    red    = Color3.fromRGB(200, 30,  30),
    white  = Color3.fromRGB(230,230,230),
    muted  = Color3.fromRGB(90, 90, 90),
    dim    = Color3.fromRGB(50, 50, 50),
}

-- ════════════════════════════════════════════════
--           СПЛЭШ ЭКРАН (АНИМАЦИЯ)
-- ════════════════════════════════════════════════
local Splash = Instance.new("Frame", sg)
Splash.Size = UDim2.new(1,0,1,0)
Splash.BackgroundColor3 = Color3.fromRGB(0,0,0)
Splash.BorderSizePixel  = 0
Splash.ZIndex = 100

-- Красная линия сверху (loading bar)
local LoadBar = Instance.new("Frame", Splash)
LoadBar.Size = UDim2.new(0,0,0,2)
LoadBar.Position = UDim2.new(0,0,0,0)
LoadBar.BackgroundColor3 = C.red
LoadBar.BorderSizePixel  = 0
LoadBar.ZIndex = 101

-- "P" красная буква
local PLetter = Instance.new("TextLabel", Splash)
PLetter.Size = UDim2.new(0,120,0,100)
PLetter.Position = UDim2.new(0.5,-60,0.35,-50)
PLetter.BackgroundTransparency = 1
PLetter.Text = "Ᵽ"
PLetter.TextColor3 = C.red
PLetter.Font = Enum.Font.GothamBlack
PLetter.TextSize = 90
PLetter.TextTransparency = 1
PLetter.ZIndex = 101

-- "RIME" белые буквы
local RimeLbl = Instance.new("TextLabel", Splash)
RimeLbl.Size = UDim2.new(0,200,0,100)
RimeLbl.Position = UDim2.new(0.5,-20,0.35,-50)
RimeLbl.BackgroundTransparency = 1
RimeLbl.Text = "RIME"
RimeLbl.TextColor3 = C.white
RimeLbl.Font = Enum.Font.GothamBlack
RimeLbl.TextSize = 90
RimeLbl.TextTransparency = 1
RimeLbl.ZIndex = 101

-- Subtitle
local SubLbl = Instance.new("TextLabel", Splash)
SubLbl.Size = UDim2.new(0,300,0,24)
SubLbl.Position = UDim2.new(0.5,-150,0.62,0)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "Murder Mystery 2 Hub"
SubLbl.TextColor3 = C.muted
SubLbl.Font = Enum.Font.GothamBold
SubLbl.TextSize = 13
SubLbl.TextTransparency = 1
SubLbl.ZIndex = 101

-- Loading text
local LoadTxt = Instance.new("TextLabel", Splash)
LoadTxt.Size = UDim2.new(0,300,0,20)
LoadTxt.Position = UDim2.new(0.5,-150,0.82,0)
LoadTxt.BackgroundTransparency = 1
LoadTxt.Text = "Загрузка..."
LoadTxt.TextColor3 = C.muted
LoadTxt.Font = Enum.Font.Code
LoadTxt.TextSize = 11
LoadTxt.TextTransparency = 1
LoadTxt.ZIndex = 101

-- Версия
local VerLbl = Instance.new("TextLabel", Splash)
VerLbl.Size = UDim2.new(0,200,0,16)
VerLbl.Position = UDim2.new(0.5,-100,0.87,0)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v3.2  •  @Primejtsu"
VerLbl.TextColor3 = C.dim
VerLbl.Font = Enum.Font.Code
VerLbl.TextSize = 10
VerLbl.TextTransparency = 1
VerLbl.ZIndex = 101

-- Декор линии по центру
local Line1 = Instance.new("Frame", Splash)
Line1.Size = UDim2.new(0,0,0,1)
Line1.Position = UDim2.new(0.5,0,0.72,0)
Line1.BackgroundColor3 = C.red
Line1.BorderSizePixel = 0
Line1.ZIndex = 101

local Line2 = Instance.new("Frame", Splash)
Line2.Size = UDim2.new(0,0,0,1)
Line2.Position = UDim2.new(0.5,0,0.72,0)
Line2.BackgroundColor3 = C.white
Line2.BorderSizePixel = 0
Line2.ZIndex = 101

-- ── АНИМАЦИЯ СПЛЭША ──
local tw = TweenInfo.new
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

task.spawn(function()
    task.wait(0.3)

    -- 1. Загрузочная полоска
    tween(LoadBar, tw(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(1,0,0,2)})

    task.wait(0.4)

    -- 2. "P" появляется слева
    tween(PLetter, tw(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {TextTransparency = 0,
         Position = UDim2.new(0.5,-90,0.35,-50)})

    task.wait(0.25)

    -- 3. "RIME" появляется справа
    tween(RimeLbl, tw(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {TextTransparency = 0})

    task.wait(0.3)

    -- 4. Линии разъезжаются
    tween(Line1, tw(0.6, Enum.EasingStyle.Quart),
        {Size = UDim2.new(0.4,0,0,1), Position = UDim2.new(0.1,0,0.72,0)})
    tween(Line2, tw(0.6, Enum.EasingStyle.Quart),
        {Size = UDim2.new(0.4,0,0,1), Position = UDim2.new(0.5,0,0.72,0)})

    task.wait(0.3)

    -- 5. Subtitle и версия
    tween(SubLbl, tw(0.4), {TextTransparency = 0})
    task.wait(0.15)
    tween(LoadTxt, tw(0.4), {TextTransparency = 0})
    task.wait(0.15)
    tween(VerLbl,  tw(0.4), {TextTransparency = 0})

    -- Loading steps
    local steps = {
        "Загрузка модулей...",
        "Подключение к игре...",
        "Инициализация GUI...",
        "Готово ✓"
    }
    for i, s in ipairs(steps) do
        task.wait(0.35)
        LoadTxt.Text = s
        if i == #steps then
            LoadTxt.TextColor3 = Color3.fromRGB(0,200,100)
        end
    end

    task.wait(0.5)

    -- 6. Всё исчезает
    tween(Splash, tw(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {BackgroundTransparency = 1})
    for _, obj in ipairs(Splash:GetDescendants()) do
        if obj:IsA("TextLabel") then
            tween(obj, tw(0.4), {TextTransparency = 1})
        elseif obj:IsA("Frame") then
            tween(obj, tw(0.4), {BackgroundTransparency = 1})
        end
    end

    task.wait(0.7)
    Splash:Destroy()

    -- ══ ПОКАЗЫВАЕМ ГЛАВНЫЙ GUI ══
    showMainGUI()

    -- Уведомление
    task.wait(0.5)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "✅ PrimejTsuHub",
            Text     = "Загружен! | @Primejtsu",
            Duration = 4,
        })
    end)
end)

-- ════════════════════════════════════════════════
--              ГЛАВНЫЙ GUI
-- ════════════════════════════════════════════════
function showMainGUI()

    -- ОКНО 270×390
    local W = Instance.new("Frame", sg)
    W.Size = UDim2.new(0,270,0,390)
    W.Position = UDim2.new(0,10,0.5,-195)
    W.BackgroundColor3 = C.bg
    W.BorderSizePixel  = 0
    W.Active    = true
    W.Draggable = true
    W.ClipsDescendants = true
    Instance.new("UICorner", W).CornerRadius = UDim.new(0,10)
    local wStroke = Instance.new("UIStroke", W)
    wStroke.Color = C.border wStroke.Thickness = 1

    -- Анимация появления окна
    W.Position = UDim2.new(0,-280,0.5,-195)
    TweenService:Create(W, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0,10,0.5,-195)}):Play()

    -- ── HEADER ──
    local Hdr = Instance.new("Frame", W)
    Hdr.Size = UDim2.new(1,0,0,48)
    Hdr.BackgroundColor3 = C.panel
    Hdr.BorderSizePixel  = 0
    Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0,10)
    local hf = Instance.new("Frame",Hdr) hf.Size=UDim2.new(1,0,0.5,0) hf.Position=UDim2.new(0,0,0.5,0) hf.BackgroundColor3=C.panel hf.BorderSizePixel=0

    -- Красная полоска сверху
    local topLine = Instance.new("Frame", Hdr)
    topLine.Size = UDim2.new(1,0,0,2)
    topLine.BackgroundColor3 = C.red
    topLine.BorderSizePixel  = 0

    -- Логотип P
    local LogoP = Instance.new("TextLabel", Hdr)
    LogoP.Size = UDim2.new(0,28,0,36)
    LogoP.Position = UDim2.new(0,10,0.5,-18)
    LogoP.BackgroundTransparency = 1
    LogoP.Text = "Ᵽ"
    LogoP.TextColor3 = C.red
    LogoP.Font = Enum.Font.GothamBlack
    LogoP.TextSize = 28

    local LogoRime = Instance.new("TextLabel", Hdr)
    LogoRime.Size = UDim2.new(0,60,0,36)
    LogoRime.Position = UDim2.new(0,34,0.5,-18)
    LogoRime.BackgroundTransparency = 1
    LogoRime.Text = "RIME"
    LogoRime.TextColor3 = C.white
    LogoRime.Font = Enum.Font.GothamBlack
    LogoRime.TextSize = 20

    local LogoSub = Instance.new("TextLabel", Hdr)
    LogoSub.Size = UDim2.new(0,100,0,12)
    LogoSub.Position = UDim2.new(0,10,1,-14)
    LogoSub.BackgroundTransparency = 1
    LogoSub.Text = "MM2 Hub  •  v3.2"
    LogoSub.TextColor3 = C.muted
    LogoSub.Font = Enum.Font.Code
    LogoSub.TextSize = 9
    LogoSub.TextXAlignment = Enum.TextXAlignment.Left

    -- Close
    local Cls = Instance.new("TextButton", Hdr)
    Cls.Size = UDim2.new(0,22,0,22)
    Cls.Position = UDim2.new(1,-28,0.5,-11)
    Cls.BackgroundColor3 = C.red
    Cls.Text = "✕"
    Cls.TextColor3 = Color3.new(1,1,1)
    Cls.Font = Enum.Font.GothamBold
    Cls.TextSize = 10
    Cls.BorderSizePixel = 0
    Instance.new("UICorner",Cls).CornerRadius = UDim.new(0,5)
    Cls.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Min
    local Min = Instance.new("TextButton", Hdr)
    Min.Size = UDim2.new(0,22,0,22)
    Min.Position = UDim2.new(1,-54,0.5,-11)
    Min.BackgroundColor3 = C.card
    Min.Text = "─"
    Min.TextColor3 = C.muted
    Min.Font = Enum.Font.GothamBold
    Min.TextSize = 10
    Min.BorderSizePixel = 0
    Instance.new("UICorner",Min).CornerRadius = UDim.new(0,5)
    local minned = false
    Min.MouseButton1Click:Connect(function()
        minned = not minned
        W.Size = minned and UDim2.new(0,270,0,48) or UDim2.new(0,270,0,390)
        Min.Text = minned and "□" or "─"
    end)

    -- ── TAB BAR ──
    local TB = Instance.new("Frame", W)
    TB.Size = UDim2.new(1,0,0,28)
    TB.Position = UDim2.new(0,0,0,48)
    TB.BackgroundColor3 = C.panel
    TB.BorderSizePixel  = 0

    local tbDiv = Instance.new("Frame", W)
    tbDiv.Size = UDim2.new(1,0,0,1)
    tbDiv.Position = UDim2.new(0,0,0,76)
    tbDiv.BackgroundColor3 = C.border
    tbDiv.BorderSizePixel  = 0

    -- ── SCROLL CONTENT ──
    local SC = Instance.new("ScrollingFrame", W)
    SC.Size = UDim2.new(1,0,1,-78)
    SC.Position = UDim2.new(0,0,0,78)
    SC.BackgroundTransparency = 1
    SC.BorderSizePixel = 0
    SC.ScrollBarThickness = 2
    SC.ScrollBarImageColor3 = C.red
    SC.CanvasSize = UDim2.new(0,0,0,0)

    local SCL = Instance.new("UIListLayout", SC)
    SCL.Padding = UDim.new(0,5)
    SCL.SortOrder = Enum.SortOrder.LayoutOrder
    local SCP = Instance.new("UIPadding", SC)
    SCP.PaddingLeft=UDim.new(0,8) SCP.PaddingRight=UDim.new(0,8)
    SCP.PaddingTop=UDim.new(0,7) SCP.PaddingBottom=UDim.new(0,7)

    SCL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SC.CanvasSize = UDim2.new(0,0,0, SCL.AbsoluteContentSize.Y + 14)
    end)

    -- Tab content store
    local tabFrames = {}
    local TABS = {"MOVE","GOD","FARM","MISC","INFO"}

    for _, name in ipairs(TABS) do
        local f = Instance.new("Frame")
        f.Name = name
        f.Size = UDim2.new(1,0,0,0)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.AutomaticSize = Enum.AutomaticSize.Y
        local fl = Instance.new("UIListLayout", f)
        fl.Padding = UDim.new(0,5)
        fl.SortOrder = Enum.SortOrder.LayoutOrder
        tabFrames[name] = f
    end

    -- ── CARD BUILDER ──
    local toggleStates = {}

    local function mkCard(tabName, ico, title, desc, cfgKey, onToggle)
        local parent = tabFrames[tabName]
        local card = Instance.new("Frame", parent)
        card.Size = UDim2.new(1,0,0,56)
        card.BackgroundColor3 = C.card
        card.BorderSizePixel  = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)
        local cs = Instance.new("UIStroke", card) cs.Color=C.border cs.Thickness=1

        -- Left red accent
        local accent = Instance.new("Frame", card)
        accent.Size = UDim2.new(0,2,0.6,0)
        accent.Position = UDim2.new(0,0,0.2,0)
        accent.BackgroundColor3 = C.dim
        accent.BorderSizePixel  = 0
        Instance.new("UICorner",accent).CornerRadius=UDim.new(1,0)

        -- Icon
        local ib = Instance.new("Frame", card)
        ib.Size = UDim2.new(0,30,0,30)
        ib.Position = UDim2.new(0,10,0.5,-15)
        ib.BackgroundColor3 = Color3.fromRGB(25,10,10)
        ib.BorderSizePixel  = 0
        Instance.new("UICorner",ib).CornerRadius=UDim.new(0,7)
        Instance.new("UIStroke",ib).Color=Color3.fromRGB(60,20,20)
        local il = Instance.new("TextLabel",ib) il.Size=UDim2.new(1,0,1,0) il.BackgroundTransparency=1 il.Text=ico il.TextSize=15

        -- Title
        local nl = Instance.new("TextLabel",card)
        nl.Size=UDim2.new(1,-88,0,14) nl.Position=UDim2.new(0,46,0,10)
        nl.BackgroundTransparency=1 nl.Text=title
        nl.TextColor3=C.white nl.Font=Enum.Font.GothamBold nl.TextSize=11
        nl.TextXAlignment=Enum.TextXAlignment.Left

        -- Desc
        local dl = Instance.new("TextLabel",card)
        dl.Size=UDim2.new(1,-88,0,20) dl.Position=UDim2.new(0,46,0,24)
        dl.BackgroundTransparency=1 dl.Text=desc
        dl.TextColor3=C.muted dl.Font=Enum.Font.Gotham dl.TextSize=9
        dl.TextXAlignment=Enum.TextXAlignment.Left dl.TextWrapped=true

        -- Toggle
        local tt = Instance.new("Frame",card)
        tt.Size=UDim2.new(0,36,0,20) tt.Position=UDim2.new(1,-44,0.5,-10)
        tt.BackgroundColor3=Color3.fromRGB(30,30,30) tt.BorderSizePixel=0
        Instance.new("UICorner",tt).CornerRadius=UDim.new(1,0)
        Instance.new("UIStroke",tt).Color=C.border

        local tc = Instance.new("Frame",tt)
        tc.Size=UDim2.new(0,14,0,14) tc.Position=UDim2.new(0,3,0.5,-7)
        tc.BackgroundColor3=C.muted tc.BorderSizePixel=0
        Instance.new("UICorner",tc).CornerRadius=UDim.new(1,0)

        local tbtn = Instance.new("TextButton",tt)
        tbtn.Size=UDim2.new(1,0,1,0) tbtn.BackgroundTransparency=1 tbtn.Text=""

        local on = false
        tbtn.MouseButton1Click:Connect(function()
            on = not on
            local tw2 = TweenInfo.new(0.15)
            if on then
                TweenService:Create(tt,tw2,{BackgroundColor3=C.red}):Play()
                TweenService:Create(tc,tw2,{Position=UDim2.new(0,19,0.5,-7), BackgroundColor3=Color3.new(1,1,1)}):Play()
                accent.BackgroundColor3 = C.red
                cs.Color = Color3.fromRGB(100,20,20)
                nl.TextColor3 = C.red
            else
                TweenService:Create(tt,tw2,{BackgroundColor3=Color3.fromRGB(30,30,30)}):Play()
                TweenService:Create(tc,tw2,{Position=UDim2.new(0,3,0.5,-7), BackgroundColor3=C.muted}):Play()
                accent.BackgroundColor3 = C.dim
                cs.Color = C.border
                nl.TextColor3 = C.white
            end
            if cfgKey then CFG[cfgKey] = on end
            if onToggle then onToggle(on) end
        end)
    end

    local function mkSec(tabName, txt)
        local parent = tabFrames[tabName]
        local f = Instance.new("Frame",parent)
        f.Size=UDim2.new(1,0,0,18) f.BackgroundTransparency=1
        local l=Instance.new("TextLabel",f)
        l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
        l.Text="  "..txt l.TextColor3=C.muted l.Font=Enum.Font.GothamBold
        l.TextSize=9 l.TextXAlignment=Enum.TextXAlignment.Left l.LetterSpacing=2
    end

    -- ═══════════ ЗАПОЛНЯЕМ ТАБЫ ═══════════

    -- MOVE
    mkSec("MOVE","ДВИЖЕНИЕ")
    mkCard("MOVE","⚡","SPEED HACK",    "Плавное ускорение без бана",           "speed")
    mkCard("MOVE","🏃","BUNNY HOP",     "Авто-прыжок при приземлении",          "bhop")
    mkCard("MOVE","🌀","NOCLIP",        "Проходить сквозь стены",               "noclip")
    mkCard("MOVE","🎯","AUTO TP",       "ТП к ближайшему игроку",               nil, function(v)
        if not v then return end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) break end
                end
            end
        end)
    end)

    -- GOD
    mkSec("GOD","ЗАЩИТА")
    mkCard("GOD","🛡","GOD MODE",      "Бесконечное HP — не умрёшь",           "god")
    mkCard("GOD","👁","ESP",           "Игроки сквозь стены",                  "esp")
    mkCard("GOD","💨","ANTI KNOCK",    "Не отбрасывают взрывами",              nil, function(v) setAntiKnock(v) end)
    mkCard("GOD","♾","INF AMMO",      "Бесконечные патроны шерифа",           nil, function(v)
        pcall(function()
            local c=getChar() if not c then return end
            for _,t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end
            end
        end)
    end)

    -- FARM
    mkSec("FARM","ФАРМ")
    mkCard("FARM","💰","COIN FARM",    "Авто-сбор монет (без подъёма)",        "coinFarm")
    mkCard("FARM","🔪","KNIFE AURA",   "Авто-убийство рядом как убийца",       "knife")
    mkCard("FARM","🎁","AUTO REWARD",  "Авто-нажатие наград после раунда",     "autoReward")

    -- MISC
    mkSec("MISC","РАЗНОЕ")
    mkCard("MISC","☀","FULLBRIGHT",   "Максимум яркости, нет теней",          nil, function(v) setFB(v) end)
    mkCard("MISC","🔒","ANTI AFK",     "Защита от кика за бездействие",        "antiAfk")
    mkCard("MISC","👻","HIDE PLAYER",  "Персонаж невидим для других",          nil, function(v) setHide(v) end)
    mkCard("MISC","🌊","ANTI TSUNAMI", "Авто-прыжок от волны цунами",          "antiTsunami")

    -- INFO
    local ipar = tabFrames["INFO"]

    -- Dev block
    local devB = Instance.new("Frame",ipar)
    devB.Size=UDim2.new(1,0,0,85) devB.BackgroundColor3=C.card devB.BorderSizePixel=0
    Instance.new("UICorner",devB).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",devB).Color=C.border
    local drt=Instance.new("Frame",devB) drt.Size=UDim2.new(1,0,0,2) drt.BackgroundColor3=C.red drt.BorderSizePixel=0

    -- Big P logo
    local bp=Instance.new("TextLabel",devB) bp.Size=UDim2.new(0,50,0,55) bp.Position=UDim2.new(0,10,0.5,-27)
    bp.BackgroundTransparency=1 bp.Text="Ᵽ" bp.TextColor3=C.red bp.Font=Enum.Font.GothamBlack bp.TextSize=48

    local dn=Instance.new("TextLabel",devB) dn.Size=UDim2.new(1,-70,0,18) dn.Position=UDim2.new(0,64,0,18)
    dn.BackgroundTransparency=1 dn.Text="Primejtsu" dn.TextColor3=C.white dn.Font=Enum.Font.GothamBold dn.TextSize=15 dn.TextXAlignment=Enum.TextXAlignment.Left

    local dr=Instance.new("TextLabel",devB) dr.Size=UDim2.new(1,-70,0,12) dr.Position=UDim2.new(0,64,0,37)
    dr.BackgroundTransparency=1 dr.Text="Script Developer" dr.TextColor3=C.muted dr.Font=Enum.Font.Code dr.TextSize=10 dr.TextXAlignment=Enum.TextXAlignment.Left

    local tgl=Instance.new("TextLabel",devB) tgl.Size=UDim2.new(1,-70,0,12) tgl.Position=UDim2.new(0,64,0,52)
    tgl.BackgroundTransparency=1 tgl.Text="✈  Telegram: @Primejtsu" tgl.TextColor3=Color3.fromRGB(50,150,220) tgl.Font=Enum.Font.Code tgl.TextSize=10 tgl.TextXAlignment=Enum.TextXAlignment.Left

    local function infoRow(lbl,val,vc)
        local f=Instance.new("Frame",ipar) f.Size=UDim2.new(1,0,0,28) f.BackgroundColor3=C.card f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
        Instance.new("UIStroke",f).Color=C.border
        local l=Instance.new("TextLabel",f) l.Size=UDim2.new(0.5,0,1,0) l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=lbl l.TextColor3=C.muted l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
        local v=Instance.new("TextLabel",f) v.Size=UDim2.new(0.45,0,1,0) v.Position=UDim2.new(0.53,0,0,0) v.BackgroundTransparency=1 v.Text=val v.TextColor3=vc or C.white v.Font=Enum.Font.Code v.TextSize=10 v.TextXAlignment=Enum.TextXAlignment.Right
    end

    infoRow("Версия",       "v3.2",          Color3.fromRGB(0,201,167))
    infoRow("Игра",         "Murder Mystery 2", C.white)
    infoRow("Executor",     "Delta Mobile",  C.white)
    infoRow("Разработчик",  "Primejtsu",     Color3.fromRGB(243,156,18))
    infoRow("Anti-Cheat",   "ACTIVE",        Color3.fromRGB(0,200,100))
    infoRow("Всего фич",    "15",            C.white)

    -- Счётчик монет живой
    local coinRow = Instance.new("Frame",ipar) coinRow.Size=UDim2.new(1,0,0,28) coinRow.BackgroundColor3=C.card coinRow.BorderSizePixel=0
    Instance.new("UICorner",coinRow).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",coinRow).Color=C.border
    local cl=Instance.new("TextLabel",coinRow) cl.Size=UDim2.new(0.5,0,1,0) cl.Position=UDim2.new(0,10,0,0) cl.BackgroundTransparency=1 cl.Text="💰 Монеты" cl.TextColor3=C.muted cl.Font=Enum.Font.GothamBold cl.TextSize=11 cl.TextXAlignment=Enum.TextXAlignment.Left
    local cv=Instance.new("TextLabel",coinRow) cv.Size=UDim2.new(0.45,0,1,0) cv.Position=UDim2.new(0.53,0,0,0) cv.BackgroundTransparency=1 cv.Text="0" cv.TextColor3=Color3.fromRGB(243,156,18) cv.Font=Enum.Font.Code cv.TextSize=10 cv.TextXAlignment=Enum.TextXAlignment.Right

    RunService.Heartbeat:Connect(function()
        cv.Text = tostring(coinCount)
    end)

    -- ═══════════ ТАБЫ ═══════════
    local tabBtns = {}
    local tbLayout = Instance.new("UIListLayout",TB)
    tbLayout.FillDirection = Enum.FillDirection.Horizontal

    local function switchTab(name)
        for k,b in pairs(tabBtns) do
            b.TextColor3 = C.muted
            local i=b:FindFirstChild("I") if i then i.Visible=false end
        end
        tabBtns[name].TextColor3 = C.white
        local i=tabBtns[name]:FindFirstChild("I") if i then i.Visible=true end

        -- Убираем старый контент
        for _,ch in ipairs(SC:GetChildren()) do
            if ch:IsA("Frame") and ch ~= SCL and ch ~= SCP then
                ch.Parent = nil
            end
        end
        -- Показываем новый
        tabFrames[name].Parent = SC
        task.wait()
        SC.CanvasSize = UDim2.new(0,0,0, SCL.AbsoluteContentSize.Y+14)
    end

    for _, name in ipairs(TABS) do
        local b = Instance.new("TextButton",TB)
        b.Size = UDim2.new(0,54,1,0)
        b.BackgroundTransparency = 1
        b.Text = name
        b.TextColor3 = C.muted
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9
        b.BorderSizePixel = 0

        local ind = Instance.new("Frame",b) ind.Name="I"
        ind.Size=UDim2.new(0.8,0,0,2) ind.Position=UDim2.new(0.1,0,1,-2)
        ind.BackgroundColor3=C.red ind.BorderSizePixel=0 ind.Visible=false
        Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)

        tabBtns[name] = b
        b.MouseButton1Click:Connect(function() switchTab(name) end)
    end

    task.wait(0.1)
    switchTab("MOVE")

end -- end showMainGUI

print("[PrimejTsuHub v3.2] Запущен! | @Primejtsu")
