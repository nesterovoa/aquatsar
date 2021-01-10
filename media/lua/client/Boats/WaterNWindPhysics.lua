--*************************************************************
--**                    Developer: IBrRus                    **
--*************************************************************

if AquaPhysics == nil then AquaPhysics = {} end
AquaPhysics.Utils = {}
AquaPhysics.Wind = {}
AquaPhysics.Water = {}


-----------------------------
-- Util variables/functions
-----------------------------

local tempVec1 = Vector3f.new()
local tempVec2 = Vector3f.new()
local tempIsoObj = IsoObject.new()
local tempSquare = IsoGridSquare.new(getCell(), nil, 0, 0, 0)

local frontVector = Vector3f.new()
local rearVector = Vector3f.new()
local collisionPosVector2 = Vector3.fromLengthDirection(1, 1)
local boatDirVector = Vector3f.new()


local function isWater(square)
	return square ~= nil and square:Is(IsoFlagType.water)
end

function AquaPhysics.Wind.getWindSpeed()
    return getClimateManager():getWindspeedKph()
end

-- function AquaPhysics.Wind.fromWindDirection()	
	-- local angle = getClimateManager():getWindAngleDegrees()	
	-- local windAngles = { 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, 382.5 }	
	-- local windAngleStr = { "N", "NW", "W", "SW", "S", "SE", "E", "NE", "N" }	
    -- for b = 1, #windAngles do	
		-- if (angle < windAngles[b]) then	
			-- return windAngleStr[b]	
		-- end	
	-- end	
    -- return windAngleStr[#windAngleStr - 1];	
-- end

function AquaPhysics.Wind.inWindDirection()
	local angle = getClimateManager():getWindAngleDegrees()
	local windAngles = { 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, 382.5 }
	local windAngleStr = { "S", "SE", "E", "NE", "N", "NW", "W", "SW", "S" }
    for b = 1, #windAngles do
		if (angle < windAngles[b]) then
			return windAngleStr[b]
		end
	end
    return windAngleStr[#windAngleStr - 1];
end

-------------------------------------
-- Water Physics
-------------------------------------

function AquaPhysics.Water.getCollisionSquaresAround(dx, dy, square)
    local squares = {}
	if square == nil then return squares end

	for y=square:getY() - dy, square:getY() + dy do
		for x=square:getX() - dx, square:getX() + dx do
            local square2 = getCell():getGridSquare(x, y, 0)
			if square2 ~= nil and not isWater(square2) then
				table.insert(squares, square2)
			end
		end
	end
	return squares
end

function AquaPhysics.Water.Borders(boat)
	local boatSquare = boat:getSquare()
	if boatSquare ~= nil and isWater(boatSquare) then
		local notWaterSquares = AquaPhysics.Water.getCollisionSquaresAround(5, 5, boatSquare)
		local collisionWithGround = false
		for _, square in ipairs(notWaterSquares) do
			tempSquare:setX(square:getX())
			tempSquare:setY(square:getY())
			tempSquare:setZ(0.8)
			tempIsoObj:setSquare(tempSquare)
			local collisionVector = boat:testCollisionWithObject(tempIsoObj, 0.5, collisionPosVector2)
			if collisionVector then
				boat:ApplyImpulse4Break(tempIsoObj, 0.2)
				boat:ApplyImpulse(tempIsoObj, 80)
				boat:update()
				collisionWithGround = true
			end
		end
		return collisionWithGround
	end
end

-------------------------------------
-- Wind Physics
-------------------------------------



function AquaPhysics.Wind.windImpulse(boat, collisionWithGround)
	local boatScriptName = boat:getScript():getName()
	local boatSpeed = boat:getCurrentSpeedKmHour()
	boat:getAttachmentWorldPos("trailerfront", frontVector)
	boat:getAttachmentWorldPos("trailer", rearVector)
	local x = frontVector:x() - rearVector:x()
	local y = frontVector:y() - rearVector:y()
	local windSpeed = AquaPhysics.Wind.getWindSpeed()

	-- AUD.insp("Boat", "boatSpeed (MPH):", boat:getCurrentSpeedKmHour() / 1.60934)
	-- AUD.insp("Boat", " ", " ")
	boatDirVector:set(x, 0, y):normalize()
	-- boat:getWorldPos(0, 0, 1, boatDirVector):add(-boat:getX(), -boat:getY(), -boat:getZ())
	-- boatDirVector:set(boatDirVector:x(), 0, boatDirVector:y())
	-- boatDirVector:normalize()
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
	if windSpeed < AquaConfig.windVeryLight then
		windForceByDirection = 0
	elseif windSpeed < AquaConfig.windLight then
		if windOnBoat > 105 and windOnBoat < 285 then
			windForceByDirection = 7 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
		end
	elseif windSpeed < AquaConfig.windMedium then
		if windOnBoat > 25 and windOnBoat < 335 then
			windForceByDirection = 10 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
		end
	elseif windSpeed < AquaConfig.windStrong then
		if windOnBoat > 25 and windOnBoat < 335 then
			windForceByDirection = 12 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
		end
	elseif windSpeed < AquaConfig.windVeryStrong then
		if windOnBoat > 105 and windOnBoat < 285 then
			windForceByDirection = 14 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
		end
	else
		if windOnBoat > 105 and windOnBoat < 285 then
			windForceByDirection = 16 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaConfig.Boats[boatScriptName].windInfluence
		end
		print("SAIL DAMAGE!")
	end
	AUD.insp("Boat", "windSpeed (MPH):", windSpeed / 1.60934)
	AUD.insp("Boat", "windForceByDirection154:", windForceByDirection)
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
	
	-- AUD.insp("Boat", "Name: ", boatScriptName)
	-- AUD.insp("Boat", "Boat Speed: ", boatSpeed)
	-- AUD.insp("Boat", "Mass: ", boat:getMass())
	-- AUD.insp("Boat", " ", " ")		
	
	AUD.insp("Boat", "windOnBoat:", windOnBoat)
	-- AUD.insp("Boat", "SailAngle:", sailAngle)
	-- AUD.insp("Boat", "RequiredSailAngle (absolute value):", requiredSailAngle)
	-- AUD.insp("Boat", "coefficientSailAngle:", coefficientSailAngle)
	AUD.insp("Boat", "windForceByDirection:", windForceByDirection)
	
	boat:getAttachmentWorldPos("checkFront", frontVector)
	
	local savedWindForce = boat:getModData()["windForceByDirection"]
	if savedWindForce == nil then
		savedWindForce = 0
	end
	
	if isKeyDown(getCore():getKey("Backward")) then
		savedWindForce = 0
	elseif collisionWithGround then
		savedWindForce = 0
	elseif savedWindForce < windForceByDirection then
		savedWindForce = (savedWindForce + 0.05)
	elseif savedWindForce >= windForceByDirection then
		savedWindForce = (savedWindForce - 0.02)
	end
	
	boat:getModData()["windForceByDirection"] = savedWindForce
	AUD.insp("Boat", "savedWindForce:", savedWindForce)

	local squareFrontVehicle = getCell():getGridSquare(frontVector:x(), frontVector:y(), 0)
	if squareFrontVehicle ~= nil and isWater(squareFrontVehicle) then
		if savedWindForce > 0 and boatSpeed < (savedWindForce * 1.60934) and boatSpeed/1.60934 < savedWindForce and not isKeyDown(getCore():getKey("Backward")) then
			local startCoeff = 1
			if boatSpeed < 2 * 1.60934 then
				startCoeff = 5
			end
			if collisionWithGround then 
				boatDirVector:mul(150 * savedWindForce)
			else
				boatDirVector:mul(550 * savedWindForce * startCoeff)
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
		if isKeyDown(getCore():getKey("Left")) then
			boat:update()
			forceVector = boat:getWorldPos(-1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
			forceVector:mul(10)
			forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
			
			boat:getWorldPos(0, 0, -3, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
			tempVec2:set(tempVec2:x(), tempVec2:z(), tempVec2:y())
			boat:addImpulse(forceVector, tempVec2)   
		elseif isKeyDown(getCore():getKey("Right")) then
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




-------------------------------------
-- Physics
-------------------------------------

function AquaPhysics.boatEngineShutDownOnGround()
	local veh = getPlayer():getVehicle()
	if veh and AquaConfig.isBoat(veh) then
		local sq = veh:getSquare()
		if sq and not isWater(sq) and veh:isEngineRunning() then
			veh:engineDoShutingDown()
		end
	end
end

function AquaPhysics.stopVehicleMove(vehicle, force)   	
	local speed = vehicle:getCurrentSpeedKmHour()
	local lenHalf = vehicle:getScript():getPhysicsChassisShape():z()/2

	local forceVector = vehicle:getWorldPos(0, 10, 1, tempVec1):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
	forceVector:mul(math.abs(speed)*300)
	forceVector:set(forceVector:x(), 0, forceVector:y())
	local pushPoint = vehicle:getWorldPos(0, 0, -lenHalf, tempVec2):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
	pushPoint:set(pushPoint:x(), 0, pushPoint:y())
	
	vehicle:addImpulse(forceVector, pushPoint)
	vehicle:update() 
end

function AquaPhysics.inertiaFix(boat)	
	if boat:getSquare() ~= nil and isWater(boat:getSquare()) then
		local speed = math.abs(boat:getCurrentSpeedKmHour())
		if speed < 1 then
			boat:setMass(100)
		elseif speed < 10 then
			boat:setMass(100*speed)
		else
			if boat:getMass() ~= 1000 then 
				boat:setMass(1000)
			end
		end
	end
end

function AquaPhysics.reverseSpeedFix(boat, limit)
	if boat:getSquare() ~= nil and isWater(boat:getSquare()) then
		local speed = boat:getCurrentSpeedKmHour()
		if isKeyDown(getCore():getKey("Backward")) then
			if speed < -limit then
				AquaPhysics.stopVehicleMove(boat, 3000)
			end
		end
	end
end

function AquaPhysics.heightFix(boat)
	local squareUnderVehicle = getCell():getGridSquare(boat:getX(), boat:getY(), 0)
	if squareUnderVehicle ~= nil and isWater(squareUnderVehicle) then
		if boat:getDebugZ() < -0.2 then 
			boat:setPhysicsActive(true)
			tempVec1:set(0, 5000, 0)
			tempVec2:set(0, 0, 0)
			boat:addImpulse(tempVec1, tempVec2)
			boat:update()
		end
	elseif boat:getDebugZ() < 0 then
		boat:setZ(0 - boat:getDebugZ())
	end
end

function AquaPhysics.waterFlowRotation(boat)
	if boat:getDriver() then
		local lenHalf = boat:getScript():getPhysicsChassisShape():z()/2
		local force = 180
		if isKeyDown(getCore():getKey("Right")) then
			boat:setPhysicsActive(true)
			

			local forceVector = boat:getWorldPos(-1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
			local pushPoint = boat:getWorldPos(0, 0, lenHalf, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
			pushPoint:set(pushPoint:x(), 0, pushPoint:y())
			
			forceVector:mul(force)
			forceVector:set(forceVector:x(), 0, forceVector:y())
			boat:addImpulse(forceVector, pushPoint)
			boat:update()

			local forceVector = boat:getWorldPos(1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
			local pushPoint = boat:getWorldPos(0, 0, -lenHalf, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
			pushPoint:set(pushPoint:x(), 0, pushPoint:y())
			
			forceVector:mul(force)
			forceVector:set(forceVector:x(), 0, forceVector:y())
			boat:addImpulse(forceVector, pushPoint)
			boat:update()

		elseif isKeyDown(getCore():getKey("Left")) then
			boat:setPhysicsActive(true)

			local forceVector = boat:getWorldPos(1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
			local pushPoint = boat:getWorldPos(0, 0, lenHalf, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
			pushPoint:set(pushPoint:x(), 0, pushPoint:y())
			
			forceVector:mul(force)
			forceVector:set(forceVector:x(), 0, forceVector:y())
			boat:addImpulse(forceVector, pushPoint)
			boat:update()

			local forceVector = boat:getWorldPos(-1, 0, 0, tempVec1):add(-boat:getX(), -boat:getY(), -boat:getZ())
			local pushPoint = boat:getWorldPos(0, 0, -lenHalf, tempVec2):add(-boat:getX(), -boat:getY(), -boat:getZ())
			pushPoint:set(pushPoint:x(), 0, pushPoint:y())
			
			forceVector:mul(force)
			forceVector:set(forceVector:x(), 0, forceVector:y())
			boat:addImpulse(forceVector, pushPoint)
			boat:update()
		end
	end
end
-----------------------------

function AquaPhysics.updateVehicles()
	local vehicles = getCell():getVehicles()
    for i=0, vehicles:size()-1 do
        local boat = vehicles:get(i)
		if boat ~= nil and AquaConfig.isBoat(boat) then
			local collisionWithGround = AquaPhysics.Water.Borders(boat)
			
			AquaPhysics.heightFix(boat)
			-- AquaPhysics.inertiaFix(boat)

			if AquaConfig.Boats[boat:getScript():getName()].limitReverseSpeed ~= nil then
				AquaPhysics.reverseSpeedFix(boat, AquaConfig.Boats[boat:getScript():getName()].limitReverseSpeed)
			end

			if AquaConfig.Boats[boat:getScript():getName()].sails then
				-- print(collisionWithGround)
				AquaPhysics.Wind.windImpulse(boat, collisionWithGround)
			end

			if math.abs(boat:getCurrentSpeedKmHour()) < 4 then
				AquaPhysics.waterFlowRotation(boat)
			end
        end
    end
	AquaPhysics.boatEngineShutDownOnGround()
end

Events.OnTick.Add(AquaPhysics.updateVehicles)