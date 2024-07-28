local modemSide = "top" -- Replace with the side where the Ender Modem is attached

-- Open the modem for communication
if peripheral.isPresent(modemSide) and peripheral.getType(modemSide) == "modem" then
    rednet.open(modemSide)
else
    error("No modem found on the specified side.")
end

local inductionData = {}
local reactorData = {}
local reactorActive = false

-- Function to display data on a monitor with text wrapping
local function displayData()
    local monitor = nil
    for _, side in ipairs({"left", "right", "top", "bottom", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "monitor" then
            monitor = peripheral.wrap(side)
            break
        end
    end

    if not monitor then
        error("No monitor found.")
    end

    -- Monitors Size Control
    local width, height = monitor.getSize()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)

    -- Apenas desenho de fora, pode ser removido
    local function drawBorder()
        for x = 1, width do
            monitor.setCursorPos(x, 1)
            monitor.write("-")
            monitor.setCursorPos(x, height)
            monitor.write("-")
        end
        for y = 1, height do
            monitor.setCursorPos(1, y)
            monitor.write("|")
            monitor.setCursorPos(width, y)
            monitor.write("|")
        end
        monitor.setCursorPos(1, 1)
        monitor.write("+")
        monitor.setCursorPos(width, 1)
        monitor.write("+")
        monitor.setCursorPos(1, height)
        monitor.write("+")
        monitor.setCursorPos(width, height)
        monitor.write("+")
    end

    local function writeCentered(text, y)
        local x = math.floor((width - #text) / 2) + 1
        monitor.setCursorPos(x, y)
        monitor.write(text)
    end

    local function drawColoredProgressBar(label, value, maxValue, y)
        local barWidth = width - 4
        local progress = math.floor((value / maxValue) * barWidth)
        monitor.setCursorPos(2, y)
        monitor.write(label)
        monitor.setCursorPos(2, y + 1)
        monitor.write("[")
        monitor.setCursorPos(barWidth + 2, y + 1)
        monitor.write("]")
        monitor.setCursorPos(3, y + 1)
        monitor.setBackgroundColor(colors.green)
        monitor.write(string.rep(" ", progress))
        monitor.setBackgroundColor(colors.black)
        monitor.write(string.rep(" ", barWidth - progress))
        monitor.setBackgroundColor(colors.black)
    end

    local function drawControlPanel()
        local panelX = width - 10
        monitor.setCursorPos(panelX, 2)
        monitor.write("Control Panel")

        -- Reactor Control Button
        monitor.setCursorPos(panelX, 4)
        monitor.write("Reactor: " .. (reactorActive and "On" or "Off"))

        -- Waste Bar
        local wastePercent = (reactorData["Waste Amount"] or 0) / (reactorData["Max Waste"] or 1) * 100
        monitor.setCursorPos(panelX, 6)
        monitor.write("Waste: " .. string.format("%.2f", wastePercent) .. "%")

        for y = 7, height - 1 do
            local barHeight = height - 8
            local fillHeight = math.floor(barHeight * (wastePercent / 100))
            monitor.setCursorPos(panelX, y)
            if y <= height - 1 - fillHeight then
                monitor.write("|")
            else
                monitor.setBackgroundColor(colors.red)
                monitor.write("|")
                monitor.setBackgroundColor(colors.green)
            end
        end
    end

    while true do
        monitor.clear()
        drawBorder()
        writeCentered("System Status", 2)

        -- Display Induction Matrix Data with a Colored Progress Bar
        local y = 4
        if next(inductionData) then
            writeCentered("Induction Matrix", y)
            y = y + 1
            for label, value in pairs(inductionData) do
                if label == "RF Stored" or label == "Max Energy" then
                    drawColoredProgressBar("Energy: ", inductionData["RF Stored"], inductionData["Max Energy"], y)
                    y = y + 3
                else
                    monitor.setCursorPos(2, y)
                    monitor.write(label .. ": " .. tostring(value))
                    y = y + 1
                end
            end
        else
            writeCentered("No Induction Matrix Data", y)
            y = y + 1
        end

        -- Display Reactor Data
        if next(reactorData) then
            y = y + 1
            writeCentered("Reactor", y)
            y = y + 1
            for label, value in pairs(reactorData) do
                monitor.setCursorPos(2, y)
                monitor.write(label .. ": " .. tostring(value))
                y = y + 1
            end
        else
            y = y + 1
            writeCentered("No Reactor Data", y)
            y = y + 1
        end

        -- Display Control Panel
        drawControlPanel()

        sleep(1)
    end
end

-- Function to handle received data
local function handleData(senderId, message, protocol)
    local data = textutils.unserialize(message)
    if protocol == "matrixPeripheralTest" then
        inductionData = data
    elseif protocol == "reactorPeripheralTest" then
        reactorData = data
    end
end

-- Function to handle monitor touch events
local function handleTouch()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        if x >= width - 10 and x <= width - 1 then
            if y == 4 then
                reactorActive = not reactorActive
                rednet.broadcast(reactorActive and "activate" or "deactivate", "reactorControl")
            end
        end
    end
end

parallel.waitForAll(displayData, function()
    while true do
        local senderId, message, protocol = rednet.receive()
        handleData(senderId, message, protocol)
    end
end, handleTouch)
