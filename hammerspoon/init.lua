
local MONITOR_MAP = {} -- 모니터 인덱스 매핑 정보
local assignHotkeys = {} -- 인덱스 부여 모드 시작시 단축키 저장
local wsHotkeys = {} -- 워크스페이스 이동 단축키 저장
local lastActiveWs = {} -- 모니터 별 마지막 활성 워크스페이스 추적
local isAssigning = false -- 인덱스 부여 모드 체크
local mouseMoveEnabled = true -- 마우스 포커스 모니터 이동 활성화 여부


-- 모니터별 워크스페이스 할당
local wsMap = {
    [1] = {"1"},
    [2] = {"2"},
    [3] = {"3"},
    [4] = {"4"},
    [5] = {"5"},
    [6] = {"6"},
    [7] = {"7"},
    [8] = {"8"},
    [9] = {"9"},
}

local registerWsHotkeys
local moveWorkspaceToMonitor


local function aerospace(cmd)
    return hs.execute("/opt/homebrew/bin/aerospace " .. cmd)
end

-- aerospace 모니터 이름 → aerospace 모니터 ID 매핑
local function getAerospaceMonitorId(monitorName)
    local output = aerospace("list-monitors")
    for line in output:gmatch("[^\r\n]+") do
        local id, name = line:match("^(%d+)%s*|%s*(.+)$")
        if id and name and name:match("^%s*(.-)%s*$") == monitorName then
            return tonumber(id)
        end
    end
    return nil
end

local function saveMap()
    local path = os.getenv("HOME") .. "/.hammerspoon/monitor_map.json"
    local f = io.open(path, "w")
    if f then f:write(hs.json.encode(MONITOR_MAP)); f:close() end
end

local function clearWsHotkeys()
    for _, hk in ipairs(wsHotkeys) do hk:delete() end
    wsHotkeys = {}
end

-- 워크스페이스가 속한 모니터 인덱스 반환
local function getMonitorIdxForWs(ws)
    for monitorIdx, workspaces in pairs(wsMap) do
        for _, w in ipairs(workspaces) do
            if w == ws then return monitorIdx end
        end
    end
    return nil
end

local function moveMouseToScreen(screen)
    if not mouseMoveEnabled then return end
    local center = screen:frame()
    local x = center.x + center.w / 2
    local y = center.y + center.h / 2
    hs.mouse.absolutePosition(hs.geometry.point(x, y))
end

-- aerospace 워크스페이스 이동 + 올바른 모니터로 배치
local function gotoWorkspace(ws)
    aerospace("workspace " .. ws)

    local monitorIdx = getMonitorIdxForWs(ws)
    if monitorIdx then
        -- Hammerspoon 인덱스 → 모니터 이름 → AeroSpace 모니터 ID 변환
        local targetName = nil
        for name, idx in pairs(MONITOR_MAP) do
            if idx == monitorIdx then targetName = name; break end
        end

        if targetName then
            local aeroId = getAerospaceMonitorId(targetName)
            if aeroId then
                aerospace("move-workspace-to-monitor --workspace " .. ws .. " " .. aeroId)
            end
        end

        lastActiveWs[monitorIdx] = ws

        -- 해당 모니터로 마우스 이동
        if targetName then
            for _, screen in ipairs(hs.screen.allScreens()) do
                if screen:name() == targetName then
                    moveMouseToScreen(screen)
                    return
                end
            end
        end

    end
end


registerWsHotkeys = function()
    clearWsHotkeys()

    for monitorIdx, workspaces in pairs(wsMap) do
        -- 해당 인덱스의 모니터가 실제 연결되어 있는지 확인
        local connected = false

        for name, idx in pairs(MONITOR_MAP) do
            if idx == monitorIdx then
                for _, screen in ipairs(hs.screen.allScreens()) do
                    if screen:name() == name then
                        connected = true
                        break
                    end
                end
            end
        end

        for _, ws in ipairs(workspaces) do
            local hk = hs.hotkey.bind({"alt", "ctrl"}, ws, function()
                if connected then
                    gotoWorkspace(ws)
                else
                    moveWorkspaceToMonitor(ws)
                end
            end)
            table.insert(wsHotkeys, hk)

            -- 윈도우 이동: alt+shift+숫자
            local moveHk = hs.hotkey.bind({"alt", "ctrl", "shift"}, ws, function()
                if isAssigning then return end -- 부여 모드중엔 무시
                aerospace("move-node-to-workspace " .. ws)
            end)
            table.insert(wsHotkeys, moveHk)

            local moveWs = hs.hotkey.bind({"alt", "ctrl", "cmd"}, ws, function()
                moveWorkspaceToMonitor(ws)
            end)
        end
    end
end

local function clearAssignHotkeys()
    for _, hk in ipairs(assignHotkeys) do hk:delete() end
    assignHotkeys = {}
    isAssigning = false
end



local function focusMonitorByIndex(idx)
    local targetName = nil
    for name, i in pairs(MONITOR_MAP) do
        if i == idx then targetName = name; break end
    end

    if not targetName then
        hs.alert("인덱스 " .. idx .. " 모니터 없음", 1)
        return
    end

    -- 해당 모니터의 첫 번째 워크스페이로 이동
    local ws = lastActiveWs[idx] or (wsMap[idx] and wsMap[idx][1])

    if ws then
        gotoWorkspace(ws)
    else
        local monitorName = nil
        for name, monitorIdx in pairs(MONITOR_MAP) do
            if monitorIdx == idx then
                monitorName = name
                break
            end
        end

        for _, screen in ipairs(hs.screen.allScreens()) do
            if screen:name() == monitorName then
                screen:focus()
                break
            end
        end
    end
end

local function onAssignComplete()
    clearAssignHotkeys()
    registerWsHotkeys()
end

-- 현재 포커스된 모니터 반환
local function getFocusedScreen()
    local win = hs.window.focusedWindow()
    if win then return win:screen() end
    return hs.screen.mainScreen()
end

-- 포커스 모니터에 인덱스 부여 모드 시작
local function startAssign()
    if isAssigning then
        hs.alert(" 이미 부여 중입니다\nalt+shift+esc 로 취소", 2)
        return
    end

    local screen = getFocusedScreen()
    local currentIdx = MONITOR_MAP[screen:name()]

    -- 사용 중인 인덱스 표시
    local usedIndices = {}
    for _, idx in pairs(MONITOR_MAP) do usedIndices[idx] = true end

    local available = {}
    for i = 1, 9 do
        if not usedIndices[i] or i == currentIdx then
            table.insert(available, tostring(i))
        end
    end

    local currentInfo = currentIdx and ("현재 인덱스: " .. currentIdx .. "\n") or "현재 인덱스: 없음\n"

    hs.alert(
        "󰍹 " .. screen:name() .. "\n"
        .. currentInfo
        .. "alt+shift+숫자로 인덱스 부여\n"
        .. "사용 가능: " .. table.concat(available, ", "),
        6
    )

    isAssigning = true
    clearAssignHotkeys() -- 혹시 남은 핫키 정리

    for i = 1, 9 do
        local hk = hs.hotkey.bind({"alt", "shift", "ctrl"}, tostring(i), function()
            -- 같은 인덱스를 가진 기존 모니터가 있으면 제거
            for name, idx in pairs(MONITOR_MAP) do
                if idx == i and name ~= screen:name() then
                    MONITOR_MAP[name] = nil
                    hs.alert(" " .. name .. " 의 인덱스 " .. i .. " 해제됨", 2)
                end
            end

            MONITOR_MAP[screen:name()] = i
            saveMap()
            hs.alert(" " .. screen:name() .. " 인덱스 " .. i, 2)
            onAssignComplete()
        end)
        table.insert(assignHotkeys, hk)
    end

    -- 취소
    local cancelHk = hs.hotkey.bind({"alt", "shift"}, "escape", function()
        hs.alert("취소", 1)
        clearAssignHotkeys()
    end)
    table.insert(assignHotkeys, cancelHk)
end


local function loadMap()
    local path = os.getenv("HOME") .. "/.hammerspoon/monitor_map.json"
    local f = io.open(path, "r")
    if f then
        local content = f:read("*a"); f:close()
        local ok, data = pcall(hs.json.decode, content)
        if ok and data then MONITOR_MAP = data end
    end

    onAssignComplete()
end


moveWorkspaceToMonitor = function(ws)
    local currentMonitor = getFocusedScreen()

    local monitorIdx = nil
    for name, idx in pairs(MONITOR_MAP) do
        if name == currentMonitor:name() then
            monitorIdx = idx
            break
        end
    end

    -- 기존에 해당 워크스페이스가 존재하면 제거
    for monitor, workspaces in pairs(wsMap) do
        for idx, workspace in pairs(workspaces) do
            if ws == workspace then
                table.remove(wsMap[monitor], idx)
                lastActiveWs[monitor] = {}
                break
            end
        end
    end

    -- 워크스페이스 새로 설정
    if not wsMap[monitorIdx] then
        wsMap[monitorIdx] = {}
    end
    table.insert(wsMap[monitorIdx], ws)

    gotoWorkspace(ws)

end

--------------------------메뉴바 오버레이 영역----------------------
local stackMenubar = hs.menubar.new()
local overlayVisible = false

local function getWsWindows(ws)
    local output = aerospace("list-windows --workspace " .. ws)
    local windows = {}

    for line in output:gmatch("[^\n]+") do
        local id, app, title = line:match("(%d+)%s*|%s*(.-)%s*|%s*(.+)")
        if id then
            table.insert(windows, { id = id, app = app, title = title })
        end
    end

    return windows
end

-- 현재 포커스된 윈도우 ID
local function getFocusedId()
    local win = hs.window.focusedWindow()
    return win and tostring(win:id()) or ""
end

local function updateMenubar()
    local currentWs = aerospace("list-workspaces --focused"):gsub("%s+", "")
    if currentWs == "" then return end

    local windows = getWsWindows(currentWs)
    local focusedId = getFocusedId()
    local items = {}
    local focusedApp = "WS" .. currentWs

    for _, win in ipairs(windows) do
        local isFocused = (win.id == focusedId)
        if isFocused then
            focusedApp = win.app
        end

        table.insert(items, {
            title = (isFocused and "● " or "○ ")
            .. win.app .. "  —  " .. win.title,
            fn = function()
                for _, w in ipairs(hs.window.allWindows()) do
                    if tostring(w:id()) == win.id then
                        w:focus(); break
                    end
                end
            end
        })
    end

    -- 구분선 + 현재 워크스페이스 정보
    table.insert(items, { title = "-" })
    table.insert(items, {
        title = "WS" .. currentWs
        .. "  (" .. #windows .. "개)",
        disabled = true
    })

    stackMenubar:setTitle("▶ " .. focusedApp)
    stackMenubar:setMenu(items)
end

-- alt+tab 오버레이

local overlayCanvas = nil
local overlayWindows = {}
local overlaySelected = 1

local function destroyOverlay()
    if overlayCanvas then
        overlayCanvas:delete()
        overlayCanvas = nil
    end

    overlayVisible = false
    overlayWindows = {}
    overlaySelected = 1
end

local function drawOverlay()
    if overlayCanvas then
        overlayCanvas:delete()
        overlayCanvas = nil
    end

    local screen = hs.window.focusedWindow() and hs.window.focusedWindow():screen() or hs.screen.mainScreen()

    local sf = screen:frame()

    local itemH = 36
    local padding = 16
    local width = 420
    local height = padding * 2 + #overlayWindows * itemH

    local x = sf.x + (sf.w - width) / 2
    local y = sf.y + (sf.h - height) / 2

    overlayCanvas = hs.canvas.new({ x = x, y = y, w = width, h = height})

    -- 배경
    overlayCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.1, green = 0.1, blue = 0.1, alpha = 0.92 },
        roundedRectRadii = { xRadius = 10, yRadius = 10 },
        frame = { x = 0, y = 0, w = width, h = height }
    })


    for i, win in ipairs(overlayWindows) do
        local itemY = padding + (i - 1) * itemH
        local isSel = (i == overlaySelected)

        -- 선택된 항목 하이라이트
        if isSel then
            overlayCanvas:appendElements({
                type = "rectangle",
                action = "fill",
                fillColor = { red = 0.2, green = 0.5, blue = 1.0, alpha = 0.7 },
                roundedRectRadii = { xRadius = 6, yRadius = 6 },
                frame = { x = 8, y = itemY, w = width - 16, h = itemH - 4 }
            })
        end

        -- 앱 이름
        overlayCanvas:appendElements({
            type = "text",
            text = win.app,
            textColor = isSel and { red = 1, green = 1, blue = 1, alpha = 1 } or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 },
            textSize = 14,
            frame = { x = 16, y = itemY + 8, w = 120, h = itemH}
        })

        -- 타이틀
        overlayCanvas:appendElements({
            type = "text",
            text = win.title,
            textColor = isSel and { red = 0.9, green = 0.9, blue = 0.9, alpha = 1 } or { red = 0.5, green = 0.5, blue = 0.5, alpha = 1 },
            textSize = 12,
            frame = { x = 144, y = itemY + 10, w = width - 160, h = itemH }
        })
    end

    overlayCanvas:show()
end

local overlayHotkeys = {}

local function clearOverlayHotkeys()
    for _, hk in ipairs(overlayHotkeys) do
        hk:delete()
    end

    overlayHotkeys = {}
end

local function focusSelected()
    local win = overlayWindows[overlaySelected]
    if not win then return end
    for _, w in ipairs(hs.window.allWindows()) do
        if tostring(w:id()) == win.id then
            w:focus(); break
        end
    end
end

local function showOverlay()
    if overlayVisible then
        -- 이미 열려있으면 다음 항목으로 이동
        overlaySelected = overlaySelected % #overlayWindows + 1
        drawOverlay()
        return
    end

    local currentWs = aerospace("list-workspaces --focused"):gsub("%s+", "")
    overlayWindows = getWsWindows(currentWs)

    if #overlayWindows <= 1 then return end -- 1개면 오버레이 필요없음

    -- 현재 포커스된 윈도우를 선택 상태로 시작
    local focusedId = getFocusedId()
    for i, win in ipairs(overlayWindows) do
        if win.id == focusedId then
            overlaySelected = i; break
        end
    end

    overlayVisible = true
    drawOverlay()

    -- 오버레이 조작 단축키 등록
    clearOverlayHotkeys()

    -- alt 떼면 확정 (tab 은 keyup 감지가 되지 않으므로, esc/enter로 대체)
    table.insert(overlayHotkeys, hs.hotkey.bind({}, "return", function()
        focusSelected()
        destroyOverlay()
        clearOverlayHotkeys()
        updateMenubar()
    end))

    table.insert(overlayHotkeys, hs.hotkey.bind({}, "escape", function()
        destroyOverlay()
        clearOverlayHotkeys()
    end))

    -- j/k, 방향키로 이동
    table.insert(overlayHotkeys, hs.hotkey.bind({"alt"}, "j", function()
        overlaySelected = overlaySelected % #overlayWindows + 1
        drawOverlay()
    end))

    table.insert(overlayHotkeys, hs.hotkey.bind({"alt"}, "k", function()
        overlaySelected = (overlaySelected - 2) % #overlayWindows + 1
        drawOverlay()
    end))
end

-- alt+tab: 오버레이 표시 / 순환
hs.hotkey.bind({"alt"}, "tab", function()
    showOverlay()
end)

-- 포커스 변경 시 메뉴바 업데이트

hs.window.filter.new():subscribe(hs.window.filter.windowFocused, function()
    if not overlayVisible then
        updateMenubar()
    end
end)

hs.timer.new(1, function()
    if not overlayVisible then
        updateMenubar()
    end
end):start()

updateMenubar()


-- 새 모니터 연결 시 알림 표시
hs.screen.watcher.new(function()
    hs.timer.doAfter(1.5, function()
        local unmapped = {}
        for _, screen in ipairs(hs.screen.allScreens()) do
            if not MONITOR_MAP[screen:name()] then
                table.insert(unmapped, screen:name())
            end
        end
        if #unmapped > 0 then
            hs.alert(
                "󰍹 인덱스 미부여 모니터:\n"
                .. table.concat(unmapped, "\n") .. "\n\n"
                .. "포커스 후 alt+shift+n 으로 부여",
                4
            )
        end
    end)
end):start()

-- 단축키 설정 
hs.hotkey.bind({"alt", "shift", "ctrl"}, "n", startAssign) -- 인덱스 부여 모드 시작


hs.hotkey.bind({"alt", "shift", "ctrl"}, "i", function() -- 현황 표시
    local lines = {"--- 모니터 인덱스 매핑 정보 ---"}
    for name, idx in pairs(MONITOR_MAP) do
        local active = ""
        for _, screen in ipairs(hs.screen.allScreens()) do
            if screen:name() == name then active = "" end
        end
        table.insert(lines, idx .. " | " .. name .. active)
    end

    table.insert(lines, "--- 워크스페이스 매핑 정보 ---")

    for idx, workspaces in pairs(wsMap) do
        local line = {idx .. " -> "}
        for _, workspace in pairs(workspaces) do
            table.insert(line, workspace)
        end
        table.insert(lines, table.concat(line, "|"))
    end

    hs.alert(table.concat(lines, "\n"), 3)
end)

hs.hotkey.bind({"alt", "shift", "ctrl"}, "r", function() -- 인식 순서대로 재설정
    MONITOR_MAP = {}
    local screens = hs.screen.allScreens()
    local lines = {"󰍹 모니터 매핑 재설정"}
    for i, screen in ipairs(screens) do
        MONITOR_MAP[screen:name()] = i
        table.insert(lines, i .. " | " .. screen:name())
    end
    saveMap()
    onAssignComplete()
    hs.alert(table.concat(lines, "\n"), 3)
end)

hs.hotkey.bind({"alt", "shift"}, "m", function()
    mouseMoveEnabled = not mouseMoveEnabled
    hs.alert("마우스 이동: " .. (mouseMoveEnabled and "ON" or "OFF"), 1)
end)

hs.hotkey.bind({"alt", "ctrl"}, "F1", function() focusMonitorByIndex(1) end)
hs.hotkey.bind({"alt", "ctrl"}, "F2", function() focusMonitorByIndex(2) end)
hs.hotkey.bind({"alt", "ctrl"}, "F3", function() focusMonitorByIndex(3) end)
hs.hotkey.bind({"alt", "ctrl"}, "F4", function() focusMonitorByIndex(4) end)

loadMap()
hs.timer.doAfter(2, function()
    local unmapped = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        if not MONITOR_MAP[screen:name()] then
            table.insert(unmapped, screen:name())
        end
    end

    if #unmapped > 0 then
        hs.alert(
            "인덱스 미부여 모니터 있음\n"
            .. "포커스 후 alt+shift+n",
            3
        )
    end
end)


---- 일반 키매핑 ----
hs.hotkey.bind({"alt", "ctrl"}, "return", function()
    local running = hs.application.get("iTerm2")
    if running then
        hs.applescript('tell application "iTerm" to create window with default profile')
    else
        hs.application.launchOrFocus("iTerm")
    end
end)

