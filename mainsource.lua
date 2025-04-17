-- SynthwaveUI Library - Fixed Version
-- Original by whohurtyoudear, fixed and improved version

-- Initialize library and services
local SynthwaveUI = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players") or {LocalPlayer = {Name = "Player"}}
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or {Name = "Player"}
local Mouse = LocalPlayer:GetMouse and LocalPlayer:GetMouse() or {X = 0, Y = 0}

-- Error handling and utility functions
local function SafeCallback(callback, ...)
    if typeof(callback) == "function" then
        local success, result = pcall(callback, ...)
        if not success then
            warn("SynthwaveUI: Callback error: " .. tostring(result))
        end
        return success, result
    end
    return false
end

local function SafeHttpGet(url)
    local success, result = pcall(function()
        return SafeHttpGet(url)
    end)
    if not success then
        warn("SynthwaveUI: HTTP Get error: " .. tostring(result))
        return ""
    end
    return result
end

local function SafeGetUserId(playerName)
    local success, userId = pcall(function()
        local PlayerImage = Players
        return PlayerImage:GetUserIdFromNameAsync(playerName)
    end)
    if not success or not userId then
        warn("SynthwaveUI: Failed to get user ID for " .. tostring(playerName))
        return 0
    end
    return userId
end

-- Create a safe environment for the library
-- SynthwaveUI Library Initialization
local SynthwaveUI = {
    Folder = "SynthwaveUI",
    Version = "1.0.0",
    Options = {
        Theme = "Dark",
        AccentColor = Color3.fromRGB(155, 89, 182),
        Font = Enum.Font.GothamMedium
    },
    ThemeGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(117, 164, 206)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(123, 201, 201)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(224, 138, 175))
    }),
    
    -- UI Creation Method
    Create = function(self, title)
        local UI = {}
        UI.Tabs = {}
        UI.Sections = {}
        UI.Elements = {}
    
        -- Create the main frame
        local MainFrame = Instance.new("ScreenGui")
        MainFrame.Name = "SynthwaveUI"
        MainFrame.ResetOnSpawn = false
        
        -- If we're in a Roblox game environment, parent to the PlayerGui
        if game:GetService("Players") or {LocalPlayer = {Name = "Player"}}.LocalPlayer then
            MainFrame.Parent = game:GetService("Players") or {LocalPlayer = {Name = "Player"}}.LocalPlayer:WaitForChild("PlayerGui")
        else
            MainFrame.Parent = game:GetService("CoreGui")
        end
    
        local DragFrame = Instance.new("Frame")
        DragFrame.Name = "DragFrame"
        DragFrame.Parent = MainFrame
        DragFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DragFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
        DragFrame.BorderSizePixel = 2
        DragFrame.Position = UDim2.new(0.5, -200, 0.5, -150) -- Center the UI on the screen
        DragFrame.Size = UDim2.new(0, 400, 0, 300)
        
        -- Make the frame draggable
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        
        local function updateDrag(input)
            local delta = input.Position - dragStart
            DragFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        
        DragFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = DragFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        DragFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                updateDrag(input)
            end
        end)
    
        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Parent = DragFrame
        TopBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TopBar.Size = UDim2.new(1, 0, 0, 30)
    
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Parent = TopBar
        TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.BackgroundTransparency = 1.000
        TitleLabel.Size = UDim2.new(1, 0, 1, 0)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 16
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
        TitleLabel.TextWrapped = true
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        -- Add close button
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Parent = TopBar
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        CloseButton.Size = UDim2.new(0, 20, 0, 20)
        CloseButton.Position = UDim2.new(1, -25, 0.5, -10)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 14
        
        CloseButton.MouseButton1Click:Connect(function()
            MainFrame:Destroy()
        end)
        
        -- Add minimize button
        local MinimizeButton = Instance.new("TextButton")
        MinimizeButton.Name = "MinimizeButton"
        MinimizeButton.Parent = TopBar
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
        MinimizeButton.Position = UDim2.new(1, -50, 0.5, -10)
        MinimizeButton.Font = Enum.Font.GothamBold
        MinimizeButton.Text = "-"
        MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinimizeButton.TextSize = 14
        
        local minimized = false
        MinimizeButton.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                DragFrame.Size = UDim2.new(0, 400, 0, 30)
                MinimizeButton.Text = "+"
            else
                DragFrame.Size = UDim2.new(0, 400, 0, 300)
                MinimizeButton.Text = "-"
            end
        end)
    
        local TabBar = Instance.new("Frame")
        TabBar.Name = "TabBar"
        TabBar.Parent = DragFrame
        TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBar.Size = UDim2.new(1, 0, 0, 40)
        TabBar.Position = UDim2.new(0, 0, 0, 30)
    
        local TabList = Instance.new("ScrollingFrame")
        TabList.Name = "TabList"
        TabList.Parent = TabBar
        TabList.BackgroundTransparency = 1.000
        TabList.Size = UDim2.new(1, 0, 1, 0)
        TabList.ScrollBarThickness = 0
        TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = TabList
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
        local Body = Instance.new("Frame")
        Body.Name = "Body"
        Body.Parent = DragFrame
        Body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Body.BackgroundTransparency = 1.000
        Body.Size = UDim2.new(1, 0, 1, -70)
        Body.Position = UDim2.new(0, 0, 0, 70)
    
        local SectionList = Instance.new("ScrollingFrame")
        SectionList.Name = "SectionList"
        SectionList.Parent = Body
        SectionList.BackgroundTransparency = 1.000
        SectionList.Size = UDim2.new(1, 0, 1, 0)
        SectionList.CanvasSize = UDim2.new(0, 0, 0, 0)
        SectionList.ScrollBarThickness = 4
        SectionList.ScrollingDirection = Enum.ScrollingDirection.Y
        SectionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = SectionList
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
        -- Function to add a new tab
        function UI:AddTab(tabName, icon)
            local tabButton = Instance.new("TextButton")
            tabButton.Name = tabName
            tabButton.Parent = TabList
            tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            tabButton.Size = UDim2.new(0, 100, 0, 30)
            tabButton.Font = Enum.Font.Gotham
            tabButton.Text = tabName
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabButton.TextSize = 14
            tabButton.TextWrapped = true
            
            -- Add icon if provided
            if icon then
                local iconImage = Instance.new("ImageLabel")
                iconImage.Name = "Icon"
                iconImage.Parent = tabButton
                iconImage.BackgroundTransparency = 1
                iconImage.Size = UDim2.new(0, 20, 0, 20)
                iconImage.Position = UDim2.new(0, 5, 0.5, -10)
                iconImage.Image = icon
                
                -- Adjust text position
                tabButton.TextXAlignment = Enum.TextXAlignment.Right
                tabButton.Text = "  " .. tabName
            end
    
            -- Create a frame for the tab's content
            local tabContent = Instance.new("Frame")
            tabContent.Name = tabName .. "Content"
            tabContent.Parent = SectionList
            tabContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            tabContent.BackgroundTransparency = 1.000
            tabContent.Size = UDim2.new(1, 0, 0, 0)
            tabContent.AutomaticSize = Enum.AutomaticSize.Y
            tabContent.Visible = false
    
            -- Store the tab content frame
            UI.Tabs[tabName] = tabContent
    
            -- Update TabList CanvasSize
            local tabCount = #TabList:GetChildren() - 1
            TabList.CanvasSize = UDim2.new(0, tabCount * 105, 0, 0)
            
            -- Tab switching logic
            tabButton.MouseButton1Click:Connect(function()
                -- Hide all tabs
                for _, tab in pairs(UI.Tabs) do
                    tab.Visible = false
                end
                
                -- Show the clicked tab
                tabContent.Visible = true
                
                -- Update tab button styling
                for _, child in pairs(TabList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end
                end
                
                tabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            -- Auto-select first tab
            if tabCount == 1 then
                tabContent.Visible = true
                tabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end
    
            -- Function to add a new section to the tab
            function tabContent:AddSection(sectionName)
                local sectionFrame = Instance.new("Frame")
                sectionFrame.Name = sectionName
                sectionFrame.Parent = tabContent
                sectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                sectionFrame.Size = UDim2.new(0.95, 0, 0, 0)
                sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                sectionFrame.BorderSizePixel = 2
                sectionFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    
                local SectionHeader = Instance.new("TextLabel")
                SectionHeader.Name = "SectionHeader"
                SectionHeader.Parent = sectionFrame
                SectionHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SectionHeader.BackgroundTransparency = 1.000
                SectionHeader.Size = UDim2.new(1, 0, 0, 30)
                SectionHeader.Font = Enum.Font.GothamBold
                SectionHeader.Text = sectionName
                SectionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
                SectionHeader.TextSize = 16
                SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
                SectionHeader.TextYAlignment = Enum.TextYAlignment.Center
                SectionHeader.TextWrapped = true
                SectionHeader.TextXAlignment = Enum.TextXAlignment.Center
    
                local ElementList = Instance.new("Frame")
                ElementList.Name = "ElementList"
                ElementList.Parent = sectionFrame
                ElementList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ElementList.BackgroundTransparency = 1.000
                ElementList.Size = UDim2.new(1, 0, 0, 0)
                ElementList.Position = UDim2.new(0, 0, 0, 30)
                ElementList.AutomaticSize = Enum.AutomaticSize.Y
    
                local UIListLayout = Instance.new("UIListLayout")
                UIListLayout.Parent = ElementList
                UIListLayout.Padding = UDim.new(0, 5)
                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
                -- Store the section frame
                UI.Sections[sectionName] = sectionFrame
    
                -- Function to add a new text box to the section
                function sectionFrame:AddTextBox(label, defaultText, placeholderText)
                    local textBoxFrame = Instance.new("Frame")
                    textBoxFrame.Name = label .. "Frame"
                    textBoxFrame.Parent = ElementList
                    textBoxFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    textBoxFrame.Size = UDim2.new(0.95, 0, 0, 30)
    
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = textBoxFrame
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.3, 0, 1, 0)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = label
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
    
                    local textBox = Instance.new("TextBox")
                    textBox.Name = label .. "TextBox"
                    textBox.Parent = textBoxFrame
                    textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    textBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    textBox.BorderSizePixel = 1
                    textBox.Position = UDim2.new(0.3, 0, 0, 0)
                    textBox.Size = UDim2.new(0.7, 0, 1, 0)
                    textBox.Font = Enum.Font.Gotham
                    textBox.Text = defaultText
                    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textBox.TextSize = 14
                    textBox.PlaceholderText = placeholderText
                    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    
                    -- Store the text box
                    UI.Elements[label] = textBox
    
                    return textBox
                end
    
                -- Function to add a new slider to the section
                function sectionFrame:AddSlider(label, minValue, maxValue, defaultValue, decimalPlaces, callback)
                    local sliderFrame = Instance.new("Frame")
                    sliderFrame.Name = label .. "Frame"
                    sliderFrame.Parent = ElementList
                    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    sliderFrame.Size = UDim2.new(0.95, 0, 0, 30)
    
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = sliderFrame
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.3, 0, 1, 0)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = label
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
    
                    local sliderBackground = Instance.new("Frame")
                    sliderBackground.Name = "SliderBackground"
                    sliderBackground.Parent = sliderFrame
                    sliderBackground.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    sliderBackground.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    sliderBackground.BorderSizePixel = 1
                    sliderBackground.Position = UDim2.new(0.3, 0, 0.5, -5)
                    sliderBackground.Size = UDim2.new(0.5, 0, 0, 10)
                    
                    local sliderFill = Instance.new("Frame")
                    sliderFill.Name = "SliderFill"
                    sliderFill.Parent = sliderBackground
                    sliderFill.BackgroundColor3 = Color3.fromRGB(155, 89, 182) -- Using accent color
                    sliderFill.BorderSizePixel = 0
                    sliderFill.Size = UDim2.new(0, 0, 1, 0)
                    
                    local sliderButton = Instance.new("TextButton")
                    sliderButton.Name = "SliderButton"
                    sliderButton.Parent = sliderBackground
                    sliderButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    sliderButton.BorderSizePixel = 0
                    sliderButton.Size = UDim2.new(0, 10, 0, 16)
                    sliderButton.Position = UDim2.new(0, -5, 0.5, -8)
                    sliderButton.Text = ""
                    sliderButton.AutoButtonColor = false

                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.Name = "ValueLabel"
                    valueLabel.Parent = sliderFrame
                    valueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    valueLabel.BackgroundTransparency = 1.000
                    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
                    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
                    valueLabel.Font = Enum.Font.Gotham
                    valueLabel.Text = string.format("%." .. decimalPlaces .. "f", defaultValue)
                    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    valueLabel.TextSize = 14
                    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
                    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
                    valueLabel.TextWrapped = true
                    
                    -- Set initial value
                    local percent = (defaultValue - minValue) / (maxValue - minValue)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderButton.Position = UDim2.new(percent, -5, 0.5, -8)
                    
                    -- Slider functionality
                    local dragging = false
                    
                    sliderButton.MouseButton1Down:Connect(function()
                        dragging = true
                    end)
                    
                    game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    game:GetService("UserInputService").InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            local relativePos = mousePos.X - sliderBackground.AbsolutePosition.X
                            local percent = math.clamp(relativePos / sliderBackground.AbsoluteSize.X, 0, 1)
                            
                            -- Update visual elements
                            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                            sliderButton.Position = UDim2.new(percent, -5, 0.5, -8)
                            
                            -- Calculate and update value
                            local value = minValue + (maxValue - minValue) * percent
                            local roundedValue = math.floor(value * 10^decimalPlaces + 0.5) / 10^decimalPlaces
                            valueLabel.Text = string.format("%." .. decimalPlaces .. "f", roundedValue)
                            
                            -- Call callback with the new value
                            callback(roundedValue)
                        end
                    end)

                    -- Store the slider
                    UI.Elements[label] = {
                        Set = function(value)
                            local clampedValue = math.clamp(value, minValue, maxValue)
                            local percent = (clampedValue - minValue) / (maxValue - minValue)
                            
                            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                            sliderButton.Position = UDim2.new(percent, -5, 0.5, -8)
                            valueLabel.Text = string.format("%." .. decimalPlaces .. "f", clampedValue)
                            
                            callback(clampedValue)
                        end
                    }
    
                    return UI.Elements[label]
                end
    
                -- Function to add a new toggle to the section
                function sectionFrame:AddToggle(label, defaultValue, callback)
                    local toggleFrame = Instance.new("Frame")
                    toggleFrame.Name = label .. "Frame"
                    toggleFrame.Parent = ElementList
                    toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    toggleFrame.Size = UDim2.new(0.95, 0, 0, 30)
    
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = toggleFrame
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.7, 0, 1, 0)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = label
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
    
                    local toggleButton = Instance.new("TextButton")
                    toggleButton.Name = label .. "Toggle"
                    toggleButton.Parent = toggleFrame
                    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                    toggleButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    toggleButton.BorderSizePixel = 1
                    toggleButton.Position = UDim2.new(0.7, 0, 0, 0)
                    toggleButton.Size = UDim2.new(0.3, 0, 1, 0)
                    toggleButton.Font = Enum.Font.Gotham
                    toggleButton.Text = defaultValue and "Enabled" or "Disabled"
                    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    toggleButton.TextSize = 14
                    toggleButton.TextWrapped = true
    
                    local toggled = defaultValue
    
                    toggleButton.MouseButton1Click:Connect(function()
                        toggled = not toggled
                        toggleButton.Text = toggled and "Enabled" or "Disabled"
                        toggleButton.BackgroundColor3 = toggled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                        callback(toggled)
                    end)
    
                    -- Store the toggle
                    UI.Elements[label] = {
                        Set = function(state)
                            toggled = state
                            toggleButton.Text = toggled and "Enabled" or "Disabled"
                            toggleButton.BackgroundColor3 = toggled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                            callback(toggled)
                        end
                    }
    
                    return UI.Elements[label]
                end
    
                -- Function to add a new dropdown to the section
                function sectionFrame:AddDropdown(label, options, defaultOption, callback)
                    local dropdownFrame = Instance.new("Frame")
                    dropdownFrame.Name = label .. "Frame"
                    dropdownFrame.Parent = ElementList
                    dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    dropdownFrame.Size = UDim2.new(0.95, 0, 0, 30)
                    dropdownFrame.ClipsDescendants = false
    
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = dropdownFrame
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.3, 0, 1, 0)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = label
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
    
                    local dropdownButton = Instance.new("TextButton")
                    dropdownButton.Name = label .. "Dropdown"
                    dropdownButton.Parent = dropdownFrame
                    dropdownButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    dropdownButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    dropdownButton.BorderSizePixel = 1
                    dropdownButton.Position = UDim2.new(0.3, 0, 0, 0)
                    dropdownButton.Size = UDim2.new(0.7, 0, 1, 0)
                    dropdownButton.Font = Enum.Font.Gotham
                    dropdownButton.Text = defaultOption
                    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    dropdownButton.TextSize = 14
                    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownButton.TextYAlignment = Enum.TextYAlignment.Center
                    dropdownButton.TextWrapped = true
    
                    local dropdownList = Instance.new("Frame")
                    dropdownList.Name = label .. "List"
                    dropdownList.Parent = dropdownFrame
                    dropdownList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    dropdownList.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    dropdownList.BorderSizePixel = 1
                    dropdownList.Position = UDim2.new(0.3, 0, 1, 0)
                    dropdownList.Size = UDim2.new(0.7, 0, 0, 0)
                    dropdownList.ZIndex = 5
                    dropdownList.Visible = false
    
                    local UIListLayout = Instance.new("UIListLayout")
                    UIListLayout.Parent = dropdownList
                    UIListLayout.Padding = UDim.new(0, 0)
                    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
                    -- Populate dropdown list
                    for i, option in ipairs(options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = option
                        optionButton.Parent = dropdownList
                        optionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                        optionButton.Size = UDim2.new(1, 0, 0, 30)
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.Text = option
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionButton.TextSize = 14
                        optionButton.TextXAlignment = Enum.TextXAlignment.Left
                        optionButton.TextYAlignment = Enum.TextYAlignment.Center
                        optionButton.TextWrapped = true
                        optionButton.ZIndex = 6
    
                        optionButton.MouseButton1Click:Connect(function()
                            dropdownButton.Text = option
                            dropdownList.Visible = false
                            dropdownList.Size = UDim2.new(0.7, 0, 0, 0)
                            callback(option)
                        end)
                    end
    
                    dropdownButton.MouseButton1Click:Connect(function()
                        if dropdownList.Visible then
                            dropdownList.Visible = false
                            dropdownList.Size = UDim2.new(0.7, 0, 0, 0)
                        else
                            dropdownList.Visible = true
                            dropdownList.Size = UDim2.new(0.7, 0, 0, #options * 30)
                        end
                    end)
    
                    -- Store the dropdown
                    UI.Elements[label] = {
                        Set = function(option)
                            if table.find(options, option) then
                                dropdownButton.Text = option
                                callback(option)
                            else
                                warn("Option '" .. option .. "' not found in dropdown options")
                            end
                        end
                    }
    
                    return UI.Elements[label]
                end
    
                -- Function to add a new button to the section
                function sectionFrame:AddButton(label, callback)
                    local button = Instance.new("TextButton")
                    button.Name = label .. "Button"
                    button.Parent = ElementList
                    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    button.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    button.BorderSizePixel = 1
                    button.Size = UDim2.new(0.95, 0, 0, 30)
                    button.Font = Enum.Font.Gotham
                    button.Text = label
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.TextSize = 14
                    button.TextWrapped = true
    
                    button.MouseButton1Click:Connect(function()
                        callback()
                    end)
    
                    -- Store the button
                    UI.Elements[label] = button
    
                    return button
                end
    
                -- Function to add a new separator to the section
                function sectionFrame:AddSeparator()
                    local separator = Instance.new("Frame")
                    separator.Name = "Separator"
                    separator.Parent = ElementList
                    separator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    separator.Size = UDim2.new(0.95, 0, 0, 2)
    
                    return separator
                end
    
                -- Function to add a new label to the section
                function sectionFrame:AddLabel(text)
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = ElementList
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.95, 0, 0, 30)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = text
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
                    labelText.TextXAlignment = Enum.TextXAlignment.Center
    
                    return labelText
                end
    
                -- Function to add a new keybind to the section
                function sectionFrame:AddKeybind(label, defaultKey, callback)
                    local keybindFrame = Instance.new("Frame")
                    keybindFrame.Name = label .. "Frame"
                    keybindFrame.Parent = ElementList
                    keybindFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    keybindFrame.Size = UDim2.new(0.95, 0, 0, 30)
    
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = keybindFrame
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.3, 0, 1, 0)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = label
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
    
                    local keybindButton = Instance.new("TextButton")
                    keybindButton.Name = label .. "Keybind"
                    keybindButton.Parent = keybindFrame
                    keybindButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    keybindButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    keybindButton.BorderSizePixel = 1
                    keybindButton.Position = UDim2.new(0.3, 0, 0, 0)
                    keybindButton.Size = UDim2.new(0.7, 0, 1, 0)
                    keybindButton.Font = Enum.Font.Gotham
                    keybindButton.Text = defaultKey.Name
                    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    keybindButton.TextSize = 14
                    keybindButton.TextXAlignment = Enum.TextXAlignment.Left
                    keybindButton.TextYAlignment = Enum.TextYAlignment.Center
                    keybindButton.TextWrapped = true
    
                    local listening = false
    
                    keybindButton.MouseButton1Click:Connect(function()
                        if not listening then
                            listening = true
                            keybindButton.Text = "Listening..."
    
                            local connection
                            connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
                                if not gameProcessedEvent then
                                    listening = false
                                    keybindButton.Text = input.KeyCode.Name
                                    defaultKey = input.KeyCode
                                    connection:Disconnect()
                                end
                            end)
                        end
                    end)
    
                    game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessedEvent)
                        if input.KeyCode == defaultKey and not listening and not gameProcessedEvent then
                            callback()
                        end
                    end)
    
                    -- Store the keybind
                    UI.Elements[label] = keybindButton
    
                    return keybindButton
                end
    
                -- Function to add a new color picker to the section
                function sectionFrame:AddColorPicker(label, defaultColor, callback)
                    local colorPickerFrame = Instance.new("Frame")
                    colorPickerFrame.Name = label .. "Frame"
                    colorPickerFrame.Parent = ElementList
                    colorPickerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    colorPickerFrame.Size = UDim2.new(0.95, 0, 0, 30)
    
                    local labelText = Instance.new("TextLabel")
                    labelText.Name = "Label"
                    labelText.Parent = colorPickerFrame
                    labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.BackgroundTransparency = 1.000
                    labelText.Size = UDim2.new(0.3, 0, 1, 0)
                    labelText.Font = Enum.Font.Gotham
                    labelText.Text = label
                    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize = 14
                    labelText.TextXAlignment = Enum.TextXAlignment.Left
                    labelText.TextYAlignment = Enum.TextYAlignment.Center
                    labelText.TextWrapped = true
    
                    local colorButton = Instance.new("TextButton")
                    colorButton.Name = label .. "ColorButton"
                    colorButton.Parent = colorPickerFrame
                    colorButton.BackgroundColor3 = defaultColor
                    colorButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    colorButton.BorderSizePixel = 1
                    colorButton.Position = UDim2.new(0.3, 0, 0, 0)
                    colorButton.Size = UDim2.new(0.7, 0, 1, 0)
                    colorButton.Font = Enum.Font.Gotham
                    colorButton.Text = "Pick Color"
                    colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    colorButton.TextSize = 14
                    colorButton.TextWrapped = true
    
                    colorButton.MouseButton1Click:Connect(function()
                        local colorPickerGui = Instance.new("ScreenGui")
                        colorPickerGui.Name = "ColorPickerGui"
                        colorPickerGui.ResetOnSpawn = false
                        colorPickerGui.Parent = MainFrame
    
                        local colorPickerFrame = Instance.new("Frame")
                        colorPickerFrame.Name = "ColorPickerFrame"
                        colorPickerFrame.Parent = colorPickerGui
                        colorPickerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        colorPickerFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
                        colorPickerFrame.BorderSizePixel = 2
                        colorPickerFrame.Size = UDim2.new(0, 300, 0, 300)
                        colorPickerFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
                        colorPickerFrame.ZIndex = 10
                        
                        -- Make draggable
                        local dragging = false
                        local dragInput
                        local dragStart
                        local startPos
                        
                        local function updateDrag(input)
                            local delta = input.Position - dragStart
                            colorPickerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                        
                        colorPickerFrame.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                dragging = true
                                dragStart = input.Position
                                startPos = colorPickerFrame.Position
                                
                                input.Changed:Connect(function()
                                    if input.UserInputState == Enum.UserInputState.End then
                                        dragging = false
                                    end
                                end)
                            end
                        end)
                        
                        colorPickerFrame.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                dragInput = input
                            end
                        end)
                        
                        game:GetService("UserInputService").InputChanged:Connect(function(input)
                            if input == dragInput and dragging then
                                updateDrag(input)
                            end
                        end)
    
                        local closeButton = Instance.new("TextButton")
                        closeButton.Name = "CloseButton"
                        closeButton.Parent = colorPickerFrame
                        closeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                        closeButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                        closeButton.BorderSizePixel = 1
                        closeButton.Size = UDim2.new(0, 30, 0, 30)
                        closeButton.Position = UDim2.new(1, -30, 0, 0)
                        closeButton.Font = Enum.Font.Gotham
                        closeButton.Text = "X"
                        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        closeButton.TextSize = 14
                        closeButton.TextWrapped = true
                        closeButton.ZIndex = 11
    
                        closeButton.MouseButton1Click:Connect(function()
                            colorPickerGui:Destroy()
                        end)
                        
                        -- Create color picker elements
                        local titleLabel = Instance.new("TextLabel")
                        titleLabel.Name = "TitleLabel"
                        titleLabel.Parent = colorPickerFrame
                        titleLabel.BackgroundTransparency = 1
                        titleLabel.Size = UDim2.new(1, -30, 0, 30)
                        titleLabel.Font = Enum.Font.GothamBold
                        titleLabel.Text = "Color Picker"
                        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        titleLabel.TextSize = 16
                        titleLabel.ZIndex = 11
                        
                        -- Simplified color picker with presets
                        local presetsContainer = Instance.new("Frame")
                        presetsContainer.Name = "PresetsContainer"
                        presetsContainer.Parent = colorPickerFrame
                        presetsContainer.BackgroundTransparency = 1
                        presetsContainer.Position = UDim2.new(0, 10, 0, 40)
                        presetsContainer.Size = UDim2.new(1, -20, 0, 200)
                        presetsContainer.ZIndex = 11
                        
                        local presetColors = {
                            Color3.fromRGB(255, 0, 0),    -- Red
                            Color3.fromRGB(255, 165, 0),  -- Orange
                            Color3.fromRGB(255, 255, 0),  -- Yellow
                            Color3.fromRGB(0, 255, 0),    -- Green
                            Color3.fromRGB(0, 255, 255),  -- Cyan
                            Color3.fromRGB(0, 0, 255),    -- Blue
                            Color3.fromRGB(128, 0, 128),  -- Purple
                            Color3.fromRGB(255, 0, 255),  -- Magenta
                            Color3.fromRGB(255, 255, 255),-- White
                            Color3.fromRGB(0, 0, 0),      -- Black
                            Color3.fromRGB(128, 128, 128),-- Gray
                            Color3.fromRGB(155, 89, 182), -- Current Theme
                        }
                        
                        local gridSize = 4 -- 4x3 grid
                        local buttonSize = 60
                        local padding = 10
                        
                        for i, color in ipairs(presetColors) do
                            local row = math.ceil(i / gridSize) - 1
                            local col = (i - 1) % gridSize
                            
                            local presetButton = Instance.new("TextButton")
                            presetButton.Name = "PresetColor" .. i
                            presetButton.Parent = presetsContainer
                            presetButton.BackgroundColor3 = color
                            presetButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                            presetButton.BorderSizePixel = 1
                            presetButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
                            presetButton.Position = UDim2.new(0, col * (buttonSize + padding), 0, row * (buttonSize + padding))
                            presetButton.Text = ""
                            presetButton.ZIndex = 11
                            
                            presetButton.MouseButton1Click:Connect(function()
                                colorButton.BackgroundColor3 = color
                                callback(color)
                                colorPickerGui:Destroy()
                            end)
                        end
                        
                        -- RGB sliders
                        local rgbContainer = Instance.new("Frame")
                        rgbContainer.Name = "RGBContainer"
                        rgbContainer.Parent = colorPickerFrame
                        rgbContainer.BackgroundTransparency = 1
                        rgbContainer.Position = UDim2.new(0, 10, 0, 250)
                        rgbContainer.Size = UDim2.new(1, -20, 0, 40)
                        rgbContainer.ZIndex = 11
                        
                        local function createRGBSlider(component, yPos, defaultValue)
                            local sliderFrame = Instance.new("Frame")
                            sliderFrame.Name = component .. "Slider"
                            sliderFrame.Parent = rgbContainer
                            sliderFrame.BackgroundTransparency = 1
                            sliderFrame.Position = UDim2.new(0, 0, 0, yPos)
                            sliderFrame.Size = UDim2.new(1, 0, 0, 10)
                            sliderFrame.ZIndex = 11
                            
                            local sliderLabel = Instance.new("TextLabel")
                            sliderLabel.Name = "Label"
                            sliderLabel.Parent = sliderFrame
                            sliderLabel.BackgroundTransparency = 1
                            sliderLabel.Size = UDim2.new(0, 20, 1, 0)
                            sliderLabel.Font = Enum.Font.Gotham
                            sliderLabel.Text = component
                            sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            sliderLabel.TextSize = 12
                            sliderLabel.ZIndex = 11
                            
                            local sliderBg = Instance.new("Frame")
                            sliderBg.Name = "Background"
                            sliderBg.Parent = sliderFrame
                            sliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                            sliderBg.BorderColor3 = Color3.fromRGB(80, 80, 80)
                            sliderBg.BorderSizePixel = 1
                            sliderBg.Position = UDim2.new(0, 25, 0, 0)
                            sliderBg.Size = UDim2.new(0.7, 0, 1, 0)
                            sliderBg.ZIndex = 11
                            
                            local sliderFill = Instance.new("Frame")
                            sliderFill.Name = "Fill"
                            sliderFill.Parent = sliderBg
                            
                            if component == "R" then
                                sliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            elseif component == "G" then
                                sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            else
                                sliderFill.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
                            end
                            
                            sliderFill.BorderSizePixel = 0
                            sliderFill.Size = UDim2.new(defaultValue/255, 0, 1, 0)
                            sliderFill.ZIndex = 11
                            
                            local valueLabel = Instance.new("TextLabel")
                            valueLabel.Name = "Value"
                            valueLabel.Parent = sliderFrame
                            valueLabel.BackgroundTransparency = 1
                            valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
                            valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
                            valueLabel.Font = Enum.Font.Gotham
                            valueLabel.Text = tostring(defaultValue)
                            valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            valueLabel.TextSize = 12
                            valueLabel.ZIndex = 11
                            
                            sliderBg.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    local relPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                                    relPos = math.clamp(relPos, 0, 1)
                                    sliderFill.Size = UDim2.new(relPos, 0, 1, 0)
                                    local value = math.floor(relPos * 255)
                                    valueLabel.Text = tostring(value)
                                    
                                    -- Update color
                                    local r = tonumber(rgbContainer.RSlider.Value.Text)
                                    local g = tonumber(rgbContainer.GSlider.Value.Text)
                                    local b = tonumber(rgbContainer.BSlider.Value.Text)
                                    local newColor = Color3.fromRGB(r, g, b)
                                    colorButton.BackgroundColor3 = newColor
                                    callback(newColor)
                                end
                            end)
                            
                            sliderBg.InputChanged:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseMovement and
                                   game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                    local relPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                                    relPos = math.clamp(relPos, 0, 1)
                                    sliderFill.Size = UDim2.new(relPos, 0, 1, 0)
                                    local value = math.floor(relPos * 255)
                                    valueLabel.Text = tostring(value)
                                    
                                    -- Update color
                                    local r = tonumber(rgbContainer.RSlider.Value.Text)
                                    local g = tonumber(rgbContainer.GSlider.Value.Text)
                                    local b = tonumber(rgbContainer.BSlider.Value.Text)
                                    local newColor = Color3.fromRGB(r, g, b)
                                    colorButton.BackgroundColor3 = newColor
                                    callback(newColor)
                                end
                            end)
                        end
                        
                        -- Create RGB sliders with the current color values
                        createRGBSlider("R", 0, colorButton.BackgroundColor3.R * 255)
                        createRGBSlider("G", 15, colorButton.BackgroundColor3.G * 255)
                        createRGBSlider("B", 30, colorButton.BackgroundColor3.B * 255)
                    end)
    
                    -- Store the color picker
                    UI.Elements[label] = {
                        Set = function(color)
                            colorButton.BackgroundColor3 = color
                            callback(color)
                        end
                    }

                    return UI.Elements[label]
                end
    
                return sectionFrame
            end
    
            return tabContent
        end
        
        -- Function to create a notification
        function UI:CreateNotification(title, message, type, duration)
            local notifGui = Instance.new("ScreenGui")
            notifGui.Name = "SynthwaveNotification"
            
            -- Parent to the correct location
            if game:GetService("Players") or {LocalPlayer = {Name = "Player"}}.LocalPlayer then
                notifGui.Parent = game:GetService("Players") or {LocalPlayer = {Name = "Player"}}.LocalPlayer:WaitForChild("PlayerGui")
            else
                notifGui.Parent = game:GetService("CoreGui")
            end
            
            local notifFrame = Instance.new("Frame")
            notifFrame.Name = "NotificationFrame"
            notifFrame.Parent = notifGui
            notifFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            notifFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
            notifFrame.BorderSizePixel = 2
            notifFrame.Position = UDim2.new(1, 10, 0.8, 0)
            notifFrame.Size = UDim2.new(0, 250, 0, 80)
            notifFrame.AnchorPoint = Vector2.new(0, 1)
            
            -- Add a colored bar based on type
            local colorBar = Instance.new("Frame")
            colorBar.Name = "ColorBar"
            colorBar.Parent = notifFrame
            colorBar.Size = UDim2.new(0, 5, 1, 0)
            colorBar.BorderSizePixel = 0
            
            -- Set color based on type
            if type == "success" then
                colorBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            elseif type == "warning" then
                colorBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            elseif type == "error" then
                colorBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            else -- info
                colorBar.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
            end
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "Title"
            titleLabel.Parent = notifFrame
            titleLabel.BackgroundTransparency = 1
            titleLabel.Position = UDim2.new(0, 10, 0, 5)
            titleLabel.Size = UDim2.new(1, -15, 0, 20)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = title
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextSize = 16
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local messageLabel = Instance.new("TextLabel")
            messageLabel.Name = "Message"
            messageLabel.Parent = notifFrame
            messageLabel.BackgroundTransparency = 1
            messageLabel.Position = UDim2.new(0, 10, 0, 30)
            messageLabel.Size = UDim2.new(1, -15, 0, 40)
            messageLabel.Font = Enum.Font.Gotham
            messageLabel.Text = message
            messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            messageLabel.TextSize = 14
            messageLabel.TextWrapped = true
            messageLabel.TextXAlignment = Enum.TextXAlignment.Left
            messageLabel.TextYAlignment = Enum.TextYAlignment.Top
            
            -- Animate the notification
            notifFrame:TweenPosition(UDim2.new(1, -260, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
            
            -- Remove after duration
            delay(duration, function()
                notifFrame:TweenPosition(UDim2.new(1, 10, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true, function()
                    notifGui:Destroy()
                end)
            end)
        end
        
        -- Function to set theme
        function UI:SetTheme(theme)
            if theme == "Dark" then
                DragFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                TopBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                
                -- Update all section backgrounds
                for _, section in pairs(UI.Sections) do
                    section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end
            elseif theme == "Light" then
                DragFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                TopBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                TabBar.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
                TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                
                -- Update all section backgrounds
                for _, section in pairs(UI.Sections) do
                    section.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
                    
                    -- Update labels to dark text
                    for _, child in pairs(section:GetDescendants()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            child.TextColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    end
                end
            elseif theme == "Midnight" then
                DragFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                
                -- Update all section backgrounds
                for _, section in pairs(UI.Sections) do
                    section.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                end
            end
            
            -- Store the current theme
            self.Options.Theme = theme
        end
        
        -- Function to set accent color
        function UI:SetAccentColor(color)
            -- Update accent color in all UI elements
            for _, elements in pairs(UI.Elements) do
                if type(elements) == "table" and elements.Set then
                    -- Find slider fills and update them
                    local parent = elements.Parent
                    if parent and parent:FindFirstChild("SliderFill") then
                        parent.SliderFill.BackgroundColor3 = color
                    end
                end
            end
            
            -- Store the current accent color
            self.Options.AccentColor = color
        end
        
        return UI
    end,
    
    -- Set/update theme
    SetTheme = function(self, theme)
        self.Options.Theme = theme
    end,
    
    -- Set/update accent color
    SetAccentColor = function(self, color)
        self.Options.AccentColor = color
    end
}

return SynthwaveUI

-- Add notification system
function SynthwaveUI:Notify(title, message, duration)
    duration = duration or 5
    
    local NotificationHolder = Instance.new("ScreenGui")
    NotificationHolder.Name = "SynthwaveNotification"
    NotificationHolder.Parent = CoreGui
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Notification.BorderSizePixel = 0
    Notification.Position = UDim2.new(1, -320, 1, -100)
    Notification.Size = UDim2.new(0, 300, 0, 80)
    Notification.Parent = NotificationHolder
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Notification
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.Size = UDim2.new(1, -30, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 0, 128)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.BackgroundTransparency = 1
    Message.Position = UDim2.new(0, 15, 0, 35)
    Message.Size = UDim2.new(1, -30, 0, 35)
    Message.Font = Enum.Font.Gotham
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(255, 255, 255)
    Message.TextSize = 14
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.Parent = Notification
    
    -- Animate in
    Notification.Position = UDim2.new(1, 20, 1, -100)
    local Tween = TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -320, 1, -100)})
    Tween:Play()
    
    -- Animate out after duration
    task.delay(duration, function()
        local Tween = TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 20, 1, -100)})
        Tween:Play()
        Tween.Completed:Connect(function()
            NotificationHolder:Destroy()
        end)
    end)
end

-- Error handling wrapper
function SynthwaveUI:SafeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        self:Notify("Error", "An error occurred: " .. tostring(result), 5)
        warn("SynthwaveUI Error: " .. tostring(result))
    end
    return success, result
end
