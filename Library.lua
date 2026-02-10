--[[
    Modern UI Library - Combined Test Script
    Fixed: Dragging, Slider, Tabs expand, Dropdown styling
]]

--============================================
-- LIBRARY START
--============================================

local cloneref = cloneref or function(instance) return instance end

local CoreGui = cloneref(game:GetService("CoreGui"))

-- Destroy previous UI if re-executed (check both CoreGui and gethui)
local function destroyOldUI()
    local function scanAndDestroy(parent)
        if not parent then return end
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("ScreenGui") then
                if child:GetAttribute("ModernUILib") or child.Name:match("^Hbo%d+$") then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
    scanAndDestroy(CoreGui)
    if gethui then pcall(function() scanAndDestroy(gethui()) end) end
end
destroyOldUI()
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Fallback icons in case HTTP fails
local FallbackIcons = {
    ["home"] = "rbxassetid://10723407389",
    ["user"] = "rbxassetid://10747373176",
    ["eye"] = "rbxassetid://10723346959",
    ["settings"] = "rbxassetid://10734950309",
    ["bell"] = "rbxassetid://10709775704",
    ["check"] = "rbxassetid://10709790644",
    ["x"] = "rbxassetid://10747384394",
    ["info"] = "rbxassetid://10723415903",
    ["alert-circle"] = "rbxassetid://10709752996",
    ["alert-triangle"] = "rbxassetid://10709753149",
    ["search"] = "rbxassetid://10734943674",
    ["chevron-down"] = "rbxassetid://10709790948",
    ["chevron-up"] = "rbxassetid://10709791523",
    ["folder"] = "rbxassetid://10723387563",
    ["star"] = "rbxassetid://10734966248",
    ["heart"] = "rbxassetid://10723406885",
    ["shield"] = "rbxassetid://10734951847",
    ["zap"] = "rbxassetid://10747385618",
    ["target"] = "rbxassetid://10734977012",
    ["globe"] = "rbxassetid://10723404337",
    ["swords"] = "rbxassetid://10734975692",
    ["crosshair"] = "rbxassetid://10709818534",
}

-- Load Lucide Icons from dawid's GitHub repository
local Icons = {}
local success, iconsModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/Icons.lua"))()
end)

if success and iconsModule and iconsModule.assets then
    Icons = iconsModule.assets
else
    -- Use fallback icons if HTTP fails
    Icons = FallbackIcons
end

local function GetIcon(name)
    if not name then return nil end
    -- Try exact match first
    if Icons[name] then return Icons[name] end
    -- Try with lucide- prefix
    if Icons["lucide-" .. name] then return Icons["lucide-" .. name] end
    -- Try without lucide- prefix
    local withoutPrefix = name:gsub("^lucide%-", "")
    if Icons[withoutPrefix] then return Icons[withoutPrefix] end
    -- Try fallback icons
    if FallbackIcons[name] then return FallbackIcons[name] end
    if FallbackIcons[withoutPrefix] then return FallbackIcons[withoutPrefix] end
    return nil
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Hbo" .. tostring(math.random(100000, 999999))
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
end)

ScreenGui:SetAttribute("ModernUILib", true)
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(17, 19, 23),
    Secondary = Color3.fromRGB(24, 27, 31),
    Tertiary = Color3.fromRGB(32, 36, 42),
    Accent = Color3.fromRGB(170, 235, 95),
    AccentDark = Color3.fromRGB(130, 195, 65),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(140, 145, 155),
    Border = Color3.fromRGB(45, 50, 58),
    Warning = Color3.fromRGB(230, 180, 50),
    Error = Color3.fromRGB(220, 80, 80),
}

-- Stores
local Toggles = {}
local Options = {}

-- Theme Element Tracking (for live theme updates)
local ThemedElements = {}

local function RegisterThemed(element, property, themeKey, modifier)
    table.insert(ThemedElements, {
        Element = element,
        Property = property,
        ThemeKey = themeKey,
        Modifier = modifier -- optional function to modify the color
    })
end

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
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
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
    local iconAsset = GetIcon(iconName)
    
    if iconAsset then
        local icon = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, size, 0, size),
            Image = iconAsset,
            ImageColor3 = color or Theme.Text,
            ScaleType = Enum.ScaleType.Fit,
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
    PickerActive = false,
    Toggles = Toggles,
    Options = Options,
    ToggleKey = Enum.KeyCode.RightControl,
    _toggleElements = {},
    _tabElements = {},
    _buttonElements = {},
    _inputElements = {},
    _dropdownElements = {},
}

-- Update all themed elements when theme changes
function Library:UpdateColors()
    -- Update registered themed elements
    for _, entry in ipairs(ThemedElements) do
        local element = entry.Element
        local property = entry.Property
        local themeKey = entry.ThemeKey
        
        if element and element.Parent then
            local color = self.Theme[themeKey]
            if color then
                if entry.Modifier then
                    color = entry.Modifier(color)
                end
                pcall(function()
                    element[property] = color
                end)
            end
        end
    end
    
    -- Update toggles
    for _, toggle in ipairs(self._toggleElements) do
        if toggle.checkbox and toggle.checkbox.Parent then
            toggle.checkbox.BackgroundColor3 = toggle.getValue() and self.Theme.Accent or self.Theme.Tertiary
        end
        if toggle.label and toggle.label.Parent then
            toggle.label.TextColor3 = toggle.getValue() and self.Theme.Text or self.Theme.TextDark
        end
    end
    
    -- Update tabs
    for _, tab in ipairs(self._tabElements) do
        if tab.iconHolder and tab.isSelected then
            local icon = tab.iconHolder:FindFirstChildOfClass("ImageLabel")
            if icon then
                icon.ImageColor3 = tab.isSelected() and self.Theme.Accent or self.Theme.TextDark
            end
        end
        if tab.button and tab.button.Parent then
            tab.button.BackgroundColor3 = self.Theme.Tertiary
        end
        if tab.buttonStroke and tab.buttonStroke.Parent then
            tab.buttonStroke.Color = self.Theme.Border
        end
        if tab.textLabel and tab.textLabel.Parent then
            tab.textLabel.TextColor3 = self.Theme.Text
        end
    end
    
    -- Update buttons
    for _, btn in ipairs(self._buttonElements) do
        if btn.button and btn.button.Parent then
            btn.button.BackgroundColor3 = self.Theme.Tertiary
            btn.button.TextColor3 = self.Theme.Text
            local stroke = btn.button:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = self.Theme.Border end
        end
    end
    
    -- Update inputs
    for _, inp in ipairs(self._inputElements) do
        if inp.container and inp.container.Parent then
            inp.container.BackgroundColor3 = self.Theme.Tertiary
            local stroke = inp.container:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = self.Theme.Border end
        end
        if inp.textbox and inp.textbox.Parent then
            inp.textbox.TextColor3 = self.Theme.Text
            inp.textbox.PlaceholderColor3 = self.Theme.TextDark
        end
        if inp.label and inp.label.Parent then
            inp.label.TextColor3 = self.Theme.TextDark
        end
    end
    
    -- Update dropdowns
    for _, dd in ipairs(self._dropdownElements) do
        if dd.container and dd.container.Parent then
            dd.container.BackgroundColor3 = self.Theme.Tertiary
            local stroke = dd.container:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = self.Theme.Border end
        end
        if dd.displayLabel and dd.displayLabel.Parent then
            dd.displayLabel.TextColor3 = self.Theme.Text
        end
        if dd.titleLabel and dd.titleLabel.Parent then
            dd.titleLabel.TextColor3 = self.Theme.TextDark
        end
        if dd.arrow and dd.arrow.Parent then
            dd.arrow.ImageColor3 = self.Theme.TextDark
        end
    end
end

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
        Size = UDim2.new(1, 0, 0, 80),
        ClipsDescendants = true,
        Parent = NotificationContainer
    })
    AddCorner(notif, 4)
    AddStroke(notif, Theme.Border, 1)
    
    local iconName = "bell"
    if notifType == "warning" then iconName = "alert-triangle" end
    if notifType == "error" then iconName = "alert-circle" end
    
    local iconFrame = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(0, 16, 0, 16),
        Parent = notif
    })
    CreateIcon(iconFrame, iconName, 16, accentColor)
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 34, 0, 10),
        Size = UDim2.new(1, -46, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    -- Divider line
    Create("Frame", {
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(0, 12, 0, 30),
        Size = UDim2.new(1, -24, 0, 1),
        Parent = notif
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 38),
        Size = UDim2.new(1, -24, 0, 22),
        Font = Enum.Font.Gotham,
        Text = description,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notif
    })
    
    local progressBg = Create("Frame", {
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 12, 1, -14),
        Size = UDim2.new(1, -24, 0, 6),
        ClipsDescendants = true,
        Parent = notif
    })
    AddCorner(progressBg, 3)
    
    local progress = Create("Frame", {
        BackgroundColor3 = accentColor,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = progressBg
    })
    AddCorner(progress, 3)
    
    Tween(notif, {BackgroundTransparency = 0}, 0.3)
    Tween(progress, {Position = UDim2.new(-1, 0, 0, 0)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        local fadeOut = Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        fadeOut.Completed:Wait()
        notif:Destroy()
    end)
    
    return notif
end

--============================================
-- WATERMARK
--============================================

local Watermark = Create("Frame", {
    Name = "Watermark",
    BackgroundColor3 = Theme.Background,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 0, 0, 38),
    AutomaticSize = Enum.AutomaticSize.X,
    BorderSizePixel = 0,
    Parent = ScreenGui
})
AddCorner(Watermark, 6)
RegisterThemed(Watermark, "BackgroundColor3", "Background")

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    Parent = Watermark
})

Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    Parent = Watermark
})

local WatermarkLabels = {}
local watermarkItems = {"HOLEX", "Lobby", "144 FPS", "25ms", "12:18 PM"}
local WatermarkAccentLabel = nil

for i, text in ipairs(watermarkItems) do
    local isAccent = (i == 1)
    local label = Create("TextLabel", {
        Name = "Item" .. i,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = isAccent and Theme.Accent or Theme.Text,
        TextSize = 12,
        Parent = Watermark
    })
    if isAccent then
        WatermarkAccentLabel = label
        RegisterThemed(label, "TextColor3", "Accent")
    else
        RegisterThemed(label, "TextColor3", "Text")
    end
    WatermarkLabels[i] = label
end

function Library:SetWatermark(items)
    for i, text in ipairs(items) do
        if WatermarkLabels[i] then
            WatermarkLabels[i].Text = text
        end
    end
end

function Library:SetWatermarkVisibility(visible)
    Watermark.Visible = visible
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
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainWindow, 12)
    local mainStroke = AddStroke(MainWindow, Theme.Border, 1)
    RegisterThemed(MainWindow, "BackgroundColor3", "Background")
    RegisterThemed(mainStroke, "Color", "Border")
    
    Library.MainWindow = MainWindow
    Library.Toggled = options.AutoShow ~= false
    
    -- Top bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 65),
        Active = true,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        Parent = MainWindow
    })
    AddCorner(TopBar, 12)
    RegisterThemed(TopBar, "BackgroundColor3", "Secondary")
    
    -- Bottom fill to hide rounded corners at bottom of TopBar
    local topBarFill = Create("Frame", {
        BackgroundColor3 = Theme.Secondary,
        Position = UDim2.new(0, 0, 1, -14),
        Size = UDim2.new(1, 0, 0, 14),
        BorderSizePixel = 0,
        Parent = TopBar
    })
    RegisterThemed(topBarFill, "BackgroundColor3", "Secondary")
    
    -- Logo with planet icon (right side)
    local LogoContainer = Create("Frame", {
        BackgroundColor3 = Theme.Tertiary,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 48, 0, 48),
        ZIndex = 2,
        Parent = TopBar
    })
    AddCorner(LogoContainer, 6)
    local logoStroke = AddStroke(LogoContainer, Theme.Border, 1)
    RegisterThemed(LogoContainer, "BackgroundColor3", "Tertiary")
    RegisterThemed(logoStroke, "Color", "Border")
    
    local logoIconHolder = Create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 34, 0, 34),
        ZIndex = 3,
        Parent = LogoContainer
    })
    
    -- Custom logo image
    local logoImage = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Image = "rbxassetid://76714333885352",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 4,
        Parent = logoIconHolder
    })
    RegisterThemed(logoImage, "ImageColor3", "Accent")
    
    -- Dedicated drag area (between logo and tabs, and after tabs)
    local DragArea = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = TopBar
    })
    
    -- SMOOTH DRAGGING (uses global input tracking)
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateDrag(input)
        if dragStart and startPos then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
    
    DragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = MainWindow.Position
            dragInput = input
        end
    end)
    
    DragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
            startPos = nil
            dragInput = nil
        end
    end)
    
    -- Tab container (starts from left side)
    local TabButtonContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 500, 1, 0),
        ZIndex = 2,
        Active = true,
        Parent = TopBar
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = TabButtonContainer
    })
    
    -- Resize handle (bottom right)
    local ResizeHandle = Create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Parent = MainWindow
    })
    
    -- Resize functionality
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    local minSize = Vector2.new(600, 400)
    local maxSize = Vector2.new(1200, 800)
    
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = MainWindow.AbsoluteSize
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
            local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
            MainWindow.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
            resizeStart = nil
            startSize = nil
        end
    end)
    
    -- Tab content container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 65),
        Size = UDim2.new(1, 0, 1, -65),
        BorderSizePixel = 0,
        Parent = MainWindow
    })
    
    -- Add Tab (with expanding effect)
    function Window:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or "home"
        local isFirst = #Window.Tabs == 0
        
        local Tab = {
            Name = tabName,
            Groupboxes = {}
        }
        
        -- Tab button with expandable text
        local tabBtn = Create("Frame", {
            BackgroundColor3 = Theme.Tertiary,
            Size = isFirst and UDim2.new(0, 120, 0, 48) or UDim2.new(0, 48, 0, 48),
            ClipsDescendants = true,
            Active = true,
            Parent = TabButtonContainer
        })
        AddCorner(tabBtn, 6)
        local tabBtnStroke = AddStroke(tabBtn, Theme.Border, 1)
        
        local iconHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 11, 0.5, -13),
            Size = UDim2.new(0, 26, 0, 26),
            Parent = tabBtn
        })
        
        local iconColor = isFirst and Theme.Accent or Theme.TextDark
        CreateIcon(iconHolder, tabIcon, 26, iconColor)
        
        -- Tab text label (visible when expanded)
        local tabTextLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 44, 0, 0),
            Size = UDim2.new(0, 70, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = isFirst and 0 or 1,
            Parent = tabBtn
        })
        
        Tab.Button = tabBtn
        Tab.ButtonStroke = tabBtnStroke
        Tab.IconHolder = iconHolder
        Tab.TextLabel = tabTextLabel
        
        local tabFrame = Create("Frame", {
            Name = tabName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            Visible = isFirst,
            Parent = TabContainer
        })
        
        Tab.Frame = tabFrame
        
        local contentArea = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 25, 0, 18),
            Size = UDim2.new(1, -50, 1, -36),
            BorderSizePixel = 0,
            Parent = tabFrame
        })
        
        local leftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -14, 1, -10),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = contentArea
        })
        RegisterThemed(leftColumn, "ScrollBarImageColor3", "Accent")
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = leftColumn
        })
        
        Create("UIPadding", {
            PaddingRight = UDim.new(0, 10),
            Parent = leftColumn
        })
        
        local rightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 14, 0, 0),
            Size = UDim2.new(0.5, -14, 1, -10),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = contentArea
        })
        RegisterThemed(rightColumn, "ScrollBarImageColor3", "Accent")
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = rightColumn
        })
        
        Create("UIPadding", {
            PaddingRight = UDim.new(0, 10),
            Parent = rightColumn
        })
        
        Tab.LeftColumn = leftColumn
        Tab.RightColumn = rightColumn
        
        function Tab:Show()
            for _, t in pairs(Window.Tabs) do
                t.Frame.Visible = false
                -- Collapse other tabs
                Tween(t.Button, {Size = UDim2.new(0, 48, 0, 48)}, 0.2)
                Tween(t.TextLabel, {TextTransparency = 1}, 0.15)
                for _, c in pairs(t.IconHolder:GetChildren()) do
                    if c:IsA("ImageLabel") then Tween(c, {ImageColor3 = Theme.TextDark}, 0.15)
                    elseif c:IsA("TextLabel") then Tween(c, {TextColor3 = Theme.TextDark}, 0.15) end
                end
            end
            Tab.Frame.Visible = true
            -- Expand selected tab (icon turns green)
            Tween(Tab.Button, {Size = UDim2.new(0, 120, 0, 48)}, 0.2)
            Tween(Tab.TextLabel, {TextTransparency = 0}, 0.15)
            for _, c in pairs(Tab.IconHolder:GetChildren()) do
                if c:IsA("ImageLabel") then Tween(c, {ImageColor3 = Theme.Accent}, 0.15)
                elseif c:IsA("TextLabel") then Tween(c, {TextColor3 = Theme.Accent}, 0.15) end
            end
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
            
            -- Outer groupbox frame with background
            local groupboxFrame = Create("Frame", {
                BackgroundColor3 = Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                Parent = parent
            })
            AddCorner(groupboxFrame, 8)
            RegisterThemed(groupboxFrame, "BackgroundColor3", "Secondary")
            
            -- Title
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 10),
                Size = UDim2.new(1, -28, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = groupboxFrame
            })
            
            -- Content container
            local container = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 34),
                Size = UDim2.new(1, -28, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = groupboxFrame
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = container
            })
            
            -- Bottom padding
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 14),
                Parent = groupboxFrame
            })
            
            Groupbox.Frame = groupboxFrame
            Groupbox.Container = container
            
            function Groupbox:AddLabel(text)
                local labelContainer = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    ClipsDescendants = false,
                    Parent = container
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = labelContainer
                })
                
                local LabelObj = { Instance = label, Container = labelContainer, Type = "Label" }
                function LabelObj:SetText(newText) label.Text = newText end
                
                -- AddKeyPicker for Labels (Linoria-style)
                function LabelObj:AddKeyPicker(kpIdx, kpOptions)
                    kpOptions = kpOptions or {}
                    local kpDefault = kpOptions.Default or "None"
                    local kpText = kpOptions.Text or "Keybind"
                    local kpMode = kpOptions.Mode or "Toggle"
                    local kpCallback = kpOptions.Callback or function() end
                    local kpChangedCallback = kpOptions.ChangedCallback or function() end
                    local kpNoUI = kpOptions.NoUI or false
                    local kpSyncToggleState = kpOptions.SyncToggleState or false
                    
                    local KeyPicker = {
                        Value = kpDefault,
                        Mode = kpMode,
                        Toggled = false,
                        Type = "KeyPicker"
                    }
                    
                    local function getKeyCode(keyName)
                        if keyName == "None" or keyName == nil then return nil end
                        local success, keyCode = pcall(function() return Enum.KeyCode[keyName] end)
                        return success and keyCode or nil
                    end
                    
                    local function getKeyName(keyCode)
                        if not keyCode then return "None" end
                        local name = keyCode.Name
                        if name == "RightControl" then return "RCtrl" end
                        if name == "LeftControl" then return "LCtrl" end
                        if name == "RightShift" then return "RShift" end
                        if name == "LeftShift" then return "LShift" end
                        if name == "RightAlt" then return "RAlt" end
                        if name == "LeftAlt" then return "LAlt" end
                        return name
                    end
                    
                    local function getDisplayText(keyName)
                        if keyName == "None" then return "[None]" end
                        local kc = getKeyCode(keyName)
                        return kc and ("[" .. getKeyName(kc) .. "]") or "[None]"
                    end
                    
                    -- Create key picker button (right side)
                    local keyBtn = Create("TextButton", {
                        BackgroundColor3 = Theme.Tertiary,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 55, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = getDisplayText(kpDefault),
                        TextColor3 = Theme.TextDark,
                        TextSize = 11,
                        AutoButtonColor = false,
                        BorderSizePixel = 0,
                        Visible = not kpNoUI,
                        Parent = labelContainer
                    })
                    AddCorner(keyBtn, 4)
                    RegisterThemed(keyBtn, "BackgroundColor3", "Tertiary")
                    
                    local listening = false
                    
                    keyBtn.MouseButton1Click:Connect(function()
                        listening = true
                        keyBtn.Text = "[...]"
                        Tween(keyBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background}, 0.15)
                    end)
                    
                    UserInputService.InputBegan:Connect(function(input, processed)
                        if processed then return end
                        
                        -- Handle keybind listening
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            if input.KeyCode == Enum.KeyCode.Escape then
                                KeyPicker.Value = "None"
                                keyBtn.Text = "[None]"
                            else
                                KeyPicker.Value = input.KeyCode.Name
                                keyBtn.Text = "[" .. getKeyName(input.KeyCode) .. "]"
                            end
                            Tween(keyBtn, {BackgroundColor3 = Theme.Tertiary, TextColor3 = Theme.TextDark}, 0.15)
                            task.spawn(kpChangedCallback, KeyPicker.Value)
                            return
                        end
                        
                        -- Handle key press for activation
                        if not listening and KeyPicker.Value ~= "None" then
                            local keyCode = getKeyCode(KeyPicker.Value)
                            if keyCode and input.KeyCode == keyCode then
                                if KeyPicker.Mode == "Toggle" then
                                    KeyPicker.Toggled = not KeyPicker.Toggled
                                    task.spawn(kpCallback, KeyPicker.Toggled)
                                elseif KeyPicker.Mode == "Hold" then
                                    KeyPicker.Toggled = true
                                    task.spawn(kpCallback, true)
                                end
                            end
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if KeyPicker.Mode == "Hold" and KeyPicker.Value ~= "None" then
                            local keyCode = getKeyCode(KeyPicker.Value)
                            if keyCode and input.KeyCode == keyCode then
                                KeyPicker.Toggled = false
                                task.spawn(kpCallback, false)
                            end
                        end
                    end)
                    
                    function KeyPicker:GetState()
                        if KeyPicker.Mode == "Always" then return true end
                        return KeyPicker.Toggled
                    end
                    
                    function KeyPicker:SetValue(data)
                        if type(data) == "table" then
                            KeyPicker.Value = data[1] or "None"
                            KeyPicker.Mode = data[2] or KeyPicker.Mode
                        else
                            KeyPicker.Value = data or "None"
                        end
                        keyBtn.Text = getDisplayText(KeyPicker.Value)
                    end
                    
                    function KeyPicker:OnClick(cb) kpCallback = cb end
                    function KeyPicker:OnChanged(cb) kpChangedCallback = cb end
                    
                    Options[kpIdx] = KeyPicker
                    return KeyPicker
                end
                
                return LabelObj
            end
            
            function Groupbox:AddToggle(idx, toggleOptions)
                toggleOptions = toggleOptions or {}
                local text = toggleOptions.Text or "Toggle"
                local default = toggleOptions.Default or false
                local callback = toggleOptions.Callback or function() end
                
                local Toggle = { 
                    Value = default, 
                    Type = "Toggle",
                    Addons = {},
                    Container = nil,
                    Label = nil
                }
                
                local toggleContainer = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = container
                })
                Toggle.Container = toggleContainer
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = default and Theme.Text or Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleContainer
                })
                Toggle.Label = label
                
                -- Addons container (right side, before checkbox)
                local addonsFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -40, 0.5, 0),
                    Size = UDim2.new(0, 0, 0, 20),
                    Parent = toggleContainer
                })
                
                local addonsLayout = Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 6),
                    Parent = addonsFrame
                })
                
                local checkbox = Create("Frame", {
                    BackgroundColor3 = default and Theme.Accent or Theme.Tertiary,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 26, 0, 26),
                    Parent = toggleContainer
                })
                AddCorner(checkbox, 6)
                
                local checkmark = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = GetIcon("check") or "rbxassetid://10709790644",
                    ImageColor3 = Theme.Background,
                    ImageTransparency = default and 0 or 1,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = checkbox
                })
                
                function Toggle:SetValue(value)
                    Toggle.Value = value
                    Tween(checkbox, {BackgroundColor3 = value and Theme.Accent or Theme.Tertiary}, 0.15)
                    Tween(checkmark, {ImageTransparency = value and 0 or 1}, 0.15)
                    label.TextColor3 = value and Theme.Text or Theme.TextDark
                    task.spawn(callback, value)
                end
                
                function Toggle:OnChanged(cb) Toggle.Changed = cb end
                
                -- AddColorPicker addon
                function Toggle:AddColorPicker(cpIdx, cpOptions)
                    cpOptions = cpOptions or {}
                    local cpDefault = cpOptions.Default or Color3.fromRGB(255, 255, 255)
                    local cpCallback = cpOptions.Callback or function() end
                    local cpTitle = cpOptions.Title or "Color Picker"
                    
                    local ColorPicker = {
                        Value = cpDefault,
                        Type = "ColorPicker",
                        Hue = 0,
                        Sat = 1,
                        Vib = 1
                    }
                    
                    -- Set initial HSV
                    local h, s, v = cpDefault:ToHSV()
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = h, s, v
                    
                    -- Color display box
                    local colorDisplay = Create("Frame", {
                        BackgroundColor3 = cpDefault,
                        Size = UDim2.new(0, 20, 0, 20),
                        LayoutOrder = -1,
                        Parent = addonsFrame
                    })
                    AddCorner(colorDisplay, 4)
                    AddStroke(colorDisplay, Theme.Border, 1)
                    
                    -- Color picker popup
                    local pickerFrame = Create("Frame", {
                        BackgroundColor3 = Theme.Secondary,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.new(0, 220, 0, 260),
                        Visible = false,
                        ZIndex = 100,
                        Active = true,
                        ClipsDescendants = true,
                        Parent = ScreenGui
                    })
                    AddCorner(pickerFrame, 10)
                    AddStroke(pickerFrame, Theme.Border, 1)
                    
                    -- Accent bar (top)
                    local accentBar = Create("Frame", {
                        BackgroundColor3 = Theme.Accent,
                        Size = UDim2.new(1, 0, 0, 3),
                        ZIndex = 101,
                        Parent = pickerFrame
                    })
                    
                    -- Title
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 10),
                        Size = UDim2.new(1, -24, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = cpTitle,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 101,
                        Parent = pickerFrame
                    })
                    
                    -- Saturation/Value map
                    local satVibMap = Create("Frame", {
                        BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1),
                        Position = UDim2.new(0, 12, 0, 38),
                        Size = UDim2.new(0, 170, 0, 170),
                        ZIndex = 101,
                        Active = true,
                        Parent = pickerFrame
                    })
                    AddCorner(satVibMap, 6)
                    
                    -- White to transparent gradient (saturation)
                    Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                        }),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Parent = satVibMap
                    })
                    
                    -- Black overlay (value)
                    local valueOverlay = Create("Frame", {
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 102,
                        Active = true,
                        Parent = satVibMap
                    })
                    AddCorner(valueOverlay, 6)
                    
                    Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(0, 0, 0)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        }),
                        Rotation = 90,
                        Parent = valueOverlay
                    })
                    
                    -- SV cursor
                    local svCursor = Create("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        ZIndex = 103,
                        Parent = satVibMap
                    })
                    AddCorner(svCursor, 6)
                    AddStroke(svCursor, Color3.new(0, 0, 0), 2)
                    
                    -- Hue slider
                    local hueSlider = Create("Frame", {
                        Position = UDim2.new(0, 190, 0, 38),
                        Size = UDim2.new(0, 18, 0, 170),
                        ZIndex = 101,
                        Active = true,
                        Parent = pickerFrame
                    })
                    AddCorner(hueSlider, 4)
                    
                    Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                        }),
                        Rotation = 90,
                        Parent = hueSlider
                    })
                    
                    -- Hue cursor
                    local hueCursor = Create("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, ColorPicker.Hue, 0),
                        Size = UDim2.new(1, 4, 0, 6),
                        ZIndex = 102,
                        Parent = hueSlider
                    })
                    AddCorner(hueCursor, 3)
                    AddStroke(hueCursor, Color3.new(0, 0, 0), 1)
                    
                    -- Hex input
                    local hexBox = Create("TextBox", {
                        BackgroundColor3 = Theme.Tertiary,
                        Position = UDim2.new(0, 12, 0, 218),
                        Size = UDim2.new(1, -24, 0, 30),
                        Font = Enum.Font.GothamMedium,
                        Text = "#" .. cpDefault:ToHex():upper(),
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        ClearTextOnFocus = false,
                        ZIndex = 101,
                        Parent = pickerFrame
                    })
                    AddCorner(hexBox, 6)
                    
                    local function updateColor()
                        local color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
                        ColorPicker.Value = color
                        colorDisplay.BackgroundColor3 = color
                        satVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
                        svCursor.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
                        hueCursor.Position = UDim2.new(0.5, 0, ColorPicker.Hue, 0)
                        hexBox.Text = "#" .. color:ToHex():upper()
                        task.spawn(cpCallback, color)
                        if ColorPicker.Changed then ColorPicker.Changed(color) end
                    end
                    
                    function ColorPicker:SetValue(color)
                        local h, s, v = color:ToHSV()
                        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = h, s, v
                        updateColor()
                    end
                    
                    function ColorPicker:SetValueRGB(color, transparency)
                        ColorPicker:SetValue(color)
                        if transparency then
                            ColorPicker.Transparency = transparency
                        end
                    end
                    
                    function ColorPicker:OnChanged(cb) ColorPicker.Changed = cb end
                    
                    -- SV map interaction
                    local svDragging = false
                    
                    satVibMap.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = true
                            Library.PickerActive = true
                            -- Immediately update on click
                            local relX = math.clamp((input.Position.X - satVibMap.AbsolutePosition.X) / satVibMap.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((input.Position.Y - satVibMap.AbsolutePosition.Y) / satVibMap.AbsoluteSize.Y, 0, 1)
                            ColorPicker.Sat = relX
                            ColorPicker.Vib = 1 - relY
                            updateColor()
                        end
                    end)
                    valueOverlay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = true
                            Library.PickerActive = true
                            -- Immediately update on click
                            local relX = math.clamp((input.Position.X - satVibMap.AbsolutePosition.X) / satVibMap.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((input.Position.Y - satVibMap.AbsolutePosition.Y) / satVibMap.AbsoluteSize.Y, 0, 1)
                            ColorPicker.Sat = relX
                            ColorPicker.Vib = 1 - relY
                            updateColor()
                        end
                    end)
                    
                    -- Hue slider interaction
                    local hueDragging = false
                    hueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = true
                            Library.PickerActive = true
                            -- Immediately update on click
                            local relY = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                            ColorPicker.Hue = relY
                            updateColor()
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if svDragging then
                                local relX = math.clamp((input.Position.X - satVibMap.AbsolutePosition.X) / satVibMap.AbsoluteSize.X, 0, 1)
                                local relY = math.clamp((input.Position.Y - satVibMap.AbsolutePosition.Y) / satVibMap.AbsoluteSize.Y, 0, 1)
                                ColorPicker.Sat = relX
                                ColorPicker.Vib = 1 - relY
                                updateColor()
                            end
                            if hueDragging then
                                local relY = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                                ColorPicker.Hue = relY
                                updateColor()
                            end
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = false
                            hueDragging = false
                            Library.PickerActive = false
                        end
                    end)
                    
                    -- Block input when interacting with picker
                    pickerFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            Library.PickerActive = true
                        end
                    end)
                    
                    -- Hex input
                    hexBox.FocusLost:Connect(function()
                        local hex = hexBox.Text:gsub("#", "")
                        local success, color = pcall(function() return Color3.fromHex(hex) end)
                        if success then
                            ColorPicker:SetValue(color)
                        else
                            hexBox.Text = "#" .. ColorPicker.Value:ToHex():upper()
                        end
                    end)
                    
                    -- Toggle picker visibility
                    local pickerOpen = false
                    colorDisplay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            pickerOpen = not pickerOpen
                            pickerFrame.Visible = pickerOpen
                            if pickerOpen then
                                local pos = colorDisplay.AbsolutePosition
                                pickerFrame.Position = UDim2.fromOffset(pos.X - 200, pos.Y + 28)
                            end
                        end
                    end)
                    
                    -- Close when clicking outside
                    UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and pickerOpen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local framePos = pickerFrame.AbsolutePosition
                            local frameSize = pickerFrame.AbsoluteSize
                            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                                local displayPos = colorDisplay.AbsolutePosition
                                local displaySize = colorDisplay.AbsoluteSize
                                if not (mousePos.X >= displayPos.X and mousePos.X <= displayPos.X + displaySize.X and
                                        mousePos.Y >= displayPos.Y and mousePos.Y <= displayPos.Y + displaySize.Y) then
                                    pickerOpen = false
                                    pickerFrame.Visible = false
                                end
                            end
                        end
                    end)
                    
                    Toggle.Addons[cpIdx] = ColorPicker
                    Options[cpIdx] = ColorPicker
                    return Toggle
                end
                
                -- AddKeyPicker addon
                function Toggle:AddKeyPicker(kpIdx, kpOptions)
                    kpOptions = kpOptions or {}
                    local kpDefault = kpOptions.Default or "None"
                    local kpCallback = kpOptions.Callback or function() end
                    local kpMode = kpOptions.Mode or "Toggle" -- Toggle, Hold, Always
                    local syncToggle = kpOptions.SyncToggleState or false
                    
                    local KeyPicker = {
                        Value = kpDefault ~= "None" and Enum.KeyCode[kpDefault] or nil,
                        Mode = kpMode,
                        Type = "KeyPicker",
                        Picking = false
                    }
                    
                    -- Key display box
                    local keyDisplay = Create("Frame", {
                        BackgroundColor3 = Theme.Tertiary,
                        Size = UDim2.new(0, 32, 0, 26),
                        LayoutOrder = 0,
                        BorderSizePixel = 0,
                        Parent = addonsFrame
                    })
                    AddCorner(keyDisplay, 4)
                    RegisterThemed(keyDisplay, "BackgroundColor3", "Tertiary")
                    
                    local keyLabel = Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = kpDefault ~= "None" and kpDefault or "...",
                        TextColor3 = Theme.TextDark,
                        TextSize = 11,
                        Parent = keyDisplay
                    })
                    RegisterThemed(keyLabel, "TextColor3", "TextDark")
                    
                    local function getKeyName(keyCode)
                        if not keyCode then return "..." end
                        local name = keyCode.Name
                        -- Shorten common keys
                        if name:match("^%a$") then return name end
                        if name == "LeftShift" then return "LShift" end
                        if name == "RightShift" then return "RShift" end
                        if name == "LeftControl" then return "LCtrl" end
                        if name == "RightControl" then return "RCtrl" end
                        if name == "LeftAlt" then return "LAlt" end
                        if name == "RightAlt" then return "RAlt" end
                        if #name > 5 then return name:sub(1, 5) end
                        return name
                    end
                    
                    function KeyPicker:SetValue(input)
                        if typeof(input) == "table" then
                            local key, mode, modifiers = input[1], input[2], input[3]
                            if key and typeof(key) == "EnumItem" then
                                KeyPicker.Value = key
                            elseif key and typeof(key) == "string" and Enum.KeyCode[key] then
                                KeyPicker.Value = Enum.KeyCode[key]
                            end
                            if mode then KeyPicker.Mode = mode end
                            if modifiers then KeyPicker.Modifiers = modifiers end
                        elseif typeof(input) == "EnumItem" then
                            KeyPicker.Value = input
                        elseif typeof(input) == "string" and Enum.KeyCode[input] then
                            KeyPicker.Value = Enum.KeyCode[input]
                        end
                        if KeyPicker.Value then
                            keyLabel.Text = getKeyName(KeyPicker.Value)
                        end
                    end
                    
                    function KeyPicker:OnChanged(cb) KeyPicker.Changed = cb end
                    
                    function KeyPicker:GetState()
                        if not KeyPicker.Value then return false end
                        if KeyPicker.Mode == "Always" then return true end
                        if KeyPicker.Mode == "Hold" then
                            return UserInputService:IsKeyDown(KeyPicker.Value)
                        end
                        return false
                    end
                    
                    -- Click to rebind
                    keyDisplay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            KeyPicker.Picking = true
                            keyLabel.Text = "..."
                            Tween(keyDisplay, {BackgroundColor3 = Theme.Accent}, 0.15)
                            Tween(keyLabel, {TextColor3 = Theme.Background}, 0.15)
                        end
                    end)
                    
                    -- Listen for key input
                    UserInputService.InputBegan:Connect(function(input, processed)
                        if processed then return end
                        
                        if KeyPicker.Picking then
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == Enum.KeyCode.Escape then
                                    KeyPicker.Value = nil
                                    keyLabel.Text = "..."
                                else
                                    KeyPicker:SetValue(input.KeyCode)
                                end
                                KeyPicker.Picking = false
                                Tween(keyDisplay, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                                Tween(keyLabel, {TextColor3 = Theme.TextDark}, 0.15)
                                if KeyPicker.Changed then KeyPicker.Changed(KeyPicker.Value) end
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                                   input.UserInputType == Enum.UserInputType.MouseButton2 then
                                -- Ignore mouse clicks during picking
                            end
                        else
                            -- Handle keybind activation
                            if KeyPicker.Value and input.KeyCode == KeyPicker.Value then
                                if KeyPicker.Mode == "Toggle" then
                                    if syncToggle then
                                        Toggle:SetValue(not Toggle.Value)
                                        if Toggle.Changed then Toggle.Changed(Toggle.Value) end
                                    end
                                    task.spawn(kpCallback, Toggle.Value)
                                elseif KeyPicker.Mode == "Hold" then
                                    if syncToggle then
                                        Toggle:SetValue(true)
                                        if Toggle.Changed then Toggle.Changed(true) end
                                    end
                                    task.spawn(kpCallback, true)
                                end
                            end
                        end
                    end)
                    
                    -- Handle hold mode key release
                    UserInputService.InputEnded:Connect(function(input)
                        if KeyPicker.Value and input.KeyCode == KeyPicker.Value then
                            if KeyPicker.Mode == "Hold" then
                                if syncToggle then
                                    Toggle:SetValue(false)
                                    if Toggle.Changed then Toggle.Changed(false) end
                                end
                                task.spawn(kpCallback, false)
                            end
                        end
                    end)
                    
                    Toggle.Addons[kpIdx] = KeyPicker
                    Options[kpIdx] = KeyPicker
                    return Toggle
                end
                
                checkbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle:SetValue(not Toggle.Value)
                        if Toggle.Changed then Toggle.Changed(Toggle.Value) end
                    end
                end)
                
                -- Register for theme updates
                table.insert(Library._toggleElements, {
                    checkbox = checkbox,
                    label = label,
                    getValue = function() return Toggle.Value end
                })
                
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
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = container
                })
                
                local labelRow = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
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
                
                -- Slider track with padding for knob
                local knobSize = 10
                local sliderBg = Create("Frame", {
                    BackgroundColor3 = Theme.Tertiary,
                    Position = UDim2.new(0, knobSize/2, 0, 24),
                    Size = UDim2.new(1, -knobSize, 0, 6),
                    Parent = sliderContainer
                })
                AddCorner(sliderBg, 3)
                RegisterThemed(sliderBg, "BackgroundColor3", "Tertiary")
                
                local sliderFill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0),
                    Parent = sliderBg
                })
                AddCorner(sliderFill, 3)
                RegisterThemed(sliderFill, "BackgroundColor3", "Accent")
                
                -- Small white knob
                local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
                
                local knob = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(initialPercent, 0, 0.5, 0),
                    Size = UDim2.new(0, knobSize, 0, knobSize),
                    ZIndex = 2,
                    Parent = sliderBg
                })
                AddCorner(knob, knobSize/2)
                
                local function updateSlider(percent)
                    percent = math.clamp(percent, 0, 1)
                    local value = min + (max - min) * percent
                    
                    if rounding == 0 then
                        value = math.floor(value + 0.5)
                    else
                        value = math.floor(value * 10^rounding + 0.5) / 10^rounding
                    end
                    
                    Slider.Value = value
                    local displayPercent = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(displayPercent, 0, 1, 0)
                    knob.Position = UDim2.new(displayPercent, 0, 0.5, 0)
                    valueLabel.Text = tostring(value) .. suffix
                    task.spawn(callback, value)
                    if Slider.Changed then Slider.Changed(value) end
                end
                
                function Slider:SetValue(value)
                    local percent = (value - min) / (max - min)
                    updateSlider(percent)
                end
                
                function Slider:OnChanged(cb) Slider.Changed = cb end
                
                local sliding = false
                
                local function startSlide(input)
                    sliding = true
                    local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    updateSlider(percent)
                end
                
                sliderContainer.InputBegan:Connect(function(input)
                    if not Library.PickerActive and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        startSlide(input)
                    end
                end)
                
                sliderBg.InputBegan:Connect(function(input)
                    if not Library.PickerActive and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        startSlide(input)
                    end
                end)
                
                knob.InputBegan:Connect(function(input)
                    if not Library.PickerActive and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        sliding = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and not Library.PickerActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        updateSlider(percent)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
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
                local allowSearch = dropdownOptions.AllowNull ~= false and #values > 5 -- Auto enable search for 5+ items
                
                local Dropdown = {
                    Value = multi and {} or default,
                    Values = values,
                    Multi = multi,
                    Type = "Dropdown"
                }
                
                -- Initialize multi dropdown with default values
                if multi and type(default) == "table" then
                    for _, v in ipairs(default) do
                        Dropdown.Value[v] = true
                    end
                end
                
                local maxVisible = 4
                local itemHeight = 30
                local searchHeight = allowSearch and 34 or 0
                
                -- Label above dropdown
                local titleLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local dropdownContainer = Create("Frame", {
                    BackgroundColor3 = Theme.Tertiary,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true,
                    Parent = container
                })
                AddCorner(dropdownContainer, 6)
                AddStroke(dropdownContainer, Theme.Border, 1)
                
                local displayText = default or "Select..."
                if multi and type(Dropdown.Value) == "table" then
                    local selected = {}
                    for v, enabled in pairs(Dropdown.Value) do
                        if enabled then table.insert(selected, v) end
                    end
                    displayText = #selected > 0 and table.concat(selected, ", ") or "Select..."
                end
                
                local displayLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -45, 0, 38),
                    Font = Enum.Font.Gotham,
                    Text = displayText,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = dropdownContainer
                })
                
                local arrow = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0, 19),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = GetIcon("chevron-down") or "rbxassetid://10709790948",
                    ImageColor3 = Theme.TextDark,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = dropdownContainer
                })
                
                table.insert(Library._dropdownElements, {
                    container = dropdownContainer,
                    displayLabel = displayLabel,
                    titleLabel = titleLabel,
                    arrow = arrow
                })
                
                -- Search box (if enabled)
                local searchBox = nil
                if allowSearch then
                    local searchContainer = Create("Frame", {
                        BackgroundColor3 = Theme.Secondary,
                        Position = UDim2.new(0, 6, 0, 44),
                        Size = UDim2.new(1, -12, 0, 28),
                        Parent = dropdownContainer
                    })
                    AddCorner(searchContainer, 4)
                    
                    searchBox = Create("TextBox", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        Font = Enum.Font.Gotham,
                        PlaceholderText = "Search...",
                        PlaceholderColor3 = Theme.TextDark,
                        Text = "",
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false,
                        Parent = searchContainer
                    })
                end
                
                -- Scrollable options frame
                local visibleCount = math.min(#values, maxVisible)
                local listHeight = visibleCount * itemHeight + (visibleCount - 1) * 2
                
                local optionsScroll = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 44 + searchHeight + 4),
                    Size = UDim2.new(1, -12, 0, listHeight),
                    CanvasSize = UDim2.new(0, 0, 0, #values * (itemHeight + 2)),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = dropdownContainer
                })
                RegisterThemed(optionsScroll, "ScrollBarImageColor3", "Accent")
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = optionsScroll
                })
                
                local isOpen = false
                local optionButtons = {}
                
                local function updateDisplay()
                    if multi then
                        local selected = {}
                        for v, enabled in pairs(Dropdown.Value) do
                            if enabled then table.insert(selected, v) end
                        end
                        displayLabel.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    else
                        displayLabel.Text = Dropdown.Value or "Select..."
                    end
                end
                
                local function filterOptions(searchText)
                    searchText = searchText:lower()
                    local visibleItems = 0
                    for _, btn in pairs(optionButtons) do
                        local matches = searchText == "" or btn.ValueName:lower():find(searchText, 1, true)
                        btn.Button.Visible = matches
                        if matches then visibleItems = visibleItems + 1 end
                    end
                    -- Update scroll canvas
                    optionsScroll.CanvasSize = UDim2.new(0, 0, 0, visibleItems * (itemHeight + 2))
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    local currentVisibleCount = math.min(#values, maxVisible)
                    local currentListHeight = currentVisibleCount * itemHeight + (currentVisibleCount - 1) * 2
                    local expandedHeight = 44 + searchHeight + 8 + currentListHeight + 6
                    local targetSize = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 38)
                    Tween(dropdownContainer, {Size = targetSize}, 0.2)
                    Tween(arrow, {Rotation = isOpen and 180 or 0}, 0.2)
                    
                    if not isOpen and searchBox then
                        searchBox.Text = ""
                        filterOptions("")
                    end
                end
                
                for _, value in ipairs(values) do
                    local isSelected = multi and Dropdown.Value[value]
                    
                    local optionBtn = Create("TextButton", {
                        BackgroundColor3 = Theme.Secondary,
                        BackgroundTransparency = 0.3,
                        Size = UDim2.new(1, 0, 0, itemHeight),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = optionsScroll
                    })
                    AddCorner(optionBtn, 4)
                    
                    -- Checkmark for multi-select
                    local checkmark = nil
                    if multi then
                        checkmark = Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(0, 20, 1, 0),
                            Font = Enum.Font.GothamBold,
                            Text = isSelected and "âœ“" or "",
                            TextColor3 = Theme.Accent,
                            TextSize = 14,
                            Parent = optionBtn
                        })
                    end
                    
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, multi and 28 or 12, 0, 0),
                        Size = UDim2.new(1, multi and -36 or -24, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = value,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = optionBtn
                    })
                    
                    table.insert(optionButtons, {Button = optionBtn, ValueName = value, Checkmark = checkmark})
                    
                    optionBtn.MouseEnter:Connect(function()
                        Tween(optionBtn, {BackgroundTransparency = 0}, 0.1)
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        Tween(optionBtn, {BackgroundTransparency = 0.3}, 0.1)
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[value] = not Dropdown.Value[value]
                            if checkmark then
                                checkmark.Text = Dropdown.Value[value] and "âœ“" or ""
                            end
                        else
                            Dropdown.Value = value
                            toggleDropdown()
                        end
                        updateDisplay()
                        task.spawn(callback, Dropdown.Value)
                    end)
                end
                
                if searchBox then
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        filterOptions(searchBox.Text)
                    end)
                end
                
                dropdownContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local relY = input.Position.Y - dropdownContainer.AbsolutePosition.Y
                        if relY <= 38 then
                            toggleDropdown()
                        end
                    end
                end)
                
                function Dropdown:SetValue(value)
                    Dropdown.Value = value
                    updateDisplay()
                    task.spawn(callback, Dropdown.Value)
                    if Dropdown.Changed then Dropdown.Changed(Dropdown.Value) end
                end
                
                function Dropdown:SetValues(newValues)
                    -- Clear existing options
                    for _, child in pairs(optionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    -- Clear option buttons tracking
                    table.clear(optionButtons)
                    -- Update values and recreate options
                    values = newValues
                    -- Update canvas and scroll size
                    local newVisibleCount = math.min(#values, maxVisible)
                    local newListHeight = newVisibleCount * itemHeight + (newVisibleCount - 1) * 2
                    optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #values * (itemHeight + 2))
                    optionsScroll.Size = UDim2.new(1, -12, 0, newListHeight)
                    
                    for i, val in ipairs(values) do
                        local isSelected = multi and Dropdown.Value[val]
                        
                        local optBtn = Create("TextButton", {
                            BackgroundColor3 = Theme.Secondary,
                            BackgroundTransparency = 0.3,
                            Size = UDim2.new(1, 0, 0, itemHeight),
                            Font = Enum.Font.Gotham,
                            Text = "",
                            AutoButtonColor = false,
                            Parent = optionsScroll
                        })
                        AddCorner(optBtn, 4)
                        
                        local checkmark = nil
                        if multi then
                            checkmark = Create("TextLabel", {
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, 8, 0, 0),
                                Size = UDim2.new(0, 20, 1, 0),
                                Font = Enum.Font.GothamBold,
                                Text = isSelected and "✓" or "",
                                TextColor3 = Theme.Accent,
                                TextSize = 14,
                                Parent = optBtn
                            })
                        end
                        
                        Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, multi and 28 or 12, 0, 0),
                            Size = UDim2.new(1, multi and -36 or -24, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = val,
                            TextColor3 = Theme.Text,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = optBtn
                        })
                        
                        table.insert(optionButtons, {Button = optBtn, ValueName = val, Checkmark = checkmark})
                        
                        optBtn.MouseEnter:Connect(function()
                            Tween(optBtn, {BackgroundTransparency = 0}, 0.1)
                        end)
                        
                        optBtn.MouseLeave:Connect(function()
                            Tween(optBtn, {BackgroundTransparency = 0.3}, 0.1)
                        end)
                        
                        if multi then
                            optBtn.MouseButton1Click:Connect(function()
                                Dropdown.Value[val] = not Dropdown.Value[val]
                                if checkmark then
                                    checkmark.Text = Dropdown.Value[val] and "✓" or ""
                                end
                                updateDisplay()
                                task.spawn(callback, Dropdown.Value)
                            end)
                        else
                            optBtn.MouseButton1Click:Connect(function()
                                Dropdown.Value = val
                                toggleDropdown()
                                updateDisplay()
                                task.spawn(callback, Dropdown.Value)
                            end)
                        end
                    end
                end
                
                function Dropdown:OnChanged(cb) Dropdown.Changed = cb end
                
                Options[idx] = Dropdown
                return Dropdown
            end
            
            function Groupbox:AddButton(buttonOptions, callbackArg)
                -- Support both syntaxes: AddButton("text", func) and AddButton({Text = "text", Func = func})
                local text, callback
                if type(buttonOptions) == "string" then
                    text = buttonOptions
                    callback = callbackArg or function() end
                else
                    buttonOptions = buttonOptions or {}
                    text = buttonOptions.Text or "Button"
                    callback = buttonOptions.Func or buttonOptions.Callback or function() end
                end
                
                local btn = Create("TextButton", {
                    BackgroundColor3 = Theme.Tertiary,
                    Size = UDim2.new(1, 0, 0, 36),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false,
                    Parent = container
                })
                AddCorner(btn, 6)
                AddStroke(btn, Theme.Border, 1)
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = Theme.Secondary}, 0.15)
                end)
                
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    task.spawn(callback)
                end)
                
                table.insert(Library._buttonElements, { button = btn })
                
                return btn
            end
            
            function Groupbox:AddInput(idx, inputOptions)
                inputOptions = inputOptions or {}
                local text = inputOptions.Text or "Input"
                local default = inputOptions.Default or ""
                local placeholder = inputOptions.Placeholder or "Enter text..."
                local callback = inputOptions.Callback or function() end
                
                local Input = { Value = default, Type = "Input" }
                
                local inputLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                -- Input container with proper styling
                local inputContainer = Create("Frame", {
                    BackgroundColor3 = Theme.Tertiary,
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = container
                })
                AddCorner(inputContainer, 6)
                AddStroke(inputContainer, Theme.Border, 1)
                
                local inputBox = Create("TextBox", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDark,
                    Text = default,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = inputContainer
                })
                
                table.insert(Library._inputElements, {
                    container = inputContainer,
                    textbox = inputBox,
                    label = inputLabel
                })
                
                -- Focus effect
                inputBox.Focused:Connect(function()
                    Tween(inputContainer, {BackgroundColor3 = Theme.Secondary}, 0.15)
                end)
                
                inputBox.FocusLost:Connect(function()
                    Tween(inputContainer, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                    Input.Value = inputBox.Text
                    task.spawn(callback, Input.Value)
                    if Input.Changed then Input.Changed(Input.Value) end
                end)
                
                function Input:SetValue(value)
                    Input.Value = value
                    inputBox.Text = value
                end
                
                function Input:OnChanged(cb) Input.Changed = cb end
                
                Options[idx] = Input
                return Input
            end
            
            function Groupbox:AddKeybind(idx, keybindOptions)
                keybindOptions = keybindOptions or {}
                local text = keybindOptions.Text or "Keybind"
                local default = keybindOptions.Default or "RightControl"
                local callback = keybindOptions.Callback or function() end
                local changesToggleKey = keybindOptions.ChangesToggleKey or false
                
                -- Convert string to KeyCode
                local function getKeyCode(keyName)
                    local success, keyCode = pcall(function()
                        return Enum.KeyCode[keyName]
                    end)
                    return success and keyCode or Enum.KeyCode.RightControl
                end
                
                local function getKeyName(keyCode)
                    if not keyCode then return "None" end
                    local name = keyCode.Name
                    -- Shorten common names
                    if name == "RightControl" then return "RCtrl" end
                    if name == "LeftControl" then return "LCtrl" end
                    if name == "RightShift" then return "RShift" end
                    if name == "LeftShift" then return "LShift" end
                    if name == "RightAlt" then return "RAlt" end
                    if name == "LeftAlt" then return "LAlt" end
                    return name
                end
                
                local Keybind = {
                    Value = getKeyCode(default),
                    Type = "Keybind"
                }
                
                local keybindRow = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = container
                })
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindRow
                })
                
                local keyBtn = Create("TextButton", {
                    BackgroundColor3 = Theme.Tertiary,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 80, 0, 28),
                    Font = Enum.Font.GothamMedium,
                    Text = getKeyName(Keybind.Value),
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = keybindRow
                })
                AddCorner(keyBtn, 4)
                AddStroke(keyBtn, Theme.Border, 1)
                
                local listening = false
                
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    Tween(keyBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if not listening then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        Keybind.Value = input.KeyCode
                        keyBtn.Text = getKeyName(input.KeyCode)
                        Tween(keyBtn, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                        
                        if changesToggleKey then
                            Library:SetToggleKey(input.KeyCode)
                        end
                        
                        task.spawn(callback, input.KeyCode)
                        if Keybind.Changed then Keybind.Changed(input.KeyCode) end
                    end
                end)
                
                function Keybind:SetValue(keyName)
                    Keybind.Value = getKeyCode(keyName)
                    keyBtn.Text = getKeyName(Keybind.Value)
                    if changesToggleKey then
                        Library:SetToggleKey(Keybind.Value)
                    end
                end
                
                function Keybind:OnChanged(cb) Keybind.Changed = cb end
                
                -- Set initial toggle key if specified
                if changesToggleKey then
                    Library:SetToggleKey(Keybind.Value)
                end
                
                Options[idx] = Keybind
                return Keybind
            end
            
            Tab.Groupboxes[name] = Groupbox
            return Groupbox
        end
        
        if #Window.Tabs == 0 then
            Window.ActiveTab = Tab
        end
        
        -- Register for theme updates
        table.insert(Library._tabElements, {
            iconHolder = Tab.IconHolder,
            button = Tab.Button,
            buttonStroke = Tab.ButtonStroke,
            textLabel = Tab.TextLabel,
            isSelected = function() return Window.ActiveTab == Tab end
        })
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    function Library:Toggle(state)
        if state == nil then state = not Library.Toggled end
        Library.Toggled = state
        MainWindow.Visible = state
    end
    
    function Library:SetToggleKey(key)
        if type(key) == "string" then
            key = Enum.KeyCode[key]
        end
        if key then
            Library.ToggleKey = key
        end
    end
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Support Library.ToggleKeybind (KeyPicker object) like Linoria
        if typeof(Library.ToggleKeybind) == "table" and Library.ToggleKeybind.Type == "KeyPicker" then
            local keyPickerValue = Library.ToggleKeybind.Value
            if keyPickerValue and keyPickerValue ~= "None" then
                local keyName = input.KeyCode and input.KeyCode.Name
                if keyName == keyPickerValue then
                    Library:Toggle()
                    return
                end
            end
        -- Fallback to Library.ToggleKey (direct KeyCode)
        elseif input.KeyCode == Library.ToggleKey then
            Library:Toggle()
        end
    end)
    
    Library.Window = Window
    return Window
end

function Library:Unload()
    -- Clean up
    Library.Unloaded = true
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

function Library:OnUnload(callback)
    -- Store callback for unload event
    Library.UnloadCallback = callback
end

return Library



