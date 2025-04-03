local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- رابط ملف JSON على GitHub
local scriptsURL = "https://raw.githubusercontent.com/ahmedalharashah/MyRobloxScripts/main/scripts.json"

-- إنشاء GUI
local ui = Instance.new("ScreenGui")
ui.Parent = game.CoreGui
ui.Name = "DynamicScriptsGUI"
ui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = ui
frame.Size = UDim2.new(0, 350, 0, 50) -- سيتم تعديل الحجم تلقائياً
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true

-- إضافة زوايا مستديرة
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🛠 سكربتات روبلوكس"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton")
closeButton.Parent = frame
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 4)
corner2.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- إضافة شريط تمرير
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = frame
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local buttonsLayout = Instance.new("UIListLayout")
buttonsLayout.Parent = scrollFrame
buttonsLayout.Padding = UDim.new(0, 5)
buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- دالة لإنشاء زر بخصائص محددة
local function createButton(name, order)
    local button = Instance.new("TextButton")
    button.Parent = scrollFrame
    button.Size = UDim2.new(1, 0, 0, 50)
    button.LayoutOrder = order
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BackgroundTransparency = 0.5
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- تأثيرات عند المرور على الزر
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    end)
    
    return button
end

-- تحديث الواجهة تلقائيًا عند إضافة أزرار جديدة
local function updateGUI()
    -- جلب قائمة السكربتات من GitHub
    local success, response = pcall(function()
        return HttpService:GetAsync(scriptsURL, true)
    end)

    if success then
        local data
        pcall(function()
            data = HttpService:JSONDecode(response)
        end)
        
        if not data then
            warn("❌ فشل في تحليل JSON")
            return
        end

        local scripts = data.scripts

        -- التحقق من وجود سكربتات
        if not scripts or #scripts == 0 then
            warn("❌ لا يوجد سكربتات في JSON")
            return
        end

        -- مسح الأزرار القديمة
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        -- إضافة الأزرار الجديدة
        for i, script in ipairs(scripts) do
            local button = createButton(script.name, i)
            
            -- تشغيل السكربت عند الضغط على الزر
            button.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(script.url, true))()
                end)

                if not success then
                    warn("❌ فشل في تحميل السكربت:", err)
                    
                    -- عرض رسالة خطأ مؤقتة
                    local oldText = button.Text
                    button.Text = "❌ فشل التحميل!"
                    task.delay(2, function()
                        if button then
                            button.Text = oldText
                        end
                    end)
                else
                    -- عرض رسالة نجاح مؤقتة
                    local oldText = button.Text
                    button.Text = "✓ تم التفعيل!"
                    task.delay(2, function()
                        if button then
                            button.Text = oldText
                        end
                    end)
                end
            end)
        end

        -- تعديل حجم الإطار بناءً على عدد الأزرار (بحد أقصى 8 أزرار)
        local maxHeight = 400
        local calculatedHeight = 40 + (math.min(#scripts, 8) * 55
        frame.Size = UDim2.new(0, 350, 0, math.min(calculatedHeight, maxHeight))
    else
        warn("❌ فشل في جلب بيانات السكربتات:", response)
    end
end

-- تشغيل تحديث الواجهة عند بدء التشغيل
updateGUI()

-- إظهار/إخفاء الواجهة عند الضغط على Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
        
        -- تأثير عند الظهور/الاختفاء
        if frame.Visible then
            frame.BackgroundTransparency = 1
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
            updateGUI() -- تحديث القائمة عند إظهار الواجهة
        end
    end
end)

-- إيقاف السكربت عند الضغط على End
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.End then
        if ui then
            ui:Destroy() -- حذف الـ GUI بالكامل
            print("✅ تم إيقاف السكربت وحذف الواجهة!")
        end
    end
end)

-- متابعة التغييرات في ملف JSON وتحديث الواجهة تلقائيًا
while true do
    task.wait(60)  -- تحقق كل دقيقة (يمكنك تغيير الوقت حسب الحاجة)
    if frame.Visible then -- تحديث فقط إذا كانت الواجهة ظاهرة
        updateGUI()
    end
end
