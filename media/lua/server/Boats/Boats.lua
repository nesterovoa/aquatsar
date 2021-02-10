--***********************************************************
--**              THE INDIE STONE / edited iBrRus          **
--***********************************************************



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
	local item = BoatUtils.createPartInventoryItem(part)
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
--**                         Sails                         **
--**                                                       **
--***********************************************************
function Boats.Create.Sails(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	CommonTemplates.createActivePart(part)
end

function Boats.Init.SailsSet(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	CommonTemplates.createActivePart(part)
	part:setLightActive(true)
	boat:getModData()["setsails"] = true
end

function Boats.Init.SailsRemoved(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	CommonTemplates.createActivePart(part)
	part:setLightActive(false)
	boat:getModData()["setsails"] = false
end

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
	if boat:getModData()["setsails"] then return false end
	return CommonTemplates.InstallTest.PartNotInCabin(boat, part, playerObj)
end

function Boats.UninstallTest.Sails(boat, part, playerObj)
	if boat:getModData()["setsails"] then return false end
	return CommonTemplates.UninstallTest.PartNotInCabin(boat, part, playerObj)
end


--***********************************************************
--**                                                       **
--**                     ManualStarter                     **
--**                                                       **
--***********************************************************
function Boats.Create.ManualStarter(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
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
		if math.floor(math.abs(boat:getCurrentSpeedKmHour())) > 0 then
			gasMultiplier = gasMultiplier / qualityMultiplier / massMultiplier/4;
			speedMultiplier = 800;
		else
			gasMultiplier = (gasMultiplier / qualityMultiplier);
			speedMultiplier = 800;
		end

		local newAmount = (speedMultiplier / gasMultiplier)  * SandboxVars.CarGasConsumption;
		newAmount =  newAmount * (boat:getEngineSpeed()/2500.0);
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

function BoatUtils.getContainers(playerNum)
	local containers = {}
	for _,v in ipairs(getPlayerInventory(playerNum).inventoryPane.inventoryPage.backpacks) do
		table.insert(containers, v.inventory)
	end
	for _,v in ipairs(getPlayerLoot(playerNum).inventoryPane.inventoryPage.backpacks) do
		table.insert(containers, v.inventory)
	end
	return containers
end

function BoatUtils.getItems(playerNum)
	local containers = BoatUtils.getContainers(playerNum)
	local typeToItem = {}
	for _,container in ipairs(containers) do
		for i=1,container:getItems():size() do
			local item = container:getItems():get(i-1)
			if item:getCondition() > 0 then
				typeToItem[item:getFullType()] = typeToItem[item:getFullType()] or {}
				table.insert(typeToItem[item:getFullType()], item)
			end
		end
	end
	return typeToItem
end

function BoatUtils.createPartInventoryItem(part)
	if not part:getItemType() or part:getItemType():isEmpty() then return nil end
	local item;
	if not part:getInventoryItem() then
		local v = part:getVehicle();
--		if not part:isSpecificItem() then
			local chosenKey = ""
			for i=1,part:getItemType():size() do
				chosenKey = chosenKey .. part:getItemType():get(i-1) .. ';'
			end
			local itemType = v:getChoosenParts():get(chosenKey);
			-- never init this part, we choose a random part in the itemtype available, so every tire will be the same, every seats... (no 2 normal tire and 2 sports tire e.g)
			-- part quality is always in the same order, 0 = bad, max = good
			-- we random the part quality depending on the engine quality
			if not itemType then
				for i=0, part:getItemType():size() - 1 do
					if ZombRand(100) > v:getEngineQuality() or i == part:getItemType():size() - 1 then
						itemType = part:getItemType():get(i);
						-- removed old brake
						itemType = itemType:gsub("Base.OldBrake", "Base.NormalBrake");
						v:getChoosenParts():put(chosenKey, itemType);
						break;
					end
				end
			end
			item = InventoryItemFactory.CreateItem(itemType);
			local conditionMultiply = 100/item:getConditionMax();
			if part:getContainerCapacity() and part:getContainerCapacity() > 0 then
				item:setMaxCapacity(part:getContainerCapacity());
			end
			item:setConditionMax(item:getConditionMax()*conditionMultiply);
			item:setCondition(item:getCondition()*conditionMultiply);
--		else
--			item = InventoryItemFactory.CreateItem(part:getItemType():get(0));
--		end
--		if not item then return; end
		part:setRandomCondition(item);
		part:setInventoryItem(item)
	end
	return part:getInventoryItem()
end



function BoatUtils.testTraits(playerObj, traits)
	if not traits or traits == "" then return true end
	for _,trait in ipairs(traits:split(";")) do
		if not playerObj:getTraits():contains(trait) then return false end
	end
	return true
end

function BoatUtils.testRecipes(playerObj, recipes)
	if not recipes or recipes == "" then return true end
	for _,recipe in ipairs(recipes:split(";")) do
		if not playerObj:isRecipeKnown(recipe) then return false end
	end
	return true
end



function BoatUtils.testItems(playerObj, items, typeToItem)
	if not items then return true end
	for _,item in pairs(items) do
		if not typeToItem[item.type] then return false end
		if item.count then
		end
	end
	return true
end