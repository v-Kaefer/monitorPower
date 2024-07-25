local modemSide = "top" -- Replace with the side where the Ender Modem is attached

-- Open the modem for communication
if peripheral.isPresent(modemSide) and peripheral.getType(modemSide) == "modem" then
    rednet.open(modemSide)
else
    error("No modem found on the specified side.")
end

local inductionData = {}
local reactorData = {}

-- Function to display data on a monitor with text wrapping
local function displayData()
    local monitor = nil
    for _, side in ipairs({"left", "right", "top", "bottom"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "monitor" then
            monitor = peripheral.wrap(side)
            break
        end
    end

    if not monitor then
        error("No monitor found.")
    end

    local width, height = monitor.getSize()

    while true do
        monitor.clear()

        -- Draw borders and headers
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

        drawBorder()
        writeCentered("System Status", 2)

        -- Display Induction Matrix Data
        local y = 4
        if next(inductionData) then
            writeCentered("Induction Matrix", y)
            y = y + 1
            for label, value in pairs(inductionData) do
                monitor.setCursorPos(2, y)
                monitor.write(label .. ": " .. value)
                y = y + 1
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
                monitor.write(label .. ": " .. value)
                y = y + 1
            end
        else
            y = y + 1
            writeCentered("No Reactor Data", y)
            y = y + 1
        end

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

parallel.waitForAll(displayData, function()
    while true do
        local senderId, message, protocol = rednet.receive()
        handleData(senderId, message, protocol)
    end
end)
