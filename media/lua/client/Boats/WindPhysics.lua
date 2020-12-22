if WindPhysics == nil then WindPhysics = {} end

local vec1 = Vector3f.new()
local vec2 = Vector3f.new()

function WindPhysics.getWindDirection()
    return ClimateManager.getWindAngleString(getClimateManager():getWindAngleDegrees())
end

function WindPhysics.getWindSpeed()
    return getClimateManager():getWindIntensity()*getClimateManager():getMaxWindspeedKph()
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
            
            print(WindPhysics.getWindDirection())

            local angle = math.rad(math.fmod(getClimateManager():getWindAngleDegrees(), 360))
            local x = math.cos(angle)
            local y = math.sin(angle)

            local forceVector = vec1:set(x, y, 0)
            forceVector:mul(335 * WindPhysics.getWindSpeed() * AquaBoats[vehicle:getScript():getName()].windInfluence * startCoeff)
            forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())

            vehicle:setPhysicsActive(true)
            vec2:set(0, 0, 0)
            vehicle:addImpulse(forceVector, vec2)            
        end
    end	
end


Events.OnTick.Add(WindPhysics.updateVehicles)