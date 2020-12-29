--*************************************************************
--**                    Developer: IBrRus                    **
--*************************************************************

if WaterNWindPhysics == nil then WaterNWindPhysics = {} end

local tempVec1 = Vector3f.new()
local tempVec2 = Vector3f.new()
local tempIsoObj = IsoObject.new()
local tempSquare = IsoGridSquare.new(getCell(), nil, 0, 0, 0)

local frontVector = Vector3f.new()
local rearVector = Vector3f.new()
local windForceByDirection = Vector3f.new()
local sailVector = Vector3f.new()
local collisionPosVector2 = Vector3.fromLengthDirection(1, 1)
local boatDirVector = Vector3f.new()


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

-- function WaterNWindPhysics.isWater(square)
	-- local tileName = square:getFloor():getTextureName()
	-- if not tileName then
		-- return true
	-- elseif string.match(string.lower(tileName), "blends_natural_02") then
		-- return true
	-- else
		-- return false
	-- end
    -- --return square:getFloor():getSprite():getProperties():Is(IsoFlagType.water)
-- end

function WaterNWindPhysics.isWater(square)
	return square ~= nil and square:Is(IsoFlagType.water)
end

function WaterNWindPhysics.ApplyImpulseBreak(veh, groundSquare)
	tempIsoObj:setSquare(groundSquare)
	local collisionVector = veh:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
	if collisionVector then
		veh:ApplyImpulse4Break(tempIsoObj, 0.1)
	end
end

function WaterNWindPhysics.getWindDirection()
	local angle = getClimateManager():getWindAngleDegrees()
	local windAngles = { 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, 382.5 }
	local windAngleStr = { "N", "NW", "W", "SW", "S", "SE", "E", "NE", "N" }
    for b = 1, #windAngles do
		if (angle < windAngles[b]) then
			return windAngleStr[b]
		end
	end
    return windAngleStr[#windAngleStr - 1];
end

function WaterNWindPhysics.getWindSpeed()
    return getClimateManager():getWindspeedKph()
end


function WaterNWindPhysics.updateVehicles()

	local boats = getCell():getVehicles()
    for i=0, boats:size()-1 do
        local boat = boats:get(i)
		local boatScriptName = boat:getScript():getName()
        if boat ~= nil and  AquaConfig.isBoat(boat) then
			local boatSpeed = boat:getCurrentSpeedKmHour()
			local collisionWithGround = false
			boat:getAttachmentWorldPos("trailerfront", frontVector)
			boat:getAttachmentWorldPos("trailer", rearVector)
			local x = frontVector:x() - rearVector:x()
			local y = frontVector:y() - rearVector:y()
			boatDirVector:set(x, 0, y):normalize()
			local squareUnderVehicle = getCell():getGridSquare(boat:getX(), boat:getY(), 0)
            if squareUnderVehicle ~= nil and WaterNWindPhysics.isWater(squareUnderVehicle) then
				--AUD.insp("Boat", "boat:getEngineSpeed()", boat:getEngineSpeed())
				--AUD.insp("Boat", "boat:isBraking()", insp)
				--AUD.insp("Boat", "boatSpeed", boatSpeed)
				-- AUD.insp("Boat", " ", " ")
				if math.abs(boatSpeed) < 0.2 and boat:getDebugZ() < 0.67 then
						boat:setPhysicsActive(true)
						boat:setMass(100)
						tempVec1:set(0, 5000, 0)
						tempVec2:set(0, 0, 0)
						boat:addImpulse(tempVec1, tempVec2)
						print("boat:addImpulse")
				elseif math.abs(boatSpeed) > 6 then
					if isKeyDown(Keyboard.KEY_S) then
						boat:setMass(1900)
					else
						boat:setMass(1000)
					end
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
			
			if AquaConfig.Boats[boat:getScript():getName()].sails then
				
				local windSpeed = WaterNWindPhysics.getWindSpeed()
				
				AUD.insp("Boat", "windSpeed (MPH):", windSpeed / 1.60934)
				-- AUD.insp("Boat", "boatSpeed (MPH):", boat:getCurrentSpeedKmHour() / 1.60934)
				-- AUD.insp("Boat", " ", " ")
				boatDirVector:set(x, 0, y):normalize()
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
						windForceByDirection = 7 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
					end
				elseif windSpeed < 23 * 1.60934 then
					if windOnBoat > 25 and windOnBoat < 335 then
						windForceByDirection = 10 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
					end
				elseif windSpeed < 31 * 1.60934 then
					if windOnBoat > 25 and windOnBoat < 335 then
						windForceByDirection = 12 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
					end
				elseif windSpeed < 61 * 1.60934 then
					if windOnBoat > 105 and windOnBoat < 285 then
						windForceByDirection = 14 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
					end
				else
					-- TODO WARNING!!!
				end
				
				local coefficientSailAngle = 0
				local requiredSailAngle = 0
				if windOnBoat >= 150 and windOnBoat <= 210 then
					if AquaConfig.Boats[boatScriptName].sailsSide == "Left" and sailAngle < 0 then
						windForceByDirection = windForceByDirection * (sailAngle / -90)
						requiredSailAngle = "Any < 0"
					elseif AquaConfig.Boats[boatScriptName].sailsSide == "Right" and sailAngle > 0 then
						windForceByDirection = windForceByDirection * (sailAngle / 90)
						requiredSailAngle = "Any > 0"
					else 
						windForceByDirection = 0
						requiredSailAngle = "Another direction"
					end
				elseif windOnBoat < 150 and AquaConfig.Boats[boatScriptName].sailsSide == "Right" and sailAngle < 0 then
					requiredSailAngle = windOnBoat/2
					local deltaAngle = math.abs(sailAngle) - requiredSailAngle
					if deltaAngle > 10 then
						local y2 = 0.44
						local x2 = requiredSailAngle+10
						local x1 = 90
						local y1 = 0
						local m = y2/(x2-x1)
						coefficientSailAngle = m * (math.abs(sailAngle)-90)
					elseif deltaAngle < -10 then
						local y2 = 0.44
						local x2 = requiredSailAngle - 10
						if x2 <= 0 then x2 = 0.01 end
						local m = y2/x2
						coefficientSailAngle = m * math.abs(sailAngle)
					else
						coefficientSailAngle = -0.005 * deltaAngle^2 + 1
					end
					if coefficientSailAngle > 0 then
						windForceByDirection = coefficientSailAngle * windForceByDirection
					else
						windForceByDirection = 0
					end
				elseif windOnBoat > 210 and AquaConfig.Boats[boatScriptName].sailsSide == "Left" and sailAngle > 0 then
					requiredSailAngle = (360 - windOnBoat)/2
					local deltaAngle = math.abs(sailAngle) - requiredSailAngle
					if deltaAngle > 10 then
						local y2 = 0.44
						local x2 = requiredSailAngle+10
						local x1 = 90
						local y1 = 0
						local m = y2/(x2-x1)
						coefficientSailAngle = m * (math.abs(sailAngle)-90)
					elseif deltaAngle < -10 then
						local y2 = 0.44
						local x2 = requiredSailAngle - 10
						if x2 <= 0 then x2 = 0.01 end
						local m = y2/x2
						coefficientSailAngle = m * math.abs(sailAngle)
					else
						coefficientSailAngle = -0.005 * deltaAngle^2 + 1
					end
					if coefficientSailAngle > 0 then
						windForceByDirection = coefficientSailAngle * windForceByDirection
					else
						windForceByDirection = 0
					end
				else
					windForceByDirection = 0
					requiredSailAngle = "Another direction"
				end
					
				AUD.insp("Boat", " ", " ")
				AUD.insp("Boat", "windOnBoat:", windOnBoat)
				AUD.insp("Boat", " ", " ")
				AUD.insp("Boat", "SailAngle:", sailAngle)
				AUD.insp("Boat", "RequiredSailAngle (absolute value):", requiredSailAngle)
				AUD.insp("Boat", " ", " ")
				AUD.insp("Boat", "coefficientSailAngle:", coefficientSailAngle)
				AUD.insp("Boat", "windForceByDirection:", windForceByDirection)
				AUD.insp("Boat", " ", " ")
				
				boat:getAttachmentWorldPos("checkFront", frontVector)
				
				local savedWindForce = boat:getModData()["windForceByDirection"]
				if savedWindForce == nil then
					savedWindForce = 0
				end
				if savedWindForce < windForceByDirection then
					savedWindForce = (savedWindForce + 0.1)
				elseif savedWindForce > windForceByDirection then
					savedWindForce = (savedWindForce - 0.02)
				else
					savedWindForce = windForceByDirection
				end
				boat:getModData()["windForceByDirection"] = savedWindForce
				AUD.insp("Boat", "savedWindForce:", savedWindForce)
				local squareFrontVehicle = getCell():getGridSquare(frontVector:x(), frontVector:y(), 0)
				if squareFrontVehicle ~= nil and WaterNWindPhysics.isWater(squareFrontVehicle) then
					if savedWindForce > 0 and boatSpeed < (savedWindForce * 1.60934) and boatSpeed/1.60934 < savedWindForce and not isKeyDown(Keyboard.KEY_S) then
						local startCoeff = 1
						if boatSpeed < 2 then
							startCoeff = 5
						end
						
						if collisionWithGround then 
							boatDirVector:mul(250 * savedWindForce)
						else
							boatDirVector:mul(450 * savedWindForce * startCoeff)
						end
						boat:setPhysicsActive(true)
						tempVec2:set(0, 0, 0)
						boat:addImpulse(boatDirVector, tempVec2)   
					end
					-- AUD.insp("Boat", "forceVectorX:", boatDirVector:x())
					-- AUD.insp("Boat", "forceVectorZ:", boatDirVector:y())
					-- AUD.insp("Boat", "forceVectorY:", boatDirVector:z())
				end
				if boat:getDriver() then
					if isKeyDown(Keyboard.KEY_A) then
						boat:update()
						forceVector = boat:getWorldPos(-1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
						forceVector:mul(10)
						forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
						
						boat:getWorldPos(0, 0, -3, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
						tempVec2:set(tempVec2:x(), tempVec2:z(), tempVec2:y())
						boat:addImpulse(forceVector, tempVec2)   
					elseif isKeyDown(Keyboard.KEY_D) then
						boat:update()
						forceVector = boat:getWorldPos(1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
						forceVector:mul(10)
						forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
						
						boat:getWorldPos(0, 0, -3, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
						tempVec2:set(tempVec2:x(), tempVec2:z(), tempVec2:y())
						boat:addImpulse(forceVector, tempVec2)
					end
					if isKeyDown(Keyboard.KEY_LEFT) then
						if sailAngle < 90 then
							sailAngle = sailAngle + 0.5
						end
						boat:getModData()["sailAngle"] = sailAngle
					elseif isKeyDown(Keyboard.KEY_RIGHT) then
						if sailAngle > -90 then
							sailAngle = sailAngle - 0.5
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
		if boat ~= nil and  AquaConfig.isBoat(boat) then
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