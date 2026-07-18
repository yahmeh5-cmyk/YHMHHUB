📋repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

-- YHMH HUB — Loader com auto-fix
-- Remove lixo do inicio dos arquivos automaticamente

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
    print("[YHMH] Baixando: " .. name)
    local ok, err = pcall(function()
        local code = game:HttpGet(url)
        
        -- AUTO-FIX: remover qualquer coisa antes do primeiro "--"
        local fixedCode = code
        local dashPos = code:find("%-%-")
        if dashPos and dashPos > 1 then
            fixedCode = code:sub(dashPos)
            print("[YHMH] Limpou " .. (dashPos - 1) .. " chars de lixo em " .. name)
        end
        
        -- Compilar e executar
        local fn, compileErr = loadstring(fixedCode)
        if fn then
            fn()
            print("[YHMH] OK: " .. name)
        else
            warn("[YHMH] Erro de compilacao em " .. name .. ": " .. tostring(compileErr))
        end
    end)
    if not ok then
        warn("[YHMH] Erro ao baixar " .. name .. ": " .. tostring(err))
    end
    task.wait(0.3)
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
print("[YHMH] HUB carregado!")
print("[YHMH] ========================")
