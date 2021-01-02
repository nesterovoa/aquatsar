AquaConfig = {}
AquaConfig.Boats = {}
AquaConfig.Trailers = {}

---------------
-- Utils
---------------

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
AquaConfig.Boats["BoatSailingYacht"] = {}
boat = AquaConfig.Boats["BoatSailingYacht"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.manualStarter = true
boat.driverBehind = true
boat.sails = false
boat.setLeftSailsScript = "BoatSailingYachtWithSailsLeft"
boat.setRightSailsScript = "BoatSailingYachtWithSailsRight"
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

-- BoatSailingYachtWithSailsLeft --
AquaConfig.Boats["BoatSailingYachtWithSailsLeft"] = {}
boat = AquaConfig.Boats["BoatSailingYachtWithSailsLeft"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.manualStarter = true
boat.driverBehind = true
boat.sails = true
boat.removeSailsScript = "BoatSailingYacht"
boat.sailsSide = "Left"
boat.setRightSailsScript = "BoatSailingYachtWithSailsRight"
boat.sailsMaxAngle = 90
boat.sailsMinAngle = 0
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
AquaConfig.Boats["BoatSailingYachtWithSailsRight"] = {}
boat = AquaConfig.Boats["BoatSailingYachtWithSailsRight"]
boat.dashboard = "ISNewSalingBoatDashboard"
boat.manualStarter = true
boat.driverBehind = true
boat.sails = true
boat.removeSailsScript = "BoatSailingYacht"
boat.sailsSide = "Right"
boat.setLeftSailsScript = "BoatSailingYachtWithSailsLeft"
boat.sailMaxAngle = 0
boat.sailMinAngle = -90
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






