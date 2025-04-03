-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configuration
local settings = {
    Aimbot = {
        Enabled = true,
        Keybind = Enum.UserInputType.MouseButton2,
        Smoothing = 0.2, -- Lower is smoother
        FOV = 250,
        VisibleCheck = true,
        TeamCheck = true,
        Prediction = 0.1, -- For moving targets
        SilentAim = false, -- Doesn't move camera visibly
        AutoShoot = false,
        AutoShootDelay = 0.1,
        HitChance = 100, -- Percentage
        Priority = "Closest", -- "Closest", "Head", "Torso"
    },
    
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        TeamColor = true,
        MaxDistance = 1000,
        Tracers = false,
        TracerOrigin = "Bottom", -- "Bottom", "Middle", "Mouse"
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 0),
        ChamsTransparency = 0.5,
    },
    
    Visuals = {
        FOVCircle = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVTransparency = 0.5,
        Crosshair = true,
        CrosshairColor = Color3.fromRGB(255, 0, 0),
        CrosshairSize = 12,
        CrosshairGap = 5,
        CrosshairThickness = 1,
    },
    
    Misc = {
        AntiAim = false, -- Makes your character look elsewhere
        AntiAimSpeed = 1,
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        TriggerBot = false,
        TriggerBotDelay = 0.1,
    }
}

-- Variables
local aimbotTarget = nil
local espCache = {}
local connections = {}
local drawingObjects = {}
local lastShot = 0
local crosshair
local fovCircle = nil

-- UI Functions
local function createCrosshair()
    if not settings.Visuals.Crosshair then return end
    
    crosshair = {
        Line1 = Drawing.new("Line"),
        Line2 = Drawing.new("Line"),
        Line3 = Drawing.new("Line"),
        Line4 = Drawing.new("Line")
    }
    
    for _, line in pairs(crosshair) do
        line.Visible = true
        line.Color = settings.Visuals.CrosshairColor
        line.Thickness = settings.Visuals.CrosshairThickness
    end
    
    connections["CrosshairUpdater"] = RunService.RenderStepped:Connect(function()
        if not settings.Visuals.Crosshair then
            for _, line in pairs(crosshair) do
                line.Visible = false
            end
            return
        end
        
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local gap = settings.Visuals.CrosshairGap
        local size = settings.Visuals.CrosshairSize
        
        -- Top line
        crosshair.Line1.From = Vector2.new(center.X, center.Y - gap - size)
        crosshair.Line1.To = Vector2.new(center.X, center.Y - gap)
        
        -- Bottom line
        crosshair.Line2.From = Vector2.new(center.X, center.Y + gap)
        crosshair.Line2.To = Vector2.new(center.X, center.Y + gap + size)
        
        -- Left line
        crosshair.Line3.From = Vector2.new(center.X - gap - size, center.Y)
        crosshair.Line3.To = Vector2.new(center.X - gap, center.Y)
        
        -- Right line
        crosshair.Line4.From = Vector2.new(center.X + gap, center.Y)
        crosshair.Line4.To = Vector2.new(center.X + gap + size, center.Y)
        
        for _, line in pairs(crosshair) do
            line.Color = settings.Visuals.CrosshairColor
            line.Thickness = settings.Visuals.CrosshairThickness
            line.Visible = true
        end
    end)
end

local function createFOVCircle()
    if not settings.Visuals.FOVCircle then return end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = true
    fovCircle.Color = settings.Visuals.FOVColor
    fovCircle.Transparency = settings.Visuals.FOVTransparency
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Radius = settings.Aimbot.FOV
    fovCircle.Filled = false
    
    connections["FOVUpdater"] = RunService.RenderStepped:Connect(function()
        if not settings.Visuals.FOVCircle then
            fovCircle.Visible = false
            return
        end
        
        fovCircle.Visible = settings.Aimbot.Enabled
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = settings.Aimbot.FOV
        fovCircle.Color = settings.Visuals.FOVColor
        fovCircle.Transparency = settings.Visuals.FOVTransparency
    end)
end

-- Utility Functions
local function isVisible(part)
    if not settings.Aimbot.VisibleCheck then return true end
    
    local character = player.Character
    if not character then return false end
    
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local origin = head.Position
    local target = part.Position
    local direction = (target - origin).Unit * (origin - target).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        return hitPart:IsDescendantOf(part.Parent)
    end
    
    return false
end

local function isTeamMate(targetPlayer)
    if not settings.Aimbot.TeamCheck then return false end
    return player.Team and targetPlayer.Team and player.Team == targetPlayer.Team
end

local function calculatePrediction(targetPart, velocity)
    if settings.Aimbot.Prediction <= 0 then return targetPart.Position end
    
    local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
    local timeToHit = distance / 2000 -- Adjust based on bullet speed
    return targetPart.Position + (velocity * timeToHit * settings.Aimbot.Prediction)
end

local function getHitChance()
    return math.random(1, 100) <= settings.Aimbot.HitChance
end

-- Aimbot Functions
local function getTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    local myCharacter = player.Character
    if not myCharacter then return nil end
    
    local myHead = myCharacter:FindFirstChild("Head")
    if not myHead then return nil end
    
    local myPosition = myHead.Position
    local cameraPosition = Camera.CFrame.Position
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and not isTeamMate(targetPlayer) then
            local targetCharacter = targetPlayer.Character
            if targetCharacter then
                local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetHead = targetCharacter:FindFirstChild("Head")
                    local targetTorso = targetCharacter:FindFirstChild("HumanoidRootPart")
                    
                    if targetHead and targetTorso then
                        local targetPosition = nil
                        
                        if settings.Aimbot.Priority == "Head" then
                            targetPosition = targetHead.Position
                        elseif settings.Aimbot.Priority == "Torso" then
                            targetPosition = targetTorso.Position
                        else
                            targetPosition = targetHead.Position
                        end
                        
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPosition)
                        
                        if onScreen then
                            local targetScreenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                            local fovDistance = (centerScreen - targetScreenPos).Magnitude
                            local worldDistance = (myPosition - targetPosition).Magnitude
                            
                            -- Check if target is within FOV circle
                            if fovDistance <= settings.Aimbot.FOV then
                                if isVisible(targetHead) then
                                    if worldDistance < closestDistance then
                                        closestDistance = worldDistance
                                        closestTarget = {
                                            Player = targetPlayer,
                                            Character = targetCharacter,
                                            Head = targetHead,
                                            Torso = targetTorso,
                                            Distance = worldDistance,
                                            Velocity = targetTorso.Velocity,
                                            ScreenPosition = targetScreenPos
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

local function aimAt(target)
    if not target then return end
    
    -- Verify target is still within FOV circle
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local currentFOVDistance = (centerScreen - target.ScreenPosition).Magnitude
    
    if currentFOVDistance > settings.Aimbot.FOV then
        return -- Don't aim if target left the FOV circle
    end
    
    local targetPart = settings.Aimbot.Priority == "Head" and target.Head or target.Torso
    local predictedPosition = calculatePrediction(targetPart, target.Velocity)
    
    if settings.Aimbot.SilentAim then
        -- Silent aim implementation would go here
    else
        -- Smooth aim
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.lookAt(currentCFrame.Position, predictedPosition)
        
        local smoothingFactor = settings.Aimbot.Smoothing
        if smoothingFactor <= 0 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - smoothingFactor)
        end
    end
end

local function fireAtTarget(target)
    if not target or not getHitChance() then return end
    
    -- Actual firing implementation would depend on the game
    -- This is just a placeholder
    if settings.Misc.RapidFire then
        -- Rapid fire implementation
    end
    
    lastShot = tick()
end

-- ESP Functions
local function createESP(targetPlayer)
    if espCache[targetPlayer] then return espCache[targetPlayer] end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthText = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = settings.ESP.Tracers and Drawing.new("Line") or nil
    }
    
    -- Box settings
    esp.Box.Visible = false
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    
    -- Name settings
    esp.Name.Visible = false
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    
    -- Health bar settings
    esp.HealthBar.Visible = false
    esp.HealthBar.Thickness = 1
    
    -- Health text settings
    esp.HealthText.Visible = false
    esp.HealthText.Size = 12
    esp.HealthText.Outline = true
    
    -- Distance text settings
    esp.Distance.Visible = false
    esp.Distance.Size = 12
    esp.Distance.Outline = true
    
    -- Tracer settings
    if esp.Tracer then
        esp.Tracer.Visible = false
        esp.Tracer.Thickness = 1
    end
    
    espCache[targetPlayer] = esp
    return esp
end

local function updateESP()
    if not settings.ESP.Enabled then
        for _, esp in pairs(espCache) do
            for _, drawing in pairs(esp) do
                if typeof(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
        return
    end
    
    local myCharacter = player.Character
    if not myCharacter then return end
    
    local myHead = myCharacter:FindFirstChild("Head")
    if not myHead then return end
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and not isTeamMate(targetPlayer) then
            local targetCharacter = targetPlayer.Character
            if targetCharacter then
                local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetHead = targetCharacter:FindFirstChild("Head")
                    if targetHead then
                        local distance = (myHead.Position - targetHead.Position).Magnitude
                        if distance <= settings.ESP.MaxDistance then
                            local esp = createESP(targetPlayer)
                            local screenPosition, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
                            
                            if onScreen then
                                local boxSize = Vector2.new(2000 / screenPosition.Z, 3000 / screenPosition.Z)
                                local boxPosition = Vector2.new(screenPosition.X - boxSize.X / 2, screenPosition.Y - boxSize.Y / 2)
                                
                                -- Box ESP
                                if settings.ESP.Boxes then
                                    esp.Box.Size = boxSize
                                    esp.Box.Position = boxPosition
                                    esp.Box.Visible = true
                                    esp.Box.Color = settings.ESP.TeamColor and targetPlayer.TeamColor.Color or Color3.fromRGB(255, 0, 0)
                                else
                                    esp.Box.Visible = false
                                end
                                
                                -- Name ESP
                                if settings.ESP.Names then
                                    esp.Name.Text = targetPlayer.Name
                                    esp.Name.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y - 16)
                                    esp.Name.Visible = true
                                    esp.Name.Color = settings.ESP.TeamColor and targetPlayer.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                                else
                                    esp.Name.Visible = false
                                end
                                
                                -- Health ESP
                                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                                local healthBarLength = boxSize.Y * healthPercentage
                                local healthBarOffset = boxSize.X + 4
                                
                                if settings.ESP.Health then
                                    -- Health bar
                                    esp.HealthBar.From = Vector2.new(boxPosition.X + healthBarOffset, boxPosition.Y + boxSize.Y)
                                    esp.HealthBar.To = Vector2.new(boxPosition.X + healthBarOffset, boxPosition.Y + boxSize.Y - healthBarLength)
                                    esp.HealthBar.Visible = true
                                    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercentage)
                                    
                                    -- Health text
                                    esp.HealthText.Text = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(math.floor(humanoid.MaxHealth))
                                    esp.HealthText.Position = Vector2.new(boxPosition.X + healthBarOffset + 10, boxPosition.Y + boxSize.Y - healthBarLength / 2)
                                    esp.HealthText.Visible = true
                                    esp.HealthText.Color = Color3.fromRGB(255, 255, 255)
                                else
                                    esp.HealthBar.Visible = false
                                    esp.HealthText.Visible = false
                                end
                                
                                -- Distance ESP
                                if settings.ESP.Distance then
                                    esp.Distance.Text = tostring(math.floor(distance)) .. "m"
                                    esp.Distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 2)
                                    esp.Distance.Visible = true
                                    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
                                else
                                    esp.Distance.Visible = false
                                end
                                
                                -- Tracer ESP
                                if settings.ESP.Tracers and esp.Tracer then
                                    local origin = nil
                                    
                                    if settings.ESP.TracerOrigin == "Bottom" then
                                        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    elseif settings.ESP.TracerOrigin == "Middle" then
                                        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                                    else -- Mouse
                                        origin = Vector2.new(mouse.X, mouse.Y)
                                    end
                                    
                                    esp.Tracer.From = origin
                                    esp.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                                    esp.Tracer.Visible = true
                                    esp.Tracer.Color = settings.ESP.TeamColor and targetPlayer.TeamColor.Color or Color3.fromRGB(255, 0, 0)
                                elseif esp.Tracer then
                                    esp.Tracer.Visible = false
                                end
                            else
                                for _, drawing in pairs(esp) do
                                    if typeof(drawing) == "table" and drawing.Visible ~= nil then
                                        drawing.Visible = false
                                    end
                                end
                            end
                        else
                            for _, drawing in pairs(esp) do
                                if typeof(drawing) == "table" and drawing.Visible ~= nil then
                                    drawing.Visible = false
                                end
                            end
                        end
                    end
                else
                    for _, drawing in pairs(esp) do
                        if typeof(drawing) == "table" and drawing.Visible ~= nil then
                            drawing.Visible = false
                        end
                    end
                end
            end
        end
    end
end

-- Chams Function
local function updateChams()
    if not settings.ESP.Chams then
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                for _, part in ipairs(targetPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part:FindFirstChild("ChamHighlight") then
                        part.ChamHighlight:Destroy()
                    end
                end
            end
        end
        return
    end
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and not isTeamMate(targetPlayer) then
            local targetCharacter = targetPlayer.Character
            if targetCharacter then
                local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    for _, part in ipairs(targetCharacter:GetDescendants()) do
                        if part:IsA("BasePart") and not part:FindFirstChild("ChamHighlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ChamHighlight"
                            highlight.Parent = part
                            highlight.FillColor = settings.ESP.ChamsColor
                            highlight.OutlineColor = settings.ESP.ChamsColor
                            highlight.FillTransparency = settings.ESP.ChamsTransparency
                            highlight.OutlineTransparency = 0
                        end
                    end
                else
                    for _, part in ipairs(targetCharacter:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChild("ChamHighlight") then
                            part.ChamHighlight:Destroy()
                        end
                    end
                end
            end
        end
    end
end

-- Trigger Bot Function
local function triggerBot()
    if not settings.Misc.TriggerBot then return end
    if tick() - lastShot < settings.Misc.TriggerBotDelay then return end
    
    local target = getTarget()
    if target then
        -- Verify target is within FOV circle before firing
        local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local currentFOVDistance = (centerScreen - target.ScreenPosition).Magnitude
        
        if currentFOVDistance <= settings.Aimbot.FOV then
            fireAtTarget(target)
        end
    end
end

-- Main Loop
connections["MainLoop"] = RunService.RenderStepped:Connect(function()
    -- Aimbot
    if settings.Aimbot.Enabled then
        if UserInputService:IsMouseButtonPressed(settings.Aimbot.Keybind) then
            aimbotTarget = getTarget()
            if aimbotTarget then
                -- Verify target is within FOV circle before aiming
                local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local currentFOVDistance = (centerScreen - aimbotTarget.ScreenPosition).Magnitude
                
                if currentFOVDistance <= settings.Aimbot.FOV then
                    aimAt(aimbotTarget)
                    
                    if settings.Aimbot.AutoShoot and tick() - lastShot >= settings.Aimbot.AutoShootDelay then
                        fireAtTarget(aimbotTarget)
                    end
                else
                    aimbotTarget = nil
                end
            end
        else
            aimbotTarget = nil
        end
    end
    
    -- ESP
    updateESP()
    updateChams()
    
    -- Trigger Bot
    if settings.Misc.TriggerBot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        triggerBot()
    end
end)

-- Cleanup
local function cleanup()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    
    for _, esp in pairs(espCache) do
        for _, drawing in pairs(esp) do
            if typeof(drawing) == "table" and drawing.Remove then
                drawing:Remove()
            end
        end
    end
    
    if crosshair then
        for _, line in pairs(crosshair) do
            line:Remove()
        end
    end
    
    if fovCircle then
        fovCircle:Remove()
    end
    
    -- Clean up chams
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer.Character then
            for _, part in ipairs(targetPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part:FindFirstChild("ChamHighlight") then
                    part.ChamHighlight:Destroy()
                end
            end
        end
    end
end

-- Initialize
createCrosshair()
createFOVCircle()

-- Clean up when player leaves
player.CharacterRemoving:Connect(cleanup)
player.OnTeleport:Connect(cleanup)
game:BindToClose(cleanup)
