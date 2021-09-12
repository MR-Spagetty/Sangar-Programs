local event = require("event")
local t = require("component").tunnel
local os = require("os")
local drone = {
wake = function()
    t.send("wake up neo")
    local _, _, _, _, _, response = event.pull("modem_message")
    print(response)
end,
move = function(dx, dy, dz)
    t.send("mov",dx,dy,dz)
end,

getOffset = function()
    t.send("gof")
    local _, _, _, _, _, response = event.pull("modem_message")
    print(response)
end,

use = function(side)
    t.send("use", side)
    local _, _, _, _, _, response, response2 = event.pull("modem_message")
    print(response, response2)
end,

scan = function()
    os.execute("robotGeo2ComputerHolo")
end,

shutdown = function()
    t.send("shut", false)
end,

reboot = function()
    t.send("shut",true)
end
}
return drone