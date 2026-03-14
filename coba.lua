-- Matikan instance lama kalau ada
if _G.KingVypersRunning then
    _G.KingVypersRunning = false
end
task.wait(0.5)
_G.KingVypersRunning = true

-- ═══════════════════════════════════════════════════════════
-- AUTH (premium key) - no raw script link
-- ═══════════════════════════════════════════════════════════
local CONFIG = {
    API_URL = "https://www.kingvypers.site",
    ENDPOINT = "/api/validate-key",
    SAVE_KEY = true,
    KEY_FILE = "SavedKey.txt",
    DISCORD_LINK = "https://discord.gg/eEqGnt4the",
    WHATSAPP_LINK = "https://wa.me/+6281225363857",
    THEME = {
        BG_PRIMARY = Color3.fromRGB(10, 5, 20),
        BG_SECONDARY = Color3.fromRGB(18, 10, 30),
        BG_CARD = Color3.fromRGB(25, 15, 40),
        BG_INPUT = Color3.fromRGB(30, 20, 45),
        ACCENT = Color3.fromRGB(138, 43, 226),
        ACCENT_HOVER = Color3.fromRGB(168, 73, 255),
        ACCENT_DARK = Color3.fromRGB(108, 20, 180),
        NEON_PURPLE = Color3.fromRGB(191, 64, 191),
        NEON_BRIGHT = Color3.fromRGB(218, 112, 214),
        NEON_GLOW = Color3.fromRGB(148, 0, 211),
        SUCCESS = Color3.fromRGB(123, 239, 178),
        ERROR = Color3.fromRGB(255, 85, 127),
        WARNING = Color3.fromRGB(255, 179, 71),
        INFO = Color3.fromRGB(116, 185, 255),
        TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(200, 195, 220),
        TEXT_MUTED = Color3.fromRGB(150, 145, 170),
        TEXT_DARK = Color3.fromRGB(100, 95, 120),
        BORDER = Color3.fromRGB(45, 35, 70),
        BORDER_BRIGHT = Color3.fromRGB(138, 43, 226),
        SHADOW = Color3.fromRGB(0, 0, 0),
    }
}

local AuthHttp = game:GetService("HttpService")
local AuthPlayers = game:GetService("Players")
local AuthCoreGui = game:GetService("CoreGui")
local AuthTween = game:GetService("TweenService")
local AuthUIS = game:GetService("UserInputService")
local AuthPlayer = AuthPlayers.LocalPlayer

local function GetHWID()
    if gethwid then return gethwid() end
    if syn and syn.fingerprint then return syn.fingerprint() end
    if identifyexecutor then
        return identifyexecutor() .. "_" .. game:GetService("RbxAnalyticsService"):GetClientId()
    end
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

local function GetSavedKey()
    if not CONFIG.SAVE_KEY then return nil end
    local ok, r = pcall(function()
        if isfile and readfile and isfile(CONFIG.KEY_FILE) then return readfile(CONFIG.KEY_FILE) end
        return nil
    end)
    return ok and r or nil
end

local function SaveKey(key)
    if not CONFIG.SAVE_KEY then return false end
    return pcall(function() if writefile then writefile(CONFIG.KEY_FILE, key) end end)
end

local function DeleteKey()
    pcall(function()
        if delfile and isfile and isfile(CONFIG.KEY_FILE) then delfile(CONFIG.KEY_FILE) end
    end)
end

local function AuthNotify(t, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = t, Text = text, Duration = dur or 5 })
    end)
end

local function CopyClip(text)
    if setclipboard then setclipboard(text) return true end
    return false
end

local function ApiRequest(url, method, headers, body)
    for _, fn in ipairs({
        function()
            if syn and syn.request then return syn.request({ Url = url, Method = method, Headers = headers, Body = body }) end
        end,
        function()
            if request then return request({ Url = url, Method = method, Headers = headers, Body = body }) end
        end,
        function()
            if http_request then return http_request({ Url = url, Method = method, Headers = headers, Body = body }) end
        end,
    }) do
        local ok, res = pcall(fn)
        if ok and res and (res.Success or res.StatusCode == 200) then return res end
    end
    return nil
end

local function ValidateKey(keyCode)
    local url = CONFIG.API_URL .. CONFIG.ENDPOINT
    local body = AuthHttp:JSONEncode({ key = keyCode, hwid = GetHWID() })
    local res = ApiRequest(url, "POST", { ["Content-Type"] = "application/json" }, body)
    if not res then return { success = false, message = "Connection failed. Check your internet." } end
    local ok, data = pcall(function() return AuthHttp:JSONDecode(res.Body) end)
    return ok and data or { success = false, message = "Invalid response from server" }
end

-- Auth UI (simplified single panel)
local function CreateAuthUI()
    pcall(function() local e = AuthCoreGui:FindFirstChild("AuthLoader") if e then e:Destroy() end end)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AuthLoader"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.DisplayOrder = 999
    if gethui then Gui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(Gui) Gui.Parent = AuthCoreGui else Gui.Parent = AuthCoreGui end

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1,0,1,0)
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.Parent = Gui

    local Container = Instance.new("Frame")
    Container.AnchorPoint = Vector2.new(0.5,0.5)
    Container.Position = UDim2.new(0.5,0,0.5,0)
    Container.Size = UDim2.new(0, 360, 0, 200)
    Container.BackgroundColor3 = CONFIG.THEME.BG_PRIMARY
    Container.Parent = Gui
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Container).Color = CONFIG.THEME.BORDER_BRIGHT

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,-24,0,24)
    Title.Position = UDim2.new(0,12,0,12)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "License"
    Title.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    Title.TextSize = 16
    Title.Parent = Container

    local InputBox = Instance.new("TextBox")
    InputBox.Name = "KeyInput"
    InputBox.Position = UDim2.new(0,12,0,44)
    InputBox.Size = UDim2.new(1,-24,0,36)
    InputBox.BackgroundColor3 = CONFIG.THEME.BG_INPUT
    InputBox.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    InputBox.PlaceholderColor3 = CONFIG.THEME.TEXT_DARK
    InputBox.Text = ""
    InputBox.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.TextSize = 12
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Container
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 8)

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Name = "VerifyButton"
    VerifyBtn.Position = UDim2.new(0,12,0,88)
    VerifyBtn.Size = UDim2.new(1,-24,0,36)
    VerifyBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
    VerifyBtn.Text = "Verify"
    VerifyBtn.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.TextSize = 12
    VerifyBtn.Parent = Container
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)

    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Name = "Status"
    StatusLbl.Position = UDim2.new(0,12,0,130)
    StatusLbl.Size = UDim2.new(1,-24,0,16)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Font = Enum.Font.GothamMedium
    StatusLbl.Text = ""
    StatusLbl.TextColor3 = CONFIG.THEME.TEXT_MUTED
    StatusLbl.TextSize = 10
    StatusLbl.Parent = Container

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Position = UDim2.new(1,-36,0,8)
    CloseBtn.Size = UDim2.new(0,28,0,28)
    CloseBtn.BackgroundColor3 = CONFIG.THEME.BG_CARD
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = CONFIG.THEME.TEXT_MUTED
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = Container
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    return { Gui = Gui, Container = Container, Overlay = Overlay, KeyInput = InputBox, VerifyButton = VerifyBtn, Status = StatusLbl, CloseButton = CloseBtn }
end

local function DestroyAuthUI(ui)
    if not ui or not ui.Gui then return end
    AuthTween:Create(ui.Overlay, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    AuthTween:Create(ui.Container, TweenInfo.new(0.3), { BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0) }):Play()
    task.wait(0.35)
    pcall(function() ui.Gui:Destroy() end)
end

-- Will be set below: run main script (Vyper UI) after auth success
local LoadMainScript

local function HandleVerification(ui)
    local key = ui.KeyInput.Text:upper():gsub("%s+", "")
    if key == "" then ui.Status.Text = "Enter a key" ui.Status.TextColor3 = CONFIG.THEME.ERROR return end
    if #key < 10 then ui.Status.Text = "Invalid format" ui.Status.TextColor3 = CONFIG.THEME.ERROR return end

    ui.VerifyButton.Active = false
    ui.VerifyButton.Text = "Verifying..."
    ui.Status.Text = "Authenticating..."
    ui.Status.TextColor3 = CONFIG.THEME.INFO
    task.wait(0.3)

    local result = ValidateKey(key)
    ui.VerifyButton.Active = true
    ui.VerifyButton.Text = "Verify"

    if result.success then
        ui.Status.Text = "Success"
        ui.Status.TextColor3 = CONFIG.THEME.SUCCESS
        SaveKey(key)
        AuthNotify("Welcome", "Access granted.", 3)
        task.wait(1)
        DestroyAuthUI(ui)
        LoadMainScript()
    else
        ui.Status.Text = result.message or "Invalid key"
        ui.Status.TextColor3 = CONFIG.THEME.ERROR
        ui.KeyInput.Text = ""
    end
end

local function AuthMain()
    local saved = GetSavedKey()
    if saved and saved ~= "" then
        AuthNotify("Please Wait", "Validating license...", 2)
        local result = ValidateKey(saved)
        if result.success then
            AuthNotify("Welcome", "Authentication successful.", 3)
            LoadMainScript()
            return
        end
        DeleteKey()
    end

    local ui = CreateAuthUI()
    ui.CloseButton.MouseButton1Click:Connect(function() DestroyAuthUI(ui) end)
    ui.VerifyButton.MouseButton1Click:Connect(function() HandleVerification(ui) end)
    ui.KeyInput.FocusLost:Connect(function(enter) if enter then HandleVerification(ui) end end)
end

-- Main script (Vyper UI) runs only after auth success — no raw link
LoadMainScript = function()
local HttpService = game:GetService("HttpService")

if not isfolder("Vyper") then
    makefolder("Vyper")
end
if not isfolder("Vyper/Config") then
    makefolder("Vyper/Config")
end

local gameName   = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName         = gameName:gsub("[^%w_ ]", "")
gameName         = gameName:gsub("%s+", "_")

local ConfigFile = "Vyper/Config/Vyper_" .. gameName .. ".json"

ConfigData       = {}
Elements         = {}
CURRENT_VERSION  = nil

function SaveConfig()
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                ConfigData = result
            else
                ConfigData = { _version = CURRENT_VERSION }
            end
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

local Icons = {
    player    = "rbxassetid://12120698352",
    web       = "rbxassetid://137601480983962",
    bag       = "rbxassetid://8601111810",
    shop      = "rbxassetid://71070628393332",
    cart      = "rbxassetid://128874923961846",
    plug      = "rbxassetid://137601480983962",
    settings  = "rbxassetid://70386228443175",
    loop      = "rbxassetid://122032243989747",
    teleport  = "rbxassetid://102393969714664",
    compas    = "rbxassetid://125300760963399",
    gamepad   = "rbxassetid://84173963561612",
    boss      = "rbxassetid://13132186360",
    scroll    = "rbxassetid://114127804740858",
    menu      = "rbxassetid://6340513838",
    crosshair = "rbxassetid://12614416478",
    user      = "rbxassetid://108483430622128",
    stat      = "rbxassetid://12094445329",
    eyes      = "rbxassetid://14321059114",
    sword     = "rbxassetid://82472368671405",
    discord   = "rbxassetid://70435110352148",
    star      = "rbxassetid://107005941750079",
    skeleton  = "rbxassetid://17313330026",
    payment   = "rbxassetid://18747025078",
    scan      = "rbxassetid://109869955247116",
    alert     = "rbxassetid://73186275216515",
    question  = "rbxassetid://17510196486",
    idea      = "rbxassetid://16833255748",
    strom     = "rbxassetid://13321880293",
    water     = "rbxassetid://100076212630732",
    dcs       = "rbxassetid://15310731934",
    start     = "rbxassetid://108886429866687",
    next      = "rbxassetid://12662718374",
    rod       = "rbxassetid://103247953194129",
    fish      = "rbxassetid://97167558235554",
    fish2      = "rbxassetid://121452933704464",
    auto      = "rbxassetid://87176505291260",
    send      = "rbxassetid://120151125998047",
    about      = "rbxassetid://74602489630618",
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y

    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end

    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Position = pos })
            Tween:Play()
        end

        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize

        local minSizeX, minSizeY
        local defSizeX, defSizeY

        if isMobile then
            minSizeX, minSizeY = 100, 100
            defSizeX, defSizeY = 470, 270
        else
            minSizeX, minSizeY = 100, 100
            defSizeX, defSizeY = 640, 400
        end

        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object

        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth = StartSize.X.Offset + Delta.X
            local newHeight = StartSize.Y.Offset + Delta.Y

            newWidth = math.max(newWidth, minSizeX)
            newHeight = math.max(newHeight, minSizeY)

            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) })
            Tween:Play()
        end

        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdateSize(input)
            end
        end)
    end

    CustomSize(object)
    CustomPos(topbarobject, object)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.8999999761581421
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad",
            Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local Vyper = {}
function Vyper:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Vyper"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(138, 43, 226)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    local NotifyFunction = {}
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui");
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame");
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NotifyLayout.BackgroundTransparency = 0.9990000128746033
            NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(
                        v,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }
                    ):Play()
                    Count = Count + 1
                end
            end)
        end
        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end
        local NotifyFrame = Instance.new("Frame");
        local NotifyFrameReal = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local DropShadowHolder = Instance.new("Frame");
        local DropShadow = Instance.new("ImageLabel");
        local Top = Instance.new("Frame");
        local TextLabel = Instance.new("TextLabel");
        local UICorner1 = Instance.new("UICorner");
        local TextLabel1 = Instance.new("TextLabel");
        local Close = Instance.new("TextButton");
        local ImageLabel = Instance.new("ImageLabel");
        local TextLabel2 = Instance.new("TextLabel");

        NotifyFrame.BackgroundColor3 = Color3.fromRGB(29, 30, 35)
        NotifyFrame.BorderColor3 = Color3.fromRGB(29, 30, 35)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.Parent = NotifyFrameReal
        UICorner.CornerRadius = UDim.new(0, 8)

        DropShadowHolder.BackgroundTransparency = 1
        DropShadowHolder.BorderSizePixel = 0
        DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
        DropShadowHolder.ZIndex = 0
        DropShadowHolder.Name = "DropShadowHolder"
        DropShadowHolder.Parent = NotifyFrameReal

        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 0.9990000128746033
        Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Top.BorderSizePixel = 0
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 0.9990000128746033
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Parent = Top
        TextLabel.Position = UDim2.new(0, 10, 0, 0)

        UICorner1.Parent = Top
        UICorner1.CornerRadius = UDim.new(0, 5)

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel1.BackgroundTransparency = 0.9990000128746033
        TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Size = UDim2.new(1, 0, 1, 0)
        TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
        TextLabel1.Parent = Top

        Close.Font = Enum.Font.SourceSans
        Close.Text = ""
        Close.TextColor3 = Color3.fromRGB(0, 0, 0)
        Close.TextSize = 14
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Close.BackgroundTransparency = 0.9990000128746033
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageLabel.BackgroundTransparency = 0.9990000128746033
        ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.49000001, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(1, -8, 1, -8)
        ImageLabel.Parent = Close

        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.TextSize = 13
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.BackgroundTransparency = 0.9990000128746033
        TextLabel2.TextColor3 = Color3.fromRGB(150.0000062584877, 150.0000062584877, 150.0000062584877)
        TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0, 10, 0, 27)
        TextLabel2.Parent = NotifyFrameReal
        TextLabel2.Size = UDim2.new(1, -20, 0, 13)

        TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
        TextLabel2.TextWrapped = true

        if TextLabel2.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
        end
        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then
                return false
            end
            waitbruh = true
            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)
        TweenService:Create(
            NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    return NotifyFunction
end

function notif(msg, delay, color, title, desc)
    return Vyper:MakeNotify({
        Title = title or "Vyper",
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = color or Color3.fromRGB(138, 43, 226),
        Delay = delay or 4
    })
end

function Vyper:Window(GuiConfig)
    GuiConfig              = GuiConfig or {}
    GuiConfig.Title        = GuiConfig.Title or "Vyper"
    GuiConfig.Footer       = GuiConfig.Footer or "Vyper >:D"
    GuiConfig.Color        = GuiConfig.Color or Color3.fromRGB(138, 43, 226)
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
    GuiConfig.Version      = GuiConfig.Version or 1

    CURRENT_VERSION        = GuiConfig.Version
    LoadConfigFromFile()

    local GuiFunc = {}

    local Vyper = Instance.new("ScreenGui");
    local DropShadowHolder = Instance.new("Frame");
    local DropShadow = Instance.new("ImageLabel");
    local Main = Instance.new("Frame");
    local UICorner = Instance.new("UICorner");
    local Top = Instance.new("Frame");
    local TextLabel = Instance.new("TextLabel");
    local UICorner1 = Instance.new("UICorner");
    local TextLabel1 = Instance.new("TextLabel");
    local Close = Instance.new("TextButton");
    local ImageLabel1 = Instance.new("ImageLabel");
    local Min = Instance.new("TextButton");
    local ImageLabel2 = Instance.new("ImageLabel");
    local LayersTab = Instance.new("Frame");
    local UICorner2 = Instance.new("UICorner");
    local DecideFrame = Instance.new("Frame");
    local Layers = Instance.new("Frame");
    local UICorner6 = Instance.new("UICorner");
    local NameTab = Instance.new("TextLabel");
    local LayersReal = Instance.new("Frame");
    local LayersFolder = Instance.new("Folder");
    local LayersPageLayout = Instance.new("UIPageLayout");

    Vyper.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Vyper.Name = "Vyper"
    Vyper.ResetOnSpawn = false
    Vyper.Parent = game:GetService("CoreGui")

    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    if isMobile then
        DropShadowHolder.Size = safeSize(470, 270)
    else
        DropShadowHolder.Size = safeSize(640, 400)
    end
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Vyper

    DropShadowHolder.Position = UDim2.new(0, (Vyper.AbsoluteSize.X // 2 - DropShadowHolder.Size.X.Offset // 2), 0,
        (Vyper.AbsoluteSize.Y // 2 - DropShadowHolder.Size.Y.Offset // 2))
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    if GuiConfig.Theme then
        Main:Destroy()
        Main = Instance.new("ImageLabel")
        Main.Image = "rbxassetid://" .. GuiConfig.Theme
        Main.ScaleType = Enum.ScaleType.Crop
        Main.BackgroundTransparency = 1
        Main.ImageTransparency = GuiConfig.ThemeTransparency or 0.15
    else
        Main.BackgroundColor3 = Color3.fromRGB(20, 15, 30) -- Dark base for gradient
        Main.BackgroundTransparency = 0.15
        
        -- Add purple-cyan gradient overlay for 3D modern look
        local GradientOverlay = Instance.new("Frame")
        GradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        GradientOverlay.BackgroundTransparency = 0.3
        GradientOverlay.BorderSizePixel = 0
        GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
        GradientOverlay.ZIndex = 1
        GradientOverlay.Name = "GradientOverlay"
        
        local MainGradient = Instance.new("UIGradient")
        MainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(80, 40, 120)),   -- Dark purple
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(138, 43, 226)),  -- Purple
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(100, 150, 255)), -- Cyan-blue
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(150, 240, 255))  -- Bright cyan
        })
        MainGradient.Rotation = 135 -- Diagonal gradient like logo
        MainGradient.Parent = GradientOverlay
        
        local GradientCorner = Instance.new("UICorner")
        GradientCorner.Parent = GradientOverlay
        
        GradientOverlay.Parent = Main
    end

    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    UICorner.Parent = Main

    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.9990000128746033
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 0.9990000128746033
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, -100, 1, 0)
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.Parent = Top

    UICorner1.Parent = Top

    TextLabel1.Font = Enum.Font.GothamBold
    TextLabel1.Text = GuiConfig.Footer
    TextLabel1.TextColor3 = GuiConfig.Color
    TextLabel1.TextSize = 14
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel1.BackgroundTransparency = 0.9990000128746033
    TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel1.BorderSizePixel = 0
    TextLabel1.Size = UDim2.new(1, -(TextLabel.TextBounds.X + 104), 1, 0)
    TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
    TextLabel1.Parent = Top

    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.9990000128746033
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel1.BackgroundTransparency = 0.9990000128746033
    ImageLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel1.BorderSizePixel = 0
    ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel1.Parent = Close

    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.9990000128746033
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel2.BackgroundTransparency = 0.9990000128746033
    ImageLabel2.ImageTransparency = 0.2
    ImageLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel2.BorderSizePixel = 0
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
    ImageLabel2.Parent = Min

    LayersTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersTab.BackgroundTransparency = 0.9990000128746033
    LayersTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 9, 0, 50)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -59)
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main

    UICorner2.CornerRadius = UDim.new(0, 2)
    UICorner2.Parent = LayersTab

    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    Layers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Layers.BackgroundTransparency = 0.9990000128746033
    Layers.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, 50)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -59)
    Layers.Name = "Layers"
    Layers.Parent = Main

    UICorner6.CornerRadius = UDim.new(0, 2)
    UICorner6.Parent = Layers

    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 24
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.BackgroundTransparency = 0.9990000128746033
    NameTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    NameTab.BorderSizePixel = 0
    NameTab.Size = UDim2.new(1, 0, 0, 30)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers

    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayersReal.BackgroundTransparency = 0.9990000128746033
    LayersReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayersReal.BorderSizePixel = 0
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, -33)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    local ScrollTab = Instance.new("ScrollingFrame");
    local UIListLayout = Instance.new("UIListLayout");

    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.10000002, 0)
    ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrollTab.BackgroundTransparency = 0.9990000128746033
    ScrollTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab

    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    local function UpdateSize1()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("Vyper") then
            Vyper:Destroy()
        end
    end

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)

        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        Overlay.ZIndex = 50
        Overlay.Parent = DropShadowHolder

        local Dialog = Instance.new("Frame") -- Changed to Frame for gradient
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.BackgroundColor3 = Color3.fromRGB(20, 15, 30) -- Dark purple base
        Dialog.BackgroundTransparency = 0.1
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        local UICorner = Instance.new("UICorner", Dialog)
        UICorner.CornerRadius = UDim.new(0, 8)
        
        -- Add purple-cyan gradient to dialog
        local DialogMainGradient = Instance.new("UIGradient")
        DialogMainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(80, 40, 120)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(100, 180, 255))
        })
        DialogMainGradient.Rotation = 135
        DialogMainGradient.Parent = Dialog

        local DialogGlow = Instance.new("Frame")
        DialogGlow.Size = UDim2.new(0, 310, 0, 160)
        DialogGlow.Position = UDim2.new(0.5, -155, 0.5, -80)
        DialogGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DialogGlow.BackgroundTransparency = 0.75
        DialogGlow.BorderSizePixel = 0
        DialogGlow.ZIndex = 50
        DialogGlow.Parent = Overlay

        local GlowCorner = Instance.new("UICorner", DialogGlow)
        GlowCorner.CornerRadius = UDim.new(0, 10)

        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(138, 43, 226)),   -- Purple
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 240, 255)),  -- Bright cyan
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(138, 43, 226))    -- Purple
        })
        Gradient.Rotation = 90
        Gradient.Parent = DialogGlow

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.Position = UDim2.new(0, 0, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = "Vyper Window"
        Title.TextSize = 22
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.ZIndex = 52
        Title.Parent = Dialog

        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 60)
        Message.Position = UDim2.new(0, 10, 0, 30)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = "Do you want to close this window?\nYou will not be able to open it again"
        Message.TextSize = 14
        Message.TextColor3 = Color3.fromRGB(200, 200, 200)
        Message.TextWrapped = true
        Message.ZIndex = 52
        Message.Parent = Dialog

        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 35)
        Yes.Position = UDim2.new(0.05, 0, 1, -55)
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 0.92
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 15
        Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        Yes.TextTransparency = 0.3
        Yes.ZIndex = 52
        Yes.Name = "Yes"
        Yes.Parent = Dialog
        Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)
        
        -- Add gradient to Yes button
        local YesGradient = Instance.new("UIGradient")
        YesGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
        })
        YesGradient.Rotation = 45
        YesGradient.Parent = Yes

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 35)
        Cancel.Position = UDim2.new(0.5, 10, 1, -55)
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.BackgroundTransparency = 0.92
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 15
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextTransparency = 0.3
        Cancel.ZIndex = 52
        Cancel.Name = "Cancel"
        Cancel.Parent = Dialog
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)
        
        -- Add gradient to Cancel button
        local CancelGradient = Instance.new("UIGradient")
        CancelGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
        })
        CancelGradient.Rotation = 45
        CancelGradient.Parent = Cancel

        Yes.MouseButton1Click:Connect(function()
            if Vyper then Vyper:Destroy() end
            if game.CoreGui:FindFirstChild("ToggleUIButton") then
                game.CoreGui.ToggleUIButton:Destroy()
            end
        end)

        Cancel.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end)

    local ToggleKey = Enum.KeyCode.F3
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end
    end)

    function GuiFunc:ToggleUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"

        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 45, 0, 45)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = "rbxassetid://" .. GuiConfig.Image
        MainButton.ScaleType = Enum.ScaleType.Fit

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = MainButton


        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end)

        local dragging = false
        local dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            MainButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    GuiFunc:ToggleUI()

    DropShadowHolder.Size = UDim2.new(0, 115 + TextLabel.TextBounds.X + 1 + TextLabel1.TextBounds.X, 0, 350)
    MakeDraggable(Top, DropShadowHolder)

    local MoreBlur = Instance.new("Frame");
    local DropShadowHolder1 = Instance.new("Frame");
    local DropShadow1 = Instance.new("ImageLabel");
    local UICorner28 = Instance.new("UICorner");
    local ConnectButton = Instance.new("TextButton");

    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers

    DropShadowHolder1.BackgroundTransparency = 1
    DropShadowHolder1.BorderSizePixel = 0
    DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder1.ZIndex = 0
    DropShadowHolder1.Name = "DropShadowHolder"
    DropShadowHolder1.Parent = MoreBlur

    DropShadow1.Image = "rbxassetid://6015897843"
    DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow1.ImageTransparency = 1
    DropShadow1.ScaleType = Enum.ScaleType.Slice
    DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow1.BackgroundTransparency = 1
    DropShadow1.BorderSizePixel = 0
    DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow1.Size = UDim2.new(1, 35, 1, 35)
    DropShadow1.ZIndex = 0
    DropShadow1.Name = "DropShadow"
    DropShadow1.Parent = DropShadowHolder1

    UICorner28.Parent = MoreBlur

    ConnectButton.Font = Enum.Font.SourceSans
    ConnectButton.Text = ""
    ConnectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.TextSize = 14
    ConnectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ConnectButton.BorderSizePixel = 0
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    local DropdownSelect = Instance.new("Frame");
    local UICorner36 = Instance.new("UICorner");
    local UIStroke14 = Instance.new("UIStroke");
    local DropdownSelectReal = Instance.new("Frame");
    local DropdownFolder = Instance.new("Folder");
    local DropPageLayout = Instance.new("UIPageLayout");

    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(20, 15, 30) -- Match Main window base
    DropdownSelect.BackgroundTransparency = 0.15 -- Match transparency
    DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur
    
    -- Add gradient to dropdown select
    local DropSelectGradient = Instance.new("UIGradient")
    DropSelectGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
    })
    DropSelectGradient.Rotation = 90
    DropSelectGradient.Parent = DropdownSelect

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)
    UICorner36.CornerRadius = UDim.new(0, 3)
    UICorner36.Parent = DropdownSelect

    UIStroke14.Color = Color3.fromRGB(138, 43, 226)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect

    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White base to make gradient vibrant!
    DropdownSelectReal.BackgroundTransparency = 0.3 -- Match Main window overlay transparency
    DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.LayoutOrder = 1
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect
    
    -- Add same gradient overlay style as main window
    local DropRealGradient = Instance.new("UIGradient")
    DropRealGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(80, 40, 120)),   -- Dark purple
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(138, 43, 226)),  -- Purple
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(100, 150, 255)), -- Cyan-blue
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(150, 240, 255))  -- Bright cyan
    })
    DropRealGradient.Rotation = 135 -- Same diagonal as main window
    DropRealGradient.Parent = DropdownSelectReal

    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.009999999776482582
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder
    --// Tabs
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0
    function Tabs:AddTab(TabConfig)
        local TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame");
        local UIListLayout1 = Instance.new("UIListLayout");

        ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80.00000283122063, 80.00000283122063, 80.00000283122063)
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ScrolLayers.BackgroundTransparency = 0.9990000128746033
        ScrolLayers.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        local Tab = Instance.new("Frame");
        local UICorner3 = Instance.new("UICorner");
        local TabButton = Instance.new("TextButton");
        local TabName = Instance.new("TextLabel")
        local FeatureImg = Instance.new("ImageLabel");
        local UIStroke2 = Instance.new("UIStroke");
        local UICorner4 = Instance.new("UICorner");

        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        if CountTab == 0 then
            Tab.BackgroundTransparency = 0.9200000166893005
        else
            Tab.BackgroundTransparency = 0.9990000128746033
        end
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab

        UICorner3.CornerRadius = UDim.new(0, 4)
        UICorner3.Parent = Tab

        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.9990000128746033
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        TabName.Font = Enum.Font.GothamBold
        TabName.Text = "| " .. tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 13
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabName.BackgroundTransparency = 0.9990000128746033
        TabName.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabName.BorderSizePixel = 0
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 30, 0, 0)
        TabName.Name = "TabName"
        TabName.Parent = Tab

        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.9990000128746033
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab
        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            local ChooseFrame = Instance.new("Frame");
            ChooseFrame.BackgroundColor3 = GuiConfig.Color
            ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
            ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.Parent = Tab

            UIStroke2.Color = GuiConfig.Color
            UIStroke2.Thickness = 1.600000023841858
            UIStroke2.Parent = ChooseFrame

            UICorner4.Parent = ChooseFrame
        end

        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then
                FeatureImg.Image = Icons[TabConfig.Icon]
            else
                FeatureImg.Image = TabConfig.Icon
            end
        end

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            local FrameChoose
            for a, s in ScrollTab:GetChildren() do
                for i, v in s:GetChildren() do
                    if v.Name == "ChooseFrame" then
                        FrameChoose = v
                        break
                    end
                end
            end
            if FrameChoose ~= nil and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in ScrollTab:GetChildren() do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(
                            TabFrame,
                            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                            { BackgroundTransparency = 0.9990000128746033 }
                        ):Play()
                    end
                end
                TweenService:Create(
                    Tab,
                    TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.9200000166893005 }
                ):Play()
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder)) }
                ):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = UDim2.new(0, 1, 0, 20) }
                ):Play()
                task.wait(0.2)
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = UDim2.new(0, 1, 0, 12) }
                ):Play()
            end
        end)
        --// Section
        local Sections = {}
        local CountSection = 0
        function Sections:AddSection(Title, AlwaysOpen)
            local Title = Title or "Title"
            local Section = Instance.new("Frame");
            local SectionDecideFrame = Instance.new("Frame");
            local UICorner1 = Instance.new("UICorner");
            local UIGradient = Instance.new("UIGradient");

            Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Section.BackgroundTransparency = 0.9990000128746033
            Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.LayoutOrder = 1
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal = Instance.new("Frame");
            local UICorner = Instance.new("UICorner");
            local UIStroke = Instance.new("UIStroke");
            local SectionButton = Instance.new("TextButton");
            local FeatureFrame = Instance.new("Frame");
            local FeatureImg = Instance.new("ImageLabel");
            local SectionTitle = Instance.new("TextLabel");

            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White for gradient
            SectionReal.BackgroundTransparency = 0.92
            SectionReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionReal.BorderSizePixel = 0
            SectionReal.LayoutOrder = 1
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, 1, 0, 30)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section
            
            -- Add gradient for 3D effect
            local SectionGradient = Instance.new("UIGradient")
            SectionGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(100, 50, 150)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 226)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(100, 180, 255))
            })
            SectionGradient.Rotation = 90
            SectionGradient.Parent = SectionReal
            
            -- Add glow stroke for 3D depth
            local SectionGlow = Instance.new("UIStroke")
            SectionGlow.Color = Color3.fromRGB(150, 100, 255)
            SectionGlow.Thickness = 1
            SectionGlow.Transparency = 0.7
            SectionGlow.Parent = SectionReal

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = SectionReal

            SectionButton.Font = Enum.Font.SourceSans
            SectionButton.Text = ""
            SectionButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            SectionButton.TextSize = 14
            SectionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionButton.BackgroundTransparency = 0.9990000128746033
            SectionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionButton.BorderSizePixel = 0
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal

            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BackgroundTransparency = 0.9990000128746033
            FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BorderSizePixel = 0
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Name = "FeatureFrame"
            FeatureFrame.Parent = SectionReal

            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            FeatureImg.BackgroundTransparency = 0.9990000128746033
            FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            FeatureImg.BorderSizePixel = 0
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Name = "FeatureImg"
            FeatureImg.Parent = FeatureFrame

            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.TextYAlignment = Enum.TextYAlignment.Top
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.BackgroundTransparency = 0.9990000128746033
            SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionTitle.BorderSizePixel = 0
            SectionTitle.Position = UDim2.new(0, 10, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionReal

            SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
            SectionDecideFrame.BorderSizePixel = 0
            SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
            SectionDecideFrame.Name = "SectionDecideFrame"
            SectionDecideFrame.Parent = Section

            UICorner1.Parent = SectionDecideFrame

            UIGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),   -- Purple
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 240, 255)), -- Bright cyan
                ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))    -- Purple
            }
            UIGradient.Parent = SectionDecideFrame

            --// Section Add
            local SectionAdd = Instance.new("Frame");
            local UICorner8 = Instance.new("UICorner");
            local UIListLayout2 = Instance.new("UIListLayout");

            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionAdd.BackgroundTransparency = 0.9990000128746033
            SectionAdd.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionAdd.BorderSizePixel = 0
            SectionAdd.ClipsDescendants = true
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 38)
            SectionAdd.Size = UDim2.new(1, 0, 0, 100)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section

            UICorner8.CornerRadius = UDim.new(0, 2)
            UICorner8.Parent = SectionAdd

            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = false

            local function UpdateSizeScroll()
                local OffsetY = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" then
                        OffsetY = OffsetY + 3 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeYWitdh = 38
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                        end
                    end
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 90 }):Play()
                    TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, SectionSizeYWitdh) })
                        :Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.5),
                        { Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38) }):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    task.wait(0.5)
                    UpdateSizeScroll()
                end
            end

            if AlwaysOpen == true then
                SectionButton:Destroy()
                FeatureFrame:Destroy()
                OpenSection = true
                UpdateSizeSection()
            elseif AlwaysOpen == false then
                OpenSection = true
                UpdateSizeSection()
            else
                OpenSection = false
            end

            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    if OpenSection then
                        TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 0 }):Play()
                        TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, 30) }):Play()
                        TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(0, 0, 0, 2) })
                            :Play()
                        OpenSection = false
                        task.wait(0.5)
                        UpdateSizeScroll()
                    else
                        OpenSection = true
                        UpdateSizeSection()
                    end
                end)
            end

            if AlwaysOpen == true or AlwaysOpen == false then
                OpenSection = true
                local SectionSizeYWitdh = 38
                for _, v in SectionAdd:GetChildren() do
                    if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                        SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                    end
                end
                FeatureFrame.Rotation = 90
                Section.Size = UDim2.new(1, 1, 0, SectionSizeYWitdh)
                SectionAdd.Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38)
                SectionDecideFrame.Size = UDim2.new(1, 0, 0, 2)
                UpdateSizeScroll()
            end

            SectionAdd.ChildAdded:Connect(UpdateSizeSection)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)

            local layout = ScrolLayers:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                end)
            end

            local Items = {}
            local CountItem = 0

            function Items:AddParagraph(ParagraphConfig)
                local ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                local ParagraphFunc = {}

                local Paragraph = Instance.new("Frame")
                local UICorner14 = Instance.new("UICorner")
                local ParagraphTitle = Instance.new("TextLabel")
                local ParagraphContent = Instance.new("TextLabel")

                Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Paragraph.BackgroundTransparency = 0.92
                Paragraph.BorderSizePixel = 0
                Paragraph.LayoutOrder = CountItem
                Paragraph.Size = UDim2.new(1, 0, 0, 46)
                Paragraph.Name = "Paragraph"
                Paragraph.Parent = SectionAdd
                
                -- Add gradient
                local ParagraphGradient = Instance.new("UIGradient")
                ParagraphGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                ParagraphGradient.Rotation = 45
                ParagraphGradient.Parent = Paragraph

                UICorner14.CornerRadius = UDim.new(0, 4)
                UICorner14.Parent = Paragraph

                local iconOffset = 10
                if ParagraphConfig.Icon then
                    local IconImg = Instance.new("ImageLabel")
                    IconImg.Size = UDim2.new(0, 20, 0, 20)
                    IconImg.Position = UDim2.new(0, 8, 0, 12)
                    IconImg.BackgroundTransparency = 1
                    IconImg.Name = "ParagraphIcon"
                    IconImg.Parent = Paragraph

                    if Icons and Icons[ParagraphConfig.Icon] then
                        IconImg.Image = Icons[ParagraphConfig.Icon]
                    else
                        IconImg.Image = ParagraphConfig.Icon
                    end

                    iconOffset = 30
                end

                ParagraphTitle.Font = Enum.Font.GothamBold
                ParagraphTitle.Text = ParagraphConfig.Title
                ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ParagraphTitle.TextSize = 13
                ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
                ParagraphTitle.BackgroundTransparency = 1
                ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
                ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
                ParagraphTitle.Name = "ParagraphTitle"
                ParagraphTitle.Parent = Paragraph

                ParagraphContent.Font = Enum.Font.Gotham
                ParagraphContent.Text = ParagraphConfig.Content
                ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ParagraphContent.TextSize = 12
                ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
                ParagraphContent.BackgroundTransparency = 1
                ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 25)
                ParagraphContent.Name = "ParagraphContent"
                ParagraphContent.TextWrapped = false
                ParagraphContent.RichText = true
                ParagraphContent.Parent = Paragraph

                ParagraphContent.Size = UDim2.new(1, -16, 0, ParagraphContent.TextBounds.Y)

                local ParagraphButton
                if ParagraphConfig.ButtonText then
                    ParagraphButton = Instance.new("TextButton")
                    ParagraphButton.Position = UDim2.new(0, 10, 0, 42)
                    ParagraphButton.Size = UDim2.new(1, -22, 0, 28)
                    ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ParagraphButton.BackgroundTransparency = 0.935
                    ParagraphButton.Font = Enum.Font.GothamBold
                    ParagraphButton.TextSize = 12
                    ParagraphButton.TextTransparency = 0.3
                    ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ParagraphButton.Text = ParagraphConfig.ButtonText
                    ParagraphButton.Parent = Paragraph

                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 6)
                    btnCorner.Parent = ParagraphButton

                    if ParagraphConfig.ButtonCallback then
                        ParagraphButton.MouseButton1Click:Connect(ParagraphConfig.ButtonCallback)
                    end
                end

                local function UpdateSize()
                    local totalHeight = ParagraphContent.TextBounds.Y + 33
                    if ParagraphButton then
                        totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 5
                    end
                    Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
                end

                UpdateSize()

                ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

                function ParagraphFunc:SetContent(content)
                    content = content or "Content"
                    ParagraphContent.Text = content
                    UpdateSize()
                end

                CountItem = CountItem + 1
                return ParagraphFunc
            end

            function Items:AddPanel(PanelConfig)
                PanelConfig = PanelConfig or {}
                PanelConfig.Title = PanelConfig.Title or "Title"
                PanelConfig.Content = PanelConfig.Content or ""
                PanelConfig.Placeholder = PanelConfig.Placeholder or nil
                PanelConfig.Default = PanelConfig.Default or ""
                PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
                PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
                PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
                PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or
                    function() end

                local configKey = "Panel_" .. PanelConfig.Title
                if ConfigData[configKey] ~= nil then
                    PanelConfig.Default = ConfigData[configKey]
                end

                local PanelFunc = { Value = PanelConfig.Default }

                local baseHeight = 50

                if PanelConfig.Placeholder then
                    baseHeight = baseHeight + 40
                end

                if PanelConfig.SubButtonText then
                    baseHeight = baseHeight + 40
                else
                    baseHeight = baseHeight + 36
                end

                local Panel = Instance.new("Frame")
                Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Panel.BackgroundTransparency = 0.92
                Panel.Size = UDim2.new(1, 0, 0, baseHeight)
                Panel.LayoutOrder = CountItem
                Panel.Parent = SectionAdd
                
                -- Add gradient
                local PanelGradient = Instance.new("UIGradient")
                PanelGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                PanelGradient.Rotation = 45
                PanelGradient.Parent = Panel

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Panel

                local Title = Instance.new("TextLabel")
                Title.Font = Enum.Font.GothamBold
                Title.Text = PanelConfig.Title
                Title.TextSize = 13
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 10)
                Title.Size = UDim2.new(1, -20, 0, 13)
                Title.Parent = Panel

                local Content = Instance.new("TextLabel")
                Content.Font = Enum.Font.Gotham
                Content.Text = PanelConfig.Content
                Content.TextSize = 12
                Content.TextColor3 = Color3.fromRGB(255, 255, 255)
                Content.TextTransparency = 0
                Content.TextXAlignment = Enum.TextXAlignment.Left
                Content.BackgroundTransparency = 1
                Content.RichText = true
                Content.Position = UDim2.new(0, 10, 0, 28)
                Content.Size = UDim2.new(1, -20, 0, 14)
                Content.Parent = Panel

                local InputBox
                if PanelConfig.Placeholder then
                    local InputFrame = Instance.new("Frame")
                    InputFrame.AnchorPoint = Vector2.new(0.5, 0)
                    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    InputFrame.BackgroundTransparency = 0.95
                    InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
                    InputFrame.Size = UDim2.new(1, -20, 0, 30)
                    InputFrame.Parent = Panel

                    local inputCorner = Instance.new("UICorner")
                    inputCorner.CornerRadius = UDim.new(0, 4)
                    inputCorner.Parent = InputFrame

                    InputBox = Instance.new("TextBox")
                    InputBox.Font = Enum.Font.GothamBold
                    InputBox.PlaceholderText = PanelConfig.Placeholder
                    InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                    InputBox.Text = PanelConfig.Default
                    InputBox.TextSize = 11
                    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    InputBox.BackgroundTransparency = 1
                    InputBox.TextXAlignment = Enum.TextXAlignment.Left
                    InputBox.Size = UDim2.new(1, -10, 1, -6)
                    InputBox.Position = UDim2.new(0, 5, 0, 3)
                    InputBox.Parent = InputFrame
                end

                local yBtn = 0
                if PanelConfig.Placeholder then
                    yBtn = 88
                else
                    yBtn = 48
                end

                local ButtonMain = Instance.new("TextButton")
                ButtonMain.Font = Enum.Font.GothamBold
                ButtonMain.Text = PanelConfig.ButtonText
                ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonMain.TextSize = 12
                ButtonMain.TextTransparency = 0.3
                ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ButtonMain.BackgroundTransparency = 0.935
                ButtonMain.Size = PanelConfig.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
                ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
                ButtonMain.Parent = Panel

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 6)
                btnCorner.Parent = ButtonMain

                ButtonMain.MouseButton1Click:Connect(function()
                    PanelConfig.ButtonCallback(InputBox and InputBox.Text or "")
                end)

                if PanelConfig.SubButtonText then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = PanelConfig.SubButtonText
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.TextSize = 12
                    SubButton.TextTransparency = 0.3
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.935
                    SubButton.Size = UDim2.new(0.5, -12, 0, 30)
                    SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
                    SubButton.Parent = Panel

                    local subCorner = Instance.new("UICorner")
                    subCorner.CornerRadius = UDim.new(0, 6)
                    subCorner.Parent = SubButton

                    SubButton.MouseButton1Click:Connect(function()
                        PanelConfig.SubButtonCallback(InputBox and InputBox.Text or "")
                    end)
                end

                if InputBox then
                    InputBox.FocusLost:Connect(function()
                        PanelFunc.Value = InputBox.Text
                        ConfigData[configKey] = InputBox.Text
                        SaveConfig()
                    end)
                end

                function PanelFunc:GetInput()
                    return InputBox and InputBox.Text or ""
                end

                CountItem = CountItem + 1
                return PanelFunc
            end

            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
                ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end

                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 0.92
                Button.Size = UDim2.new(1, 0, 0, 40)
                Button.LayoutOrder = CountItem
                Button.Parent = SectionAdd
                
                -- Add gradient
                local ButtonGradient = Instance.new("UIGradient")
                ButtonGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                ButtonGradient.Rotation = 45
                ButtonGradient.Parent = Button

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Button

                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = ButtonConfig.Title
                MainButton.TextSize = 12
                MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.TextTransparency = 0.3
                MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.BackgroundTransparency = 0.935
                MainButton.Size = ButtonConfig.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
                MainButton.Position = UDim2.new(0, 6, 0, 5)
                MainButton.Parent = Button

                local mainCorner = Instance.new("UICorner")
                mainCorner.CornerRadius = UDim.new(0, 4)
                mainCorner.Parent = MainButton

                MainButton.MouseButton1Click:Connect(ButtonConfig.Callback)

                if ButtonConfig.SubTitle then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = ButtonConfig.SubTitle
                    SubButton.TextSize = 12
                    SubButton.TextTransparency = 0.3
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.935
                    SubButton.Size = UDim2.new(0.5, -8, 1, -10)
                    SubButton.Position = UDim2.new(0.5, 2, 0, 5)
                    SubButton.Parent = Button

                    local subCorner = Instance.new("UICorner")
                    subCorner.CornerRadius = UDim.new(0, 4)
                    subCorner.Parent = SubButton

                    SubButton.MouseButton1Click:Connect(ButtonConfig.SubCallback)
                end

                CountItem = CountItem + 1
            end

            function Items:AddToggle(ToggleConfig)
                local ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Title"
                ToggleConfig.Title2 = ToggleConfig.Title2 or ""
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local configKey = "Toggle_" .. ToggleConfig.Title
                if ConfigData[configKey] ~= nil then
                    ToggleConfig.Default = ConfigData[configKey]
                end

                local ToggleFunc = { Value = ToggleConfig.Default }

                local Toggle = Instance.new("Frame")
                local UICorner20 = Instance.new("UICorner")
                local ToggleTitle = Instance.new("TextLabel")
                local ToggleContent = Instance.new("TextLabel")
                local ToggleButton = Instance.new("TextButton")
                local FeatureFrame2 = Instance.new("Frame")
                local UICorner22 = Instance.new("UICorner")
                local UIStroke8 = Instance.new("UIStroke")
                local ToggleCircle = Instance.new("Frame")
                local UICorner23 = Instance.new("UICorner")

                Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.BackgroundTransparency = 0.92
                Toggle.BorderSizePixel = 0
                Toggle.LayoutOrder = CountItem
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionAdd
                
                -- Add gradient
                local ToggleGradient = Instance.new("UIGradient")
                ToggleGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                ToggleGradient.Rotation = 45
                ToggleGradient.Parent = Toggle

                UICorner20.CornerRadius = UDim.new(0, 4)
                UICorner20.Parent = Toggle

                ToggleTitle.Font = Enum.Font.GothamBold
                ToggleTitle.Text = ToggleConfig.Title
                ToggleTitle.TextSize = 13
                ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
                ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
                ToggleTitle.Name = "ToggleTitle"
                ToggleTitle.Parent = Toggle

                local ToggleTitle2 = Instance.new("TextLabel")
                ToggleTitle2.Font = Enum.Font.GothamBold
                ToggleTitle2.Text = ToggleConfig.Title2
                ToggleTitle2.TextSize = 12
                ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
                ToggleTitle2.BackgroundTransparency = 1
                ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
                ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
                ToggleTitle2.Name = "ToggleTitle2"
                ToggleTitle2.Parent = Toggle

                ToggleContent.Font = Enum.Font.GothamBold
                ToggleContent.Text = ToggleConfig.Content
                ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleContent.TextSize = 12
                ToggleContent.TextTransparency = 0.6
                ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
                ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
                ToggleContent.BackgroundTransparency = 1
                ToggleContent.Size = UDim2.new(1, -100, 0, 12)
                ToggleContent.Name = "ToggleContent"
                ToggleContent.Parent = Toggle

                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, 57)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 36)
                    ToggleTitle2.Visible = true
                else
                    Toggle.Size = UDim2.new(1, 0, 0, 46)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 23)
                    ToggleTitle2.Visible = false
                end

                ToggleContent.Size = UDim2.new(1, -100, 0,
                    12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
                ToggleContent.TextWrapped = true
                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
                else
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                end

                ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    ToggleContent.TextWrapped = false
                    ToggleContent.Size = UDim2.new(1, -100, 0,
                        12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
                    if ToggleConfig.Title2 ~= "" then
                        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
                    else
                        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                    end
                    ToggleContent.TextWrapped = true
                    UpdateSizeSection()
                end)

                ToggleButton.Font = Enum.Font.SourceSans
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = Toggle

                FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
                FeatureFrame2.BackgroundTransparency = 0.92
                FeatureFrame2.BorderSizePixel = 0
                FeatureFrame2.Position = UDim2.new(1, -15, 0.5, 0)
                FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
                FeatureFrame2.Name = "FeatureFrame"
                FeatureFrame2.Parent = Toggle

                UICorner22.Parent = FeatureFrame2

                UIStroke8.Color = Color3.fromRGB(255, 255, 255)
                UIStroke8.Thickness = 2
                UIStroke8.Transparency = 0.9
                UIStroke8.Parent = FeatureFrame2

                ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Parent = FeatureFrame2

                UICorner23.CornerRadius = UDim.new(0, 15)
                UICorner23.Parent = ToggleCircle

                ToggleButton.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)

                function ToggleFunc:Set(Value)
                    if typeof(ToggleConfig.Callback) == "function" then
                        local ok, err = pcall(function()
                            ToggleConfig.Callback(Value)
                        end)
                        if not ok then warn("Toggle Callback error:", err) end
                    end
                    ConfigData[configKey] = Value
                    SaveConfig()
                    if Value then
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) })
                            :Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 })
                            :Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                            { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                    else
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2),
                            { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2),
                            { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                            { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
                    end
                end

                ToggleFunc:Set(ToggleFunc.Value)
                CountItem = CountItem + 1
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            function Items:AddSlider(SliderConfig)
                local SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Content = SliderConfig.Content or ""
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local configKey = "Slider_" .. SliderConfig.Title
                if ConfigData[configKey] ~= nil then
                    SliderConfig.Default = ConfigData[configKey]
                end

                local SliderFunc = { Value = SliderConfig.Default }

                local Slider = Instance.new("Frame");
                local UICorner15 = Instance.new("UICorner");
                local SliderTitle = Instance.new("TextLabel");
                local SliderContent = Instance.new("TextLabel");
                local SliderInput = Instance.new("Frame");
                local UICorner16 = Instance.new("UICorner");
                local TextBox = Instance.new("TextBox");
                local SliderFrame = Instance.new("Frame");
                local UICorner17 = Instance.new("UICorner");
                local SliderDraggable = Instance.new("Frame");
                local UICorner18 = Instance.new("UICorner");
                local UIStroke5 = Instance.new("UIStroke");
                local SliderCircle = Instance.new("Frame");
                local UICorner19 = Instance.new("UICorner");
                local UIStroke6 = Instance.new("UIStroke");
                local UIStroke7 = Instance.new("UIStroke");

                Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Slider.BackgroundTransparency = 0.92
                Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Slider.BorderSizePixel = 0
                Slider.LayoutOrder = CountItem
                Slider.Size = UDim2.new(1, 0, 0, 46)
                Slider.Name = "Slider"
                Slider.Parent = SectionAdd
                
                -- Add gradient
                local SliderGradient = Instance.new("UIGradient")
                SliderGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                SliderGradient.Rotation = 45
                SliderGradient.Parent = Slider

                UICorner15.CornerRadius = UDim.new(0, 4)
                UICorner15.Parent = Slider

                SliderTitle.Font = Enum.Font.GothamBold
                SliderTitle.Text = SliderConfig.Title
                SliderTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
                SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderTitle.BackgroundTransparency = 0.9990000128746033
                SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderTitle.BorderSizePixel = 0
                SliderTitle.Position = UDim2.new(0, 10, 0, 10)
                SliderTitle.Size = UDim2.new(1, -180, 0, 13)
                SliderTitle.Name = "SliderTitle"
                SliderTitle.Parent = Slider

                SliderContent.Font = Enum.Font.GothamBold
                SliderContent.Text = SliderConfig.Content
                SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderContent.TextSize = 12
                SliderContent.TextTransparency = 0.6000000238418579
                SliderContent.TextXAlignment = Enum.TextXAlignment.Left
                SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
                SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderContent.BackgroundTransparency = 0.9990000128746033
                SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderContent.BorderSizePixel = 0
                SliderContent.Position = UDim2.new(0, 10, 0, 25)
                SliderContent.Size = UDim2.new(1, -180, 0, 12)
                SliderContent.Name = "SliderContent"
                SliderContent.Parent = Slider

                SliderContent.Size = UDim2.new(1, -180, 0,
                    12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
                SliderContent.TextWrapped = true
                Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

                SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    SliderContent.TextWrapped = false
                    SliderContent.Size = UDim2.new(1, -180, 0,
                        12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
                    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
                    SliderContent.TextWrapped = true
                    UpdateSizeSection()
                end)

                SliderInput.AnchorPoint = Vector2.new(0, 0.5)
                SliderInput.BackgroundColor3 = GuiConfig.Color
                SliderInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderInput.BackgroundTransparency = 1
                SliderInput.BorderSizePixel = 0
                SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
                SliderInput.Size = UDim2.new(0, 28, 0, 20)
                SliderInput.Name = "SliderInput"
                SliderInput.Parent = Slider

                UICorner16.CornerRadius = UDim.new(0, 2)
                UICorner16.Parent = SliderInput

                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = "90"
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.TextSize = 13
                TextBox.TextWrapped = true
                TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                TextBox.BackgroundTransparency = 0.9990000128746033
                TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextBox.BorderSizePixel = 0
                TextBox.Position = UDim2.new(0, -1, 0, 0)
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Parent = SliderInput

                SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderFrame.BackgroundTransparency = 0.800000011920929
                SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
                SliderFrame.Size = UDim2.new(0, 100, 0, 3)
                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = Slider

                UICorner17.Parent = SliderFrame

                SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
                SliderDraggable.BackgroundColor3 = GuiConfig.Color
                SliderDraggable.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderDraggable.BorderSizePixel = 0
                SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
                SliderDraggable.Size = UDim2.new(0.899999976, 0, 0, 1)
                SliderDraggable.Name = "SliderDraggable"
                SliderDraggable.Parent = SliderFrame

                UICorner18.Parent = SliderDraggable

                SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
                SliderCircle.BackgroundColor3 = GuiConfig.Color
                SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderCircle.BorderSizePixel = 0
                SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
                SliderCircle.Size = UDim2.new(0, 8, 0, 8)
                SliderCircle.Name = "SliderCircle"
                SliderCircle.Parent = SliderDraggable

                UICorner19.Parent = SliderCircle

                UIStroke6.Color = GuiConfig.Color
                UIStroke6.Parent = SliderCircle

                local Dragging = false
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then
                        Result = Result + Factor
                    end
                    return Result
                end
                function SliderFunc:Set(Value)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    TextBox.Text = tostring(Value)
                    TweenService:Create(
                        SliderDraggable,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }
                    ):Play()

                    SliderConfig.Callback(Value)
                    ConfigData[configKey] = Value
                    SaveConfig()
                end

                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        TweenService:Create(
                            SliderCircle,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 14, 0, 14) }
                        ):Play()
                        local SizeScale = math.clamp(
                            (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                            0,
                            1
                        )
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)

                SliderFrame.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        SliderConfig.Callback(SliderFunc.Value)
                        TweenService:Create(
                            SliderCircle,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 8, 0, 8) }
                        ):Play()
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local SizeScale = math.clamp(
                            (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                            0,
                            1
                        )
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)

                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local Valid = TextBox.Text:gsub("[^%d]", "")
                    if Valid ~= "" then
                        local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
                        SliderFunc:Set(ValidNumber)
                    else
                        SliderFunc:Set(SliderConfig.Min)
                    end
                end)
                SliderFunc:Set(SliderConfig.Default)
                CountItem = CountItem + 1
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

            function Items:AddInput(InputConfig)
                local InputConfig = InputConfig or {}
                InputConfig.Title = InputConfig.Title or "Title"
                InputConfig.Content = InputConfig.Content or ""
                InputConfig.Callback = InputConfig.Callback or function() end
                InputConfig.Default = InputConfig.Default or ""

                local configKey = "Input_" .. InputConfig.Title
                if ConfigData[configKey] ~= nil then
                    InputConfig.Default = ConfigData[configKey]
                end

                local InputFunc = { Value = InputConfig.Default }

                local Input = Instance.new("Frame");
                local UICorner12 = Instance.new("UICorner");
                local InputTitle = Instance.new("TextLabel");
                local InputContent = Instance.new("TextLabel");
                local InputFrame = Instance.new("Frame");
                local UICorner13 = Instance.new("UICorner");
                local InputTextBox = Instance.new("TextBox");

                Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Input.BackgroundTransparency = 0.92
                Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Input.BorderSizePixel = 0
                Input.LayoutOrder = CountItem
                Input.Size = UDim2.new(1, 0, 0, 46)
                Input.Name = "Input"
                Input.Parent = SectionAdd
                
                -- Add gradient
                local InputGradient = Instance.new("UIGradient")
                InputGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                InputGradient.Rotation = 45
                InputGradient.Parent = Input

                UICorner12.CornerRadius = UDim.new(0, 4)
                UICorner12.Parent = Input

                InputTitle.Font = Enum.Font.GothamBold
                InputTitle.Text = InputConfig.Title or "TextBox"
                InputTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
                InputTitle.TextSize = 13
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                InputTitle.TextYAlignment = Enum.TextYAlignment.Top
                InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputTitle.BackgroundTransparency = 0.9990000128746033
                InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputTitle.BorderSizePixel = 0
                InputTitle.Position = UDim2.new(0, 10, 0, 10)
                InputTitle.Size = UDim2.new(1, -180, 0, 13)
                InputTitle.Name = "InputTitle"
                InputTitle.Parent = Input

                InputContent.Font = Enum.Font.GothamBold
                InputContent.Text = InputConfig.Content or "This is a TextBox"
                InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputContent.TextSize = 12
                InputContent.TextTransparency = 0.6000000238418579
                InputContent.TextWrapped = true
                InputContent.TextXAlignment = Enum.TextXAlignment.Left
                InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
                InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputContent.BackgroundTransparency = 0.9990000128746033
                InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputContent.BorderSizePixel = 0
                InputContent.Position = UDim2.new(0, 10, 0, 25)
                InputContent.Size = UDim2.new(1, -180, 0, 12)
                InputContent.Name = "InputContent"
                InputContent.Parent = Input

                InputContent.Size = UDim2.new(1, -180, 0,
                    12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
                InputContent.TextWrapped = true
                Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)

                InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    InputContent.TextWrapped = false
                    InputContent.Size = UDim2.new(1, -180, 0,
                        12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
                    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
                    InputContent.TextWrapped = true
                    UpdateSizeSection()
                end)

                InputFrame.AnchorPoint = Vector2.new(1, 0.5)
                InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputFrame.BackgroundTransparency = 0.949999988079071
                InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputFrame.BorderSizePixel = 0
                InputFrame.ClipsDescendants = true
                InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
                InputFrame.Size = UDim2.new(0, 148, 0, 30)
                InputFrame.Name = "InputFrame"
                InputFrame.Parent = Input

                UICorner13.CornerRadius = UDim.new(0, 4)
                UICorner13.Parent = InputFrame

                InputTextBox.CursorPosition = -1
                InputTextBox.Font = Enum.Font.GothamBold
                InputTextBox.PlaceholderColor3 = Color3.fromRGB(120.00000044703484, 120.00000044703484,
                    120.00000044703484)
                InputTextBox.PlaceholderText = "Input Here"
                InputTextBox.Text = InputConfig.Default
                InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputTextBox.TextSize = 12
                InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                InputTextBox.ClearTextOnFocus = false  -- ← TAMBAHKAN BARIS INI
                InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
                InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputTextBox.BackgroundTransparency = 0.9990000128746033
                InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputTextBox.BorderSizePixel = 0
                InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
                InputTextBox.Size = UDim2.new(1, -10, 1, -8)
                InputTextBox.Name = "InputTextBox"
                InputTextBox.Parent = InputFrame
                function InputFunc:Set(Value)
                    InputTextBox.Text = Value
                    InputFunc.Value = Value
                    InputConfig.Callback(Value)
                    ConfigData[configKey] = Value
                    SaveConfig()
                end

                InputFunc:Set(InputFunc.Value)

                InputTextBox.FocusLost:Connect(function()
                    InputFunc:Set(InputTextBox.Text)
                end)
                CountItem = CountItem + 1
                Elements[configKey] = InputFunc
                return InputFunc
            end
            
            function Items:AddDropdown(DropdownConfig)
                local DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Title"
                DropdownConfig.Content = DropdownConfig.Content or ""
                DropdownConfig.Multi = DropdownConfig.Multi or false
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
                DropdownConfig.Callback = DropdownConfig.Callback or function() end

                local configKey = "Dropdown_" .. DropdownConfig.Title
                if ConfigData[configKey] ~= nil then
                    DropdownConfig.Default = ConfigData[configKey]
                end

                local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }

                local Dropdown = Instance.new("Frame")
                local DropdownButton = Instance.new("TextButton")
                local UICorner10 = Instance.new("UICorner")
                local DropdownTitle = Instance.new("TextLabel")
                local DropdownContent = Instance.new("TextLabel")
                local SelectOptionsFrame = Instance.new("Frame")
                local UICorner11 = Instance.new("UICorner")
                local OptionSelecting = Instance.new("TextLabel")
                local OptionImg = Instance.new("ImageLabel")

                Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.BackgroundTransparency = 0.92
                Dropdown.BorderSizePixel = 0
                Dropdown.LayoutOrder = CountItem
                Dropdown.Size = UDim2.new(1, 0, 0, 46)
                Dropdown.Name = "Dropdown"
                Dropdown.Parent = SectionAdd
                
                -- Add gradient
                local DropdownGradient = Instance.new("UIGradient")
                DropdownGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                DropdownGradient.Rotation = 45
                DropdownGradient.Parent = Dropdown

                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Name = "ToggleButton"
                DropdownButton.Parent = Dropdown

                UICorner10.CornerRadius = UDim.new(0, 4)
                UICorner10.Parent = Dropdown

                DropdownTitle.Font = Enum.Font.GothamBold
                DropdownTitle.Text = DropdownConfig.Title
                DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                DropdownTitle.TextSize = 13
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
                DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
                DropdownTitle.Name = "DropdownTitle"
                DropdownTitle.Parent = Dropdown

                DropdownContent.Font = Enum.Font.GothamBold
                DropdownContent.Text = DropdownConfig.Content
                DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownContent.TextSize = 12
                DropdownContent.TextTransparency = 0.6
                DropdownContent.TextWrapped = true
                DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
                DropdownContent.BackgroundTransparency = 1
                DropdownContent.Position = UDim2.new(0, 10, 0, 25)
                DropdownContent.Size = UDim2.new(1, -180, 0, 12)
                DropdownContent.Name = "DropdownContent"
                DropdownContent.Parent = Dropdown

                SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
                SelectOptionsFrame.BackgroundTransparency = 0.95
                SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
                SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
                SelectOptionsFrame.Name = "SelectOptionsFrame"
                SelectOptionsFrame.LayoutOrder = CountDropdown
                SelectOptionsFrame.Parent = Dropdown

                UICorner11.CornerRadius = UDim.new(0, 4)
                UICorner11.Parent = SelectOptionsFrame

                DropdownButton.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
                        TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                        TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) })
                            :Play()
                    end
                end)

                OptionSelecting.Font = Enum.Font.GothamBold
                OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
                OptionSelecting.TextSize = 12
                OptionSelecting.TextTransparency = 0.6
                OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
                OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
                OptionSelecting.BackgroundTransparency = 1
                OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
                OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
                OptionSelecting.Name = "OptionSelecting"
                OptionSelecting.Parent = SelectOptionsFrame

                OptionImg.Image = "rbxassetid://16851841101"
                OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
                OptionImg.AnchorPoint = Vector2.new(1, 0.5)
                OptionImg.BackgroundTransparency = 1
                OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
                OptionImg.Size = UDim2.new(0, 25, 0, 25)
                OptionImg.Name = "OptionImg"
                OptionImg.Parent = SelectOptionsFrame

                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
                DropdownContainer.BackgroundTransparency = 1
                DropdownContainer.Parent = DropdownFolder

                local SearchBox = Instance.new("TextBox")
                SearchBox.PlaceholderText = "Search"
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.Text = ""
                SearchBox.TextSize = 12
                SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SearchBox.BackgroundTransparency = 0.92
                SearchBox.BorderSizePixel = 0
                SearchBox.Size = UDim2.new(1, 0, 0, 25)
                SearchBox.Position = UDim2.new(0, 0, 0, 0)
                SearchBox.ClearTextOnFocus = false
                SearchBox.Name = "SearchBox"
                SearchBox.Parent = DropdownContainer
                
                -- Add gradient to search box
                local SearchGradient = Instance.new("UIGradient")
                SearchGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                })
                SearchGradient.Rotation = 45
                SearchGradient.Parent = SearchBox

                local ScrollSelect = Instance.new("ScrollingFrame")
                ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
                ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
                ScrollSelect.ScrollBarImageTransparency = 1
                ScrollSelect.BorderSizePixel = 0
                ScrollSelect.BackgroundTransparency = 1
                ScrollSelect.ScrollBarThickness = 0
                ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
                ScrollSelect.Name = "ScrollSelect"
                ScrollSelect.Parent = DropdownContainer

                local UIListLayout4 = Instance.new("UIListLayout")
                UIListLayout4.Padding = UDim.new(0, 3)
                UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout4.Parent = ScrollSelect

                UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = string.lower(SearchBox.Text)
                    for _, option in pairs(ScrollSelect:GetChildren()) do
                        if option.Name == "Option" and option:FindFirstChild("OptionText") then
                            local text = string.lower(option.OptionText.Text)
                            option.Visible = query == "" or string.find(text, query, 1, true)
                        end
                    end
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)

                local DropCount = 0

                function DropdownFunc:Clear()
                    for _, DropFrame in ScrollSelect:GetChildren() do
                        if DropFrame.Name == "Option" then
                            DropFrame:Destroy()
                        end
                    end
                    DropdownFunc.Value = DropdownConfig.Multi and {} or nil
                    DropdownFunc.Options = {}
                    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                    DropCount = 0
                end

                function DropdownFunc:AddOption(option)
                    local label, value
                    if typeof(option) == "table" and option.Label and option.Value ~= nil then
                        label = tostring(option.Label)
                        value = option.Value
                    else
                        label = tostring(option)
                        value = option
                    end

                    local Option = Instance.new("Frame")
                    local OptionButton = Instance.new("TextButton")
                    local OptionText = Instance.new("TextLabel")
                    local ChooseFrame = Instance.new("Frame")
                    local UIStroke15 = Instance.new("UIStroke")
                    local UICorner38 = Instance.new("UICorner")
                    local UICorner37 = Instance.new("UICorner")

                    Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Option.BackgroundTransparency = 0.999
                    Option.Size = UDim2.new(1, 0, 0, 30)
                    Option.Name = "Option"
                    Option.Parent = ScrollSelect
                    
                    -- Add gradient to option
                    local OptionGradient = Instance.new("UIGradient")
                    OptionGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
                    })
                    OptionGradient.Rotation = 45
                    OptionGradient.Parent = Option

                    UICorner37.CornerRadius = UDim.new(0, 3)
                    UICorner37.Parent = Option

                    OptionButton.BackgroundTransparency = 1
                    OptionButton.Size = UDim2.new(1, 0, 1, 0)
                    OptionButton.Text = ""
                    OptionButton.Name = "OptionButton"
                    OptionButton.Parent = Option

                    OptionText.Font = Enum.Font.GothamBold
                    OptionText.Text = label
                    OptionText.TextSize = 13
                    OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
                    OptionText.Position = UDim2.new(0, 8, 0, 8)
                    OptionText.Size = UDim2.new(1, -100, 0, 13)
                    OptionText.BackgroundTransparency = 1
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.Name = "OptionText"
                    OptionText.Parent = Option

                    Option:SetAttribute("RealValue", value)

                    ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
                    ChooseFrame.BackgroundColor3 = GuiConfig.Color
                    ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
                    ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
                    ChooseFrame.Name = "ChooseFrame"
                    ChooseFrame.Parent = Option

                    UIStroke15.Color = GuiConfig.Color
                    UIStroke15.Thickness = 1.6
                    UIStroke15.Transparency = 0.999
                    UIStroke15.Parent = ChooseFrame
                    UICorner38.Parent = ChooseFrame

                    OptionButton.Activated:Connect(function()
                        if DropdownConfig.Multi then
                            if not table.find(DropdownFunc.Value, value) then
                                table.insert(DropdownFunc.Value, value)
                            else
                                for i, v in pairs(DropdownFunc.Value) do
                                    if v == value then
                                        table.remove(DropdownFunc.Value, i)
                                        break
                                    end
                                end
                            end
                        else
                            DropdownFunc.Value = value
                        end
                        DropdownFunc:Set(DropdownFunc.Value)
                    end)
                end

                function DropdownFunc:Set(Value)
                    if DropdownConfig.Multi then
                        DropdownFunc.Value = type(Value) == "table" and Value or {}
                    else
                        DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
                    end

                    ConfigData[configKey] = DropdownFunc.Value
                    SaveConfig()

                    local texts = {}
                    for _, Drop in ScrollSelect:GetChildren() do
                        if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                            local v = Drop:GetAttribute("RealValue")
                            local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or
                                DropdownFunc.Value == v

                            if selected then
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2),
                                    { Size = UDim2.new(0, 1, 0, 12) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 })
                                    :Play()
                                TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.92 }):Play()
                                table.insert(texts, Drop.OptionText.Text)
                            else
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1),
                                    { Size = UDim2.new(0, 0, 0, 0) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1),
                                    { Transparency = 0.999 }):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                            end
                        end
                    end

                    OptionSelecting.Text = (#texts == 0)
                        and (DropdownConfig.Multi and "Select Options" or "Select Option")
                        or table.concat(texts, ", ")

                    if DropdownConfig.Callback then
                        if DropdownConfig.Multi then
                            DropdownConfig.Callback(DropdownFunc.Value)
                        else
                            local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                            DropdownConfig.Callback(str)
                        end
                    end
                end

                function DropdownFunc:SetValue(val)
                    self:Set(val)
                end

                function DropdownFunc:GetValue()
                    return self.Value
                end

                function DropdownFunc:SetValues(newList, selecting)
                    newList = newList or {}
                    selecting = selecting or (DropdownConfig.Multi and {} or nil)
                    DropdownFunc:Clear()
                    for _, v in ipairs(newList) do
                        DropdownFunc:AddOption(v)
                    end
                    DropdownFunc.Options = newList
                    DropdownFunc:Set(selecting)
                end

                DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)

                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end

            function Items:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Parent = SectionAdd
                Divider.AnchorPoint = Vector2.new(0.5, 0)
                Divider.Position = UDim2.new(0.5, 0, 0, 0)
                Divider.Size = UDim2.new(1, 0, 0, 2)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = CountItem

                local UIGradient = Instance.new("UIGradient")
                UIGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
                }
                UIGradient.Parent = Divider

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 2)
                UICorner.Parent = Divider

                CountItem = CountItem + 1
                return Divider
            end

            function Items:AddSubSection(title)
                title = title or "Sub Section"

                local SubSection = Instance.new("Frame")
                SubSection.Name = "SubSection"
                SubSection.Parent = SectionAdd
                SubSection.BackgroundTransparency = 1
                SubSection.Size = UDim2.new(1, 0, 0, 22)
                SubSection.LayoutOrder = CountItem

                local Background = Instance.new("Frame")
                Background.Parent = SubSection
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Background.BackgroundTransparency = 0.935
                Background.BorderSizePixel = 0
                Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

                local Label = Instance.new("TextLabel")
                Label.Parent = SubSection
                Label.AnchorPoint = Vector2.new(0, 0.5)
                Label.Position = UDim2.new(0, 10, 0.5, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.GothamBold
                Label.Text = "── [ " .. title .. " ] ──"
                Label.TextColor3 = GuiConfig.Color
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left

                CountItem = CountItem + 1
                return SubSection
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end

    return Tabs
end

---end UI
---
-- King Vypers Racing V3 - Speed Hack + Spawn Car + Auto Barista LOOP
-- FIXED v2: Karakter tidak jatuh saat boost (Y velocity dibiarkan natural)
-- UPDATE v3: Tambah Auto Rejoin di Protection Section

-- Tunggu game fully loaded sebelum apapun
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- Destroy semua ScreenGui dari PlayerGui dan CoreGui sebelum load ulang
-- Ini cara paling reliable buat cegah double window saat re-execute/rejoin
pcall(function()
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui:GetAttribute("VyperWindow") then
            gui:Destroy()
        end
    end
end)
pcall(function()
    local cg = game:GetService("CoreGui")
    for _, gui in ipairs(cg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui:GetAttribute("VyperWindow") then
            gui:Destroy()
        end
    end
end)


local Window = Vyper:Window({
    Title = "KING VYPERS",
    Footer = "|DDS PREMIUM BETA",
    Color = Color3.fromRGB(100, 200, 255),
    ["Tab Width"] = 130,
    Version = 1,
    Image = "107726435417936"
})

-- Tag semua ScreenGui yang baru dibuat supaya bisa di-cleanup saat re-execute
task.defer(function()
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui:GetAttribute("VyperWindow") then
            gui:SetAttribute("VyperWindow", true)
        end
    end
    local cg = game:GetService("CoreGui")
    for _, gui in ipairs(cg:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui:GetAttribute("VyperWindow") then
            -- hanya tag yang baru (tidak ada nama vanilla roblox)
            local name = gui.Name
            if not name:find("Roblox") and not name:find("Chat") and not name:find("TopBar") then
                gui:SetAttribute("VyperWindow", true)
            end
        end
    end
end)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local UIS = game:GetService("UserInputService")
local isMobileDevice = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- =============================================
-- AUTO SKIP MAIN MENU (jalan otomatis saat execute)
-- Dipakai saat rejoin: HOME -> pilih Barista -> masuk game
-- =============================================

task.spawn(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- Tunggu mainMenuSystem ada (muncul di lobby)
    local mainMenu = playerGui:WaitForChild("mainMenuSystem", 10)
    if not mainMenu then return end

    -- Kalau menu tidak aktif, skip
    if not mainMenu.Enabled then return end

    -- Kalau MainUI sudah aktif = sudah di dalam game, skip
    local mainUI = playerGui:FindFirstChild("MainUI")
    if mainUI and mainUI.Enabled then return end

    local baseFrame = mainMenu:FindFirstChild("baseFrame")
    if not baseFrame or not baseFrame.Visible then return end

    task.wait(1.5)

    -- Helper: coba semua cara fire button yang ada
    local function clickBtn(btn)
        if not btn then return end
        
        local success = false
        -- Cara 1: getconnections (Paling Ampuh kalau disupport Executor)
        if getconnections then
            pcall(function()
                for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                    conn:Fire()
                    success = true
                end
                for _, conn in pairs(getconnections(btn.Activated)) do
                    conn:Fire()
                    success = true
                end
            end)
        end
        
        -- Cara 2: VirtualInputManager (Simulasi klik fisik mouse di tengah tombol)
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local centerX = pos.X + (size.X / 2)
            local centerY = pos.Y + (size.Y / 2)
            -- offset sedikit ke bawah judul bar / topbar (biasanya di roblox gui ditambah offset, tapi ini cukup)
            VIM:SendMouseButtonEvent(centerX, centerY + 36, 0, true, game, 1)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(centerX, centerY + 36, 0, false, game, 1)
            success = true
        end)

        -- Cara 3: firesignal / Fire()
        pcall(function() firesignal(btn.MouseButton1Click) success = true end)
        pcall(function() firesignal(btn.Activated) success = true end)
        pcall(function() btn.MouseButton1Click:Fire() success = true end)
        pcall(function() btn.Activated:Fire() success = true end)

        return success
    end

    -- Step 1: Klik PLAY di HOME screen (applySelect)
    local applySelect = nil
    pcall(function()
        applySelect = baseFrame
            :FindFirstChild("homeFrame")
            :FindFirstChild("playFrame")
            :FindFirstChild("applySelect")
    end)
    print("[AutoSkip] applySelect found:", applySelect ~= nil)
    clickBtn(applySelect)

    task.wait(1.5)

    -- Step 2: Pilih team Barista (teamFiveTeamSelect)
    local baristaBtn = nil
    pcall(function()
        baristaBtn = baseFrame
            :FindFirstChild("playFrame")
            :FindFirstChild("ScrollingFrame")
            :FindFirstChild("teamFiveTeamSelect")
    end)
    print("[AutoSkip] baristaBtn found:", baristaBtn ~= nil)
    clickBtn(baristaBtn)

    task.wait(0.8)

    -- Step 3: Klik PLAY/Deploy di TEAMS screen (deploySelect)
    local deploySelect = nil
    pcall(function()
        deploySelect = baseFrame
            :FindFirstChild("playFrame")
            :FindFirstChild("deploySelect")
    end)
    print("[AutoSkip] deploySelect found:", deploySelect ~= nil)
    clickBtn(deploySelect)

    -- Step 4: Tunggu masuk game = MainUI jadi Enabled
    -- (mainMenu.Enabled kadang tidak berubah, jadi cek MainUI saja)
    local timeout = tick() + 30
    local entered = false
    while tick() < timeout do
        local mui = playerGui:FindFirstChild("MainUI")
        if mui and mui.Enabled then
            entered = true
            break
        end
        task.wait(0.5)
    end
    print("[AutoSkip] Entered game:", entered)

    task.wait(3) -- buffer biar character & game load sempurna

    -- Step 5: Auto trigger Barista kalau user sudah aktifin
    if entered and baristaRunning == false and SpawnCar.SelectedCar and SpawnCar.SelectedCar ~= "Refresh dulu..." then
        print("[AutoSkip] Auto starting Barista loop...")
        task.spawn(startBaristaLoop)
    end
end)

-- =============================================
-- HELPER: Ambil tombol Gas dari Interface
-- =============================================

local function getGasButton()
    local interface = LocalPlayer.PlayerGui:FindFirstChild("Interface")
    if not interface then return nil end
    local buttons = interface:FindFirstChild("Buttons")
    if not buttons then return nil end
    return buttons:FindFirstChild("Gas")
end

-- =============================================
-- VEHICLE SPEED MODULE
-- =============================================

local VehicleSpeed = {}
VehicleSpeed.Enabled = false
VehicleSpeed.CurrentSpeed = 100
VehicleSpeed.BoostActive = false
VehicleSpeed.BoostLoop = nil
VehicleSpeed.DecelActive = false
VehicleSpeed.DecelLoop = nil
VehicleSpeed.InputConn1 = nil
VehicleSpeed.InputConn2 = nil
VehicleSpeed._liveSpeed = 0

local function findMyMotor()
    local myName = LocalPlayer.Name
    for _, v in pairs(Workspace:GetChildren()) do
        if v.Name:match(myName) and v.Name:match("Montors") then
            return v
        end
    end
    return nil
end

local function getMotorPrimaryPart()
    local motor = findMyMotor()
    if not motor then return nil end
    return motor.PrimaryPart or motor:FindFirstChildWhichIsA("BasePart")
end

local function isRidingMotor()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Sit == true and humanoid.SeatPart ~= nil
end

-- KEY FIX: Hanya override X dan Z, biarkan Y fisika game yang handle
local function applyVelocity(p, dir, targetSpeed, blend)
    local vel = p.AssemblyLinearVelocity
    local newX = vel.X + (dir.X * targetSpeed - vel.X) * blend
    local newZ = vel.Z + (dir.Z * targetSpeed - vel.Z) * blend
    -- Y TIDAK diubah sama sekali — biarkan physics engine yang handle gravity & suspensi
    p.AssemblyLinearVelocity = Vector3.new(newX, vel.Y, newZ)
end

local function stopDecelLoop()
    VehicleSpeed.DecelActive = false
    if VehicleSpeed.DecelLoop then
        task.cancel(VehicleSpeed.DecelLoop)
        VehicleSpeed.DecelLoop = nil
    end
end

local function startBoostLoop()
    stopDecelLoop()
    if VehicleSpeed.BoostActive then return end
    VehicleSpeed.BoostActive = true
    VehicleSpeed.BoostLoop = task.spawn(function()
        local currentSpeed = VehicleSpeed._liveSpeed
        local p = getMotorPrimaryPart()
        if p then
            local vel = p.AssemblyLinearVelocity
            local flatMag = Vector3.new(vel.X, 0, vel.Z).Magnitude
            currentSpeed = math.max(currentSpeed, flatMag)
        end

        while VehicleSpeed.BoostActive and VehicleSpeed.Enabled do
            if isRidingMotor() then
                p = getMotorPrimaryPart()
                if p then
                    local dir = -p.CFrame.LookVector
                    currentSpeed = currentSpeed + (VehicleSpeed.CurrentSpeed - currentSpeed) * 0.2
                    VehicleSpeed._liveSpeed = currentSpeed
                    applyVelocity(p, dir, currentSpeed, 0.35)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopBoostLoop()
    VehicleSpeed.BoostActive = false
    if VehicleSpeed.BoostLoop then
        task.cancel(VehicleSpeed.BoostLoop)
        VehicleSpeed.BoostLoop = nil
    end
    VehicleSpeed._liveSpeed = 0
end

function VehicleSpeed.Start()
    if VehicleSpeed.Enabled then return end
    VehicleSpeed.Enabled = true

    if isMobileDevice then
        task.spawn(function()
            local gasBtn = nil
            while VehicleSpeed.Enabled and not gasBtn do
                gasBtn = getGasButton()
                if not gasBtn then task.wait(0.5) end
            end
            if not gasBtn then return end

            VehicleSpeed.InputConn1 = gasBtn.MouseButton1Down:Connect(function()
                if VehicleSpeed.Enabled then startBoostLoop() end
            end)
            VehicleSpeed.InputConn2 = gasBtn.MouseButton1Up:Connect(function()
                if VehicleSpeed.Enabled then stopBoostLoop() end
            end)
        end)
    else
        VehicleSpeed.InputConn1 = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not VehicleSpeed.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                startBoostLoop()
            end
        end)
        VehicleSpeed.InputConn2 = UIS.InputEnded:Connect(function(input, gpe)
            if not VehicleSpeed.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                if not UIS:IsKeyDown(Enum.KeyCode.W) and not UIS:IsKeyDown(Enum.KeyCode.Up) then
                    stopBoostLoop()
                end
            end
        end)
    end
end

function VehicleSpeed.Stop()
    if not VehicleSpeed.Enabled then return end
    VehicleSpeed.Enabled = false
    VehicleSpeed.BoostActive = false
    if VehicleSpeed.BoostLoop then task.cancel(VehicleSpeed.BoostLoop) VehicleSpeed.BoostLoop = nil end
    VehicleSpeed._liveSpeed = 0
    if VehicleSpeed.InputConn1 then VehicleSpeed.InputConn1:Disconnect() VehicleSpeed.InputConn1 = nil end
    if VehicleSpeed.InputConn2 then VehicleSpeed.InputConn2:Disconnect() VehicleSpeed.InputConn2 = nil end
end

function VehicleSpeed.SetSpeed(speed)
    VehicleSpeed.CurrentSpeed = speed
end

-- =============================================
-- SLOW RACE MODULE (Gradual Acceleration)
-- =============================================

local SlowRace = {}
SlowRace.Enabled = false
SlowRace.MaxSpeed = 200
SlowRace.AccelMultiplier = 3
SlowRace.BoostActive = false
SlowRace.BoostLoop = nil
SlowRace.DecelActive = false
SlowRace.DecelLoop = nil
SlowRace.InputConn1 = nil
SlowRace.InputConn2 = nil
SlowRace._liveSpeed = 0

local function stopSlowDecelLoop()
    SlowRace.DecelActive = false
    if SlowRace.DecelLoop then
        task.cancel(SlowRace.DecelLoop)
        SlowRace.DecelLoop = nil
    end
end

local function startSlowRaceLoop()
    stopSlowDecelLoop()
    if SlowRace.BoostActive then return end
    SlowRace.BoostActive = true
    SlowRace.BoostLoop = task.spawn(function()
        local currentSpeed = SlowRace._liveSpeed
        local p = getMotorPrimaryPart()
        if p then
            local vel = p.AssemblyLinearVelocity
            local flatMag = Vector3.new(vel.X, 0, vel.Z).Magnitude
            currentSpeed = math.max(currentSpeed, flatMag)
        end

        while SlowRace.BoostActive and SlowRace.Enabled do
            if isRidingMotor() then
                p = getMotorPrimaryPart()
                if p then
                    currentSpeed = math.min(
                        currentSpeed + (SlowRace.AccelMultiplier * 0.5),
                        SlowRace.MaxSpeed
                    )
                    SlowRace._liveSpeed = currentSpeed
                    local dir = -p.CFrame.LookVector
                    applyVelocity(p, dir, currentSpeed, 0.3)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopSlowRaceLoop()
    SlowRace.BoostActive = false
    if SlowRace.BoostLoop then
        task.cancel(SlowRace.BoostLoop)
        SlowRace.BoostLoop = nil
    end
    SlowRace._liveSpeed = 0
end

function SlowRace.Start()
    if SlowRace.Enabled then return end
    SlowRace.Enabled = true

    if isMobileDevice then
        task.spawn(function()
            local gasBtn = nil
            while SlowRace.Enabled and not gasBtn do
                gasBtn = getGasButton()
                if not gasBtn then task.wait(0.5) end
            end
            if not gasBtn then return end

            SlowRace.InputConn1 = gasBtn.MouseButton1Down:Connect(function()
                if SlowRace.Enabled then startSlowRaceLoop() end
            end)
            SlowRace.InputConn2 = gasBtn.MouseButton1Up:Connect(function()
                if SlowRace.Enabled then stopSlowRaceLoop() end
            end)
        end)
    else
        SlowRace.InputConn1 = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not SlowRace.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                startSlowRaceLoop()
            end
        end)
        SlowRace.InputConn2 = UIS.InputEnded:Connect(function(input, gpe)
            if not SlowRace.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                if not UIS:IsKeyDown(Enum.KeyCode.W) and not UIS:IsKeyDown(Enum.KeyCode.Up) then
                    stopSlowRaceLoop()
                end
            end
        end)
    end
end

function SlowRace.Stop()
    if not SlowRace.Enabled then return end
    SlowRace.Enabled = false
    SlowRace.BoostActive = false
    if SlowRace.BoostLoop then task.cancel(SlowRace.BoostLoop) SlowRace.BoostLoop = nil end
    SlowRace._liveSpeed = 0
    if SlowRace.InputConn1 then SlowRace.InputConn1:Disconnect() SlowRace.InputConn1 = nil end
    if SlowRace.InputConn2 then SlowRace.InputConn2:Disconnect() SlowRace.InputConn2 = nil end
end

-- =============================================
-- SPAWN CAR MODULE
-- =============================================

local SpawnCar = {}
SpawnCar.SelectedCar = nil
SpawnCar.CarList = {}
SpawnCar.AutoRide = false
SpawnCar.AutoRideAlways = false

local function exitMotor()
    local motor = findMyMotor()
    if not motor then return false end
    local char = LocalPlayer.Character
    if not char then return false end

    local anims = motor:FindFirstChild("Anims")
    if anims then
        pcall(function() anims:FireServer("RemovePlayer", char, nil) end)
        task.wait(0.3)
    end

    local driveSeat = motor:FindFirstChild("DriveSeat", true)
    if driveSeat then
        pcall(function() driveSeat:Sit(nil) end)
        task.wait(0.3)
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function() humanoid.Jump = true end)
    end

    return true
end

local function rideMotor()
    local motor = findMyMotor()
    if not motor then return false end

    local char = LocalPlayer.Character
    if not char then return false end

    local anims = motor:FindFirstChild("Anims")
    if anims then
        pcall(function() anims:FireServer("CreatePlayer", char) end)
        task.wait(0.2)
        pcall(function() anims:FireServer("RegisterPlayer", char) end)
        task.wait(0.2)
    end

    local kickstand = motor:FindFirstChild("Kickstand")
    if kickstand then
        pcall(function() kickstand:FireServer("StandUp", 0, 0, 0, 0, false) end)
        task.wait(0.2)
    end

    local driveSeat = motor:FindFirstChild("DriveSeat", true)
    if driveSeat then
        pcall(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = driveSeat.CFrame end
            driveSeat:Sit(char:FindFirstChildOfClass("Humanoid"))
        end)
    end
    return true
end

local function getCarList()
    local carNames = {}
    pcall(function()
        local mainUI = LocalPlayer.PlayerGui:WaitForChild("MainUI")
        local frame = mainUI:WaitForChild("Frame")
        local spawnBtn = mainUI:WaitForChild("Spawn"):WaitForChild("SpawnCar")
        frame.Visible = false
        firesignal(spawnBtn.MouseButton1Click)
        task.wait(2)
        local sf = frame:WaitForChild("MainFrame"):WaitForChild("ScrollingFrame")
        for _, v in ipairs(sf:GetChildren()) do
            if v.ClassName:sub(1,2) ~= "UI" then
                table.insert(carNames, v.Name)
            end
        end
        frame.Visible = false
    end)
    SpawnCar.CarList = carNames
    return #carNames > 0 and carNames or { "Refresh dulu..." }
end

function SpawnCar.Spawn()
    if not SpawnCar.SelectedCar or SpawnCar.SelectedCar == "Refresh dulu..." then return end
    local ok = pcall(function()
        ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SpawnCar.SelectedCar)
    end)
    if ok and SpawnCar.AutoRide then
        task.spawn(function()
            task.wait(4)
            rideMotor()
        end)
    end
end

function SpawnCar.Despawn()
    pcall(function()
        ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("DespawnCar"):FireServer()
    end)
end

local autoRideLoop = nil
function SpawnCar.StartAutoRideAlways()
    if autoRideLoop then return end
    autoRideLoop = task.spawn(function()
        while SpawnCar.AutoRideAlways do
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and not humanoid.Sit and findMyMotor() then
                rideMotor()
            end
            task.wait(2)
        end
        autoRideLoop = nil
    end)
end

function SpawnCar.StopAutoRideAlways()
    SpawnCar.AutoRideAlways = false
    if autoRideLoop then task.cancel(autoRideLoop) autoRideLoop = nil end
end

-- =============================================
-- AUTO JOB BARISTA MODULE
-- =============================================

local BaristaJob = { Name = "Barista", TeamId = 11378976, X = -5022.51, Y = 3.18, Z = -676.96 }

local function setJob(job)
    pcall(function()
        ReplicatedStorage:WaitForChild("JobEvents"):WaitForChild("TeamChangeRequest")
            :FireServer(job.Name, job.TeamId, 1, 0, "Detector")
    end)
end

local function walkTo(humanoid, point, timeout)
    timeout = timeout or 10
    local t = tick()
    while tick() - t < timeout do
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (hrp.Position - point).Magnitude < 5 then break end
        humanoid:MoveTo(point)
        task.wait(0.5)
    end
end

local function getBaristaEvent()
    local assets = ReplicatedStorage:FindFirstChild("BaristaAssets")
    if not assets then return nil end
    local events = assets:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("BaristaEvent")
end

-- =============================================
-- AUTO COMPLETE MINIGAME - HUMAN-LIKE ANTI DETEKSI
-- =============================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

task.spawn(function()
    math.randomseed(os.clock() * 1000)

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local baristaGui = playerGui:FindFirstChild("BaristaGUI")
    while not baristaGui do
        task.wait(1)
        baristaGui = playerGui:FindFirstChild("BaristaGUI")
    end

    local minigame     = baristaGui:WaitForChild("MinigameFrame")
    local bgBar        = minigame:WaitForChild("BackgroundBar")
    local tapZone      = minigame:WaitForChild("TapZone")
    local targetZone   = bgBar:WaitForChild("TargetZone")
    local playerCursor = bgBar:WaitForChild("PlayerCursor")

    local function tap()
        local r = math.random(1, 3)
        if r == 1 then
            pcall(function() firesignal(tapZone.MouseButton1Click) end)
        elseif r == 2 then
            pcall(function() firesignal(tapZone.MouseButton1Down) end)
            task.wait(math.random(5, 15) * 0.01)
            pcall(function() firesignal(tapZone.MouseButton1Up) end)
        else
            pcall(function() firesignal(tapZone.MouseButton1Click) end)
        end
    end

    local lastTapTime = 0

    while true do
        task.wait(math.random(10, 25) * 0.001)

        if not minigame.Visible then
            task.wait(0.2)
            continue
        end

        local targetMid = targetZone.AbsolutePosition.Y + targetZone.AbsoluteSize.Y / 2
        local cursorMid = playerCursor.AbsolutePosition.Y + playerCursor.AbsoluteSize.Y / 2
        local diff = cursorMid - targetMid
        local now = tick()

        if diff > 10 then
            -- Bar putih di BAWAH kapsul kuning → tap buat naik
            local urgency = math.clamp(diff / 80, 0.3, 1.0)
            local interval = math.random(30, 70) * 0.001 / urgency
            if now - lastTapTime >= interval then
                tap()
                lastTapTime = now
            end
        elseif diff > -10 then
            -- Sudah sejajar → tap pelan buat maintain
            if math.random(1, 100) <= 20 then
                local interval = math.random(80, 150) * 0.001
                if now - lastTapTime >= interval then
                    tap()
                    lastTapTime = now
                end
            end
        end
        -- diff < -10 = cursor di atas → jangan tap, tunggu turun sendiri
    end
end)

-- =============================================
-- FUNGSI SERVE ORDER & TRY BREW
-- =============================================

local function doTryBrew()
    local ok, prompt = pcall(function()
        return Workspace.BaristaJob.Interactions.MachinePart.MachinePart.MachinePrompt
    end)
    if not ok or not prompt then
        print("[doTryBrew] MachinePrompt tidak ditemukan!")
        return false
    end
    print("[doTryBrew] Hold MachinePrompt selama:", prompt.HoldDuration)
    prompt:InputHoldBegin()
    task.wait(prompt.HoldDuration + 0.1)
    prompt:InputHoldEnd()
    return true
end

local function doServeOrder()
    pcall(function()
        local prompt = Workspace.BaristaJob.Interactions.RegisterPart.RegisterPart.RegisterPrompt
        -- Tunggu prompt enabled dulu (max 10 detik)
        local t = tick()
        while not prompt.Enabled and tick() - t < 10 do
            task.wait(0.2)
        end
        if not prompt.Enabled then return end
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()
    end)
end

-- =============================================
-- FIX MACHINE (Repair Brewing Machine)
-- Dipanggil kalau MachinePrompt.ActionText berubah = mesin rusak
-- =============================================


-- Waypoint route ke mesin dan balik
local MACHINE_ROUTE = {
    Vector3.new(-4995.341309, 4.289086, -801.850220), -- Pos 1
    Vector3.new(-5007.872070, 4.289086, -801.314514), -- Pos 2
    Vector3.new(-5006.809082, 4.289086, -728.798645), -- Pos 3
    Vector3.new(-4999.592773, 3.189320, -670.799133), -- Pos 4
    Vector3.new(-5113.675781, 3.189320, -672.781311), -- Pos 5 (mesin)
}

local fixingMachine = false -- flag: sedang fix mesin, pause loop utama
local machineNeedsRepair = false -- dipindah ke sini agar bisa diakses oleh doFixMachine

local function doFixMachine()
    fixingMachine = true
    -- machineNeedsRepair di-reset SETELAH UI confirm beres, bukan di sini

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then fixingMachine = false return end

    -- Jalan ke mesin lewat waypoint 1→2→3→4→5
    for _, pos in ipairs(MACHINE_ROUTE) do
        humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then fixingMachine = false return end
        walkTo(humanoid, pos, 15)
    end

    task.wait(0.5)

    -- Cari SupplyPrompt (bukan MachinePrompt!)
    -- Path: Workspace.BaristaJob.Interactions.SupplyPart.SupplyPart.SupplyPrompt
    local supplyPrompt = nil
    pcall(function()
        supplyPrompt = Workspace.BaristaJob.Interactions.SupplyPart.SupplyPart.SupplyPrompt
    end)

    -- Fallback: scan workspace kalau path berubah
    if not supplyPrompt then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "SupplyPrompt" and v:IsA("ProximityPrompt") then
                supplyPrompt = v
                break
            end
        end
    end

    print("[FixMachine] SupplyPrompt found:", supplyPrompt ~= nil)

    if supplyPrompt then
        -- Hold pakai HoldDuration dari prompt itu sendiri
        pcall(function()
            supplyPrompt:InputHoldBegin()
            task.wait(supplyPrompt.HoldDuration + 0.05)
            supplyPrompt:InputHoldEnd()
        end)
    end

    task.wait(1)

    -- Tunggu UI confirm mesin sudah beres (max 15 detik)
    -- Kalau ObjectiveLabel dan OrderText sudah tidak "Fix Machine" / "Machine broke down!" = selesai
    local waitTimeout = tick() + 15
    while tick() < waitTimeout do
        local obj1 = ""
        local obj2 = ""
        pcall(function()
            obj1 = PlayerGui.BaristaMissionUI.Container.MainFrame.Frame.ObjectiveLabel.Text
        end)
        pcall(function()
            obj2 = PlayerGui.BaristaGUI.StatusFrame.OrderText.Text
        end)
        if obj1 ~= "Fix Machine" and obj2 ~= "Machine broke down!" then
            print("[FixMachine] Mesin sudah beres! Lanjut balik...")
            break
        end
        task.wait(0.5)
    end

    -- Reset flag SETELAH UI confirm beres
    machineNeedsRepair = false
    task.wait(1)

    -- Balik lewat waypoint terbalik: 4→3→2→1
    humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for i = #MACHINE_ROUTE - 1, 1, -1 do
            humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid then break end
            walkTo(humanoid, MACHINE_ROUTE[i], 15)
        end
    end

    task.wait(0.5)
    fixingMachine = false
end



-- =============================================
-- AUTO BARISTA GOTO + LOOP
-- =============================================

local baristaRunning = false

-- Monitor mesin rusak: cek ObjectiveLabel + OrderText setiap 1 detik
-- var machineNeedsRepair dipindah ke atas

task.spawn(function()
    -- Tunggu sampai barista loop jalan dulu
    while not baristaRunning do task.wait(1) end
    print("[MachineMonitor] Mulai monitor mesin...")

    while baristaRunning and _G.KingVypersRunning do
        task.wait(1)

        if fixingMachine then continue end

        local obj1 = ""
        local obj2 = ""

        pcall(function()
            obj1 = PlayerGui.BaristaMissionUI.Container.MainFrame.Frame.ObjectiveLabel.Text
        end)
        pcall(function()
            obj2 = PlayerGui.BaristaGUI.StatusFrame.OrderText.Text
        end)

        if obj1 == "Fix Machine" or obj2 == "Machine broke down!" then
            if not machineNeedsRepair then
                print("[MachineMonitor] MESIN RUSAK! obj1=[" .. obj1 .. "] obj2=[" .. obj2 .. "]")
                machineNeedsRepair = true
            end
        end
    end

    print("[MachineMonitor] Monitor berhenti")
end)

local function startBaristaLoop()
    local job = BaristaJob

    if baristaRunning then return end
    if not SpawnCar.SelectedCar or SpawnCar.SelectedCar == "Refresh dulu..." then return end
    baristaRunning = true

    setJob(job)
    task.wait(0.5)

    pcall(function()
        ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SpawnCar.SelectedCar)
    end)

    task.wait(4)
    rideMotor()
    task.wait(2)

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local motor = findMyMotor()

    if not (motor and hrp) then baristaRunning = false return end

    local target = CFrame.new(job.X, job.Y, job.Z)
    pcall(function()
        motor:SetPrimaryPartCFrame(target)
        task.wait(0.1)
        hrp.CFrame = target * CFrame.new(0, 2, 0)
    end)

    task.wait(2)
    exitMotor()
    task.wait(0.5)

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then baristaRunning = false return end

    local approachPoints = {
        Vector3.new(-5004.69, 3.18, -675.35),
        Vector3.new(-5003.38, 4.28, -715.09),
        Vector3.new(-4991.12, 4.28, -714.90),
    }
    for _, pos in ipairs(approachPoints) do
        walkTo(humanoid, pos, 10)
    end

    task.wait(0.5)
    -- Start job pakai JobPrompt
    pcall(function()
        local prompt = Workspace.BaristaJob.Interactions.StartPart.StartPart.JobPrompt
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()
    end)
    task.wait(0.5)

    local innerPoints = {
        Vector3.new(-5007.13, 4.28, -757.45),
        Vector3.new(-5006.95, 4.28, -801.65),
        Vector3.new(-4996.64, 4.28, -801.13),
        Vector3.new(-4997.60, 4.28, -794.40),
    }
    for _, pos in ipairs(innerPoints) do
        walkTo(humanoid, pos, 15)
    end

    while baristaRunning and _G.KingVypersRunning do
        humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then task.wait(2) continue end

        -- PRIORITAS: kalau mesin rusak, pause semua dan fix dulu
        if machineNeedsRepair and not fixingMachine then
            print("[BaristaLoop] Mesin rusak terdeteksi! Memulai doFixMachine...")
            task.spawn(doFixMachine)
        end

        -- Tunggu sampai fix selesai sebelum lanjut brew
        if fixingMachine then
            task.wait(0.5)
            continue
        end

        -- Step 1: Jalan ke posisi mesin brewing
        walkTo(humanoid, Vector3.new(-4997.60, 4.28, -794.40), 10)
        task.wait(0.5)

        -- Step 2: Hold MachinePrompt (trigger brew + minigame)
        local brewOk = doTryBrew()

        if not brewOk then
            -- Prompt gagal, tunggu sebentar lalu retry dari awal loop
            print("[BaristaLoop] doTryBrew gagal, retry...")
            task.wait(2)
            continue
        end

        -- Step 3: Tunggu minigame muncul (max 10 detik)
        local bGui = PlayerGui:FindFirstChild("BaristaGUI")
        local mgAppeared = false
        if bGui then
            local t = tick()
            while tick() - t < 10 do
                local mf = bGui:FindFirstChild("MinigameFrame")
                if mf and mf.Visible then
                    mgAppeared = true
                    break
                end
                task.wait(0.2)
            end
        end

        -- Step 4: Tunggu minigame selesai (max 30 detik)
        if mgAppeared then
            local timeout = tick() + 30
            local mf = bGui and bGui:FindFirstChild("MinigameFrame")
            while mf and mf.Visible and tick() < timeout do
                task.wait(0.2)
            end
        end

        task.wait(1)

        -- Step 5: Jalan ke kasir dan serve order
        humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            walkTo(humanoid, Vector3.new(-4995.49, 4.28, -761.86), 15)
        end
        task.wait(0.5)
        doServeOrder()

        task.wait(5)
    end
end

-- =============================================
-- AUTO JOB COURIER MODULE
-- =============================================
-- =============================================
-- AUTO JOB COURIER MODULE
-- =============================================
local CourierJob = { Name = "Courier", TeamId = 11378976, X = -5158.57, Y = 4.41, Z = -3757.87 }
local courierRunning = false
local ServiceEventConn = nil

local function startCourierLoop()
    local job = CourierJob

    if courierRunning then return end
    if not SpawnCar.SelectedCar or SpawnCar.SelectedCar == "Refresh dulu..." then return end
    courierRunning = true

    local activePackageLoc = nil
    local activePackageNum = nil
    
    local serviceEvent = ReplicatedStorage:FindFirstChild("ServiceEvent", true)
    if serviceEvent then
        ServiceEventConn = serviceEvent.OnClientEvent:Connect(function(eventName, action, paketNum)
            if action == "Create" then
                local Location = workspace:FindFirstChild("Livrason") and workspace.Livrason:FindFirstChild("Location")
                if Location then
                    local paket = Location:FindFirstChild(tostring(paketNum))
                    if paket then
                        local point = paket:FindFirstChild("POINT")
                        local block = paket:FindFirstChild("Block")
                        local billboard = point and point:FindFirstChild("billboardgui")
                        local namaLokasi = ""
                        if billboard then
                            for _, gui in ipairs(billboard:GetChildren()) do
                                if gui:IsA("TextLabel") and gui.Text ~= "🔻" and gui.Text ~= "" then
                                    namaLokasi = gui.Text
                                end
                            end
                        end
                        if point and block then
                            activePackageLoc = block.Position
                            activePackageNum = paketNum
                            print("=== AMBIL PAKET ===")
                            print("Paket #" .. tostring(paketNum))
                            print("Lokasi: " .. namaLokasi)
                            print("Position: " .. tostring(activePackageLoc))
                        end
                    end
                end
            elseif action == "Remove" then
                print("Paket #" .. tostring(paketNum) .. " selesai!")
                if activePackageNum == paketNum then
                    activePackageLoc = nil
                    activePackageNum = nil
                end
            end
        end)
    end

    setJob(job)
    task.wait(1.5)

    pcall(function()
        ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SpawnCar.SelectedCar)
    end)

    task.wait(6)
    rideMotor()
    task.wait(3.5)

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local motor = findMyMotor()

    if not (motor and hrp) then courierRunning = false return end

    local target = CFrame.new(job.X, job.Y, job.Z)
    pcall(function()
        motor:SetPrimaryPartCFrame(target)
        task.wait(0.3)
        hrp.CFrame = target * CFrame.new(0, 2, 0)
    end)

    task.wait(3.5)
    exitMotor()
    task.wait(1.5)

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then courierRunning = false return end

    walkTo(humanoid, Vector3.new(-5109.06, 5.18, -3758.69), 10)
    task.wait(1.5)

    -- Ambil Paket di pickup point
    pcall(function()
        local prompt = workspace.Livrason.Take1.Take.ProximityPrompt
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.2)
            prompt:InputHoldEnd()
        end
    end)
    task.wait(1.5)

    -- =========================================================
    -- GHOST GLIDE: nembus tembok langsung ke paket
    -- =========================================================
    local function forceDismount()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not char or not hum then return end
        print("Turun dari motor...")
        hum.Sit = false
        hum.Jump = true
        task.wait(0.1)
        if hum.SeatPart then
            char:PivotTo(char:GetPivot() * CFrame.new(0, 2, 0))
            hum.Sit = false
            hum.Jump = true
        end
        task.wait(0.2)
    end

    local function ghostGlideMotor(targetPos)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local seat = hum and hum.SeatPart
        local vehicle = seat and seat:FindFirstAncestorOfClass("Model")
        if not (vehicle and vehicle.PrimaryPart) then return end

        local pp = vehicle.PrimaryPart
        local speed = 150
        local glideHeight = targetPos.Y + 3
        local posTujuan = Vector3.new(targetPos.X, glideHeight, targetPos.Z)

        print("Mengaktifkan Ghost Rider mode...")

        local virtualAnchor = Instance.new("BodyVelocity")
        virtualAnchor.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        virtualAnchor.Velocity = Vector3.new(0, 0, 0)
        virtualAnchor.Parent = pp

        local virtualGyro = Instance.new("BodyGyro")
        virtualGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        virtualGyro.P = 100000
        virtualGyro.Parent = pp

        local noclip = RunService.Stepped:Connect(function()
            for _, v in pairs(vehicle:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)

        local _, currentYRot, _ = pp.CFrame:ToEulerAnglesYXZ()

        local function glideTo(targetVector, faceForward)
            local dist = (pp.Position - targetVector).Magnitude
            local timeToMove = dist / speed
            if timeToMove > 0 then
                local startTime = tick()
                while tick() - startTime < timeToMove do
                    if not hum.SeatPart then break end
                    local alpha = (tick() - startTime) / timeToMove
                    local currentPos = pp.Position:Lerp(targetVector, alpha)
                    if faceForward then
                        local dir = (targetVector - pp.Position).Unit
                        local flatDir = Vector3.new(dir.X, 0, dir.Z).Unit
                        if flatDir.Magnitude > 0.001 then
                            local newCFrame = CFrame.lookAt(currentPos, currentPos + flatDir)
                            virtualGyro.CFrame = newCFrame
                            vehicle:PivotTo(newCFrame)
                        end
                    else
                        local newCFrame = CFrame.new(currentPos) * CFrame.Angles(0, currentYRot, 0)
                        virtualGyro.CFrame = newCFrame
                        vehicle:PivotTo(newCFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end
        end

        print("Terbang menembus tembok ke target...")
        glideTo(posTujuan, true)

        print("Cari aspal untuk mendarat...")
        local finalSafeY = targetPos.Y + 3
        local timeout = tick() + 8
        while tick() < timeout do
            local rayOrigin = Vector3.new(targetPos.X, glideHeight + 5, targetPos.Z)
            local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -100, 0))
            if rayResult and rayResult.Instance then
                finalSafeY = rayResult.Position.Y + 1.5
                print("Aspal ketemu! Mendarat...")
                break
            else
                task.wait(1)
            end
        end

        glideTo(Vector3.new(targetPos.X, finalSafeY, targetPos.Z), false)

        virtualAnchor:Destroy()
        virtualGyro:Destroy()
        noclip:Disconnect()
        pp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        pp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        forceDismount()
    end
    -- =========================================================

    -- Loop terus antar paket selama ada yang masuk
    while courierRunning do
        -- Tunggu paket baru (max 20 detik), kalau kosong stop
        local t = tick()
        while courierRunning and not activePackageLoc and tick() - t < 20 do
            task.wait(0.4)
        end

        if not activePackageLoc then
            print("Tidak ada paket baru dalam 20 detik. Auto Courier berhenti.")
            break
        end

        local curChar = LocalPlayer.Character
        local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
        local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")

        -- Spawn motor baru, naik, lalu ghost glide
        print("Spawn motor...")
        pcall(function()
            ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SpawnCar.SelectedCar)
        end)
        task.wait(4)
        rideMotor()
        task.wait(3.5)

        print("Ghost Glide ke lokasi paket #" .. tostring(activePackageNum) .. "...")
        ghostGlideMotor(activePackageLoc)
        task.wait(1)

        -- Refresh char setelah dismount
        curChar = LocalPlayer.Character
        curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")

        -- Jalan kaki ke paket
        print("Berjalan kaki ke paket...")
        local walkHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if walkHum then
            walkTo(walkHum, activePackageLoc, 20)
            task.wait(2.0)
        end

        print("Sampai! Mengambil/Menaruh paket...")

        -- Simpan num sekarang sebelum di-nil oleh event Remove
        local targetNum = activePackageNum

        pcall(function()
            local LocationFolder = workspace.Livrason.Location
            local paketModel = LocationFolder:FindFirstChild(tostring(targetNum))
            if paketModel then
                local block = paketModel:FindFirstChild("Block")
                local prompt = block and block:FindFirstChild("ProximityPrompt")
                if prompt and prompt.Enabled then
                    print("Equip box & taruh paket #" .. tostring(targetNum))
                    local box = LocalPlayer.Backpack:FindFirstChild("Box")
                        or curChar:FindFirstChild("Box")
                        or curChar:FindFirstChildWhichIsA("Tool")
                    if box and curHum then
                        curHum:EquipTool(box)
                        task.wait(1.0)
                    end
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + 0.2)
                    prompt:InputHoldEnd()
                    task.wait(2.5)
                end
            else
                for _, p in ipairs(LocationFolder:GetChildren()) do
                    local b = p:FindFirstChild("Block")
                    local pr = b and b:FindFirstChild("ProximityPrompt")
                    if pr and pr.Enabled then
                        print("Fallback: taruh paket #" .. p.Name)
                        local box = LocalPlayer.Backpack:FindFirstChild("Box")
                            or curChar:FindFirstChild("Box")
                            or curChar:FindFirstChildWhichIsA("Tool")
                        if box and curHum then
                            curHum:EquipTool(box)
                            task.wait(1.0)
                        end
                        pr:InputHoldBegin()
                        task.wait(pr.HoldDuration + 0.2)
                        pr:InputHoldEnd()
                        task.wait(2.5)
                    end
                end
            end
        end)

        print("Paket #" .. tostring(targetNum) .. " selesai! Cek paket berikutnya...")
        task.wait(2.0)
    end

    if ServiceEventConn then
        ServiceEventConn:Disconnect()
        ServiceEventConn = nil
    end
    print("Auto Courier dihentikan.")
end
-- =============================================
-- GUI - TAB RACE
-- =============================================

local RaceTab = Window:AddTab({ Name = "Race", Icon = "gamepad" })

local SpeedSection = RaceTab:AddSection("Speed Hack")

SpeedSection:AddParagraph({
    Title = "Penting",
    Content = isMobileDevice
        and "MOBILE: Naik motor dulu → Toggle ON → Tekan gas → boost! Lepas gas → rem halus!"
        or  "PC: Naik kendaraan dulu → Toggle ON → Pencet W → boost! Lepas W → rem halus!"
})

SpeedSection:AddInput({
    Title = "Speed Value",
    Default = "100",
    Placeholder = "Enter speed (10-1000)",
    Callback = function(value)
        local speed = tonumber(value)
        if speed and speed >= 10 and speed <= 1000 then
            VehicleSpeed.SetSpeed(speed)
        end
    end
})

SpeedSection:AddToggle({
    Title = "Enable Speed Hack",
    Default = false,
    Callback = function(on)
        if on then VehicleSpeed.Start() else VehicleSpeed.Stop() end
    end
})

local SlowSection = RaceTab:AddSection("Slow Race (Gradual)")

SlowSection:AddParagraph({
    Title = "Info",
    Content = isMobileDevice
        and "MOBILE: Naik motor dulu → Toggle ON → Tekan gas → speed naik pelan! Lepas gas → rem halus!"
        or  "PC: Speed naik pelan-pelan sampai Max Speed. Lepas W → rem halus! Makin besar Accel, makin cepat naiknya!"
})

SlowSection:AddInput({
    Title = "Max Speed",
    Default = "200",
    Placeholder = "Batas max speed (10-1000)",
    Callback = function(value)
        local v = tonumber(value)
        if v and v >= 10 and v <= 1000 then
            SlowRace.MaxSpeed = v
        end
    end
})

SlowSection:AddInput({
    Title = "Acceleration (kelipatan)",
    Default = "3",
    Placeholder = "Kelipatan akselerasi (1-20)",
    Callback = function(value)
        local v = tonumber(value)
        if v and v >= 1 and v <= 20 then
            SlowRace.AccelMultiplier = v
        end
    end
})

SlowSection:AddToggle({
    Title = "Enable Slow Race",
    Default = false,
    Callback = function(on)
        if on then SlowRace.Start() else SlowRace.Stop() end
    end
})

-- =============================================
-- GUI - TAB GARAGE
-- =============================================

local initialCarList = getCarList()

local GarageTab = Window:AddTab({ Name = "Garage", Icon = "menu" })
local GarageSection = GarageTab:AddSection("Spawn Kendaraan")

local carDropdown = GarageSection:AddDropdown({
    Title = "Pilih Kendaraan",
    Content = "Pilih kendaraan yang mau di-spawn",
    Multi = false,
    Options = initialCarList,
    Default = initialCarList[1],
    Callback = function(selected)
        if selected ~= "Refresh dulu..." then
            SpawnCar.SelectedCar = selected
        end
    end
})
SpawnCar.SelectedCar = initialCarList[1] ~= "Refresh dulu..." and initialCarList[1] or nil

GarageSection:AddButton({
    Title = "Refresh List Kendaraan",
    Callback = function()
        local cars = getCarList()
        if cars[1] ~= "Refresh dulu..." then
            pcall(function()
                carDropdown:Refresh(cars, cars[1])
            end)
            SpawnCar.SelectedCar = cars[1]
        end
    end
})

GarageSection:AddButton({
    Title = "Spawn Kendaraan",
    Callback = function() SpawnCar.Spawn() end
})

GarageSection:AddButton({
    Title = "Despawn Kendaraan",
    Callback = function() SpawnCar.Despawn() end
})

GarageSection:AddButton({
    Title = "Ride Motor",
    Callback = function() rideMotor() end
})

GarageSection:AddToggle({
    Title = "Auto Ride after Spawn",
    Default = false,
    Callback = function(on)
        SpawnCar.AutoRide = on
    end
})

GarageSection:AddToggle({
    Title = "Auto Ride Always",
    Default = false,
    Callback = function(on)
        SpawnCar.AutoRideAlways = on
        if on then SpawnCar.StartAutoRideAlways()
        else SpawnCar.StopAutoRideAlways() end
    end
})

-- =============================================
-- GUI - TAB JOB
-- =============================================

local JobTab = Window:AddTab({ Name = "Job", Icon = "payment" })
local JobSection = JobTab:AddSection("Auto Job Barista")

JobSection:AddButton({
    Title = "Accept Job Barista",
    Callback = function()
        setJob(BaristaJob)
    end
})

JobSection:AddToggle({
    Title = "Auto Work Barista",
    Default = false,
    Callback = function(on)
        if on then
            task.spawn(startBaristaLoop)
        else
            baristaRunning = false
        end
    end
})

local CourierSection = JobTab:AddSection("Auto Job Courier")

CourierSection:AddButton({
    Title = "Accept Job Courier",
    Callback = function()
        setJob(CourierJob)
    end
})

CourierSection:AddToggle({
    Title = "Auto Work Courier",
    Default = false,
    Callback = function(on)
        if on then
            task.spawn(startCourierLoop)
        else
            courierRunning = false
        end
    end
})


-- =============================================
-- CHARACTER ADDED
-- =============================================

local function onCharacterAdded(char)
    Character = char
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if Character then onCharacterAdded(Character) end

-- =============================================
-- HIDE STATS MODULE
-- =============================================

local HideStats = (function()
    local HS = {}

    local enabled = false
    local FakeName = "King Vypers"
    local FakeRank = "King Vypers 👑"
    local updateLoop = nil

    local function getRankTags()
        local char = LocalPlayer.Character
        if not char then return nil end
        local head = char:FindFirstChild("Head")
        if not head then return nil end
        return head:FindFirstChild("RankTags")
    end

    local function updateStats()
        if not enabled then return end
        local rankTags = getRankTags()
        if not rankTags then return end

        local username = rankTags:FindFirstChild("Player_Username")
        local rank = rankTags:FindFirstChild("Player_Rank")

        if username then
            username.Text = FakeName
            local shadow = username:FindFirstChild("Shadow")
            if shadow then shadow.Text = FakeName end
        end
        if rank then rank.Text = FakeRank end
    end

    local function restoreStats()
        local rankTags = getRankTags()
        if not rankTags then return end

        local username = rankTags:FindFirstChild("Player_Username")
        local rank = rankTags:FindFirstChild("Player_Rank")

        if username then
            username.Text = LocalPlayer.Name
            local shadow = username:FindFirstChild("Shadow")
            if shadow then shadow.Text = LocalPlayer.Name end
        end
        if rank then rank.Text = "Member" end
    end

    local function startLoop()
        if updateLoop then return end
        updateLoop = true
        task.spawn(function()
            while updateLoop do
                task.wait(0.2)
                if enabled then updateStats() end
            end
        end)
    end

    function HS.Enable()
        enabled = true
        startLoop()
        updateStats()
    end

    function HS.Disable()
        enabled = false
        updateLoop = false
        restoreStats()
    end

    function HS.SetFakeName(name)
        FakeName = name or LocalPlayer.Name
        if enabled then updateStats() end
    end

    function HS.SetFakeRank(rank)
        FakeRank = rank or "Member"
        if enabled then updateStats() end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if enabled then updateStats() end
    end)

    return HS
end)()

-- =============================================
-- ANTI-AFK MODULE
-- =============================================

local AntiAFK = (function()
    local AA = {
        Enabled = false,
        Thread = nil,
    }

    function AA.Start()
        if AA.Enabled then return end
        AA.Enabled = true

        AA.Thread = task.spawn(function()
            while AA.Enabled do
                task.wait(240)
                if not AA.Enabled then break end
                pcall(function()
                    local cam = Workspace.CurrentCamera
                    local orig = cam.CFrame
                    cam.CFrame = orig * CFrame.Angles(0, 0.01, 0)
                    task.wait(0.1)
                    cam.CFrame = orig
                end)
            end
        end)
    end

    function AA.Stop()
        if not AA.Enabled then return end
        AA.Enabled = false
        if AA.Thread then
            task.cancel(AA.Thread)
            AA.Thread = nil
        end
    end

    return AA
end)()

-- =============================================
-- ANTI-STAFF MODULE
-- =============================================

local AntiStaff = (function()
    local AS = {}
    AS.Active = false

    local GROUP_ID = 35102746
    local STAFF_RANKS = {
        [2]=true, [3]=true, [4]=true, [75]=true, [79]=true,
        [145]=true, [250]=true, [252]=true, [254]=true, [255]=true,
        [55]=true, [30]=true, [35]=true, [100]=true, [76]=true
    }

    local function checkLoop()
        while AS.Active do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local ok, rank = pcall(function()
                        return player:GetRankInGroup(GROUP_ID)
                    end)
                    if ok and STAFF_RANKS[rank] then
                        LocalPlayer:Kick("Staff Detected! Auto Kicked for Safety.")
                        return
                    end
                end
            end
            task.wait(1)
        end
    end

    function AS.Start()
        if AS.Active then return end
        AS.Active = true
        task.spawn(checkLoop)
    end

    function AS.Stop()
        AS.Active = false
    end

    return AS
end)()

-- =============================================
-- AUTO RECONNECT + AUTO EXECUTE MODULE
-- =============================================

local AutoRejoin = (function()
    local AR = {}
    AR.Enabled = false
    AR.AutoExecEnabled = false

    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local disconnectSetup = false
    local hasTriggered = false

    -- URL script yang akan di-execute otomatis setelah rejoin
    -- WARNING: Ganti SCRIPT_URL dengan URL script UTAMA (misal pastebin/github raw cobadds.lua lo)
    -- JANGAN pakai URL vyperui.lua karena itu cuma UI-nya saja!
    local SCRIPT_URL = "https://raw.githubusercontent.com/SapuLidi-Eak/mantaplek123/refs/heads/main/coba.lua" 
    local EXEC_DELAY = 30 -- detik tunggu sebelum execute setelah rejoin (dilebihin dikit biar game load)
    task.wait(10)
    -- Cari queue_on_teleport dari berbagai executor secara aman
    local function getQueueOnTeleport()
        local getQueue = nil
        pcall(function() getQueue = queue_on_teleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = queueonteleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = syn and syn.queue_on_teleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = fluxus and fluxus.queue_on_teleport end)
        if getQueue then return getQueue end
        return nil
    end

    local function setupAutoExecuteQueue()
        local queueTeleport = getQueueOnTeleport()
        if not queueTeleport then return false end
        if not AR.AutoExecEnabled then return false end

        local autoExecCode = string.format([[
            task.wait(%d)
            pcall(function()
                loadstring(game:HttpGet("%s"))()
            end)
        ]], EXEC_DELAY, SCRIPT_URL)

        local ok = pcall(function() queueTeleport(autoExecCode) end)
        return ok
    end

    local function doRejoin()
        if hasTriggered then return end
        if not AR.Enabled then return end
        hasTriggered = true

        -- Queue auto execute dulu sebelum teleport kalau fitur aktif
        if AR.AutoExecEnabled then
            setupAutoExecuteQueue()
        end

        task.spawn(function()
            while true do
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
                task.wait(3) -- Loop terus misal teleport gagal
            end
        end)
    end

    local function setupDetection()
        if disconnectSetup then return end
        disconnectSetup = true

        -- Method 1: GuiService ErrorMessageChanged
        pcall(function()
            game:GetService("GuiService").ErrorMessageChanged:Connect(function(message)
                if message and message ~= "" and AR.Enabled then
                    task.wait(1)
                    doRejoin()
                end
            end)
        end)

        -- Method 2: CoreGui RobloxPromptGui — popup "You were kicked" / error
        pcall(function()
            local CoreGui = game:GetService("CoreGui")
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 5)
            if RobloxPromptGui then
                local promptOverlay = RobloxPromptGui:WaitForChild("promptOverlay", 5)
                if promptOverlay then
                    promptOverlay.ChildAdded:Connect(function(child)
                        if child.Name == "ErrorPrompt" and AR.Enabled then
                            task.wait(0.5)
                            doRejoin()
                        end
                    end)
                end
            end
        end)

        -- Method 3: LocalPlayer.Idled — kicked karena idle terlalu lama
        pcall(function()
            LocalPlayer.Idled:Connect(function(t)
                if t > 1150 and AR.Enabled then -- 1150 detik biar gakeduluan Roblox
                    doRejoin()
                end
            end)
        end)

        -- Method 4: OnTeleport — fallback
        pcall(function()
            LocalPlayer.OnTeleport:Connect(function(state)
                if state == Enum.TeleportState.RequestedFromServer and AR.Enabled then
                    task.wait(1)
                    doRejoin()
                end
            end)
        end)
    end

    function AR.Start()
        if AR.Enabled then return end
        AR.Enabled = true
        hasTriggered = false
        setupDetection()
        
        if AR.AutoExecEnabled then
            setupAutoExecuteQueue()
        end
    end

    function AR.Stop()
        AR.Enabled = false
        hasTriggered = false
    end

    function AR.EnableAutoExec()
        AR.AutoExecEnabled = true
        if AR.Enabled then
            setupAutoExecuteQueue()
        end
    end

    function AR.DisableAutoExec()
        AR.AutoExecEnabled = false
    end

    function AR.SetScriptURL(url)
        if type(url) == "string" and url ~= "" then
            SCRIPT_URL = url
        end
    end

    function AR.IsQueueSupported()
        return getQueueOnTeleport() ~= nil
    end

    return AR
end)()

-- =============================================
-- POTATO MODE MODULE
-- =============================================

local PotatoMode = (function()
    local PM = {}
    PM.Enabled = false

    local Lighting = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    local originalStates = { lighting = {}, waterProperties = {}, camera = {} }
    local pmConnections = {}
    local processedObjects = setmetatable({}, {__mode = "k"})

    local DESTROY_CLASSES = {
        BloomEffect=true, BlurEffect=true, ColorCorrectionEffect=true,
        SunRaysEffect=true, DepthOfFieldEffect=true, Atmosphere=true,
    }

    local function shouldDestroy(obj) return DESTROY_CLASSES[obj.ClassName] end

    local function isInVehicle(obj)
        local parent = obj.Parent
        while parent and parent ~= Workspace do
            if parent.Name:find("Montors") or parent.Name:find("Vehicle") or parent.Name:find("Car") then
                return true
            end
            parent = parent.Parent
        end
        return false
    end

    local function safeDestroy(obj)
        local ok, locked = pcall(function() return obj.Locked end)
        if ok and locked then return end
        if isInVehicle(obj) then return end
        pcall(function() obj:Destroy() end)
    end

    local function optimizeObject(obj)
        if not PM.Enabled or processedObjects[obj] then return end
        processedObjects[obj] = true
        if shouldDestroy(obj) then safeDestroy(obj) return end
        pcall(function()
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
                obj.Reflectance = 0
                obj.TopSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.RightSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.BackSurface = Enum.SurfaceType.SmoothNoOutlines
            elseif obj:IsA("Sound") then
                obj.Volume = 0
            end
        end)
    end

    local function optimizeCharacter(character)
        if not character or processedObjects[character] then return end
        processedObjects[character] = true
        pcall(function()
            for _, obj in ipairs(character:GetDescendants()) do
                if shouldDestroy(obj) then
                    local okL, isLocked = pcall(function() return obj.Locked end)
                    if not (okL and isLocked) then
                        pcall(function() obj:Destroy() end)
                    end
                elseif obj:IsA("BasePart") then
                    if obj.Name == "Head" then obj.Transparency = 1 end
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                    obj.CanCollide = obj.Name == "HumanoidRootPart" or obj.Name == "Head"
                    obj.Reflectance = 0
                    obj.TopSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.RightSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.BackSurface = Enum.SurfaceType.SmoothNoOutlines
                elseif obj:IsA("Humanoid") then
                    for _, t in ipairs(obj:GetPlayingAnimationTracks()) do t:Stop() end
                    obj.HealthDisplayDistance = 0
                    obj.NameDisplayDistance = 0
                elseif obj:IsA("Sound") then
                    obj.Volume = 0
                end
            end
        end)
    end

    function PM.Enable()
        if PM.Enabled then return end
        PM.Enabled = true

        task.spawn(function()
            local all = Workspace:GetDescendants()
            for i = 1, #all, 200 do
                if not PM.Enabled then break end
                for j = i, math.min(i+199, #all) do optimizeObject(all[j]) end
                task.wait()
            end
        end)

        if LocalPlayer.Character then optimizeCharacter(LocalPlayer.Character) end

        table.insert(pmConnections, LocalPlayer.CharacterAdded:Connect(function(char)
            if PM.Enabled then task.wait(0.2) optimizeCharacter(char) end
        end))

        if Terrain then
            pcall(function()
                originalStates.waterProperties = {
                    WaterReflectance = Terrain.WaterReflectance,
                    WaterWaveSize = Terrain.WaterWaveSize,
                    WaterWaveSpeed = Terrain.WaterWaveSpeed,
                    WaterTransparency = Terrain.WaterTransparency
                }
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
                Terrain.Decoration = false
            end)
            local clouds = Terrain:FindFirstChildOfClass("Clouds")
            if clouds then clouds:Destroy() end
        end

        for _, sky in ipairs(Lighting:GetChildren()) do
            if sky:IsA("Sky") then
                sky.SkyboxBk="" sky.SkyboxDn="" sky.SkyboxFt=""
                sky.SkyboxLf="" sky.SkyboxRt="" sky.SkyboxUp=""
                sky.StarCount=0 sky.SunAngularSize=0 sky.MoonAngularSize=0
                sky.CelestialBodiesShown=false
            end
        end

        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere:Destroy() end

        originalStates.lighting = {
            GlobalShadows = Lighting.GlobalShadows,
            Brightness = Lighting.Brightness,
            Technology = Lighting.Technology
        }
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Technology = Enum.Technology.Legacy
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ShadowSoftness = 0

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = false end
        end

        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function()
            local cam = Workspace.CurrentCamera
            originalStates.camera = { FieldOfView = cam.FieldOfView }
            cam.FieldOfView = 70
        end)

        table.insert(pmConnections, Workspace.DescendantAdded:Connect(function(obj)
            if PM.Enabled then
                if shouldDestroy(obj) then safeDestroy(obj)
                else task.defer(optimizeObject, obj) end
            end
        end))

        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
        end)
    end

    function PM.Disable()
        if not PM.Enabled then return end
        PM.Enabled = false

        if Terrain and originalStates.waterProperties then
            pcall(function()
                Terrain.WaterReflectance = originalStates.waterProperties.WaterReflectance or 0
                Terrain.WaterWaveSize = originalStates.waterProperties.WaterWaveSize or 0
                Terrain.WaterWaveSpeed = originalStates.waterProperties.WaterWaveSpeed or 0
                Terrain.WaterTransparency = originalStates.waterProperties.WaterTransparency or 0
                Terrain.Decoration = true
            end)
        end

        if originalStates.lighting.GlobalShadows ~= nil then
            Lighting.GlobalShadows = originalStates.lighting.GlobalShadows
            Lighting.Brightness = originalStates.lighting.Brightness
            Lighting.Technology = originalStates.lighting.Technology
        end

        if originalStates.camera.FieldOfView then
            pcall(function() Workspace.CurrentCamera.FieldOfView = originalStates.camera.FieldOfView end)
        end

        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
        end)

        for _, conn in ipairs(pmConnections) do conn:Disconnect() end
        pmConnections = {}
        processedObjects = setmetatable({}, {__mode = "k"})
        originalStates = { lighting = {}, waterProperties = {}, camera = {} }
        pcall(function() collectgarbage("collect") end)
    end

    return PM
end)()

-- =============================================
-- DISABLE RENDERING MODULE
-- =============================================

local DisableRendering = (function()
    local DR = {}
    DR.Enabled = false
    local renderConn = nil

    function DR.Start()
        if DR.Enabled then return end
        DR.Enabled = true
        renderConn = RunService.RenderStepped:Connect(function()
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
        end)
    end

    function DR.Stop()
        if not DR.Enabled then return end
        DR.Enabled = false
        if renderConn then renderConn:Disconnect() renderConn = nil end
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end

    return DR
end)()

-- =============================================
-- UNLOCK FPS MODULE
-- =============================================

local UnlockFPS = (function()
    local UF = {}
    UF.Enabled = false
    UF.CurrentCap = 60

    function UF.SetCap(fps)
        UF.CurrentCap = fps
        if UF.Enabled and setfpscap then setfpscap(fps) end
    end

    function UF.Start()
        if UF.Enabled then return end
        UF.Enabled = true
        if setfpscap then setfpscap(UF.CurrentCap) end
    end

    function UF.Stop()
        if not UF.Enabled then return end
        UF.Enabled = false
        if setfpscap then setfpscap(60) end
    end

    return UF
end)()

-- =============================================
-- GUI - TAB SETTINGS
-- =============================================

local FreecamTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

local HideStatsSection = FreecamTab:AddSection("Hide Stats")

HideStatsSection:AddToggle({
    Title = "Enable Hide Stats",
    Default = false,
    Callback = function(on)
        if on then HideStats.Enable() else HideStats.Disable() end
    end
})

HideStatsSection:AddInput({
    Title = "Fake Name",
    Default = "King Vypers",
    Placeholder = "Nama palsu",
    Callback = function(value)
        HideStats.SetFakeName(value)
    end
})

HideStatsSection:AddInput({
    Title = "Fake Rank",
    Default = "King Vypers 👑",
    Placeholder = "Rank palsu",
    Callback = function(value)
        HideStats.SetFakeRank(value)
    end
})

-- =============================================
-- GUI - PERFORMANCE SECTION (di Settings tab)
-- =============================================

local PerformanceSection = FreecamTab:AddSection("Performance")

PerformanceSection:AddToggle({
    Title = "FPS Booster (Potato Mode)",
    Default = false,
    Callback = function(on)
        if on then PotatoMode.Enable() else PotatoMode.Disable() end
    end
})

PerformanceSection:AddToggle({
    Title = "Disable 3D Rendering",
    Default = false,
    Callback = function(on)
        if on then DisableRendering.Start() else DisableRendering.Stop() end
    end
})

local selectedFpsCap = 60

PerformanceSection:AddDropdown({
    Title = "FPS Cap",
    Options = {"60", "90", "120", "240"},
    Default = "60",
    Callback = function(value)
        selectedFpsCap = tonumber(value) or 60
        UnlockFPS.SetCap(selectedFpsCap)
    end
})

PerformanceSection:AddToggle({
    Title = "Enable FPS Unlock",
    Default = false,
    Callback = function(on)
        if on then
            UnlockFPS.CurrentCap = selectedFpsCap
            UnlockFPS.Start()
        else
            UnlockFPS.Stop()
        end
    end
})

-- =============================================
-- GUI - PROTECTION SECTION (di Settings tab)
-- =============================================

local ProtectionSection = FreecamTab:AddSection("Protection")

ProtectionSection:AddToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(on)
        if on then AntiAFK.Start() else AntiAFK.Stop() end
    end
})

ProtectionSection:AddToggle({
    Title = "Anti Staff (Auto Kick)",
    Default = false,
    Callback = function(on)
        if on then AntiStaff.Start() else AntiStaff.Stop() end
    end
})

-- =============================================
-- GUI - AUTO RECONNECT + AUTO EXECUTE SECTION
-- =============================================

local ReconnectSection = FreecamTab:AddSection("Auto Reconnect & Execute")

ReconnectSection:AddParagraph({
    Title = "Info",
    Content = "Auto Reconnect: rejoin otomatis kena kick/disconnect.\nAuto Execute: jalanin script ini lagi otomatis setelah rejoin (butuh executor yang support queue_on_teleport)."
})

-- Toggle combined: Auto Reconnect
ReconnectSection:AddToggle({
    Title = "Enable Auto Reconnect",
    Default = false,
    Callback = function(on)
        if on then
            AutoRejoin.Start()
        else
            AutoRejoin.Stop()
        end
    end
})

-- Toggle: Auto Execute setelah rejoin
-- Kalau ON, script King Vypers akan otomatis ke-load lagi setelah rejoin
ReconnectSection:AddToggle({
    Title = "Auto Execute Setelah Rejoin",
    Default = false,
    Callback = function(on)
        if on then
            if AutoRejoin.IsQueueSupported() then
                AutoRejoin.EnableAutoExec()
            else
                -- Executor tidak support queue_on_teleport, fitur tidak akan jalan
                -- Toggle tetap bisa di-ON tapi tidak akan ada efek
                AutoRejoin.EnableAutoExec()
            end
        else
            AutoRejoin.DisableAutoExec()
        end
    end
})

ReconnectSection:AddParagraph({
    Title = "Auto Execute URL",
    Content = "Script URL sudah di-set ke URL King Vypers default.\nEdit variable SCRIPT_URL di module AutoRejoin kalau mau ganti."
})



end -- LoadMainScript

AuthMain()
