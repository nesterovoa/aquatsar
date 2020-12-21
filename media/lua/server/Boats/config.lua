AquaTsarConfig = {}


AquaTsarConfig.trailerAfterBoatLaunchTable = {
    ["TrailerWithBoatSailingYacht"] = "TrailerForBoat",
}

AquaTsarConfig.boatAfterBoatLaunchFromTrailerTable = {
    ["TrailerWithBoatSailingYacht"] = "BoatSailingYacht",
}

AquaTsarConfig.boatsTable = {
    ["BoatSailingYacht"] = true,
    ["BoatSailingYachtWithSails"] = true,
}

AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable = {}
AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable["TrailerForBoat"] = {}
AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable["TrailerForBoat"]["BoatSailingYacht"] = "TrailerWithBoatSailingYacht"
AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable["TrailerForBoat"]["BoatSailingYachtWithSails"] = "TrailerWithBoatSailingYacht"

function AquaTsarConfig.isEmptyTrailerForBoat(vehicle)
    return AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable[vehicle:getScript():getName()] ~= nil
end

function AquaTsarConfig.isTrailerWithBoat(vehicle)
    return AquaTsarConfig.trailerAfterBoatLaunchTable[vehicle:getScript():getName()] ~= nil
end

function AquaTsarConfig.isBoat(vehicle)
    return AquaTsarConfig.boatsTable[vehicle:getScript():getName()] ~= nil
end

-----------------------------

AquaTsarConfig.boatSeatUI_Image = {
    ["BoatSailingYacht"] = "BoatSailingYacht_seat",
    ["BoatSailingYachtWithSails"] = "BoatSailingYacht_seat",
}

AquaTsarConfig.boatSeatUI_Scale = {
    ["BoatSailingYacht"] = 1.1,
    ["BoatSailingYachtWithSails"] = 1.1,
}
AquaTsarConfig.boatSeatUI_SeatOffsetX = {}
AquaTsarConfig.boatSeatUI_SeatOffsetX["BoatSailingYacht"] = {
	["FrontLeft"] = 1,
	["FrontRight"] = 1,
	["MiddleLeft"] = 0,
	["MiddleRight"] = 1,
	["RearLeft"] = -4,
	["RearRight"] = 1,
}
AquaTsarConfig.boatSeatUI_SeatOffsetX["BoatSailingYachtWithSails"] = AquaTsarConfig.boatSeatUI_SeatOffsetX["BoatSailingYacht"]

AquaTsarConfig.boatSeatUI_SeatOffsetY = {}
AquaTsarConfig.boatSeatUI_SeatOffsetY["BoatSailingYacht"] = {
	["FrontLeft"] = 10,
	["FrontRight"] = 10,
	["MiddleLeft"] = -75, 
	["MiddleRight"] = -55,
	["RearLeft"] = -30,
	["RearRight"] = 10,
}
AquaTsarConfig.boatSeatUI_SeatOffsetY["BoatSailingYachtWithSails"] = AquaTsarConfig.boatSeatUI_SeatOffsetY["BoatSailingYacht"]