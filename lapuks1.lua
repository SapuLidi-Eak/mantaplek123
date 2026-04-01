-- =============================================
-- AUTO JOB BARISTA LOADER
-- Paste SELURUH file ini di dds.lua
-- Letakkan SEBELUM bagian "UI WEBHOOK SECTION"
-- =============================================

-- ① Load module dari GitHub
local BaristaModule = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SapuLidi-Eak/mantaplek123/refs/heads/main/lapuks.lua"
))()

-- ② Sambungkan sendWebhookRepairEvent dari dds.lua ke module
--    (fungsi ini sudah ada di dds.lua, tinggal di-pass)
BaristaModule.onRepairEvent = sendWebhookRepairEvent

-- ③ Sync totalCycle dari module ke variable totalCycle dds.lua
--    Setiap cycle selesai di module, totalCycle dds.lua ikut update
--    supaya webhook profit ikut hitung cycle yang bener
task.spawn(function()
    while true do
        task.wait(1)
        totalCycle = BaristaModule.totalCycle
    end
end)

-- =============================================
-- CONFIG SAVE/LOAD (barista section)
-- =============================================
local baristaConfigPath = "DDS_BaristaConfig.json"

local function loadBaristaConfig()
    local ok, data = pcall(readfile, baristaConfigPath)
    if ok and data then
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if ok2 and decoded then return decoded end
    end
    return {}
end

local function saveBaristaConfig(data)
    pcall(writefile, baristaConfigPath, HttpService:JSONEncode(data))
end

local bCfg       = loadBaristaConfig()
local isBLoading = true

-- Apply saved config ke module
if bCfg.TimeoutMax       then BaristaModule.timeoutMax       = bCfg.TimeoutMax       end
if bCfg.TimeoutEnabled  ~= nil then BaristaModule.timeoutEnabled  = bCfg.TimeoutEnabled  end
if bCfg.KickLimitMinutes then BaristaModule.kickLimitMinutes = bCfg.KickLimitMinutes end
if bCfg.KickLimitEnabled ~= nil then BaristaModule.kickLimitEnabled = bCfg.KickLimitEnabled end

-- =============================================
-- UI — JOB SECTION
-- Letakkan setelah JobTab dibuat di dds.lua
-- =============================================
local JobSection = JobTab:Section({
    Title          = "Auto Job Barista",
    Box            = true,
    TextXAlignment = "Center",
    TextSize       = 15,
    Opened         = false,
})

-- Toggle Auto Barista
local baristaToggle = JobSection:Toggle({
    Title = "Auto Barista",
    Value = false,
    Callback = function(on)
        if not isBLoading then
            bCfg.AutoBarista = on
            saveBaristaConfig(bCfg)
        end
        if on then
            BaristaModule:Start()
        else
            BaristaModule:Stop()
        end
    end
})

JobSection:Space()

-- ---- AUTO RESTART TIMEOUT ----
JobSection:Paragraph({ Title = "Auto Restart Jika Timeout" })

JobSection:Input({
    Type        = "Input",
    Title       = "Timeout (detik)",
    Value       = tostring(BaristaModule.timeoutMax),
    Placeholder = "Contoh: 90",
    Callback    = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BaristaModule.timeoutMax = num
            if not isBLoading then
                bCfg.TimeoutMax = num
                saveBaristaConfig(bCfg)
            end
        end
    end
})

local restartToggle = JobSection:Toggle({
    Title = "Auto Restart",
    Value = false,
    Callback = function(on)
        BaristaModule.timeoutEnabled = on
        if not isBLoading then
            bCfg.TimeoutEnabled = on
            saveBaristaConfig(bCfg)
        end
        if on then BaristaModule.lastServeTime = tick() end
    end
})

JobSection:Space()

-- ---- KICK LIMIT ----
JobSection:Paragraph({ Title = "Limit Auto Job (Auto Kick)" })

JobSection:Input({
    Type        = "Input",
    Title       = "Limit Menit",
    Value       = tostring(BaristaModule.kickLimitMinutes),
    Placeholder = "Contoh: 120",
    Callback    = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BaristaModule.kickLimitMinutes = num
            if not isBLoading then
                bCfg.KickLimitMinutes = num
                saveBaristaConfig(bCfg)
            end
        end
    end
})

local kickToggle = JobSection:Toggle({
    Title = "Toggle Auto Kick",
    Value = false,
    Callback = function(on)
        BaristaModule.kickLimitEnabled = on
        if not isBLoading then
            bCfg.KickLimitEnabled = on
            saveBaristaConfig(bCfg)
        end
    end
})

-- =============================================
-- LOAD SAVED CONFIG KE UI
-- =============================================
task.spawn(function()
    task.wait(0.5)
    if bCfg.TimeoutEnabled   then restartToggle:Set(true)  end
    if bCfg.KickLimitEnabled then kickToggle:Set(true)     end
    if bCfg.AutoBarista      then baristaToggle:Set(true)  end
    isBLoading = false
end)
