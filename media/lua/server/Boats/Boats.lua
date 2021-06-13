--***********************************************************
--**              THE INDIE STONE / edited iBrRus          **
--***********************************************************

require 'CommonTemplates/CommonTemplates.lua'

Boats = {}
Boats.CheckEngine = {}
Boats.CheckOperate = {}
Boats.ContainerAccess = {}
Boats.Create = {}
Boats.Init = {}
Boats.InstallComplete = {}
Boats.InstallTest = {}
Boats.UninstallComplete = {}
Boats.UninstallTest = {}
Boats.Update = {}
Boats.Use = {}



--***********************************************************
--**                                                       **
--**                       Propeller                       **
--**                                                       **
--***********************************************************

function Boats.Create.Propeller(boat, part)
	local item = VehicleUtils.createPartInventoryItem(part)
	if (part:getInventoryItem()== nil) then
		part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.BoatPropeller"), 10)
	end
end

function Boats.Update.Propeller(boat, part, elapsedMinutes)
	BoatUtils.LowerEngineCondition(boat, part, elapsedMinutes);
end

function Boats.InstallTest.Propeller(boat, part, playerObj)
	if ISVehicleMechanics.cheat then return true; end
	if boat:isEngineRunning() then return false end
	return CommonTemplates.InstallTest.PartNotInCabin(boat, part, playerObj)
end

function Boats.UninstallTest.Propeller(boat, part, playerObj)
	if ISVehicleMechanics.cheat then return true; end
	if boat:isEngineRunning() then return false end
	return CommonTemplates.UninstallTest.PartNotInCabin(boat, part, playerObj)
end

function Boats.InstallComplete.Propeller(boat, part, item)
	local part = boat:getPartById("TireFrontLeft")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	boat:transmitPartItem(part)
	part = boat:getPartById("TireFrontRight")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	boat:transmitPartItem(part)
	part = boat:getPartById("TireRearLeft")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	boat:transmitPartItem(part)
	part = boat:getPartById("TireRearRight")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	boat:transmitPartItem(part)
	--part:setModelVisible("InflatedTirePlusWheel", true)
end

function Boats.UninstallComplete.Propeller(boat, part, item)
	local part = boat:getPartById("TireFrontLeft")
	part:setInventoryItem(nil)
	part = boat:getPartById("TireFrontRight")
	part:setInventoryItem(nil)
	part = boat:getPartById("TireRearLeft")
	part:setInventoryItem(nil)
	part = boat:getPartById("TireRearRight")
	part:setInventoryItem(nil)
	--part:setModelVisible("InflatedTirePlusWheel", false)
end

--***********************************************************
--**                                                       **
--**                       Boat Name                       **
--**                                                       **
--***********************************************************

function Boats.Create.BoatName(boat, part)
	local item = VehicleUtils.createPartInventoryItem(part)
	if item:getType() == "SailingYachtName_Sakharov_Item" then
		part:setModelVisible("Sakharov", true)
	else
		part:setModelVisible("Sakharov",false)
	end
end

function Boats.Init.BoatName(boat, part)
	local item = part:getInventoryItem()
	if item then
		if item:getType() == "SailingYachtName_Sakharov_Item" then
			part:setModelVisible("Sakharov", true)
		else
			part:setModelVisible("Sakharov",false)
		end
	end
end


function Boats.InstallComplete.BoatName(vehicle, part)
	local item = part:getInventoryItem()
	if not item then
		-- part:setModelVisible("LB", true)
		part:setModelVisible("Sakharov", false)
	elseif item:getType() == "SailingYachtName_Sakharov_Item" then
		-- part:setModelVisible("LB", false)
		part:setModelVisible("Sakharov", true)
	else
		part:setModelVisible("Sakharov", false)
	end


	vehicle:doDamageOverlay()
	-- vehicle:getPartById("BoatName"):setModelVisible("Sakharov", true)
	-- vehicle:getPartById("BoatName"):setModelVisible("LB", false)
	
end

--***********************************************************
--**                                                       **
--**                         Sails                         **
--**                                                       **
--***********************************************************
function Boats.Create.Sails(boat, part)
	local item = VehicleUtils.createPartInventoryItem(part)
	CommonTemplates.createActivePart(part)
	boat:getModData().sailCode = 0  -- 0 - паруса опущены
									-- 1 - паруса слева
									-- 2 - паруса справа
	part:setModelVisible("Boom", true)
	part:setModelVisible("SailCover", true)
end

function Boats.Init.Sails(boat, part)
print("Boats.Init.Sails: ", boat:getX(), " ", boat:getY())
	local item = part:getInventoryItem()
	if not item then
		part:setModelVisible("Boom", true)
		part:setModelVisible("SailCover", false)
		boat:getModData().sailCode = 0
		part:setLightActive(false)
	elseif boat:getModData().sailCode == 0 then
		part:setModelVisible("Boom", true)
		part:setModelVisible("SailCover", true)
		part:setModelVisible("SailLeft", false)
		part:setModelVisible("SailRight", false)
		part:setLightActive(false)
	elseif boat:getModData().sailCode == 1 then
		part:setModelVisible("Boom", false)
		part:setModelVisible("SailCover", false)
		part:setModelVisible("SailLeft", true)
		part:setModelVisible("SailRight", false)
		part:setLightActive(true)
	elseif boat:getModData().sailCode == 2 then
		part:setModelVisible("Boom", false)
		part:setModelVisible("SailCover", false)
		part:setModelVisible("SailLeft", false)
		part:setModelVisible("SailRight", true)
		part:setLightActive(true)
	end
end

-- function Boats.Init.SailsSet(boat, part)
	-- local item = VehicleUtils.createPartInventoryItem(part)
	-- CommonTemplates.createActivePart(part)
	-- part:setLightActive(true)
-- end

-- function Boats.Init.SailsRemoved(boat, part)
	-- local item = VehicleUtils.createPartInventoryItem(part)
	-- CommonTemplates.createActivePart(part)
	-- part:setLightActive(false)
-- end

function Boats.Update.SailsSet(boat, part, elapsedMinutes)
	BoatUtils.LowerCondition(boat, part, elapsedMinutes);
	local windSpeed = getClimateManager():getWindspeedKph()
	if part:getInventoryItem() and windSpeed > AquaConfig.windVeryStrong then
		local partCondition = part:getCondition()
		if partCondition == 1 then
			part:setCondition(0)
			boat:getEmitter():playSound("boat_sails_torned2")
		elseif partCondition > 0 then
			part:setCondition(part:getCondition() - 1)
			boat:getEmitter():playSound("boat_sails_torn" .. ZombRand(8)+1)
		else
			part:setLightActive(false)
		end
	end
end

function Boats.InstallTest.Sails(boat, part, playerObj)
	if boat:getModData().sailCode ~= 0 then return false end
	return CommonTemplates.InstallTest.PartNotInCabin(boat, part, playerObj)
end

function Boats.InstallComplete.Sails(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	part:setModelVisible("Boom", true)
	part:setModelVisible("SailCover", true)
	vehicle:doDamageOverlay()
	-- vehicle:getPartById("BoatName"):setModelVisible("Sakharov", true)
	-- vehicle:getPartById("BoatName"):setModelVisible("LB", false)
	
end

function Boats.UninstallTest.Sails(boat, part, playerObj)
	if boat:getModData().sailCode ~= 0 then return false end
	return CommonTemplates.UninstallTest.PartNotInCabin(boat, part, playerObj)
end

function Boats.UninstallComplete.Sails(vehicle, part, item)
	if not item then return end
	part:setModelVisible("Boom", true)
	part:setModelVisible("SailCover", false)
	-- vehicle:getPartById("BoatName"):setModelVisible("Sakharov", false)
	-- vehicle:getPartById("BoatName"):setModelVisible("LB", true)
	vehicle:doDamageOverlay()
end

--***********************************************************
--**                                                       **
--**                     ManualStarter                     **
--**                                                       **
--***********************************************************
function Boats.Create.ManualStarter(boat, part)
	local item = VehicleUtils.createPartInventoryItem(part)
end

function Boats.InstallComplete.ManualStarter(boat, part, item)
	boat:cheatHotwire(true, false)
end

function Boats.UninstallComplete.ManualStarter(boat, part, item)
	boat:cheatHotwire(false, false)
end

--***********************************************************
--**                                                       **
--**                        GasTank                        **
--**                                                       **
--***********************************************************
function Boats.Update.GasTank(boat, part, elapsedMinutes)
	local invItem = part:getInventoryItem();
	if not invItem then return; end
	local amount = part:getContainerContentAmount()
	if elapsedMinutes > 0 and amount > 0 and boat:isEngineRunning() then
		local amountOld = amount
		local gasMultiplier = 90000;
		local heater = boat:getHeater();
		if heater and heater:getModData().active then
			gasMultiplier = gasMultiplier + 5000;
		end
		local qualityMultiplier = ((100 - boat:getEngineQuality()) / 200) + 1;
		local massMultiplier =  ((math.abs(1000 - boat:getScript():getMass())) / 300) + 1;
		-- if boat is stopped, we half the value of gas consummed
		-- AUD.insp("Boat", "getCurrentSpeedKmHour:", boat:getCurrentSpeedKmHour())
		if math.abs(boat:getCurrentSpeedKmHour()) > 0.4 then
			gasMultiplier = gasMultiplier / qualityMultiplier / massMultiplier;
			speedMultiplier = 800;
		else
			gasMultiplier = (gasMultiplier / qualityMultiplier);
			speedMultiplier = 800;
		end

		local newAmount = (speedMultiplier / gasMultiplier) * AquaConfig.Boat(boat).multiplierFuelConsumption * SandboxVars.CarGasConsumption;
		newAmount =  newAmount * (boat:getEngineSpeed()/2500.0);
		-- AUD.insp("Boat", "newAmount:", newAmount)
		amount = amount - elapsedMinutes * newAmount;
		-- if your gas tank is in bad condition, you can simply lose fuel
		if part:getCondition() < 70 then
			if ZombRand(part:getCondition() * 2) == 0 then
				amount = amount - 0.01;
			end
		end
	
		part:setContainerContentAmount(amount, false, true);
		amount = part:getContainerContentAmount();
		local precision = (amount < 0.5) and 2 or 1
		if VehicleUtils.compareFloats(amountOld, amount, precision) then
			boat:transmitPartModData(part)
		end
	end
end

function Boats.ContainerAccess.BlockSeat(boat, part, playerObj)
	return false
end

--***********************************************************
--**                                                       **
--**                        BoatUtils                      **
--**                                                       **
--***********************************************************


BoatUtils = {}

function BoatUtils.LowerCondition(vehicle, part, elapsedMinutes)
	if part:getInventoryItem() then
		local chance = vehicle:getEngineSpeed()/ 1000
		if part:getCondition() > 0 and ZombRandFloat(0, 100) < chance then
			part:setCondition(part:getCondition() - 1);
			vehicle:transmitPartCondition(part);
			vehicle:updatePartStats();
		end
		return chance;
	end
	return 0;
end

function BoatUtils.LowerEngineCondition(vehicle, part, elapsedMinutes)
	if vehicle:isEngineRunning() and part:getInventoryItem() then
		local chance = vehicle:getEngineSpeed()/ 1000
		if part:getCondition() > 0 and ZombRandFloat(0, 100) < chance then
			part:setCondition(part:getCondition() - 1);
			vehicle:transmitPartCondition(part);
			vehicle:updatePartStats();
		end
		return chance;
	end
	return 0;
end
