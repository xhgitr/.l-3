if not game:IsLoaded() then
    game.Loaded:Wait()
end

local library = {flags = {}, setters = {}, Version = "2.0", Windows = {}}

local cloneref = cloneref or function(o) return o end
local services = setmetatable({}, {
    __index = function(t, k)
        local ok, s = pcall(function() return cloneref(game:GetService(k)) end)
        if ok then rawset(t, k, s) return s end
    end
})
local TweenService = services.TweenService
local UIS = services.UserInputService
local RunService = services.RunService
local Players = services.Players
local HttpService = services.HttpService
local GuiService = services.GuiService
local LocalPlayer = Players.LocalPlayer

local Quint, Quad, EBack, Linear = Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingStyle.Back, Enum.EasingStyle.Linear
local Out, In = Enum.EasingDirection.Out, Enum.EasingDirection.In
local Left, Right = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right
local rgb = Color3.fromRGB
local HasHover = UIS.MouseEnabled

local Themes = {
    Glass = {Main = rgb(16, 18, 22), Side = rgb(16, 18, 22), Element = rgb(0, 0, 0), Hover = rgb(0, 0, 0),
        Accent = rgb(61, 220, 132), Accent2 = rgb(0, 200, 255), Text = rgb(245, 247, 250), SubText = rgb(185, 190, 200),
        Stroke = rgb(255, 255, 255), Off = rgb(255, 255, 255), Inset = rgb(255, 255, 255),
        MainA = 0.3, ElemA = 0.5, SecA = 1, HoverA = 0.32, InsetA = 0.9},
    Midnight = {Main = rgb(28, 33, 55), Side = rgb(22, 26, 44), Element = rgb(255, 255, 255), Hover = rgb(255, 255, 255),
        Accent = rgb(96, 140, 255), Accent2 = rgb(190, 110, 255), Text = rgb(245, 247, 255), SubText = rgb(185, 192, 220),
        Stroke = rgb(255, 255, 255), Off = rgb(255, 255, 255), Inset = rgb(0, 0, 0),
        MainA = 0, ElemA = 0.88, SecA = 0.93, HoverA = 0.8, InsetA = 0.6},
    Dark = {Main = rgb(20, 20, 24), Side = rgb(15, 15, 19), Element = rgb(255, 255, 255), Hover = rgb(255, 255, 255),
        Accent = rgb(130, 112, 255), Accent2 = rgb(80, 200, 255), Text = rgb(240, 240, 245), SubText = rgb(175, 175, 190),
        Stroke = rgb(255, 255, 255), Off = rgb(255, 255, 255), Inset = rgb(0, 0, 0),
        MainA = 0, ElemA = 0.9, SecA = 0.94, HoverA = 0.82, InsetA = 0.55},
    Ocean = {Main = rgb(12, 28, 38), Side = rgb(8, 21, 30), Element = rgb(255, 255, 255), Hover = rgb(255, 255, 255),
        Accent = rgb(0, 205, 225), Accent2 = rgb(80, 130, 255), Text = rgb(235, 250, 255), SubText = rgb(170, 205, 220),
        Stroke = rgb(255, 255, 255), Off = rgb(255, 255, 255), Inset = rgb(0, 0, 0),
        MainA = 0, ElemA = 0.88, SecA = 0.93, HoverA = 0.8, InsetA = 0.6},
    Rose = {Main = rgb(38, 22, 32), Side = rgb(29, 16, 25), Element = rgb(255, 255, 255), Hover = rgb(255, 255, 255),
        Accent = rgb(255, 105, 160), Accent2 = rgb(255, 170, 90), Text = rgb(255, 242, 248), SubText = rgb(225, 185, 205),
        Stroke = rgb(255, 255, 255), Off = rgb(255, 255, 255), Inset = rgb(0, 0, 0),
        MainA = 0, ElemA = 0.88, SecA = 0.93, HoverA = 0.8, InsetA = 0.6},
    Light = {Main = rgb(240, 242, 248), Side = rgb(226, 230, 240), Element = rgb(255, 255, 255), Hover = rgb(255, 255, 255),
        Accent = rgb(70, 110, 255), Accent2 = rgb(160, 90, 255), Text = rgb(25, 28, 40), SubText = rgb(90, 96, 115),
        Stroke = rgb(160, 168, 195), Off = rgb(120, 125, 150), Inset = rgb(0, 0, 0),
        MainA = 0, ElemA = 0.3, SecA = 0.55, HoverA = 0.08, InsetA = 0.9},
}
library.Themes = Themes
library.Loc = {Translations = {}}
function library.Localize(self, tbl)
    if not (type(self) == "table" and (self == library or rawget(self, "HPUI") == library)) then tbl = self end
    if type(tbl) ~= "table" then return end
    for lang, map in pairs(tbl.Translations or {}) do
        library.Loc.Translations[lang] = library.Loc.Translations[lang] or {}
        for k, v in pairs(map) do library.Loc.Translations[lang][k] = v end
    end
    if tbl.Default then library.Loc.Default = tbl.Default end
end
local BuiltinLoc = {
    zh = {ui_settings = "设置", ui_ui = "界面", ui_theme = "主题", ui_key = "显示/隐藏 快捷键", ui_glow = "流光边框", ui_rainbow = "彩虹流光",
        ui_blur = "背景模糊", ui_lang = "语言", ui_mini = "最小化为小方块", ui_slider = "滑条", ui_slidercolor = "滑条颜色",
        ui_reset = "恢复主题色", ui_bg = "自定义背景", ui_bghelp = "填图片 ID / 链接 / 本地图片；填一个放满 png 帧图的文件夹 (如 HPUI/frames) 就是动态背景",
        ui_fps = "动图帧率", ui_bgsrc = "背景 图片/文件夹", ui_bgt = "图片透明度 (%)", ui_ovl = "遮罩浓度 (%)", ui_clear = "清除背景",
        ui_cfg = "配置", ui_cfgname = "配置名", ui_cfglist = "已有配置", ui_save = "保存配置", ui_load = "读取配置", ui_info = "信息",
        ui_destroy = "销毁界面", ui_search = "搜索功能…", ui_confirm = "确定", ui_cancel = "取消", ui_destroy_q = "确定要销毁界面吗？",
        ui_perf = "性能模式", ui_perf_d = "停掉边框和标题动画，降低显卡占用", ui_lowfps = "检测到持续掉帧，已自动关闭动态背景", ui_autoperf = "帧率偏低，已自动开启性能模式"},
    en = {ui_settings = "Settings", ui_ui = "Interface", ui_theme = "Theme", ui_key = "Toggle key", ui_glow = "Glow border", ui_rainbow = "Rainbow glow",
        ui_blur = "Background blur", ui_lang = "Language", ui_mini = "Minimize to square", ui_slider = "Sliders", ui_slidercolor = "Slider color",
        ui_reset = "Use theme color", ui_bg = "Custom background", ui_bghelp = "Enter an image ID / link / local image. A folder full of png frames (e.g. HPUI/frames) becomes an animated background.",
        ui_fps = "Frame rate", ui_bgsrc = "Background image/folder", ui_bgt = "Image opacity (%)", ui_ovl = "Overlay strength (%)", ui_clear = "Clear background",
        ui_cfg = "Config", ui_cfgname = "Config name", ui_cfglist = "Saved configs", ui_save = "Save config", ui_load = "Load config", ui_info = "Info",
        ui_destroy = "Destroy UI", ui_search = "Search…", ui_confirm = "Confirm", ui_cancel = "Cancel", ui_destroy_q = "Destroy the UI?",
        ui_perf = "Performance mode", ui_perf_d = "Stops border/title animations to reduce GPU load", ui_lowfps = "Low FPS detected, animated background disabled", ui_autoperf = "Low FPS, performance mode enabled"},
}
local ThemeOrder = {"Glass", "Midnight", "Dark", "Ocean", "Rose", "Light"}

local function Tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Quint, dir or Out), props)
    t:Play()
    return t
end

local function P(obj, props, animated, time, style)
    if animated then
        Tween(obj, time or 0.25, props, style)
    else
        for k, v in pairs(props) do obj[k] = v end
    end
end

local function New(class, props, children)
    local o = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else o[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if parent then o.Parent = parent end
    return o
end

local function Corner(r, parent)
    return New("UICorner", {CornerRadius = UDim.new(0, r), Parent = parent})
end

local function Pad(v, h, parent)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, v), PaddingBottom = UDim.new(0, v),
        PaddingLeft = UDim.new(0, h), PaddingRight = UDim.new(0, h), Parent = parent})
end

local function Safe(fn, ...)
    if type(fn) == "function" then task.spawn(fn, ...) end
end

local function GetViewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function GetGuiParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and typeof(ui) == "Instance" then return ui end
    return services.CoreGui
end

local function IsImage(icon)
    if type(icon) == "number" then return true end
    if type(icon) ~= "string" then return false end
    return icon:match("^%d+$") ~= nil or icon:match("^rbxasset") ~= nil or icon:match("^http://www%.roblox%.com") ~= nil
end

local function ToImage(icon)
    if type(icon) == "number" or (type(icon) == "string" and icon:match("^%d+$")) then
        return "rbxassetid://" .. tostring(icon)
    end
    return icon
end

local function Hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
    return tostring(h)
end

local function GetExt(src)
    local clean = src:gsub("[%?#].*$", "")
    return (clean:match("%.(%w+)$") or ""):lower()
end

local function ResolveImage(src)
    if src == nil or src == "" then return nil end
    if type(src) == "number" then return "rbxassetid://" .. src end
    src = tostring(src)
    if src:match("^%d+$") then return "rbxassetid://" .. src end
    if src:match("^rbxasset") or src:match("^http://www%.roblox%.com") then return src end
    if not getcustomasset then return nil, "执行器不支持 getcustomasset，只能填图片 ID" end
    pcall(function() if makefolder and not isfolder("HPUI") then makefolder("HPUI") end end)
    local ext = GetExt(src)

    if src:match("^https?://") then
        if not (writefile and isfile) then return nil, "执行器不支持 writefile，无法缓存链接" end
        local path = "HPUI/bg_" .. Hash(src) .. "." .. ((ext ~= "" and #ext <= 5) and ext or "img")
        local have = false
        pcall(function() have = isfile(path) end)
        if not have then
            local data, why
            local ok, res = pcall(function() return game:HttpGet(src) end)
            if ok and type(res) == "string" then data = res else why = tostring(res) end
            if not data then
                local req = (syn and syn.request) or http_request or request
                if req then
                    local ok2, r = pcall(req, {Url = src, Method = "GET"})
                    if ok2 and r and (r.StatusCode == nil or r.StatusCode == 200) then
                        data = r.Body
                    else
                        why = ok2 and ("HTTP " .. tostring(r and r.StatusCode)) or tostring(r)
                    end
                end
            end
            if not data or #data < 16 then return nil, "下载失败: " .. tostring(why or "内容为空") end
            local head = data:sub(1, 15):lower()
            if head:sub(1, 1) == "<" then
                return nil, "这个链接返回的是网页，不是文件。GitHub 请用 raw.githubusercontent.com 开头的直链"
            end
            local okw, errw = pcall(writefile, path, data)
            if not okw then return nil, "写入文件失败: " .. tostring(errw) end
        end
        local ok, asset = pcall(getcustomasset, path)
        if not ok or not asset then return nil, "getcustomasset 失败: " .. tostring(asset) end
        return asset
    end

    if isfile then
        local ok, exist = pcall(isfile, src)
        if ok and exist then
            local ok2, asset = pcall(getcustomasset, src)
            if not ok2 or not asset then return nil, "getcustomasset 失败: " .. tostring(asset) end
            return asset
        end
    end
    return nil, "找不到文件: " .. src
end

local function ClampIntoView(target, margin, time)
    margin = margin or 8
    local vs = GetViewport()
    local inset = GuiService:GetGuiInset().Y
    local abs, size = target.AbsolutePosition, target.AbsoluteSize
    local dx, dy = 0, 0
    if abs.X < margin then dx = margin - abs.X
    elseif abs.X + size.X > vs.X - margin then dx = (vs.X - margin) - (abs.X + size.X) end
    if abs.Y < margin then dy = margin - abs.Y
    elseif abs.Y + size.Y > vs.Y - inset - margin then dy = (vs.Y - inset - margin) - (abs.Y + size.Y) end
    if dx ~= 0 or dy ~= 0 then
        local p = target.Position
        Tween(target, time or 0.35, {Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset + dy)})
    end
end

local function AddRipple(btn, radius)
    local holder
    btn.InputBegan:Connect(function(input)
        if library.Perf then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        if not holder then
            holder = New("Frame", {Name = "Ripple", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
                ClipsDescendants = true, ZIndex = 3, Parent = btn})
            Corner(radius or 8, holder)
        end
        local abs, size = btn.AbsolutePosition, btn.AbsoluteSize
        local x = math.clamp(input.Position.X - abs.X, 0, size.X)
        local y = math.clamp(input.Position.Y - abs.Y, 0, size.Y)
        local d = math.min(math.max(size.X, size.Y) * 2.4, 400)
        local c = New("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(0, 0),
            BorderSizePixel = 0, Parent = holder})
        Corner(999, c)
        Tween(c, 0.5, {Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1}, Quad)
        task.delay(0.55, function() c:Destroy() end)
    end)
end

function library.new(self, name, theme)
    if not (type(self) == "table" and (self == library or rawget(self, "HPUI") == library)) then name, theme = self, name end
    local cfg = {}
    if type(name) == "table" then
        cfg = name
        name = cfg.Title or cfg.Name
        theme = cfg.Theme
    end
    name = tostring(name or "HPUI")

    local genv = (getgenv and getgenv()) or _G
    if type(genv.__HPUI_Windows) == "table" then
        for _, w in ipairs(genv.__HPUI_Windows) do
            pcall(function() w:Destroy(true) end)
        end
    end
    genv.__HPUI_Windows = {}

    local themeName = "Glass"
    if type(theme) == "string" and theme:lower() ~= "dark" then
        for k in pairs(Themes) do
            if k:lower() == theme:lower() then themeName = k end
        end
    end

    for _, parent in ipairs({GetGuiParent(), services.CoreGui, LocalPlayer:FindFirstChildOfClass("PlayerGui")}) do
        pcall(function()
            for _, v in ipairs(parent:GetChildren()) do
                if v.Name == "frosty is cute" or v.Name == "HPUI" then v:Destroy() end
            end
        end)
    end

    local W = {Title = name, Destroyed = false, State = "open", Flags = library.flags,
        ToggleKey = cfg.ToggleKey or Enum.KeyCode.LeftControl, BgTransparency = cfg.BackgroundTransparency or 0.35,
        OverlayOpacity = cfg.OverlayOpacity or 0.6, HasBg = false, Tabs = {}, Ticks = {}}
    W.theme = Themes[themeName]
    W.themeName = themeName
    library.flags.__theme = themeName
    table.insert(library.Windows, W)
    table.insert(genv.__HPUI_Windows, W)

    local conns = {}
    local function Track(c) table.insert(conns, c) return c end

    local binds = {}
    local function bind(fn)
        table.insert(binds, fn)
        fn(W.theme, false)
        return fn
    end
    local function th() return W.theme end

    W.Language = cfg.Language or library.Loc.Default or "zh"
    library.flags.__lang = W.Language
    local function Tr(text)
        if type(text) ~= "string" then return text end
        local key = text:match("^loc:(.+)$")
        if not key then return text end
        local user = library.Loc.Translations[W.Language]
        local v = (user and user[key]) or (BuiltinLoc[W.Language] and BuiltinLoc[W.Language][key])
        return v or key
    end
    local locObjs = {}
    local function LocSet(obj, prop, text)
        if text == nil then return end
        obj[prop] = Tr(text)
        if type(text) == "string" and text:match("^loc:") then table.insert(locObjs, {obj, prop, text}) end
    end
    local sliceT = os.clock()
    local function Slice()
        if os.clock() - sliceT > 0.007 then
            task.wait()
            sliceT = os.clock()
            if W.Destroyed then error("HPUI: window destroyed", 0) end
        end
    end

    function W.SetLanguage(self, lang)
        W.Language = lang
        library.flags.__lang = lang
        for i = #locObjs, 1, -1 do
            local e = locObjs[i]
            if e[1].Parent then e[1][e[2]] = Tr(e[3]) else table.remove(locObjs, i) end
        end
    end

    local gui = New("ScreenGui", {Name = "HPUI", ResetOnSpawn = false, DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local okParent = pcall(function() gui.Parent = GetGuiParent() end)
    if not okParent or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    W.Gui = gui

    local vs = GetViewport()
    local size = Vector2.new(math.min(580, vs.X - 24), math.min(360, vs.Y - 70))
    if typeof(cfg.Size) == "UDim2" then
        size = Vector2.new(cfg.Size.X.Offset, cfg.Size.Y.Offset)
    elseif typeof(cfg.Size) == "Vector2" then
        size = cfg.Size
    end

    W.Glow = cfg.Glow ~= false
    W.Rainbow = cfg.Rainbow ~= false
    W.BgFps = 12
    W.SliderPaints = {}
    W.Blur = cfg.Blur == true
    W.Perf = cfg.Perf == true
    W.LowFps = 0
    W.SlowTicks = 0

    local COMET = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(0.28, 0.82),
        NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(0.72, 0.82), NumberSequenceKeypoint.new(1, 0.82)})
    local function glowColor(t)
        if W.Rainbow then
            local k = {}
            for i = 0, 6 do table.insert(k, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1))) end
            return ColorSequence.new(k)
        end
        return ColorSequence.new({ColorSequenceKeypoint.new(0, t.Accent), ColorSequenceKeypoint.new(0.5, t.Accent2),
            ColorSequenceKeypoint.new(1, t.Accent)})
    end

    local Holder = New("Frame", {Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size.X, size.Y), BackgroundTransparency = 1, Parent = gui})
    local HolderScale = {Scale = 1}

    local Main = Instance.new("Frame")
    local isGroup = false
    Main.ClipsDescendants = true
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.Size = UDim2.fromScale(1, 1)
    Main.BorderSizePixel = 0
    Main.Parent = Holder
    local MainScale = New("UIScale", {Scale = 1, Parent = Main})
    if isGroup then Main.GroupTransparency = 1 end
    Corner(18, Main)
    local decor, decorAcc = {}, 0
    local function DecorTween(grad, kind, period)
        local d = {grad = grad, kind = kind, period = period, active = false, t = 0}
        function d.Play(_) d.active = true end
        function d.Pause(_) d.active = false end
        table.insert(decor, d)
        return d
    end

    local MainStroke = New("UIStroke", {Thickness = 2, Transparency = 0, Color = Color3.new(1, 1, 1), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Main})
    local GlowGrad = New("UIGradient", {Parent = MainStroke})
    local glowTween = DecorTween(GlowGrad, "rot", 6)
    glowTween:Play()
    local function applyGlow()
        MainStroke.Enabled = W.Glow
        GlowGrad.Color = glowColor(W.theme)
    end
    Main.BackgroundColor3 = Color3.new(1, 1, 1)
    local MainGrad = New("UIGradient", {Rotation = 55, Parent = Main})
    bind(function(t, a)
        local light = (t.Main.R + t.Main.G + t.Main.B) / 3 > 0.6
        MainGrad.Color = ColorSequence.new(t.Main:Lerp(Color3.new(1, 1, 1), light and 0 or 0.09), t.Main:Lerp(Color3.new(0, 0, 0), light and 0.07 or 0.3))
        P(Main, {BackgroundTransparency = t.MainA}, a)
        applyGlow()
    end)

    local BgLayer = New("Frame", {Name = "BgLayer", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 0, Parent = Main})
    local BgImage = New("ImageLabel", {Name = "BgImage", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        ScaleType = Enum.ScaleType.Crop, ImageTransparency = 1, Parent = BgLayer})
    Corner(18, BgImage)
    local Overlay = New("Frame", {Name = "Overlay", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundTransparency = 1, Parent = BgLayer})
    Corner(18, Overlay)
    bind(function(t, a) P(Overlay, {BackgroundColor3 = t.Main}, a) end)

    local Top = New("Frame", {Name = "Top", Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = Main})
    local TopLine = New("Frame", {Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0,
        BackgroundTransparency = 0.5, Parent = Top})
    bind(function(t, a) P(TopLine, {BackgroundColor3 = t.Stroke, BackgroundTransparency = 1}, a) end)

    local TitleLbl = New("TextLabel", {Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -120, 1, 0), Font = Enum.Font.GothamSemibold, Text = name, TextSize = 14, TextXAlignment = Left,
        TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.6, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Top})
    local TitleGrad = New("UIGradient", {Offset = Vector2.new(-1, 0), Parent = TitleLbl})
    bind(function(t)
        TitleGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t.Accent), ColorSequenceKeypoint.new(0.5, t.Accent2),
            ColorSequenceKeypoint.new(1, t.Accent)})
    end)
    local titleTween = DecorTween(TitleGrad, "off", 3.2)
    titleTween:Play()

    local function TopButton(kind, xoff)
        local b = New("TextButton", {AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xoff, 0.5, 0),
            Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, Text = "", Parent = Top})
        Corner(14, b)
        local bars = {}
        local function bar(rot)
            local f = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(kind == "close" and 14 or 12, 2), Rotation = rot, BorderSizePixel = 0, Parent = b})
            Corner(1, f)
            table.insert(bars, f)
        end
        if kind == "close" then bar(45) bar(-45) else bar(0) end
        bind(function(t, a) for _, f in ipairs(bars) do P(f, {BackgroundColor3 = t.SubText}, a) end end)
        return b, bars
    end
    local BtnClose, CloseBars = TopButton("close", -12)
    local BtnMin, MinBars = TopButton("min", -46)
    local function tintBars(bars, color) for _, f in ipairs(bars) do Tween(f, 0.15, {BackgroundColor3 = color}) end end
    BtnMin.MouseEnter:Connect(function()
        Tween(BtnMin, 0.15, {BackgroundTransparency = th().HoverA, BackgroundColor3 = th().Hover})
        tintBars(MinBars, th().Text)
    end)
    BtnMin.MouseLeave:Connect(function()
        Tween(BtnMin, 0.15, {BackgroundTransparency = 1})
        tintBars(MinBars, th().SubText)
    end)
    BtnClose.MouseEnter:Connect(function()
        Tween(BtnClose, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = rgb(232, 70, 80)})
        tintBars(CloseBars, Color3.new(1, 1, 1))
    end)
    BtnClose.MouseLeave:Connect(function()
        Tween(BtnClose, 0.15, {BackgroundTransparency = 1})
        tintBars(CloseBars, th().SubText)
    end)

    local active
    Track(UIS.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            active.t = os.clock()
            if not pcall(active.move, input) then active = nil end
        end
    end))
    Track(UIS.InputEnded:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local a = active
            active = nil
            if a.finish then pcall(a.finish) end
        end
    end))
    local function startDrag(move, finish) active = {move = move, finish = finish, t = os.clock()} end
    local function releaseDrag()
        if active then
            local a = active
            active = nil
            if a.finish then pcall(a.finish) end
        end
    end
    Track(UIS.WindowFocusReleased:Connect(releaseDrag))

    local function MakeDrag(handle, target, opts)
        opts = opts or {}
        handle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local startMouse, startPos, moved = input.Position, target.Position, false
            startDrag(function(inp)
                local d = inp.Position - startMouse
                if not moved and d.Magnitude < (opts.threshold or 4) then return end
                moved = true
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end, function()
                if opts.onEnd then opts.onEnd(moved) end
            end)
        end)
    end
    MakeDrag(Top, Holder, {onEnd = function() ClampIntoView(Holder, 8) end})

    local SIDE_W = 124
    local Side = New("Frame", {Name = "Side", Position = UDim2.fromOffset(0, 0), Size = UDim2.new(0, SIDE_W, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, Parent = Main})
    TitleLbl.Parent = Side
    TitleLbl.Position = UDim2.fromOffset(14, 0)
    TitleLbl.Size = UDim2.new(1, -20, 0, 36)
    local SideLine = New("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0, BackgroundTransparency = 0.85, Parent = Side})
    bind(function(t, a) P(Side, {BackgroundColor3 = t.Side}, a); P(SideLine, {BackgroundColor3 = t.Stroke, BackgroundTransparency = 1}, a) end)

    local SearchBg = New("Frame", {Position = UDim2.fromOffset(8, 42), Size = UDim2.new(1, -16, 0, 30), BorderSizePixel = 0, Parent = Side})
    Corner(9, SearchBg)
    local SearchBox = New("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham, PlaceholderText = "搜索功能…", Text = "", TextSize = 13, ClearTextOnFocus = false,
        TextXAlignment = Left, Parent = SearchBg})
    LocSet(SearchBox, "PlaceholderText", "loc:ui_search")
    bind(function(t, a)
        P(SearchBg, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA}, a)
        P(SearchBox, {TextColor3 = t.Text, PlaceholderColor3 = t.SubText}, a)
    end)

    local TabList = New("ScrollingFrame", {Name = "TabList", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 80),
        Size = UDim2.new(1, 0, 1, -126), ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Side})
    New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList})
    Pad(2, 8, TabList)

    local Pinned = New("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -46), Size = UDim2.new(1, 0, 0, 46), Parent = Side})
    Pad(6, 8, Pinned)

    local Content = New("Frame", {Name = "Content", Position = UDim2.fromOffset(SIDE_W + 8, 44), Size = UDim2.new(1, -(SIDE_W + 16), 1, -52),
        BackgroundTransparency = 1, ClipsDescendants = true, Parent = Main})

    local Grip = New("TextButton", {AutoButtonColor = false, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -2, 1, -2), Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1, Text = "", ZIndex = 10, Parent = Main})
    local GripDots = {}
    for _, pos in ipairs({{16, 16}, {10, 16}, {16, 10}}) do
        local d = New("Frame", {Position = UDim2.fromOffset(pos[1], pos[2]), Size = UDim2.fromOffset(3, 3), BorderSizePixel = 0, Parent = Grip})
        Corner(2, d)
        table.insert(GripDots, d)
    end
    bind(function(t, a) for _, d in ipairs(GripDots) do P(d, {BackgroundColor3 = t.SubText}, a) end end)
    Grip.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local startMouse, startSize, startPos = input.Position, Holder.AbsoluteSize / HolderScale.Scale, Holder.Position
        local vsz = GetViewport()
        startDrag(function(inp)
            local d = inp.Position - startMouse
            local nw = math.clamp(startSize.X + d.X, 440, math.max(440, vsz.X - 16))
            local nh = math.clamp(startSize.Y + d.Y, 290, math.max(290, vsz.Y - 60))
            Holder.Size = UDim2.fromOffset(nw, nh)
            Holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (nw - startSize.X) / 2, startPos.Y.Scale, startPos.Y.Offset + (nh - startSize.Y) / 2)
        end, function() ClampIntoView(Holder, 8) end)
    end)

    local function setTabVisual(tab, active, animated)
        local t = th()
        P(tab.Btn, {BackgroundTransparency = 1}, animated, 0.2)
        P(tab.Label, {TextColor3 = active and t.Text or t.SubText}, animated, 0.2)
        P(tab.Icon, {[tab.IconIsImage and "ImageColor3" or "TextColor3"] = active and t.Accent or t.SubText}, animated, 0.2)
        P(tab.Bar, {Size = active and UDim2.fromOffset(3, 18) or UDim2.fromOffset(3, 0), BackgroundColor3 = t.Accent}, animated, 0.3)
    end

    local function filter(q)
        local tab = W.current
        if not tab then return end
        q = (q or ""):lower()
        for _, sec in ipairs(tab.sections) do
            local nameHit = q ~= "" and tostring(Tr(sec.name)):lower():find(q, 1, true) ~= nil
            local any = false
            for _, m in ipairs(sec.modules) do
                if m.Parent then
                    local show = q == "" or nameHit or (tostring(m:GetAttribute("HPName") or "")):find(q, 1, true) ~= nil
                    m.Visible = show
                    if show then any = true end
                end
            end
            sec.searching = q ~= ""
            sec.Frame.Visible = q == "" or any
            sec.refresh()
        end
    end
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function() filter(SearchBox.Text) end)

    function W.SelectTab(self, tab)
        if not tab or W.current == tab then return end
        local old = W.current
        W.current = tab
        if old then
            old.Page.Visible = false
            setTabVisual(old, false, true)
        end
        tab.Page.Visible = true
        if W.Perf then
            tab.Page.Position = UDim2.fromOffset(0, 0)
        else
            tab.Page.Position = UDim2.fromOffset(0, 12)
            Tween(tab.Page, 0.3, {Position = UDim2.fromOffset(0, 0)})
        end
        setTabVisual(tab, true, true)
        if SearchBox.Text ~= "" then SearchBox.Text = "" end
        filter("")
        if tab.Build then
            local b = tab.Build
            tab.Build = nil
            task.spawn(b)
        end
    end

    local function createTab(tabName, icon, pinned)
        local tab = {sections = {}}
        tab.Btn = New("TextButton", {Name = "Tab_" .. tostring(tabName), AutoButtonColor = false, Text = "", BorderSizePixel = 0,
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = #W.Tabs, Parent = pinned and Pinned or TabList})
        Corner(9, tab.Btn)
        tab.Bar = New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(3, 0),
            BorderSizePixel = 0, Parent = tab.Btn})
        Corner(2, tab.Bar)

        tab.IconIsImage = icon == nil or IsImage(icon)
        if tab.IconIsImage then
            tab.Icon = New("ImageLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 7), Size = UDim2.fromOffset(16, 16),
                Image = ToImage(icon or 4370341699), Parent = tab.Btn})
        else
            tab.Icon = New("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 7), Size = UDim2.fromOffset(16, 16),
                Font = Enum.Font.GothamBold, Text = tostring(icon), TextSize = 15, Parent = tab.Btn})
        end
        tab.Label = New("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -34, 1, 0),
            Font = Enum.Font.GothamMedium, Text = tostring(tabName), TextSize = 12, TextXAlignment = Left, TextStrokeTransparency = 0.55,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = tab.Btn})
        LocSet(tab.Label, "Text", tostring(tabName))

        tab.Page = New("ScrollingFrame", {Name = "Page_" .. tostring(tabName), Active = true, BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = Content})
        New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Page})
        New("UIPadding", {PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 8), Parent = tab.Page})

        bind(function(t, a)
            P(tab.Page, {ScrollBarImageColor3 = t.Accent}, a)
            setTabVisual(tab, W.current == tab, a)
        end)
        if HasHover then
            tab.Btn.MouseEnter:Connect(function() if W.current ~= tab then Tween(tab.Label, 0.15, {TextColor3 = th().Text}) end end)
            tab.Btn.MouseLeave:Connect(function() if W.current ~= tab then Tween(tab.Label, 0.15, {TextColor3 = th().SubText}) end end)
        end
        tab.Btn.MouseButton1Click:Connect(function() W:SelectTab(tab) end)

        table.insert(W.Tabs, tab)
        if not W.current and not pinned then W:SelectTab(tab) end

        function tab.section(tabSelf, secName, openState)
            secName = tostring(secName or "Section")
            Slice()
            local open = openState ~= false
            local secObj = {name = secName, modules = {}, searching = false}
            table.insert(tab.sections, secObj)

            local Section = New("Frame", {Name = "Section", BackgroundTransparency = 0.93, BorderSizePixel = 0, ClipsDescendants = true,
                Size = UDim2.new(1, 0, 0, 34), LayoutOrder = #tab.sections, Parent = tab.Page})
            Corner(12, Section)
            secObj.Frame = Section

            local Header = New("TextButton", {AutoButtonColor = false, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = Section})
            local SecTitle = New("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -64, 1, 0),
                Font = Enum.Font.GothamBold, Text = secName, TextSize = 13, TextXAlignment = Left, Parent = Header})
            LocSet(SecTitle, "Text", secName)
            local SecBar = New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(4, 14),
                BorderSizePixel = 0, Parent = Header})
            Corner(2, SecBar)
            local Arrow = New("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -20, 0.5, 0),
                Size = UDim2.fromOffset(20, 20), Font = Enum.Font.GothamBold, Text = "+", TextSize = 18, Rotation = open and 45 or 0, Parent = Header})
            bind(function(t, a)
                P(Section, {BackgroundColor3 = t.Element, BackgroundTransparency = t.SecA}, a)
                P(SecTitle, {TextColor3 = t.Text}, a)
                P(Arrow, {TextColor3 = t.Accent}, a)
                P(SecBar, {BackgroundColor3 = t.Accent}, a)
            end)

            local Objs = New("Frame", {Name = "Objs", BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 36), Size = UDim2.new(1, -8, 0, 0), Parent = Section})
            local ObjsL = New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Objs})

            local function refresh(instant)
                local isOpen = open or secObj.searching
                local target = isOpen and (36 + ObjsL.AbsoluteContentSize.Y + 6) or 34
                if instant then
                    Section.Size = UDim2.new(1, 0, 0, target)
                else
                    Tween(Section, 0.28, {Size = UDim2.new(1, 0, 0, target)})
                end
            end
            secObj.refresh = refresh
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if W.Animating then return end
                refresh(true)
            end)
            refresh(true)

            Header.MouseButton1Click:Connect(function()
                open = not open
                Tween(Arrow, 0.3, {Rotation = open and 45 or 0}, EBack)
                refresh(false)
            end)
            if HasHover then
                Header.MouseEnter:Connect(function() Tween(Section, 0.15, {BackgroundTransparency = math.max(th().SecA - 0.05, 0)}) end)
                Header.MouseLeave:Connect(function() Tween(Section, 0.15, {BackgroundTransparency = th().SecA}) end)
            end

            local function Base(label, height, clickable, nameKey, desc)
                Slice()
                if desc and desc ~= "" then height = math.max(height, 54) end
                local Module = New("Frame", {Name = nameKey or "Module", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height),
                    LayoutOrder = #secObj.modules, Parent = Objs})
                Module:SetAttribute("HPName", tostring(Tr(label) or ""):lower())
                table.insert(secObj.modules, Module)
                local Back = New(clickable and "TextButton" or "Frame", {Name = "Back", Size = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 0.08, BorderSizePixel = 0, Parent = Module})
                if clickable then Back.AutoButtonColor = false Back.Text = "" end
                Corner(8, Back)
                local Title = New("TextLabel", {Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0),
                    Size = UDim2.new(1, -28, 0, height), Font = Enum.Font.GothamMedium, Text = tostring(label or ""), TextSize = 13,
                    TextXAlignment = Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Back})
                LocSet(Title, "Text", label)
                if desc and desc ~= "" then
                    Title.Position = UDim2.fromOffset(14, 8)
                    Title.Size = UDim2.new(1, -28, 0, 20)
                    local D = New("TextLabel", {Name = "Desc", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 28), Size = UDim2.new(1, -28, 0, 18),
                        Font = Enum.Font.Gotham, Text = tostring(desc), TextSize = 12, TextXAlignment = Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Back})
                    LocSet(D, "Text", desc)
                    bind(function(t, a) P(D, {TextColor3 = t.SubText}, a) end)
                end
                bind(function(t, a)
                    P(Back, {BackgroundColor3 = t.Element, BackgroundTransparency = t.ElemA}, a)
                    P(Title, {TextColor3 = t.Text}, a)
                end)
                if clickable then
                    if HasHover then
                        Back.MouseEnter:Connect(function() Tween(Back, 0.15, {BackgroundTransparency = th().HoverA}) end)
                        Back.MouseLeave:Connect(function() Tween(Back, 0.15, {BackgroundTransparency = th().ElemA}) end)
                    end
                    AddRipple(Back, 8)
                end
                return Module, Back, Title
            end

            local section = {}
            function section.Section() return secObj end

            function section.Button(sec, text, callback, desc)
                local Module, Back, Title = Base(text, 32, true, "BtnModule", desc)
                Title.Size = UDim2.new(1, -46, 0, Title.Size.Y.Offset)
                local Icon = New("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20), Font = Enum.Font.GothamBold, Text = "›", TextSize = 22, Parent = Back})
                bind(function(t, a) P(Icon, {TextColor3 = t.Accent}, a) end)
                Back.MouseButton1Click:Connect(function()
                    Tween(Icon, 0.12, {Position = UDim2.new(1, -6, 0.5, 0)})
                    task.delay(0.12, function() Tween(Icon, 0.3, {Position = UDim2.new(1, -12, 0.5, 0)}, EBack) end)
                    Safe(callback)
                end)
                local f = {Module = Module}
                function f.SetText(_, t) LocSet(Title, "Text", tostring(t)) Title.Text = Tr(tostring(t)) Module:SetAttribute("HPName", tostring(t):lower()) end
                function f.Destroy() Module:Destroy() end
                return f
            end

            function section.Label(sec, text)
                local Module = New("Frame", {Name = "LabelModule", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = #secObj.modules, Parent = Objs})
                Module:SetAttribute("HPName", tostring(text or ""):lower())
                table.insert(secObj.modules, Module)
                local L = New("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.35,
                    BorderSizePixel = 0, Font = Enum.Font.Gotham, Text = tostring(text or ""), TextSize = 12, TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Center, Parent = Module})
                Corner(8, L)
                LocSet(L, "Text", text)
                Pad(8, 12, L)
                bind(function(t, a) P(L, {BackgroundColor3 = t.Element, BackgroundTransparency = t.ElemA, TextColor3 = t.Text}, a) end)
                return L
            end

            function section.Paragraph(sec, title, content)
                local Module = New("Frame", {Name = "ParagraphModule", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = #secObj.modules, Parent = Objs})
                Module:SetAttribute("HPName", (tostring(title or "") .. " " .. tostring(content or "")):lower())
                table.insert(secObj.modules, Module)
                local Card = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.2,
                    BorderSizePixel = 0, Parent = Module})
                Corner(8, Card)
                Pad(10, 12, Card)
                New("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Card})
                local T = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.GothamBold, Text = tostring(title or ""), TextSize = 14, TextWrapped = true, TextXAlignment = Left, LayoutOrder = 1, Parent = Card})
                local C = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham, Text = tostring(content or ""), TextSize = 13, TextWrapped = true, TextXAlignment = Left, LayoutOrder = 2, Parent = Card})
                LocSet(T, "Text", title)
                LocSet(C, "Text", content)
                bind(function(t, a)
                    P(Card, {BackgroundColor3 = t.Element, BackgroundTransparency = t.ElemA}, a)
                    P(T, {TextColor3 = t.Text}, a)
                    P(C, {TextColor3 = t.SubText}, a)
                end)
                local f = {Module = Module}
                function f.Set(_, a, b) if a ~= nil then T.Text = tostring(a) end if b ~= nil then C.Text = tostring(b) end end
                return f
            end

            function section.Divider(sec)
                local Module = New("Frame", {Name = "DividerModule", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8),
                    LayoutOrder = #secObj.modules, Parent = Objs})
                Module:SetAttribute("HPName", "")
                local line = New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0, BackgroundTransparency = 0.4, Parent = Module})
                bind(function(t, a) P(line, {BackgroundColor3 = t.Stroke}, a) end)
                table.insert(secObj.modules, Module)
                return {Module = Module}
            end

            function section.Toggle(sec, text, flag, enabled, callback, desc)
                flag = flag or ("toggle_" .. tostring(text))
                local state = enabled == true
                library.flags[flag] = state
                local Module, Back, Title = Base(text, 32, true, "ToggleModule", desc)
                Title.Size = UDim2.new(1, -44, 0, Title.Size.Y.Offset)
                local Track_ = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(20, 20),
                    BorderSizePixel = 0, Parent = Back})
                Corner(6, Track_)
                local Knob = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = Track_})
                Corner(3, Knob)

                local function visual(animated)
                    local t = th()
                    P(Track_, {BackgroundColor3 = state and t.Accent or t.Off, BackgroundTransparency = state and 0 or 0.8}, animated, 0.2)
                    P(Knob, {Size = state and UDim2.fromOffset(8, 8) or UDim2.fromOffset(0, 0)}, animated, 0.25, EBack)
                end
                bind(function(t, a) visual(a) end)

                local f = {Module = Module}
                function f.SetState(_, v, silent)
                    if v == nil then v = not state end
                    v = v and true or false
                    if v == state then return end
                    state = v
                    library.flags[flag] = v
                    visual(true)
                    if not silent then Safe(callback, v) end
                end
                function f.Get() return state end
                function f.Destroy() Module:Destroy() end
                Back.MouseButton1Click:Connect(function() f:SetState() end)
                library.setters[flag] = function(v) f:SetState(v) end
                return f
            end

            function section.Keybind(sec, text, default, callback, flag, onChange)
                if type(default) == "string" then default = Enum.KeyCode[default] end
                local bindKey = default
                local banned = {Return = true, Space = true, Tab = true, Backquote = true, CapsLock = true, Unknown = true}
                local short = {RightControl = "RCtrl", LeftControl = "LCtrl", LeftShift = "LShift", RightShift = "RShift", Semicolon = ";",
                    Quote = "'", LeftBracket = "[", RightBracket = "]", Equals = "=", Minus = "-", RightAlt = "RAlt", LeftAlt = "LAlt"}
                local function keyText(k) return k and (short[k.Name] or k.Name) or "无" end

                local Module, Back, Title = Base(text, 32, true, "KeybindModule")
                local Box = New("TextLabel", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(60, 26),
                    Font = Enum.Font.GothamMedium, Text = keyText(bindKey), TextSize = 13, BorderSizePixel = 0, Parent = Back})
                Corner(7, Box)
                bind(function(t, a)
                    P(Box, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA, TextColor3 = t.Accent}, a)
                end)
                local function fit()
                    local w = math.max(48, Box.TextBounds.X + 22)
                    Tween(Box, 0.2, {Size = UDim2.fromOffset(w, 26)})
                    Title.Size = UDim2.new(1, -(w + 30), 0, 32)
                end
                fit()
                Box:GetPropertyChangedSignal("Text"):Connect(fit)

                local listening, listenConn = false, nil
                local f = {Module = Module}
                local function setKey(k, silent)
                    bindKey = k
                    Box.Text = keyText(k)
                    if flag then library.flags[flag] = k and k.Name or nil end
                    if not silent and onChange then Safe(onChange, k) end
                end
                function f.SetKey(_, k, silent)
                    if type(k) == "string" then k = Enum.KeyCode[k] end
                    setKey(k, silent)
                end
                function f.Get() return bindKey end

                Back.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    W.Listening = true
                    Box.Text = "…"
                    listenConn = UIS.InputBegan:Connect(function(inp)
                        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        local n = inp.KeyCode.Name
                        if listenConn then listenConn:Disconnect() listenConn = nil end
                        task.defer(function() listening = false W.Listening = false end)
                        if n == "Escape" then Box.Text = keyText(bindKey) return end
                        if n == "Backspace" or n == "Delete" then setKey(nil) return end
                        if banned[n] then Box.Text = keyText(bindKey) return end
                        setKey(inp.KeyCode)
                    end)
                end)
                Track(UIS.InputBegan:Connect(function(inp, gpe)
                    if gpe or listening or not bindKey then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == bindKey then
                        Safe(callback, bindKey.Name)
                    end
                end))
                if flag then
                    library.flags[flag] = bindKey and bindKey.Name or nil
                    library.setters[flag] = function(v) f:SetKey(v, false) end
                end
                return f
            end

            function section.Textbox(sec, text, flag, default, callback)
                flag = flag or ("textbox_" .. tostring(text))
                default = default ~= nil and tostring(default) or ""
                library.flags[flag] = default
                local Module, Back, Title = Base(text, 32, false, "TextboxModule")
                Title.Size = UDim2.new(0.5, -14, 0, 32)
                local BoxBg = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.45, 0, 0, 26),
                    BorderSizePixel = 0, Parent = Back})
                Corner(7, BoxBg)
                local Box = New("TextBox", {BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), Font = Enum.Font.Gotham,
                    Text = default, PlaceholderText = "输入…", TextSize = 13, ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Left, Parent = BoxBg})
                bind(function(t, a)
                    P(BoxBg, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA}, a)
                    P(Box, {TextColor3 = t.Text, PlaceholderColor3 = t.SubText}, a)
                end)
                local ring
                Box.Focused:Connect(function()
                    if not ring then ring = New("UIStroke", {Thickness = 1, Parent = BoxBg}) end
                    ring.Color = th().Accent
                    ring.Enabled = true
                end)
                Box.FocusLost:Connect(function(enter)
                    if ring then ring.Enabled = false end
                    if Box.Text == "" and default ~= "" then Box.Text = default end
                    library.flags[flag] = Box.Text
                    Safe(callback, Box.Text, enter)
                end)
                local f = {Module = Module}
                function f.Set(_, v, silent)
                    Box.Text = tostring(v)
                    library.flags[flag] = Box.Text
                    if not silent then Safe(callback, Box.Text, false) end
                end
                function f.Get() return Box.Text end
                library.setters[flag] = function(v) f:Set(v) end
                return f
            end

            function section.Slider(sec, text, flag, default, min, max, precise, callback, color)
                flag = flag or ("slider_" .. tostring(text))
                min, max = tonumber(min) or 1, tonumber(max) or 10
                default = tonumber(default) or min
                local custom = typeof(color) == "Color3" and color or nil
                local dec = precise == true and 1 or (type(precise) == "number" and precise or 0)
                local Module, Back, Title = Base(text, 54, false, "SliderModule")
                Title.Size = UDim2.new(1, -86, 0, 30)

                local ValBg = New("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 5), Size = UDim2.fromOffset(60, 22),
                    BorderSizePixel = 0, Parent = Back})
                Corner(7, ValBg)
                local Box = New("TextBox", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamMedium, Text = "",
                    TextSize = 13, ClearTextOnFocus = false, Parent = ValBg})
                local Bar = New("Frame", {Position = UDim2.fromOffset(14, 38), Size = UDim2.new(1, -28, 0, 8), BorderSizePixel = 0, Parent = Back})
                Corner(4, Bar)
                local Fill = New("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = Bar})
                Corner(4, Fill)
                local FillGrad = New("UIGradient", {Parent = Fill})
                local Knob = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
                    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2, Parent = Bar})
                Corner(7, Knob)
                local KnobStroke = New("UIStroke", {Thickness = 2, Parent = Knob})
                local Hit = New("TextButton", {Text = "", BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 28), Size = UDim2.new(1, -16, 0, 26),
                    ZIndex = 3, Parent = Back})
                local function paintFill(t, a)
                    local c = custom or W.SliderColor
                    if c then
                        FillGrad.Color = ColorSequence.new(c)
                        P(KnobStroke, {Color = c}, a)
                        P(Box, {TextColor3 = c}, a)
                    else
                        FillGrad.Color = ColorSequence.new(t.Accent, t.Accent2)
                        P(KnobStroke, {Color = t.Accent}, a)
                        P(Box, {TextColor3 = t.Accent}, a)
                    end
                end
                table.insert(W.SliderPaints, function(animated) paintFill(W.theme, animated) end)
                bind(function(t, a)
                    P(Bar, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA}, a)
                    P(Fill, {BackgroundColor3 = Color3.new(1, 1, 1)}, a)
                    paintFill(t, a)
                    P(ValBg, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA}, a)
                end)

                local value
                local function setValue(v, silent, instant, force)
                    v = math.clamp(tonumber(v) or min, min, max)
                    local m = 10 ^ dec
                    v = math.floor(v * m + 0.5) / m
                    local pct = (max == min) and 0 or (v - min) / (max - min)
                    P(Fill, {Size = UDim2.fromScale(pct, 1)}, not instant, 0.12, Quad)
                    P(Knob, {Position = UDim2.fromScale(pct, 0.5)}, not instant, 0.12, Quad)
                    if not Box:IsFocused() then Box.Text = tostring(v) end
                    if v == value and not force then return end
                    value = v
                    library.flags[flag] = v
                    if not silent then Safe(callback, v) end
                end
                local function fromX(x)
                    local pct = math.clamp((x - Bar.AbsolutePosition.X) / math.max(Bar.AbsoluteSize.X, 1), 0, 1)
                    setValue(min + (max - min) * pct, false, true)
                end
                Hit.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                    local pg = tab.Page
                    pg.ScrollingEnabled = false
                    Tween(Knob, 0.15, {Size = UDim2.fromOffset(18, 18)}, EBack)
                    fromX(input.Position.X)
                    startDrag(function(inp) fromX(inp.Position.X) end, function()
                        pg.ScrollingEnabled = true
                        Tween(Knob, 0.2, {Size = UDim2.fromOffset(14, 14)})
                    end)
                end)
                Box.FocusLost:Connect(function()
                    local n = tonumber(Box.Text)
                    if n then setValue(n, false, false, true) else Box.Text = tostring(value) end
                end)
                setValue(default, false, true, true)

                local f = {Module = Module}
                function f.SetValue(_, v, silent) setValue(v, silent, false, true) end
                f.Set = f.SetValue
                function f.Get() return value end
                function f.SetColor(_, c) custom = typeof(c) == "Color3" and c or nil paintFill(W.theme, true) end
                function f.Destroy() Module:Destroy() end
                library.setters[flag] = function(v) f:SetValue(v) end
                return f
            end

            local function makeDropdown(text, flag, options, callback, multi, default)
                flag = flag or ((multi and "multidropdown_" or "dropdown_") .. tostring(text))
                options = options or {}
                local HEADER = 32
                local selected, selSet, btns, order, open = nil, {}, {}, {}, false
                local optSet, built = {}, false
                local makeBtn
                library.flags[flag] = multi and {} or nil

                local Module, Back, Title = Base(text, HEADER, true, multi and "MultiDropdownModule" or "DropdownModule")
                Module.ClipsDescendants = true
                Title.Size = UDim2.new(0.5, -14, 0, HEADER)
                local ValueLbl = New("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, 0),
                    Size = UDim2.new(0.46, -30, 0, 20), Font = Enum.Font.GothamMedium, Text = "无", TextSize = 13, TextXAlignment = Right,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = Back})
                local Arrow = New("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20), Font = Enum.Font.GothamBold, Text = "+", TextSize = 18, Parent = Back})

                local List = New("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, HEADER + 4),
                    Size = UDim2.new(1, 0, 0, 0), ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Module})
                local ListL = New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = List})
                New("UIPadding", {PaddingRight = UDim.new(0, 4), Parent = List})

                local SBg = New("Frame", {Size = UDim2.new(1, -4, 0, 28), BorderSizePixel = 0, LayoutOrder = -1, Visible = false, Parent = List})
                Corner(7, SBg)
                local SBox = New("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
                    Font = Enum.Font.Gotham, PlaceholderText = "搜索选项…", Text = "", TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Left, Parent = SBg})

                local function getList()
                    local l = {}
                    for _, o in ipairs(order) do if selSet[o] then table.insert(l, o) end end
                    return l
                end
                local function paint(animated)
                    local t = th()
                    for opt, b in pairs(btns) do
                        local on = multi and selSet[opt] or (not multi and selected == opt)
                        P(b, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA, TextColor3 = on and t.Accent or t.Text}, animated, 0.15)
                        b.Check.Visible = on and true or false
                        b.Check.BackgroundColor3 = t.Accent
                    end
                    P(SBg, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA}, animated)
                    P(SBox, {TextColor3 = t.Text, PlaceholderColor3 = t.SubText}, animated)
                    P(ValueLbl, {TextColor3 = t.Accent}, animated)
                    P(Arrow, {TextColor3 = t.SubText}, animated)
                    P(List, {ScrollBarImageColor3 = t.Accent}, animated)
                    if multi then
                        local l = getList()
                        ValueLbl.Text = #l == 0 and "无" or (#l <= 2 and table.concat(l, ", ") or (#l .. " 项已选"))
                    else
                        ValueLbl.Text = selected or "无"
                    end
                end
                bind(function(t, a) paint(a) end)

                local function resize()
                    local listH = math.min(ListL.AbsoluteContentSize.Y, 156)
                    List.Size = UDim2.new(1, 0, 0, listH)
                    Tween(Module, 0.3, {Size = UDim2.new(1, 0, 0, open and (HEADER + 8 + listH) or HEADER)})
                end
                ListL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if open then resize() end end)

                local function setOpen(v)
                    open = v
                    if open and not built then
                        built = true
                        for i2, o in ipairs(order) do makeBtn(o, i2) end
                        paint(false)
                    end
                    if open then SBox.Text = "" end
                    Tween(Arrow, 0.3, {Rotation = open and 45 or 0}, EBack)
                    resize()
                end
                Back.MouseButton1Click:Connect(function() setOpen(not open) end)

                SBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local q = SBox.Text:lower()
                    for opt, b in pairs(btns) do
                        b.Visible = q == "" or opt:lower():find(q, 1, true) ~= nil
                    end
                end)

                local f = {Module = Module}
                local function commit(silent)
                    if multi then
                        library.flags[flag] = getList()
                        if not silent then Safe(callback, getList()) end
                    else
                        library.flags[flag] = selected
                        if not silent and selected ~= nil then Safe(callback, selected) end
                    end
                    paint(true)
                end

                makeBtn = function(opt, idx)
                    local b = New("TextButton", {Name = "Option_" .. opt, AutoButtonColor = false, Text = opt, Font = Enum.Font.GothamMedium,
                        TextSize = 13, TextXAlignment = Left, BackgroundTransparency = 0.3, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 30),
                        LayoutOrder = idx, Parent = List})
                    Corner(7, b)
                    Pad(0, 12, b)
                    local ck = New("Frame", {Name = "Check", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.fromOffset(8, 8), BorderSizePixel = 0, Visible = false, Parent = b})
                    Corner(4, ck)
                    btns[opt] = b
                    if HasHover then
                        b.MouseEnter:Connect(function() Tween(b, 0.12, {BackgroundTransparency = math.max(th().InsetA - 0.25, 0)}) end)
                        b.MouseLeave:Connect(function() Tween(b, 0.12, {BackgroundTransparency = th().InsetA}) end)
                    end
                    b.MouseButton1Click:Connect(function()
                        if multi then
                            selSet[opt] = not selSet[opt] or nil
                            commit(false)
                        else
                            selected = opt
                            commit(false)
                            setOpen(false)
                        end
                    end)
                end

                function f.AddOption(_, opt)
                    opt = tostring(opt)
                    if optSet[opt] then return end
                    optSet[opt] = true
                    table.insert(order, opt)
                    SBg.Visible = #order > 6
                    if built then
                        makeBtn(opt, #order)
                        paint(false)
                    end
                end
                function f.RemoveOption(_, opt)
                    opt = tostring(opt)
                    if not optSet[opt] then return end
                    optSet[opt] = nil
                    local b = btns[opt]
                    if b then b:Destroy() btns[opt] = nil end
                    selSet[opt] = nil
                    if selected == opt then selected = nil end
                    for i2, o in ipairs(order) do if o == opt then table.remove(order, i2) break end end
                    SBg.Visible = #order > 6
                    commit(true)
                end
                function f.SetOptions(_, opts)
                    for _, b in pairs(btns) do b:Destroy() end
                    btns, order, optSet = {}, {}, {}
                    local oldSel, oldSet = selected, selSet
                    selected, selSet = nil, {}
                    for _, o in ipairs(opts or {}) do f:AddOption(o) end
                    if oldSel and optSet[oldSel] then selected = oldSel end
                    for o in pairs(oldSet) do if optSet[o] then selSet[o] = true end end
                    commit(true)
                end
                f.Refresh = f.SetOptions
                function f.Set(_, v, silent)
                    if multi then
                        selSet = {}
                        for _, o in ipairs(type(v) == "table" and v or {v}) do if optSet[tostring(o)] then selSet[tostring(o)] = true end end
                    else
                        v = v ~= nil and tostring(v) or nil
                        selected = (v and optSet[v]) and v or nil
                    end
                    commit(silent)
                end
                function f.Get() return multi and getList() or selected end
                function f.Open() setOpen(true) end
                function f.Close() setOpen(false) end
                function f.Destroy() Module:Destroy() end

                for _, o in ipairs(options) do f:AddOption(o) end
                if default ~= nil then f:Set(default, true) end
                library.setters[flag] = function(v) f:Set(v, false) end
                return f
            end

            function section.Dropdown(sec, text, flag, options, callback, default)
                return makeDropdown(text, flag, options, callback, false, default)
            end
            function section.MultiDropdown(sec, text, flag, options, callback, defaults)
                return makeDropdown(text, flag, options, callback, true, defaults)
            end

            function section.ColorPicker(sec, text, flag, default, callback)
                flag = flag or ("color_" .. tostring(text))
                if typeof(default) ~= "Color3" then default = Color3.new(1, 1, 1) end
                local h, s, v = default:ToHSV()
                local HEADER, PANEL = 32, 122
                local open = false
                local Module, Back, Title = Base(text, HEADER, true, "ColorPickerModule")
                Module.ClipsDescendants = true
                Title.Size = UDim2.new(1, -70, 0, HEADER)
                local Preview = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(38, 22),
                    BorderSizePixel = 0, Parent = Back})
                Corner(7, Preview)
                local Panel = New("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(0, HEADER + 6), Size = UDim2.new(1, 0, 0, PANEL), Parent = Module})

                local update
                local bars = {}
                local function makeBar(y, letter, getPct, setPct)
                    local Row = New("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, y), Size = UDim2.new(1, -24, 0, 22), Parent = Panel})
                    local Lbl = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 22), Font = Enum.Font.GothamBold, Text = letter,
                        TextSize = 12, Parent = Row})
                    local BarF = New("Frame", {Position = UDim2.fromOffset(22, 6), Size = UDim2.new(1, -22, 0, 10), BorderSizePixel = 0,
                        BackgroundColor3 = Color3.new(1, 1, 1), Parent = Row})
                    Corner(5, BarF)
                    local Grad = New("UIGradient", {Parent = BarF})
                    local K = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0, ZIndex = 2, Parent = BarF})
                    Corner(7, K)
                    New("UIStroke", {Color = Color3.new(0, 0, 0), Transparency = 0.5, Thickness = 1.5, Parent = K})
                    local Hit = New("TextButton", {Text = "", BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -22, 1, 0),
                        ZIndex = 3, Parent = Row})
                    bind(function(t, a) P(Lbl, {TextColor3 = t.SubText}, a) end)
                    local function fromX(x)
                        setPct(math.clamp((x - BarF.AbsolutePosition.X) / math.max(BarF.AbsoluteSize.X, 1), 0, 1))
                        update(true)
                    end
                    Hit.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        local pg = tab.Page
                        pg.ScrollingEnabled = false
                        fromX(input.Position.X)
                        startDrag(function(inp) fromX(inp.Position.X) end, function() pg.ScrollingEnabled = true update() end)
                    end)
                    table.insert(bars, {Grad = Grad, K = K, get = getPct})
                    return Grad
                end
                local rainbow = {}
                for i = 0, 6 do table.insert(rainbow, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1))) end
                local HGrad = makeBar(4, "H", function() return h end, function(p) h = p end)
                HGrad.Color = ColorSequence.new(rainbow)
                local SGrad = makeBar(34, "S", function() return s end, function(p) s = p end)
                local VGrad = makeBar(64, "V", function() return v end, function(p) v = p end)

                local HexBg = New("Frame", {Position = UDim2.fromOffset(12, 94), Size = UDim2.new(1, -24, 0, 24), BorderSizePixel = 0, Parent = Panel})
                Corner(7, HexBg)
                local Hex = New("TextBox", {BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), Font = Enum.Font.Gotham,
                    Text = "", PlaceholderText = "#RRGGBB", TextSize = 13, ClearTextOnFocus = false, Parent = HexBg})
                bind(function(t, a) P(HexBg, {BackgroundColor3 = t.Inset, BackgroundTransparency = t.InsetA}, a) P(Hex, {TextColor3 = t.Text, PlaceholderColor3 = t.SubText}, a) end)

                local silent = true
                local pending = false
                update = function(skipHex)
                    local c = Color3.fromHSV(h, s, v)
                    Preview.BackgroundColor3 = c
                    if not skipHex and not Hex:IsFocused() then Hex.Text = "#" .. c:ToHex():upper() end
                    SGrad.Color = ColorSequence.new(Color3.fromHSV(h, 0, v), Color3.fromHSV(h, 1, v))
                    VGrad.Color = ColorSequence.new(Color3.fromHSV(h, s, 0), Color3.fromHSV(h, s, 1))
                    for _, b in ipairs(bars) do b.K.Position = UDim2.fromScale(b.get(), 0.5) end
                    library.flags[flag] = c
                    if not silent and not pending then
                        pending = true
                        task.delay(0.05, function()
                            pending = false
                            Safe(callback, Color3.fromHSV(h, s, v))
                        end)
                    end
                end
                update()
                silent = false

                Hex.FocusLost:Connect(function()
                    local ok, c = pcall(Color3.fromHex, Hex.Text)
                    if ok and c then h, s, v = c:ToHSV() end
                    update()
                end)

                local function resize()
                    Tween(Module, 0.3, {Size = UDim2.new(1, 0, 0, open and (HEADER + PANEL + 10) or HEADER)})
                end
                Back.MouseButton1Click:Connect(function() open = not open resize() end)

                local f = {Module = Module}
                function f.Set(_, c, sil)
                    if typeof(c) == "table" and c.__c then c = Color3.new(c.__c[1], c.__c[2], c.__c[3]) end
                    if typeof(c) ~= "Color3" then return end
                    h, s, v = c:ToHSV()
                    local old = silent
                    silent = sil and true or false
                    update()
                    silent = old
                end
                function f.Get() return Color3.fromHSV(h, s, v) end
                function f.Destroy() Module:Destroy() end
                library.setters[flag] = function(c) f:Set(c, false) end
                return f
            end

            section.button, section.label, section.toggle, section.slider, section.dropdown, section.keybind, section.textbox =
                section.Button, section.Label, section.Toggle, section.Slider, section.Dropdown, section.Keybind, section.Textbox
            return section
        end
        tab.Section = tab.section
        return tab
    end

    function W.Tab(self, tabName, icon)
        return createTab(tabName, icon, false)
    end

    local MINI = 80
    local Mini = New("TextButton", {Name = "Mini", AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = typeof(cfg.MiniPosition) == "UDim2" and cfg.MiniPosition or UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(MINI, MINI), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, Parent = gui})
    local MiniScale = New("UIScale", {Scale = 1, Parent = Mini})
    local Body = New("Frame", {Name = "Body", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundTransparency = 0.1, Parent = Mini})
    Corner(24, Body)
    local MiniStroke = New("UIStroke", {Thickness = 2, Transparency = 0, Color = Color3.new(1, 1, 1), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Body})
    local MiniGrad = New("UIGradient", {Parent = MiniStroke})
    local miniTween = DecorTween(MiniGrad, "rot", 6)
    local MiniContent = New("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = Body})
    New("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center, Parent = MiniContent})
    local Avatar = New("ImageLabel", {Size = UDim2.fromOffset(36, 36), BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = 1, Parent = MiniContent})
    Corner(18, Avatar)
    local Line1 = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2,
        Font = Enum.Font.GothamBold, Text = "-- FPS", TextSize = 13, Parent = MiniContent})
    local Line2 = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), LayoutOrder = 3,
        Font = Enum.Font.GothamMedium, Text = "--:--", TextSize = 10, Parent = MiniContent})
    bind(function(t, a)
        P(Body, {BackgroundColor3 = t.Main}, a)
        P(Avatar, {BackgroundColor3 = t.Accent}, a)
        P(Line1, {TextColor3 = t.Text}, a)
        P(Line2, {TextColor3 = t.SubText}, a)
        MiniGrad.Color = glowColor(t)
    end)

    task.spawn(function()
        if cfg.MiniIcon ~= nil then
            Avatar.Image = ToImage(cfg.MiniIcon)
            return
        end
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and img then Avatar.Image = img end
    end)

    W.MiniContent = cfg.MiniContent
    function W.SetMiniContent(self, fn) W.MiniContent = fn end

    Mini.MouseEnter:Connect(function() if W.State == "mini" then Tween(MiniScale, 0.25, {Scale = 1.06}, EBack) end end)
    Mini.MouseLeave:Connect(function() if W.State == "mini" then Tween(MiniScale, 0.25, {Scale = 1}, EBack) end end)

    W.MiniMoved = typeof(cfg.MiniPosition) == "UDim2"
    MakeDrag(Mini, Mini, {threshold = 6, onEnd = function(moved)
        if moved then
            W.MiniMoved = true
            ClampIntoView(Mini, 6, 0.3)
        else
            W:Restore()
        end
    end})

    local Blur
    local function syncBlur()
        if Blur then Blur.Enabled = W.Blur and W.State == "open" end
    end

    local animToken = 0
    local animUntil = 0
    local scaleTween
    W.Animating = false

    local function settle()
        if W.Destroyed then return end
        W.Animating = false
        animUntil = 0
        if scaleTween then scaleTween:Cancel() scaleTween = nil end
        if W.State == "open" then
            Mini.Visible = false
            miniTween:Pause()
            MainScale.Scale = 1
            Holder.Visible = true
            for _, tb in ipairs(W.Tabs) do
                for _, sec in ipairs(tb.sections) do
                    pcall(sec.refresh, true)
                end
            end
            if not W.Perf then
                glowTween:Play()
                titleTween:Play()
            end
            ClampIntoView(Holder, 8, 0.01)
        else
            Holder.Visible = false
            MainScale.Scale = 1
            Mini.Visible = true
            MiniScale.Scale = 0.7
            Tween(MiniScale, 0.3, {Scale = 1}, EBack)
            miniTween:Play()
        end
    end

    local function animateIn()
        Holder.Visible = true
    end

    function W.Minimize(self)
        if W.Destroyed or W.State ~= "open" then return end
        W.State = "mini"
        animToken += 1
        local tok = animToken
        syncBlur()
        if not W.MiniMoved then Mini.Position = Holder.Position end
        glowTween:Pause()
        titleTween:Pause()
        if scaleTween then scaleTween:Cancel() scaleTween = nil end
        if W.Perf or not Holder.Visible then
            settle()
            return
        end
        W.Animating = true
        animUntil = os.clock() + 0.45
        scaleTween = Tween(MainScale, 0.2, {Scale = 0.04}, Quint, In)
        task.delay(0.2, function()
            if tok == animToken then settle() end
        end)
    end

    function W.Restore(self)
        if W.Destroyed or W.State == "open" then return end
        W.State = "open"
        animToken += 1
        local tok = animToken
        syncBlur()
        Mini.Visible = false
        miniTween:Pause()
        if scaleTween then scaleTween:Cancel() scaleTween = nil end
        if W.Perf then
            settle()
            return
        end
        if not Holder.Visible then
            MainScale.Scale = 0.55
            Holder.Visible = true
        end
        W.Animating = true
        animUntil = os.clock() + 0.5
        scaleTween = Tween(MainScale, 0.26, {Scale = 1}, Quint, Out)
        task.delay(0.26, function()
            if tok == animToken then settle() end
        end)
    end

    function W.Toggle(self)
        if W.State == "open" then W:Minimize() else W:Restore() end
    end

    function W.Destroy(self, instant)
        if W.Destroyed then return end
        W.Destroyed = true
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        animToken += 1
        if scaleTween then scaleTween:Cancel() scaleTween = nil end
        if Holder.Visible and not instant then
            Tween(MainScale, 0.2, {Scale = 0.04}, Quint, In)
        end
        Mini.Visible = false
        if Blur then Blur:Destroy() Blur = nil end
        for i, w in ipairs(library.Windows) do if w == W then table.remove(library.Windows, i) break end end
        if instant then
            gui:Destroy()
        else
            task.delay(0.35, function() gui:Destroy() end)
        end
    end

    BtnMin.MouseButton1Click:Connect(function() W:Minimize() end)
    BtnClose.MouseButton1Click:Connect(function() W:Destroy() end)

    Track(UIS.InputBegan:Connect(function(inp, gpe)
        if W.Destroyed or W.Listening or UIS:GetFocusedTextBox() then return end
        if W.ToggleKey and inp.KeyCode == W.ToggleKey then W:Toggle() end
    end))
    function W.SetToggleKey(self, key)
        if type(key) == "string" then key = Enum.KeyCode[key] end
        W.ToggleKey = key
    end
    function W.SetTitle(self, t) W.Title = tostring(t) TitleLbl.Text = W.Title end

    function W.SetTheme(self, themeKey)
        for k in pairs(Themes) do
            if tostring(themeKey):lower() == k:lower() then themeKey = k break end
        end
        local t = Themes[themeKey]
        if not t then return end
        W.theme, W.themeName = t, themeKey
        library.flags.__theme = themeKey
        for i = #binds, 1, -1 do
            if not pcall(binds[i], t, true) then table.remove(binds, i) end
        end
    end

    function W.SetSliderColor(self, c)
        if typeof(c) ~= "Color3" then c = nil end
        W.SliderColor = c
        for i = #W.SliderPaints, 1, -1 do
            if not pcall(W.SliderPaints[i], false) then table.remove(W.SliderPaints, i) end
        end
    end

    function W.SetPerf(self, on)
        W.Perf = on and true or false
        library.Perf = W.Perf
        if W.Perf then
            glowTween:Pause()
            titleTween:Pause()
        elseif W.State == "open" then
            glowTween:Play()
            titleTween:Play()
        end
    end

    function W.SetGlow(self, on, rainbow)
        if on ~= nil then W.Glow = on and true or false end
        if rainbow ~= nil then W.Rainbow = rainbow and true or false end
        applyGlow()
        MiniGrad.Enabled = W.Glow
        MiniStroke.Color = W.Glow and Color3.new(1, 1, 1) or W.theme.Stroke
        MiniStroke.Transparency = W.Glow and 0 or 0.7
        MiniGrad.Color = glowColor(W.theme)
    end
    local function applyBg(animated)
        local on = W.HasBg
        P(BgImage, {ImageTransparency = on and W.BgTransparency or 1}, animated, 0.25)
        P(Overlay, {BackgroundTransparency = on and (1 - W.OverlayOpacity) or 1}, animated, 0.25)
    end

    function W.SetBackground(self, src, transparency)
        if transparency ~= nil then W.BgTransparency = math.clamp(transparency, 0, 1) end
        W.BgSource = src
        library.flags.__bg = src
        W.FrameToken = (W.FrameToken or 0) + 1
        W.FrameMode = false
        local tok = W.FrameToken
        task.spawn(function()
            local function fail(msg)
                W.HasBg = false
                if not src or src == "" then BgImage.Image = "" end
                applyBg(true)
                if src and src ~= "" then W:Notify{Title = "背景", Content = msg, Type = "Warning", Duration = 7} end
            end
            local isDir = false
            if type(src) == "string" and src ~= "" and isfolder then pcall(function() isDir = isfolder(src) end) end
            if isDir then
                local files = {}
                pcall(function()
                    for _, f in ipairs(listfiles(src)) do
                        local e = GetExt(tostring(f))
                        if e == "png" or e == "jpg" or e == "jpeg" or e == "webp" then table.insert(files, tostring(f)) end
                    end
                end)
                table.sort(files)
                for k = #files, 61, -1 do files[k] = nil end
                if #files == 0 or not getcustomasset then
                    fail("文件夹里没有 png/jpg 帧图，或执行器不支持 getcustomasset")
                    return
                end
                W.FrameMode = true
                W.HasBg = true
                applyBg(true)
                local cache = {}
                while W.FrameToken == tok and not W.Destroyed do
                    for i = 1, #files do
                        if W.FrameToken ~= tok or W.Destroyed then break end
                        local f = files[i]
                        if cache[f] == nil then
                            local ok, a = pcall(getcustomasset, f)
                            cache[f] = ok and a or false
                        end
                        if cache[f] then BgImage.Image = cache[f] end
                        task.wait(1 / math.clamp(W.BgFps or 12, 1, 60))
                    end
                end
                return
            end

            local img, err = ResolveImage(src)
            if W.FrameToken ~= tok then return end
            if not img then
                fail(err or "加载失败")
                return
            end
            BgImage.Image = img
            W.HasBg = true
            applyBg(true)
        end)
    end
    function W.SetBackgroundTransparency(self, v) W.BgTransparency = math.clamp(v, 0, 1) applyBg(true) end
    function W.SetOverlay(self, v) W.OverlayOpacity = math.clamp(v, 0, 1) applyBg(true) end

    local NotifyHolder = New("Frame", {Name = "Notifications", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(288, 600), Parent = gui})
    New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifyHolder})
    local notifyCount = 0

    function W.Notify(self, o)
        if type(o) ~= "table" then o = {Content = tostring(o)} end
        local kinds = {Info = th().Accent, Success = rgb(70, 200, 120), Warning = rgb(255, 190, 60), Error = rgb(240, 85, 85)}
        local color = kinds[o.Type or "Info"] or th().Accent
        local dur = tonumber(o.Duration) or 4
        notifyCount += 1

        local Wrap = New("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = notifyCount, Parent = NotifyHolder})
        local Card = New("Frame", {Position = UDim2.new(1, 40, 0, 0), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = th().Main, BorderSizePixel = 0, ClipsDescendants = true, Parent = Wrap})
        Corner(14, Card)
        local Inner = New("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Card})
        Pad(12, 14, Inner)
        New("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Inner})
        New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.GothamBold,
            Text = tostring(o.Title or W.Title), TextSize = 14, TextColor3 = color, TextWrapped = true, TextXAlignment = Left, LayoutOrder = 1, Parent = Inner})
        if o.Content and o.Content ~= "" then
            New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham,
                Text = tostring(o.Content), TextSize = 13, TextColor3 = th().SubText, TextWrapped = true, TextXAlignment = Left, LayoutOrder = 2, Parent = Inner})
        end
        local Prog = New("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 3),
            BackgroundColor3 = color, BorderSizePixel = 0, BackgroundTransparency = 0.2, Parent = Card})

        Tween(Card, 0.5, {Position = UDim2.new(0, 0, 0, 0)}, EBack)
        Tween(Prog, dur, {Size = UDim2.new(0, 0, 0, 3)}, Linear)
        task.delay(dur, function()
            if not Card.Parent then return end
            Tween(Card, 0.4, {Position = UDim2.new(1, 40, 0, 0)}, Quint, In)
            task.delay(0.42, function() Wrap:Destroy() end)
        end)

        local kids = {}
        for _, c in ipairs(NotifyHolder:GetChildren()) do if c:IsA("Frame") then table.insert(kids, c) end end
        table.sort(kids, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        if #kids > 5 then kids[1]:Destroy() end
    end

    function W.SetBlur(self, on)
        W.Blur = on and true or false
        if W.Blur and not Blur then
            pcall(function()
                Blur = Instance.new("BlurEffect")
                Blur.Name = "HPUI_Blur"
                Blur.Size = 14
                Blur.Parent = services.Lighting
            end)
        end
        syncBlur()
    end

    function W.Dialog(self, o)
        o = type(o) == "table" and o or {Content = tostring(o)}
        local Dim = New("TextButton", {Name = "Dialog", AutoButtonColor = false, Text = "", BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = Holder})
        Corner(18, Dim)
        local Card = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 300, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = th().Main:Lerp(Color3.new(1, 1, 1), 0.08), BorderSizePixel = 0, Parent = Dim})
        Corner(16, Card)
        Pad(16, 18, Card)
        local CardScale = New("UIScale", {Scale = 0.9, Parent = Card})
        New("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Card})
        New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.GothamBold,
            Text = tostring(o.Title or W.Title), TextSize = 16, TextColor3 = th().Text, TextWrapped = true, TextXAlignment = Left, LayoutOrder = 1, Parent = Card})
        if o.Content and o.Content ~= "" then
            New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham,
                Text = tostring(o.Content), TextSize = 13, TextColor3 = th().SubText, TextWrapped = true, TextXAlignment = Left, LayoutOrder = 2, Parent = Card})
        end
        local Row = New("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 3, Parent = Card})
        New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = Row})
        local function close()
            Tween(Dim, 0.2, {BackgroundTransparency = 1})
            Tween(CardScale, 0.2, {Scale = 0.9}, Quint, In)
            task.delay(0.22, function() Dim:Destroy() end)
        end
        for i, b in ipairs(o.Buttons or {{Title = Tr("loc:ui_confirm"), Primary = true}}) do
            local Btn = New("TextButton", {AutoButtonColor = false, Text = tostring(b.Title or "OK"), Font = Enum.Font.GothamBold, TextSize = 13,
                Size = UDim2.fromOffset(88, 34), BorderSizePixel = 0, LayoutOrder = i, Parent = Row})
            Corner(10, Btn)
            if b.Primary then
                Btn.BackgroundColor3 = th().Accent
                Btn.TextColor3 = Color3.new(1, 1, 1)
            else
                Btn.BackgroundColor3 = Color3.new(1, 1, 1)
                Btn.BackgroundTransparency = th().ElemA
                Btn.TextColor3 = th().Text
            end
            AddRipple(Btn, 10)
            Btn.MouseButton1Click:Connect(function()
                close()
                Safe(b.Callback)
            end)
        end
        Tween(Dim, 0.25, {BackgroundTransparency = 0.45})
        Tween(CardScale, 0.35, {Scale = 1}, EBack)
    end

    local TagHolder = New("Frame", {Name = "Tags", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -84, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X, Parent = Top})
    New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = TagHolder})
    local tagCount = 0
    function W.Tag(self, o)
        o = type(o) == "table" and o or {Title = tostring(o)}
        tagCount += 1
        local color = typeof(o.Color) == "Color3" and o.Color or th().Accent
        local Pill = New("Frame", {Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = color,
            BackgroundTransparency = 0.75, BorderSizePixel = 0, LayoutOrder = tagCount, Parent = TagHolder})
        Corner(tonumber(o.Radius) or 11, Pill)
        Pad(0, 10, Pill)
        local Lbl = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold, Text = "", TextSize = 12, Parent = Pill})
        LocSet(Lbl, "Text", tostring(o.Title or ""))
        bind(function(t, a) P(Lbl, {TextColor3 = t.Text}, a) end)
        local f = {}
        function f.SetTitle(_, t) LocSet(Lbl, "Text", tostring(t)) end
        function f.Destroy() Pill:Destroy() end
        return f
    end
    for _, tg in ipairs(cfg.Tags or {}) do W:Tag(tg) end

    local function cfgPath(n) return "HPUI/configs/" .. tostring(n) .. ".json" end
    local function ensureFolders()
        pcall(function()
            if makefolder then
                if not isfolder("HPUI") then makefolder("HPUI") end
                if not isfolder("HPUI/configs") then makefolder("HPUI/configs") end
            end
        end)
    end
    function W.SaveConfig(self, n)
        if not writefile then return false end
        ensureFolders()
        local data = {}
        for k, v in pairs(library.flags) do
            if typeof(v) == "Color3" then data[k] = {__c = {v.R, v.G, v.B}}
            elseif type(v) == "table" or type(v) == "string" or type(v) == "number" or type(v) == "boolean" then data[k] = v end
        end
        data.__bgT = W.BgTransparency
        data.__ovl = W.OverlayOpacity
        local ok = pcall(function() writefile(cfgPath(n), HttpService:JSONEncode(data)) end)
        return ok
    end
    function W.LoadConfig(self, n)
        if not (readfile and isfile) then return false end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(cfgPath(n))) end)
        if not ok or type(data) ~= "table" then return false end
        if data.__bgT then W.BgTransparency = data.__bgT end
        if data.__ovl then W.OverlayOpacity = data.__ovl end
        if data.__theme then W:SetTheme(data.__theme) end
        if data.__lang then W:SetLanguage(data.__lang) end
        if data.__bg then W:SetBackground(data.__bg) end
        for k, v in pairs(data) do
            if library.setters[k] then
                if type(v) == "table" and v.__c then v = Color3.new(v.__c[1], v.__c[2], v.__c[3]) end
                pcall(library.setters[k], v)
            end
        end
        return true
    end
    function W.ListConfigs(self)
        local out = {}
        pcall(function()
            if listfiles and isfolder("HPUI/configs") then
                for _, f in ipairs(listfiles("HPUI/configs")) do
                    local n = tostring(f):match("([^/\\]+)%.json$")
                    if n then table.insert(out, n) end
                end
            end
        end)
        return out
    end

    local frames, lastT, fps = 0, os.clock(), 60
    local function getPing()
        local ok, p = pcall(function() return math.floor(services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        return ok and p or 0
    end
    W.GetFPS = function() return fps end
    W.GetPing = getPing
    Track(RunService.Heartbeat:Connect(function(dt)
        frames += 1
        decorAcc += dt
        if W.Animating and os.clock() > animUntil then settle() end
        if decorAcc >= 0.05 then
            local step = decorAcc
            decorAcc = 0
            for _, d in ipairs(decor) do
                if d.active then
                    d.t += step
                    if d.kind == "rot" then
                        d.grad.Rotation = (d.t / d.period * 360) % 360
                    else
                        local ph = (d.t / d.period) % 2
                        d.grad.Offset = Vector2.new(-1 + 2 * (ph < 1 and ph or 2 - ph), 0)
                    end
                end
            end
        end
        local now = os.clock()
        if now - lastT >= 0.5 then
            fps = math.floor(frames / (now - lastT) + 0.5)
            frames, lastT = 0, now
            if active and now - active.t > 6 then releaseDrag() end
            if W.State == "open" and not W.Perf then
                if fps < 24 then W.SlowTicks += 1 else W.SlowTicks = 0 end
                if W.SlowTicks >= 12 then
                    W.SlowTicks = 0
                    W:SetPerf(true)
                    W:Notify{Title = "HPUI", Content = Tr("loc:ui_autoperf"), Type = "Info", Duration = 5}
                end
            else
                W.SlowTicks = 0
            end
            if W.HasBg and W.FrameMode and W.State == "open" then
                if fps < 12 then W.LowFps += 1 else W.LowFps = 0 end
                if W.LowFps >= 8 then
                    W.LowFps = 0
                    W:SetBackground(nil)
                    W:Notify{Title = "HPUI", Content = Tr("loc:ui_lowfps"), Type = "Warning", Duration = 6}
                end
            else
                W.LowFps = 0
            end
            if W.State == "mini" then
                local l1, l2
                if W.MiniContent then
                    local ok, a, b = pcall(W.MiniContent)
                    if ok then l1, l2 = a, b end
                end
                Line1.Text = tostring(l1 or (fps .. " FPS"))
                Line2.Text = tostring(l2 or os.date("%H:%M"))
            end
            for _, fn in ipairs(W.Ticks) do pcall(fn, fps) end
        end
    end))

    if cfg.Settings ~= false then
        local st = createTab("loc:ui_settings", "⚙", true)
        st.Build = function()
            local ui = st:section("loc:ui_ui", true)
            ui:Dropdown("loc:ui_theme", "__ui_theme", ThemeOrder, function(v) W:SetTheme(v) end, themeName)
            ui:Dropdown("loc:ui_lang", "__ui_lang", {"中文", "English"}, function(v) W:SetLanguage(v == "English" and "en" or "zh") end, W.Language == "en" and "English" or "中文")
            ui:Keybind("loc:ui_key", W.ToggleKey, function() end, "__ui_key", function(k) if k then W:SetToggleKey(k) end end)
            ui:Toggle("loc:ui_glow", "__ui_glow", W.Glow, function(v) W:SetGlow(v) end)
            ui:Toggle("loc:ui_rainbow", "__ui_rainbow", W.Rainbow, function(v) W:SetGlow(nil, v) end)
            ui:Toggle("loc:ui_blur", "__ui_blur", W.Blur == true, function(v) W:SetBlur(v) end)
            ui:Toggle("loc:ui_perf", "__ui_perf", W.Perf == true, function(v) W:SetPerf(v) end, "loc:ui_perf_d")
            ui:Button("loc:ui_mini", function() W:Minimize() end)

            local sl = st:section("loc:ui_slider", false)
            sl:ColorPicker("loc:ui_slidercolor", "__ui_slidercolor", W.theme.Accent, function(c) W:SetSliderColor(c) end)
            sl:Button("loc:ui_reset", function() W:SetSliderColor(nil) end)

            local bg = st:section("loc:ui_bg", true)
            bg:Label("loc:ui_bghelp")
            bg:Slider("loc:ui_fps", "__ui_fps", 12, 1, 30, false, function(v) W.BgFps = v end)
            bg:Textbox("loc:ui_bgsrc", "__ui_bg", "", function(v) W:SetBackground(v) end)
            bg:Slider("loc:ui_bgt", "__ui_bgt", math.floor(W.BgTransparency * 100), 0, 95, false, function(v) W:SetBackgroundTransparency(v / 100) end)
            bg:Slider("loc:ui_ovl", "__ui_ovl", math.floor(W.OverlayOpacity * 100), 0, 100, false, function(v) W:SetOverlay(v / 100) end)
            bg:Button("loc:ui_clear", function() W:SetBackground(nil) end)

            local cf = st:section("loc:ui_cfg", false)
            local cname = "default"
            cf:Textbox("loc:ui_cfgname", "__ui_cfgname", "default", function(v) cname = v end)
            local cfgDrop = cf:Dropdown("loc:ui_cfglist", "__ui_cfglist", W:ListConfigs(), function(v) cname = v end)
            cf:Button("loc:ui_save", function()
                if W:SaveConfig(cname) then W:Notify{Title = Tr("loc:ui_cfg"), Content = cname, Type = "Success"} cfgDrop:SetOptions(W:ListConfigs())
                else W:Notify{Title = Tr("loc:ui_cfg"), Content = "writefile ✗", Type = "Error"} end
            end)
            cf:Button("loc:ui_load", function()
                if W:LoadConfig(cname) then W:Notify{Title = Tr("loc:ui_cfg"), Content = cname, Type = "Success"}
                else W:Notify{Title = Tr("loc:ui_cfg"), Content = cname .. " ✗", Type = "Error"} end
            end)

            local info = st:section("loc:ui_info", false)
            local infoLbl = info:Label("HPUI v" .. library.Version)
            table.insert(W.Ticks, function(f) infoLbl.Text = ("HPUI v%s   |   FPS %d   |   Ping %dms"):format(library.Version, f, getPing()) end)
            info:Button("loc:ui_destroy", function()
                W:Dialog{Title = Tr("loc:ui_destroy"), Content = Tr("loc:ui_destroy_q"), Buttons = {
                    {Title = Tr("loc:ui_cancel")},
                    {Title = Tr("loc:ui_confirm"), Primary = true, Callback = function() W:Destroy() end},
                }}
            end)
        end
    end

    local env = (getgenv and getgenv()) or _G
    env.UiDestroy = function() W:Destroy() end
    env.ToggleUILib = function() gui.Enabled = not gui.Enabled end
    env.toggleui = function() W:Toggle() end

    if cfg.Background then W:SetBackground(cfg.Background) end
    applyBg(false)
    if W.Perf then W:SetPerf(true) end
    animateIn()
    return W
end

local UI = setmetatable({HPUI = library, HP = library, Library = library, Version = library.Version}, {__index = library})
pcall(function() ((getgenv and getgenv()) or _G).HPUI = UI end)
return UI
