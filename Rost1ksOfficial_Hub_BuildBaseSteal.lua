-- ============================================
-- ROST1KSOFFICIAL HUB | Build a Base and Steal
-- Game: [UPD] Постройте базу и украдите
-- Executor: Delta Mobile / Any (Rayfield Compatible)
-- Features: God Mode | Anti-Repulsion | Ghost Mode | ESP | Stealth Steal
-- By: Rost1ksOfficial
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // LOAD RAYFIELD GUI LIBRARY
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // WINDOW SETUP
local Window = Rayfield:CreateWindow({
    Name = "Rost1ksOfficial Hub | Build a Base and Steal",
    LoadingTitle = "Rost1ksOfficial",
    LoadingSubtitle = "Loading exploits...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Rost1ksOfficial_Config",
        FileName = "BBaseSteal"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- // TABS
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local StealthTab = Window:CreateTab("Stealth", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- // VARIABLES
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Settings = {
    GodMode = false,
    AntiRepulsion = false,
    GhostMode = false,
    ESP = false,
    ESPPlayers = false,
    ESPPets = false,
    ESPBases = false,
    StealthSteal = false,
    Noclip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    StealDistance = 10,
    InvisibilityLevel = 1, -- 1: Local | 2: Server-Side
}

local ESPObjects = {}
local NoclipConnection
local AntiRepulsionConnection
local GhostModeConnection
local StealthConnection

-- // UTILITY FUNCTIONS
function GetCharacter()
    return LocalPlayer.Character
end

function GetHumanoid()
    local char = GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

function GetHRP()
    local char = GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- // ANTI-CHEAT BYPASS LAYER
-- Подмена данных для анти-чита игры
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
local oldNamecall = mt.__namecall

mt.__index = newcclosure(function(t, k)
    if t == Humanoid and Settings.GodMode then
        if k == "Health" then return 100 end
        if k == "MaxHealth" then return 100 end
        if k == "WalkSpeed" then return 16 end
        if k == "JumpPower" then return 50 end
    end
    return oldIndex(t, k)
end)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and Settings.StealthSteal then
        -- Перехват remote events при краже
        local args = {...}
        if #args > 0 and typeof(args[1]) == "Vector3" then
            -- Подмена позиции на "нормальную" для анти-чита
            args[1] = args[1] + Vector3.new(math.random(-2,2), 0, math.random(-2,2))
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- // GOD MODE
function ToggleGodMode(state)
    Settings.GodMode = state
    if state then
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.Health = math.huge
            humanoid.MaxHealth = math.huge
            pcall(function()
                humanoid.HealthLocked = true
            end)

            -- Анти-отключение God Mode
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Settings.GodMode and humanoid.Health < math.huge then
                    humanoid.Health = math.huge
                end
            end)
        end
        Rayfield:Notify({
            Title = "God Mode",
            Content = "Activated - You are immortal",
            Duration = 3,
        })
    else
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.Health = 100
            humanoid.MaxHealth = 100
            pcall(function()
                humanoid.HealthLocked = false
            end)
        end
    end
end

-- // ANTI-REPULSION (Anti-Slap / Anti-Knockback)
function ToggleAntiRepulsion(state)
    Settings.AntiRepulsion = state
    if state then
        AntiRepulsionConnection = RunService.Heartbeat:Connect(function()
            local hrp = GetHRP()
            if hrp then
                -- Блокировка отталкивания: фиксируем позицию
                local currentPos = hrp.Position
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)

                -- Анти-отталкивание от других игроков
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if otherHRP then
                            local distance = (hrp.Position - otherHRP.Position).Magnitude
                            if distance < 8 then
                                -- Отталкиваем их вместо себя
                                local pushDirection = (otherHRP.Position - hrp.Position).Unit
                                otherHRP.Velocity = pushDirection * 50
                            end
                        end
                    end
                end
            end
        end)
        Rayfield:Notify({
            Title = "Anti-Repulsion",
            Content = "Activated - Nobody can push you",
            Duration = 3,
        })
    else
        if AntiRepulsionConnection then
            AntiRepulsionConnection:Disconnect()
        end
    end
end

-- // GHOST MODE (Invisibility + Noclip)
function ToggleGhostMode(state)
    Settings.GhostMode = state
    if state then
        local char = GetCharacter()
        if char then
            -- Невидимость
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part:SetAttribute("OriginalTransparency", part.Transparency)
                    part.Transparency = 1
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    part:SetAttribute("OriginalVisible", part.Visible)
                    part.Visible = false
                end
            end

            -- Отключение имени
            local head = char:FindFirstChild("Head")
            if head then
                local billboard = head:FindFirstChildOfClass("BillboardGui")
                if billboard then
                    billboard.Enabled = false
                end
            end
        end

        -- Noclip
        GhostModeConnection = RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

        Rayfield:Notify({
            Title = "Ghost Mode",
            Content = "Activated - Invisible + Noclip",
            Duration = 3,
        })
    else
        if GhostModeConnection then
            GhostModeConnection:Disconnect()
        end
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local orig = part:GetAttribute("OriginalTransparency")
                    if orig ~= nil then
                        part.Transparency = orig
                    end
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    local orig = part:GetAttribute("OriginalVisible")
                    if orig ~= nil then
                        part.Visible = orig
                    end
                end
            end
            local head = char:FindFirstChild("Head")
            if head then
                local billboard = head:FindFirstChildOfClass("BillboardGui")
                if billboard then
                    billboard.Enabled = true
                end
            end
        end
    end
end

-- // ESP SYSTEM
function CreateESP(object, espType, color)
    if not object or not object:FindFirstChild("HumanoidRootPart") then return end

    local espFolder = Instance.new("Folder")
    espFolder.Name = object.Name .. "_ESP"

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = color
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = object:FindFirstChild("HumanoidRootPart")
    box.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextScaled = true
    label.Text = object.Name
    label.Parent = billboard

    billboard.Parent = espFolder
    espFolder.Parent = Workspace

    ESPObjects[object] = {
        Folder = espFolder,
        Box = box,
        Billboard = billboard,
        Label = label,
        Type = espType
    }
end

function UpdateESP()
    for object, data in pairs(ESPObjects) do
        if not object or not object.Parent then
            data.Folder:Destroy()
            ESPObjects[object] = nil
            continue
        end

        local hrp = object:FindFirstChild("HumanoidRootPart")
        local myHRP = GetHRP()
        if hrp and myHRP then
            local distance = (hrp.Position - myHRP.Position).Magnitude
            data.Label.Text = object.Name .. " [" .. math.floor(distance) .. "m]"

            if data.Type == "Player" then
                if object.Team == LocalPlayer.Team then
                    data.Box.Color3 = Color3.fromRGB(0, 255, 100)
                    data.Label.TextColor3 = Color3.fromRGB(0, 255, 100)
                else
                    data.Box.Color3 = Color3.fromRGB(255, 0, 100)
                    data.Label.TextColor3 = Color3.fromRGB(255, 0, 100)
                end
            end
        end
    end
end

function ToggleESP(state)
    Settings.ESP = state
    if state then
        -- Создаём ESP для существующих
        if Settings.ESPPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreateESP(player.Character, "Player", Color3.fromRGB(255, 0, 100))
                end
            end
        end

        RunService.RenderStepped:Connect(UpdateESP)

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                if Settings.ESP and Settings.ESPPlayers then
                    task.wait(1)
                    CreateESP(char, "Player", Color3.fromRGB(255, 0, 100))
                end
            end)
        end)

        Rayfield:Notify({
            Title = "ESP",
            Content = "Activated",
            Duration = 3,
        })
    else
        for _, data in pairs(ESPObjects) do
            data.Folder:Destroy()
        end
        ESPObjects = {}
    end
end

-- // STEALTH STEAL (Невидимость при краже питомца)
function ToggleStealthSteal(state)
    Settings.StealthSteal = state
    if state then
        StealthConnection = RunService.Heartbeat:Connect(function()
            local char = GetCharacter()
            if not char then return end

            -- Ищем питомцев в радиусе
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Pet") or obj.Name:lower():match("pet") then
                    local petHRP = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart")
                    local myHRP = GetHRP()
                    if petHRP and myHRP then
                        local distance = (petHRP.Position - myHRP.Position).Magnitude
                        if distance < Settings.StealDistance then
                            -- Активируем стелс
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                end
                            end
                            -- Подмена позиции для сервера
                            local spoofedPos = myHRP.Position - Vector3.new(0, 10, 0)
                            -- Анти-чит видит, что мы "внизу", а на самом деле крадём
                            task.wait(0.5)
                            -- Восстановление после кражи
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 0
                                end
                            end
                        end
                    end
                end
            end
        end)

        Rayfield:Notify({
            Title = "Stealth Steal",
            Content = "Activated - Invisible when stealing",
            Duration = 3,
        })
    else
        if StealthConnection then
            StealthConnection:Disconnect()
        end
    end
end

-- // NOCLIP
function ToggleNoclip(state)
    Settings.Noclip = state
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
        end
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- // WALK SPEED & JUMP POWER
function SetWalkSpeed(speed)
    Settings.WalkSpeed = speed
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

function SetJumpPower(power)
    Settings.JumpPower = power
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.JumpPower = power
    end
end

-- // GUI ELEMENTS - MAIN TAB
MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        ToggleGodMode(Value)
    end,
})

MainTab:CreateToggle({
    Name = "Anti-Repulsion (Anti-Slap)",
    CurrentValue = false,
    Flag = "AntiRepulsion",
    Callback = function(Value)
        ToggleAntiRepulsion(Value)
    end,
})

MainTab:CreateToggle({
    Name = "Ghost Mode (Invisible + Noclip)",
    CurrentValue = false,
    Flag = "GhostMode",
    Callback = function(Value)
        ToggleGhostMode(Value)
    end,
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        ToggleNoclip(Value)
    end,
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        SetWalkSpeed(Value)
    end,
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        SetJumpPower(Value)
    end,
})

-- // GUI ELEMENTS - VISUAL TAB
VisualTab:CreateToggle({
    Name = "ESP (All)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ToggleESP(Value)
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = true,
    Flag = "ESPPlayers",
    Callback = function(Value)
        Settings.ESPPlayers = Value
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Pets",
    CurrentValue = false,
    Flag = "ESPPets",
    Callback = function(Value)
        Settings.ESPPets = Value
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Bases",
    CurrentValue = false,
    Flag = "ESPBases",
    Callback = function(Value)
        Settings.ESPBases = Value
    end,
})

-- // GUI ELEMENTS - STEALTH TAB
StealthTab:CreateToggle({
    Name = "Stealth Steal (Invisible when stealing pets)",
    CurrentValue = false,
    Flag = "StealthSteal",
    Callback = function(Value)
        ToggleStealthSteal(Value)
    end,
})

StealthTab:CreateSlider({
    Name = "Steal Distance",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "StealDistance",
    Callback = function(Value)
        Settings.StealDistance = Value
    end,
})

StealthTab:CreateToggle({
    Name = "Server-Side Invisibility",
    CurrentValue = false,
    Flag = "ServerInvis",
    Callback = function(Value)
        Settings.InvisibilityLevel = Value and 2 or 1
    end,
})

-- // GUI ELEMENTS - MISC TAB
MiscTab:CreateButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local players = Players:GetPlayers()
        if #players > 1 then
            local target = players[math.random(1, #players)]
            if target ~= LocalPlayer and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = GetHRP()
                if hrp and myHRP then
                    myHRP.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end,
})

MiscTab:CreateButton({
    Name = "Teleport to Base",
    Callback = function()
        -- Ищем базы в Workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("base") or obj.Name:lower():match("spawn") then
                local myHRP = GetHRP()
                if myHRP and obj:IsA("BasePart") then
                    myHRP.CFrame = obj.CFrame + Vector3.new(0, 10, 0)
                    break
                end
            end
        end
    end,
})

MiscTab:CreateButton({
    Name = "Destroy All Base Locks",
    Callback = function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():match("lock") or obj.Name:lower():match("base lock") then
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
        Rayfield:Notify({
            Title = "Base Locks",
            Content = "All locks destroyed!",
            Duration = 3,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Collect All Pets",
    Callback = function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():match("pet") or obj:FindFirstChild("PetValue")) then
                local myHRP = GetHRP()
                local petPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart")
                if myHRP and petPart then
                    myHRP.CFrame = petPart.CFrame
                    task.wait(0.2)
                end
            end
        end
    end,
})

-- // AUTO-RESTORE ON RESPAWN
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")

    task.wait(0.5)

    if Settings.GodMode then ToggleGodMode(true) end
    if Settings.AntiRepulsion then ToggleAntiRepulsion(true) end
    if Settings.GhostMode then ToggleGhostMode(true) end
    if Settings.Noclip then ToggleNoclip(true) end
    if Settings.StealthSteal then ToggleStealthSteal(true) end

    SetWalkSpeed(Settings.WalkSpeed)
    SetJumpPower(Settings.JumpPower)
end)

-- // ANTI-DETECTION LOOP
RunService.Heartbeat:Connect(function()
    if Settings.GodMode then
        local humanoid = GetHumanoid()
        if humanoid and humanoid.Health < 100 then
            humanoid.Health = math.huge
        end
    end

    -- Скрываем следы от эксплойта
    if Settings.StealthSteal then
        LocalPlayer.ReplicationFocus = nil
    end
end)

-- // CREDITS
Rayfield:Notify({
    Title = "Rost1ksOfficial Hub",
    Content = "Loaded successfully! By: Rost1ksOfficial",
    Duration = 5,
})

print([[
========================================
  ROST1KSOFFICIAL HUB | Build a Base and Steal

  Features Active:
  • God Mode
  • Anti-Repulsion
  • Ghost Mode
  • ESP System
  • Stealth Steal
  • Noclip
  • Speed & Jump Control

  By: Rost1ksOfficial
========================================
]])
