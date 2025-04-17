--[[
    Nebula UI Library v2.2
    Complete Synthwave UI Library for Roblox
    Features:
    - Fixed all PlaceMaxPlayers/MarketplaceService errors
    - Modern wide design with neon aesthetics
    - Player dashboard with avatar + game info
    - Toggles, sliders, dropdowns, keybinds, buttons
    - Notification system
    - Fully draggable with minimize/close
    - Works on PC + Mobile
    - No nil errors
]]

local NebulaUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Constants
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local DEFAULT_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SYNTHWAVE_PALETTE = {
    Primary = Color3.fromRGB(255, 85, 227),
    Secondary = Color3.fromRGB(85, 205, 252),
    Background = Color3.fromRGB(20, 20, 40),
    DarkBackground = Color3.fromRGB(10, 10, 25),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(255, 42, 85),
    Success = Color3.fromRGB(85, 255, 127),
    Warning = Color3.fromRGB(255, 213, 85),
    Error = Color3.fromRGB(255, 85, 85)
}

-- Utility functions
local function Create(class, props)
    local instance = Instance.new(class)
    for prop, value in pairs(props) do
        if prop ~= "Parent" then
            if pcall(function() return instance[prop] end) then
                if typeof(value) == "Instance" then
                    value.Parent = instance
                else
                    instance[prop] = value
                end
            end
        end
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

local function Round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Tween(instance, properties, tweenInfo, callback)
    local tween = TweenService:Create(instance, tweenInfo or DEFAULT_TWEEN_INFO, properties)
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

local function GetTextSize(text, font, size, frame)
    return TextService:GetTextSize(text, size, font, frame.AbsoluteSize)
end

-- UI Components
function NebulaUI:CreateWindow(title, options)
    options = options or {}
    local theme = options.Theme or SYNTHWAVE_PALETTE
    local size = options.Size or Vector2.new(500, 600)
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local minSize = options.MinSize or Vector2.new(300, 300)
    
    -- Main window container
    local Window = {
        Title = title,
        Theme = theme,
        Tabs = {},
        CurrentTab = nil,
        Minimized = false,
        Hidden = false,
        Closed = false,
        Dragging = false,
        DragStart = nil,
        LastPosition = position,
        Notifications = {}
    }
    
    -- ScreenGui container
   local ScreenGui = Create("ScreenGui", {
    Name = "NebulaUI_" .. HttpService:GenerateGUID(false),
    ResetOnSpawn = false,
    DisplayOrder = 999,
    Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") -- 🔥 CRITICAL FIX
})
    
    -- Main frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.fromOffset(size.X, size.Y),
        Position = position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.DarkBackground,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    -- Corner rounding
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })
    
    -- Drop shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Parent = MainFrame
    })
    
    -- Title bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = TitleBar
    })
    
    -- Title text
    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    -- Close button
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.Error,
        TextColor3 = theme.Text,
        Text = "×",
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseButton
    })
    
    -- Minimize button
    local MinimizeButton = Create("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -80, 0.5, -15),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.Warning,
        TextColor3 = theme.Text,
        Text = "-",
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = MinimizeButton
    })
    
    -- Content container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Dashboard tab (default)
    local DashboardTab = Create("Frame", {
        Name = "DashboardTab",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = true,
        Parent = ContentContainer
    })
    
    -- Player info section
    local PlayerInfo = Create("Frame", {
        Name = "PlayerInfo",
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = theme.Background,
        Parent = DashboardTab
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = PlayerInfo
    })
    
    -- Player avatar
    local PlayerAvatar = Create("ImageLabel", {
        Name = "PlayerAvatar",
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0, 15, 0.5, -40),
        BackgroundColor3 = theme.DarkBackground,
        BorderSizePixel = 0,
        Parent = PlayerInfo
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = PlayerAvatar
    })
    
    -- Player name
    local PlayerName = Create("TextLabel", {
        Name = "PlayerName",
        Size = UDim2.new(0.6, 0, 0, 30),
        Position = UDim2.new(0, 110, 0, 20),
        BackgroundTransparency = 1,
        Text = Players.LocalPlayer.Name,
        TextColor3 = theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = PlayerInfo
    })
    
    -- Player display name
    local DisplayName = Create("TextLabel", {
        Name = "DisplayName",
        Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.new(0, 110, 0, 50),
        BackgroundTransparency = 1,
        Text = "@" .. Players.LocalPlayer.DisplayName,
        TextColor3 = theme.Text,
        TextTransparency = 0.5,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        Parent = PlayerInfo
    })
    
    -- Game info section
    local GameInfo = Create("Frame", {
        Name = "GameInfo",
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 140),
        BackgroundColor3 = theme.Background,
        Parent = DashboardTab
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = GameInfo
    })
    
    -- Game title (with error handling)
    local gameName = "Unknown Game"
    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    if success then gameName = result end
    
    local GameTitle = Create("TextLabel", {
        Name = "GameTitle",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = gameName,
        TextColor3 = theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = GameInfo
    })
    
    -- Server info (with error handling for UGC games)
    local serverInfoText = "Server: "..game.JobId.." | Players: "..#Players:GetPlayers()
    if pcall(function() return game.PlaceMaxPlayers end) then
        serverInfoText = serverInfoText.."/"..game.PlaceMaxPlayers
    end

    local ServerInfo = Create("TextLabel", {
        Name = "ServerInfo",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        Text = serverInfoText,
        TextColor3 = theme.Text,
        TextTransparency = 0.5,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        Parent = GameInfo
    })
    
    -- Place ID
    local PlaceID = Create("TextLabel", {
        Name = "PlaceID",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Text = "Place ID: "..game.PlaceId,
        TextColor3 = theme.Text,
        TextTransparency = 0.5,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        Parent = GameInfo
    })
    
    -- Tab buttons container
    local TabButtons = Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 250),
        BackgroundTransparency = 1,
        Parent = DashboardTab
    })
    
    -- Tab list
    local TabList = Create("Frame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = ContentContainer
    })
    
    local UIListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = TabList
    })
    
    -- Add dashboard tab button
    local DashboardTabButton = Create("TextButton", {
        Name = "DashboardTabButton",
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = theme.Primary,
        TextColor3 = theme.Text,
        Text = "Dashboard",
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        LayoutOrder = 0,
        Parent = TabList
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = DashboardTabButton
    })
    
    -- Initialize window methods
    function Window:SetTheme(newTheme)
    -- Merge with default theme to ensure all colors exist
    theme = setmetatable(newTheme or {}, {__index = SYNTHWAVE_PALETTE})
    Window.Theme = theme
    
    -- Update all elements with new theme
    if MainFrame then MainFrame.BackgroundColor3 = theme.DarkBackground or SYNTHWAVE_PALETTE.DarkBackground end
    if TitleBar then TitleBar.BackgroundColor3 = theme.Background or SYNTHWAVE_PALETTE.Background end
    if TitleLabel then TitleLabel.TextColor3 = theme.Text or SYNTHWAVE_PALETTE.Text end
    if CloseButton then CloseButton.BackgroundColor3 = theme.Error or SYNTHWAVE_PALETTE.Error end
    if MinimizeButton then MinimizeButton.BackgroundColor3 = theme.Warning or SYNTHWAVE_PALETTE.Warning end
    if PlayerInfo then PlayerInfo.BackgroundColor3 = theme.Background or SYNTHWAVE_PALETTE.Background end
    if GameInfo then GameInfo.BackgroundColor3 = theme.Background or SYNTHWAVE_PALETTE.Background end
    if DashboardTabButton then DashboardTabButton.BackgroundColor3 = theme.Primary or SYNTHWAVE_PALETTE.Primary end
    
    -- Update existing tabs and elements
    for _, tab in pairs(Window.Tabs) do
        if tab.Container then
            tab.Container.BackgroundColor3 = theme.Background or SYNTHWAVE_PALETTE.Background
        end
        if tab.Button then
            tab.Button.BackgroundColor3 = (Window.CurrentTab == tab) and (theme.Primary or SYNTHWAVE_PALETTE.Primary) or (theme.Secondary or SYNTHWAVE_PALETTE.Secondary)
        end
    end
end
    
    function Window:Minimize()
        Window.Minimized = true
        Tween(MainFrame, {Size = UDim2.new(0, 200, 0, 40)})
        Tween(ContentContainer, {Size = UDim2.new(1, 0, 0, 0)})
    end
    
    function Window:Maximize()
        Window.Minimized = false
        Tween(MainFrame, {Size = UDim2.fromOffset(size.X, size.Y)})
        Tween(ContentContainer, {Size = UDim2.new(1, 0, 1, -40)})
    end
    
    function Window:ToggleMinimize()
        if Window.Minimized then
            Window:Maximize()
        else
            Window:Minimize()
        end
    end
    
    function Window:Hide()
        Window.Hidden = true
        MainFrame.Visible = false
    end
    
    function Window:Show()
        Window.Hidden = false
        MainFrame.Visible = true
    end
    
    function Window:ToggleVisibility()
        if Window.Hidden then
            Window:Show()
        else
            Window:Hide()
        end
    end
    
    function Window:Close()
        Window.Closed = true
        ScreenGui:Destroy()
    end
    
    function Window:CreateTab(name, icon)
        local tabName = name or "Tab " .. (#Window.Tabs + 1)
        local tabId = #Window.Tabs + 1
        
        -- Create tab container
        local TabContainer = Create("ScrollingFrame", {
            Name = tabName .. "Tab",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = theme.Primary,
            Parent = ContentContainer
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = TabContainer
        })
        
        -- Create tab button
        local TabButton = Create("TextButton", {
            Name = tabName .. "TabButton",
            Size = UDim2.new(0, 120, 1, 0),
            BackgroundColor3 = theme.Secondary,
            TextColor3 = theme.Text,
            Text = tabName,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            LayoutOrder = tabId,
            Parent = TabList
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = TabButton
        })
        
        -- Tab data
        local Tab = {
            Name = tabName,
            Id = tabId,
            Container = TabContainer,
            Button = TabButton,
            Sections = {}
        }
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab button click event
        TabButton.MouseButton1Click:Connect(function()
            Window:SwitchTab(tabId)
        end)
        
        -- Set first tab as active if none selected
        if #Window.Tabs == 1 then
            Window:SwitchTab(1)
        end
        
        return Tab
    end
    
    function Window:SwitchTab(tabId)
        if Window.CurrentTab then
            Window.CurrentTab.Container.Visible = false
            Window.CurrentTab.Button.BackgroundColor3 = theme.Secondary
        end
        
        Window.CurrentTab = Window.Tabs[tabId]
        Window.CurrentTab.Container.Visible = true
        Window.CurrentTab.Button.BackgroundColor3 = theme.Primary
    end
    
    function Window:CreateSection(tab, name)
        local sectionName = name or "Section " .. (#tab.Sections + 1)
        
        -- Section frame
        local SectionFrame = Create("Frame", {
            Name = sectionName .. "Section",
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundColor3 = theme.Background,
            LayoutOrder = #tab.Sections + 1,
            Parent = tab.Container
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = SectionFrame
        })
        
        -- Section title
        local SectionTitle = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = sectionName,
            TextColor3 = theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            Parent = SectionFrame
        })
        
        -- Section content
        local SectionContent = Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 35),
            BackgroundTransparency = 1,
            Parent = SectionFrame
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = SectionContent
        })
        
        local Section = {
            Name = sectionName,
            Frame = SectionFrame,
            Title = SectionTitle,
            Content = SectionContent,
            Elements = {}
        }
        
        table.insert(tab.Sections, Section)
        
        -- Auto-size section
        SectionContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local contentHeight = 0
            for _, child in ipairs(SectionContent:GetChildren()) do
                if child:IsA("GuiObject") and child ~= SectionContent.UIListLayout then
                    contentHeight = contentHeight + child.AbsoluteSize.Y + 10
                end
            end
            
            SectionFrame.Size = UDim2.new(1, -20, 0, contentHeight + 40)
            SectionContent.Size = UDim2.new(1, 0, 0, contentHeight)
        end)
        
        return Section
    end
    
    function Window:CreateLabel(section, text)
        local labelText = text or "Label"
        
        local Label = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            LayoutOrder = #section.Elements + 1,
            Parent = section.Content
        })
        
        table.insert(section.Elements, {
            Type = "Label",
            Instance = Label
        })
        
        return Label
    end
    
    function Window:CreateButton(section, text, callback)
        local buttonText = text or "Button"
        local buttonCallback = callback or function() end
        
        local Button = Create("TextButton", {
            Name = "Button",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = theme.Primary,
            TextColor3 = theme.Text,
            Text = buttonText,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            LayoutOrder = #section.Elements + 1,
            Parent = section.Content
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Button
        })
        
        Button.MouseButton1Click:Connect(function()
            Tween(Button, {Size = UDim2.new(0.95, 0, 0, 30)})
            Tween(Button, {Size = UDim2.new(1, 0, 0, 30)}, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
            buttonCallback()
        end)
        
        table.insert(section.Elements, {
            Type = "Button",
            Instance = Button,
            Callback = buttonCallback
        })
        
        return Button
    end
    
    function Window:CreateToggle(section, text, default, callback)
        local toggleText = text or "Toggle"
        local toggleState = default or false
        local toggleCallback = callback or function() end
        
        local ToggleFrame = Create("Frame", {
            Name = "Toggle",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = #section.Elements + 1,
            Parent = section.Content
        })
        
        local ToggleButton = Create("TextButton", {
            Name = "ToggleButton",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundColor3 = toggleState and theme.Success or theme.Error,
            Text = "",
            Parent = ToggleFrame
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ToggleButton
        })
        
        local ToggleLabel = Create("TextLabel", {
            Name = "ToggleLabel",
            Size = UDim2.new(1, -40, 1, 0),
            BackgroundTransparency = 1,
            Text = toggleText,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            Parent = ToggleFrame
        })
        
        local function UpdateToggle()
            Tween(ToggleButton, {BackgroundColor3 = toggleState and theme.Success or theme.Error})
            toggleCallback(toggleState)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            toggleState = not toggleState
            UpdateToggle()
        end)
        
        UpdateToggle()
        
        table.insert(section.Elements, {
            Type = "Toggle",
            Instance = ToggleFrame,
            State = toggleState,
            Callback = toggleCallback,
            Update = UpdateToggle
        })
        
        return {
            Frame = ToggleFrame,
            Button = ToggleButton,
            Label = ToggleLabel,
            Set = function(self, state)
                toggleState = state
                UpdateToggle()
            end,
            Get = function(self)
                return toggleState
            end,
            Toggle = function(self)
                toggleState = not toggleState
                UpdateToggle()
            end
        }
    end
    
    function Window:CreateSlider(section, text, min, max, default, callback, precise)
        local sliderText = text or "Slider"
        local sliderMin = min or 0
        local sliderMax = max or 100
        local sliderValue = default or math.floor((sliderMin + sliderMax) / 2)
        local sliderCallback = callback or function() end
        local sliderPrecise = precise or false
        
        local SliderFrame = Create("Frame", {
            Name = "Slider",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
            LayoutOrder = #section.Elements + 1,
            Parent = section.Content
        })
        
        local SliderLabel = Create("TextLabel", {
            Name = "SliderLabel",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = sliderText,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            Parent = SliderFrame
        })
        
        local SliderValue = Create("TextLabel", {
            Name = "SliderValue",
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -50, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(sliderValue),
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.Gotham,
            Parent = SliderFrame
        })
        
        local SliderTrack = Create("Frame", {
            Name = "SliderTrack",
            Size = UDim2.new(1, 0, 0, 5),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundColor3 = theme.Background,
            Parent = SliderFrame
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SliderTrack
        })
        
        local SliderFill = Create("Frame", {
            Name = "SliderFill",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = theme.Primary,
            Parent = SliderTrack
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SliderFill
        })
        
        local SliderButton = Create("TextButton", {
            Name = "SliderButton",
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 0, 0.5, -7.5),
            BackgroundColor3 = theme.Text,
            Text = "",
            Parent = SliderTrack
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SliderButton
        })
        
        local function UpdateSlider(value)
            local normalized = math.clamp(value, sliderMin, sliderMax)
            local percent = (normalized - sliderMin) / (sliderMax - sliderMin)
            
            if sliderPrecise then
                sliderValue = normalized
            else
                sliderValue = math.floor(normalized)
            end
            
            SliderValue.Text = tostring(sliderValue)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderButton.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
            
            sliderCallback(sliderValue)
        end
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        local function UpdateSliderFromMouse()
            if not dragging then return end
            
            local mousePos = UserInputService:GetMouseLocation()
            local trackPos = SliderTrack.AbsolutePosition
            local trackSize = SliderTrack.AbsoluteSize
            local relativeX = math.clamp(mousePos.X - trackPos.X, 0, trackSize.X)
            local percent = relativeX / trackSize.X
            local value = sliderMin + (sliderMax - sliderMin) * percent
            
            UpdateSlider(value)
        end
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                UpdateSliderFromMouse()
            end
        end)
        
        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSliderFromMouse()
            end
        end)
        
        UpdateSlider(sliderValue)
        
        table.insert(section.Elements, {
            Type = "Slider",
            Instance = SliderFrame,
            Value = sliderValue,
            Min = sliderMin,
            Max = sliderMax,
            Callback = sliderCallback,
            Set = function(self, value)
                UpdateSlider(value)
            end,
            Get = function(self)
                return sliderValue
            end
        })
        
        return {
            Frame = SliderFrame,
            Label = SliderLabel,
            ValueLabel = SliderValue,
            Track = SliderTrack,
            Fill = SliderFill,
            Button = SliderButton,
            Set = function(self, value)
                UpdateSlider(value)
            end,
            Get = function(self)
                return sliderValue
            end
        }
    end
    
    function Window:CreateDropdown(section, text, options, default, callback)
        local dropdownText = text or "Dropdown"
        local dropdownOptions = options or {"Option 1", "Option 2", "Option 3"}
        local dropdownValue = default or dropdownOptions[1]
        local dropdownCallback = callback or function() end
        local dropdownOpen = false
        
        local DropdownFrame = Create("Frame", {
            Name = "Dropdown",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = #section.Elements + 1,
            Parent = section.Content
        })
        
        local DropdownLabel = Create("TextLabel", {
            Name = "DropdownLabel",
            Size = UDim2.new(1, -40, 1, 0),
            BackgroundTransparency = 1,
            Text = dropdownText,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            Parent = DropdownFrame
        })
        
        local DropdownButton = Create("TextButton", {
            Name = "DropdownButton",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundColor3 = theme.Secondary,
            Text = "▼",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = DropdownFrame
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = DropdownButton
        })
        
        local DropdownValue = Create("TextLabel", {
            Name = "DropdownValue",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = dropdownValue,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.Gotham,
            Parent = DropdownFrame
        })
        
        local DropdownList = Create("Frame", {
            Name = "DropdownList",
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = theme.Background,
            ClipsDescendants = true,
            Visible = false,
            Parent = DropdownFrame
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = DropdownList
        })
        
        local DropdownListLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DropdownList
        })
        
        local function UpdateDropdown()
            DropdownValue.Text = dropdownValue
            dropdownCallback(dropdownValue)
        end
        
        local function ToggleDropdown()
            dropdownOpen = not dropdownOpen
            
            if dropdownOpen then
                DropdownList.Visible = true
                DropdownButton.Text = "▲"
                
                -- Clear existing options
                for _, child in ipairs(DropdownList:GetChildren()) do
                    if child:IsA("GuiObject") then
                        child:Destroy()
                    end
                end
                
                -- Add new options
                for i, option in ipairs(dropdownOptions) do
                    local OptionButton = Create("TextButton", {
                        Name = "Option" .. i,
                        Size = UDim2.new(1, -10, 0, 30),
                        Position = UDim2.new(0, 5, 0, (i-1)*35),
                        BackgroundColor3 = theme.DarkBackground,
                        Text = option,
                        TextColor3 = theme.Text,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        LayoutOrder = i,
                        Parent = DropdownList
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        dropdownValue = option
                        UpdateDropdown()
                        ToggleDropdown()
                    end)
                end
                
                -- Update dropdown list size
                DropdownList.Size = UDim2.new(1, 0, 0, #dropdownOptions * 35 + 5)
            else
                DropdownButton.Text = "▼"
                Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), function()
                    DropdownList.Visible = false
                end)
            end
        end
        
        DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
        
        UpdateDropdown()
        
        table.insert(section.Elements, {
            Type = "Dropdown",
            Instance = DropdownFrame,
            Value = dropdownValue,
            Options = dropdownOptions,
            Callback = dropdownCallback,
            Set = function(self, value)
                if table.find(dropdownOptions, value) then
                    dropdownValue = value
                    UpdateDropdown()
                end
            end,
            Get = function(self)
                return dropdownValue
            end,
            SetOptions = function(self, options)
                dropdownOptions = options
                if not table.find(dropdownOptions, dropdownValue) then
                    dropdownValue = dropdownOptions[1]
                    UpdateDropdown()
                end
            end
        })
        
        return {
            Frame = DropdownFrame,
            Label = DropdownLabel,
            Value = DropdownValue,
            Button = DropdownButton,
            List = DropdownList,
            Set = function(self, value)
                if table.find(dropdownOptions, value) then
                    dropdownValue = value
                    UpdateDropdown()
                end
            end,
            Get = function(self)
                return dropdownValue
            end,
            SetOptions = function(self, options)
                dropdownOptions = options
                if not table.find(dropdownOptions, dropdownValue) then
                    dropdownValue = dropdownOptions[1]
                    UpdateDropdown()
                end
            end,
            Toggle = ToggleDropdown
        }
    end
    
    function Window:CreateKeybind(section, text, default, callback)
        local keybindText = text or "Keybind"
        local keybindValue = default or Enum.KeyCode.F
        local keybindCallback = callback or function() end
        local listening = false
        
        local KeybindFrame = Create("Frame", {
            Name = "Keybind",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = #section.Elements + 1,
            Parent = section.Content
        })
        
        local KeybindLabel = Create("TextLabel", {
            Name = "KeybindLabel",
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = keybindText,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            Parent = KeybindFrame
        })
        
        local KeybindButton = Create("TextButton", {
            Name = "KeybindButton",
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = theme.Secondary,
            Text = tostring(keybindValue):gsub("Enum.KeyCode.", ""),
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = KeybindFrame
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = KeybindButton
        })
        
        local function UpdateKeybind()
            KeybindButton.Text = tostring(keybindValue):gsub("Enum.KeyCode.", "")
            keybindCallback(keybindValue)
        end
        
        KeybindButton.MouseButton1Click:Connect(function()
            listening = true
            KeybindButton.Text = "..."
            KeybindButton.BackgroundColor3 = theme.Primary
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not listening or gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keybindValue = input.KeyCode
                listening = false
                KeybindButton.BackgroundColor3 = theme.Secondary
                UpdateKeybind()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                keybindValue = input.UserInputType
                listening = false
                KeybindButton.BackgroundColor3 = theme.Secondary
                UpdateKeybind()
            end
        end)
        
        UpdateKeybind()
        
        table.insert(section.Elements, {
            Type = "Keybind",
            Instance = KeybindFrame,
            Value = keybindValue,
            Callback = keybindCallback,
            Set = function(self, value)
                keybindValue = value
                UpdateKeybind()
            end,
            Get = function(self)
                return keybindValue
            end
        })
        
        return {
            Frame = KeybindFrame,
            Label = KeybindLabel,
            Button = KeybindButton,
            Set = function(self, value)
                keybindValue = value
                UpdateKeybind()
            end,
            Get = function(self)
                return keybindValue
            end,
            IsListening = function(self)
                return listening
            end
        }
    end
    
    function Window:CreateNotification(title, text, duration, notificationType)
        local notifTitle = title or "Notification"
        local notifText = text or "This is a notification"
        local notifDuration = duration or 5
        local notifType = notificationType or "Info"
        
        local NotifFrame = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 300, 0, 80),
            Position = UDim2.new(1, -320, 1, -90),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = theme.Background,
            Parent = ScreenGui
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = NotifFrame
        })
        
        local NotifTitle = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = notifTitle,
            TextColor3 = theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            Parent = NotifFrame
        })
        
        local NotifText = Create("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, -20, 1, -40),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 1,
            Text = notifText,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Font = Enum.Font.Gotham,
            Parent = NotifFrame
        })
        
        local NotifBar = Create("Frame", {
            Name = "Bar",
            Size = UDim2.new(0, 5, 1, -10),
            Position = UDim2.new(0, 5, 0.5, -5),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = theme.Primary,
            Parent = NotifFrame
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = NotifBar
        })
        
        -- Set notification type color
        if notifType == "Success" then
            NotifBar.BackgroundColor3 = theme.Success
        elseif notifType == "Warning" then
            NotifBar.BackgroundColor3 = theme.Warning
        elseif notifType == "Error" then
            NotifBar.BackgroundColor3 = theme.Error
        end
        
        -- Animate in
        NotifFrame.Position = UDim2.new(1, 320, 1, -90)
        Tween(NotifFrame, {Position = UDim2.new(1, -320, 1, -90)})
        
        -- Auto-close after duration
        task.delay(notifDuration, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 320, 1, -90)}, function()
                NotifFrame:Destroy()
            end)
        end)
        
        return NotifFrame
    end
    
    -- Initialize window events
    CloseButton.MouseButton1Click:Connect(function()
        Window:Close()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Window:ToggleMinimize()
    end)
    
    -- Dragging functionality
    local function UpdateDrag(input)
        if Window.Minimized or Window.Closed then return end
        
        local delta = input.Position - Window.DragStart
        local newPos = UDim2.new(
            Window.LastPosition.X.Scale,
            Window.LastPosition.X.Offset + delta.X,
            Window.LastPosition.Y.Scale,
            Window.LastPosition.Y.Offset + delta.Y
        )
        
        MainFrame.Position = newPos
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Window.Dragging = true
            Window.DragStart = input.Position
            Window.LastPosition = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Window.Dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if Window.Dragging then
                UpdateDrag(input)
            end
        end
    end)
    
    -- Load player avatar
    local function LoadPlayerAvatar()
        local userId = Players.LocalPlayer.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        
        PlayerAvatar.Image = content
    end
    
    LoadPlayerAvatar()
    
    -- Return window object
    return Window
end

-- Initialize library
return NebulaUI
