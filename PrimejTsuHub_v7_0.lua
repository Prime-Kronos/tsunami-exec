-- ╔══════════════════════════════════════════════════════════════╗
-- ║       PrimejTsuHub v7.0 | @Primejtsu | Nazar513000          ║
-- ║         MM2 | MOBILE EDITION — полностью под телефон        ║
-- ╚══════════════════════════════════════════════════════════════╝

-- СЕРВИСЫ
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local StarterGui   = game:GetService("StarterGui")
local CoreGui      = game:GetService("CoreGui")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- ХЕЛПЕРЫ
local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=dur or 3})
    end)
end

-- CFG
local CFG = {
    speed=false, bhop=false, noclip=false, infiniteJump=false, fly=false,
    god=false, antiKnock=false, infAmmo=false,
    coinFarm=false, bringCoins=false, autoReward=false, knife=false,
    esp=false, fullbright=false, tracers=false,
    bypass=false, antiAfk=true,
    hide=false, bigHead=false, spinBot=false,
    aimbot=false,
}

local coinCount   = 0
local farmPaused  = false
local espObjects  = {}
local victimName  = "Никто"
local noclipWasOn = false
local flyActive   = false
local flyBV       = nil
local flyBG       = nil

-- ════════════════════════════════════════════════════
-- GOD MODE
-- ════════════════════════════════════════════════════
local function applyGod(on)
    pcall(function()
        local h=getHum() if not h then return end
        if on then h.MaxHealth=1e6 h.Health=1e6 h.BreakJointsOnDeath=false end
    end)
end
RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h=getHum() if not h then return end
    if h.Health<h.MaxHealth then h.Health=h.MaxHealth end
    h.BreakJointsOnDeath=false
end)
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if CFG.god then applyGod(true) end
end)

-- ════════════════════════════════════════════════════
-- ANTI AFK
-- ════════════════════════════════════════════════════
pcall(function()
    LP.Idled:Connect(function()
        if not CFG.antiAfk then return end
        local vu=game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
        task.wait(0.1) vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        local h=getHum() if h then h.Jump=true end
    end)
end)
task.spawn(function()
    while true do
        task.wait(55)
        if not CFG.antiAfk then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1) vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

-- ════════════════════════════════════════════════════
-- SPEED / BHOP / INF JUMP
-- ════════════════════════════════════════════════════
UIS.JumpRequest:Connect(function()
    if CFG.infiniteJump then
        local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
RunService.Heartbeat:Connect(function()
    local h=getHum() if not h then return end
    if CFG.coinFarm then return end
    if CFG.speed then h.WalkSpeed=50
    elseif CFG.bhop then
        h.WalkSpeed=28
        if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
    else
        if h.WalkSpeed~=16 then h.WalkSpeed=16 end
    end
end)

-- ════════════════════════════════════════════════════
-- FLY
-- ════════════════════════════════════════════════════
local function enableFly(on)
    local hrp=getHRP()
    if on and hrp then
        flyActive=true
        local bv=Instance.new("BodyVelocity",hrp)
        bv.MaxForce=Vector3.new(1e5,1e5,1e5) bv.Velocity=Vector3.new(0,0,0) flyBV=bv
        local bg=Instance.new("BodyGyro",hrp)
        bg.MaxTorque=Vector3.new(1e5,1e5,1e5) bg.D=500 flyBG=bg
        local h=getHum() if h then h.PlatformStand=true end
        task.spawn(function()
            while flyActive do
                task.wait()
                if not flyBV or not flyBV.Parent then break end
                local cf=Camera.CFrame
                local spd=28
                local vel=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,spd,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,spd,0) end
                flyBV.Velocity=vel
                if flyBG then flyBG.CFrame=cf end
            end
        end)
    else
        flyActive=false
        if flyBV then pcall(function() flyBV:Destroy() end) flyBV=nil end
        if flyBG then pcall(function() flyBG:Destroy() end) flyBG=nil end
        local h=getHum() if h then h.PlatformStand=false end
    end
end

-- ════════════════════════════════════════════════════
-- NOCLIP
-- ════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    if CFG.noclip then
        noclipWasOn=true
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    elseif noclipWasOn then
        noclipWasOn=false
        pcall(function()
            local c=getChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end
            end
            local hrp=getHRP()
            if hrp and hrp.Position.Y<-30 then
                task.wait(0.1)
                hrp.CFrame=CFrame.new(hrp.Position.X,15,hrp.Position.Z)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════
-- COIN FARM v4 — все методы сбора
-- ════════════════════════════════════════════════════
local function isCoin(o)
    if not o or not o.Parent then return false end
    if not(o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation")) then return false end
    if o.Transparency>=0.85 then return false end
    if o.Parent==LP.Character then return false end
    local n=o.Name:lower()
    if n=="coin" or n=="dropcoin" or n=="goldcoin" or n=="silvercoin" or n=="coinpart" or n=="coin_part" then return true end
    if o.Parent and o.Parent:IsA("Model") then
        local pn=o.Parent.Name:lower()
        if pn=="coin" or pn=="dropcoin" or pn=="goldcoin" then return true end
    end
    return false
end

local function collectCoin(target, hrp)
    if not target or not target.Parent then return end
    pcall(function() firetouchinterest(hrp,target,0) firetouchinterest(hrp,target,1) end)
    pcall(function()
        local cd=target:FindFirstChildOfClass("ClickDetector")
        if not cd and target.Parent then cd=target.Parent:FindFirstChildOfClass("ClickDetector") end
        if cd then fireclickdetector(cd) end
    end)
    pcall(function()
        if target.Parent and target.Parent~=workspace and target.Parent:IsA("Model") then
            for _,p in ipairs(target.Parent:GetDescendants()) do
                if p:IsA("BasePart") then
                    firetouchinterest(hrp,p,0)
                    firetouchinterest(hrp,p,1)
                end
            end
        end
    end)
end

-- Авто-триггер монет рядом (без движения)
task.spawn(function()
    while true do
        task.wait(0.15)
        if not CFG.coinFarm then continue end
        local hrp=getHRP() if not hrp then continue end
        pcall(function()
            for _,o in ipairs(workspace:GetDescendants()) do
                if isCoin(o) then
                    if (hrp.Position-o.Position).Magnitude<10 then
                        collectCoin(o,hrp)
                    end
                end
            end
        end)
    end
end)

-- Основной цикл фарма — движение к монетам
task.spawn(function()
    while true do
        task.wait(0.06)
        if not CFG.coinFarm or farmPaused then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum or hum.Health<=0 then continue end

        local coins={}
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then table.insert(coins,o) end
        end
        if #coins==0 then task.wait(0.4) continue end

        local target,bestDist=nil,math.huge
        for _,c in ipairs(coins) do
            pcall(function()
                local d=(hrp.Position-c.Position).Magnitude
                if d<bestDist then bestDist=d target=c end
            end)
        end
        if not target or not target.Parent then continue end

        if bestDist<5 then
            collectCoin(target,hrp) task.wait(0.05) continue
        end

        if bestDist>50 then
            -- Далеко: телепорт в 2 шага
            pcall(function()
                local mid=(hrp.Position+target.Position)/2+Vector3.new(0,4,0)
                hrp.CFrame=CFrame.new(mid)
            end)
            task.wait(0.1)
            pcall(function() hrp.CFrame=CFrame.new(target.Position+Vector3.new(0,2,0)) end)
        elseif bestDist>15 then
            -- Средне: один телепорт
            pcall(function() hrp.CFrame=CFrame.new(target.Position+Vector3.new(0,2,0)) end)
        else
            -- Близко: бег
            hum.WalkSpeed=50
            pcall(function() hum:MoveTo(target.Position) end)
            local t0=tick()
            repeat
                task.wait(0.04)
                if not CFG.coinFarm or hum.Health<=0 then break end
                if not target or not target.Parent then break end
                collectCoin(target,hrp)
            until not target or not target.Parent
                or (hrp.Position-target.Position).Magnitude<3
                or tick()-t0>2
            hum.WalkSpeed=16
            continue
        end

        task.wait(0.05)
        for i=1,5 do
            if not target or not target.Parent then break end
            collectCoin(target,hrp) task.wait(0.04)
        end
        task.wait(math.random(3,10)/100)
    end
end)

-- Bring Coins
task.spawn(function()
    while true do
        task.wait(0.1)
        if not CFG.bringCoins or farmPaused then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then
                pcall(function() o.CFrame=hrp.CFrame+Vector3.new(math.random(-2,2),0,math.random(-2,2)) end)
            end
        end
    end
end)

-- Счётчик монет
task.spawn(function()
    local tracked={}
    while task.wait(0.15) do
        if not CFG.coinFarm and not CFG.bringCoins then continue end
        for _,o in ipairs(workspace:GetDescendants()) do if isCoin(o) then tracked[o]=true end end
        for obj in pairs(tracked) do
            if not obj or not obj.Parent or obj.Transparency>=0.85 then
                coinCount=coinCount+1 tracked[obj]=nil
            end
        end
    end
end)

-- ════════════════════════════════════════════════════
-- BYPASS v4
-- ════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(math.random(10,20))
        if not CFG.bypass then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            for _=1,math.random(2,4) do
                vu:MoveMouse(Vector2.new(math.random(200,900),math.random(150,700)))
                task.wait(math.random(1,3)/10)
            end
        end)
    end
end)
task.spawn(function()
    while true do
        task.wait(math.random(20,40))
        if not CFG.bypass then continue end
        pcall(function() local h=getHum() if h then h.Jump=true end end)
    end
end)
task.spawn(function()
    while true do
        task.wait(math.random(30,60))
        if CFG.bypass and (CFG.coinFarm or CFG.bringCoins) then
            farmPaused=true task.wait(math.random(2,5)) farmPaused=false
        end
    end
end)

-- ════════════════════════════════════════════════════
-- KNIFE AURA
-- ════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.35) do
        if not CFG.knife then continue end
        local hum=getHum() local hrp=getHRP()
        if not hum or not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if t and th and th.Health>0 and (hrp.Position-t.Position).Magnitude<=16 then
                    hum:MoveTo(t.Position)
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════
-- AUTO REWARD
-- ════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t=g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") or t:find("skip") then
                    pcall(function() g.MouseButton1Click:Fire() end)
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════
-- FULLBRIGHT
-- ════════════════════════════════════════════════════
local function setFB(v)
    if v then
        Lighting.Brightness=2.5 Lighting.ClockTime=14
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else
        Lighting.Brightness=1 Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    end
end

-- ════════════════════════════════════════════════════
-- ESP
-- ════════════════════════════════════════════════════
local ROLE_COLORS={Murderer=Color3.fromRGB(255,50,50),Sheriff=Color3.fromRGB(50,130,255),Innocent=Color3.fromRGB(50,220,100)}
local ROLE_LABELS={Murderer="🔪 УБИЙЦА",Sheriff="🔫 ШЕРИФ",Innocent="😇 НЕВИННЫЙ"}

local function getRole(player)
    local role="Innocent"
    pcall(function()
        local char=player.Character if not char then return end
        local function checkTool(item)
            local n=item.Name:lower()
            if n:find("knife") or n:find("murder") or n:find("blade") then role="Murderer"
            elseif n:find("gun") or n:find("sheriff") or n:find("revolver") then role="Sheriff" end
        end
        for _,item in ipairs(char:GetChildren()) do if item:IsA("Tool") then checkTool(item) end end
        local bp=player:FindFirstChild("Backpack")
        if bp then for _,item in ipairs(bp:GetChildren()) do if item:IsA("Tool") then checkTool(item) end end end
    end)
    return role
end

local function removeESP(p) if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end end

local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end
        local bb=Instance.new("BillboardGui") bb.Name="PTJESP" bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,130,0,70) bb.StudsOffset=Vector3.new(0,3.5,0)
        bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false
        local bg=Instance.new("Frame",bb) bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(5,5,8) bg.BackgroundTransparency=0.4 bg.BorderSizePixel=0
        Instance.new("UICorner",bg).CornerRadius=UDim.new(0,5)
        local nL=Instance.new("TextLabel",bb) nL.Size=UDim2.new(1,0,0,22) nL.Position=UDim2.new(0,0,0,2) nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBlack nL.TextSize=13 nL.Text=p.Name nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        local rL=Instance.new("TextLabel",bb) rL.Size=UDim2.new(1,0,0,18) rL.Position=UDim2.new(0,0,0,24) rL.BackgroundTransparency=1 rL.Font=Enum.Font.GothamBold rL.TextSize=12 rL.TextStrokeTransparency=0 rL.TextStrokeColor3=Color3.new(0,0,0)
        local hpBg=Instance.new("Frame",bb) hpBg.Size=UDim2.new(0.85,0,0,5) hpBg.Position=UDim2.new(0.075,0,0,44) hpBg.BackgroundColor3=Color3.fromRGB(30,30,30) hpBg.BorderSizePixel=0
        Instance.new("UICorner",hpBg).CornerRadius=UDim.new(1,0)
        local hpBar=Instance.new("Frame",hpBg) hpBar.Size=UDim2.new(1,0,1,0) hpBar.BackgroundColor3=Color3.fromRGB(50,220,80) hpBar.BorderSizePixel=0
        Instance.new("UICorner",hpBar).CornerRadius=UDim.new(1,0)
        local dL=Instance.new("TextLabel",bb) dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,52) dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=10 dL.TextColor3=Color3.fromRGB(160,160,160) dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        local function upd()
            if not bb.Parent then return end
            local role=getRole(p) local col=ROLE_COLORS[role]
            nL.TextColor3=col rL.Text=ROLE_LABELS[role] rL.TextColor3=col
            local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            hpBar.Size=UDim2.new(pct,0,1,0)
            hpBar.BackgroundColor3=pct>0.6 and Color3.fromRGB(50,220,80) or pct>0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50)
            local myH=getHRP() if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).."st" end
            bb.Enabled=CFG.esp
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        RunService.Heartbeat:Connect(function() if bb and bb.Parent then bb.Enabled=CFG.esp end end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(1) end end)
        espObjects[p]=bb pcall(upd)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ════════════════════════════════════════════════════
-- MISC
-- ════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.infAmmo then return end
    pcall(function()
        local c=getChar() if not c then return end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then
                local a=t:FindFirstChild("Ammo") if a then a.Value=999 end
            end
        end
    end)
end)
RunService.Heartbeat:Connect(function()
    if not CFG.antiKnock then return end
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        hrp.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0)
    end)
end)
RunService.Heartbeat:Connect(function()
    if not CFG.bigHead then return end
    pcall(function()
        local c=getChar() if not c then return end
        local h=c:FindFirstChild("Head") if h then h.Size=Vector3.new(4,4,4) end
    end)
end)
local spinAngle=0
RunService.Heartbeat:Connect(function()
    if not CFG.spinBot then return end
    local hrp=getHRP() if not hrp then return end
    spinAngle=spinAngle+8
    pcall(function() hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,math.rad(spinAngle),0) end)
end)
local function hidePlayer(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end
        end
    end)
end
local function tpToRole(role)
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and getRole(p)==role and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=t.CFrame+Vector3.new(3,0,0) return end
            end
        end
        notify("TP","Роль '"..role.."' не найдена",2)
    end)
end

-- Trol loops
local followActive=false local blockActive=false
task.spawn(function()
    while true do task.wait(0.1)
        if not followActive then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame*CFrame.new(0,0,2.2) end
                end
            end
        end)
    end
end)
task.spawn(function()
    while true do task.wait(0.08)
        if not blockActive then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=CFrame.new(t.Position+t.CFrame.LookVector*2.5,t.Position) end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--   МОБИЛЬНЫЙ UI — специально под телефон
--   • Нет заставки (она блокировала экран)
--   • Маленькое окно 320x500 в правом нижнем углу
--   • Большие кнопки для пальцев (44px высота)
--   • Скролл работает на тач
--   • Кнопка ▲▼ для скролла крупная
--   • Можно перетаскивать окно
-- ════════════════════════════════════════════════════════════════
if CoreGui:FindFirstChild("PTH70") then CoreGui.PTH70:Destroy() end
local sg=Instance.new("ScreenGui",CoreGui)
sg.Name="PTH70" sg.ResetOnSpawn=false sg.DisplayOrder=999 sg.IgnoreGuiInset=true

-- ЦВЕТА
local BG     = Color3.fromRGB(10,10,12)
local SIDE   = Color3.fromRGB(14,14,17)
local CARD   = Color3.fromRGB(22,22,27)
local BORDER = Color3.fromRGB(40,40,50)
local RED    = Color3.fromRGB(215,25,25)
local WHITE  = Color3.fromRGB(228,228,228)
local MUTED  = Color3.fromRGB(85,85,95)
local DIM    = Color3.fromRGB(30,30,38)
local GREEN  = Color3.fromRGB(0,215,100)
local GOLD   = Color3.fromRGB(243,156,18)

-- Размеры под мобильный
local WIN_W = 320
local WIN_H = 500
local TAB_W = 72   -- ширина боковых табов
local HDR_H = 42   -- высота шапки
local SCR_H = 50   -- высота зоны скролл-кнопок

-- Основное окно — правый нижний угол
local Body=Instance.new("Frame",sg)
Body.Size=UDim2.new(0,WIN_W,0,WIN_H)
Body.Position=UDim2.new(1,-WIN_W-8,1,-WIN_H-8)
Body.BackgroundColor3=BG Body.BorderSizePixel=0
Instance.new("UICorner",Body).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",Body).Color=BORDER

-- Шапка
local Header=Instance.new("Frame",Body)
Header.Size=UDim2.new(1,0,0,HDR_H) Header.BackgroundColor3=SIDE Header.BorderSizePixel=0
local hc=Instance.new("UICorner",Header) hc.CornerRadius=UDim.new(0,12)
local hfix=Instance.new("Frame",Header) hfix.Size=UDim2.new(1,0,0.5,0) hfix.Position=UDim2.new(0,0,0.5,0) hfix.BackgroundColor3=SIDE hfix.BorderSizePixel=0
local redLine=Instance.new("Frame",Header) redLine.Size=UDim2.new(1,0,0,2) redLine.Position=UDim2.new(0,0,1,-2) redLine.BackgroundColor3=RED redLine.BorderSizePixel=0

local hIcon=Instance.new("TextLabel",Header) hIcon.Size=UDim2.new(0,26,1,0) hIcon.Position=UDim2.new(0,8,0,0) hIcon.BackgroundTransparency=1 hIcon.Text="Ᵽ" hIcon.TextColor3=RED hIcon.Font=Enum.Font.GothamBlack hIcon.TextSize=24
local hTitle=Instance.new("TextLabel",Header) hTitle.Size=UDim2.new(0,140,1,0) hTitle.Position=UDim2.new(0,36,0,0) hTitle.BackgroundTransparency=1 hTitle.Text="Primejtsu Hub" hTitle.TextColor3=WHITE hTitle.Font=Enum.Font.GothamBlack hTitle.TextSize=15 hTitle.TextXAlignment=Enum.TextXAlignment.Left
local hVer=Instance.new("TextLabel",Header) hVer.Size=UDim2.new(0,50,1,0) hVer.Position=UDim2.new(0,175,0,0) hVer.BackgroundTransparency=1 hVer.Text="v7.0" hVer.TextColor3=MUTED hVer.Font=Enum.Font.Code hVer.TextSize=11 hVer.TextXAlignment=Enum.TextXAlignment.Left

-- Кнопка закрыть (большая для пальца)
local closeBtn=Instance.new("TextButton",Header)
closeBtn.Size=UDim2.new(0,36,0,32) closeBtn.Position=UDim2.new(1,-40,0.5,-16)
closeBtn.BackgroundColor3=Color3.fromRGB(55,10,10) closeBtn.BorderSizePixel=0
closeBtn.Text="✕" closeBtn.TextColor3=WHITE closeBtn.Font=Enum.Font.GothamBold closeBtn.TextSize=16
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,7)

-- Кнопка показать (плавает сбоку)
local toggleBtn=Instance.new("TextButton",sg)
toggleBtn.Size=UDim2.new(0,44,0,44) toggleBtn.Position=UDim2.new(1,-52,1,-52)
toggleBtn.BackgroundColor3=Color3.fromRGB(15,15,20) toggleBtn.BorderSizePixel=0
toggleBtn.Text="Ᵽ" toggleBtn.TextColor3=RED toggleBtn.Font=Enum.Font.GothamBlack toggleBtn.TextSize=26
toggleBtn.Visible=false
Instance.new("UICorner",toggleBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",toggleBtn).Color=BORDER

local guiVisible=true
closeBtn.MouseButton1Click:Connect(function()
    guiVisible=false Body.Visible=false toggleBtn.Visible=true
end)
closeBtn.TouchTap:Connect(function()
    guiVisible=false Body.Visible=false toggleBtn.Visible=true
end)
toggleBtn.MouseButton1Click:Connect(function()
    guiVisible=true Body.Visible=true toggleBtn.Visible=false
end)
toggleBtn.TouchTap:Connect(function()
    guiVisible=true Body.Visible=true toggleBtn.Visible=false
end)

-- Перетаскивание окна (touch)
local dragging=false local dragStart=nil local startPos=nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=i.Position startPos=Body.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local delta=i.Position-dragStart
        Body.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=false
    end
end)

-- Боковые табы
local SB=Instance.new("Frame",Body)
SB.Size=UDim2.new(0,TAB_W,1,-HDR_H) SB.Position=UDim2.new(0,0,0,HDR_H)
SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
local sbBorder=Instance.new("Frame",Body) sbBorder.Size=UDim2.new(0,1,1,-HDR_H) sbBorder.Position=UDim2.new(0,TAB_W,0,HDR_H) sbBorder.BackgroundColor3=BORDER sbBorder.BorderSizePixel=0

-- Контент ScrollingFrame
local CT=Instance.new("ScrollingFrame",Body)
CT.Size=UDim2.new(1,-TAB_W-1,1,-HDR_H-SCR_H)
CT.Position=UDim2.new(0,TAB_W+1,0,HDR_H)
CT.BackgroundTransparency=1 CT.BorderSizePixel=0
CT.ScrollBarThickness=3 CT.ScrollBarImageColor3=RED
CT.CanvasSize=UDim2.new(0,0,0,0)
CT.ScrollingEnabled=true
CT.ElasticBehavior=Enum.ElasticBehavior.Always -- важно для тача

-- Кнопки скролла — крупные для пальца
local scrollZone=Instance.new("Frame",Body)
scrollZone.Size=UDim2.new(1,-TAB_W-1,0,SCR_H)
scrollZone.Position=UDim2.new(0,TAB_W+1,1,-SCR_H)
scrollZone.BackgroundColor3=SIDE scrollZone.BorderSizePixel=0
local szTop=Instance.new("Frame",scrollZone) szTop.Size=UDim2.new(1,0,0,1) szTop.BackgroundColor3=BORDER szTop.BorderSizePixel=0

local btnUp=Instance.new("TextButton",scrollZone)
btnUp.Size=UDim2.new(0.5,-1,1,0) btnUp.Position=UDim2.new(0,0,0,0)
btnUp.BackgroundColor3=SIDE btnUp.BorderSizePixel=0
btnUp.Text="▲" btnUp.TextColor3=MUTED btnUp.Font=Enum.Font.GothamBold btnUp.TextSize=20

local szDiv=Instance.new("Frame",scrollZone) szDiv.Size=UDim2.new(0,1,1,0) szDiv.Position=UDim2.new(0.5,-0.5,0,0) szDiv.BackgroundColor3=BORDER szDiv.BorderSizePixel=0

local btnDown=Instance.new("TextButton",scrollZone)
btnDown.Size=UDim2.new(0.5,-1,1,0) btnDown.Position=UDim2.new(0.5,1,0,0)
btnDown.BackgroundColor3=SIDE btnDown.BorderSizePixel=0
btnDown.Text="▼" btnDown.TextColor3=WHITE btnDown.Font=Enum.Font.GothamBold btnDown.TextSize=20

-- Скролл логика — надёжная для тача
local scrolling=false
local scrollDir=0
local function doScrollLoop()
    task.spawn(function()
        while scrolling do
            local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
            CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+scrollDir*35,0,maxY))
            task.wait(0.04)
        end
    end)
end
local function stopScroll() scrolling=false end
local function startScroll(dir) scrollDir=dir scrolling=true doScrollLoop() end

-- Touch держание — самый надёжный метод
btnUp.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        startScroll(-1)
    end
end)
btnUp.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        stopScroll()
    end
end)
btnDown.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        startScroll(1)
    end
end)
btnDown.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        stopScroll()
    end
end)
-- Тап (одиночное нажатие)
btnUp.MouseButton1Click:Connect(function()
    local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
    CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y-120,0,maxY))
end)
btnDown.MouseButton1Click:Connect(function()
    local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
    CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+120,0,maxY))
end)

-- Layout для контента
local CTL=Instance.new("UIListLayout",CT)
CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT)
CTP.PaddingLeft=UDim.new(0,8) CTP.PaddingRight=UDim.new(0,8) CTP.PaddingTop=UDim.new(0,6) CTP.PaddingBottom=UDim.new(0,6)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12)
end)

-- Система табов
local tabContent={} local tabBtns={}
local TABS={"Info","Player","God","Farm","Visual","Bypass","TP","Trol","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end

Instance.new("UIListLayout",SB).Padding=UDim.new(0,0)

local tabIcons={Info="ℹ",Player="🏃",God="🛡",Farm="💰",Visual="👁",Bypass="🔓",TP="📍",Trol="😈",Misc="⚙"}

local function makeSideBtn(label,icon)
    local b=Instance.new("TextButton",SB)
    b.Size=UDim2.new(1,0,0,44) -- 44px — удобно для пальца
    b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local dot=Instance.new("Frame",b) dot.Size=UDim2.new(0,3,0,20) dot.Position=UDim2.new(0,0,0.5,-10) dot.BackgroundColor3=RED dot.BorderSizePixel=0 dot.Visible=false
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(1,0,0,22) il.Position=UDim2.new(0,0,0,4) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=MUTED il.Font=Enum.Font.Gotham il.TextSize=16
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-2,0,14) l.Position=UDim2.new(0,2,0,26) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=9 l.TextXAlignment=Enum.TextXAlignment.Center
    tabBtns[label]={btn=b,dot=dot,lbl=l,ico=il}
    return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do
        t.dot.Visible=false t.lbl.TextColor3=MUTED t.ico.TextColor3=MUTED
    end
    if tabBtns[name] then
        tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE tabBtns[name].ico.TextColor3=RED
    end
    if tabContent[name] then
        for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end
    end
    task.wait(0.02)
    CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12)
    CT.CanvasPosition=Vector2.new(0,0)
end

for _,n in ipairs(TABS) do
    local b=makeSideBtn(n,tabIcons[n]) local nn=n
    b.MouseButton1Click:Connect(function() switchTab(nn) end)
    b.TouchTap:Connect(function() switchTab(nn) end)
end

-- ──────────────────── UI ХЕЛПЕРЫ ────────────────────
-- Секция-заголовок
local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,20) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title:upper() l.TextColor3=Color3.fromRGB(100,100,115) l.Font=Enum.Font.GothamBold l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

-- Тоггл — 46px высота (удобно для пальца)
local function mkToggle(tab,title,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,46) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",f).Color=BORDER
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-60,1,0) lbl.Position=UDim2.new(0,12,0,0) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.TextWrapped=true
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,44,0,24) track.Position=UDim2.new(1,-52,0.5,-12) track.BackgroundColor3=DIM track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,18,0,18) circle.Position=UDim2.new(0,3,0.5,-9) circle.BackgroundColor3=MUTED circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",f) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    local function toggle()
        on=not on
        local t2=TweenInfo.new(0.15)
        if on then
            TweenService:Create(track,t2,{BackgroundColor3=RED}):Play()
            TweenService:Create(circle,t2,{Position=UDim2.new(0,24,0.5,-9),BackgroundColor3=WHITE}):Play()
        else
            TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play()
            TweenService:Create(circle,t2,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=MUTED}):Play()
        end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end
    btn.MouseButton1Click:Connect(toggle)
    btn.TouchTap:Connect(toggle)
    table.insert(tabContent[tab],f)
end

-- Кнопка — 46px высота
local function mkButton(tab,title,col,fn)
    local bc=col or DIM
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,46) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",f).Color=BORDER
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0 b.TextWrapped=true
    local function press()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=RED}):Play()
        task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=bc}):Play()
        if fn then fn() end
    end
    b.MouseButton1Click:Connect(press)
    b.TouchTap:Connect(press)
    table.insert(tabContent[tab],f)
end

-- ════════════════════════════════
-- ВКЛАДКА: INFO
-- ════════════════════════════════
mkSec("Info","Primejtsu Hub v7.0")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,80) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",ic).Color=BORDER
local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
local lp_ico=Instance.new("TextLabel",ic) lp_ico.Size=UDim2.new(0,34,0,40) lp_ico.Position=UDim2.new(0,10,0.5,-20) lp_ico.BackgroundTransparency=1 lp_ico.Text="Ᵽ" lp_ico.TextColor3=RED lp_ico.Font=Enum.Font.GothamBlack lp_ico.TextSize=38
local n1=Instance.new("TextLabel",ic) n1.Size=UDim2.new(1,-55,0,18) n1.Position=UDim2.new(0,50,0,10) n1.BackgroundTransparency=1 n1.Text="Primejtsu Hub" n1.TextColor3=WHITE n1.Font=Enum.Font.GothamBlack n1.TextSize=16 n1.TextXAlignment=Enum.TextXAlignment.Left
local n2=Instance.new("TextLabel",ic) n2.Size=UDim2.new(1,-55,0,13) n2.Position=UDim2.new(0,50,0,30) n2.BackgroundTransparency=1 n2.Text="✈ @Primejtsu | Nazar513000" n2.TextColor3=Color3.fromRGB(50,150,220) n2.Font=Enum.Font.Code n2.TextSize=11 n2.TextXAlignment=Enum.TextXAlignment.Left
local n3=Instance.new("TextLabel",ic) n3.Size=UDim2.new(1,0,0,13) n3.Position=UDim2.new(0,10,1,-17) n3.BackgroundTransparency=1 n3.Text="v7.0 • Mobile Edition • MM2 🪐" n3.TextColor3=GREEN n3.Font=Enum.Font.Code n3.TextSize=10 n3.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

-- Счётчик монет
local cdFr=Instance.new("Frame") cdFr.Size=UDim2.new(1,0,0,46) cdFr.BackgroundColor3=CARD cdFr.BorderSizePixel=0
Instance.new("UICorner",cdFr).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",cdFr).Color=BORDER
local cdL=Instance.new("TextLabel",cdFr) cdL.Size=UDim2.new(0.6,0,1,0) cdL.Position=UDim2.new(0,12,0,0) cdL.BackgroundTransparency=1 cdL.Text="💰 Монет собрано" cdL.TextColor3=MUTED cdL.Font=Enum.Font.Gotham cdL.TextSize=12 cdL.TextXAlignment=Enum.TextXAlignment.Left
local cdV=Instance.new("TextLabel",cdFr) cdV.Size=UDim2.new(0.35,0,1,0) cdV.Position=UDim2.new(0.62,0,0,0) cdV.BackgroundTransparency=1 cdV.Text="0" cdV.TextColor3=GOLD cdV.Font=Enum.Font.GothamBlack cdV.TextSize=22 cdV.TextXAlignment=Enum.TextXAlignment.Right
table.insert(tabContent["Info"],cdFr)
RunService.Heartbeat:Connect(function() if cdV and cdV.Parent then cdV.Text=tostring(coinCount) end end)

-- Список игроков
mkSec("Info","Игроки")
local plInfoF=Instance.new("Frame") plInfoF.Size=UDim2.new(1,0,0,10) plInfoF.BackgroundTransparency=1 plInfoF.AutomaticSize=Enum.AutomaticSize.Y plInfoF.BorderSizePixel=0
Instance.new("UIListLayout",plInfoF).Padding=UDim.new(0,4)
table.insert(tabContent["Info"],plInfoF)
local function refreshInfoPlayers()
    for _,c in ipairs(plInfoF:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        local role=getRole(p)
        local pf=Instance.new("Frame",plInfoF) pf.Size=UDim2.new(1,0,0,34) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",pf).Color=BORDER
        local col=ROLE_COLORS[role] or WHITE
        local acc=Instance.new("Frame",pf) acc.Size=UDim2.new(0,3,0.6,0) acc.Position=UDim2.new(0,0,0.2,0) acc.BackgroundColor3=col acc.BorderSizePixel=0
        Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(0.7,0,1,0) nm.Position=UDim2.new(0,14,0,0) nm.BackgroundTransparency=1 nm.Text=(p==LP and "★ " or "")..p.Name nm.TextColor3=p==LP and GOLD or WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=12 nm.TextXAlignment=Enum.TextXAlignment.Left
        local rl=Instance.new("TextLabel",pf) rl.Size=UDim2.new(0.28,0,1,0) rl.Position=UDim2.new(0.7,0,0,0) rl.BackgroundTransparency=1 rl.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rl.Font=Enum.Font.GothamBold rl.TextSize=16
    end
end
task.spawn(function() while sg and sg.Parent do pcall(refreshInfoPlayers) task.wait(3) end end)

-- ════════════════════════════════
-- ВКЛАДКА: PLAYER
-- ════════════════════════════════
mkSec("Player","Движение")
mkToggle("Player","⚡ Speed Hack","speed")
mkToggle("Player","🐇 Bunny Hop","bhop")
mkToggle("Player","👻 Noclip","noclip")
mkToggle("Player","🦘 Infinite Jump","infiniteJump")
mkToggle("Player","🕊 Fly","fly",function(v) enableFly(v) end)

-- ════════════════════════════════
-- ВКЛАДКА: GOD
-- ════════════════════════════════
mkSec("God","Защита")
mkToggle("God","❤ God Mode","god",function(v) applyGod(v) end)
mkToggle("God","🛡 Anti Knock","antiKnock")
mkToggle("God","🔫 Inf Ammo","infAmmo")
mkButton("God","💉 Восстановить HP",Color3.fromRGB(15,40,15),function()
    pcall(function() local h=getHum() if h then h.Health=h.MaxHealth end end)
    notify("God","HP восстановлен",2)
end)
mkButton("God","💀 Перезапустить персонажа",Color3.fromRGB(40,10,10),function()
    pcall(function() LP:LoadCharacter() end)
end)

-- ════════════════════════════════
-- ВКЛАДКА: FARM
-- ════════════════════════════════
mkSec("Farm","Монеты")
-- Инфо о методах
local fInfo=Instance.new("Frame") fInfo.Size=UDim2.new(1,0,0,62) fInfo.BackgroundColor3=Color3.fromRGB(10,18,8) fInfo.BorderSizePixel=0
Instance.new("UICorner",fInfo).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",fInfo).Color=Color3.fromRGB(0,140,50)
local fTxt=Instance.new("TextLabel",fInfo) fTxt.Size=UDim2.new(1,-14,1,0) fTxt.Position=UDim2.new(0,7,0,0) fTxt.BackgroundTransparency=1
fTxt.Text="v4: бег(<15st) → телепорт(15-50st) → 2шага(>50st)\nfiretouchinterest + fireclickdetector + авто-тач рядом"
fTxt.TextColor3=Color3.fromRGB(80,200,80) fTxt.Font=Enum.Font.Code fTxt.TextSize=10 fTxt.TextWrapped=true fTxt.TextXAlignment=Enum.TextXAlignment.Left fTxt.TextYAlignment=Enum.TextYAlignment.Center
table.insert(tabContent["Farm"],fInfo)
mkToggle("Farm","🪙 Coin Farm v4","coinFarm")
mkToggle("Farm","🧲 Bring Coins","bringCoins")
mkToggle("Farm","🔪 Knife Aura","knife")
mkToggle("Farm","🎁 Auto Reward","autoReward")
mkSec("Farm","АФК")
mkToggle("Farm","💤 Anti AFK","antiAfk")
mkButton("Farm","🔄 Сбросить счётчик",DIM,function()
    coinCount=0 notify("Farm","Счётчик сброшен",2)
end)

-- ════════════════════════════════
-- ВКЛАДКА: VISUAL
-- ════════════════════════════════
mkSec("Visual","ESP")
mkToggle("Visual","👁 ESP (роли + HP + дистанция)","esp")
mkSec("Visual","Окружение")
mkToggle("Visual","☀ Fullbright","fullbright",function(v) setFB(v) end)
mkToggle("Visual","👻 Hide Player","hide",function(v) hidePlayer(v) end)
mkToggle("Visual","🗿 Big Head","bigHead")
mkToggle("Visual","🌀 Spin Bot","spinBot")
mkSec("Visual","Роли")
mkButton("Visual","🎭 Показать роли всех",Color3.fromRGB(20,20,50),function()
    task.spawn(function()
        local m,s,inn={},{},{}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local r=getRole(p)
                if r=="Murderer" then table.insert(m,p.Name)
                elseif r=="Sheriff" then table.insert(s,p.Name)
                else table.insert(inn,p.Name) end
            end
        end
        local txt=""
        if #m>0 then txt=txt.."🔪 "..table.concat(m,", ").." | " end
        if #s>0 then txt=txt.."🔫 "..table.concat(s,", ").." | " end
        if #inn>0 then txt=txt.."😇 "..table.concat(inn,", ") end
        notify("👁 ESP",txt,7)
    end)
end)
mkButton("Visual","🔪 Кто убийца?",Color3.fromRGB(50,5,5),function()
    for _,p in ipairs(Players:GetPlayers()) do
        if getRole(p)=="Murderer" then notify("🔪 УБИЙЦА",p.Name,5) return end
    end
    notify("Убийца","Не найден",2)
end)
mkButton("Visual","🔫 Кто шериф?",Color3.fromRGB(5,15,55),function()
    for _,p in ipairs(Players:GetPlayers()) do
        if getRole(p)=="Sheriff" then notify("🔫 ШЕРИФ",p.Name,5) return end
    end
    notify("Шериф","Не найден",2)
end)

-- ════════════════════════════════
-- ВКЛАДКА: BYPASS
-- ════════════════════════════════
mkSec("Bypass","Antikick v4")
local bInfo=Instance.new("Frame") bInfo.Size=UDim2.new(1,0,0,60) bInfo.BackgroundColor3=Color3.fromRGB(18,10,6) bInfo.BorderSizePixel=0
Instance.new("UICorner",bInfo).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",bInfo).Color=Color3.fromRGB(200,100,0)
local bTxt=Instance.new("TextLabel",bInfo) bTxt.Size=UDim2.new(1,-14,1,0) bTxt.Position=UDim2.new(0,7,0,0) bTxt.BackgroundTransparency=1
bTxt.Text="Имитация мыши + прыжки + паузы фарма (2-5 сек каждые 30-60 сек) + смена WalkSpeed"
bTxt.TextColor3=Color3.fromRGB(210,160,80) bTxt.Font=Enum.Font.Code bTxt.TextSize=10 bTxt.TextWrapped=true bTxt.TextXAlignment=Enum.TextXAlignment.Left bTxt.TextYAlignment=Enum.TextYAlignment.Center
table.insert(tabContent["Bypass"],bInfo)
mkToggle("Bypass","🛡 Bypass v4 (включи с фармом)","bypass")
mkToggle("Bypass","💤 Anti AFK","antiAfk")
mkSec("Bypass","Утилиты")
mkButton("Bypass","🔄 Перезапустить персонажа",Color3.fromRGB(25,25,55),function()
    pcall(function() LP:LoadCharacter() end)
end)
mkButton("Bypass","🧹 СТЕЛС — выключить всё",Color3.fromRGB(18,38,18),function()
    CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
    CFG.bypass=false CFG.esp=false CFG.noclip=false CFG.aimbot=false CFG.spinBot=false CFG.fly=false
    enableFly(false)
    pcall(function() local h=getHum() if h then h.WalkSpeed=16 h.JumpPower=50 end end)
    notify("🧹 Стелс","Все читы выключены",3)
end)

-- ════════════════════════════════
-- ВКЛАДКА: TP
-- ════════════════════════════════
mkSec("TP","Быстрый TP")
mkButton("TP","🔪 TP к Убийце",Color3.fromRGB(70,10,10),function() tpToRole("Murderer") end)
mkButton("TP","🔫 TP к Шерифу",Color3.fromRGB(10,20,70),function() tpToRole("Sheriff") end)
mkButton("TP","😇 TP к случайному",Color3.fromRGB(20,30,20),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        local others={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then table.insert(others,p) end end
        if #others==0 then notify("TP","Нет игроков",2) return end
        local p=others[math.random(1,#others)]
        local t=p.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame=t.CFrame+Vector3.new(3,0,0) end
    end)
end)
mkButton("TP","🏠 TP к спавну",DIM,function()
    pcall(function() local hrp=getHRP() if hrp then hrp.CFrame=CFrame.new(0,10,0) end end)
end)
mkSec("TP","Игроки")
local plF=Instance.new("Frame") plF.Size=UDim2.new(1,0,0,10) plF.BackgroundTransparency=1 plF.AutomaticSize=Enum.AutomaticSize.Y plF.BorderSizePixel=0
Instance.new("UIListLayout",plF).Padding=UDim.new(0,4)
table.insert(tabContent["TP"],plF)
local function rebuildPL()
    for _,ch in ipairs(plF:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",plF) pf.Size=UDim2.new(1,0,0,44) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",pf).Color=BORDER
        local role=getRole(p) local col=ROLE_COLORS[role]
        local acc=Instance.new("Frame",pf) acc.Size=UDim2.new(0,3,0.6,0) acc.Position=UDim2.new(0,0,0.2,0) acc.BackgroundColor3=col acc.BorderSizePixel=0
        Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(1,-60,1,0) nm.Position=UDim2.new(0,14,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=13 nm.TextXAlignment=Enum.TextXAlignment.Left
        local rt=Instance.new("TextLabel",pf) rt.Size=UDim2.new(0,46,1,0) rt.Position=UDim2.new(1,-48,0,0) rt.BackgroundTransparency=1 rt.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rt.Font=Enum.Font.GothamBold rt.TextSize=20
        local tb=Instance.new("TextButton",pf) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text=""
        local function doTP()
            pcall(function()
                local hrp=getHRP() if not hrp then return end
                if p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
                        task.wait(0.15) TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
                        hrp.CFrame=t.CFrame+Vector3.new(0,0,3)
                    end
                end
            end)
        end
        tb.MouseButton1Click:Connect(doTP) tb.TouchTap:Connect(doTP)
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildPL) task.wait(3) end end)
Players.PlayerAdded:Connect(function() task.wait(1) pcall(rebuildPL) end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(rebuildPL) end)

-- ════════════════════════════════
-- ВКЛАДКА: TROL v4
-- ════════════════════════════════
mkSec("Trol","Выбери жертву")
local vLabel=Instance.new("Frame") vLabel.Size=UDim2.new(1,0,0,36) vLabel.BackgroundColor3=CARD vLabel.BorderSizePixel=0
Instance.new("UICorner",vLabel).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",vLabel).Color=Color3.fromRGB(200,40,40)
local vl=Instance.new("TextLabel",vLabel) vl.Size=UDim2.new(1,0,1,0) vl.BackgroundTransparency=1 vl.Text="😈 Жертва: "..victimName vl.TextColor3=Color3.fromRGB(255,80,80) vl.Font=Enum.Font.GothamBold vl.TextSize=12
table.insert(tabContent["Trol"],vLabel)

local trollPLF=Instance.new("Frame") trollPLF.Size=UDim2.new(1,0,0,10) trollPLF.BackgroundTransparency=1 trollPLF.AutomaticSize=Enum.AutomaticSize.Y trollPLF.BorderSizePixel=0
Instance.new("UIListLayout",trollPLF).Padding=UDim.new(0,3)
table.insert(tabContent["Trol"],trollPLF)
local function rebuildTrol()
    for _,ch in ipairs(trollPLF:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",trollPLF) pf.Size=UDim2.new(1,0,0,44) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",pf).Color=BORDER
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(1,-80,1,0) nm.Position=UDim2.new(0,10,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=13 nm.TextXAlignment=Enum.TextXAlignment.Left
        local selBtn=Instance.new("TextButton",pf) selBtn.Size=UDim2.new(0,72,0,32) selBtn.Position=UDim2.new(1,-76,0.5,-16) selBtn.BackgroundColor3=Color3.fromRGB(60,10,10) selBtn.BorderSizePixel=0 selBtn.Text="▶ Выбрать" selBtn.TextColor3=WHITE selBtn.Font=Enum.Font.GothamBold selBtn.TextSize=10
        Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,6)
        local function sel()
            victimName=p.Name vl.Text="😈 Жертва: "..victimName
            TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
            task.wait(0.2) TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
            notify("😈",victimName.." выбран жертвой",2)
        end
        selBtn.MouseButton1Click:Connect(sel) selBtn.TouchTap:Connect(sel)
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildTrol) task.wait(4) end end)

mkSec("Trol","Действия")
mkToggle("Trol","👣 Постоянно следить",nil,function(v) followActive=v end)
mkToggle("Trol","🚧 Блокировать путь",nil,function(v) blockActive=v end)
mkButton("Trol","💢 TP прямо на жертву",Color3.fromRGB(80,10,10),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=t.CFrame end
            end
        end
    end)
end)
mkButton("Trol","💥 Спам TP (4 сек)",Color3.fromRGB(60,10,10),function()
    task.spawn(function()
        for i=1,25 do task.wait(0.16)
            pcall(function()
                local hrp=getHRP() if not hrp then return end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Name==victimName and p.Character then
                        local t=p.Character:FindFirstChild("HumanoidRootPart")
                        if t then hrp.CFrame=t.CFrame*CFrame.new(math.random(-3,3),0,math.random(-3,3)) end
                    end
                end
            end)
        end
    end)
end)
mkButton("Trol","🚀 Прыгнуть сверху на жертву",Color3.fromRGB(50,20,80),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=CFrame.new(t.Position+Vector3.new(0,28,0)) hrp.Velocity=Vector3.new(0,-80,0) end
            end
        end
    end)
end)
mkButton("Trol","😤 Вплотную к жертве",Color3.fromRGB(40,20,5),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=CFrame.new(t.Position+Vector3.new(0,0,0.8),t.Position) end
            end
        end
    end)
end)
mkButton("Trol","🌀 Фриз ESP жертвы",Color3.fromRGB(30,10,60),function()
    task.spawn(function()
        local hrp=getHRP() if not hrp then return end
        local orig=hrp.CFrame
        for i=1,40 do task.wait(0.04)
            pcall(function() hrp.CFrame=orig*CFrame.new(math.random(-50,50),math.random(-5,30),math.random(-50,50)) end)
        end
        task.wait(0.1) hrp.CFrame=orig
    end)
end)
mkButton("Trol","👁 Роль жертвы",Color3.fromRGB(20,25,55),function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name==victimName then
            local r=getRole(p)
            notify("👁 "..victimName,(r=="Murderer" and "🔪 УБИЙЦА!" or r=="Sheriff" and "🔫 ШЕРИФ!" or "😇 Невинный"),5)
            return
        end
    end
    notify("Trol","Жертва не найдена",2)
end)
mkButton("Trol","🎭 Роли всех игроков",Color3.fromRGB(30,20,55),function()
    local m,s,inn={},{},{}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then local r=getRole(p)
            if r=="Murderer" then table.insert(m,p.Name)
            elseif r=="Sheriff" then table.insert(s,p.Name)
            else table.insert(inn,p.Name) end
        end
    end
    local txt=""
    if #m>0 then txt=txt.."🔪 "..table.concat(m,", ").." | " end
    if #s>0 then txt=txt.."🔫 "..table.concat(s,", ").." | " end
    if #inn>0 then txt=txt.."😇 "..table.concat(inn,", ") end
    notify("Роли",txt,7)
end)

-- ════════════════════════════════
-- ВКЛАДКА: MISC
-- ════════════════════════════════
mkSec("Misc","Разное")
mkToggle("Misc","☀ Fullbright","fullbright",function(v) setFB(v) end)
mkToggle("Misc","👻 Hide Player","hide",function(v) hidePlayer(v) end)
mkToggle("Misc","🗿 Big Head","bigHead")
mkToggle("Misc","🌀 Spin Bot","spinBot")
mkToggle("Misc","🦘 Infinite Jump","infiniteJump")
mkSec("Misc","Инфо")
mkButton("Misc","📍 Мои координаты",DIM,function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        local p=hrp.Position
        notify("📍 Позиция","X:"..math.floor(p.X).." Y:"..math.floor(p.Y).." Z:"..math.floor(p.Z),5)
    end)
end)
mkButton("Misc","🧹 Стелс (выкл всё)",Color3.fromRGB(18,38,18),function()
    CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
    CFG.bypass=false CFG.esp=false CFG.noclip=false CFG.spinBot=false CFG.fly=false
    enableFly(false)
    pcall(function() local h=getHum() if h then h.WalkSpeed=16 h.JumpPower=50 end end)
    notify("🧹 Стелс","Все читы выключены",3)
end)
mkButton("Misc","🔄 Перезапустить персонажа",Color3.fromRGB(25,25,55),function()
    pcall(function() LP:LoadCharacter() end)
end)
mkButton("Misc","📋 v7.0 | @Primejtsu",DIM,function()
    notify("Primejtsu Hub","v7.0 Mobile | @Primejtsu | Nazar513000",4)
end)

-- Запускаем
switchTab("Info")

-- HP бар внизу экрана (маленький)
local hpGui=Instance.new("ScreenGui",CoreGui) hpGui.Name="PTHSelfHP" hpGui.ResetOnSpawn=false
local hpF=Instance.new("Frame",hpGui) hpF.Size=UDim2.new(0,160,0,14) hpF.Position=UDim2.new(0.5,-80,1,-120) hpF.BackgroundColor3=Color3.fromRGB(20,5,5) hpF.BorderSizePixel=0
Instance.new("UICorner",hpF).CornerRadius=UDim.new(1,0)
local hpFill=Instance.new("Frame",hpF) hpFill.Size=UDim2.new(1,0,1,0) hpFill.BackgroundColor3=Color3.fromRGB(50,220,80) hpFill.BorderSizePixel=0
Instance.new("UICorner",hpFill).CornerRadius=UDim.new(1,0)
local hpTxt=Instance.new("TextLabel",hpF) hpTxt.Size=UDim2.new(1,0,1,0) hpTxt.BackgroundTransparency=1 hpTxt.Font=Enum.Font.GothamBold hpTxt.TextSize=10 hpTxt.TextColor3=WHITE hpTxt.TextStrokeTransparency=0 hpTxt.TextStrokeColor3=Color3.new(0,0,0)
RunService.Heartbeat:Connect(function()
    local hum=getHum() if not hum then return end
    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    hpFill.Size=UDim2.new(pct,0,1,0)
    hpFill.BackgroundColor3=pct>0.6 and Color3.fromRGB(50,220,80) or pct>0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50)
    hpTxt.Text="❤ "..math.floor(hum.Health)
end)

notify("🪐 Primejtsu Hub v7.0","Mobile Edition загружен!",4)
print("╔═══════════════════════════════════════╗")
print("║  Primejtsu Hub v7.0 | MOBILE EDITION  ║")
print("║  @Primejtsu | Nazar513000 | MM2 🪐    ║")
print("╚═══════════════════════════════════════╝")
