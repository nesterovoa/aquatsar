



 

local function windTest()
    local clim = getClimateManager()
    --print(clim:getClimateFloat(6):getAdminValue()*clim:getMaxWindspeedKph())
    --print(clim:getWindAngleIntensity())
    --print(clim:getCorrectedWindAngleIntensity())
    
    --print(clim:getWindAngleDegrees())
    print(ClimateManager.getWindAngleString(clim:getWindAngleDegrees()))
    
    print(clim:getWindIntensity()*clim:getMaxWindspeedKph(), " Kph")


    --local val = ClimateManager.getWindAngleString(1)
    --print(val)
end


Events.OnTick.Add(windTest)

