-- vzzox fly v1
-- Expanded premium UI + PC/mobile flight
-- Put into StarterPlayer > StarterPlayerScripts
-- Key: vzzox2026

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local KEY = "vzzox2026"

local state = {
	unlocked = false,
	flying = false,
	minimized = false,
	upHeld = false,
	downHeld = false,
	speed = 60,
	canDrag = true,
}

local character
local humanoid
local hrp

local bodyVelocity
local bodyGyro
local flightConnection

local gui
local main
local topBar
local content
local title
local subtitle
local statusLabel
local keyBox
local unlockButton
local flyButton
local upButton
local downButton
local speedMinusButton
local speedPlusButton
local speedValueLabel
local miniButton
local closeButton
local hintLabel
local pulseFrame
local glowFrame

local dragState = {
	dragging = false,
	dragStart = nil,
	startPos = nil,
	input = nil,
}

local function safeCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
end

safeCharacter()

player.CharacterAdded:Connect(function()
	task.wait(0.2)
	safeCharacter()
	if state.flying then
		task.wait(0.2)
		state.flying = false
	end
end)

local function destroyFlightObjects()
	if flightConnection then
		flightConnection:Disconnect()
		flightConnection = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	if humanoid then
		humanoid.AutoRotate = true
	end
end

local function setStatus(text, color)
	if statusLabel then
		statusLabel.Text = text
		statusLabel.TextColor3 = color
	end
end

local function tween(obj, props, t, style, dir)
	local info = TweenInfo.new(
		t or 0.2,
		style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out
	)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function makeStroke(parent, transparency, color, thickness)
	local s = Instance.new("UIStroke")
	s.Transparency = transparency or 0.5
	s.Color = color or Color3.fromRGB(150, 110, 255)
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function makeGradient(parent, c1, c2, rotation)
	local g = Instance.new("UIGradient")
	g.Rotation = rotation or 45
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2),
	})
	g.Parent = parent
	return g
end

local function createText(parent, text, size, bold)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = Color3.fromRGB(245, 245, 255)
	t.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	t.TextSize = size
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.RichText = false
	t.Parent = parent
	return t
end

local function createButton(parent, text)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text
	b.Parent = parent

	makeCorner(b, 12)
	makeStroke(b, 0.6, Color3.fromRGB(170, 130, 255), 1)

	local grad = makeGradient(
		b,
		Color3.fromRGB(78, 42, 140),
		Color3.fromRGB(20, 20, 28),
		90
	)

	return b, grad
end

local function animateButton(btn)
	btn.MouseEnter:Connect(function()
		tween(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 2, btn.Size.Y.Scale, btn.Size.Y.Offset + 2)}, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 2, btn.Size.Y.Scale, btn.Size.Y.Offset - 2)}, 0.12)
	end)
end

local function buildUI()
	gui = Instance.new("ScreenGui")
	gui.Name = "vzzoxFlyV1"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.fromOffset(380, 350)
	main.Position = UDim2.new(0.5, -190, 0.68, -175)
	main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	main.BorderSizePixel = 0
	main.Parent = gui
	makeCorner(main, 20)
	makeStroke(main, 0.25, Color3.fromRGB(180, 120, 255), 1)
	makeGradient(main, Color3.fromRGB(24, 14, 40), Color3.fromRGB(10, 10, 14), 90)

	glowFrame = Instance.new("Frame")
	glowFrame.Name = "Glow"
	glowFrame.BackgroundTransparency = 0.25
	glowFrame.BackgroundColor3 = Color3.fromRGB(120, 70, 255)
	glowFrame.BorderSizePixel = 0
	glowFrame.Size = UDim2.new(1, 12, 1, 12)
	glowFrame.Position = UDim2.fromOffset(-6, -6)
	glowFrame.ZIndex = 0
	glowFrame.Parent = main
	makeCorner(glowFrame, 24)

	pulseFrame = Instance.new("Frame")
	pulseFrame.Name = "Pulse"
	pulseFrame.BackgroundTransparency = 0.82
	pulseFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	pulseFrame.BorderSizePixel = 0
	pulseFrame.Size = UDim2.new(1, 0, 1, 0)
	pulseFrame.Parent = main
	makeCorner(pulseFrame, 20)

	topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 54)
	topBar.BackgroundTransparency = 1
	topBar.Parent = main

	title = createText(topBar, "vzzox fly v1", 22, true)
	title.Position = UDim2.fromOffset(18, 10)
	title.Size = UDim2.new(1, -140, 0, 24)

	subtitle = createText(topBar, "PC + Mobile flight system", 12, false)
	subtitle.TextColor3 = Color3.fromRGB(188, 178, 210)
	subtitle.Position = UDim2.fromOffset(18, 30)
	subtitle.Size = UDim2.new(1, -140, 0, 16)

	miniButton = createButton(topBar, "—")
	miniButton.Size = UDim2.fromOffset(34, 28)
	miniButton.Position = UDim2.new(1, -78, 0, 12)
	miniButton.TextSize = 22
	animateButton(miniButton)

	closeButton = createButton(topBar, "×")
	closeButton.Size = UDim2.fromOffset(34, 28)
	closeButton.Position = UDim2.new(1, -38, 0, 12)
	closeButton.TextSize = 24
	animateButton(closeButton)

	content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(0, 54)
	content.Size = UDim2.new(1, 0, 1, -54)
	content.Parent = main

	keyBox = Instance.new("TextBox")
	keyBox.Name = "KeyBox"
	keyBox.PlaceholderText = "Enter key"
	keyBox.Text = ""
	keyBox.ClearTextOnFocus = false
	keyBox.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 165)
	keyBox.Font = Enum.Font.Gotham
	keyBox.TextSize = 16
	keyBox.Size = UDim2.new(1, -36, 0, 44)
	keyBox.Position = UDim2.fromOffset(18, 10)
	keyBox.Parent = content
	makeCorner(keyBox, 14)
	makeStroke(keyBox, 0.58, Color3.fromRGB(130, 120, 170), 1)

	unlockButton, _ = createButton(content, "UNLOCK")
	unlockButton.Size = UDim2.new(1, -36, 0, 44)
	unlockButton.Position = UDim2.fromOffset(18, 64)
	animateButton(unlockButton)

	statusLabel = createText(content, "Locked", 13, true)
	statusLabel.TextColor3 = Color3.fromRGB(255, 110, 110)
	statusLabel.Position = UDim2.fromOffset(18, 116)
	statusLabel.Size = UDim2.new(1, -36, 0, 18)

	flyButton, _ = createButton(content, "FLY: OFF")
	flyButton.Size = UDim2.new(0.52, -22, 0, 42)
	flyButton.Position = UDim2.fromOffset(18, 144)
	flyButton.Visible = false
	animateButton(flyButton)

	upButton, _ = createButton(content, "UP")
	upButton.Size = UDim2.new(0.22, -6, 0, 42)
	upButton.Position = UDim2.fromOffset(176, 144)
	upButton.Visible = false

	downButton, _ = createButton(content, "DOWN")
	downButton.Size = UDim2.new(0.22, -6, 0, 42)
	downButton.Position = UDim2.fromOffset(250, 144)
	downButton.Visible = false

	local speedTitle = createText(content, "Speed control", 12, true)
	speedTitle.TextColor3 = Color3.fromRGB(210, 200, 230)
	speedTitle.Position = UDim2.fromOffset(18, 194)
	speedTitle.Size = UDim2.new(1, -36, 0, 16)
	speedTitle.Visible = false
	speedTitle.Name = "SpeedTitle"

	speedMinusButton, _ = createButton(content, "−")
	speedMinusButton.Size = UDim2.fromOffset(42, 34)
	speedMinusButton.Position = UDim2.fromOffset(18, 220)
	speedMinusButton.Visible = false

	speedValueLabel = createText(content, tostring(state.speed), 16, true)
	speedValueLabel.TextAlignment = Enum.TextXAlignment.Center
	speedValueLabel.TextXAlignment = Enum.TextXAlignment.Center
	speedValueLabel.Position = UDim2.fromOffset(70, 220)
	speedValueLabel.Size = UDim2.fromOffset(70, 34)
	speedValueLabel.Visible = false

	speedPlusButton, _ = createButton(content, "+")
	speedPlusButton.Size = UDim2.fromOffset(42, 34)
	speedPlusButton.Position = UDim2.fromOffset(150, 220)
	speedPlusButton.Visible = false

	hintLabel = createText(content, "Drag from top bar | F = toggle fly", 11, false)
	hintLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
	hintLabel.TextXAlignment = Enum.TextXAlignment.Right
	hintLabel.Position = UDim2.new(1, -190, 1, -20)
	hintLabel.Size = UDim2.fromOffset(170, 14)
	hintLabel.Visible = true

	local bottomLine = Instance.new("Frame")
	bottomLine.BackgroundTransparency = 0.55
	bottomLine.BackgroundColor3 = Color3.fromRGB(120, 90, 170)
	bottomLine.BorderSizePixel = 0
	bottomLine.Size = UDim2.new(1, -36, 0, 1)
	bottomLine.Position = UDim2.fromOffset(18, 178)
	bottomLine.Parent = content

	local bottomGlow = Instance.new("Frame")
	bottomGlow.BackgroundTransparency = 0.86
	bottomGlow.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
	bottomGlow.BorderSizePixel = 0
	bottomGlow.Size = UDim2.new(1, -36, 0, 6)
	bottomGlow.Position = UDim2.fromOffset(18, 175)
	bottomGlow.Parent = content
	makeCorner(bottomGlow, 8)
end

local function setUnlockedUI()
	local speedTitle = content:FindFirstChild("SpeedTitle")
	if speedTitle then
		speedTitle.Visible = true
	end

	flyButton.Visible = true
	upButton.Visible = true
	downButton.Visible = true
	speedMinusButton.Visible = true
	speedPlusButton.Visible = true
	speedValueLabel.Visible = true
	hintLabel.Text = "Drag from top bar | F = toggle fly | Space / Ctrl"

	tween(main, {Size = UDim2.fromOffset(380, 366)}, 0.18)
	setStatus("Unlocked", Color3.fromRGB(110, 255, 160))
end

local function refreshSpeedLabel()
	if speedValueLabel then
		speedValueLabel.Text = tostring(state.speed)
	end
end

local function updateFlyButtonText()
	if flyButton then
		flyButton.Text = state.flying and "FLY: ON" or "FLY: OFF"
	end
end

local function stopFly()
	state.flying = false
	state.upHeld = false
	state.downHeld = false
	updateFlyButtonText()
	destroyFlightObjects()
	setStatus(state.unlocked and "Unlocked" or "Locked", state.unlocked and Color3.fromRGB(110, 255, 160) or Color3.fromRGB(255, 110, 110))
end

local function startFly()
	if not state.unlocked then
		setStatus("Need key", Color3.fromRGB(255, 180, 80))
		return
	end

	safeCharacter()

	if not character or not humanoid or not hrp then
		return
	end

	state.flying = true
	updateFlyButtonText()

	humanoid.AutoRotate = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "vzzoxBV"
	bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bodyVelocity.P = 1250
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = hrp

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Name = "vzzoxBG"
	bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bodyGyro.P = 9000
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	flightConnection = RunService.RenderStepped:Connect(function()
		if not state.flying or not character or not humanoid or not hrp or humanoid.Health <= 0 then
			stopFly()
			return
		end

		camera = workspace.CurrentCamera
		if not camera then
			return
		end

		local direction = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			direction += camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.S) then
			direction -= camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.A) then
			direction -= camera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.D) then
			direction += camera.CFrame.RightVector
		end

		local move = humanoid.MoveDirection
		direction += Vector3.new(move.X, 0, move.Z)

		direction = Vector3.new(direction.X, 0, direction.Z)

		local velocity = Vector3.zero
		if direction.Magnitude > 0.05 then
			velocity += direction.Unit * state.speed
		end

		local vertical = 0
		if state.upHeld then
			vertical += 1
		end
		if state.downHeld then
			vertical -= 1
		end

		velocity += Vector3.new(0, vertical * state.speed, 0)

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
	end)
end

local function toggleFly()
	if not state.unlocked then
		setStatus("Need key", Color3.fromRGB(255, 180, 80))
		return
	end

	if state.flying then
		stopFly()
	else
		startFly()
	end
end

local function setMinimized(value)
	state.minimized = value

	if state.minimized then
		content.Visible = false
		tween(main, {Size = UDim2.fromOffset(380, 54)}, 0.18)
	else
		content.Visible = true
		tween(main, {Size = UDim2.fromOffset(380, 366)}, 0.18)
	end
end

local function flashUnlock()
	tween(glowFrame, {BackgroundTransparency = 0.62}, 0.12)
	task.delay(0.12, function()
		if glowFrame then
			tween(glowFrame, {BackgroundTransparency = 0.9}, 0.18)
		end
	end)
end

local function animateIntro()
	main.BackgroundTransparency = 1
	glowFrame.BackgroundTransparency = 1
	pulseFrame.BackgroundTransparency = 1

	for _, obj in ipairs(main:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			obj.TextTransparency = 1
			if obj:IsA("TextButton") or obj:IsA("TextBox") then
				obj.BackgroundTransparency = 1
			end
		elseif obj:IsA("Frame") then
			obj.BackgroundTransparency = math.clamp(obj.BackgroundTransparency + 0.2, 0, 1)
		end
	end

	tween(main, {BackgroundTransparency = 0}, 0.22)
	tween(glowFrame, {BackgroundTransparency = 0.25}, 0.22)
	tween(pulseFrame, {BackgroundTransparency = 0.82}, 0.22)

	task.delay(0.05, function()
		for _, obj in ipairs(main:GetDescendants()) do
			if obj:IsA("TextLabel") then
				tween(obj, {TextTransparency = 0}, 0.18)
			elseif obj:IsA("TextButton") then
				tween(obj, {TextTransparency = 0, BackgroundTransparency = 0}, 0.18)
			elseif obj:IsA("TextBox") then
				tween(obj, {TextTransparency = 0, BackgroundTransparency = 0}, 0.18)
			end
		end
	end)
end

local function bindMobileHold(button, startFn, endFn)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			startFn()
		end
	end)

	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			endFn()
		end
	end)
end

local function setupInteractions()
	unlockButton.MouseButton1Click:Connect(function()
		if keyBox.Text == KEY then
			state.unlocked = true
			setUnlockedUI()
			flashUnlock()
		else
			state.unlocked = false
			setStatus("Wrong key", Color3.fromRGB(255, 110, 110))
		end
	end)

	flyButton.MouseButton1Click:Connect(function()
		toggleFly()
	end)

	bindMobileHold(upButton,
		function() state.upHeld = true end,
		function() state.upHeld = false end
	)

	bindMobileHold(downButton,
		function() state.downHeld = true end,
		function() state.downHeld = false end
	)

	speedMinusButton.MouseButton1Click:Connect(function()
		state.speed = math.max(10, state.speed - 10)
		refreshSpeedLabel()
	end)

	speedPlusButton.MouseButton1Click:Connect(function()
		state.speed = math.min(200, state.speed + 10)
		refreshSpeedLabel()
	end)

	miniButton.MouseButton1Click:Connect(function()
		setMinimized(not state.minimized)
	end)

	closeButton.MouseButton1Click:Connect(function()
		stopFly()
		if gui then
			gui:Destroy()
		end
	end)

	UIS.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == Enum.KeyCode.F then
			toggleFly()
		elseif input.KeyCode == Enum.KeyCode.Space then
			state.upHeld = true
		elseif input.KeyCode == Enum.KeyCode.LeftControl then
			state.downHeld = true
		end
	end)

	UIS.InputEnded:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Space then
			state.upHeld = false
		elseif input.KeyCode == Enum.KeyCode.LeftControl then
			state.downHeld = false
		end
	end)
end

local function setupDragging()
	local function update(input)
		local delta = input.Position - dragState.dragStart
		main.Position = UDim2.new(
			dragState.startPos.X.Scale,
			dragState.startPos.X.Offset + delta.X,
			dragState.startPos.Y.Scale,
			dragState.startPos.Y.Offset + delta.Y
		)
	end

	topBar.InputBegan:Connect(function(input)
		if not state.canDrag then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragState.dragging = true
			dragState.dragStart = input.Position
			dragState.startPos = main.Position
			dragState.input = input
		end
	end)

	topBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragState.dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragState.dragging and dragState.input and input.UserInputType == dragState.input.UserInputType then
			update(input)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input == dragState.input then
			dragState.dragging = false
			dragState.input = nil
		end
	end)
end

local function setupPulse()
	task.spawn(function()
		while gui and gui.Parent do
			if pulseFrame then
				tween(pulseFrame, {BackgroundTransparency = 0.9}, 0.8)
				task.wait(0.8)
				tween(pulseFrame, {BackgroundTransparency = 0.82}, 0.8)
				task.wait(0.8)
			else
				break
			end
		end
	end)
end

buildUI()
setupInteractions()
setupDragging()
animateIntro()
refreshSpeedLabel()
updateFlyButtonText()
setStatus("Locked", Color3.fromRGB(255, 110, 110))
setupPulse()