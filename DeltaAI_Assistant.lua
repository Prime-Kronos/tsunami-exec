-- ═══════════════════════════════════════════════════════════════
--  DELTA AI ASSISTANT v2.0
--  ИИ-помощник для Delta Exploit с Groq API
--  Автор: AI
--  Описание: Круглая кнопка → Меню → Анализ игры + Чат-команды
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
--  КОНФИГУРАЦИЯ
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    GROQ_API_KEY = "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", -- ЗАМЕНИ НА СВОЙ КЛЮЧ!
    GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions",
    GROQ_MODEL = "llama-3.3-70b-versatile", -- или "llama3-8b-8192" для скорости
    MAX_TOKENS = 4096,
    TEMPERATURE = 0.7,

    -- UI Настройки
    BUTTON_SIZE = 56,
    BUTTON_POSITION = UDim2.new(0, 20, 1, -76), -- Низ слева
    MENU_WIDTH = 420,
    MENU_HEIGHT = 520,

    -- Цвета
    PRIMARY_COLOR = Color3.fromRGB(88, 101, 242),    -- Фиолетовый
    SECONDARY_COLOR = Color3.fromRGB(32, 34, 37),    -- Тёмный
    ACCENT_COLOR = Color3.fromRGB(88, 101, 242),     -- Акцент
    SUCCESS_COLOR = Color3.fromRGB(67, 181, 129),    -- Зелёный
    WARNING_COLOR = Color3.fromRGB(250, 166, 26),    -- Жёлтый
    ERROR_COLOR = Color3.fromRGB(240, 71, 71),       -- Красный
    TEXT_COLOR = Color3.fromRGB(220, 221, 222),      -- Светлый текст
    DARK_TEXT = Color3.fromRGB(142, 146, 151),       -- Тёмный текст

    -- Анимации
    TWEEN_DURATION = 0.3,
    EASING_STYLE = Enum.EasingStyle.Quart,
    EASING_DIRECTION = Enum.EasingDirection.Out,
}

-- ═══════════════════════════════════════════════════════════════
--  УТИЛИТЫ
-- ═══════════════════════════════════════════════════════════════

local Utils = {}

function Utils.Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

function Utils.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or CONFIG.TWEEN_DURATION,
            easingStyle or CONFIG.EASING_STYLE,
            easingDirection or CONFIG.EASING_DIRECTION
        ),
        properties
    )
    tween:Play()
    return tween
end

function Utils.Round(number, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
end

function Utils.FormatBytes(bytes)
    if bytes >= 1073741824 then
        return string.format("%.2f GB", bytes / 1073741824)
    elseif bytes >= 1048576 then
        return string.format("%.2f MB", bytes / 1048576)
    elseif bytes >= 1024 then
        return string.format("%.2f KB", bytes / 1024)
    else
        return bytes .. " B"
    end
end

function Utils.GetGameInfo()
    local gameInfo = {
        placeId = game.PlaceId,
        gameId = game.GameId,
        jobId = game.JobId,
        placeName = "Unknown",
        creatorName = "Unknown",
        creatorId = 0,
        maxPlayers = 0,
        playerCount = #Players:GetPlayers(),
    }

    pcall(function()
        local marketplaceService = game:GetService("MarketplaceService")
        local placeInfo = marketplaceService:GetProductInfo(game.PlaceId)
        gameInfo.placeName = placeInfo.Name or "Unknown"
        gameInfo.creatorName = placeInfo.Creator.Name or "Unknown"
        gameInfo.creatorId = placeInfo.Creator.Id or 0
        gameInfo.maxPlayers = placeInfo.MaxPlayers or 0
    end)

    return gameInfo
end

-- ═══════════════════════════════════════════════════════════════
--  СКАНЕР ИГРЫ
-- ═══════════════════════════════════════════════════════════════

local GameScanner = {}
GameScanner.Results = {
    remoteEvents = {},
    remoteFunctions = {},
    bindableEvents = {},
    bindableFunctions = {},
    modules = {},
    scripts = {},
    localScripts = {},
    guis = {},
    hiddenServices = {},
    antiCheats = {},
    suspicious = {},
}

function GameScanner.ScanRemotes(parent, path)
    parent = parent or game
    path = path or "game"

    for _, child in ipairs(parent:GetChildren()) do
        local childPath = path .. "." .. child.Name
        local className = child.ClassName

        if className == "RemoteEvent" then
            table.insert(GameScanner.Results.remoteEvents, {
                name = child.Name,
                path = childPath,
                instance = child,
                parent = parent.Name,
            })
        elseif className == "RemoteFunction" then
            table.insert(GameScanner.Results.remoteFunctions, {
                name = child.Name,
                path = childPath,
                instance = child,
                parent = parent.Name,
            })
        elseif className == "BindableEvent" then
            table.insert(GameScanner.Results.bindableEvents, {
                name = child.Name,
                path = childPath,
                instance = child,
            })
        elseif className == "BindableFunction" then
            table.insert(GameScanner.Results.bindableFunctions, {
                name = child.Name,
                path = childPath,
                instance = child,
            })
        elseif className == "ModuleScript" then
            table.insert(GameScanner.Results.modules, {
                name = child.Name,
                path = childPath,
                instance = child,
            })
        elseif className == "Script" then
            table.insert(GameScanner.Results.scripts, {
                name = child.Name,
                path = childPath,
                instance = child,
            })
        elseif className == "LocalScript" then
            table.insert(GameScanner.Results.localScripts, {
                name = child.Name,
                path = childPath,
                instance = child,
            })
        elseif className == "ScreenGui" or className == "BillboardGui" or className == "SurfaceGui" then
            table.insert(GameScanner.Results.guis, {
                name = child.Name,
                path = childPath,
                className = className,
                instance = child,
            })
        end

        -- Проверка на анти-чит
        local lowerName = child.Name:lower()
        if lowerName:find("anticheat") or lowerName:find("anti.cheat") or 
           lowerName:find("acdetect") or lowerName:find("cheatdetect") or
           lowerName:find("ban") or lowerName:find("kick") or
           lowerName:find("exploit") or lowerName:find("hackdetect") then
            table.insert(GameScanner.Results.antiCheats, {
                name = child.Name,
                path = childPath,
                className = className,
                instance = child,
            })
        end

        -- Рекурсивный скан
        if #child:GetChildren() > 0 and child ~= Players then
            pcall(function()
                GameScanner.ScanRemotes(child, childPath)
            end)
        end
    end
end

function GameScanner.ScanHiddenServices()
    local servicesToCheck = {
        "AdService", "AnalyticsService", "AssetService", "BadgeService",
        "Chat", "CollectionService", "ContextActionService", "DataStoreService",
        "Debris", "FriendService", "GamePassService", "GroupService",
        "HapticService", "HttpService", "InsertService", "JointsService",
        "LocalizationService", "LogService", "MemoryStoreService", "MessagingService",
        "NetworkSettings", "NotificationService", "PhysicsService", "PolicyService",
        "PointsService", "ProximityPromptService", "RenderSettings", "RunService",
        "ScriptContext", "Selection", "SocialService", "SoundService",
        "StarterPlayer", "Teams", "TeleportService", "TextChatService",
        "TextService", "TweenService", "UserInputService", "VRService",
        "Workspace", "Sound", "Lighting", "ReplicatedStorage", "ReplicatedFirst",
        "StarterGui", "StarterPack", "StarterPlayer", "ServerScriptService",
        "ServerStorage", "Workspace"
    }

    for _, serviceName in ipairs(servicesToCheck) do
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        if success and service then
            local children = service:GetChildren()
            if #children > 0 then
                table.insert(GameScanner.Results.hiddenServices, {
                    name = serviceName,
                    childCount = #children,
                    instance = service,
                })
            end
        end
    end
end

function GameScanner.DetectAntiCheatPatterns()
    -- Сканируем на подозрительные паттерны
    local suspiciousPatterns = {
        "fireserver", "invokeserver", "kick", "ban", "detect",
        "exploit", "cheat", "hack", "fly", "speed", "teleport",
        "noclip", "godmode", "infinite", "auto", "farm"
    }

    for _, module in ipairs(GameScanner.Results.modules) do
        pcall(function()
            local source = module.instance.Source or ""
            local lowerSource = source:lower()
            for _, pattern in ipairs(suspiciousPatterns) do
                if lowerSource:find(pattern) then
                    table.insert(GameScanner.Results.suspicious, {
                        name = module.name,
                        path = module.path,
                        pattern = pattern,
                        type = "module",
                    })
                    break
                end
            end
        end)
    end
end

function GameScanner.FullScan()
    GameScanner.Results = {
        remoteEvents = {},
        remoteFunctions = {},
        bindableEvents = {},
        bindableFunctions = {},
        modules = {},
        scripts = {},
        localScripts = {},
        guis = {},
        hiddenServices = {},
        antiCheats = {},
        suspicious = {},
    }

    GameScanner.ScanRemotes()
    GameScanner.ScanHiddenServices()
    GameScanner.DetectAntiCheatPatterns()

    return GameScanner.Results
end

function GameScanner.GetSummary()
    local results = GameScanner.Results
    return string.format(
        "📊 АНАЛИЗ ИГРЫ\n" ..
        "═══════════════════════\n" ..
        "🎮 Игра: %s\n" ..
        "🏢 Place ID: %d\n" ..
        "👥 Игроков: %d/%d\n" ..
        "\n📡 RemoteEvents: %d\n" ..
        "📡 RemoteFunctions: %d\n" ..
        "🔗 BindableEvents: %d\n" ..
        "🔗 BindableFunctions: %d\n" ..
        "📦 Modules: %d\n" ..
        "📜 Scripts: %d\n" ..
        "💻 LocalScripts: %d\n" ..
        "🖼️ GUIs: %d\n" ..
        "🔒 AntiCheats найдено: %d\n" ..
        "⚠️ Подозрительных модулей: %d\n" ..
        "📁 Сервисов с детьми: %d\n",
        Utils.GetGameInfo().placeName,
        game.PlaceId,
        #Players:GetPlayers(),
        Utils.GetGameInfo().maxPlayers,
        #results.remoteEvents,
        #results.remoteFunctions,
        #results.bindableEvents,
        #results.bindableFunctions,
        #results.modules,
        #results.scripts,
        #results.localScripts,
        #results.guis,
        #results.antiCheats,
        #results.suspicious,
        #results.hiddenServices
    )
end

-- ═══════════════════════════════════════════════════════════════
--  GROQ API КЛИЕНТ
-- ═══════════════════════════════════════════════════════════════

local GroqClient = {}
GroqClient.ConversationHistory = {}

function GroqClient.BuildSystemPrompt()
    local gameInfo = Utils.GetGameInfo()
    local scanResults = GameScanner.Results

    local systemPrompt = string.format(
        "Ты — ИИ-помощник для Roblox эксплойтера, работающий в Delta Executor.\n" ..
        "Ты помогаешь анализировать игры, находить уязвимости и создавать скрипты.\n\n" ..
        "ТЕКУЩАЯ ИГРА:\n" ..
        "- Название: %s\n" ..
        "- Place ID: %d\n" ..
        "- Job ID: %s\n" ..
        "- Игроков: %d\n\n" ..
        "НАЙДЕНО В ИГРЕ:\n" ..
        "- RemoteEvents: %d\n" ..
        "- RemoteFunctions: %d\n" ..
        "- BindableEvents: %d\n" ..
        "- BindableFunctions: %d\n" ..
        "- ModuleScripts: %d\n" ..
        "- Scripts: %d\n" ..
        "- LocalScripts: %d\n" ..
        "- GUIs: %d\n" ..
        "- AntiCheats обнаружено: %d\n\n" ..
        "ТВОИ ВОЗМОЖНОСТИ:\n" ..
        "1. Анализировать игру и находить RemoteEvent/RemoteFunction для эксплойтов\n" ..
        "2. Создавать GUI элементы (кнопки, фреймы, текстбоксы и т.д.)\n" ..
        "3. Генерировать Lua скрипты для обхода защит\n" ..
        "4. Находить обходные пути (workarounds) для анти-читов\n" ..
        "5. Писать скрипты для авто-фарма, телепорта, ESP, флая и т.д.\n\n" ..
        "ПРАВИЛА:\n" ..
        "- Всегда отвечай на русском языке\n" ..
        "- Давай готовый Lua код, который можно сразу выполнить\n" ..
        "- Объясняй, что делает каждый скрипт\n" ..
        "- Если просят создать GUI — пиши полный код с Instance.new\n" ..
        "- Если просят удалить GUI — указывай как найти и удалить\n" ..
        "- Для RemoteEvent пиши примеры FireServer с правильными аргументами\n" ..
        "- Будь краток, но информативен\n" ..
        "- Используй markdown для форматирования кода",
        gameInfo.placeName,
        gameInfo.placeId,
        gameInfo.jobId,
        gameInfo.playerCount,
        #scanResults.remoteEvents,
        #scanResults.remoteFunctions,
        #scanResults.bindableEvents,
        #scanResults.bindableFunctions,
        #scanResults.modules,
        #scanResults.scripts,
        #scanResults.localScripts,
        #scanResults.guis,
        #scanResults.antiCheats
    )

    -- Добавляем список RemoteEvents
    if #scanResults.remoteEvents > 0 then
        systemPrompt = systemPrompt .. "\n\nСПИСОК RemoteEvents:\n"
        for i, re in ipairs(scanResults.remoteEvents) do
            if i <= 30 then -- ограничиваем контекст
                systemPrompt = systemPrompt .. string.format("- %s (путь: %s)\n", re.name, re.path)
            end
        end
    end

    -- Добавляем список RemoteFunctions
    if #scanResults.remoteFunctions > 0 then
        systemPrompt = systemPrompt .. "\n\nСПИСОК RemoteFunctions:\n"
        for i, rf in ipairs(scanResults.remoteFunctions) do
            if i <= 30 then
                systemPrompt = systemPrompt .. string.format("- %s (путь: %s)\n", rf.name, rf.path)
            end
        end
    end

    -- Добавляем анти-читы
    if #scanResults.antiCheats > 0 then
        systemPrompt = systemPrompt .. "\n\nОБНАРУЖЕННЫЕ АНТИ-ЧИТЫ:\n"
        for _, ac in ipairs(scanResults.antiCheats) do
            systemPrompt = systemPrompt .. string.format("- %s (%s) по пути %s\n", ac.name, ac.className, ac.path)
        end
    end

    return systemPrompt
end

function GroqClient.SendMessage(userMessage)
    if CONFIG.GROQ_API_KEY == "gsk_YOUR_GROQ_API_KEY_HERE" then
        return "❌ ОШИБКА: Не указан GROQ_API_KEY! Открой скрипт и замени 'gsk_YOUR_GROQ_API_KEY_HERE' на свой ключ. Получи ключ на groq.com"
    end

    -- Добавляем сообщение пользователя в историю
    table.insert(GroqClient.ConversationHistory, {
        role = "user",
        content = userMessage
    })

    -- Ограничиваем историю (последние 10 сообщений)
    while #GroqClient.ConversationHistory > 10 do
        table.remove(GroqClient.ConversationHistory, 1)
    end

    -- Формируем сообщения
    local messages = {
        {
            role = "system",
            content = GroqClient.BuildSystemPrompt()
        }
    }

    for _, msg in ipairs(GroqClient.ConversationHistory) do
        table.insert(messages, msg)
    end

    local requestBody = {
        model = CONFIG.GROQ_MODEL,
        messages = messages,
        max_tokens = CONFIG.MAX_TOKENS,
        temperature = CONFIG.TEMPERATURE,
    }

    local success, result = pcall(function()
        local response = HttpService:RequestAsync({
            Url = CONFIG.GROQ_API_URL,
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. CONFIG.GROQ_API_KEY,
                ["Content-Type"] = "application/json",
            },
            Body = HttpService:JSONEncode(requestBody),
        })

        if response.Success then
            local data = HttpService:JSONDecode(response.Body)
            if data.choices and data.choices[1] and data.choices[1].message then
                local assistantMessage = data.choices[1].message.content
                -- Сохраняем ответ в историю
                table.insert(GroqClient.ConversationHistory, {
                    role = "assistant",
                    content = assistantMessage
                })
                return assistantMessage
            else
                return "⚠️ Неожиданный формат ответа от API"
            end
        else
            return "❌ Ошибка API (HTTP " .. response.StatusCode .. "): " .. response.StatusMessage
        end
    end)

    if success then
        return result
    else
        return "❌ Ошибка запроса: " .. tostring(result)
    end
end

function GroqClient.ClearHistory()
    GroqClient.ConversationHistory = {}
end

-- ═══════════════════════════════════════════════════════════════
--  GUI СОЗДАТЕЛЬ
-- ═══════════════════════════════════════════════════════════════

local GUICreator = {}
GUICreator.CreatedGUIs = {}

function GUICreator.CreateButton(properties)
    local button = Utils.Create("TextButton", {
        Name = properties.name or "Button",
        Size = properties.size or UDim2.new(0, 200, 0, 50),
        Position = properties.position or UDim2.new(0.5, -100, 0.5, -25),
        BackgroundColor3 = properties.color or CONFIG.PRIMARY_COLOR,
        Text = properties.text or "Кнопка",
        TextColor3 = CONFIG.TEXT_COLOR,
        TextSize = properties.textSize or 16,
        Font = Enum.Font.GothamBold,
        Parent = properties.parent or playerGui,
        BorderSizePixel = 0,
        AutoButtonColor = true,
    })

    local corner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = button,
    })

    if properties.onClick then
        button.MouseButton1Click:Connect(properties.onClick)
    end

    table.insert(GUICreator.CreatedGUIs, button)
    return button
end

function GUICreator.CreateFrame(properties)
    local frame = Utils.Create("Frame", {
        Name = properties.name or "Frame",
        Size = properties.size or UDim2.new(0, 300, 0, 200),
        Position = properties.position or UDim2.new(0.5, -150, 0.5, -100),
        BackgroundColor3 = properties.color or CONFIG.SECONDARY_COLOR,
        Parent = properties.parent or playerGui,
        BorderSizePixel = 0,
    })

    local corner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = frame,
    })

    table.insert(GUICreator.CreatedGUIs, frame)
    return frame
end

function GUICreator.CreateLabel(properties)
    local label = Utils.Create("TextLabel", {
        Name = properties.name or "Label",
        Size = properties.size or UDim2.new(1, 0, 0, 30),
        Position = properties.position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = properties.text or "Текст",
        TextColor3 = properties.color or CONFIG.TEXT_COLOR,
        TextSize = properties.textSize or 14,
        Font = properties.font or Enum.Font.Gotham,
        TextWrapped = true,
        Parent = properties.parent or playerGui,
    })

    table.insert(GUICreator.CreatedGUIs, label)
    return label
end

function GUICreator.CreateTextBox(properties)
    local textBox = Utils.Create("TextBox", {
        Name = properties.name or "TextBox",
        Size = properties.size or UDim2.new(0, 200, 0, 40),
        Position = properties.position or UDim2.new(0.5, -100, 0.5, -20),
        BackgroundColor3 = Color3.fromRGB(64, 68, 75),
        Text = properties.text or "",
        PlaceholderText = properties.placeholder or "Введите текст...",
        TextColor3 = CONFIG.TEXT_COLOR,
        PlaceholderColor3 = CONFIG.DARK_TEXT,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Parent = properties.parent or playerGui,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
    })

    local corner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = textBox,
    })

    table.insert(GUICreator.CreatedGUIs, textBox)
    return textBox
end

function GUICreator.CreateScreenGui(properties)
    local screenGui = Utils.Create("ScreenGui", {
        Name = properties.name or "CustomGUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    table.insert(GUICreator.CreatedGUIs, screenGui)
    return screenGui
end

function GUICreator.DeleteGUI(name)
    for _, gui in ipairs(GUICreator.CreatedGUIs) do
        if gui.Name == name then
            gui:Destroy()
            return true
        end
    end

    -- Также ищем в playerGui
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name == name then
            gui:Destroy()
            return true
        end
    end

    return false
end

function GUICreator.DeleteAll()
    for _, gui in ipairs(GUICreator.CreatedGUIs) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    GUICreator.CreatedGUIs = {}
end

-- ═══════════════════════════════════════════════════════════════
--  ОСНОВНОЙ GUI (КРУГЛАЯ КНОПКА + МЕНЮ)
-- ═══════════════════════════════════════════════════════════════

local MainGUI = {}
MainGUI.ScreenGui = nil
MainGUI.MainButton = nil
MainGUI.MenuFrame = nil
MainGUI.ChatFrame = nil
MainGUI.IsMenuOpen = false
MainGUI.IsChatOpen = false

function MainGUI.Init()
    -- Удаляем старый GUI если есть
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name == "DeltaAIAssistant" then
            gui:Destroy()
        end
    end

    -- ScreenGui
    MainGUI.ScreenGui = Utils.Create("ScreenGui", {
        Name = "DeltaAIAssistant",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- ═══════════════════════════════════════
    --  КРУГЛАЯ КНОПКА (Низ слева)
    -- ═══════════════════════════════════════
    MainGUI.MainButton = Utils.Create("TextButton", {
        Name = "AI_Button",
        Size = UDim2.new(0, CONFIG.BUTTON_SIZE, 0, CONFIG.BUTTON_SIZE),
        Position = CONFIG.BUTTON_POSITION,
        BackgroundColor3 = CONFIG.PRIMARY_COLOR,
        Text = "🤖",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 28,
        Font = Enum.Font.GothamBold,
        Parent = MainGUI.ScreenGui,
        BorderSizePixel = 0,
    })

    local buttonCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0), -- Полностью круглая
        Parent = MainGUI.MainButton,
    })

    local buttonStroke = Utils.Create("UIStroke", {
        Color = Color3.fromRGB(120, 130, 255),
        Thickness = 2,
        Parent = MainGUI.MainButton,
    })

    -- Glow эффект
    local glow = Utils.Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1.5, 0, 1.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4996891979",
        ImageColor3 = CONFIG.PRIMARY_COLOR,
        ImageTransparency = 0.8,
        Parent = MainGUI.MainButton,
    })

    -- Анимация свечения
    spawn(function()
        while MainGUI.MainButton and MainGUI.MainButton.Parent do
            Utils.Tween(glow, {ImageTransparency = 0.6}, 1)
            task.wait(1)
            Utils.Tween(glow, {ImageTransparency = 0.9}, 1)
            task.wait(1)
        end
    end)

    -- Hover эффект
    MainGUI.MainButton.MouseEnter:Connect(function()
        Utils.Tween(MainGUI.MainButton, {Size = UDim2.new(0, CONFIG.BUTTON_SIZE + 8, 0, CONFIG.BUTTON_SIZE + 8)}, 0.2)
        buttonStroke.Color = Color3.fromRGB(160, 170, 255)
    end)

    MainGUI.MainButton.MouseLeave:Connect(function()
        Utils.Tween(MainGUI.MainButton, {Size = UDim2.new(0, CONFIG.BUTTON_SIZE, 0, CONFIG.BUTTON_SIZE)}, 0.2)
        buttonStroke.Color = Color3.fromRGB(120, 130, 255)
    end)

    MainGUI.MainButton.MouseButton1Click:Connect(function()
        MainGUI.ToggleMenu()
    end)

    -- ═══════════════════════════════════════
    --  МЕНЮ (Основное)
    -- ═══════════════════════════════════════
    MainGUI.MenuFrame = Utils.Create("Frame", {
        Name = "Menu",
        Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT),
        Position = UDim2.new(0, 20, 1, -CONFIG.MENU_HEIGHT - 80),
        BackgroundColor3 = CONFIG.SECONDARY_COLOR,
        Parent = MainGUI.ScreenGui,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
    })

    local menuCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = MainGUI.MenuFrame,
    })

    local menuStroke = Utils.Create("UIStroke", {
        Color = Color3.fromRGB(60, 63, 69),
        Thickness = 1,
        Parent = MainGUI.MenuFrame,
    })

    -- Тень
    local menuShadow = Utils.Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Parent = MainGUI.MenuFrame,
    })
    menuShadow.ZIndex = -1

    -- ═══════════════════════════════════════
    --  ЗАГОЛОВОК МЕНЮ
    -- ═══════════════════════════════════════
    local titleBar = Utils.Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(43, 45, 49),
        Parent = MainGUI.MenuFrame,
        BorderSizePixel = 0,
    })

    local titleCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = titleBar,
    })

    -- Исправляем углы заголовка
    local titleFix = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(43, 45, 49),
        Parent = titleBar,
        BorderSizePixel = 0,
    })

    local titleLabel = Utils.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "🤖 Delta AI Assistant",
        TextColor3 = CONFIG.TEXT_COLOR,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Кнопка закрытия
    local closeButton = Utils.Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(240, 71, 71),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = titleBar,
        BorderSizePixel = 0,
    })

    local closeCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = closeButton,
    })

    closeButton.MouseButton1Click:Connect(function()
        MainGUI.ToggleMenu()
    end)

    -- Кнопка свернуть чат
    local chatToggleButton = Utils.Create("TextButton", {
        Name = "ChatToggle",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -75, 0.5, -15),
        BackgroundColor3 = CONFIG.PRIMARY_COLOR,
        Text = "💬",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = titleBar,
        BorderSizePixel = 0,
    })

    local chatToggleCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = chatToggleButton,
    })

    chatToggleButton.MouseButton1Click:Connect(function()
        MainGUI.ToggleChat()
    end)

    -- ═══════════════════════════════════════
    --  КНОПКИ ДЕЙСТВИЙ
    -- ═══════════════════════════════════════
    local actionsFrame = Utils.Create("Frame", {
        Name = "Actions",
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Parent = MainGUI.MenuFrame,
    })

    local actionsLayout = Utils.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = actionsFrame,
    })

    local function CreateActionButton(text, icon, color, callback)
        local btn = Utils.Create("TextButton", {
            Size = UDim2.new(0, 120, 1, 0),
            BackgroundColor3 = color,
            Text = icon .. " " .. text,
            TextColor3 = CONFIG.TEXT_COLOR,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            Parent = actionsFrame,
        })

        local btnCorner = Utils.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = btn,
        })

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Кнопка "Анализировать"
    CreateActionButton("Анализ", "🔍", CONFIG.PRIMARY_COLOR, function()
        MainGUI.RunFullAnalysis()
    end)

    -- Кнопка "Сканер"
    CreateActionButton("Сканер", "📡", CONFIG.SUCCESS_COLOR, function()
        MainGUI.ShowScannerResults()
    end)

    -- Кнопка "Очистить"
    CreateActionButton("Очистить", "🗑️", CONFIG.ERROR_COLOR, function()
        MainGUI.ClearOutput()
    end)

    -- ═══════════════════════════════════════
    --  ОБЛАСТЬ ВЫВОДА
    -- ═══════════════════════════════════════
    local outputFrame = Utils.Create("ScrollingFrame", {
        Name = "Output",
        Size = UDim2.new(1, -20, 0, 280),
        Position = UDim2.new(0, 10, 0, 115),
        BackgroundColor3 = Color3.fromRGB(24, 25, 28),
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.PRIMARY_COLOR,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainGUI.MenuFrame,
    })

    local outputCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = outputFrame,
    })

    local outputPadding = Utils.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = outputFrame,
    })

    local outputLayout = Utils.Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = outputFrame,
    })

    MainGUI.OutputFrame = outputFrame

    -- ═══════════════════════════════════════
    --  СТАТУС БАР
    -- ═══════════════════════════════════════
    local statusBar = Utils.Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 1, -35),
        BackgroundColor3 = Color3.fromRGB(43, 45, 49),
        Parent = MainGUI.MenuFrame,
        BorderSizePixel = 0,
    })

    local statusCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = statusBar,
    })

    MainGUI.StatusLabel = Utils.Create("TextLabel", {
        Name = "Status",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = "✅ Готов к работе",
        TextColor3 = CONFIG.SUCCESS_COLOR,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = statusBar,
    })

    -- ═══════════════════════════════════════
    --  ЧАТ ФРЕЙМ (Скрыт по умолчанию)
    -- ═══════════════════════════════════════
    MainGUI.ChatFrame = Utils.Create("Frame", {
        Name = "ChatFrame",
        Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, 400),
        Position = UDim2.new(0, 20 + CONFIG.MENU_WIDTH + 10, 1, -400 - 80),
        BackgroundColor3 = CONFIG.SECONDARY_COLOR,
        Parent = MainGUI.ScreenGui,
        BorderSizePixel = 0,
        Visible = false,
    })

    local chatCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = MainGUI.ChatFrame,
    })

    local chatStroke = Utils.Create("UIStroke", {
        Color = Color3.fromRGB(60, 63, 69),
        Thickness = 1,
        Parent = MainGUI.ChatFrame,
    })

    -- Заголовок чата
    local chatTitleBar = Utils.Create("Frame", {
        Name = "ChatTitleBar",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(43, 45, 49),
        Parent = MainGUI.ChatFrame,
        BorderSizePixel = 0,
    })

    local chatTitleCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = chatTitleBar,
    })

    local chatTitleFix = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(43, 45, 49),
        Parent = chatTitleBar,
        BorderSizePixel = 0,
    })

    local chatTitleLabel = Utils.Create("TextLabel", {
        Name = "ChatTitle",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "💬 ИИ Чат",
        TextColor3 = CONFIG.TEXT_COLOR,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = chatTitleBar,
    })

    local chatCloseBtn = Utils.Create("TextButton", {
        Name = "ChatClose",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = CONFIG.ERROR_COLOR,
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = chatTitleBar,
        BorderSizePixel = 0,
    })

    local chatCloseCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = chatCloseBtn,
    })

    chatCloseBtn.MouseButton1Click:Connect(function()
        MainGUI.ToggleChat()
    end)

    -- Область сообщений
    local messagesFrame = Utils.Create("ScrollingFrame", {
        Name = "Messages",
        Size = UDim2.new(1, -20, 1, -110),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Color3.fromRGB(24, 25, 28),
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.PRIMARY_COLOR,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainGUI.ChatFrame,
    })

    local messagesCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = messagesFrame,
    })

    local messagesPadding = Utils.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = messagesFrame,
    })

    local messagesLayout = Utils.Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = messagesFrame,
    })

    MainGUI.MessagesFrame = messagesFrame

    -- Поле ввода
    local inputFrame = Utils.Create("Frame", {
        Name = "InputFrame",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 1, -50),
        BackgroundColor3 = Color3.fromRGB(64, 68, 75),
        Parent = MainGUI.ChatFrame,
        BorderSizePixel = 0,
    })

    local inputCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = inputFrame,
    })

    local chatInput = Utils.Create("TextBox", {
        Name = "ChatInput",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Напиши команду ИИ...",
        TextColor3 = CONFIG.TEXT_COLOR,
        PlaceholderColor3 = CONFIG.DARK_TEXT,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })

    local sendButton = Utils.Create("TextButton", {
        Name = "SendButton",
        Size = UDim2.new(0, 40, 0, 32),
        Position = UDim2.new(1, -45, 0.5, -16),
        BackgroundColor3 = CONFIG.PRIMARY_COLOR,
        Text = "➤",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = inputFrame,
        BorderSizePixel = 0,
    })

    local sendCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = sendButton,
    })

    -- Отправка сообщения
    local function SendChatMessage()
        local text = chatInput.Text:gsub("^%s*", ""):gsub("%s*$", "")
        if text == "" then return end

        chatInput.Text = ""
        MainGUI.AddChatMessage("user", text)
        MainGUI.SetStatus("🤖 ИИ думает...", CONFIG.WARNING_COLOR)

        spawn(function()
            local response = GroqClient.SendMessage(text)
            MainGUI.AddChatMessage("assistant", response)
            MainGUI.SetStatus("✅ Готов к работе", CONFIG.SUCCESS_COLOR)
        end)
    end

    sendButton.MouseButton1Click:Connect(SendChatMessage)
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SendChatMessage()
        end
    end)

    -- Drag functionality для меню
    MainGUI.MakeDraggable(MainGUI.MenuFrame, titleBar)
    MainGUI.MakeDraggable(MainGUI.ChatFrame, chatTitleBar)

    -- Приветственное сообщение
    MainGUI.AddOutput("🤖 Delta AI Assistant v2.0 запущен!", CONFIG.PRIMARY_COLOR)
    MainGUI.AddOutput("📍 Нажми кнопку 🔍 Анализ для сканирования игры", CONFIG.DARK_TEXT)
    MainGUI.AddOutput("💬 Нажми 💬 для открытия чата с ИИ", CONFIG.DARK_TEXT)
    MainGUI.AddOutput("⚠️ Не забудь вставить свой GROQ_API_KEY в начало скрипта!", CONFIG.WARNING_COLOR)
end

function MainGUI.MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function MainGUI.ToggleMenu()
    MainGUI.IsMenuOpen = not MainGUI.IsMenuOpen

    if MainGUI.IsMenuOpen then
        MainGUI.MenuFrame.Visible = true
        Utils.Tween(MainGUI.MenuFrame, {Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT)}, 0.3)
        MainGUI.MainButton.Text = "❌"
    else
        Utils.Tween(MainGUI.MenuFrame, {Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, 0)}, 0.2)
        task.wait(0.2)
        MainGUI.MenuFrame.Visible = false
        MainGUI.MainButton.Text = "🤖"
    end
end

function MainGUI.ToggleChat()
    MainGUI.IsChatOpen = not MainGUI.IsChatOpen

    if MainGUI.IsChatOpen then
        MainGUI.ChatFrame.Visible = true
        Utils.Tween(MainGUI.ChatFrame, {Position = UDim2.new(0, 20 + CONFIG.MENU_WIDTH + 10, 1, -400 - 80)}, 0.3)
    else
        Utils.Tween(MainGUI.ChatFrame, {Position = UDim2.new(0, 20 + CONFIG.MENU_WIDTH + 10, 1, -400 - 80)}, 0.2)
        task.wait(0.2)
        MainGUI.ChatFrame.Visible = false
    end
end

function MainGUI.AddOutput(text, color)
    color = color or CONFIG.TEXT_COLOR

    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = MainGUI.OutputFrame,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    -- Автоскролл вниз
    task.wait()
    MainGUI.OutputFrame.CanvasPosition = Vector2.new(0, MainGUI.OutputFrame.AbsoluteCanvasSize.Y)
end

function MainGUI.AddChatMessage(sender, text)
    local isUser = sender == "user"
    local bubbleColor = isUser and CONFIG.PRIMARY_COLOR or Color3.fromRGB(64, 68, 75)
    local textColor = CONFIG.TEXT_COLOR
    local alignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left

    local bubble = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = MainGUI.MessagesFrame,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local innerBubble = Utils.Create("Frame", {
        Size = UDim2.new(0.9, 0, 0, 0),
        Position = isUser and UDim2.new(1, -10, 0, 0) or UDim2.new(0, 10, 0, 0),
        AnchorPoint = isUser and Vector2.new(1, 0) or Vector2.new(0, 0),
        BackgroundColor3 = bubbleColor,
        Parent = bubble,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })

    local innerCorner = Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = innerBubble,
    })

    local padding = Utils.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = innerBubble,
    })

    local senderLabel = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = isUser and "👤 Ты" or "🤖 ИИ",
        TextColor3 = isUser and Color3.fromRGB(180, 190, 255) or Color3.fromRGB(150, 255, 180),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = alignment,
        Parent = innerBubble,
    })

    local messageLabel = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = textColor,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = alignment,
        Parent = innerBubble,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    -- Автоскролл
    task.wait()
    MainGUI.MessagesFrame.CanvasPosition = Vector2.new(0, MainGUI.MessagesFrame.AbsoluteCanvasSize.Y)
end

function MainGUI.SetStatus(text, color)
    MainGUI.StatusLabel.Text = text
    MainGUI.StatusLabel.TextColor3 = color or CONFIG.SUCCESS_COLOR
end

function MainGUI.ClearOutput()
    for _, child in ipairs(MainGUI.OutputFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    MainGUI.AddOutput("🗑️ Вывод очищен", CONFIG.DARK_TEXT)
end

function MainGUI.RunFullAnalysis()
    MainGUI.ClearOutput()
    MainGUI.SetStatus("🔍 Сканирование игры...", CONFIG.WARNING_COLOR)

    spawn(function()
        local results = GameScanner.FullScan()
        local summary = GameScanner.GetSummary()

        MainGUI.AddOutput(summary, CONFIG.TEXT_COLOR)

        -- RemoteEvents
        if #results.remoteEvents > 0 then
            MainGUI.AddOutput("\n📡 REMOTE EVENTS:", CONFIG.PRIMARY_COLOR)
            for i, re in ipairs(results.remoteEvents) do
                if i <= 15 then
                    MainGUI.AddOutput("  • " .. re.name .. " → " .. re.path, CONFIG.DARK_TEXT)
                end
            end
            if #results.remoteEvents > 15 then
                MainGUI.AddOutput("  ... и ещё " .. (#results.remoteEvents - 15), CONFIG.DARK_TEXT)
            end
        end

        -- RemoteFunctions
        if #results.remoteFunctions > 0 then
            MainGUI.AddOutput("\n📡 REMOTE FUNCTIONS:", CONFIG.PRIMARY_COLOR)
            for i, rf in ipairs(results.remoteFunctions) do
                if i <= 15 then
                    MainGUI.AddOutput("  • " .. rf.name .. " → " .. rf.path, CONFIG.DARK_TEXT)
                end
            end
            if #results.remoteFunctions > 15 then
                MainGUI.AddOutput("  ... и ещё " .. (#results.remoteFunctions - 15), CONFIG.DARK_TEXT)
            end
        end

        -- AntiCheats
        if #results.antiCheats > 0 then
            MainGUI.AddOutput("\n🚨 АНТИ-ЧИТЫ ОБНАРУЖЕНЫ:", CONFIG.ERROR_COLOR)
            for _, ac in ipairs(results.antiCheats) do
                MainGUI.AddOutput("  ⚠️ " .. ac.name .. " (" .. ac.className .. ")", CONFIG.WARNING_COLOR)
            end
        end

        MainGUI.SetStatus("✅ Анализ завершён!", CONFIG.SUCCESS_COLOR)
    end)
end

function MainGUI.ShowScannerResults()
    MainGUI.ClearOutput()
    local results = GameScanner.Results

    MainGUI.AddOutput("📊 ДЕТАЛЬНЫЙ СКАНЕР", CONFIG.PRIMARY_COLOR)
    MainGUI.AddOutput("═══════════════════════", CONFIG.DARK_TEXT)

    for category, items in pairs(results) do
        if #items > 0 then
            MainGUI.AddOutput("\n📁 " .. category:upper() .. ": " .. #items, CONFIG.WARNING_COLOR)
            for i, item in ipairs(items) do
                if i <= 10 then
                    local text = "  • " .. item.name
                    if item.path then text = text .. " (" .. item.path .. ")" end
                    MainGUI.AddOutput(text, CONFIG.DARK_TEXT)
                end
            end
            if #items > 10 then
                MainGUI.AddOutput("  ... и ещё " .. (#items - 10), CONFIG.DARK_TEXT)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
--  ИНИЦИАЛИЗАЦИЯ
-- ═══════════════════════════════════════════════════════════════

MainGUI.Init()

print("🤖 Delta AI Assistant v2.0 загружен!")
print("📍 Кнопка ИИ внизу слева — нажми для открытия меню")
print("🔑 Не забудь настроить GROQ_API_KEY!")
