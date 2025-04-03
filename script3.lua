local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local clicking = false

-- عند الضغط على زر الماوس الأيسر
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        clicking = true
        while clicking do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) -- ضغط الزر
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) -- إفلات الزر
            task.wait(0.05) -- تعديل سرعة النقر (يمكنك تقليل الرقم لجعلها أسرع)
        end
    end
end)

-- عند رفع الإصبع عن زر الماوس الأيسر
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        clicking = false
    end
end)
