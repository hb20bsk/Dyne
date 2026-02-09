--[[
    Modern UI Library
    Full featured UI with Lucide icons
]]

local cloneref = cloneref or function(instance) return instance end

local CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Lucide Icons Module
local LucideIcons = nil
local IconsLoaded = false

pcall(function()
    LucideIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/main/src/icons.lua"))()
    IconsLoaded = true
end)

local function GetIcon(name)
    if IconsLoaded and LucideIcons and LucideIcons[name] then
        return LucideIcons[name]
    end
    return nil
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernUI_" .. tostring(math.random(100000, 999999))
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
end)

ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(17, 19, 23),
    Secondary = Color3.fromRGB(24, 27, 31),
    Tertiary = Color3.fromRGB(32, 36, 42),
    Accent = Color3.fromRGB(140, 200, 75),
    AccentDark = Color3.fromRGB(100, 160, 55),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(140, 145, 155),
    Border = Color3.fromRGB(45, 50, 58),
    Warning = Color3.fromRGB(230, 180, 50),
    Error = Color3.fromRGB(220, 80, 80),
}

-- Stores
local Toggles = {}
local Options = {}

-- Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function CreateIcon(parent, iconName, size, color)
    local iconData = GetIcon(iconName)
    
    if iconData then
        local icon = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, size, 0, size),
            Image = iconData.Image,
            ImageRectOffset = iconData.ImageRectOffset,
            ImageRectSize = iconData.ImageRectSize,
            ImageColor3 = color or Theme.Text,
            Parent = parent
        })
        return icon
    else
        local icon = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, size, 0, size),
            Font = Enum.Font.GothamBold,
            Text = string.sub(iconName, 1, 1):upper(),
            TextColor3 = color or Theme.Text,
            TextSize = size * 0.6,
            Parent = parent
        })
        return icon
    end
end

--============================================
-- LIBRARY
--============================================

local Library = {
    ScreenGui = ScreenGui,
    Theme = Theme,
    Toggled = false,
    OpenedFrames = {},
    Toggles = Toggles,
    Options = Options,
}

--============================================
-- NOTIFICATIONS
--============================================

local NotificationContainer = Create("Frame", {
    Name = "NotificationContainer",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(0, 320, 0, 600),
    Parent = ScreenGui
})

Create("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificationContainer
})

function Library:Notify(options)
    if type(options) == "string" then
        options = { Title = "Notification", Description = options }
    end
    
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local duration = options.Duration or 5
    local notifType = options.Type or "info"
    
    local accentColor = Theme.Accent
    if notifType == "warning" then
        accentColor = Theme.Warning
    elseif notifType == "error" then
        accentColor = Theme.Error
    end
    
    local notif = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 65),
        ClipsDescendants = true,
        Parent = NotificationContainer
    })
    AddCorner(notif, 8)
    AddStroke(notif, Theme.Border, 1)
    
    local accent = Create("Frame", {
        BackgroundColor3 = accentColor,
        Position = UDim2.new(0, 0, 0.12, 0),
        Size = UDim2.new(0, 3, 0.76, 0),
        Parent = notif
    })
    AddCorner(accent, 2)
    
    local iconName = "bell"
    if notifType == "warning" then iconName = "alert-triangle" end
    if notifType == "error" then iconName = "alert-circle" end
    
    local iconFrame = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 14),
        Size = UDim2.new(0, 20, 0, 20),
        Parent = notif
    })
    CreateIcon(iconFrame, iconName, 20, accentColor)
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 12),
        Size = UDim2.new(1, -60, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 34),
        Size = UDim2.new(1, -60, 0, 18),
        Font = Enum.Font.Gotham,
        Text = description,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    local progressBg = Create("Frame", {
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 16, 1, -12),
        Size = UDim2.new(0.45, 0, 0, 4),
        Parent = notif
    })
    AddCorner(progressBg, 2)
    
    local progress = Create("Frame", {
        BackgroundColor3 = accentColor,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = progressBg
    })
    AddCorner(progress, 2)
    
    Tween(notif, {BackgroundTransparency = 0}, 0.3)
    Tween(progress, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        Tween(notif, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end)
    
    return notif
end

--============================================
-- WATERMARK
--============================================

local Watermark = Create("Frame", {
    Name = "Watermark",
    BackgroundColor3 = Theme.Secondary,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 380, 0, 36),
    Parent = ScreenGui
})
AddCorner(Watermark, 8)
AddStroke(Watermark, Theme.Border, 1)

local WatermarkLayout = Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 30),
    Parent = Watermark
})

local WatermarkLabels = {}
local watermarkItems = {"HOLEX", "1 Lobby", "144 FPS", "25 PING", "12:18 PM"}

for i, text in ipairs(watermarkItems) do
    local label = Create("TextLabel", {
        Name = "Item" .. i,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = Theme.TextDark,
        TextSize = 13,
        Parent = Watermark
    })
    WatermarkLabels[i] = label
end

function Library:SetWatermark(items)
    for i, text in ipairs(items) do
        if WatermarkLabels[i] then
            WatermarkLabels[i].Text = text
        end
    end
end

Library.Watermark = Watermark

--============================================
-- MAIN WINDOW
--============================================

function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Modern UI"
    local size = options.Size or UDim2.new(0, 780, 0, 550)
    
    local Window = {
        Tabs = {},
        ActiveTab = nil
    }
    
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = Theme.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        Visible = options.AutoShow ~= false,
        Parent = ScreenGui
    })
    AddCorner(MainWindow, 12)
    AddStroke(MainWindow, Theme.Border, 1)
    
    Library.MainWindow = MainWindow
    Library.Toggled = options.AutoShow ~= false
    
    -- Dragging
    local dragging, dragStart, startPos
    
    MainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local relY = mousePos.Y - MainWindow.AbsolutePosition.Y
            if relY <= 55 then
                dragging = true
                dragStart = input.Position
                startPos = MainWindow.Position
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Top bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 55),
        Parent = MainWindow
    })
    AddCorner(TopBar, 12)
    
    Create("Frame", {
        BackgroundColor3 = Theme.Secondary,
        Position = UDim2.new(0, 0, 1, -14),
        Size = UDim2.new(1, 0, 0, 14),
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    -- Logo
    local LogoIcon = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 18, 0.5, -14),
        Size = UDim2.new(0, 28, 0, 28),
        Parent = TopBar
    })
    AddCorner(LogoIcon, 7)
    
    -- Tab container
    local TabButtonContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 0),
        Size = UDim2.new(0, 280, 1, 0),
        Parent = TopBar
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = TabButtonContainer
    })
    
    -- Tab title
    local TabTitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 50, 0.5, 0),
        Size = UDim2.new(0, 200, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Parent = TopBar
    })
    
    -- Power button
    local PowerBtn = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -20, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        Parent = TopBar
    })
    AddCorner(PowerBtn, 7)
    
    -- Tab content container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -55),
        Parent = MainWindow
    })
    
    -- Add Tab
    function Window:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or "home"
        
        local Tab = {
            Name = tabName,
            Groupboxes = {}
        }
        
        local tabBtn = Create("Frame", {
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = #Window.Tabs == 0 and 0 or 1,
            Size = UDim2.new(0, 40, 0, 40),
            Parent = TabButtonContainer
        })
        AddCorner(tabBtn, 10)
        
        local iconHolder = Create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 22, 0, 22),
            Parent = tabBtn
        })
        
        local iconColor = #Window.Tabs == 0 and Theme.Text or Theme.TextDark
        CreateIcon(iconHolder, tabIcon, 22, iconColor)
        
        Tab.Button = tabBtn
        Tab.IconHolder = iconHolder
        
        local tabFrame = Create("Frame", {
            Name = tabName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = #Window.Tabs == 0,
            Parent = TabContainer
        })
        
        Tab.Frame = tabFrame
        
        local contentArea = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 25, 0, 18),
            Size = UDim2.new(1, -50, 1, -36),
            Parent = tabFrame
        })
        
        local leftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -12, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = contentArea
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = leftColumn
        })
        
        local rightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 12, 0, 0),
            Size = UDim2.new(0.5, -12, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = contentArea
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = rightColumn
        })
        
        Tab.LeftColumn = leftColumn
        Tab.RightColumn = rightColumn
        
        function Tab:Show()
            for _, t in pairs(Window.Tabs) do
                t.Frame.Visible = false
                t.Button.BackgroundTransparency = 1
                for _, c in pairs(t.IconHolder:GetChildren()) do
                    if c:IsA("ImageLabel") then c.ImageColor3 = Theme.TextDark
                    elseif c:IsA("TextLabel") then c.TextColor3 = Theme.TextDark end
                end
            end
            Tab.Frame.Visible = true
            Tab.Button.BackgroundTransparency = 0
            for _, c in pairs(Tab.IconHolder:GetChildren()) do
                if c:IsA("ImageLabel") then c.ImageColor3 = Theme.Text
                elseif c:IsA("TextLabel") then c.TextColor3 = Theme.Text end
            end
            TabTitle.Text = Tab.Name
            Window.ActiveTab = Tab
        end
        
        tabBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Tab:Show()
            end
        end)
        
        function Tab:AddLeftGroupbox(name)
            return Tab:AddGroupbox(name, leftColumn)
        end
        
        function Tab:AddRightGroupbox(name)
            return Tab:AddGroupbox(name, rightColumn)
        end
        
        function Tab:AddGroupbox(name, parent)
            local Groupbox = {
                Name = name,
                Elements = {}
            }
            
            local container = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = parent
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = container
            })
            
            Groupbox.Container = container
            
            function Groupbox:AddLabel(text)
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local LabelObj = { Instance = label }
                function LabelObj:SetText(newText) label.Text = newText end
                return LabelObj
            end
            
            function Groupbox:AddToggle(idx, toggleOptions)
                toggleOptions = toggleOptions or {}
                local text = toggleOptions.Text or "Toggle"
                local default = toggleOptions.Default or false
                local callback = toggleOptions.Callback or function() end
                
                local Toggle = { Value = default, Type = "Toggle" }
                
                local toggleContainer = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = container
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -55, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = default and Theme.Text or Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleContainer
                })
                
                if toggleOptions.HasSettings then
                    local settingsBtn = Create("Frame", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -36, 0.5, 0),
                        Size = UDim2.new(0, 18, 0, 18),
                        Parent = toggleContainer
                    })
                    CreateIcon(settingsBtn, "settings", 16, Theme.TextDark)
                end
                
                local checkbox = Create("Frame", {
                    BackgroundColor3 = default and Theme.Accent or Theme.Tertiary,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    Parent = toggleContainer
                })
                AddCorner(checkbox, 6)
                
                local checkmark = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = default and "✓" or "",
                    TextColor3 = Theme.Background,
                    TextSize = 14,
                    Parent = checkbox
                })
                
                function Toggle:SetValue(value)
                    Toggle.Value = value
                    Tween(checkbox, {BackgroundColor3 = value and Theme.Accent or Theme.Tertiary}, 0.15)
                    checkmark.Text = value and "✓" or ""
                    label.TextColor3 = value and Theme.Text or Theme.TextDark
                    task.spawn(callback, value)
                end
                
                function Toggle:OnChanged(cb) Toggle.Changed = cb end
                
                toggleContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle:SetValue(not Toggle.Value)
                        if Toggle.Changed then Toggle.Changed(Toggle.Value) end
                    end
                end)
                
                Toggles[idx] = Toggle
                return Toggle
            end
            
            function Groupbox:AddSlider(idx, sliderOptions)
                sliderOptions = sliderOptions or {}
                local text = sliderOptions.Text or "Slider"
                local default = sliderOptions.Default or 50
                local min = sliderOptions.Min or 0
                local max = sliderOptions.Max or 100
                local rounding = sliderOptions.Rounding or 0
                local suffix = sliderOptions.Suffix or ""
                local callback = sliderOptions.Callback or function() end
                
                local Slider = { Value = default, Min = min, Max = max, Type = "Slider" }
                
                local sliderContainer = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    Parent = container
                })
                
                local labelRow = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = sliderContainer
                })
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = labelRow
                })
                
                local valueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = labelRow
                })
                
                local sliderBg = Create("Frame", {
                    BackgroundColor3 = Theme.Tertiary,
                    Position = UDim2.new(0, 0, 0, 26),
                    Size = UDim2.new(1, 0, 0, 8),
                    Parent = sliderContainer
                })
                AddCorner(sliderBg, 4)
                
                local sliderFill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = sliderBg
                })
                AddCorner(sliderFill, 4)
                
                local knob = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 18, 0, 18),
                    ZIndex = 2,
                    Parent = sliderBg
                })
                AddCorner(knob, 9)
                
                function Slider:SetValue(value)
                    value = math.clamp(value, min, max)
                    if rounding == 0 then
                        value = math.floor(value)
                    else
                        value = math.floor(value * 10^rounding + 0.5) / 10^rounding
                    end
                    Slider.Value = value
                    local percent = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    valueLabel.Text = tostring(value) .. suffix
                    task.spawn(callback, value)
                end
                
                function Slider:OnChanged(cb) Slider.Changed = cb end
                
                local sliding = false
                
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        Slider:SetValue(value)
                        if Slider.Changed then Slider.Changed(Slider.Value) end
                    end
                end)
                
                Options[idx] = Slider
                return Slider
            end
            
            function Groupbox:AddDropdown(idx, dropdownOptions)
                dropdownOptions = dropdownOptions or {}
                local text = dropdownOptions.Text or "Dropdown"
                local values = dropdownOptions.Values or {}
                local default = dropdownOptions.Default
                local multi = dropdownOptions.Multi or false
                local callback = dropdownOptions.Callback or function() end
                
                local Dropdown = {
                    Value = multi and {} or default,
                    Values = values,
                    Multi = multi,
                    Type = "Dropdown"
                }
                
                local dropdownContainer = Create("Frame", {
                    BackgroundColor3 = Theme.Secondary,
                    Size = UDim2.new(1, 0, 0, 42),
                    ClipsDescendants = true,
                    Parent = container
                })
                AddCorner(dropdownContainer, 10)
                
                local displayText = default or text
                if multi and type(Dropdown.Value) == "table" then
                    local selected = {}
                    for v, enabled in pairs(Dropdown.Value) do
                        if enabled then table.insert(selected, v) end
                    end
                    displayText = #selected > 0 and table.concat(selected, ", ") or text
                end
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 0),
                    Size = UDim2.new(1, -55, 0, 42),
                    Font = Enum.Font.Gotham,
                    Text = displayText,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = dropdownContainer
                })
                
                local arrow = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -16, 0, 21),
                    Size = UDim2.new(0, 20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    Parent = dropdownContainer
                })
                
                local optionsFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 48),
                    Size = UDim2.new(1, 0, 0, #values * 34),
                    Parent = dropdownContainer
                })
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    Parent = optionsFrame
                })
                
                local isOpen = false
                
                local function updateDisplay()
                    if multi then
                        local selected = {}
                        for v, enabled in pairs(Dropdown.Value) do
                            if enabled then table.insert(selected, v) end
                        end
                        label.Text = #selected > 0 and table.concat(selected, ", ") or text
                    else
                        label.Text = Dropdown.Value or text
                    end
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    local targetSize = isOpen and UDim2.new(1, 0, 0, 48 + #values * 34) or UDim2.new(1, 0, 0, 42)
                    Tween(dropdownContainer, {Size = targetSize}, 0.2)
                    arrow.Text = isOpen and "▲" or "▼"
                end
                
                for _, value in ipairs(values) do
                    local optionBtn = Create("TextButton", {
                        BackgroundColor3 = Theme.Tertiary,
                        BackgroundTransparency = 0.4,
                        Size = UDim2.new(1, -12, 0, 30),
                        Position = UDim2.new(0, 6, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = "  " .. value,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = optionsFrame
                    })
                    AddCorner(optionBtn, 6)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[value] = not Dropdown.Value[value]
                        else
                            Dropdown.Value = value
                            toggleDropdown()
                        end
                        updateDisplay()
                        task.spawn(callback, Dropdown.Value)
                    end)
                end
                
                dropdownContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local relY = input.Position.Y - dropdownContainer.AbsolutePosition.Y
                        if relY <= 42 then
                            toggleDropdown()
                        end
                    end
                end)
                
                function Dropdown:SetValue(value)
                    Dropdown.Value = value
                    updateDisplay()
                end
                
                function Dropdown:OnChanged(cb) Dropdown.Changed = cb end
                
                Options[idx] = Dropdown
                return Dropdown
            end
            
            function Groupbox:AddButton(buttonOptions)
                buttonOptions = buttonOptions or {}
                local text = buttonOptions.Text or "Button"
                local callback = buttonOptions.Func or buttonOptions.Callback or function() end
                
                local btn = Create("TextButton", {
                    BackgroundColor3 = Theme.Secondary,
                    Size = UDim2.new(1, 0, 0, 38),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Parent = container
                })
                AddCorner(btn, 10)
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                end)
                
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = Theme.Secondary}, 0.15)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    task.spawn(callback)
                end)
                
                return btn
            end
            
            function Groupbox:AddInput(idx, inputOptions)
                inputOptions = inputOptions or {}
                local text = inputOptions.Text or "Input"
                local default = inputOptions.Default or ""
                local placeholder = inputOptions.Placeholder or "Enter text..."
                local callback = inputOptions.Callback or function() end
                
                local Input = { Value = default, Type = "Input" }
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local inputBox = Create("TextBox", {
                    BackgroundColor3 = Theme.Secondary,
                    Size = UDim2.new(1, 0, 0, 38),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDark,
                    Text = default,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = container
                })
                AddCorner(inputBox, 10)
                AddPadding(inputBox, 12)
                
                inputBox.FocusLost:Connect(function()
                    Input.Value = inputBox.Text
                    task.spawn(callback, Input.Value)
                end)
                
                function Input:SetValue(value)
                    Input.Value = value
                    inputBox.Text = value
                end
                
                Options[idx] = Input
                return Input
            end
            
            Tab.Groupboxes[name] = Groupbox
            return Groupbox
        end
        
        if #Window.Tabs == 0 then
            Window.ActiveTab = Tab
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    function Library:Toggle(state)
        if state == nil then state = not Library.Toggled end
        Library.Toggled = state
        MainWindow.Visible = state
    end
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            Library:Toggle()
        end
    end)
    
    Library.Window = Window
    return Window
end

print("[Modern UI] Library loaded successfully!")
return Library
