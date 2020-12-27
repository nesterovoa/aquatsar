AquaTsarConfig = {}
AquaBoats = {}

AquaBoats["BoatZeroPatient"] = {}
local boat = AquaBoats["BoatZeroPatient"]
boat.dashboard = nil
boat.trailerAfterLaunchOnWater = "TrailerForBoat"
boat.trailerAfterBoatLoaded = "TrailerWithBoatSailingYacht"
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 1.25
boat.windInfluence = 1.1
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 1,
	["FrontRight"] = 1,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 1,
	["RearLeft"] = -4,
	["RearRight"] = 1,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 10,
	["FrontRight"] = 10,
	["MiddleLeft"] = -75, 
	["MiddleRight"] = -55,
	["RearLeft"] = -30,
	["RearRight"] = 10,
}

-- BoatSailingYacht --
AquaBoats["BoatSailingYacht"] = {}
boat = AquaBoats["BoatSailingYacht"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.driverBehind = true
boat.sails = false
boat.setLeftSailsScript = "BoatSailingYachtWithSailsLeft"
boat.setRightSailsScript = "BoatSailingYachtWithSailsRight"
boat.trailerAfterLaunchOnWater = "TrailerForBoat"
boat.trailerAfterBoatLoaded = "TrailerWithBoatSailingYacht"
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 1.25
boat.windInfluence = 1.1
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 1,
	["FrontRight"] = 1,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 1,
	["RearLeft"] = -4,
	["RearRight"] = 1,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 10,
	["FrontRight"] = 10,
	["MiddleLeft"] = -75, 
	["MiddleRight"] = -55,
	["RearLeft"] = -30,
	["RearRight"] = 10,
}
--AquaBoats["BoatZeroPatient"].dashboard = nil
-- BoatSailingYachtWithSailsLeft --
AquaBoats["BoatSailingYachtWithSailsLeft"] = {}
boat = AquaBoats["BoatSailingYachtWithSailsLeft"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.driverBehind = true
boat.sails = true
boat.removeSailsScript = "BoatSailingYacht"
boat.sailsSide = "Left"
boat.setRightSailsScript = "BoatSailingYachtWithSailsRight"
boat.sailsMaxAngle = 90
boat.sailsMinAngle = 0
boat.trailerAfterLaunchOnWater = "TrailerForBoat"
boat.trailerAfterBoatLoaded = "TrailerWithBoatSailingYacht"
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 1.25
boat.windInfluence = 1.1
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 1,
	["FrontRight"] = 1,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 1,
	["RearLeft"] = -4,
	["RearRight"] = 1,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 10,
	["FrontRight"] = 10,
	["MiddleLeft"] = -75, 
	["MiddleRight"] = -55,
	["RearLeft"] = -30,
	["RearRight"] = 10,
}

-- BoatSailingYachtWithSailsRight --
AquaBoats["BoatSailingYachtWithSailsRight"] = {}
boat = AquaBoats["BoatSailingYachtWithSailsRight"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.driverBehind = true
boat.sails = true
boat.removeSailsScript = "BoatSailingYacht"
boat.sailsSide = "Right"
boat.setLeftSailsScript = "BoatSailingYachtWithSailsLeft"
boat.sailMaxAngle = 0
boat.sailMinAngle = -90
boat.trailerAfterLaunchOnWater = "TrailerForBoat"
boat.trailerAfterBoatLoaded = "TrailerWithBoatSailingYacht"
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 1.25
boat.windInfluence = 1.1
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 1,
	["FrontRight"] = 1,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 1,
	["RearLeft"] = -4,
	["RearRight"] = 1,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 10,
	["FrontRight"] = 10,
	["MiddleLeft"] = -75, 
	["MiddleRight"] = -55,
	["RearLeft"] = -30,
	["RearRight"] = 10,
}


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
    return AquaBoats[vehicle:getScript():getName()]
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



