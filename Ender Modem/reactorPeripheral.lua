-- Replace "back" with the side where the Ender Modem is attached
local modemSide = "top"

if peripheral.isPresent(modemSide) and peripheral.getType(modemSide) == "modem" then
    rednet.open(modemSide)
else
    error("Reactor modem not found")
end

local function respondToRequests()
    while true do
        local senderID, message, protocol = rednet.receive("energyMonitor")
        if protocol == "energyMonitor" and message == "requestReactorInfo" then
            local reactor = peripheral.wrap("BigReactors-Reactor_142")
            local energyStored = reactor.get
            local maxEnergyStored = reactor.
            rednet.send(senderID, toString(energyStored) .. "," .. toString(maxEnergyStored))
        end
    end
end

respondToRequests()
