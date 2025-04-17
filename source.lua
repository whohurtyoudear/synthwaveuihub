-- SynthwaveX UI Library
-- Part 1: Core Framework and Initialization

local SynthwaveX = {
    Version = "1.0.0",
    Windows = {},
    Theme = {
        Primary = Color3.fromRGB(255, 65, 125),   -- Hot pink
        Secondary = Color3.fromRGB(0, 255, 255),  -- Cyan
        Background = Color3.fromRGB(20, 20, 35),  -- Dark blue-gray
        Text = Color3.fromRGB(255, 255, 255),     -- White
        Border = Color3.fromRGB(123, 47, 189),    -- Purple
        Accent = Color3.fromRGB(255, 122, 0),     -- Orange
        Success = Color3.fromRGB(46, 255, 119),   -- Green
        Error = Color3.fromRGB(255, 44, 44),      -- Red
    },
    Fonts = {
        Regular = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
        Semi = Enum.Font.GothamSemibold
    }
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Viewport = workspace.CurrentCamera.ViewportSize

-- Utility Functions
local function Create(instanceType)
    return function(properties)
        local instance = Instance.new(instanceType)
        for property, value in pairs(properties) do
            instance[property] = value
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

local function Ripple(button)
    local ripple = Create("Frame"){
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button
    }
    
    local corner = Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    }
    
    Tween(ripple, {
        Size = UDim2.new(1.5, 0, 1.5, 0),
        BackgroundTransparency = 1
    }, 0.5)
    
    game:GetService("Debris"):AddItem(ripple, 0.5)
end

-- Main Window Creator
function SynthwaveX:CreateWindow(title)
    local Window = {}
    
    -- Main GUI Container
    local ScreenGui = Create("ScreenGui"){
        Name = "SynthwaveX",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    }
    
    -- Main Frame
    local MainFrame = Create("Frame"){
        Name = "MainFrame",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        Parent = ScreenGui
    }
    
    local MainCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    }
    
    -- Top Bar
    local TopBar = Create("Frame"){
        Name = "TopBar",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainFrame
    }
    
    local TopBarCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 8),
        Parent = TopBar
    }
    
    -- Title
    local TitleLabel = Create("TextLabel"){
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = SynthwaveX.Fonts.Bold,
        Text = title,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    }
-- Part 2: Core Controls and Tab System

-- Control Buttons
local ControlButtons = Create("Frame"){
    Name = "ControlButtons",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -90, 0, 0),
    Size = UDim2.new(0, 90, 1, 0),
    Parent = TopBar
}

local MinimizeButton = Create("TextButton"){
    Name = "Minimize",
    BackgroundColor3 = SynthwaveX.Theme.Secondary,
    Position = UDim2.new(0, 5, 0.2, 0),
    Size = UDim2.new(0, 20, 0, 20),
    Text = "",
    Parent = ControlButtons
}

local CloseButton = Create("TextButton"){
    Name = "Close",
    BackgroundColor3 = SynthwaveX.Theme.Error,
    Position = UDim2.new(1, -25, 0.2, 0),
    Size = UDim2.new(0, 20, 0, 20),
    Text = "",
    Parent = ControlButtons
}

Create("UICorner"){
    CornerRadius = UDim.new(0, 4),
    Parent = MinimizeButton
}

Create("UICorner"){
    CornerRadius = UDim.new(0, 4),
    Parent = CloseButton
}

-- Content Container
local ContentContainer = Create("Frame"){
    Name = "ContentContainer",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 35),
    Size = UDim2.new(1, 0, 1, -35),
    Parent = MainFrame
}

-- Tab System
local TabList = Create("Frame"){
    Name = "TabList",
    BackgroundColor3 = SynthwaveX.Theme.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 5, 0, 5),
    Size = UDim2.new(0, 150, 1, -10),
    Parent = ContentContainer
}

local TabListCorner = Create("UICorner"){
    CornerRadius = UDim.new(0, 6),
    Parent = TabList
}

local TabContainer = Create("ScrollingFrame"){
    Name = "TabContainer",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 5, 0, 5),
    Size = UDim2.new(1, -10, 1, -10),
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = SynthwaveX.Theme.Secondary,
    Parent = TabList
}

local TabListLayout = Create("UIListLayout"){
    Padding = UDim.new(0, 5),
    Parent = TabContainer
}

-- Content Area
local ContentArea = Create("Frame"){
    Name = "ContentArea",
    BackgroundColor3 = SynthwaveX.Theme.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 160, 0, 5),
    Size = UDim2.new(1, -165, 1, -10),
    Parent = ContentContainer
}

local ContentAreaCorner = Create("UICorner"){
    CornerRadius = UDim.new(0, 6),
    Parent = ContentArea
}

-- Player Info Section
local PlayerInfo = Create("Frame"){
    Name = "PlayerInfo",
    BackgroundColor3 = SynthwaveX.Theme.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 5, 0, 5),
    Size = UDim2.new(1, -10, 0, 100),
    Parent = ContentArea
}

local PlayerInfoCorner = Create("UICorner"){
    CornerRadius = UDim.new(0, 6),
    Parent = PlayerInfo
}

local PlayerAvatar = Create("ImageLabel"){
    Name = "PlayerAvatar",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 10),
    Size = UDim2.new(0, 80, 0, 80),
    Image = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size80x80
    )
}

local PlayerAvatarCorner = Create("UICorner"){
    CornerRadius = UDim.new(0, 40),
    Parent = PlayerAvatar
}

local PlayerInfoText = Create("Frame"){
    Name = "PlayerInfoText",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 100, 0, 10),
    Size = UDim2.new(1, -110, 1, -20),
    Parent = PlayerInfo
}

local PlayerName = Create("TextLabel"){
    Name = "PlayerName",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = SynthwaveX.Fonts.Bold,
    Text = LocalPlayer.DisplayName,
    TextColor3 = SynthwaveX.Theme.Text,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = PlayerInfoText
}

local GameInfo = Create("TextLabel"){
    Name = "GameInfo",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 25),
    Size = UDim2.new(1, 0, 0, 20),
    Font = SynthwaveX.Fonts.Regular,
    Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    TextColor3 = SynthwaveX.Theme.Secondary,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = PlayerInfoText
}

local ServerInfo = Create("TextLabel"){
    Name = "ServerInfo",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 50),
    Size = UDim2.new(1, 0, 0, 20),
    Font = SynthwaveX.Fonts.Regular,
    Text = string.format("Server: %d/%d players", #Players:GetPlayers(), Players.MaxPlayers),
    TextColor3 = SynthwaveX.Theme.Secondary,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = PlayerInfoText
}

-- Tab Creation Function
function Window:CreateTab(name)
    local Tab = {}
    
    local TabButton = Create("TextButton"){
        Name = name,
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 30),
        Font = SynthwaveX.Fonts.Semi,
        Text = name,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        Parent = TabContainer
    }

    local TabButtonCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = TabButton
    }
-- Part 3: UI Elements and Interactions

-- Element Container
local function CreateElementContainer(parent)
    local Container = Create("Frame"){
        Name = "ElementContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 110),
        Size = UDim2.new(1, -10, 1, -115),
        Parent = parent
    }
    
    local ScrollingFrame = Create("ScrollingFrame"){
        Name = "ScrollingElements",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = SynthwaveX.Theme.Secondary,
        Parent = Container
    }
    
    local UIListLayout = Create("UIListLayout"){
        Padding = UDim.new(0, 5),
        Parent = ScrollingFrame
    }
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
    end)
    
    return ScrollingFrame
end

-- Button Creation
function Tab:CreateButton(text, callback)
    callback = callback or function() end
    
    local Button = Create("TextButton"){
        Name = "Button",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 35),
        Font = SynthwaveX.Fonts.Semi,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        Parent = self.Container
    }
    
    local ButtonCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = Button
    }
    
    Button.MouseButton1Click:Connect(function()
        Ripple(Button)
        callback()
    end)
    
    return Button
end

-- Toggle Creation
function Tab:CreateToggle(text, default, callback)
    callback = callback or function() end
    local toggled = default or false
    
    local Toggle = Create("Frame"){
        Name = "Toggle",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 35),
        Parent = self.Container
    }
    
    local ToggleCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = Toggle
    }
    
    local ToggleButton = Create("TextButton"){
        Name = "ToggleButton",
        BackgroundColor3 = toggled and SynthwaveX.Theme.Success or SynthwaveX.Theme.Error,
        Position = UDim2.new(0, 5, 0.5, -10),
        Size = UDim2.new(0, 40, 0, 20),
        Text = "",
        Parent = Toggle
    }
    
    local ToggleButtonCorner = Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = ToggleButton
    }
    
    local Indicator = Create("Frame"){
        Name = "Indicator",
        BackgroundColor3 = SynthwaveX.Theme.Text,
        Position = UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Parent = ToggleButton
    }
    
    local IndicatorCorner = Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = Indicator
    }
    
    local Label = Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 55, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Toggle
    }
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        Tween(Indicator, {
            Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        })
        Tween(ToggleButton, {
            BackgroundColor3 = toggled and SynthwaveX.Theme.Success or SynthwaveX.Theme.Error
        })
        callback(toggled)
    end)
    
    return Toggle
end

-- Slider Creation
function Tab:CreateSlider(text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    callback = callback or function() end
    
    local Slider = Create("Frame"){
        Name = "Slider",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = self.Container
    }
    
    local SliderCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = Slider
    }
    
    local Label = Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 0, 20),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Slider
    }
    
    local Value = Create("TextLabel"){
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -45, 0, 5),
        Size = UDim2.new(0, 40, 0, 20),
        Font = SynthwaveX.Fonts.Regular,
        Text = tostring(default),
        TextColor3 = SynthwaveX.Theme.Secondary,
        TextSize = 14,
        Parent = Slider
    }
    
    local SliderBar = Create("Frame"){
        Name = "SliderBar",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new(0, 5, 0, 35),
        Size = UDim2.new(1, -10, 0, 4),
        Parent = Slider
    }
    
    local SliderBarCorner = Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = SliderBar
    }
    
    local SliderFill = Create("Frame"){
        Name = "SliderFill",
        BackgroundColor3 = SynthwaveX.Theme.Secondary,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        Parent = SliderBar
    }
    
    local SliderFillCorner = Create("UICorner"){
        CornerRadius = UDim.new(1, 0),
        Parent = SliderFill
    }
-- Part 4: Dropdowns, Notifications, and Dragging

-- Dropdown Creation
function Tab:CreateDropdown(text, options, default, callback)
    callback = callback or function() end
    options = options or {}
    default = default or options[1]
    
    local Dropdown = Create("Frame"){
        Name = "Dropdown",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Size = UDim2.new(1, 0, 0, 35),
        ClipsDescendants = true,
        Parent = self.Container
    }
    
    local DropdownCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 4),
        Parent = Dropdown
    }
    
    local Label = Create("TextLabel"){
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(1, -35, 0, 35),
        Font = SynthwaveX.Fonts.Regular,
        Text = text,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Dropdown
    }
    
    local SelectedValue = Create("TextLabel"){
        Name = "SelectedValue",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -130, 0, 0),
        Size = UDim2.new(0, 100, 0, 35),
        Font = SynthwaveX.Fonts.Regular,
        Text = default,
        TextColor3 = SynthwaveX.Theme.Secondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Dropdown
    }
    
    local ToggleButton = Create("TextButton"){
        Name = "ToggleButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Text = "▼",
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        Parent = Dropdown
    }
    
    local OptionList = Create("Frame"){
        Name = "OptionList",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, #options * 25),
        Visible = false,
        Parent = Dropdown
    }
    
    local OptionListLayout = Create("UIListLayout"){
        Parent = OptionList
    }
    
    local isOpen = false
    local function ToggleDropdown()
        isOpen = not isOpen
        local newSize = isOpen and UDim2.new(1, 0, 0, 35 + (#options * 25)) or UDim2.new(1, 0, 0, 35)
        Tween(Dropdown, {Size = newSize})
        OptionList.Visible = isOpen
        ToggleButton.Text = isOpen and "▲" or "▼"
    end
    
    ToggleButton.MouseButton1Click:Connect(ToggleDropdown)
    
    for i, option in ipairs(options) do
        local OptionButton = Create("TextButton"){
            Name = option,
            BackgroundColor3 = SynthwaveX.Theme.Background,
            Size = UDim2.new(1, 0, 0, 25),
            Font = SynthwaveX.Fonts.Regular,
            Text = option,
            TextColor3 = SynthwaveX.Theme.Text,
            TextSize = 14,
            Parent = OptionList
        }
        
        OptionButton.MouseButton1Click:Connect(function()
            SelectedValue.Text = option
            callback(option)
            ToggleDropdown()
        end)
        
        OptionButton.MouseEnter:Connect(function()
            Tween(OptionButton, {BackgroundColor3 = SynthwaveX.Theme.Primary})
        end)
        
        OptionButton.MouseLeave:Connect(function()
            Tween(OptionButton, {BackgroundColor3 = SynthwaveX.Theme.Background})
        end)
    end
    
    return Dropdown
end

-- Notification System
SynthwaveX.Notifications = {}

function SynthwaveX:Notify(title, message, duration)
    duration = duration or 3
    
    local Notification = Create("Frame"){
        Name = "Notification",
        BackgroundColor3 = SynthwaveX.Theme.Background,
        Position = UDim2.new(1, -330, 1, -100),
        Size = UDim2.new(0, 300, 0, 80),
        Parent = ScreenGui
    }
    
    local NotificationCorner = Create("UICorner"){
        CornerRadius = UDim.new(0, 6),
        Parent = Notification
    }
    
    local Title = Create("TextLabel"){
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 25),
        Font = SynthwaveX.Fonts.Bold,
        Text = title,
        TextColor3 = SynthwaveX.Theme.Primary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    }
    
    local Message = Create("TextLabel"){
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 0, 35),
        Font = SynthwaveX.Fonts.Regular,
        Text = message,
        TextColor3 = SynthwaveX.Theme.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    }
    
    local Progress = Create("Frame"){
        Name = "Progress",
        BackgroundColor3 = SynthwaveX.Theme.Primary,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = Notification
    }
    
    -- Animation
    Notification.Position = UDim2.new(1, 0, 1, -100)
    Tween(Notification, {Position = UDim2.new(1, -330, 1, -100)}, 0.3)
    Tween(Progress, {Size = UDim2.new(0, 0, 0, 2)}, duration)
    
    task.delay(duration, function()
        Tween(Notification, {Position = UDim2.new(1, 0, 1, -100)}, 0.3).Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end

-- Dragging Functionality
local function EnableDragging(frame)
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end
-- Part 5: Mobile Support, Initialization, and Return Functions

-- Mobile Support
local function AddMobileSupport()
    local function CreateTouchButton(position)
        local TouchButton = Create("ImageButton"){
            Name = "TouchButton",
            BackgroundColor3 = SynthwaveX.Theme.Primary,
            BackgroundTransparency = 0.5,
            Position = position,
            Size = UDim2.new(0, 40, 0, 40),
            Image = "",
            Parent = ScreenGui
        }
        
        local TouchButtonCorner = Create("UICorner"){
            CornerRadius = UDim.new(1, 0),
            Parent = TouchButton
        }
        
        return TouchButton
    end
    
    if UserInputService.TouchEnabled then
        local ToggleButton = CreateTouchButton(UDim2.new(0, 20, 0.5, -20))
        local CloseButton = CreateTouchButton(UDim2.new(0, 20, 0.5, 30))
        
        ToggleButton.MouseButton1Click:Connect(function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
    end
end

-- Window Management
function Window:Show()
    MainFrame.Visible = true
end

function Window:Hide()
    MainFrame.Visible = false
end

function Window:Toggle()
    MainFrame.Visible = not MainFrame.Visible
end

-- Theme Management
function SynthwaveX:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if SynthwaveX.Theme[key] then
            SynthwaveX.Theme[key] = value
        end
    end
end

-- Initialize Controls
local function InitializeControls()
    -- Minimize Button
    MinimizeButton.MouseButton1Click:Connect(function()
        local size = MainFrame.Size
        if size.Y.Offset > 35 then
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 35)})
        else
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 500)})
        end
    end)
    
    -- Close Button
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Position = UDim2.new(1, 0, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}, 0.3)
            .Completed:Connect(function()
                ScreenGui:Destroy()
            end)
    end)
    
    -- Enable Dragging
    EnableDragging(MainFrame)
    
    -- Add Mobile Support
    AddMobileSupport()
end

-- Auto-update Server Info
local function UpdateServerInfo()
    RunService.Heartbeat:Connect(function()
        if ServerInfo then
            ServerInfo.Text = string.format("Server: %d/%d players", #Players:GetPlayers(), Players.MaxPlayers)
        end
    end)
end

-- Initialize Window
local function InitializeWindow()
    InitializeControls()
    UpdateServerInfo()
    
    -- Add Ripple Effect to all buttons
    for _, instance in ipairs(ScreenGui:GetDescendants()) do
        if instance:IsA("TextButton") then
            instance.MouseButton1Click:Connect(function()
                Ripple(instance)
            end)
        end
    end
end

-- Create New Window
function SynthwaveX.new(title)
    local window = Window.new(title)
    InitializeWindow()
    return window
end

-- Return Library
return SynthwaveX
