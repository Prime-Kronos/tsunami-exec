-- ================================================
--   Primejtsu X | Chat v1.0
--   Мессенджер внутри Roblox
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LP               = Players.LocalPlayer

local BIN_KEY   = "$2a$10$.nVyE4S9KNEwrKHlU.freOXAxkC7ddIvkt8iwZo5p83UQerKVB.BC"
local BIN_URL   = "https://api.jsonbin.io/v3/b"
local BIN_HDR   = {
    ["Content-Type"] = "application/json",
    ["X-Master-Key"] = "$2a$10$.nVyE4S9KNEwrKHlU.freOXAxkC7ddIvkt8iwZo5p83UQerKVB.BC",
    ["X-Bin-Private"] = "false",
}

-- ================================================
-- HTTP
-- ================================================
local function httpReq(url, method, headers, body)
    local fn = request or http_request or (syn and syn.request)
    if not fn then return nil, "No HTTP function" end
    local ok, res = pcall(fn, {Url=url, Method=method, Headers=headers, Body=body})
    if not ok then return nil, tostring(res) end
    return res, nil
end

local UPDATE_INTERVAL = 2

local function createBin(data, callback)
    local body = HttpService:JSONEncode(data)
    local res, err = httpReq(BIN_URL, "POST", BIN_HDR, body)
    if err or not res then callback(nil, tostring(err)); return end
    if res.StatusCode ~= 200 then callback(nil, "Error "..res.StatusCode..": "..tostring(res.Body):sub(1,80)); return end
    local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
    if not ok then callback(nil, "JSON error"); return end
    callback(parsed.metadata.id, nil)
end

local function readBin(binId, callback)
    local res, err = httpReq(BIN_URL.."/"..binId.."/latest", "GET", {
        ["X-Master-Key"] = BIN_HDR["X-Master-Key"],
    }, nil)
    if err or not res then callback(nil, tostring(err)); return end
    if res.StatusCode ~= 200 then callback(nil, "Error "..res.StatusCode); return end
    local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
    if not ok then callback(nil, "JSON error"); return end
    callback(parsed.record, nil)
end

local function updateBin(binId, data, callback)
    local body = HttpService:JSONEncode(data)
    local res, err = httpReq(BIN_URL.."/"..binId, "PUT", {
        ["Content-Type"] = "application/json",
        ["X-Master-Key"] = BIN_HDR["X-Master-Key"],
    }, body)
    if err or not res then if callback then callback(false) end; return end
    if callback then callback(res.StatusCode == 200) end
end

-- ================================================
-- СОСТОЯНИЕ
-- ================================================
local myNick    = LP.Name
local activeBin = nil       -- ID текущей комнаты
local lastMsgCount = 0
local updateConn   = nil
local onlineUsers  = {}     -- {nick, binId, lastSeen}
local LOBBY_BIN    = nil    -- общий бин лобби

-- ================================================
-- GUI
-- ================================================
local oldGui = LP.PlayerGui:FindFirstChild("PX_Chat")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name="PX_Chat"; Gui.ResetOnSpawn=false; Gui.DisplayOrder=998
Gui.Parent=LP.PlayerGui

-- Главное окно
local Main = Instance.new("Frame", Gui)
Main.Size=UDim2.new(0,280,0,380)
Main.Position=UDim2.new(0.5,-140,0.5,-190)
Main.BackgroundColor3=Color3.fromRGB(10,12,20)
Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(0,150,255); ms.Thickness=1.5

-- Тайтл
local TB=Instance.new("Frame",Main)
TB.Size=UDim2.new(1,0,0,36); TB.BackgroundColor3=Color3.fromRGB(0,100,200)
TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,12)
local tbfix=Instance.new("Frame",TB)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(0,100,200); tbfix.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-70,1,0); TL.Position=UDim2.new(0,12,0,0)
TL.BackgroundTransparency=1; TL.TextColor3=Color3.fromRGB(255,255,255)
TL.TextSize=13; TL.Font=Enum.Font.GothamBold
TL.Text="PX Chat | "..myNick; TL.TextXAlignment=Enum.TextXAlignment.Left

local function mkBtn(txt, xOff, col)
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2.new(0,26,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=col; b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=10
    b.Font=Enum.Font.GothamBold; b.Text=txt; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    return b
end
local MinBtn = mkBtn("_",-58,Color3.fromRGB(40,40,80))
local XBtn   = mkBtn("X",-28,Color3.fromRGB(150,0,40))

-- ================================================
-- СТРАНИЦА 1: ЛОББИ (поиск / список онлайн)
-- ================================================
local LobbyPage = Instance.new("Frame",Main)
LobbyPage.Size=UDim2.new(1,0,1,-36); LobbyPage.Position=UDim2.new(0,0,0,36)
LobbyPage.BackgroundTransparency=1; LobbyPage.BorderSizePixel=0

-- Заголовок
local lobbyTitle=Instance.new("TextLabel",LobbyPage)
lobbyTitle.Size=UDim2.new(1,-12,0,20); lobbyTitle.Position=UDim2.new(0,6,0,6)
lobbyTitle.BackgroundTransparency=1; lobbyTitle.TextColor3=Color3.fromRGB(100,180,255)
lobbyTitle.TextSize=11; lobbyTitle.Font=Enum.Font.GothamBold
lobbyTitle.Text="Онлайн игроки со скриптом:"
lobbyTitle.TextXAlignment=Enum.TextXAlignment.Left

-- Список онлайн
local OnlineScroll=Instance.new("ScrollingFrame",LobbyPage)
OnlineScroll.Size=UDim2.new(1,-12,0,140); OnlineScroll.Position=UDim2.new(0,6,0,30)
OnlineScroll.BackgroundColor3=Color3.fromRGB(14,16,26); OnlineScroll.BorderSizePixel=0
OnlineScroll.ScrollBarThickness=3; OnlineScroll.ScrollBarImageColor3=Color3.fromRGB(0,150,255)
OnlineScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; OnlineScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",OnlineScroll).CornerRadius=UDim.new(0,8)
local OL=Instance.new("UIListLayout",OnlineScroll)
OL.Padding=UDim.new(0,4); OL.SortOrder=Enum.SortOrder.LayoutOrder
local OP=Instance.new("UIPadding",OnlineScroll)
OP.PaddingLeft=UDim.new(0,5); OP.PaddingRight=UDim.new(0,5)
OP.PaddingTop=UDim.new(0,5); OP.PaddingBottom=UDim.new(0,5)

-- Поиск
local searchTitle=Instance.new("TextLabel",LobbyPage)
searchTitle.Size=UDim2.new(1,-12,0,16); searchTitle.Position=UDim2.new(0,6,0,178)
searchTitle.BackgroundTransparency=1; searchTitle.TextColor3=Color3.fromRGB(150,150,200)
searchTitle.TextSize=10; searchTitle.Font=Enum.Font.Gotham
searchTitle.Text="Или введи ID комнаты чтобы присоединиться:"
searchTitle.TextXAlignment=Enum.TextXAlignment.Left

local SearchFrame=Instance.new("Frame",LobbyPage)
SearchFrame.Size=UDim2.new(1,-12,0,32); SearchFrame.Position=UDim2.new(0,6,0,197)
SearchFrame.BackgroundColor3=Color3.fromRGB(18,20,32); SearchFrame.BorderSizePixel=0
Instance.new("UICorner",SearchFrame).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",SearchFrame).Color=Color3.fromRGB(0,120,220)

local SearchBox=Instance.new("TextBox",SearchFrame)
SearchBox.Size=UDim2.new(1,-70,1,0); SearchBox.Position=UDim2.new(0,8,0,0)
SearchBox.BackgroundTransparency=1; SearchBox.TextColor3=Color3.fromRGB(200,220,255)
SearchBox.PlaceholderText="Введи Room ID..."; SearchBox.PlaceholderColor3=Color3.fromRGB(80,80,120)
SearchBox.TextSize=11; SearchBox.Font=Enum.Font.Gotham
SearchBox.TextXAlignment=Enum.TextXAlignment.Left; SearchBox.ClearTextOnFocus=false; SearchBox.Text=""

local JoinBtn=Instance.new("TextButton",SearchFrame)
JoinBtn.Size=UDim2.new(0,60,1,-4); JoinBtn.Position=UDim2.new(1,-64,0,2)
JoinBtn.BackgroundColor3=Color3.fromRGB(0,120,220); JoinBtn.BorderSizePixel=0
JoinBtn.TextColor3=Color3.fromRGB(255,255,255); JoinBtn.TextSize=11
JoinBtn.Font=Enum.Font.GothamBold; JoinBtn.Text="Join"; JoinBtn.AutoButtonColor=false
Instance.new("UICorner",JoinBtn).CornerRadius=UDim.new(0,6)

-- Кнопка создать комнату
local CreateBtn=Instance.new("TextButton",LobbyPage)
CreateBtn.Size=UDim2.new(1,-12,0,34); CreateBtn.Position=UDim2.new(0,6,0,234)
CreateBtn.BackgroundColor3=Color3.fromRGB(0,140,60); CreateBtn.BorderSizePixel=0
CreateBtn.TextColor3=Color3.fromRGB(255,255,255); CreateBtn.TextSize=13
CreateBtn.Font=Enum.Font.GothamBold; CreateBtn.Text="+ Создать комнату"; CreateBtn.AutoButtonColor=false
Instance.new("UICorner",CreateBtn).CornerRadius=UDim.new(0,8)

-- Статус лобби
local LobbyStatus=Instance.new("TextLabel",LobbyPage)
LobbyStatus.Size=UDim2.new(1,-12,0,14); LobbyStatus.Position=UDim2.new(0,6,0,272)
LobbyStatus.BackgroundTransparency=1; LobbyStatus.TextColor3=Color3.fromRGB(100,100,150)
LobbyStatus.TextSize=9; LobbyStatus.Font=Enum.Font.Gotham
LobbyStatus.Text="Подключение к лобби..."
LobbyStatus.TextXAlignment=Enum.TextXAlignment.Left

-- ================================================
-- СТРАНИЦА 2: ЧАТ
-- ================================================
local ChatPage=Instance.new("Frame",Main)
ChatPage.Size=UDim2.new(1,0,1,-36); ChatPage.Position=UDim2.new(0,0,0,36)
ChatPage.BackgroundTransparency=1; ChatPage.BorderSizePixel=0; ChatPage.Visible=false

-- Инфо комнаты
local RoomInfo=Instance.new("Frame",ChatPage)
RoomInfo.Size=UDim2.new(1,-12,0,28); RoomInfo.Position=UDim2.new(0,6,0,4)
RoomInfo.BackgroundColor3=Color3.fromRGB(14,16,26); RoomInfo.BorderSizePixel=0
Instance.new("UICorner",RoomInfo).CornerRadius=UDim.new(0,6)

local RoomLabel=Instance.new("TextLabel",RoomInfo)
RoomLabel.Size=UDim2.new(1,-60,1,0); RoomLabel.Position=UDim2.new(0,8,0,0)
RoomLabel.BackgroundTransparency=1; RoomLabel.TextColor3=Color3.fromRGB(100,200,255)
RoomLabel.TextSize=10; RoomLabel.Font=Enum.Font.GothamBold; RoomLabel.Text="Room: ..."
RoomLabel.TextXAlignment=Enum.TextXAlignment.Left

local BackBtn=Instance.new("TextButton",RoomInfo)
BackBtn.Size=UDim2.new(0,50,1,-4); BackBtn.Position=UDim2.new(1,-54,0,2)
BackBtn.BackgroundColor3=Color3.fromRGB(100,0,40); BackBtn.BorderSizePixel=0
BackBtn.TextColor3=Color3.fromRGB(255,255,255); BackBtn.TextSize=10
BackBtn.Font=Enum.Font.GothamBold; BackBtn.Text="Выйти"; BackBtn.AutoButtonColor=false
Instance.new("UICorner",BackBtn).CornerRadius=UDim.new(0,5)

-- Чат сообщения
local ChatScroll=Instance.new("ScrollingFrame",ChatPage)
ChatScroll.Size=UDim2.new(1,-12,1,-100); ChatScroll.Position=UDim2.new(0,6,0,36)
ChatScroll.BackgroundColor3=Color3.fromRGB(14,16,26); ChatScroll.BorderSizePixel=0
ChatScroll.ScrollBarThickness=3; ChatScroll.ScrollBarImageColor3=Color3.fromRGB(0,150,255)
ChatScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; ChatScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",ChatScroll).CornerRadius=UDim.new(0,8)
local CL=Instance.new("UIListLayout",ChatScroll)
CL.Padding=UDim.new(0,4); CL.SortOrder=Enum.SortOrder.LayoutOrder
local CP=Instance.new("UIPadding",ChatScroll)
CP.PaddingLeft=UDim.new(0,5); CP.PaddingRight=UDim.new(0,5)
CP.PaddingTop=UDim.new(0,5); CP.PaddingBottom=UDim.new(0,5)

-- ID комнаты (копировать)
local RoomIdFrame=Instance.new("Frame",ChatPage)
RoomIdFrame.Size=UDim2.new(1,-12,0,22); RoomIdFrame.Position=UDim2.new(0,6,1,-60)
RoomIdFrame.BackgroundColor3=Color3.fromRGB(14,16,26); RoomIdFrame.BorderSizePixel=0
Instance.new("UICorner",RoomIdFrame).CornerRadius=UDim.new(0,5)

local RoomIdLabel=Instance.new("TextLabel",RoomIdFrame)
RoomIdLabel.Size=UDim2.new(1,-70,1,0); RoomIdLabel.Position=UDim2.new(0,6,0,0)
RoomIdLabel.BackgroundTransparency=1; RoomIdLabel.TextColor3=Color3.fromRGB(150,150,200)
RoomIdLabel.TextSize=9; RoomIdLabel.Font=Enum.Font.Gotham
RoomIdLabel.Text="Room ID: ..."; RoomIdLabel.TextXAlignment=Enum.TextXAlignment.Left

local CopyBtn=Instance.new("TextButton",RoomIdFrame)
CopyBtn.Size=UDim2.new(0,60,1,-2); CopyBtn.Position=UDim2.new(1,-62,0,1)
CopyBtn.BackgroundColor3=Color3.fromRGB(0,100,180); CopyBtn.BorderSizePixel=0
CopyBtn.TextColor3=Color3.fromRGB(255,255,255); CopyBtn.TextSize=9
CopyBtn.Font=Enum.Font.GothamBold; CopyBtn.Text="Скопировать"; CopyBtn.AutoButtonColor=false
Instance.new("UICorner",CopyBtn).CornerRadius=UDim.new(0,4)

-- Инпут
local MsgFrame=Instance.new("Frame",ChatPage)
MsgFrame.Size=UDim2.new(1,-12,0,32); MsgFrame.Position=UDim2.new(0,6,1,-34)
MsgFrame.BackgroundColor3=Color3.fromRGB(18,20,32); MsgFrame.BorderSizePixel=0
Instance.new("UICorner",MsgFrame).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",MsgFrame).Color=Color3.fromRGB(0,120,220)

local MsgBox=Instance.new("TextBox",MsgFrame)
MsgBox.Size=UDim2.new(1,-44,1,0); MsgBox.Position=UDim2.new(0,8,0,0)
MsgBox.BackgroundTransparency=1; MsgBox.TextColor3=Color3.fromRGB(200,220,255)
MsgBox.PlaceholderText="Сообщение..."; MsgBox.PlaceholderColor3=Color3.fromRGB(80,80,120)
MsgBox.TextSize=11; MsgBox.Font=Enum.Font.Gotham
MsgBox.TextXAlignment=Enum.TextXAlignment.Left; MsgBox.ClearTextOnFocus=false; MsgBox.Text=""

local MsgSend=Instance.new("TextButton",MsgFrame)
MsgSend.Size=UDim2.new(0,36,1,-4); MsgSend.Position=UDim2.new(1,-40,0,2)
MsgSend.BackgroundColor3=Color3.fromRGB(0,140,220); MsgSend.BorderSizePixel=0
MsgSend.TextColor3=Color3.fromRGB(255,255,255); MsgSend.TextSize=16
MsgSend.Font=Enum.Font.GothamBold; MsgSend.Text=">"; MsgSend.AutoButtonColor=false
Instance.new("UICorner",MsgSend).CornerRadius=UDim.new(0,6)

-- Кнопка чата (когда скрыт)
local ChatBtn=Instance.new("TextButton",Gui)
ChatBtn.Size=UDim2.new(0,42,0,42); ChatBtn.Position=UDim2.new(0,8,0.5,-21)
ChatBtn.BackgroundColor3=Color3.fromRGB(0,100,200); ChatBtn.BorderSizePixel=0
ChatBtn.TextColor3=Color3.fromRGB(255,255,255); ChatBtn.TextSize=11
ChatBtn.Font=Enum.Font.GothamBold; ChatBtn.Text="💬"; ChatBtn.AutoButtonColor=false; ChatBtn.Visible=false
Instance.new("UICorner",ChatBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",ChatBtn).Color=Color3.fromRGB(0,180,255)

XBtn.MouseButton1Click:Connect(function() Main.Visible=false; ChatBtn.Visible=true end)
ChatBtn.MouseButton1Click:Connect(function() Main.Visible=true; ChatBtn.Visible=false end)

local collapsed=false
MinBtn.MouseButton1Click:Connect(function()
    collapsed=not collapsed
    LobbyPage.Visible=not collapsed; ChatPage.Visible= (not collapsed) and (activeBin~=nil)
    Main.Size=collapsed and UDim2.new(0,280,0,36) or UDim2.new(0,280,0,380)
end)

-- ================================================
-- ФУНКЦИИ ЧАТА
-- ================================================
local msgCounter=0

local function addChatMsg(nick, text, isMe)
    msgCounter=msgCounter+1
    local bg=Instance.new("Frame",ChatScroll)
    bg.LayoutOrder=msgCounter; bg.AutomaticSize=Enum.AutomaticSize.Y
    bg.Size=UDim2.new(1,0,0,0); bg.BorderSizePixel=0
    bg.BackgroundColor3=isMe and Color3.fromRGB(0,60,120) or Color3.fromRGB(20,20,36)
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
    local p=Instance.new("UIPadding",bg)
    p.PaddingLeft=UDim.new(0,6); p.PaddingRight=UDim.new(0,6)
    p.PaddingTop=UDim.new(0,4); p.PaddingBottom=UDim.new(0,4)

    local nickLbl=Instance.new("TextLabel",bg)
    nickLbl.Size=UDim2.new(1,0,0,12); nickLbl.BackgroundTransparency=1
    nickLbl.TextColor3=isMe and Color3.fromRGB(100,180,255) or Color3.fromRGB(255,180,100)
    nickLbl.TextSize=9; nickLbl.Font=Enum.Font.GothamBold
    nickLbl.Text=nick..(isMe and " (ты)" or ""); nickLbl.TextXAlignment=Enum.TextXAlignment.Left

    local txtLbl=Instance.new("TextLabel",bg)
    txtLbl.Size=UDim2.new(1,0,0,0); txtLbl.Position=UDim2.new(0,0,0,14)
    txtLbl.AutomaticSize=Enum.AutomaticSize.Y; txtLbl.BackgroundTransparency=1
    txtLbl.TextColor3=Color3.fromRGB(220,220,255); txtLbl.TextSize=11
    txtLbl.Font=Enum.Font.Gotham; txtLbl.TextWrapped=true
    txtLbl.TextXAlignment=Enum.TextXAlignment.Left; txtLbl.Text=text

    task.wait(0.03)
    ChatScroll.CanvasPosition=Vector2.new(0,999999)
end

local function addOnlineUser(nick, binId)
    -- Добавляем в список онлайн
    for _,v in pairs(OnlineScroll:GetChildren()) do
        if v:IsA("Frame") and v.Name==nick then return end
    end

    local row=Instance.new("Frame",OnlineScroll)
    row.Name=nick; row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=Color3.fromRGB(18,22,36)
    row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)

    local dot=Instance.new("Frame",row)
    dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,8,0.5,-4)
    dot.BackgroundColor3=Color3.fromRGB(0,255,100); dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,4)

    local nl=Instance.new("TextLabel",row)
    nl.Size=UDim2.new(1,-80,1,0); nl.Position=UDim2.new(0,24,0,0)
    nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(200,220,255)
    nl.TextSize=11; nl.Font=Enum.Font.GothamBold; nl.Text=nick
    nl.TextXAlignment=Enum.TextXAlignment.Left

    local msgBtn=Instance.new("TextButton",row)
    msgBtn.Size=UDim2.new(0,60,1,-6); msgBtn.Position=UDim2.new(1,-64,0,3)
    msgBtn.BackgroundColor3=Color3.fromRGB(0,100,200); msgBtn.BorderSizePixel=0
    msgBtn.TextColor3=Color3.fromRGB(255,255,255); msgBtn.TextSize=10
    msgBtn.Font=Enum.Font.GothamBold; msgBtn.Text="Написать"; msgBtn.AutoButtonColor=false
    Instance.new("UICorner",msgBtn).CornerRadius=UDim.new(0,4)

    msgBtn.MouseButton1Click:Connect(function()
        -- Присоединяемся к его комнате
        if binId then
            activeBin=binId
            RoomLabel.Text="Чат с " .. nick
            RoomIdLabel.Text="Room ID: " .. binId
            LobbyPage.Visible=false; ChatPage.Visible=true
            msgCounter=0
            for _,v in pairs(ChatScroll:GetChildren()) do
                if v:IsA("Frame") then v:Destroy() end
            end
            addChatMsg("Система","Вы присоединились к чату с "..nick, false)
            lastMsgCount=0
        end
    end)
end

-- ================================================
-- ЛОББИ БИН (общий список онлайн)
-- ================================================
local LOBBY_BIN_ID = nil

local function initLobby()
    -- Ищем или создаём лобби бин
    -- Используем фиксированный ID который все знают
    -- Создаём свой бин для комнаты
    local myRoomData = {
        messages = {},
        created  = os.time(),
    }

    createBin(myRoomData, function(binId, err)
        if err or not binId then
            LobbyStatus.Text="Ошибка подключения: "..tostring(err)
            return
        end

        -- Сохраняем свой bin ID
        _G.PX_MyRoomBin = binId
        LobbyStatus.Text="Твой Room ID: " .. binId .. " | Скопируй и поделись!"

        -- Создаём лобби бин с нашим ником и room id
        local lobbyData = {
            users = {{nick=myNick, roomBin=binId, time=os.time()}}
        }

        createBin(lobbyData, function(lobbyId, lerr)
            if lobbyId then
                LOBBY_BIN_ID = lobbyId
                _G.PX_LobbyBin = lobbyId
                LobbyStatus.Text="Онлайн! Room ID: " .. binId
            end
        end)
    end)
end

-- ================================================
-- СОЗДАТЬ КОМНАТУ
-- ================================================
CreateBtn.MouseButton1Click:Connect(function()
    CreateBtn.Text="Создаю..."
    CreateBtn.BackgroundColor3=Color3.fromRGB(0,100,40)

    local roomData = {messages={}, owner=myNick, created=os.time()}

    createBin(roomData, function(binId, err)
        if err or not binId then
            CreateBtn.Text="+ Создать комнату"
            CreateBtn.BackgroundColor3=Color3.fromRGB(0,140,60)
            LobbyStatus.Text="Ошибка: "..tostring(err)
            return
        end

        activeBin=binId
        _G.PX_MyRoomBin=binId
        RoomLabel.Text="Моя комната | " .. myNick
        RoomIdLabel.Text="Room ID: " .. binId
        LobbyPage.Visible=false; ChatPage.Visible=true
        msgCounter=0
        addChatMsg("Система","Комната создана! ID: "..binId.."\nПоделись этим ID с другом!", false)
        lastMsgCount=0

        CreateBtn.Text="+ Создать комнату"
        CreateBtn.BackgroundColor3=Color3.fromRGB(0,140,60)
    end)
end)

-- ================================================
-- ПРИСОЕДИНИТЬСЯ ПО ID
-- ================================================
JoinBtn.MouseButton1Click:Connect(function()
    local roomId = SearchBox.Text:match("^%s*(.-)%s*$")
    if roomId=="" then return end

    JoinBtn.Text="..."; JoinBtn.BackgroundColor3=Color3.fromRGB(0,80,160)

    readBin(roomId, function(data, err)
        JoinBtn.Text="Join"; JoinBtn.BackgroundColor3=Color3.fromRGB(0,120,220)

        if err or not data then
            LobbyStatus.Text="Не найдено: "..tostring(err)
            return
        end

        activeBin=roomId
        RoomLabel.Text="Комната: " .. roomId:sub(1,8).."..."
        RoomIdLabel.Text="Room ID: " .. roomId
        LobbyPage.Visible=false; ChatPage.Visible=true
        msgCounter=0
        for _,v in pairs(ChatScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end

        -- Загружаем историю сообщений
        if data.messages then
            for _,msg in ipairs(data.messages) do
                addChatMsg(msg.nick, msg.text, msg.nick==myNick)
            end
            lastMsgCount=#data.messages
        end

        addChatMsg("Система","Вы подключились к комнате!", false)
        SearchBox.Text=""
    end)
end)

-- ================================================
-- ВЫЙТИ ИЗ КОМНАТЫ
-- ================================================
BackBtn.MouseButton1Click:Connect(function()
    if updateConn then updateConn:Disconnect(); updateConn=nil end
    activeBin=nil; lastMsgCount=0
    ChatPage.Visible=false; LobbyPage.Visible=true
    for _,v in pairs(ChatScroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    msgCounter=0
end)

-- ================================================
-- КОПИРОВАТЬ ROOM ID
-- ================================================
CopyBtn.MouseButton1Click:Connect(function()
    if activeBin then
        setclipboard(activeBin)
        CopyBtn.Text="✓ Скопировано"
        task.delay(2,function() CopyBtn.Text="Скопировать" end)
    end
end)

-- ================================================
-- ОТПРАВИТЬ СООБЩЕНИЕ
-- ================================================
local function sendMessage()
    local txt=MsgBox.Text:match("^%s*(.-)%s*$")
    if txt=="" or not activeBin then return end
    MsgBox.Text=""
    MsgSend.Text="..."

    -- Читаем текущие сообщения
    readBin(activeBin, function(data, err)
        MsgSend.Text=">"
        if err or not data then return end

        local msgs = data.messages or {}
        -- Ограничиваем до 50 сообщений
        if #msgs >= 50 then
            table.remove(msgs, 1)
        end
        table.insert(msgs, {nick=myNick, text=txt, time=os.time()})

        -- Сохраняем обратно
        local newData = {messages=msgs, owner=data.owner or myNick}
        updateBin(activeBin, newData, function(ok)
            if ok then
                addChatMsg(myNick, txt, true)
                lastMsgCount=#msgs
            end
        end)
    end)
end

MsgSend.MouseButton1Click:Connect(sendMessage)
MsgBox.FocusLost:Connect(function(e) if e then sendMessage() end end)

-- ================================================
-- АВТО-ОБНОВЛЕНИЕ СООБЩЕНИЙ
-- ================================================
task.spawn(function()
    while true do
        task.wait(UPDATE_INTERVAL)
        if activeBin then
            readBin(activeBin, function(data, err)
                if err or not data then return end
                local msgs = data.messages or {}
                if #msgs > lastMsgCount then
                    for i=lastMsgCount+1, #msgs do
                        local msg=msgs[i]
                        if msg.nick ~= myNick then
                            addChatMsg(msg.nick, msg.text, false)
                        end
                    end
                    lastMsgCount=#msgs
                end
            end)
        end
    end
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local drg,ds,sp=false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then drg=true;ds=i.Position;sp=Main.Position end
end)
UserInputService.InputChanged:Connect(function(i)
    if not drg then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement
    or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-ds
        Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)

-- ================================================
-- СТАРТ
-- ================================================
task.wait(0.5)
initLobby()
print("[PX] Chat v1.0 Loaded! Nick: "..myNick)
