-- ================================================
--   Primejtsu X | Ultimate Tools
--   Replay + NPC AI + Physics Gun
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local LP               = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

-- ================================================
-- REPLAY SYSTEM
-- ================================================
local replayData    = {}
local isRecording   = false
local isReplaying   = false
local replayConn    = nil
local replayClone   = nil
local recordConn    = nil
local MAX_FRAMES    = 300 -- 10 сек при 30fps

local function startRecording()
    replayData = {}
    isRecording = true
    recordConn = RunService.Heartbeat:Connect(function()
        if not isRecording then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if not root or not hum then return end
        table.insert(replayData, {
            cf    = root.CFrame,
            speed = hum.WalkSpeed,
            state = hum:GetState(),
        })
        if #replayData >= MAX_FRAMES then
            isRecording = false
            recordConn:Disconnect()
        end
    end)
end

local function stopRecording()
    isRecording = false
    if recordConn then recordConn:Disconnect(); recordConn=nil end
end

local function playReplay()
    if #replayData == 0 then return end
    if isReplaying then return end
    isReplaying = true

    -- Клонируем персонажа
    local char = LP.Character
    if not char then isReplaying=false; return end

    replayClone = char:Clone()
    replayClone.Name = "PX_Replay_Clone"
    -- Убираем скрипты из клона
    for _, v in pairs(replayClone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
    end
    -- Меняем цвет чтобы отличался
    for _, v in pairs(replayClone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.BrickColor = BrickColor.new("Cyan")
            v.Anchored = false
            v.CanCollide = false
        end
    end
    local cloneRoot = replayClone:FindFirstChild("HumanoidRootPart")
    if cloneRoot then cloneRoot.Anchored = true end

    replayClone.Parent = workspace

    -- Воспроизводим
    local frame = 1
    replayConn = RunService.Heartbeat:Connect(function()
        if not isReplaying or frame > #replayData then
            isReplaying = false
            if replayConn then replayConn:Disconnect() end
            if replayClone then replayClone:Destroy(); replayClone=nil end
            return
        end
        local data = replayData[frame]
        if cloneRoot then cloneRoot.CFrame = data.cf end
        frame = frame + 1
    end)
end

local function stopReplay()
    isReplaying = false
    if replayConn then replayConn:Disconnect(); replayConn=nil end
    if replayClone then replayClone:Destroy(); replayClone=nil end
end

-- ================================================
-- NPC AI SYSTEM
-- ================================================
local npcModel   = nil
local npcConn    = nil
local npcMode    = "follow"  -- follow / patrol / idle / attack
local patrolPoints = {}
local patrolIndex  = 1

local function createNPC()
    if npcModel then npcModel:Destroy(); npcModel=nil end
    if npcConn  then npcConn:Disconnect(); npcConn=nil end

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Создаём NPC
    npcModel = Instance.new("Model")
    npcModel.Name = "PX_NPC"

    local body = Instance.new("Part", npcModel)
    body.Name = "HumanoidRootPart"
    body.Size = Vector3.new(2,2,1)
    body.BrickColor = BrickColor.new("Bright red")
    body.Material = Enum.Material.SmoothPlastic
    body.CFrame = root.CFrame + Vector3.new(3,0,0)

    local head = Instance.new("Part", npcModel)
    head.Name = "Head"
    head.Size = Vector3.new(2,1,1)
    head.BrickColor = BrickColor.new("Bright yellow")
    head.CFrame = body.CFrame + Vector3.new(0,1.5,0)

    local headWeld = Instance.new("WeldConstraint", head)
    headWeld.Part0 = body; headWeld.Part1 = head

    -- Имя над головой
    local bb = Instance.new("BillboardGui", head)
    bb.Size = UDim2.new(0,100,0,30); bb.StudsOffset = Vector3.new(0,1,0); bb.AlwaysOnTop=true
    local nl = Instance.new("TextLabel", bb)
    nl.Size = UDim2.new(1,0,1,0); nl.BackgroundTransparency=1
    nl.TextColor3=Color3.fromRGB(255,255,255); nl.TextSize=14
    nl.Font=Enum.Font.GothamBold; nl.Text="PX Bot"

    -- Humanoid
    local hum = Instance.new("Humanoid", npcModel)
    hum.WalkSpeed = 16

    -- BodyVelocity для движения
    local bv = Instance.new("BodyVelocity", body)
    bv.MaxForce = Vector3.new(1e5,0,1e5)
    bv.Velocity = Vector3.new(0,0,0)

    local bg = Instance.new("BodyGyro", body)
    bg.MaxTorque = Vector3.new(0,1e5,0)
    bg.CFrame = body.CFrame

    npcModel.PrimaryPart = body
    npcModel.Parent = workspace

    -- AI цикл
    local attackCooldown = 0
    npcConn = RunService.Heartbeat:Connect(function(dt)
        if not npcModel or not npcModel.Parent then
            npcConn:Disconnect(); return
        end

        local npcRoot = npcModel.PrimaryPart
        if not npcRoot then return end

        if npcMode == "follow" then
            local char2 = LP.Character
            local myRoot = char2 and char2:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local dir = (myRoot.Position - npcRoot.Position)
                local dist = dir.Magnitude
                if dist > 5 then
                    local moveDir = dir.Unit
                    bv.Velocity = Vector3.new(moveDir.X*16, 0, moveDir.Z*16)
                    bg.CFrame = CFrame.lookAt(npcRoot.Position, myRoot.Position)
                else
                    bv.Velocity = Vector3.new(0,0,0)
                end
            end

        elseif npcMode == "attack" then
            -- Атакуем ближайшего игрока (не LP)
            local best, bestDist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local er = p.Character:FindFirstChild("HumanoidRootPart")
                    if er then
                        local d = (er.Position - npcRoot.Position).Magnitude
                        if d < bestDist then bestDist=d; best=p end
                    end
                end
            end
            if best and best.Character then
                local er = best.Character:FindFirstChild("HumanoidRootPart")
                if er then
                    local dir = (er.Position - npcRoot.Position)
                    local dist = dir.Magnitude
                    if dist > 4 then
                        local md = dir.Unit
                        bv.Velocity = Vector3.new(md.X*24, 0, md.Z*24)
                        bg.CFrame = CFrame.lookAt(npcRoot.Position, er.Position)
                    else
                        bv.Velocity = Vector3.new(0,0,0)
                        attackCooldown = attackCooldown - dt
                        if attackCooldown <= 0 then
                            attackCooldown = 1
                            local eh = best.Character:FindFirstChild("Humanoid")
                            if eh then eh.Health = eh.Health - 10 end
                        end
                    end
                end
            end

        elseif npcMode == "patrol" then
            if #patrolPoints > 0 then
                local target = patrolPoints[patrolIndex]
                local dir = (target - npcRoot.Position)
                local dist = dir.Magnitude
                if dist > 3 then
                    local md = dir.Unit
                    bv.Velocity = Vector3.new(md.X*14, 0, md.Z*14)
                    bg.CFrame = CFrame.lookAt(npcRoot.Position, target)
                else
                    bv.Velocity = Vector3.new(0,0,0)
                    patrolIndex = patrolIndex % #patrolPoints + 1
                end
            end

        elseif npcMode == "idle" then
            bv.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function removeNPC()
    if npcConn  then npcConn:Disconnect();  npcConn=nil  end
    if npcModel then npcModel:Destroy();    npcModel=nil end
end

local function addPatrolPoint()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        table.insert(patrolPoints, root.Position)
        return #patrolPoints
    end
    return 0
end

-- ================================================
-- PHYSICS GUN
-- ================================================
local physGunEnabled  = false
local grabbedPart     = nil
local grabConn        = nil
local grabDist        = 20
local grabBV          = nil
local grabBG          = nil
local GRAB_KEY        = Enum.KeyCode.E
local DELETE_KEY      = Enum.KeyCode.Q
local lastGrabAttempt = 0

local function releaseGrab()
    if grabBV then grabBV:Destroy(); grabBV=nil end
    if grabBG then grabBG:Destroy(); grabBG=nil end
    if grabbedPart then
        pcall(function() grabbedPart.Anchored = false end)
        grabbedPart = nil
    end
end

local function tryGrab()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local unitRay = Camera:ScreenPointToRay(
        Camera.ViewportSize.X/2,
        Camera.ViewportSize.Y/2
    )
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 50)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char, workspace.Terrain})

    if hit and not hit.Locked and hit.Anchored == false then
        -- Не хватаем части игроков
        local isPlayer = false
        for _,p in pairs(Players:GetPlayers()) do
            if p.Character and hit:IsDescendantOf(p.Character) then
                isPlayer = true; break
            end
        end
        if isPlayer then return end

        releaseGrab()
        grabbedPart = hit
        grabDist    = (pos - root.Position).Magnitude

        grabBV = Instance.new("BodyVelocity", grabbedPart)
        grabBV.MaxForce = Vector3.new(1e5,1e5,1e5)
        grabBV.Velocity = Vector3.new(0,0,0)

        grabBG = Instance.new("BodyGyro", grabbedPart)
        grabBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
        grabBG.CFrame = grabbedPart.CFrame
    end
end

local function launchGrabbed()
    if not grabbedPart then return end
    local dir = Camera.CFrame.LookVector
    local launched = grabbedPart
    releaseGrab()
    local lv = Instance.new("BodyVelocity", launched)
    lv.Velocity = dir * 120
    lv.MaxForce = Vector3.new(1e5,1e5,1e5)
    game:GetService("Debris"):AddItem(lv, 0.15)
end

local function deleteGrabbed()
    if grabbedPart then
        grabbedPart:Destroy()
        grabbedPart = nil
    end
end

local function enablePhysGun()
    physGunEnabled = true
    grabConn = RunService.RenderStepped:Connect(function()
        if not physGunEnabled then return end
        if not grabbedPart or not grabbedPart.Parent then
            releaseGrab(); return
        end

        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Скроллом меняем дистанцию
        local targetPos = Camera.CFrame.Position + Camera.CFrame.LookVector * grabDist
        grabBV.Velocity = (targetPos - grabbedPart.Position) * 15
        grabBG.CFrame   = Camera.CFrame
    end)

    -- Скролл для изменения дистанции
    UserInputService.InputChanged:Connect(function(inp)
        if not physGunEnabled then return end
        if inp.UserInputType == Enum.UserInputType.MouseWheel then
            grabDist = math.clamp(grabDist - inp.Position.Z * 2, 3, 60)
        end
    end)

    -- E = схватить / отпустить
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not physGunEnabled then return end
        if inp.KeyCode == GRAB_KEY then
            if grabbedPart then
                launchGrabbed()
            else
                tryGrab()
            end
        end
        if inp.KeyCode == DELETE_KEY then
            deleteGrabbed()
        end
    end)

    -- ПКМ = бросить
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not physGunEnabled then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            if grabbedPart then releaseGrab() end
        end
    end)
end

local function disablePhysGun()
    physGunEnabled = false
    releaseGrab()
    if grabConn then grabConn:Disconnect(); grabConn=nil end
end

-- ================================================
-- GUI
-- ================================================
local oldGui = LP.PlayerGui:FindFirstChild("PX_Ultimate")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name="PX_Ultimate"; Gui.ResetOnSpawn=false; Gui.DisplayOrder=999
Gui.Parent=LP.PlayerGui

local Main = Instance.new("Frame",Gui)
Main.Size=UDim2.new(0,300,0,480)
Main.Position=UDim2.new(0,10,0.5,-240)
Main.BackgroundColor3=Color3.fromRGB(10,10,18)
Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(150,0,255); ms.Thickness=1.5

-- Тайтл
local TB=Instance.new("Frame",Main)
TB.Size=UDim2.new(1,0,0,36); TB.BackgroundColor3=Color3.fromRGB(80,0,180)
TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,12)
local tbfix=Instance.new("Frame",TB)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(80,0,180); tbfix.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-38,1,0); TL.Position=UDim2.new(0,12,0,0)
TL.BackgroundTransparency=1; TL.TextColor3=Color3.fromRGB(255,255,255)
TL.TextSize=13; TL.Font=Enum.Font.GothamBold
TL.Text="Primejtsu X | Ultimate Tools"; TL.TextXAlignment=Enum.TextXAlignment.Left

local XBtn=Instance.new("TextButton",TB)
XBtn.Size=UDim2.new(0,28,0,28); XBtn.Position=UDim2.new(1,-34,0.5,-14)
XBtn.BackgroundColor3=Color3.fromRGB(160,0,50); XBtn.BorderSizePixel=0
XBtn.TextColor3=Color3.fromRGB(255,255,255); XBtn.TextSize=13
XBtn.Font=Enum.Font.GothamBold; XBtn.Text="X"; XBtn.AutoButtonColor=false
Instance.new("UICorner",XBtn).CornerRadius=UDim.new(0,6)

-- Кнопка показать
local ShowBtn=Instance.new("TextButton",Gui)
ShowBtn.Size=UDim2.new(0,44,0,44); ShowBtn.Position=UDim2.new(0,10,0.5,-22)
ShowBtn.BackgroundColor3=Color3.fromRGB(80,0,180); ShowBtn.BorderSizePixel=0
ShowBtn.TextColor3=Color3.fromRGB(255,255,255); ShowBtn.TextSize=11
ShowBtn.Font=Enum.Font.GothamBold; ShowBtn.Text="PX"; ShowBtn.AutoButtonColor=false
ShowBtn.Visible=false
Instance.new("UICorner",ShowBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",ShowBtn).Color=Color3.fromRGB(180,80,255)

XBtn.MouseButton1Click:Connect(function() Main.Visible=false; ShowBtn.Visible=true end)
ShowBtn.MouseButton1Click:Connect(function() Main.Visible=true; ShowBtn.Visible=false end)

-- Хелпер: секция
local function makeSection(parent, text, yPos)
    local s=Instance.new("TextLabel",parent)
    s.Size=UDim2.new(1,-12,0,18); s.Position=UDim2.new(0,6,0,yPos)
    s.BackgroundColor3=Color3.fromRGB(80,0,180); s.BorderSizePixel=0
    s.TextColor3=Color3.fromRGB(255,255,255); s.TextSize=11
    s.Font=Enum.Font.GothamBold; s.Text=text
    Instance.new("UICorner",s).CornerRadius=UDim.new(0,5)
    return s
end

-- Хелпер: кнопка
local function makeBtn(parent, text, yPos, col)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-12,0,32); b.Position=UDim2.new(0,6,0,yPos)
    b.BackgroundColor3=col or Color3.fromRGB(60,0,140)
    b.BorderSizePixel=0; b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=12; b.Font=Enum.Font.GothamBold; b.Text=text
    b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    return b
end

-- Хелпер: статус лейбл
local function makeLbl(parent, text, yPos)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,-12,0,16); l.Position=UDim2.new(0,6,0,yPos)
    l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(150,150,200)
    l.TextSize=10; l.Font=Enum.Font.Gotham; l.Text=text
    l.TextXAlignment=Enum.TextXAlignment.Left
    return l
end

-- ================================================
-- REPLAY UI
-- ================================================
makeSection(Main,"Replay System",44)

local recBtn   = makeBtn(Main,"REC — Начать запись",66,Color3.fromRGB(180,0,0))
local playBtn  = makeBtn(Main,"PLAY — Воспроизвести",102,Color3.fromRGB(0,140,0))
local stopBtn  = makeBtn(Main,"STOP — Остановить",138,Color3.fromRGB(60,60,60))
local replayLbl = makeLbl(Main,"Статус: Готов к записи",174)

recBtn.MouseButton1Click:Connect(function()
    if isRecording then
        stopRecording()
        recBtn.Text="REC — Начать запись"
        recBtn.BackgroundColor3=Color3.fromRGB(180,0,0)
        replayLbl.Text="Записано "..#replayData.." кадров"
    else
        startRecording()
        recBtn.Text="REC — Остановить запись"
        recBtn.BackgroundColor3=Color3.fromRGB(255,50,50)
        replayLbl.Text="Запись... (макс 10 сек)"
    end
end)

playBtn.MouseButton1Click:Connect(function()
    if #replayData==0 then replayLbl.Text="Нет записи!"; return end
    playReplay()
    replayLbl.Text="Воспроизведение клона..."
end)

stopBtn.MouseButton1Click:Connect(function()
    stopRecording()
    stopReplay()
    replayLbl.Text="Остановлено"
    recBtn.Text="REC — Начать запись"
    recBtn.BackgroundColor3=Color3.fromRGB(180,0,0)
end)

-- ================================================
-- NPC AI UI
-- ================================================
makeSection(Main,"NPC AI Bot",196)

local npcCreateBtn = makeBtn(Main,"Создать NPC",218,Color3.fromRGB(0,120,60))
local npcRemoveBtn = makeBtn(Main,"Удалить NPC",254,Color3.fromRGB(80,0,0))

-- Режимы NPC (2x2)
local modeFrame=Instance.new("Frame",Main)
modeFrame.Size=UDim2.new(1,-12,0,34); modeFrame.Position=UDim2.new(0,6,0,290)
modeFrame.BackgroundTransparency=1; modeFrame.BorderSizePixel=0
local mgl=Instance.new("UIListLayout",modeFrame)
mgl.FillDirection=Enum.FillDirection.Horizontal; mgl.Padding=UDim.new(0,4)

local function makeModeBtn(txt, mode, col)
    local b=Instance.new("TextButton",modeFrame)
    b.Size=UDim2.new(0.25,-3,1,0)
    b.BackgroundColor3=col; b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=10
    b.Font=Enum.Font.GothamBold; b.Text=txt; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        npcMode=mode
        if npcModel then npcLbl.Text="NPC режим: "..txt end
    end)
    return b
end

local npcLbl = makeLbl(Main,"NPC: не создан",328)

npcCreateBtn.MouseButton1Click:Connect(function()
    createNPC()
    npcLbl.Text="NPC создан! Режим: "..npcMode
    npcLbl.TextColor3=Color3.fromRGB(100,255,120)
end)

npcRemoveBtn.MouseButton1Click:Connect(function()
    removeNPC()
    patrolPoints={}; patrolIndex=1
    npcLbl.Text="NPC удалён"
    npcLbl.TextColor3=Color3.fromRGB(255,100,100)
end)

makeModeBtn("Follow","follow",Color3.fromRGB(0,100,180))
makeModeBtn("Attack","attack",Color3.fromRGB(160,0,0))
makeModeBtn("Patrol","patrol",Color3.fromRGB(100,80,0))
makeModeBtn("Idle","idle",Color3.fromRGB(40,40,60))

local patrolBtn=makeBtn(Main,"+ Добавить точку патруля",344,Color3.fromRGB(80,60,0))
patrolBtn.MouseButton1Click:Connect(function()
    local n = addPatrolPoint()
    npcLbl.Text="Точек патруля: "..n
end)

-- ================================================
-- PHYSICS GUN UI
-- ================================================
makeSection(Main,"Physics Gun",382)

local pgBtn  = makeBtn(Main,"Включить Physics Gun",404,Color3.fromRGB(0,80,160))
local pgLbl  = makeLbl(Main,"Статус: выключен",440)
local pgHelp = makeLbl(Main,"E = схватить/бросить | ПКМ = отпустить | Q = удалить",458)
pgHelp.TextSize=9; pgHelp.TextColor3=Color3.fromRGB(100,100,150)
pgHelp.Size=UDim2.new(1,-12,0,24); pgHelp.TextWrapped=true

pgBtn.MouseButton1Click:Connect(function()
    if physGunEnabled then
        disablePhysGun()
        pgBtn.Text="Включить Physics Gun"
        pgBtn.BackgroundColor3=Color3.fromRGB(0,80,160)
        pgLbl.Text="Статус: выключен"
        pgLbl.TextColor3=Color3.fromRGB(150,150,200)
    else
        enablePhysGun()
        pgBtn.Text="Выключить Physics Gun"
        pgBtn.BackgroundColor3=Color3.fromRGB(200,100,0)
        pgLbl.Text="Статус: включён (E = схватить)"
        pgLbl.TextColor3=Color3.fromRGB(100,255,120)
    end
end)

-- ================================================
-- Прицел для Physics Gun
-- ================================================
local crosshair = Instance.new("Frame",Gui)
crosshair.Size=UDim2.new(0,16,0,16); crosshair.Position=UDim2.new(0.5,-8,0.5,-8)
crosshair.BackgroundTransparency=1; crosshair.BorderSizePixel=0; crosshair.Visible=false

local ch1=Instance.new("Frame",crosshair); ch1.Size=UDim2.new(1,0,0,2); ch1.Position=UDim2.new(0,0,0.5,-1)
ch1.BackgroundColor3=Color3.fromRGB(255,150,0); ch1.BorderSizePixel=0
local ch2=Instance.new("Frame",crosshair); ch2.Size=UDim2.new(0,2,1,0); ch2.Position=UDim2.new(0.5,-1,0,0)
ch2.BackgroundColor3=Color3.fromRGB(255,150,0); ch2.BorderSizePixel=0

-- Показываем прицел когда Physics Gun включён
RunService.RenderStepped:Connect(function()
    crosshair.Visible = physGunEnabled
    if physGunEnabled and grabbedPart then
        ch1.BackgroundColor3=Color3.fromRGB(0,255,100)
        ch2.BackgroundColor3=Color3.fromRGB(0,255,100)
    else
        ch1.BackgroundColor3=Color3.fromRGB(255,150,0)
        ch2.BackgroundColor3=Color3.fromRGB(255,150,0)
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
print("[PX] Ultimate Tools Loaded!")
print("[PX] Replay + NPC AI + Physics Gun")
