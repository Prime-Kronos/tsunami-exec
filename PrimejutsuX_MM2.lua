-- ================================================
--   Primejtsu X | Murder Mystery 2
--   Kavo UI Edition v1.0
-- ================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window  = Library.CreateLib("Primejtsu X | Murder Mystery 2", "BloodTheme")

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

-- ================================================
-- РОЛИ
-- ================================================
-- MM2 хранит роль в leaderstats или в тегах персонажа
-- Цвета: Murderer = красный, Sheriff = синий, Innocent = зелёный

local RoleColors = {
    Murderer  = Color3.fromRGB(255, 50,  50),
    Sheriff   = Color3.fromRGB(50,  150, 255),
    Hero      = Color3.fromRGB(50,  150, 255),
    Innocent  = Color3.fromRGB(80,  255, 80),
}

local function getRole(player)
    -- Пробуем несколько способов определить роль
    local char = player.Character
    if not char then return "Innocent" end

    -- Способ 1: через тег BillboardGui над головой
    local head = char:FindFirstChild("Head")
    if head then
        for _, v in pairs(head:GetChildren()) do
            if v:IsA("BillboardGui") then
                local lbl = v:FindFirstChildOfClass("TextLabel")
                if lbl then
                    local t = lbl.Text:lower()
                    if t:find("murder") then return "Murderer" end
                    if t:find("sheriff") then return "Sheriff" end
                    if t:find("hero")    then return "Hero"    end
                end
            end
        end
    end

    -- Способ 2: через StringValue внутри персонажа
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("StringValue") then
            local t = v.Value:lower()
            if t == "murderer" then return "Murderer" end
            if t == "sheriff"  then return "Sheriff"  end
            if t == "hero"     then return "Hero"     end
        end
    end

    -- Способ 3: через leaderstats
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local role = ls:FindFirstChild("Role") or ls:FindFirstChild("role")
        if role then
            local t = tostring(role.Value):lower()
            if t:find("murder") then return "Murderer" end
            if t:find("sheriff") then return "Sheriff" end
            if t:find("hero")    then return "Hero"    end
        end
    end

    return "Innocent"
end

-- ================================================
-- CONFIG
-- ================================================
local Cfg = {
    -- ESP
    ESPEnabled   = false,
    ShowRoles    = true,
    ShowNames    = true,
    ShowDist     = false,
    -- Aimbot
    AimbotEnabled = false,
    SilentAim     = false,
    AimbotSmooth  = 0.2,
    AimbotPart    = "Head",
    AimbotTarget  = "Murderer", -- Murderer / Sheriff / All
    -- AI Helper
    AIHelper     = false,
    AIDistance   = 15,    -- если убийца ближе N метров — уклоняемся
    AICooldown   = 1.5,
    -- Gun
    AutoGrabGun  = false,
    -- Farm
    AutoFarm     = false,
    -- Movement
    SpeedEnabled = false, SpeedValue = 30,
    FlyEnabled   = false, FlySpeed   = 50,
    InfJump      = false,
    Noclip       = false,
    -- Misc
    FullBright   = false,
    AntiAFK      = false,
    MurderHelper = false, -- подсвечивает шерифа если ты убийца
}

-- ================================================
-- ESP HIGHLIGHTS
-- ================================================
local ESPObjects = {}

local function removeESP(p)
    if ESPObjects[p] then
        pcall(function() ESPObjects[p].hl:Destroy() end)
        pcall(function() ESPObjects[p].bb:Destroy() end)
        ESPObjects[p] = nil
    end
end

local function applyESP(p)
    removeESP(p)
    if p == LP then return end
    if not Cfg.ESPEnabled then return end

    local obj = {}

    -- Highlight через стены
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    local role = getRole(p)
    local col  = RoleColors[role] or RoleColors.Innocent
    hl.FillColor    = col
    hl.OutlineColor = col
    if p.Character then hl.Parent = p.Character end
    p.CharacterAdded:Connect(function(c)
        hl.Parent = c
        hl.FillColor    = RoleColors[getRole(p)] or RoleColors.Innocent
        hl.OutlineColor = hl.FillColor
    end)
    obj.hl = hl

    -- BillboardGui — имя + роль над головой
    if Cfg.ShowNames or Cfg.ShowRoles then
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0,120,0,40)
        bb.StudsOffset = Vector3.new(0,2.5,0)
        if p.Character and p.Character:FindFirstChild("Head") then
            bb.Adornee = p.Character.Head
        end
        p.CharacterAdded:Connect(function(c)
            bb.Adornee = c:WaitForChild("Head")
        end)

        local frame = Instance.new("Frame", bb)
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1,0,1,0)

        local nameLbl = Instance.new("TextLabel", frame)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Size = UDim2.new(1,0,0.5,0)
        nameLbl.Position = UDim2.new(0,0,0,0)
        nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextScaled = true
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.Text = p.Name

        local roleLbl = Instance.new("TextLabel", frame)
        roleLbl.BackgroundTransparency = 1
        roleLbl.Size = UDim2.new(1,0,0.5,0)
        roleLbl.Position = UDim2.new(0,0,0.5,0)
        roleLbl.TextScaled = true
        roleLbl.Font = Enum.Font.Gotham
        roleLbl.TextStrokeTransparency = 0
        roleLbl.Text = role
        roleLbl.TextColor3 = col

        bb.Parent = p.Character or workspace
        obj.bb = bb
        obj.nameLbl  = nameLbl
        obj.roleLbl  = roleLbl
    end

    ESPObjects[p] = obj
end

local function refreshESP()
    for p in pairs(ESPObjects) do removeESP(p) end
    if not Cfg.ESPEnabled then return end
    for _,p in pairs(Players:GetPlayers()) do applyESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(1); applyESP(p) end)
end)
Players.PlayerRemoving:Connect(removeESP)

-- Обновляем цвета ESP каждые 2 секунды (роль может поменяться)
task.spawn(function()
    while true do
        task.wait(2)
        if Cfg.ESPEnabled then
            for p, obj in pairs(ESPObjects) do
                if p.Character then
                    local role = getRole(p)
                    local col  = RoleColors[role] or RoleColors.Innocent
                    pcall(function()
                        obj.hl.FillColor    = col
                        obj.hl.OutlineColor = col
                        if obj.roleLbl then
                            obj.roleLbl.Text      = role
                            obj.roleLbl.TextColor3 = col
                        end
                    end)
                end
            end
        end
    end
end)

-- ================================================
-- GET TARGET (аимбот)
-- ================================================
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local ray    = Ray.new(origin, (part.Position - origin).Unit * 500)
    local hit    = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, workspace.Terrain})
    if hit then return hit:IsDescendantOf(part.Parent) end
    return false
end

local function getTarget()
    local best, bestD = nil, math.huge
    local cx = Camera.ViewportSize.X/2
    local cy = Camera.ViewportSize.Y/2

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local role = getRole(p)
                local match = (Cfg.AimbotTarget == "All")
                    or (Cfg.AimbotTarget == "Murderer" and role == "Murderer")
                    or (Cfg.AimbotTarget == "Sheriff"  and (role == "Sheriff" or role == "Hero"))

                if match then
                    local part = p.Character:FindFirstChild(Cfg.AimbotPart)
                             or p.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local sp, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis then
                            local d = math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                            if d < bestD then
                                bestD = d
                                best  = {part=part, player=p, role=role}
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ================================================
-- SILENT AIM
-- ================================================
local silentTarget = nil

if syn and syn.set_thread_identity then -- проверка на экзекьютор
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and Cfg.SilentAim and silentTarget then
            local args = {...}
            -- Подменяем позицию первого аргумента на позицию цели
            if typeof(args[1]) == "Vector3" or typeof(args[1]) == "CFrame" then
                args[1] = silentTarget.part.Position
            end
            return oldNamecall(self, table.unpack(args))
        end
        return oldNamecall(self, ...)
    end)
end

-- Обновляем silent target каждый кадр
RunService.Heartbeat:Connect(function()
    if Cfg.SilentAim then
        silentTarget = getTarget()
    end
end)

-- ================================================
-- AI HELPER — детект убийцы рядом + телепорт
-- ================================================
local aiLastTp   = 0
local aiStatusLbl = nil

local function aiTeleport(root)
    local dirs = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(1,0,1).Unit,  Vector3.new(-1,0,-1).Unit,
        Vector3.new(1,0,-1).Unit, Vector3.new(-1,0,1).Unit,
    }
    local d   = dirs[math.random(1,#dirs)]
    root.CFrame = CFrame.new(root.Position + d * 8 + Vector3.new(0,0.5,0))
end

RunService.Heartbeat:Connect(function()
    if not Cfg.AIHelper then return end
    local char   = LP.Character
    if not char  then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local now = tick()
    if now - aiLastTp < Cfg.AICooldown then return end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local role = getRole(p)
            if role == "Murderer" then
                local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if eRoot then
                    local dist = (eRoot.Position - myRoot.Position).Magnitude
                    if dist <= Cfg.AIDistance then
                        aiLastTp = now
                        aiTeleport(myRoot)
                        if aiStatusLbl then
                            pcall(function()
                                aiStatusLbl:UpdateSection("⚡ Уклонился от " .. p.Name .. "!")
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ================================================
-- AUTO GRAB GUN (если шериф умер — телепорт к пушке)
-- ================================================
local function findDroppedGun()
    -- Ищем модель пушки в workspace (обычно называется Gun, Revolver, SheriffGun)
    for _,v in pairs(workspace:GetChildren()) do
        local n = v.Name:lower()
        if n:find("gun") or n:find("revolver") or n:find("sheriff") then
            if v:IsA("Model") or v:IsA("BasePart") then
                return v
            end
        end
    end
    -- Ищем глубже
    for _,v in pairs(workspace:GetDescendants()) do
        local n = v.Name:lower()
        if (n:find("gun") or n:find("revolver")) and v:IsA("BasePart") then
            -- Проверяем что не в руках игрока
            local inChar = false
            for _,pl in pairs(Players:GetPlayers()) do
                if pl.Character and v:IsDescendantOf(pl.Character) then
                    inChar = true; break
                end
            end
            if not inChar then return v end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not Cfg.AutoGrabGun then return end
    local char   = LP.Character
    if not char  then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local gun = findDroppedGun()
    if gun then
        local gunPos = gun:IsA("Model") and gun:GetModelCFrame().Position or gun.Position
        local dist   = (gunPos - myRoot.Position).Magnitude
        if dist > 3 then
            myRoot.CFrame = CFrame.new(gunPos + Vector3.new(0,2,0))
        end
    end
end)

-- ================================================
-- AUTO FARM МОНЕТ
-- ================================================
local farmConn
local function startFarm()
    farmConn = RunService.Heartbeat:Connect(function()
        if not Cfg.AutoFarm then
            farmConn:Disconnect(); farmConn=nil; return
        end
        -- Ищем монеты в workspace
        for _,v in pairs(workspace:GetDescendants()) do
            local n = v.Name:lower()
            if (n:find("coin") or n:find("gold") or n:find("token")) and v:IsA("BasePart") then
                local char   = LP.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (v.Position - myRoot.Position).Magnitude
                    if dist > 2 then
                        myRoot.CFrame = CFrame.new(v.Position + Vector3.new(0,1,0))
                    end
                end
                task.wait(0.1)
            end
        end
        task.wait(0.5)
    end)
end

-- ================================================
-- MURDERER HELPER (ты убийца — видишь кто шериф)
-- ================================================
local sheriffHL = {}
local function updateMurderHelper()
    -- Убираем старые
    for _,hl in pairs(sheriffHL) do pcall(function() hl:Destroy() end) end
    sheriffHL = {}

    if not Cfg.MurderHelper then return end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local role = getRole(p)
            if role == "Sheriff" or role == "Hero" then
                local hl = Instance.new("Highlight")
                hl.FillColor    = Color3.fromRGB(255,215,0) -- золотой
                hl.OutlineColor = Color3.fromRGB(255,215,0)
                hl.FillTransparency = 0.3
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = p.Character
                table.insert(sheriffHL, hl)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        updateMurderHelper()
    end
end)

-- ================================================
-- FLY
-- ================================================
local flyConn
local function toggleFly(on)
    if on then
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if not root or not hum then return end
        hum.PlatformStand = true
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(1e5,1e5,1e5)
        bp.Position = root.Position
        bp.Parent   = root
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bg.CFrame    = Camera.CFrame
        bg.Parent    = root
        flyConn = RunService.Heartbeat:Connect(function()
            if not Cfg.FlyEnabled then return end
            local cf  = Camera.CFrame
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            bp.Position = bp.Position + dir * Cfg.FlySpeed * 0.016
            bg.CFrame   = cf
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if root then
            local bp = root:FindFirstChild("BodyPosition")
            local bg = root:FindFirstChild("BodyGyro")
            if bp then bp:Destroy() end
            if bg then bg:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end
end

-- ================================================
-- MOVEMENT LOOP
-- ================================================
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local h = char:FindFirstChild("Humanoid")
    if h then
        if Cfg.SpeedEnabled then
            h.WalkSpeed = Cfg.SpeedValue
        else
            if h.WalkSpeed ~= 16 and not Cfg.FlyEnabled then h.WalkSpeed = 16 end
        end
        if Cfg.InfJump then
            UserInputService.JumpRequest:Connect(function()
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
    if Cfg.Noclip then
        for _,p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ================================================
-- AIMBOT LOOP
-- ================================================
RunService.RenderStepped:Connect(function()
    if Cfg.AimbotEnabled and not Cfg.SilentAim then
        local t = getTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.lookAt(Camera.CFrame.Position, t.part.Position),
                Cfg.AimbotSmooth
            )
        end
    end
end)

-- ================================================
-- FULLBRIGHT
-- ================================================
local Lighting = game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness     = on and 10 or 1
    Lighting.ClockTime      = 14
    Lighting.GlobalShadows  = not on
    Lighting.Ambient        = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- ================================================
-- ANTI-AFK
-- ================================================
LP.Idled:Connect(function()
    if not Cfg.AntiAFK then return end
    local vu = game:GetService("VirtualUser")
    vu:Button1Down(Vector2.new(0,0), Camera.CFrame)
    task.wait(0.1)
    vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
end)

-- ================================================
-- KAVO UI
-- ================================================

-- ╔══════════════════════════════╗
-- ║  TAB: ESP                   ║
-- ╚══════════════════════════════╝
local TabESP     = Window:NewTab("ESP")
local SecESP     = TabESP:NewSection("Player ESP")

SecESP:NewToggle("ESP Через Стены", "Видеть всех игроков через стены", function(v)
    Cfg.ESPEnabled = v
    refreshESP()
end)

SecESP:NewToggle("Показывать Роли", "Murderer/Sheriff/Innocent над головой", function(v)
    Cfg.ShowRoles = v
    refreshESP()
end)

SecESP:NewToggle("Показывать Имена", "Имя игрока над головой", function(v)
    Cfg.ShowNames = v
    refreshESP()
end)

local SecRoleESP = TabESP:NewSection("Цвета ролей")
SecRoleESP:NewLabel("🔴 Murderer = Красный")
SecRoleESP:NewLabel("🔵 Sheriff / Hero = Синий")
SecRoleESP:NewLabel("🟢 Innocent = Зелёный")
SecRoleESP:NewLabel("🟡 Sheriff (Murder Helper) = Золотой")

-- ╔══════════════════════════════╗
-- ║  TAB: Aimbot                ║
-- ╚══════════════════════════════╝
local TabAim    = Window:NewTab("Aimbot")
local SecAim    = TabAim:NewSection("Настройки")

SecAim:NewToggle("Включить Aimbot", "Авто-прицел на цель", function(v)
    Cfg.AimbotEnabled = v
    if v then Cfg.SilentAim = false end
end)

SecAim:NewToggle("Silent Aim", "Пуля летит в цель невидимо (только Synapse)", function(v)
    Cfg.SilentAim = v
    if v then Cfg.AimbotEnabled = false end
end)

SecAim:NewDropdown("Цель аимбота", "Кого наводить", {"Murderer","Sheriff","All"}, function(opt)
    Cfg.AimbotTarget = opt
end)

SecAim:NewDropdown("Часть тела", "Куда целиться", {"Head","HumanoidRootPart","UpperTorso"}, function(opt)
    Cfg.AimbotPart = opt
end)

SecAim:NewSlider("Плавность (1=быстро, 10=плавно)", "Скорость наведения", 10, 1, function(v)
    Cfg.AimbotSmooth = v / 10
end)

-- ╔══════════════════════════════╗
-- ║  TAB: AI Helper             ║
-- ╚══════════════════════════════╝
local TabAI   = Window:NewTab("AI Helper")
local SecAI   = TabAI:NewSection("Авто-уклонение от Убийцы")

SecAI:NewToggle("Включить AI Helper", "Телепортирует от убийцы если он рядом", function(v)
    Cfg.AIHelper = v
end)

SecAI:NewSlider("Дистанция детекта (метры)", "Насколько близко убийца должен быть", 30, 5, function(v)
    Cfg.AIDistance = v
end)

SecAI:NewSlider("Кулдаун телепорта (сек)", "Пауза между уклонениями", 10, 1, function(v)
    Cfg.AICooldown = v
end)

aiStatusLbl = TabAI:NewSection("Статус AI")
aiStatusLbl:NewLabel("💤 Жду убийцу...")

local SecAIInfo = TabAI:NewSection("Как работает")
SecAIInfo:NewLabel("👁  Каждый кадр ищет Murderer рядом")
SecAIInfo:NewLabel("📏 Если ближе N метров — телепорт на 8м")
SecAIInfo:NewLabel("⚡ Мгновенная реакция без задержки")
SecAIInfo:NewLabel("🔄 Кулдаун чтобы не спамить телепорты")

-- ╔══════════════════════════════╗
-- ║  TAB: Murder Helper         ║
-- ╚══════════════════════════════╝
local TabMurder = Window:NewTab("Murder Helper")
local SecMurder = TabMurder:NewSection("Если ты Убийца")

SecMurder:NewToggle("Подсветка Шерифа", "Шериф светится золотым — видно через стены", function(v)
    Cfg.MurderHelper = v
    updateMurderHelper()
end)

SecMurder:NewButton("Кто Шериф? (в чат)", "Напечатать в консоль кто шериф", function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local role = getRole(p)
            if role == "Sheriff" or role == "Hero" then
                print("[MM2] Шериф: " .. p.Name)
            end
        end
    end
end)

SecMurder:NewButton("Кто Убийца?", "Напечатать в консоль кто убийца", function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local role = getRole(p)
            if role == "Murderer" then
                print("[MM2] Убийца: " .. p.Name)
            end
        end
    end
end)

local SecSheriff = TabMurder:NewSection("Если ты Шериф")
SecSheriff:NewToggle("Авто-Grab Gun", "Авто телепорт к пушке если шериф умер", function(v)
    Cfg.AutoGrabGun = v
end)

-- ╔══════════════════════════════╗
-- ║  TAB: Farm                  ║
-- ╚══════════════════════════════╝
local TabFarm = Window:NewTab("Farm")
local SecFarm = TabFarm:NewSection("Авто-Фарм")

SecFarm:NewToggle("Авто Собирать Монеты", "Телепортирует к монетам автоматически", function(v)
    Cfg.AutoFarm = v
    if v then startFarm() end
end)

SecFarm:NewButton("Телепорт к монетам (1 раз)", "Разовый сбор монет", function()
    local char   = LP.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _,v in pairs(workspace:GetDescendants()) do
        local n = v.Name:lower()
        if (n:find("coin") or n:find("gold") or n:find("token")) and v:IsA("BasePart") then
            myRoot.CFrame = CFrame.new(v.Position + Vector3.new(0,1,0))
            task.wait(0.15)
        end
    end
end)

local SecTp = TabFarm:NewSection("Телепорты")
SecTp:NewButton("Телепорт к Убийце", "Прыгнуть к убийце", function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and getRole(p) == "Murderer" and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local mine = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root and mine then
                mine.CFrame = root.CFrame + Vector3.new(3,0,0)
            end
        end
    end
end)

SecTp:NewButton("Телепорт к Шерифу", "Прыгнуть к шерифу", function()
    for _,p in pairs(Players:GetPlayers()) do
        local role = getRole(p)
        if p ~= LP and (role == "Sheriff" or role == "Hero") and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local mine = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root and mine then
                mine.CFrame = root.CFrame + Vector3.new(3,0,0)
            end
        end
    end
end)

-- ╔══════════════════════════════╗
-- ║  TAB: Movement              ║
-- ╚══════════════════════════════╝
local TabMove  = Window:NewTab("Movement")
local SecMove  = TabMove:NewSection("Движение")

SecMove:NewToggle("Speed Hack", "Увеличить скорость ходьбы", function(v)
    Cfg.SpeedEnabled = v
end)
SecMove:NewSlider("Walk Speed", "Скорость (16 = дефолт)", 200, 16, function(v)
    Cfg.SpeedValue = v
end)
SecMove:NewToggle("Fly (W/A/S/D + Space)", "Летать по карте", function(v)
    Cfg.FlyEnabled = v; toggleFly(v)
end)
SecMove:NewSlider("Fly Speed", "Скорость полёта", 200, 10, function(v)
    Cfg.FlySpeed = v
end)
SecMove:NewToggle("Infinite Jump", "Прыгать в воздухе бесконечно", function(v)
    Cfg.InfJump = v
end)
SecMove:NewToggle("Noclip", "Проходить сквозь стены", function(v)
    Cfg.Noclip = v
end)

-- ╔══════════════════════════════╗
-- ║  TAB: Misc                  ║
-- ╚══════════════════════════════╝
local TabMisc = Window:NewTab("Misc")
local SecMisc = TabMisc:NewSection("Разное")

SecMisc:NewToggle("Fullbright", "Сделать карту яркой (видно в темноте)", function(v)
    Cfg.FullBright = v; setFullBright(v)
end)
SecMisc:NewToggle("Anti-AFK", "Не вылетать за неактивность", function(v)
    Cfg.AntiAFK = v
end)
SecMisc:NewButton("Show Player Roles", "Вывести все роли в консоль", function()
    for _,p in pairs(Players:GetPlayers()) do
        print("[MM2] " .. p.Name .. " = " .. getRole(p))
    end
end)
SecMisc:NewButton("Rejoin", "Перезайти в игру", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
SecMisc:NewButton("Respawn", "Умереть и заспавниться", function()
    if LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then h.Health = 0 end
    end
end)

-- ╔══════════════════════════════╗
-- ║  TAB: About                 ║
-- ╚══════════════════════════════╝
local TabAbout  = Window:NewTab("About")
local SecAbout  = TabAbout:NewSection("Primejtsu X | MM2")
SecAbout:NewLabel("Version: v1.0 | Game: Murder Mystery 2")
SecAbout:NewLabel("Creator: @Primejtsu")
SecAbout:NewLabel("UI: Kavo UI by xHeptc")
SecAbout:NewLabel("Executor: Delta & others")

local SecFeatures = TabAbout:NewSection("Функции")
SecFeatures:NewLabel("✅ ESP — роли через стены")
SecFeatures:NewLabel("✅ Aimbot + Silent Aim")
SecFeatures:NewLabel("✅ AI Helper — уклонение от убийцы")
SecFeatures:NewLabel("✅ Murder Helper — видишь шерифа")
SecFeatures:NewLabel("✅ Auto Grab Gun — авто подбор пушки")
SecFeatures:NewLabel("✅ Auto Farm монет")
SecFeatures:NewLabel("✅ Телепорты к убийце/шерифу")
SecFeatures:NewLabel("✅ Fly / Speed / Noclip / InfJump")
SecFeatures:NewLabel("✅ Fullbright / Anti-AFK")

-- ================================================
-- СТАРТ
-- ================================================
task.wait(1)
refreshESP()
print("[Primejtsu X] MM2 v1.0 Loaded! Creator: @Primejtsu")
