-- 测试注入脚本 - 点击按钮变绿
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 创建测试界面
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 创建测试按钮
local testButton = Instance.new("TextButton")
testButton.Size = UDim2.new(0, 200, 0, 100)
testButton.Position = UDim2.new(0.5, -100, 0.5, -50)
testButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
testButton.Text = "点击测试\n(点击后变绿)"
testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
testButton.TextSize = 20
testButton.Font = Enum.Font.GothamBold
testButton.BorderSizePixel = 0
testButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = testButton

-- 点击事件
testButton.MouseButton1Click:Connect(function()
    testButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    testButton.Text = "✅ 注入成功！\n脚本正常工作"
    print("✅ 测试成功：按钮已点击，注入正常工作！")
end)

print("🎮 测试脚本已加载 - 请点击屏幕中央的红色按钮")
