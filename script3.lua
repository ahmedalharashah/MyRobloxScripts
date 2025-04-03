local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local jumping = false

-- دالة لتحقق إذا كان اللاعب يضغط على زر القفز
local function onJumpRequest(input, gameProcessed)
    if gameProcessed then return end

    -- التحقق إذا كان الضغط على زر القفز
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        -- إذا لم يكن اللاعب في الهواء، نفذ القفز
        if not jumping then
            jumping = true
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid:Move(Vector3.new(0, 50, 0))  -- أو القيمة المطلوبة لقوة القفز
        end
    end
end

-- دالة للإيقاف عندما يرفع اللاعب إصبعه عن زر القفز
local function onJumpRelease(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        jumping = false
    end
end

-- الاستماع إلى حدث الضغط على زر القفز
UserInputService.InputBegan:Connect(onJumpRequest)
UserInputService.InputEnded:Connect(onJumpRelease)
