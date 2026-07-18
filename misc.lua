
-- Character, Time, FPS, AntiAFK, RemoteSpy, Info, Utilities

local TK = getgenv().TK
local lp = TK.lp
local Light = game:GetService("Lighting")
local WS = game:GetService("Workspace")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")

local misc = TK.tabs["Misc"]

-- ══════════════════════════════════
-- CHARACTER SCALE
-- ══════════════════════════════════
TK.mkSec(misc, "CHARACTER")

TK.mkBtn(misc, "🐜 Tiny Character", function()
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        local desc = hum:GetAppliedDescription()
        desc.HeadScale = 0.5
        desc.BodyDepthScale = 0.5
        desc.BodyHeightScale = 0.5
        desc.BodyWidthScale = 0.5
        hum:ApplyDescription(desc)
        print("[MISC] Tiny!")
    end)
end)

TK.mkBtn(misc, "🦕 Giant Character", function()
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        local desc = hum:GetAppliedDescription()
        desc.HeadScale = 3
        desc.BodyDepthScale = 3
        desc.BodyHeightScale = 3
        desc.BodyWidthScale = 3
        hum:ApplyDescription(desc)
        print("[MISC] Giant!")
    end)
end)

TK.mkBtn(misc, "👤 Normal Size", function()
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        local desc = hum:GetAppliedDescription()
        desc.HeadScale = 1
        desc.BodyDepthScale = 1
        desc.BodyHeightScale = 1
        desc.BodyWidthScale = 1
        hum:ApplyDescription(desc)
        print("[MISC] Normal!")
    end)
end)

-- ══════════════════════════════════
-- TIME OF DAY
-- ══════════════════════════════════
TK.mkSec(misc, "TIME")

TK.mkBtn(misc, "🌅 Day (14h)", function()
    pcall(function() Light.ClockTime = 14 end)
    print("[MISC] Day")
end)

TK.mkBtn(misc, "🌙 Night (0h)", function()
    pcall(function() Light.ClockTime = 0 end)
    print("[MISC] Night")
end)

TK.mkBtn(misc, "🌄 Dawn (6h)", function()
    pcall(function() Light.ClockTime = 6 end)
    print("[MISC] Dawn")
end)

TK.mkBtn(misc, "🌇 Dusk (18h)", function()
    pcall(function() Light.ClockTime = 18 end)
    print("[MISC] Dusk")
end)

-- ══════════════════════════════════
-- PERFORMANCE
-- ══════════════════════════════════
TK.mkSec(misc, "PERFORMANCE")

TK.mkTog(misc, "FPS Boost", "fps", function()
    -- Desativar particles, trails, decals
    pcall(function()
        local count = 0
        for _, d in ipairs(WS:GetDescendants()) do
            pcall(function()
                if d:IsA("ParticleEmitter") then
                    d.Enabled = false
                    count = count + 1
                elseif d:IsA("Trail") then
                    d.Enabled = false
                    count = count + 1
                elseif d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                    d.Enabled = false
                    count = count + 1
                end
            end)
        end
        -- Remover efeitos de Lighting
        for _, e in ipairs(Light:GetDescendants()) do
            pcall(function()
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("BloomEffect") then
                    e.Enabled = false
                    count = count + 1
                end
            end)
        end
        print("[MISC] FPS Boost: " .. count .. " efeitos desativados")
    end)
end, function()
    -- Reativar tudo
    pcall(function()
        for _, d in ipairs(WS:GetDescendants()) do
            pcall(function()
                if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                    d.Enabled = true
                end
            end)
        end
        for _, e in ipairs(Light:GetDescendants()) do
            pcall(function()
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("BloomEffect") then
                    e.Enabled = true
                end
            end)
        end
        print("[MISC] FPS Boost desativado")
    end)
end)

-- ══════════════════════════════════
-- DEBUG & SPY
-- ══════════════════════════════════
TK.mkSec(misc, "DEBUG")

TK.mkTog(misc, "Remote Spy (console)", "spy")

-- Hook remote spy
pcall(function()
    local hookMM = hookmetamethod or (getgenv and getgenv().hookmetamethod)
    local getNCM = getnamecallmethod or (getgenv and getgenv().getnamecallmethod)
    if hookMM and getNCM then
        local old
        old = hookMM(game, "__namecall", function(self, ...)
            if TK.ON.spy then
                pcall(function()
                    local method = getNCM()
                    if (method == "FireServer" or method == "InvokeServer") then
                        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                            local args = {...}
                            local parts = {}
                            for _, v in ipairs(args) do
                                if typeof(v) == "Instance" then
                                    table.insert(parts, "Inst<" .. v.Name .. ">")
                                elseif type(v) == "table" then
                                    local tp = {}
                                    local c = 0
                                    for k, val in pairs(v) do
                                        c = c + 1
                                        if c > 5 then break end
                                        table.insert(tp, tostring(k) .. "=" .. tostring(val))
                                    end
                                    table.insert(parts, "{" .. table.concat(tp, ",") .. "}")
                                else
                                    table.insert(parts, tostring(v))
                                end
                            end
                            print("[SPY] " .. method .. " -> " .. self.Name .. "(" .. table.concat(parts, ", "):sub(1, 200) .. ")")
                        end
                    end
                end)
            end
            return old(self, ...)
        end)
        print("[MISC] Remote Spy hookado")
    else
        print("[MISC] hookmetamethod nao disponivel — Remote Spy limitado")
    end
end)

-- ══════════════════════════════════
-- INFO & UTILITIES
-- ══════════════════════════════════
TK.mkSec(misc, "INFO")

TK.mkBtn(misc, "📊 Print Game Info", function()
    print("══════════════════════════════")
    print("Game PlaceId: " .. game.PlaceId)
    print("GameId: " .. game.GameId)
    print("JobId: " .. game.JobId)
    print("Player: " .. lp.Name)
    print("UserId: " .. lp.UserId)
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        print("Game Name: " .. info.Name)
        print("Creator: " .. info.Creator.Name)
    end)
    pcall(function()
        print("Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
    end)
    pcall(function()
        local ls = lp:FindFirstChild("leaderstats")
        if ls then
            print("--- Leaderstats ---")
            for _, v in ipairs(ls:GetChildren()) do
                if v:IsA("ValueBase") then
                    print("  " .. v.Name .. " = " .. tostring(v.Value))
                end
            end
        end
    end)
    print("══════════════════════════════")
end)

TK.mkBtn(misc, "📡 Print All Remotes", function()
    print("══════════════════════════════")
    print("ALL REMOTES:")
    local count = 0
    for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        pcall(function()
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                count = count + 1
                print("  " .. count .. ". " .. d.Name .. " [" .. d.ClassName .. "] " .. d:GetFullName())
            end
        end)
    end
    print("Total: " .. count)
    print("══════════════════════════════")
end)

TK.mkBtn(misc, "📋 Copy Leaderstats", function()
    local lines = {"=== LEADERSTATS ==="}
    pcall(function()
        table.insert(lines, "Player: " .. lp.Name)
        table.insert(lines, "Game: " .. game.PlaceId)
        local ls = lp:FindFirstChild("leaderstats")
        if ls then
            for _, v in ipairs(ls:GetChildren()) do
                if v:IsA("ValueBase") then
                    table.insert(lines, v.Name .. " = " .. tostring(v.Value))
                end
            end
        end
        -- Tambem pegar Data folder se existir
        for _, folder in ipairs(lp:GetChildren()) do
            if folder:IsA("Folder") and folder.Name ~= "leaderstats" then
                for _, v in ipairs(folder:GetChildren()) do
                    if v:IsA("ValueBase") then
                        table.insert(lines, folder.Name .. "." .. v.Name .. " = " .. tostring(v.Value))
                    end
                end
            end
        end
    end)
    local text = table.concat(lines, "\n")
    local ok = false
    pcall(function() if setclipboard then setclipboard(text) ok = true end end)
    pcall(function() if not ok and toclipboard then toclipboard(text) ok = true end end)
    if ok then
        print("[MISC] Leaderstats copiados!")
    else
        print(text)
        print("[MISC] Clipboard nao disponivel — printado acima")
    end
end)

TK.mkBtn(misc, "📋 Copy All Player Data", function()
    local lines = {"=== FULL PLAYER DATA ==="}
    pcall(function()
        table.insert(lines, "Player: " .. lp.Name)
        for _, d in ipairs(lp:GetDescendants()) do
            pcall(function()
                if d:IsA("ValueBase") then
                    table.insert(lines, d:GetFullName() .. " = " .. tostring(d.Value))
                end
            end)
        end
        -- Attributes
        for k, v in pairs(lp:GetAttributes()) do
            table.insert(lines, "@" .. k .. " = " .. tostring(v))
        end
    end)
    local text = table.concat(lines, "\n")
    local ok = false
    pcall(function() if setclipboard then setclipboard(text) ok = true end end)
    pcall(function() if not ok and toclipboard then toclipboard(text) ok = true end end)
    if ok then
        print("[MISC] Player data copiado! (" .. #text .. " chars)")
    else
        print(text)
    end
end)

-- ══════════════════════════════════
-- DESTRUCTIVE (cuidado)
-- ══════════════════════════════════
TK.mkSec(misc, "DANGER ZONE")

TK.mkBtn(misc, "🗑 Remove Game GUIs", function()
    pcall(function()
        local count = 0
        for _, gui in ipairs(lp.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "YHMH" then
                gui.Enabled = false
                count = count + 1
            end
        end
        print("[MISC] " .. count .. " GUIs escondidas")
    end)
end)

TK.mkBtn(misc, "🔄 Restore Game GUIs", function()
    pcall(function()
        local count = 0
        for _, gui in ipairs(lp.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "YHMH" then
                gui.Enabled = true
                count = count + 1
            end
        end
        print("[MISC] " .. count .. " GUIs restauradas")
    end)
end)

-- ══════════════════════════════════
-- ANTI-AFK (sempre ativo)
-- ══════════════════════════════════
pcall(function()
    local VU = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
    print("[MISC] Anti-AFK ativo permanentemente")
end)

-- ══════════════════════════════════
-- CONTADOR DE FERRAMENTAS
-- ══════════════════════════════════
local totalTools = 0
for key, val in pairs(TK.ON) do
    if type(val) == "boolean" and not tostring(key):sub(1, 1) == "_" then
        totalTools = totalTools + 1
    end
end

print("[MISC] 15 ferramentas carregadas")
print("")
print("══════════════════════════════════")
print("  YHMH HUB — CARREGADO!")
print("  Toque no botao YH para abrir")
print("══════════════════════════════════")
