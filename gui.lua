
-- Cria interface, tabs e funcoes builder

local TK = getgenv().TK
local lp = TK.lp
local UIS = game:GetService("UserInputService")

-- Limpar GUI antiga
pcall(function()
    local old = lp.PlayerGui:FindFirstChild("YHMH")
    if old then old:Destroy() end
end)

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "YHMH"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")
TK.sg = sg

-- ══════════════════════════════════
-- TOGGLE BUTTON (arrastavel, canto esquerdo)
-- ══════════════════════════════════
local mBtn = Instance.new("TextButton")
mBtn.Name = "Toggle"
mBtn.Size = UDim2.new(0, 50, 0, 50)
mBtn.Position = UDim2.new(0, 8, 0.35, 0)
mBtn.BackgroundColor3 = Color3.fromRGB(88, 28, 135)
mBtn.Text = "YH"
mBtn.TextColor3 = Color3.new(1, 1, 1)
mBtn.Font = Enum.Font.SourceSansBold
mBtn.TextSize = 18
mBtn.BorderSizePixel = 0
mBtn.ZIndex = 200
mBtn.Parent = sg

-- Drag do botao toggle
local dragT = false
local dragTS = nil
local dragTP = nil
local wasDrag = false

mBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragT = true
        wasDrag = false
        dragTS = i.Position
        dragTP = mBtn.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragT and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        if dragTS then
            local delta = i.Position - dragTS
            if delta.Magnitude > 8 then wasDrag = true end
            mBtn.Position = UDim2.new(
                dragTP.X.Scale, dragTP.X.Offset + delta.X,
                dragTP.Y.Scale, dragTP.Y.Offset + delta.Y
            )
        end
    end
end)

mBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        if dragT and not wasDrag then
            -- Foi clique, nao drag — toggle painel
            TK.ON._open = not TK.ON._open
            sg:FindFirstChild("Panel").Visible = TK.ON._open
            mBtn.Text = TK.ON._open and "X" or "YH"
            mBtn.BackgroundColor3 = TK.ON._open and Color3.fromRGB(185, 28, 28) or Color3.fromRGB(88, 28, 135)
        end
        dragT = false
    end
end)

-- ══════════════════════════════════
-- PANEL PRINCIPAL
-- ══════════════════════════════════
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0.92, 0, 0.85, 0)
panel.Position = UDim2.new(0.04, 0, 0.075, 0)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 50
panel.Parent = sg

-- ══════════════════════════════════
-- TITLE BAR (arrastavel)
-- ══════════════════════════════════
local tBar = Instance.new("Frame")
tBar.Name = "TitleBar"
tBar.Size = UDim2.new(1, 0, 0, 38)
tBar.BackgroundColor3 = Color3.fromRGB(88, 28, 135)
tBar.BorderSizePixel = 0
tBar.ZIndex = 51
tBar.Parent = panel

-- Titulo: YHMH HUB
local tName = Instance.new("TextLabel")
tName.Size = UDim2.new(0.55, 0, 1, 0)
tName.Position = UDim2.new(0, 12, 0, 0)
tName.BackgroundTransparency = 1
tName.Text = "YHMH HUB"
tName.TextColor3 = Color3.new(1, 1, 1)
tName.Font = Enum.Font.SourceSansBold
tName.TextSize = 16
tName.TextXAlignment = Enum.TextXAlignment.Left
tName.ZIndex = 52
tName.Parent = tBar

-- Game name (direita do titulo)
local gName = Instance.new("TextLabel")
gName.Size = UDim2.new(0.4, 0, 1, 0)
gName.Position = UDim2.new(0.55, 0, 0, 0)
gName.BackgroundTransparency = 1
gName.TextColor3 = Color3.fromRGB(200, 180, 255)
gName.Font = Enum.Font.SourceSans
gName.TextSize = 11
gName.TextXAlignment = Enum.TextXAlignment.Right
gName.ZIndex = 52
gName.Parent = tBar

-- Pegar nome do jogo
task.spawn(function()
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        gName.Text = info.Name
    end)
end)

-- Close button no titulo
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 38, 0, 38)
closeBtn.Position = UDim2.new(1, -38, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.ZIndex = 52
closeBtn.Parent = tBar
closeBtn.MouseButton1Click:Connect(function()
    TK.ON._open = false
    panel.Visible = false
    mBtn.Text = "YH"
    mBtn.BackgroundColor3 = Color3.fromRGB(88, 28, 135)
end)

-- Drag do painel pelo titulo
local dragP = false
local dragPS = nil
local dragPP = nil

tBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragP = true
        dragPS = i.Position
        dragPP = panel.Position
    end
end)

tBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragP = false
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragP and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        if dragPS then
            local delta = i.Position - dragPS
            panel.Position = UDim2.new(
                dragPP.X.Scale, dragPP.X.Offset + delta.X,
                dragPP.Y.Scale, dragPP.Y.Offset + delta.Y
            )
        end
    end
end)

-- ══════════════════════════════════
-- TAB BAR
-- ══════════════════════════════════
local tabNames = {"Move", "ESP", "Def", "TP", "Misc"}
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.Position = UDim2.new(0, 0, 0, 38)
tabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 26)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 51
tabBar.Parent = panel

TK.tabs = {}
TK.tabBtns = {}

for i, name in ipairs(tabNames) do
    -- Tab button
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1 / #tabNames, -2, 0, 30)
    b.Position = UDim2.new((i - 1) / #tabNames, 1, 0.5, -15)
    b.BackgroundColor3 = i == 1 and Color3.fromRGB(88, 28, 135) or Color3.fromRGB(22, 22, 38)
    b.Text = name
    b.TextColor3 = i == 1 and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 170)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.ZIndex = 52
    b.Parent = tabBar
    TK.tabBtns[name] = b

    -- Tab content (ScrollingFrame)
    local f = Instance.new("ScrollingFrame")
    f.Name = "Tab_" .. name
    f.Size = UDim2.new(1, -8, 1, -82)
    f.Position = UDim2.new(0, 4, 0, 78)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Color3.fromRGB(88, 28, 135)
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Visible = i == 1
    f.ZIndex = 51
    f.Parent = panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = f

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = f

    TK.tabs[name] = f

   
    b.MouseButton1Click:Connect(function()
        for n, tb in pairs(TK.tabBtns) do
            tb.BackgroundColor3 = n == name and Color3.fromRGB(88, 28, 135) or Color3.fromRGB(22, 22, 38)
            tb.TextColor3 = n == name and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 170)
        end
        for n, tf in pairs(TK.tabs) do
            tf.Visible = n == name
        end
    end)
end


function TK.mkSec(parent, title)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = "  " .. title
    l.TextColor3 = Color3.fromRGB(88, 28, 135)
    l.Font = Enum.Font.SourceSansBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 52
    l.Parent = parent
end


function TK.mkTog(parent, name, key, onCB, offCB)
    TK.ON[key] = false

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 44)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    f.BorderSizePixel = 0
    f.ZIndex = 52
    f.Parent = parent

    -- Nome
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.64, 0, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(215, 215, 230)
    l.Font = Enum.Font.SourceSansBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 53
    l.Parent = f

  
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 58, 0, 30)
    b.Position = UDim2.new(1, -66, 0.5, -15)
    b.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
    b.Text = "OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.ZIndex = 53
    b.Parent = f

    b.MouseButton1Click:Connect(function()
        TK.ON[key] = not TK.ON[key]
        b.Text = TK.ON[key] and "ON" or "OFF"
        b.BackgroundColor3 = TK.ON[key] and Color3.fromRGB(22, 130, 50) or Color3.fromRGB(50, 20, 20)
        f.BackgroundColor3 = TK.ON[key] and Color3.fromRGB(16, 22, 16) or Color3.fromRGB(16, 16, 28)
        if TK.ON[key] and onCB then pcall(onCB) end
        if not TK.ON[key] and offCB then pcall(offCB) end
    end)
end


function TK.mkBtn(parent, name, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(18, 18, 34)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(190, 190, 210)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    b.ZIndex = 53
    b.Parent = parent

    b.MouseButton1Click:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
        b.Text = "  ..."
        pcall(cb)
        task.delay(0.4, function()
            pcall(function()
                b.BackgroundColor3 = Color3.fromRGB(18, 18, 34)
                b.Text = "  " .. name
            end)
        end)
    end)
end


function TK.mkSlider(parent, name, key, min, max, step)
    TK.V[key] = TK.V[key] or min

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 24)
    f.BorderSizePixel = 0
    f.ZIndex = 52
    f.Parent = parent

    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.42, 0, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(140, 140, 165)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 53
    l.Parent = f

  
    local mb = Instance.new("TextButton")
    mb.Size = UDim2.new(0, 36, 0, 26)
    mb.Position = UDim2.new(0.46, 0, 0.5, -13)
    mb.BackgroundColor3 = Color3.fromRGB(55, 18, 18)
    mb.Text = "-"
    mb.TextColor3 = Color3.new(1, 1, 1)
    mb.Font = Enum.Font.SourceSansBold
    mb.TextSize = 18
    mb.BorderSizePixel = 0
    mb.ZIndex = 53
    mb.Parent = f

  
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 52, 0, 26)
    vl.Position = UDim2.new(0.46, 40, 0.5, -13)
    vl.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    vl.Text = tostring(TK.V[key])
    vl.TextColor3 = Color3.fromRGB(255, 200, 60)
    vl.Font = Enum.Font.SourceSansBold
    vl.TextSize = 14
    vl.BorderSizePixel = 0
    vl.ZIndex = 53
    vl.Parent = f


    local pb = Instance.new("TextButton")
    pb.Size = UDim2.new(0, 36, 0, 26)
    pb.Position = UDim2.new(0.46, 96, 0.5, -13)
    pb.BackgroundColor3 = Color3.fromRGB(18, 55, 18)
    pb.Text = "+"
    pb.TextColor3 = Color3.new(1, 1, 1)
    pb.Font = Enum.Font.SourceSansBold
    pb.TextSize = 18
    pb.BorderSizePixel = 0
    pb.ZIndex = 53
    pb.Parent = f

    mb.MouseButton1Click:Connect(function()
        TK.V[key] = math.max(min, TK.V[key] - step)
        vl.Text = tostring(TK.V[key])
    end)

    pb.MouseButton1Click:Connect(function()
        TK.V[key] = math.min(max, TK.V[key] + step)
        vl.Text = tostring(TK.V[key])
    end)
end


local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, 0, 0, 18)
statusBar.Position = UDim2.new(0, 0, 1, -18)
statusBar.BackgroundColor3 = Color3.fromRGB(6, 6, 14)
statusBar.Text = "  YHMH HUB | " .. lp.Name .. " | PlaceId: " .. game.PlaceId
statusBar.TextColor3 = Color3.fromRGB(80, 80, 110)
statusBar.Font = Enum.Font.SourceSans
statusBar.TextSize = 10
statusBar.TextXAlignment = Enum.TextXAlignment.Left
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 51
statusBar.Parent = panel

print("[GUI] Interface criada com sucesso")
