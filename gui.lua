local UserInputService = game:GetService("UserInputService")

-- إنشاء ScreenGui
local ui = Instance.new("ScreenGui")
ui.Parent = game.CoreGui
ui.Name = "CustomGUI"

-- إنشاء الإطار الرئيسي
local frame = Instance.new("Frame")
frame.Parent = ui
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- إضافة تأثير الحدود (Stroke)
local stroke = Instance.new("UIStroke")
stroke.Parent = frame
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 255, 255)

-- إضافة تأثير التدرج اللوني (Gradient)
local gradient = Instance.new("UIGradient")
gradient.Parent = frame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
}

-- إنشاء عنوان في الأعلى
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🛠 سكربتات روبلوكس"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- إنشاء زر السكربت الأول
local script1Button = Instance.new("TextButton")
script1Button.Parent = frame
script1Button.Size = UDim2.new(0.9, 0, 0, 50)
script1Button.Position = UDim2.new(0.05, 0, 0.2, 0)
script1Button.Text = "تشغيل السكربت الأول"
script1Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
script1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
script1Button.Font = Enum.Font.SourceSansBold
script1Button.TextSize = 18

-- إنشاء زر السكربت الثاني
local script2Button = Instance.new("TextButton")
script2Button.Parent = frame
script2Button.Size = UDim2.new(0.9, 0, 0, 50)
script2Button.Position = UDim2.new(0.05, 0, 0.5, 0)
script2Button.Text = "تشغيل السكربت الثاني"
script2Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
script2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
script2Button.Font = Enum.Font.SourceSansBold
script2Button.TextSize = 18

-- تشغيل السكربت الأول عند الضغط على الزر
script1Button.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ahmedalharashah/MyRobloxScripts/main/script1.lua"))()
end)

-- تشغيل السكربت الثاني عند الضغط على الزر
script2Button.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ahmedalharashah/MyRobloxScripts/main/script2.lua"))()
end)

-- إظهار/إخفاء الواجهة باستخدام زر Insert
local visible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        frame.Visible = visible
    end
end)
