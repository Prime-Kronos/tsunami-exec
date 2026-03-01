-- PrimejTsuHub v4.1 | @Primejtsu | MM2
-- Floating кнопка-иконка для открытия/закрытия GUI

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- ══ CFG ══
local CFG = {
    god=false, speed=false, bhop=false, noclip=false,
    esp=false, coinFarm=false, knife=false, autoReward=false,
    fullbright=false, antiAfk=true, hide=false, antiTsunami=false,
}
local coinCount = 0

local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══ ANTI AFK ══
pcall(function()
    local vu=game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if CFG.antiAfk then vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(1) vu:Button2Up(Vector2.new(0,0),Camera.CFrame) end
    end)
end)

-- ══ LOOPS ══
RunService.Heartbeat:Connect(function()
    local h=getHum() if not h then return end
    if CFG.god then h.MaxHealth=math.huge h.Health=math.huge h.BreakJointsOnDeath=false end
    if CFG.speed then if h.WalkSpeed<30 then h.WalkSpeed=h.WalkSpeed+1 end
    elseif not CFG.bhop then if h.WalkSpeed~=16 then h.WalkSpeed=16 end end
    if CFG.bhop then h.WalkSpeed=28 if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end
    if CFG.antiTsunami and h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
end)

RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
end)

local coinNames={Coin=true,DropCoin=true,GoldCoin=true,SilverCoin=true,coin=true}
local lastTP=0 local cidx=1
RunService.Heartbeat:Connect(function()
    if not CFG.coinFarm then return end
    if tick()-lastTP<0.45 then return end lastTP=tick()
    local hrp=getHRP() if not hrp then return end
    local coins={} for _,o in ipairs(workspace:GetDescendants()) do if coinNames[o.Name] and o:IsA("BasePart") then table.insert(coins,o) end end
    if #coins==0 then return end
    if cidx>#coins then cidx=1 end
    local t=coins[cidx] cidx=cidx+1
    if t and t.Parent then hrp.CFrame=CFrame.new(t.Position.X,hrp.Position.Y,t.Position.Z) end
end)

local lastKnife=0
RunService.Heartbeat:Connect(function()
    if not CFG.knife then return end
    if tick()-lastKnife<0.4 then return end lastKnife=tick()
    local hrp=getHRP() if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if t and hum and hum.Health>0 and (hrp.Position-t.Position).Magnitude<=10 then
                hrp.CFrame=t.CFrame+Vector3.new(0,0,2) task.wait(0.3)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t=g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") then g.MouseButton1Click:Fire() end
            end
        end
    end)
end)

local function setFB(v)
    if v then Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127) end
end

local function trackCoins(char)
    local hrp=char:WaitForChild("HumanoidRootPart",5) if not hrp then return end
    hrp.Touched:Connect(function(hit) if CFG.coinFarm and coinNames[hit.Name] then coinCount=coinCount+1 end end)
end
LP.CharacterAdded:Connect(function(c) task.wait(0.5) trackCoins(c) end)
if LP.Character then trackCoins(LP.Character) end

-- ════════════════════════════════════════
--                  GUI
-- ════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH41") then game.CoreGui.PTH41:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH41" sg.ResetOnSpawn=false sg.DisplayOrder=999

local BG    =Color3.fromRGB(18,18,18)
local SIDE  =Color3.fromRGB(12,12,12)
local CARD  =Color3.fromRGB(24,24,24)
local BORDER=Color3.fromRGB(38,38,38)
local RED   =Color3.fromRGB(200,30,30)
local WHITE =Color3.fromRGB(220,220,220)
local MUTED =Color3.fromRGB(90,90,90)
local DIM   =Color3.fromRGB(45,45,45)
local GREEN =Color3.fromRGB(0,200,100)

-- ════ SPLASH ════
local Splash=Instance.new("Frame",sg)
Splash.Size=UDim2.new(1,0,1,0) Splash.BackgroundColor3=Color3.fromRGB(0,0,0) Splash.BorderSizePixel=0 Splash.ZIndex=100

local loadBar=Instance.new("Frame",Splash) loadBar.Size=UDim2.new(0,0,0,2) loadBar.BackgroundColor3=RED loadBar.BorderSizePixel=0 loadBar.ZIndex=101
local PL=Instance.new("TextLabel",Splash) PL.Size=UDim2.new(0,50,0,70) PL.Position=UDim2.new(0.5,-90,0.38,-35) PL.BackgroundTransparency=1 PL.Text="Ᵽ" PL.TextColor3=RED PL.Font=Enum.Font.GothamBlack PL.TextSize=64 PL.TextTransparency=1 PL.ZIndex=101
local RL=Instance.new("TextLabel",Splash) RL.Size=UDim2.new(0,160,0,70) RL.Position=UDim2.new(0.5,-42,0.38,-35) RL.BackgroundTransparency=1 RL.Text="RIME" RL.TextColor3=WHITE RL.Font=Enum.Font.GothamBlack RL.TextSize=58 RL.TextTransparency=1 RL.ZIndex=101
local SL=Instance.new("TextLabel",Splash) SL.Size=UDim2.new(0,260,0,20) SL.Position=UDim2.new(0.5,-130,0.62,0) SL.BackgroundTransparency=1 SL.Text="Murder Mystery 2  •  @Primejtsu" SL.TextColor3=MUTED SL.Font=Enum.Font.Code SL.TextSize=12 SL.TextTransparency=1 SL.ZIndex=101
local LT=Instance.new("TextLabel",Splash) LT.Size=UDim2.new(0,240,0,18) LT.Position=UDim2.new(0.5,-120,0.78,0) LT.BackgroundTransparency=1 LT.Text="Инициализация..." LT.TextColor3=MUTED LT.Font=Enum.Font.Code LT.TextSize=11 LT.TextTransparency=1 LT.ZIndex=101

local function tw(obj,t,props) TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Quart),props):Play() end
local function twBack(obj,t,props) TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),props):Play() end

task.spawn(function()
    task.wait(0.2)
    tw(loadBar,1.0,{Size=UDim2.new(1,0,0,2)})
    task.wait(0.5)
    twBack(PL,0.45,{TextTransparency=0,Position=UDim2.new(0.5,-95,0.38,-35)})
    task.wait(0.2)
    twBack(RL,0.4,{TextTransparency=0})
    task.wait(0.3)
    tw(SL,0.35,{TextTransparency=0})
    task.wait(0.2)
    tw(LT,0.3,{TextTransparency=0})
    local steps={"Загрузка модулей...","Подключение к MM2...","Готово ✓"}
    for i,s in ipairs(steps) do task.wait(0.4) LT.Text=s if i==#steps then LT.TextColor3=GREEN end end
    task.wait(0.5)
    tw(Splash,0.5,{BackgroundTransparency=1})
    for _,o in ipairs(Splash:GetDescendants()) do
        if o:IsA("TextLabel") then tw(o,0.3,{TextTransparency=1})
        elseif o:IsA("Frame") then tw(o,0.3,{BackgroundTransparency=1}) end
    end
    task.wait(0.6)
    Splash:Destroy()
    showGUI()
    task.wait(0.4)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ PrimejTsuHub",Text="Нажми Ᵽ чтобы открыть | @Primejtsu",Duration=4})
    end)
end)

-- ════════════════════════════════════════
function showGUI()

-- ══════════════════════════════════════
--   FLOATING ICON КНОПКА (как иконка приложения)
-- ══════════════════════════════════════
local iconFrame = Instance.new("Frame", sg)
iconFrame.Size = UDim2.new(0, 46, 0, 46)
iconFrame.Position = UDim2.new(1, -56, 0.5, -23)  -- справа по центру
iconFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
iconFrame.BorderSizePixel = 0
iconFrame.Active = true
iconFrame.Draggable = true
iconFrame.ZIndex = 50
Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 12)

-- Тень под иконкой
local shadow = Instance.new("Frame", iconFrame)
shadow.Size = UDim2.new(1, 6, 1, 6)
shadow.Position = UDim2.new(0, -3, 0, 3)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = 49
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)

-- Красный градиент фон
local iconBG = Instance.new("Frame", iconFrame)
iconBG.Size = UDim2.new(1,0,1,0)
iconBG.BackgroundColor3 = RED
iconBG.BorderSizePixel = 0
iconBG.ZIndex = 51
Instance.new("UICorner", iconBG).CornerRadius = UDim.new(0, 12)

-- Тёмная полоска снизу (как у иконок приложений)
local iconBottom = Instance.new("Frame", iconFrame)
iconBottom.Size = UDim2.new(1,0,0.35,0)
iconBottom.Position = UDim2.new(0,0,0.65,0)
iconBottom.BackgroundColor3 = Color3.fromRGB(140,15,15)
iconBottom.BorderSizePixel = 0
iconBottom.ZIndex = 52
Instance.new("UICorner", iconBottom).CornerRadius = UDim.new(0, 12)
-- фикс верхних углов у нижней части
local ibFix = Instance.new("Frame", iconBottom)
ibFix.Size = UDim2.new(1,0,0.5,0) ibFix.BackgroundColor3=Color3.fromRGB(140,15,15) ibFix.BorderSizePixel=0 ibFix.ZIndex=52

-- Буква Ᵽ
local iconLetter = Instance.new("TextLabel", iconFrame)
iconLetter.Size = UDim2.new(1,0,1,0)
iconLetter.BackgroundTransparency = 1
iconLetter.Text = "Ᵽ"
iconLetter.TextColor3 = Color3.new(1,1,1)
iconLetter.Font = Enum.Font.GothamBlack
iconLetter.TextSize = 26
iconLetter.ZIndex = 53

-- Маленький красный индикатор (dot) — "активен"
local activeDot = Instance.new("Frame", iconFrame)
activeDot.Size = UDim2.new(0, 10, 0, 10)
activeDot.Position = UDim2.new(1,-3,0,-3)
activeDot.BackgroundColor3 = GREEN
activeDot.BorderSizePixel = 0
activeDot.ZIndex = 54
Instance.new("UICorner", activeDot).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", activeDot).Color = Color3.fromRGB(0,0,0)

-- Пульсация dot
task.spawn(function()
    while sg and sg.Parent do
        TweenService:Create(activeDot,TweenInfo.new(0.8),{BackgroundTransparency=0.5}):Play()
        task.wait(0.8)
        TweenService:Create(activeDot,TweenInfo.new(0.8),{BackgroundTransparency=0}):Play()
        task.wait(0.8)
    end
end)

-- ══════════════════════════════════════
--          ГЛАВНОЕ ОКНО
-- ══════════════════════════════════════
local W = Instance.new("Frame", sg)
W.Size = UDim2.new(0, 300, 0, 340)
W.Position = UDim2.new(0.5, -150, 0.5, -170)
W.BackgroundColor3 = BG
W.BorderSizePixel = 0
W.Active = true
W.Draggable = true
W.ClipsDescendants = true
W.Visible = false  -- скрыто по умолчанию
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", W).Color = BORDER

-- ══ ИКОНКА: открывает / закрывает окно ══
local guiOpen = false
local iconBtn = Instance.new("TextButton", iconFrame)
iconBtn.Size = UDim2.new(1,0,1,0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text = ""
iconBtn.ZIndex = 55

iconBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    if guiOpen then
        W.Visible = true
        W.Size = UDim2.new(0, 0, 0, 0)
        W.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(W, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 340),
            Position = UDim2.new(0.5, -150, 0.5, -170)
        }):Play()
        -- Иконка уменьшается
        TweenService:Create(iconFrame, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 38, 0, 38),
            Position = UDim2.new(1, -48, 0.5, -19)
        }):Play()
    else
        TweenService:Create(W, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.25)
        W.Visible = false
        -- Иконка возвращается
        TweenService:Create(iconFrame, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 46, 0, 46),
            Position = UDim2.new(1, -56, 0.5, -23)
        }):Play()
    end
end)

-- ── ШАПКА ──
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,36) Hdr.BackgroundColor3=SIDE Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,8)
local hf=Instance.new("Frame",Hdr) hf.Size=UDim2.new(1,0,0.5,0) hf.Position=UDim2.new(0,0,0.5,0) hf.BackgroundColor3=SIDE hf.BorderSizePixel=0
local rl2=Instance.new("Frame",Hdr) rl2.Size=UDim2.new(1,0,0,2) rl2.BackgroundColor3=RED rl2.BorderSizePixel=0
local lp2=Instance.new("TextLabel",Hdr) lp2.Size=UDim2.new(0,18,0,28) lp2.Position=UDim2.new(0,8,0.5,-14) lp2.BackgroundTransparency=1 lp2.Text="Ᵽ" lp2.TextColor3=RED lp2.Font=Enum.Font.GothamBlack lp2.TextSize=20
local lr2=Instance.new("TextLabel",Hdr) lr2.Size=UDim2.new(0,60,0,28) lr2.Position=UDim2.new(0,24,0.5,-14) lr2.BackgroundTransparency=1 lr2.Text="RIME" lr2.TextColor3=WHITE lr2.Font=Enum.Font.GothamBlack lr2.TextSize=16 lr2.TextXAlignment=Enum.TextXAlignment.Left
local ls2=Instance.new("TextLabel",Hdr) ls2.Size=UDim2.new(0,100,0,12) ls2.Position=UDim2.new(0,8,1,-13) ls2.BackgroundTransparency=1 ls2.Text="MM2 Hub  •  v4.1" ls2.TextColor3=MUTED ls2.Font=Enum.Font.Code ls2.TextSize=8 ls2.TextXAlignment=Enum.TextXAlignment.Left

-- X кнопка — закрывает GUI и скрывает
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,20,0,20) xBtn.Position=UDim2.new(1,-26,0.5,-10) xBtn.BackgroundColor3=RED xBtn.Text="✕" xBtn.TextColor3=WHITE xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=9 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,5)
xBtn.MouseButton1Click:Connect(function()
    guiOpen = false
    TweenService:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.25) W.Visible=false
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,46,0,46),Position=UDim2.new(1,-56,0.5,-23)}):Play()
end)

-- ── ТЕЛО ──
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-36) Body.Position=UDim2.new(0,0,0,36) Body.BackgroundTransparency=1 Body.BorderSizePixel=0
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,75,1,0) SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
local sdiv=Instance.new("Frame",Body) sdiv.Size=UDim2.new(0,1,1,0) sdiv.Position=UDim2.new(0,75,0,0) sdiv.BackgroundColor3=BORDER sdiv.BorderSizePixel=0
local CT=Instance.new("ScrollingFrame",Body) CT.Size=UDim2.new(1,-76,1,0) CT.Position=UDim2.new(0,76,0,0) CT.BackgroundTransparency=1 CT.BorderSizePixel=0 CT.ScrollBarThickness=2 CT.ScrollBarImageColor3=RED CT.CanvasSize=UDim2.new(0,0,0,0)
local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,4) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,6) CTP.PaddingRight=UDim.new(0,6) CTP.PaddingTop=UDim.new(0,6) CTP.PaddingBottom=UDim.new(0,6)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12) end)

local tabContent={} local tabBtns={}
local TABS={"Info","Player","God","Farm","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end

local SBL=Instance.new("UIListLayout",SB) SBL.Padding=UDim.new(0,0) SBL.SortOrder=Enum.SortOrder.LayoutOrder
local SBP=Instance.new("UIPadding",SB) SBP.PaddingTop=UDim.new(0,6)

local function makeSideBtn(label)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,38) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local dot=Instance.new("Frame",b) dot.Size=UDim2.new(0,3,0,20) dot.Position=UDim2.new(0,0,0.5,-10) dot.BackgroundColor3=RED dot.BorderSizePixel=0 dot.Visible=false
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",b) lbl.Size=UDim2.new(1,-10,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=MUTED lbl.Font=Enum.Font.GothamBold lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Left
    tabBtns[label]={btn=b,dot=dot,lbl=lbl}
    return b
end

local currentFrames={}
local function switchTab(name)
    for _,f in ipairs(currentFrames) do f.Parent=nil end currentFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=MUTED end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(currentFrames,f) end end
    task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12) CT.CanvasPosition=Vector2.new(0,0)
end

for _,n in ipairs(TABS) do local b=makeSideBtn(n) local nn=n b.MouseButton1Click:Connect(function() switchTab(nn) end) end

local function mkSection(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=WHITE l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,36) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",f).Color=BORDER
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

-- ═══ INFO ═══
mkSection("Info","Информация")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,80) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",ic).Color=BORDER
local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
local ip=Instance.new("TextLabel",ic) ip.Size=UDim2.new(0,30,0,40) ip.Position=UDim2.new(0,8,0.5,-20) ip.BackgroundTransparency=1 ip.Text="Ᵽ" ip.TextColor3=RED ip.Font=Enum.Font.GothamBlack ip.TextSize=36
local in2=Instance.new("TextLabel",ic) in2.Size=UDim2.new(1,-50,0,16) in2.Position=UDim2.new(0,44,0,14) in2.BackgroundTransparency=1 in2.Text="Primejtsu" in2.TextColor3=WHITE in2.Font=Enum.Font.GothamBold in2.TextSize=14 in2.TextXAlignment=Enum.TextXAlignment.Left
local in3=Instance.new("TextLabel",ic) in3.Size=UDim2.new(1,-50,0,12) in3.Position=UDim2.new(0,44,0,32) in3.BackgroundTransparency=1 in3.Text="Script Developer" in3.TextColor3=MUTED in3.Font=Enum.Font.Code in3.TextSize=10 in3.TextXAlignment=Enum.TextXAlignment.Left
local in4=Instance.new("TextLabel",ic) in4.Size=UDim2.new(1,-50,0,12) in4.Position=UDim2.new(0,44,0,48) in4.BackgroundTransparency=1 in4.Text="✈ Telegram: @Primejtsu" in4.TextColor3=Color3.fromRGB(50,150,220) in4.Font=Enum.Font.Code in4.TextSize=10 in4.TextXAlignment=Enum.TextXAlignment.Left
local in5=Instance.new("TextLabel",ic) in5.Size=UDim2.new(1,0,0,12) in5.Position=UDim2.new(0,8,1,-16) in5.BackgroundTransparency=1 in5.Text="v4.1  •  MM2  •  Delta Mobile" in5.TextColor3=MUTED in5.Font=Enum.Font.Code in5.TextSize=9 in5.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,30) cd.BackgroundColor3=CARD cd.BorderSizePixel=0
Instance.new("UICorner",cd).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",cd).Color=BORDER
local cdl=Instance.new("TextLabel",cd) cdl.Size=UDim2.new(0.6,0,1,0) cdl.Position=UDim2.new(0,10,0,0) cdl.BackgroundTransparency=1 cdl.Text="💰 Монет собрано" cdl.TextColor3=MUTED cdl.Font=Enum.Font.Gotham cdl.TextSize=11 cdl.TextXAlignment=Enum.TextXAlignment.Left
local cdv=Instance.new("TextLabel",cd) cdv.Size=UDim2.new(0.35,0,1,0) cdv.Position=UDim2.new(0.63,0,0,0) cdv.BackgroundTransparency=1 cdv.Text="0" cdv.TextColor3=Color3.fromRGB(243,156,18) cdv.Font=Enum.Font.GothamBold cdv.TextSize=12 cdv.TextXAlignment=Enum.TextXAlignment.Right
table.insert(tabContent["Info"],cd)
RunService.Heartbeat:Connect(function() cdv.Text=tostring(coinCount) end)

-- ═══ PLAYER ═══
mkSection("Player","Движение")
mkToggle("Player","Speed Hack","speed")
mkToggle("Player","Bunny Hop","bhop")
mkToggle("Player","Noclip","noclip")
mkButton("Player","Auto TP к игроку",function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) break end
            end
        end
    end)
end)

-- ═══ GOD ═══
mkSection("God","Защита")
mkToggle("God","God Mode","god")
mkToggle("God","ESP (сквозь стены)","esp")
mkToggle("God","Anti Knock",nil,function(v) pcall(function() local hrp=getHRP() if not hrp then return end hrp.CustomPhysicalProperties=v and PhysicalProperties.new(0,0,0,0,0) or PhysicalProperties.new(0.7,0.3,0.5) end) end)
mkToggle("God","Inf Ammo (шериф)",nil,function(v) pcall(function() local c=getChar() if not c then return end for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end end end) end)

-- ═══ FARM ═══
mkSection("Farm","Фарм")
mkToggle("Farm","Coin Farm","coinFarm")
mkToggle("Farm","Knife Aura","knife")
mkToggle("Farm","Auto Reward","autoReward")

-- ═══ MISC ═══
mkSection("Misc","Разное")
mkToggle("Misc","Fullbright",nil,function(v) setFB(v) end)
mkToggle("Misc","Anti AFK","antiAfk")
mkToggle("Misc","Hide Player",nil,function(v) pcall(function() local c=getChar() if not c then return end for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end end end) end)
mkToggle("Misc","Anti Tsunami","antiTsunami")

-- Первый таб
task.wait(0.15)
switchTab("Info")

end -- showGUI

print("[PrimejTsuHub v4.1] | Нажми Ᵽ | @Primejtsu")
