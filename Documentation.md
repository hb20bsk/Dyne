# Modern UI Library Documentation

## Table of Contents
1. [Getting Started](#getting-started)
2. [Library](#library)
3. [Window](#window)
4. [Tabs](#tabs)
5. [Groupboxes](#groupboxes)
6. [Components](#components)
   - [Toggle](#toggle)
   - [Slider](#slider)
   - [Dropdown](#dropdown)
   - [Button](#button)
   - [Input](#input)
   - [Label](#label)
7. [Addons](#addons)
   - [ColorPicker](#colorpicker)
   - [KeyPicker](#keypicker)
8. [Notifications](#notifications)
9. [Watermark](#watermark)
10. [SaveManager](#savemanager)
11. [ThemeManager](#thememanager)

---

## Getting Started

```lua
-- Load the library
local Library = loadstring(game:HttpGet("YOUR_URL/Test.lua"))()

-- Create a window
local Window = Library:CreateWindow({
    Title = "My Script",
    Size = UDim2.new(0, 780, 0, 550),
    Position = UDim2.new(0.5, -390, 0.5, -275),
    AutoShow = true
})

-- Create tabs
local MainTab = Window:AddTab({
    Name = "Main",
    Icon = "crosshair"
})

-- Create groupboxes
local LeftGroup = MainTab:AddLeftGroupbox("Settings")
local RightGroup = MainTab:AddRightGroupbox("Options")
```

---

## Library

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `ScreenGui` | ScreenGui | The main ScreenGui instance |
| `Theme` | table | Table containing theme colors |
| `Toggled` | boolean | Whether the UI is visible |
| `Toggles` | table | All registered toggles (key = idx) |
| `Options` | table | All registered options (key = idx) |
| `PickerActive` | boolean | Whether a color picker is open |

### Methods

#### `Library:CreateWindow(options)`
Creates the main window.

```lua
local Window = Library:CreateWindow({
    Title = "Window Title",    -- Window title
    Size = UDim2.new(0, 780, 0, 550),  -- Window size
    Position = UDim2.new(0.5, -390, 0.5, -275),  -- Window position
    AutoShow = true  -- Show window immediately
})
```

#### `Library:Notify(options)`
Shows a notification.

```lua
Library:Notify({
    Title = "Notification",
    Description = "This is a notification message",
    Duration = 5,  -- seconds
    Type = "info"  -- "info", "warning", "error", "success"
})
```

#### `Library:SetWatermark(items)`
Updates the watermark text.

```lua
Library:SetWatermark({"ScriptName", "v1.0", "60 FPS", "25ms", "12:00 PM"})
```

---

## Window

### Methods

#### `Window:AddTab(options)`
Adds a tab to the window.

```lua
local Tab = Window:AddTab({
    Name = "Tab Name",
    Icon = "crosshair"  -- Lucide icon name
})
```

**Available Icons:**
- `crosshair` - Aimbot/targeting
- `user` - Player/profile
- `swords` - Combat
- `folder` - Files/config
- `settings` - Settings
- `globe` - World/ESP
- `alert-triangle` - Warning
- Any other Lucide icon name in icons.lua

---

## Tabs

### Methods

#### `Tab:AddLeftGroupbox(name)`
Adds a groupbox to the left column.

```lua
local LeftBox = Tab:AddLeftGroupbox("Groupbox Name")
```

#### `Tab:AddRightGroupbox(name)`
Adds a groupbox to the right column.

```lua
local RightBox = Tab:AddRightGroupbox("Groupbox Name")
```

#### `Tab:Show()`
Shows this tab (called automatically on tab click).

---

## Groupboxes

All UI elements are added to groupboxes.

---

## Components

### Toggle

```lua
local Toggle = Groupbox:AddToggle("UniqueIndex", {
    Text = "Toggle Name",      -- Display text
    Default = false,           -- Default value
    Callback = function(value) -- Called when value changes
        print("Toggle:", value)
    end
})
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `Value` | boolean | Current toggle state |
| `Type` | string | Always "Toggle" |

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetValue(value)` | boolean | Sets the toggle value |
| `OnChanged(callback)` | function | Sets change callback |
| `AddColorPicker(idx, options)` | string, table | Adds color picker addon |
| `AddKeyPicker(idx, options)` | string, table | Adds key picker addon |

---

### Slider

```lua
local Slider = Groupbox:AddSlider("UniqueIndex", {
    Text = "Slider Name",      -- Display text
    Default = 50,              -- Default value
    Min = 0,                   -- Minimum value
    Max = 100,                 -- Maximum value
    Rounding = 0,              -- Decimal places (0 = integers)
    Suffix = "px",             -- Value suffix (optional)
    Callback = function(value) -- Called when value changes
        print("Slider:", value)
    end
})
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `Value` | number | Current slider value |
| `Min` | number | Minimum value |
| `Max` | number | Maximum value |
| `Type` | string | Always "Slider" |

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetValue(value)` | number | Sets the slider value |
| `OnChanged(callback)` | function | Sets change callback |

---

### Dropdown

#### Single-Select
```lua
local Dropdown = Groupbox:AddDropdown("UniqueIndex", {
    Text = "Dropdown Name",             -- Display text
    Values = {"Option1", "Option2"},    -- Available options
    Default = "Option1",                -- Default selection
    AllowNull = false,                  -- Allow no selection
    Callback = function(value)          -- Called when value changes
        print("Selected:", value)
    end
})
```

#### Multi-Select
```lua
local Dropdown = Groupbox:AddDropdown("UniqueIndex", {
    Text = "Multi-Select",
    Values = {"ESP", "Chams", "Tracers"},
    Default = {"ESP", "Tracers"},       -- Default selections (table)
    Multi = true,                        -- Enable multi-select
    Callback = function(value)
        -- value is a table: {ESP = true, Tracers = true, Chams = false}
        for option, selected in pairs(value) do
            print(option, selected)
        end
    end
})
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `Value` | string/table | Current value (string for single, table for multi) |
| `Multi` | boolean | Whether multi-select is enabled |
| `Type` | string | Always "Dropdown" |

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetValue(value)` | string/table | Sets the dropdown value |
| `SetValues(values)` | table | Replaces all options |
| `OnChanged(callback)` | function | Sets change callback |

---

### Button

```lua
Groupbox:AddButton({
    Text = "Button Text",
    Func = function()
        print("Button clicked!")
    end
})
```

---

### Input

```lua
local Input = Groupbox:AddInput("UniqueIndex", {
    Text = "Input Label",           -- Display text/label
    Default = "",                   -- Default value
    Placeholder = "Enter text...",  -- Placeholder text
    Callback = function(value)      -- Called when focus lost
        print("Input:", value)
    end
})
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `Value` | string | Current input value |
| `Type` | string | Always "Input" |

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetValue(value)` | string | Sets the input value |
| `OnChanged(callback)` | function | Sets change callback |

---

### Label

```lua
local Label = Groupbox:AddLabel("Label Text")
```

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetText(text)` | string | Updates label text |

---

## Addons

Addons are chained to toggles using `:AddColorPicker()` and `:AddKeyPicker()`.

### ColorPicker

```lua
local Toggle = Groupbox:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = true
}):AddColorPicker("MyColor", {
    Default = Color3.fromRGB(255, 0, 0),  -- Default color
    Title = "Feature Color",               -- Picker title
    Callback = function(color)
        print("Color:", color)
    end
})
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `Value` | Color3 | Current color value |
| `Hue` | number | Hue component (0-1) |
| `Sat` | number | Saturation component (0-1) |
| `Vib` | number | Vibrance/Value component (0-1) |
| `Type` | string | Always "ColorPicker" |

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetValue(color)` | Color3 | Sets the color |
| `SetValueRGB(color, transparency)` | Color3, number | Sets color with transparency |
| `OnChanged(callback)` | function | Sets change callback |

---

### KeyPicker

```lua
local Toggle = Groupbox:AddToggle("MyToggle", {
    Text = "Enable Feature"
}):AddKeyPicker("MyKeybind", {
    Default = "G",                    -- Default key (string name)
    Mode = "Toggle",                  -- "Toggle", "Hold", "Always"
    SyncToggleState = true,           -- Sync with toggle
    Callback = function(state)
        print("Keybind state:", state)
    end
})
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `Value` | KeyCode | Current key |
| `Mode` | string | "Toggle", "Hold", or "Always" |
| `Type` | string | Always "KeyPicker" |

#### Methods
| Method | Parameters | Description |
|--------|------------|-------------|
| `SetValue(input)` | KeyCode/table | Sets key (or {key, mode, modifiers}) |
| `GetState()` | - | Returns whether key is active |
| `OnChanged(callback)` | function | Sets change callback |

---

## Notifications

```lua
Library:Notify({
    Title = "Title Text",
    Description = "Description text here",
    Duration = 5,
    Type = "info"
})
```

#### Types
| Type | Icon | Color |
|------|------|-------|
| `"info"` | alert-circle | Blue |
| `"success"` | check-circle | Green/Accent |
| `"warning"` | alert-triangle | Yellow |
| `"error"` | x-circle | Red |

---

## Watermark

The watermark displays at the top-right of the screen.

```lua
Library:SetWatermark({
    "ScriptName",
    "v1.0.0",
    "60 FPS",
    "15ms",
    "12:00 PM"
})
```

To update dynamically:
```lua
game:GetService("RunService").Heartbeat:Connect(function()
    local fps = math.floor(1 / game:GetService("RunService").Heartbeat:Wait())
    Library:SetWatermark({"Script", tostring(fps) .. " FPS", os.date("%I:%M %p")})
end)
```

---

## SaveManager

### Setup

```lua
local SaveManager = loadstring(game:HttpGet("YOUR_URL/SaveManager.lua"))()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MyScriptConfigs")
SaveManager:IgnoreThemeSettings()
```

### Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `SetLibrary(library)` | Library | Sets the library reference |
| `SetFolder(folder)` | string | Sets config folder name |
| `SetSubFolder(folder)` | string | Sets sub-folder (for game-specific) |
| `SetIgnoreIndexes(list)` | table | Ignores specific indexes when saving |
| `IgnoreThemeSettings()` | - | Ignores all theme-related options |
| `Save(name)` | string | Saves config |
| `Load(name)` | string | Loads config |
| `Delete(name)` | string | Deletes config |
| `RefreshConfigList()` | - | Returns table of config names |
| `GetAutoloadConfig()` | - | Returns autoload config name |
| `LoadAutoloadConfig()` | - | Loads the autoload config |
| `SaveAutoloadConfig(name)` | string | Sets autoload config |
| `DeleteAutoLoadConfig()` | - | Removes autoload config |
| `BuildConfigSection(tab)` | Tab | Builds config UI in tab |

### Building Config UI

```lua
SaveManager:BuildConfigSection(SettingsTab)
```

---

## ThemeManager

### Setup

```lua
local ThemeManager = loadstring(game:HttpGet("YOUR_URL/ThemeManager.lua"))()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScriptConfigs")
```

### Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `SetLibrary(library)` | Library | Sets the library reference |
| `SetFolder(folder)` | string | Sets themes folder name |
| `ApplyTheme(name)` | string | Applies a theme by name |
| `SaveCustomTheme(name)` | string | Saves current colors as theme |
| `Delete(name)` | string | Deletes a custom theme |
| `ReloadCustomThemes()` | - | Returns table of custom themes |
| `LoadDefault()` | - | Loads the default theme |
| `SaveDefault(name)` | string | Sets default theme |
| `ApplyToTab(tab)` | Tab | Builds theme UI in tab |
| `ApplyToGroupbox(groupbox)` | Groupbox | Builds theme UI in groupbox |

### Built-in Themes

- Default (Green accent)
- Midnight (Purple accent)
- Ocean (Blue accent)
- Crimson (Red accent)
- Forest (Green accent)
- Sunset (Orange accent)
- Nord (Cyan accent)
- Dracula (Purple accent)

### Building Theme UI

```lua
-- Option 1: Auto-create groupbox in tab
ThemeManager:ApplyToTab(SettingsTab)

-- Option 2: Use existing groupbox
local ThemesBox = Tab:AddLeftGroupbox("Themes")
ThemeManager:ApplyToGroupbox(ThemesBox)
```

---

## Complete Example

```lua
-- Load Library
local Library = loadstring(game:HttpGet("URL/Test.lua"))()
local SaveManager = loadstring(game:HttpGet("URL/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet("URL/ThemeManager.lua"))()

-- Setup managers
SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:SetFolder("MyScript")
ThemeManager:SetFolder("MyScript")
SaveManager:IgnoreThemeSettings()

-- Create window
local Window = Library:CreateWindow({
    Title = "My Script",
    AutoShow = true
})

-- Update watermark
Library:SetWatermark({"MyScript", "v1.0", "Loaded"})

-- Create tabs
local MainTab = Window:AddTab({ Name = "Main", Icon = "crosshair" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

-- Main tab content
local AimbotBox = MainTab:AddLeftGroupbox("Aimbot")

AimbotBox:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false
}):AddKeyPicker("AimbotKey", {
    Default = "E",
    Mode = "Hold"
}):AddColorPicker("AimbotColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "FOV Color"
})

AimbotBox:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 100,
    Min = 10,
    Max = 500,
    Suffix = "px"
})

AimbotBox:AddDropdown("TargetPart", {
    Text = "Target Part",
    Values = {"Head", "Torso", "Random"},
    Default = "Head"
})

-- Settings tab
ThemeManager:ApplyToTab(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

-- Load autoload config
SaveManager:LoadAutoloadConfig()

-- Notify ready
Library:Notify({
    Title = "Loaded",
    Description = "Script loaded successfully!",
    Duration = 3,
    Type = "success"
})
```

---

## Theme Colors

| Color | Default | Description |
|-------|---------|-------------|
| Background | RGB(17, 19, 23) | Main background |
| Secondary | RGB(24, 27, 31) | Secondary background |
| Tertiary | RGB(32, 36, 42) | Elements background |
| Accent | RGB(170, 235, 95) | Primary accent (green) |
| Text | RGB(255, 255, 255) | Primary text |
| TextDark | RGB(140, 145, 155) | Secondary text |
| Border | RGB(45, 50, 58) | Border color |
| Warning | RGB(230, 180, 50) | Warning notifications |
| Error | RGB(220, 80, 80) | Error notifications |
