-- ============================================================
-- 🎯 RIVALS GUI SCRIPT - SHOOTER MOD
-- ============================================================
-- Скрипт для красивого GUI меню с функциями стрелялки
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerCharacter = player.Character or player.CharacterAdded:Wait()
local playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")

-- ============================================================
-- 📊 КОНФИГ ПЕРЕМЕННЫЕ
-- ============================================================

local Config = {
	AimBot = {
		Enabled = false,
		FOV = 200,
		Smoothness = 0.5,
		Prediction = true,
		CurrentTarget = nil,
	},
	Shooter = {
		AutoShoot = false,
		NoRecoil = false,
		BulletSpeed = 100,
		ShootDelay = 100,
		InfiniteAmmo = false,
	},
	ESP = {
		Enabled = false,
		MaxDistance = 500,
		ShowDistance = true,
		ShowHP = true,
	},
	UI = {
		MenuOpen = false,
		MenuPosition = UDim2.new(0.5, -200, 0.5, -250),
	}
}

-- ============================================================
-- 🎨 UI КОНСТАНТЫ
-- ============================================================

local UI_COLORS = {
	Primary = Color3.fromRGB(138, 43, 226),      -- Фиолетовый
	Secondary = Color3.fromRGB(255, 20, 147),    -- Розовый
	Accent = Color3.fromRGB(0, 255, 255),        -- Циан
	Background = Color3.fromRGB(20, 20, 30),     -- Тёмный
	Success = Color3.fromRGB(0, 255, 100),       -- Зелёный
	Danger = Color3.fromRGB(255, 50, 50),        -- Красный
}

-- ============================================================
-- 🖼️ СОЗДАНИЕ GUI
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsModGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- ============================================================
-- 🔴 КРУГ В ЦЕНТРЕ (ПРИЦЕЛ)
-- ============================================================

local CenterCircle = Instance.new("Frame")
CenterCircle.Name = "CenterCircle"
CenterCircle.Size = UDim2.new(0, 60, 0, 60)
CenterCircle.Position = UDim2.new(0.5, -30, 0.5, -30)
CenterCircle.BackgroundColor3 = UI_COLORS.Accent
CenterCircle.BackgroundTransparency = 0.7
CenterCircle.BorderSizePixel = 0
CenterCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = CenterCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = UI_COLORS.Accent
CircleStroke.Thickness = 2
CircleStroke.Parent = CenterCircle

-- ============================================================
-- 📱 ГЛАВНОЕ МЕНЮ
-- ============================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = Config.UI.MenuPosition
MainFrame.BackgroundColor3 = UI_COLORS.Background
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 15)
MenuCorner.Parent = MainFrame

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = UI_COLORS.Primary
MenuStroke.Thickness = 3
MenuStroke.Parent = MainFrame

-- ============================================================
-- 📌 ЗАГОЛОВОК МЕНЮ
-- ============================================================

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "Header"
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)
HeaderFrame.BackgroundColor3 = UI_COLORS.Primary
HeaderFrame.BackgroundTransparency = 0.3
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = HeaderFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎯 RIVALS MOD"
TitleLabel.TextSize = 28
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = HeaderFrame

-- ============================================================
-- 🔘 КНОПКА ЗАКРЫТИЯ МЕНЮ
-- ============================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseBtn"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundColor3 = UI_COLORS.Danger
CloseButton.BackgroundTransparency = 0.3
CloseButton.Text = "✕"
CloseButton.TextSize = 24
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = HeaderFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
	Config.UI.MenuOpen = false
	MainFrame:TweenSize(UDim2.new(0, 400, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
	wait(0.3)
	MainFrame.Visible = false
end)

-- ============================================================
-- 📋 СПИСОК ФУНКЦИЙ (SCROLLABLE)
-- ============================================================

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, -60)
ScrollFrame.Position = UDim2.new(0, 0, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 10)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ScrollFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 15)
Padding.PaddingLeft = UDim.new(0, 15)
Padding.PaddingRight = UDim.new(0, 15)
Padding.PaddingBottom = UDim.new(0, 15)
Padding.Parent = ScrollFrame

-- ============================================================
-- 🔧 ФУНКЦИЯ СОЗДАНИЯ TOGGLE КНОПКИ
-- ============================================================

local function CreateToggleButton(parent, name, description, initialState, callback)
	local ToggleContainer = Instance.new("Frame")
	ToggleContainer.Name = name .. "_Toggle"
	ToggleContainer.Size = UDim2.new(1, 0, 0, 60)
	ToggleContainer.BackgroundColor3 = UI_COLORS.Background
	ToggleContainer.BackgroundTransparency = 0.5
	ToggleContainer.BorderSizePixel = 0
	ToggleContainer.Parent = parent

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 10)
	ToggleCorner.Parent = ToggleContainer

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Color = UI_COLORS.Primary
	ToggleStroke.Thickness = 1
	ToggleStroke.Parent = ToggleContainer

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, -80, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name .. "\n" .. description
	Label.TextSize = 14
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Center
	Label.Parent = ToggleContainer

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Name = "ToggleBtn"
	ToggleButton.Size = UDim2.new(0, 50, 0, 25)
	ToggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
	ToggleButton.BackgroundColor3 = initialState and UI_COLORS.Success or UI_COLORS.Danger
	ToggleButton.BackgroundTransparency = 0.2
	ToggleButton.Text = initialState and "ON" or "OFF"
	ToggleButton.TextSize = 12
	ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToggleButton.Font = Enum.Font.GothamBold
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Parent = ToggleContainer

	local ToggleBtnCorner = Instance.new("UICorner")
	ToggleBtnCorner.CornerRadius = UDim.new(0, 8)
	ToggleBtnCorner.Parent = ToggleButton

	local state = initialState

	ToggleButton.MouseButton1Click:Connect(function()
		state = not state
		ToggleButton.BackgroundColor3 = state and UI_COLORS.Success or UI_COLORS.Danger
		ToggleButton.Text = state and "ON" or "OFF"
		callback(state)
	end)

	return ToggleButton, function() return state end
end

-- ============================================================
-- 🔧 ФУНКЦИЯ СОЗДАНИЯ СЛАЙДЕРА
-- ============================================================

local function CreateSlider(parent, name, min, max, default, callback)
	local SliderContainer = Instance.new("Frame")
	SliderContainer.Name = name .. "_Slider"
	SliderContainer.Size = UDim2.new(1, 0, 0, 70)
	SliderContainer.BackgroundColor3 = UI_COLORS.Background
	SliderContainer.BackgroundTransparency = 0.5
	SliderContainer.BorderSizePixel = 0
	SliderContainer.Parent = parent

	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 10)
	SliderCorner.Parent = SliderContainer

	local SliderStroke = Instance.new("UIStroke")
	SliderStroke.Color = UI_COLORS.Primary
	SliderStroke.Thickness = 1
	SliderStroke.Parent = SliderContainer

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, -20, 0, 20)
	Label.Position = UDim2.new(0, 10, 0, 5)
	Label.BackgroundTransparency = 1
	Label.Text = name .. ": " .. tostring(default)
	Label.TextSize = 12
	Label.TextColor3 = UI_COLORS.Accent
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderContainer

	local SliderBar = Instance.new("Frame")
	SliderBar.Name = "SliderBar"
	SliderBar.Size = UDim2.new(1, -20, 0, 5)
	SliderBar.Position = UDim2.new(0, 10, 0, 30)
	SliderBar.BackgroundColor3 = UI_COLORS.Primary
	SliderBar.BackgroundTransparency = 0.5
	SliderBar.BorderSizePixel = 0
	SliderBar.Parent = SliderContainer

	local SliderBarCorner = Instance.new("UICorner")
	SliderBarCorner.CornerRadius = UDim.new(1, 0)
	SliderBarCorner.Parent = SliderBar

	local SliderButton = Instance.new("TextButton")
	SliderButton.Name = "SliderBtn"
	SliderButton.Size = UDim2.new(0, 15, 0, 15)
	SliderButton.BackgroundColor3 = UI_COLORS.Secondary
	SliderButton.Text = ""
	SliderButton.BorderSizePixel = 0
	SliderButton.Parent = SliderBar

	local SliderBtnCorner = Instance.new("UICorner")
	SliderBtnCorner.CornerRadius = UDim.new(1, 0)
	SliderBtnCorner.Parent = SliderButton

	local percentage = (default - min) / (max - min)
	SliderButton.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)

	local dragging = false

	SliderButton.MouseButton1Down:Connect(function()
		dragging = true
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging then
			local mousePos = mouse.X
			local barPos = SliderBar.AbsolutePosition.X
			local barSize = SliderBar.AbsoluteSize.X

			local newPos = math.clamp(mousePos - barPos, 0, barSize)
			local newPercentage = newPos / barSize
			local newValue = math.floor(min + (newPercentage * (max - min)) + 0.5)

			SliderButton.Position = UDim2.new(newPercentage, -7.5, 0.5, -7.5)
			Label.Text = name .. ": " .. tostring(newValue)
			callback(newValue)
		end
	end)

end

-- ============================================================
-- 📌 СОЗДАНИЕ ВСЕХ КНОПОК И СЛАЙДЕРОВ
-- ============================================================

-- Заголовок секции
local function CreateSectionLabel(parent, text)
	local Section = Instance.new("TextLabel")
	Section.Name = text .. "_Section"
	Section.Size = UDim2.new(1, 0, 0, 25)
	Section.BackgroundColor3 = UI_COLORS.Primary
	Section.BackgroundTransparency = 0.7
	Section.Text = "  " .. text
	Section.TextSize = 14
	Section.TextColor3 = UI_COLORS.Accent
	Section.Font = Enum.Font.GothamBold
	Section.TextXAlignment = Enum.TextXAlignment.Left
	Section.BorderSizePixel = 0
	Section.Parent = parent
end

-- AIM BOT СЕКЦИЯ
CreateSectionLabel(ScrollFrame, "🎯 AIM BOT")

local aimBotBtn, getAimBotState = CreateToggleButton(ScrollFrame, "Aim Bot", "Автоматический прицел", false, function(state)
	Config.AimBot.Enabled = state
end)

local predictionBtn, getPredictionState = CreateToggleButton(ScrollFrame, "Prediction", "Предсказание движения", true, function(state)
	Config.AimBot.Prediction = state
end)

CreateSlider(ScrollFrame, "FOV", 50, 500, 200, function(value)
	Config.AimBot.FOV = value
end)

CreateSlider(ScrollFrame, "Smoothness", 10, 100, 50, function(value)
	Config.AimBot.Smoothness = value / 100
end)

-- SHOOTER СЕКЦИЯ
CreateSectionLabel(ScrollFrame, "🔫 SHOOTER")

local autoShootBtn, getAutoShootState = CreateToggleButton(ScrollFrame, "Auto Shoot", "Автоматическая стрельба", false, function(state)
	Config.Shooter.AutoShoot = state
end)

local noRecoilBtn, getNoRecoilState = CreateToggleButton(ScrollFrame, "No Recoil", "Отсутствие отдачи", false, function(state)
	Config.Shooter.NoRecoil = state
end)

local infiniteAmmoBtn, getInfiniteAmmoState = CreateToggleButton(ScrollFrame, "Infinite Ammo", "Бесконечные патроны", false, function(state)
	Config.Shooter.InfiniteAmmo = state
end)

CreateSlider(ScrollFrame, "Bullet Speed", 50, 200, 100, function(value)
	Config.Shooter.BulletSpeed = value
end)

CreateSlider(ScrollFrame, "Shoot Delay", 50, 500, 100, function(value)
	Config.Shooter.ShootDelay = value
end)

-- ESP СЕКЦИЯ
CreateSectionLabel(ScrollFrame, "👁️ ESP")

local espBtn, getESPState = CreateToggleButton(ScrollFrame, "ESP", "Видимость врагов через стены", false, function(state)
	Config.ESP.Enabled = state
end)

local distanceBtn, getDistanceState = CreateToggleButton(ScrollFrame, "Show Distance", "Показывать расстояние", true, function(state)
	Config.ESP.ShowDistance = state
end)

local hpBtn, getHPState = CreateToggleButton(ScrollFrame, "Show HP", "Показывать здоровье", true, function(state)
	Config.ESP.ShowHP = state
end)

CreateSlider(ScrollFrame, "Max Distance", 50, 1000, 500, function(value)
	Config.ESP.MaxDistance = value
end)

-- ============================================================
-- ⌨️ ГОРЯЧИЕ КЛАВИШИ
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- Открыть/Закрыть меню
	if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.Delete then
		Config.UI.MenuOpen = not Config.UI.MenuOpen
		MainFrame.Visible = Config.UI.MenuOpen
		if Config.UI.MenuOpen then
			MainFrame:TweenSize(UDim2.new(0, 400, 0, 500), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		else
			MainFrame:TweenSize(UDim2.new(0, 400, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
			wait(0.3)
			MainFrame.Visible = false
		end
	end

	-- Быстрые тоглы
	if input.KeyCode == Enum.KeyCode.Q then
		Config.AimBot.Enabled = not Config.AimBot.Enabled
	end
	if input.KeyCode == Enum.KeyCode.E then
		Config.Shooter.AutoShoot = not Config.Shooter.AutoShoot
	end
	if input.KeyCode == Enum.KeyCode.F then
		Config.Shooter.NoRecoil = not Config.Shooter.NoRecoil
	end
	if input.KeyCode == Enum.KeyCode.X then
		Config.ESP.Enabled = not Config.ESP.Enabled
	end
	if input.KeyCode == Enum.KeyCode.C then
		Config.Shooter.InfiniteAmmo = not Config.Shooter.InfiniteAmmo
	end
end)

-- ============================================================
-- 🎯 AIM BOT ФУНКЦИИ
-- ============================================================

local function getEnemies()
	local enemies = {}
	for _, player_instance in pairs(Players:GetPlayers()) do
		if player_instance ~= player and player_instance.Character then
			table.insert(enemies, player_instance.Character)
		end
	end
	return enemies
end

local function getClosestEnemy()
	local enemies = getEnemies()
	local closest = nil
	local closestDistance = Config.AimBot.FOV

	for _, enemy in pairs(enemies) do
		if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
			local distance = (enemy.HumanoidRootPart.Position - playerHumanoidRootPart.Position).Magnitude
			if distance < closestDistance then
				closest = enemy
				closestDistance = distance
			end
		end
	end

	return closest
end

local function getPredictedPosition(targetPart, distance)
	if not Config.AimBot.Prediction then
		return targetPart.Position
	end

	local velocity = targetPart.AssemblyLinearVelocity
	local predictTime = distance / 100 -- примерный расчёт
	return targetPart.Position + (velocity * predictTime)
end

local function aimAtTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end

	local targetPos = getPredictedPosition(target.HumanoidRootPart, 100)
	local direction = (targetPos - Camera.CFrame.Position).Unit
	
	local newCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + direction)
	Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.AimBot.Smoothness)
end

-- ============================================================
-- 🔫 SHOOTER ФУНКЦИИ
-- ============================================================

local lastShotTime = 0

local function autoShoot()
	if not Config.Shooter.AutoShoot then return end

	local currentTime = tick()
	if currentTime - lastShotTime < (Config.Shooter.ShootDelay / 1000) then return end

	-- Симуляция выстрела (в реальной игре нужно найти правильный способ)
	lastShotTime = currentTime
end

-- ============================================================
-- 👁️ ESP ФУНКЦИИ
-- ============================================================

local espBoxes = {}

local function createESPBox(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Adornee = humanoidRootPart
	billboardGui.MaxDistance = Config.ESP.MaxDistance
	billboardGui.Size = UDim2.new(4, 0, 5, 0)
	billboardGui.Parent = humanoidRootPart

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Parent = billboardGui

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.TextColor3 = UI_COLORS.Danger
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = frame

	if character.Parent and character.Parent:IsA("Player") then
		textLabel.Text = character.Parent.Name
	end

	if Config.ESP.ShowDistance then
		local distance = (humanoidRootPart.Position - playerHumanoidRootPart.Position).Magnitude
		textLabel.Text = textLabel.Text .. "\n" .. math.floor(distance) .. "m"
	end

	if Config.ESP.ShowHP and character:FindFirstChild("Humanoid") then
		textLabel.Text = textLabel.Text .. "\nHP: " .. math.floor(character.Humanoid.Health)
	end

	table.insert(espBoxes, {gui = billboardGui, character = character})
end

local function updateESP()
	if not Config.ESP.Enabled then
		for _, espBox in pairs(espBoxes) do
			espBox.gui:Destroy()
		end
		espBoxes = {}
		return
	end

	for _, enemy in pairs(getEnemies()) do
		local found = false
		for _, espBox in pairs(espBoxes) do
			if espBox.character == enemy then
				found = true
				break
			end
		end
		if not found then
			createESPBox(enemy)
		end
	end
end

-- ============================================================
-- 🎮 ГЛАВНОЙ ЛУП ОБНОВЛЕНИЯ
-- ============================================================

RunService.RenderStepped:Connect(function()
	if Config.AimBot.Enabled then
		local target = getClosestEnemy()
		if target then
			Config.AimBot.CurrentTarget = target
			aimAtTarget(target)
		end
	end

	autoShoot()
	updateESP()

	-- Обновление цвета круга прицела
	if Config.AimBot.Enabled and Config.AimBot.CurrentTarget then
		CenterCircle.BackgroundColor3 = UI_COLORS.Danger
		CircleStroke.Color = UI_COLORS.Danger
	else
		CenterCircle.BackgroundColor3 = UI_COLORS.Accent
		CircleStroke.Color = UI_COLORS.Accent
	end
end)

-- ============================================================
-- 🔄 ОБНОВЛЕНИЕ ПЕРСОНАЖА
-- ============================================================

player.CharacterAdded:Connect(function(newCharacter)
	playerCharacter = newCharacter
	playerHumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

print("✅ Rivals Mod Script Loaded!")
print("🎮 Press INSERT/DEL to open menu")
print("⌨️  Hotkeys: Q=AimBot, E=AutoShoot, F=NoRecoil, X=ESP, C=InfiniteAmmo")
