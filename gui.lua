local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- رابط ملف JSON على GitHub
local scriptsURL = "https://raw.githubusercontent.com/ahmedalharashah/MyRobloxScripts/main/scripts.json"

-- إنشاء GUI
local ui = Instance.new("ScreenGui")
ui.Parent = game.CoreGui
ui.Name = "DynamicGUI"

local frame = Instance.new("Frame")
frame.Parent = ui
frame.Size = UDim2.new(0, 350, 0, 400) -- الحجم يمكن تعديله حسب الحاجة
frame.Position = UDim2.new(0.5, -175, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- إضافة ScrollingFrame داخل الـ Frame لتوفير ميزة التمرير
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = frame
scrollFrame.Size = UDim2.new(1, 0, 1, -40)  -- يسمح بالتمرير داخل الـ Frame
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- سيتم تعديله لاحقًا
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 10

-- إضافة UIListLayout لتهيئة ترتيب الأزرار داخل ScrollingFrame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.Padding = UDim.new(0, 10) -- المسافة بين الأزرار
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🛠 سكربتات روبلوكس"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- دالة لتحديث الواجهة بناءً على السكربتات الموجودة في JSON
local function updateGUI()
    -- حذف الأزرار القديمة (إذا كانت موجودة)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- جلب قائمة السكربتات من GitHub
    local success, response = pcall(function()
        return HttpService:GetAsync(scriptsURL)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        local scripts = data.scripts

        -- التحقق من وجود سكربتات
        if not scripts or #scripts == 0 then
            print("❌ لا يوجد سكربتات في JSON")
            return
        end

        -- إنشاء الأزرار بناءً على البيانات
        for i, script in ipairs(scripts) do
            local button = Instance.new("TextButton")
            button.Parent = scrollFrame
            button.Size = UDim2.new(0.9, 0, 0, 50)
            button.Text = script.name
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.SourceSansBold
            button.TextSize = 18

            -- تشغيل السكربت عند الضغط على الزر
            button.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(script.url))()
                end)

                if not success then
                    print("❌ فشل في تحميل السكربت:", err)
                end
            end)
        end

        -- إضافة زر تفعيل وضع الطيران (مرتبط بالسكربت الأول)
        if #scripts >= 1 then
            local flightButton = Instance.new("TextButton")
            flightButton.Parent = scrollFrame
            flightButton.Size = UDim2.new(0.9, 0, 0, 50)
            flightButton.Text = "تفعيل الطيران"
            flightButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            flightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            flightButton.Font = Enum.Font.SourceSansBold
            flightButton.TextSize = 18

            -- تشغيل سكربت الطيران عند الضغط
            flightButton.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(scripts[1].url))() -- الطيران مرتبط بالسكربت الأول
                end)

                if not success then
                    print("❌ فشل في تفعيل الطيران:", err)
                end
            end)
        end

        -- إضافة زر تفعيل السرعة (مرتبط بالسكربت الثاني)
        if #scripts >= 2 then
            local speedButton = Instance.new("TextButton")
            speedButton.Parent = scrollFrame
            speedButton.Size = UDim2.new(0.9, 0, 0, 50)
            speedButton.Text = "تفعيل السرعة"
            speedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            speedButton.Font = Enum.Font.SourceSansBold
            speedButton.TextSize = 18

            -- تشغيل سكربت السرعة عند الضغط
            speedButton.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(scripts[2].url))() -- السرعة مرتبطة بالسكربت الثاني
                end)

                if not success then
                    print("❌ فشل في تفعيل السرعة:", err)
                end
            end)
        end

        -- إضافة زر النقر التلقائي (مرتبط بالسكربت الثالث)
        if #scripts >= 3 then
            local autoClickButton = Instance.new("TextButton")
            autoClickButton.Parent = scrollFrame
            autoClickButton.Size = UDim2.new(0.9, 0, 0, 50)
            autoClickButton.Text = "تفعيل النقر التلقائي"
            autoClickButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            autoClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            autoClickButton.Font = Enum.Font.SourceSansBold
            autoClickButton.TextSize = 18

            -- تشغيل سكربت النقر التلقائي عند الضغط
            autoClickButton.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(scripts[3].url))() -- النقر التلقائي مرتبط بالسكربت الثالث
                end)

                if not success then
                    print("❌ فشل في تفعيل النقر التلقائي:", err)
                end
            end)
        end

        -- تعديل حجم الـ CanvasSize بناءً على عدد الأزرار
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 60 * (#scripts + 3))  -- إضافة 3 أزرار إضافية
    else
        print("❌ فشل في جلب بيانات السكربتات:", response)
    end
end

-- تشغيل تحديث الواجهة عند بدء التشغيل
updateGUI()

-- تحديث الواجهة عند الضغط على زر Insert
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)

-- إيقاف السكربت عند الضغط على زر End
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.End then
        if ui then
            ui:Destroy() -- حذف الـ GUI بالكامل
            print("✅ تم إيقاف السكربت وحذف الواجهة!")
        end
    end
end)

-- متابعة التغييرات في ملف JSON وتحديث الواجهة تلقائيًا
while true do
    wait(30)  -- تحقق كل 30 ثانية (يمكنك تغيير الوقت حسب الحاجة)
    updateGUI()  -- تحديث الواجهة
end
