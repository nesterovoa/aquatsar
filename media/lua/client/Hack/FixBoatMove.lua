local function fixBoatMove()
    local veh = getPlayer():getVehicle()
    local vec = veh:getScript():getCenterOfMassOffset()
    vec:set(vec:x()+0.1, vec:y(), vec:z())
    veh:scriptReloaded()
end

AUD.setButton(1, "Fix Boat", fixBoatMove)