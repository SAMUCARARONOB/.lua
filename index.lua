local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Criar a janela principal
local Window = Rayfield:CreateWindow({
    Name = "Sistema Completo",
    LoadingTitle = "Carregando Recursos Avançados...",
    LoadingSubtitle = "By ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AdvancedConfig",
        FileName = "Settings"
    }
})

-- Criar as abas
local HitboxTab = Window:CreateTab("HITBOX HEAD", 4483362458)
local PlayerTab = Window:CreateTab("PLAYER", 4483362458)
local TeleportTab = Window:CreateTab("TELEPORTE", 4483362458)

-- Configurações globais
local settings = {
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTransparency = 1,
    hitboxColor = Color3.fromRGB(255, 0, 0),
    noclipEnabled = false,
    teleportDistance = 7
}

-- Armazenamento para os sistemas
local originalProperties = {}
local appliedHeads = {}
local noclipConnection = nil
local teleportConnection = nil

-- Função para aplicar a hitbox
local function applyHeadHitbox(head)
    if not head or appliedHeads[head] then return end
    
    -- Salvar propriedades originais
    originalProperties[head] = {
        Size = head.Size,
        Transparency = head.Transparency,
        CanCollide = head.CanCollide,
        Massless = head.Massless,
        BrickColor = head.BrickColor,
        Material = head.Material
    }
    
    -- Aplicar modificações
    head.Size = Vector3.new(settings.hitboxSize, settings.hitboxSize, settings.hitboxSize)
    head.CanCollide = false
    head.Massless = true
    head.Transparency = settings.hitboxTransparency
    head.BrickColor = BrickColor.new(settings.hitboxColor)
    head.Material = "Neon"
    
    appliedHeads[head] = true
end

-- Função para restaurar a hitbox
local function restoreHead(head)
    if originalProperties[head] then
        local props = originalProperties[head]
        head.Size = props.Size
        head.Transparency = props.Transparency
        head.CanCollide = props.CanCollide
        head.Massless = props.Massless
        head.BrickColor = props.BrickColor
        head.Material = props.Material
        appliedHeads[head] = nil
        originalProperties[head] = nil
    end
end

-- Sistema de detecção e aplicação de hitbox
local function setupHitboxSystem()
    -- Processar todos os humanoids existentes
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local head = model:FindFirstChild("Head")
            
            if humanoid and head then
                -- Ignorar jogador local
                if model == localPlayer.Character then
                    restoreHead(head)
                else
                    applyHeadHitbox(head)
                end
            end
        end
    end
    
    -- Monitorar novos humanoids
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            task.wait(0.1)  -- Esperar um pouco para garantir que os componentes sejam criados
            
            local humanoid = descendant:FindFirstChildOfClass("Humanoid")
            local head = descendant:FindFirstChild("Head")
            
            if humanoid and head then
                -- Ignorar jogador local
                if descendant == localPlayer.Character then
                    restoreHead(head)
                else
                    applyHeadHitbox(head)
                end
            end
        end
    end)
end

-- Sistema para manter a hitbox aplicada
local function maintainHitboxSystem()
    RunService.Heartbeat:Connect(function()
        if not settings.hitboxEnabled then return end
        
        -- Atualizar todas as cabeças com as novas configurações
        for head in pairs(appliedHeads) do
            if head and head.Parent then
                head.Size = Vector3.new(settings.hitboxSize, settings.hitboxSize, settings.hitboxSize)
                head.Transparency = settings.hitboxTransparency
                head.BrickColor = BrickColor.new(settings.hitboxColor)
            else
                appliedHeads[head] = nil
            end
        end
    end)
end

-- Sistema de noclip
local function setupNoclipSystem()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if settings.noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if localPlayer.Character then
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- Sistema de teleporte de cabeças
local function setupTeleportSystem()
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
    
    if settings.teleportEnabled then
        teleportConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            
            -- Teleportar cabeças de bots
            local bots = workspace:FindFirstChild("Mobs")
            if bots then
                for _, v in bots:GetChildren() do
                    if (localPlayer.Character and localPlayer.Character:GetAttribute("Team") ~= -1) and 
                       (v:GetAttribute("Team") == localPlayer.Character:GetAttribute("Team")) then
                        continue
                    end
                    
                    local head = v:FindFirstChild("Head")
                    if head then
                        head.CFrame = camera.CFrame + camera.CFrame.lookVector * settings.teleportDistance
                    end
                end
            end
            
            -- Teleportar cabeças de jogadores
            for _, v in Players:GetPlayers() do
                if v == localPlayer then continue end
                
                if (localPlayer.Character and localPlayer.Character:GetAttribute("Team") ~= -1) and 
                   (v.Character and v.Character:GetAttribute("Team") == localPlayer.Character:GetAttribute("Team")) then
                    continue
                end
                
                if v.Character then
                    local head = v.Character:FindFirstChild("Head")
                    if head then
                        head.CFrame = camera.CFrame + camera.CFrame.lookVector * settings.teleportDistance
                    end
                end
            end
        end)
    end
end

-- Função para limpar tudo
local function cleanupSystems()
    -- Limpar hitboxes
    for head in pairs(appliedHeads) do
        if head and head.Parent then
            restoreHead(head)
        end
    end
    
    -- Limpar conexões
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
    
    -- Resetar tabelas
    appliedHeads = {}
    originalProperties = {}
end

-- Elementos da interface para Hitbox Head
HitboxTab:CreateToggle({
    Name = "Ativar Hitbox Head",
    CurrentValue = settings.hitboxEnabled,
    Flag = "HitboxToggle",
    Callback = function(Value)
        settings.hitboxEnabled = Value
        if Value then
            setupHitboxSystem()
            maintainHitboxSystem()
            Rayfield:Notify({
                Title = "Hitbox Head Ativada",
                Content = "Todas as cabeças foram ampliadas",
                Duration = 3,
                Image = 4483362458,
            })
        else
            cleanupSystems()
            Rayfield:Notify({
                Title = "Hitbox Head Desativada",
                Content = "Todas as cabeças foram restauradas",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

HitboxTab:CreateSlider({
    Name = "Tamanho da Hitbox",
    Range = {7, 100},
    Increment = 1,
    Suffix = "unidades",
    CurrentValue = settings.hitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value)
        settings.hitboxSize = Value
    end,
})

HitboxTab:CreateSlider({
    Name = "Transparência da Hitbox",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = settings.hitboxTransparency,
    Flag = "HitboxTransparency",
    Callback = function(Value)
        settings.hitboxTransparency = Value
    end,
})

HitboxTab:CreateColorPicker({
    Name = "Cor da Hitbox",
    Color = settings.hitboxColor,
    Flag = "HitboxColor",
    Callback = function(Value)
        settings.hitboxColor = Value
    end
})

HitboxTab:CreateParagraph({
    Title = "Informações",
    Content = "Este sistema amplia a hitbox da cabeça de todos os humanoids (jogadores, bots, NPCs) para facilitar acertos."
})

-- Elementos da interface para Noclip
PlayerTab:CreateToggle({
    Name = "Ativar Noclip",
    CurrentValue = settings.noclipEnabled,
    Flag = "NoclipToggle",
    Callback = function(Value)
        settings.noclipEnabled = Value
        setupNoclipSystem()
        Rayfield:Notify({
            Title = Value and "Noclip Ativado" or "Noclip Desativado",
            Content = Value and "Você pode atravessar paredes" or "Colisão restaurada",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

PlayerTab:CreateParagraph({
    Title = "Funcionalidade Noclip",
    Content = "Permite que você atravesse paredes e outros objetos. Ative com cuidado!"
})

-- Elementos da interface para Teleporte de Cabeças
TeleportTab:CreateToggle({
    Name = "Teleportar Cabeças para Frente",
    CurrentValue = false,
    Flag = "TeleportToggle",
    Callback = function(Value)
        settings.teleportEnabled = Value
        setupTeleportSystem()
        Rayfield:Notify({
            Title = Value and "Teleporte Ativado" or "Teleporte Desativado",
            Content = Value and "Cabeças estão sendo teleportadas" or "Cabeças voltaram ao normal",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

TeleportTab:CreateSlider({
    Name = "Distância do Teleporte",
    Range = {1, 20},
    Increment = 1,
    Suffix = "estudos",
    CurrentValue = settings.teleportDistance,
    Flag = "TeleportDistance",
    Callback = function(Value)
        settings.teleportDistance = Value
    end,
})

TeleportTab:CreateParagraph({
    Title = "Aviso Importante",
    Content = "Este recurso é altamente visível para outros jogadores e pode levar a bans."
})

-- Botão de emergência
local EmergencySection = Window:CreateTab("EMERGÊNCIA", 4483362458)
EmergencySection:CreateButton({
    Name = "DESATIVAR TODOS OS SISTEMAS",
    Callback = function()
        cleanupSystems()
        settings.hitboxEnabled = false
        settings.noclipEnabled = false
        settings.teleportEnabled = false
        Rayfield:Notify({
            Title = "Todos os Sistemas Desativados",
            Content = "Recursos desligados com segurança",
            Duration = 5,
            Image = 4483362458,
        })
    end,
})

EmergencySection:CreateParagraph({
    Title = "Uso de Emergência",
    Content = "Clique neste botão se estiver enfrentando problemas ou para desligar tudo rapidamente."
})

-- Inicialização dos sistemas
task.spawn(function()
    setupHitboxSystem()
    maintainHitboxSystem()
    setupNoclipSystem()
end)

print("Sistema completo carregado com sucesso!")
