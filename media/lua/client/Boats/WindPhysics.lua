if WindPhysics == nil then WindPhysics = {} end

local vec1 = Vector3f.new()
local vec2 = Vector3f.new()

local windForce = Vector3f.new()
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
        local vehicle = vehicles:get(i)
        if vehicle ~= nil and AquaTsarConfig.isBoat(vehicle) then
            local speed = vehicle:getLinearVelocity(vec1):length()
            local startCoeff = 1
            if speed < 5 then
                startCoeff = 5
            end
            
            

            local angle = math.rad(math.fmod(getClimateManager():getWindAngleDegrees(), 360))
            local x = math.cos(angle)
            local y = math.sin(angle)
            windForce:set(x, y, 0)

            print("Direction ", WindPhysics.getWindDirection())
            print("Wind angle ", math.fmod(getClimateManager():getWindAngleDegrees(), 360))
            print("Wind force ", windForce)

            local sailAngle = vehicle:getModData()["sailAngle"]
            if sailAngle == nil then
                sailAngle = 0
            end

            

            x = math.cos(math.rad(sailAngle))
            y = math.sin(math.rad(sailAngle))

            sailVector:set(x, y, 0)
            vehicle:getWorldPos(x, 0, y, sailVector):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())


            print("Sail angle ", sailAngle)
            print("Sail vector ", sailVector)


            -- вот тут взять относительные координаты паруса!


            -- проекция

            local value = windForce:x() * sailVector:x() + windForce:y()*sailVector:y()

            print("Value ", value)

            print(math.abs(335 * WindPhysics.getWindSpeed() * value * AquaBoats[vehicle:getScript():getName()].windInfluence * startCoeff))

            local forceVector = vehicle:getWorldPos(0, 0, 1, vec1):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
            forceVector:mul(math.abs(335 * WindPhysics.getWindSpeed() * value * AquaBoats[vehicle:getScript():getName()].windInfluence * startCoeff))
            forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())

            vehicle:setPhysicsActive(true)
            vec2:set(0, 0, 0)
            vehicle:addImpulse(forceVector, vec2)   
            
            if vehicle:getDriver() then
                if isKeyDown(Keyboard.KEY_A) then
                    vehicle:update()
                        forceVector = vehicle:getWorldPos(1, 0, 0, vec1):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
                        forceVector:mul(600 * WindPhysics.getWindSpeed() * value * AquaBoats[vehicle:getScript():getName()].windInfluence * startCoeff)
                        forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
                        
                        vehicle:getWorldPos(0, 0, -3, vec2):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
                        vec2:set(vec2:x(), vec2:z(), vec2:y())
                        vehicle:addImpulse(forceVector, vec2)   
                        print("Force ", forceVector)
                        print(vec2)
                elseif isKeyDown(Keyboard.KEY_D) then
                    vehicle:update()
                    forceVector = vehicle:getWorldPos(-1, 0, 0, vec1):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
                    forceVector:mul(600 * WindPhysics.getWindSpeed() * value * AquaBoats[vehicle:getScript():getName()].windInfluence * startCoeff)
                    forceVector:set(forceVector:x(), forceVector:z(), forceVector:y())
                    
                    vehicle:getWorldPos(0, 0, -3, vec2):add(-vehicle:getX(), -vehicle:getY(), -vehicle:getZ())
                    vec2:set(vec2:x(), vec2:z(), vec2:y())
                    vehicle:addImpulse(forceVector, vec2)  
                elseif isKeyDown(Keyboard.KEY_LEFT) then
                    if sailAngle < 180 then
                        sailAngle = sailAngle + 1
                    end
                    vehicle:getModData()["sailAngle"] = sailAngle
                elseif isKeyDown(Keyboard.KEY_RIGHT) then
                    if sailAngle > 0 then
                        sailAngle = sailAngle - 1
                    end
                    vehicle:getModData()["sailAngle"] = sailAngle
                end
            end
        end
    end	
end

Events.OnTick.Add(WindPhysics.updateVehicles)