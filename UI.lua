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
    getgenv()["library"]:Unload()
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
    Watermark = nil,
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
--CreateWatermark
--]

function library:CreateWatermark(options)
    local WatermarkName = (options.Name or options.Title or options.Text) or "Watermark | {game} | {fps}"

    local WatermarkTitle = " " .. WatermarkName:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", "0 FPS") .. " "

    local Watermark = Instance.new("ScreenGui")

    Watermark.Name = "Watermark"
    Watermark.IgnoreGuiInset = true
    Watermark.ZIndexBehavior = Enum.ZIndexBehavior.Global

    if RunService:IsStudio() then
        Watermark.Parent = script.Parent.Parent
    end

    if gethui then
        Watermark.Parent = gethui()
    end

    if syn and syn.protect_gui then
        syn.protect_gui(Watermark)

        Watermark.Parent = CoreGui
    end

    library.Watermark = Watermark

    local MainBar = Instance.new("Frame", Watermark)

    MainBar.Name = "MainBar"
    MainBar.BorderSizePixel = 0
    MainBar.ZIndex = 5
    MainBar.Position = UDim2.new(0, 10, 0, 10)
    MainBar.Size = UDim2.new(0, 0, 0, 25)

    local Gradient = Instance.new("UIGradient", MainBar)

    Gradient.Name = "Gradient"
    Gradient.Rotation = 90
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(10, 10, 10))
    })

    local Outline = Instance.new("Frame", MainBar)

    Outline.Name = "Outline"
    Outline.ZIndex = 4
    Outline.BorderSizePixel = 0
    Outline.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Outline.Position = UDim2.fromOffset(-1, -1)

    local BlackOutline = Instance.new("Frame", MainBar)

    BlackOutline.Name = "BlackOutline"
    BlackOutline.ZIndex = 3
    BlackOutline.BorderSizePixel = 0
    BlackOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackOutline.Position = UDim2.fromOffset(-2, -2)

    local WTitle = Instance.new("TextLabel", MainBar)

    WTitle.Name = "WTitle"
    WTitle.BackgroundTransparency = 1
    WTitle.Position = UDim2.new(0, 0, 0, 0)
    WTitle.Size = UDim2.new(0, 238, 0, 25)
    WTitle.Font = Enum.Font.Code
    WTitle.ZIndex = 6
    WTitle.Text = WatermarkTitle
    WTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WTitle.TextSize = 15
    WTitle.TextStrokeTransparency = 0
    WTitle.TextXAlignment = Enum.TextXAlignment.Left
    WTitle.Size = UDim2.new(0, WTitle.TextBounds.X + 10, 0, 25)

    local TopBar = Instance.new("Frame", MainBar)

    TopBar.Name = "TopBar"
    TopBar.ZIndex = 6
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(0, 0, 0, 1)

    TweenService:Create(MainBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X, 0, 25)}):Play()
    TweenService:Create(TopBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X + 6, 0, 1)}):Play()

    repeat
        task.wait()
    until MainBar.Size == UDim2.new(0, WTitle.TextBounds.X, 0, 25)

    TweenService:Create(Outline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = MainBar.Size + UDim2.fromOffset(2, 2)}):Play()
    TweenService:Create(BlackOutline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = MainBar.Size + UDim2.fromOffset(4, 4)}):Play()

    TweenService:Create(MainBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X + 4, 0, 25)}):Play()
    TweenService:Create(WTitle, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X + 4, 0, 25)}):Play()
    TweenService:Create(TopBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X + 6, 0, 1)}):Play()

    repeat
        task.wait()
    until MainBar.Size == UDim2.new(0, WTitle.TextBounds.X + 4, 0, 25)

    TweenService:Create(Outline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = MainBar.Size + UDim2.fromOffset(2, 2)}):Play()
    TweenService:Create(BlackOutline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = MainBar.Size + UDim2.fromOffset(4, 4)}):Play()

    local StartTime, Counter, OldFPS = os.clock(), 0, nil

    RunService.Heartbeat:Connect(function()
        if not WatermarkName:find("{fps}") then
            WTitle.Text = " " .. WatermarkName:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", "0 FPS") .. " "
        end

        if WatermarkName:find("{fps}") then
            local CurrentTime = os.clock()

            Counter = Counter + 1

            if CurrentTime - StartTime >= 1 then
                local FPS = math.floor(Counter / (CurrentTime - StartTime))

                Counter = 0

                StartTime = CurrentTime

                if FPS ~= OldFPS then
                    WTitle.Text = " " .. WatermarkName:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", FPS .. " FPS") .. " "

                    TweenService:Create(WTitle, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X + 10, 0, 25)}):Play()
                    TweenService:Create(MainBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X, 0, 25)}):Play()
                    TweenService:Create(TopBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, WTitle.TextBounds.X, 0, 1)}):Play()

                    repeat
                        task.wait()
                    until MainBar.Size == UDim2.new(0, WTitle.TextBounds.X + 10, 0, 25)

                    TweenService:Create(Outline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = MainBar.Size + UDim2.fromOffset(2, 2)}):Play()
                    TweenService:Create(BlackOutline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = MainBar.Size + UDim2.fromOffset(4, 4)}):Play()
                end

                OldFPS = FPS
            end
        end
    end)

    MainBar.MouseEnter:Connect(function()
        TweenService:Create(MainBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(TopBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(WTitle, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency = 1, Active = false}):Play()
        TweenService:Create(Outline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
        TweenService:Create(BlackOutline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1, Active = false}):Play()
    end)

    MainBar.MouseLeave:Connect(function()
        TweenService:Create(MainBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(TopBar, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(WTitle, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency = 0, Active = true}):Play()
        TweenService:Create(Outline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
        TweenService:Create(BlackOutline, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0, Active = true}):Play()
    end)

    local WatermarkFunctions = {}

    --[
    --Destroy
    --]

    function WatermarkFunctions:Destroy()
        Watermark:Destroy()
    end

    return WatermarkFunctions
end

return library
