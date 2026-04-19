local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

if LP.PlayerGui:FindFirstChild("VzzoxUltimate") then LP.PlayerGui.VzzoxUltimate:Destroy() end

-- ==========================================
-- 1. КОНФИГУРАЦИЯ
-- ==========================================
local Theme = {
    Main = Color3.fromRGB(15, 15, 18),
    Sidebar = Color3.fromRGB(20, 20, 24),
    Accent = Color3.fromRGB(110, 80, 255), -- Фирменный фиолетово-синий
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(130, 130, 140),
    Element = Color3.fromRGB(28, 28, 33)
}

-- Иконки (Material / Lucide Design из библиотеки Roblox)
local Icons = {
    Home = "rbxassetid://3926305904", -- Иконка домика
    Code = "rbxassetid://3926305904", -- Иконка кода
    Settings = "rbxassetid://3926307971", -- Шестеренка
    HomeRect = Rect.new(964, 204, 1000, 240),
    CodeRect = Rect.new(324, 124, 360, 160),
    SettingsRect = Rect.new(324, 124, 360, 160)
}

-- ==========================================
-- 2. ФИЗИКА DRAG С ОГРАНИЧИТЕЛЕМ
-- ==========================================
local function MakeDraggable(topbarObject, objectToMove)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        
        -- Высчитываем новую позицию
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        
        -- CLAMPING: Окно не может улететь за верх экрана (Y < 0) 
        -- и не может уехать за бока больше чем наполовину
        newY = math.clamp(newY, 0, viewport.Y - 50)
        newX = math.clamp(newX, -objectToMove.AbsoluteSize.X/2, viewport.X - 50)

        TweenService:Create(objectToMove, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        }):Play()
    end

    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = objectToMove.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
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
Container.Position = UDim2.new(0.5, -275, 0.5, -190) -- Центр
Container.Size = UDim2.new(0, 550, 0, 380)
Container.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
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
UIStroke.Transparency = 0.8
UIStroke.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5
TopBar.Parent = MainFrame

MakeDraggable(TopBar, Container)

-- ==========================================
-- 4. SIDEBAR (ВКЛАДКИ С ИКОНКАМИ)
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, 60, 1, 0)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- Скрываем скругление справа, чтобы сливалось с основным окном
local SidebarHideCorner = Instance.new("Frame")
SidebarHideCorner.BackgroundColor3 = Theme.Sidebar
SidebarHideCorner.BorderSizePixel = 0
SidebarHideCorner.Position = UDim2.new(1, -10, 0, 0)
SidebarHideCorner.Size = UDim2.new(0, 10, 1, 0)
SidebarHideCorner.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 15)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local Spacer = Instance.new("Frame")
Spacer.BackgroundTransparency = 1
Spacer.Size = UDim2.new(1, 0, 0, 10)
Spacer.Parent = Sidebar

local Tabs = {}
local Pages = {}

local PageContainer = Instance.new("Frame")
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 70, 0, 40)
PageContainer.Size = UDim2.new(1, -80, 1, -50)
PageContainer.Parent = MainFrame

local function CreateTab(name, iconId, iconRect)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 40, 0, 40)
    TabBtn.BackgroundColor3 = Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.Parent = Sidebar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 10)
    TabCorner.Parent = TabBtn

    -- Вставляем "SVG" (Иконку)
    local Icon = Instance.new("ImageLabel")
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    Icon.Image = iconId
    Icon.ImageRectOffset = iconRect.Min
    Icon.ImageRectSize = iconRect.Max - iconRect.Min
    Icon.ImageColor3 = Theme.TextDim
    Icon.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Visible = false
    Page.Parent = PageContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

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
-- 5. ФУНКЦИИ ВНУТРИ (КОМПОНЕНТЫ)
-- ==========================================
local function CreateToggle(pageName, text, callback)
    local PageData = Tabs[pageName]
    local Frame = Instance.new("TextButton")
    Frame.BackgroundColor3 = Theme.Element
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.Parent = PageData.Page

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Text = text
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 14
    Title.TextColor3 = Theme.Text
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local SwitchBg = Instance.new("Frame")
    SwitchBg.BackgroundColor3 = Theme.Main
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -55, 0.5, -10)
    SwitchBg.Parent = Frame
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local SwitchKnob = Instance.new("Frame")
    SwitchKnob.BackgroundColor3 = Theme.TextDim
    SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
    SwitchKnob.Position = UDim2.new(0, 2, 0.5, -8)
    SwitchKnob.Parent = SwitchBg
    Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

    local toggled = false
    Frame.MouseButton1Click:Connect(function()
        toggled = not toggled
        callback(toggled)
        
        if toggled then
            TweenService:Create(SwitchKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = Theme.Text
            }):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
        else
            TweenService:Create(SwitchKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Theme.TextDim
            }):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Main}):Play()
        end
    end)

    PageData.Page.CanvasSize = UDim2.new(0, 0, 0, PageData.Layout.AbsoluteContentSize.Y + 10)
end

-- ==========================================
-- 6. СБОРКА ИНТЕРФЕЙСА
-- ==========================================
CreateTab("Visuals", Icons.Home, Icons.HomeRect)
CreateTab("Scripts", Icons.Code, Icons.CodeRect)
CreateTab("Settings", Icons.Settings, Icons.SettingsRect)

-- Наполняем вкладку Visuals функциями
local TitleVis = Instance.new("TextLabel")
TitleVis.Text = "XHEARTBLADE VISUALS"
TitleVis.Font = Enum.Font.GothamBlack
TitleVis.TextSize = 18
TitleVis.TextColor3 = Theme.Accent
TitleVis.BackgroundTransparency = 1
TitleVis.Size = UDim2.new(1, 0, 0, 30)
TitleVis.TextXAlignment = Enum.TextXAlignment.Left
TitleVis.Parent = Tabs["Visuals"].Page

CreateToggle("Visuals", "Enable Chams (ESP)", function(state)
    print("ESP State: ", state)
    -- Сюда потом вставишь логику подсветки игроков
end)

CreateToggle("Visuals", "Show Tracers", function(state)
    print("Tracers State: ", state)
end)

CreateToggle("Visuals", "Fullbright (Night Vision)", function(state)
    if state then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
    else
        game.Lighting.Ambient = Color3.new(0, 0, 0)
    end
end)

-- Активируем первую вкладку по умолчанию
Tabs["Visuals"].Btn.BackgroundColor3 = Theme.Accent
Tabs["Visuals"].Btn.BackgroundTransparency = 0.8
Tabs["Visuals"].Icon.ImageColor3 = Theme.Text
Tabs["Visuals"].Page.Visible = true

-- ==========================================
-- 7. EPIC ANIMATION (ВХОД)
-- ==========================================
Container.Size = UDim2.new(0, 0, 0, 0)
local ExpandTween = TweenService:Create(Container, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 550, 0, 380)
})
ExpandTween:Play()

-- Если окно случайно потерялось, кнопка F4 вернет его в центр
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F4 then
        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
            Position = UDim2.new(0.5, -275, 0.5, -190)
        }):Play()
    end
end)
