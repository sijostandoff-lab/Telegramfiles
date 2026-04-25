-- vzzox fly v1
-- Для Roblox Studio / своего плейса
-- ПК: F = включить/выключить
-- Телефон: кнопка FLY
-- Ключ: vzzox2026

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local KEY = "vzzox2026"

local flySpeed = 60
local isUnlocked = false
local isFlying = false
local upHeld = false
local downHeld = false

local character, humanoid, hrp
local bv, bg
local flyConn

local function getChar()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
end

getChar()
player.CharacterAdded:Connect(function()
	task.wait(0.2)
	getChar()
	if isFlying then
		task.wait(0.2)
		-- если персонаж переродился, выключаем полёт
		isFlying = false
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "vzzoxFlyV1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
end

local function addStroke(obj, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = transparency or 0.45
	s.Color = Color3.fromRGB(120, 120, 140)
	s.Parent = obj
end

local function addGradient(obj)
	local g = Instance.new("UIGradient")
	g.Rotation = 45
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 18, 62)),
	})
	g.Parent = obj
end

local function makeText(parent, text, size, bold)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = Color3.fromRGB(245, 245, 255)
	t.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	t.TextSize = size
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = parent
	return t
end

local function makeButton(parent, text)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text
	b.Parent = parent
	addCorner(b, 10)
	addStroke(b, 0.55)

	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 54, 72)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 26, 34)),
	})
	grad.Parent = b

	return b
end

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(310, 235)
main.Position = UDim2.new(0.5, -155, 0.72, -117)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.Parent = gui
addCorner(main, 18)
addStroke(main, 0.35)
addGradient(main)

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.Position = UDim2.fromOffset(-6, -6)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0
shadow.Parent = main

local title = makeText(main, "vzzox fly v1", 22, true)
title.Position = UDim2.fromOffset(18, 14)
title.Size = UDim2.new(1, -36, 0, 28)

local sub = makeText(main, "PC + mobile flight", 13, false)
sub.TextColor3 = Color3.fromRGB(185, 185, 200)
sub.Position = UDim2.fromOffset(18, 42)
sub.Size = UDim2.new(1, -36, 0, 20)

local keyBox = Instance.new("TextBox")
keyBox.PlaceholderText = "Enter key"
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.Text = ""
keyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 165)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 16
keyBox.Size = UDim2.new(1, -36, 0, 42)
keyBox.Position = UDim2.fromOffset(18, 72)
keyBox.Parent = main
addCorner(keyBox, 12)
addStroke(keyBox, 0.6)

local unlockBtn = makeButton(main, "Unlock")
unlockBtn.Size = UDim2.new(1, -36, 0, 42)
unlockBtn.Position = UDim2.fromOffset(18, 124)

local status = makeText(main, "Locked", 13, true)
status.TextColor3 = Color3.fromRGB(255, 110, 110)
status.Position = UDim2.fromOffset(18, 170)
status.Size = UDim2.new(1, -36, 0, 20)

local flyBtn = makeButton(main, "FLY: OFF")
flyBtn.Size = UDim2.new(0.5, -24, 0, 40)
flyBtn.Position = UDim2.fromOffset(18, 194)
flyBtn.Visible = false

local upBtn = makeButton(main, "UP")
upBtn.Size = UDim2.new(0.22, -6, 0, 40)
upBtn.Position = UDim2.fromOffset(162, 194)
upBtn.Visible = false

local downBtn = makeButton(main, "DOWN")
downBtn.Size = UDim2.new(0.22, -6, 0, 40)
downBtn.Position = UDim2.fromOffset(234, 194)
downBtn.Visible = false

local info = makeText(main, "F = toggle", 12, false)
info.TextColor3 = Color3.fromRGB(170, 170, 185)
info.Position = UDim2.fromOffset(18, 214)
info.Size = UDim2.new(1, -36, 0, 16)
info.Visible = false

local function setStatus(text, color)
	status.Text = text
	status.TextColor3 = color
end

local function stopFly()
	isFlying = false
	upHeld = false
	downHeld = false

	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end

	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end

	if humanoid then
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end

	flyBtn.Text = "FLY: OFF"
end

local function startFly()
	if not (character and humanoid and hrp) then
		getChar()
	end

	isFlying = true
	humanoid.AutoRotate = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	bv = Instance.new("BodyVelocity")
	bv.Name = "vzzoxBV"
	bv.P = 1250
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
	bg.Name = "vzzoxBG"
	bg.P = 9000
	bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	flyConn = RunService.RenderStepped:Connect(function()
		if not isFlying or not character or not humanoid or not hrp or humanoid.Health <= 0 then
			stopFly()
			return
		end

		local cam = workspace.CurrentCamera
		if not cam then return end

		local move = humanoid.MoveDirection
		local forward = cam.CFrame.LookVector
		local right = cam.CFrame.RightVector

		local flat = (forward * move.Z) + (right * move.X)
		flat = Vector3.new(flat.X, 0, flat.Z)

		local vel = Vector3.zero
		if flat.Magnitude > 0.05 then
			vel += flat.Unit * flySpeed
		end

		local vertical = 0
		if upHeld then vertical += 1 end
		if downHeld then vertical -= 1 end
		vel += Vector3.new(0, vertical * flySpeed, 0)

		bv.Velocity = vel
		bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
	end)

	flyBtn.Text = "FLY: ON"
end

local function toggleFly()
	if not isUnlocked then return end
	if isFlying then
		stopFly()
	else
		startFly()
	end
end

unlockBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == KEY then
		isUnlocked = true
		setStatus("Unlocked", Color3.fromRGB(110, 255, 160))

		flyBtn.Visible = true
		upBtn.Visible = true
		downBtn.Visible = true
		info.Visible = true

		tween(main, {Size = UDim2.fromOffset(310, 265)}, 0.2)
	else
		setStatus("Wrong key", Color3.fromRGB(255, 110, 110))
	end
end)

flyBtn.MouseButton1Click:Connect(toggleFly)

local function bindHold(button, onStart, onEnd)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			onStart()
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			onEnd()
		end
	end)
end

bindHold(upBtn, function()
	upHeld = true
end, function()
	upHeld = false
end)

bindHold(downBtn, function()
	downHeld = true
end, function()
	downHeld = false
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		toggleFly()
	elseif input.KeyCode == Enum.KeyCode.Space then
		upHeld = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		downHeld = true
	end
end)

UIS.InputEnded:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		upHeld = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		downHeld = false
	end
end)

-- маленькая анимация появления
main.BackgroundTransparency = 1
for _, v in ipairs(main:GetDescendants()) do
	if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
		v.TextTransparency = 1
		if v:IsA("TextButton") or v:IsA("TextBox") then
			v.BackgroundTransparency = 1
		end
	end
end

tween(main, {BackgroundTransparency = 0}, 0.25)
for _, v in ipairs(main:GetDescendants()) do
	if v:IsA("TextLabel") then
		tween(v, {TextTransparency = 0}, 0.25)
	elseif v:IsA("TextButton") then
		tween(v, {TextTransparency = 0, BackgroundTransparency = 0}, 0.25)
	elseif v:IsA("TextBox") then
		tween(v, {TextTransparency = 0, BackgroundTransparency = 0}, 0.25)
	end
end