-- ╔══════════════════════════════════════════════════╗
-- ║         PrimejTsuHub • Murder Mystery 2          ║
-- ║         Разработчик: Primejtsu                   ║
-- ║         Telegram: @Primejtsu                     ║
-- ║         Версия: v3.0 | Delta Mobile              ║
-- ╚══════════════════════════════════════════════════╝

-- ═══════════════════════════════
--        ANTI-CHEAT SYSTEM
-- ═══════════════════════════════
local AC = {}

-- Рандомизация задержек чтобы не палиться
AC.randomDelay = function(min, max)
    return min + math.random() * (max - min)
end

-- Humanize movement (не телепортировать резко)
AC.humanizeTP = function(hrp, targetCF)
    local steps = 8
    local startCF = hrp.CFrame
    for i = 1, steps do
        hrp.CFrame = startCF:Lerp(targetCF, i / steps)
        task.wait(0.03)
    end
end

-- Лимит действий в секунду
AC.actionCooldown = 0.5
AC.lastAction = 0
AC.canAct = function()
    local now = tick()
    if now - AC.lastAction >= AC.actionCooldown then
        AC.lastAction = now
        return true
    end
    return false
end

-- Скрыть RemoteEvent вызовы (через pcall)
AC.safeCall = function(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        -- тихо глотаем ошибку, не крашим
    end
end

-- ═══════════════════════════════
--         SERVICES
-- ═══════════════════════════════
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Lighting       = game:GetService("Lighting")
local Camera         = workspace.CurrentCamera
local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

-- ═══════════════════════════════
--         SETTINGS
-- ═══════════════════════════════
local CFG = {
    -- MOVE
    SpeedEnabled   = false,
    SpeedValue     = 28,          -- (норм. 16, не ставь >50 — забанят)
    NoclipEnabled  = false,
    FreeCamEnabled = false,
    ObserverMode   = false,
    JumpEnabled    = false,
    JumpPower      = 60,

    -- GOD
    GodEnabled     = false,
    ESPEnabled     = false,
    ESPMurderer    = true,
    ESPSheriff     = true,
    ESPInnocent    = false,
    AimbotEnabled  = false,
    AimbotFOV      = 120,
    InfAmmoEnabled = false,

    -- FARM
    CoinFarmEnabled    = false,
    AutoPickupEnabled  = false,
    KnifeAuraEnabled   = false,
    KnifeAuraRadius    = 10,

    -- MISC
    FullBrightEnabled  = false,
    AntiAFKEnabled     = true,    -- включён по умолчанию
    ChatSpamEnabled    = false,
    ChatSpamMsg        = "PrimejTsuHub v3.0 | @Primejtsu",
    WalkAnimEnabled    = false,   -- отключает анимацию (тише)

    -- OBSERVER
    FreeCamSpeed = 1,
}

-- ═══════════════════════════════
--      ESP DRAWING SYSTEM
-- ═══════════════════════════════
local ESPObjects = {}

local function clearESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    clearESP(player)

    local objects = {}

    -- Box ESP через Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 80, 0, 120)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = nil -- назначим когда появится char
    billboard.Parent = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Text = player.Name

    local healthLabel = Instance.new("TextLabel", billboard)
    healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.25, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextStrokeTransparency = 0
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextSize = 11

    objects.billboard = billboard
    objects.nameLabel = nameLabel
    objects.healthLabel = healthLabel
    ESPObjects[player] = objects

    -- Обновляем когда появляется персонаж
    local function onChar(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hrp or not hum then return end

        billboard.Adornee = hrp
        billboard.Enabled = CFG.ESPEnabled

        -- Цвет по роли (определяем по тегам)
        local color = Color3.fromRGB(80, 255, 120) -- innocent
        local tag = player:FindFirstChild("PlayerGui") and
                    player.PlayerGui:FindFirstChild("Role")
        -- Fallback: murderer красный, sheriff синий
        nameLabel.TextColor3 = color
        healthLabel.TextColor3 = color

        -- Живое обновление HP
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            local hp = math.floor(hum.Health)
            healthLabel.Text = "HP: " .. hp
        end)
        healthLabel.Text = "HP: " .. math.floor(hum.Health)
    end

    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

-- ═══════════════════════════════
--       AIMBOT SYSTEM
-- ═══════════════════════════════
local function getNearestPlayer()
    local nearest, nearestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = Vector2.new(screenPos.X, screenPos.Y) -
                                 Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    if dist.Magnitude < CFG.AimbotFOV and dist.Magnitude < nearestDist then
                        nearestDist = dist.Magnitude
                        nearest = p
                    end
                end
            end
        end
    end
    return nearest
end

-- ═══════════════════════════════
--       FREE CAM SYSTEM
-- ═══════════════════════════════
local FreeCam = {}
FreeCam.active = false
FreeCam.connection = nil
FreeCam.cf = CFrame.new(0,10,0)
FreeCam.speed = 0.5

function FreeCam:Enable()
    self.active = true
    Camera.CameraType = Enum.CameraType.Scriptable
    self.cf = Camera.CFrame

    self.connection = RunService.RenderStepped:Connect(function(dt)
        if not self.active then return end

        local mv = Vector3.new(0,0,0)
        -- W A S D на мобиле симулируем кнопками (на ПК работает)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv + Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv + Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Vector3.new(1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then mv = mv + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then mv = mv + Vector3.new(0,-1,0) end

        if mv.Magnitude > 0 then
            self.cf = self.cf * CFrame.new(mv * CFG.FreeCamSpeed * 0.4)
        end

        Camera.CFrame = self.cf
    end)

    print("[PrimejTsuHub] FreeCam ON")
end

function FreeCam:Disable()
    self.active = false
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    Camera.CameraType = Enum.CameraType.Custom
    -- Переход в Observer Mode
    CFG.ObserverMode = true
    ObserverMode:Enable()
    print("[PrimejTsuHub] FreeCam OFF → Observer Mode")
end

-- ═══════════════════════════════
--      OBSERVER MODE
-- ═══════════════════════════════
ObserverMode = {}
ObserverMode.spectateIndex = 1
ObserverMode.spectateConn = nil

function ObserverMode:Enable()
    -- Спектируем следующего живого игрока
    local alivePlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and
           p.Character:FindFirstChildOfClass("Humanoid") and
           p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            table.insert(alivePlayers, p)
        end
    end

    if #alivePlayers == 0 then
        Camera.CameraType = Enum.CameraType.Custom
        CFG.ObserverMode = false
        return
    end

    self.spectateIndex = math.clamp(self.spectateIndex, 1, #alivePlayers)
    local target = alivePlayers[self.spectateIndex]
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
    print("[PrimejTsuHub] Observer → " .. target.Name)
end

function ObserverMode:Next()
    self.spectateIndex = self.spectateIndex + 1
    self:Enable()
end

function ObserverMode:Disable()
    CFG.ObserverMode = false
    Camera.CameraType = Enum.CameraType.Custom
    local hum = LocalPlayer.Character and
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then Camera.CameraSubject = hum end
end

-- ═══════════════════════════════
--       MAIN LOOPS
-- ═══════════════════════════════

-- Noclip loop
RunService.Stepped:Connect(function()
    if not CFG.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p ~= char.PrimaryPart then
            p.CanCollide = false
        end
    end
end)

-- God mode loop
RunService.Heartbeat:Connect(function()
    if not CFG.GodEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
    end
end)

-- Speed loop
RunService.Heartbeat:Connect(function()
    if not CFG.SpeedEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        -- Плавное изменение — не резко (anti-cheat)
        hum.WalkSpeed = math.min(hum.WalkSpeed + 1, CFG.SpeedValue)
    end
end)

-- Jump loop
RunService.Heartbeat:Connect(function()
    if not CFG.JumpEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = CFG.JumpPower end
end)

-- ESP update loop
RunService.Heartbeat:Connect(function()
    if not CFG.ESPEnabled then return end
    for player, objects in pairs(ESPObjects) do
        if objects.billboard then
            objects.billboard.Enabled = true
        end
    end
end)

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not CFG.AimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local target = getNearestPlayer()
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- Плавный поворот камеры (не телепорт — humanized)
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, hrp.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.3)
end)

-- Coin farm loop
local coinConn
local function startCoinFarm()
    coinConn = RunService.Heartbeat:Connect(function()
        if not CFG.CoinFarmEnabled then return end
        if not AC.canAct() then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj.Name == "Coin" or obj.Name == "DropCoin") and obj:IsA("BasePart") then
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < 60 then
                    -- Humanized подход (не телепорт)
                    AC.humanizeTP(hrp, CFrame.new(obj.Position + Vector3.new(0,3,0)))
                    task.wait(AC.randomDelay(0.1, 0.25))
                end
            end
        end
    end)
end
startCoinFarm()

-- Knife Aura loop (murder role)
RunService.Heartbeat:Connect(function()
    if not CFG.KnifeAuraEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if tHRP and hum and hum.Health > 0 then
                local dist = (hrp.Position - tHRP.Position).Magnitude
                if dist <= CFG.KnifeAuraRadius then
                    -- Симулируем нажатие (без FireServer напрямую — тише)
                    AC.safeCall(function()
                        hrp.CFrame = CFrame.new(tHRP.Position + Vector3.new(0,0,2))
                    end)
                    task.wait(AC.randomDelay(0.3, 0.7))
                end
            end
        end
    end
end)

-- FullBright
local function applyFullBright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime  = 14
        Lighting.FogEnd     = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient    = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime  = 14
        Lighting.GlobalShadows = true
        Lighting.Ambient    = Color3.fromRGB(127,127,127)
    end
end

-- Anti-AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if CFG.AntiAFKEnabled then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        print("[PrimejTsuHub] Anti-AFK сработал")
    end
end)

-- ═══════════════════════════════
--         ESP INIT
-- ═══════════════════════════════
for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end
Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    createESP(p)
end)
Players.PlayerRemoving:Connect(function(p)
    clearESP(p)
end)

-- ═══════════════════════════════
--     CHARACTER RESPAWN
-- ═══════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    -- Восстанавливаем активные фичи после смерти
    if CFG.SpeedEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = CFG.SpeedValue
    end
    if CFG.JumpEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.JumpPower = CFG.JumpPower
    end
    -- Переустанавливаем ESP
    for _, p in ipairs(Players:GetPlayers()) do
        createESP(p)
    end
end)

-- ═══════════════════════════════
--     GUI — PRIMEJTSUHUB
-- ═══════════════════════════════
-- Удаляем старый GUI если есть
if game.CoreGui:FindFirstChild("PrimejTsuHub") then
    game.CoreGui.PrimejTsuHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrimejTsuHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ── MAIN FRAME ──
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 360, 0, 520)
Main.Position = UDim2.new(0.5, -180, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(33, 48, 63)
mainStroke.Thickness = 1

-- ── HEADER ──
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = Color3.fromRGB(17, 24, 32)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
-- Скрыть нижние углы
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0.5, 0)
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = Color3.fromRGB(17, 24, 32)
headerFix.BorderSizePixel = 0
headerFix.Parent = Header

-- Логотип
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(0, 36, 0, 36)
LogoFrame.Position = UDim2.new(0, 10, 0.5, -18)
LogoFrame.BackgroundColor3 = Color3.fromRGB(0, 201, 167)
LogoFrame.BorderSizePixel = 0
LogoFrame.Parent = Header
Instance.new("UICorner", LogoFrame).CornerRadius = UDim.new(0, 8)

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(1, 0, 1, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "🌊"
LogoLabel.TextSize = 18
LogoLabel.Parent = LogoFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 160, 0, 20)
TitleLabel.Position = UDim2.new(0, 54, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PrimejTsuHub"
TitleLabel.TextColor3 = Color3.fromRGB(230, 237, 243)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 14)
SubLabel.Position = UDim2.new(0, 54, 0, 28)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Murder Mystery 2 • v3.0"
SubLabel.TextColor3 = Color3.fromRGB(100, 116, 128)
SubLabel.Font = Enum.Font.Code
SubLabel.TextSize = 11
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(224, 48, 48)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Минимизировать
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 42, 56)
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(100,116,128)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 360, 0, 52)
        MinBtn.Text = "□"
    else
        Main.Size = UDim2.new(0, 360, 0, 520)
        MinBtn.Text = "─"
    end
end)

-- ── TAB BAR ──
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 38)
TabBar.Position = UDim2.new(0, 0, 0, 52)
TabBar.BackgroundColor3 = Color3.fromRGB(17, 24, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TEAL = Color3.fromRGB(0, 201, 167)
local MUTED = Color3.fromRGB(100, 116, 128)
local TABS_DATA = {"MOVE","GOD","FARM","MISC","INFO"}
local tabButtons = {}
local currentTab = "MOVE"

-- ── CONTENT FRAME ──
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -92)
ContentFrame.Position = UDim2.new(0, 0, 0, 92)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = Main

-- Divider
local Div = Instance.new("Frame")
Div.Size = UDim2.new(1, 0, 0, 1)
Div.Position = UDim2.new(0, 0, 0, 90)
Div.BackgroundColor3 = Color3.fromRGB(33, 48, 63)
Div.BorderSizePixel = 0
Div.Parent = Main

-- Helper: Create Tab Panel
local panels = {}
local function newPanel(name)
    local f = Instance.new("ScrollingFrame")
    f.Name = name
    f.Size = UDim2.new(1, 0, 1, 0)
    f.Position = UDim2.new(0,0,0,0)
    f.BackgroundTransparency = 1
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = TEAL
    f.CanvasSize = UDim2.new(0,0,0,0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Visible = false
    f.Parent = ContentFrame

    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    panels[name] = f
    return f
end

-- Helper: Toggle карточка
local function newToggleCard(parent, icon, title, desc, onToggle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 74)
    card.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(33, 48, 63)
    stroke.Thickness = 1

    -- Icon box
    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.new(0, 40, 0, 40)
    iconBox.Position = UDim2.new(0, 10, 0.5, -20)
    iconBox.BackgroundColor3 = Color3.fromRGB(0,201,167,0.1)
    iconBox.BackgroundColor3 = Color3.fromRGB(15, 40, 40)
    iconBox.BorderSizePixel = 0
    iconBox.Parent = card
    Instance.new("UICorner", iconBox).CornerRadius = UDim.new(0, 8)
    local iconStroke = Instance.new("UIStroke", iconBox)
    iconStroke.Color = Color3.fromRGB(0,80,70)

    local iconLbl = Instance.new("TextLabel", iconBox)
    iconLbl.Size = UDim2.new(1,0,1,0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 20
    iconLbl.Font = Enum.Font.GothamBold

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -110, 0, 18)
    titleLbl.Position = UDim2.new(0, 58, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = TEAL
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    -- Desc
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -110, 0, 28)
    descLbl.Position = UDim2.new(0, 58, 0, 30)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = MUTED
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 11
    descLbl.TextWrapped = true
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    -- Status dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 58, 1, -16)
    dot.BackgroundColor3 = Color3.fromRGB(55,65,80)
    dot.BorderSizePixel = 0
    dot.Parent = card
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(0, 80, 0, 14)
    statusLbl.Position = UDim2.new(0, 69, 1, -18)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "INACTIVE"
    statusLbl.TextColor3 = MUTED
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextSize = 10
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent = card

    -- Toggle button
    local togBG = Instance.new("Frame")
    togBG.Size = UDim2.new(0, 44, 0, 24)
    togBG.Position = UDim2.new(1, -54, 0.5, -12)
    togBG.BackgroundColor3 = Color3.fromRGB(40,52,68)
    togBG.BorderSizePixel = 0
    togBG.Parent = card
    Instance.new("UICorner", togBG).CornerRadius = UDim.new(1, 0)

    local togCircle = Instance.new("Frame")
    togCircle.Size = UDim2.new(0, 18, 0, 18)
    togCircle.Position = UDim2.new(0, 3, 0.5, -9)
    togCircle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    togCircle.BorderSizePixel = 0
    togCircle.Parent = togBG
    Instance.new("UICorner", togCircle).CornerRadius = UDim.new(1,0)

    local enabled = false

    local togBtn = Instance.new("TextButton")
    togBtn.Size = UDim2.new(1,0,1,0)
    togBtn.BackgroundTransparency = 1
    togBtn.Text = ""
    togBtn.Parent = togBG

    togBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            -- Animate ON
            TweenService:Create(togBG, TweenInfo.new(0.2), {
                BackgroundColor3 = TEAL
            }):Play()
            TweenService:Create(togCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 23, 0.5, -9)
            }):Play()
            dot.BackgroundColor3 = TEAL
            statusLbl.Text = "ACTIVE"
            statusLbl.TextColor3 = TEAL
            stroke.Color = Color3.fromRGB(0, 100, 84)
        else
            TweenService:Create(togBG, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40,52,68)
            }):Play()
            TweenService:Create(togCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -9)
            }):Play()
            dot.BackgroundColor3 = Color3.fromRGB(55,65,80)
            statusLbl.Text = "INACTIVE"
            statusLbl.TextColor3 = MUTED
            stroke.Color = Color3.fromRGB(33, 48, 63)
        end
        onToggle(enabled)
    end)

    return card
end

-- Helper: Section title
local function newSection(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.Position = UDim2.new(0.5, -40, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = MUTED
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.LetterSpacing = 3

    local lineL = Instance.new("Frame", f)
    lineL.Size = UDim2.new(0.3, -50, 0, 1)
    lineL.Position = UDim2.new(0, 0, 0.5, 0)
    lineL.BackgroundColor3 = Color3.fromRGB(33,48,63)
    lineL.BorderSizePixel = 0

    local lineR = Instance.new("Frame", f)
    lineR.Size = UDim2.new(0.3, -50, 0, 1)
    lineR.Position = UDim2.new(0.7, 50, 0.5, 0)
    lineR.BackgroundColor3 = Color3.fromRGB(33,48,63)
    lineR.BorderSizePixel = 0
end

-- ════════════════════════════
--     BUILD PANELS
-- ════════════════════════════

-- ── MOVE ──
local movePanel = newPanel("MOVE")
newToggleCard(movePanel, "⚡", "SPEED HACK",
    "Увеличение скорости (плавно, без бана)",
    function(v)
        CFG.SpeedEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = 16 end
            end
        end
    end)

newToggleCard(movePanel, "🌀", "NOCLIP",
    "Проходить сквозь стены и объекты",
    function(v) CFG.NoclipEnabled = v end)

newToggleCard(movePanel, "📷", "FREE CAM",
    "Свободная камера. Выкл → Observer Mode",
    function(v)
        if v then FreeCam:Enable()
        else FreeCam:Disable() end
        CFG.FreeCamEnabled = v
    end)

newToggleCard(movePanel, "🏃", "BUNNY HOP",
    "Авто-прыжок при приземлении (быстрей)",
    function(v)
        CFG.JumpEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.JumpPower = 50 end
            end
        end
    end)

newToggleCard(movePanel, "🎯", "AUTO TELEPORT",
    "ТП к ближайшему игроку (E для активации)",
    function(v)
        if v and AC.canAct() then
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        AC.humanizeTP(hrp, tHRP.CFrame + Vector3.new(0,0,3))
                        break
                    end
                end
            end
        end
    end)

-- ── GOD ──
local godPanel = newPanel("GOD")
newToggleCard(godPanel, "🛡", "GOD MODE",
    "Бесконечное здоровье — нельзя умереть",
    function(v) CFG.GodEnabled = v end)

newToggleCard(godPanel, "👁", "ESP",
    "Видеть игроков сквозь стены с ролями",
    function(v)
        CFG.ESPEnabled = v
        for _, objects in pairs(ESPObjects) do
            if objects.billboard then
                objects.billboard.Enabled = v
            end
        end
    end)

newToggleCard(godPanel, "🎯", "AIMBOT",
    "Авто-прицеливание на ближайшего (ПКМ)",
    function(v) CFG.AimbotEnabled = v end)

newToggleCard(godPanel, "∞", "INF AMMO",
    "Бесконечные патроны для шерифа",
    function(v)
        CFG.InfAmmoEnabled = v
        if v then
            -- Патчим через LocalScript
            AC.safeCall(function()
                local gun = LocalPlayer.Character and
                            LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if gun then
                    local ammo = gun:FindFirstChild("Ammo")
                    if ammo then ammo.Value = 999 end
                end
            end)
        end
    end)

newToggleCard(godPanel, "💨", "ANTI KNOCK",
    "Предотвращает отбрасывание персонажа",
    function(v)
        if v then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                end
            end
        end
    end)

-- ── FARM ──
local farmPanel = newPanel("FARM")
newToggleCard(farmPanel, "💰", "COIN FARM",
    "Авто-сбор монет по всей карте",
    function(v) CFG.CoinFarmEnabled = v end)

newToggleCard(farmPanel, "🔪", "KNIFE AURA",
    "Авто-убийство как убийца (радиус 10)",
    function(v) CFG.KnifeAuraEnabled = v end)

newToggleCard(farmPanel, "💎", "ITEM COLLECT",
    "Авто-подбор всех предметов и дропов",
    function(v) CFG.AutoPickupEnabled = v end)

newToggleCard(farmPanel, "🎁", "AUTO REWARD",
    "Авто-сбор наград в конце раунда",
    function(v)
        if v then
            -- Ищем кнопки наград в GUI
            AC.safeCall(function()
                for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and
                       (gui.Text:find("Reward") or gui.Text:find("Claim")) then
                        gui.MouseButton1Click:Fire()
                    end
                end
            end)
        end
    end)

-- ── MISC ──
local miscPanel = newPanel("MISC")
newToggleCard(miscPanel, "☀", "FULLBRIGHT",
    "Максимальная яркость, нет теней",
    function(v)
        CFG.FullBrightEnabled = v
        applyFullBright(v)
    end)

newToggleCard(miscPanel, "🔒", "ANTI AFK",
    "Защита от кика за бездействие",
    function(v) CFG.AntiAFKEnabled = v end)

newToggleCard(miscPanel, "🌊", "ANTI TSUNAMI",
    "Авто-уклонение/прыжок от волны",
    function(v)
        if v then
            RunService.Heartbeat:Connect(function()
                if not v then return end
                AC.safeCall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                end)
            end)
        end
    end)

newToggleCard(miscPanel, "👻", "HIDE PLAYER",
    "Сделать персонажа невидимым для других",
    function(v)
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier = v and 1 or 0
            end
        end
    end)

newToggleCard(miscPanel, "📢", "CHAT BYPASS",
    "Отправка сообщений в чат без фильтра",
    function(v)
        CFG.ChatSpamEnabled = v
        if v then
            AC.safeCall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("DefaultChatSystemChatEvents")
                    :WaitForChild("SayMessageRequest")
                    :FireServer(CFG.ChatSpamMsg, "All")
            end)
        end
    end)

-- ── INFO ──
local infoPanel = newPanel("INFO")

-- Dev card
local devCard = Instance.new("Frame")
devCard.Size = UDim2.new(1, 0, 0, 100)
devCard.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
devCard.BorderSizePixel = 0
devCard.Parent = infoPanel
Instance.new("UICorner", devCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", devCard).Color = Color3.fromRGB(33,48,63)

local avatarFrame = Instance.new("Frame", devCard)
avatarFrame.Size = UDim2.new(0, 56, 0, 56)
avatarFrame.Position = UDim2.new(0.5, -28, 0, 12)
avatarFrame.BackgroundColor3 = TEAL
avatarFrame.BorderSizePixel = 0
Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 12)
local avLbl = Instance.new("TextLabel", avatarFrame)
avLbl.Size = UDim2.new(1,0,1,0)
avLbl.BackgroundTransparency = 1
avLbl.Text = "👑"
avLbl.TextSize = 28
avLbl.Font = Enum.Font.GothamBold

local devName = Instance.new("TextLabel", devCard)
devName.Size = UDim2.new(1, 0, 0, 18)
devName.Position = UDim2.new(0, 0, 0, 72)
devName.BackgroundTransparency = 1
devName.Text = "Primejtsu"
devName.TextColor3 = TEAL
devName.Font = Enum.Font.GothamBold
devName.TextSize = 15

local tgBtn = Instance.new("TextButton", devCard)
tgBtn.Size = UDim2.new(0, 160, 0, 26)
tgBtn.Position = UDim2.new(0.5, -80, 1, -38)
tgBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 160)
tgBtn.Text = "✈ @Primejtsu"
tgBtn.TextColor3 = Color3.fromRGB(255,255,255)
tgBtn.Font = Enum.Font.GothamBold
tgBtn.TextSize = 12
tgBtn.BorderSizePixel = 0
Instance.new("UICorner", tgBtn).CornerRadius = UDim.new(0, 6)

local function newInfoRow(parent, label, value, valColor)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", row).Color = Color3.fromRGB(33,48,63)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = MUTED
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.new(0.45, 0, 1, 0)
    val.Position = UDim2.new(0.55, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = valColor or TEAL
    val.Font = Enum.Font.Code
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right
end

newSection(infoPanel, "ИНФОРМАЦИЯ")
newInfoRow(infoPanel, "Хаб",          "PrimejTsuHub")
newInfoRow(infoPanel, "Игра",         "Murder Mystery 2")
newInfoRow(infoPanel, "Версия",       "v3.0")
newInfoRow(infoPanel, "Executor",     "Delta (Mobile)")
newInfoRow(infoPanel, "Разработчик",  "Primejtsu",    Color3.fromRGB(243,156,18))
newInfoRow(infoPanel, "Telegram",     "@Primejtsu",   Color3.fromRGB(41,182,246))
newInfoRow(infoPanel, "Фич всего",    "15")
newInfoRow(infoPanel, "Anti-Cheat",   "✓ ACTIVE",     Color3.fromRGB(0,201,167))

-- ═══════════════════════════════
--       BUILD TABS
-- ═══════════════════════════════
for _, name in ipairs(TABS_DATA) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = MUTED
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    tabButtons[name] = btn

    -- Bottom indicator
    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0.7, 0, 0, 2)
    ind.Position = UDim2.new(0.15, 0, 1, -2)
    ind.BackgroundColor3 = TEAL
    ind.BorderSizePixel = 0
    ind.Visible = false
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)
    btn:SetAttribute("Indicator", ind)

    btn.MouseButton1Click:Connect(function()
        -- Скрыть все
        for k, b in pairs(tabButtons) do
            b.TextColor3 = MUTED
            local i = b:GetAttribute("Indicator")
            if i then i.Visible = false end
            if panels[k] then panels[k].Visible = false end
        end
        -- Показать текущий
        btn.TextColor3 = TEAL
        ind.Visible = true
        if panels[name] then panels[name].Visible = true end
        currentTab = name
    end)
end

-- Активируем первый таб
tabButtons["MOVE"].TextColor3 = TEAL
local firstInd = tabButtons["MOVE"]:GetAttribute("Indicator")
if firstInd then firstInd.Visible = true end
panels["MOVE"].Visible = true

-- ═══════════════════════════════
print("[PrimejTsuHub v3.0] Загружен! | @Primejtsu")
print("[PrimejTsuHub] Anti-Cheat система активна")
print("[PrimejTsuHub] Перетащи GUI куда удобно!")
