local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

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
        Text = Color3.fromRGB(250, 250, 250),
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
-- 2. ЭФФЕКТЫ: RIPPLE (ВОЛНА ПРИ КЛИКЕ)
-- ==========================================
local function SpawnRipple(button, x, y)
    local Ripple = Instance.new("ImageLabel")
    Ripple.Name = "Ripple"
    Ripple.BackgroundTransparency = 1
    Ripple.Image = "rbxassetid://270245673"
    Ripple.ImageColor3 = Theme.Text
    Ripple.ImageTransparency = 0.8
    Ripple.ZIndex = button.ZIndex + 1
    
    local relX = math.clamp(x - button.AbsolutePosition.X, 0, button.AbsoluteSize.X)
    local relY = math.clamp(y - button.AbsolutePosition.Y, 0, button.AbsoluteSize.Y)
    
    Ripple.Position = UDim2.new(0, relX, 0, relY)
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.Parent = button
    
    local maxDim = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y)
    local goalSize = UDim2.new(0, maxDim * 2, 0, maxDim * 2)
    
    TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = goalSize, ImageTransparency = 1}):Play()
    task.delay(0.4, function() Ripple:Destroy() end)
end

-- ==========================================
-- 3. УЛУЧШЕННЫЙ DRAG (МЫШЬ + СЕНСОР)
-- ==========================================
local function MakeDraggable(topbarObject, objectToMove)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        
        -- Ограничители (чтобы не улетало за края)
        local newX = math.clamp(startPos.X.Offset + delta.X, -objectToMove.AbsoluteSize.X + 50, viewport.X - 50)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, viewport.Y - 50)

        TweenService:Create(objectToMove, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        }):Play()
    end

    topbarObject.InputBegan:Connect(function(input)
        -- Работает и от левой кнопки мыши, и от тапа по экрану
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- ==========================================
-- 4. СОЗДАНИЕ UI И ОКОН
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzzoxUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP.PlayerGui

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.Size = UDim2.new(0, 0, 0, 0)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Rotation = -45
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
UIStroke.Transparency = 1

-- ШАПКА ДЛЯ DRAG
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -80, 0, 40) -- Оставляем место для кнопок закрытия
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5
TopBar.Parent = MainFrame
MakeDraggable(TopBar, Container) -- Цепляем драг на шапку

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "VZZOX // CORE"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = Theme.Text
Title.Position = UDim2.new(0, 70, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextTransparency = 1
CloseBtn.ZIndex = 6

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextTransparency = 1
MinBtn.ZIndex = 6

-- Виджет
local Widget = Instance.new("TextButton", ScreenGui)
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
Instance.new("UICorner", Widget).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Widget).Color = Theme.Accent
MakeDraggable(Widget, Widget)

-- ==========================================
-- 5. АНИМАЦИИ СВОРАЧИВАНИЯ / ЗАКРЫТИЯ
-- ==========================================
local isMinimized = false

MinBtn.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true
    local currentPos = Container.Position
    
    TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()

    task.wait(0.1)
    TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Rotation = 10}):Play()
    task.wait(0.4)
    Container.Visible = false
    
    Widget.Position = currentPos
    Widget.Size = UDim2.new(0, 0, 0, 0)
    Widget.Visible = true
    TweenService:Create(Widget, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = Config.WidgetSize}):Play()
end)

Widget.MouseButton1Click:Connect(function()
    if not isMinimized then return end
    TweenService:Create(Widget, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.3)
    Widget.Visible = false
    
    Container.Visible = true
    TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Config.WindowSize, Rotation = 0}):Play()
    
    task.wait(0.3)
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(CloseBtn, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Transparency = 0.8}):Play()
    isMinimized = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Rotation = -15}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
end)

-- Анимации ховера для крестика
CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 60, 60)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play() end)

-- ==========================================
-- 6. SIDEBAR С АНИМАЦИЕЙ ПЕРЕХОДОВ
-- ==========================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, 60, 1, 0)
Sidebar.BackgroundTransparency = 1
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

Instance.new("Frame", Sidebar).Size = UDim2.new(1, 0, 0, 10)
Sidebar.Frame.BackgroundTransparency = 1

-- Используем CanvasGroup для плавного исчезновения целых страниц
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 70, 0, 40)
PageContainer.Size = UDim2.new(1, -80, 1, -50)
PageContainer.ClipsDescendants = true

local Tabs = {}
local function CreateTab(name, iconId, iconRect)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0, 40, 0, 40)
    TabBtn.BackgroundColor3 = Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.AutoButtonColor = false
    TabBtn.ClipsDescendants = true -- Для Ripple
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
    Icon.ImageTransparency = 1

    local PageGroup = Instance.new("CanvasGroup", PageContainer)
    PageGroup.BackgroundTransparency = 1
    PageGroup.Size = UDim2.new(1, 0, 1, 0)
    PageGroup.GroupTransparency = 1
    PageGroup.Visible = false
    
    -- Анимация "Выезда снизу" для страниц
    local PageLayout = Instance.new("UIListLayout", PageGroup)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Tabs[name] = {Btn = TabBtn, Icon = Icon, Page = PageGroup, Layout = PageLayout}

    -- Ховеры
    TabBtn.MouseEnter:Connect(function()
        if PageGroup.Visible == false then
            TweenService:Create(Icon, TweenInfo.new(0.2), {Size = UDim2.new(0, 28, 0, 28), ImageColor3 = Theme.Text}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if PageGroup.Visible == false then
            TweenService:Create(Icon, TweenInfo.new(0.2), {Size = UDim2.new(0, 24, 0, 24), ImageColor3 = Theme.TextDim}):Play()
        end
    end)

    -- Клик (Смена вкладок с эффектами)
    TabBtn.MouseButton1Click:Connect(function()
        SpawnRipple(TabBtn, Mouse.X, Mouse.Y)
        
        for tName, tData in pairs(Tabs) do
            if tName == name then
                tData.Page.Visible = true
                -- Анимация появления: Сдвиг + Растворение
                tData.Page.Position = UDim2.new(0, 20, 0, 0)
                TweenService:Create(tData.Page, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}):Play()
                
                TweenService:Create(tData.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.Text, Size = UDim2.new(0, 26, 0, 26)}):Play()
                TweenService:Create(tData.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
            else
                -- Анимация скрытия
                TweenService:Create(tData.Page, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
                task.delay(0.2, function() if tData.Page.GroupTransparency == 1 then tData.Page.Visible = false end end)
                
                TweenService:Create(tData.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.TextDim, Size = UDim2.new(0, 24, 0, 24)}):Play()
                TweenService:Create(tData.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            end
        end
    end)
    return PageGroup
end

-- ==========================================
-- 7. КОМПОНЕНТЫ: АНИМИРОВАННЫЙ ТУМБЛЕР
-- ==========================================
local function CreateToggle(pageName, text, callback)
    local PageData = Tabs[pageName]
    local Frame = Instance.new("TextButton", PageData.Page)
    Frame.BackgroundColor3 = Theme.Element
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.ClipsDescendants = true
    Frame.BackgroundTransparency = 1
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

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

    task.spawn(function()
        task.wait(2.2)
        TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        TweenService:Create(SwitchKnob, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    end)

    local toggled = false
    Frame.MouseButton1Click:Connect(function()
        SpawnRipple(Frame, Mouse.X, Mouse.Y) -- Вызов волны
        
        toggled = not toggled
        callback(toggled)
        
        -- Физика сжатия кнопки при клике
        TweenService:Create(Frame, TweenInfo.new(0.1), {Size = UDim2.new(1, -14, 0, 41)}):Play()
        task.wait(0.1)
        TweenService:Create(Frame, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Size = UDim2.new(1, -10, 0, 45)}):Play()

        if toggled then
            TweenService:Create(SwitchKnob, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
        else
            TweenService:Create(SwitchKnob, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDim}):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Main}):Play()
        end
    end)
end

-- ==========================================
-- 8. ИНИЦИАЛИЗАЦИЯ И ИНТРО
-- ==========================================
CreateTab("Visuals", Icons.Home, Icons.HomeRect)
CreateTab("Scripts", Icons.Code, Icons.CodeRect)
CreateTab("Settings", Icons.Settings, Icons.SettingsRect)

CreateToggle("Visuals", "Enable Chams (ESP)", function(state) print("ESP: ", state) end)
CreateToggle("Visuals", "Show Tracers", function(state) print("Tracers: ", state) end)
CreateToggle("Visuals", "Fullbright", function(state) if state then game.Lighting.Ambient = Color3.new(1,1,1) else game.Lighting.Ambient = Color3.new(0,0,0) end end)

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

TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 150), Rotation = 0}):Play()
task.wait(0.4)
TweenService:Create(LogoLeft, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 80)}):Play()
task.wait(0.2)
TweenService:Create(LogoRight, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 80)}):Play()
task.wait(0.6)

local logoFlash = TweenService:Create(LogoContainer, TweenInfo.new(0.3), {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1})
TweenService:Create(LogoLeft, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
TweenService:Create(LogoRight, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
logoFlash:Play()

TweenService:Create(Container, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Config.WindowSize}):Play()
task.wait(0.2)

TweenService:Create(UIStroke, TweenInfo.new(0.5), {Transparency = 0.8}):Play()
TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(CloseBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(MinBtn, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(Sidebar, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
SidebarHideCorner.BackgroundTransparency = 0

for _, tData in pairs(Tabs) do TweenService:Create(tData.Icon, TweenInfo.new(0.5), {ImageTransparency = 0}):Play() end
Tabs["Visuals"].Btn.BackgroundTransparency = 0.8
Tabs["Visuals"].Icon.ImageColor3 = Theme.Text
Tabs["Visuals"].Page.Visible = true
Tabs["Visuals"].Page.GroupTransparency = 0

task.wait(0.5)
LogoContainer:Destroy()
