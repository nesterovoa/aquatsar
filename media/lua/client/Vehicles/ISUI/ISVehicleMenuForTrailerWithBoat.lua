require("Boats/aquatsarConfig")

ISVehicleMenuForTrailerWithBoat = {}
local vec = Vector3f.new()

ISVehicleMenuForTrailerWithBoat.nearCheckThatTrailerNearWater = 3
ISVehicleMenuForTrailerWithBoat.spawnDistForBoat = 6


-- Launch boat on water

local function canLaunchBoat(boat)
	local point = boat:getWorldPos(0, 0, -boat:getScript():getPhysicsChassisShape():z()/2 - ISVehicleMenuForTrailerWithBoat.nearCheckThatTrailerNearWater, vec)
	if not WaterBorders.isWater(getCell():getGridSquare(point:x(), point:y(), 0)) then return false end
	
	point = boat:getWorldPos(0, 0, -boat:getScript():getPhysicsChassisShape():z()/2 - ISVehicleMenuForTrailerWithBoat.spawnDistForBoat, vec)
	if not WaterBorders.isWater(getCell():getGridSquare(point:x(), point:y(), 0)) then return false end

	return true
end

function ISVehicleMenuForTrailerWithBoat.launchRadialMenu(playerObj, vehicle)
	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    if canLaunchBoat(vehicle) then
		menu:addSlice(getText("ContextMenu_LaunchBoat"), getTexture("media/ui/boats/ICON_boat_on_trailer.png"), ISVehicleMenuForTrailerWithBoat.launchBoat, playerObj, vehicle)
	end
end

function ISVehicleMenuForTrailerWithBoat.launchBoat(playerObj, vehicle)
	local point = vehicle:getWorldPos(0, 0, -vehicle:getScript():getPhysicsChassisShape():z()/2 - ISVehicleMenuForTrailerWithBoat.spawnDistForBoat, vec)
	local sq = getCell():getGridSquare(point:x(), point:y(), 0)
	if sq == nil then return end
	
	if luautils.walkAdj(playerObj, vehicle:getSquare()) then
		ISTimedActionQueue.add(ISLaunchBoatOnWater:new(playerObj, vehicle, sq));
	end
end



-- Load boat on trailer

local function getBoatAtRearOfTrailer(vehicle)
	-- Check line at rear of trailer
	for i=0, 8, 0.5 do	
		local point = vehicle:getWorldPos(0, 0, -vehicle:getScript():getPhysicsChassisShape():z()/2 - i, vec)
		local sq = getCell():getGridSquare(point:x(), point:y(), 0)
		
		local boat = sq:getVehicleContainer()
		if boat then
			if AquaTsarConfig.isBoat(boat) and AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable[vehicle:getScript():getName()][boat:getScript():getName()] then
				return boat
			end
		end
	end
end

local function isEmptyContainersOnVehicle(vehicle)
	for i=1,vehicle:getPartCount() do
		local part = vehicle:getPartByIndex(i-1)	
		if part:isContainer() and part:getItemContainer() ~= nil then
			local itemContainer = part:getItemContainer()
			if itemContainer:getItems():size() ~= 0 then return false end
		end
	end
	return true
end


function ISVehicleMenuForTrailerWithBoat.loadOntoTrailerRadialMenu(playerObj, vehicle)
	if AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable[vehicle:getScript():getName()] == nil then 	-- check is trailer for boat
		return
	end
	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
	
	local boat = getBoatAtRearOfTrailer(vehicle)
	if boat then
		if isEmptyContainersOnVehicle(boat) then	
			menu:addSlice(getText("ContextMenu_LoadBoatOntoTrailer"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenuForTrailerWithBoat.loadOntoTrailer, playerObj, vehicle, boat)
		else
			menu:addSlice(getText("ContextMenu_CantLoadBoatBecauseItemsInside"), getTexture("media/ui/vehicles/vehicle_repair.png"))
		end
	end
end


function ISVehicleMenuForTrailerWithBoat.loadOntoTrailer(playerObj, vehicle, boat)
	if luautils.walkAdj(playerObj, vehicle:getSquare()) then
		ISTimedActionQueue.add(ISLoadBoatOntoTrailer:new(playerObj, vehicle, boat));
	end
end










































--[[

	Должна быть вода в нужных точках
	спавн лодки на воду

	Обратно аналогично
	должна быть лодка в нужных точках

	Надо сохранять состояние всех контейнеров и топлива и аккумулятора в мод дата

]]








