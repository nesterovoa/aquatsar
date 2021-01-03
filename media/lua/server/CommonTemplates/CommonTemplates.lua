--***********************************************************
--**              THE INDIE STONE / edited iBrRus          **
--***********************************************************

CommonTemplates = {}
CommonTemplates.CheckEngine = {}
CommonTemplates.CheckOperate = {}
CommonTemplates.ContainerAccess = {}
CommonTemplates.Create = {}
CommonTemplates.Init = {}
CommonTemplates.InstallComplete = {}
CommonTemplates.InstallTest = {}
CommonTemplates.UninstallComplete = {}
CommonTemplates.UninstallTest = {}
CommonTemplates.Update = {}
CommonTemplates.Use = {}

function CommonTemplates.Create.Propeller(vehicle, part)
	print("CommonTemplates.Create.Propeller")
	print(part:getInventoryItem())
	local item = BoatUtils.createPartInventoryItem(part)
	print(part:getInventoryItem())
	if (part:getInventoryItem()== nil) then
		part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.BoatPropeller"), 10)
	end
end

function CommonTemplates.InstallComplete.Propeller(vehicle, part, item)
	local part = vehicle:getPartById("TireFrontLeft")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	part = vehicle:getPartById("TireFrontRight")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	part = vehicle:getPartById("TireRearLeft")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	part = vehicle:getPartById("TireRearRight")
	part:setInventoryItem(InventoryItemFactory.CreateItem("Aquatsar.AirBagNormal3"), 10)
	part:setContainerContentAmount(35)
	vehicle:transmitPartItem(part)
	--part:setModelVisible("InflatedTirePlusWheel", true)
end

function CommonTemplates.UninstallComplete.Propeller(vehicle, part, item)
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

function CommonTemplates.Init.ApiBoatlight(vehicle, part)
	part:setModelVisible("test", true)
end

function CommonTemplates.Update.ApiBoatlight(vehicle, part, elapsedMinutes)
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

function CommonTemplates.ContainerAccess.Container(transport, part, chr)
	if not part:getInventoryItem() then return false; end
	if chr:getVehicle() == transport then
		local script = transport:getScript()
		local seat = transport:getSeat(chr)
		local seatname = 'Seat'..script:getPassenger(seat):getId()
		return part:getArea() == seatname
	else
		return false
	end
end

function CommonTemplates.Create.Fridge(vehicle, part)
	--print("TC: Create Fridge")
	local invItem = VehicleUtils.createPartInventoryItem(part);

	if part:getInventoryItem() and part:getItemContainer() then
	if vehicle:getBatteryCharge() > 0.00005 then
		part:getModData().coolerActive = true
	else
		part:getModData().coolerActive = false
	end
		part:getItemContainer():setType("fridge")
		part:getItemContainer():setCustomTemperature(0.2)
	end
end

function CommonTemplates.Init.Fridge(vehicle, part)
	--print("TC: Init Fridge")
	part:setModelVisible("test", true)
	if vehicle:getBatteryCharge() > 0.00005 then
		part:getModData().coolerActive = true
	else
		part:getModData().coolerActive = false
	end
	
	part:getItemContainer():setType("fridge")
	part:getItemContainer():setCustomTemperature(0.2)
end

function CommonTemplates.Update.Fridge(vehicle, part, elapsedMinutes)
	--print("TC: Update Fridge")
	if part:getInventoryItem() and part:getItemContainer() and part:getModData().coolerActive then
		--print("ACTIVE")
		local batteryChange = -0.000050;

		if vehicle:getBatteryCharge() <= 0.0 then
			part:getModData().coolerActive = false
		else
			part:getItemContainer():setCustomTemperature(0.2)
			--print("COOLER")
			if not vehicle:isEngineRunning() then
				VehicleUtils.chargeBattery(vehicle, batteryChange * elapsedMinutes)
			end
		end
	end
end

function CommonTemplates.Create.Oven(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("stove")
		part:getItemContainer():setActive(false)
		part:getModData().ovenActive = false
	end
end


function CommonTemplates.Init.Oven(vehicle, part)
	--print("TC: Init Oven")
	part:setModelVisible("test", true)
	if part:getInventoryItem() and part:getItemContainer() and part:getItemContainer():isActive() and vehicle:isEngineRunning() then
		part:getItemContainer():setCustomTemperature(2.0)
	else		
		part:getItemContainer():setCustomTemperature(1.0)
	end
	
end

function CommonTemplates.Use.Oven(vehicle, cont, player)
	--print("TC: Use Fridge")
	local id = vehicle:getId()
	if cont:isActive() then
		cont:setActive(false)
		player:getEmitter():playSound("PZ_Switch")
		--print("Oven Off")
	elseif vehicle:getBatteryCharge() > 0.00005 then
		cont:setActive(true)
		VehicleUtils.chargeBattery(vehicle, -0.00005)
		player:getEmitter():playSound("PZ_Switch")
		--print("Oven On")
	end
end

function CommonTemplates.Update.Oven(vehicle, part, elapsedMinutes)
	--print("UPDATE OVEN SERVER?")
	local id = vehicle:getId()
	--print(part:getItemContainer():isActive())
	
	if part:getInventoryItem() and part:getItemContainer() and part:getItemContainer():isActive() and vehicle:isEngineRunning() then
		local currentTemp = part:getItemContainer():getTemprature()
		--print(tostring(currentTemp))
		local maxTemp = 2.0

		if currentTemp < maxTemp then
			part:getItemContainer():setCustomTemperature(currentTemp + (0.05 * elapsedMinutes))
		elseif currentTemp > maxTemp then
			part:getItemContainer():setCustomTemperature(maxTemp)
		end
	end

	if part:getInventoryItem() and part:getItemContainer() and not part:getItemContainer():isActive() then
		local currentTemp = part:getItemContainer():getTemprature()
		--print(tostring(currentTemp))
		local minTemp = 1.0

		if currentTemp > minTemp then
			part:getItemContainer():setCustomTemperature(currentTemp - (0.05 * elapsedMinutes))
		elseif currentTemp < minTemp then
			part:getItemContainer():setCustomTemperature(minTemp)
		end
	end
end

function CommonTemplates.Create.Counter(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("counter")
	end
end

function CommonTemplates.Create.Shelve(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("shelves")
	end
end

function CommonTemplates.Create.Drawer(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("sidetable")
	end
end

function CommonTemplates.Create.Cupboard(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("wardrobe")
	end
end

function CommonTemplates.Create.Medicine(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("medicine")
	end
end

function CommonTemplates.Create.Microwave(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("microwave")
	end
end

function CommonTemplates.Create.Freezer(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		if vehicle:getBatteryCharge() > 0.00005 then
			part:getModData().coolerActive = true
		else
			part:getModData().coolerActive = false
		end
		part:getItemContainer():setType("freezer")
		part:getItemContainer():setCustomTemperature(0.2)
	end
end

function CommonTemplates.Init.Freezer(vehicle, part)
	--print("TC: Init Fridge")
	part:setModelVisible("test", true)
	if vehicle:getBatteryCharge() > 0.00005 then
		part:getModData().coolerActive = true
	else
		part:getModData().coolerActive = false
	end
	
	part:getItemContainer():setType("freezer")
	part:getItemContainer():setCustomTemperature(0.2)
end