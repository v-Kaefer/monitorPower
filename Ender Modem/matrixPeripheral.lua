-- Replace "top" with the side where the Ender Modem is attached
local modemSide = "top"

-- Detect peripheral
if peripheral.isPresent(modemSide) and peripheral.getType(modemSide) == "modem" then
    rednet.open(modemSide)
else
    error("No modem found in Induction Matrix!")
end

-- Instead of sending data periodically, send upon request only
local function respondToRequests()
    while true do
        local senderId, message, protocol = rednet.receive("energyMonitor")
        if protocol == "energyMonitor" and message == "requestMatrixInfo" then
            local matrix = peripheral.wrap("Induction Matrix_32")
            local energyStored = matrix.getRFStored() or 0
            local maxEnergyStored = matrix.getRFCapacity() or 0
            modem.send(senderId, tostring(energyStored) .. "," .. toString(maxEnergyStored))
        end
    end
end

respondToRequests()
