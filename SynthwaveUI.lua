--[[ 
    SynthwaveX UI Library v2.0
    Part 1: Core Framework and Initialization
    DO NOT MODIFY ANYTHING BETWEEN SECTION MARKERS
--]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                                MAIN LIBRARY                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local SynthwaveX = {
    Version = "2.0.0",
    Windows = {},
    Theme = {
        Primary = Color3.fromRGB(255, 65, 125),    -- Hot pink
        Secondary = Color3.fromRGB(0, 255, 255),   -- Cyan
        Background = Color3.fromRGB(20, 20, 35),   -- Dark blue-gray
        SecondaryBackground = Color3.fromRGB(30, 30, 45), -- Lighter blue-gray
        Text = Color3.fromRGB(255, 255, 255),      -- White
        SecondaryText = Color3.fromRGB(200, 200, 200), -- Light gray
        Border = Color3.fromRGB(123, 47, 189),     -- Purple
        Accent = Color3.fromRGB(255, 122, 0),      -- Orange
        Success = Color3.fromRGB(46, 255, 119),    -- Green
        Error = Color3.fromRGB(255, 44, 44),       -- Red
        Gradient1 = Color3.fromRGB(255, 65, 125),  -- Gradient start
        Gradient2 = Color3.fromRGB(0, 255, 255)    -- Gradient end
    },
    Fonts = {
        Regular = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
        Semi = Enum.Font.GothamSemibold,
        Mono = Enum.Font.Code
    },
    Icons = {
        Close = "rbxassetid://11293981586",
        Minimize = "rbxassetid://11293981898",
        Settings = "rbxassetid://11293981983",
        Search = "rbxassetid://11293982064",
        Notification = "rbxassetid://11293982169"
    }
}

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                                  SERVICES                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    TextService = game:GetService("TextService")
}

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              UTILITY FUNCTIONS                               ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Utility = {}

function Utility.Create(instanceType)
    return function(properties)
        local instance = Instance.new(instanceType)
        for property, value in pairs(properties) do
            if property ~= "Parent" then
                instance[property] = value
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
        return instance
    end
end

function Utility.Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = Services.TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility.CreateGradient(parent, rotation)
    return Utility.Create("UIGradient"){
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SynthwaveX.Theme.Gradient1),
            ColorSequenceKeypoint.new(1, SynthwaveX.Theme.Gradient2)
        }),
        Rotation = rotation or 45,
        Parent = parent
    }
end

function Utility.CreateShadow(parent, size)
    return Utility.Create("ImageLabel"){
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 28, 1, size or 28),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        Parent = parent
    }
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                                WINDOW CLASS                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({
        Title = title,
        Tabs = {},
        ActiveTab = nil,
        Dragging = false,
        DragStart = nil,
        StartPosition = nil
    }, Window)

    self:Initialize()
    return self
end

function Window:Initialize()
    -- Create main GUI elements
    self.ScreenGui = Utility.Create("ScreenGui"){
        Name = "SynthwaveX",
        Parent = Services.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    }

    self.MainFrame = Utility.Create("Frame"){
        Name = "MainFrame",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        Parent = self.ScreenGui
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = self.MainFrame
    }

    Utility.CreateShadow(self.MainFrame, 35)

    -- Initialize containers
    self:InitializeTopBar()
    self:InitializeContainers()
    self:EnableDragging()
end

function Window:InitializeTopBar()
    self.TopBar = Utility.Create("Frame"){
        Name = "TopBar",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.MainFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = self.TopBar
    }

    Utility.CreateGradient(self.TopBar, 90)

    self.TitleLabel = Utility.Create("TextLabel"){
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = SynthwaveX.Fonts.Bold,
        Text = self.Title,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    }
end

function Window:InitializeContainers()
    self.TabContainer = Utility.Create("ScrollingFrame"){
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 150, 1, -50),
        ScrollBarThickness = 0,
        Parent = self.MainFrame
    }

    self.ContentContainer = Utility.Create("Frame"){
        Name = "ContentContainer",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 170, 0, 40),
        Size = UDim2.new(1, -180, 1, -50),
        Parent = self.MainFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = self.ContentContainer
    }
end

function Window:EnableDragging()
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    self.TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              LIBRARY FUNCTIONS                               ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function SynthwaveX:CreateWindow(title)
    local window = Window.new(title)
    table.insert(self.Windows, window)
    return window
end

-- Initialize the library
_G.SynthwaveXLoaded = true

return SynthwaveX

--[[ 
    SynthwaveX UI Library v2.0
    Part 2: Tab System and Elements
    PLACE THIS CODE AFTER PART 1
--]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                                 TAB CLASS                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
    local self = setmetatable({
        Window = window,
        Name = name,
        Icon = icon,
        Elements = {},
        Visible = false
    }, Tab)

    self:Initialize()
    return self
end

function Tab:Initialize()
    -- Create tab button
    self.TabButton = Utility.Create("TextButton"){
        Name = self.Name .. "Button",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Size = UDim2.new(1, -10, 0, 36),
        Font = SynthwaveX.Fonts.Semi,
        Text = "",
        AutoButtonColor = false,
        Parent = self.Window.TabContainer
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = self.TabButton
    }

    -- Tab Icon
    if self.Icon then
        self.TabIcon = Utility.Create("ImageLabel"){
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 20, 0, 20),
            Image = self.Icon,
            ImageColor3 = SynthwaveX.Theme.SecondaryText,
            Parent = self.TabButton
        }
    end

    -- Tab Label
    self.TabLabel = Utility.Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, self.Icon and 36 or 10, 0, 0),
        Size = UDim2.new(1, self.Icon and -44 or -20, 1, 0),
        Font = SynthwaveX.Fonts.Semi,
        Text = self.Name,
        TextColor3 = SynthwaveX.Theme.SecondaryText,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TabButton
    }

    -- Selection Indicator
    self.SelectionIndicator = Utility.Create("Frame"){
        Name = "SelectionIndicator",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = false,
        Parent = self.TabButton
    }

    Utility.CreateGradient(self.SelectionIndicator, 90)

    -- Content Frame
    self.ContentFrame = Utility.Create("ScrollingFrame"){
        Name = self.Name .. "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = SynthwaveX.Theme.Secondary,
        Visible = false,
        Parent = self.Window.ContentContainer
    }

    -- Add padding and layout
    Utility.Create("UIListLayout"){
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.ContentFrame
    }

    Utility.Create("UIPadding"){
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = self.ContentFrame
    }

    -- Setup tab button events
    self:SetupEvents()
end

function Tab:SetupEvents()
    -- Auto-adjust canvas size
    local function updateCanvasSize()
        local contentSize = self.ContentFrame.UIListLayout.AbsoluteContentSize
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 20)
    end

    self.ContentFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

    -- Tab button hover effect
    self.TabButton.MouseEnter:Connect(function()
        if not self.Visible then
            Utility.Tween(self.TabButton, {BackgroundColor3 = SynthwaveX.Theme.Background})
            Utility.Tween(self.TabLabel, {TextColor3 = SynthwaveX.Theme.Text})
            if self.TabIcon then
                Utility.Tween(self.TabIcon, {ImageColor3 = SynthwaveX.Theme.Text})
            end
        end
    end)

    self.TabButton.MouseLeave:Connect(function()
        if not self.Visible then
            Utility.Tween(self.TabButton, {BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground})
            Utility.Tween(self.TabLabel, {TextColor3 = SynthwaveX.Theme.SecondaryText})
            if self.TabIcon then
                Utility.Tween(self.TabIcon, {ImageColor3 = SynthwaveX.Theme.SecondaryText})
            end
        end
    end)

    -- Tab selection
    self.TabButton.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              WINDOW TAB METHODS                              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Window:CreateTab(name, icon)
    local tab = Tab.new(self, name, icon)
    table.insert(self.Tabs, tab)

    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function Window:SelectTab(tab)
    -- Deselect current tab
    if self.ActiveTab then
        self.ActiveTab.Visible = false
        self.ActiveTab.ContentFrame.Visible = false
        self.ActiveTab.SelectionIndicator.Visible = false
        
        Utility.Tween(self.ActiveTab.TabButton, {
            BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground
        })
        Utility.Tween(self.ActiveTab.TabLabel, {
            TextColor3 = SynthwaveX.Theme.SecondaryText
        })
        if self.ActiveTab.TabIcon then
            Utility.Tween(self.ActiveTab.TabIcon, {
                ImageColor3 = SynthwaveX.Theme.SecondaryText
            })
        end
    end

    -- Select new tab
    self.ActiveTab = tab
    tab.Visible = true
    tab.ContentFrame.Visible = true
    tab.SelectionIndicator.Visible = true

    -- Animate selection
    Utility.Tween(tab.TabButton, {
        BackgroundColor3 = SynthwaveX.Theme.Primary
    })
    Utility.Tween(tab.TabLabel, {
        TextColor3 = SynthwaveX.Theme.Text
    })
    if tab.TabIcon then
        Utility.Tween(tab.TabIcon, {
            ImageColor3 = SynthwaveX.Theme.Text
        })
    end

    -- Selection indicator animation
    tab.SelectionIndicator.Size = UDim2.new(0, 0, 0, 2)
    tab.SelectionIndicator.Position = UDim2.new(0.5, 0, 1, -2)
    Utility.Tween(tab.SelectionIndicator, {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2)
    })
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              SECTION CREATION                                ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateSection(name)
    local section = Utility.Create("Frame"){
        Name = name .. "Section",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = section
    }

    Utility.Create("TextLabel"){
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = SynthwaveX.Fonts.Bold,
        Text = name,
        TextColor3 = SynthwaveX.Theme.Primary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    }

    return section
end

--[[ 
    SynthwaveX UI Library v2.0
    Part 3: UI Elements Implementation
    PLACE THIS CODE AFTER PART 2
--]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              BUTTON ELEMENT                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateButton(text, callback)
    callback = callback or function() end
    
    local button = Utility.Create("Frame"){
        Name = "Button",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = button
    }

    local buttonInner = Utility.Create("TextButton"){
        Name = "ButtonInner",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Font = SynthwaveX.Fonts.Semi,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        Parent = button
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = buttonInner
    }

    Utility.CreateGradient(buttonInner, 90)

    -- Click Effect
    buttonInner.MouseButton1Down:Connect(function()
        Utility.Tween(buttonInner, {
            Position = UDim2.new(0, 3, 0, 3),
            Size = UDim2.new(1, -6, 1, -6)
        }, 0.1)
    end)

    buttonInner.MouseButton1Up:Connect(function()
        Utility.Tween(buttonInner, {
            Position = UDim2.new(0, 2, 0, 2),
            Size = UDim2.new(1, -4, 1, -4)
        }, 0.1)
        task.spawn(callback)
    end)

    return button
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              TOGGLE ELEMENT                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateToggle(text, default, callback)
    callback = callback or function() end
    local toggled = default or false
    
    local toggle = Utility.Create("Frame"){
        Name = "Toggle",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = toggle
    }

    local label = Utility.Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggle
    }

    local toggleButton = Utility.Create("TextButton"){
        Name = "ToggleButton",
        BackgroundColor3 = toggled and SynthwaveX.Theme.Success or SynthwaveX.Theme.Error,
        Position = UDim2.new(1, -46, 0.5, -10),
        Size = UDim2.new(0, 36, 0, 20),
        Text = "",
        Parent = toggle
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = toggleButton
    }

    local indicator = Utility.Create("Frame"){
        Name = "Indicator",
        BackgroundColor3 = SynthwaveX.Theme.Text,
        Position = UDim2.new(toggled and 1 or 0, toggled and -18 or 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Parent = toggleButton
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = indicator
    }

    local function updateToggle()
        Utility.Tween(toggleButton, {
            BackgroundColor3 = toggled and SynthwaveX.Theme.Success or SynthwaveX.Theme.Error
        })
        Utility.Tween(indicator, {
            Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        })
        task.spawn(callback, toggled)
    end

    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)

    return toggle
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              SLIDER ELEMENT                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateSlider(text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    callback = callback or function() end

    local slider = Utility.Create("Frame"){
        Name = "Slider",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = slider
    }

    local label = Utility.Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 0, 25),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider
    }

    local value = Utility.Create("TextLabel"){
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 40, 0, 25),
        Font = SynthwaveX.Fonts.Mono,
        Text = tostring(default),
        TextColor3 = SynthwaveX.Theme.Secondary,
        TextSize = 14,
        Parent = slider
    }

    local sliderBar = Utility.Create("Frame"){
        Name = "SliderBar",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 10, 0, 32),
        Size = UDim2.new(1, -20, 0, 4),
        Parent = slider
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBar
    }

    local sliderFill = Utility.Create("Frame"){
        Name = "SliderFill",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        Parent = sliderBar
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    }

    Utility.CreateGradient(sliderFill, 90)

    local sliderButton = Utility.Create("TextButton"){
        Name = "SliderButton",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new((default - min)/(max - min), -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        Parent = sliderBar
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = sliderButton
    }

    -- Slider Functionality
    local dragging = false

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(min + ((max - min) * pos))
        
        Utility.Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
        Utility.Tween(sliderButton, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.1)
        
        value.Text = tostring(newValue)
        task.spawn(callback, newValue)
    end

    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return slider
end

--[[ 
    SynthwaveX UI Library v2.0
    Part 4: Advanced UI Elements
    PLACE THIS CODE AFTER PART 3
--]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                             DROPDOWN ELEMENT                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateDropdown(text, options, default, callback)
    callback = callback or function() end
    options = options or {}
    default = default or options[1]
    
    local dropdown = Utility.Create("Frame"){
        Name = "Dropdown",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown
    }

    local label = Utility.Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -40, 0, 36),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    }

    local selectedValue = Utility.Create("TextLabel"){
        Name = "SelectedValue",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 36),
        Size = UDim2.new(1, -40, 0, 36),
        Font = SynthwaveX.Fonts.Semi,
        Text = default,
        TextColor3 = SynthwaveX.Theme.Secondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    }

    local toggleButton = Utility.Create("ImageButton"){
        Name = "ToggleButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0, 2),
        Size = UDim2.new(0, 32, 0, 32),
        Image = "rbxassetid://11293981898",
        ImageColor3 = SynthwaveX.Theme.Text,
        Rotation = 0,
        Parent = dropdown
    }

    local optionContainer = Utility.Create("Frame"){
        Name = "OptionContainer",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 0, 0, 72),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = dropdown
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = optionContainer
    }

    local optionList = Utility.Create("ScrollingFrame"){
        Name = "OptionList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, #options * 30),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = SynthwaveX.Theme.Primary,
        Parent = optionContainer
    }

    local UIListLayout = Utility.Create("UIListLayout"){
        Padding = UDim.new(0, 2),
        Parent = optionList
    }

    -- Dropdown State
    local isOpen = false
    local function toggleDropdown()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(1, 0, 0, math.min(#options * 30 + 72, 230)) or UDim2.new(1, 0, 0, 36)
        Utility.Tween(dropdown, {Size = targetSize}, 0.3)
        Utility.Tween(toggleButton, {Rotation = isOpen and 180 or 0}, 0.3)
    end

    toggleButton.MouseButton1Click:Connect(toggleDropdown)

    -- Create Options
    for _, option in ipairs(options) do
        local optionButton = Utility.Create("TextButton"){
            Name = option,
            BackgroundColor3 = SynthwaveX.Theme.Background,
            Size = UDim2.new(1, -4, 0, 28),
            Position = UDim2.new(0, 2, 0, 0),
            Font = SynthwaveX.Fonts.Regular,
            Text = option,
            TextColor3 = SynthwaveX.Theme.Text,
            TextSize = 14,
            Parent = optionList
        }

        Utility.Create("UICorner"){
            CornerRadius = UDim.new(0, 4),
            Parent = optionButton
        }

        optionButton.MouseEnter:Connect(function()
            Utility.Tween(optionButton, {BackgroundColor3 = SynthwaveX.Theme.Primary})
        end)

        optionButton.MouseLeave:Connect(function()
            Utility.Tween(optionButton, {BackgroundColor3 = SynthwaveX.Theme.Background})
        end)

        optionButton.MouseButton1Click:Connect(function()
            selectedValue.Text = option
            task.spawn(callback, option)
            toggleDropdown()
        end)
    end

    return dropdown
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              INPUT ELEMENT                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateInput(text, placeholder, callback)
    callback = callback or function() end
    
    local input = Utility.Create("Frame"){
        Name = "Input",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = input
    }

    local label = Utility.Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 0, 16),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = input
    }

    local inputBox = Utility.Create("TextBox"){
        Name = "InputBox",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 10, 0, 18),
        Size = UDim2.new(1, -20, 0, 24),
        Font = SynthwaveX.Fonts.Regular,
        PlaceholderText = placeholder,
        Text = "",
        TextColor3 = SynthwaveX.Theme.Text,
        PlaceholderColor3 = SynthwaveX.Theme.SecondaryText,
        TextSize = 14,
        ClearTextOnFocus = false,
        Parent = input
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = inputBox
    }

    -- Input box effects
    inputBox.Focused:Connect(function()
        Utility.Tween(inputBox, {
            BackgroundColor3 = SynthwaveX.Theme.Primary
        }, 0.2)
    end)

    inputBox.FocusLost:Connect(function(enterPressed)
        Utility.Tween(inputBox, {
            BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground
        }, 0.2)
        
        if enterPressed then
            task.spawn(callback, inputBox.Text)
        end
    end)

    return input
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                            KEYBIND ELEMENT                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Tab:CreateKeybind(text, default, callback)
    callback = callback or function() end
    default = default or "None"
    
    local keybind = Utility.Create("Frame"){
        Name = "Keybind",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = keybind
    }

    local label = Utility.Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -90, 1, 0),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybind
    }

    local bindButton = Utility.Create("TextButton"){
        Name = "BindButton",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(1, -80, 0.5, -15),
        Size = UDim2.new(0, 70, 0, 30),
        Font = SynthwaveX.Fonts.Semi,
        Text = default,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        Parent = keybind
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = bindButton
    }

    -- Keybind Logic
    local waiting = false
    local currentKey = default

    bindButton.MouseButton1Click:Connect(function()
        waiting = true
        bindButton.Text = "..."
        
        Utility.Tween(bindButton, {
            BackgroundColor3 = SynthwaveX.Theme.Primary
        }, 0.2)
    end)

    Services.UserInputService.InputBegan:Connect(function(input)
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            waiting = false
            currentKey = input.KeyCode.Name
            bindButton.Text = currentKey
            
            Utility.Tween(bindButton, {
                BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground
            }, 0.2)
            
            task.spawn(callback, currentKey)
        end
    end)

    return keybind
end

--[[ 
    SynthwaveX UI Library v2.0
    Part 5: Notifications and Mobile Support
    PLACE THIS CODE AFTER PART 4
--]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                           NOTIFICATION SYSTEM                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

SynthwaveX.NotificationSystem = {
    Notifications = {},
    MaxNotifications = 5,
    Padding = 10,
    Height = 80
}

function SynthwaveX:Notify(title, message, duration, type)
    duration = duration or 3
    type = type or "Info" -- Info, Success, Warning, Error

    local colors = {
        Info = SynthwaveX.Theme.Primary,
        Success = SynthwaveX.Theme.Success,
        Warning = SynthwaveX.Theme.Accent,
        Error = SynthwaveX.Theme.Error
    }

    -- Remove old notifications if we exceed the maximum
    while #self.NotificationSystem.Notifications >= self.NotificationSystem.MaxNotifications do
        local oldestNotification = self.NotificationSystem.Notifications[1]
        if oldestNotification and oldestNotification.Instance then
            oldestNotification.Instance:Destroy()
        end
        table.remove(self.NotificationSystem.Notifications, 1)
    end

    local notification = Utility.Create("Frame"){
        Name = "Notification",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Position = UDim2.new(1, 0, 1, -((#self.NotificationSystem.Notifications + 1) * 
            (self.NotificationSystem.Height + self.NotificationSystem.Padding))),
        Size = UDim2.new(0, 300, 0, self.NotificationSystem.Height),
        Parent = self.ScreenGui
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    }

    Utility.CreateShadow(notification)

    local accent = Utility.Create("Frame"){
        Name = "Accent",
        BackgroundColor3 = colors[type],
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notification
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = accent
    }

    local icon = Utility.Create("ImageLabel"){
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(0, 24, 0, 24),
        Image = SynthwaveX.Icons.Notification,
        ImageColor3 = colors[type],
        Parent = notification
    }

    local titleLabel = Utility.Create("TextLabel"){
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 8),
        Size = UDim2.new(1, -60, 0, 20),
        Font = SynthwaveX.Fonts.Bold,
        Text = title,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    }

    local messageLabel = Utility.Create("TextLabel"){
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 32),
        Size = UDim2.new(1, -60, 0, 40),
        Font = SynthwaveX.Fonts.Regular,
        Text = message,
        TextColor3 = SynthwaveX.Theme.SecondaryText,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    }

    local progress = Utility.Create("Frame"){
        Name = "Progress",
        BackgroundColor3 = colors[type],
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = notification
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = progress
    }

    -- Add to notifications table
    table.insert(self.NotificationSystem.Notifications, {
        Instance = notification,
        StartTime = tick()
    })

    -- Animate in
    notification.Position = UDim2.new(1, 0, notification.Position.Y.Scale, notification.Position.Y.Offset)
    Utility.Tween(notification, {
        Position = UDim2.new(1, -330, notification.Position.Y.Scale, notification.Position.Y.Offset)
    }, 0.3)

    -- Progress bar animation
    Utility.Tween(progress, {
        Size = UDim2.new(0, 0, 0, 2)
    }, duration)

    -- Remove after duration
    task.delay(duration, function()
        -- Find and remove from notifications table
        for i, notif in ipairs(self.NotificationSystem.Notifications) do
            if notif.Instance == notification then
                table.remove(self.NotificationSystem.Notifications, i)
                break
            end
        end

        -- Animate out
        Utility.Tween(notification, {
            Position = UDim2.new(1, 0, notification.Position.Y.Scale, notification.Position.Y.Offset)
        }, 0.3).Completed:Connect(function()
            notification:Destroy()
        end)

        -- Adjust positions of remaining notifications
        for i, notif in ipairs(self.NotificationSystem.Notifications) do
            Utility.Tween(notif.Instance, {
                Position = UDim2.new(1, -330, 1, -(i * (self.NotificationSystem.Height + self.NotificationSystem.Padding)))
            }, 0.3)
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                              MOBILE SUPPORT                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

function Window:InitializeMobileSupport()
    if not Services.UserInputService.TouchEnabled then return end

    -- Create mobile toggle button
    self.MobileToggle = Utility.Create("ImageButton"){
        Name = "MobileToggle",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0, 20, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Image = "rbxassetid://11293982267",
        Parent = self.ScreenGui
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = self.MobileToggle
    }

    -- Create mobile navigation bar
    self.MobileNav = Utility.Create("Frame"){
        Name = "MobileNav",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 50),
        Visible = false,
        Parent = self.MainFrame
    }

    Utility.Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = self.MobileNav
    }

    -- Mobile tab container
    self.MobileTabContainer = Utility.Create("ScrollingFrame"){
        Name = "MobileTabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = self.MobileNav
    }

    Utility.Create("UIListLayout"){
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        Parent = self.MobileTabContainer
    }

    -- Mobile UI toggle
    self.MobileToggle.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end)

    -- Update layout for mobile
    self:UpdateMobileLayout()
end

function Window:UpdateMobileLayout()
    if not Services.UserInputService.TouchEnabled then return end

    -- Adjust main frame for mobile
    self.MainFrame.Position = UDim2.new(0, 0, 0, 0)
    self.MainFrame.Size = UDim2.new(1, 0, 1, 0)

    -- Show mobile navigation
    if self.MobileNav then
        self.MobileNav.Visible = true
    end

    -- Adjust content container for mobile
    if self.ContentContainer then
        self.ContentContainer.Position = UDim2.new(0, 10, 0, 90)
        self.ContentContainer.Size = UDim2.new(1, -20, 1, -100)
    end
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                           FINAL INITIALIZATION                                ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

-- Update Window initialization to include mobile support
local oldWindowInitialize = Window.Initialize
function Window:Initialize()
    oldWindowInitialize(self)
    self:InitializeMobileSupport()
end

-- Add automatic cleanup
function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    -- Remove from windows table
    for i, window in ipairs(SynthwaveX.Windows) do
        if window == self then
            table.remove(SynthwaveX.Windows, i)
            break
        end
    end
end

-- Return the library
return SynthwaveX
