require("_DebugUIs/AIDebug/DebugValuesInspector")

if WindPhysics == nil then WindPhysics = {} end

local tempVec1 = Vector3f.new()
local tempVec2 = Vector3f.new()

local windForceByDirection = Vector3f.new()
local sailVector = Vector3f.new()


function WindPhysics.getWindDirection()
    return ClimateManager.getWindAngleString(getClimateManager():getWindAngleDegrees())
end

function WindPhysics.getWindSpeed()
    return getClimateManager():getWindIntensity()*getClimateManager():getMaxWindspeedKph()
end

function WindPhysics.updateVehicles()
    local vehicles = getCell():getVehicles()
    for i=0, vehicles:size()-1 do
        local boat = vehicles:get(i)
        if boat ~= nil and AquaTsarConfig.isBoat(boat) and AquaTsarConfig.isBoat(boat).sails then
            local boatSpeed = boat:getCurrentSpeedKmHour()
			local windSpeed = WindPhysics.getWindSpeed()
			
			AIDebug.setInsp("Boat", "windSpeed (MPH):", windSpeed / 1.60934)
			AIDebug.setInsp("Boat", "boatSpeed (MPH):", boat:getCurrentSpeedKmHour() / 1.60934)
			AIDebug.setInsp("Boat", " ", " ")
			
			local frontVector = Vector3f.new()
			local rearVector = Vector3f.new()
			boat:getAttachmentWorldPos("trailerfront", frontVector)
			boat:getAttachmentWorldPos("trailer", rearVector)
			local x = frontVector:x() - rearVector:x()
			local y = frontVector:y() - rearVector:y()
			
			local boatDirVector = Vector3f.new(x, y, 0):normalize()
			local boatDirection = math.atan2(x,y) * 57.2958 + 180

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
					windForceByDirection = 7 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boat:getScript():getName()].windInfluence
				end
			elseif windSpeed < 23 * 1.60934 then
				if windOnBoat > 25 and windOnBoat < 335 then
					windForceByDirection = 10 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boat:getScript():getName()].windInfluence
				end
			elseif windSpeed < 31 * 1.60934 then
				if windOnBoat > 25 and windOnBoat < 335 then
					windForceByDirection = 13 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boat:getScript():getName()].windInfluence
				end
			elseif windSpeed < 61 then
				if windOnBoat > 105 and windOnBoat < 285 then
					windForceByDirection = 10 * math.sqrt(1 * math.cos(math.rad(2*(windOnBoat + 90))) + 1.3) * AquaBoats[boat:getScript():getName()].windInfluence
				end
			else
				-- TODO WARNING!!!
			end
				
			AIDebug.setInsp("Boat", " ", " ")
			AIDebug.setInsp("Boat", "windOnBoat:", windOnBoat)
			AIDebug.setInsp("Boat", "windForceByDirection:", windForceByDirection)
			AIDebug.setInsp("Boat", " ", " ")
            
			local sailAngle = boat:getModData()["sailAngle"]
            if sailAngle == nil then
                sailAngle = 0
				boat:getModData()["sailAngle"] = 0
            end
			if boatSpeed < (windForceByDirection * 1.60934) and boatSpeed < windSpeed then
				local startCoeff = 1
				if boatSpeed < 2 then
					startCoeff = 5
				end
				boatDirVector:set(boatDirVector:x(), 0, boatDirVector:y())
				boatDirVector:mul(300 * windForceByDirection * startCoeff)
				boat:setPhysicsActive(true)
				tempVec2:set(0, 0, 0)
				boat:addImpulse(boatDirVector, tempVec2)   
			end
            AIDebug.setInsp("Boat", "forceVectorX:", boatDirVector:x())
			AIDebug.setInsp("Boat", "forceVectorZ:", boatDirVector:y())
			AIDebug.setInsp("Boat", "forceVectorY:", boatDirVector:z())

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

--Events.OnTick.Add(WindPhysics.updateVehicles)