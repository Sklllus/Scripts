local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
--[
--UI Library Made By xS_Killus
--]

--Instances And Functions

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
                TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)}):Play()
            end
        end
    end)
end

--[
--UI Library Functions
--]

--[
--Create
--]

function library:Create(class, props)
    props = props or {}

    if not class then
        return
    end

    local A = class == "Square" or class == "Line" or class == "Text" or class == "Quad" or class == "Circle" or class == "Triangle"

    local T = A and Drawing or Instance

    local Inst = T.new(class)

    if not A then
        if class == "ScreenGui" then
            if RunService:IsStudio() then
                Inst.Parent = script.Parent.Parent
            end

            if gethui then
                Inst.Parent = gethui()
            end

            if syn and syn.protect_gui then
                syn.syn.protect_gui(Inst)

                Inst.Parent = CoreGui
            end
        end
    end

    for p, v in next, props do
        Inst[p] = v
    end

    table.insert(self.Instances, {
        Object = Inst,
        Method = A
    })

    return Inst
end

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

    for _, i in next, self.Instances do
        if i.Method then
            pcall(function()
                i.Object:Remove()
            end)
        else
            i.Object:Destroy()
        end
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

    local Window = library:Create("ScreenGui", {
        Name = "Window",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })

    local MainFrame = library:Create("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 640, 0, 450),
        Parent = Window
    })

    MakeDraggable(MainFrame, MainFrame)

    local MainFrameCorner = library:Create("UICorner", {
        Name = "MainFrameCorner",
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })

    local LeftFrame = library:Create("Frame", {
        Name = "LeftFrame",
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(0, 0, 0.089, 0),
        Size = UDim2.new(0, 155, 0, 410),
        Parent = MainFrame
    })

    local LeftFrameCorner = library:Create("UICorner", {
        Name = "LeftFrameCorner",
        CornerRadius = UDim.new(0, 6),
        Parent = LeftFrame
    })

    local LeftFrameList = library:Create("UIListLayout", {
        Name = "LeftFrameList",
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = LeftFrame
    })

    local TopFrame = library:Create("Frame", {
        Name = "TopFrame",
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Size = UDim2.new(0, 640, 0, 40),
        Parent = MainFrame
    })

    local TopFrameCorner = library:Create("UICorner", {
        Name = "TopFrameCorner",
        CornerRadius = UDim.new(0, 6),
        Parent = TopFrame
    })

    local WindowTitle = library:Create("TextLabel", {
        Name = "WindowTitle",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 210, 0, 20),
        Font = Enum.Font.Code,
        Text = WindowName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopFrame
    })

    local WindowTitlePadding = library:Create("UIPadding", {
        Name = "WindowTitlePadding",
        PaddingLeft = UDim.new(0, 4),
        Parent = WindowTitle
    })

    local GameName = library:Create("GameName", {
        Name = "GameName",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 210, 0, 20),
        Font = Enum.Font.Code,
        Text = MarketplaceService:GetProductInfo(game.PlaceId).Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopFrame
    })

    local GameNamePadding = library:Create("UIPadding", {
        Name = "GameNamePadding",
        PaddingLeft = UDim.new(0, 4),
        Parent = GameName
    })

    local DestroyWindowButton = library:Create("ImageButton", {
        Name = "DestroyWindowButton",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.953, 0, 0.125, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://6031094678",
        Parent = TopFrame
    })

    local MinimizeButton = library:Create("ImageButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.906, 0, 0.125, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://6035067836",
        Parent = TopFrame
    })

    local InternalUIButton = library:Create("ImageButton", {
        Name = "InternalUIButton",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.859, 0, 0.125, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://6023426930",
        Parent = TopFrame
    })

    local SettingsButton = library:Create("ImageButton", {
        Name = "SettingsButton",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.813, 0, 0.125, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://6031280882",
        Parent = TopFrame
    })
end
