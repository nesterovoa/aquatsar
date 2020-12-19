AquaTsarConfig = {}


AquaTsarConfig.trailerAfterBoatLaunchTable = {
    ["TrailerWithBoatSailingYacht"] = "TrailerForBoat",
}

AquaTsarConfig.boatAfterBoatLaunchFromTrailerTable = {
    ["TrailerWithBoatSailingYacht"] = "BoatSailingYacht",
}

AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable = {}
AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable["TrailerForBoat"] = {}
AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable["TrailerForBoat"]["BoatSailingYacht"] = "TrailerWithBoatSailingYacht"
AquaTsarConfig.trailerAfterLoadBoatOnTrailerTable["TrailerForBoat"]["BoatSailingYachtWithSails"] = "TrailerWithBoatSailingYacht"