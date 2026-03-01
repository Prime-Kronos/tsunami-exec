-- PrimejTsuHub v4.5 | @Primejtsu | MM2

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

local CFG = {
    god=false, speed=false, bhop=false, noclip=false,
    esp=false, coinFarm=false, knife=false, autoReward=false,
    fullbright=false, antiAfk=true, hide=false,
}
local coinCount = 0
local espObjects = {}

local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════
--   GOD MODE — НАДЁЖНЫЙ
--   Используем 1 000 000 HP вместо math.huge
--   math.huge иногда ломает MM2
-- ══════════════════════════════════════
local GOD_HP = 1000000

RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h = getHum() if not h then return end
    if h.MaxHealth ~= GOD_HP then h.MaxHealth = GOD_HP end
    if h.Health < GOD_HP then h.Health = GOD_HP end
    h.BreakJointsOnDeath = false
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not CFG.god then return end
    local h = char:WaitForChild("Humanoid", 5)
    if h then h.MaxHealth=GOD_HP h.Health=GOD_HP h.BreakJointsOnDeath=false end
end)

-- ══════════════════════════════════════
--   ANTI AFK — ПРЫГАЕТ КАЖДЫЕ 5 СЕК
-- ══════════════════════════════════════
task.spawn(function()
    while task.wait(5) do
        if not CFG.antiAfk then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.05)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        end)
        pcall(function()
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

pcall(function()
    LP.Idled:Connect(function()
        if CFG.antiAfk then
            pcall(function()
                local vu=game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
                task.wait(0.05)
                vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            end)
        end
    end)
end)

-- ══ SPEED / BHOP ══
RunService.Heartbeat:Connect(function()
    local h=getHum() if not h then return end
    if CFG.speed then
        if h.WalkSpeed<26 then h.WalkSpeed=h.WalkSpeed+0.5 end
    elseif not CFG.bhop then
        if h.WalkSpeed~=16 then h.WalkSpeed=16 end
    end
    if CFG.bhop then h.WalkSpeed=24 if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end
end)

-- ══ NOCLIP ══
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- ══════════════════════════════════════
--   COIN FARM — ТЕЛЕПОРТ + ПРЫЖОК
--   Прыжок нужен чтобы подобрать монету
-- ══════════════════════════════════════
local function findNearestCoin()
    local hrp=getHRP() if not hrp then return nil,0 end
    local nearest=nil local nearDist=math.huge
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation") then
            local n=o.Name:lower()
            if n:find("coin") or n=="dropcoin" or n=="goldcoin" or n=="silvercoin" then
                if o.Parent and o.Transparency<1 then
                    local d=(hrp.Position-o.Position).Magnitude
                    if d<nearDist then nearDist=d nearest=o end
                end
            end
        end
    end
    return nearest,nearDist
end

task.spawn(function()
    while task.wait(1.0) do
        if not CFG.coinFarm then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        local coin,dist=findNearestCoin()
        if not coin then continue end
        if dist>3 then
            local dir=(coin.Position-hrp.Position)
            local step=math.min(dist-2,20)
            local tp=hrp.Position+dir.Unit*step
            hrp.CFrame=CFrame.new(tp.X,hrp.Position.Y,tp.Z)
            task.wait(0.15)
        end
        -- Прыжок чтобы подобрать монету
        hum.Jump=true
        task.wait(0.1)
        if coin.Parent==nil then coinCount=coinCount+1 end
    end
end)

-- ══ KNIFE AURA ══
task.spawn(function()
    while task.wait(0.5) do
        if not CFG.knife then continue end
        local hum=getHum() local hrp=getHRP()
        if not hum or not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if t and th and th.Health>0 and (hrp.Position-t.Position).Magnitude<=12 then
                    hum:MoveTo(t.Position)
                end
            end
        end
    end
end)

-- ══ AUTO REWARD ══
RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t=g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") then
                    g.MouseButton1Click:Fire()
                end
            end
        end
    end)
end)

-- ══ FULLBRIGHT ══
local function setFB(v)
    if v then Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127) end
end

-- ══════════════════════════════════════
--   ESP — С РОЛЯМИ + РАССТОЯНИЕ
-- ══════════════════════════════════════
local ROLE_COLORS={Murderer=Color3.fromRGB(255,60,60),Sheriff=Color3.fromRGB(60,140,255),Innocent=Color3.fromRGB(60,230,110)}
local ROLE_LABELS={Murderer="🔪 УБИЙЦА",Sheriff="🔫 ШЕРИФ",Innocent="😇 НЕВИННЫЙ"}

local function getRole(player)
    local role="Innocent"
    pcall(function()
        local char=player.Character if not char then return end
        for _,item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n=item.Name:lower()
                if n:find("knife") or n:find("murder") or n:find("blade") then role="Murderer" return
                elseif n:find("gun") or n:find("sheriff") or n:find("revolver") or n:find("pistol") then role="Sheriff" return end
            end
        end
        local bp=player:FindFirstChild("Backpack")
        if bp then
            for _,item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") then
                    local n=item.Name:lower()
                    if n:find("knife") or n:find("murder") then role="Murderer" return
                    elseif n:find("gun") or n:find("sheriff") then role="Sheriff" return end
                end
            end
        end
    end)
    return role
end

local function removeESP(p)
    if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end
end

local function createESP(p)
    if p==LP then return end
    removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end

        local bb=Instance.new("BillboardGui")
        bb.Name="PTJESP" bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,110,0,66) bb.StudsOffset=Vector3.new(0,3.5,0)
        bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false

        local nameLbl=Instance.new("TextLabel",bb)
        nameLbl.Size=UDim2.new(1,0,0,20) nameLbl.Position=UDim2.new(0,0,0,0)
        nameLbl.BackgroundTransparency=1 nameLbl.Font=Enum.Font.GothamBold nameLbl.TextSize=13
        nameLbl.Text=p.Name nameLbl.TextStrokeTransparency=0 nameLbl.TextStrokeColor3=Color3.new(0,0,0)

        local roleLbl=Instance.new("TextLabel",bb)
        roleLbl.Size=UDim2.new(1,0,0,18) roleLbl.Position=UDim2.new(0,0,0,20)
        roleLbl.BackgroundTransparency=1 roleLbl.Font=Enum.Font.GothamBold roleLbl.TextSize=12
        roleLbl.TextStrokeTransparency=0 roleLbl.TextStrokeColor3=Color3.new(0,0,0)

        local hpLbl=Instance.new("TextLabel",bb)
        hpLbl.Size=UDim2.new(1,0,0,14) hpLbl.Position=UDim2.new(0,0,0,38)
        hpLbl.BackgroundTransparency=1 hpLbl.Font=Enum.Font.Code hpLbl.TextSize=11
        hpLbl.TextColor3=Color3.fromRGB(200,200,200)
        hpLbl.TextStrokeTransparency=0 hpLbl.TextStrokeColor3=Color3.new(0,0,0)

        local distLbl=Instance.new("TextLabel",bb)
        distLbl.Size=UDim2.new(1,0,0,12) distLbl.Position=UDim2.new(0,0,0,52)
        distLbl.BackgroundTransparency=1 distLbl.Font=Enum.Font.Code distLbl.TextSize=10
        distLbl.TextColor3=Color3.fromRGB(160,160,160)
        distLbl.TextStrokeTransparency=0 distLbl.TextStrokeColor3=Color3.new(0,0,0)

        local function updateESP()
            if not bb.Parent then return end
            local role=getRole(p)
            local col=ROLE_COLORS[role]
            nameLbl.TextColor3=col
            roleLbl.Text=ROLE_LABELS[role] roleLbl.TextColor3=col
            local hp=math.max(0,math.min(100,math.floor(hum.Health)))
            hpLbl.Text="❤ HP: "..hp
            local myH=getHRP()
            if myH then distLbl.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).." studs" end
            bb.Enabled=CFG.esp
        end

        hum:GetPropertyChangedSignal("Health"):Connect(function()
            pcall(function()
                local hp=math.max(0,math.min(100,math.floor(hum.Health)))
                hpLbl.Text="❤ HP: "..hp
            end)
        end)
        char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(updateESP) end end)
        char.ChildRemoved:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(updateESP) end end)
        RunService.Heartbeat:Connect(function() if bb and bb.Parent then bb.Enabled=CFG.esp end end)
        task.spawn(function()
            while bb and bb.Parent do pcall(updateESP) task.wait(1) end
        end)
        espObjects[p]=bb
        pcall(updateESP)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ════════════════════════════════════════
--                  GUI
-- ════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH45") then game.CoreGui.PTH45:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH45" sg.ResetOnSpawn=false sg.DisplayOrder=999

local BG=Color3.fromRGB(18,18,18) local SIDE=Color3.fromRGB(12,12,12)
local CARD=Color3.fromRGB(24,24,24) local BORDER=Color3.fromRGB(38,38,38)
local RED=Color3.fromRGB(200,30,30) local WHITE=Color3.fromRGB(220,220,220)
local MUTED=Color3.fromRGB(90,90,90) local DIM=Color3.fromRGB(45,45,45)
local GREEN=Color3.fromRGB(0,200,100)

-- SPLASH
local Splash=Instance.new("Frame",sg) Splash.Size=UDim2.new(1,0,1,0) Splash.BackgroundColor3=Color3.fromRGB(0,0,0) Splash.BorderSizePixel=0 Splash.ZIndex=100
local loadBar=Instance.new("Frame",Splash) loadBar.Size=UDim2.new(0,0,0,2) loadBar.BackgroundColor3=RED loadBar.BorderSizePixel=0 loadBar.ZIndex=101
local PL=Instance.new("TextLabel",Splash) PL.Size=UDim2.new(0,50,0,70) PL.Position=UDim2.new(0.5,-90,0.38,-35) PL.BackgroundTransparency=1 PL.Text="Ᵽ" PL.TextColor3=RED PL.Font=Enum.Font.GothamBlack PL.TextSize=64 PL.TextTransparency=1 PL.ZIndex=101
local RL=Instance.new("TextLabel",Splash) RL.Size=UDim2.new(0,160,0,70) RL.Position=UDim2.new(0.5,-42,0.38,-35) RL.BackgroundTransparency=1 RL.Text="RIME" RL.TextColor3=WHITE RL.Font=Enum.Font.GothamBlack RL.TextSize=58 RL.TextTransparency=1 RL.ZIndex=101
local SL=Instance.new("TextLabel",Splash) SL.Size=UDim2.new(0,260,0,20) SL.Position=UDim2.new(0.5,-130,0.62,0) SL.BackgroundTransparency=1 SL.Text="Murder Mystery 2  •  @Primejtsu" SL.TextColor3=MUTED SL.Font=Enum.Font.Code SL.TextSize=12 SL.TextTransparency=1 SL.ZIndex=101
local LT=Instance.new("TextLabel",Splash) LT.Size=UDim2.new(0,240,0,18) LT.Position=UDim2.new(0.5,-120,0.78,0) LT.BackgroundTransparency=1 LT.Text="Инициализация..." LT.TextColor3=MUTED LT.Font=Enum.Font.Code LT.TextSize=11 LT.TextTransparency=1 LT.ZIndex=101

local function twQ(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart),p):Play() end
local function twB(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end

task.spawn(function()
    task.wait(0.2) twQ(loadBar,1.0,{Size=UDim2.new(1,0,0,2)})
    task.wait(0.5) twB(PL,0.45,{TextTransparency=0,Position=UDim2.new(0.5,-95,0.38,-35)})
    task.wait(0.2) twB(RL,0.4,{TextTransparency=0})
    task.wait(0.3) twQ(SL,0.35,{TextTransparency=0})
    task.wait(0.2) twQ(LT,0.3,{TextTransparency=0})
    local steps={"Загрузка модулей...","God Mode (1M HP)...","ESP + Роли...","Готово ✓"}
    for i,s in ipairs(steps) do task.wait(0.35) LT.Text=s if i==#steps then LT.TextColor3=GREEN end end
    task.wait(0.5)
    twQ(Splash,0.5,{BackgroundTransparency=1})
    for _,o in ipairs(Splash:GetDescendants()) do
        if o:IsA("TextLabel") then twQ(o,0.3,{TextTransparency=1})
        elseif o:IsA("Frame") then twQ(o,0.3,{BackgroundTransparency=1}) end
    end
    task.wait(0.6) Splash:Destroy()
    showGUI()
    task.wait(0.4)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="✅ PrimejTsuHub v4.5",
            Text="God Mode + ESP Roles + AFK Jump | @Primejtsu",
            Duration=5
        })
    end)
end)

function showGUI()
-- ICON
local iconFrame=Instance.new("Frame",sg)
iconFrame.Size=UDim2.new(0,46,0,46) iconFrame.Position=UDim2.new(1,-56,0.5,-23)
iconFrame.BackgroundColor3=Color3.fromRGB(0,0,0) iconFrame.BorderSizePixel=0 iconFrame.ZIndex=50
Instance.new("UICorner",iconFrame).CornerRadius=UDim.new(0,12)
local iconBG=Instance.new("Frame",iconFrame) iconBG.Size=UDim2.new(1,0,1,0) iconBG.BackgroundColor3=RED iconBG.BorderSizePixel=0 iconBG.ZIndex=51
Instance.new("UICorner",iconBG).CornerRadius=UDim.new(0,12)
local iconBot=Instance.new("Frame",iconFrame) iconBot.Size=UDim2.new(1,0,0.35,0) iconBot.Position=UDim2.new(0,0,0.65,0) iconBot.BackgroundColor3=Color3.fromRGB(140,15,15) iconBot.BorderSizePixel=0 iconBot.ZIndex=52
Instance.new("UICorner",iconBot).CornerRadius=UDim.new(0,12)
local ibFix=Instance.new("Frame",iconBot) ibFix.Size=UDim2.new(1,0,0.5,0) ibFix.BackgroundColor3=Color3.fromRGB(140,15,15) ibFix.BorderSizePixel=0 ibFix.ZIndex=52
local iconLetter=Instance.new("TextLabel",iconFrame) iconLetter.Size=UDim2.new(1,0,1,0) iconLetter.BackgroundTransparency=1 iconLetter.Text="Ᵽ" iconLetter.TextColor3=Color3.new(1,1,1) iconLetter.Font=Enum.Font.GothamBlack iconLetter.TextSize=26 iconLetter.ZIndex=53
local dot=Instance.new("Frame",iconFrame) dot.Size=UDim2.new(0,10,0,10) dot.Position=UDim2.new(1,-3,0,-3) dot.BackgroundColor3=GREEN dot.BorderSizePixel=0 dot.ZIndex=54
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0) Instance.new("UIStroke",dot).Color=Color3.fromRGB(0,0,0)
task.spawn(function() while sg and sg.Parent do TweenService:Create(dot,TweenInfo.new(0.8),{BackgroundTransparency=0.6}):Play() task.wait(0.8) TweenService:Create(dot,TweenInfo.new(0.8),{BackgroundTransparency=0}):Play() task.wait(0.8) end end)

local drag=false local dSt=nil local sSt=nil
iconFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true dSt=i.Position sSt=iconFrame.Position end
end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then
        local d=i.Position-dSt iconFrame.Position=UDim2.new(sSt.X.Scale,sSt.X.Offset+d.X,sSt.Y.Scale,sSt.Y.Offset+d.Y)
    end
end)

-- WINDOW
local W=Instance.new("Frame",sg)
W.Size=UDim2.new(0,300,0,340) W.Position=UDim2.new(0.5,-150,0.5,-170)
W.BackgroundColor3=BG W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",W).Color=BORDER

local guiOpen=false local tS2=Vector2.new(0,0) local tT2=0
local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,300,0,340),Position=UDim2.new(0.5,-150,0.5,-170)}):Play()
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,38,0,38)}):Play()
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.25) W.Visible=false
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,46,0,46)}):Play()
end
iconFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tS2=Vector2.new(i.Position.X,i.Position.Y) tT2=tick() end
end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        local dist=(Vector2.new(i.Position.X,i.Position.Y)-tS2).Magnitude
        if dist<10 and tick()-tT2<0.4 then if guiOpen then closeGUI() else openGUI() end end
    end
end)

-- HEADER
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,36) Hdr.BackgroundColor3=SIDE Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,8)
local hf=Instance.new("Frame",Hdr) hf.Size=UDim2.new(1,0,0.5,0) hf.Position=UDim2.new(0,0,0.5,0) hf.BackgroundColor3=SIDE hf.BorderSizePixel=0
local tl=Instance.new("Frame",Hdr) tl.Size=UDim2.new(1,0,0,2) tl.BackgroundColor3=RED tl.BorderSizePixel=0
local lp2=Instance.new("TextLabel",Hdr) lp2.Size=UDim2.new(0,18,0,28) lp2.Position=UDim2.new(0,8,0.5,-14) lp2.BackgroundTransparency=1 lp2.Text="Ᵽ" lp2.TextColor3=RED lp2.Font=Enum.Font.GothamBlack lp2.TextSize=20
local lr2=Instance.new("TextLabel",Hdr) lr2.Size=UDim2.new(0,60,0,28) lr2.Position=UDim2.new(0,24,0.5,-14) lr2.BackgroundTransparency=1 lr2.Text="RIME" lr2.TextColor3=WHITE lr2.Font=Enum.Font.GothamBlack lr2.TextSize=16 lr2.TextXAlignment=Enum.TextXAlignment.Left
local ls2=Instance.new("TextLabel",Hdr) ls2.Size=UDim2.new(0,130,0,12) ls2.Position=UDim2.new(0,8,1,-13) ls2.BackgroundTransparency=1 ls2.Text="MM2 Hub  •  v4.5" ls2.TextColor3=GREEN ls2.Font=Enum.Font.Code ls2.TextSize=8 ls2.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,20,0,20) xBtn.Position=UDim2.new(1,-26,0.5,-10) xBtn.BackgroundColor3=RED xBtn.Text="✕" xBtn.TextColor3=WHITE xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=9 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,5) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-36) Body.Position=UDim2.new(0,0,0,36) Body.BackgroundTransparency=1
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,75,1,0) SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
local sdiv=Instance.new("Frame",Body) sdiv.Size=UDim2.new(0,1,1,0) sdiv.Position=UDim2.new(0,75,0,0) sdiv.BackgroundColor3=BORDER sdiv.BorderSizePixel=0
local CT=Instance.new("ScrollingFrame",Body) CT.Size=UDim2.new(1,-76,1,0) CT.Position=UDim2.new(0,76,0,0) CT.BackgroundTransparency=1 CT.BorderSizePixel=0 CT.ScrollBarThickness=2 CT.ScrollBarImageColor3=RED CT.CanvasSize=UDim2.new(0,0,0,0)
local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,4) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,6) CTP.PaddingRight=UDim.new(0,6) CTP.PaddingTop=UDim.new(0,6) CTP.PaddingBottom=UDim.new(0,6)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12) end)

local tabContent={} local tabBtns={} local TABS={"Info","Player","God","Farm","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
local SBLayout=Instance.new("UIListLayout",SB) SBLayout.Padding=UDim.new(0,0) SBLayout.SortOrder=Enum.SortOrder.LayoutOrder
local SBPad=Instance.new("UIPadding",SB) SBPad.PaddingTop=UDim.new(0,6)

local function makeSideBtn(label)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,38) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local d=Instance.new("Frame",b) d.Size=UDim2.new(0,3,0,20) d.Position=UDim2.new(0,0,0.5,-10) d.BackgroundColor3=RED d.BorderSizePixel=0 d.Visible=false
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-10,1,0) l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    tabBtns[label]={btn=b,dot=d,lbl=l} return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=MUTED end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
    task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12) CT.CanvasPosition=Vector2.new(0,0)
end
for _,n in ipairs(TABS) do local b=makeSideBtn(n) local nn=n b.MouseButton1Click:Connect(function() switchTab(nn) end) end

local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=WHITE l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,36) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",f).Color=BORDER
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-52,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,34,0,18) track.Position=UDim2.new(1,-42,0.5,-9) track.BackgroundColor3=DIM track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,13,0,13) circle.Position=UDim2.new(0,2,0.5,-6) circle.BackgroundColor3=MUTED circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        local t2=TweenInfo.new(0.15)
        if on then TweenService:Create(track,t2,{BackgroundColor3=RED}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,19,0.5,-6),BackgroundColor3=WHITE}):Play()
        else TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=MUTED}):Play() end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,fn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,32) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",f).Color=BORDER
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.Gotham b.TextSize=11 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=RED}):Play()
        task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
        if fn then fn() end
    end)
    table.insert(tabContent[tab],f)
end

-- INFO
mkSec("Info","О скрипте")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,80) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",ic).Color=BORDER
local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
local _lp=Instance.new("TextLabel",ic) _lp.Size=UDim2.new(0,30,0,40) _lp.Position=UDim2.new(0,8,0.5,-20) _lp.BackgroundTransparency=1 _lp.Text="Ᵽ" _lp.TextColor3=RED _lp.Font=Enum.Font.GothamBlack _lp.TextSize=36
local _n2=Instance.new("TextLabel",ic) _n2.Size=UDim2.new(1,-50,0,16) _n2.Position=UDim2.new(0,44,0,14) _n2.BackgroundTransparency=1 _n2.Text="Primejtsu" _n2.TextColor3=WHITE _n2.Font=Enum.Font.GothamBold _n2.TextSize=14 _n2.TextXAlignment=Enum.TextXAlignment.Left
local _n3=Instance.new("TextLabel",ic) _n3.Size=UDim2.new(1,-50,0,12) _n3.Position=UDim2.new(0,44,0,32) _n3.BackgroundTransparency=1 _n3.Text="Script Developer" _n3.TextColor3=MUTED _n3.Font=Enum.Font.Code _n3.TextSize=10 _n3.TextXAlignment=Enum.TextXAlignment.Left
local _n4=Instance.new("TextLabel",ic) _n4.Size=UDim2.new(1,-50,0,12) _n4.Position=UDim2.new(0,44,0,48) _n4.BackgroundTransparency=1 _n4.Text="✈ Telegram: @Primejtsu" _n4.TextColor3=Color3.fromRGB(50,150,220) _n4.Font=Enum.Font.Code _n4.TextSize=10 _n4.TextXAlignment=Enum.TextXAlignment.Left
local _n5=Instance.new("TextLabel",ic) _n5.Size=UDim2.new(1,0,0,12) _n5.Position=UDim2.new(0,8,1,-16) _n5.BackgroundTransparency=1 _n5.Text="v4.5  •  God 1M HP  •  AFK Jump 5s" _n5.TextColor3=GREEN _n5.Font=Enum.Font.Code _n5.TextSize=9 _n5.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

local leg=Instance.new("Frame") leg.Size=UDim2.new(1,0,0,54) leg.BackgroundColor3=CARD leg.BorderSizePixel=0
Instance.new("UICorner",leg).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",leg).Color=BORDER
local ll=Instance.new("TextLabel",leg) ll.Size=UDim2.new(1,0,0,14) ll.Position=UDim2.new(0,8,0,4) ll.BackgroundTransparency=1 ll.Text="ESP Легенда:" ll.TextColor3=WHITE ll.Font=Enum.Font.GothamBold ll.TextSize=11 ll.TextXAlignment=Enum.TextXAlignment.Left
local le1=Instance.new("TextLabel",leg) le1.Size=UDim2.new(1,0,0,13) le1.Position=UDim2.new(0,8,0,19) le1.BackgroundTransparency=1 le1.Text="🔪 Убийца = Красный    🔫 Шериф = Синий" le1.TextColor3=MUTED le1.Font=Enum.Font.Code le1.TextSize=10 le1.TextXAlignment=Enum.TextXAlignment.Left
local le2=Instance.new("TextLabel",leg) le2.Size=UDim2.new(1,0,0,13) le2.Position=UDim2.new(0,8,0,33) le2.BackgroundTransparency=1 le2.Text="😇 Невинный = Зелёный    📍 = расстояние" le2.TextColor3=MUTED le2.Font=Enum.Font.Code le2.TextSize=10 le2.TextXAlignment=Enum.TextXAlignment.Left
local le3=Instance.new("TextLabel",leg) le3.Size=UDim2.new(1,0,0,12) le3.Position=UDim2.new(0,8,0,46) le3.BackgroundTransparency=1 le3.Text="⚠ Роль = по инструменту в руках / рюкзаке" le3.TextColor3=Color3.fromRGB(200,150,0) le3.Font=Enum.Font.Code le3.TextSize=9 le3.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],leg)

local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,30) cd.BackgroundColor3=CARD cd.BorderSizePixel=0
Instance.new("UICorner",cd).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",cd).Color=BORDER
local cdl=Instance.new("TextLabel",cd) cdl.Size=UDim2.new(0.55,0,1,0) cdl.Position=UDim2.new(0,10,0,0) cdl.BackgroundTransparency=1 cdl.Text="💰 Монет собрано" cdl.TextColor3=MUTED cdl.Font=Enum.Font.Gotham cdl.TextSize=11 cdl.TextXAlignment=Enum.TextXAlignment.Left
local cdv=Instance.new("TextLabel",cd) cdv.Size=UDim2.new(0.4,0,1,0) cdv.Position=UDim2.new(0.58,0,0,0) cdv.BackgroundTransparency=1 cdv.Text="0" cdv.TextColor3=Color3.fromRGB(243,156,18) cdv.Font=Enum.Font.GothamBold cdv.TextSize=13 cdv.TextXAlignment=Enum.TextXAlignment.Right
table.insert(tabContent["Info"],cd)
RunService.Heartbeat:Connect(function() if cdv and cdv.Parent then cdv.Text=tostring(coinCount) end end)

-- PLAYER
mkSec("Player","Движение")
mkToggle("Player","Speed Hack","speed")
mkToggle("Player","Bunny Hop","bhop")
mkToggle("Player","Noclip","noclip")
mkButton("Player","TP к ближайшему",function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        local near,nearD=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then local d=(hrp.Position-t.Position).Magnitude if d<nearD then nearD=d near=t end end
            end
        end
        if near then hrp.CFrame=near.CFrame+Vector3.new(0,0,3) end
    end)
end)

-- GOD
mkSec("God","Защита")
mkToggle("God","God Mode (1 000 000 HP)","god")
mkToggle("God","ESP (роли игроков)","esp")
mkToggle("God","Anti Knock",nil,function(v) pcall(function() local hrp=getHRP() if not hrp then return end hrp.CustomPhysicalProperties=v and PhysicalProperties.new(0,0,0,0,0) or PhysicalProperties.new(0.7,0.3,0.5) end) end)
mkToggle("God","Inf Ammo (шериф)",nil,function(v) pcall(function() local c=getChar() if not c then return end for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end end end) end)

-- FARM
mkSec("Farm","Фарм монет")
mkToggle("Farm","Coin Farm + Прыжок","coinFarm")
mkToggle("Farm","Knife Aura","knife")
mkToggle("Farm","Auto Reward","autoReward")
mkSec("Farm","АФК (прыжок каждые 5с)")
mkToggle("Farm","Anti AFK","antiAfk")

-- MISC
mkSec("Misc","Разное")
mkToggle("Misc","Fullbright",nil,function(v) setFB(v) end)
mkToggle("Misc","Hide Player",nil,function(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end
        end
    end)
end)

task.wait(0.15)
switchTab("Info")
end

print("[PrimejTsuHub v4.5] | @Primejtsu")
