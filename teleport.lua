📋 Copiar-- YHMH HUB — Teleport
-- 11 ferramentas de teleporte + slider de distancia

local TK = getgenv().TK
local lp = TK.lp
local Players = game:GetService("Players")
local WS = game:GetService("Workspace")
local TSvc = game:GetService("TeleportService")

local tp = TK.tabs["TP"]

-- Posicao salva
TK.ON._savedPos = nil

-- Helper: pegar HRP seguro
local function getHRP()
    local ch = lp.Character
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart")
end

-- ══════════════════════════════════
-- PLAYER TELEPORTS
-- ══════════════════════════════════
TK.mkSec(tp, "PLAYERS")

TK.mkBtn(tp, "📍 TP Closest Player", function()
    local hrp = getHRP()
    if not hrp then return end
    local best = nil
    local bestDist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - hrp.Position).Magnitude
                if d < bestDist then
                    best = r
                    bestDist = d
                end
            end
        end
    end
    if best then
        hrp.CFrame = best.CFrame * CFrame.new(0, 0, 4)
        print("[TP] -> Player a " .. math.floor(bestDist) .. "m")
    end
end)

TK.mkBtn(tp, "🎲 TP Random Player", function()
    local hrp = getHRP()
    if not hrp then return end
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                table.insert(targets, {name = p.Name, hrp = r})
            end
        end
    end
    if #targets > 0 then
        local t = targets[math.random(#targets)]
        hrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 4)
        print("[TP] -> " .. t.name)
    end
end)

TK.mkBtn(tp, "🥷 TP Behind Closest Player", function()
    local hrp = getHRP()
    if not hrp then return end
    local best = nil
    local bestDist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - hrp.Position).Magnitude
                if d < bestDist then
                    best = r
                    bestDist = d
                end
            end
        end
    end
    if best then
        -- Aparecer ATRAS (offset negativo no Z do CFrame do alvo)
        hrp.CFrame = best.CFrame * CFrame.new(0, 0, -5)
        print("[TP] -> Atras do player")
    end
end)

-- ══════════════════════════════════
-- WORLD TELEPORTS
-- ══════════════════════════════════
TK.mkSec(tp, "WORLD")

TK.mkBtn(tp, "🏠 TP to Spawn", function()
    local hrp = getHRP()
    if not hrp then return end
    for _, p in ipairs(WS:GetDescendants()) do
        pcall(function()
            if p:IsA("SpawnLocation") then
                hrp.CFrame = p.CFrame + Vector3.new(0, 5, 0)
                print("[TP] -> Spawn")
            end
        end)
    end
end)

TK.mkBtn(tp, "🏔 TP Highest Point", function()
    local hrp = getHRP()
    if not hrp then return end
    local highest = hrp.Position.Y
    local target = hrp.CFrame
    for _, p in ipairs(WS:GetDescendants()) do
        pcall(function()
            if p:IsA("BasePart") and p.Anchored and p.Size.Magnitude > 3 and p.Position.Y > highest then
                highest = p.Position.Y
                target = p.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
    hrp.CFrame = target
    print("[TP] -> Y=" .. math.floor(highest))
end)

TK.mkBtn(tp, "🤖 TP to Nearest NPC", function()
    local hrp = getHRP()
    if not hrp then return end
    local best = nil
    local bestDist = math.huge
    for _, d in ipairs(WS:GetDescendants()) do
        pcall(function()
            if d:IsA("Humanoid") and d.Parent and not Players:GetPlayerFromCharacter(d.Parent) then
                local root = d.Parent:FindFirstChild("HumanoidRootPart")
                    or d.Parent:FindFirstChild("Head")
                    or d.Parent:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < bestDist then
                        best = root
                        bestDist = dist
                    end
                end
            end
        end)
    end
    if best then
        hrp.CFrame = best.CFrame * CFrame.new(0, 0, 4)
        print("[TP] -> NPC a " .. math.floor(bestDist) .. "m")
    end
end)

TK.mkBtn(tp, "💎 TP to Nearest Item", function()
    local hrp = getHRP()
    if not hrp then return end
    local itemKW = {"item", "collect", "coin", "gem", "orb", "shard", "chest",
        "crate", "loot", "drop", "star", "fruit", "key", "token", "crystal",
        "pickup", "meteor", "diamond", "gold", "reward", "banana", "sunken"}
    local best = nil
    local bestDist = math.huge
    local bestName = ""
    for _, d in ipairs(WS:GetDescendants()) do
        pcall(function()
            if d:IsA("BasePart") or d:IsA("Model") then
                local n = d.Name:lower()
                for _, kw in ipairs(itemKW) do
                    if n:find(kw, 1, true) then
                        local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = (part.Position - hrp.Position).Magnitude
                            if dist < bestDist then
                                best = part
                                bestDist = dist
                                bestName = d.Name
                            end
                        end
                        break
                    end
                end
            end
        end)
    end
    if best then
        hrp.CFrame = best.CFrame + Vector3.new(0, 3, 0)
        print("[TP] -> " .. bestName .. " a " .. math.floor(bestDist) .. "m")
    end
end)

-- ══════════════════════════════════
-- DIRECTIONAL TELEPORTS
-- ══════════════════════════════════
TK.mkSec(tp, "DIRECTIONAL")

TK.mkSlider(tp, "Distance", "tp", 10, 500, 25)

TK.mkBtn(tp, "➡️ TP Forward", function()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -TK.V.tp)
        print("[TP] Forward " .. TK.V.tp .. " studs")
    end
end)

TK.mkBtn(tp, "⬅️ TP Backward", function()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, TK.V.tp)
        print("[TP] Backward " .. TK.V.tp .. " studs")
    end
end)

TK.mkBtn(tp, "⬆️ TP Up", function()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, TK.V.tp, 0)
        print("[TP] Up " .. TK.V.tp .. " studs")
    end
end)

TK.mkBtn(tp, "⬇️ TP Down", function()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, -TK.V.tp, 0)
        print("[TP] Down " .. TK.V.tp .. " studs")
    end
end)

-- ══════════════════════════════════
-- SAVE / LOAD POSITION
-- ══════════════════════════════════
TK.mkSec(tp, "WAYPOINT")

TK.mkBtn(tp, "💾 Save Position", function()
    local hrp = getHRP()
    if hrp then
        TK.ON._savedPos = hrp.CFrame
        print("[TP] Posicao salva: " .. tostring(hrp.Position))
    end
end)

TK.mkBtn(tp, "📌 Load Position", function()
    local hrp = getHRP()
    if hrp and TK.ON._savedPos then
        hrp.CFrame = TK.ON._savedPos
        print("[TP] Posicao carregada")
    else
        print("[TP] Nenhuma posicao salva")
    end
end)

-- ══════════════════════════════════
-- SERVER
-- ══════════════════════════════════
TK.mkSec(tp, "SERVER")

TK.mkBtn(tp, "🔄 Rejoin Server", function()
    pcall(function()
        TSvc:Teleport(game.PlaceId, lp)
    end)
end)

TK.mkBtn(tp, "🌐 Server Hop", function()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=10"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        if data and data.data then
            for _, sv in ipairs(data.data) do
                if sv.playing and sv.maxPlayers and sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                    TSvc:TeleportToPlaceInstance(game.PlaceId, sv.id, lp)
                    print("[TP] Hopping para server com " .. sv.playing .. " players")
                    return
                end
            end
        end
        print("[TP] Nenhum server encontrado")
    end)
end)

print("[TELEPORT] 14 ferramentas carregadas")
