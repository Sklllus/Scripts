--[
--Script Made By xS_Killus
--]

--Instances And Functions

local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

if getgenv()["library"] then
    getgenv()["library"]:Unlad()
end

local library = {
    Tabs = {},
    Flags = {},
    Instances = {},
    Connections = {},
    Options = {},
    Notifications = {},
    Theme = {},
    Draggable = true,
    Open = false,
    Popup = nil,
    TabSize = 0,
    Name = "Break-Skill Hub - V1",
    Version = "1.0",
    FolderName = "Break-Skill Hub - V1",
    FileExt = ".json"
}

getgenv()["library"] = library

--[
--UI Library Functions
--]

--[
--CreateWindow
--]

function library:CreateWindow(options)
    local WindowName = (options.Name or options.Title or options.Text) or "New Window"
    local WatermarkName = (options.WName or options.WTitle or options.WText) or "New Watermark {game} | {fps} | {ping}"

    local WName = " " .. WatermarkName:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", "0 FPS"):gsub("{ping}", "0 ping") .. " "

    local Watermark = Instance.new("ScreenGui")

    Watermark.Name = "Watermark"
    Watermark.IgnoreGuiInset = true
    Watermark.ZIndexBehavior = Enum.ZIndexBehavior.Global

    if gethui then
        Watermark.Parent = gethui()
    end

    if syn and syn.protect_gui then
        syn.protect_gui(Watermark)

        Watermark.Parent = CoreGui
    end

    if getgenv()["Watermark"] then
        getgenv()["Watermark"]:Destroy()
    end

    getgenv()["Watermark"] = Watermark

    local MainBar = Instance.new("Frame", Watermark)
    local Gradient = Instance.new("UIGradient", MainBar)
    local Outline = Instance.new("Frame", MainBar)
    local BlackOutline = Instance.new("Frame", MainBar)
    local WTitle = Instance.new("TextLabel", MainBar)
    local TopBar = Instance.new("Frame", MainBar)

    MainBar.Name = "MainBar"
    MainBar.BorderColor3 = Color3.fromRGB(80, 80, 80)
    MainBar.BorderSizePixel = 0
    MainBar.ZIndex = 5
    MainBar.Position = UDim2.new(0, 10, 0, 10)
    MainBar.Size = UDim2.new(0, 0, 0, 25)

    Gradient.Name = "Gradient"
    Gradient.Rotation = 90
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(10, 10, 10))
    })

    Outline.Name = "Outline"
    Outline.ZIndex = 4
    Outline.BorderSizePixel = 0
    Outline.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Outline.Position = UDim2.fromOffset(-1, -1)

    BlackOutline.Name = "BlackOutline"
    BlackOutline.ZIndex = 3
    BlackOutline.BorderSizePixel = 0
    BlackOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackOutline.Position = UDim2.fromOffset(-2, -2)

    WTitle.Name = "WTitle"
    WTitle.BackgroundTransparency = 1
    WTitle.Position = UDim2.new(0, 0, 0, 0)
    WTitle.Size = UDim2.new(0, 238, 0, 25)
    WTitle.Font = Enum.Font.Code
    WTitle.ZIndex = 6
    WTitle.Text = WName
    WTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WTitle.TextSize = 15
    WTitle.TextStrokeTransparency = 0
    WTitle.TextXAlignment = Enum.TextXAlignment.Left
    WTitle.Size = UDim2.new(0, WTitle.TextBounds.X + 10, 0, 25)

    TopBar.Name = "TopBar"
    TopBar.ZIndex = 6
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(0, 0, 0, 1)

    MainBar.Size = UDim2.new(0, WTitle.TextBounds.X, 0, 25)
    TopBar.Size = UDim2.new(0, WTitle.TextBounds.X + 6, 0, 1)
    Outline.Size = MainBar.Size + UDim2.fromOffset(2, 2)
    BlackOutline.Size = MainBar.Size + UDim2.fromOffset(4, 4)
    MainBar.Size = UDim2.new(0, WTitle.TextBounds.X + 4, 0, 25)
    WTitle.Size = UDim2.new(0, WTitle.TextBounds.X + 4, 0, 25)
    TopBar.Size = UDim2.new(0, WTitle.TextBounds.X + 6, 0, 1)
    Outline.Size = MainBar.Size + UDim2.fromOffset(2, 2)
    BlackOutline.Size = MainBar.Size + UDim2.fromOffset(4, 4)

    local StartTime, Counter, OldFPS = os.clock(), 0, nil

    RunService.Heartbeat:Connect(function()
        if not WatermarkName:find("{fps}") or not WatermarkName:find("{ping}") then
            WTitle.Text = " " .. WatermarkName:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", "0 FPS"):gsub("{ping}", "0 ping") .. " "
        end

        if WatermarkName:find("{fps}") or WatermarkName:find("{ping}") then
            local CurrentTime = os.clock()

            Counter = Counter + 1

            if CurrentTime - StartTime >= 1 then
                local FPS = math.floor(Counter / (CurrentTime - StartTime))

                Counter = 0

                StartTime = CurrentTime

                if FPS ~= OldFPS then
                    WTitle.Text = " " .. WatermarkName:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", FPS .. " FPS"):gsub("{ping}", Stats.Network.ServerStatsItem["Data Ping"]:GetValue(), " ping") .. " "
                    WTitle.Size = UDim2.new(0, WTitle.TextBounds.X + 10, 0, 25)
                    MainBar.Size = UDim2.new(0, WTitle.TextBounds.X, 0, 25)
                    TopBar.Size = UDim2.new(0, WTitle.TextBounds.X, 0, 1)
                    Outline.Size = MainBar.Size + UDim2.fromOffset(2, 2)
                    BlackOutline.Size = MainBar.Size + UDim2.fromOffset(4, 4)
                end

                OldFPS = FPS
            end
        end
    end)

    MainBar.MouseEnter:Connect(function()
        TweenService:Create(MainBar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(TopBar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(WTitle, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(Outline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(BlackOutline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
    end)

    MainBar.MouseLeave:Connect(function()
        TweenService:Create(MainBar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(TopBar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(WTitle, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(Outline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(BlackOutline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
    end)


end


return library
