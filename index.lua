local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Criar a janela principal
local Window = Rayfield:CreateWindow({
    Name = "SISTEMA DE COMBATE V2",
    LoadingTitle = "Carregando Recursos Táticos...",
    LoadingSubtitle = "By ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TacticalConfig",
        FileName = "Settings"
    }
})

-- Criar as abas
local CombatTab = Window:CreateTab("COMBATE", 4483362458)
local PlayerTab = Window:CreateTab("PLAYER", 4483362458)
local TeleportTab = Window:CreateTab("TELEPORTE TÁTICO", 4483362458)

-- Configurações globais
local settings = {
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTransparency = 1,
    hitboxColor = Color3.fromRGB(255, 0, 0),
    noclipEnabled = false,
    teleportDistance = 7,
    backstabEnabled = false,
    followEnemyEnabled = false,
    espEnabled = true
}

-- Armazenamento para os sistemas
local originalProperties = {}
local appliedHeads = {}
local noclipConnection = nil
local teleportConnection = nil
local backstabConnection = nil
local followConnection = nil
local currentTarget = nil
local enemyEsp = {}

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
            local bots = workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("NPCs")
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

-- Função para obter inimigos
local function getEnemies()
    local enemies = {}
    
    -- Jogadores inimigos
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Verificar time
                if localPlayer.Character and localPlayer.Character:GetAttribute("Team") ~= nil and 
                   player.Character:GetAttribute("Team") ~= nil then
                    if localPlayer.Character:GetAttribute("Team") ~= player.Character:GetAttribute("Team") then
                        table.insert(enemies, player.Character)
                    end
                else
                    table.insert(enemies, player.Character)
                end
            end
        end
    end
    
    -- NPCs/Bots inimigos
    local bots = workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("NPCs")
    if bots then
        for _, npc in ipairs(bots:GetChildren()) do
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Verificar time
                if localPlayer.Character and localPlayer.Character:GetAttribute("Team") ~= nil and 
                   npc:GetAttribute("Team") ~= nil then
                    if localPlayer.Character:GetAttribute("Team") ~= npc:GetAttribute("Team") then
                        table.insert(enemies, npc)
                    end
                else
                    table.insert(enemies, npc)
                end
            end
        end
    end
    
    return enemies
end

-- Sistema de Backstab (teleporte para as costas)
local function setupBackstabSystem()
    if backstabConnection then
        backstabConnection:Disconnect()
        backstabConnection = nil
    end
    
    if settings.backstabEnabled then
        backstabConnection = RunService.Heartbeat:Connect(function()
            local enemies = getEnemies()
            if #enemies > 0 then
                local target = enemies[math.random(1, #enemies)]
                local rootPart = target:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    -- Calcular a posição atrás do alvo (2 unidades atrás)
                    local backPosition = rootPart.Position - (rootPart.CFrame.LookVector * 2)
                    -- Manter a mesma altura
                    backPosition = Vector3.new(backPosition.X, rootPart.Position.Y, backPosition.Z)
                    localPlayer.Character:MoveTo(backPosition)
                    -- Esperar um pouco antes do próximo teleporte
                    task.wait(1.5)
                end
            end
        end)
    end
end

-- Sistema de Follow (teleporte acima do inimigo)
local function setupFollowSystem()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
        currentTarget = nil
    end
    
    if settings.followEnemyEnabled then
        followConnection = RunService.Heartbeat:Connect(function()
            -- Se não temos alvo ou o alvo morreu, encontrar um novo
            if not currentTarget or not currentTarget.Parent or 
               (currentTarget:FindFirstChildOfClass("Humanoid") and currentTarget:FindFirstChildOfClass("Humanoid").Health <= 0) then
                
                local enemies = getEnemies()
                if #enemies > 0 then
                    currentTarget = enemies[math.random(1, #enemies)]
                    Rayfield:Notify({
                        Title = "Novo Alvo Selecionado",
                        Content = "Seguindo novo inimigo",
                        Duration = 2,
                        Image = 4483362458,
                    })
                else
                    currentTarget = nil
                    return
                end
            end
            
            -- Teleportar para 5 unidades acima e na frente do alvo
            if currentTarget and currentTarget.Parent then
                local rootPart = currentTarget:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local targetPosition = rootPart.Position + 
                                           (rootPart.CFrame.LookVector * 1) + 
                                           Vector3.new(0, 5, 0)
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                end
            end
        end)
    end
end

-- Sistema ESP para inimigos
local function setupEnemyESP()
    for _, obj in pairs(enemyEsp) do
        if obj then
            obj:Destroy()
        end
    end
    enemyEsp = {}
    
    if not settings.espEnabled then return end
    
    local function createESP(target, color)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = target
        table.insert(enemyEsp, highlight)
    end
    
    -- Atualizar ESP
    local function updateESP()
        for _, obj in pairs(enemyEsp) do
            obj:Destroy()
        end
        enemyEsp = {}
        
        local enemies = getEnemies()
        for _, enemy in ipairs(enemies) do
            createESP(enemy, Color3.new(1, 0, 0))  -- Vermelho para inimigos
        end
        
        -- Aliados (opcional)
        if localPlayer.Character and localPlayer.Character:GetAttribute("Team") then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:GetAttribute("Team") == localPlayer.Character:GetAttribute("Team") then
                    createESP(player.Character, Color3.new(0, 1, 0))  -- Verde para aliados
                end
            end
        end
    end
    
    -- Atualizar inicialmente
    updateESP()
    
    -- Atualizar quando novos personagens surgirem
    Players.PlayerAdded:Connect(updateESP)
    Players.PlayerRemoving:Connect(updateESP)
    workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
            task.wait(1)
            updateESP()
        end
    end)
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
    
    if backstabConnection then
        backstabConnection:Disconnect()
        backstabConnection = nil
    end
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    -- Limpar ESP
    for _, obj in pairs(enemyEsp) do
        if obj then
            obj:Destroy()
        end
    end
    enemyEsp = {}
    
    -- Resetar tabelas
    appliedHeads = {}
    originalProperties = {}
    currentTarget = nil
end

-- ===== INTERFACE DO USUÁRIO ===== --

-- Aba COMBATE
CombatTab:CreateSection("Configurações de Hitbox")

CombatTab:CreateToggle({
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

CombatTab:CreateSlider({
    Name = "Tamanho da Hitbox",
    Range = {7, 50},
    Increment = 1,
    Suffix = "unidades",
    CurrentValue = settings.hitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value)
        settings.hitboxSize = Value
    end,
})

CombatTab:CreateSlider({
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

CombatTab:CreateColorPicker({
    Name = "Cor da Hitbox",
    Color = settings.hitboxColor,
    Flag = "HitboxColor",
    Callback = function(Value)
        settings.hitboxColor = Value
    end
})

CombatTab:CreateSection("Visuais de Combate")

CombatTab:CreateToggle({
    Name = "Ativar ESP de Inimigos",
    CurrentValue = settings.espEnabled,
    Flag = "ESPToggle",
    Callback = function(Value)
        settings.espEnabled = Value
        setupEnemyESP()
    end
})

-- Aba PLAYER
PlayerTab:CreateSection("Movimentação")

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

PlayerTab:CreateToggle({
    Name = "Ativar Velocidade Aumentada",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        if Value then
            if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid.WalkSpeed = 32
            end
        else
            if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Altura do Salto",
    Range = {50, 150},
    Increment = 5,
    Suffix = "unidades",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Resetar Personagem",
    Callback = function()
        localPlayer.Character:BreakJoints()
    end
})

-- Aba TELEPORTE TÁTICO
TeleportTab:CreateSection("Teleporte de Cabeças")

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
    Suffix = "unidades",
    CurrentValue = settings.teleportDistance,
    Flag = "TeleportDistance",
    Callback = function(Value)
        settings.teleportDistance = Value
    end,
})

TeleportTab:CreateSection("Teleportes Táticos")

TeleportTab:CreateToggle({
    Name = "Teleportar para Costas de Inimigos",
    CurrentValue = settings.backstabEnabled,
    Flag = "BackstabToggle",
    Callback = function(Value)
        settings.backstabEnabled = Value
        if Value then
            -- Desativar outros sistemas de teleporte
            settings.followEnemyEnabled = false
            TeleportTab:UpdateToggle("FollowToggle", false)
            setupBackstabSystem()
        else
            if backstabConnection then
                backstabConnection:Disconnect()
            end
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Seguir Inimigo (5 unidades acima)",
    CurrentValue = settings.followEnemyEnabled,
    Flag = "FollowToggle",
    Callback = function(Value)
        settings.followEnemyEnabled = Value
        if Value then
            -- Desativar outros sistemas de teleporte
            settings.backstabEnabled = false
            TeleportTab:UpdateToggle("BackstabToggle", false)
            setupFollowSystem()
        else
            if followConnection then
                followConnection:Disconnect()
            end
            currentTarget = nil
        end
    end
})

TeleportTab:CreateDropdown({
    Name = "Prioridade de Alvo",
    Options = {"Mais Próximo", "Menos Vida", "Mais Fraco", "Aleatório"},
    CurrentOption = "Aleatório",
    Flag = "TargetPriority",
    Callback = function(Option)
        -- Implementação de prioridade
    end
})

TeleportTab:CreateKeybind({
    Name = "Teleporte Rápido (Flanquear)",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "FlankKey",
    Callback = function()
        local enemies = getEnemies()
        if #enemies > 0 then
            local target = enemies[math.random(1, #enemies)]
            local rootPart = target:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Calcular posição ao lado do inimigo
                local side = math.random() > 0.5 and 1 or -1
                local flankPosition = rootPart.Position + (rootPart.CFrame.RightVector * 5 * side)
                flankPosition = Vector3.new(flankPosition.X, rootPart.Position.Y, flankPosition.Z)
                localPlayer.Character:MoveTo(flankPosition)
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleportar para Inimigo Mais Próximo",
    Callback = function()
        local closestEnemy = nil
        local closestDistance = math.huge
        
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPosition = localPlayer.Character.HumanoidRootPart.Position
            
            for _, enemy in ipairs(getEnemies()) do
                local rootPart = enemy:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (myPosition - rootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end
            
            if closestEnemy then
                local rootPart = closestEnemy:FindFirstChild("HumanoidRootPart")
                localPlayer.Character:MoveTo(rootPart.Position)
            end
        end
    end
})

-- Botão de emergência
local EmergencySection = Window:CreateTab("EMERGÊNCIA", 4483362458)
EmergencySection:CreateSection("Controle Total")

EmergencySection:CreateButton({
    Name = "DESATIVAR TODOS OS SISTEMAS",
    Callback = function()
        cleanupSystems()
        settings.hitboxEnabled = false
        settings.noclipEnabled = false
        settings.teleportEnabled = false
        settings.backstabEnabled = false
        settings.followEnemyEnabled = false
        Rayfield:Notify({
            Title = "Todos os Sistemas Desativados",
            Content = "Recursos desligados com segurança",
            Duration = 5,
            Image = 4483362458,
        })
    end,
})

EmergencySection:CreateSection("Recuperação")

EmergencySection:CreateButton({
    Name = "Restaurar Configurações Padrão",
    Callback = function()
        -- Implementação de reset
    end
})

EmergencySection:CreateButton({
    Name = "Reiniciar Personagem",
    Callback = function()
        localPlayer.Character:BreakJoints()
    end
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
    setupEnemyESP()
end)

print("Sistema tático carregado com sucesso!")
