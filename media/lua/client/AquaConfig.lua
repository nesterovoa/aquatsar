AquaConfig = {}
AquaConfig.Boats = {}
AquaConfig.Trailers = {}

---------------
-- Utils
---------------

AquaConfig.windVeryLight = 7 * 1.60934
AquaConfig.windLight = 12 * 1.60934
AquaConfig.windMedium = 23 * 1.60934
AquaConfig.windStrong = 31 * 1.60934
AquaConfig.windVeryStrong = 55 * 1.60934


function AquaConfig.isBoat(boat)
	if not boat then return false end
    return AquaConfig.Boats[boat:getScript():getName()] ~= nil
end

function AquaConfig.Boat(boat)
	if not boat then return false end
    return AquaConfig.Boats[boat:getScript():getName()]
end

--------------
-- Boats
--------------

-- BoatMotor --
AquaConfig.Boats["BoatMotor"] = {}
boat = AquaConfig.Boats["BoatMotor"]
boat.manualStarter = false
boat.dashboard = "ISBoatDashboard"
boat.driverBehind = false
boat.sails = false
boat.boatSeatUI_Image = "BoatMotorYacht_seat"
boat.boatSeatUI_Scale = 1
boat.windInfluence = 1.1
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 0,
	["FrontRight"] = 0,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 0,
	["RearLeft"] = 0,
	["RearRight"] = 0,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 0,
	["FrontRight"] = 0,
	["MiddleLeft"] = 0, 
	["MiddleRight"] = 0,
	["RearLeft"] = 0,
	["RearRight"] = 0,
}

-- BoatSailingYacht --
AquaConfig.Boats["BoatSailingYacht"] = {}
boat = AquaConfig.Boats["BoatSailingYacht"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.manualStarter = true
boat.driverBehind = true
boat.sails = false
boat.limitReverseSpeed = 6
boat.setLeftSailsScript = "BoatSailingYachtWithSailsLeft"
boat.setRightSailsScript = "BoatSailingYachtWithSailsRight"
boat.windInfluence = 1.1
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 0.75
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 0,
	["FrontRight"] = 0,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 0,
	["RearLeft"] = 0,
	["RearRight"] = 0,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 120,
	["FrontRight"] = 120,
	["MiddleLeft"] = -30, 
	["MiddleRight"] = -50,
	["RearLeft"] = -40,
	["RearRight"] = 50,
}

-- BoatSailingYachtWithSailsLeft --
AquaConfig.Boats["BoatSailingYachtWithSailsLeft"] = {}
boat = AquaConfig.Boats["BoatSailingYachtWithSailsLeft"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.manualStarter = true
boat.driverBehind = true
boat.sails = true
boat.limitReverseSpeed = 6
boat.removeSailsScript = "BoatSailingYacht"
boat.sailsSide = "Left"
boat.setRightSailsScript = "BoatSailingYachtWithSailsRight"
boat.sailsMaxAngle = 90
boat.sailsMinAngle = 0
boat.windInfluence = 1.1
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 0.75
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 0,
	["FrontRight"] = 0,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 0,
	["RearLeft"] = 0,
	["RearRight"] = 0,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 120,
	["FrontRight"] = 120,
	["MiddleLeft"] = -30, 
	["MiddleRight"] = -50,
	["RearLeft"] = -40,
	["RearRight"] = 50,
}

-- BoatSailingYachtWithSailsRight --
AquaConfig.Boats["BoatSailingYachtWithSailsRight"] = {}
boat = AquaConfig.Boats["BoatSailingYachtWithSailsRight"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.manualStarter = true
boat.driverBehind = true
boat.sails = true
boat.limitReverseSpeed = 6
boat.removeSailsScript = "BoatSailingYacht"
boat.sailsSide = "Right"
boat.setLeftSailsScript = "BoatSailingYachtWithSailsLeft"
boat.sailMaxAngle = 0
boat.sailMinAngle = -90
boat.windInfluence = 1.1
boat.boatSeatUI_Image = "BoatSailingYacht_seat"
boat.boatSeatUI_Scale = 0.75
boat.boatSeatUI_SeatOffsetX = {
	["FrontLeft"] = 0,
	["FrontRight"] = 0,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 0,
	["RearLeft"] = 0,
	["RearRight"] = 0,
}
boat.boatSeatUI_SeatOffsetY = {
	["FrontLeft"] = 120,
	["FrontRight"] = 120,
	["MiddleLeft"] = -30, 
	["MiddleRight"] = -50,
	["RearLeft"] = -40,
	["RearRight"] = 50,
}

--[[
AquaConfig.Boats["BoatZeroPatient"] = {}
local boat = AquaConfig.Boats["BoatZeroPatient"]
boat.dashboard = nil
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
]]

-----------------
-- Trailers
-----------------

AquaConfig.Trailers["TrailerForBoat"] = {}
local trailer = AquaConfig.Trailers["TrailerForBoat"]
trailer.isWithBoat = false
trailer.trailerWithBoatTable = {}
trailer.trailerWithBoatTable["BoatSailingYacht"] = "TrailerWithBoatSailingYacht"
trailer.trailerWithBoatTable["BoatSailingYachtWithSailsLeft"] = "TrailerWithBoatSailingYacht"
trailer.trailerWithBoatTable["BoatSailingYachtWithSailsRight"] = "TrailerWithBoatSailingYacht"

AquaConfig.Trailers["TrailerWithBoatSailingYacht"] = {}
local trailer = AquaConfig.Trailers["TrailerWithBoatSailingYacht"]
trailer.isWithBoat = true
trailer.boat = "BoatSailingYacht"
trailer.emptyTrailer = "TrailerForBoat"






