
-- Players, NPCs+Stats, Items, Player Stats, Chests

local TK = getgenv().TK
local lp = TK.lp
local Players = game:GetService("Players")
local WS = game:GetService("Workspace")

local esp = TK.tabs["ESP"]

-- ══════════════════════════════════
-- TOGGLES
-- ══════════════════════════════════

TK.mkSec(esp, "PLAYERS")
TK.mkTog(esp, "ESP Players", "espP")
TK.mkTog(esp, "ESP Player Stats", "espS")

TK.mkSec(esp, "WORLD")
TK.mkTog(esp, "ESP NPCs + HP", "espN")
TK.mkTog(esp, "ESP Items / Collectibles", "espI")
TK.mkTog(esp, "ESP Chests / Spawns", "espC")

TK.mkSec(esp, "VISUAL")

TK.mkTog(esp, "Fullbright", "fullbright", nil, function()
    pcall(function()
        local L = game:GetService("Lighting")
        L.Brightness = TK._origBright or 1
        L.Ambient = TK._origAmb or Color3.fromRGB(127, 127, 127)
        L.OutdoorAmbient = TK._origOAmb or Color3.fromRGB(127, 127, 127)
    end)
end)

TK.mkTog(esp, "Remove Fog", "noFog", nil, function()
    pcall(function()
        local L = game:GetService("Lighting")
        L.FogEnd = TK._origFogEnd or 100000
        L.FogStart = TK._origFogStart or 0
    end)
end)

TK.mkTog(esp, "FOV 120", "fov", nil, function()
    pcall(function()
        WS.CurrentCamera.FieldOfView = TK._origFOV or 70
    end)
end)

TK.mkTog(esp, "Invisible", "invis", nil, function()
    pcall(function()
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 0 end
            if p:IsA("Decal") and p.Name == "face" then p.Transparency = 0 end
        end
        pcall(function() lp.Character.Head.Transparency = 0 end)
    end)
end)

-- Salvar valores originais
pcall(function()
    local L = game:GetService("Lighting")
    TK._origBright = L.Brightness
    TK._origAmb = L.Ambient
    TK._origOAmb = L.OutdoorAmbient
    TK._origFogEnd = L.FogEnd
    TK._origFogStart = L.FogStart
    TK._origFOV = WS.CurrentCamera.FieldOfView
end)

-- ══════════════════════════════════
-- ESP FOLDER
-- ══════════════════════════════════
local espFolder = Instance.new("Folder")
espFolder.Name = "YHMH_ESP"
espFolder.Parent = WS.CurrentCamera

-- ══════════════════════════════════
-- HELPER: Criar highlight
-- ══════════════════════════════════
local function addHL(target, color, alpha)
    local hl = Instance.new("Highlight")
    hl.Adornee = target
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = alpha or 0.7
    hl.OutlineTransparency = 0.3
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espFolder
end

-- ══════════════════════════════════
-- HELPER: Criar billboard label
-- ══════════════════════════════════
local function addBB(target, text, color, yOffset)
    local bb = Instance.new("BillboardGui")
    bb.Adornee = target
    bb.Size = UDim2.new(0, 240, 0, 22)
    bb.StudsOffset = Vector3.new(0, yOffset or 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 0.35
    l.BackgroundColor3 = Color3.new(0, 0, 0)
    l.Text = text
    l.TextColor3 = color
    l.Font = Enum.Font.SourceSansBold
    l.TextScaled = true
    l.Parent = bb
end

-- ══════════════════════════════════
-- NPC STATS: coleta adaptativa
-- Procura ValueBase + Attributes com nomes de stats
-- ══════════════════════════════════
local STAT_KEYWORDS = {"power", "damage", "level", "strength", "str", "defense", "def", "attack", "atk", "speed", "spd", "hp", "mana", "energy", "rank", "tier", "rarity"}

local function getNPCStats(model)
    local stats = {}
    -- ValueBase children/descendants
    pcall(function()
        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("ValueBase") and type(v.Value) == "number" then
                local n = v.Name:lower()
                for _, kw in ipairs(STAT_KEYWORDS) do
                    if n:find(kw, 1, true) then
                        stats[v.Name] = v.Value
                        break
                    end
                end
            end
        end
    end)
    -- Attributes
    pcall(function()
        for k, v in pairs(model:GetAttributes()) do
            if type(v) == "number" then
                local n = k:lower()
                for _, kw in ipairs(STAT_KEYWORDS) do
                    if n:find(kw, 1, true) then
                        stats[k] = v
                        break
                    end
                end
            end
        end
    end)
    return stats
end

-- ══════════════════════════════════
-- ITEM KEYWORDS (50+)
-- ══════════════════════════════════
local ITEM_KEYWORDS = {
    "item", "collect", "coin", "gem", "orb", "shard", "chest",
    "crate", "loot", "drop", "star", "fruit", "key", "token",
    "crystal", "pickup", "meteor", "sunken", "reward", "bonus",
    "diamond", "ruby", "emerald", "pearl", "gold", "silver",
    "candy", "egg", "present", "gift", "prize", "treasure",
    "potion", "scroll", "rune", "fragment", "essence", "soul",
    "banana", "apple", "berry", "flower", "seed", "ore",
    "wood", "stone", "iron", "copper", "material", "resource",
}

local CHEST_KEYWORDS = {
    "chest", "crate", "box", "barrel", "vault", "safe",
    "spawn", "spawner", "npc", "quest", "shop", "merchant",
    "portal", "gate", "entrance", "exit", "warp", "teleport",
}

-- ══════════════════════════════════
-- ESP UPDATE LOOP
-- ══════════════════════════════════
task.spawn(function()
    while true do
        task.wait(2.5)

        -- Limpar ESP antiga
        for _, c in ipairs(espFolder:GetChildren()) do
            c:Destroy()
        end

        -- Posicao do jogador local
        local myPos = Vector3.zero
        pcall(function()
            myPos = lp.Character.HumanoidRootPart.Position
        end)

        -- ═══ ESP PLAYERS ═══
        if TK.ON.espP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    pcall(function()
                        addHL(p.Character, Color3.fromRGB(0, 150, 255))

                        local r = p.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local dist = math.floor((r.Position - myPos).Magnitude)
                            local hp = ""
                            pcall(function()
                                local h = p.Character:FindFirstChildOfClass("Humanoid")
                                if h then
                                    hp = " | " .. math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth) .. "HP"
                                end
                            end)
                            addBB(r, p.Name .. " [" .. dist .. "m]" .. hp, Color3.fromRGB(80, 200, 255))
                        end
                    end)
                end
            end
        end

        -- ═══ ESP PLAYER STATS (leaderstats adaptativos) ═══
        if TK.ON.espS then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    pcall(function()
                        local r = p.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local info = p.Name

                            -- Leaderstats
                            pcall(function()
                                local ls = p:FindFirstChild("leaderstats")
                                if ls then
                                    for _, v in ipairs(ls:GetChildren()) do
                                        if v:IsA("ValueBase") then
                                            info = info .. " | " .. v.Name .. ":" .. tostring(v.Value)
                                        end
                                    end
                                end
                            end)

                            -- Humanoid stats
                            pcall(function()
                                local h = p.Character:FindFirstChildOfClass("Humanoid")
                                if h then
                                    info = info .. " | WS:" .. math.floor(h.WalkSpeed)
                                    info = info .. " JP:" .. math.floor(h.JumpPower)
                                end
                            end)

                            -- Player attributes
                            pcall(function()
                                for k, v in pairs(p:GetAttributes()) do
                                    if type(v) == "number" then
                                        info = info .. " | " .. k .. ":" .. v
                                    end
                                end
                            end)

                            addBB(r, info, Color3.fromRGB(190, 170, 255), 4.5)
                        end
                    end)
                end
            end
        end

        -- ═══ ESP NPCs + STATS ADAPTATIVOS ═══
        if TK.ON.espN then
            for _, d in ipairs(WS:GetDescendants()) do
                pcall(function()
                    if d:IsA("Humanoid") and d.Parent and not Players:GetPlayerFromCharacter(d.Parent) then
                        addHL(d.Parent, Color3.fromRGB(255, 60, 60))

                        local root = d.Parent:FindFirstChild("HumanoidRootPart")
                            or d.Parent:FindFirstChild("Head")
                            or d.Parent:FindFirstChildWhichIsA("BasePart")

                        if root then
                            -- Info basica
                            local info = d.Parent.Name
                            info = info .. " HP:" .. math.floor(d.Health) .. "/" .. math.floor(d.MaxHealth)

                            -- Stats adaptativos
                            local stats = getNPCStats(d.Parent)
                            for k, v in pairs(stats) do
                                info = info .. " " .. k .. ":" .. v
                            end

                            -- Distancia
                            local dist = math.floor((root.Position - myPos).Magnitude)
                            info = info .. " [" .. dist .. "m]"

                            addBB(root, info, Color3.fromRGB(255, 100, 100))
                        end
                    end
                end)
            end
        end

        -- ═══ ESP ITEMS / COLLECTIBLES ═══
        if TK.ON.espI then
            for _, d in ipairs(WS:GetDescendants()) do
                pcall(function()
                    if d:IsA("BasePart") or d:IsA("Model") then
                        local n = d.Name:lower()
                        for _, kw in ipairs(ITEM_KEYWORDS) do
                            if n:find(kw, 1, true) then
                                addHL(d, Color3.fromRGB(255, 210, 40), 0.5)

                                -- Billboard com nome
                                local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local dist = math.floor((part.Position - myPos).Magnitude)
                                    addBB(part, d.Name .. " [" .. dist .. "m]", Color3.fromRGB(255, 230, 80), 2)
                                end
                                break
                            end
                        end
                    end
                end)
            end
        end

        -- ═══ ESP CHESTS / SPAWNS ═══
        if TK.ON.espC then
            for _, d in ipairs(WS:GetDescendants()) do
                pcall(function()
                    if d:IsA("BasePart") or d:IsA("Model") then
                        local n = d.Name:lower()
                        for _, kw in ipairs(CHEST_KEYWORDS) do
                            if n:find(kw, 1, true) then
                                addHL(d, Color3.fromRGB(50, 220, 120), 0.6)

                                local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local dist = math.floor((part.Position - myPos).Magnitude)
                                    addBB(part, d.Name .. " [" .. dist .. "m]", Color3.fromRGB(80, 240, 140), 2)
                                end
                                break
                            end
                        end
                    end
                end)
            end
        end

        -- ═══ FULLBRIGHT / FOG / FOV / INVISIBLE (visual loop) ═══
        pcall(function()
            local L = game:GetService("Lighting")
            if TK.ON.fullbright then
                L.Brightness = 2
                L.Ambient = Color3.fromRGB(200, 200, 200)
                L.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            end
            if TK.ON.noFog then
                L.FogEnd = 1e8
                L.FogStart = 1e8
                pcall(function()
                    for _, e in ipairs(L:GetDescendants()) do
                        if e:IsA("Atmosphere") then e.Density = 0 end
                    end
                end)
            end
            if TK.ON.fov then
                WS.CurrentCamera.FieldOfView = 120
            end
            if TK.ON.invis then
                for _, p in ipairs(lp.Character:GetDescendants()) do
                    pcall(function()
                        if p:IsA("BasePart") or p:IsA("Decal") then
                            p.Transparency = 1
                        end
                    end)
                end
            end
        end)
    end
end)

print("[ESP] 9 ferramentas carregadas")
