-- Function to find peripherals
local function findPeripheral(peripheralType)
    for _, side in ipairs({"left", "right", "top", "bottom", "front", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == peripheralType then
            return peripheral.wrap(side)
        end
    end
    error(peripheralType .. " not found")
end

-- Peripheral setup
local reactor = findPeripheral("reactor") -- Change "reactor" to the actual type if needed
local matrix = findPeripheral("inductionMatrix") -- Change "inductionMatrix" to the actual type if needed
local monitor = findPeripheral("monitor")

monitor.setTextScale(0.5) -- Set text scale for readability

-- Function to get monitor size
local function getMonitorSize()
    local width, height = monitor.getSize()
    return width, height
end

-- Function to get reactor info
local function getReactorInfo()
    local status = reactor.getStatus() and "Active" or "Inactive"
    local fuelAmount = reactor.getFuelAmount() -- Assuming such a function exists
    local temperature = reactor.getTemperature() -- Assuming such a function exists
    local energy = reactor.getEnergyStored() -- Assuming such a function exists
    return {
        status = status,
        fuelAmount = fuelAmount,
        temperature = temperature,
        energy = energy
    }
end

-- Function to get matrix info
local function getMatrixInfo()
    local energyStored = matrix.getEnergyStored() -- Assuming such a function exists
    local maxEnergyStored = matrix.getMaxEnergyStored() -- Assuming such a function exists
    return {
        energyStored = energyStored,
        maxEnergyStored = maxEnergyStored
    }
end

-- Function to display info on monitor
local function displayInfo()
    while true do
        monitor.clear()
        local width, height = getMonitorSize()

        -- Get reactor info
        local reactorInfo = getReactorInfo()
        monitor.setCursorPos(1, 1)
        monitor.write("Reactor Status: " .. reactorInfo.status)
        monitor.setCursorPos(1, 2)
        monitor.write("Fuel Amount: " .. reactorInfo.fuelAmount)
        monitor.setCursorPos(1, 3)
        monitor.write("Temperature: " .. reactorInfo.temperature)
        monitor.setCursorPos(1, 4)
        monitor.write("Energy: " .. reactorInfo.energy)

        -- Get matrix info
        local matrixInfo = getMatrixInfo()
        monitor.setCursorPos(1, 6)
        monitor.write("Matrix Energy Stored: " .. matrixInfo.energyStored)
        monitor.setCursorPos(1, 7)
        monitor.write("Matrix Max Energy: " .. matrixInfo.maxEnergyStored)

        -- Adjust the display for larger monitors
        if height > 7 then
            monitor.setCursorPos(1, 9)
            monitor.write("More information can be added here if needed.")
        end

        -- Sleep for a bit before updating again
        sleep(5)
    end
end

-- Run the display function
displayInfo()
