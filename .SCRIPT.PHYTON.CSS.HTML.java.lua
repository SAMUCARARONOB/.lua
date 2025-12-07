local HttpService = game:GetService("HttpService")
local parts = {104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,83,65,77,85,67,65,82,65,82,79,78,79,66,47,48,45,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,82,65,78,79,88,95,73,78,84,69,70,65,82,67,69}
local function assembleURL(t)
    local s="" for _,v in ipairs(t) do s=s..string.char(v) end return s
end
local RANOX = loadstring(game:HttpGet(assembleURL(parts)))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer

----------------------------------------------------
-------------- JANELA PRINCIPAL --------------------
----------------------------------------------------

local Window = RANOX:CreateWindow({
    Title = "+1 speed per step⚡️",
    Subtitle = "AUTO FARM SYSTEM v1.  RANOX_OFC CHANEL"
})

Window:CreateTab("PRINCIPAL", 4483362458)
Window:CreateTab("CONFIGURAÇÃO", 4483362458)

----------------------------------------------------
----------------- VARIÁVEIS ------------------------
----------------------------------------------------

local zonaNumero = 11
local autoTrofeu = false
local autoVel = false
local applySpeed = false
local applyJump = false
local noclipEnabled = false
local gravMod = false
local gravValue = 196.2
local originalGravity = workspace.Gravity
local infJump = false

local antiAFK = false
local autoRejoin = false
local antiLag = false

local speedValue = 16
local jumpValue = 16

----------------------------------------------------
---------------- AUTO TROFÉU -----------------------
----------------------------------------------------

task.spawn(function()
    while true do
        if autoTrofeu then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local success, touchPart = pcall(function()
                    return workspace.Map.Zones[tostring(zonaNumero)].WinPart.Touch
                end)
                if success and touchPart then
                    firetouchinterest(hrp, touchPart, 0)
                    task.wait()
                    firetouchinterest(hrp, touchPart, 1)
                end
            end
        end
        task.wait(0.15)
    end
end)

----------------------------------------------------
--------------------- GUI PRINCIPAL ----------------
----------------------------------------------------

Window:CreateLabel("PRINCIPAL", "AUTO FARM ✨️")

Window:CreateToggle("PRINCIPAL", {
    Text = "GANHAR TROFÉU 🏆",
    Callback = function(s) autoTrofeu = s end
})

Window:CreateTextBox("PRINCIPAL", "NÚMERO DA ZONA 🔢", function(t)
    local n = tonumber(t)
    if n then zonaNumero = n end
end)

Window:CreateLabel("PRINCIPAL", "⚡ VELOCIDADE ⚡")

Window:CreateToggle("PRINCIPAL", {
    Text = "AUTO VELOCIDADE ⚡",
    Callback = function(s) autoVel = s end
})

task.spawn(function()
    while true do
        if autoVel then
            pcall(function()
                game.ReplicatedStorage.Remotes.Level.Treadmilling:FireServer(true, 999e999)
            end)
        end
        task.wait(0.2)
    end
end)

Window:CreateSlider("PRINCIPAL", {
    Text = "VELOCIDADE 🚀",
    Min = 16, Max = 9999, Default = 16,
    Callback = function(v) speedValue = v end
})

Window:CreateToggle("PRINCIPAL", {
    Text = "ATIVAR VELOCIDADE 🎯",
    Callback = function(s) applySpeed = s end
})

task.spawn(function()
    while true do
        if applySpeed then
            local char = plr.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.WalkSpeed = speedValue end
        end
        task.wait(0.1)
    end
end)

Window:CreateSlider("PRINCIPAL", {
    Text = "PULO 🦘",
    Min = 16, Max = 9999, Default = 16,
    Callback = function(v) jumpValue = v end
})

Window:CreateToggle("PRINCIPAL", {
    Text = "PULO PERSONALIZADO 🌙",
    Callback = function(s) applyJump = s end
})

task.spawn(function()
    while true do
        if applyJump then
            local char = plr.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.JumpPower = jumpValue end
        end
        task.wait(0.1)
    end
end)

Window:CreateLabel("PRINCIPAL", "EXTRA OPÇÕES 🎁")

Window:CreateToggle("PRINCIPAL", {
    Text = "NOCLIP 👻",
    Callback = function(s)
        noclipEnabled = s
        if not s and plr.Character then
            for _, v in ipairs(plr.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
})

RunService.Stepped:Connect(function()
    if noclipEnabled and plr.Character then
        for _, v in ipairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

Window:CreateToggle("PRINCIPAL", {
    Text = "GRAVIDADE MODIFICADA 🌎",
    Callback = function(s)
        gravMod = s
        if not s then workspace.Gravity = originalGravity end
    end
})

Window:CreateTextBox("PRINCIPAL", "VALOR DA GRAVIDADE 🌐", function(t)
    local n = tonumber(t)
    if n then gravValue = n end
end)

task.spawn(function()
    while true do
        if gravMod then workspace.Gravity = gravValue end
        task.wait(0.1)
    end
end)

Window:CreateToggle("PRINCIPAL", {
    Text = "INFINITE JUMP ♾️",
    Callback = function(s) infJump = s end
})

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

----------------------------------------------------
--------------------- CONFIGURAÇÃO -----------------
----------------------------------------------------

Window:CreateLabel("CONFIGURAÇÃO", "SISTEMA ⚙️")

----------------------------------------------------
-- ANT AFK
----------------------------------------------------

Window:CreateToggle("CONFIGURAÇÃO", {
    Text = "ANT AFK 🔄",
    Callback = function(s)
        antiAFK = s
    end
})

task.spawn(function()
    while true do
        if antiAFK then
            local char = plr.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum:Move(Vector3.new(0,0,-1), true)
                task.wait(0.2)

                task.wait(3)

                hum:Move(Vector3.new(0,0,1), true)
                task.wait(0.2)
            end
        end
        task.wait(0.2)
    end
end)

----------------------------------------------------
-- AUTO REJOIN
----------------------------------------------------

Window:CreateToggle("CONFIGURAÇÃO", {
    Text = "AUTO REJOIN 🔁",
    Callback = function(s) autoRejoin = s end
})

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Failed and autoRejoin then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

----------------------------------------------------
-- RESETAR TUDO
----------------------------------------------------

Window:CreateToggle("CONFIGURAÇÃO", {
    Text = "RESETAR TODAS FUNÇÕES 🧹",
    Callback = function(s)
        if s then
            autoTrofeu = false
            autoVel = false
            applySpeed = false
            applyJump = false
            noclipEnabled = false
            gravMod = false
            infJump = false
            antiAFK = false
            workspace.Gravity = originalGravity

            speedValue = 16
            jumpValue = 16
        end
    end
})

----------------------------------------------------
-- ANTI LAG
----------------------------------------------------

Window:CreateToggle("CONFIGURAÇÃO", {
    Text = "MODO ANTI LAG 🚫🔥",
    Callback = function(s)
        antiLag = s
        if s then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") 
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Explosion")
                or obj:IsA("Beam") then
                    obj.Enabled = false
                end
            end
        end
    end
})

----------------------------------------------------
-- THEME BOXES
----------------------------------------------------

Window:CreateLabel("CONFIGURAÇÃO", "THEMES 🎨")
Window:CreateThemeBoxes("CONFIGURAÇÃO")
