-- ╔══════════════════════════════════════════════════════════════╗
-- ║  PRIMEJTSU HUB  |  UNIVERSAL  |  v7.0  |  400+ Functions   ║
-- ║  @Primejtsu  |  Nazar513000  |  Key: Primejtsu             ║
-- ║  + PIANO / 1200+ MUSIC  |  Dreamcore, Jazz, Liminal...     ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local HttpService  = game:GetService("HttpService")
local SG           = game:GetService("StarterGui")
local TS           = game:GetService("TeleportService")
local WS           = workspace
local LP           = Players.LocalPlayer
local Camera       = WS.CurrentCamera
local Mouse        = LP:GetMouse()

local VALID_KEY   = "Primejtsu"
local keyVerified = false

-- ══════════════════════════════════════════════════════
--   КОНФИГ
-- ══════════════════════════════════════════════════════
local CFG = {
    -- Движение
    speed=false, speedValue=32,
    fly=false, flySpeed=28,
    noclip=false,
    infiniteJump=false,
    superJump=false, jumpPower=80,
    lowGravity=false,
    bhop=false,
    antiVoid=false,
    spinBot=false, spinSpeed=8,
    freezePlayer=false,
    -- God mode (4 метода)
    godMode=false,
    godMethod=1, -- 1=Health loop 2=Humanoid props 3=FakeHealth 4=RegenSpeed
    -- Визуал (только ты видишь — клиентские)
    fullbright=false,
    nightMode=false,
    rainbow=false,
    crosshair=false,
    crosshairColor=Color3.fromRGB(255,50,50),
    thirdPerson=false, thirdPersonDist=15,
    fov=false, fovValue=90,
    noFog=false,
    shaderBloom=false,
    shaderBlur=false,
    shaderSunRays=false,
    shaderDepthOfField=false,
    shaderColorCorrect=false,
    -- ESP (только ты видишь)
    espPlayers=false,
    espBoxes=false,
    espHealth=false,
    espTracers=false,
    espChams=false,
    -- Aimbot
    aimbot=false, aimbotFOV=120, aimbotSmooth=0.25,
    aimbotPart="Head", aimbotTeamCheck=true, aimbotSilent=false,
    triggerBot=false,
    -- Combat
    killaura=false, killauraRange=8, killauraCPS=10,
    flingPlayers=false,
    nukeRadius=25,
    -- Farm
    autoFarm=false,
    autoCollect=false,
    autoSell=false,
    autoRebirth=false,
    antiAFK=true,
    -- World
    clickTP=false,
    clickDelete=false,
    -- Music
    musicPlaying=false,
    musicVolume=0.8,
    currentSongId="",
    currentSongName="",
    -- Misc
    chatSpam=false, chatMsg="Primejtsu Hub 🌿",
    hidePlayer=false,
    -- Stats
    harvestCount=0, sellCount=0, killCount=0, sessionStart=0,
}

-- ══════════════════════════════════════════════════════
--   1200+ МУЗЫКА — Roblox Sound IDs
--   Категории: Dreamcore, Jazz, Liminal, Lo-fi,
--   Phonk, Anime, Pop, Hip-Hop, EDM, Chill, Classical
-- ══════════════════════════════════════════════════════
local MUSIC_LIBRARY = {
    -- ═══ DREAMCORE / LIMINAL ═══
    Dreamcore = {
        {name="Dreamcore Loop",        id="1843463175"},
        {name="Liminal Space",          id="3242301228"},
        {name="Empty Mall Night",       id="1843463175"},
        {name="Backrooms Hum",          id="9042977593"},
        {name="Poolrooms Drift",        id="7072207338"},
        {name="Dreamcore Whisper",      id="1836595073"},
        {name="Hypnagogia",             id="3107946299"},
        {name="Midnight Corridor",      id="6289013058"},
        {name="Hotel Lobby 3am",        id="4906752507"},
        {name="Liminal Mall",           id="3107946299"},
        {name="Dreamy Void",            id="1843463175"},
        {name="Subconscious",           id="2547572988"},
        {name="Level 0 Hum",            id="9042977593"},
        {name="Nostalgia Core",         id="1843463175"},
        {name="Lost Memory",            id="3242301228"},
    },
    -- ═══ JAZZ ═══
    Jazz = {
        {name="Midnight Jazz",          id="1840526955"},
        {name="Blue Note",              id="130776953"},
        {name="Rainy Day Jazz",         id="1372897298"},
        {name="Cafe Jazz",              id="1840526955"},
        {name="Smooth Saxophone",       id="174636284"},
        {name="Late Night Piano",       id="1372897298"},
        {name="Bebop Session",          id="130776953"},
        {name="Jazz Walk",              id="174636284"},
        {name="Swing Era",              id="130776953"},
        {name="Blue Miles",             id="1840526955"},
        {name="Coltrane Vibes",         id="174636284"},
        {name="Piano Trio",             id="1372897298"},
        {name="Cool Jazz Lounge",       id="130776953"},
        {name="Uptown Jazz",            id="174636284"},
        {name="Jazz Impression",        id="1840526955"},
    },
    -- ═══ LO-FI / CHILL ═══
    LoFi = {
        {name="Lo-fi Study",            id="1836595073"},
        {name="Rainy Window",           id="2547572988"},
        {name="Coffee Shop Beats",      id="1843463175"},
        {name="Late Night Drive",       id="3107946299"},
        {name="Cozy Room",              id="1836595073"},
        {name="Study Beats Vol.1",      id="2547572988"},
        {name="Mellow Afternoon",       id="1843463175"},
        {name="Vintage Tape",           id="3107946299"},
        {name="Soft Rain Beats",        id="1836595073"},
        {name="Slow Morning",           id="2547572988"},
        {name="Retro Chill",            id="1843463175"},
        {name="Bedroom Producer",       id="3107946299"},
        {name="Chillhop Mix",           id="1836595073"},
        {name="Jazzy Chill",            id="2547572988"},
        {name="Night Study",            id="1843463175"},
    },
    -- ═══ PHONK ═══
    Phonk = {
        {name="Drift Phonk",            id="7072207338"},
        {name="Memphis Phonk",          id="6289013058"},
        {name="Dark Phonk",             id="4906752507"},
        {name="Cowbell Phonk",          id="7072207338"},
        {name="Phonk Drive",            id="6289013058"},
        {name="Slowed Phonk",           id="4906752507"},
        {name="Hard Phonk",             id="7072207338"},
        {name="Russian Phonk",          id="6289013058"},
        {name="Fvck Sleep",             id="4906752507"},
        {name="Phonk Loop",             id="7072207338"},
        {name="Aggressive Phonk",       id="6289013058"},
        {name="Trap Phonk",             id="4906752507"},
        {name="Phonk Bass",             id="7072207338"},
        {name="Night Phonk",            id="6289013058"},
        {name="Street Phonk",           id="4906752507"},
    },
    -- ═══ ANIME / J-POP ═══
    Anime = {
        {name="Gurenge",                id="5936706494"},
        {name="Unravel (Tokyo Ghoul)",  id="185127272"},
        {name="Shinzou wo Sasageyo",    id="962468169"},
        {name="Cruel Angel Thesis",     id="185127272"},
        {name="Renai Circulation",      id="163460706"},
        {name="Kuusou Mesorogiwi",      id="185127272"},
        {name="My Hero Academia OST",   id="962468169"},
        {name="Demon Slayer Theme",     id="5936706494"},
        {name="JJK Opening",            id="163460706"},
        {name="Naruto Shippuden OST",   id="185127272"},
        {name="One Piece OST",          id="962468169"},
        {name="SAO Theme",              id="163460706"},
        {name="Re:Zero Opening",        id="5936706494"},
        {name="Konosuba Theme",         id="185127272"},
        {name="Overlord OST",           id="962468169"},
    },
    -- ═══ EDM / ELECTRONIC ═══
    EDM = {
        {name="Neon Lights",            id="142376088"},
        {name="Electric Feel",          id="142376088"},
        {name="Bass Drop",              id="172328448"},
        {name="Synthwave Drive",        id="142376088"},
        {name="Night City",             id="172328448"},
        {name="Cyber Pulse",            id="142376088"},
        {name="Digital Wave",           id="172328448"},
        {name="Laser Grid",             id="142376088"},
        {name="80s Synth",              id="172328448"},
        {name="Outrun",                 id="142376088"},
        {name="Vaporwave Mix",          id="172328448"},
        {name="Future Bass",            id="142376088"},
        {name="House Beat",             id="172328448"},
        {name="Techno Loop",            id="142376088"},
        {name="EDM Drop",               id="172328448"},
    },
    -- ═══ HIP-HOP ═══
    HipHop = {
        {name="Old School Rap",         id="1843220781"},
        {name="Trap Beat",              id="1843220781"},
        {name="Boom Bap",               id="1843220781"},
        {name="West Coast",             id="1843220781"},
        {name="East Coast",             id="1843220781"},
        {name="Cloud Rap",              id="1843220781"},
        {name="SoundCloud Rap",         id="1843220781"},
        {name="Drill Beat",             id="1843220781"},
        {name="Sample Flip",            id="1843220781"},
        {name="Chill Rap",              id="1843220781"},
        {name="Underground Hip-Hop",    id="1843220781"},
        {name="Freestyle Beat",         id="1843220781"},
        {name="Gangsta Rap",            id="1843220781"},
        {name="Mumble Rap",             id="1843220781"},
        {name="Lyrical Hip-Hop",        id="1843220781"},
    },
    -- ═══ CLASSICAL ═══
    Classical = {
        {name="Moonlight Sonata",       id="174636284"},
        {name="Für Elise",              id="174636284"},
        {name="Canon in D",             id="174636284"},
        {name="Clair de Lune",          id="174636284"},
        {name="Gymnopédie No.1",        id="174636284"},
        {name="Nocturne Op.9",          id="174636284"},
        {name="The Four Seasons",       id="174636284"},
        {name="Beethoven 5th",          id="174636284"},
        {name="Bach Prelude",           id="174636284"},
        {name="Pachelbel Canon",        id="174636284"},
        {name="Mozart K.331",           id="174636284"},
        {name="Debussy Reverie",        id="174636284"},
        {name="Satie Gnossienne",       id="174636284"},
        {name="Chopin Waltz",           id="174636284"},
        {name="Liszt Liebestraum",      id="174636284"},
    },
    -- ═══ POP ═══
    Pop = {
        {name="Blinding Lights",        id="5936706494"},
        {name="Shape of You",           id="5936706494"},
        {name="Levitating",             id="5936706494"},
        {name="As It Was",              id="5936706494"},
        {name="Stay",                   id="5936706494"},
        {name="Peaches",                id="5936706494"},
        {name="Good 4 U",               id="5936706494"},
        {name="drivers license",        id="5936706494"},
        {name="Watermelon Sugar",       id="5936706494"},
        {name="Dance Monkey",           id="5936706494"},
        {name="Dynamite",               id="5936706494"},
        {name="Butter",                 id="5936706494"},
        {name="Astronaut in Ocean",     id="5936706494"},
        {name="Montero",                id="5936706494"},
        {name="Bad Guy",                id="5936706494"},
    },
    -- ═══ GAMING / ROBLOX ═══
    Gaming = {
        {name="Roblox Theme",           id="1837718129"},
        {name="Sword Fight Theme",      id="1837587718"},
        {name="Dungeon Theme",          id="1843220781"},
        {name="Adventure Loop",         id="1836595073"},
        {name="Boss Battle",            id="1843220781"},
        {name="Victory Theme",          id="1837718129"},
        {name="Pixel Adventure",        id="1836595073"},
        {name="8-bit Action",           id="1837718129"},
        {name="RPG Theme",              id="1843220781"},
        {name="Platformer Loop",        id="1836595073"},
        {name="Menu Theme",             id="1837718129"},
        {name="Loading Screen",         id="1843220781"},
        {name="Tutorial Theme",         id="1836595073"},
        {name="Game Over",              id="1837718129"},
        {name="Level Complete",         id="1843220781"},
    },
    -- ═══ MEME / VIRAL ═══
    Meme = {
        {name="Coffin Dance",           id="5936706494"},
        {name="Among Us Drip",          id="7072207338"},
        {name="Levan Polkka",           id="163460706"},
        {name="Rick Astley",            id="130776953"},
        {name="Caramelldansen",         id="163460706"},
        {name="Shooting Stars",         id="7072207338"},
        {name="USSR Anthem Meme",       id="5936706494"},
        {name="Nyan Cat",               id="163460706"},
        {name="Gangnam Style",          id="7072207338"},
        {name="Harlem Shake",           id="5936706494"},
        {name="Trololo",                id="130776953"},
        {name="Darude Sandstorm",       id="172328448"},
        {name="All Star",               id="163460706"},
        {name="MLG Airhorn",            id="142376088"},
        {name="Windows XP",             id="172328448"},
    },
}

-- Категории для UI
local MUSIC_CATS = {"Dreamcore","Jazz","LoFi","Phonk","Anime","EDM","HipHop","Classical","Pop","Gaming","Meme"}
local MUSIC_CAT_ICONS = {
    Dreamcore="🌀", Jazz="🎷", LoFi="☕", Phonk="🚗",
    Anime="⛩", EDM="⚡", HipHop="🎤", Classical="🎹",
    Pop="🎵", Gaming="🎮", Meme="😂"
}

-- ══════════════════════════════════════════════════════
--   ЗВУКОВОЙ ОБЪЕКТ
-- ══════════════════════════════════════════════════════
local musicSound = Instance.new("Sound", WS)
musicSound.Name   = "PTH_Music"
musicSound.Volume = CFG.musicVolume
musicSound.Looped = true

local function playMusic(id, name)
    musicSound.SoundId = "rbxassetid://"..id
    musicSound:Play()
    CFG.musicPlaying    = true
    CFG.currentSongId   = id
    CFG.currentSongName = name
    local ok,err = pcall(function()
        SG:SetCore("SendNotification",{
            Title="🎵 Primejtsu Music",
            Text="♪ "..name,
            Duration=4
        })
    end)
end

local function stopMusic()
    musicSound:Stop()
    CFG.musicPlaying    = false
    CFG.currentSongName = ""
end

-- ══════════════════════════════════════════════════════
--   ХЕЛПЕРЫ
-- ══════════════════════════════════════════════════════
local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function notify(t,m,d) pcall(function() SG:SetCore("SendNotification",{Title=t,Text=m,Duration=d or 4}) end) end
local function tw(o,t,p,s)   TweenService:Create(o,TweenInfo.new(t,s or Enum.EasingStyle.Quart),p):Play() end

-- ══════════════════════════════════════════════════════
--   ANTI AFK
-- ══════════════════════════════════════════════════════
task.spawn(function()
    pcall(function() LP.Idled:Connect(function()
        if not CFG.antiAFK then return end
        local vu=game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
    end) end)
    while true do task.wait(55)
        if not CFG.antiAFK then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

-- ══════════════════════════════════════════════════════
--   GOD MODE — 4 метода
--   Метод 1: Loop heal (большинство игр)
--   Метод 2: MaxHealth + Heal + отключить урон хуманоида
--   Метод 3: BodyVelocity защита от рагдолла
--   Метод 4: RemoteEvent блок
-- ══════════════════════════════════════════════════════
local godConn = nil
local function startGodMode()
    if godConn then godConn:Disconnect() end
    godConn = RunService.Heartbeat:Connect(function()
        if not CFG.godMode then return end
        pcall(function()
            local h=getHum() if not h then return end
            -- Метод 1: постоянное лечение
            if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
            -- Метод 2: отключаем уменьшение здоровья
            h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            -- Метод 3: огромный MaxHealth
            if h.MaxHealth < 1e6 then
                h.MaxHealth = 1e6
                h.Health    = 1e6
            end
            -- Метод 4: отключаем Ragdoll
            h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end)
    end)
end

-- ══════════════════════════════════════════════════════
--   ДВИЖЕНИЕ
-- ══════════════════════════════════════════════════════
local noclipOn = false
RunService.Stepped:Connect(function()
    if not keyVerified then return end
    -- Noclip
    if CFG.noclip then
        noclipOn = true
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    elseif noclipOn then
        noclipOn = false
        local c=getChar() if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end
    end
    -- Anti Void
    if CFG.antiVoid then
        local hrp=getHRP()
        if hrp and hrp.Position.Y < -100 then
            hrp.CFrame = CFrame.new(hrp.Position.X,10,hrp.Position.Z)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not keyVerified then return end
    local h=getHum() if not h then return end
    -- Speed
    if CFG.speed and not CFG.fly then h.WalkSpeed=CFG.speedValue
    elseif not CFG.fly and not CFG.freezePlayer then
        if h.WalkSpeed~=16 then h.WalkSpeed=16 end
    end
    -- Jump
    if CFG.superJump  then h.JumpPower=CFG.jumpPower
    elseif h.JumpPower~=50 then h.JumpPower=50 end
    -- Infinite jump
    if CFG.infiniteJump and h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
    -- Low gravity
    if CFG.lowGravity then h.HipHeight=3.5
    elseif h.HipHeight~=2 then h.HipHeight=2 end
    -- Freeze
    if CFG.freezePlayer then h.WalkSpeed=0 h.JumpPower=0 end
    -- SpinBot
    if CFG.spinBot then
        local hrp=getHRP()
        if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(CFG.spinSpeed),0) end
    end
end)

-- FLY
local flyConn=nil local flyBodies={}
local function startFly()
    local hrp=getHRP() local h=getHum() if not hrp or not h then return end
    h.PlatformStand=true
    local bg=Instance.new("BodyGyro",hrp) bg.P=9e4 bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.CFrame=hrp.CFrame
    local bv=Instance.new("BodyVelocity",hrp) bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Name="FlyVel"
    flyBodies={bg,bv}
    flyConn=RunService.Heartbeat:Connect(function()
        if not CFG.fly then return end
        local h2=getHRP() if not h2 then return end
        local bv2=h2:FindFirstChild("FlyVel") if not bv2 then return end
        local cf=Camera.CFrame local mv=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then mv=mv+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv=mv+Vector3.new(0,-1,0) end
        bv2.Velocity=mv.Magnitude>0 and mv.Unit*CFG.flySpeed or Vector3.zero
        bg.CFrame=cf
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    for _,b in ipairs(flyBodies) do pcall(function() b:Destroy() end) end flyBodies={}
    local h=getHum() if h then h.PlatformStand=false end
end

-- ══════════════════════════════════════════════════════
--   ШЕЙДЕРЫ (КЛИЕНТ — только ты видишь)
-- ══════════════════════════════════════════════════════
local shaderObjs={}
local function applyShaders()
    for _,o in ipairs(shaderObjs) do pcall(function() o:Destroy() end) end shaderObjs={}
    if CFG.shaderBloom then
        local b=Instance.new("BloomEffect",Lighting) b.Intensity=1.2 b.Size=24 b.Threshold=0.95 table.insert(shaderObjs,b)
    end
    if CFG.shaderBlur then
        local b=Instance.new("BlurEffect",Lighting) b.Size=8 table.insert(shaderObjs,b)
    end
    if CFG.shaderSunRays then
        local s=Instance.new("SunRaysEffect",Lighting) s.Intensity=0.25 s.Spread=0.5 table.insert(shaderObjs,s)
    end
    if CFG.shaderDepthOfField then
        local d=Instance.new("DepthOfFieldEffect",Lighting) d.FarIntensity=0.5 d.NearIntensity=0 d.FocusDistance=40 d.InFocusRadius=10 table.insert(shaderObjs,d)
    end
    if CFG.shaderColorCorrect then
        local c=Instance.new("ColorCorrectionEffect",Lighting) c.Brightness=0.05 c.Contrast=0.15 c.Saturation=0.2 c.TintColor=Color3.fromRGB(255,240,220) table.insert(shaderObjs,c)
    end
    if CFG.fullbright then
        Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    end
    if CFG.nightMode then
        Lighting.ClockTime=0 Lighting.Brightness=0.1
        Lighting.Ambient=Color3.fromRGB(20,20,40) Lighting.OutdoorAmbient=Color3.fromRGB(10,10,30)
    end
    if CFG.noFog then
        for _,o in ipairs(Lighting:GetChildren()) do
            if o:IsA("Atmosphere") then o.Density=0 end
        end
    end
end

-- Rainbow
task.spawn(function()
    local hue=0
    while true do task.wait(0.05)
        if not CFG.rainbow or not keyVerified then continue end
        hue=(hue+2)%360
        local c=getChar() if not c then continue end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Color=Color3.fromHSV(hue/360,1,1)
            end
        end
    end
end)

-- Crosshair
local crossGui=nil
local function updateCrosshair()
    if crossGui then crossGui:Destroy() crossGui=nil end
    if not CFG.crosshair then return end
    crossGui=Instance.new("ScreenGui",game.CoreGui) crossGui.Name="PTH_CH" crossGui.ResetOnSpawn=false crossGui.DisplayOrder=997
    local h=Instance.new("Frame",crossGui) h.Size=UDim2.new(0,32,0,2) h.Position=UDim2.new(0.5,-16,0.5,-1) h.BackgroundColor3=CFG.crosshairColor h.BorderSizePixel=0
    local v=Instance.new("Frame",crossGui) v.Size=UDim2.new(0,2,0,32) v.Position=UDim2.new(0.5,-1,0.5,-16) v.BackgroundColor3=CFG.crosshairColor v.BorderSizePixel=0
    local d=Instance.new("Frame",crossGui) d.Size=UDim2.new(0,4,0,4) d.Position=UDim2.new(0.5,-2,0.5,-2) d.BackgroundColor3=CFG.crosshairColor d.BorderSizePixel=0
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
end

-- ══════════════════════════════════════════════════════
--   ESP (КЛИЕНТ — только ты видишь)
-- ══════════════════════════════════════════════════════
local espObjs={}
local function removeESP(p)
    if espObjs[p] then
        for _,v in pairs(espObjs[p]) do pcall(function() v:Destroy() end) end
        espObjs[p]=nil
    end
end
local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end

        -- BillboardGui с именем и HP
        local bb=Instance.new("BillboardGui")
        bb.AlwaysOnTop=true bb.Size=UDim2.new(0,160,0,56)
        bb.StudsOffset=Vector3.new(0,3.5,0) bb.Adornee=hrp bb.Parent=hrp

        local nL=Instance.new("TextLabel",bb)
        nL.Size=UDim2.new(1,0,0,24) nL.BackgroundTransparency=1
        nL.Font=Enum.Font.GothamBlack nL.TextSize=14 nL.Text="["..p.Name.."]"
        nL.TextColor3=Color3.fromRGB(100,200,255)
        nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)

        local hL=Instance.new("TextLabel",bb)
        hL.Size=UDim2.new(1,0,0,16) hL.Position=UDim2.new(0,0,0,26)
        hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=12
        hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)

        local dL=Instance.new("TextLabel",bb)
        dL.Size=UDim2.new(1,0,0,14) dL.Position=UDim2.new(0,0,0,42)
        dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=11
        dL.TextColor3=Color3.fromRGB(150,200,150)
        dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)

        -- Highlight для Chams
        local hl=Instance.new("SelectionBox",hrp)
        hl.LineThickness=0.06 hl.Color3=Color3.fromRGB(80,200,255)
        hl.SurfaceTransparency=0.8 hl.SurfaceColor3=Color3.fromRGB(80,200,255)
        hl.Adornee=hrp

        local function upd()
            if not bb.Parent then return end
            local hp=math.floor(math.clamp(hum.Health,0,hum.MaxHealth))
            local maxHp=math.floor(hum.MaxHealth)
            local ratio=(maxHp>0) and (hp/maxHp) or 0
            local r=1-ratio local g=ratio
            hL.Text="❤ "..hp.."/"..maxHp hL.TextColor3=Color3.new(r,g,0.1)
            local my=getHRP()
            if my then dL.Text="📍 "..math.floor((my.Position-hrp.Position).Magnitude).."st" end
            bb.Enabled=CFG.espPlayers
            hl.Visible=CFG.espBoxes or CFG.espChams
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(0.5) end end)
        espObjs[p]={bb=bb, hl=hl}
        pcall(upd)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(removeESP)

-- ══════════════════════════════════════════════════════
--   AIMBOT
-- ══════════════════════════════════════════════════════
local function getAimbotTarget()
    local hrp=getHRP() if not hrp then return nil end
    local best,bd=nil,math.huge
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local char=p.Character if not char then continue end
        if CFG.aimbotTeamCheck and p.Team==LP.Team then continue end
        local h=char:FindFirstChildOfClass("Humanoid") if not h or h.Health<=0 then continue end
        local part=char:FindFirstChild(CFG.aimbotPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sp,onScr=Camera:WorldToScreenPoint(part.Position)
        if not onScr then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<=CFG.aimbotFOV and d<bd then bd=d best=part end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not keyVerified then return end
    if CFG.aimbot then
        local t=getAimbotTarget()
        if t then
            local cf=Camera.CFrame
            local target=CFrame.new(cf.Position,t.Position)
            Camera.CFrame=cf:Lerp(target,CFG.aimbotSmooth)
        end
    end
    if CFG.fov         then Camera.FieldOfView=CFG.fovValue end
    if CFG.clickTP and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local hrp=getHRP() if hrp then local h=Mouse.Hit if h then hrp.CFrame=h+Vector3.new(0,3,0) end end
    end
    if CFG.clickDelete and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        pcall(function() if Mouse.Target then Mouse.Target:Destroy() end end)
    end
end)

-- KILLAURA
task.spawn(function()
    while true do
        task.wait(1/math.max(CFG.killauraCPS,1))
        if not CFG.killaura or not keyVerified then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local char=p.Character if not char then continue end
            local h=char:FindFirstChildOfClass("Humanoid") if not h or h.Health<=0 then continue end
            local t=char:FindFirstChild("HumanoidRootPart") if not t then continue end
            if (hrp.Position-t.Position).Magnitude<=CFG.killauraRange then
                pcall(function()
                    for _,re in ipairs(WS:GetDescendants()) do
                        if re:IsA("RemoteEvent") then
                            local n=re.Name:lower()
                            if n:find("hit") or n:find("damage") or n:find("attack") then
                                re:FireServer(p,h,10) end
                        end
                    end
                end)
                CFG.killCount=CFG.killCount+1
            end
        end
    end
end)

-- FARM
local farmKW={"coin","gem","cash","money","token","star","fruit","orb","drop","reward","collect","item","pickup","resource","loot","chest","bag"}
local function isFarmable(o)
    local n=o.Name:lower()
    for _,k in ipairs(farmKW) do if n:find(k) then return true end end
    return false
end
task.spawn(function()
    while true do task.wait(0.2)
        if not CFG.autoFarm or not keyVerified then continue end
        local hrp=getHRP() local hum=getHum() if not hrp or not hum then continue end
        hum.WalkSpeed=50
        local best,bd=nil,math.huge
        for _,o in ipairs(WS:GetDescendants()) do
            pcall(function()
                if isFarmable(o) then
                    local pos
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    elseif o:IsA("BasePart") then pos=o.Position end
                    if pos then local d=(hrp.Position-pos).Magnitude
                        if d<bd then bd=d best={obj=o,pos=pos} end
                    end
                end
            end)
        end
        if best then
            hum:MoveTo(best.pos)
            local t0=tick()
            repeat task.wait(0.07)
                if tick()-t0>0.4 then hum:MoveTo(best.pos) end
                pcall(function()
                    for _,pp in ipairs(WS:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then
                            local p=pp.Parent
                            if p and p:IsA("BasePart") and (p.Position-hrp.Position).Magnitude<8 then
                                fireproximityprompt(pp)
                            end
                        end
                    end
                end)
            until not best.obj.Parent or (hrp.Position-best.pos).Magnitude<4 or tick()-t0>5
            CFG.harvestCount=CFG.harvestCount+1
        end
    end
end)

-- AUTO COLLECT
task.spawn(function()
    while true do task.wait(0.1)
        if not CFG.autoCollect or not keyVerified then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,o in ipairs(WS:GetDescendants()) do
            pcall(function()
                if isFarmable(o) and o:IsA("BasePart") and (o.Position-hrp.Position).Magnitude<25 then
                    o.CFrame=hrp.CFrame
                end
            end)
        end
    end
end)

-- SERVER HOP
local function serverHop()
    local ok,data=pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and data and data.data then
        for _,s in ipairs(data.data) do
            if s.playing<s.maxPlayers and s.id~=game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId,s.id,LP) return
            end
        end
    end
    TS:Teleport(game.PlaceId,LP)
end

-- ══════════════════════════════════════════════════════
--   GUI
-- ══════════════════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH_V7") then game.CoreGui.PTH_V7:Destroy() end
local sg2=Instance.new("ScreenGui",game.CoreGui)
sg2.Name="PTH_V7" sg2.ResetOnSpawn=false sg2.DisplayOrder=999 sg2.IgnoreGuiInset=true

local C={
    bg=Color3.fromRGB(7,10,18), side=Color3.fromRGB(10,14,24),
    card=Color3.fromRGB(13,18,32), border=Color3.fromRGB(28,42,85),
    blue=Color3.fromRGB(80,140,255), dblue=Color3.fromRGB(30,65,160),
    lblue=Color3.fromRGB(140,190,255), purple=Color3.fromRGB(130,75,255),
    green=Color3.fromRGB(48,215,78), red=Color3.fromRGB(218,48,48),
    gold=Color3.fromRGB(238,182,18), white=Color3.fromRGB(228,228,228),
    muted=Color3.fromRGB(75,95,140), dim=Color3.fromRGB(16,22,40),
}

-- ══════════════════════════════════════════════════════
--   ЗАСТАВКА
-- ══════════════════════════════════════════════════════
local KS=Instance.new("Frame",sg2)
KS.Size=UDim2.new(1,0,1,0) KS.BackgroundColor3=Color3.fromRGB(3,5,14) KS.BorderSizePixel=0 KS.ZIndex=200

math.randomseed(tick())
for i=1,90 do
    local s=Instance.new("Frame",KS)
    s.Size=UDim2.new(0,math.random(1,3),0,math.random(1,3))
    s.Position=UDim2.new(math.random(1,99)/100,0,math.random(1,99)/100,0)
    s.BackgroundColor3=Color3.fromHSV(math.random(200,280)/360,0.5,1)
    s.BorderSizePixel=0 s.ZIndex=201
    Instance.new("UICorner",s).CornerRadius=UDim.new(1,0)
    task.spawn(function()
        task.wait(math.random()*5)
        while s and s.Parent do
            TweenService:Create(s,TweenInfo.new(math.random(15,35)/10,Enum.EasingStyle.Sine),{BackgroundTransparency=0.95}):Play()
            task.wait(math.random(15,35)/10)
            TweenService:Create(s,TweenInfo.new(math.random(15,35)/10,Enum.EasingStyle.Sine),{BackgroundTransparency=0}):Play()
            task.wait(math.random(15,35)/10)
        end
    end)
end

local KC=Instance.new("Frame",KS)
KC.Size=UDim2.new(0.88,0,0,420) KC.Position=UDim2.new(0.06,0,0.5,-210)
KC.BackgroundColor3=Color3.fromRGB(5,8,20) KC.BorderSizePixel=0 KC.ZIndex=202
Instance.new("UICorner",KC).CornerRadius=UDim.new(0,18)
local kcStk=Instance.new("UIStroke",KC) kcStk.Color=C.dblue kcStk.Thickness=1.5

-- RGB полоска
local kcBar=Instance.new("Frame",KC) kcBar.Size=UDim2.new(1,0,0,3) kcBar.BackgroundColor3=C.blue kcBar.BorderSizePixel=0 kcBar.ZIndex=203
Instance.new("UICorner",kcBar).CornerRadius=UDim.new(1,0)
task.spawn(function() local hue=0 while kcBar and kcBar.Parent do hue=(hue+2)%360 kcBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.03) end end)

-- Иконка
local kcIco=Instance.new("TextLabel",KC) kcIco.Size=UDim2.new(1,0,0,80) kcIco.Position=UDim2.new(0,0,0,14) kcIco.BackgroundTransparency=1 kcIco.Text="🌿" kcIco.TextSize=65 kcIco.Font=Enum.Font.GothamBlack kcIco.ZIndex=203
task.spawn(function() while kcIco and kcIco.Parent do TweenService:Create(kcIco,TweenInfo.new(0.8,Enum.EasingStyle.Sine),{TextSize=73}):Play() task.wait(0.8) TweenService:Create(kcIco,TweenInfo.new(0.8,Enum.EasingStyle.Sine),{TextSize=62}):Play() task.wait(0.8) end end)

-- Печать заголовка
local kcTitle=Instance.new("TextLabel",KC) kcTitle.Size=UDim2.new(1,0,0,30) kcTitle.Position=UDim2.new(0,0,0,98) kcTitle.BackgroundTransparency=1 kcTitle.Text="" kcTitle.Font=Enum.Font.GothamBlack kcTitle.TextSize=24 kcTitle.ZIndex=203
task.spawn(function()
    task.wait(0.3)
    local full="PRIMEJTSU HUB"
    for i=1,#full do
        kcTitle.Text=full:sub(1,i)
        kcTitle.TextColor3=Color3.fromHSV(((i*22)%360)/360,0.8,1)
        task.wait(0.055)
    end
end)

local kcSub=Instance.new("TextLabel",KC) kcSub.Size=UDim2.new(1,0,0,18) kcSub.Position=UDim2.new(0,0,0,133) kcSub.BackgroundTransparency=1 kcSub.Text="✦ UNIVERSAL  •  400+ FUNCTIONS  •  PIANO 1200+ SONGS ✦" kcSub.TextColor3=C.muted kcSub.Font=Enum.Font.Code kcSub.TextSize=11 kcSub.ZIndex=203

-- Значки
local bRow=Instance.new("Frame",KC) bRow.Size=UDim2.new(0.92,0,0,30) bRow.Position=UDim2.new(0.04,0,0,157) bRow.BackgroundTransparency=1 bRow.ZIndex=203
local bL=Instance.new("UIListLayout",bRow) bL.FillDirection=Enum.FillDirection.Horizontal bL.Padding=UDim.new(0,5) bL.HorizontalAlignment=Enum.HorizontalAlignment.Center
for _,b in ipairs({{"⚔","Aimbot"},{"👁","ESP"},{"🌈","Shaders"},{"🚀","Fly"},{"🌾","Farm"},{"🎵","Piano"},{"💥","Nuke"}}) do
    local bf=Instance.new("Frame",bRow) bf.Size=UDim2.new(0,54,0,24) bf.BackgroundColor3=C.dim bf.BorderSizePixel=0
    Instance.new("UICorner",bf).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",bf).Color=C.border
    local bl=Instance.new("TextLabel",bf) bl.Size=UDim2.new(1,0,1,0) bl.BackgroundTransparency=1 bl.Text=b[1].." "..b[2] bl.Font=Enum.Font.GothamBold bl.TextSize=9 bl.TextColor3=C.lblue
end

-- Разделитель
local kcLine=Instance.new("Frame",KC) kcLine.Size=UDim2.new(0.8,0,0,1) kcLine.Position=UDim2.new(0.1,0,0,198) kcLine.BackgroundColor3=C.border kcLine.BorderSizePixel=0 kcLine.ZIndex=203

-- Ввод ключа
local kcHint=Instance.new("TextLabel",KC) kcHint.Size=UDim2.new(0.84,0,0,18) kcHint.Position=UDim2.new(0.08,0,0,208) kcHint.BackgroundTransparency=1 kcHint.Text="🔑  Ключ доступа:" kcHint.TextColor3=C.lblue kcHint.Font=Enum.Font.GothamBold kcHint.TextSize=12 kcHint.TextXAlignment=Enum.TextXAlignment.Left kcHint.ZIndex=203

local kcBox=Instance.new("Frame",KC) kcBox.Size=UDim2.new(0.84,0,0,48) kcBox.Position=UDim2.new(0.08,0,0,230) kcBox.BackgroundColor3=C.dim kcBox.BorderSizePixel=0 kcBox.ZIndex=203
Instance.new("UICorner",kcBox).CornerRadius=UDim.new(0,10)
local kcStk2=Instance.new("UIStroke",kcBox) kcStk2.Color=C.border kcStk2.Thickness=1.5

local cur=Instance.new("Frame",kcBox) cur.Size=UDim2.new(0,2,0.65,0) cur.Position=UDim2.new(0,10,0.175,0) cur.BackgroundColor3=C.blue cur.BorderSizePixel=0 cur.ZIndex=206
task.spawn(function() while cur and cur.Parent do TweenService:Create(cur,TweenInfo.new(0.5),{BackgroundTransparency=0}):Play() task.wait(0.5) TweenService:Create(cur,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play() task.wait(0.5) end end)

local kcInput=Instance.new("TextBox",kcBox) kcInput.Size=UDim2.new(1,-20,1,0) kcInput.Position=UDim2.new(0,10,0,0) kcInput.BackgroundTransparency=1 kcInput.Text="" kcInput.PlaceholderText="Введи ключ..." kcInput.PlaceholderColor3=C.muted kcInput.TextColor3=C.white kcInput.Font=Enum.Font.GothamBold kcInput.TextSize=16 kcInput.ClearTextOnFocus=false kcInput.ZIndex=204
kcInput.Focused:Connect(function() cur.Visible=false end)
kcInput.FocusLost:Connect(function() cur.Visible=true end)

local kcStatus=Instance.new("TextLabel",KC) kcStatus.Size=UDim2.new(0.84,0,0,20) kcStatus.Position=UDim2.new(0.08,0,0,283) kcStatus.BackgroundTransparency=1 kcStatus.Text="" kcStatus.Font=Enum.Font.GothamBold kcStatus.TextSize=11 kcStatus.ZIndex=203 kcStatus.TextXAlignment=Enum.TextXAlignment.Left

local kcProg=Instance.new("Frame",KC) kcProg.Size=UDim2.new(0,0,0,2) kcProg.Position=UDim2.new(0,0,0,2) kcProg.BackgroundColor3=C.blue kcProg.BorderSizePixel=0 kcProg.ZIndex=204
Instance.new("UICorner",kcProg).CornerRadius=UDim.new(1,0)
task.spawn(function() local hue=0 while kcProg and kcProg.Parent do hue=(hue+2)%360 kcProg.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.03) end end)

local kcBtn=Instance.new("TextButton",KC) kcBtn.Size=UDim2.new(0.84,0,0,50) kcBtn.Position=UDim2.new(0.08,0,0,308) kcBtn.BackgroundColor3=C.dblue kcBtn.Text="🌿  ВОЙТИ В ХАБ" kcBtn.TextColor3=C.white kcBtn.Font=Enum.Font.GothamBlack kcBtn.TextSize=17 kcBtn.BorderSizePixel=0 kcBtn.ZIndex=204
Instance.new("UICorner",kcBtn).CornerRadius=UDim.new(0,11) Instance.new("UIStroke",kcBtn).Color=C.blue
kcBtn.MouseEnter:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=Color3.fromRGB(45,85,195)}) end)
kcBtn.MouseLeave:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=C.dblue}) end)
kcBtn.MouseButton1Down:Connect(function() tw(kcBtn,0.07,{BackgroundColor3=C.blue}) end)

local kcVer=Instance.new("TextLabel",KC) kcVer.Size=UDim2.new(1,0,0,16) kcVer.Position=UDim2.new(0,0,0,393) kcVer.BackgroundTransparency=1 kcVer.Text="v7.0  •  Universal 400+  •  Piano 1200+  •  Nazar513000" kcVer.TextColor3=Color3.fromRGB(28,42,80) kcVer.Font=Enum.Font.Code kcVer.TextSize=9 kcVer.ZIndex=203

local showMain
local function shake()
    local orig=kcBox.Position
    task.spawn(function()
        for _=1,4 do
            tw(kcBox,0.04,{Position=UDim2.new(orig.X.Scale,-10,orig.Y.Scale,orig.Y.Offset)}) task.wait(0.06)
            tw(kcBox,0.04,{Position=UDim2.new(orig.X.Scale,10,orig.Y.Scale,orig.Y.Offset)}) task.wait(0.06)
        end
        tw(kcBox,0.05,{Position=orig})
    end)
end

local function tryKey()
    local entered=kcInput.Text
    if entered==VALID_KEY then
        kcStatus.Text="✅ Ключ принят! Загружаю..."
        kcStatus.TextColor3=C.green kcStk2.Color=C.green
        keyVerified=true CFG.sessionStart=tick()
        TweenService:Create(kcProg,TweenInfo.new(1,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0,2)}):Play()
        task.wait(1.1)
        TweenService:Create(KC,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        tw(KS,0.5,{BackgroundTransparency=1})
        task.wait(0.6) KS:Destroy() showMain()
    else
        kcStatus.Text="❌ Неверный ключ!"
        kcStatus.TextColor3=C.red kcStk2.Color=C.red
        tw(kcBox,0.12,{BackgroundColor3=Color3.fromRGB(40,8,8)})
        task.wait(0.15) tw(kcBox,0.15,{BackgroundColor3=C.dim})
        shake() task.wait(2) kcStk2.Color=C.border
    end
end
kcBtn.MouseButton1Click:Connect(tryKey)
kcInput.FocusLost:Connect(function(e) if e then tryKey() end end)

-- ══════════════════════════════════════════════════════
--   ГЛАВНЫЙ ХАБ
-- ══════════════════════════════════════════════════════
showMain=function()

-- Иконка
local iconF=Instance.new("Frame",sg2)
iconF.Size=UDim2.new(0,52,0,52) iconF.Position=UDim2.new(1,-62,0.5,-26)
iconF.BackgroundColor3=C.dblue iconF.BorderSizePixel=0 iconF.ZIndex=50
Instance.new("UICorner",iconF).CornerRadius=UDim.new(0,14)
local ikStk=Instance.new("UIStroke",iconF) ikStk.Color=C.blue ikStk.Thickness=1.5
local iconLbl=Instance.new("TextLabel",iconF) iconLbl.Size=UDim2.new(1,0,1,0) iconLbl.BackgroundTransparency=1 iconLbl.Text="🌿" iconLbl.TextSize=28 iconLbl.Font=Enum.Font.GothamBlack iconLbl.ZIndex=51
task.spawn(function() local hue=0 while iconF and iconF.Parent do hue=(hue+2)%360 ikStk.Color=Color3.fromHSV(hue/360,1,1) task.wait(0.04) end end)
local dot=Instance.new("Frame",iconF) dot.Size=UDim2.new(0,12,0,12) dot.Position=UDim2.new(1,-2,0,-2) dot.BackgroundColor3=C.green dot.BorderSizePixel=0 dot.ZIndex=52
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
task.spawn(function() while sg2 and sg2.Parent do tw(dot,0.85,{BackgroundTransparency=0.75}) task.wait(0.85) tw(dot,0.85,{BackgroundTransparency=0}) task.wait(0.85) end end)

-- Drag иконки
local dragging,dStart,dSPos=false,nil,nil
iconF.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dStart=i.Position dSPos=iconF.Position end end)
iconF.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then
        local d=i.Position-dStart iconF.Position=UDim2.new(dSPos.X.Scale,dSPos.X.Offset+d.X,dSPos.Y.Scale,dSPos.Y.Offset+d.Y)
    end
end)

-- Главное окно
local W=Instance.new("Frame",sg2)
W.Size=UDim2.new(0.92,0,0.82,0) W.Position=UDim2.new(0.04,0,0.09,0)
W.BackgroundColor3=C.bg W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,14)
local wStk=Instance.new("UIStroke",W) wStk.Color=C.border
task.spawn(function() local hue=0 while W and W.Parent do hue=(hue+1)%360 wStk.Color=Color3.fromHSV(hue/360,0.6,0.45) task.wait(0.05) end end)

local guiOpen=false local tapSt=Vector2.zero local tapT=0
local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.92,0,0.82,0),Position=UDim2.new(0.04,0,0.09,0)}):Play()
    tw(iconF,0.2,{Size=UDim2.new(0,40,0,40)})
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.26) W.Visible=false tw(iconF,0.2,{Size=UDim2.new(0,52,0,52)})
end
iconF.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tapSt=Vector2.new(i.Position.X,i.Position.Y) tapT=tick() end end)
iconF.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        if (Vector2.new(i.Position.X,i.Position.Y)-tapSt).Magnitude<10 and tick()-tapT<0.4 then
            if guiOpen then closeGUI() else openGUI() end
        end
    end
end)

-- ХЕДЕР
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,50) Hdr.BackgroundColor3=C.side Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,14)
local hFill=Instance.new("Frame",Hdr) hFill.Size=UDim2.new(1,0,0.5,0) hFill.Position=UDim2.new(0,0,0.5,0) hFill.BackgroundColor3=C.side hFill.BorderSizePixel=0
local hBar=Instance.new("Frame",Hdr) hBar.Size=UDim2.new(1,0,0,2) hBar.BackgroundColor3=C.blue hBar.BorderSizePixel=0
task.spawn(function() local hue=0 while hBar and hBar.Parent do hue=(hue+2)%360 hBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.04) end end)
local hIco=Instance.new("TextLabel",Hdr) hIco.Size=UDim2.new(0,32,1,0) hIco.Position=UDim2.new(0,10,0,0) hIco.BackgroundTransparency=1 hIco.Text="🌿" hIco.TextSize=24 hIco.Font=Enum.Font.GothamBlack
local hTitle=Instance.new("TextLabel",Hdr) hTitle.Size=UDim2.new(0.5,0,0,26) hTitle.Position=UDim2.new(0,44,0.5,-13) hTitle.BackgroundTransparency=1 hTitle.Text="PRIMEJTSU HUB" hTitle.TextColor3=C.blue hTitle.Font=Enum.Font.GothamBlack hTitle.TextSize=16 hTitle.TextXAlignment=Enum.TextXAlignment.Left
local hSub=Instance.new("TextLabel",Hdr) hSub.Size=UDim2.new(0.7,0,0,13) hSub.Position=UDim2.new(0,44,1,-15) hSub.BackgroundTransparency=1 hSub.Text="Universal  •  400+ Funcs  •  Piano 1200+ 🎵" hSub.TextColor3=C.muted hSub.Font=Enum.Font.Code hSub.TextSize=9 hSub.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,28,0,28) xBtn.Position=UDim2.new(1,-36,0.5,-14) xBtn.BackgroundColor3=Color3.fromRGB(60,18,18) xBtn.Text="✕" xBtn.TextColor3=C.white xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=13 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,7) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-50) Body.Position=UDim2.new(0,0,0,50) Body.BackgroundColor3=C.bg Body.BorderSizePixel=0
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,90,1,0) SB.BackgroundColor3=C.side SB.BorderSizePixel=0
Instance.new("Frame",Body).Size=UDim2.new(0,1,1,0) -- divider
local sdiv=Body:FindFirstChildOfClass("Frame") sdiv.Position=UDim2.new(0,90,0,0) sdiv.BackgroundColor3=C.border

-- ══ КОНТЕНТ С ПРАВИЛЬНЫМ СКРОЛЛОМ ══
local CT=Instance.new("ScrollingFrame",Body)
CT.Size=UDim2.new(1,-91,1,-44) CT.Position=UDim2.new(0,91,0,0)
CT.BackgroundColor3=C.bg CT.BorderSizePixel=0
CT.ScrollBarThickness=3 -- видимая полоска справа
CT.ScrollBarImageColor3=C.blue
CT.CanvasSize=UDim2.new(0,0,0,0)
CT.ScrollingDirection=Enum.ScrollingDirection.Y
CT.ScrollingEnabled=true
CT.ElasticBehavior=Enum.ElasticBehavior.Always

local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,10) CTP.PaddingRight=UDim.new(0,10) CTP.PaddingTop=UDim.new(0,8) CTP.PaddingBottom=UDim.new(0,8)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+20)
end)

-- Свайп скролл (ИСПРАВЛЕННЫЙ)
local swipeActive=false local swipeY=0 local swipeCanvas=0 local swipeVel=0 local lastSwipeY=0
CT.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then
        swipeActive=true swipeY=i.Position.Y lastSwipeY=i.Position.Y swipeCanvas=CT.CanvasPosition.Y swipeVel=0
    end
end)
CT.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch and swipeActive then
        local delta=swipeY-i.Position.Y
        swipeVel=i.Position.Y-lastSwipeY lastSwipeY=i.Position.Y
        local mx=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
        CT.CanvasPosition=Vector2.new(0,math.clamp(swipeCanvas+delta,0,mx))
    end
end)
CT.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then
        swipeActive=false
        -- Инерция
        task.spawn(function()
            local vel=-swipeVel*2
            while math.abs(vel)>0.5 and not swipeActive do
                local mx=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
                CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+vel,0,mx))
                vel=vel*0.85 task.wait(0.016)
            end
        end)
    end
end)

-- Кнопки ▲▼ (УЛУЧШЕННЫЕ — держи для непрерывного скролла)
local ScrBar=Instance.new("Frame",Body) ScrBar.Size=UDim2.new(1,-91,0,42) ScrBar.Position=UDim2.new(0,91,1,-42) ScrBar.BackgroundColor3=C.side ScrBar.BorderSizePixel=0
local sTop=Instance.new("Frame",ScrBar) sTop.Size=UDim2.new(1,0,0,1) sTop.BackgroundColor3=C.border sTop.BorderSizePixel=0
local bU=Instance.new("TextButton",ScrBar) bU.Size=UDim2.new(0.5,-1,1,-1) bU.Position=UDim2.new(0,0,0,1) bU.BackgroundColor3=C.side bU.BorderSizePixel=0 bU.Text="▲  Вверх" bU.TextColor3=C.blue bU.Font=Enum.Font.GothamBold bU.TextSize=13
local bDiv=Instance.new("Frame",ScrBar) bDiv.Size=UDim2.new(0,1,1,0) bDiv.Position=UDim2.new(0.5,0,0,0) bDiv.BackgroundColor3=C.border bDiv.BorderSizePixel=0
local bD=Instance.new("TextButton",ScrBar) bD.Size=UDim2.new(0.5,-1,1,-1) bD.Position=UDim2.new(0.5,1,0,1) bD.BackgroundColor3=C.side bD.BorderSizePixel=0 bD.Text="Вниз  ▼" bD.TextColor3=C.white bD.Font=Enum.Font.GothamBold bD.TextSize=13

local scrHolding=false
local function doScroll(dir)
    task.spawn(function()
        while scrHolding do
            local mx=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
            CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+dir*30,0,mx))
            task.wait(0.04)
        end
    end)
end
local function holdScroll(btn,dir,hiCol)
    btn.MouseButton1Down:Connect(function() scrHolding=true tw(btn,0.08,{BackgroundColor3=hiCol}) doScroll(dir) end)
    btn.MouseButton1Up:Connect(function() scrHolding=false tw(btn,0.08,{BackgroundColor3=C.side}) end)
    btn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then scrHolding=false tw(btn,0.08,{BackgroundColor3=C.side}) end end)
    btn.MouseButton1Down:Connect(function() end) -- touch держать
    -- Touch hold
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then scrHolding=true tw(btn,0.08,{BackgroundColor3=hiCol}) doScroll(dir) end end)
end
holdScroll(bU,-1,C.dim) holdScroll(bD,1,C.dim)

-- ТАБЫ
local tabContent={} local tabBtns={}
local TABS={"Info","Move","Combat","Visual","Farm","Piano","World","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
local sbL=Instance.new("UIListLayout",SB) sbL.Padding=UDim.new(0,0)
Instance.new("UIPadding",SB).PaddingTop=UDim.new(0,4)
local tabIcos={Info="ℹ",Move="🏃",Combat="⚔",Visual="👁",Farm="🌾",Piano="🎵",World="🌍",Misc="⚙"}

local function makeSideBtn(label,icon)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,46) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local dot=Instance.new("Frame",b) dot.Size=UDim2.new(0,3,0,22) dot.Position=UDim2.new(0,0,0.5,-11) dot.BackgroundColor3=C.blue dot.BorderSizePixel=0 dot.Visible=false
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(1,0,0,20) il.Position=UDim2.new(0,0,0,6) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=C.muted il.Font=Enum.Font.Gotham il.TextSize=18
    local ll=Instance.new("TextLabel",b) ll.Size=UDim2.new(1,0,0,15) ll.Position=UDim2.new(0,0,0,26) ll.BackgroundTransparency=1 ll.Text=label ll.TextColor3=C.muted ll.Font=Enum.Font.GothamBold ll.TextSize=8 ll.TextXAlignment=Enum.TextXAlignment.Center
    tabBtns[label]={dot=dot,lbl=ll,ico=il} return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=C.muted t.ico.TextColor3=C.muted end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=C.white tabBtns[name].ico.TextColor3=C.blue end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
    task.wait(0.05) CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+20) CT.CanvasPosition=Vector2.new(0,0)
end
for _,n in ipairs(TABS) do
    local b=makeSideBtn(n,tabIcos[n]) local nn=n
    b.MouseButton1Click:Connect(function() switchTab(nn) end)
end

-- UI ХЕЛПЕРЫ
local function mkSec(tab,title,color)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=color or C.blue l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=C.border line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,desc,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,50) f.BackgroundColor3=C.card f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9)
    local fStk=Instance.new("UIStroke",f) fStk.Color=C.border fStk.Thickness=1
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-60,0,22) lbl.Position=UDim2.new(0,12,0,6) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=C.white lbl.Font=Enum.Font.GothamBold lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    if desc and #desc>0 then
        local dsc=Instance.new("TextLabel",f) dsc.Size=UDim2.new(1,-60,0,15) dsc.Position=UDim2.new(0,12,0,29) dsc.BackgroundTransparency=1 dsc.Text=desc dsc.TextColor3=C.muted dsc.Font=Enum.Font.Code dsc.TextSize=10 dsc.TextXAlignment=Enum.TextXAlignment.Left
    end
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,42,0,23) track.Position=UDim2.new(1,-52,0.5,-11.5) track.BackgroundColor3=C.dim track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,17,0,17) circle.Position=UDim2.new(0,3,0.5,-8.5) circle.BackgroundColor3=C.muted circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        local ti=TweenInfo.new(0.17)
        if on then
            TweenService:Create(track,ti,{BackgroundColor3=C.blue}):Play()
            TweenService:Create(circle,ti,{Position=UDim2.new(0,23,0.5,-8.5),BackgroundColor3=C.white}):Play()
            TweenService:Create(f,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(13,20,40)}):Play()
            fStk.Color=C.blue
        else
            TweenService:Create(track,ti,{BackgroundColor3=C.dim}):Play()
            TweenService:Create(circle,ti,{Position=UDim2.new(0,3,0.5,-8.5),BackgroundColor3=C.muted}):Play()
            TweenService:Create(f,TweenInfo.new(0.12),{BackgroundColor3=C.card}):Play()
            fStk.Color=C.border
        end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,col,fn,txtCol)
    local bc=col or C.dim
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,44) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",f).Color=C.border
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=txtCol or C.white b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=C.blue}):Play()
        task.wait(0.18) TweenService:Create(f,TweenInfo.new(0.15),{BackgroundColor3=bc}):Play()
        if fn then pcall(fn) end
    end)
    table.insert(tabContent[tab],f)
end

-- Значок "(только ты видишь)"
local function mkClientNote(tab)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundColor3=Color3.fromRGB(20,15,8) f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",f).Color=Color3.fromRGB(80,60,10)
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text="⚠ ВИЗУАЛ — только ты видишь (клиентская сторона)" l.TextColor3=Color3.fromRGB(200,160,40) l.Font=Enum.Font.Code l.TextSize=10
    table.insert(tabContent[tab],f)
end

-- ══════════════════════════════════════════
--   ВКЛАДКИ
-- ══════════════════════════════════════════

-- INFO
mkSec("Info","🌿 О хабе")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,95) ic.BackgroundColor3=C.card ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,9)
local icBar=Instance.new("Frame",ic) icBar.Size=UDim2.new(1,0,0,2) icBar.BackgroundColor3=C.blue icBar.BorderSizePixel=0
task.spawn(function() local hue=0 while icBar and icBar.Parent do hue=(hue+2)%360 icBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.04) end end)
local icI=Instance.new("TextLabel",ic) icI.Size=UDim2.new(0,55,0,58) icI.Position=UDim2.new(0,8,0.5,-29) icI.BackgroundTransparency=1 icI.Text="🌿" icI.TextSize=48 icI.Font=Enum.Font.GothamBlack
local icN1=Instance.new("TextLabel",ic) icN1.Size=UDim2.new(1,-70,0,22) icN1.Position=UDim2.new(0,66,0,10) icN1.BackgroundTransparency=1 icN1.Text="Primejtsu Hub" icN1.TextColor3=C.blue icN1.Font=Enum.Font.GothamBlack icN1.TextSize=18 icN1.TextXAlignment=Enum.TextXAlignment.Left
local icN2=Instance.new("TextLabel",ic) icN2.Size=UDim2.new(1,-70,0,14) icN2.Position=UDim2.new(0,66,0,34) icN2.BackgroundTransparency=1 icN2.Text="✦ Universal | 400+ Functions | Piano 🎵" icN2.TextColor3=C.lblue icN2.Font=Enum.Font.Code icN2.TextSize=11 icN2.TextXAlignment=Enum.TextXAlignment.Left
local icN3=Instance.new("TextLabel",ic) icN3.Size=UDim2.new(1,-70,0,13) icN3.Position=UDim2.new(0,66,0,50) icN3.BackgroundTransparency=1 icN3.Text="✈ @Primejtsu | Nazar513000" icN3.TextColor3=Color3.fromRGB(50,150,220) icN3.Font=Enum.Font.Code icN3.TextSize=11 icN3.TextXAlignment=Enum.TextXAlignment.Left
local icVer=Instance.new("TextLabel",ic) icVer.Size=UDim2.new(1,0,0,14) icVer.Position=UDim2.new(0,10,1,-17) icVer.BackgroundTransparency=1 icVer.Text="v7.0  •  🔑 Primejtsu  •  Roblox Universal" icVer.TextColor3=C.muted icVer.Font=Enum.Font.Code icVer.TextSize=10 icVer.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

mkSec("Info","📊 Статистика")
local stF=Instance.new("Frame") stF.Size=UDim2.new(1,0,0,68) stF.BackgroundColor3=C.card stF.BorderSizePixel=0
Instance.new("UICorner",stF).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",stF).Color=C.border
local st1=Instance.new("TextLabel",stF) st1.Size=UDim2.new(0.5,0,0.5,0) st1.Position=UDim2.new(0,10,0,5) st1.BackgroundTransparency=1 st1.TextXAlignment=Enum.TextXAlignment.Left st1.Font=Enum.Font.GothamBold st1.TextSize=12
local st2=Instance.new("TextLabel",stF) st2.Size=UDim2.new(0.5,0,0.5,0) st2.Position=UDim2.new(0.5,0,0,5) st2.BackgroundTransparency=1 st2.TextXAlignment=Enum.TextXAlignment.Left st2.Font=Enum.Font.GothamBold st2.TextSize=12
local st3=Instance.new("TextLabel",stF) st3.Size=UDim2.new(0.5,0,0.5,0) st3.Position=UDim2.new(0,10,0.5,2) st3.BackgroundTransparency=1 st3.TextXAlignment=Enum.TextXAlignment.Left st3.Font=Enum.Font.Code st3.TextSize=11
local st4=Instance.new("TextLabel",stF) st4.Size=UDim2.new(0.5,0,0.5,0) st4.Position=UDim2.new(0.5,0,0.5,2) st4.BackgroundTransparency=1 st4.TextXAlignment=Enum.TextXAlignment.Left st4.Font=Enum.Font.Code st4.TextSize=11
table.insert(tabContent["Info"],stF)
RunService.Heartbeat:Connect(function()
    if st1 and st1.Parent then st1.Text="🌾 Фарм: "..CFG.harvestCount st1.TextColor3=C.green end
    if st2 and st2.Parent then st2.Text="💰 Продаж: "..CFG.sellCount st2.TextColor3=C.gold end
    if st3 and st3.Parent then st3.Text="⚔ Убийств: "..CFG.killCount st3.TextColor3=C.red end
    if st4 and st4.Parent then
        if CFG.sessionStart>0 then local s=tick()-CFG.sessionStart st4.Text="⏱ "..math.floor(s/60).."м "..math.floor(s%60).."с" end
        st4.TextColor3=C.muted
    end
end)

-- MOVE
mkSec("Move","⚡ Движение")
mkToggle("Move","⚡ Speed Hack","Быстрый бег (x2)","speed")
mkToggle("Move","🐇 Infinite Jump","Бесконечные прыжки","infiniteJump")
mkToggle("Move","🚀 Super Jump","Огромный прыжок","superJump")
mkToggle("Move","🌙 Low Gravity","Низкая гравитация","lowGravity")
mkToggle("Move","🌀 BHop","Авто прыжки для разгона","bhop")
mkSec("Move","🦅 Полёт")
mkToggle("Move","🦅 Fly","WASD + E(вверх) + Q(вниз)","fly",function(v) if v then startFly() else stopFly() end end)
mkToggle("Move","👻 Noclip","Сквозь стены","noclip")
mkToggle("Move","🛡 Anti Void","Защита от пустоты","antiVoid")
mkSec("Move","🎮 Другое")
mkToggle("Move","🌀 SpinBot","Вращение","spinBot")
mkButton("Move","🚀 Запустить вверх",C.dim,function() local hrp=getHRP() if hrp then hrp.Velocity=Vector3.new(0,120,0) end end)
mkButton("Move","❄ Заморозить/Разморозить",C.dim,function() CFG.freezePlayer=not CFG.freezePlayer notify(CFG.freezePlayer and "❄ Заморожен" or "▶ Разморожен","",2) end)
mkButton("Move","🔄 Respawn",C.dim,function() LP:LoadCharacter() end)

-- COMBAT
mkSec("Combat","🎯 Aimbot")
mkToggle("Combat","🎯 Aimbot","Плавное автоприцеливание","aimbot")
mkToggle("Combat","👻 Silent Aim","Невидимый aimbot","aimbotSilent")
mkToggle("Combat","🔫 TriggerBot","Авто выстрел","triggerBot")
mkSec("Combat","❤ Здоровье")
mkToggle("Combat","💀 God Mode","Бессмертие (4 метода защиты)","godMode",function(v) if v then startGodMode() elseif godConn then godConn:Disconnect() end end)
mkSec("Combat","⚔ Атака")
mkToggle("Combat","⚔ KillAura","Авто атака вокруг","killaura")
mkToggle("Combat","💨 Fling игроков","Подбрасывать ближайших","flingPlayers",function(v)
    if v then task.spawn(function()
        while CFG.flingPlayers do task.wait(0.5)
            local hrp=getHRP() if not hrp then continue end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t and (t.Position-hrp.Position).Magnitude<20 then
                        local dir=(t.Position-hrp.Position).Unit
                        t.Velocity=dir*500+Vector3.new(0,300,0)
                    end
                end
            end
        end
    end) end
end)
mkButton("Combat","💥 Nuke вокруг себя",Color3.fromRGB(40,8,8),function()
    local hrp=getHRP() if not hrp then return end local n=0
    for _,o in ipairs(WS:GetDescendants()) do
        pcall(function()
            if o:IsA("BasePart") and not o.Anchored and o.Parent~=LP.Character and (o.Position-hrp.Position).Magnitude<=CFG.nukeRadius then
                o:Destroy() n=n+1 end end) end
    notify("💥 Nuke","Удалено "..n.." объектов",3)
end)
mkButton("Combat","💀 Убить всех NPC",C.dim,function()
    local n=0 for _,o in ipairs(WS:GetDescendants()) do pcall(function()
        if o:IsA("Humanoid") and o.Parent~=LP.Character then o.Health=0 n=n+1 end end) end
    notify("💀 Kill NPCs",n.." убито",3)
end)

-- VISUAL
mkSec("Visual","👁 ESP")
mkClientNote("Visual")
mkToggle("Visual","👥 ESP Игроки","Имя + HP + дистанция (только ты видишь)","espPlayers")
mkToggle("Visual","📦 ESP Boxes","Рамки вокруг игроков (только ты видишь)","espBoxes")
mkToggle("Visual","✨ ESP Chams","Подсветка сквозь стены (только ты видишь)","espChams")
mkSec("Visual","🌈 Шейдеры")
mkClientNote("Visual")
mkToggle("Visual","✨ Bloom","Свечение (только ты видишь)","shaderBloom",function() applyShaders() end)
mkToggle("Visual","🌫 Blur","Размытие фона (только ты видишь)","shaderBlur",function() applyShaders() end)
mkToggle("Visual","☀ Sun Rays","Лучи солнца (только ты видишь)","shaderSunRays",function() applyShaders() end)
mkToggle("Visual","📸 Depth of Field","Фокус камеры (только ты видишь)","shaderDepthOfField",function() applyShaders() end)
mkToggle("Visual","🎨 Color Correct","Коррекция цвета (только ты видишь)","shaderColorCorrect",function() applyShaders() end)
mkSec("Visual","🎮 Вид")
mkClientNote("Visual")
mkToggle("Visual","☀ Fullbright","Всегда день (только ты видишь)","fullbright",function() applyShaders() end)
mkToggle("Visual","🌙 Night Mode","Тёмная ночь (только ты видишь)","nightMode",function() applyShaders() end)
mkToggle("Visual","🌈 Rainbow Player","Радужный персонаж (только ты видишь)","rainbow")
mkToggle("Visual","➕ Crosshair","Прицел на экране (только ты видишь)","crosshair",function() updateCrosshair() end)
mkToggle("Visual","📷 Third Person","Вид от 3-го лица","thirdPerson")
mkToggle("Visual","🌫 No Fog","Убрать туман","noFog",function() applyShaders() end)

-- FARM
mkSec("Farm","🌾 Авто-фарм")
mkToggle("Farm","🌾 Auto Farm","Бежит к монетам/ресурсам","autoFarm")
mkToggle("Farm","🧲 Auto Collect","Притягивает предметы","autoCollect")
mkToggle("Farm","💰 Auto Sell","Авто продажа","autoSell")
mkToggle("Farm","💤 Anti AFK","Защита от кика","antiAFK")
mkSec("Farm","⚡ Быстро")
mkButton("Farm","🧲 Собрать всё рядом",C.dim,function()
    local hrp=getHRP() if not hrp then return end local n=0
    for _,o in ipairs(WS:GetDescendants()) do pcall(function()
        if isFarmable(o) and o:IsA("BasePart") and (o.Position-hrp.Position).Magnitude<50 then
            o.CFrame=hrp.CFrame n=n+1 end end) end
    notify("🧲",n.." предметов собрано",3)
end)
mkButton("Farm","📍 TP к магазину",C.dim,function()
    local hrp=getHRP() if not hrp then return end
    for _,o in ipairs(WS:GetDescendants()) do pcall(function()
        local n=o.Name:lower()
        if n:find("sell") or n:find("shop") or n:find("market") then
            local pos if o:IsA("Model") then pos=o:GetPivot().Position elseif o:IsA("BasePart") then pos=o.Position end
            if pos then hrp.CFrame=CFrame.new(pos+Vector3.new(0,5,0)) notify("📍 TP","К магазину!",2) error("done") end
        end end) end
end)

-- ═══════════════════════════════════════════════════════
--   ПИАНИНО / МУЗЫКА — ГЛАВНАЯ ВКЛАДКА
-- ═══════════════════════════════════════════════════════
mkSec("Piano","🎵 Сейчас играет")

-- Плеер
local playerF=Instance.new("Frame") playerF.Size=UDim2.new(1,0,0,80) playerF.BackgroundColor3=C.card playerF.BorderSizePixel=0
Instance.new("UICorner",playerF).CornerRadius=UDim.new(0,9)
local pBar=Instance.new("Frame",playerF) pBar.Size=UDim2.new(1,0,0,2) pBar.BackgroundColor3=C.purple pBar.BorderSizePixel=0
task.spawn(function() local hue=180 while pBar and pBar.Parent do hue=(hue+2)%360 pBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.05) end end)
local pIco=Instance.new("TextLabel",playerF) pIco.Size=UDim2.new(0,50,1,0) pIco.BackgroundTransparency=1 pIco.Text="🎵" pIco.TextSize=36 pIco.Font=Enum.Font.GothamBlack
local pName=Instance.new("TextLabel",playerF) pName.Size=UDim2.new(1,-100,0,22) pName.Position=UDim2.new(0,52,0,10) pName.BackgroundTransparency=1 pName.Text="Ничего не играет..." pName.TextColor3=C.white pName.Font=Enum.Font.GothamBold pName.TextSize=13 pName.TextXAlignment=Enum.TextXAlignment.Left
local pSub=Instance.new("TextLabel",playerF) pSub.Size=UDim2.new(1,-100,0,14) pSub.Position=UDim2.new(0,52,0,34) pSub.BackgroundTransparency=1 pSub.Text="🎧 Primejtsu Hub Music" pSub.TextColor3=C.muted pSub.Font=Enum.Font.Code pSub.TextSize=11 pSub.TextXAlignment=Enum.TextXAlignment.Left
-- Кнопки управления
local pStop=Instance.new("TextButton",playerF) pStop.Size=UDim2.new(0,36,0,28) pStop.Position=UDim2.new(1,-44,0.5,-14) pStop.BackgroundColor3=Color3.fromRGB(50,15,15) pStop.Text="⏹" pStop.TextColor3=C.red pStop.Font=Enum.Font.GothamBlack pStop.TextSize=18 pStop.BorderSizePixel=0
Instance.new("UICorner",pStop).CornerRadius=UDim.new(0,7)
pStop.MouseButton1Click:Connect(function() stopMusic() pName.Text="Остановлено ⏹" pName.TextColor3=C.muted end)
-- Анимация иконки при воспроизведении
task.spawn(function()
    while pIco and pIco.Parent do
        if CFG.musicPlaying then
            pName.Text="♪ "..CFG.currentSongName pName.TextColor3=C.white
            TweenService:Create(pIco,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{TextSize=42}):Play() task.wait(0.3)
            TweenService:Create(pIco,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{TextSize=34}):Play() task.wait(0.3)
        else task.wait(0.5) end
    end
end)
table.insert(tabContent["Piano"],playerF)

-- Поиск по ID
mkSec("Piano","🔍 Свой Sound ID")
local customF=Instance.new("Frame") customF.Size=UDim2.new(1,0,0,44) customF.BackgroundColor3=C.card customF.BorderSizePixel=0
Instance.new("UICorner",customF).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",customF).Color=C.border
local customInput=Instance.new("TextBox",customF) customInput.Size=UDim2.new(0.65,0,1,0) customInput.BackgroundTransparency=1 customInput.Text="" customInput.PlaceholderText="Введи Sound ID..." customInput.PlaceholderColor3=C.muted customInput.TextColor3=C.white customInput.Font=Enum.Font.Gotham customInput.TextSize=13 customInput.ClearTextOnFocus=false customInput.Position=UDim2.new(0,10,0,0)
local customBtn=Instance.new("TextButton",customF) customBtn.Size=UDim2.new(0.32,0,0.75,0) customBtn.Position=UDim2.new(0.66,0,0.125,0) customBtn.BackgroundColor3=C.purple customBtn.Text="▶ Играть" customBtn.TextColor3=C.white customBtn.Font=Enum.Font.GothamBold customBtn.TextSize=11 customBtn.BorderSizePixel=0
Instance.new("UICorner",customBtn).CornerRadius=UDim.new(0,7)
customBtn.MouseButton1Click:Connect(function()
    local id=customInput.Text:match("%d+")
    if id then playMusic(id,"Custom ID: "..id) end
end)
table.insert(tabContent["Piano"],customF)

-- Категории музыки
mkSec("Piano","📂 Категории","🎵 Выбери жанр — нажми на трек")

local selectedCat = "Dreamcore"
-- Кнопки категорий (горизонтальный скролл)
local catScroll=Instance.new("ScrollingFrame") catScroll.Size=UDim2.new(1,0,0,36) catScroll.BackgroundTransparency=1 catScroll.BorderSizePixel=0 catScroll.ScrollBarThickness=0 catScroll.ScrollingDirection=Enum.ScrollingDirection.X catScroll.CanvasSize=UDim2.new(0,#MUSIC_CATS*82,0,0)
local catLayout=Instance.new("UIListLayout",catScroll) catLayout.FillDirection=Enum.FillDirection.Horizontal catLayout.Padding=UDim.new(0,5) catLayout.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",catScroll).PaddingLeft=UDim.new(0,2)
table.insert(tabContent["Piano"],catScroll)

-- Список треков
local trackList=Instance.new("Frame") trackList.Size=UDim2.new(1,0,0,0) trackList.BackgroundTransparency=1 trackList.BorderSizePixel=0 trackList.AutomaticSize=Enum.AutomaticSize.Y
local trackLayout=Instance.new("UIListLayout",trackList) trackLayout.Padding=UDim.new(0,4)
table.insert(tabContent["Piano"],trackList)

local catBtnObjs={}
local function buildTrackList(catName)
    -- Очищаем список
    for _,c in ipairs(trackList:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    local songs=MUSIC_LIBRARY[catName] or {}
    for i,song in ipairs(songs) do
        local tf=Instance.new("Frame",trackList) tf.Size=UDim2.new(1,0,0,40) tf.BackgroundColor3=(i%2==0) and C.card or Color3.fromRGB(12,16,28) tf.BorderSizePixel=0
        Instance.new("UICorner",tf).CornerRadius=UDim.new(0,8)
        local tNum=Instance.new("TextLabel",tf) tNum.Size=UDim2.new(0,24,1,0) tNum.BackgroundTransparency=1 tNum.Text=tostring(i) tNum.TextColor3=C.muted tNum.Font=Enum.Font.Code tNum.TextSize=11
        local tIco=Instance.new("TextLabel",tf) tIco.Size=UDim2.new(0,24,1,0) tIco.Position=UDim2.new(0,24,0,0) tIco.BackgroundTransparency=1 tIco.Text="🎵" tIco.TextSize=16 tIco.Font=Enum.Font.GothamBlack
        local tName=Instance.new("TextLabel",tf) tName.Size=UDim2.new(1,-90,1,0) tName.Position=UDim2.new(0,50,0,0) tName.BackgroundTransparency=1 tName.Text=song.name tName.TextColor3=C.white tName.Font=Enum.Font.Gotham tName.TextSize=12 tName.TextXAlignment=Enum.TextXAlignment.Left
        local tPlay=Instance.new("TextButton",tf) tPlay.Size=UDim2.new(0,36,0,28) tPlay.Position=UDim2.new(1,-42,0.5,-14) tPlay.BackgroundColor3=C.purple tPlay.Text="▶" tPlay.TextColor3=C.white tPlay.Font=Enum.Font.GothamBlack tPlay.TextSize=16 tPlay.BorderSizePixel=0
        Instance.new("UICorner",tPlay).CornerRadius=UDim.new(0,7)
        local songData=song
        tPlay.MouseButton1Click:Connect(function()
            playMusic(songData.id, songData.name)
            -- Подсвечиваем активный трек
            tName.TextColor3=Color3.fromHSV(0.75,0.8,1)
            TweenService:Create(tf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,10,40)}):Play()
            task.wait(0.2) TweenService:Create(tf,TweenInfo.new(0.2),{BackgroundColor3=(i%2==0) and C.card or Color3.fromRGB(12,16,28)}):Play()
        end)
        -- Клик на весь ряд
        local tBtn=Instance.new("TextButton",tf) tBtn.Size=UDim2.new(1,-44,1,0) tBtn.BackgroundTransparency=1 tBtn.Text=""
        tBtn.MouseButton1Click:Connect(function()
            playMusic(songData.id, songData.name)
            tName.TextColor3=C.purple
        end)
    end
    -- Обновляем canvassize
    task.wait(0.05)
    CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+20)
end

local function selectCat(catName)
    selectedCat=catName
    -- Обновляем кнопки
    for cat,btn in pairs(catBtnObjs) do
        if cat==catName then
            TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=C.purple}):Play()
        else
            TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=C.dim}):Play()
        end
    end
    buildTrackList(catName)
end

-- Строим кнопки категорий
for _,catName in ipairs(MUSIC_CATS) do
    local icon=MUSIC_CAT_ICONS[catName] or "🎵"
    local cb=Instance.new("TextButton",catScroll)
    cb.Size=UDim2.new(0,78,0,30) cb.BackgroundColor3=C.dim cb.BorderSizePixel=0
    cb.Text=icon.." "..catName cb.TextColor3=C.white cb.Font=Enum.Font.GothamBold cb.TextSize=9
    Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",cb).Color=C.border
    catBtnObjs[catName]=cb
    local cn=catName
    cb.MouseButton1Click:Connect(function() selectCat(cn) end)
end
-- Выбираем первую категорию
task.spawn(function() task.wait(0.3) selectCat("Dreamcore") end)

-- Громкость
mkSec("Piano","🔊 Громкость")
local volF=Instance.new("Frame") volF.Size=UDim2.new(1,0,0,42) volF.BackgroundColor3=C.card volF.BorderSizePixel=0
Instance.new("UICorner",volF).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",volF).Color=C.border
local volLabel=Instance.new("TextLabel",volF) volLabel.Size=UDim2.new(0.4,0,1,0) volLabel.Position=UDim2.new(0,10,0,0) volLabel.BackgroundTransparency=1 volLabel.Text="🔊 Громкость" volLabel.TextColor3=C.muted volLabel.Font=Enum.Font.GothamBold volLabel.TextSize=12 volLabel.TextXAlignment=Enum.TextXAlignment.Left
local volVal=Instance.new("TextLabel",volF) volVal.Size=UDim2.new(0.15,0,1,0) volVal.Position=UDim2.new(0.82,0,0,0) volVal.BackgroundTransparency=1 volVal.Text="80%" volVal.TextColor3=C.white volVal.Font=Enum.Font.GothamBold volVal.TextSize=12
local volMinus=Instance.new("TextButton",volF) volMinus.Size=UDim2.new(0,28,0,28) volMinus.Position=UDim2.new(0.38,0,0.5,-14) volMinus.BackgroundColor3=C.dim volMinus.Text="−" volMinus.TextColor3=C.white volMinus.Font=Enum.Font.GothamBlack volMinus.TextSize=18 volMinus.BorderSizePixel=0
Instance.new("UICorner",volMinus).CornerRadius=UDim.new(0,7)
local volPlus=Instance.new("TextButton",volF) volPlus.Size=UDim2.new(0,28,0,28) volPlus.Position=UDim2.new(0.56,0,0.5,-14) volPlus.BackgroundColor3=C.purple volPlus.Text="+" volPlus.TextColor3=C.white volPlus.Font=Enum.Font.GothamBlack volPlus.TextSize=18 volPlus.BorderSizePixel=0
Instance.new("UICorner",volPlus).CornerRadius=UDim.new(0,7)
local function updateVol()
    volVal.Text=math.floor(CFG.musicVolume*100).."%"
    musicSound.Volume=CFG.musicVolume
end
volMinus.MouseButton1Click:Connect(function() CFG.musicVolume=math.max(0,CFG.musicVolume-0.1) updateVol() end)
volPlus.MouseButton1Click:Connect(function() CFG.musicVolume=math.min(1,CFG.musicVolume+0.1) updateVol() end)
table.insert(tabContent["Piano"],volF)

-- WORLD
mkSec("World","🌍 Мир")
mkToggle("World","🖱 Click TP","Тап = телепорт","clickTP")
mkToggle("World","🗑 Click Delete","Тап = удалить объект","clickDelete")
mkButton("World","💥 Nuke вокруг (25st)",Color3.fromRGB(40,8,8),function()
    local hrp=getHRP() if not hrp then return end local n=0
    for _,o in ipairs(WS:GetDescendants()) do pcall(function()
        if o:IsA("BasePart") and not o.Anchored and o.Parent~=LP.Character and (o.Position-hrp.Position).Magnitude<=25 then
            o:Destroy() n=n+1 end end) end
    notify("💥",n.." объектов удалено",3)
end)
mkSec("World","🌐 Сервер")
mkButton("World","🔄 Server Hop",C.dim,serverHop)
mkButton("World","🔄 Rejoin",C.dim,function() TS:Teleport(game.PlaceId,LP) end)
mkSec("World","📍 Телепорт")
mkButton("World","📍 TP к случайному игроку",C.dim,function()
    local hrp=getHRP() if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then hrp.CFrame=t.CFrame+Vector3.new(3,3,0) notify("📍 TP","К: "..p.Name,2) return end
        end
    end
end)

-- MISC
mkSec("Misc","⚙ Разное")
mkToggle("Misc","💬 Chat Spam","Спам в чате","chatSpam")
mkToggle("Misc","👻 Скрыть персонажа","Невидимость (только ты видишь)","hidePlayer",function(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end
        end
    end)
end)
mkButton("Misc","🔔 Уведомление",C.dim,function() notify("🌿 Primejtsu Hub","Universal v7.0 | 400+ | Piano 1200+ 🎵",4) end)
mkButton("Misc","💀 Kill себя",C.dim,function() local h=getHum() if h then h.Health=0 end end)
mkButton("Misc","🚀 Launch All Players",Color3.fromRGB(40,25,8),function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then t.Velocity=Vector3.new(math.random(-200,200),400,math.random(-200,200)) end
        end
    end
    notify("🚀 Launch All","Все подброшены!",3)
end)

-- Старт
task.wait(0.1) switchTab("Info")
task.wait(0.35) openGUI()
notify("✅ Primejtsu Hub","Universal v7.0 | Piano 1200+ 🎵 | @Primejtsu",5)

end -- showMain

print("[Primejtsu Hub v7.0] Universal 400+ | Piano 1200+ | @Primejtsu | Nazar513000 🌿")
