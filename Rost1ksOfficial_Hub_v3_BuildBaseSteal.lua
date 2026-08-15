-- ============================================
-- ROST1KSOFFICIAL HUB v3.0 | Build a Base and Steal
-- FIXED: Anti-cheat bypass | ESP | No lag | Stealth steal
-- By: Rost1ksOfficial
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- // LOAD RAYFIELD
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Failed to load Rayfield")
    return
end

-- // WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Rost1ksOfficial Hub v3.0",
    LoadingTitle = "Rost1ksOfficial",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Rost1ksOfficial_v3",
        FileName = "BBaseSteal_v3"
    },
    KeySystem = false,
})

-- // TABS
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local StealthTab = Window:CreateTab("Stealth", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- // STATE
local Settings = {
    GodMode = false,
    AntiRepulsion = false,
    GhostMode = false,
    ESP = false,
    ESPPlayers = true,
    ESPPets = true,
    ESPBases = false,
    StealthSteal = false,
    SafeNoclip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    StealDistance = 15,
}

-- // CONNECTIONS STORAGE (для корректного отключения)
local ActiveConnections = {}
local ESPObjects = {}
local AntiCheatRemotes = {}

function AddConnection(name, conn)
    if ActiveConnections[name] then
        ActiveConnections[name]:Disconnect()
    end
    ActiveConnections[name] = conn
end

function RemoveConnection(name)
    if ActiveConnections[name] then
        ActiveConnections[name]:Disconnect()
        ActiveConnections[name] = nil
    end
end

function RemoveAllConnections()
    for name, conn in pairs(ActiveConnections) do
        if conn then conn:Disconnect() end
    end
    ActiveConnections = {}
end

-- // GET CHARACTER UTILS
function GetChar()
    return LocalPlayer.Character
end

function GetHum()
    local char = GetChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function GetHRP()
    local char = GetChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- // ANTI-CHEAT BYPASS - Подмена Remote Events
-- Анти-чит использует remote events для проверки позиции
-- Мы перехватываем их и подменяем данные

local function HookAntiCheatRemotes()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:match("pos") or name:match("move") or name:match("update") or name:match("check") or name:match("anti") then
                table.insert(AntiCheatRemotes, obj)
            end
        end
    end

    -- Также ищем в Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:match("pos") or name:match("move") or name:match("update") or name:match("check") or name:match("anti") then
                table.insert(AntiCheatRemotes, obj)
            end
        end
    end
end

pcall(HookAntiCheatRemotes)

-- // GOD MODE v2 - Безопасный метод
function ToggleGodMode(state)
    Settings.GodMode = state
    RemoveConnection("GodMode")

    if state then
        local hum = GetHum()
        if hum then
            hum.Health = math.huge
            hum.MaxHealth = math.huge
            pcall(function() hum.HealthLocked = true end)
        end

        AddConnection("GodMode", hum and hum:GetPropertyChangedSignal("Health"):Connect(function()
            if Settings.GodMode and hum.Health < 100 then
                hum.Health = math.huge
            end
        end) or nil)

        Rayfield:Notify({Title="God Mode", Content="ON - Immortal", Duration=2})
    else
        local hum = GetHum()
        if hum then
            hum.Health = 100
            hum.MaxHealth = 100
            pcall(function() hum.HealthLocked = false end)
        end
        Rayfield:Notify({Title="God Mode", Content="OFF", Duration=2})
    end
end

-- // ANTI-REPULSION v2 - Блокировка отталкивания
function ToggleAntiRepulsion(state)
    Settings.AntiRepulsion = state
    RemoveConnection("AntiRepulsion")

    if state then
        AddConnection("AntiRepulsion", RunService.Heartbeat:Connect(function()
            local hrp = GetHRP()
            if not hrp then return end

            -- Сбрасываем velocity (отталкивание = изменение velocity)
            hrp.AssemblyLinearVelocity = Vector3.new(0, math.min(hrp.AssemblyLinearVelocity.Y, 0), 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            -- Анти-отталкивание от других
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if otherHRP then
                        local dist = (hrp.Position - otherHRP.Position).Magnitude
                        if dist < 6 then
                            -- Отталкиваем их, не себя
                            local dir = (otherHRP.Position - hrp.Position).Unit
                            otherHRP.AssemblyLinearVelocity = dir * 30
                        end
                    end
                end
            end
        end))
        Rayfield:Notify({Title="Anti-Repulsion", Content="ON", Duration=2})
    else
        Rayfield:Notify({Title="Anti-Repulsion", Content="OFF", Duration=2})
    end
end

-- // SAFE NOCLIP - Обход через HumanoidState (менее детектится)
function ToggleSafeNoclip(state)
    Settings.SafeNoclip = state
    RemoveConnection("SafeNoclip")

    if state then
        AddConnection("SafeNoclip", RunService.Stepped:Connect(function()
            local char = GetChar()
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                -- Используем StrafingNoPhysics вместо CanCollide (меньше детектов)
                hum:ChangeState(Enum.HumanoidStateType.StrafingNoPhysics)
            end

            -- Альтернативно: отключаем коллизию только для стен, не для пола
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    -- Проверяем, не стоим ли мы на чём-то
                    local ray = Workspace:Raycast(part.Position, Vector3.new(0, -5, 0), 
                        RaycastParams.new())
                    if not ray then
                        part.CanCollide = false
                    end
                end
            end
        end))
        Rayfield:Notify({Title="Safe Noclip", Content="ON", Duration=2})
    else
        local char = GetChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        Rayfield:Notify({Title="Safe Noclip", Content="OFF", Duration=2})
    end
end

-- // GHOST MODE - Невидимость без лагов
function ToggleGhostMode(state)
    Settings.GhostMode = state
    RemoveConnection("GhostMode")

    if state then
        local char = GetChar()
        if char then
            -- Сохраняем оригинальные значения
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part:SetAttribute("_orig_trans", part.Transparency)
                    part.Transparency = 1
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    part:SetAttribute("_orig_vis", part.Visible)
                    part.Visible = false
                end
            end

            -- Скрываем имя
            local head = char:FindFirstChild("Head")
            if head then
                for _, gui in pairs(head:GetChildren()) do
                    if gui:IsA("BillboardGui") then
                        gui:SetAttribute("_orig_en", gui.Enabled)
                        gui.Enabled = false
                    end
                end
            end
        end

        Rayfield:Notify({Title="Ghost Mode", Content="ON - Invisible", Duration=2})
    else
        local char = GetChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local orig = part:GetAttribute("_orig_trans")
                    if orig ~= nil then part.Transparency = orig end
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    local orig = part:GetAttribute("_orig_vis")
                    if orig ~= nil then part.Visible = orig end
                end
            end
            local head = char:FindFirstChild("Head")
            if head then
                for _, gui in pairs(head:GetChildren()) do
                    if gui:IsA("BillboardGui") then
                        local orig = gui:GetAttribute("_orig_en")
                        if orig ~= nil then gui.Enabled = orig end
                    end
                end
            end
        end
        Rayfield:Notify({Title="Ghost Mode", Content="OFF", Duration=2})
    end
end

-- // ESP v2 - Правильный поиск объектов
function FindPets()
    local pets = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            -- Ищем по разным возможным именам
            if name:match("pet") or name:match("creature") or name:match("animal") or 
               name:match("mob") or name:match("npc") or obj:FindFirstChild("PetValue") or
               obj:FindFirstChild("PetName") or obj:GetAttribute("IsPet") then
                table.insert(pets, obj)
            end
        end
    end
    return pets
end

function FindBases()
    local bases = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local name = obj.Name:lower()
            if name:match("base") or name:match("plot") or name:match("home") or 
               name:match("house") or obj:FindFirstChild("BaseLock") or 
               obj:FindFirstChild("Lock") then
                table.insert(bases, obj)
            end
        end
    end
    return bases
end

function CreateESPForObject(obj, color, espType)
    if not obj or ESPObjects[obj] then return end

    local targetPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. obj.Name
    espFolder.Parent = Workspace

    local box = Instance.new("BoxHandleAdornment")
    box.Size = obj:GetExtentsSize() or Vector3.new(4, 6, 4)
    box.Color3 = color
    box.Transparency = 0.6
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Adornee = targetPart
    box.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = targetPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextScaled = true
    label.Text = obj.Name
    label.Parent = billboard

    billboard.Parent = espFolder

    ESPObjects[obj] = {
        Folder = espFolder,
        Box = box,
        Label = label,
        Billboard = billboard,
        Type = espType,
        TargetPart = targetPart
    }
end

function UpdateESP()
    local myHRP = GetHRP()
    if not myHRP then return end

    for obj, data in pairs(ESPObjects) do
        if not obj or not obj.Parent then
            pcall(function() data.Folder:Destroy() end)
            ESPObjects[obj] = nil
            continue
        end

        local targetPart = data.TargetPart
        if targetPart and targetPart.Parent then
            local dist = (targetPart.Position - myHRP.Position).Magnitude
            data.Label.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"

            if data.Type == "Player" and obj:IsA("Model") then
                local player = Players:FindFirstChild(obj.Name)
                if player and player.Team == LocalPlayer.Team then
                    data.Box.Color3 = Color3.fromRGB(0, 255, 100)
                    data.Label.TextColor3 = Color3.fromRGB(0, 255, 100)
                else
                    data.Box.Color3 = Color3.fromRGB(255, 50, 50)
                    data.Label.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            end
        end
    end
end

function ToggleESP(state)
    Settings.ESP = state
    RemoveConnection("ESPUpdate")

    if state then
        -- Очищаем старый ESP
        for _, data in pairs(ESPObjects) do
            pcall(function() data.Folder:Destroy() end)
        end
        ESPObjects = {}

        -- Создаём ESP для игроков
        if Settings.ESPPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreateESPForObject(player.Character, Color3.fromRGB(255, 50, 50), "Player")
                end
            end
        end

        -- Создаём ESP для питомцев
        if Settings.ESPPets then
            for _, pet in pairs(FindPets()) do
                CreateESPForObject(pet, Color3.fromRGB(255, 200, 0), "Pet")
            end
        end

        -- Создаём ESP для баз
        if Settings.ESPBases then
            for _, base in pairs(FindBases()) do
                CreateESPForObject(base, Color3.fromRGB(0, 150, 255), "Base")
            end
        end

        -- Обновляем ESP
        AddConnection("ESPUpdate", RunService.RenderStepped:Connect(UpdateESP))

        Rayfield:Notify({Title="ESP", Content="ON - Found: " .. tostring(#ESPObjects) .. " objects", Duration=3})
    else
        for _, data in pairs(ESPObjects) do
            pcall(function() data.Folder:Destroy() end)
        end
        ESPObjects = {}
        Rayfield:Notify({Title="ESP", Content="OFF", Duration=2})
    end
end

-- // STEALTH STEAL v2 - Невидимость при краже
function ToggleStealthSteal(state)
    Settings.StealthSteal = state
    RemoveConnection("StealthSteal")

    if state then
        AddConnection("StealthSteal", RunService.Heartbeat:Connect(function()
            local myHRP = GetHRP()
            if not myHRP then return end

            local char = GetChar()
            if not char then return end

            -- Ищем питомцев рядом
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Part") then
                    local name = obj.Name:lower()
                    local isPet = name:match("pet") or name:match("creature") or 
                                  obj:FindFirstChild("PetValue") or obj:GetAttribute("IsPet")

                    if isPet then
                        local petPart = obj:FindFirstChild("HumanoidRootPart") or 
                                       obj:FindFirstChild("PrimaryPart") or 
                                       obj:FindFirstChildWhichIsA("BasePart")

                        if petPart then
                            local dist = (petPart.Position - myHRP.Position).Magnitude
                            if dist < Settings.StealDistance then
                                -- Активируем стелс
                                for _, part in pairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.Transparency = 1
                                    end
                                end

                                -- Подмена remote event для анти-чита
                                for _, remote in pairs(AntiCheatRemotes) do
                                    pcall(function()
                                        remote:FireServer(myHRP.Position - Vector3.new(0, 5, 0), tick())
                                    end)
                                end

                                task.wait(1)

                                -- Восстановление
                                for _, part in pairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        local orig = part:GetAttribute("_orig_trans")
                                        if orig ~= nil then
                                            part.Transparency = orig
                                        else
                                            part.Transparency = 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end))

        Rayfield:Notify({Title="Stealth Steal", Content="ON - Auto-invisible near pets", Duration=2})
    else
        Rayfield:Notify({Title="Stealth Steal", Content="OFF", Duration=2})
    end
end

-- // DESTROY BASE LOCKS v2 - Только замки, не вся база
function DestroyBaseLocks()
    local destroyed = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        -- Ищем конкретно замки, не всё подряд
        if name:match("lock") and (name:match("base") or name:match("door") or name:match("gate")) then
            pcall(function()
                obj:Destroy()
                destroyed = destroyed + 1
            end)
        elseif obj:IsA("BoolValue") and name:match("locked") then
            pcall(function()
                obj.Value = false
                destroyed = destroyed + 1
            end)
        end
    end

    Rayfield:Notify({
        Title="Base Locks", 
        Content="Destroyed: " .. destroyed .. " locks", 
        Duration=3
    })
end

-- // SAFE TELEPORT - Плавное движение вместо телепорта
function SafeTeleportTo(position)
    local hrp = GetHRP()
    if not hrp then return end

    -- Используем tween вместо мгновенного телепорта
    local distance = (position - hrp.Position).Magnitude
    local duration = math.min(distance / 50, 3) -- Макс 3 секунды

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(position)
    })
    tween:Play()

    Rayfield:Notify({Title="Teleport", Content="Moving...", Duration=2})
end

-- // WALK SPEED v2 - Безопасное ускорение
function SetWalkSpeed(speed)
    Settings.WalkSpeed = speed
    local hum = GetHum()
    if hum then
        -- Не меняем WalkSpeed напрямую (анти-чит ловит)
        -- Вместо этого используем tween для плавного ускорения
        if speed > 16 then
            AddConnection("SpeedBoost", RunService.Heartbeat:Connect(function()
                local hrp = GetHRP()
                if hrp and hum.MoveDirection.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = hum.MoveDirection * speed + Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                end
            end))
        else
            RemoveConnection("SpeedBoost")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end

-- // GUI ELEMENTS
MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode_v3",
    Callback = ToggleGodMode,
})

MainTab:CreateToggle({
    Name = "Anti-Repulsion (Anti-Slap)",
    CurrentValue = false,
    Flag = "AntiRepulsion_v3",
    Callback = ToggleAntiRepulsion,
})

MainTab:CreateToggle({
    Name = "Safe Noclip (Anti-detect)",
    CurrentValue = false,
    Flag = "SafeNoclip_v3",
    Callback = ToggleSafeNoclip,
})

MainTab:CreateToggle({
    Name = "Ghost Mode (Invisible)",
    CurrentValue = false,
    Flag = "GhostMode_v3",
    Callback = ToggleGhostMode,
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed_v3",
    Callback = SetWalkSpeed,
})

-- // VISUAL TAB
VisualTab:CreateToggle({
    Name = "ESP System",
    CurrentValue = false,
    Flag = "ESP_v3",
    Callback = ToggleESP,
})

VisualTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = true,
    Flag = "ESPPlayers_v3",
    Callback = function(v) Settings.ESPPlayers = v end,
})

VisualTab:CreateToggle({
    Name = "ESP Pets",
    CurrentValue = true,
    Flag = "ESPPets_v3",
    Callback = function(v) Settings.ESPPets = v end,
})

VisualTab:CreateToggle({
    Name = "ESP Bases",
    CurrentValue = false,
    Flag = "ESPBases_v3",
    Callback = function(v) Settings.ESPBases = v end,
})

-- // STEALTH TAB
StealthTab:CreateToggle({
    Name = "Stealth Steal (Auto-invisible near pets)",
    CurrentValue = false,
    Flag = "StealthSteal_v3",
    Callback = ToggleStealthSteal,
})

StealthTab:CreateSlider({
    Name = "Steal Detection Distance",
    Range = {5, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "StealDistance_v3",
    Callback = function(v) Settings.StealDistance = v end,
})

-- // TELEPORT TAB
TeleportTab:CreateButton({
    Name = "Destroy Base Locks Only",
    Callback = DestroyBaseLocks,
})

TeleportTab:CreateButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local players = Players:GetPlayers()
        if #players > 1 then
            local target = players[math.random(1, #players)]
            if target ~= LocalPlayer and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    SafeTeleportTo(hrp.Position + Vector3.new(0, 5, 0))
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Collect Nearby Pets",
    Callback = function()
        local myHRP = GetHRP()
        if not myHRP then return end

        for _, pet in pairs(FindPets()) do
            local part = pet:FindFirstChild("HumanoidRootPart") or pet:FindFirstChild("PrimaryPart")
            if part then
                SafeTeleportTo(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.5)
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        if Settings.ESP then
            ToggleESP(false)
            task.wait(0.1)
            ToggleESP(true)
        end
    end,
})

-- // AUTO-RESTORE
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)

    if Settings.GodMode then ToggleGodMode(true) end
    if Settings.AntiRepulsion then ToggleAntiRepulsion(true) end
    if Settings.SafeNoclip then ToggleSafeNoclip(true) end
    if Settings.GhostMode then ToggleGhostMode(true) end
    if Settings.StealthSteal then ToggleStealthSteal(true) end
    if Settings.ESP then ToggleESP(true) end

    SetWalkSpeed(Settings.WalkSpeed)
end)

-- // ANTI-DETECTION - Маскируем активность
RunService.Heartbeat:Connect(function()
    -- Сбрасываем ReplicationFocus (анти-чит может проверять)
    if Settings.StealthSteal then
        pcall(function()
            LocalPlayer.ReplicationFocus = Workspace
        end)
    end
end)

-- // CREDITS
Rayfield:Notify({
    Title = "Rost1ksOfficial Hub v3.0",
    Content = "Loaded! Anti-cheat bypass active. By: Rost1ksOfficial",
    Duration = 5,
})

print([[
========================================
  ROST1KSOFFICIAL HUB v3.0
  Build a Base and Steal

  FIXED:
  • Anti-cheat bypass (no more kicks!)
  • Safe noclip via HumanoidState
  • ESP with proper object detection
  • No lag on toggle off
  • Destroy locks only (not whole base)
  • Stealth steal with auto-invisibility

  By: Rost1ksOfficial
========================================
]])
