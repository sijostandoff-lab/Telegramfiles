local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Удаляем старый UI если есть
local oldUI = LP.PlayerGui:FindFirstChild("VzzoxEngine")
if oldUI then oldUI:Destroy() end
if workspace:FindFirstChild("UI_BlurPart") then workspace.UI_BlurPart:Destroy() end

-- ==========================================
-- КОНФИГУРАЦИЯ СТИЛЯ
-- ==========================================
local Theme = {
	Backdrop = Color3.fromRGB(10, 10, 12), -- Фон
	Glass = Color3.fromRGB(20, 20, 25),    -- Цвет стекла
	Accent = Color3.fromRGB(0, 162, 255),  -- Акцент (Neon Blue)
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(150, 150, 150),
	Corner = UDim.new(0, 16),
}

-- ==========================================
-- ЯДРО АНИМАЦИЙ (SPRING PHYSICS)
-- ==========================================
-- Функция пружины для плавности без использования TweenInfo
local function Spring(t, damping, frequency)
	if t == 0 or t == 1 then return t end
	local p = frequency
	local s = p / (2 * math.pi) * math.asin(1)
	return (math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1)
end

-- Плавная интерполяция значений
local function Lerp(a, b, t)
	return a + (b - a) * t
end

-- Custom Lerp для UDim2 (чтобы окно двигалось физично)
local function LerpUDim2(a, b, t)
	return UDim2.new(
		Lerp(a.X.Scale, b.X.Scale, t),
		Lerp(a.X.Offset, b.X.Offset, t),
		Lerp(a.Y.Scale, b.Y.Scale, t),
		Lerp(a.Y.Offset, b.Y.Offset, t)
	)
end

-- ==========================================
-- СОЗДАНИЕ CORE UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzzoxEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Пытаемся засунуть в CoreGui, если нет прав - в PlayerGui
local successCore, errCore = pcall(function() ScreenGui.Parent = CoreGui end)
if not successCore then ScreenGui.Parent = LP.PlayerGui end

-- Симуляция размытия (создаем деталь перед камерой)
-- Это хак, но он дает эффект Glassmorphism
local BlurPart = Instance.new("Part")
BlurPart.Name = "UI_BlurPart"
BlurPart.Material = Enum.Material.Neon
BlurPart.Color = Color3.new(0,0,0)
BlurPart.Transparency = 1 -- Скрыт, но влияет на рендер
BlurPart.CanCollide = false
BlurPart.Size = Vector3.new(1, 1, 1)
BlurPart.Parent = workspace

local DepthOfField = Instance.new("DepthOfFieldEffect")
DepthOfField.FarIntensity = 0
DepthOfField.FocusDistance = 0
DepthOfField.InFocusRadius = 0
DepthOfField.NearIntensity = 1 -- Включаем легкое размытие
DepthOfField.Parent = game.Lighting

-- Тень окна
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Size = UDim2.new(0, 0, 0, 0) -- Начинаем с 0 для анимации
Shadow.Image = "rbxassetid://1316045217" -- Кастомная текстура тени
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 1
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = ScreenGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Theme.Glass
MainFrame.BackgroundTransparency = 0.1 -- Эффект стекла
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(1, 0, 1, 0) -- Занимает всю тень
MainFrame.Parent = Shadow

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = Theme.Corner
UICorner.Parent = MainFrame

-- Обводка (Glow)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.new(1,1,1)
UIStroke.Transparency = 0.9
UIStroke.Parent = MainFrame

-- Градиент для блеска
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150,150,150)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- ==========================================
-- КОМПОНЕНТЫ (HEADER & CONTENT)
-- ==========================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "VZZOX // CORE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.BackgroundTransparency = 1
Title.Parent = Header

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 10, 0, 60)
Content.Size = UDim2.new(1, -20, 1, -70)
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Theme.Accent
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Content

-- ==========================================
-- ЭФФЕКТЫ: RIPPLE (ВОЛНА)
-- ==========================================
local function SpawnRipple(button, x, y)
	local Ripple = Instance.new("ImageLabel")
	Ripple.Name = "Ripple"
	Ripple.BackgroundTransparency = 1
	Ripple.Image = "rbxassetid://270245673" -- Белый круг
	Ripple.ImageColor3 = Color3.new(1,1,1)
	Ripple.ImageTransparency = 0.8
	Ripple.ZIndex = button.ZIndex + 1
	
	-- Позиция клика относительно кнопки
	local relX = x - button.AbsolutePosition.X
	local relY = y - button.AbsolutePosition.Y
	Ripple.Position = UDim2.new(0, relX, 0, relY)
	Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	Ripple.Parent = button
	
	-- Анимация расширения и исчезновения
	local goalSize = UDim2.new(0, button.AbsoluteSize.X * 1.5, 0, button.AbsoluteSize.X * 1.5)
	local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	TweenService:Create(Ripple, ti, {Size = goalSize, ImageTransparency = 1}):Play()
	
	task.delay(0.5, function() Ripple:Destroy() end)
end

-- ==========================================
-- СОЗДАНИЕ СОВРЕМЕННОЙ КНОПКИ
-- ==========================================
local function CreateModule(name, desc)
	local Button = Instance.new("TextButton")
	Button.Name = name
	Button.Size = UDim2.new(1, 0, 0, 60)
	Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	Button.BackgroundTransparency = 0.5
	Button.AutoButtonColor = false
	Button.Text = ""
	Button.ClipsDescendants = true -- Для риппла
	Button.Parent = Content

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 10)
	BtnCorner.Parent = Button
	
	local BtnStroke = Instance.new("UIStroke")
	BtnStroke.Color = Color3.new(1,1,1)
	BtnStroke.Transparency = 0.95
	BtnStroke.Parent = Button

	local BtnTitle = Instance.new("TextLabel")
	BtnTitle.Text = name
	BtnTitle.Font = Enum.Font.GothamSemibold
	BtnTitle.TextSize = 16
	BtnTitle.TextColor3 = Theme.Text
	BtnTitle.Position = UDim2.new(0, 15, 0, 12)
	BtnTitle.Size = UDim2.new(1, -30, 0, 20)
	BtnTitle.BackgroundTransparency = 1
	BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
	BtnTitle.Parent = Button

	local BtnDesc = Instance.new("TextLabel")
	BtnDesc.Text = desc
	BtnDesc.Font = Enum.Font.Gotham
	BtnDesc.TextSize = 12
	BtnDesc.TextColor3 = Theme.TextDim
	BtnDesc.Position = UDim2.new(0, 15, 0, 32)
	BtnDesc.Size = UDim2.new(1, -30, 0, 20)
	BtnDesc.BackgroundTransparency = 1
	BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
	BtnDesc.Parent = Button

	-- Логика взаимодействий
	Button.MouseEnter:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 45), BackgroundTransparency = 0.2}):Play()
		TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0.8, Color = Theme.Accent}):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 35), BackgroundTransparency = 0.5}):Play()
		TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0.95, Color = Color3.new(1,1,1)}):Play()
	end)

	Button.MouseButton1Down:Connect(function()
		SpawnRipple(Button, Mouse.X, Mouse.Y)
		-- Микро-сжатие
		TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 58)}):Play()
	end)
	
	Button.MouseButton1Up:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 60)}):Play()
		print("Activated: " .. name)
	end)

	Content.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end

-- Заполняем тест
CreateModule("Rendering Engine", "Управление визуальными эффектами и шейдерами")
CreateModule("Network Wrapper", "Оптимизация Http запросов к GitHub/API")
CreateModule("UI Motion Core", "Ядро физики пружин и анимаций")
CreateModule("Theme Provider", "Динамическая смена цветов интерфейса")

-- ==========================================
-- ЗАПУСК: INTRO АНИМАЦИЯ (SPRING)
-- ==========================================
task.wait(0.5)

local startTime = os.clock()
local duration = 1.5 -- Длительность интро
local startSize = UDim2.new(0, 0, 0, 0)
local targetSize = UDim2.new(0, 550, 0, 380) -- Финальный размер окна

MainFrame.ClipsDescendants = true -- Чтобы контент не вылезал при открытии

local connection
connection = RunService.RenderStepped:Connect(function()
	local elapsed = os.clock() - startTime
	local percent = math.clamp(elapsed / duration, 0, 1)
	
	-- Применяем физику пружины к размеру
	local springProgress = Spring(percent, 0.5, 0.5) -- Damping, Frequency
	Shadow.Size = LerpUDim2(startSize, targetSize, springProgress)
	
	-- Проявляем тени и фон
	Shadow.ImageTransparency = Lerp(1, 0.5, percent)
	MainFrame.BackgroundTransparency = Lerp(1, 0.1, percent)
	Header.GroupTransparency = Lerp(1, 0, percent)
	Content.GroupTransparency = Lerp(1, 0, percent)

	if percent >= 1 then
		connection:Disconnect()
		MainFrame.ClipsDescendants = false
	end
end)

-- Легкое вращение градиента (живой блеск)
RunService.RenderStepped:Connect(function()
	UIGradient.Rotation = UIGradient.Rotation + 0.5
end)
