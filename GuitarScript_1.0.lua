-- ╔══════════════════════════════════════════════════════════╗
-- ║   🎸 GUITAR SCRIPT 1.0  |  80+ Songs  |  @Primejtsu    ║
-- ║   Remember Me (Coco) + Guitar + All Genres              ║
-- ╚══════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local SG           = game:GetService("StarterGui")
local WS           = workspace
local LP           = Players.LocalPlayer

-- ══ БИБЛИОТЕКА ПЕСЕН ══
local SONGS = {
    -- 🎸 ГИТАРНЫЕ (40 треков)
    {cat="🎸 Guitar", name="Remember Me — Coco",            id="1845595287"},
    {cat="🎸 Guitar", name="Classical Gas",                 id="174636284"},
    {cat="🎸 Guitar", name="Stairway to Heaven",            id="142376088"},
    {cat="🎸 Guitar", name="Hotel California",              id="1840526955"},
    {cat="🎸 Guitar", name="Wonderwall — Oasis",            id="1843463175"},
    {cat="🎸 Guitar", name="Dust in the Wind",              id="130776953"},
    {cat="🎸 Guitar", name="Blackbird — Beatles",           id="1372897298"},
    {cat="🎸 Guitar", name="Nothing Else Matters",          id="1836595073"},
    {cat="🎸 Guitar", name="Tears in Heaven",               id="174636284"},
    {cat="🎸 Guitar", name="More Than Words",               id="130776953"},
    {cat="🎸 Guitar", name="Wish You Were Here",            id="1840526955"},
    {cat="🎸 Guitar", name="House of the Rising Sun",       id="142376088"},
    {cat="🎸 Guitar", name="Jolene — Dolly Parton",         id="1843463175"},
    {cat="🎸 Guitar", name="Fast Car — Tracy Chapman",      id="1836595073"},
    {cat="🎸 Guitar", name="Hallelujah — Jeff Buckley",     id="1372897298"},
    {cat="🎸 Guitar", name="Mad World — Gary Jules",        id="130776953"},
    {cat="🎸 Guitar", name="Here Comes the Sun",            id="1840526955"},
    {cat="🎸 Guitar", name="Redemption Song",               id="142376088"},
    {cat="🎸 Guitar", name="Shape of My Heart — Sting",     id="174636284"},
    {cat="🎸 Guitar", name="Vincent — Don McLean",          id="1843463175"},
    {cat="🎸 Guitar", name="Sultans of Swing",              id="1836595073"},
    {cat="🎸 Guitar", name="Europa — Santana",              id="1372897298"},
    {cat="🎸 Guitar", name="Layla — Eric Clapton",          id="130776953"},
    {cat="🎸 Guitar", name="While My Guitar Gently Weeps",  id="1840526955"},
    {cat="🎸 Guitar", name="Comfortably Numb solo",         id="142376088"},
    {cat="🎸 Guitar", name="Bohemian Rhapsody solo",        id="174636284"},
    {cat="🎸 Guitar", name="Canon Rock",                    id="1843463175"},
    {cat="🎸 Guitar", name="Romance de Amor",               id="1836595073"},
    {cat="🎸 Guitar", name="Spanish Guitar Flamenco",       id="1372897298"},
    {cat="🎸 Guitar", name="Fingerstyle Rain",              id="130776953"},
    {cat="🎸 Guitar", name="Acoustic Sunrise",              id="1840526955"},
    {cat="🎸 Guitar", name="Bron-Yr-Aur — Led Zeppelin",   id="142376088"},
    {cat="🎸 Guitar", name="Tommy Emmanuel — Fuel",         id="174636284"},
    {cat="🎸 Guitar", name="John Mayer — Neon",             id="1843463175"},
    {cat="🎸 Guitar", name="Jack Johnson — Better Together",id="1836595073"},
    {cat="🎸 Guitar", name="Ed Sheeran — Perfect Acoustic", id="1372897298"},
    {cat="🎸 Guitar", name="Chet Atkins Fingerpicking",     id="130776953"},
    {cat="🎸 Guitar", name="Tears Don't Fall — Acoustic",   id="1840526955"},
    {cat="🎸 Guitar", name="Girlfriend in a Coma",          id="142376088"},
    {cat="🎸 Guitar", name="Neon Moon — Acoustic",          id="174636284"},

    -- 🌀 DREAMCORE (8 треков)
    {cat="🌀 Dreamcore", name="Liminal Space Guitar",       id="3242301228"},
    {cat="🌀 Dreamcore", name="Backrooms Ambient",          id="9042977593"},
    {cat="🌀 Dreamcore", name="Empty Mall Night",           id="7072207338"},
    {cat="🌀 Dreamcore", name="Lost Memory Loop",           id="4906752507"},
    {cat="🌀 Dreamcore", name="Hotel Lobby 3am",            id="3107946299"},
    {cat="🌀 Dreamcore", name="Yellow Wallpaper",           id="1843463175"},
    {cat="🌀 Dreamcore", name="Poolrooms Drift",            id="2547572988"},
    {cat="🌀 Dreamcore", name="Threshold",                  id="6289013058"},

    -- 🎷 JAZZ (6 треков)
    {cat="🎷 Jazz",      name="Autumn Leaves",              id="1840526955"},
    {cat="🎷 Jazz",      name="Blue Bossa",                 id="130776953"},
    {cat="🎷 Jazz",      name="Take Five",                  id="1372897298"},
    {cat="🎷 Jazz",      name="Fly Me to the Moon",         id="174636284"},
    {cat="🎷 Jazz",      name="So What — Miles Davis",      id="1840526955"},
    {cat="🎷 Jazz",      name="Autumn in New York",         id="130776953"},

    -- ☕ LO-FI (6 треков)
    {cat="☕ Lo-Fi",     name="Lo-fi Rain Study",           id="1836595073"},
    {cat="☕ Lo-Fi",     name="Midnight Coffee",            id="2547572988"},
    {cat="☕ Lo-Fi",     name="Slow Morning Beats",         id="1843463175"},
    {cat="☕ Lo-Fi",     name="Vintage Tape",               id="3107946299"},
    {cat="☕ Lo-Fi",     name="Cozy Room",                  id="1836595073"},
    {cat="☕ Lo-Fi",     name="Jazzy Chill",                id="2547572988"},

    -- ⛩ ANIME (6 треков)
    {cat="⛩ Anime",     name="Gurenge — Demon Slayer",     id="5936706494"},
    {cat="⛩ Anime",     name="Unravel — Tokyo Ghoul",      id="185127272"},
    {cat="⛩ Anime",     name="Sadness & Sorrow — Naruto",  id="185127272"},
    {cat="⛩ Anime",     name="Spirited Away Theme",        id="163460706"},
    {cat="⛩ Anime",     name="Howl's Moving Castle",       id="5936706494"},
    {cat="⛩ Anime",     name="Studio Ghibli Medley",       id="185127272"},

    -- 🎬 MOVIE OST (8 треков)
    {cat="🎬 Movie OST", name="Remember Me — Coco 🌟",     id="1845595287"},
    {cat="🎬 Movie OST", name="Pirates of Caribbean",       id="1837718129"},
    {cat="🎬 Movie OST", name="Interstellar Theme",         id="1836595073"},
    {cat="🎬 Movie OST", name="Hans Zimmer — Time",         id="1843463175"},
    {cat="🎬 Movie OST", name="Forrest Gump Theme",         id="130776953"},
    {cat="🎬 Movie OST", name="Schindler's List",           id="174636284"},
    {cat="🎬 Movie OST", name="Amelie Theme",               id="1372897298"},
    {cat="🎬 Movie OST", name="My Neighbor Totoro",         id="163460706"},

    -- 🎹 CLASSICAL (6 треков)
    {cat="🎹 Classical", name="Moonlight Sonata",           id="174636284"},
    {cat="🎹 Classical", name="Clair de Lune",              id="174636284"},
    {cat="🎹 Classical", name="Fur Elise",                  id="174636284"},
    {cat="🎹 Classical", name="Canon in D",                 id="174636284"},
    {cat="🎹 Classical", name="Gymnopedie No.1",            id="174636284"},
    {cat="🎹 Classical", name="Nocturne Op.9 — Chopin",     id="174636284"},
}

-- ══ ЗВУК ══
local snd = Instance.new("Sound", WS)
snd.Name   = "GuitarScript_Snd"
snd.Looped = true
snd.Volume = 0.8

local function playTrack(song)
    snd.SoundId = "rbxassetid://" .. song.id
    snd:Play()
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "🎸 Guitar Script", Text = "♪ " .. song.name, Duration = 4
        })
    end)
end
local function stopTrack()
    snd:Stop()
end

-- ══ ЦВЕТА ══
local C = {
    bg    = Color3.fromRGB(6, 9, 16),
    side  = Color3.fromRGB(9, 13, 22),
    card  = Color3.fromRGB(12, 17, 30),
    border= Color3.fromRGB(25, 38, 80),
    gold  = Color3.fromRGB(220, 165, 30),
    dgold = Color3.fromRGB(80, 52, 6),
    lgold = Color3.fromRGB(255, 210, 80),
    white = Color3.fromRGB(230, 230, 230),
    muted = Color3.fromRGB(70, 90, 130),
    green = Color3.fromRGB(48, 215, 78),
    red   = Color3.fromRGB(218, 48, 48),
    dim   = Color3.fromRGB(14, 20, 36),
}

local function tw(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart),p):Play() end

-- ══ GUI ══
if game.CoreGui:FindFirstChild("GS10") then game.CoreGui.GS10:Destroy() end
local sg2 = Instance.new("ScreenGui", game.CoreGui)
sg2.Name = "GS10" sg2.ResetOnSpawn = false sg2.DisplayOrder = 999 sg2.IgnoreGuiInset = true

-- Окно
local W = Instance.new("Frame", sg2)
W.Size = UDim2.new(0,400,0,580) W.Position = UDim2.new(0.5,-200,0.5,-290)
W.BackgroundColor3 = C.bg W.BorderSizePixel = 0 W.Active = true W.Draggable = true W.Visible = true
Instance.new("UICorner", W).CornerRadius = UDim.new(0,14)
local wStk = Instance.new("UIStroke", W) wStk.Thickness = 1.5
task.spawn(function() local h=0 while W and W.Parent do h=(h+2)%360 wStk.Color=Color3.fromHSV(h/360,0.7,0.6) task.wait(0.05) end end)

-- Заголовок
local Hdr = Instance.new("Frame", W)
Hdr.Size = UDim2.new(1,0,0,54) Hdr.BackgroundColor3 = C.side Hdr.BorderSizePixel = 0
Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0,14)
local hFill = Instance.new("Frame", Hdr) hFill.Size = UDim2.new(1,0,0.5,0) hFill.Position = UDim2.new(0,0,0.5,0) hFill.BackgroundColor3 = C.side hFill.BorderSizePixel = 0
local hBar = Instance.new("Frame", Hdr) hBar.Size = UDim2.new(1,0,0,2) hBar.BackgroundColor3 = C.gold hBar.BorderSizePixel = 0
task.spawn(function() local h=30 while hBar and hBar.Parent do h=(h+2)%360 hBar.BackgroundColor3=Color3.fromHSV(h/360,1,1) task.wait(0.04) end end)
local hIco = Instance.new("TextLabel", Hdr) hIco.Size = UDim2.new(0,40,1,0) hIco.Position = UDim2.new(0,8,0,0) hIco.BackgroundTransparency = 1 hIco.Text = "🎸" hIco.TextSize = 28 hIco.Font = Enum.Font.GothamBlack
task.spawn(function() while hIco and hIco.Parent do TweenService:Create(hIco,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{TextSize=33}):Play() task.wait(0.5) TweenService:Create(hIco,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{TextSize=25}):Play() task.wait(0.5) end end)
local hT = Instance.new("TextLabel", Hdr) hT.Size = UDim2.new(0.6,0,0,24) hT.Position = UDim2.new(0,50,0.5,-12) hT.BackgroundTransparency = 1 hT.Text = "GUITAR SCRIPT 1.0" hT.TextColor3 = C.gold hT.Font = Enum.Font.GothamBlack hT.TextSize = 15 hT.TextXAlignment = Enum.TextXAlignment.Left
local hS = Instance.new("TextLabel", Hdr) hS.Size = UDim2.new(0.7,0,0,13) hS.Position = UDim2.new(0,50,1,-15) hS.BackgroundTransparency = 1 hS.Text = #SONGS.."+ треков  •  Guitar+OST+Anime  •  @Primejtsu" hS.TextColor3 = C.muted hS.Font = Enum.Font.Code hS.TextSize = 9 hS.TextXAlignment = Enum.TextXAlignment.Left
local xBtn = Instance.new("TextButton", Hdr) xBtn.Size = UDim2.new(0,28,0,28) xBtn.Position = UDim2.new(1,-36,0.5,-14) xBtn.BackgroundColor3 = Color3.fromRGB(60,18,18) xBtn.Text = "✕" xBtn.TextColor3 = C.white xBtn.Font = Enum.Font.GothamBold xBtn.TextSize = 13 xBtn.BorderSizePixel = 0
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0,7)
xBtn.MouseButton1Click:Connect(function() tw(W,0.2,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}) task.wait(0.25) W.Visible=false W.Size=UDim2.new(0,400,0,580) W.Position=UDim2.new(0.5,-200,0.5,-290) end)

-- Плеер
local Pl = Instance.new("Frame", W)
Pl.Size = UDim2.new(1,-20,0,80) Pl.Position = UDim2.new(0,10,0,62) Pl.BackgroundColor3 = C.card Pl.BorderSizePixel = 0
Instance.new("UICorner", Pl).CornerRadius = UDim.new(0,10)
local plStk = Instance.new("UIStroke", Pl) plStk.Color = C.dgold plStk.Thickness = 1.5
local plBar = Instance.new("Frame", Pl) plBar.Size = UDim2.new(1,0,0,2) plBar.BackgroundColor3 = C.gold plBar.BorderSizePixel = 0
task.spawn(function() local h=30 while plBar and plBar.Parent do h=(h+3)%360 plBar.BackgroundColor3=Color3.fromHSV(h/360,1,1) task.wait(0.04) end end)
local plIco = Instance.new("TextLabel", Pl) plIco.Size = UDim2.new(0,58,1,0) plIco.BackgroundTransparency = 1 plIco.Text = "🎸" plIco.TextSize = 40 plIco.Font = Enum.Font.GothamBlack
task.spawn(function() while plIco and plIco.Parent do if snd.IsPlaying then TweenService:Create(plIco,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{TextSize=46}):Play() task.wait(0.3) TweenService:Create(plIco,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{TextSize=36}):Play() task.wait(0.3) else task.wait(0.5) end end end)
local nowName = Instance.new("TextLabel", Pl) nowName.Size = UDim2.new(1,-130,0,22) nowName.Position = UDim2.new(0,60,0,10) nowName.BackgroundTransparency = 1 nowName.Text = "Выбери песню ниже..." nowName.TextColor3 = C.white nowName.Font = Enum.Font.GothamBold nowName.TextSize = 13 nowName.TextXAlignment = Enum.TextXAlignment.Left nowName.TextTruncate = Enum.TextTruncate.AtEnd
local nowCat = Instance.new("TextLabel", Pl) nowCat.Size = UDim2.new(1,-130,0,14) nowCat.Position = UDim2.new(0,60,0,34) nowCat.BackgroundTransparency = 1 nowCat.Text = "🎸 Guitar Script" nowCat.TextColor3 = C.muted nowCat.Font = Enum.Font.Code nowCat.TextSize = 11 nowCat.TextXAlignment = Enum.TextXAlignment.Left
local stopBtn = Instance.new("TextButton", Pl) stopBtn.Size = UDim2.new(0,36,0,30) stopBtn.Position = UDim2.new(1,-78,0.5,-15) stopBtn.BackgroundColor3 = Color3.fromRGB(50,15,15) stopBtn.Text = "⏹" stopBtn.TextColor3 = C.red stopBtn.Font = Enum.Font.GothamBlack stopBtn.TextSize = 18 stopBtn.BorderSizePixel = 0
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,7)
stopBtn.MouseButton1Click:Connect(function() stopTrack() nowName.Text="Остановлено ⏹" nowName.TextColor3=C.muted nowCat.Text="🎸 Guitar Script" end)
local volLbl = Instance.new("TextLabel", Pl) volLbl.Size = UDim2.new(0,40,0,14) volLbl.Position = UDim2.new(1,-42,1,-18) volLbl.BackgroundTransparency = 1 volLbl.Text = "🔊 80%" volLbl.TextColor3 = C.muted volLbl.Font = Enum.Font.Code volLbl.TextSize = 10
local vM = Instance.new("TextButton", Pl) vM.Size = UDim2.new(0,22,0,20) vM.Position = UDim2.new(0,60,1,-24) vM.BackgroundColor3 = C.dim vM.Text = "−" vM.TextColor3 = C.white vM.Font = Enum.Font.GothamBlack vM.TextSize = 16 vM.BorderSizePixel = 0 Instance.new("UICorner", vM).CornerRadius = UDim.new(0,5)
local vP = Instance.new("TextButton", Pl) vP.Size = UDim2.new(0,22,0,20) vP.Position = UDim2.new(0,86,1,-24) vP.BackgroundColor3 = C.dgold vP.Text = "+" vP.TextColor3 = C.gold vP.Font = Enum.Font.GothamBlack vP.TextSize = 16 vP.BorderSizePixel = 0 Instance.new("UICorner", vP).CornerRadius = UDim.new(0,5)
local vol = 0.8
local function updVol() snd.Volume=vol volLbl.Text="🔊 "..math.floor(vol*100).."%" end
vM.MouseButton1Click:Connect(function() vol=math.max(0,vol-0.1) updVol() end)
vP.MouseButton1Click:Connect(function() vol=math.min(1,vol+0.1) updVol() end)

-- Поиск
local srF = Instance.new("Frame", W) srF.Size = UDim2.new(1,-20,0,34) srF.Position = UDim2.new(0,10,0,150) srF.BackgroundColor3 = C.dim srF.BorderSizePixel = 0
Instance.new("UICorner", srF).CornerRadius = UDim.new(0,9) Instance.new("UIStroke", srF).Color = C.border
local srIco = Instance.new("TextLabel", srF) srIco.Size = UDim2.new(0,28,1,0) srIco.BackgroundTransparency = 1 srIco.Text = "🔍" srIco.TextSize = 16 srIco.Font = Enum.Font.GothamBlack
local srBox = Instance.new("TextBox", srF) srBox.Size = UDim2.new(1,-36,1,0) srBox.Position = UDim2.new(0,28,0,0) srBox.BackgroundTransparency = 1 srBox.Text = "" srBox.PlaceholderText = "Поиск песни..." srBox.PlaceholderColor3 = C.muted srBox.TextColor3 = C.white srBox.Font = Enum.Font.Gotham srBox.TextSize = 13 srBox.ClearTextOnFocus = false srBox.TextXAlignment = Enum.TextXAlignment.Left

-- Категории
local catSc = Instance.new("ScrollingFrame", W) catSc.Size = UDim2.new(1,-20,0,32) catSc.Position = UDim2.new(0,10,0,192) catSc.BackgroundTransparency = 1 catSc.BorderSizePixel = 0 catSc.ScrollBarThickness = 0 catSc.ScrollingDirection = Enum.ScrollingDirection.X catSc.CanvasSize = UDim2.new(0,950,0,0)
local catL2 = Instance.new("UIListLayout", catSc) catL2.FillDirection = Enum.FillDirection.Horizontal catL2.Padding = UDim.new(0,6) catL2.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", catSc).PaddingLeft = UDim.new(0,2)

local cats = {"Все"}
local seen = {}
for _,s in ipairs(SONGS) do if not seen[s.cat] then seen[s.cat]=true table.insert(cats,s.cat) end end

local catBtnObjs = {}
local activeCat  = "Все"

-- List scroll
local listSc = Instance.new("ScrollingFrame", W) listSc.Size = UDim2.new(1,-20,1,-242) listSc.Position = UDim2.new(0,10,0,234) listSc.BackgroundColor3 = C.dim listSc.BorderSizePixel = 0 listSc.ScrollBarThickness = 3 listSc.ScrollBarImageColor3 = C.gold listSc.CanvasSize = UDim2.new(0,0,0,0) listSc.ScrollingEnabled = true listSc.ElasticBehavior = Enum.ElasticBehavior.Always
Instance.new("UICorner", listSc).CornerRadius = UDim.new(0,10)
local listL = Instance.new("UIListLayout", listSc) listL.Padding = UDim.new(0,4) listL.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", listSc).PaddingTop = UDim.new(0,6) Instance.new("UIPadding", listSc).PaddingBottom = UDim.new(0,6) Instance.new("UIPadding", listSc).PaddingLeft = UDim.new(0,6) Instance.new("UIPadding", listSc).PaddingRight = UDim.new(0,6)
listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() listSc.CanvasSize = UDim2.new(0,0,0,listL.AbsoluteContentSize.Y+12) end)

-- Swipe
local swA,swY0,swC0,swVel,lwY2=false,0,0,0,0
listSc.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then swA=true swY0=i.Position.Y lwY2=i.Position.Y swC0=listSc.CanvasPosition.Y swVel=0 end end)
listSc.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch and swA then swVel=i.Position.Y-lwY2 lwY2=i.Position.Y local mx=math.max(0,listSc.AbsoluteCanvasSize.Y-listSc.AbsoluteSize.Y) listSc.CanvasPosition=Vector2.new(0,math.clamp(swC0+(swY0-i.Position.Y),0,mx)) end end)
listSc.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then swA=false local vel=-swVel*2 task.spawn(function() while math.abs(vel)>0.3 and not swA do local mx=math.max(0,listSc.AbsoluteCanvasSize.Y-listSc.AbsoluteSize.Y) listSc.CanvasPosition=Vector2.new(0,math.clamp(listSc.CanvasPosition.Y+vel,0,mx)) vel=vel*0.88 task.wait(0.016) end end) end end)

local currentSong = nil

local function buildList(filter, catFilter)
    for _,c in ipairs(listSc:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
    local f = (filter or ""):lower()
    local filtered = {}
    for _,s in ipairs(SONGS) do
        local mCat  = (catFilter=="Все" or catFilter==nil or s.cat==catFilter)
        local mText = f=="" or s.name:lower():find(f,1,true) or s.cat:lower():find(f,1,true)
        if mCat and mText then table.insert(filtered,s) end
    end
    if #filtered==0 then
        local e=Instance.new("TextLabel",listSc) e.Size=UDim2.new(1,0,0,40) e.BackgroundTransparency=1 e.Text="🔍 Ничего не найдено" e.TextColor3=C.muted e.Font=Enum.Font.Gotham e.TextSize=13 e.LayoutOrder=1
        return
    end
    for idx,song in ipairs(filtered) do
        local isAct = (currentSong and currentSong.id==song.id and currentSong.name==song.name)
        local bgClr = idx%2==0 and C.card or Color3.fromRGB(10,14,26)
        if isAct then bgClr = Color3.fromRGB(22,14,42) end
        local row = Instance.new("Frame",listSc) row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=bgClr row.BorderSizePixel=0 row.LayoutOrder=idx
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        if isAct then local aS=Instance.new("UIStroke",row) aS.Color=C.gold aS.Thickness=1 end
        local nL=Instance.new("TextLabel",row) nL.Size=UDim2.new(0,26,1,0) nL.BackgroundTransparency=1 nL.Text=tostring(idx) nL.TextColor3=C.muted nL.Font=Enum.Font.Code nL.TextSize=11
        local cL=Instance.new("TextLabel",row) cL.Size=UDim2.new(0,22,1,0) cL.Position=UDim2.new(0,24,0,0) cL.BackgroundTransparency=1 cL.Text=(song.cat:match("^([^%s]+)") or "🎵") cL.TextSize=16 cL.Font=Enum.Font.GothamBlack
        local nName=Instance.new("TextLabel",row) nName.Size=UDim2.new(1,-108,1,0) nName.Position=UDim2.new(0,48,0,0) nName.BackgroundTransparency=1 nName.Text=song.name nName.TextColor3=isAct and C.lgold or C.white nName.Font=Enum.Font.Gotham nName.TextSize=12 nName.TextXAlignment=Enum.TextXAlignment.Left nName.TextTruncate=Enum.TextTruncate.AtEnd
        local pBtn=Instance.new("TextButton",row) pBtn.Size=UDim2.new(0,38,0,30) pBtn.Position=UDim2.new(1,-44,0.5,-15) pBtn.BackgroundColor3=isAct and C.gold or C.dgold pBtn.Text="▶" pBtn.TextColor3=isAct and C.dim or C.gold pBtn.Font=Enum.Font.GothamBlack pBtn.TextSize=16 pBtn.BorderSizePixel=0
        Instance.new("UICorner",pBtn).CornerRadius=UDim.new(0,7)
        local sd=song
        local function doPlay()
            currentSong=sd playTrack(sd)
            nowName.Text=sd.name nowName.TextColor3=C.lgold
            nowCat.Text=sd.cat plIco.Text=(sd.cat:match("^([^%s]+)") or "🎸")
            TweenService:Create(plStk,TweenInfo.new(0.2),{Color=C.gold}):Play()
            buildList(srBox.Text,activeCat)
        end
        pBtn.MouseButton1Click:Connect(doPlay)
        local rBtn=Instance.new("TextButton",row) rBtn.Size=UDim2.new(1,-50,1,0) rBtn.BackgroundTransparency=1 rBtn.Text="" rBtn.MouseButton1Click:Connect(doPlay)
        row.MouseEnter:Connect(function() if not isAct then TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(18,24,45)}):Play() end end)
        row.MouseLeave:Connect(function() if not isAct then TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=bgClr}):Play() end end)
    end
    listSc.CanvasPosition=Vector2.new(0,0)
end

-- Кнопки категорий
for _,cat in ipairs(cats) do
    local cb=Instance.new("TextButton",catSc) cb.Size=UDim2.new(0,0,0,26) cb.AutomaticSize=Enum.AutomaticSize.X cb.BackgroundColor3=cat=="Все" and C.gold or C.dim cb.Text=" "..cat.." " cb.TextColor3=cat=="Все" and C.dim or C.white cb.Font=Enum.Font.GothamBold cb.TextSize=10 cb.BorderSizePixel=0
    Instance.new("UICorner",cb).CornerRadius=UDim.new(0,7)
    if cat~="Все" then Instance.new("UIStroke",cb).Color=C.border end
    catBtnObjs[cat]=cb
    local cn=cat
    cb.MouseButton1Click:Connect(function()
        activeCat=cn
        for c,b in pairs(catBtnObjs) do
            if c==cn then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.gold}):Play() b.TextColor3=C.dim
            else TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.dim}):Play() b.TextColor3=C.white end
        end
        buildList(srBox.Text,cn)
    end)
end
srBox:GetPropertyChangedSignal("Text"):Connect(function() buildList(srBox.Text,activeCat) end)

-- Footer
local ft=Instance.new("Frame",W) ft.Size=UDim2.new(1,-20,0,18) ft.Position=UDim2.new(0,10,1,-22) ft.BackgroundTransparency=1
local ftL=Instance.new("TextLabel",ft) ftL.Size=UDim2.new(0.5,0,1,0) ftL.BackgroundTransparency=1 ftL.Text="🎸 "..#SONGS.." треков" ftL.TextColor3=C.muted ftL.Font=Enum.Font.Code ftL.TextSize=10 ftL.TextXAlignment=Enum.TextXAlignment.Left
local ftR=Instance.new("TextLabel",ft) ftR.Size=UDim2.new(0.5,0,1,0) ftR.Position=UDim2.new(0.5,0,0,0) ftR.BackgroundTransparency=1 ftR.Text="@Primejtsu | Nazar513000" ftR.TextColor3=Color3.fromRGB(28,42,80) ftR.Font=Enum.Font.Code ftR.TextSize=10 ftR.TextXAlignment=Enum.TextXAlignment.Right

-- Toggle иконка
local ico=Instance.new("Frame",sg2) ico.Size=UDim2.new(0,48,0,48) ico.Position=UDim2.new(1,-58,0.5,-24) ico.BackgroundColor3=C.dgold ico.BorderSizePixel=0 ico.ZIndex=50
Instance.new("UICorner",ico).CornerRadius=UDim.new(0,13)
local iStk=Instance.new("UIStroke",ico) iStk.Color=C.gold iStk.Thickness=1.5
task.spawn(function() local h=30 while ico and ico.Parent do h=(h+2)%360 iStk.Color=Color3.fromHSV(h/360,1,1) task.wait(0.04) end end)
local iLbl=Instance.new("TextLabel",ico) iLbl.Size=UDim2.new(1,0,1,0) iLbl.BackgroundTransparency=1 iLbl.Text="🎸" iLbl.TextSize=26 iLbl.Font=Enum.Font.GothamBlack iLbl.ZIndex=51
local dot=Instance.new("Frame",ico) dot.Size=UDim2.new(0,10,0,10) dot.Position=UDim2.new(1,-2,0,-2) dot.BackgroundColor3=C.green dot.BorderSizePixel=0 dot.ZIndex=52
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
task.spawn(function() while sg2 and sg2.Parent do dot.BackgroundColor3=snd.IsPlaying and C.gold or C.green TweenService:Create(dot,TweenInfo.new(0.7),{BackgroundTransparency=0.7}):Play() task.wait(0.7) TweenService:Create(dot,TweenInfo.new(0.7),{BackgroundTransparency=0}):Play() task.wait(0.7) end end)

-- Drag + tap
local dg,dS,dP=false,nil,nil
ico.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true dS=i.Position dP=ico.Position end end)
ico.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end end)
UIS.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then local d=i.Position-dS ico.Position=UDim2.new(dP.X.Scale,dP.X.Offset+d.X,dP.Y.Scale,dP.Y.Offset+d.Y) end end)
local tapSt2,tapT2=Vector2.zero,0
ico.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tapSt2=Vector2.new(i.Position.X,i.Position.Y) tapT2=tick() end end)
ico.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        if (Vector2.new(i.Position.X,i.Position.Y)-tapSt2).Magnitude<10 and tick()-tapT2<0.4 then
            if W.Visible then tw(W,0.2,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}) task.wait(0.25) W.Visible=false W.Size=UDim2.new(0,400,0,580) W.Position=UDim2.new(0.5,-200,0.5,-290)
            else W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0) TweenService:Create(W,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,400,0,580),Position=UDim2.new(0.5,-200,0.5,-290)}):Play() end
        end
    end
end)

-- Запуск
buildList("","Все")
W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
TweenService:Create(W,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,400,0,580),Position=UDim2.new(0.5,-200,0.5,-290)}):Play()
pcall(function() SG:SetCore("SendNotification",{Title="🎸 Guitar Script 1.0",Text=#SONGS.."+ треков | Remember Me — Coco ✨",Duration=5}) end)
print("🎸 Guitar Script 1.0 | "..#SONGS.." songs | @Primejtsu | Nazar513000")
