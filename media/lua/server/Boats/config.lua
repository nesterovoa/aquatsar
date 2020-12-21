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
    ["BoatSailingYacht"] = 1.25,
    ["BoatSailingYachtWithSails"] = 1.25,
}



