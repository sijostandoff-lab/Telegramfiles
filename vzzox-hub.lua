local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Создаем главное хранилище UI
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старый UI, если перезапускаем скрипт
if playerGui:FindFirstChild("VzzoxUI") then
    playerGui.VzzoxUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzzoxUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- --- ГЛАВНОЕ ОКНО ---
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22) -- Глубокий темный цвет
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
-- Стартовый размер для анимации (с 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Закругление краев
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Неоновая обводка (UIStroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(90, 100, 255) -- Сине-фиолетовый неон
UIStroke.Thickness = 2
UIStroke.Transparency = 1 -- Скрыто до анимации
UIStroke.Parent = MainFrame

-- --- ВЕРХНЯЯ ПАНЕЛЬ (ЗАГОЛОВОК) ---
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Size = UDim2.new(1, -40, 0, 50)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "VZZOX HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextTransparency = 1 -- Скрыто до анимации
TitleLabel.Parent = MainFrame

-- Разделительная линия
local Line = Instance.new("Frame")
Line.BackgroundColor3 = Color3.fromRGB(90, 100, 255)
Line.BorderSizePixel = 0
Line.Position = UDim2.new(0, 0, 0, 50)
Line.Size = UDim2.new(1, 0, 0, 2)
Line.BackgroundTransparency = 1 -- Скрыто до анимации
Line.Parent = MainFrame

-- --- КОНТЕЙНЕР ДЛЯ КНОПОК (СКРИПТОВ) ---
local ScriptsContainer = Instance.new("ScrollingFrame")
ScriptsContainer.BackgroundTransparency = 1
ScriptsContainer.Position = UDim2.new(0, 10, 0, 60)
ScriptsContainer.Size = UDim2.new(1, -20, 1, -70)
ScriptsContainer.ScrollBarThickness = 4
ScriptsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScriptsContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScriptsContainer

-- --- ФУНКЦИЯ СОЗДАНИЯ АНИМИРОВАННЫХ КНОПОК ---
local function CreateButton(name)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 16
    Button.AutoButtonColor = false -- Отключаем стандартный цвет нажатия, чтобы сделать свой
    Button.Parent = ScriptsContainer

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    BtnStroke.Color = Color3.fromRGB(90, 100, 255)
    BtnStroke.Transparency = 1
    BtnStroke.Parent = Button

    -- Анимации наведения
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0.2}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            TextColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    end)
    
    -- Анимация клика (эффект вдавливания)
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -14, 0, 41)}):Play()
    end)
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 45)}):Play()
        print("Запущен скрипт: " .. name) -- Сюда потом вставишь логику скрипта
    end)

    -- Увеличиваем зону скроллинга при добавлении кнопок
    ScriptsContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- Создаем пару кнопок для примера
CreateButton("✨ Visual ESP (Тест)")
CreateButton("🚀 Fly (Тест)")
CreateButton("⚡ Speed Boost (Тест)")

-- --- АНИМАЦИЯ ПОЯВЛЕНИЯ (OPEN TWEENS) ---
local tweenInfoBounce = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfoFade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Пружинистое открытие окна
TweenService:Create(MainFrame, tweenInfoBounce, {Size = UDim2.new(0, 450, 0, 350)}):Play()

-- Плавное появление текста и обводки (с небольшой задержкой)
task.wait(0.2)
TweenService:Create(UIStroke, tweenInfoFade, {Transparency = 0}):Play()
TweenService:Create(TitleLabel, tweenInfoFade, {TextTransparency = 0}):Play()
TweenService:Create(Line, tweenInfoFade, {BackgroundTransparency = 0.3}):Play()
