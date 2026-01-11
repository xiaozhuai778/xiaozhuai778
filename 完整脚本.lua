-- ROBLOX 悬浮窗 UI
-- 现代化设计的游戏开发工具界面

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 配置保存
local savedConfig = {
    flySpeed = 50,
    walkSpeed = 16,
    mainFrameColor = {25, 25, 35},
    titleBarColor = {45, 45, 65},
    infoFrameColor = {35, 35, 50},
    borderColor = {255, 0, 0}
}

local function saveConfig()
    pcall(function()
        writefile("XiaoZhuaiScript_Config.json", HttpService:JSONEncode(savedConfig))
        print("✅ 配置已保存")
    end)
end

local function loadConfig()
    pcall(function()
        if isfile("XiaoZhuaiScript_Config.json") then
            savedConfig = HttpService:JSONDecode(readfile("XiaoZhuaiScript_Config.json"))
            print("✅ 配置已加载")
        end
    end)
end

loadConfig()

-- 重置人物状态函数
local function resetPlayerState()
    if player.Character then
        local character = player.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        -- 重置移动速度
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.PlatformStand = false
        end
        
        -- 清除所有飞行相关的BodyVelocity和BodyAngularVelocity
        if rootPart then
            for _, obj in pairs(rootPart:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyForce") then
                    obj:Destroy()
                end
            end
        end
        
        -- 清除其他可能的修改
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                for _, obj in pairs(part:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyForce") then
                        obj:Destroy()
                    end
                end
            end
        end
        
        print("人物状态已重置")
    end
end

-- 删除之前的悬浮窗实例并重置状态
for _, gui in pairs(playerGui:GetChildren()) do
    if gui.Name == "FloatingUI" then
        gui:Destroy()
    end
end

-- 重置人物状态（但不重置速度）
if player.Character then
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.JumpPower = 50
        humanoid.PlatformStand = false
    end
    
    if rootPart then
        for _, obj in pairs(rootPart:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyForce") then
                obj:Destroy()
            end
        end
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            for _, obj in pairs(part:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyForce") then
                    obj:Destroy()
                end
            end
        end
    end
end

-- 应用保存的配置
if player.Character and player.Character:FindFirstChild("Humanoid") then
    player.Character.Humanoid.WalkSpeed = savedConfig.walkSpeed
    print("✅ 已应用保存的速度: " .. savedConfig.walkSpeed)
end

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = savedConfig.walkSpeed
    print("✅ 角色重生，已应用保存的速度: " .. savedConfig.walkSpeed)
end)

-- 创建主界面
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloatingUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = playerGui

-- 窗口层级管理
local currentZIndex = 1
local function bringToFront(frame)
    currentZIndex = currentZIndex + 1
    frame.ZIndex = currentZIndex
    for _, child in pairs(frame:GetDescendants()) do
        if child:IsA("GuiObject") then
            child.ZIndex = currentZIndex
        end
    end
end

-- 创建缩放手柄函数
local function createResizeHandle(frame)
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeHandle.Text = "⟲"
    resizeHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
    resizeHandle.TextSize = 12
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Active = false
    resizeHandle.Parent = frame
    
    local resizeCorner = Instance.new("UICorner")
    resizeCorner.CornerRadius = UDim.new(0, 3)
    resizeCorner.Parent = resizeHandle
    
    local dragging = false
    local startSize = frame.Size
    local startPos = Vector2.new(0, 0)
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startSize = frame.Size
            startPos = Vector2.new(input.Position.X, input.Position.Y)
            bringToFront(frame)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentPos - startPos
            
            local newWidth = math.max(200, startSize.X.Offset + delta.X)
            local newHeight = math.max(150, startSize.Y.Offset + delta.Y)
            
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- 主窗口框架
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(savedConfig.mainFrameColor[1], savedConfig.mainFrameColor[2], savedConfig.mainFrameColor[3])
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- 主窗口点击置顶
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bringToFront(mainFrame)
    end
end)

-- 添加圆角和光带效果（去掉灰色阴影）
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- 流动光带边框
local lightBorder = Instance.new("UIStroke")
lightBorder.Color = Color3.fromRGB(savedConfig.borderColor[1], savedConfig.borderColor[2], savedConfig.borderColor[3])
lightBorder.Thickness = 3
lightBorder.Parent = mainFrame

-- 主窗口缩放手柄
createResizeHandle(mainFrame)

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(savedConfig.titleBarColor[1], savedConfig.titleBarColor[2], savedConfig.titleBarColor[3])
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- 缩小时的当前时间显示（左边）
local minimizedTime = Instance.new("TextLabel")
minimizedTime.Size = UDim2.new(0, 60, 1, 0)
minimizedTime.Position = UDim2.new(0, 10, 0, 0)
minimizedTime.BackgroundTransparency = 1
minimizedTime.Text = "12:00"
minimizedTime.TextColor3 = Color3.fromRGB(255, 200, 100)
minimizedTime.TextSize = 12
minimizedTime.Font = Enum.Font.GothamBold
minimizedTime.Visible = false
minimizedTime.Parent = titleBar

-- 标题文本（居中）
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -200, 1, 0)
titleLabel.Position = UDim2.new(0, 100, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "小拽脚本"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- 缩小时的FPS显示（右边）
local minimizedFPS = Instance.new("TextLabel")
minimizedFPS.Size = UDim2.new(0, 60, 1, 0)
minimizedFPS.Position = UDim2.new(1, -130, 0, 0)
minimizedFPS.BackgroundTransparency = 1
minimizedFPS.Text = "60 FPS"
minimizedFPS.TextColor3 = Color3.fromRGB(100, 255, 100)
minimizedFPS.TextSize = 12
minimizedFPS.Font = Enum.Font.GothamBold
minimizedFPS.Visible = false
minimizedFPS.Parent = titleBar

-- 最小化按钮
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0.5, 0)
minimizeCorner.Parent = minimizeBtn

-- 关闭按钮
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- 内容区域
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- 游戏信息区域（上半部分）
local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoFrame"
infoFrame.Size = UDim2.new(1, 0, 0, 150)
infoFrame.Position = UDim2.new(0, 0, 0, 0)
infoFrame.BackgroundColor3 = Color3.fromRGB(savedConfig.infoFrameColor[1], savedConfig.infoFrameColor[2], savedConfig.infoFrameColor[3])
infoFrame.BorderSizePixel = 0
infoFrame.Parent = contentFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

-- 信息标题
local infoTitle = Instance.new("TextLabel")
infoTitle.Name = "InfoTitle"
infoTitle.Size = UDim2.new(1, -20, 0, 25)
infoTitle.Position = UDim2.new(0, 10, 0, 5)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "📊 游戏信息"
infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
infoTitle.TextScaled = true
infoTitle.Font = Enum.Font.GothamBold
infoTitle.Parent = infoFrame

-- 玩家信息
local playerInfo = Instance.new("TextLabel")
playerInfo.Name = "PlayerInfo"
playerInfo.Size = UDim2.new(1, -20, 0, 25)
playerInfo.Position = UDim2.new(0, 10, 0, 30)
playerInfo.BackgroundTransparency = 1
playerInfo.Text = "玩家: " .. player.Name
playerInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
playerInfo.TextScaled = true
playerInfo.Font = Enum.Font.Gotham
playerInfo.TextXAlignment = Enum.TextXAlignment.Left
playerInfo.Parent = infoFrame

-- FPS显示
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(1, -20, 0, 25)
fpsLabel.Position = UDim2.new(0, 10, 0, 55)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "帧率: 60 FPS"
fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = infoFrame

-- 移动速度显示
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 80)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "速度: 16"
speedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = infoFrame

-- 当前时间显示
local currentTimeLabel = Instance.new("TextLabel")
currentTimeLabel.Size = UDim2.new(1, -20, 0, 25)
currentTimeLabel.Position = UDim2.new(0, 10, 0, 105)
currentTimeLabel.BackgroundTransparency = 1
currentTimeLabel.Text = "时间: 12:00:00"
currentTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
currentTimeLabel.TextScaled = true
currentTimeLabel.Font = Enum.Font.Gotham
currentTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
currentTimeLabel.Parent = infoFrame

-- 功能按钮区域（下半部分，两列布局）
local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "ButtonFrame"
buttonFrame.Size = UDim2.new(1, 0, 0, 120)
buttonFrame.Position = UDim2.new(0, 0, 0, 160)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = contentFrame

-- 飞行变量
local flying = false
local bodyVelocity = nil
local bodyAngularVelocity = nil
local flySpeed = savedConfig.flySpeed or 50

-- 飞行功能
local function toggleFly()
    flying = not flying
    
    if flying then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
            
            bodyAngularVelocity = Instance.new("BodyAngularVelocity")
            bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            bodyAngularVelocity.Parent = rootPart
            
            print("飞行模式已开启")
        end
    else
        if bodyVelocity then 
            bodyVelocity:Destroy() 
            bodyVelocity = nil
        end
        if bodyAngularVelocity then
            bodyAngularVelocity:Destroy()
            bodyAngularVelocity = nil
        end
        print("飞行模式已关闭")
    end
end

-- 屏幕左侧飞行控制按钮（可拖动，不可缩放）
local leftControlFrame = Instance.new("Frame")
leftControlFrame.Size = UDim2.new(0, 200, 0, 230)
leftControlFrame.Position = UDim2.new(0, 10, 0.5, -115)
leftControlFrame.BackgroundTransparency = 1
leftControlFrame.Visible = false
leftControlFrame.Active = true
leftControlFrame.Draggable = true
leftControlFrame.Parent = screenGui

-- 飞行控制窗口点击置顶
leftControlFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bringToFront(leftControlFrame)
    end
end)

-- 飞行速度标签
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, 0, 0, 20)
flySpeedLabel.Position = UDim2.new(0, 0, 0, 0)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "飞行速度: " .. flySpeed
flySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedLabel.TextSize = 12
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.Parent = leftControlFrame

-- 飞行速度输入框
local flySpeedInput = Instance.new("TextBox")
flySpeedInput.Size = UDim2.new(0, 80, 0, 25)
flySpeedInput.Position = UDim2.new(0, 10, 0, 20)
flySpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
flySpeedInput.Text = tostring(flySpeed)
flySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedInput.TextSize = 12
flySpeedInput.Font = Enum.Font.Gotham
flySpeedInput.BorderSizePixel = 0
flySpeedInput.Parent = leftControlFrame
local flySpeedInputCorner = Instance.new("UICorner")
flySpeedInputCorner.CornerRadius = UDim.new(0, 4)
flySpeedInputCorner.Parent = flySpeedInput

local flySpeedSetBtn = Instance.new("TextButton")
flySpeedSetBtn.Size = UDim2.new(0, 60, 0, 25)
flySpeedSetBtn.Position = UDim2.new(0, 100, 0, 20)
flySpeedSetBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
flySpeedSetBtn.Text = "设置"
flySpeedSetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedSetBtn.TextSize = 12
flySpeedSetBtn.Font = Enum.Font.GothamBold
flySpeedSetBtn.BorderSizePixel = 0
flySpeedSetBtn.Parent = leftControlFrame
local flySpeedSetBtnCorner = Instance.new("UICorner")
flySpeedSetBtnCorner.CornerRadius = UDim.new(0, 4)
flySpeedSetBtnCorner.Parent = flySpeedSetBtn

flySpeedSetBtn.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(flySpeedInput.Text)
    if newSpeed and newSpeed > 0 then
        flySpeed = newSpeed
        flySpeedLabel.Text = "飞行速度: " .. flySpeed
        savedConfig.flySpeed = flySpeed
        saveConfig()
    else
        flySpeedInput.Text = tostring(flySpeed)
    end
end)

-- 开启/关闭飞天按钮（最上方中央）
local toggleFlyBtn = Instance.new("TextButton")
toggleFlyBtn.Size = UDim2.new(0, 120, 0, 35)
toggleFlyBtn.Position = UDim2.new(0, 40, 0, 50)
toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
toggleFlyBtn.Text = "开启飞天"
toggleFlyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleFlyBtn.TextSize = 14
toggleFlyBtn.Font = Enum.Font.GothamBold
toggleFlyBtn.BorderSizePixel = 0
toggleFlyBtn.Parent = leftControlFrame

local toggleFlyCorner = Instance.new("UICorner")
toggleFlyCorner.CornerRadius = UDim.new(0, 8)
toggleFlyCorner.Parent = toggleFlyBtn

-- 上下控制（左边）
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 80, 0, 40)
upBtn.Position = UDim2.new(0, 0, 0, 95)
upBtn.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
upBtn.Text = "上升\n(空格)"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.TextSize = 12
upBtn.Font = Enum.Font.GothamBold
upBtn.BorderSizePixel = 0
upBtn.Parent = leftControlFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = upBtn

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 80, 0, 40)
downBtn.Position = UDim2.new(0, 0, 0, 145)
downBtn.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
downBtn.Text = "下降\n(C键)"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 12
downBtn.Font = Enum.Font.GothamBold
downBtn.BorderSizePixel = 0
downBtn.Parent = leftControlFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = downBtn

-- 前后控制（右边）
local forwardBtn = Instance.new("TextButton")
forwardBtn.Size = UDim2.new(0, 80, 0, 40)
forwardBtn.Position = UDim2.new(0, 100, 0, 95)
forwardBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
forwardBtn.Text = "前进\n(W键)"
forwardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
forwardBtn.TextSize = 12
forwardBtn.Font = Enum.Font.GothamBold
forwardBtn.BorderSizePixel = 0
forwardBtn.Parent = leftControlFrame

local forwardCorner = Instance.new("UICorner")
forwardCorner.CornerRadius = UDim.new(0, 8)
forwardCorner.Parent = forwardBtn

local backwardBtn = Instance.new("TextButton")
backwardBtn.Size = UDim2.new(0, 80, 0, 40)
backwardBtn.Position = UDim2.new(0, 100, 0, 145)
backwardBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
backwardBtn.Text = "后退\n(S键)"
backwardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backwardBtn.TextSize = 12
backwardBtn.Font = Enum.Font.GothamBold
backwardBtn.BorderSizePixel = 0
backwardBtn.Parent = leftControlFrame

local backwardCorner = Instance.new("UICorner")
backwardCorner.CornerRadius = UDim.new(0, 8)
backwardCorner.Parent = backwardBtn

-- 持续性飞行控制
local flyingUp = false
local flyingDown = false
local flyingForward = false
local flyingBackward = false

-- 开启/关闭飞天按钮
toggleFlyBtn.MouseButton1Click:Connect(function()
    toggleFly()
    if flying then
        toggleFlyBtn.Text = "关闭飞天"
        toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
        toggleFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleFlyBtn.Text = "开启飞天"
        toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
        toggleFlyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- 上升按钮
upBtn.MouseButton1Down:Connect(function()
    flyingUp = true
end)
upBtn.MouseButton1Up:Connect(function()
    flyingUp = false
end)

-- 下降按钮
downBtn.MouseButton1Down:Connect(function()
    flyingDown = true
end)
downBtn.MouseButton1Up:Connect(function()
    flyingDown = false
end)

-- 前进按钮
forwardBtn.MouseButton1Down:Connect(function()
    flyingForward = true
end)
forwardBtn.MouseButton1Up:Connect(function()
    flyingForward = false
end)

-- 后退按钮
backwardBtn.MouseButton1Down:Connect(function()
    flyingBackward = true
end)
backwardBtn.MouseButton1Up:Connect(function()
    flyingBackward = false
end)

-- 飞行控制循环
local function flyControl()
    if not flying or not bodyVelocity then return end
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new(0, 0, 0)
    
    -- 按钮控制
    if flyingUp then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if flyingDown then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    if flyingForward then
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if flyingBackward then
        moveVector = moveVector - camera.CFrame.LookVector
    end
    
    -- 键盘控制（电脑专用）
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.C) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + camera.CFrame.RightVector
    end
    
    bodyVelocity.Velocity = moveVector * flySpeed
end

-- 启动飞行控制循环
RunService.Heartbeat:Connect(flyControl)

-- 移速设置窗口（可拖动，可缩放）
local speedWindow = Instance.new("Frame")
speedWindow.Size = UDim2.new(0, 400, 0, 500)
speedWindow.Position = UDim2.new(0, 370, 0, 20)
speedWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedWindow.BorderSizePixel = 0
speedWindow.Visible = false
speedWindow.Active = true
speedWindow.Draggable = true
speedWindow.Parent = screenGui

-- 移速窗口点击置顶
speedWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bringToFront(speedWindow)
    end
end)

local speedWindowCorner = Instance.new("UICorner")
speedWindowCorner.CornerRadius = UDim.new(0, 10)
speedWindowCorner.Parent = speedWindow

local speedWindowBorder = Instance.new("UIStroke")
speedWindowBorder.Color = Color3.fromRGB(220, 53, 69)
speedWindowBorder.Thickness = 2
speedWindowBorder.Parent = speedWindow

-- 移速窗口缩放手柄
createResizeHandle(speedWindow)

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -25, 0, 30)
speedTitle.Position = UDim2.new(0, 5, 0, 5)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "⚡ 移动速度设置"
speedTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
speedTitle.TextSize = 14
speedTitle.Font = Enum.Font.GothamBold
speedTitle.Parent = speedWindow

local speedCloseBtn = Instance.new("TextButton")
speedCloseBtn.Size = UDim2.new(0, 20, 0, 20)
speedCloseBtn.Position = UDim2.new(1, -25, 0, 5)
speedCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
speedCloseBtn.Text = "×"
speedCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedCloseBtn.TextSize = 12
speedCloseBtn.BorderSizePixel = 0
speedCloseBtn.Parent = speedWindow

local speedCloseBtnCorner = Instance.new("UICorner")
speedCloseBtnCorner.CornerRadius = UDim.new(0, 3)
speedCloseBtnCorner.Parent = speedCloseBtn

-- 滚动框
local speedScrollFrame = Instance.new("ScrollingFrame")
speedScrollFrame.Size = UDim2.new(1, -20, 1, -80)
speedScrollFrame.Position = UDim2.new(0, 10, 0, 40)
speedScrollFrame.BackgroundTransparency = 1
speedScrollFrame.ScrollBarThickness = 8
speedScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
speedScrollFrame.Parent = speedWindow

-- 预设速度
local speedValues = {100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 2000, 3000, 4000}

for i, speed in ipairs(speedValues) do
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(0, 180, 0, 35)
    speedBtn.Position = UDim2.new(0, 10 + ((i-1) % 2) * 190, 0, 10 + math.floor((i-1) / 2) * 45)
    speedBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    speedBtn.Text = "速度: " .. speed
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.TextSize = 12
    speedBtn.Font = Enum.Font.Gotham
    speedBtn.BorderSizePixel = 0
    speedBtn.Parent = speedScrollFrame
    
    local speedBtnCorner = Instance.new("UICorner")
    speedBtnCorner.CornerRadius = UDim.new(0, 5)
    speedBtnCorner.Parent = speedBtn
    
    speedBtn.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = speed
            savedConfig.walkSpeed = speed
            saveConfig()
            print("移动速度已设置为: " .. speed)
        end
    end)
end

-- 自定义移速区域
local customSpeedFrame = Instance.new("Frame")
customSpeedFrame.Size = UDim2.new(1, -20, 0, 80)
customSpeedFrame.Position = UDim2.new(0, 10, 0, 470)
customSpeedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
customSpeedFrame.BorderSizePixel = 0
customSpeedFrame.Parent = speedScrollFrame

local customSpeedCorner = Instance.new("UICorner")
customSpeedCorner.CornerRadius = UDim.new(0, 8)
customSpeedCorner.Parent = customSpeedFrame

local customSpeedLabel = Instance.new("TextLabel")
customSpeedLabel.Size = UDim2.new(1, 0, 0, 25)
customSpeedLabel.Position = UDim2.new(0, 0, 0, 5)
customSpeedLabel.BackgroundTransparency = 1
customSpeedLabel.Text = "自定义移速"
customSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
customSpeedLabel.TextSize = 14
customSpeedLabel.Font = Enum.Font.GothamBold
customSpeedLabel.Parent = customSpeedFrame

local customSpeedInput = Instance.new("TextBox")
customSpeedInput.Size = UDim2.new(0, 200, 0, 30)
customSpeedInput.Position = UDim2.new(0, 10, 0, 30)
customSpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
customSpeedInput.Text = "输入速度值"
customSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
customSpeedInput.TextSize = 12
customSpeedInput.Font = Enum.Font.Gotham
customSpeedInput.BorderSizePixel = 0
customSpeedInput.Parent = customSpeedFrame

local customSpeedInputCorner = Instance.new("UICorner")
customSpeedInputCorner.CornerRadius = UDim.new(0, 5)
customSpeedInputCorner.Parent = customSpeedInput

local customSpeedSetBtn = Instance.new("TextButton")
customSpeedSetBtn.Size = UDim2.new(0, 80, 0, 30)
customSpeedSetBtn.Position = UDim2.new(0, 220, 0, 30)
customSpeedSetBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
customSpeedSetBtn.Text = "设置"
customSpeedSetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
customSpeedSetBtn.TextSize = 12
customSpeedSetBtn.Font = Enum.Font.GothamBold
customSpeedSetBtn.BorderSizePixel = 0
customSpeedSetBtn.Parent = customSpeedFrame

local customSpeedSetBtnCorner = Instance.new("UICorner")
customSpeedSetBtnCorner.CornerRadius = UDim.new(0, 5)
customSpeedSetBtnCorner.Parent = customSpeedSetBtn

customSpeedSetBtn.MouseButton1Click:Connect(function()
    local speedValue = tonumber(customSpeedInput.Text)
    if speedValue and speedValue > 0 then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = speedValue
            savedConfig.walkSpeed = speedValue
            saveConfig()
            print("自定义移动速度已设置为: " .. speedValue)
        end
    else
        print("请输入有效的数字")
    end
end)

-- 颜色选择窗口（可拖动，可缩放）
local colorWindow = Instance.new("Frame")
colorWindow.Size = UDim2.new(0, 320, 0, 300)
colorWindow.Position = UDim2.new(0, 370, 0, 20)
colorWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
colorWindow.BorderSizePixel = 0
colorWindow.Visible = false
colorWindow.Active = true
colorWindow.Draggable = true
colorWindow.Parent = screenGui

-- 颜色窗口点击置顶
colorWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bringToFront(colorWindow)
    end
end)

local colorWindowCorner = Instance.new("UICorner")
colorWindowCorner.CornerRadius = UDim.new(0, 10)
colorWindowCorner.Parent = colorWindow

local colorWindowBorder = Instance.new("UIStroke")
colorWindowBorder.Color = Color3.fromRGB(138, 43, 226)
colorWindowBorder.Thickness = 2
colorWindowBorder.Parent = colorWindow

-- 颜色窗口缩放手柄
createResizeHandle(colorWindow)

local colorTitle = Instance.new("TextLabel")
colorTitle.Size = UDim2.new(1, -25, 0, 30)
colorTitle.Position = UDim2.new(0, 5, 0, 5)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "🎨 自定义悬浮窗颜色"
colorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
colorTitle.TextSize = 14
colorTitle.Font = Enum.Font.GothamBold
colorTitle.Parent = colorWindow

local colorCloseBtn = Instance.new("TextButton")
colorCloseBtn.Size = UDim2.new(0, 20, 0, 20)
colorCloseBtn.Position = UDim2.new(1, -25, 0, 5)
colorCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
colorCloseBtn.Text = "×"
colorCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
colorCloseBtn.TextSize = 12
colorCloseBtn.BorderSizePixel = 0
colorCloseBtn.Parent = colorWindow

local colorCloseBtnCorner = Instance.new("UICorner")
colorCloseBtnCorner.CornerRadius = UDim.new(0, 3)
colorCloseBtnCorner.Parent = colorCloseBtn

-- 更多颜色选择
local colors = {
    {Color3.fromRGB(100, 200, 255), "天空蓝"},
    {Color3.fromRGB(255, 100, 100), "樱花红"},
    {Color3.fromRGB(100, 255, 100), "翡翠绿"},
    {Color3.fromRGB(255, 200, 100), "夕阳橙"},
    {Color3.fromRGB(200, 100, 255), "薰衣紫"},
    {Color3.fromRGB(255, 255, 100), "柠檬黄"},
    {Color3.fromRGB(255, 150, 200), "粉玫瑰"},
    {Color3.fromRGB(150, 255, 200), "薄荷绿"},
    {Color3.fromRGB(200, 255, 150), "青草绿"},
    {Color3.fromRGB(255, 200, 150), "蜜桃橙"},
    {Color3.fromRGB(150, 200, 255), "海洋蓝"},
    {Color3.fromRGB(255, 150, 255), "梦幻紫"}
}

for i, colorData in ipairs(colors) do
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 95, 0, 35)
    colorBtn.Position = UDim2.new(0, 10 + ((i-1) % 3) * 105, 0, 40 + math.floor((i-1) / 3) * 45)
    colorBtn.BackgroundColor3 = colorData[1]
    colorBtn.Text = colorData[2]
    colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorBtn.TextSize = 10
    colorBtn.Font = Enum.Font.Gotham
    colorBtn.BorderSizePixel = 0
    colorBtn.Parent = colorWindow
    
    local colorBtnCorner = Instance.new("UICorner")
    colorBtnCorner.CornerRadius = UDim.new(0, 5)
    colorBtnCorner.Parent = colorBtn
    
    colorBtn.MouseButton1Click:Connect(function()
        mainFrame.BackgroundColor3 = colorData[1]
        titleBar.BackgroundColor3 = Color3.new(colorData[1].R * 0.8, colorData[1].G * 0.8, colorData[1].B * 0.8)
        infoFrame.BackgroundColor3 = Color3.new(colorData[1].R * 0.6, colorData[1].G * 0.6, colorData[1].B * 0.6)
        lightBorder.Color = colorData[1]
        savedConfig.mainFrameColor = {math.floor(colorData[1].R * 255), math.floor(colorData[1].G * 255), math.floor(colorData[1].B * 255)}
        savedConfig.titleBarColor = {math.floor(colorData[1].R * 0.8 * 255), math.floor(colorData[1].G * 0.8 * 255), math.floor(colorData[1].B * 0.8 * 255)}
        savedConfig.infoFrameColor = {math.floor(colorData[1].R * 0.6 * 255), math.floor(colorData[1].G * 0.6 * 255), math.floor(colorData[1].B * 0.6 * 255)}
        savedConfig.borderColor = {math.floor(colorData[1].R * 255), math.floor(colorData[1].G * 255), math.floor(colorData[1].B * 255)}
        saveConfig()
        print("颜色已更改为: " .. colorData[2])
    end)
end

-- 创建两列按钮函数
local function createSmallButton(text, color, icon, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 155, 0, 35)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = icon .. " " .. text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = buttonFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(color.R + 0.1, color.G + 0.1, color.B + 0.1)})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color})
        tween:Play()
    end)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

-- 创建两列三个按钮
createSmallButton("飞行模式", Color3.fromRGB(0, 123, 255), "✈️", UDim2.new(0, 5, 0, 5), function()
    leftControlFrame.Visible = not leftControlFrame.Visible
end)

createSmallButton("移速设置", Color3.fromRGB(220, 53, 69), "⚡", UDim2.new(0, 170, 0, 5), function()
    speedWindow.Visible = not speedWindow.Visible
    colorWindow.Visible = false
end)

createSmallButton("自定义颜色", Color3.fromRGB(138, 43, 226), "🎨", UDim2.new(0, 87.5, 0, 50), function()
    colorWindow.Visible = not colorWindow.Visible
    speedWindow.Visible = false
end)

-- 功能实现
local isMinimized = false
local frameCount = 0
local lastTime = tick()

-- 光带颜色数组
local lightColors = {
    Color3.fromRGB(255, 100, 100),
    Color3.fromRGB(255, 200, 100),
    Color3.fromRGB(255, 255, 100),
    Color3.fromRGB(100, 255, 100),
    Color3.fromRGB(100, 200, 255),
    Color3.fromRGB(200, 100, 255),
}

local colorIndex = 1
local colorProgress = 0

-- 最小化功能
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 350, 0, 40) or UDim2.new(0, 350, 0, 450)
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize})
    tween:Play()
    
    contentFrame.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "—"
    minimizedFPS.Visible = isMinimized
    minimizedTime.Visible = isMinimized
end)

-- 关闭功能
closeBtn.MouseButton1Click:Connect(function()
    if flying then 
        toggleFly()
        leftControlFrame.Visible = false
    end
    -- 关闭时重置人物状态
    resetPlayerState()
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

speedCloseBtn.MouseButton1Click:Connect(function()
    speedWindow.Visible = false
end)

colorCloseBtn.MouseButton1Click:Connect(function()
    colorWindow.Visible = false
end)

-- 实时更新信息和光带流动效果
RunService.Heartbeat:Connect(function(deltaTime)
    frameCount = frameCount + 1
    local currentTime = tick()
    
    -- 更新FPS
    if currentTime - lastTime >= 1 then
        local fps = math.floor(frameCount / (currentTime - lastTime))
        fpsLabel.Text = "帧率: " .. fps .. " FPS"
        minimizedFPS.Text = fps .. " FPS"
        frameCount = 0
        lastTime = currentTime
    end
    
    -- 更新移动速度
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local speed = player.Character.Humanoid.WalkSpeed
        speedLabel.Text = "速度: " .. math.floor(speed)
    end
    
    -- 更新当前时间
    local realTime = os.date("*t")
    local timeString = string.format("%02d:%02d:%02d", realTime.hour, realTime.min, realTime.sec)
    currentTimeLabel.Text = "时间: " .. timeString
    
    -- 缩小时显示简化时间
    local shortTime = string.format("%02d:%02d", realTime.hour, realTime.min)
    minimizedTime.Text = shortTime
    
    -- 光带流动效果
    colorProgress = colorProgress + deltaTime * 2
    
    if colorProgress >= 1 then
        colorIndex = colorIndex + 1
        if colorIndex > #lightColors then
            colorIndex = 1
        end
        colorProgress = 0
    end
    
    local currentColor = lightColors[colorIndex]
    local nextIndex = colorIndex + 1
    if nextIndex > #lightColors then
        nextIndex = 1
    end
    local nextColor = lightColors[nextIndex]
    
    local r = currentColor.R + (nextColor.R - currentColor.R) * colorProgress
    local g = currentColor.G + (nextColor.G - currentColor.G) * colorProgress
    local b = currentColor.B + (nextColor.B - currentColor.B) * colorProgress
    
    lightBorder.Color = Color3.new(r, g, b)
end)

-- 添加淡入动画
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 350, 0, 450),
    Position = UDim2.new(0.5, -175, 0.5, -225)
})
openTween:Play()

print("🎮 小拽脚本已加载完成! - 人物状态已重置")


-- ========== 吃吃世界功能 ==========
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local LocalPlayer = Players.LocalPlayer

local autofarm = false
local autoCollectingCubes = false
local autoClaimRewards = false
local farmMoving = false
local showMap = false
local autoeat = false
local autoUpgradeSize = false
local autoUpgradeSpd = false
local autoUpgradeMulti = false
local autoUpgradeEat = false
local keepUnanchor = false
local boundProtect = false

local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function checkLoaded()
    return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Size") and LocalPlayer.Character:FindFirstChild("Events") and LocalPlayer.Character.Events:FindFirstChild("Grab") and LocalPlayer.Character.Events:FindFirstChild("Eat") and LocalPlayer.Character.Events:FindFirstChild("Sell") and LocalPlayer.Character:FindFirstChild("CurrentChunk")) ~= nil
end

local function changeMap()
    local args = {{MapTime = -1, Paused = true}}
    Events.SetServerSettings:FireServer(unpack(args))
end

local function sizeGrowth(level) return math.floor(((level + 0.5) ^ 2 - 0.25) / 2 * 100) end
local function speedGrowth(level) return math.floor(level * 2 + 10) end
local function multiplierGrowth(level) return math.floor(level) end
local function eatSpeedGrowth(level) return math.floor((1 + (level - 1) * 0.2) * 10) / 10 end
local function sizePrice(level) return math.floor(level ^ 3 / 2) * 20 end
local function speedPrice(level) return math.floor((level * 3) ^ 3 / 200) * 1000 end
local function multiplierPrice(level) return math.floor((level * 10) ^ 3 / 200) * 1000 end
local function eatSpeedPrice(level) return math.floor((level * 10) ^ 3 / 200) * 2000 end

local function createEatWorldWindow(title, width, height)
    local popup = Instance.new("Frame")
    popup.Name = title .. "Window"
    popup.Size = UDim2.new(0, width, 0, height)
    popup.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    popup.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.Active = true
    popup.Draggable = true
    popup.Parent = screenGui
    popup.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then bringToFront(popup) end
    end)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = popup
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(100, 150, 255)
    border.Thickness = 2
    border.Parent = popup
    createResizeHandle(popup)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = popup
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -32, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function() popup.Visible = false end)
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = popup
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    return popup, content
end

local function createEatToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 45, 0, 25)
    toggle.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 19, 0, 19)
    indicator.Position = UDim2.new(0, 3, 0.5, -9.5)
    indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            indicator.Position = UDim2.new(1, -22, 0.5, -9.5)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            indicator.Position = UDim2.new(0, 3, 0.5, -9.5)
        end
        callback(enabled)
    end)
    return frame
end

local function createEatButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    button.MouseButton1Click:Connect(callback)
    button.MouseEnter:Connect(function() button.BackgroundColor3 = Color3.fromRGB(80, 80, 100) end)
    button.MouseLeave:Connect(function() button.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end)
    return button
end

local autoWindow, autoContent = createEatWorldWindow("自动", 300, 400)

createEatToggle(autoContent, "自动刷", function(enabled)
    autofarm = enabled
    coroutine.wrap(function()
    	local text = Drawing.new("Text")
    	text.Outline = true
    	text.OutlineColor = Color3.new(0, 0, 0)
    	text.Color = Color3.new(1, 1, 1)
    	text.Center = false
    	text.Position = Vector2.new(64, 64)
    	text.Text = ""
    	text.Size = 14
    	text.Visible = true
    	local startTime = tick()
    	local eatTime = 0
    	local lastEatTime = tick()
        local timer = 0
        local grabTimer = 0
        local sellDebounce = false
        local sellCount = 0
        local bedrock = Instance.new("Part")
        bedrock.Anchored = true
        bedrock.Size = Vector3.new(2048, 10, 2048)
        bedrock.Position = Vector3.new(0, -5, 0)
        bedrock.BrickColor = BrickColor.Black()
        bedrock.Parent = workspace
        local map, chunks = workspace:FindFirstChild("Map"), workspace:FindFirstChild("Chunks")
        if map and chunks then map.Parent, chunks.Parent = nil, nil end
        local numChunks = 0
        local hum, root, size, events, eat, grab, sell, sendTrack, chunk, radius, autoConn, sizeConn
        local function onCharAdd(char)
            numChunks = 0
            hum = char:WaitForChild("Humanoid")
            root = char:WaitForChild("HumanoidRootPart")
            size = char:WaitForChild("Size")
            events = char:WaitForChild("Events")
            eat = events:WaitForChild("Eat")
            grab = events:WaitForChild("Grab")
            sell = events:WaitForChild("Sell")
            chunk = char:WaitForChild("CurrentChunk")
            sendTrack = char:WaitForChild("SendTrack")
            radius = char:WaitForChild("Radius")
            autoConn = game["Run Service"].Heartbeat:Connect(function(dt)
                if not autofarm then autoConn:Disconnect() return end
                local ran = tick() - startTime
                local hours = math.floor(ran / 60 / 60)
                local minutes = math.floor(ran / 60)
                local seconds = math.floor(ran)
                local eatMinutes = math.floor(eatTime / 60)
                local eatSeconds = math.floor(eatTime)
                local y = bedrock.Position.Y + bedrock.Size.Y / 2 + hum.HipHeight + root.Size.Y / 2
                local sizeAdd = LocalPlayer.Upgrades.Multiplier.Value / 100
                local addAmount = LocalPlayer.Upgrades.MaxSize.Value / sizeAdd
                local sellTime = addAmount / 2
                local sellMinutes = math.floor(sellTime / 60)
                local sellSeconds = math.floor(sellTime)
                local secondEarn = math.floor(sizeGrowth(LocalPlayer.Upgrades.MaxSize.Value) / sellTime)
                local minuteEarn = secondEarn * 60
                local hourEarn = minuteEarn * 60
                local dayEarn = hourEarn * 24
                text.Text = "\n运行时间: " .. string.format("%ih%im%is", hours, minutes % 60, seconds % 60) .. "\n实际时间: " .. string.format("%im%is", eatMinutes % 60, eatSeconds % 60) .. "\n大约时间: " .. string.format("%im%is", sellMinutes % 60, sellSeconds % 60) .. "\n每天: " .. dayEarn .. "\n块数: " .. numChunks
                hum:ChangeState(Enum.HumanoidStateType.Physics)
                grab:FireServer()
                root.Anchored = false
                eat:FireServer()
                sendTrack:FireServer()
                if chunk.Value then
                    if timer > 0 then numChunks += 1 end
                    timer = 0
                    grabTimer += dt
                else
                    timer += dt
                    grabTimer = 0
                end
                if timer > 60 then hum.Health = 0 timer = 0 numChunks = 0 end
                if grabTimer > 15 then size.Value = LocalPlayer.Upgrades.MaxSize.Value end
                if (size.Value >= LocalPlayer.Upgrades.MaxSize.Value) or timer > 8 then
                    if timer < 8 then
                        sell:FireServer()
                        if not sellDebounce then changeMap() end
                        sellDebounce = true
                    else
                        changeMap()
                    end
                    numChunks = 0
                elseif size.Value == 0 then
                    if sellDebounce then
                        local currentEatTime = tick()
                        eatTime = currentEatTime - lastEatTime
                        lastEatTime = currentEatTime
                        sellCount += 1
                    end
                    sellDebounce = false
                end
                if farmMoving then
                    local bound = 300
                    local startPos = CFrame.new(-bound/2, y, -bound/2)
                    local r = radius.Value * 1.1
                    local dist = (r * numChunks)
                    local x = dist % bound
                    local z = math.floor(dist / bound) * r
                    local offset = CFrame.new(x, 0, z + r * 2)
                    if z > bound then changeMap() numChunks = 0 end
                    root.CFrame = startPos * offset
                else
                    root.CFrame = CFrame.new(0, y, 0)
                end
            end)
            hum.Died:Connect(function() autoConn:Disconnect() changeMap() end)
            char:WaitForChild("LocalChunkManager").Enabled = false
            char:WaitForChild("Animate").Enabled = false
        end
        if LocalPlayer.Character then task.spawn(onCharAdd, LocalPlayer.Character) else task.spawn(onCharAdd, LocalPlayer.CharacterAdded:Wait()) end
        local charAddConn = LocalPlayer.CharacterAdded:Connect(onCharAdd)
        while autofarm do
            local dt = task.wait()
            if workspace:FindFirstChild("Loading") then workspace.Loading:Destroy() end
            if map and chunks then
                if showMap then map.Parent, chunks.Parent = workspace, workspace else map.Parent, chunks.Parent = nil, nil end
            end
        end
        charAddConn:Disconnect()
        if autoConn then autoConn:Disconnect() end
        if map and chunks then map.Parent, chunks.Parent = workspace, workspace end
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        bedrock:Destroy()
        LocalPlayer.Character.LocalChunkManager.Enabled = true
        LocalPlayer.Character.Animate.Enabled = true
        text:Destroy()
    end)()
end)

createEatToggle(autoContent, "自动收", function(enabled)
    autoCollectingCubes = enabled
    coroutine.wrap(function()
        LocalPlayer.PlayerScripts.CubeVis.Enabled = false
        while autoCollectingCubes do
            task.wait()
            local root = getRoot()
            if root then
                for _, v in workspace:GetChildren() do
                    if v.Name == "Cube" and v:FindFirstChild("Owner") and (v.Owner.Value == LocalPlayer.Name or v.Owner.Value == "") then
                        v.CFrame = root.CFrame
                    end
                end
            end
        end
        LocalPlayer.PlayerScripts.CubeVis.Enabled = true
    end)()
end)

createEatToggle(autoContent, "自动领", function(enabled)
    autoClaimRewards = enabled
    coroutine.wrap(function()
        while autoClaimRewards do
            task.wait(1)
            for _, reward in LocalPlayer.TimedRewards:GetChildren() do
                if reward.Value > 0 then Events.RewardEvent:FireServer(reward) end
            end
            Events.SpinEvent:FireServer()
        end
    end)()
end)

createEatToggle(autoContent, "移动模式", function(enabled) farmMoving = enabled end)
createEatToggle(autoContent, "显示地图", function(enabled) showMap = enabled end)

createEatToggle(autoContent, "自动吃", function(enabled)
    autoeat = enabled
    coroutine.wrap(function()
        while autoeat do
            local dt = task.wait()
            if checkLoaded() then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                LocalPlayer.Character.Events.Grab:FireServer()
                LocalPlayer.Character.Events.Eat:FireServer()
            end
        end
    end)()
end)

local upgradeWindow, upgradeContent = createEatWorldWindow("升级", 300, 300)

createEatToggle(upgradeContent, "大小", function(enabled)
    autoUpgradeSize = enabled
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeSize do task.wait(1) Events.PurchaseEvent:FireServer("MaxSize") end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

createEatToggle(upgradeContent, "移速", function(enabled)
    autoUpgradeSpd = enabled
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeSpd do task.wait(1) Events.PurchaseEvent:FireServer("Speed") end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

createEatToggle(upgradeContent, "乘数", function(enabled)
    autoUpgradeMulti = enabled
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeMulti do task.wait(1) Events.PurchaseEvent:FireServer("Multiplier") end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

createEatToggle(upgradeContent, "吃速", function(enabled)
    autoUpgradeEat = enabled
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeEat do task.wait(1) Events.PurchaseEvent:FireServer("EatSpeed") end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

local figureWindow, figureContent = createEatWorldWindow("人物", 300, 250)

createEatToggle(figureContent, "取消锚固", function(enabled)
    keepUnanchor = enabled
    coroutine.wrap(function()
        while keepUnanchor do
            task.wait()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end)()
end)

createEatToggle(figureContent, "边界保护", function(enabled)
    boundProtect = enabled
    coroutine.wrap(function()
        while boundProtect do
            task.wait()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                local pos = root.Position
                local mapSize = workspace.Map.Bedrock.Size * Vector3.new(1, 0, 1)
                local clampedPos = Vector3.new(math.clamp(pos.X, -mapSize.X / 2, mapSize.X / 2), pos.Y, math.clamp(pos.Z, -mapSize.Z / 2, mapSize.Z / 2))
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(clampedPos) * root.CFrame.Rotation
            end
        end
    end)()
end)

local otherWindow, otherContent = createEatWorldWindow("其它", 300, 250)

createEatButton(otherContent, "查看玩家数据", function()
    local localization = {MaxSize = "体积", Speed = "移速", Multiplier = "乘数", EatSpeed = "吃速"}
    local growthFunctions = {MaxSize = sizeGrowth, Speed = speedGrowth, Multiplier = multiplierGrowth, EatSpeed = eatSpeedGrowth}
    local priceFunctions = {MaxSize = sizePrice, Speed = speedPrice, Multiplier = multiplierPrice, EatSpeed = eatSpeedPrice}
    for _, player in Players:GetPlayers() do
        print()
        for _, upg in player.Upgrades:GetChildren() do
            local content = player.Name .. "："
            local cost = 0
            for l = 2, upg.Value do cost += priceFunctions[upg.Name](l) end
            content = content .. " " .. localization[upg.Name] .. "：" .. upg.Value .. "级；" .. growthFunctions[upg.Name](upg.Value) .. "值；" .. cost .. "花费；"
            print(content)
        end
    end
    game.StarterGui:SetCore("DevConsoleVisible", true)
end)

createEatToggle(otherContent, "竖屏", function(enabled)
    LocalPlayer.PlayerGui.ScreenOrientation = enabled and Enum.ScreenOrientation.Portrait or Enum.ScreenOrientation.LandscapeRight
end)

buttonFrame.Size = UDim2.new(1, 0, 0, 210)

local eatWorldY = 95
createSmallButton("自动", Color3.fromRGB(255, 165, 0), "🤖", UDim2.new(0, 5, 0, eatWorldY), function()
    autoWindow.Visible = not autoWindow.Visible
    speedWindow.Visible = false
    colorWindow.Visible = false
    upgradeWindow.Visible = false
    figureWindow.Visible = false
    otherWindow.Visible = false
end)

createSmallButton("升级", Color3.fromRGB(34, 139, 34), "⬆️", UDim2.new(0, 170, 0, eatWorldY), function()
    upgradeWindow.Visible = not upgradeWindow.Visible
    speedWindow.Visible = false
    colorWindow.Visible = false
    autoWindow.Visible = false
    figureWindow.Visible = false
    otherWindow.Visible = false
end)

createSmallButton("人物", Color3.fromRGB(138, 43, 226), "👤", UDim2.new(0, 5, 0, eatWorldY + 45), function()
    figureWindow.Visible = not figureWindow.Visible
    speedWindow.Visible = false
    colorWindow.Visible = false
    autoWindow.Visible = false
    upgradeWindow.Visible = false
    otherWindow.Visible = false
end)

createSmallButton("其它", Color3.fromRGB(70, 130, 180), "📋", UDim2.new(0, 170, 0, eatWorldY + 45), function()
    otherWindow.Visible = not otherWindow.Visible
    speedWindow.Visible = false
    colorWindow.Visible = false
    autoWindow.Visible = false
    upgradeWindow.Visible = false
    figureWindow.Visible = false
end)

print("🎮 小拽脚本 + 吃吃世界功能已加载完成!")


-- 重置所有功能函数
local function resetAllFeatures()
    if flying then
        flying = false
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyAngularVelocity then bodyAngularVelocity:Destroy() bodyAngularVelocity = nil end
        toggleFlyBtn.Text = "开启飞天"
        toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
        toggleFlyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        leftControlFrame.Visible = false
    end
    autofarm = false
    autoCollectingCubes = false
    autoClaimRewards = false
    farmMoving = false
    showMap = false
    autoeat = false
    autoUpgradeSize = false
    autoUpgradeSpd = false
    autoUpgradeMulti = false
    autoUpgradeEat = false
    keepUnanchor = false
    boundProtect = false
    resetPlayerState()
    local map, chunks = workspace:FindFirstChild("Map"), workspace:FindFirstChild("Chunks")
    if map and chunks and (map.Parent == nil or chunks.Parent == nil) then
        map.Parent, chunks.Parent = workspace, workspace
    end
    if player.Character then
        local localChunkManager = player.Character:FindFirstChild("LocalChunkManager")
        local animate = player.Character:FindFirstChild("Animate")
        if localChunkManager then localChunkManager.Enabled = true end
        if animate then animate.Enabled = true end
    end
    print("✅ 所有功能已重置")
end

buttonFrame.Size = UDim2.new(1, 0, 0, 255)

createSmallButton("重置功能", Color3.fromRGB(220, 53, 69), "🔄", UDim2.new(0, 87.5, 0, eatWorldY + 90), function()
    resetAllFeatures()
end)
