
-- Godmode, Anti-Void, Anti-Ragdoll, Anti-Kill, Auto-Respawn, ForceField

local TK = getgenv().TK
local lp = TK.lp
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")

local def = TK.tabs["Def"]

-- ══════════════════════════════════
-- TOGGLES
-- ══════════════════════════════════

TK.mkSec(def, "HP PROTECTION")

TK.mkTog(def, "Godmode (HP Loop)", "god", nil, function()
    -- Restaurar HP normal ao desligar
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
        end
    end)
end)

TK.mkTog(def, "ForceField (invisivel)", "ff", nil, function()
    -- Remover FF ao desligar
    pcall(function()
        local ff = lp.Character:FindFirstChildOfClass("ForceField")
        if ff then ff:Destroy() end
    end)
end)

TK.mkSec(def, "POSITION SAFETY")

TK.mkTog(def, "Anti-Void", "aVoid")

TK.mkTog(def, "Auto-Respawn (0.05s)", "aResp")

TK.mkSec(def, "STATE PROTECTION")

TK.mkTog(def, "Anti-Ragdoll", "aRag", nil, function()
    -- Restaurar estados ao desligar
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end)
        end
    end)
end)

TK.mkSec(def, "WORLD PROTECTION")

TK.mkTog(def, "Anti-Kill Parts", "aKill", function()
    -- Neutralizar kill parts existentes ao ativar
    pcall(function()
        local killWords = {
            "kill", "lava", "death", "damage", "hurt", "spike",
            "trap", "hazard", "lethal", "deadly", "acid", "poison",
            "fire", "laser", "saw", "blade", "crusher", "void",
        }
        for _, obj in ipairs(WS:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    for _, kw in ipairs(killWords) do
                        if n:find(kw, 1, true) then
                            obj.CanTouch = false
                            break
                        end
                    end
                end
            end)
        end
    end)
    print("[DEF] Kill parts neutralizadas")
end, function()
    -- Restaurar CanTouch ao desligar
    pcall(function()
        for _, obj in ipairs(WS:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.CanTouch = true
                end
            end)
        end
    end)
end)

-- ══════════════════════════════════
-- MAIN DEFENSE LOOP
-- ══════════════════════════════════

RS.Heartbeat:Connect(function()
    local ch = lp.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- GODMODE
    if TK.ON.god then
        hum.MaxHealth = 1e8
        hum.Health = 1e8
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    end

    -- ANTI-VOID
    if TK.ON.aVoid then
        if hrp.Position.Y > -50 then
            TK.ON._safePos = hrp.CFrame
        end
        if hrp.Position.Y < -200 and TK.ON._safePos then
            hrp.CFrame = TK.ON._safePos
            if TK.ON.god then hum.Health = hum.MaxHealth end
        end
    end

    -- ANTI-RAGDOLL
    if TK.ON.aRag then
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
    end

    -- FORCEFIELD (recriar se removido)
    if TK.ON.ff then
        if not ch:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = ch
        end
    end
end)

-- ══════════════════════════════════
-- ANTI-KILL PARTS: novas partes
-- Neutralizar kill parts que aparecem depois
-- ══════════════════════════════════
WS.DescendantAdded:Connect(function(obj)
    if not TK.ON.aKill then return end
    task.defer(function()
        pcall(function()
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                local killWords = {"kill", "lava", "death", "damage", "hurt", "spike", "trap", "hazard", "laser", "saw", "crusher"}
                for _, kw in ipairs(killWords) do
                    if n:find(kw, 1, true) then
                        obj.CanTouch = false
                        break
                    end
                end
            end
        end)
    end)
end)

-- ══════════════════════════════════
-- AUTO-RESPAWN + REAPLICAR DEFESAS
-- ══════════════════════════════════

local function onNewCharacter(char)
    task.wait(0.3)

    -- Reaplicar godmode
    if TK.ON.god then
        pcall(function()
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.MaxHealth = 1e8
                hum.Health = 1e8
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
            end
        end)
    end

    -- Reaplicar ForceField
    if TK.ON.ff then
        pcall(function()
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
        end)
    end

    -- Reaplicar anti-ragdoll
    if TK.ON.aRag then
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
            end
        end)
    end

    -- Teleportar de volta à posição segura
    if TK.ON.aResp and TK.ON._safePos then
        pcall(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                task.wait(0.1)
                hrp.CFrame = TK.ON._safePos
            end
        end)
    end

    -- Conectar detecção de morte para auto-respawn
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if TK.ON.aResp then
                    task.wait(0.05)
                    -- Salvar posição antes de respawnar
                    pcall(function()
                        TK.ON._safePos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame or TK.ON._safePos
                    end)
                    -- Tentar LoadCharacter
                    pcall(function() lp:LoadCharacter() end)
                    -- Fallback: procurar remote de respawn
                    pcall(function()
                        for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                            pcall(function()
                                if d:IsA("RemoteEvent") then
                                    local n = d.Name:lower()
                                    if n:find("respawn") or n:find("spawn") or n:find("revive") or n:find("reset") or n:find("retry") then
                                        d:FireServer()
                                    end
                                end
                            end)
                        end
                    end)
                end
            end)
        end
    end)
end

-- Aplicar no character atual
if lp.Character then
    onNewCharacter(lp.Character)
end

-- Aplicar em futuros characters (respawn)
lp.CharacterAdded:Connect(function(char)
    onNewCharacter(char)
end)

print("[DEFENSE] 6 ferramentas carregadas")
