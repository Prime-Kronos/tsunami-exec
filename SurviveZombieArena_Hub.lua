-- ╔══════════════════════════════════════════════════╗
-- ║   SURVIVE ZOMBIE ARENA v2.0 - TSUNAMI HUB       ║
-- ║   Полная перезапись | Работает на всех exec      ║
-- ╚══════════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local LP            = Players.LocalPlayer
local Mouse         = LP:GetMouse()

-- Утилита: получить свежего персонажа
local function GetChar()
    return LP.Character
end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ══════════════════════════════
-- НАСТРОЙКИ
-- ══════════════════════════════
local Flags = {
    GodMode       = false,
    KillAura      = false,
    KillAuraRange = 40,
    AutoFarm      = false,
    AutoCollect   = false,
    RapidFire     = false,
    InfAmmo       = false,
    NoClip        = false,
    SpeedHack     = false,
    HighJump      = false,
    AutoDodge     = false,
    ESP           = false,
    FlyMode       = false,
}

-- ══════════════════════════════
-- УДАЛИТЬ СТАРЫЙ GUI
-- ══════════════════════════════
if game.CoreGui:FindFirstChild("TsunamiHub") then
    game.CoreGui.TsunamiHub:Destroy()
end

-- ══════════════════════════════
-- СОЗДАНИЕ ЭКРАНА
-- ══════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name          = "TsunamiHub"
SG.ResetOnSpawn  = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent        = game.CoreGui

-- Главный фрейм
local MF = Instance.new("Frame")
MF.Name              = "Main"
MF.Size              = UDim2.new(0, 400, 0, 520)
MF.Position          = UDim2.new(0.5,-200,0.5,-260)
MF.BackgroundColor3  = Color3.fromRGB(12, 12, 18)
MF.BorderSizePixel   = 0
MF.ClipsDescendants  = true
MF.Parent            = SG

Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke", MF)
Stroke.Color     = Color3.fromRGB(200, 0, 0)
Stroke.Thickness = 2

-- ШАПКА
local Head = Instance.new("Frame", MF)
Head.Size             = UDim2.new(1,0,0,48)
Head.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Head.BorderSizePixel  = 0

local HeadCorner = Instance.new("UICorner", Head)
HeadCorner.CornerRadius = UDim.new(0,14)

-- Квадратный низ шапки
local HeadFix = Instance.new("Frame", Head)
HeadFix.Size             = UDim2.new(1,0,0.5,0)
HeadFix.Position         = UDim2.new(0,0,0.5,0)
HeadFix.BackgroundColor3 = Color3.fromRGB(200,0,0)
HeadFix.BorderSizePixel  = 0

local Title = Instance.new("TextLabel", Head)
Title.Size               = UDim2.new(1,-100,1,0)
Title.Position           = UDim2.new(0,14,0,0)
Title.BackgroundTransparency = 1
Title.Text               = "🧟  TSUNAMI HUB  v2.0"
Title.TextColor3         = Color3.fromRGB(255,255,255)
Title.TextSize           = 17
Title.Font               = Enum.Font.GothamBold
Title.TextXAlignment     = Enum.TextXAlignment.Left

-- Кнопки шапки
local function MakeHeadBtn(pos, txt, col)
    local b = Instance.new("TextButton", Head)
    b.Size              = UDim2.new(0,28,0,28)
    b.Position          = UDim2.new(1, pos, 0.5, -14)
    b.BackgroundColor3  = col
    b.Text              = txt
    b.TextColor3        = Color3.new(1,1,1)
    b.TextSize          = 13
    b.Font              = Enum.Font.GothamBold
    b.BorderSizePixel   = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    return b
end

local BtnClose = MakeHeadBtn(-36, "✕", Color3.fromRGB(220,50,50))
local BtnMin   = MakeHeadBtn(-70, "–", Color3.fromRGB(255,170,0))

-- Строка статуса
local StatBar = Instance.new("Frame", MF)
StatBar.Size             = UDim2.new(1,-20,0,26)
StatBar.Position         = UDim2.new(0,10,0,54)
StatBar.BackgroundColor3 = Color3.fromRGB(20,20,30)
StatBar.BorderSizePixel  = 0
Instance.new("UICorner",StatBar).CornerRadius = UDim.new(0,6)

local StatLbl = Instance.new("TextLabel", StatBar)
StatLbl.Size              = UDim2.new(1,-10,1,0)
StatLbl.Position          = UDim2.new(0,8,0,0)
StatLbl.BackgroundTransparency = 1
StatLbl.Text              = "⚡ Готов к работе"
StatLbl.TextColor3        = Color3.fromRGB(100,255,100)
StatLbl.TextSize          = 12
StatLbl.Font              = Enum.Font.Gotham
StatLbl.TextXAlignment    = Enum.TextXAlignment.Left

local function Status(msg, col)
    StatLbl.Text      = "⚡ " .. msg
    StatLbl.TextColor3 = col or Color3.fromRGB(100,255,100)
end

-- ВКЛАДКИ
local TabBar = Instance.new("Frame", MF)
TabBar.Size             = UDim2.new(1,-20,0,32)
TabBar.Position         = UDim2.new(0,10,0,86)
TabBar.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding       = UDim.new(0,5)

-- КОНТЕНТ
local Content = Instance.new("ScrollingFrame", MF)
Content.Size                 = UDim2.new(1,-20,1,-130)
Content.Position             = UDim2.new(0,10,0,124)
Content.BackgroundTransparency = 1
Content.BorderSizePixel      = 0
Content.ScrollBarThickness   = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(200,0,0)
Content.CanvasSize           = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize  = Enum.AutomaticSize.Y

local ConLayout = Instance.new("UIListLayout", Content)
ConLayout.Padding = UDim.new(0,7)

-- ══════════════════════════════
-- СИСТЕМА ВКЛАДОК
-- ══════════════════════════════
local Tabs       = {}
local ActiveTab  = nil

local function MakeTab(name, icon)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size             = UDim2.new(0,74,1,0)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,40)
    btn.Text             = icon.." "..name
    btn.TextColor3       = Color3.fromRGB(160,160,160)
    btn.TextSize         = 11
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,7)

    local pages = {}
    Tabs[name] = {btn=btn, pages=pages}

    btn.MouseButton1Click:Connect(function()
        if ActiveTab then
            Tabs[ActiveTab].btn.BackgroundColor3 = Color3.fromRGB(28,28,40)
            Tabs[ActiveTab].btn.TextColor3       = Color3.fromRGB(160,160,160)
            for _,p in pairs(Tabs[ActiveTab].pages) do p.Visible = false end
        end
        ActiveTab = name
        btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
        btn.TextColor3       = Color3.fromRGB(255,255,255)
        for _,p in pairs(pages) do p.Visible = true end
        Content.CanvasPosition = Vector2.new(0,0)
    end)

    return pages
end

-- ══════════════════════════════
-- ЭЛЕМЕНТЫ GUI
-- ══════════════════════════════
local function Section(pages, text)
    local f = Instance.new("TextLabel")
    f.Size               = UDim2.new(1,-8,0,20)
    f.BackgroundTransparency = 1
    f.Text               = "  ─── "..text.." ───"
    f.TextColor3         = Color3.fromRGB(200,0,0)
    f.TextSize           = 11
    f.Font               = Enum.Font.GothamBold
    f.TextXAlignment     = Enum.TextXAlignment.Left
    f.Parent             = Content
    table.insert(pages, f)
    return f
end

local function Toggle(pages, label, flag, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-8,0,40)
    row.BackgroundColor3 = Color3.fromRGB(20,20,30)
    row.BorderSizePixel  = 0
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,9)
    row.Parent = Content
    table.insert(pages, row)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(1,-60,1,0)
    lbl.Position         = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = Color3.fromRGB(220,220,220)
    lbl.TextSize         = 13
    lbl.Font             = Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    local tbtn = Instance.new("TextButton", row)
    tbtn.Size            = UDim2.new(0,46,0,24)
    tbtn.Position        = UDim2.new(1,-56,0.5,-12)
    tbtn.BackgroundColor3= Color3.fromRGB(45,45,58)
    tbtn.Text            = ""
    tbtn.BorderSizePixel = 0
    Instance.new("UICorner",tbtn).CornerRadius = UDim.new(1,0)

    local circle = Instance.new("Frame", tbtn)
    circle.Size          = UDim2.new(0,18,0,18)
    circle.Position      = UDim2.new(0,3,0.5,-9)
    circle.BackgroundColor3 = Color3.fromRGB(160,160,160)
    circle.BorderSizePixel = 0
    Instance.new("UICorner",circle).CornerRadius = UDim.new(1,0)

    local state = Flags[flag] or false
    local function Refresh()
        TweenService:Create(circle, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        }):Play()
        tbtn.BackgroundColor3  = state and Color3.fromRGB(200,0,0) or Color3.fromRGB(45,45,58)
        circle.BackgroundColor3= state and Color3.new(1,1,1) or Color3.fromRGB(160,160,160)
    end
    Refresh()

    tbtn.MouseButton1Click:Connect(function()
        state = not state
        Flags[flag] = state
        Refresh()
        if cb then cb(state) end
        Status(label..": "..(state and "ВКЛ ✅" or "ВЫКЛ ❌"),
            state and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100))
    end)
end

local function Button(pages, label, col, cb)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-8,0,38)
    btn.BackgroundColor3 = col or Color3.fromRGB(200,0,0)
    btn.Text             = label
    btn.TextColor3       = Color3.new(1,1,1)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,9)
    btn.Parent = Content
    table.insert(pages, btn)

    btn.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{
            BackgroundColor3 = Color3.new(
                math.min(col.R+0.12,1),
                math.min(col.G+0.12,1),
                math.min(col.B+0.12,1))
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=col}):Play()
    end)
end

-- ══════════════════════════════
-- СОЗДАНИЕ ВКЛАДОК
-- ══════════════════════════════
local pAuto   = MakeTab("Авто",   "🤖")
local pPlayer = MakeTab("Игрок",  "⚡")
local pWeapon = MakeTab("Оружие", "🔫")
local pVisual = MakeTab("Визуал", "👁")
local pMisc   = MakeTab("Прочее", "⚙")

-- Активировать первую
Tabs["Авто"].btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
Tabs["Авто"].btn.TextColor3       = Color3.fromRGB(255,255,255)
for _,p in pairs(pAuto) do p.Visible = true end
ActiveTab = "Авто"

-- ══════════════════════════════
-- TAB: АВТО
-- ══════════════════════════════
Section(pAuto, "Авто-Фарм")
Toggle(pAuto, "🧟 Авто Убийство Зомби", "AutoFarm")
Toggle(pAuto, "💰 Авто Сбор Кредитов", "AutoCollect")
Toggle(pAuto, "🏃 Авто Уворот", "AutoDodge")

Section(pAuto, "Быстрые Действия")
Button(pAuto, "💀 Убить всех зомби в радиусе 80", Color3.fromRGB(160,0,0), function()
    local n = 0
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= GetChar() then
            local r = v.Parent:FindFirstChild("HumanoidRootPart")
            local root = GetRoot()
            if r and root and (root.Position-r.Position).Magnitude < 80 then
                v.Health = 0; n = n+1
            end
        end
    end
    Status("Уничтожено: "..n.." зомби", Color3.fromRGB(255,80,80))
end)

Button(pAuto, "💀 УБИТЬ ВСЕХ НА КАРТЕ", Color3.fromRGB(120,0,0), function()
    local n = 0
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= GetChar() then
            v.Health = 0; n = n+1
        end
    end
    Status("Убито всего: "..n, Color3.fromRGB(255,50,50))
end)

Button(pAuto, "📍 ТП в центр арены", Color3.fromRGB(30,100,200), function()
    local r = GetRoot()
    if r then r.CFrame = CFrame.new(0,5,0) end
    Status("Телепорт в центр!", Color3.fromRGB(100,200,255))
end)

-- ══════════════════════════════
-- TAB: ИГРОК
-- ══════════════════════════════
Section(pPlayer, "Выживание")
Toggle(pPlayer, "❤️ GOD MODE (бесконечное HP)", "GodMode", function(v)
    if v then Status("GOD MODE ВКЛ — ты бессмертен!", Color3.fromRGB(255,80,80)) end
end)
Toggle(pPlayer, "🌊 NoClip (сквозь стены)", "NoClip")
Toggle(pPlayer, "🚀 Speed Hack (WS 80)", "SpeedHack", function(v)
    local h = GetHum()
    if h then h.WalkSpeed = v and 80 or 16 end
end)
Toggle(pPlayer, "🦘 High Jump (JP 150)", "HighJump", function(v)
    local h = GetHum()
    if h then h.JumpPower = v and 150 or 50 end
end)
Toggle(pPlayer, "✈️ Fly Mode", "FlyMode")

Section(pPlayer, "Телепорт")
Button(pPlayer, "📍 ТП к ближайшему зомби", Color3.fromRGB(140,60,0), function()
    local root = GetRoot()
    if not root then return end
    local best, bd = nil, math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent~=GetChar() and v.Health>0 then
            local r = v.Parent:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (root.Position-r.Position).Magnitude
                if d<bd then bd=d; best=r end
            end
        end
    end
    if best then
        root.CFrame = best.CFrame + Vector3.new(0,5,3)
        Status("ТП к зомби!", Color3.fromRGB(255,160,0))
    else
        Status("Зомби не найдены!", Color3.fromRGB(255,80,80))
    end
end)

Button(pPlayer, "📍 ТП в Спавн", Color3.fromRGB(0,120,60), function()
    local root = GetRoot()
    if root then root.CFrame = CFrame.new(0,10,0) end
    Status("ТП в спавн!", Color3.fromRGB(100,255,100))
end)

Section(pPlayer, "Статы")
Button(pPlayer, "⚡ WalkSpeed = 100", Color3.fromRGB(200,130,0), function()
    local h = GetHum(); if h then h.WalkSpeed=100 end
    Status("WalkSpeed: 100", Color3.fromRGB(255,200,0))
end)
Button(pPlayer, "🔄 Сброс WalkSpeed/Jump", Color3.fromRGB(50,50,70), function()
    local h = GetHum()
    if h then h.WalkSpeed=16; h.JumpPower=50 end
    Status("Сброс скорости и прыжка.", Color3.fromRGB(180,180,180))
end)

-- ══════════════════════════════
-- TAB: ОРУЖИЕ
-- ══════════════════════════════
Section(pWeapon, "Боевые Функции")
Toggle(pWeapon, "⚔️ Kill Aura (30 studs)", "KillAura", function(v)
    Status(v and "Kill Aura ВКЛ — зомби умирают рядом!" or "Kill Aura ВЫКЛ",
        v and Color3.fromRGB(255,80,80) or Color3.fromRGB(180,180,180))
end)
Toggle(pWeapon, "🔫 Rapid Fire (без задержки)", "RapidFire", function(v)
    -- Патчим FireRate всех Tool'ов в инвентаре
    local function PatchTools()
        for _,tool in pairs(LP.Backpack:GetChildren()) do
            for _,s in pairs(tool:GetDescendants()) do
                if s:IsA("Script") or s:IsA("LocalScript") then
                    -- Ищем FireRate / Cooldown переменные через атрибуты
                    for attrName, _ in pairs(s:GetAttributes()) do
                        local low = attrName:lower()
                        if low:find("fire") or low:find("cool") or low:find("delay") or low:find("rate") then
                            s:SetAttribute(attrName, v and 0.01 or nil)
                        end
                    end
                end
            end
            -- Попытка напрямую через Configuration
            local cfg = tool:FindFirstChild("Configuration") or tool:FindFirstChildOfClass("Configuration")
            if cfg then
                for _,val in pairs(cfg:GetChildren()) do
                    local low = val.Name:lower()
                    if low:find("fire") or low:find("cool") or low:find("delay") or low:find("rate") or low:find("rpm") then
                        if val:IsA("NumberValue") or val:IsA("IntValue") then
                            if v then
                                val.Value = 0.01
                            end
                        end
                    end
                end
            end
        end
    end
    PatchTools()
    Status(v and "Rapid Fire ВКЛ!" or "Rapid Fire ВЫКЛ", v and Color3.fromRGB(255,200,0) or Color3.fromRGB(180,180,180))
end)

Toggle(pWeapon, "♾️ Inf Ammo (авто перезаряд)", "InfAmmo", function(v)
    Status(v and "Inf Ammo ВКЛ!" or "Inf Ammo ВЫКЛ", v and Color3.fromRGB(100,255,200) or Color3.fromRGB(180,180,180))
end)

Section(pWeapon, "Kill Aura Радиус")
Button(pWeapon, "📏 Радиус: 30 studs (норм)", Color3.fromRGB(80,0,160), function()
    Flags.KillAuraRange = 30
    Status("Kill Aura радиус: 30", Color3.fromRGB(200,100,255))
end)
Button(pWeapon, "📏 Радиус: 60 studs (большой)", Color3.fromRGB(120,0,200), function()
    Flags.KillAuraRange = 60
    Status("Kill Aura радиус: 60", Color3.fromRGB(200,100,255))
end)
Button(pWeapon, "📏 Радиус: 150 (вся карта)", Color3.fromRGB(160,0,200), function()
    Flags.KillAuraRange = 150
    Status("Kill Aura радиус: 150 (вся карта!)", Color3.fromRGB(255,80,255))
end)

-- ══════════════════════════════
-- TAB: ВИЗУАЛ
-- ══════════════════════════════
Section(pVisual, "ESP")
Toggle(pVisual, "🔴 Зомби ESP", "ESP")

Button(pVisual, "🔦 Создать ESP на всех зомби", Color3.fromRGB(150,0,150), function()
    local n = 0
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent~=GetChar() and v.Health>0 then
            local r = v.Parent:FindFirstChild("HumanoidRootPart")
            if r and not r:FindFirstChild("_ESP") then
                local bb = Instance.new("BillboardGui", r)
                bb.Name="\_ESP"; bb.Size=UDim2.new(0,70,0,26)
                bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true
                local lbl=Instance.new("TextLabel",bb)
                lbl.Size=UDim2.new(1,0,1,0)
                lbl.BackgroundColor3=Color3.fromRGB(180,0,0)
                lbl.BackgroundTransparency=0.25
                lbl.TextColor3=Color3.new(1,1,1)
                lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold
                lbl.Text="🧟 ZOMBIE"
                Instance.new("UICorner",lbl).CornerRadius=UDim.new(0,4)
                n=n+1
            end
        end
    end
    Status("ESP создан: "..n.." зомби", Color3.fromRGB(255,150,255))
end)

Button(pVisual, "🗑 Убрать все ESP", Color3.fromRGB(50,50,70), function()
    local n=0
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name=="_ESP" then v:Destroy(); n=n+1 end
    end
    Status("Удалено ESP: "..n, Color3.fromRGB(180,180,180))
end)

Section(pVisual, "Камера / Графика")
Button(pVisual, "🔭 FOV: 120", Color3.fromRGB(0,80,160), function()
    workspace.CurrentCamera.FieldOfView=120
    Status("FOV: 120", Color3.fromRGB(100,180,255))
end)
Button(pVisual, "🔄 FOV: 70 (стандарт)", Color3.fromRGB(50,50,70), function()
    workspace.CurrentCamera.FieldOfView=70
    Status("FOV сброшен.", Color3.fromRGB(180,180,180))
end)

-- ══════════════════════════════
-- TAB: ПРОЧЕЕ
-- ══════════════════════════════
Section(pMisc, "Инфо")
Button(pMisc, "📊 Показать мой HP / Speed", Color3.fromRGB(0,100,160), function()
    local h=GetHum()
    if h then
        Status("HP: "..math.floor(h.Health).."/"..math.floor(h.MaxHealth).."  WS: "..h.WalkSpeed, Color3.fromRGB(100,220,255))
    end
end)
Button(pMisc, "🔔 Сколько зомби на карте", Color3.fromRGB(100,60,0), function()
    local n=0
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent~=GetChar() and v.Health>0 then n=n+1 end
    end
    Status("Живых зомби: "..n, Color3.fromRGB(255,160,0))
end)

Section(pMisc, "Система")
Button(pMisc, "❌ Закрыть хаб", Color3.fromRGB(180,0,0), function()
    local tw=TweenService:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
        Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)
    })
    tw:Play(); tw.Completed:Connect(function() SG:Destroy() end)
end)

-- Скрыть все страницы кроме активной
for name,tab in pairs(Tabs) do
    if name ~= "Авто" then
        for _,p in pairs(tab.pages) do p.Visible = false end
    end
end

-- ══════════════════════════════
-- КНОПКИ ШАПКИ
-- ══════════════════════════════
BtnClose.MouseButton1Click:Connect(function()
    local tw=TweenService:Create(MF,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
        Size=UDim2.new(0,400,0,0), Position=UDim2.new(0.5,-200,0.5,0)
    })
    tw:Play(); tw.Completed:Connect(function() SG:Destroy() end)
end)

local minimized = false
BtnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(MF,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
        Size = minimized and UDim2.new(0,400,0,48) or UDim2.new(0,400,0,520)
    }):Play()
    BtnMin.Text = minimized and "□" or "–"
end)

-- ══════════════════════════════
-- DRAG
-- ══════════════════════════════
do
    local drag, ds, sp = false, nil, nil
    Head.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=MF.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
end

-- ══════════════════════════════
-- FLY СИСТЕМА
-- ══════════════════════════════
local flyBV, flyGyro
local function StartFly()
    local root = GetRoot()
    if not root then return end
    local hum = GetHum()
    if hum then hum.PlatformStand = true end
    flyBV = Instance.new("BodyVelocity", root)
    flyBV.Velocity = Vector3.zero
    flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    flyGyro = Instance.new("BodyGyro", root)
    flyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    flyGyro.P = 1e4
end
local function StopFly()
    if flyBV then flyBV:Destroy(); flyBV=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
    local hum = GetHum()
    if hum then hum.PlatformStand = false end
end

-- ══════════════════════════════
-- ГЛАВНЫЙ LOOP
-- ══════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    local char = GetChar()
    if not char then return end
    local hum  = GetHum()
    local root = GetRoot()
    if not hum or not root then return end

    -- GOD MODE (aggressively restore HP)
    if Flags.GodMode then
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        -- Также блокируем дамаг через защиту
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end

    -- NOCLIP
    if Flags.NoClip then
        for _,p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    -- SPEED HACK
    if Flags.SpeedHack and hum.WalkSpeed ~= 80 then
        hum.WalkSpeed = 80
    end

    -- HIGH JUMP
    if Flags.HighJump and hum.JumpPower ~= 150 then
        hum.JumpPower = 150
    end

    -- KILL AURA
    if Flags.KillAura then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent~=char and v.Health>0 then
                local r = v.Parent:FindFirstChild("HumanoidRootPart")
                if r then
                    local dist = (root.Position - r.Position).Magnitude
                    if dist <= Flags.KillAuraRange then
                        v.Health = 0
                    end
                end
            end
        end
    end

    -- AUTO DODGE
    if Flags.AutoDodge then
        local near, nd = nil, math.huge
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent~=char and v.Health>0 then
                local r = v.Parent:FindFirstChild("HumanoidRootPart")
                if r then
                    local d=(root.Position-r.Position).Magnitude
                    if d<nd then nd=d; near=r end
                end
            end
        end
        if near and nd<12 then
            local dir=(root.Position-near.Position).Unit
            root.CFrame=root.CFrame+dir*0.8
        end
    end

    -- AUTO COLLECT
    if Flags.AutoCollect then
        for _,obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("credit") or n:find("drop") or n:find("coin") or n:find("pickup") then
                    local d=(root.Position-obj.Position).Magnitude
                    if d<60 then
                        root.CFrame = CFrame.new(obj.Position+Vector3.new(0,3,0))
                    end
                end
            end
        end
    end

    -- INF AMMO (пытаемся найти Ammo значения в инвентаре)
    if Flags.InfAmmo then
        for _,tool in pairs(LP.Backpack:GetChildren()) do
            for _,v in pairs(tool:GetDescendants()) do
                local n=v.Name:lower()
                if (n:find("ammo") or n:find("bullet") or n:find("mag")) and (v:IsA("IntValue") or v:IsA("NumberValue")) then
                    if v.Value < 100 then v.Value = 9999 end
                end
            end
        end
        -- Также в char (текущий Tool)
        for _,tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _,v in pairs(tool:GetDescendants()) do
                    local n=v.Name:lower()
                    if (n:find("ammo") or n:find("bullet") or n:find("mag")) and (v:IsA("IntValue") or v:IsA("NumberValue")) then
                        if v.Value < 100 then v.Value = 9999 end
                    end
                end
            end
        end
    end

    -- ESP ОБНОВЛЕНИЕ HP
    if Flags.ESP then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent~=char and v.Health>0 then
                local r = v.Parent:FindFirstChild("HumanoidRootPart")
                if r then
                    local bb = r:FindFirstChild("_ESP")
                    if not bb then
                        bb = Instance.new("BillboardGui", r)
                        bb.Name="\_ESP"; bb.Size=UDim2.new(0,80,0,28)
                        bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true
                        local lbl=Instance.new("TextLabel",bb)
                        lbl.Name="Lbl"; lbl.Size=UDim2.new(1,0,1,0)
                        lbl.BackgroundColor3=Color3.fromRGB(180,0,0)
                        lbl.BackgroundTransparency=0.2
                        lbl.TextColor3=Color3.new(1,1,1)
                        lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold
                        Instance.new("UICorner",lbl).CornerRadius=UDim.new(0,4)
                    end
                    local lbl=bb:FindFirstChild("Lbl")
                    if lbl then
                        lbl.Text=("🧟 HP: %d"):format(math.floor(v.Health))
                    end
                end
            end
        end
    end

    -- FLY
    if Flags.FlyMode then
        if not flyBV then StartFly() end
        if flyBV then
            local cam = workspace.CurrentCamera
            local spd = 40
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector * spd end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector * spd end
            if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector * spd end
            if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector * spd end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,spd,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,spd,0) end
            flyBV.Velocity = vel
            flyGyro.CFrame = cam.CFrame
        end
    else
        if flyBV then StopFly() end
    end
end)

-- ══════════════════════════════
-- АНИМАЦИЯ ОТКРЫТИЯ
-- ══════════════════════════════
MF.Size     = UDim2.new(0,0,0,0)
MF.Position = UDim2.new(0.5,0,0.5,0)
TweenService:Create(MF, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {
    Size     = UDim2.new(0,400,0,520),
    Position = UDim2.new(0.5,-200,0.5,-260),
}):Play()

Status("Tsunami Hub v2.0 загружен! 🧟", Color3.fromRGB(100,255,100))
print("[TsunamiHub v2.0] Загружен успешно!")
