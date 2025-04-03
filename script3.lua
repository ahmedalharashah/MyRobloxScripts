local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = game.Players.LocalPlayer

-- إنشاء واجهة المستخدم (GUI)
local ui = Instance.new("ScreenGui")
ui.Parent = game.CoreGui
ui.Name = "PlayerKickGUI"

local frame = Instance.new("Frame")
frame.Parent = ui
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0.5, -175, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- إنشاء مربع النص لكتابة اسم اللاعب
local playerNameBox = Instance.new("TextBox")
playerNameBox.Parent = frame
playerNameBox.Size = UDim2.new(0.9, 0, 0, 40)
playerNameBox.Position = UDim2.new(0.05, 0, 0.1, 0)
playerNameBox.PlaceholderText = "أدخل اسم اللاعب"
playerNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
playerNameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerNameBox.Font = Enum.Font.SourceSansBold
playerNameBox.TextSize = 18

-- إنشاء زر "قتل"
local killButton = Instance.new("TextButton")
killButton.Parent = frame
killButton.Size = UDim2.new(0.9, 0, 0, 50)
killButton.Position = UDim2.new(0.05, 0, 0.3, 0)
killButton.Text = "قتل اللاعب"
killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.Font = Enum.Font.SourceSansBold
killButton.TextSize = 18

-- إنشاء زر "طرد"
local kickButton = Instance.new("TextButton")
kickButton.Parent = frame
kickButton.Size = UDim2.new(0.9, 0, 0, 50)
kickButton.Position = UDim2.new(0.05, 0, 0.5, 0)
kickButton.Text = "طرد اللاعب"
kickButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
kickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
kickButton.Font = Enum.Font.SourceSansBold
kickButton.TextSize = 18

-- دالة لقتل اللاعب
local function killPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer then
        -- قتل اللاعب
        local character = targetPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            humanoid.Health = 0 -- تقليل الصحة إلى صفر لقتل اللاعب
        end
    else
        print("❌ اللاعب غير موجود.")
    end
end

-- دالة لطرد اللاعب
local function kickPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer then
        -- طرد اللاعب من السيرفر
        targetPlayer:Kick("تم طردك من السيرفر.")
    else
        print("❌ اللاعب غير موجود.")
    end
end

-- ربط زر "قتل" بالوظيفة
killButton.MouseButton1Click:Connect(function()
    local playerName = playerNameBox.Text
    if playerName ~= "" then
        killPlayer(playerName)
    else
        print("❌ لم يتم إدخال اسم اللاعب.")
    end
end)

-- ربط زر "طرد" بالوظيفة
kickButton.MouseButton1Click:Connect(function()
    local playerName = playerNameBox.Text
    if playerName ~= "" then
        kickPlayer(playerName)
    else
        print("❌ لم يتم إدخال اسم اللاعب.")
    end
end)

-- إظهار/إخفاء الواجهة باستخدام زر Insert
local visible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        frame.Visible = visible
    end
end)
