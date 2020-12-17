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

function Boats.Create.Propeller(vehicle, part)
	print("Boats.Create.Propeller")
	print(part:getInventoryItem())
	local item = BoatUtils.createPartInventoryItem(part)
	print(part:getInventoryItem())
	if (part:getInventoryItem()== nil) then
		part:setInventoryItem(InventoryItemFactory.CreateItem("Aqua.BoatPropeller"), 10)
	end
end

function Boats.InstallComplete.Propeller(vehicle, part, item)
	local part = vehicle:getPartById("TireFrontLeft")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aqua.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	part = vehicle:getPartById("TireFrontRight")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aqua.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	part = vehicle:getPartById("TireRearLeft")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aqua.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	part = vehicle:getPartById("TireRearRight")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aqua.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	--part:setModelVisible("InflatedTirePlusWheel", true)
end

function Boats.UninstallComplete.Propeller(vehicle, part, item)
	local part = vehicle:getPartById("TireFrontLeft")
	part:setInventoryItem(nil)
	part = vehicle:getPartById("TireFrontRight")
	part:setInventoryItem(nil)
	part = vehicle:getPartById("TireRearLeft")
	part:setInventoryItem(nil)
	part = vehicle:getPartById("TireRearRight")
	part:setInventoryItem(nil)
	--part:setModelVisible("InflatedTirePlusWheel", false)
end


function Boats.Create.ManualStarter(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
end

function Boats.InstallComplete.ManualStarter(boat, part, item)
	boat:cheatHotwire(true, false)
	print(boat:isHotwired())
end

function Boats.UninstallComplete.ManualStarter(boat, part, item)
	boat:cheatHotwire(false, false)
	print(boat:isHotwired())
end

function Boats.Create.ApiBoatlight(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	-- if part:getId() == "HeadlightLeft" then
		-- part:createSpotLight(0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	-- elseif part:getId() == "HeadlightRight" then
		-- part:createSpotLight(-0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	-- end
	part:setInventoryItem(nil)
end

function Boats.Init.ApiBoatlight(vehicle, part)
	part:setModelVisible("test", true)
end

function Boats.Update.ApiBoatlight(vehicle, part, elapsedMinutes)
	local light = part:getLight()
	if not light then return end
	local active = vehicle:getHeadlightsOn()
	if active and (not part:getInventoryItem() or vehicle:getBatteryCharge() <= 0.0) then
		active = false
	end
	part:setLightActive(active)
	if active and not vehicle:isEngineRunning() then
		VehicleUtils.chargeBattery(vehicle, -0.000025 * elapsedMinutes)
	end
end

function Boats.Create.BoatHeadlight(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	if part:getId() == "BoatLightFloodlightLeft" then
		part:createSpotLight(0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	elseif part:getId() == "BoatLightFloodlightRight" then
		part:createSpotLight(-0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	end
end

function Boats.Init.BoatHeadlight(vehicle, part)
	part:setModelVisible("test", true)
end


function Boats.InstallComplete.Cabinlight(boat, partt)
	print("Boats.InstallComplete.Cabinlight")
end

function Boats.UninstallComplete.Cabinlight(boat, partt)
	print("Boats.UninstallComplete.Cabinlight")
end


--***********************************************************
--**                                                       **
--**                        BoatUtils                      **
--**                                                       **
--***********************************************************


BoatUtils = {}

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



function BoatUtils.testTraits(chr, traits)
	if not traits or traits == "" then return true end
	for _,trait in ipairs(traits:split(";")) do
		if not chr:getTraits():contains(trait) then return false end
	end
	return true
end

function BoatUtils.testRecipes(chr, recipes)
	if not recipes or recipes == "" then return true end
	for _,recipe in ipairs(recipes:split(";")) do
		if not chr:isRecipeKnown(recipe) then return false end
	end
	return true
end



function BoatUtils.testItems(chr, items, typeToItem)
	if not items then return true end
	for _,item in pairs(items) do
		if not typeToItem[item.type] then return false end
		if item.count then
		end
	end
	return true
end