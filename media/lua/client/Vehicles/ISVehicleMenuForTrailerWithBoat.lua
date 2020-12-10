
ISVehicleMenuForTrailerWithBoat = {}

local function get_name_of_boat(scriptName)
	return scriptName:sub(12)
end

function ISVehicleMenuForTrailerWithBoat.launchRadialMenu(playerObj, vehicle)
   local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
   menu:addSlice(getText("ContextMenu_LaunchBoat"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenuForTrailerWithBoat.launchBoat, playerObj, vehicle)
end


function ISVehicleMenuForTrailerWithBoat.launchBoat(playerObj, vehicle)
	--print(get_name_of_boat(vehicle:getScript():getName()))
	--vehicle:setScriptName(get_name_of_boat(vehicle:getScript():getName()))
	vehicle:setScriptName("TrailerForBoat")
	vehicle:scriptReloaded()
end