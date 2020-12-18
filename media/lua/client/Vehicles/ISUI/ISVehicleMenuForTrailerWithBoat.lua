ISVehicleMenuForTrailerWithBoat = {}

--[[

	Должна быть вода в нужных точках
	спавн лодки на воду

	Обратно аналогично
	должна быть лодка в нужных точках

	Надо сохранять состояние всех контейнеров и топлива и аккумулятора в мод дата

]]
local vec = Vector3f.new()

local function canLaunchBoat(boat)
	local point = boat:getWorldPos(0, 0, -boat:getScript():getPhysicsChassisShape():z()/2 - 0.5, vec)
	if not WaterBorders.isWater(getCell():getGridSquare(point:x(), point:y(), 0)) then return false end
	
	point = boat:getWorldPos(0, 0, -boat:getScript():getPhysicsChassisShape():z()/2 - 6, vec)
	if not WaterBorders.isWater(getCell():getGridSquare(point:x(), point:y(), 0)) then return false end

	return true
end



function ISVehicleMenuForTrailerWithBoat.launchRadialMenu(playerObj, vehicle)
	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    if canLaunchBoat(vehicle) then
		menu:addSlice(getText("ContextMenu_LaunchBoat"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenuForTrailerWithBoat.launchBoat, playerObj, vehicle)
	end
end


function ISVehicleMenuForTrailerWithBoat.launchBoat(playerObj, vehicle)
	local point = vehicle:getWorldPos(0, 0, -vehicle:getScript():getPhysicsChassisShape():z()/2 - 6, vec)
	local sq = getCell():getGridSquare(point:x(), point:y(), 0)
	if sq == nil then return end
	
	local boatName = string.sub(vehicle:getScript():getName(), string.len("trailerwith")+1)
	vehicle:setScriptName("TrailerForBoat")
	vehicle:scriptReloaded()
	
	-- direction
	local diffX = math.abs(point:x() - vehicle:getX())
	local diffY = math.abs(point:y() - vehicle:getY())
	local dir = IsoDirections.N

	if vehicle:getY() > point:y() and diffY > diffX then
		dir = IsoDirections.S
		print("south")
	elseif vehicle:getX() > point:x() and diffX > diffY then
		dir = IsoDirections.E
		print("east")
	elseif vehicle:getX() < point:x() and diffX > diffY then
		dir = IsoDirections.W
		print("west")
	else
		dir = IsoDirections.N
		print("north")
	end
	addVehicleDebug("Base."..boatName, dir, 0, sq)
end
