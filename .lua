local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 350)
frame.Position = UDim2.new(0.25, -225, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Transformador de Texto"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.Parent = titleBar

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(0.2, 0, 1, 0)
sizeLabel.Position = UDim2.new(0.6, 0, 0, 0)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "TAMANHO PIXELS INTERFACE"
sizeLabel.TextColor3 = Color3.new(1, 1, 1)
sizeLabel.Font = Enum.Font.SourceSans
sizeLabel.TextSize = 14
sizeLabel.Parent = titleBar

local sizeTextBox = Instance.new("TextBox")
sizeTextBox.Size = UDim2.new(0.2, 0, 1, 0)
sizeTextBox.Position = UDim2.new(0.8, 0, 0, 0)
sizeTextBox.BackgroundTransparency = 0.5
sizeTextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
sizeTextBox.TextColor3 = Color3.new(1, 1, 1)
sizeTextBox.Text = "450/350"
sizeTextBox.Font = Enum.Font.SourceSans
sizeTextBox.TextSize = 14
sizeTextBox.ClearTextOnFocus = true
sizeTextBox.Parent = titleBar

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(1, -20, 1, -60)
scriptBox.Position = UDim2.new(0, 10, 0, 50)
scriptBox.BackgroundTransparency = 0.5
scriptBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
scriptBox.TextColor3 = Color3.new(1, 1, 1)
scriptBox.TextWrapped = true
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.Text = "-- Escreva seu texto aqui"
scriptBox.Font = Enum.Font.SourceSans
scriptBox.TextSize = 14
scriptBox.ClearTextOnFocus = false
scriptBox.MultiLine = true
scriptBox.Parent = frame

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.new(1, -20, 0, 30)
runButton.Position = UDim2.new(0, 10, 1, -40)
runButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
runButton.TextColor3 = Color3.new(1, 1, 1)
runButton.Text = "Transformar Texto"
runButton.Font = Enum.Font.SourceSansBold
runButton.TextSize = 18
runButton.Parent = frame

local outputFrame = Instance.new("Frame")
outputFrame.Size = UDim2.new(0, 450, 0, 350)
outputFrame.Position = UDim2.new(1, 0, 0, 0)
outputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
outputFrame.BorderSizePixel = 0
outputFrame.Parent = frame

local outputTitleBar = Instance.new("Frame")
outputTitleBar.Size = UDim2.new(1, 0, 0, 40)
outputTitleBar.Position = UDim2.new(0, 0, 0, 0)
outputTitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
outputTitleBar.BorderSizePixel = 0
outputTitleBar.Parent = outputFrame

local outputTitleLabel = Instance.new("TextLabel")
outputTitleLabel.Size = UDim2.new(1, 0, 1, 0)
outputTitleLabel.Position = UDim2.new(0, 0, 0, 0)
outputTitleLabel.BackgroundTransparency = 1
outputTitleLabel.Text = "Texto Transformado"
outputTitleLabel.TextColor3 = Color3.new(1, 1, 1)
outputTitleLabel.Font = Enum.Font.SourceSansBold
outputTitleLabel.TextSize = 24
outputTitleLabel.Parent = outputTitleBar

local outputScrollFrame = Instance.new("ScrollingFrame")
outputScrollFrame.Size = UDim2.new(1, -10, 1, -90)
outputScrollFrame.Position = UDim2.new(0, 5, 0, 45)
outputScrollFrame.CanvasSize = UDim2.new(0, 0, 1, 0)
outputScrollFrame.ScrollBarThickness = 10
outputScrollFrame.BackgroundTransparency = 0.5
outputScrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
outputScrollFrame.Parent = outputFrame

local outputTextLabel = Instance.new("TextLabel")
outputTextLabel.Size = UDim2.new(1, -10, 1, -10)
outputTextLabel.Position = UDim2.new(0, 5, 0, 5)
outputTextLabel.BackgroundTransparency = 1
outputTextLabel.TextColor3 = Color3.new(1, 1, 1)
outputTextLabel.TextWrapped = true
outputTextLabel.Font = Enum.Font.SourceSans
outputTextLabel.TextSize = 14
outputTextLabel.TextXAlignment = Enum.TextXAlignment.Left
outputTextLabel.TextYAlignment = Enum.TextYAlignment.Top
outputTextLabel.Text = ""
outputTextLabel.Parent = outputScrollFrame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(1, -20, 0, 30)
copyButton.Position = UDim2.new(0, 10, 1, -40)
copyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.Text = "Copiar Texto Transformado"
copyButton.Font = Enum.Font.SourceSansBold
copyButton.TextSize = 18
copyButton.Parent = outputFrame

local function isSingleLine(text)
    return not text:find("\n")
end

scriptBox:GetPropertyChangedSignal("Text"):Connect(function()
    originalText = scriptBox.Text
    outputTextLabel.Text = scriptBox.Text
    outputScrollFrame.CanvasSize = UDim2.new(0, outputTextLabel.TextBounds.X, 0, outputTextLabel.TextBounds.Y)
end)

local function transformToSingleLine(text)
    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        line = line:gsub("%-%-.*", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if #line > 0 then
            table.insert(lines, line)
        end
    end
    return table.concat(lines, " "):gsub("%s+", " ")
end

local function transformToMultiLine(text)
    local formattedText = text
        :gsub("([;{}])", "%1\n")
        :gsub("%s*%(", " (")
        :gsub("\n%s*", "\n")
        :gsub("%)\n", ")\n\n")
        :gsub("([^\n;{}])%s*\n%s*([^\n;{}])", "%1 %2")
  
    formattedText = formattedText
        :gsub("(\n+)", "\n")
        :gsub("(%f[%w_]do%f[%W])", "\ndo")
        :gsub("(%f[%w_]end%f[%W])", "end\n")
        :gsub("(%f[%w_]then%f[%W])", "then\n")
        :gsub("(%f[%w_]function%f[%W])", "\nfunction")
        :gsub("(%f[%w_]local%f[%W])", "\nlocal")
        :gsub("(%f[%w_]if%f[%W])", "\nif")
        :gsub("(%f[%w_]elseif%f[%W])", "\nelseif")
        :gsub("(%f[%w_]else%f[%W])", "\nelse")

    formattedText = formattedText:gsub("(\n+)", "\n")

    return formattedText
end

runButton.MouseButton1Click:Connect(function()
    local text = scriptBox.Text
    if isSingleLine(text) then
        outputTextLabel.Text = transformToMultiLine(text)
    else
        outputTextLabel.Text = transformToSingleLine(text)
    end
    outputScrollFrame.CanvasSize = UDim2.new(0, outputTextLabel.TextBounds.X, 0, outputTextLabel.TextBounds.Y)
end)

copyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(outputTextLabel.Text)
        print("Texto copiado: " .. outputTextLabel.Text)
    else
        warn("Função de copiar para a área de transferência não suportada.")
    end
end)

revertButton.MouseButton1Click:Connect(function()
    outputTextLabel.Text = originalText
    outputScrollFrame.CanvasSize = UDim2.new(0, outputTextLabel.TextBounds.X, 0, outputTextLabel.TextBounds.Y)
end)
