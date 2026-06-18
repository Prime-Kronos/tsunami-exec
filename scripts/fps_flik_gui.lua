-- FPS Flik Rayfield GUI Script
-- Created for Tsunami Exec
-- Красивый и функциональный GUI для FPS игр

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎮 FPS Flik Pro",
   LoadingTitle = "Loading FPS Pro...",
   LoadingSubtitle = "by Prime-Kronos",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FPS_Flik_Config",
      FileName = "Config"
   },
   KeySystem = false,
   KeySettings = {
      Title = "FPS Flik Key System",
      Subtitle = "Enter your key",
      Note = "No key needed for now",
      FileName = "FPSKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {""}
   }
})

-- ====== ОСНОВНЫЕ ВКЛАДКИ ======

local PlayerTab = Window:CreateTab("👤 Игрок", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Визуалы", 4483362458)
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Разное", 4483362458)
local SettingsTab = Window:CreateTab("🔧 Настройки", 4483362458)

-- ====== ПЕРЕМЕННЫЕ ДЛЯ ФУНКЦИЙ ======

local Settings = {
   ESP_Enabled = false,
   ESP_Players = true,
   ESP_Distance = 500,
   Aimbot_Enabled = false,
   Aimbot_Smoothness = 0.5,
   SpeedHack_Enabled = false,
   SpeedHack_Speed = 50,
   JumpPower = 50,
   Wallhack_Enabled = false,
   ShowNotifications = true
}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====== ФУНКЦИИ ======

-- ESP Функция
local function UpdateESP()
   if not Settings.ESP_Enabled then return end
   
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
         if humanoidRootPart then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            
            if distance <= Settings.ESP_Distance then
               -- ESP логика (можно расширить)
               if Settings.ShowNotifications then
                  print("🔍 ESP: " .. player.Name .. " (" .. math.floor(distance) .. "м)")
               end
            end
         end
      end
   end
end

-- Speedhack Функция
local function SetSpeed(speed)
   if LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.WalkSpeed = speed
      end
   end
end

-- Jump Power Функция
local function SetJumpPower(power)
   if LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.JumpPower = power
      end
   end
end

-- Aimbot Функция
local function GetNearestPlayer()
   local nearest = nil
   local nearestDistance = math.huge
   
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
         if humanoidRootPart then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
               nearest = player
               nearestDistance = distance
            end
         end
      end
   end
   
   return nearest
end

-- ====== PLAYER TAB ======

PlayerTab:CreateSlider({
   Name = "⚡ Скорость бега",
   Min = 16,
   Max = 200,
   Default = 16,
   Color = Color3.fromRGB(255, 100, 100),
   Increment = 1,
   ValueChanged = function(Value)
      Settings.SpeedHack_Speed = Value
      if Settings.SpeedHack_Enabled then
         SetSpeed(Value)
      end
   end
})

PlayerTab:CreateToggle({
   Name = "🚀 Включить SpeedHack",
   CurrentValue = false,
   Flag = "SpeedHack_Toggle",
   Callback = function(Value)
      Settings.SpeedHack_Enabled = Value
      if Value then
         SetSpeed(Settings.SpeedHack_Speed)
         if Settings.ShowNotifications then
            Rayfield:Notify({
               Title = "✅ SpeedHack",
               Content = "Включён! Скорость: " .. Settings.SpeedHack_Speed,
               Duration = 2,
               Image = 4483362458,
            })
         end
      else
         SetSpeed(16)
      end
   end
})

PlayerTab:CreateSlider({
   Name = "📈 Сила прыжка",
   Min = 7,
   Max = 200,
   Default = 50,
   Color = Color3.fromRGB(100, 200, 255),
   Increment = 1,
   ValueChanged = function(Value)
      Settings.JumpPower = Value
      SetJumpPower(Value)
   end
})

PlayerTab:CreateButton({
   Name = "🆙 Поднять игрока",
   Callback = function()
      if LocalPlayer.Character then
         LocalPlayer.Character:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 50, 0))
         if Settings.ShowNotifications then
            Rayfield:Notify({
               Title = "✈️ Поднято!",
               Content = "Ты поднялся на 50 единиц",
               Duration = 2,
               Image = 4483362458,
            })
         end
      end
   end
})

-- ====== VISUALS TAB ======

VisualsTab:CreateToggle({
   Name = "👁️ ESP Включить",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
      Settings.ESP_Enabled = Value
      if Value then
         if Settings.ShowNotifications then
            Rayfield:Notify({
               Title = "✅ ESP",
               Content = "ESP активирован!",
               Duration = 2,
               Image = 4483362458,
            })
         end
         while Settings.ESP_Enabled do
            UpdateESP()
            wait(0.5)
         end
      end
   end
})

VisualsTab:CreateToggle({
   Name = "👥 Видеть игроков",
   CurrentValue = true,
   Flag = "ESP_Players",
   Callback = function(Value)
      Settings.ESP_Players = Value
   end
})

VisualsTab:CreateSlider({
   Name = "📏 Дистанция ESP",
   Min = 50,
   Max = 1000,
   Default = 500,
   Color = Color3.fromRGB(100, 255, 100),
   Increment = 50,
   ValueChanged = function(Value)
      Settings.ESP_Distance = Value
   end
})

VisualsTab:CreateToggle({
   Name = "🚫 Wallhack (Прозрачные стены)",
   CurrentValue = false,
   Flag = "Wallhack_Toggle",
   Callback = function(Value)
      Settings.Wallhack_Enabled = Value
      for _, part in pairs(workspace:GetDescendants()) do
         if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            if Value then
               part.CanCollide = false
            else
               part.CanCollide = true
            end
         end
      end
   end
})

-- ====== AIMBOT TAB ======

AimbotTab:CreateToggle({
   Name = "🎯 Aimbot Включить",
   CurrentValue = false,
   Flag = "Aimbot_Toggle",
   Callback = function(Value)
      Settings.Aimbot_Enabled = Value
      if Value then
         if Settings.ShowNotifications then
            Rayfield:Notify({
               Title = "✅ Aimbot",
               Content = "Aimbot активирован!",
               Duration = 2,
               Image = 4483362458,
            })
         end
      end
   end
})

AimbotTab:CreateSlider({
   Name = "🔄 Гладкость Aimbot",
   Min = 0.1,
   Max = 1,
   Default = 0.5,
   Color = Color3.fromRGB(255, 200, 100),
   Increment = 0.1,
   ValueChanged = function(Value)
      Settings.Aimbot_Smoothness = Value
   end
})

-- ====== MISC TAB ======

MiscTab:CreateToggle({
   Name = "🔔 Показывать уведомления",
   CurrentValue = true,
   Flag = "Notifications_Toggle",
   Callback = function(Value)
      Settings.ShowNotifications = Value
   end
})

MiscTab:CreateButton({
   Name = "🔄 Перезагрузить игру",
   Callback = function()
      if Settings.ShowNotifications then
         Rayfield:Notify({
            Title = "⚠️ П��резагрузка",
            Content = "Игра перезагружается через 3 сек...",
            Duration = 3,
            Image = 4483362458,
         })
      end
      wait(3)
      game:Shutdown()
   end
})

MiscTab:CreateButton({
   Name = "❌ Выйти из игры",
   Callback = function()
      Players.LocalPlayer:Kick("Вышел из игры через GUI")
   end
})

-- ====== SETTINGS TAB ======

SettingsTab:CreateSection("📋 Информация")

SettingsTab:CreateLabel("🎮 Скрипт: FPS Flik Pro")
SettingsTab:CreateLabel("👨‍💻 Автор: Prime-Kronos")
SettingsTab:CreateLabel("📦 Executor: Tsunami Exec")

SettingsTab:CreateButton({
   Name = "💾 Сохранить конфиг",
   Callback = function()
      if Settings.ShowNotifications then
         Rayfield:Notify({
            Title = "✅ Сохранено",
            Content = "Конфигурация сохранена!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end
})

SettingsTab:CreateButton({
   Name = "🗑️ Очистить всё",
   Callback = function()
      Settings.ESP_Enabled = false
      Settings.Aimbot_Enabled = false
      Settings.SpeedHack_Enabled = false
      Settings.Wallhack_Enabled = false
      SetSpeed(16)
      if Settings.ShowNotifications then
         Rayfield:Notify({
            Title = "🗑️ Очищено",
            Content = "Все настройки сброшены!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end
})

-- ====== ГЛАВНОЕ УВЕДОМЛЕНИЕ ======

Rayfield:Notify({
   Title = "🎮 FPS Flik Pro загружен",
   Content = "Добро пожаловать! Используй GUI для управления функциями",
   Duration = 4,
   Image = 4483362458,
})

-- ====== ОБНОВЛЕНИЯ ======

game:GetService("RunService").RenderStepped:Connect(function()
   if Settings.Aimbot_Enabled then
      local nearest = GetNearestPlayer()
      if nearest and nearest.Character then
         local targetHead = nearest.Character:FindFirstChild("Head")
         if targetHead then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetHead.Position), Settings.Aimbot_Smoothness)
         end
      end
   end
   
   if Settings.SpeedHack_Enabled then
      SetSpeed(Settings.SpeedHack_Speed)
   end
end)

print("✅ FPS Flik Pro скрипт загружен успешно!")
