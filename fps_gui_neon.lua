local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TSUNAMI FPS - NEON EDITION",
    LoadingTitle = "Loading GUI...",
    LoadingSubtitle = "Initializing systems",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TsunamiExec",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Subtitle",
        Note = "Note",
        FileName = "Key",
        SaveKey = true,
        SaveKeySettings = true
    }
})

local ESPEnabled = false
local AimbotEnabled = false
local SpeedEnabled = false
local WallhackEnabled = false
local NotificationsEnabled = true
local PlayerSpeed = 50

-- Custom Icons (using Unicode symbols)
local ICON_ESP = "[>]"
local ICON_AIM = "[*]"
local ICON_SPEED = "[+]"
local ICON_WALL = "[#]"
local ICON_ON = "[ON]"
local ICON_OFF = "[OFF]"
local ICON_TOGGLE = "[~]"

-- Notification function
local function ShowNotification(title, message)
    if NotificationsEnabled then
        Rayfield:Notify({
            Title = title,
            Content = message,
            Duration = 3,
            Image = 4483362458,
        })
    end
end

-- ESP Function
local function ToggleESP()
    ESPEnabled = not ESPEnabled
    local status = ESPEnabled and "ACTIVATED" or "DEACTIVATED"
    ShowNotification("ESP SYSTEM", "ESP " .. status)
    
    if ESPEnabled then
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local esp = Instance.new("BillboardGui")
                    esp.Name = "ESP_" .. player.Name
                    esp.Size = UDim2.new(4, 0, 5, 0)
                    esp.MaxDistance = 500
                    esp.Parent = character.HumanoidRootPart
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 0.5
                    text.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                    text.TextColor3 = Color3.fromRGB(0, 255, 255)
                    text.Text = player.Name
                    text.TextSize = 14
                    text.Parent = esp
                end
            end
        end
    else
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            local character = player.Character
            if character then
                local esp = character.HumanoidRootPart:FindFirstChild("ESP_" .. player.Name)
                if esp then
                    esp:Destroy()
                end
            end
        end
    end
end

-- Aimbot Function
local function ToggleAimbot()
    AimbotEnabled = not AimbotEnabled
    local status = AimbotEnabled and "LOCKED" or "RELEASED"
    ShowNotification("AIMBOT", "Aimbot " .. status)
    
    if AimbotEnabled then
        game:GetService("RunService").RenderStepped:Connect(function()
            if AimbotEnabled then
                local camera = workspace.CurrentCamera
                local closestPlayer = nil
                local closestDistance = math.huge
                
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= game:GetService("Players").LocalPlayer and player.Character then
                        local distance = (player.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
                
                if closestPlayer and closestPlayer.Character then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.Head.Position)
                end
            end
        end)
    end
end

-- Speed Function
local function ToggleSpeed()
    SpeedEnabled = not SpeedEnabled
    local status = SpeedEnabled and "ACTIVE" or "INACTIVE"
    ShowNotification("SPEED BOOST", "Speed " .. status)
    
    if SpeedEnabled then
        local player = game:GetService("Players").LocalPlayer
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = PlayerSpeed
        end
    else
        local player = game:GetService("Players").LocalPlayer
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

-- Wallhack Function
local function ToggleWallhack()
    WallhackEnabled = not WallhackEnabled
    local status = WallhackEnabled and "ENABLED" or "DISABLED"
    ShowNotification("WALLHACK", "Wallhack " .. status)
    
    if WallhackEnabled then
        for _, part in pairs(workspace:FindPartBoundsInRadius(Vector3.new(0, 0, 0), 500)) do
            if part.Parent:FindFirstChild("Humanoid") and part.Parent ~= game:GetService("Players").LocalPlayer.Character then
                part.Transparency = 0.5
            end
        end
    end
end

-- Main Tab
local MainTab = Window:CreateTab("MAIN", "")

MainTab:CreateLabel("FPS TOOLKIT - NEON EDITION", true)
MainTab:CreateDivider()

MainTab:CreateToggle({
    Name = ICON_ESP .. " ESP SYSTEM",
    Callback = function(Value)
        ToggleESP()
    end,
})

MainTab:CreateToggle({
    Name = ICON_AIM .. " AIMBOT",
    Callback = function(Value)
        ToggleAimbot()
    end,
})

MainTab:CreateToggle({
    Name = ICON_WALL .. " WALLHACK",
    Callback = function(Value)
        ToggleWallhack()
    end,
})

MainTab:CreateDivider()

MainTab:CreateToggle({
    Name = ICON_SPEED .. " SPEED BOOST",
    Callback = function(Value)
        ToggleSpeed()
    end,
})

MainTab:CreateSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 100,
    Increment = 5,
    Suffix = " Speed",
    Callback = function(Value)
        PlayerSpeed = Value
        if SpeedEnabled then
            local player = game:GetService("Players").LocalPlayer
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = PlayerSpeed
            end
        end
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("SETTINGS", "")

SettingsTab:CreateLabel("NOTIFICATION SETTINGS", true)
SettingsTab:CreateToggle({
    Name = ICON_TOGGLE .. " Enable Notifications",
    Default = true,
    Callback = function(Value)
        NotificationsEnabled = Value
        ShowNotification("SETTINGS", "Notifications " .. (Value and "Enabled" or "Disabled"))
    end,
})

SettingsTab:CreateDivider()

SettingsTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        ESPEnabled = false
        AimbotEnabled = false
        SpeedEnabled = false
        WallhackEnabled = false
        PlayerSpeed = 50
        ShowNotification("RESET", "All settings restored to default")
    end,
})

SettingsTab:CreateButton({
    Name = "Clear Exploits",
    Callback = function()
        ToggleESP()
        ToggleAimbot()
        ToggleWallhack()
        ToggleSpeed()
        ShowNotification("CLEARED", "All exploits deactivated")
    end,
})

SettingsTab:CreateDivider()

SettingsTab:CreateLabel("Script Status: ACTIVE", true)

Rayfield:SetNotificationTheme("Darker")

ShowNotification("TSUNAMI EXEC", "FPS GUI Neon Edition Loaded Successfully")
