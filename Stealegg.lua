--// Egg Game | By:Rostislavv
--// Dark Style Modern GUI
--// Features: ESP Eggs + Anti-Bypass Speed Hack + IMBA

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Dark Style GUI Library (Custom, embedded)
local DarkUI = {}

DarkUI.Colors = {
    Background = Color3.fromRGB(18, 18, 24),
    Surface = Color3.fromRGB(28, 28, 36),
    Primary = Color3.fromRGB(138, 92, 245),
    Secondary = Color3.fromRGB(88, 196, 220),
    Accent = Color3.fromRGB(255, 100, 150),
    Text = Color3.fromRGB(230, 230, 240),
    TextDim = Color3.fromRGB(150, 150, 170),
    Success = Color3.fromRGB(100, 255, 150),
    Danger = Color3.fromRGB(255, 80, 80),
    Border = Color3.fromRGB(40, 40, 55)
}

function DarkUI:Tween(obj, props, duration)
    duration = duration or 0.25
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function DarkUI:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ByRostislavv_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    --// Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.BackgroundColor3 = self.Colors.Background
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -225, 0.5, -275)
    Main.Size = UDim2.new(0, 450, 0, 550)
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    --// Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = Main
    
    --// Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.Colors.Border
    Stroke.Thickness = 1.5
    Stroke.Parent = Main
    
    --// Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = Main
    
    --// Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = self.Colors.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.Parent = Main
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.BackgroundColor3 = self.Colors.Surface
    TitleFix.BorderSizePixel = 0
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.Parent = TitleBar
    
    --// Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Colors.Primary),
        ColorSequenceKeypoint.new(1, self.Colors.Secondary)
    })
    Gradient.Rotation = 45
    Gradient.Parent = TitleBar
    
    --// Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 20, 0, 0)
    TitleText.Size = UDim2.new(0.7, 0, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = title
    TitleText.TextColor3 = self.Colors.Text
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    --// Version/Author
    local AuthorText = Instance.new("TextLabel")
    AuthorText.BackgroundTransparency = 1
    AuthorText.Position = UDim2.new(0.7, 0, 0, 0)
    AuthorText.Size = UDim2.new(0.28, 0, 1, 0)
    AuthorText.Font = Enum.Font.Gotham
    AuthorText.Text = "v2.0"
    AuthorText.TextColor3 = self.Colors.TextDim
    AuthorText.TextSize = 12
    AuthorText.TextXAlignment = Enum.TextXAlignment.Right
    AuthorText.Parent = TitleBar
    
    --// Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = self.Colors.TextDim
    CloseBtn.TextSize = 24
    CloseBtn.Parent = TitleBar
    
    CloseBtn.MouseEnter:Connect(function()
        self:Tween(CloseBtn, {TextColor3 = self.Colors.Danger}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        self:Tween(CloseBtn, {TextColor3 = self.Colors.TextDim}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    --// Content
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 15, 0, 60)
    Content.Size = UDim2.new(1, -30, 1, -70)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = self.Colors.Primary
    Content.Parent = Main
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Content
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    --// Dragging
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,
        Content = Content,
        DarkUI = self
    }
    
    function Window:CreateSection(name)
        local Section = Instance.new("Frame")
        Section.Name = name
        Section.BackgroundColor3 = self.DarkUI.Colors.Surface
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(1, 0, 0, 35)
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.Parent = self.Content
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 12)
        SectionCorner.Parent = Section
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0, 15, 0, 0)
        SectionTitle.Size = UDim2.new(1, -30, 0, 35)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = name
        SectionTitle.TextColor3 = self.DarkUI.Colors.Primary
        SectionTitle.TextSize = 14
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = Section
        
        local SectionContent = Instance.new("Frame")
        SectionContent.Name = "SectionContent"
        SectionContent.BackgroundTransparency = 1
        SectionContent.Position = UDim2.new(0, 15, 0, 40)
        SectionContent.Size = UDim2.new(1, -30, 0, 0)
        SectionContent.AutomaticSize = Enum.AutomaticSize.Y
        SectionContent.Parent = Section
        
        local SectionList = Instance.new("UIListLayout")
        SectionList.Padding = UDim.new(0, 8)
        SectionList.SortOrder = Enum.SortOrder.LayoutOrder
        SectionList.Parent = SectionContent
        
        SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionContent.Size = UDim2.new(1, -30, 0, SectionList.AbsoluteContentSize.Y)
        end)
        
        return SectionContent
    end
    
    function Window:CreateToggle(parent, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
        ToggleFrame.Parent = parent
        
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = self.DarkUI.Colors.Text
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local ToggleBg = Instance.new("Frame")
        ToggleBg.BackgroundColor3 = default and self.DarkUI.Colors.Success or self.DarkUI.Colors.Danger
        ToggleBg.BorderSizePixel = 0
        ToggleBg.Position = UDim2.new(1, -50, 0.5, -12)
        ToggleBg.Size = UDim2.new(0, 44, 0, 24)
        ToggleBg.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleBg
        
        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Position = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
        ToggleCircle.Parent = ToggleBg
        
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = ToggleCircle
        
        local enabled = default
        
        local function updateToggle()
            enabled = not enabled
            local targetColor = enabled and self.DarkUI.Colors.Success or self.DarkUI.Colors.Danger
            local targetPos = enabled and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            
            self.DarkUI:Tween(ToggleBg, {BackgroundColor3 = targetColor}, 0.2)
            self.DarkUI:Tween(ToggleCircle, {Position = targetPos}, 0.2)
            
            if callback then
                callback(enabled)
            end
        end
        
        local clickArea = Instance.new("TextButton")
        clickArea.BackgroundTransparency = 1
        clickArea.Size = UDim2.new(1, 0, 1, 0)
        clickArea.Text = ""
        clickArea.Parent = ToggleFrame
        clickArea.MouseButton1Click:Connect(updateToggle)
        
        return {
            Set = function(val)
                if val ~= enabled then
                    updateToggle()
                end
            end,
            Get = function() return enabled end
        }
    end
    
    function Window:CreateSlider(parent, text, min, max, default, suffix, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.Parent = parent
        
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.5, 0, 0, 22)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = self.DarkUI.Colors.Text
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        ValueLabel.Size = UDim2.new(0.5, 0, 0, 22)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(default) .. (suffix or "")
        ValueLabel.TextColor3 = self.DarkUI.Colors.Primary
        ValueLabel.TextSize = 13
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame
        
        local SliderBg = Instance.new("Frame")
        SliderBg.BackgroundColor3 = self.DarkUI.Colors.Border
        SliderBg.BorderSizePixel = 0
        SliderBg.Position = UDim2.new(0, 0, 0, 32)
        SliderBg.Size = UDim2.new(1, 0, 0, 6)
        SliderBg.Parent = SliderFrame
        
        local SliderBgCorner = Instance.new("UICorner")
        SliderBgCorner.CornerRadius = UDim.new(1, 0)
        SliderBgCorner.Parent = SliderBg
        
        local SliderFill = Instance.new("Frame")
        SliderFill.BackgroundColor3 = self.DarkUI.Colors.Primary
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.Parent = SliderBg
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderKnob = Instance.new("Frame")
        SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderKnob.BorderSizePixel = 0
        SliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        SliderKnob.Size = UDim2.new(0, 16, 0, 16)
        SliderKnob.Parent = SliderBg
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = SliderKnob
        
        local KnobGlow = Instance.new("UIStroke")
        KnobGlow.Color = self.DarkUI.Colors.Primary
        KnobGlow.Thickness = 2
        KnobGlow.Transparency = 0.5
        KnobGlow.Parent = SliderKnob
        
        local dragging = false
        local currentValue = default
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            currentValue = value
            
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
            ValueLabel.Text = tostring(value) .. (suffix or "")
            
            if callback then
                callback(value)
            end
        end
        
        SliderKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateSlider(input)
            end
        end)
        
        return {
            Set = function(val)
                val = math.clamp(val, min, max)
                local pos = (val - min) / (max - min)
                currentValue = val
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
                ValueLabel.Text = tostring(val) .. (suffix or "")
                if callback then callback(val) end
            end,
            Get = function() return currentValue end
        }
    end
    
    function Window:CreateButton(parent, text, color, callback)
        local BtnFrame = Instance.new("Frame")
        BtnFrame.BackgroundTransparency = 1
        BtnFrame.Size = UDim2.new(1, 0, 0, 40)
        BtnFrame.Parent = parent
        
        local Btn = Instance.new("TextButton")
        Btn.BackgroundColor3 = color or self.DarkUI.Colors.Primary
        Btn.BorderSizePixel = 0
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.Font = Enum.Font.GothamBold
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 14
        Btn.Parent = BtnFrame
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 10)
        BtnCorner.Parent = Btn
        
        Btn.MouseEnter:Connect(function()
            self.DarkUI:Tween(Btn, {BackgroundColor3 = color and color:Lerp(Color3.fromRGB(255,255,255), 0.2) or self.DarkUI.Colors.Secondary}, 0.15)
        end)
        Btn.MouseLeave:Connect(function()
            self.DarkUI:Tween(Btn, {BackgroundColor3 = color or self.DarkUI.Colors.Primary}, 0.15)
        end)
        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        return Btn
    end
    
    return Window
end

--// Initialize GUI
local Window = DarkUI:CreateWindow("By:Rostislavv")

--// Settings
local Settings = {
    ESPEnabled = false,
    ESPDistance = 1000,
    
    AntiBypass = false,
    SpeedHack = false,
    SpeedValue = 16,
    
    AutoCollect = false,
    AutoHatch = false
}

--// ESP Objects
local EggESPObjects = {}

--// Anti-Bypass Variables
local FakeCharacter = nil
local RealRoot = nil
local FakeRoot = nil

--// Find Eggs Function
local function FindEggs()
    local eggs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("batch") or name:find("nest") or name:find("incubat") then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

--// Create Egg ESP
local function CreateEggESP(egg)
    if EggESPObjects[egg] then return end
    
    local label = Drawing.new("Text")
    label.Visible = false
    label.Size = 14
    label.Center = true
    label.Outline = true
    label.Color = Color3.fromRGB(255, 215, 0)
    label.Font = Drawing.Fonts.UI
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 215, 0)
    tracer.Transparency = 0.5
    
    EggESPObjects[egg] = {
        Label = label,
        Tracer = tracer
    }
end

--// Update Egg ESP
local function UpdateEggESP()
    for egg, data in pairs(EggESPObjects) do
        if not egg or not egg.Parent or not Settings.ESPEnabled then
            data.Label.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        local pos
        if egg:IsA("Model") then
            local primary = egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("Torso") or egg.PrimaryPart
            if not primary then
                data.Label.Visible = false
                data.Tracer.Visible = false
                continue
            end
            pos = primary.Position
        else
            pos = egg.Position
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then
            data.Label.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        local distance = (pos - Camera.CFrame.Position).Magnitude
        if distance > Settings.ESPDistance then
            data.Label.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        data.Label.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
        data.Label.Text = "🥚 " .. egg.Name .. " [" .. math.floor(distance) .. "m]"
        data.Label.Visible = true
        
        data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        data.Tracer.Visible = true
    end
end

--// Anti-Bypass Speed Hack
local function SetupAntiBypass()
    local character = LocalPlayer.Character
    if not character then return end
    
    RealRoot = character:FindFirstChild("HumanoidRootPart")
    if not RealRoot then return end
    
    --// Create fake character (upper half)
    FakeCharacter = Instance.new("Model")
    FakeCharacter.Name = "FakeCharacter"
    FakeCharacter.Parent = Workspace
    
    --// Clone upper body parts
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:find("Upper") or part.Name:find("Head") or part.Name:find("Arm") or part.Name:find("Torso")) then
            local clone = part:Clone()
            clone.Anchored = false
            clone.CanCollide = false
            clone.Parent = FakeCharacter
            
            local weld = Instance.new("Weld")
            weld.Part0 = part
            weld.Part1 = clone
            weld.Parent = clone
        end
    end
    
    --// Create fake root for client movement
    FakeRoot = Instance.new("Part")
    FakeRoot.Name = "FakeHumanoidRootPart"
    FakeRoot.Size = RealRoot.Size
    FakeRoot.CFrame = RealRoot.CFrame
    FakeRoot.Anchored = false
    FakeRoot.CanCollide = false
    FakeRoot.Transparency = 1
    FakeRoot.Parent = FakeCharacter
    
    --// Weld fake root to real root initially
    local rootWeld = Instance.new("Weld")
    rootWeld.Part0 = RealRoot
    rootWeld.Part1 = FakeRoot
    rootWeld.Parent = FakeRoot
    
    --// Notification
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "ByRostislavv_Notif"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = CoreGui
    
    local notifFrame = Instance.new("Frame")
    notifFrame.BackgroundColor3 = DarkUI.Colors.Surface
    notifFrame.BorderSizePixel = 0
    notifFrame.Position = UDim2.new(1, -340, 1, -90)
    notifFrame.Size = UDim2.new(0, 320, 0, 70)
    notifFrame.Parent = notifGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 16)
    notifCorner.Parent = notifFrame
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = DarkUI.Colors.Success
    notifStroke.Thickness = 1.5
    notifStroke.Parent = notifFrame
    
    local notifText = Instance.new("TextLabel")
    notifText.BackgroundTransparency = 1
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.Font = Enum.Font.GothamBold
    notifText.Text = "By:Rostislavv\nAnti-Bypass activated!"
    notifText.TextColor3 = DarkUI.Colors.Text
    notifText.TextSize = 14
    notifText.Parent = notifFrame
    
    task.delay(4, function()
        DarkUI:Tween(notifFrame, {Position = UDim2.new(1, 20, 1, -90)}, 0.5)
        task.wait(0.6)
        notifGui:Destroy()
    end)
end

--// Speed Hack with Anti-Bypass
local function UpdateSpeedHack()
    if not Settings.AntiBypass or not Settings.SpeedHack then return end
    if not FakeRoot or not RealRoot then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    --// Calculate movement direction
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + Camera.CFrame.RightVector
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit * Settings.SpeedValue
        
        --// Move fake root (client-side visual)
        FakeRoot.CFrame = FakeRoot.CFrame + Vector3.new(moveDirection.X, 0, moveDirection.Z) * 0.016
        
        --// Teleport real root to fake root periodically (bypass server check)
        if math.random(1, 10) == 1 then
            RealRoot.CFrame = CFrame.new(FakeRoot.Position.X, RealRoot.Position.Y, FakeRoot.Position.Z)
        end
    end
    
    --// Keep fake root at same height as real root
    FakeRoot.CFrame = CFrame.new(FakeRoot.Position.X, RealRoot.Position.Y, FakeRoot.Position.Z)
end

--// Auto Collect Eggs
local function AutoCollect()
    if not Settings.AutoCollect then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if obj.Parent and obj.Parent.Name:lower():find("egg") then
                local dist = (obj.Parent.Position - hrp.Position).Magnitude
                if dist < 20 then
                    fireproximityprompt(obj)
                end
            end
        end
    end
end

--// Auto Hatch Eggs
local function AutoHatch()
    if not Settings.AutoHatch then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if obj.Parent and (obj.Parent.Name:lower():find("hatch") or obj.Parent.Name:lower():find("incubat")) then
                fireproximityprompt(obj)
            end
        end
    end
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    --// ESP
    if Settings.ESPEnabled then
        UpdateEggESP()
    else
        for _, data in pairs(EggESPObjects) do
            data.Label.Visible = false
            data.Tracer.Visible = false
        end
    end
    
    --// Speed Hack
    UpdateSpeedHack()
    
    --// Auto Collect
    AutoCollect()
    
    --// Auto Hatch
    AutoHatch()
end)

--// Scan for eggs periodically
task.spawn(function()
    while true do
        if Settings.ESPEnabled then
            local eggs = FindEggs()
            for _, egg in ipairs(eggs) do
                CreateEggESP(egg)
            end
        end
        task.wait(2)
    end
end)

--// ==================== GUI ELEMENTS ====================

--// ESP Section
local ESPSection = Window:CreateSection("🥚 Egg ESP")

ESPSection:CreateToggle("Enable Egg ESP", false, function(Value)
    Settings.ESPEnabled = Value
    if Value then
        local eggs = FindEggs()
        for _, egg in ipairs(eggs) do
            CreateEggESP(egg)
        end
    end
end)

ESPSection:CreateSlider("ESP Distance", 100, 5000, 1000, "m", function(Value)
    Settings.ESPDistance = Value
end)

--// Anti-Bypass Section
local BypassSection = Window:CreateSection("🛡️ Anti-Bypass")

BypassSection:CreateButton("Activate Anti-Bypass", DarkUI.Colors.Danger, function()
    Settings.AntiBypass = true
    SetupAntiBypass()
end)

BypassSection:CreateToggle("Enable Speed Hack", false, function(Value)
    Settings.SpeedHack = Value
end)

BypassSection:CreateSlider("Speed Value", 10, 1000, 50, "", function(Value)
    Settings.SpeedValue = Value
end)

--// Auto Section
local AutoSection = Window:CreateSection("🤖 Automation")

AutoSection:CreateToggle("Auto-Collect Eggs", false, function(Value)
    Settings.AutoCollect = Value
end)

AutoSection:CreateToggle("Auto-Hatch", false, function(Value)
    Settings.AutoHatch = Value
end)

--// Misc Section
local MiscSection = Window:CreateSection("⚡ Misc")

MiscSection:CreateButton("Teleport to Nearest Egg", DarkUI.Colors.Secondary, function()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            if obj.Name:lower():find("egg") then
                local pos
                if obj:IsA("Model") then
                    local primary = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                    if primary then
                        pos = primary.Position
                    end
                else
                    pos = obj.Position
                end
                
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = pos
                    end
                end
            end
        end
    end
    
    if nearest then
        hrp.CFrame = CFrame.new(nearest + Vector3.new(0, 5, 0))
        
        --// Notification
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ByRostislavv_Teleport"

      
