local ui = Instance.new("ScreenGui")
ui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Parent = ui
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local script1Button = Instance.new("TextButton")
script1Button.Parent = frame
script1Button.Size = UDim2.new(0, 280, 0, 50)
script1Button.Position = UDim2.new(0, 10, 0, 20)
script1Button.Text = "تشغيل السكربت الأول"
script1Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
script1Button.TextColor3 = Color3.fromRGB(255, 255, 255)

local script2Button = Instance.new("TextButton")
script2Button.Parent = frame
script2Button.Size = UDim2.new(0, 280, 0, 50)
script2Button.Position = UDim2.new(0, 10, 0, 80)
script2Button.Text = "تشغيل السكربت الثاني"
script2Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
script2Button.TextColor3 = Color3.fromRGB(255, 255, 255)

-- تشغيل السكربت الأول عند الضغط على الزر
script1Button.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/script1.lua"))()
end)

-- تشغيل السكربت الثاني عند الضغط على الزر
script2Button.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/script2.lua"))()
end)
