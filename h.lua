local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer
if LP.PlayerGui:FindFirstChild("VzzoxUltimate") then LP.PlayerGui.VzzoxUltimate:Destroy() end

-- ==========================================
-- 1. КОНФИГУРАЦИЯ И ТЕМА
-- ==========================================
local Config = {
    WindowSize = UDim2.new(0, 550, 0, 380),
    WidgetSize = UDim2.new(0, 50, 0, 50),
    Theme = {
        Main = Color3.fromRGB(12, 12, 15),
        Sidebar = Color3.fromRGB(18, 18, 22),
        Accent = Color3.fromRGB(80, 120, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(130, 130, 140),
        Element = Color3.fromRGB(25, 25, 30)
    }
}
local Theme = Config.Theme

local Icons = {
    Home = "rbxassetid://3926305904", HomeRect = Rect.new(964, 204, 1000, 240),
    Code = "rbxassetid://3926305904", CodeRect = Rect.new(324, 124, 360, 160),
    Settings = "rbxassetid://3926307971", SettingsRect = Rect.new(324, 124, 360, 160)
}

-- ==========================================
-- 2. ФИЗИКА И DRAG (С ОГРАНИЧИТЕЛЕМ)
-- ==========================================
local function MakeDraggable(topbarObject, objectToMove)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        
        local newX = math.clamp(startPos.X.Offset + delta.X, -objectToMove.AbsoluteSize.X/2, viewport.X - 50)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, viewport.Y - 50)

        TweenService:Create(objectToMove, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        }):Play()
    end
    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = objectToMove.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- ==========================================
-- 3. СОЗДАНИЕ CORE UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzzoxUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP.PlayerGui

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.Size = UDim2.new(0, 0, 0, 0) -- Для интро
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Rotation = -45 -- Для интро
Container.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.ClipsDescendants = true
MainFrame.Parent = Container

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Theme.Accent
UIStroke.Thickness = 1.5
UIStroke.Transparency = 1 -- Скрыто до интро

-- ==========================================
-- 4. ШАПКА, КНОПКИ, ВИДЖЕТ
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5
TopBar.Parent = MainFrame
MakeDraggable(TopBar, Container)

local Title = Instance.new("TextLabel")
Title.Text = "VZZOX // CORE"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = Theme.Text
Title.Position = UDim2.new(0, 70, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextTransparency = 1
CloseBtn.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextTransparency = 1
MinBtn.Parent = TopBar

-- Виджет
local Widget = Instance.new("TextButton")
Widget.BackgroundColor3 = Theme.Main
Widget.Size = Config.WidgetSize
Widget.Position = UDim2.new(0.5, 0, 0.1, 0)
Widget.AnchorPoint = Vector2.new(0.5, 0.5)
Widget.Text = "V"
Widget.Font = Enum.Font.GothamBlack
Widget.TextSize = 24
Widget.TextColor3 = Theme.Accent
Widget.AutoButtonColor = false
Widget.Visible = false
Widget.Parent = ScreenGui
Instance.new("UICorner", Widget).CornerRadius = UDim.new(1, 0)
local WidgetStroke = Instance.new("UIStroke", Widget)
WidgetStroke.Color = Theme.Accent
WidgetStroke.Thickness = 2
MakeDraggable(Widget, Widget)

-- ==========================================
-- 5. ЛОГИКА СВОРАЧИВАНИЯ / ЗАКРЫТИЯ
-- ==========================================
local isMinimized = false

MinBtn.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true
    local currentPos = Container.Position
    
    -- Прячем UI внутри
    TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()

    task.wait(0.2)
    local shrinkTween = TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    shrinkTween:Play()
    shrinkTween.Completed:Wait()
    Container.Visible = false
    
    Widget.Position = currentPos
    Widget.Size = UDim2.new(0, 0, 0, 0)
    Widget.Visible = true
    TweenService:Create(Widget, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = Config.WidgetSize}):Play()
end)

Widget.MouseButton1Click:Connect(function()
    if not isMinimized then return end
    local widgetPos = Widget.Position
    local hideWidget = TweenService:Create(Widget, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    hideWidget:Play()
    hideWidget.Completed:Wait()
    Widget.Visible = false
    
    Container.Position = widgetPos
    Container.Visible = true
    TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Config.WindowSize}):Play()
    
    task.wait(0.3)
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Transparency = 0.8}):Play()
    isMinimized = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    TweenService:Create(Container, ti, {Size = UDim2.new(0, 0, 0, 0), Rotation = 15}):Play()
    TweenService:Create(UIStroke, ti, {Transparency = 1}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
end)

-- ==========================================
-- 6. SIDEBAR И ВКЛАДКИ
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, 60, 1, 0)
Sidebar.BackgroundTransparency = 1 -- Скрыто для интро
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarHideCorner = Instance.new("Frame", Sidebar)
SidebarHideCorner.BackgroundColor3 = Theme.Sidebar
SidebarHideCorner.BorderSizePixel = 0
SidebarHideCorner.Position = UDim2.new(1, -10, 0, 0)
SidebarHideCorner.Size = UDim2.new(0, 10, 1, 0)
SidebarHideCorner.BackgroundTransparency = 1

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 15)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder

Instance.new("Frame", Sidebar).Size = UDim2.new(1, 0, 0, 10) -- Spacer
Sidebar.Frame.BackgroundTransparency = 1

local PageContainer = Instance.new("Frame")
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 70, 0, 40)
PageContainer.Size = UDim2.new(1, -80, 1, -50)
PageContainer.Parent = MainFrame

local Tabs = {}
local function CreateTab(name, iconId, iconRect)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0, 40, 0, 40)
    TabBtn.BackgroundColor3 = Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

    local Icon = Instance.new("ImageLabel", TabBtn)
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    Icon.Image = iconId
    Icon.ImageRectOffset = iconRect.Min
    Icon.ImageRectSize = iconRect.Max - iconRect.Min
    Icon.ImageColor3 = Theme.TextDim
    Icon.ImageTransparency = 1 -- Скрыто для интро

    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Visible = false
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Tabs[name] = {Btn = TabBtn, Icon = Icon, Page = Page, Layout = PageLayout}

    TabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(Tabs) do
            if tName == name then
                tData.Page.Visible = true
                TweenService:Create(tData.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.Text}):Play()
                TweenService:Create(tData.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
            else
                tData.Page.Visible = false
                TweenService:Create(tData.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.TextDim}):Play()
                TweenService:Create(tData.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            end
        end
    end)
    return Page
end

-- ==========================================
-- 7. КОМПОНЕНТЫ (ТУМБЛЕРЫ)
-- ==========================================
local function CreateToggle(pageName, text, callback)
    local PageData = Tabs[pageName]
    local Frame = Instance.new("TextButton", PageData.Page)
    Frame.BackgroundColor3 = Theme.Element
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    -- Скрываем контент для интро
    Frame.BackgroundTransparency = 1 

    local TitleLbl = Instance.new("TextLabel", Frame)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.GothamSemibold
    TitleLbl.TextSize = 14
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.Position = UDim2.new(0, 15, 0, 0)
    TitleLbl.Size = UDim2.new(1, -60, 1, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.TextTransparency = 1

    local SwitchBg = Instance.new("Frame", Frame)
    SwitchBg.BackgroundColor3 = Theme.Main
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -55, 0.5, -10)
    SwitchBg.BackgroundTransparency = 1
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local SwitchKnob = Instance.new("Frame", SwitchBg)
    SwitchKnob.BackgroundColor3 = Theme.TextDim
    SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
    SwitchKnob.Position = UDim2.new(0, 2, 0.5, -8)
    SwitchKnob.BackgroundTransparency = 1
    Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

    -- Магия проявления после интро
    task.spawn(function()
        task.wait(2.2)
        TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        TweenService:Create(SwitchKnob, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    end)

    local toggled = false
    Frame.MouseButton1Click:Connect(function()
        toggled = not toggled
        callback(toggled)
        if toggled then
            TweenService:Create(SwitchKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
        else
            TweenService:Create(SwitchKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDim}):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Main}):Play()
        end
    end)
    PageData.Page.CanvasSize = UDim2.new(0, 0, 0, PageData.Layout.AbsoluteContentSize.Y + 10)
end

-- Сборка вкладок
CreateTab("Visuals", Icons.Home, Icons.HomeRect)
CreateTab("Scripts", Icons.Code, Icons.CodeRect)
CreateTab("Settings", Icons.Settings, Icons.SettingsRect)

CreateToggle("Visuals", "Enable Chams (ESP)", function(state) print("ESP: ", state) end)
CreateToggle("Visuals", "Show Tracers", function(state) print("Tracers: ", state) end)
CreateToggle("Visuals", "Fullbright", function(state) if state then game.Lighting.Ambient = Color3.new(1,1,1) else game.Lighting.Ambient = Color3.new(0,0,0) end end)

-- ==========================================
-- 8. ЭПИЧНОЕ ИНТРО С ЛОГОТИПОМ
-- ==========================================
local LogoContainer = Instance.new("Frame", MainFrame)
LogoContainer.Size = UDim2.new(1, 0, 1, 0)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 10

local LogoLeft = Instance.new("Frame", LogoContainer)
LogoLeft.BackgroundColor3 = Theme.Accent
LogoLeft.Size = UDim2.new(0, 10, 0, 0)
LogoLeft.Position = UDim2.new(0.5, -20, 0.5, -30)
LogoLeft.Rotation = 30
LogoLeft.BorderSizePixel = 0

local LogoRight = Instance.new("Frame", LogoContainer)
LogoRight.BackgroundColor3 = Theme.Accent
LogoRight.Size = UDim2.new(0, 10, 0, 0)
LogoRight.Position = UDim2.new(0.5, 10, 0.5, -30)
LogoRight.Rotation = -30
LogoRight.BorderSizePixel = 0

task.wait(0.5)

-- Шаг 1: Окно разворачивается в квадрат
TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 150, 0, 150),
    Rotation = 0
}):Play()

task.wait(0.4)

-- Шаг 2: Рисуем логотип "V"
TweenService:Create(LogoLeft, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 80)}):Play()
task.wait(0.2)
TweenService:Create(LogoRight, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 80)}):Play()

task.wait(0.6)

-- Шаг 3: Вспышка
local logoFlash = TweenService:Create(LogoContainer, TweenInfo.new(0.3), {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1})
TweenService:Create(LogoLeft, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
TweenService:Create(LogoRight, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
logoFlash:Play()

-- Шаг 4: Разворот в полный размер
TweenService:Create(Container, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Config.WindowSize}):Play()

task.wait(0.2)

-- Шаг 5: Проявляем весь интерфейс
TweenService:Create(UIStroke, TweenInfo.new(0.5), {Transparency = 0.8}):Play()
TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(CloseBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(MinBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(Sidebar, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
SidebarHideCorner.BackgroundTransparency = 0

-- Активируем вкладку по умолчанию и показываем иконки
for _, tData in pairs(Tabs) do
    TweenService:Create(tData.Icon, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
end
Tabs["Visuals"].Btn.BackgroundTransparency = 0.8
Tabs["Visuals"].Icon.ImageColor3 = Theme.Text
Tabs["Visuals"].Page.Visible = true

task.wait(0.5)
LogoContainer:Destroy()
