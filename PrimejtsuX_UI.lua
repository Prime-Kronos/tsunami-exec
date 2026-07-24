-- ================================================
--   Primejtsu X | Project
--   Custom GUI - Pulse Hub Style v2
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer

local function tw(o,p,t,s) TweenService:Create(o,TweenInfo.new(t or 0.15,s or Enum.EasingStyle.Quad),p):Play() end
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p;return c end
local function stroke(p,col,t) local s=Instance.new("UIStroke");s.Color=col or Color3.fromRGB(60,60,80);s.Thickness=t or 1;s.Parent=p;return s end
local function newFrame(parent,size,pos,color,transp)
    local f=Instance.new("Frame");f.Size=size;f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=color or Color3.fromRGB(30,30,40);f.BackgroundTransparency=transp or 0
    f.BorderSizePixel=0;f.Parent=parent;return f
end
local function newLabel(parent,text,size,color,font,pos,sz,xa)
    local l=Instance.new("TextLabel");l.Text=text;l.TextSize=size or 13
    l.TextColor3=color or Color3.fromRGB(240,240,255);l.Font=font or Enum.Font.GothamBold
    l.BackgroundTransparency=1;l.Position=pos or UDim2.new(0,0,0,0)
    l.Size=sz or UDim2.new(1,0,1,0);l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.Parent=parent;return l
end

-- ================================================
-- SCREEN GUI
-- ================================================
local SG=Instance.new("ScreenGui")
SG.Name="PrimejtsuX_UI";SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.Parent=LP.PlayerGui

-- ================================================
-- MINI BUTTON (иконка) — появляется первой
-- ================================================
local miniBtn=newFrame(SG,UDim2.new(0,52,0,52),UDim2.new(0,-60,0.5,-26),Color3.fromRGB(200,30,50))
miniBtn.ZIndex=20
corner(miniBtn,12)
stroke(miniBtn,Color3.fromRGB(255,80,100),2)

-- P буква по центру
local pLetter=newLabel(miniBtn,"P",28,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,
    UDim2.new(0,0,0,0),UDim2.new(1,0,1,0),Enum.TextXAlignment.Center)
pLetter.ZIndex=21

local miniBtnHit=Instance.new("TextButton")
miniBtnHit.Size=UDim2.new(1,0,1,0);miniBtnHit.BackgroundTransparency=1
miniBtnHit.Text="";miniBtnHit.ZIndex=22;miniBtnHit.Parent=miniBtn

-- Выезжает при старте
task.wait(0.3)
tw(miniBtn,{Position=UDim2.new(0,10,0.5,-26)},0.5,Enum.EasingStyle.Back)

-- ================================================
-- MAIN WINDOW
-- ================================================
local Main=newFrame(SG,UDim2.new(0,0,0,0),UDim2.new(0.5,-290,0.5,-200),Color3.fromRGB(28,28,35))
Main.Visible=false;Main.ZIndex=10
corner(Main,12);stroke(Main,Color3.fromRGB(50,50,65),1)

-- Drag
local drag,dragStart,startPos=false,nil,nil
Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true;dragStart=i.Position;startPos=Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- Toggle
local guiOpen=false
local function toggleGUI()
    guiOpen=not guiOpen
    -- Иконка анимация нажатия
    tw(miniBtn,{Size=UDim2.new(0,44,0,44),Position=UDim2.new(0,14,0.5,-22)},0.08)
    task.delay(0.1,function()
        tw(miniBtn,{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,10,0.5,-26)},0.15,Enum.EasingStyle.Back)
    end)
    if guiOpen then
        Main.Visible=true
        Main.Size=UDim2.new(0,0,0,0)
        Main.Position=UDim2.new(0.5,-290,0.5,-200)
        tw(Main,{Size=UDim2.new(0,580,0,400)},0.3,Enum.EasingStyle.Back)
    else
        tw(Main,{Size=UDim2.new(0,0,0,0)},0.2)
        task.delay(0.21,function() Main.Visible=false end)
    end
end

miniBtnHit.MouseButton1Click:Connect(toggleGUI)

-- ================================================
-- TOP BAR
-- ================================================
local TopBar=newFrame(Main,UDim2.new(1,0,0,44),UDim2.new(0,0,0,0),Color3.fromRGB(22,22,30))
TopBar.ZIndex=11;corner(TopBar,12)
newFrame(TopBar,UDim2.new(1,0,0,12),UDim2.new(0,0,1,-12),Color3.fromRGB(22,22,30)).ZIndex=11

-- Mini logo in topbar
local tbLogo=newFrame(TopBar,UDim2.new(0,28,0,28),UDim2.new(0,10,0.5,-14),Color3.fromRGB(200,30,50))
tbLogo.ZIndex=12;corner(tbLogo,7)
local tbP=newLabel(tbLogo,"P",15,Color3.fromRGB(255,255,255),Enum.Font.GothamBold)
tbP.ZIndex=13;tbP.TextXAlignment=Enum.TextXAlignment.Center

newLabel(TopBar,"Primejtsu X | Project",14,Color3.fromRGB(230,225,255),Enum.Font.GothamBold,
    UDim2.new(0,46,0,0),UDim2.new(0,180,1,0)).ZIndex=12

-- FPS
local fpsLabel=newLabel(TopBar,"FPS: --",11,Color3.fromRGB(80,220,100),Enum.Font.GothamBold,
    UDim2.new(1,-110,0,0),UDim2.new(0,70,1,0),Enum.TextXAlignment.Right)
fpsLabel.ZIndex=12

-- Close
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,26,0,26);closeBtn.Position=UDim2.new(1,-34,0.5,-13)
closeBtn.BackgroundColor3=Color3.fromRGB(200,30,50);closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255);closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=18;closeBtn.BorderSizePixel=0;closeBtn.ZIndex=12;closeBtn.Parent=TopBar
corner(closeBtn,7)
closeBtn.MouseButton1Click:Connect(toggleGUI)

-- FPS counter
local fpsTimer=0;local fpsSamples={}
RunService.Heartbeat:Connect(function(dt)
    fpsTimer=fpsTimer+dt
    table.insert(fpsSamples,1/dt)
    if #fpsSamples>20 then table.remove(fpsSamples,1) end
    if fpsTimer>=0.5 then
        fpsTimer=0
        local sum=0;for _,v in pairs(fpsSamples) do sum=sum+v end
        local fps=math.floor(sum/#fpsSamples)
        fpsLabel.Text="FPS: "..fps
        if fps>=50 then fpsLabel.TextColor3=Color3.fromRGB(80,220,100)
        elseif fps>=30 then fpsLabel.TextColor3=Color3.fromRGB(220,180,50)
        else fpsLabel.TextColor3=Color3.fromRGB(220,60,60) end
    end
end)

-- ================================================
-- SIDEBAR
-- ================================================
local Sidebar=newFrame(Main,UDim2.new(0,130,1,-44),UDim2.new(0,0,0,44),Color3.fromRGB(22,22,30))
Sidebar.ZIndex=11
newFrame(Sidebar,UDim2.new(0,10,1,0),UDim2.new(1,-10,0,0),Color3.fromRGB(22,22,30)).ZIndex=11
newFrame(Main,UDim2.new(0,1,1,-44),UDim2.new(0,130,0,44),Color3.fromRGB(40,40,55)).ZIndex=11

local tabList=newFrame(Sidebar,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),1)
tabList.ZIndex=12
local tLayout=Instance.new("UIListLayout");tLayout.Padding=UDim.new(0,3);tLayout.Parent=tabList
local tPad=Instance.new("UIPadding")
tPad.PaddingTop=UDim.new(0,8);tPad.PaddingLeft=UDim.new(0,8);tPad.PaddingRight=UDim.new(0,8)
tPad.Parent=tabList

-- ================================================
-- CONTENT — 2 КОЛОНКИ
-- ================================================
local ContentBG=newFrame(Main,UDim2.new(1,-130,1,-44),UDim2.new(0,131,0,44),Color3.fromRGB(0,0,0),1)
ContentBG.ZIndex=11

local function makeScrollCol(xScale, xOffset)
    local s=Instance.new("ScrollingFrame")
    s.Size=UDim2.new(xScale,-1,1,-8);s.Position=UDim2.new(xOffset==0 and 0 or 0.5,xOffset==0 and 0 or 1,0,4)
    s.BackgroundTransparency=1;s.ScrollBarThickness=2
    s.ScrollBarImageColor3=Color3.fromRGB(200,30,50);s.BorderSizePixel=0
    s.ZIndex=12;s.Parent=ContentBG
    local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,4);l.Parent=s
    local p=Instance.new("UIPadding");p.PaddingLeft=UDim.new(0,6);p.PaddingRight=UDim.new(0,6);p.Parent=s
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+8)
    end)
    return s
end

local Col1=makeScrollCol(0.5, 0)
local Col2=makeScrollCol(0.5, 1)
newFrame(ContentBG,UDim2.new(0,1,1,-8),UDim2.new(0.5,0,0,4),Color3.fromRGB(40,40,55)).ZIndex=11

-- Pages
local Pages={}
local sideButtons={}

local function newPage(name)
    local function makePageFrame(col)
        local f=Instance.new("Frame")
        f.Size=UDim2.new(1,0,0,0);f.BackgroundTransparency=1;f.Visible=false;f.ZIndex=13;f.Parent=col
        local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,4);l.Parent=f
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            f.Size=UDim2.new(1,0,0,l.AbsoluteContentSize.Y)
            col.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+8)
        end)
        return f
    end
    Pages[name]={c1=makePageFrame(Col1),c2=makePageFrame(Col2)}
    return Pages[name]
end

local function showPage(name)
    for n,p in pairs(Pages) do
        p.c1.Visible=(n==name)
        p.c2.Visible=(n==name)
    end
    Col1.CanvasPosition=Vector2.new(0,0)
    Col2.CanvasPosition=Vector2.new(0,0)
end

-- ИКОНКИ (Drawing-like unicode символы)
local ICONS={
    Main   = "⊞",
    Combat = "⊕",
    Farm   = "⊛",
    Move   = "⊿",
    Visual = "◈",
    Misc   = "⊙",
    Settings="⚙",
}

local function makeSideTab(name, icon)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,38)
    btn.BackgroundColor3=Color3.fromRGB(28,28,38)
    btn.BorderSizePixel=0;btn.ZIndex=13;btn.Parent=tabList
    btn.Text="";btn.AutoButtonColor=false
    corner(btn,8)

    -- Icon square
    local iconBG=newFrame(btn,UDim2.new(0,24,0,24),UDim2.new(0,8,0.5,-12),Color3.fromRGB(38,38,50))
    iconBG.ZIndex=14;corner(iconBG,6)
    local iconLbl=newLabel(iconBG,icon or "•",13,Color3.fromRGB(160,155,200),Enum.Font.GothamBold,
        UDim2.new(0,0,0,0),UDim2.new(1,0,1,0),Enum.TextXAlignment.Center)
    iconLbl.ZIndex=15

    -- Name
    local nameLbl=newLabel(btn,name,11,Color3.fromRGB(140,135,175),Enum.Font.GothamBold,
        UDim2.new(0,38,0,0),UDim2.new(1,-46,1,0))
    nameLbl.ZIndex=14

    -- Red accent bar left
    local accent=newFrame(btn,UDim2.new(0,3,0,22),UDim2.new(0,0,0.5,-11),Color3.fromRGB(200,30,50))
    accent.Visible=false;accent.ZIndex=14;corner(accent,2)

    table.insert(sideButtons,{btn=btn,icon=iconBG,iconLbl=iconLbl,nameLbl=nameLbl,accent=accent})

    btn.MouseEnter:Connect(function()
        tw(btn,{BackgroundColor3=Color3.fromRGB(34,34,46)},0.1)
    end)
    btn.MouseLeave:Connect(function()
        if not accent.Visible then
            tw(btn,{BackgroundColor3=Color3.fromRGB(28,28,38)},0.1)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(sideButtons) do
            tw(b.btn,{BackgroundColor3=Color3.fromRGB(28,28,38)},0.12)
            tw(b.nameLbl,{TextColor3=Color3.fromRGB(140,135,175)},0.12)
            tw(b.iconLbl,{TextColor3=Color3.fromRGB(160,155,200)},0.12)
            tw(b.iconBG,{BackgroundColor3=Color3.fromRGB(38,38,50)},0.12)
            b.accent.Visible=false
        end
        tw(btn,{BackgroundColor3=Color3.fromRGB(35,28,44)},0.12)
        tw(nameLbl,{TextColor3=Color3.fromRGB(255,255,255)},0.12)
        tw(iconLbl,{TextColor3=Color3.fromRGB(255,255,255)},0.12)
        tw(iconBG,{BackgroundColor3=Color3.fromRGB(200,30,50)},0.12)
        accent.Visible=true
        showPage(name)
    end)
    return btn
end

-- ================================================
-- ELEMENT MAKERS
-- ================================================
local function makeSection(parent,name)
    local f=newFrame(parent,UDim2.new(1,0,0,26),nil,Color3.fromRGB(0,0,0),1)
    f.ZIndex=14
    local line=newFrame(f,UDim2.new(0,3,0,16),UDim2.new(0,0,0.5,-8),Color3.fromRGB(200,30,50))
    line.ZIndex=15;corner(line,2)
    local lbl=newLabel(f,name,12,Color3.fromRGB(230,225,255),Enum.Font.GothamBold,
        UDim2.new(0,10,0,0),UDim2.new(1,-10,1,0))
    lbl.ZIndex=15
end

local function makeToggle(parent,name,default,cb)
    local row=newFrame(parent,UDim2.new(1,0,0,38),nil,Color3.fromRGB(33,33,42))
    row.ZIndex=14;corner(row,7)

    -- Icon area
    local iconArea=newFrame(row,UDim2.new(0,6,0,20),UDim2.new(0,6,0.5,-10),Color3.fromRGB(200,30,50))
    iconArea.ZIndex=15;corner(iconArea,3)

    newLabel(row,name,11,Color3.fromRGB(210,205,240),Enum.Font.GothamBold,
        UDim2.new(0,18,0,0),UDim2.new(1,-62,1,0)).ZIndex=15

    local bg=newFrame(row,UDim2.new(0,38,0,20),UDim2.new(1,-46,0.5,-10),
        default and Color3.fromRGB(80,200,120) or Color3.fromRGB(48,48,62))
    bg.ZIndex=15;corner(bg,10)
    local dot=newFrame(bg,UDim2.new(0,16,0,16),
        default and UDim2.new(0,20,0.5,-8) or UDim2.new(0,2,0.5,-8),
        Color3.fromRGB(255,255,255))
    dot.ZIndex=16;corner(dot,8)

    local val=default or false
    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,1,0);hit.BackgroundTransparency=1;hit.Text=""
    hit.ZIndex=17;hit.Parent=row

    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(40,40,52)},0.1) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(33,33,42)},0.1) end)

    hit.MouseButton1Click:Connect(function()
        val=not val
        tw(bg,{BackgroundColor3=val and Color3.fromRGB(80,200,120) or Color3.fromRGB(48,48,62)},0.15)
        tw(dot,{Position=val and UDim2.new(0,20,0.5,-8) or UDim2.new(0,2,0.5,-8)},0.15)
        tw(row,{BackgroundColor3=Color3.fromRGB(48,44,60)},0.07)
        task.delay(0.1,function() tw(row,{BackgroundColor3=Color3.fromRGB(33,33,42)},0.1) end)
        if cb then cb(val) end
    end)
end

local function makeSlider(parent,name,min,max,default,inc,cb)
    local row=newFrame(parent,UDim2.new(1,0,0,54),nil,Color3.fromRGB(33,33,42))
    row.ZIndex=14;corner(row,7)

    newLabel(row,name,11,Color3.fromRGB(210,205,240),Enum.Font.GothamBold,
        UDim2.new(0,10,0,4),UDim2.new(1,-70,0,22)).ZIndex=15

    local valL=newLabel(row,tostring(default),11,Color3.fromRGB(200,30,50),Enum.Font.GothamBold,
        UDim2.new(1,-62,0,4),UDim2.new(0,54,0,22),Enum.TextXAlignment.Right)
    valL.ZIndex=15

    -- Track BG
    local trackBG=newFrame(row,UDim2.new(1,-20,0,6),UDim2.new(0,10,1,-16),Color3.fromRGB(44,44,58))
    trackBG.ZIndex=15;corner(trackBG,3)

    -- Fill
    local fill=newFrame(trackBG,UDim2.new((default-min)/(max-min),0,1,0),nil,Color3.fromRGB(200,30,50))
    fill.ZIndex=16;corner(fill,3)

    -- Dot handle
    local dot=newFrame(fill,UDim2.new(0,14,0,14),UDim2.new(0,-7,0.5,-7),Color3.fromRGB(255,255,255))
    dot.ZIndex=17;corner(dot,7)
    stroke(dot,Color3.fromRGB(200,30,50),1.5)

    local val=default
    local sliding=false

    -- Input on track
    trackBG.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true
            -- Immediate click response
            local abs=trackBG.AbsolutePosition;local sz=trackBG.AbsoluteSize
            local p=math.clamp((i.Position.X-abs.X)/sz.X,0,1)
            val=math.clamp(math.round((min+(max-min)*p)/inc)*inc,min,max)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            valL.Text=tostring(val)
            if cb then cb(val) end
        end
    end)

    -- Input on dot too
    dot.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if not sliding then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local abs=trackBG.AbsolutePosition;local sz=trackBG.AbsoluteSize
            local p=math.clamp((i.Position.X-abs.X)/sz.X,0,1)
            val=math.clamp(math.round((min+(max-min)*p)/inc)*inc,min,max)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            valL.Text=tostring(val)
            if cb then cb(val) end
        end
    end)
end

local function makeDropdown(parent,name,options,default,cb)
    local row=newFrame(parent,UDim2.new(1,0,0,38),nil,Color3.fromRGB(33,33,42))
    row.ClipsDescendants=false;row.ZIndex=14;corner(row,7)

    newLabel(row,name,11,Color3.fromRGB(210,205,240),Enum.Font.GothamBold,
        UDim2.new(0,10,0,0),UDim2.new(0.5,0,1,0)).ZIndex=15

    local sel=default or options[1]
    local dBtn=Instance.new("TextButton")
    dBtn.Size=UDim2.new(0,94,0,26);dBtn.Position=UDim2.new(1,-102,0.5,-13)
    dBtn.BackgroundColor3=Color3.fromRGB(22,22,30)
    dBtn.Text=sel.." ▾";dBtn.TextColor3=Color3.fromRGB(200,195,235)
    dBtn.Font=Enum.Font.Gotham;dBtn.TextSize=10;dBtn.ZIndex=15;dBtn.Parent=row
    corner(dBtn,5);stroke(dBtn,Color3.fromRGB(50,50,68),1)

    local dFrame=newFrame(row,UDim2.new(0,94,0,#options*26+6),UDim2.new(1,-102,1,4),Color3.fromRGB(22,22,30))
    dFrame.Visible=false;dFrame.ZIndex=50;dFrame.ClipsDescendants=false
    corner(dFrame,6);stroke(dFrame,Color3.fromRGB(50,50,68),1)

    local dl=Instance.new("UIListLayout");dl.Padding=UDim.new(0,2);dl.Parent=dFrame
    local dp=Instance.new("UIPadding")
    dp.PaddingTop=UDim.new(0,3);dp.PaddingLeft=UDim.new(0,3);dp.PaddingRight=UDim.new(0,3)
    dp.Parent=dFrame

    for _,opt in pairs(options) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,22);ob.BackgroundColor3=Color3.fromRGB(28,28,38)
        ob.Text=opt;ob.TextColor3=Color3.fromRGB(200,195,235)
        ob.Font=Enum.Font.Gotham;ob.TextSize=10;ob.ZIndex=51;ob.Parent=dFrame
        corner(ob,4)
        ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(38,30,46)},0.08) end)
        ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(28,28,38)},0.08) end)
        ob.MouseButton1Click:Connect(function()
            sel=opt;dBtn.Text=opt.." ▾";dFrame.Visible=false
            tw(row,{Size=UDim2.new(1,0,0,38)},0.1)
            if cb then cb(opt) end
        end)
    end

    local open=false
    dBtn.MouseButton1Click:Connect(function()
        open=not open;dFrame.Visible=open
        tw(row,{Size=UDim2.new(1,0,0,open and 38+#options*26+10 or 38)},0.15)
    end)
    if cb then cb(sel) end
end

local function makeButton(parent,name,cb)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,34)
    btn.BackgroundColor3=Color3.fromRGB(200,30,50)
    btn.Text=name;btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold;btn.TextSize=11
    btn.BorderSizePixel=0;btn.ZIndex=14;btn.Parent=parent
    corner(btn,7)
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(220,45,65)},0.1) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(200,30,50)},0.1) end)
    btn.MouseButton1Click:Connect(function()
        tw(btn,{Size=UDim2.new(1,-6,0,30)},0.07)
        task.delay(0.1,function() tw(btn,{Size=UDim2.new(1,0,0,34)},0.1,Enum.EasingStyle.Back) end)
        if cb then cb() end
    end)
end

-- ================================================
-- BUILD TABS + PAGES
-- ================================================
local Lighting=game:GetService("Lighting")

-- MAIN
makeSideTab("Main", "⊞")
local mainP=newPage("Main")
makeSection(mainP.c1,"ESP")
makeToggle(mainP.c1,"Enable ESP",false,function(v) end)
makeToggle(mainP.c1,"Name ESP",false,function(v) end)
makeToggle(mainP.c1,"Health Bar",false,function(v) end)
makeDropdown(mainP.c1,"ESP Mode",{"Highlight","Box","Tracer"},"Highlight",function(v) end)
makeDropdown(mainP.c1,"ESP Color",{"Red","Green","Blue","Yellow","Cyan","White"},"Red",function(v) end)
makeSlider(mainP.c1,"Transparency",0,10,5,1,function(v) end)

makeSection(mainP.c2,"Movement")
makeToggle(mainP.c2,"Noclip",false,function(v) end)
makeToggle(mainP.c2,"Infinite Jump",false,function(v)
    if v then
        UserInputService.JumpRequest:Connect(function()
            if LP.Character then
                local h=LP.Character:FindFirstChild("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)
makeToggle(mainP.c2,"Speed Hack",false,function(v)
    RunService.Heartbeat:Connect(function()
        if LP.Character then
            local h=LP.Character:FindFirstChild("Humanoid")
            if h then h.WalkSpeed=v and 40 or 16 end
        end
    end)
end)
makeSlider(mainP.c2,"Walk Speed",16,200,40,1,function(v)
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed=v end
    end
end)

-- COMBAT
makeSideTab("Combat","⊕")
local combatP=newPage("Combat")
makeSection(combatP.c1,"Aimbot")
makeToggle(combatP.c1,"Enable Aimbot",false,function(v) end)
makeToggle(combatP.c1,"FOV Circle",false,function(v) end)
makeSlider(combatP.c1,"FOV Radius",30,500,150,5,function(v) end)
makeSlider(combatP.c1,"Smoothness",1,100,15,1,function(v) end)
makeDropdown(combatP.c1,"Aim Part",{"Head","HumanoidRootPart","UpperTorso"},"Head",function(v) end)
makeSection(combatP.c2,"AI Helper")
makeToggle(combatP.c2,"AI Dodge",false,function(v) end)
makeSlider(combatP.c2,"Dodge Distance",1,10,3,1,function(v) end)

-- VISUALS
makeSideTab("Visual","◈")
local visP=newPage("Visual")
makeSection(visP.c1,"World")
makeToggle(visP.c1,"Fullbright",false,function(v)
    Lighting.Brightness=v and 10 or 1;Lighting.ClockTime=14
    Lighting.GlobalShadows=not v
    Lighting.Ambient=v and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end)
makeSection(visP.c2,"Info")
makeToggle(visP.c2,"Show FPS",true,function(v) fpsLabel.Visible=v end)

-- MISC
makeSideTab("Misc","⊙")
local miscP=newPage("Misc")
makeSection(miscP.c1,"Utility")
makeToggle(miscP.c1,"Anti-AFK",false,function(v)
    if v then
        LP.Idled:Connect(function()
            local vu=game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            vu:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
end)
makeButton(miscP.c1,"Rejoin",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end)
makeButton(miscP.c1,"Respawn",function()
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h.Health=0 end end
end)

-- SETTINGS
makeSideTab("Settings","⚙")
local setP=newPage("Settings")
makeSection(setP.c1,"About")
makeButton(setP.c1,"Creator: @Primejtsu",function() end)
makeButton(setP.c1,"Version: v2.0",function() end)

-- Show first
showPage("Main")
tw(sideButtons[1].btn,{BackgroundColor3=Color3.fromRGB(35,28,44)},0)
tw(sideButtons[1].nameLbl,{TextColor3=Color3.fromRGB(255,255,255)},0)
tw(sideButtons[1].iconLbl,{TextColor3=Color3.fromRGB(255,255,255)},0)
tw(sideButtons[1].iconBG,{BackgroundColor3=Color3.fromRGB(200,30,50)},0)
sideButtons[1].accent.Visible=true

print("[Primejtsu X] UI v2.0 Loaded!")
