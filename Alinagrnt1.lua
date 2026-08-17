--// Snipers vs Runners | @aLiNa_grnt
--// Rafield GUI Library
--// Features: Aimbot, ESP Only

--// Load Rafield GUI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
--// NOTE: If Rafield specific URL is different, replace above. 
--// Using Linoria as base since Rafield is fork/variant. 
--// For TRUE Rafield, use: loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()

local Window = Library:CreateWindow({
    Name = "Snipers vs Runners | @aLiNa_grnt",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SvR_Exploit"
})

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Tabs
local AimbotTab = Window:CreateTab("Aimbot")
local ESPTab = Window:CreateTab("ESP")
local MiscTab = Window:CreateTab("Misc")

--// Settings
local Settings = {
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimPart = "Head",
    AimFov = 150,
    AimSmoothness = 3,
    TeamCheck = true,
    WallCheck = false,
    AutoShoot = false,
    ShootDelay = 0.1,
    
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPDistance = false,
    ESPMaxDistance = 1000
}

--// ESP Storage
local ESPObjects = {}

--// FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(180, 130, 220)
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.AimFov

--// Utility Functions
local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeammate(player) then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local aimPart = character:FindFirstChild(Settings.AimPart)
        if not aimPart then continue end
        
        if not IsVisible(aimPart) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < Settings.AimFov and dist < closestDist then
            closestDist = dist
            closest = {Player = player, Part = aimPart, ScreenPos = screenPos, Character = character}
        end
    end
    
    return closest
end

--// ESP Functions
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Distance = Drawing.new("Text")
    }
    
    objects.Box.Visible = false
    objects.Box.Thickness = 1
    objects.Box.Color = Color3.fromRGB(255, 50, 50)
    objects.Box.Transparency = 1
    objects.Box.Filled = false
    
    objects.Name.Visible = false
    objects.Name.Size = 13
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Color = Color3.fromRGB(255, 255, 255)
    objects.Name.Font = Drawing.Fonts.UI
    
    objects.HealthBarBg.Visible = false
    objects.HealthBarBg.Thickness = 1
    objects.HealthBarBg.Color = Color3.fromRGB(50, 50, 50)
    objects.HealthBarBg.Filled = true
    objects.HealthBarBg.Transparency = 0.5
    
    objects.HealthBar.Visible = false
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Color = Color3.fromRGB(50, 255, 50)
    objects.HealthBar.Filled = true
    objects.HealthBar.Transparency = 0.8
    
    objects.Tracer.Visible = false
    objects.Tracer.Thickness = 1
    objects.Tracer.Color = Color3.fromRGB(180, 130, 220)
    objects.Tracer.Transparency = 0.7
    
    objects.Distance.Visible = false
    objects.Distance.Size = 11
    objects.Distance.Center = true
    objects.Distance.Outline = true
    objects.Distance.Color = Color3.fromRGB(200, 200, 200)
    objects.Distance.Font = Drawing.Fonts.UI
    
    ESPObjects[player] = objects
end

local function RemoveESP(player)
    local objects = ESPObjects[player]
    if not objects then return end
    for _, obj in pairs(objects) do
        if obj then obj:Remove() end
    end
    ESPObjects[player] = nil
end

local function UpdateESP()
    for player, objects in pairs(ESPObjects) do
        local character = player.Character
        if not character or not Settings.ESPEnabled then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        if IsTeammate(player) then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.ESPMaxDistance then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local head = character:FindFirstChild("Head")
        local foot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg")
        if not head or not foot then continue end
        
        local headPos = Camera:WorldToViewportPoint(head.Position)
        local footPos = Camera:WorldToViewportPoint(foot.Position)
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height * 0.5
        
        local boxX = pos.X - width / 2
        local boxY = pos.Y - height / 2
        
        --// Box
        if Settings.ESPBoxes then
            objects.Box.Size = Vector2.new(width, height)
            objects.Box.Position = Vector2.new(boxX, boxY)
            objects.Box.Visible = true
        else
            objects.Box.Visible = false
        end
        
        --// Name
        if Settings.ESPNames then
            objects.Name.Position = Vector2.new(pos.X, boxY - 18)
            objects.Name.Text = player.Name .. " | @aLiNa_grnt"
            objects.Name.Visible = true
        else
            objects.Name.Visible = false
        end
        
        --// Health
        if Settings.ESPHealth then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = height * healthPercent
            
            objects.HealthBarBg.Size = Vector2.new(4, height)
            objects.HealthBarBg.Position = Vector2.new(boxX - 10, boxY)
            objects.HealthBarBg.Visible = true
            
            objects.HealthBar.Size = Vector2.new(4, barHeight)
            objects.HealthBar.Position = Vector2.new(boxX - 10, boxY + height - barHeight)
            objects.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 50)
            objects.HealthBar.Visible = true
        else
            objects.HealthBar.Visible = false
            objects.HealthBarBg.Visible = false
        end
        
        --// Tracer
        if Settings.ESPTracers then
            objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            objects.Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
            objects.Tracer.Visible = true
        else
            objects.Tracer.Visible = false
        end
        
        --// Distance
        if Settings.ESPDistance then
            objects.Distance.Position = Vector2.new(pos.X, boxY + height + 2)
            objects.Distance.Text = string.format("[%.0fm]", distance)
            objects.Distance.Visible = true
        else
            objects.Distance.Visible = false
        end
    end
end

--// Aimbot Logic
local function RunAimbot()
    if not Settings.AimbotEnabled then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local targetPos = Camera:WorldToViewportPoint(target.Part.Position)
    local mousePos = UserInputService:GetMouseLocation()
    local moveVec = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) / Settings.AimSmoothness
    
    mousemoverel(moveVec.X, moveVec.Y)
    
    if Settings.AutoShoot then
        task.wait(Settings.ShootDelay)
        mouse1click()
    end
end

--// Player Events
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

--// Render Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.AimFov
    FOVCircle.Visible = Settings.AimbotEnabled and true or false
    
    if Settings.ESPEnabled then
        UpdateESP()
    else
        for _, objects in pairs(ESPObjects) do
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
        end
    end
    
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        RunAimbot()
    end
end)

--// ==================== RAFIELD GUI ELEMENTS ====================

--// Aimbot Section
local AimbotSection = AimbotTab:CreateSection("Aimbot Settings")

AimbotSection:CreateToggle("Enable Aimbot", false, function(Value)
    Settings.AimbotEnabled = Value
end)

AimbotSection:CreateToggle("Auto Shoot", false, function(Value)
    Settings.AutoShoot = Value
end)

AimbotSection:CreateToggle("Team Check", true, function(Value)
    Settings.TeamCheck = Value
end)

AimbotSection:CreateToggle("Wall Check", false, function(Value)
    Settings.WallCheck = Value
end)

AimbotSection:CreateDropdown("Aim Part", {"Head", "Torso", "HumanoidRootPart"}, function(Value)
    Settings.AimPart = Value
end)

AimbotSection:CreateSlider("FOV", 10, 400, 150, function(Value)
    Settings.AimFov = Value
end)

AimbotSection:CreateSlider("Smoothness", 1, 20, 3, function(Value)
    Settings.AimSmoothness = Value
end)

AimbotSection:CreateSlider("Shoot Delay", 1, 50, 10, function(Value)
    Settings.ShootDelay = Value / 100
end)

--// ESP Section
local ESPSection = ESPTab:CreateSection("ESP Settings")

ESPSection:CreateToggle("Enable ESP", false, function(Value)
    Settings.ESPEnabled = Value
end)

ESPSection:CreateToggle("Boxes", true, function(Value)
    Settings.ESPBoxes = Value
end)

ESPSection:CreateToggle("Names", true, function(Value)
    Settings.ESPNames = Value
end)

ESPSection:CreateToggle("Health Bar", true, function(Value)
    Settings.ESPHealth = Value
end)

ESPSection:CreateToggle("Tracers", false, function(Value)
    Settings.ESPTracers = Value
end)

ESPSection:CreateToggle("Distance", false, function(Value)
    Settings.ESPDistance = Value
end)

ESPSection:CreateSlider("Max Distance", 100, 5000, 1000, function(Value)
    Settings.ESPMaxDistance = Value
end)

--// Misc Section
local MiscSection = MiscTab:CreateSection("Miscellaneous")

MiscSection:CreateButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

MiscSection:CreateButton("Copy Author", function()
    setclipboard("@aLiNa_grnt")
end)

MiscSection:CreateLabel("Author: @aLiNa_grnt")

--// Delta Exploit Compatibility
if not getgenv then getgenv = function() return _G end end
if not mousemoverel then 
    mousemoverel = function(x, y)
        --// Fallback for exploits without native mousemoverel
        local vim = game:GetService("VirtualInputManager")
        local currentPos = UserInputService:GetMouseLocation()
        vim:SendMouseMoveEvent(currentPos.X + x, currentPos.Y + y, game)
    end 
end
if not mouse1click then
    mouse1click = function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

--// Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// Watermark
Library:CreateWatermark("@aLiNa_grnt | Snipers vs Runners")

--// Notification
Library:Notify({
    Title = "Loaded!",
    Content = "Snipers vs Runners Exploit by @aLiNa_grnt",
    Duration = 5
})

print("╔══════════════════════════════════════╗")
print("║  Snipers vs Runners | @aLiNa_grnt   ║")
print("║  Rafield GUI | Delta Compatible      ║")
print("║  Status: Loaded & Ready              ║")
print("╚══════════════════════════════════════╝")
