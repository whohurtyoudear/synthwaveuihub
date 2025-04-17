-- SynthwaveX UI Library v2.0
-- Part 1: Core Framework and Initialization

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

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Viewport = workspace.CurrentCamera.ViewportSize
local Registry = {}
local RegistryMap = {}

-- Utility Functions
local function Create(instanceType)
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

local function Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateGradient(parent, rotation)
    local gradient = Create("UIGradient"){
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SynthwaveX.Theme.Gradient1),
            ColorSequenceKeypoint.new(1, SynthwaveX.Theme.Gradient2)
        }),
        Rotation = rotation or 45,
        Parent = parent
    }
    return gradient
end

local function CreateStroke(parent, color, thickness)
    local stroke = Create("UIStroke"){
        Color = color or SynthwaveX.Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    }
    return stroke
end

local function CreateShadow(parent, size)
    local shadow = Create("ImageLabel"){
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
    return shadow
end

-- Window Class
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

    -- Create main GUI elements
    self.ScreenGui = Create("ScreenGui"){
        Name = "SynthwaveX",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    }

    self.MainFrame = Create("Frame"){
        Name = "MainFrame",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        Parent = self.ScreenGui
    }

    -- Add corner and shadow
    Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = self.MainFrame
    }

    CreateShadow(self.MainFrame, 35)

    -- Create top bar with gradient
    self.TopBar = Create("Frame"){
        Name = "TopBar",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.MainFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = self.TopBar
    }

    CreateGradient(self.TopBar, 90)

    -- Title with icon
    self.TitleIcon = Create("ImageLabel"){
        Name = "TitleIcon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://11293982267", -- Replace with your icon
        Parent = self.TopBar
    }

    self.TitleLabel = Create("TextLabel"){
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(0.5, -30, 1, 0),
        Font = SynthwaveX.Fonts.Bold,
        Text = title,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    }

    -- Initialize the rest of the UI
    self:InitializeControls()
    self:EnableDragging()

    return self
end

-- Add this at the end of Part 1
_G.SynthwaveXLoaded = true
return SynthwaveX

-- Part 2: Tab System and Navigation

-- Tab Class
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

    -- Create tab button
    self.TabButton = Create("TextButton"){
        Name = name .. "Button",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Size = UDim2.new(1, -10, 0, 36),
        Font = SynthwaveX.Fonts.Semi,
        Text = "",
        AutoButtonColor = false,
        Parent = window.TabContainer
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = self.TabButton
    }

    -- Tab Icon
    self.TabIcon = Create("ImageLabel"){
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        Image = icon or "",
        ImageColor3 = SynthwaveX.Theme.SecondaryText,
        Parent = self.TabButton
    }

    -- Tab Label
    self.TabLabel = Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = SynthwaveX.Fonts.Semi,
        Text = name,
        TextColor3 = SynthwaveX.Theme.SecondaryText,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TabButton
    }

    -- Selection Indicator
    self.SelectionIndicator = Create("Frame"){
        Name = "SelectionIndicator",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = false,
        Parent = self.TabButton
    }

    CreateGradient(self.SelectionIndicator, 90)

    -- Content Frame
    self.ContentFrame = Create("ScrollingFrame"){
        Name = name .. "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = SynthwaveX.Theme.Secondary,
        Visible = false,
        Parent = window.ContentContainer
    }

    -- Auto-size content
    local UIListLayout = Create("UIListLayout"){
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.ContentFrame
    }

    local UIPadding = Create("UIPadding"){
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = self.ContentFrame
    }

    -- Auto-adjust canvas size
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Tab button hover effect
    self.TabButton.MouseEnter:Connect(function()
        if not self.Visible then
            Tween(self.TabButton, {BackgroundColor3 = SynthwaveX.Theme.Background})
            Tween(self.TabLabel, {TextColor3 = SynthwaveX.Theme.Text})
            Tween(self.TabIcon, {ImageColor3 = SynthwaveX.Theme.Text})
        end
    end)

    self.TabButton.MouseLeave:Connect(function()
        if not self.Visible then
            Tween(self.TabButton, {BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground})
            Tween(self.TabLabel, {TextColor3 = SynthwaveX.Theme.SecondaryText})
            Tween(self.TabIcon, {ImageColor3 = SynthwaveX.Theme.SecondaryText})
        end
    end)

    -- Tab selection
    self.TabButton.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)

    return self
end

-- Window Tab Methods
function Window:InitializeTabs()
    -- Tab Container
    self.TabContainer = Create("ScrollingFrame"){
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 150, 1, -50),
        ScrollBarThickness = 0,
        Parent = self.MainFrame
    }

    local UIListLayout = Create("UIListLayout"){
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabContainer
    }

    -- Content Container
    self.ContentContainer = Create("Frame"){
        Name = "ContentContainer",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 170, 0, 40),
        Size = UDim2.new(1, -180, 1, -50),
        Parent = self.MainFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = self.ContentContainer
    }
end

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
        
        Tween(self.ActiveTab.TabButton, {BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground})
        Tween(self.ActiveTab.TabLabel, {TextColor3 = SynthwaveX.Theme.SecondaryText})
        Tween(self.ActiveTab.TabIcon, {ImageColor3 = SynthwaveX.Theme.SecondaryText})
    end

    -- Select new tab
    self.ActiveTab = tab
    tab.Visible = true
    tab.ContentFrame.Visible = true
    tab.SelectionIndicator.Visible = true

    Tween(tab.TabButton, {BackgroundColor3 = SynthwaveX.Theme.Primary})
    Tween(tab.TabLabel, {TextColor3 = SynthwaveX.Theme.Text})
    Tween(tab.TabIcon, {ImageColor3 = SynthwaveX.Theme.Text})

    -- Animation
    tab.SelectionIndicator.Size = UDim2.new(0, 0, 0, 2)
    tab.SelectionIndicator.Position = UDim2.new(0.5, 0, 1, -2)
    Tween(tab.SelectionIndicator, {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2)
    })
end
-- Part 3: UI Elements

-- Section Class
function Tab:CreateSection(name)
    local section = Create("Frame"){
        Name = name .. "Section",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = section
    }

    Create("TextLabel"){
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

-- Button Element
function Tab:CreateButton(text, callback)
    callback = callback or function() end
    
    local button = Create("Frame"){
        Name = "Button",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = button
    }

    local buttonInner = Create("TextButton"){
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

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = buttonInner
    }

    CreateGradient(buttonInner, 90)

    -- Click Effect
    buttonInner.MouseButton1Down:Connect(function()
        Tween(buttonInner, {
            Position = UDim2.new(0, 3, 0, 3),
            Size = UDim2.new(1, -6, 1, -6)
        }, 0.1)
    end)

    buttonInner.MouseButton1Up:Connect(function()
        Tween(buttonInner, {
            Position = UDim2.new(0, 2, 0, 2),
            Size = UDim2.new(1, -4, 1, -4)
        }, 0.1)
        callback()
    end)

    return button
end

-- Toggle Element
function Tab:CreateToggle(text, default, callback)
    callback = callback or function() end
    local toggled = default or false
    
    local toggle = Create("Frame"){
        Name = "Toggle",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = toggle
    }

    local label = Create("TextLabel"){
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

    local toggleButton = Create("TextButton"){
        Name = "ToggleButton",
        BackgroundColor3 = toggled and SynthwaveX.Theme.Success or SynthwaveX.Theme.Error,
        Position = UDim2.new(1, -46, 0.5, -10),
        Size = UDim2.new(0, 36, 0, 20),
        Text = "",
        Parent = toggle
    }

    Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = toggleButton
    }

    local indicator = Create("Frame"){
        Name = "Indicator",
        BackgroundColor3 = SynthwaveX.Theme.Text,
        Position = UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Parent = toggleButton
    }

    Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = indicator
    }

    -- Toggle Animation
    local function updateToggle()
        Tween(toggleButton, {
            BackgroundColor3 = toggled and SynthwaveX.Theme.Success or SynthwaveX.Theme.Error
        })
        Tween(indicator, {
            Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        })
        callback(toggled)
    end

    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)

    return toggle
end

-- Slider Element
function Tab:CreateSlider(text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    callback = callback or function() end

    local slider = Create("Frame"){
        Name = "Slider",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = slider
    }

    local label = Create("TextLabel"){
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

    local value = Create("TextLabel"){
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

    local sliderBar = Create("Frame"){
        Name = "SliderBar",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 10, 0, 32),
        Size = UDim2.new(1, -20, 0, 4),
        Parent = slider
    }

    Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBar
    }

    local sliderFill = Create("Frame"){
        Name = "SliderFill",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        Parent = sliderBar
    }

    Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    }

    CreateGradient(sliderFill, 90)

    local sliderButton = Create("TextButton"){
        Name = "SliderButton",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new((default - min)/(max - min), -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        Parent = sliderBar
    }

    Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = sliderButton
    }

    -- Slider Functionality
    local dragging = false

    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local newValue = math.floor(min + ((max - min) * pos))
            
            Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
            Tween(sliderButton, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.1)
            
            value.Text = tostring(newValue)
            callback(newValue)
        end
    end)

    return slider
end
-- Part 4: Advanced UI Elements and Notifications

-- Dropdown Element
function Tab:CreateDropdown(text, options, default, callback)
    callback = callback or function() end
    options = options or {}
    default = default or options[1]
    
    local dropdown = Create("Frame"){
        Name = "Dropdown",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown
    }

    local label = Create("TextLabel"){
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

    local selectedValue = Create("TextLabel"){
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

    local toggleButton = Create("ImageButton"){
        Name = "ToggleButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0, 2),
        Size = UDim2.new(0, 32, 0, 32),
        Image = "rbxassetid://11293981898",
        ImageColor3 = SynthwaveX.Theme.Text,
        Rotation = 0,
        Parent = dropdown
    }

    local optionContainer = Create("Frame"){
        Name = "OptionContainer",
        BackgroundColor3 = SynthwaveX.Theme.SecondaryBackground,
        Position = UDim2.new(0, 0, 0, 72),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = dropdown
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = optionContainer
    }

    local optionList = Create("ScrollingFrame"){
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

    local UIListLayout = Create("UIListLayout"){
        Padding = UDim.new(0, 2),
        Parent = optionList
    }

    -- Dropdown State
    local isOpen = false
    local function toggleDropdown()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(1, 0, 0, math.min(#options * 30 + 72, 230)) or UDim2.new(1, 0, 0, 36)
        Tween(dropdown, {Size = targetSize}, 0.3)
        Tween(toggleButton, {Rotation = isOpen and 180 or 0}, 0.3)
    end

    toggleButton.MouseButton1Click:Connect(toggleDropdown)

    -- Create Options
    for _, option in ipairs(options) do
        local optionButton = Create("TextButton"){
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

        Create("UICorner"){
            CornerRadius = UDim.new(0, 4),
            Parent = optionButton
        }

        optionButton.MouseEnter:Connect(function()
            Tween(optionButton, {BackgroundColor3 = SynthwaveX.Theme.Primary})
        end)

        optionButton.MouseLeave:Connect(function()
            Tween(optionButton, {BackgroundColor3 = SynthwaveX.Theme.Background})
        end)

        optionButton.MouseButton1Click:Connect(function()
            selectedValue.Text = option
            callback(option)
            toggleDropdown()
        end)
    end

    return dropdown
end

-- Input Field Element
function Tab:CreateInput(text, placeholder, callback)
    callback = callback or function() end
    
    local input = Create("Frame"){
        Name = "Input",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = input
    }

    local label = Create("TextLabel"){
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

    local inputBox = Create("TextBox"){
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
        Parent = input
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = inputBox
    }

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(inputBox.Text)
        end
    end)

    return input
end

-- Notification System
SynthwaveX.Notifications = {
    Active = {},
    Queue = {}
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

    local notification = Create("Frame"){
        Name = "Notification",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Position = UDim2.new(1, -330, 1, -100),
        Size = UDim2.new(0, 300, 0, 80),
        Parent = self.ScreenGui
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    }

    CreateShadow(notification)

    local accent = Create("Frame"){
        Name = "Accent",
        BackgroundColor3 = colors[type],
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notification
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = accent
    }

    local icon = Create("ImageLabel"){
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(0, 24, 0, 24),
        Image = SynthwaveX.Icons.Notification,
        ImageColor3 = colors[type],
        Parent = notification
    }

    local titleLabel = Create("TextLabel"){
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

    local messageLabel = Create("TextLabel"){
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

    local progress = Create("Frame"){
        Name = "Progress",
        BackgroundColor3 = colors[type],
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = notification
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = progress
    }

    -- Animation
    notification.Position = UDim2.new(1, 0, 1, -100)
    Tween(notification, {Position = UDim2.new(1, -330, 1, -100)}, 0.3)
    Tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, duration)

    task.delay(duration, function()
        Tween(notification, {Position = UDim2.new(1, 0, 1, -100)}, 0.3).Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end
-- Part 5: Mobile Support, Keybinds, and Additional Features

-- Keybind Element
function Tab:CreateKeybind(text, default, callback)
    callback = callback or function() end
    default = default or "None"
    
    local keybind = Create("Frame"){
        Name = "Keybind",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = keybind
    }

    local label = Create("TextLabel"){
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

    local bindButton = Create("TextButton"){
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

    Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = bindButton
    }

    -- Keybind Logic
    local waiting = false
    local currentKey = default

    bindButton.MouseButton1Click:Connect(function()
        waiting = true
        bindButton.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            waiting = false
            currentKey = input.KeyCode.Name
            bindButton.Text = currentKey
            callback(currentKey)
        end
    end)

    return keybind
end

-- Color Picker Element
function Tab:CreateColorPicker(text, default, callback)
    callback = callback or function() end
    default = default or Color3.fromRGB(255, 255, 255)
    
    local colorPicker = Create("Frame"){
        Name = "ColorPicker",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 36),
        ClipsDescendants = true,
        Parent = self.ContentFrame
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = colorPicker
    }

    local label = Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorPicker
    }

    local preview = Create("Frame"){
        Name = "Preview",
        BackgroundColor3 = default,
        Position = UDim2.new(1, -46, 0.5, -15),
        Size = UDim2.new(0, 36, 0, 30),
        Parent = colorPicker
    }

    Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = preview
    }

    -- Mobile Support
    local function AddMobileSupport()
        if not UserInputService.TouchEnabled then return end

        -- Create mobile toggle button
        local mobileToggle = Create("ImageButton"){
            Name = "MobileToggle",
            BackgroundColor3 = SynthwaveX.Theme.Primary,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 20, 0.5, -20),
            Size = UDim2.new(0, 40, 0, 40),
            Image = "rbxassetid://11293982267",
            Parent = SynthwaveX.ScreenGui
        }

        Create("UICorner"){
            CornerRadius = UDim.new(1, 0),
            Parent = mobileToggle
        }

        -- Mobile navigation
        local mobileNav = Create("Frame"){
            Name = "MobileNav",
            BackgroundColor3 = SynthwaveX.Theme.Background,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 50),
            Visible = false,
            Parent = SynthwaveX.MainFrame
        }

        Create("UICorner"){
            CornerRadius = UDim.new(0, 6),
            Parent = mobileNav
        }

        -- Mobile tab buttons
        local mobileTabContainer = Create("ScrollingFrame"){
            Name = "MobileTabContainer",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 40),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X,
            Parent = mobileNav
        }

        local UIListLayout = Create("UIListLayout"){
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 5),
            Parent = mobileTabContainer
        }

        -- Update mobile layout
        local function UpdateMobileLayout()
            SynthwaveX.MainFrame.Position = UDim2.new(0, 0, 0, 0)
            SynthwaveX.MainFrame.Size = UDim2.new(1, 0, 1, 0)
        end

        -- Toggle mobile UI
        mobileToggle.MouseButton1Click:Connect(function()
            SynthwaveX.MainFrame.Visible = not SynthwaveX.MainFrame.Visible
        end)

        -- Apply mobile layout
        if UserInputService.TouchEnabled then
            UpdateMobileLayout()
            mobileNav.Visible = true
        end
    end

    -- Context Menu
    function SynthwaveX:CreateContextMenu(items)
        local contextMenu = Create("Frame"){
            Name = "ContextMenu",
            BackgroundColor3 = SynthwaveX.Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 150, 0, #items * 30),
            Visible = false,
            Parent = self.ScreenGui
        }

        Create("UICorner"){
            CornerRadius = UDim.new(0, 6),
            Parent = contextMenu
        }

        CreateShadow(contextMenu)

        for i, item in ipairs(items) do
            local button = Create("TextButton"){
                Name = item.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, (i-1) * 30),
                Size = UDim2.new(1, 0, 0, 30),
                Font = SynthwaveX.Fonts.Regular,
                Text = item.Text,
                TextColor3 = SynthwaveX.Theme.Text,
                TextSize = 14,
                Parent = contextMenu
            }

            button.MouseButton1Click:Connect(function()
                contextMenu.Visible = false
                item.Callback()
            end)

            button.MouseEnter:Connect(function()
                Tween(button, {BackgroundTransparency = 0.9})
            end)

            button.MouseLeave:Connect(function()
                Tween(button, {BackgroundTransparency = 1})
            end)
        end

        return contextMenu
    end

    -- Save/Load Settings
    function SynthwaveX:SaveSettings(name)
        local settings = {}
        -- Implement your save logic here
        return settings
    end

    function SynthwaveX:LoadSettings(name)
        -- Implement your load logic here
    end

    -- Initialize
    AddMobileSupport()

    -- Return Library
    return SynthwaveX
end
