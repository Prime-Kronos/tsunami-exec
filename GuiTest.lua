-- ==============================================
-- GUI в стиле PJTSUXProject для экзекьютора
-- Полное переключение видимости, вкладки, перетаскивание
-- ==============================================

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "PJTSUXGUI"
gui.Parent = player:WaitForChild("PlayerGui")

-- Переменная для toggle
local guiVisible = true

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

-- Заголовок (верхняя панель)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
titleBar.Active = true
titleBar.Draggable = true

-- Текст заголовка
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -90, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "PJTSUXProject"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- Кнопка toggle (≡) — показывает/скрывает GUI
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 1, 0)
toggleBtn.Position = UDim2.new(1, -30, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 18
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = titleBar
toggleBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

-- Кнопка закрытия (×)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -60, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Панель вкладок (Tabs)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

-- Список вкладок
local tabs = {"Home", "Scripts", "Teleports", "Settings", "Credits"}
local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, 0, 1, 0)
    btn.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = tabContainer
    tabButtons[tabName] = btn
end

-- Контентная область
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -70)
contentFrame.Position = UDim2.new(0, 0, 0, 70)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Страницы вкладок
local pages = {}
for _, tabName in ipairs(tabs) do
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Parent = contentFrame
    page.Visible = (tabName == "Home")
    pages[tabName] = page

    -- Заполняем каждую страницу примерным текстом
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Содержимое вкладки " .. tabName
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 18
    label.Font = Enum.Font.Gotham
    label.Parent = page
end

-- Обработка кликов по табам
for tabName, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Скрыть все страницы
        for _, page in pairs(pages) do
            page.Visible = false
        end
        -- Показать нужную
        if pages[tabName] then
            pages[tabName].Visible = true
        end
        -- Подсветка активного таба
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    end)
end

-- По умолчанию подсвечен Home
tabButtons["Home"].BackgroundColor3 = Color3.fromRGB(70, 70, 80)

print("[✔] PJTSUXProject GUI загружен!")
