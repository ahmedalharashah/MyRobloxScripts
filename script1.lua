local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local bodyVelocity = nil

-- دالة لجعل اللاعب يطفو
local function floatPlayer()
    -- التأكد من أن اللاعب ليس في الهواء بالفعل
    if not bodyVelocity then
        -- إنشاء جسم لإعطاء اللاعب قوة لرفع نفسه
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)  -- قوة كبيرة لرفع اللاعب
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)  -- دفع اللاعب للأعلى
        bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
    end
end

-- دالة لإلغاء الطفو عندما يتم رفع زر السبيس
local function stopFloating()
    if bodyVelocity then
        bodyVelocity:Destroy()  -- إزالة جسم الجسم (BodyVelocity) للتوقف عن الطفو
        bodyVelocity = nil
    end
end

-- الاستماع للضغط على مفتاح Space
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- إذا كانت اللعبة قد استقبلت الحدث، لا تعالجه
    if input.KeyCode == Enum.KeyCode.Space then  -- إذا كان المفتاح هو "Space"
        floatPlayer()  -- تمكين الطفو
    end
end)

-- الاستماع لإلغاء الضغط على Space لإيقاف الطفو
userInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then  -- إذا تم رفع مفتاح Space
        stopFloating()  -- إيقاف الطفو
    end
end)
