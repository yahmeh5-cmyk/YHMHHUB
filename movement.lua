📋 Copiar-- YHMH HUB — Movement
-- Speed, Fly+DPad, Noclip, InfJump, HighJump, LowGrav, ClickTP, Freeze

local TK = getgenv().TK
local lp = TK.lp
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")

local mv = TK.tabs["Move"]
local origGrav = WS.Gravity

-- ══════════════════════════════════
-- TOGGLES
-- ══════════════════════════════════

TK.mkSec(mv, "SPEED")

TK.mkTog(mv, "Speed Hack", "speed", nil, function()
    pcall(function() lp.Character.Humanoid.WalkSpeed = 16 end)
end)

TK.mkSlider(mv, "Speed", "speed", 16, 500, 25)

TK.mkSec(mv, "FLY")

TK.mkTog(mv, "Fly (D-Pad)", "fly", nil, function()
    -- Limpar BodyMovers
    pcall(function()
        local hrp = lp.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("_YH_BV")
        local bg = hrp:FindFirstChild("_YH_BG")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
    -- Restaurar estado
    pcall(function() lp.Character.Humanoid.PlatformStand = false end)
end)

TK.mkSlider(mv, "Fly Speed", "fly", 20, 300, 20)

TK.mkSec(mv, "COLLISION")

TK.mkTog(mv, "Noclip", "noclip", nil, function()
    pcall(function()
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = true
            end
        end
    end)
end)

TK.mkSec(mv, "JUMP")

TK.mkTog(mv, "Infinite Jump", "infJump")

TK.mkTog(mv, "High Jump", "highJump", nil, function()
    pcall(function() lp.Character.Humanoid.JumpPower = 50 end)
end)

TK.mkSlider(mv, "Jump Power", "jump", 50, 500, 25)

TK.mkSec(mv, "PHYSICS")

TK.mkTog(mv, "Low Gravity", "lowGrav", nil, function()
    WS.Gravity = origGrav
end)

TK.mkSec(mv, "TELEPORT")

TK.mkTog(mv, "Click TP", "clickTP")

TK.mkTog(mv, "Freeze Position", "freeze", function()
    -- Salvar posicao atual ao ativar
    pcall(function()
        TK.ON._freezePos = lp.Character.HumanoidRootPart.CFrame
    end)
end)

-- ══════════════════════════════════
-- FLY D-PAD
-- 6 botoes: W(frente) S(tras) A(esq) D(dir) UP DN
-- Posicionado no canto inferior direito
-- Só aparece quando Fly está ON
-- ══════════════════════════════════
local dpad = Instance.new("Frame")
dpad.Name = "FlyDPad"
dpad.Size = UDim2.new(0, 152, 0, 152)
dpad.Position = UDim2.new(1, -162, 1, -222)
dpad.BackgroundTransparency = 1
dpad.Visible = false
dpad.ZIndex = 150
dpad.Parent = TK.sg

-- Background sutil do dpad
local dpadBG = Instance.new("Frame")
dpadBG.Size = UDim2.new(1, 8, 1, 8)
dpadBG.Position = UDim2.new(0, -4, 0, -4)
dpadBG.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
dpadBG.BackgroundTransparency = 0.4
dpadBG.BorderSizePixel = 0
dpadBG.ZIndex = 149
dpadBG.Parent = dpad

-- Estado dos botoes
local hold = {f = false, b = false, l = false, r = false, u = false, d = false}

local function makeDPadBtn(text, pos, id)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 25, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.ZIndex = 151
    btn.Parent = dpad

    local colorOff = Color3.fromRGB(30, 25, 55)
    local colorOn = Color3.fromRGB(88, 28, 135)

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            hold[id] = true
            btn.BackgroundColor3 = colorOn
            btn.TextColor3 = Color3.new(1, 1, 1)
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            hold[id] = false
            btn.BackgroundColor3 = colorOff
            btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
    end)
end

--         [UP]    [ W ]
--   [ A ] [center] [ D ]
--         [ S ]   [DN]

makeDPadBtn("W",  UDim2.new(0.5, -22, 0,    2),  "f")  -- frente (cima centro)
makeDPadBtn("S",  UDim2.new(0.5, -22, 1,   -46),  "b")  -- tras (baixo centro)
makeDPadBtn("A",  UDim2.new(0,    2,  0.5, -22),  "l")  -- esquerda
makeDPadBtn("D",  UDim2.new(1,   -46, 0.5, -22),  "r")  -- direita
makeDPadBtn("UP", UDim2.new(0,    2,  0,     2),  "u")  -- subir (canto sup esq)
makeDPadBtn("DN", UDim2.new(1,   -46, 1,   -46),  "d")  -- descer (canto inf dir)

-- ══════════════════════════════════
-- MAIN LOOP (Heartbeat)
-- ══════════════════════════════════
RS.Heartbeat:Connect(function()
    local ch = lp.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- SPEED
    if TK.ON.speed then
        hum.WalkSpeed = TK.V.speed
    end

    -- HIGH JUMP
    if TK.ON.highJump then
        hum.JumpPower = TK.V.jump
    end

    -- LOW GRAVITY
    if TK.ON.lowGrav then
        WS.Gravity = 35
    end

    -- NOCLIP
    if TK.ON.noclip then
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end

    -- FREEZE
    if TK.ON.freeze and TK.ON._freezePos then
        hrp.CFrame = TK.ON._freezePos
    end

    -- ═══ FLY ═══
    dpad.Visible = TK.ON.fly

    if TK.ON.fly then
        -- Criar BodyMovers se nao existem
        local bv = hrp:FindFirstChild("_YH_BV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "_YH_BV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end

        local bg = hrp:FindFirstChild("_YH_BG")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "_YH_BG"
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 1e4
            bg.Parent = hrp
        end

        hum.PlatformStand = true

        -- Calcular direcao baseado nos botoes pressionados
        local dir = Vector3.zero
        if hold.f then dir = dir + Vector3.new(0, 0, -1) end
        if hold.b then dir = dir + Vector3.new(0, 0,  1) end
        if hold.l then dir = dir + Vector3.new(-1, 0, 0) end
        if hold.r then dir = dir + Vector3.new(1,  0, 0) end
        if hold.u then dir = dir + Vector3.new(0,  1, 0) end
        if hold.d then dir = dir + Vector3.new(0, -1, 0) end

        -- Converter direcao relativa a camera
        if dir.Magnitude > 0 then
            bv.Velocity = WS.CurrentCamera.CFrame:VectorToWorldSpace(dir.Unit * TK.V.fly)
        else
            bv.Velocity = Vector3.zero
        end

        bg.CFrame = WS.CurrentCamera.CFrame
    else
        -- Limpar BodyMovers quando fly esta OFF
        pcall(function()
            local bv = hrp:FindFirstChild("_YH_BV")
            local bg = hrp:FindFirstChild("_YH_BG")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end
end)

-- ══════════════════════════════════
-- INFINITE JUMP
-- ══════════════════════════════════
UIS.JumpRequest:Connect(function()
    if TK.ON.infJump then
        pcall(function()
            lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- ══════════════════════════════════
-- CLICK TP
-- Só funciona quando o menu esta FECHADO
-- para nao teleportar ao clicar no menu
-- ══════════════════════════════════
pcall(function()
    local mouse = lp:GetMouse()
    mouse.Button1Down:Connect(function()
        if TK.ON.clickTP and not TK.ON._open then
            pcall(function()
                local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp and mouse.Hit then
                    hrp.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
                end
            end)
        end
    end)
end)

print("[MOVEMENT] 8 ferramentas carregadas")
