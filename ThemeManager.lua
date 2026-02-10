local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

local assert = function(condition, errorMessage) 
    if (not condition) then
        error(if errorMessage then errorMessage else "assert failed", 3)
    end
end

if typeof(clonefunction) == "function" then
    local isfolder_copy, isfile_copy, listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local ThemeManager = {} do
    local ThemeFields = { "Background", "Secondary", "Tertiary", "Accent", "Text", "TextDark", "Border" }
    ThemeManager.Folder = "ModernUISettings"
    ThemeManager.Library = nil
    ThemeManager.BuiltInThemes = {
        ['Default'] = { 1, { 
            Background = "111317", 
            Secondary = "181b1f", 
            Tertiary = "20242a", 
            Accent = "aaeb5f", 
            Text = "ffffff", 
            TextDark = "8c919b", 
            Border = "2d323a" 
        }},
        ['Midnight'] = { 2, { 
            Background = "0d0d12", 
            Secondary = "13131a", 
            Tertiary = "1a1a24", 
            Accent = "7c5cff", 
            Text = "ffffff", 
            TextDark = "8888aa", 
            Border = "252530" 
        }},
        ['Ocean'] = { 3, { 
            Background = "0a1628", 
            Secondary = "0f1d30", 
            Tertiary = "142540", 
            Accent = "00a8ff", 
            Text = "ffffff", 
            TextDark = "7090b0", 
            Border = "1e3550" 
        }},
        ['Crimson'] = { 4, { 
            Background = "140a0a", 
            Secondary = "1c0f0f", 
            Tertiary = "241414", 
            Accent = "ff3b3b", 
            Text = "ffffff", 
            TextDark = "b08080", 
            Border = "3a1a1a" 
        }},
        ['Forest'] = { 5, { 
            Background = "0a140a", 
            Secondary = "0f1c0f", 
            Tertiary = "142414", 
            Accent = "3bff5c", 
            Text = "ffffff", 
            TextDark = "80b085", 
            Border = "1a3a1a" 
        }},
        ['Sunset'] = { 6, { 
            Background = "1a1210", 
            Secondary = "221815", 
            Tertiary = "2a1e1a", 
            Accent = "ff8c42", 
            Text = "ffffff", 
            TextDark = "b09080", 
            Border = "3d2820" 
        }},
        ['Nord'] = { 7, { 
            Background = "2e3440", 
            Secondary = "3b4252", 
            Tertiary = "434c5e", 
            Accent = "88c0d0", 
            Text = "eceff4", 
            TextDark = "a0a8b8", 
            Border = "4c566a" 
        }},
        ['Dracula'] = { 8, { 
            Background = "282a36", 
            Secondary = "2d303d", 
            Tertiary = "343746", 
            Accent = "bd93f9", 
            Text = "f8f8f2", 
            TextDark = "a0a0b0", 
            Border = "44475a" 
        }},
    }

    function ThemeManager:SetLibrary(library)
        self.Library = library
    end

    --// Folders \\--
    function ThemeManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split('/')
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, '/', 1, idx)
        end

        paths[#paths + 1] = self.Folder .. '/themes'
        
        return paths
    end

    function ThemeManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if isfolder(str) then continue end
            makefolder(str)
        end
    end

    function ThemeManager:CheckFolderTree()
        if isfolder(self.Folder) then return end
        self:BuildFolderTree()
        task.wait(0.1)
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    --// Apply, Update theme \\--
    function ThemeManager:ApplyTheme(theme)
        local customThemeData = self:GetCustomTheme(theme)
        local data = customThemeData or self.BuiltInThemes[theme]

        if not data then return end

        local scheme = data[2] or data
        for field, col in next, scheme do
            if self.Library.Theme and self.Library.Theme[field] then
                self.Library.Theme[field] = Color3.fromHex(col)
            end
            
            if self.Library.Options and self.Library.Options[field] then
                self.Library.Options[field]:SetValueRGB(Color3.fromHex(col))
            end
        end

        self:ThemeUpdate()
    end

    function ThemeManager:ThemeUpdate()
        -- Update theme colors from options
        for _, field in next, ThemeFields do
            if self.Library.Options and self.Library.Options[field] then
                if self.Library.Theme then
                    self.Library.Theme[field] = self.Library.Options[field].Value
                end
            end
        end

        -- Call library's update function if available
        if self.Library.UpdateColors then
            self.Library:UpdateColors()
        end
    end

    --// Get, Load, Save, Delete, Refresh \\--
    function ThemeManager:GetCustomTheme(file)
        local path = self.Folder .. '/themes/' .. file .. '.json'
        if not isfile(path) then
            return nil
        end

        local data = readfile(path)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        
        if not success then
            return nil
        end

        return decoded
    end

    function ThemeManager:LoadDefault()
        local theme = 'Default'
        local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

        local isDefault = true
        if content then
            if self.BuiltInThemes[content] then
                theme = content
            elseif self:GetCustomTheme(content) then
                theme = content
                isDefault = false
            end
        elseif self.DefaultTheme and self.BuiltInThemes[self.DefaultTheme] then
            theme = self.DefaultTheme
        end

        if isDefault then
            if self.Library.Options.ThemeManager_ThemeList then
                self.Library.Options.ThemeManager_ThemeList:SetValue(theme)
            end
        else
            self:ApplyTheme(theme)
        end
    end

    function ThemeManager:SaveDefault(theme)
        writefile(self.Folder .. '/themes/default.txt', theme)
    end

    function ThemeManager:SaveCustomTheme(file)
        if file:gsub(' ', '') == '' then
            self.Library:Notify({
                Title = "Error",
                Description = 'Invalid file name for theme (empty)',
                Duration = 3,
                Type = "error"
            })
            return
        end

        local theme = {}
        for _, field in next, ThemeFields do
            if self.Library.Options[field] then
                theme[field] = self.Library.Options[field].Value:ToHex()
            end
        end

        writefile(self.Folder .. '/themes/' .. file .. '.json', HttpService:JSONEncode(theme))
    end

    function ThemeManager:Delete(name)
        if (not name) then
            return false, 'no theme file is selected'
        end

        local file = self.Folder .. '/themes/' .. name .. '.json'
        if not isfile(file) then return false, 'invalid file' end

        local success = pcall(delfile, file)
        if not success then return false, 'delete file error' end
        
        return true
    end

    function ThemeManager:ReloadCustomThemes()
        local list = listfiles(self.Folder .. '/themes')

        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == '.json' then
                local pos = file:find('.json', 1, true)
                local start = pos

                local char = file:sub(pos, pos)
                while char ~= '/' and char ~= '\\' and char ~= '' do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end

                if char == '/' or char == '\\' then
                    table.insert(out, file:sub(pos + 1, start - 1))
                end
            end
        end

        return out
    end

    --// GUI \\--
    function ThemeManager:CreateThemeManager(groupbox)
        -- Theme color pickers
        groupbox:AddToggle('ThemeManager_BackgroundColor', { Text = 'Background color' }):AddColorPicker('Background', { Default = self.Library.Theme.Background, Title = 'Background' })
        groupbox:AddToggle('ThemeManager_SecondaryColor', { Text = 'Secondary color' }):AddColorPicker('Secondary', { Default = self.Library.Theme.Secondary, Title = 'Secondary' })
        groupbox:AddToggle('ThemeManager_TertiaryColor', { Text = 'Tertiary color' }):AddColorPicker('Tertiary', { Default = self.Library.Theme.Tertiary, Title = 'Tertiary' })
        groupbox:AddToggle('ThemeManager_AccentColor', { Text = 'Accent color' }):AddColorPicker('Accent', { Default = self.Library.Theme.Accent, Title = 'Accent' })
        groupbox:AddToggle('ThemeManager_TextColor', { Text = 'Text color' }):AddColorPicker('Text', { Default = self.Library.Theme.Text, Title = 'Text' })
        groupbox:AddToggle('ThemeManager_TextDarkColor', { Text = 'Text dark color' }):AddColorPicker('TextDark', { Default = self.Library.Theme.TextDark, Title = 'Text Dark' })
        groupbox:AddToggle('ThemeManager_BorderColor', { Text = 'Border color' }):AddColorPicker('Border', { Default = self.Library.Theme.Border, Title = 'Border' })

        local ThemesArray = {}
        for Name, _ in next, self.BuiltInThemes do
            table.insert(ThemesArray, Name)
        end

        table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

        groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 'Default' })
        
        groupbox:AddButton({
            Text = 'Set as default',
            Func = function()
                self:SaveDefault(self.Library.Options.ThemeManager_ThemeList.Value)
                self.Library:Notify({
                    Title = "Success",
                    Description = string.format('Set default theme to %q', self.Library.Options.ThemeManager_ThemeList.Value),
                    Duration = 3,
                    Type = "success"
                })
            end
        })

        self.Library.Options.ThemeManager_ThemeList:OnChanged(function()
            self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value)
        end)

        groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name', Placeholder = 'Enter name...' })
        
        groupbox:AddButton({
            Text = 'Create theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeName.Value
                if name:gsub(" ", "") == "" then
                    self.Library:Notify({
                        Title = "Error",
                        Description = "Invalid theme name (empty)",
                        Duration = 2,
                        Type = "error"
                    })
                    return
                end

                self:SaveCustomTheme(name)

                self.Library:Notify({
                    Title = "Success",
                    Description = string.format("Created theme %q", name),
                    Duration = 3,
                    Type = "success"
                })
                task.wait(0.1); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
                self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end
        })

        groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true })
        
        groupbox:AddButton({
            Text = 'Load theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value

                self:ApplyTheme(name)
                self.Library:Notify({
                    Title = "Success",
                    Description = string.format('Loaded theme %q', name),
                    Duration = 3,
                    Type = "success"
                })
            end
        })

        groupbox:AddButton({
            Text = 'Overwrite theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value

                self:SaveCustomTheme(name)
                self.Library:Notify({
                    Title = "Success",
                    Description = string.format('Overwrote theme %q', name),
                    Duration = 3,
                    Type = "success"
                })
            end
        })

        groupbox:AddButton({
            Text = 'Delete theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value

                local success, err = self:Delete(name)
                if not success then
                    self.Library:Notify({
                        Title = "Error",
                        Description = 'Failed to delete theme: ' .. err,
                        Duration = 3,
                        Type = "error"
                    })
                    return
                end

                self.Library:Notify({
                    Title = "Success",
                    Description = string.format('Deleted theme %q', name),
                    Duration = 3,
                    Type = "success"
                })
                task.wait(0.1); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
                self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end
        })

        groupbox:AddButton({
            Text = 'Refresh list',
            Func = function()
                task.wait(0.1); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
                self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end
        })

        groupbox:AddButton({
            Text = 'Reset default',
            Func = function()
                local success = pcall(delfile, self.Folder .. '/themes/default.txt')
                if not success then 
                    self.Library:Notify({
                        Title = "Error",
                        Description = 'Failed to reset default: delete file error',
                        Duration = 3,
                        Type = "error"
                    })
                    return
                end
                    
                self.Library:Notify({
                    Title = "Success",
                    Description = 'Reset default theme',
                    Duration = 3,
                    Type = "success"
                })
                task.wait(0.1); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
                self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end
        })

        self:LoadDefault()

        local function UpdateTheme() self:ThemeUpdate() end
        self.Library.Options.Background:OnChanged(UpdateTheme)
        self.Library.Options.Secondary:OnChanged(UpdateTheme)
        self.Library.Options.Tertiary:OnChanged(UpdateTheme)
        self.Library.Options.Accent:OnChanged(UpdateTheme)
        self.Library.Options.Text:OnChanged(UpdateTheme)
        self.Library.Options.TextDark:OnChanged(UpdateTheme)
        self.Library.Options.Border:OnChanged(UpdateTheme)
    end

    function ThemeManager:CreateGroupBox(tab)
        assert(self.Library, 'ThemeManager:CreateGroupBox -> Must set ThemeManager.Library first!')
        return tab:AddLeftGroupbox('Themes')
    end

    function ThemeManager:ApplyToTab(tab)
        assert(self.Library, 'ThemeManager:ApplyToTab -> Must set ThemeManager.Library first!')
        local groupbox = self:CreateGroupBox(tab)
        self:CreateThemeManager(groupbox)
    end

    function ThemeManager:ApplyToGroupbox(groupbox)
        assert(self.Library, 'ThemeManager:ApplyToGroupbox -> Must set ThemeManager.Library first!')
        self:CreateThemeManager(groupbox)
    end

    ThemeManager:BuildFolderTree()
end

return ThemeManager

