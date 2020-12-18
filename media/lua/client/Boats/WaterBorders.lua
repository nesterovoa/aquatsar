if WaterBorders == nil then WaterBorders = {} end

local tempIsoObj = IsoObject.new()
local tempSquare = IsoGridSquare.new(getCell(), nil, 0, 0, 0)
local collisionPosVector2 = Vector3.fromLengthDirection(1, 1)

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

function WaterBorders.getCollisionSquaresNear(dx, dy, square)
    local squares = {}
	if square == nil then return squares end

	for y=square:getY() - dy, square:getY() + dy do
		for x=square:getX() - dx, square:getX() + dx do
            local square2 = getCell():getGridSquare(x, y, 0)
			if square2 ~= nil and not WaterBorders.isWater(square2) then
				table.insert(squares, square2)
			end
		end
	end
	return squares
end

function WaterBorders.isBoat(vehicle)
    return starts_with(string.lower(vehicle:getScript():getName()), "boat")
end

function WaterBorders.isWater(square)
	local tileName = square:getFloor():getTextureName()
	if not tileName then
		return true
	elseif string.match(string.lower(tileName), "blends_natural_02") then
		return true
	else
		return false
	end
    --return square:getFloor():getSprite():getProperties():Is(IsoFlagType.water)
end

function WaterBorders:ApplyImpulseBreak(veh, groundSquare)
	tempIsoObj:setSquare(groundSquare)
	local collisionVector = veh:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
	if collisionVector then
		veh:ApplyImpulse4Break(tempIsoObj, 0.1)
	end
end

function WaterBorders.updateVehicles()
    local vehicles = getCell():getVehicles()
    for i=0, vehicles:size()-1 do
        local vehicle = vehicles:get(i)
        if vehicle ~= nil and WaterBorders.isBoat(vehicle) then
            local squareUnderVehicle = getCell():getGridSquare(vehicle:getX(), vehicle:getY(), 0)
            if squareUnderVehicle ~= nil and WaterBorders.isWater(squareUnderVehicle) then
				if vehicle:getDebugZ() < 0.65 then
					vehicle:setDebugZ(0.68)
				end
                local notWaterSquares = WaterBorders.getCollisionSquaresNear(5, 5, squareUnderVehicle)
                local a = 1
				for _, square in ipairs(notWaterSquares) do
					--print(a, ": ", square:getX(), " ", square:getY())
                    tempSquare:setX(square:getX())
                    tempSquare:setY(square:getY())
                    tempSquare:setZ(0.8)

                    tempIsoObj:setSquare(tempSquare)
                    local collisionVector = vehicle:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
                    if collisionVector then
						--print(collisionVector:getX(), " ", collisionVector:getY())
                        vehicle:ApplyImpulse4Break(tempIsoObj, 0.2)
						vehicle:ApplyImpulse(tempIsoObj, 180)
                    end
                end
			else
				if vehicle:getDebugZ() < 0.65 then
					vehicle:setZ(0.65 - vehicle:getDebugZ())
				end
			end
        end
    end
	
	local player = getPlayer()
	if player then
		local vehicle = player:getVehicle()
		if vehicle ~= nil and WaterBorders.isBoat(vehicle) then
			local squareUnderVehicle = getCell():getGridSquare(vehicle:getX(), vehicle:getY(), 0)
            if squareUnderVehicle ~= nil and WaterBorders.isWater(squareUnderVehicle)==false then
				if vehicle:isEngineRunning() then
					vehicle:engineDoShutingDown()
				end
			end
		end
	end
	
end

Events.OnTick.Add(WaterBorders.updateVehicles)