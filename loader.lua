
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/yahmeh5-cmyk/YHMHHUB/main/loader.lua"))()

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local BASE = "https://raw.githubusercontent.com/yahmeh5-cmyk/YHMHHUB/main/"


if not getgenv then
    getgenv = function() return _G end
end

getgenv().TK = {
    ON = {},
    V = {speed = 50, fly = 60, jump = 120, tp = 100},
    lp = game:GetService("Players").LocalPlayer,
}

local function load(name)
    local url = BASE .. name
    print("[YHMH] Carregando: " .. name)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if ok then
        print("[YHMH] OK: " .. name)
    else
        warn("[YHMH] ERRO em " .. name .. ": " .. tostring(err))
    end
    task.wait(0.2)
end

print("[YHMH] ========================")
print("[YHMH] YHMH HUB — Carregando...")
print("[YHMH] ========================")

load("gui.lua")
load("movement.lua")
load("esp.lua")
load("defense.lua")
load("teleport.lua")
load("misc.lua")

print("[YHMH] ========================")
print("[YHMH] HUB carregado! Toque TK")
print("[YHMH] ========================")
