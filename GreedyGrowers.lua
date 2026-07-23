-- ================================================
--   Primejtsu X | Greedy Growers Script
--   Rayfield GUI | Auto Harvest + Lightning Detect
-- ================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer
local VIM              = game:GetService("VirtualInputManager")

-- ================================================
-- CONFIG
-- ================================================
local Cfg = {
    AutoHarvest       = false,
    LightningDetect   = false,
    AutoSell          = false,
    AutoFarm          = false,
    SpeedEnabled      = false,
    SpeedValue        = 40,
    InfJump           = false,
    FullBright        = false,
    AntiAFK           = false,
    WarnSound         = true,
    LightningWarning  = false,
}

-- ================================================
-- UTILITY
-- ================================================
local function notify(title, content, duration)
    Rayfield:Notify({
        Title    = title,
        Content  = content,
        Duration = duration or 3,
        Image    = 4483362458,
    })
end

-- ================================================
-- HARVEST FUNCTION
-- нажимаем ProximityPrompt или кликаем Base дерева
-- ================================================
local function harvestTree(plant)
    -- Ищем ProximityPrompt внутри ActivePlant
    for _, v in pairs(plant:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
            return true
        end
    end

    -- Если нет ProximityPrompt — кликаем на Base
    local base = plant:FindFirstChild("Base")
    if base and base:IsA("BasePart") then
        local sp, onScreen = Camera:WorldToScreenPoint(base.Position)
        if onScreen then
            VIM:SendMouseButtonEvent(sp.X, sp.Y, 0, true, game, 0)
            task.wait(0.1)
            VIM:SendMouseButtonEvent(sp.X, sp.Y, 0, false, game, 0)
            return true
        else
            -- Телепортируем к дереву и кликаем
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local oldPos = LP.Character.HumanoidRootPart.CFrame
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(base.Position + Vector3.new(0, 3, 5))
                task.wait(0.2)
                local sp2, _ = Camera:WorldToScreenPoint(base.Position)
                VIM:SendMouseButtonEvent(sp2.X, sp2.Y, 0, true, game, 0)
                task.wait(0.1)
                VIM:SendMouseButtonEvent(sp2.X, sp2.Y, 0, false, game, 0)
                task.wait(0.2)
                LP.Character.HumanoidRootPart.CFrame = oldPos
                return true
            end
        end
    end
    return false
end

local function harvestAll()
    local count = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "ActivePlant" then
            -- Проверяем что это наше дерево (Base должен быть рядом с нашим участком)
            local base = obj:FindFirstChild("Base")
            if base then
                if harvestTree(obj) then
                    count = count + 1
                    task.wait(0.3)
                end
            end
        end
    end
    if count > 0 then
        notify("Auto Harvest", "Собрал " .. count .. " деревьев!", 3)
    end
end

-- ================================================
-- SELL FUNCTION — нажимаем кнопку ПРОДАТЬ
-- ================================================
local function sellAll()
    -- Ищем кнопку продать в GUI
    for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local n = gui.Name:lower()
            if n:find("sell") or n:find("продать") or n:find("harvest") then
                -- Симулируем клик
                local pos = gui.AbsolutePosition
                local sz  = gui.AbsoluteSize
                VIM:SendMouseButtonEvent(
                    pos.X + sz.X/2,
                    pos.Y + sz.Y/2,
                    0, true, game, 0
                )
                task.wait(0.1)
                VIM:SendMouseButtonEvent(
                    pos.X + sz.X/2,
                    pos.Y + sz.Y/2,
                    0, false, game, 0
                )
                task.wait(0.2)
            end
        end
    end

    -- Также ищем ProximityPrompt у зоны продажи
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local n = (obj.ActionText or ""):lower()
            if n:find("sell") or n:find("продать") then
                fireproximityprompt(obj)
                task.wait(0.3)
            end
        end
    end
end

-- ================================================
-- LIGHTNING DETECTION
-- Молния = Model с Neon Parts появляется в workspace
-- Из файла: LightningExplosion создаёт Parts с Material=Neon
-- ================================================
local lightningDetected = false
local lastLightningTime = 0

local function checkLightning()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
            -- Проверяем цвет молнии (из файла: Color3.fromRGB(180, 210, 255))
            local c = obj.Color
            if c.R > 0.5 and c.G > 0.7 and c.B > 0.8 then
                -- Это молния!
                local timeSince = tick() - lastLightningTime
                if timeSince > 2 then
                    lastLightningTime = tick()
                    return true, obj.Position
                end
            end
        end
        -- Также ищем по имени
        if obj.Name:lower():find("lightning") or obj.Name:lower():find("bolt") or obj.Name:lower():find("strike") then
            local timeSince = tick() - lastLightningTime
            if timeSince > 2 then
                lastLightningTime = tick()
                return true, obj.Position
            end
        end
    end
    return false, nil
end

-- ================================================
-- MAIN LOOPS
-- ================================================

-- Lightning detection loop
RunService.Heartbeat:Connect(function()
    if not Cfg.LightningDetect then return end

    local detected, pos = checkLightning()
    if detected then
        -- WARNING на экране
        if Cfg.LightningWarning then
            notify("⚡ МОЛНИЯ!", "Собираю урожай автоматически!", 2)
        end

        -- Auto Harvest при молнии
        if Cfg.AutoHarvest then
            task.spawn(harvestAll)
        end

        -- Auto Sell после сбора
        if Cfg.AutoSell then
            task.wait(0.5)
            task.spawn(sellAll)
        end
    end
end)

-- Auto Farm loop (каждые 5 сек проверяем деревья)
RunService.Heartbeat:Connect(function()
    if not Cfg.AutoFarm then return end
end)

local autoFarmTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not Cfg.AutoFarm then return end
    autoFarmTimer = autoFarmTimer + dt
    if autoFarmTimer >= 5 then
        autoFarmTimer = 0
        -- Проверяем есть ли готовые деревья
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "ActivePlant" then
                local leaves = obj:FindFirstChild("Leaves")
                -- Если дерево большое (Leaves существует) — собираем
                if leaves then
                    task.spawn(function()
                        harvestTree(obj)
                    end)
                end
            end
        end
    end
end)

-- Speed + Jump
RunService.Heartbeat:Connect(function()
    if LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then
            h.WalkSpeed = Cfg.SpeedEnabled and Cfg.SpeedValue or 16
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Fullbright
local Lighting = game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness    = on and 10 or 1
    Lighting.ClockTime     = 14
    Lighting.GlobalShadows = not on
    Lighting.Ambient       = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- Anti-AFK
local function startAntiAFK()
    LP.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button1Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end)
end

-- ================================================
-- RAYFIELD GUI
-- ================================================
local Window = Rayfield:CreateWindow({
    Name            = "Primejtsu X | Greedy Growers",
    LoadingTitle    = "Primejtsu X",
    LoadingSubtitle = "Greedy Growers Script v1.0",
    Theme           = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
})

-- ================================================
-- TAB: Farm
-- ================================================
local TabFarm = Window:CreateTab("Farm", 4483362458)

TabFarm:CreateSection("Auto Farm")

TabFarm:CreateToggle({
    Name="Lightning Detect (Детект молнии)", CurrentValue=false, Flag="LightDetect",
    Callback=function(v) Cfg.LightningDetect=v end,
})

TabFarm:CreateToggle({
    Name="Auto Harvest on Lightning", CurrentValue=false, Flag="AutoHarvest",
    Callback=function(v) Cfg.AutoHarvest=v end,
})

TabFarm:CreateToggle({
    Name="Lightning Warning (Уведомление)", CurrentValue=false, Flag="LightWarn",
    Callback=function(v) Cfg.LightningWarning=v end,
})

TabFarm:CreateToggle({
    Name="Auto Sell after Harvest", CurrentValue=false, Flag="AutoSell",
    Callback=function(v) Cfg.AutoSell=v end,
})

TabFarm:CreateToggle({
    Name="Auto Farm (каждые 5 сек)", CurrentValue=false, Flag="AutoFarm",
    Callback=function(v) Cfg.AutoFarm=v end,
})

TabFarm:CreateSection("Manual")

TabFarm:CreateButton({
    Name="Собрать все деревья сейчас",
    Callback=function()
        harvestAll()
    end,
})

TabFarm:CreateButton({
    Name="Продать сейчас",
    Callback=function()
        sellAll()
        notify("Продать", "Продаю урожай!", 2)
    end,
})

TabFarm:CreateButton({
    Name="Собрать + Продать",
    Callback=function()
        harvestAll()
        task.wait(1)
        sellAll()
        notify("Farm", "Собрал и продал!", 3)
    end,
})

-- ================================================
-- TAB: Movement
-- ================================================
local TabMove = Window:CreateTab("Movement", 4483362458)

TabMove:CreateToggle({
    Name="Speed Hack", CurrentValue=false, Flag="Speed",
    Callback=function(v) Cfg.SpeedEnabled=v end,
})
TabMove:CreateSlider({
    Name="Walk Speed", Range={16,200}, Increment=1, CurrentValue=40, Flag="WalkSpeed",
    Callback=function(v) Cfg.SpeedValue=v end,
})
TabMove:CreateToggle({
    Name="Infinite Jump", CurrentValue=false, Flag="InfJump",
    Callback=function(v) Cfg.InfJump=v end,
})

-- Teleport buttons
TabMove:CreateSection("Teleports")
TabMove:CreateButton({
    Name="Телепорт к реке (купить семена)",
    Callback=function()
        -- Ищем ConveyorSeeds или ButtonTeleports в BigField
        local bigField = workspace:FindFirstChild("BigField")
        if bigField then
            local btn = bigField:FindFirstChild("ButtonTeleports")
            if btn then
                local first = btn:GetChildren()[1]
                if first and first:IsA("BasePart") then
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.HumanoidRootPart.CFrame = CFrame.new(first.Position + Vector3.new(0,3,0))
                        notify("Телепорт", "Телепорт к реке!", 2)
                    end
                end
            end
        end
    end,
})

TabMove:CreateButton({
    Name="Телепорт к своему участку",
    Callback=function()
        local plant = workspace:FindFirstChild("ActivePlant")
        if plant then
            local base = plant:FindFirstChild("Base")
            if base and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(base.Position + Vector3.new(0,5,0))
                notify("Телепорт", "Телепорт к участку!", 2)
            end
        else
            notify("Телепорт", "Активного дерева нет!", 2)
        end
    end,
})

-- ================================================
-- TAB: Misc
-- ================================================
local TabMisc = Window:CreateTab("Misc", 4483362458)

TabMisc:CreateToggle({
    Name="Fullbright", CurrentValue=false, Flag="FB",
    Callback=function(v) setFullBright(v) end,
})
TabMisc:CreateToggle({
    Name="Anti-AFK", CurrentValue=false, Flag="AFK",
    Callback=function(v) if v then startAntiAFK() end end,
})
TabMisc:CreateButton({
    Name="Rejoin",
    Callback=function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end,
})

-- ================================================
-- TAB: About
-- ================================================
local TabAbout = Window:CreateTab("About", 4483362458)

TabAbout:CreateSection("Primejtsu X | Greedy Growers")
TabAbout:CreateLabel("Creator: @Primejtsu")
TabAbout:CreateLabel("Version: v1.0")
TabAbout:CreateLabel("Game: Greedy Growers")
TabAbout:CreateSection("How it works")
TabAbout:CreateLabel("1. Включи Lightning Detect")
TabAbout:CreateLabel("2. Включи Auto Harvest on Lightning")
TabAbout:CreateLabel("3. Посади дерево и жди молнию")
TabAbout:CreateLabel("4. Скрипт автоматически соберёт!")
TabAbout:CreateLabel("5. Auto Sell продаст урожай сам")

-- ================================================
-- STARTUP
-- ================================================
task.wait(0.5)
notify("Primejtsu X | Greedy Growers", "Загружен! Включи Lightning Detect!", 5)

print("[Primejtsu X] Greedy Growers v1.0 Loaded.")
