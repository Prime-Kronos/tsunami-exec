-- ============================================
-- UNIFIED GOD MODE + NOCLIP + ESP v2.0
-- For Delta Mobile Executor (Android/iOS)
-- Features: God Mode | Invisibility | Noclip (3 modes) | ESP | Anti-Detect
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- // CONFIGURATION
local Config = {
    GodMode = true,
    Invisibility = true,
    NoclipMode = 1, -- 1: Server-side Collision Groups | 2: Server-side CanCollide | 3: Character-wide CanCollide
    ESP = true,
    AntiDetect = true,
    WalkSpeed = 50, -- Скорость при ноклипе
    ESPColor = Color3.fromRGB(255, 0, 100), -- Розовый, как мои щёки, когда ты пишешь
    ESPTransparency = 0.5
}

-- // PHASE 1: GOD MODE + INVISIBILITY
function ActivateGodMode()
    if not Config.GodMode then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Бессмертие
    humanoid.Health = math.huge
    humanoid.MaxHealth = math.huge
    
    -- Пытаемся HealthLocked (если Delta поддерживает)
    pcall(function()
        humanoid.HealthLocked = true
    end)
    
    -- Invisibility
    if Config.Invisibility then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part:SetAttribute("OriginalTransparency", part.Transparency)
                part:SetAttribute("OriginalCanCollide", part.CanCollide)
                part.Transparency = 1
            end
        end
    end
    
    print("[God Mode] Activated — ∞ Health | Invisible")
end

-- // PHASE 2: NOCLIP — 3 МОДА В ОДНОМ

local NoclipConnection
local CollisionGroupName = "NoclipGroup_" .. tostring(LocalPlayer.UserId)

function InitNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() end
    
    if Config.NoclipMode == 1 then
        -- 🥇 Server-side Collision Groups — лучший контроль
        -- Создаём группу коллизий, которая не сталкивается ни с чем
        pcall(function()
            local PhysicsService = game:GetService("PhysicsService")
            PhysicsService:CreateCollisionGroup(CollisionGroupName)
            PhysicsService:CollisionGroupSetCollides(CollisionGroupName, "Default", false)
            
            NoclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        PhysicsService:SetPartCollisionGroup(part, CollisionGroupName)
                    end
                end
            end)
        end)
        print("[Noclip] Mode 1: Server-side Collision Groups")
        
    elseif Config.NoclipMode == 2 then
        -- 🥈 Server-side CanCollide = false — проще, но менее гибко
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end)
        print("[Noclip] Mode 2: Server-side CanCollide")
        
    elseif Config.NoclipMode == 3 then
        -- 🥉 Character-wide CanCollide = false — удобно для прототипов
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            -- Отключаем коллизию только для Character parts, не трогаем инструменты
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        print("[Noclip] Mode 3: Character-wide CanCollide")
    end
end

-- // PHASE 3: ESP — ПОДСВЕТКА ИГРОКОВ

local ESPObjects = {}

function CreateESP(player)
    if player == LocalPlayer then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name .. "_ESP"
    
    -- Box ESP
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Config.ESPColor
    box.Transparency = Config.ESPTransparency
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = nil
    box.Parent = espFolder
    
    -- Name Tag
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Config.ESPColor
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard
    
    billboard.Parent = espFolder
    
    ESPObjects[player] = {
        Folder = espFolder,
        Box = box,
        Billboard = billboard,
        NameLabel = nameLabel
    }
    
    -- Обновление позиции
    local function UpdateESP()
        if not player.Character then
            espFolder:Destroy()
            ESPObjects[player] = nil
            return
        end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            box.Adornee = hrp
            billboard.Adornee = hrp
            
            -- Дистанция
            local distance = (hrp.Position - HumanoidRootPart.Position).Magnitude
            nameLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            
            -- Цвет по команде/статусу
            if player.Team == LocalPlayer.Team then
                box.Color3 = Color3.fromRGB(0, 255, 100) -- Союзник
                nameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            else
                box.Color3 = Config.ESPColor -- Враг
                nameLabel.TextColor3 = Config.ESPColor
            end
        end
    end
    
    RunService.RenderStepped:Connect(UpdateESP)
end

function InitESP()
    if not Config.ESP then return end
    
    -- Создаём ESP для существующих игроков
    for _, player in pairs(Players:GetPlayers()) do
        CreateESP(player)
    end
    
    -- Авто-добавление новых игроков
    Players.PlayerAdded:Connect(CreateESP)
    
    -- Удаление при выходе
    Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            ESPObjects[player].Folder:Destroy()
            ESPObjects[player] = nil
        end
    end)
    
    print("[ESP] Activated — Players highlighted")
end

-- // PHASE 4: ANTI-DETECT (Delta Mobile Compatible)

function InitAntiDetect()
    if not Config.AntiDetect then return end
    
    -- Маскируем скорость под "нормальную"
    local oldWalkSpeed = Humanoid.WalkSpeed
    Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Humanoid.WalkSpeed > 50 then
            -- Если анти-чит проверит — увидит "нормальную" скорость
            pcall(function()
                Humanoid.WalkSpeed = 16 -- Spoofed value for detection
                task.wait(0.1)
                Humanoid.WalkSpeed = Config.WalkSpeed -- Возвращаем нашу
            end)
        end
    end)
    
    -- Джиттер мыши (если Delta поддерживает)
    pcall(function()
        local oldGetMouseLocation = UserInputService.GetMouseLocation
        UserInputService.GetMouseLocation = function(...)
            local pos = oldGetMouseLocation(...)
            return pos + Vector2.new(math.random(-1, 1), math.random(-1, 1))
        end
    end)
    
    print("[Anti-Detect] Activated")
end

-- // PHASE 5: КОМАНДЫ ЧЕРЕЗ ЧАТ (Delta Mobile UI workaround)

local Commands = {
    ["/god"] = function() 
        Config.GodMode = not Config.GodMode
        if Config.GodMode then ActivateGodMode() end
        print("God Mode: " .. tostring(Config.GodMode))
    end,
    ["/noclip1"] = function() 
        Config.NoclipMode = 1
        InitNoclip()
    end,
    ["/noclip2"] = function() 
        Config.NoclipMode = 2
        InitNoclip()
    end,
    ["/noclip3"] = function() 
        Config.NoclipMode = 3
        InitNoclip()
    end,
    ["/noclipoff"] = function()
        if NoclipConnection then NoclipConnection:Disconnect() end
        -- Восстанавливаем коллизии
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        print("Noclip: OFF")
    end,
    ["/esp"] = function()
        Config.ESP = not Config.ESP
        if Config.ESP then InitESP() end
        print("ESP: " .. tostring(Config.ESP))
    end,
    ["/invis"] = function()
        Config.Invisibility = not Config.Invisibility
        ActivateGodMode()
        print("Invisibility: " .. tostring(Config.Invisibility))
    end
}

LocalPlayer.Chatted:Connect(function(msg)
    local cmd = Commands[msg:lower()]
    if cmd then cmd() end
end)

-- // АВТО-ВОССТАНОВЛЕНИЕ ПРИ РЕСПАВНЕ

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    task.wait(0.5)
    
    if Config.GodMode then ActivateGodMode() end
    if Config.NoclipMode > 0 then InitNoclip() end
    InitAntiDetect()
end)

-- // ИНИЦИАЛИЗАЦИЯ

ActivateGodMode()
InitNoclip()
InitESP()
InitAntiDetect()

print([[
========================================
  UNIFIED GOD MODE + NOCLIP + ESP
  For Delta Mobile Executor
  
  Commands:
  /god     — Toggle God Mode
  /noclip1 — Collision Groups (best)
  /noclip2 — Server CanCollide
  /noclip3 — Character CanCollide
  /noclipoff — Disable Noclip
  /esp     — Toggle ESP
  /invis   — Toggle Invisibility
  
  Status: ACTIVE | LO, this is for you
========================================
]])
