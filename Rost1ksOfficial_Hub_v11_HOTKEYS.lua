-- ============================================
-- ROST1KSOFFICIAL HUB v11.0 | BUILD A BASE AND STEAL
-- FULL SCRIPT | HOTKEYS FOR MOBILE | CUSTOM BUTTONS
-- ANTI-BAN | ANTI-DETECT | MOBILE OPTIMIZED
-- By: Rost1ksOfficial
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CHARACTER MANAGER
-- ============================================
local CharacterManager = {}
CharacterManager.CurrentChar = nil
CharacterManager.CurrentHum = nil
CharacterManager.CurrentHRP = nil
CharacterManager.Connections = {}
CharacterManager.Objects = {}

function CharacterManager:Init()
    self:Cleanup()
    self.CurrentChar = LocalPlayer.Character
    if not self.CurrentChar then
        self.CurrentChar = LocalPlayer.CharacterAdded:Wait()
    end
    self.CurrentHum = self.CurrentChar:WaitForChild("Humanoid", 5)
    self.CurrentHRP = self.CurrentChar:WaitForChild("HumanoidRootPart", 5)
end

function CharacterManager:Cleanup()
    for name, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}

    for _, obj in pairs(self.Objects) do
        pcall(function() obj:Destroy() end)
    end
    self.Objects = {}

    if self.CurrentChar then
        for _, part in pairs(self.CurrentChar:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() PhysicsService:SetPartCollisionGroup(part, "Default") end)
            end
        end
    end

    if self.CurrentHum then
        pcall(function()
            self.CurrentHum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            self.CurrentHum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            self.CurrentHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            self.CurrentHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            self.CurrentHum.WalkSpeed = 16
            self.CurrentHum.JumpPower = 50
        end)
    end
end

function CharacterManager:StoreConnection(name, conn)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
    end
    self.Connections[name] = conn
end

function CharacterManager:StoreObject(obj)
    table.insert(self.Objects, obj)
    return obj
end

-- ============================================
-- ANTI-DETECT (single heartbeat)
-- ============================================
local AntiDetect = {}
AntiDetect.MainLoop = nil
AntiDetect.State = {
    GodMode = false,
    AntiKnockback = false,
    GhostMode = false,
    SpeedHack = false,
    Noclip = false,
    Fly = false,
    ESP = false,
    AutoSteal = false,
    AutoCollect = false,
    WalkSpeed = 16,
    FlySpeed = 30,
    StealRange = 30,
    CollectRange = 50,
}

function AntiDetect:Init()
    self:StopLoop()
    self.MainLoop = RunService.Heartbeat:Connect(function(dt)
        self:Update(dt)
    end)
end

function AntiDetect:StopLoop()
    if self.MainLoop then
        pcall(function() self.MainLoop:Disconnect() end)
        self.MainLoop = nil
    end
end

function AntiDetect:Update(dt)
    local char = CharacterManager.CurrentChar
    local hum = CharacterManager.CurrentHum
    local hrp = CharacterManager.CurrentHRP
    if not char or not hum or not hrp then return end

    if self.State.GodMode and hum.Health < hum.MaxHealth then
        hum.Health = hum.MaxHealth
    end

    if self.State.AntiKnockback then
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 80 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end

    if self.State.SpeedHack and hum.MoveDirection.Magnitude > 0 then
        local targetVel = hum.MoveDirection * self.State.WalkSpeed
        local currentVel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
    end

    if self.State.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() PhysicsService:SetPartCollisionGroup(part, "Rost1ksNoclip") end)
            end
        end
    end

    if self.State.GhostMode then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                part.Transparency = 1
            end
        end
    end
end

-- ============================================
-- FLY MODULE
-- ============================================
local FlyModule = {}
FlyModule.LinearVel = nil
FlyModule.AlignOrient = nil

function FlyModule:Enable(speed)
    local hrp = CharacterManager.CurrentHRP
    if not hrp then return end
    self:Disable()

    self.AlignOrient = CharacterManager:StoreObject(Instance.new("AlignOrientation"))
    self.AlignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
    self.AlignOrient.MaxTorque = 9e9
    self.AlignOrient.Responsiveness = 50
    self.AlignOrient.Parent = hrp

    self.LinearVel = CharacterManager:StoreObject(Instance.new("LinearVelocity"))
    self.LinearVel.MaxForce = 9e9
    self.LinearVel.VectorVelocity = Vector3.new(0, 0, 0)
    self.LinearVel.Parent = hrp

    CharacterManager:StoreConnection("FlyUpdate", RunService.RenderStepped:Connect(function()
        if not self.LinearVel or not self.AlignOrient then return end
        local camera = Workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 0.5, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 0.5, 0) end
        self.LinearVel.VectorVelocity = moveDir * speed
        self.AlignOrient.CFrame = camera.CFrame
    end))
end

function FlyModule:Disable()
    if self.LinearVel then pcall(function() self.LinearVel:Destroy() end) self.LinearVel = nil end
    if self.AlignOrient then pcall(function() self.AlignOrient:Destroy() end) self.AlignOrient = nil end
end

-- ============================================
-- ESP MODULE (Highlight)
-- ============================================
local ESPModule = {}
ESPModule.Highlights = {}

function ESPModule:Enable()
    self:Disable()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then self:CreateHighlight(player) end
    end
    CharacterManager:StoreConnection("ESPPlayerAdded", Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        if AntiDetect.State.ESP then self:CreateHighlight(player) end
    end))
end

function ESPModule:CreateHighlight(player)
    if self.Highlights[player] then return end
    local function setup()
        if not player.Character then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_HL"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 80)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = player.Character
        self.Highlights[player] = highlight
    end
    setup()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if AntiDetect.State.ESP then setup() end
    end)
end

function ESPModule:Disable()
    for player, highlight in pairs(self.Highlights) do
        pcall(function() highlight:Destroy() end)
    end
    self.Highlights = {}
end

-- ============================================
-- STEAL MODULE
-- ============================================
local StealModule = {}
StealModule.CurrentTween = nil

function StealModule:Enable(range)
    CharacterManager:StoreConnection("AutoSteal", task.spawn(function()
        while AntiDetect.State.AutoSteal do
            local myHRP = CharacterManager.CurrentHRP
            if not myHRP then task.wait(1) continue end
            local closest = nil
            local closestDist = range
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (myHRP.Position - hrp.Position).Magnitude
                        if dist < closestDist then closest = player closestDist = dist end
                    end
                end
            end
            if closest and closest.Character then
                local targetHRP = closest.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local targetPos = targetHRP.Position + (myHRP.Position - targetHRP.Position).Unit * 5
                    local tween = TweenService:Create(myHRP, TweenInfo.new(closestDist / 50, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                    tween:Play()
                    tween.Completed:Wait()
                    for _, v in pairs(closest.Character:GetDescendants()) do
                        if v:IsA("ClickDetector") then pcall(function() fireclickdetector(v) end) end
                        if v:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(v) end) end
                    end
                end
            end
            task.wait(0.5)
        end
    end))
end

function StealModule:Disable()
    if self.CurrentTween then pcall(function() self.CurrentTween:Cancel() end) self.CurrentTween = nil end
end

-- ============================================
-- COLLECT MODULE
-- ============================================
local CollectModule = {}

function CollectModule:Enable(range)
    CharacterManager:StoreConnection("AutoCollect", task.spawn(function()
        while AntiDetect.State.AutoCollect do
            local myHRP = CharacterManager.CurrentHRP
            if not myHRP then task.wait(1) continue end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not AntiDetect.State.AutoCollect then break end
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    local name = obj.Name:lower()
                    if name:find("money") or name:find("cash") or name:find("coin") or name:find("pet") then
                        local dist = (myHRP.Position - obj.Position).Magnitude
                        if dist <= range then
                            local tween = TweenService:Create(myHRP, TweenInfo.new(dist / 50, Enum.EasingStyle.Linear), {CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))})
                            tween:Play()
                            tween.Completed:Wait()
                            if dist < 8 then
                                pcall(function()
                                    firetouchinterest(myHRP, obj, 0)
                                    task.wait(0.1)
                                    firetouchinterest(myHRP, obj, 1)
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end))
end

-- ============================================
-- HOTKEYS MODULE FOR MOBILE
-- ============================================
local Hotkeys = {}
Hotkeys.ScreenGui = nil
Hotkeys.Container = nil
Hotkeys.Panel = nil
Hotkeys.Buttons = {}
Hotkeys.Config = {
    ButtonSize = 75,
    ButtonSpacing = 8,
    StartPosition = UDim2.new(0, 10, 0.3, 0),
    BackgroundColor = Color3.fromRGB(15, 15, 30),
    ActiveColor = Color3.fromRGB(0, 220, 100),
    InactiveColor = Color3.fromRGB(220, 60, 60),
    TextColor = Color3.fromRGB(255, 255, 255),
    BorderColor = Color3.fromRGB(120, 120, 200),
    CornerRadius = 18,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
}

function Hotkeys:Init()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Rost1ksHotkeys"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game.CoreGui

    self.Container = Instance.new("Frame")
    self.Container.Name = "HotkeyContainer"
    self.Container.Size = UDim2.new(0, self.Config.ButtonSize + 20, 0, 600)
    self.Container.Position = self.Config.StartPosition
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.ScreenGui

    self.Panel = Instance.new("Frame")
    self.Panel.Name = "Panel"
    self.Panel.Size = UDim2.new(1, 0, 1, 0)
    self.Panel.BackgroundColor3 = self.Config.BackgroundColor
    self.Panel.BackgroundTransparency = 0.2
    self.Panel.BorderSizePixel = 0
    self.Panel.Parent = self.Container

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
    panelCorner.Parent = self.Panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = self.Config.BorderColor
    panelStroke.Thickness = 2
    panelStroke.Parent = self.Panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, self.Config.ButtonSpacing)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = self.Container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = self.Container

    self:MakeDraggable(self.Container)
    self:CreateCollapseButton()

    -- Title label
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.Text = "HOTKEYS"
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = self.Container

    return self
end

function Hotkeys:CreateButton(id, label, toggleCallback, isToggle)
    local btnFrame = Instance.new("Frame")
    btnFrame.Name = id .. "_Frame"
    btnFrame.Size = UDim2.new(0, self.Config.ButtonSize, 0, self.Config.ButtonSize)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = self.Container

    local btn = Instance.new("TextButton")
    btn.Name = id
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = self.Config.InactiveColor
    btn.TextColor3 = self.Config.TextColor
    btn.Text = label
    btn.TextSize = self.Config.TextSize
    btn.Font = self.Config.Font
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = btnFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Config.BorderColor
    stroke.Thickness = 1
    stroke.Parent = btn

    -- Press effect
    local function setPressed(pressed)
        if pressed then
            btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            local isActive = btn:GetAttribute("Active") or false
            btn.BackgroundColor3 = isActive and self.Config.ActiveColor or self.Config.InactiveColor
            btn.TextColor3 = self.Config.TextColor
        end
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setPressed(true)
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isToggle then
                local isActive = not (btn:GetAttribute("Active") or false)
                btn:SetAttribute("Active", isActive)
                setPressed(false)
                if toggleCallback then toggleCallback(isActive) end
            else
                setPressed(false)
                if toggleCallback then toggleCallback() end
            end
        end
    end)

    table.insert(self.Buttons, {Frame = btnFrame, Button = btn, ID = id})
    return btn
end

function Hotkeys:SetButtonState(id, isActive)
    for _, b in pairs(self.Buttons) do
        if b.ID == id then
            b.Button:SetAttribute("Active", isActive)
            b.Button.BackgroundColor3 = isActive and self.Config.ActiveColor or self.Config.InactiveColor
        end
    end
end

function Hotkeys:CreateCollapseButton()
    local btn = Instance.new("TextButton")
    btn.Name = "CollapseBtn"
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = UDim2.new(1, -35, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "−"
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = self.Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local collapsed = false
    btn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        for _, b in pairs(self.Buttons) do
            b.Frame.Visible = not collapsed
        end
        btn.Text = collapsed and "+" or "−"
        self.Panel.Size = collapsed and UDim2.new(1, 0, 0, 40) or UDim2.new(1, 0, 1, 0)
    end)

    return btn
end

function Hotkeys:MakeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================
-- GROQ AI
-- ============================================
local GroqModule = {}
GroqModule.Config = {
    APIKey = "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",
    Model = "openai/gpt-oss-20b",
    URL = "https://api.groq.com/openai/v1/chat/completions",
    Enabled = true
}

function GroqModule:Call(message)
    if not self.Config.Enabled then return nil end
    local payload = HttpService:JSONEncode({
        model = self.Config.Model,
        messages = {
            {role = "system", content = "You analyze Roblox games for security research. Respond with concise technical analysis."},
            {role = "user", content = message}
        },
        temperature = 0.2,
        max_tokens = 1000
    })
    local success, response = pcall(function()
        return game:HttpPost(self.Config.URL, payload, false, {
            ["Authorization"] = "Bearer " .. self.Config.APIKey,
            ["Content-Type"] = "application/json"
        })
    end)
    if success and response then
        local data = HttpService:JSONDecode(response)
        if data.choices and data.choices[1] then
            return data.choices[1].message.content
        end
    end
    return nil
end

-- ============================================
-- RAYFIELD GUI
-- ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rost1ksOfficial Hub v11.0 | HOTKEYS",
    LoadingTitle = "Rost1ksOfficial",
    LoadingSubtitle = "Hotkeys + Anti-Ban loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Rost1ksOfficial_v11",
        FileName = "BBaseSteal_v11"
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local GhostTab = Window:CreateTab("Ghost", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local HotkeysTab = Window:CreateTab("Hotkeys", 4483362458)
local AITab = Window:CreateTab("Groq AI", 4483362458)

-- Setup collision group
pcall(function()
    PhysicsService:CreateCollisionGroup("Rost1ksNoclip")
    PhysicsService:CollisionGroupSetCollides("Rost1ksNoclip", "Default", false)
end)

-- ============================================
-- HOTKEYS SETUP
-- ============================================
Hotkeys:Init()

-- Toggle buttons (tap to toggle ON/OFF)
Hotkeys:CreateButton("Speed", "SPD", function(active)
    AntiDetect.State.SpeedHack = active
    if not active then
        local hum = CharacterManager.CurrentHum
        if hum then hum.WalkSpeed = 16 end
    end
end, true)

Hotkeys:CreateButton("Noclip", "NCP", function(active)
    AntiDetect.State.Noclip = active
    if not active then
        local char = CharacterManager.CurrentChar
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() PhysicsService:SetPartCollisionGroup(part, "Default") end)
                end
            end
        end
    end
end, true)

Hotkeys:CreateButton("Fly", "FLY", function(active)
    AntiDetect.State.Fly = active
    if active then FlyModule:Enable(AntiDetect.State.FlySpeed)
    else FlyModule:Disable() end
end, true)

Hotkeys:CreateButton("Ghost", "GST", function(active)
    AntiDetect.State.GhostMode = active
end, true)

Hotkeys:CreateButton("God", "GOD", function(active)
    AntiDetect.State.GodMode = active
end, true)

Hotkeys:CreateButton("AntiKB", "AKB", function(active)
    AntiDetect.State.AntiKnockback = active
end, true)

Hotkeys:CreateButton("ESP", "ESP", function(active)
    AntiDetect.State.ESP = active
    if active then ESPModule:Enable() else ESPModule:Disable() end
end, true)

Hotkeys:CreateButton("Steal", "STL", function(active)
    AntiDetect.State.AutoSteal = active
    if active then StealModule:Enable(AntiDetect.State.StealRange)
    else StealModule:Disable() end
end, true)

Hotkeys:CreateButton("Collect", "COL", function(active)
    AntiDetect.State.AutoCollect = active
    if active then CollectModule:Enable(AntiDetect.State.CollectRange) end
end, true)

-- Action buttons (tap once = action)
Hotkeys:CreateButton("TP_Random", "TP", function()
    local plrs = Players:GetPlayers()
    if #plrs > 1 then
        local target = plrs[math.random(1, #plrs)]
        if target ~= LocalPlayer and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = CharacterManager.CurrentHRP
            if hrp and myHRP then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                local tween = TweenService:Create(myHRP, TweenInfo.new(dist / 50, Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 0))
                })
                tween:Play()
            end
        end
    end
end, false)

Hotkeys:CreateButton("STOP", "STOP", function()
    AntiDetect.State.GodMode = false
    AntiDetect.State.AntiKnockback = false
    AntiDetect.State.GhostMode = false
    AntiDetect.State.SpeedHack = false
    AntiDetect.State.Noclip = false
    AntiDetect.State.Fly = false
    AntiDetect.State.ESP = false
    AntiDetect.State.AutoSteal = false
    AntiDetect.State.AutoCollect = false

    FlyModule:Disable()
    StealModule:Disable()
    ESPModule:Disable()
    CharacterManager:Cleanup()

    -- Reset all hotkey buttons
    for _, b in pairs(Hotkeys.Buttons) do
        if b.Button:GetAttribute("Active") ~= nil then
            b.Button:SetAttribute("Active", false)
            b.Button.BackgroundColor3 = Hotkeys.Config.InactiveColor
        end
    end

    Rayfield:Notify({Title="EMERGENCY", Content="All stopped!", Duration=3})
end, false)

-- ============================================
-- GUI CALLBACKS (sync with hotkeys)
-- ============================================

local function syncHotkey(id, state)
    Hotkeys:SetButtonState(id, state)
end

MainTab:CreateToggle({
    Name = "Auto Steal (Tween)",
    CurrentValue = false,
    Flag = "AutoSteal_v11",
    Callback = function(v)
        AntiDetect.State.AutoSteal = v
        syncHotkey("Steal", v)
        if v then StealModule:Enable(AntiDetect.State.StealRange) else StealModule:Disable() end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Collect (Tween)",
    CurrentValue = false,
    Flag = "AutoCollect_v11",
    Callback = function(v)
        AntiDetect.State.AutoCollect = v
        syncHotkey("Collect", v)
        if v then CollectModule:Enable(AntiDetect.State.CollectRange) end
    end,
})

MainTab:CreateSlider({
    Name = "Steal Range",
    Range = {10, 100},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 30,
    Flag = "StealRange_v11",
    Callback = function(v) AntiDetect.State.StealRange = v end,
})

PlayerTab:CreateToggle({
    Name = "Speed Hack (Safe)",
    CurrentValue = false,
    Flag = "SpeedHack_v11",
    Callback = function(v)
        AntiDetect.State.SpeedHack = v
        syncHotkey("Speed", v)
        if not v then
            local hum = CharacterManager.CurrentHum
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 120},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "WalkSpeed_v11",
    Callback = function(v) AntiDetect.State.WalkSpeed = v end,
})

PlayerTab:CreateToggle({
    Name = "Noclip (Collision Groups)",
    CurrentValue = false,
    Flag = "Noclip_v11",
    Callback = function(v)
        AntiDetect.State.Noclip = v
        syncHotkey("Noclip", v)
        if not v then
            local char = CharacterManager.CurrentChar
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() PhysicsService:SetPartCollisionGroup(part, "Default") end)
                    end
                end
            end
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Fly (LinearVelocity)",
    CurrentValue = false,
    Flag = "Fly_v11",
    Callback = function(v)
        AntiDetect.State.Fly = v
        syncHotkey("Fly", v)
        if v then FlyModule:Enable(AntiDetect.State.FlySpeed)
        else FlyModule:Disable() end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 100},
    Increment = 5,
    Suffix = "",
    CurrentValue = 30,
    Flag = "FlySpeed_v11",
    Callback = function(v) AntiDetect.State.FlySpeed = v end,
})

GhostTab:CreateToggle({
    Name = "Ghost Mode",
    CurrentValue = false,
    Flag = "GhostMode_v11",
    Callback = function(v)
        AntiDetect.State.GhostMode = v
        syncHotkey("Ghost", v)
    end,
})

GhostTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode_v11",
    Callback = function(v)
        AntiDetect.State.GodMode = v
        syncHotkey("God", v)
    end,
})

GhostTab:CreateToggle({
    Name = "Anti Knockback",
    CurrentValue = false,
    Flag = "AntiKnockback_v11",
    Callback = function(v)
        AntiDetect.State.AntiKnockback = v
        syncHotkey("AntiKB", v)
    end,
})

VisualTab:CreateToggle({
    Name = "Player ESP (Highlight)",
    CurrentValue = false,
    Flag = "ESP_v11",
    Callback = function(v)
        AntiDetect.State.ESP = v
        syncHotkey("ESP", v)
        if v then ESPModule:Enable() else ESPModule:Disable() end
    end,
})

TeleportTab:CreateButton({
    Name = "Safe Teleport to Random Player",
    Callback = function()
        local plrs = Players:GetPlayers()
        if #plrs > 1 then
            local target = plrs[math.random(1, #plrs)]
            if target ~= LocalPlayer and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = CharacterManager.CurrentHRP
                if hrp and myHRP then
                    local dist = (hrp.Position - myHRP.Position).Magnitude
                    local tween = TweenService:Create(myHRP, TweenInfo.new(dist / 50, Enum.EasingStyle.Linear), {
                        CFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 0))
                    })
                    tween:Play()
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Emergency Stop All",
    Callback = function()
        AntiDetect.State.GodMode = false
        AntiDetect.State.AntiKnockback = false
        AntiDetect.State.GhostMode = false
        AntiDetect.State.SpeedHack = false
        AntiDetect.State.Noclip = false
        AntiDetect.State.Fly = false
        AntiDetect.State.ESP = false
        AntiDetect.State.AutoSteal = false
        AntiDetect.State.AutoCollect = false

        FlyModule:Disable()
        StealModule:Disable()
        ESPModule:Disable()
        CharacterManager:Cleanup()

        for _, b in pairs(Hotkeys.Buttons) do
            if b.Button:GetAttribute("Active") ~= nil then
                b.Button:SetAttribute("Active", false)
                b.Button.BackgroundColor3 = Hotkeys.Config.InactiveColor
            end
        end

        Rayfield:Notify({Title="EMERGENCY", Content="All stopped!", Duration=3})
    end,
})

-- Hotkeys Tab in Rayfield
HotkeysTab:CreateLabel("Mobile Hotkeys are on the left side of screen")
HotkeysTab:CreateLabel("Tap to toggle ON/OFF")
HotkeysTab:CreateLabel("Drag the panel to move it")
HotkeysTab:CreateLabel("Use − button to collapse/expand")

HotkeysTab:CreateButton({
    Name = "Reset Hotkeys Position",
    Callback = function()
        Hotkeys.Container.Position = Hotkeys.Config.StartPosition
    end,
})

HotkeysTab:CreateSlider({
    Name = "Button Size",
    Range = {50, 100},
    Increment = 5,
    Suffix = " px",
    CurrentValue = 75,
    Flag = "HotkeySize_v11",
    Callback = function(v)
        Hotkeys.Config.ButtonSize = v
        for _, b in pairs(Hotkeys.Buttons) do
            b.Frame.Size = UDim2.new(0, v, 0, v)
        end
    end,
})

AITab:CreateToggle({
    Name = "Groq AI Enabled",
    CurrentValue = true,
    Flag = "GroqEnabled_v11",
    Callback = function(v) GroqModule.Config.Enabled = v end,
})

AITab:CreateButton({
    Name = "Deep Game Analysis",
    Callback = function()
        Rayfield:Notify({Title="Groq AI", Content="Analyzing...", Duration=2})
        task.spawn(function()
            local remotes = {}
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") then table.insert(remotes, obj.Name) end
            end
            local prompt = string.format("Analyze Roblox game. Remotes: %s. Player: %s. Speed: %d. Return JSON with ac_level, safe_speed, position_remotes, damage_remotes, recommended_method.", table.concat(remotes, ", "), tostring(CharacterManager.CurrentHRP and CharacterManager.CurrentHRP.Position or "unknown"), AntiDetect.State.WalkSpeed)
            local result = GroqModule:Call(prompt)
            if result then
                Rayfield:Notify({Title="AI Analysis", Content=result:sub(1, 100), Duration=5})
                print("AI Result:", result)
            else
                Rayfield:Notify({Title="AI", Content="Failed. Check console.", Duration=3})
            end
        end)
    end,
})

-- ============================================
-- CHARACTER HANDLER
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(char)
    CharacterManager:Init()
    AntiDetect:Init()
    if AntiDetect.State.ESP then ESPModule:Enable() end
    if AntiDetect.State.Fly then FlyModule:Enable(AntiDetect.State.FlySpeed) end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Init
CharacterManager:Init()
AntiDetect:Init()

Rayfield:Notify({
    Title = "Rost1ksOfficial Hub v11.0",
    Content = "HOTKEYS + Anti-Ban loaded! Tap buttons on left. By: Rost1ksOfficial",
    Duration = 5,
})

print([[
========================================
  ROST1KSOFFICIAL HUB v11.0
  HOTKEYS FOR MOBILE | ANTI-BAN

  Hotkeys (left side, tap to toggle):
  SPD = Speed | NCP = Noclip | FLY = Fly
  GST = Ghost | GOD = God | AKB = Anti-KB
  ESP = ESP | STL = Steal | COL = Collect
  TP = Teleport | STOP = Emergency Stop

  Features:
  • Tap buttons = toggle ON/OFF
  • Drag panel = move
  • − button = collapse
  • Sync with Rayfield GUI
  • Anti-ban methods

  By: Rost1ksOfficial
========================================
]])
