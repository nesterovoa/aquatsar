if WaterBorders == nil then WaterBorders = {} end

local tempIsoObj = IsoObject.new()
local tempSquare = IsoGridSquare.new(getCell(), nil, 0, 0, 0)
local collisionPosVector2 = Vector3.fromLengthDirection(1, 1)


function WaterBorders.getCollisionSquaresNear(radius, square)
    local squares = {}
	if square == nil then return squares end

	for y=square:getY() - radius, square:getY() + radius do
		for x=square:getX() - radius, square:getX() + radius do
            local square2 = getCell():getGridSquare(x, y, 0)
			if square2 ~= nil and not WaterBorders.isWater(square2) then
				table.insert(squares, square2)
			end
		end
	end
	return squares
end

function WaterBorders.isBoat(vehicle)
    return string.match(string.lower(vehicle:getScript():getName()), "boat")
end

function WaterBorders.isWater(square)
    return square:getFloor():getSprite():getProperties():Is(IsoFlagType.water)
end

function WaterBorders.updateVehicles()
    local vehicles = getCell():getVehicles()
    for i=0, vehicles:size()-1 do
        local veh = vehicles:get(i)

        if veh ~= nil and WaterBorders.isBoat(veh) then
            local squareUnderVehicle = getCell():getGridSquare(veh:getX(), veh:getY(), 0)
            if squareUnderVehicle ~= nil and WaterBorders.isWater(squareUnderVehicle) then
                local notWaterSquares = WaterBorders.getCollisionSquaresNear(8, squareUnderVehicle)
                for _, square in ipairs(notWaterSquares) do
                    tempSquare:setX(square:getX())
                    tempSquare:setY(square:getY())
                    tempSquare:setZ(0.8)

                    tempIsoObj:setSquare(tempSquare)
                    local collisionVector = veh:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
                    if collisionVector then
                        veh:ApplyImpulse4Break(tempIsoObj, 0.1)
                    end
                end
            end
        end
    end
end

Events.OnTick.Add(WaterBorders.updateVehicles)