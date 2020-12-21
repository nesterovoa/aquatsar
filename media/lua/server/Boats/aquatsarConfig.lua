AquaTsarConfig = {}
AquaBoats = {}

-- BoatSailingYacht --
AquaBoats["BoatSailingYacht"] = {}
local boat = AquaBoats["BoatSailingYacht"]

boat.trailerAfterLaunchOnWater = "TrailerForBoat"
boat.trailerAfterBoatLoaded = "TrailerWithBoatSailingYacht"
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 1.25
boat.windInfluence = 0.1

-- BoatSailingYachtWithSails --
AquaBoats["BoatSailingYachtWithSails"] = {}
local boat = AquaBoats["BoatSailingYachtWithSails"]

boat.trailerAfterLaunchOnWater = "TrailerForBoat"
boat.trailerAfterBoatLoaded = "TrailerWithBoatSailingYacht"
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 1.25
boat.windInfluence = 1.0

-- Functions --
function AquaTsarConfig.isEmptyTrailerForBoat(vehicle)
    for key, value in pairs(AquaBoats) do
        if value.trailerAfterLaunchOnWater == vehicle:getScript():getName() then
            return true
        end
    end
    return false
end

function AquaTsarConfig.isTrailerWithBoat(vehicle)
    for key, value in pairs(AquaBoats) do
        if value.trailerAfterBoatLoaded == vehicle:getScript():getName() then
            return true
        end
    end
    return false    
end

function AquaTsarConfig.isBoat(vehicle)
    return AquaBoats[vehicle:getScript():getName()] ~= nil
end

function AquaTsarConfig.getTrailerNameAfterLaunchBoat(vehicle)
    for key, value in pairs(AquaBoats) do
        if value.trailerAfterBoatLoaded == vehicle:getScript():getName() then
            return value.trailerAfterLaunchOnWater
        end
    end   
end

function AquaTsarConfig.getBoatNameAfterLaunchBoat(vehicle)
    for key, value in pairs(AquaBoats) do
        if value.trailerAfterBoatLoaded == vehicle:getScript():getName() then
            return key
        end
    end   
end



