require "CommonTemplates/CommonDistributions"

local distributionTable = {
	BoatSailingYacht = {
		Normal = VehicleDistributions.CommonTemplatesDist,
	}, 
	BoatSailingYachtWithSailsLeft = {
		Normal = VehicleDistributions.CommonTemplatesDist,
	}, 
	BoatSailingYachtWithSailsRight = {
		Normal = VehicleDistributions.CommonTemplatesDist,
	}, 
	BoatMotor = {
		Normal = VehicleDistributions.CommonTemplatesDist,
	}, 
	TrailerWithBoatSailingYacht = {
		Normal = VehicleDistributions.CommonTemplatesDist,
	}, 
	TrailerWithBoatMotor = {
		Normal = VehicleDistributions.CommonTemplatesDist,
	}, 
}

table.insert(VehicleDistributions, 1, distributionTable);


