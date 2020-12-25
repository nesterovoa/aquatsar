require("_DebugUIs/AIDebug/DebugValuesInspector")

if WaterNWindPhysics == nil then WaterNWindPhysics = {} end

local tempVec1 = Vector3f.new()
local tempVec2 = Vector3f.new()
local tempIsoObj = IsoObject.new()
local tempSquare = IsoGridSquare.new(getCell(), nil, 0, 0, 0)

local windForceByDirection = Vector3f.new()
local sailVector = Vector3f.new()
local collisionPosVector2 = Vector3.fromLengthDirection(1, 1)


function WaterNWindPhysics.getCollisionSquaresNear(dx, dy, square)
    local squares = {}
	if square == nil then return squares end

	for y=square:getY() - dy, square:getY() + dy do
		for x=square:getX() - dx, square:getX() + dx do
            local square2 = getCell():getGridSquare(x, y, 0)
			if square2 ~= nil and not WaterNWindPhysics.isWater(square2) then
				table.insert(squares, square2)
			end
		end
	end
	return squares
end

function WaterNWindPhysics.isWater(square)
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

function WaterNWindPhysics:ApplyImpulseBreak(veh, groundSquare)
	tempIsoObj:setSquare(groundSquare)
	local collisionVector = veh:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
	if collisionVector then
		veh:ApplyImpulse4Break(tempIsoObj, 0.1)
	end
end

function WaterNWindPhysics.getWindDirection()
    return ClimateManager.getWindAngleString(getClimateManager():getWindAngleDegrees())
end

function WaterNWindPhysics.getWindSpeed()
    return getClimateManager():getWindIntensity()*getClimateManager():getMaxWindspeedKph()
end


function WaterNWindPhysics.updateVehicles()

	local boats = getCell():getVehicles()
    for i=0, boats:size()-1 do
        local boat = boats:get(i)
		local boatScriptName = boat:getScript():getName()
        if boat ~= nil and  AquaTsarConfig.isBoat(boat) then

			local collisionWithGround = false
			local frontVector = Vector3f.new()
			local rearVector = Vector3f.new()
			boat:getAttachmentWorldPos("trailerfront", frontVector)
			boat:getAttachmentWorldPos("trailer", rearVector)
			
			local squareUnderVehicle = getCell():getGridSquare(boat:getX(), boat:getY(), 0)
            if squareUnderVehicle ~= nil and WaterNWindPhysics.isWater(squareUnderVehicle) then
				if boat:getDebugZ() < 0.64 then
					-- if boat:getDriver() then
					-- -- for i = 1, 5 do 
						-- -- boat:setDebugZ(0.64 + i/100)
						-- tempVec1:set(0, 3000, 0)
						-- boat:setPhysicsActive(true)
						-- tempVec2:set(0, 0, 0)
						-- boat:addImpulse(tempVec1, tempVec2)
					-- else
					boat:setDebugZ(0.67)
					-- end
					-- end
					print("boat:setDebugZ(0.68)")
				end
                local notWaterSquares = WaterNWindPhysics.getCollisionSquaresNear(5, 5, squareUnderVehicle)
                local a = 1
				for _, square in ipairs(notWaterSquares) do
					--print(a, ": ", square:getX(), " ", square:getY())
                    tempSquare:setX(square:getX())
                    tempSquare:setY(square:getY())
                    tempSquare:setZ(0.8)

                    tempIsoObj:setSquare(tempSquare)
                    local collisionVector = boat:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
                    if collisionVector then
						--print(collisionVector:getX(), " ", collisionVector:getY())
                        boat:ApplyImpulse4Break(tempIsoObj, 0.2)
						boat:ApplyImpulse(tempIsoObj, 120)
						collisionWithGround = true
                    end
                end
			else
				if boat:getDebugZ() < 0.65 then
					boat:setZ(0.65 - boat:getDebugZ())
				end
			end
			
			if AquaTsarConfig.isBoat(boat).sails then
				local boatSpeed = boat:getCurrentSpeedKmHour()
				local windSpeed = WaterNWindPhysics.getWindSpeed()
				
				AIDebug.setInsp("Boat", "windSpeed (MPH):", windSpeed / 1.60934)
				AIDebug.setInsp("Boat", "boatSpeed (MPH):", boat:getCurrentSpeedKmHour() / 1.60934)
				AIDebug.setInsp("Boat", " ", " ")
				
				
				local x = frontVector:x() - rearVector:x()
				local y = frontVector:y() - rearVector:y()
				
				local boatDirVector = Vector3f.new(x, y, 0):normalize()
				local boatDirection = math.atan2(x,y) * 57.2958 + 180
				
				local sailAngle = boat:getModData()["sailAngle"]
				if sailAngle == nil then
					sailAngle = 0
					boat:getModData()["sailAngle"] = 0
				end
				
				local wind = getClimateManager():getWindAngleDegrees()
				local windOnBoat = 0
				if wind > boatDirection then
					windOnBoat = wind - boatDirection
				else
					windOnBoat = 360 - (boatDirection - wind)
				end
				
				local windForceByDirection = 0
				if windSpeed < 7 * 1.60934 then
					windForceByDirection = 0
				elseif windSpeed < 12 * 1.60934 then
					if windOnBoat > 105 and windOnBoat < 285 then
						windForceByDirection = 7 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boatScriptName].windInfluence
					end
				elseif windSpeed < 23 * 1.60934 then
					if windOnBoat > 25 and windOnBoat < 335 then
						windForceByDirection = 10 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boatScriptName].windInfluence
					end
				elseif windSpeed < 31 * 1.60934 then
					if windOnBoat > 25 and windOnBoat < 335 then
						windForceByDirection = 13 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boatScriptName].windInfluence
					end
				elseif windSpeed < 61 then
					if windOnBoat > 105 and windOnBoat < 285 then
						windForceByDirection = 16 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boatScriptName].windInfluence
					end
				else
					-- TODO WARNING!!!
				end
				
				local coefficientSailAngle = 0
				local requiredSailAngle = 0
				if windOnBoat > 160 and windOnBoat < 200 then
					if AquaBoats[boatScriptName].sailsSide == "Left" and sailAngle < 0 then
						windForceByDirection = windForceByDirection * (sailAngle / -90)
						requiredSailAngle = "Any < 0"
					elseif AquaBoats[boatScriptName].sailsSide == "Right" and sailAngle > 0 then
						windForceByDirection = windForceByDirection * (sailAngle / 90)
						requiredSailAngle = "Any > 0"
					else 
						windForceByDirection = 0
						requiredSailAngle = "Another direction"
					end
				elseif windOnBoat < 160 and AquaBoats[boatScriptName].sailsSide == "Right" and sailAngle < 0 then
					requiredSailAngle = windOnBoat/2
					coefficientSailAngle = -0.01 * (math.abs(sailAngle) - requiredSailAngle)^2 + 1
					if coefficientSailAngle > 0 then
						windForceByDirection = coefficientSailAngle * windForceByDirection
					else
						windForceByDirection = 0
					end
				elseif windOnBoat > 200 and AquaBoats[boatScriptName].sailsSide == "Left" and sailAngle > 0 then
					requiredSailAngle = (360 - windOnBoat)/2
					coefficientSailAngle = -0.01 * (math.abs(sailAngle) - requiredSailAngle)^2 + 1
					if coefficientSailAngle > 0 then
						windForceByDirection = coefficientSailAngle * windForceByDirection
					else
						windForceByDirection = 0
					end
				else
					windForceByDirection = 0
					requiredSailAngle = "Another direction"
				end
					
				AIDebug.setInsp("Boat", " ", " ")
				AIDebug.setInsp("Boat", "windOnBoat:", windOnBoat)
				AIDebug.setInsp("Boat", " ", " ")
				AIDebug.setInsp("Boat", "SailAngle:", sailAngle)
				AIDebug.setInsp("Boat", "RequiredSailAngle (absolute value):", requiredSailAngle)
				AIDebug.setInsp("Boat", " ", " ")
				AIDebug.setInsp("Boat", "coefficientSailAngle:", coefficientSailAngle)
				AIDebug.setInsp("Boat", "windForceByDirection:", windForceByDirection)
				AIDebug.setInsp("Boat", " ", " ")
				
				boat:getAttachmentWorldPos("checkFront", frontVector)
				local squareFrontVehicle = getCell():getGridSquare(frontVector:x(), frontVector:y(), 0)
				if squareFrontVehicle ~= nil and WaterNWindPhysics.isWater(squareFrontVehicle) then
					if boatSpeed < (windForceByDirection * 1.60934) and boatSpeed < windSpeed and not isKeyDown(Keyboard.KEY_S) then
						local startCoeff = 1
						if boatSpeed < 2 then
							startCoeff = 5
						end
						if collisionWithGround then 
							boatDirVector:mul(250 * windForceByDirection)
						else
							boatDirVector:mul(450 * windForceByDirection * startCoeff)
						end
						boatDirVector:set(boatDirVector:x(), 0, boatDirVector:y())
						boat:setPhysicsActive(true)
						tempVec2:set(0, 0, 0)
						boat:addImpulse(boatDirVector, tempVec2)   
					end
					AIDebug.setInsp("Boat", "forceVectorX:", boatDirVector:x())
					AIDebug.setInsp("Boat", "forceVectorZ:", boatDirVector:y())
					AIDebug.setInsp("Boat", "forceVectorY:", boatDirVector:z())
				end
				if boat:getDriver() then
					if isKeyDown(Keyboard.KEY_A) then
						boat:update()
						forceVector = boat:getWorldPos(-1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
						forceVector:mul(80 * windForceByDirection)
						forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
						
						boat:getWorldPos(0, 0, -3, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
						tempVec2:set(tempVec2:x(), tempVec2:z(), tempVec2:y())
						boat:addImpulse(forceVector, tempVec2)   
					elseif isKeyDown(Keyboard.KEY_D) then
						boat:update()
						forceVector = boat:getWorldPos(1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
						forceVector:mul(80 * windForceByDirection)
						forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
						
						boat:getWorldPos(0, 0, -3, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
						tempVec2:set(tempVec2:x(), tempVec2:z(), tempVec2:y())
						boat:addImpulse(forceVector, tempVec2)  
					elseif isKeyDown(Keyboard.KEY_LEFT) then
						if sailAngle < 90 then
							sailAngle = sailAngle + 1
						end
						boat:getModData()["sailAngle"] = sailAngle
					elseif isKeyDown(Keyboard.KEY_RIGHT) then
						if sailAngle > -90 then
							sailAngle = sailAngle - 1
						end
						boat:getModData()["sailAngle"] = sailAngle
					end
				end
			end
        end
    end
	
	local player = getPlayer()
	if player then
		local boat = player:getVehicle()
		if boat ~= nil and  AquaTsarConfig.isBoat(boat) then
			local squareUnderVehicle = getCell():getGridSquare(boat:getX(), boat:getY(), 0)
            if squareUnderVehicle ~= nil and WaterNWindPhysics.isWater(squareUnderVehicle)==false then
				if boat:isEngineRunning() then
					boat:engineDoShutingDown()
				end
			end
		end
	end

end

Events.OnTick.Add(WaterNWindPhysics.updateVehicles)