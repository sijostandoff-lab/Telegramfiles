--[[
    VZZOX UI ENGINE - ULTIMATE EDITION
    Features: Dragging, Minimizing to Widget, Closing, Procedural Logo Animation, Spring Physics.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer

-- Зачистка старого интерфейса
if LP.PlayerGui:FindFirstChild("VzzoxUltimate") then LP.PlayerGui.VzzoxUltimate:Destroy() end

-- ==========================================
-- 1. КОНФИГУРАЦИЯ И ТЕМЫ
-- ==========================================
local Config = {
    Themes = {
        Deox = { Main = Color3.fromRGB(12, 12, 15), Accent = Color3.fromRGB(80, 120, 255) },
        Aneksia = { Main = Color3.fromRGB(15, 10, 15), Accent = Color3.fromRGB(255, 60, 100) },
        Sijo = { Main = Color3.fromRGB(20, 20, 20), Accent = Color3.fromRGB(255, 180, 50) }
    },
    CurrentTheme = "Deox",
    WindowSize = UDim2.new(0, 550, 0, 380),
    WidgetSize = UDim2.new(0, 50, 0, 50),
    AnimationSpeed = 0.6
}

local Theme = Config.Themes[Config.CurrentTheme]

-- ==========================================
-- 2. ФИЗИКА И УТИЛИТЫ
-- ==========================================
local function GetSpring(t, damping, freq)
    if t == 0 or t == 1 then return t end
    local p = freq
    local s = p / (2 * math.pi) * math.asin(1)
    return (math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1)
end

-- Система перетаскивания (Draggable)
local function MakeDraggable(topbarObject, objectToMove)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        -- Плавное перемещение окна
        TweenService:Create(objectToMove, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = objectToMove.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- ==========================================
-- 3. СОЗДАНИЕ ИНТЕРФЕЙСА
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzzoxUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP.PlayerGui

-- Главный контейнер (для анимаций масштаба)
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.Size = Config.WindowSize
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Parent = ScreenGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.ClipsDescendants = true
MainFrame.Parent = Container

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Accent
UIStroke.Thickness = 1.5
UIStroke.Transparency = 1
UIStroke.Parent = MainFrame

-- ==========================================
-- 4. ЛОГОТИП И ИНТРО-АНИМАЦИЯ (XHEARTBLADE STYLE)
-- ==========================================
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(1, 0, 1, 0)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 10
LogoContainer.Parent = MainFrame

-- Процедурный логотип "V"
local LogoLeft = Instance.new("Frame")
LogoLeft.BackgroundColor3 = Theme.Accent
LogoLeft.Size = UDim2.new(0, 10, 0, 0) -- Начинается с 0
LogoLeft.Position = UDim2.new(0.5, -20, 0.5, -30)
LogoLeft.Rotation = 30
LogoLeft.BorderSizePixel = 0
LogoLeft.Parent = LogoContainer

local LogoRight = Instance.new("Frame")
LogoRight.BackgroundColor3 = Theme.Accent
LogoRight.Size = UDim2.new(0, 10, 0, 0) -- Начинается с 0
LogoRight.Position = UDim2.new(0.5, 10, 0.5, -30)
LogoRight.Rotation = -30
LogoRight.BorderSizePixel = 0
LogoRight.Parent = LogoContainer

-- ==========================================
-- 5. ЭЛЕМЕНТЫ УПРАВЛЕНИЯ (ШАПКА)
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "VZZOX // OMNI"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1 -- Скрыто до конца интро
Title.Parent = TopBar

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextTransparency = 1
CloseBtn.Parent = TopBar

-- Кнопка сворачивания (Minimize)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextTransparency = 1
MinBtn.Parent = TopBar

-- Подключаем перетаскивание к шапке
MakeDraggable(TopBar, Container)

-- ==========================================
-- 6. ВИДЖЕТ СВОРАЧИВАНИЯ (ПЛАВАЮЩАЯ ИКОНКА)
-- ==========================================
local Widget = Instance.new("TextButton")
Widget.Name = "Widget"
Widget.BackgroundColor3 = Theme.Main
Widget.Size = Config.WidgetSize
Widget.Position = UDim2.new(0.5, 0, 0.1, 0) -- Появляется сверху
Widget.AnchorPoint = Vector2.new(0.5, 0.5)
Widget.Text = "V"
Widget.Font = Enum.Font.GothamBlack
Widget.TextSize = 24
Widget.TextColor3 = Theme.Accent
Widget.ClipsDescendants = true
Widget.AutoButtonColor = false
Widget.Visible = false -- Скрыт изначально
Widget.Parent = ScreenGui

local WidgetCorner = Instance.new("UICorner")
WidgetCorner.CornerRadius = UDim.new(1, 0) -- Круглый
WidgetCorner.Parent = Widget

local WidgetStroke = Instance.new("UIStroke")
WidgetStroke.Color = Theme.Accent
WidgetStroke.Thickness = 2
WidgetStroke.Parent = Widget

MakeDraggable(Widget, Widget)

-- ==========================================
-- 7. ЛОГИКА АНИМАЦИЙ СОСТОЯНИЙ
-- ==========================================
local isMinimized = false

-- Функция сворачивания
MinBtn.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true
    
    -- Сохраняем позицию большого окна
    local currentPos = Container.Position
    
    -- Прячем контент внутри
    TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()

    task.wait(0.2)
    
    -- Окно схлопывается в точку (эффект всасывания)
    local shrinkTween = TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    shrinkTween:Play()
    shrinkTween.Completed:Wait()
    
    Container.Visible = false
    
    -- Появляется виджет на месте схлопывания
    Widget.Position = currentPos
    Widget.Size = UDim2.new(0, 0, 0, 0)
    Widget.Visible = true
    TweenService:Create(Widget, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
        Size = Config.WidgetSize
    }):Play()
end)

-- Функция разворачивания из виджета
Widget.MouseButton1Click:Connect(function()
    if not isMinimized then return end
    
    local widgetPos = Widget.Position
    
    -- Виджет исчезает
    local hideWidget = TweenService:Create(Widget, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    hideWidget:Play()
    hideWidget.Completed:Wait()
    Widget.Visible = false
    
    -- Окно выстреливает из позиции виджета
    Container.Position = widgetPos
    Container.Visible = true
    
    local expandTween = TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Config.WindowSize
    })
    expandTween:Play()
    
    task.wait(0.3)
    -- Возвращаем UI
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    
    isMinimized = false
end)

-- Закрытие (Полное удаление с эффектом растворения)
CloseBtn.MouseButton1Click:Connect(function()
    local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    TweenService:Create(Container, ti, {Size = UDim2.new(0, 0, 0, 0), Rotation = 15}):Play()
    TweenService:Create(UIStroke, ti, {Transparency = 1}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
end)

-- Ховер эффекты кнопок
for _, btn in pairs({CloseBtn, MinBtn}) do
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Theme.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
    end)
end

-- ==========================================
-- 8. EPIC INTRO SEQUENCE (АХУЕННОЕ ПОЯВЛЕНИЕ)
-- ==========================================
-- Окно изначально крошечное
Container.Size = UDim2.new(0, 0, 0, 0)
Container.Rotation = -45

task.wait(0.5)

-- Шаг 1: Окно резко разворачивается в квадрат (фон для лого)
TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 150, 0, 150),
    Rotation = 0
}):Play()

task.wait(0.4)

-- Шаг 2: Рисуем логотип "V" линиями (Procedural Animation)
TweenService:Create(LogoLeft, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 10, 0, 80)
}):Play()

task.wait(0.2)

TweenService:Create(LogoRight, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 10, 0, 80)
}):Play()

task.wait(0.6)

-- Шаг 3: Логотип вспыхивает и растворяется
local logoFlash = TweenService:Create(LogoContainer, TweenInfo.new(0.3), {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1})
TweenService:Create(LogoLeft, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
TweenService:Create(LogoRight, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
logoFlash:Play()

-- Шаг 4: Разворот в полный рабочий размер с Bounce-эффектом
local ExpandToFull = TweenService:Create(Container, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = Config.WindowSize
})
ExpandToFull:Play()

task.wait(0.2)
-- Появление обводки и текста шапки
TweenService:Create(UIStroke, TweenInfo.new(0.5), {Transparency = 0.2}):Play()
TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(CloseBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(MinBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

task.wait(0.5)
LogoContainer:Destroy() -- Очищаем мусор после интро
