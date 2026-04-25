-- vzzox fly v1
-- Roblox Studio / свой плейс
-- ПК: F = fly toggle
-- Mobile: кнопки на экране
-- Key: vzzox2026

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
local minimized = false

local character, humanoid, hrp
local bv, bg, flyConn

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
		isFlying = false
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "vzzoxFlyV1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function stroke(obj, t, c)
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = t or 0.45
	s.Color = c or Color3.fromRGB(120, 120, 140)
	s.Parent = obj
	return s
end

local function gradient(obj, a, b, rot)
	local g = Instance.new("UIGradient")
	g.Rotation = rot or 45
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, a),
		ColorSequenceKeypoint.new(1, b)
	})
	g.Parent = obj
	return g
end

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function mkLabel(parent, text, size, bold)
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

local function mkButton(parent, text)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text
	b.Parent = parent
	corner(b, 12)
	stroke(b, 0.62, Color3.fromRGB(145, 120, 255))

	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(78, 42, 140)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(35, 35, 48)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24)),
	})
	g.Parent = b

	return b
end

local function applyHover(btn)
	btn.MouseEnter:Connect(function()
		tween(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 2, btn.Size.Y.Scale, btn.Size.Y.Offset + 2)}, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 2, btn.Size.Y.Scale, btn.Size.Y.Offset - 2)}, 0.12)
	end)
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

		local direction = Vector3.zero

if UIS:IsKeyDown(Enum.KeyCode.W) then
	direction += cam.CFrame.LookVector
end
if UIS:IsKeyDown(Enum.KeyCode.S) then
	direction -= cam.CFrame.LookVector
end
if UIS:IsKeyDown(Enum.KeyCode.A) then
	direction -= cam.CFrame.RightVector
end
if UIS:IsKeyDown(Enum.KeyCode.D) then
	direction += cam.CFrame.RightVector
end

-- мобилка (джойстик)
local move = humanoid.MoveDirection
direction += Vector3.new(move.X, 0, move.Z)

direction = Vector3.new(direction.X, 0, direction.Z)

local vel = Vector3.zero
if direction.Magnitude > 0 then
	vel += direction.Unit * flySpeed
end

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
end

local function toggleFly()
	if not isUnlocked then return end
	if isFlying then
		stopFly()
	else
		startFly()
	end
end

-- UI
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(360, 300)
main.Position = UDim2.new(0.5, -180, 0.68, -150)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
main.Parent = gui
corner(main, 20)
stroke(main, 0.28, Color3.fromRGB(180, 120, 255))
gradient(main, Color3.fromRGB(24, 14, 40), Color3.fromRGB(10, 10, 14), 90)

local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.fromOffset(-10, -10)
shadow.ZIndex = 0
shadow.Parent = main

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local title = mkLabel(topBar, "vzzox fly v1", 22, true)
title.Position = UDim2.fromOffset(18, 10)
title.Size = UDim2.new(1, -120, 0, 24)

local tag = mkLabel(topBar, "PC + Mobile | Premium UI", 12, false)
tag.TextColor3 = Color3.fromRGB(185, 175, 205)
tag.Position = UDim2.fromOffset(18, 30)
tag.Size = UDim2.new(1, -120, 0, 16)

local miniBtn = mkButton(topBar, "—")
miniBtn.Size = UDim2.fromOffset(34, 28)
miniBtn.Position = UDim2.new(1, -78, 0, 10)
miniBtn.TextSize = 22
applyHover(miniBtn)

local closeBtn = mkButton(topBar, "×")
closeBtn.Size = UDim2.fromOffset(34, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 10)
closeBtn.TextSize = 24
applyHover(closeBtn)

local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Position = UDim2.fromOffset(0, 48)
content.Size = UDim2.new(1, 0, 1, -48)
content.Parent = main

local keyBox = Instance.new("TextBox")
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
corner(keyBox, 14)
stroke(keyBox, 0.6, Color3.fromRGB(130, 120, 170))

local unlockBtn = mkButton(content, "UNLOCK")
unlockBtn.Size = UDim2.new(1, -36, 0, 44)
unlockBtn.Position = UDim2.fromOffset(18, 62)
applyHover(unlockBtn)

local status = mkLabel(content, "Locked", 13, true)
status.TextColor3 = Color3.fromRGB(255, 110, 110)
status.Position = UDim2.fromOffset(18, 112)
status.Size = UDim2.new(1, -36, 0, 18)

local flyBtn = mkButton(content, "FLY: OFF")
flyBtn.Size = UDim2.new(0.5, -24, 0, 42)
flyBtn.Position = UDim2.fromOffset(18, 142)
flyBtn.Visible = false
applyHover(flyBtn)

local upBtn = mkButton(content, "UP")
upBtn.Size = UDim2.new(0.22, -6, 0, 42)
upBtn.Position = UDim2.fromOffset(168, 142)
upBtn.Visible = false

local downBtn = mkButton(content, "DOWN")
downBtn.Size = UDim2.new(0.22, -6, 0, 42)
downBtn.Position = UDim2.fromOffset(242, 142)
downBtn.Visible = false

local info = mkLabel(content, "F = toggle flight | Space = up | Ctrl = down", 12, false)
info.TextColor3 = Color3.fromRGB(170, 170, 185)
info.Position = UDim2.fromOffset(18, 190)
info.Size = UDim2.new(1, -36, 0, 16)
info.Visible = false

local speedLabel = mkLabel(content, "Speed", 12, true)
speedLabel.TextColor3 = Color3.fromRGB(210, 200, 230)
speedLabel.Position = UDim2.fromOffset(18, 214)
speedLabel.Size = UDim2.new(1, -36, 0, 16)
speedLabel.Visible = false

local speedMinus = mkButton(content, "-")
speedMinus.Size = UDim2.fromOffset(38, 34)
speedMinus.Position = UDim2.fromOffset(18, 236)
speedMinus.Visible = false

local speedValue = mkLabel(content, tostring(flySpeed), 16, true)
speedValue.TextXAlignment = Enum.TextXAlignment.Center
speedValue.Position = UDim2.fromOffset(68, 236)
speedValue.Size = UDim2.fromOffset(60, 34)
speedValue.Visible = false

local speedPlus = mkButton(content, "+")
speedPlus.Size = UDim2.fromOffset(38, 34)
speedPlus.Position = UDim2.fromOffset(138, 236)
speedPlus.Visible = false

local hint = mkLabel(content, "Drag window from the top bar", 11, false)
hint.TextColor3 = Color3.fromRGB(160, 160, 180)
hint.TextXAlignment = Enum.TextXAlignment.Right
hint.Position = UDim2.new(1, -170, 1, -22)
hint.Size = UDim2.fromOffset(150, 14)

local function setStatus(text, color)
	status.Text = text
	status.TextColor3 = color
end

local function setUnlockedUI()
	flyBtn.Visible = true
	upBtn.Visible = true
	downBtn.Visible = true
	info.Visible = true
	speedLabel.Visible = true
	speedMinus.Visible = true
	speedValue.Visible = true
	speedPlus.Visible = true

	tween(main, {Size = UDim2.fromOffset(360, 344)}, 0.18)
	setStatus("Unlocked", Color3.fromRGB(110, 255, 160))
end

unlockBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == KEY then
		isUnlocked = true
		setUnlockedUI()
	else
		setStatus("Wrong key", Color3.fromRGB(255, 110, 110))
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	toggleFly()
	flyBtn.Text = isFlying and "FLY: ON" or "FLY: OFF"
end)

local function updateFlyButton()
	flyBtn.Text = isFlying and "FLY: ON" or "FLY: OFF"
end

local function holdBind(button, startFn, endFn)
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

holdBind(upBtn, function()
	upHeld = true
end, function()
	upHeld = false
end)

holdBind(downBtn, function()
	downHeld = true
end, function()
	downHeld = false
end)

speedMinus.MouseButton1Click:Connect(function()
	flySpeed = math.max(10, flySpeed - 10)
	speedValue.Text = tostring(flySpeed)
end)

speedPlus.MouseButton1Click:Connect(function()
	flySpeed = math.min(200, flySpeed + 10)
	speedValue.Text = tostring(flySpeed)
end)

miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		content.Visible = false
		tween(main, {Size = UDim2.fromOffset(360, 48)}, 0.18)
	else
		content.Visible = true
		tween(main, {Size = UDim2.fromOffset(360, 344)}, 0.18)
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	stopFly()
	gui:Destroy()
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		if isUnlocked then
			toggleFly()
			updateFlyButton()
		end
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

-- Dragging (мышь + тач)
do
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
end

-- tiny intro animation
main.BackgroundTransparency = 1
for _, v in ipairs(main:GetDescendants()) do
	if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
		v.TextTransparency = 1
		if v:IsA("TextButton") or v:IsA("TextBox") then
			v.BackgroundTransparency = 1
		end
	end
end

tween(main, {BackgroundTransparency = 0}, 0.22)
for _, v in ipairs(main:GetDescendants()) do
	if v:IsA("TextLabel") then
		tween(v, {TextTransparency = 0}, 0.18)
	elseif v:IsA("TextButton") then
		tween(v, {TextTransparency = 0, BackgroundTransparency = 0}, 0.18)
	elseif v:IsA("TextBox") then
		tween(v, {TextTransparency = 0, BackgroundTransparency = 0}, 0.18)
	end
end