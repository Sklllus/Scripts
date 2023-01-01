--[
--UI Library Made By xS_Killus
--]

--Instances And Functions

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if getgenv()["library"] then
    getgenv()["library"]:Unload()
end

local library = {
    Title = "Break-Skill Hub - V1",
    WorkspaceName = "Break-Skill Hub - V1",
    FileExt = ".json",
    Tabs = {},
    Flags = {},
    Instances = {},
    Connections = {},
    Options = {}
}

getgenv()["library"] = library

local IsDraggingSomething = false

local BlacklistedKeys = {
    Enum.KeyCode.Unknown,
    Enum.KeyCode.W,
    Enum.KeyCode.S,
    Enum.KeyCode.A,
    Enum.KeyCode.D,
    Enum.KeyCode.Slash,
    Enum.KeyCode.Tab,
    Enum.KeyCode.Escape,
    Enum.KeyCode.Return
}

local WhitelistedMouseInputs = {
    Enum.UserInputType.MouseButton1,
    Enum.UserInputType.MouseButton2,
    Enum.UserInputType.MouseButton3
}

local function MakeDraggable(topBarObject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPos = nil

    library:AddConnection(topBarObject.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true

            DragStart = input.Position

            StartPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    library:AddConnection(topBarObject.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    library:AddConnection(UserInputService.InputChanged, function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart

            if not IsDraggingSomething then
                TweenService:Create(object, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)}):Play()
            end
        end
    end)
end

--[
--UI Library Functions
--]

--[
--AddConnection
--]

function library:AddConnection(connection, name, callback)
    callback = type(name) == "function" and name or callback

    connection = connection:Connect(callback)

    if name ~= callback then
        self.Connections[name] = connection
    else
        table.insert(self.Connections, connection)
    end

    return connection
end

--[
--Unload
--]

function library:Unload()
    for _, c in next, self.Connections do
        c:Disconnect()
    end

    if CoreGui:FindFirstChild("Window") then
        CoreGui.Window:Destroy()
    end

    for _, o in next, self.Options do
        if o.Type == "Toggle" then
            coroutine.resume(coroutine.create(o.SetState, o))
        end
    end

    library = nil

    getgenv()["library"] = nil
end

--[
--GetConfigs
--]

function library:GetConfigs()
    if not isfolder(library.WorkspaceName) then
        makefolder(library.WorkspaceName)
    end

    if not isfolder(library.WorkspaceName .. "/Configs") then
        makefolder(library.WorkspaceName .. "/Configs")

        return {}
    end

    local Files = {}

    local A = 0

    for i, f in next, listfiles(library.WorkspaceName .. "/Configs") do
        if f:sub(#f - #library.FileExt + 1, #f) == library.FileExt then
            A = A + 1

            f = f:gsub(library.WorkspaceName .. "\\", "")
            f = f:gsub(library.FileExt, "")

            table.insert(Files, A, f)
        end
    end

    return Files
end

--[
--SaveConfig
--]

function library:SaveConfig(config)
    local Config = {}

    if table.find(library:GetConfigs(), config) then
        Config = HttpService:JSONDecode(readfile(library.WorkspaceName .. "/" .. config .. library.FileExt))
    end

    for _, o in next, library.Options do
        if o.Type ~= "Button" and o.Flag and not o.SkipFlag then
            if o.Type == "Toggle" then
                Config[o.Flag] = o.State and 1 or 0
            elseif o.Type == "ColorPicker" then
                Config[o.Flag] = {
                    o.Color.R,
                    o.Color.G,
                    o.Color.B
                }

                if o.Transparency then
                    Config[o.Flag .. "/Transparency"] = o.Transparency
                end
            elseif o.Type == "Keybind" then
                if o.Key ~= "none" then
                    Config[o.Flag] = o.Key
                end
            elseif o.Type == "Dropdown" then
                Config[o.Flag] = o.Value
            else
                Config[o.Flag] = o.Value
            end
        end
    end

    writefile(library.WorkspaceName .. "/" .. config .. library.FileExt, HttpService:JSONEncode(Config))
end

--[
--LoadConfig
--]

function library:LoadConfig(config)
    if table.find(library:GetConfigs(), config) then
        local Read, Config = pcall(function()
            return HttpService:JSONDecode(readfile(library.WorkspaceName .. "/" .. config .. library.FileExt))
        end)

        Config = Read and Config or {}

        for _, o in next, library.Options do
            if o.Type ~= "Button" and o.Flag and not o.SkipFlag then
                if o.Type == "Toggle" then
                    spawn(function()
                        o:SetState(Config[o.Flag] == 1)
                    end)
                elseif o.Type == "ColorPicker" then
                    if Config[o.Flag] then
                        spawn(function()
                            o:SetColor(Config[o.Flag])
                        end)

                        if o.Transparency then
                            spawn(function()
                                o:SetTransparency(Config[o.Flag .. "/Transparency"])
                            end)
                        end
                    end
                elseif o.Type == "Keybind" then
                    spawn(function()
                        o:SetKey(Config[o.Flag])
                    end)
                else
                    spawn(function()
                        o:SetValue(Config[o.Flag])
                    end)
                end
            end
        end
    end
end

--[
--CreateWindow
--]

function library:CreateWindow(options)
    local WindowName = (options.Name or options.Title or options.Text) or "New Window"

    local Window = Instance.new("ScreenGui")

    if RunService:IsStudio() then
        Window.Parent = script.Parent.Parent
    end

    if gethui then
        Window.Parent = gethui()
    end

    if syn and syn.protect_gui then
        syn.protect_gui(Window)

        Window.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame", Window)
    local MainFrameCorner = Instance.new("UICorner", MainFrame)
    local LeftFrame = Instance.new("Frame", MainFrame)
    local LeftFrameCorner = Instance.new("UICorner", LeftFrame)
    local LeftFrameList = Instance.new("UIListLayout", LeftFrame)
    local TopFrame = Instance.new("Frame", MainFrame)
    local TopFrameCorner = Instance.new("UICorner", TopFrame)
    local WindowTitle = Instance.new("TextLabel", TopFrame)
    local WindowTitlePadding = Instance.new("UIPadding", WindowTitle)
    local GameName = Instance.new("TextLabel", TopFrame)
    local GameNamePadding = Instance.new("UIPadding", GameName)
    local DestroyWindowButton = Instance.new("ImageButton", TopFrame)
    local MinimizeButton = Instance.new("ImageButton", TopFrame)
    local InternalUIButton = Instance.new("ImageButton", TopFrame)
    local SettingsButton = Instance.new("ImageButton", TopFrame)

    Window.Name = "Window"
    Window.IgnoreGuiInset = true
    Window.ZIndexBehavior = Enum.ZIndexBehavior.Global

    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 640, 0, 450)

    MakeDraggable(MainFrame, MainFrame)

    MainFrameCorner.Name = "MainFrameCorner"
    MainFrameCorner.CornerRadius = UDim.new(0, 6)

    LeftFrame.Name = "LeftFrame"
    LeftFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LeftFrame.Position = UDim2.new(0, 0, 0.089, 0)
    LeftFrame.Size = UDim2.new(0, 155, 0, 410)

    LeftFrameCorner.Name = "LeftFrameCorner"
    LeftFrameCorner.CornerRadius = UDim.new(0, 6)

    LeftFrameList.Name = "LeftFrameList"
    LeftFrameList.Padding = UDim.new(0, 4)
    LeftFrameList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    TopFrame.Name = "TopFrame"
    TopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopFrame.Size = UDim2.new(0, 640, 0, 40)

    TopFrameCorner.Name = "TopFrameCorner"
    TopFrameCorner.CornerRadius = UDim.new(0, 6)

    WindowTitle.Name = "WindowTitle"
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.BorderSizePixel = 0
    WindowTitle.Size = UDim2.new(0, 210, 0, 20)
    WindowTitle.Font = Enum.Font.Code
    WindowTitle.Text = WindowName
    WindowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.TextSize = 20
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left

    WindowTitlePadding.Name = "WindowTitlePadding"
    WindowTitlePadding.PaddingLeft = UDim.new(0, 4)

    GameName.Name = "GameName"
    GameName.BackgroundTransparency = 1
    GameName.BorderSizePixel = 0
    GameName.Position = UDim2.new(0, 0, 0.5, 0)
    GameName.Size = UDim2.new(0, 210, 0, 20)
    GameName.Font = Enum.Font.Code
    GameName.Text = MarketplaceService:GetProductInfo(game.PlaceId).Name
    GameName.TextColor3 = Color3.fromRGB(255, 255, 255)
    GameName.TextSize = 18
    GameName.TextXAlignment = Enum.TextXAlignment.Left

    GameNamePadding.Name = "GameNamePadding"
    GameNamePadding.PaddingLeft = UDim.new(0, 4)

    DestroyWindowButton.Name = "DestroyWindowButton"
    DestroyWindowButton.BackgroundTransparency = 1
    DestroyWindowButton.BorderSizePixel = 0
    DestroyWindowButton.Position = UDim2.new(0.953, 0, 0.125, 0)
    DestroyWindowButton.Size = UDim2.new(0, 30, 0, 30)
    DestroyWindowButton.Image = "rbxassetid://6031094678"

    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(0.906, 0, 0.125, 0)
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Image = "rbxassetid://6035067836"

    InternalUIButton.Name = "InternalUIButton"
    InternalUIButton.BackgroundTransparency = 1
    InternalUIButton.BorderSizePixel = 0
    InternalUIButton.Position = UDim2.new(0.859, 0, 0.125, 0)
    InternalUIButton.Size = UDim2.new(0, 30, 0, 30)
    InternalUIButton.Image = "rbxassetid://6023426930"

    SettingsButton.Name = "SettingsButton"
    SettingsButton.BackgroundTransparency = 1
    SettingsButton.BorderSizePixel = 0
    SettingsButton.Position = UDim2.new(0.813, 0, 0.125, 0)
    SettingsButton.Size = UDim2.new(0, 30, 0, 30)
    SettingsButton.Image = "rbxassetid://6031280882"

    DestroyWindowButton.MouseButton1Click:Connect(function()
        TweenService:Create(DestroyWindowButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
        TweenService:Create(InternalUIButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
        TweenService:Create(SettingsButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
        TweenService:Create(WindowTitle, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(GameName, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(TopFrame, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LeftFrame, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

        task.wait(0.5)

        TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, 640, 0, 5)}):Play()

        repeat
            task.wait()
        until MainFrame.Size == UDim2.new(0, 640, 0, 5)

        TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, 2, 0, 2), BackgroundTransparency = 1}):Play()

        task.wait(0.5)

        library:Unload()
    end)
end
