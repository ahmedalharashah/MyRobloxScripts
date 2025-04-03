local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- السرعة العادية والسرعة الخارقة
local normalSpeed = 16  -- السرعة العادية
local superSpeed = 400  -- السرعة الخارقة

-- عند الضغط على مفتاح Q
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- إذا كانت اللعبة قد استقبلت الحدث، لا تعالجه
    if input.KeyCode == Enum.KeyCode.Q then  -- إذا كان المفتاح هو "Q"
        humanoid.WalkSpeed = superSpeed  -- تعيين السرعة إلى السرعة الخارقة
    end
end)

-- عند رفع مفتاح Q
userInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then  -- إذا تم رفع "Q"
        humanoid.WalkSpeed = normalSpeed  -- تعيين السرعة إلى السرعة العادية
    end
end)
