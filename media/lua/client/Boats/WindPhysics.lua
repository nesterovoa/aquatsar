if WindPhysics == nil then WindPhysics = {} end

local vec1 = Vector3f.new()
local vec2 = Vector3f.new()

function WindPhysics.getWindDirection()
    return ClimateManager.getWindAngleString(getClimateManager():getWindAngleDegrees())
end

function WindPhysics.getWindSpeed()
    return getClimateManager():getWindIntensity()*getClimateManager():getMaxWindspeedKph()
end

local function getWindXY()
    local dir = WindPhysics.getWindDirection()
    local x = 0
    local y = 0

    if string.find(dir, "S") then
		if string.find(dir, "E") then
			x = 1
			y = 0
		elseif string.find(dir, "W") then
			x = 0
			y = 1
		else
			x = 1
			y = 1
		end
    elseif string.find(dir, "N") then
		if string.find(dir, "E") then
			x = 0
			y = -1
		elseif string.find(dir, "W") then
			x = -1
			y = 0
		else
			x = -1
			y = -1
		end
    elseif string.find(dir, "E") then
		x = 1
		y = -1
	elseif string.find(dir, "W") then
		x = -1
		y = 1
	end
    -- print(dir)
    -- print(WindPhysics.getWindSpeed())

    return x, y
end

function WindPhysics.updateVehicles()
    local vehicles = getCell():getVehicles()
    for i=0, vehicles:size()-1 do
        local vehicle = vehicles:get(i)
        if vehicle ~= nil and AquaTsarConfig.isBoat(vehicle) then
            local speed = vehicle:getLinearVelocity(vec1):length()
            local startCoeff = 1
            if speed < 5 then
                startCoeff = 5
            end
            
            local x, y = getWindXY()
            local forceVector = vec1:set(x, y, 0)
            forceVector:normalize()
            forceVector:mul(135 * WindPhysics.getWindSpeed() * AquaBoats[vehicle:getScript():getName()].windInfluence * startCoeff)
            forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())

            vehicle:setPhysicsActive(true)
            vec2:set(0, 0, 0)
            vehicle:addImpulse(forceVector, vec2)            
        end
    end	
end


--Events.OnTick.Add(WindPhysics.updateVehicles)