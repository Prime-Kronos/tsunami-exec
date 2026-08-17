--// Snipers vs Runners | Full Exploit Suite
--// Author: @aLiNa_grnt
--// Library: Rafield GUI
--// Features: Aimbot, Auto-Shot, ESP, Delta Exploit Optimized

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Rafield GUI Library (Embedded for standalone execution)
local Rafield = {}

--// Color Palette
Rafield.Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(180, 130, 220),
    Secondary = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(230, 230, 240),
    DarkText = Color3.fromRGB(150, 150, 170),
    ToggleOn = Color3.fromRGB(130, 220, 150),
    ToggleOff = Color3.fromRGB(220, 80, 80),
    Border = Color3.fromRGB(40, 40, 55)
}

--// Utility Functions
function Rafield:Tween(obj, props, duration)
    duration = duration or 0.3
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function Rafield:CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = parent
    return shadow
end

function Rafield:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// Main Window Creation
function Rafield:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Rafield_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    --// Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = self.Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    MainFrame.Size = UDim2.new(0, 400, 0, 450)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    --// Corner Radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    --// Shadow
    self:CreateShadow(MainFrame)
    
    --// Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.Colors.Border
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame
    
    --// Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = self.Colors.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.BackgroundColor3 = self.Colors.Secondary
    TitleFix.BorderSizePixel = 0
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.Parent = TitleBar
    
    --// Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(0.7, 0, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = title
    TitleText.TextColor3 = self.Colors.Text
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    --// Author Label
    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Name = "Author"
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Position = UDim2.new(0.7, 0, 0, 0)
    AuthorLabel.Size = UDim2.new(0.28, 0, 1, 0)
    AuthorLabel.Font = Enum.Font.Gotham
    AuthorLabel.Text = "@aLiNa_grnt"
    AuthorLabel.TextColor3 = self.Colors.Accent
    AuthorLabel.TextSize = 11
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Right
    AuthorLabel.Parent = TitleBar
    
    --// Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = self.Colors.DarkText
    CloseBtn.TextSize = 18
    CloseBtn.Parent = TitleBar
    
    CloseBtn.MouseEnter:Connect(function()
        self:Tween(CloseBtn, {TextColor3 = self.Colors.ToggleOff}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        self:Tween(CloseBtn, {TextColor3 = self.Colors.DarkText}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    --// Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "Minimize"
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -55, 0, 5)
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "−"
    MinBtn.TextColor3 = self.Colors.DarkText
    MinBtn.TextSize = 18
    MinBtn.Parent = TitleBar
    
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            self:Tween(MainFrame, {Size = UDim2.new(0, 400, 0, 35)}, 0.3)
            MinBtn.Text = "+"
        else
            self:Tween(MainFrame, {Size = UDim2.new(0, 400, 0, 450)}, 0.3)
            MinBtn.Text = "−"
        end
    end)
    
    --// Content Frame
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.Size = UDim2.new(1, -20, 1, -55)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = self.Colors.Accent
    Content.Parent = MainFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Content
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    --// Dragging
    self:MakeDraggable(MainFrame, TitleBar)
    
    --// Window Object
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Content = Content,
        Rafield = self
    }
    
    function Window:CreateSection(name)
        local Section = Instance.new("Frame")
        Section.Name = name
        Section.BackgroundColor3 = self.Rafield.Colors.Secondary
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(1, 0, 0, 30)
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.Parent = self.Content
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = Section
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0, 10, 0, 0)
        SectionTitle.Size = UDim2.new(1, -20, 0, 30)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = name
        SectionTitle.TextColor3 = self.Rafield.Colors.Accent
        SectionTitle.TextSize = 13
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = Section
        
        local SectionContent = Instance.new("Frame")
        SectionContent.Name = "SectionContent"
        SectionContent.BackgroundTransparency = 1
        SectionContent.Position = UDim2.new(0, 10, 0, 35)
        SectionContent.Size = UDim2.new(1, -20, 0, 0)
        SectionContent.AutomaticSize = Enum.AutomaticSize.Y
        SectionContent.Parent = Section
        
        local SectionList = Instance.new("UIListLayout")
        SectionList.Padding = UDim.new(0, 6)
        SectionList.SortOrder = Enum.SortOrder.LayoutOrder
        SectionList.Parent = SectionContent
        
        SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionContent.Size = UDim2.new(1, -20, 0, SectionList.AbsoluteContentSize.Y)
        end)
        
        return SectionContent
    end
    
    function Window:CreateToggle(parent, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(1, 0, 0, 28)
        ToggleFrame.Parent = parent
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.BackgroundTransparency = 1
        ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
        ToggleBtn.Text = ""
        ToggleBtn.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = self.Rafield.Colors.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local ToggleBg = Instance.new("Frame")
        ToggleBg.BackgroundColor3 = default and self.Rafield.Colors.ToggleOn or self.Rafield.Colors.ToggleOff
        ToggleBg.BorderSizePixel = 0
        ToggleBg.Position = UDim2.new(1, -40, 0.5, -10)
        ToggleBg.Size = UDim2.new(0, 36, 0, 20)
        ToggleBg.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleBg
        
        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
        ToggleCircle.Parent = ToggleBg
        
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = ToggleCircle
        
        local enabled = default
        
        local function updateToggle()
            enabled = not enabled
            local targetColor = enabled and self.Rafield.Colors.ToggleOn or self.Rafield.Colors.ToggleOff
            local targetPos = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            
            self.Rafield:Tween(ToggleBg, {BackgroundColor3 = targetColor}, 0.2)
            self.Rafield:Tween(ToggleCircle, {Position = targetPos}, 0.2)
            
            if callback then
                callback(enabled)
            end
        end
        
        ToggleBtn.MouseButton1Click:Connect(updateToggle)
        
        return {
            Set = function(val)
                if val ~= enabled then
                    updateToggle()
                end
            end,
            Get = function() return enabled end
        }
    end
    
    function Window:CreateSlider(parent, text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Size = UDim2.new(1, 0, 0, 45)
        SliderFrame.Parent = parent
        
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.6, 0, 0, 20)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = self.Rafield.Colors.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
        ValueLabel.Size = UDim2.new(0.4, 0, 0, 20)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(default)
        ValueLabel.TextColor3 = self.Rafield.Colors.Accent
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame
        
        local SliderBg = Instance.new("Frame")
        SliderBg.BackgroundColor3 = self.Rafield.Colors.Border
        SliderBg.BorderSizePixel = 0
        SliderBg.Position = UDim2.new(0, 0, 0, 30)
        SliderBg.Size = UDim2.new(1, 0, 0, 6)
        SliderBg.Parent = SliderFrame
        
        local SliderBgCorner = Instance.new("UICorner")
        SliderBgCorner.CornerRadius = UDim.new(1, 0)
        SliderBgCorner.Parent = SliderBg
        
        local SliderFill = Instance.new("Frame")
        SliderFill.BackgroundColor3 = self.Rafield.Colors.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.Parent = SliderBg
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderKnob = Instance.new("Frame")
        SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderKnob.BorderSizePixel = 0
        SliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        SliderKnob.Size = UDim2.new(0, 12, 0, 12)
        SliderKnob.Parent = SliderBg
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = SliderKnob
        
        local dragging = false
        local currentValue = default
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            currentValue = value
            
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
            ValueLabel.Text = tostring(value)
            
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
                SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                ValueLabel.Text = tostring(val)
                if callback then callback(val) end
            end,
            Get = function() return currentValue end
        }
    end
    
    function Window:CreateDropdown(parent, text, options, callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.BackgroundTransparency = 1
        DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Parent = parent
        
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.5, 0, 0, 20)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = self.Rafield.Colors.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = DropdownFrame
        
        local DropdownBtn = Instance.new("TextButton")
        DropdownBtn.BackgroundColor3 = self.Rafield.Colors.Secondary
        DropdownBtn.BorderSizePixel = 0
        DropdownBtn.Position = UDim2.new(0.5, 0, 0, 0)
        DropdownBtn.Size = UDim2.new(0.5, 0, 0, 25)
        DropdownBtn.Font = Enum.Font.Gotham
        DropdownBtn.Text = options[1] or "Select"
        DropdownBtn.TextColor3 = self.Rafield.Colors.Text
        DropdownBtn.TextSize = 11
        DropdownBtn.Parent = DropdownFrame
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = DropdownBtn
        
        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.BackgroundColor3 = self.Rafield.Colors.Secondary
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.Position = UDim2.new(0.5, 0, 0, 28)
        OptionsFrame.Size = UDim2.new(0.5, 0, 0, 0)
        OptionsFrame.AutomaticSize = Enum.AutomaticSize.Y
        OptionsFrame.Visible = false
        OptionsFrame.Parent = DropdownFrame
        
        local OptionsCorner = Instance.new("UICorner")
        OptionsCorner.CornerRadius = UDim.new(0, 4)
        OptionsCorner.Parent = OptionsFrame
        
        local OptionsList = Instance.new("UIListLayout")
        OptionsList.Padding = UDim.new(0, 2)
        OptionsList.Parent = OptionsFrame
        
        local open = false
        
        for _, option in ipairs(options) do
            local OptionBtn = Instance.new("TextButton")
            OptionBtn.BackgroundTransparency = 1
            OptionBtn.Size = UDim2.new(1, 0, 0, 22)
            OptionBtn.Font = Enum.Font.Gotham
            OptionBtn.Text = option
            OptionBtn.TextColor3 = self.Rafield.Colors.DarkText
            OptionBtn.TextSize = 11
            OptionBtn.Parent = OptionsFrame
            
            OptionBtn.MouseEnter:Connect(function()
                self.Rafield:Tween(OptionBtn, {TextColor3 = self.Rafield.Colors.Accent}, 0.15)
            end)
            OptionBtn.MouseLeave:Connect(function()
                self.Rafield:Tween(OptionBtn, {TextColor3 = self.Rafield.Colors.DarkText}, 0.15)
            end)
            OptionBtn.MouseLeave:Connect(function()
    self.Rafield:Tween(OptionBtn, {TextColor3 = self.Rafield.Colors.DarkText}, 0.15)
end)
OptionBtn.MouseButton1Click:Connect(function()
    DropdownBtn.Text = option
    open = false
    OptionsFrame.Visible = false
    DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    if callback then callback(option) end
end)
        end
        
        DropdownBtn.MouseButton1Click:Connect(function()
            open = not open
            OptionsFrame.Visible = open
            if open then
                DropdownFrame.Size = UDim2.new(1, 0, 0, 30 + OptionsFrame.AbsoluteSize.Y + 5)
            else
                DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
            end
        end)
        
        return {
            Set = function(val)
                DropdownBtn.Text = val
                if callback then callback(val) end
            end,
            Get = function() return DropdownBtn.Text end
        }
    end
    
    return Window
end

--// Инициализация GUI
local Window = Rafield:CreateWindow("Snipers vs Runners | @aLiNa_grnt")

--// Хранилище настроек
local Settings = {
    Aimbot = false,
    AutoShot = false,
    ESP = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPTracers = false,
    AimFov = 100,
    AimSmooth = 5,
    AimPart = "Head",
    TeamCheck = true,
    WallCheck = false,
    AutoShootDelay = 0.1
}

--// Секции интерфейса
local AimbotSection = Window:CreateSection("Аимбот")
local ESPSection = Window:CreateSection("ЕСП")
local MiscSection = Window:CreateSection("Разное")

--// Тумблеры Аимбота
Window:CreateToggle(AimbotSection, "Включить Аимбот", false, function(val)
    Settings.Aimbot = val
end)

Window:CreateToggle(AimbotSection, "Авто-Выстрел", false, function(val)
    Settings.AutoShot = val
end)

Window:CreateToggle(AimbotSection, "Проверка Команды", true, function(val)
    Settings.TeamCheck = val
end)

Window:CreateToggle(AimbotSection, "Проверка Стены", false, function(val)
    Settings.WallCheck = val
end)

--// Ползунки Аимбота
Window:CreateSlider(AimbotSection, "Поле Зрения", 10, 300, 100, function(val)
    Settings.AimFov = val
end)

Window:CreateSlider(AimbotSection, "Плавность", 1, 20, 5, function(val)
    Settings.AimSmooth = val
end)

Window:CreateSlider(AimbotSection, "Задержка Выстрела", 1, 50, 10, function(val)
    Settings.AutoShootDelay = val / 100
end)

--// Выпадающий список для части тела
Window:CreateDropdown(AimbotSection, "Целевая Часть", {"Голова", "Туловище", "Корень"}, function(val)
    local partMap = {["Голова"] = "Head", ["Туловище"] = "Torso", ["Корень"] = "HumanoidRootPart"}
    Settings.AimPart = partMap[val] or "Head"
end)

--// Тумблеры ЕСП
Window:CreateToggle(ESPSection, "Включить ЕСП", false, function(val)
    Settings.ESP = val
    if not val then
        for _, data in pairs(ESPObjects) do
            for _, obj in pairs(data) do
                if obj then obj.Visible = false end
            end
        end
    end
end)

Window:CreateToggle(ESPSection, "Коробки", true, function(val)
    Settings.ESPBoxes = val
end)

Window:CreateToggle(ESPSection, "Имена", true, function(val)
    Settings.ESPNames = val
end)

Window:CreateToggle(ESPSection, "Здоровье", true, function(val)
    Settings.ESPHealth = val
end)

Window:CreateToggle(ESPSection, "Линии", false, function(val)
    Settings.ESPTracers = val
end)

--// Разное
Window:CreateToggle(MiscSection, "Показать Круг FOV", true, function(val)
    FOVCircle.Visible = val
end)

--// Хранилище объектов ЕСП
local ESPObjects = {}

--// Круг поля зрения
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(180, 130, 220)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.AimFov

--// Вспомогательные функции
local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function GetTeam(player)
    return player.Team
end

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
        
        local character = GetCharacter(player)
        if not character then continue end
        
        local humanoid = GetHumanoid(character)
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local aimPart = character:FindFirstChild(Settings.AimPart)
        if not aimPart then continue end
        
        if not IsVisible(aimPart) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < Settings.AimFov and dist < closestDist then
            closestDist = dist
            closest = {Player = player, Part = aimPart, ScreenPos = screenPos}
        end
    end
    
    return closest
end

--// Создание ЕСП
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    
    --// Коробка
    objects.Box.Visible = false
    objects.Box.Thickness = 1
    objects.Box.Color = Color3.fromRGB(255, 50, 50)
    objects.Box.Transparency = 1
    objects.Box.Filled = false
    
    --// Имя
    objects.Name.Visible = false
    objects.Name.Size = 13
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Color = Color3.fromRGB(255, 255, 255)
    objects.Name.Font = Drawing.Fonts.UI
    
    --// Фон полоски здоровья
    objects.HealthBarBg.Visible = false
    objects.HealthBarBg.Thickness = 1
    objects.HealthBarBg.Color = Color3.fromRGB(50, 50, 50)
    objects.HealthBarBg.Filled = true
    objects.HealthBarBg.Transparency = 0.5
    
    --// Полоска здоровья
    objects.HealthBar.Visible = false
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Color = Color3.fromRGB(50, 255, 50)
    objects.HealthBar.Filled = true
    objects.HealthBar.Transparency = 0.8
    
    --// Линия-трассер
    objects.Tracer.Visible = false
    objects.Tracer.Thickness = 1
    objects.Tracer.Color = Color3.fromRGB(180, 130, 220)
    objects.Tracer.Transparency = 0.7
    
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
        local character = GetCharacter(player)
        if not character or not Settings.ESP then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local humanoid = GetHumanoid(character)
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
        
        --// Коробка
        if Settings.ESPBoxes then
            objects.Box.Size = Vector2.new(width, height)
            objects.Box.Position = Vector2.new(boxX, boxY)
            objects.Box.Visible = true
        else
            objects.Box.Visible = false
        end
        
        --// Имя
        if Settings.ESPNames then
            objects.Name.Position = Vector2.new(pos.X, boxY - 15)
            objects.Name.Text = player.Name .. " | @aLiNa_grnt"
            objects.Name.Visible = true
        else
            objects.Name.Visible = false
        end
        
        --// Здоровье
        if Settings.ESPHealth then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = height * healthPercent
            
            objects.HealthBarBg.Size = Vector2.new(4, height)
            objects.HealthBarBg.Position = Vector2.new(boxX - 8, boxY)
            objects.HealthBarBg.Visible = true
            
            objects.HealthBar.Size = Vector2.new(4, barHeight)
            objects.HealthBar.Position = Vector2.new(boxX - 8, boxY + height - barHeight)
            objects.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 50)
            objects.HealthBar.Visible = true
        else
            objects.HealthBar.Visible = false
            objects.HealthBarBg.Visible = false
        end
        
        --// Трассер
        if Settings.ESPTracers then
            objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            objects.Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
            objects.Tracer.Visible = true
        else
            objects.Tracer.Visible = false
        end
    end
end

--// Логика Аимбота
local function Aimbot()
    if not Settings.Aimbot then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local targetPos = Camera:WorldToViewportPoint(target.Part.Position)
    local mousePos = UserInputService:GetMouseLocation()
    local moveVec = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) / Settings.AimSmooth
    
    mousemoverel(moveVec.X, moveVec.Y)
    
    --// Авто-выстрел
    if Settings.AutoShot then
        task.wait(Settings.AutoShootDelay)
        mouse1click()
    end
end

--// Управление игроками
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

--// Главный цикл
RunService.RenderStepped:Connect(function()
    --// Обновление круга FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.AimFov
    
    --// Обновление ЕСП
    if Settings.ESP then
        UpdateESP()
    end
    
    --// Запуск Аимбота
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        Aimbot()
    end
end)

--// Уведомление о загрузке
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "Notification_@aLiNa_grnt"
NotifGui.ResetOnSpawn = false
NotifGui.Parent = CoreGui

local NotifFrame = Instance.new("Frame")
NotifFrame.BackgroundColor3 = Rafield.Colors.Background
NotifFrame.BorderSizePixel = 0
NotifFrame.Position = UDim2.new(1, -320, 1, -80)
NotifFrame.Size = UDim2.new(0, 300, 0, 60)
NotifFrame.Parent = NotifGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 8)
NotifCorner.Parent = NotifFrame

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Rafield.Colors.Accent
NotifStroke.Thickness = 1
NotifStroke.Parent = NotifFrame

local NotifText = Instance.new("TextLabel")
NotifText.BackgroundTransparency = 1
NotifText.Size = UDim2.new(1, -20, 1, 0)
NotifText.Position = UDim2.new(0, 10, 0, 0)
NotifText.Font = Enum.Font.GothamBold
NotifText.Text = "Snipers vs Runners Чит Загружен\nСделано с любовью от @aLiNa_grnt"
NotifText.TextColor3 = Rafield.Colors.Text
NotifText.TextSize = 13
NotifText.Parent = NotifFrame

task.delay(5, function()
    Rafield:Tween(NotifFrame, {Position = UDim2.new(1, 20, 1, -80)}, 0.5)
    task.wait(0.6)
    NotifGui:Destroy()
end)

--// Совместимость с Delta Exploit
if not getgenv then getgenv = function() return _G end end
if not mousemoverel then 
    mousemoverel = function(x, y)
        local absX, absY = x + UserInputService:GetMouseLocation().X, y + UserInputService:GetMouseLocation().Y
        --// Запасной вариант для эксплойтов без mousemoverel
    end 
end
if not mouse1click then
    mouse1click = function()
        --// Запасной вариант — используем виртуальный ввод если доступен
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

--// Анти-АФК
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// Финальный водяной знак в консоли
print("╔══════════════════════════════════════╗")
print("║  Snipers vs Runners Чит Сьют        ║")
print("║  Автор: @aLiNa_grnt                  ║")
print("║  Статус: Загружен и Готов            ║")
print("╚══════════════════════════════════════╝")
