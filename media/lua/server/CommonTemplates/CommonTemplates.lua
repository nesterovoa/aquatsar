--***********************************************************
--**             			iBrRus        				   **
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

local OvenBatteryChange = -0.000500
local FridgeBatteryChange = -0.000020
local MicrowaveBatteryChange = -0.000200


--***********************************************************
--**                                                       **
--**                         Common                        **
--**                                                       **
--***********************************************************
function CommonTemplates.createActivePart(part)
	if not part:getLight() then
		part:createSpotLight(0.1, 0.1, 0.1, 0.01, 100, 0)
	end
end

--***********************************************************
--**                                                       **
--**                    Fridge n Freezer                   **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.Freezer(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("freezer")
	end
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Create.Fridge(vehicle, part)
	--print("CommonTemplates.Create.Fridge")
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("fridge")
	end
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Init.Fridge(vehicle, part)
	--print("CommonTemplates.Init.Fridge")
	part:setModelVisible("test", true)
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00010 then
			part:getItemContainer():setCustomTemperature(0.2)
		else		
			part:getItemContainer():setCustomTemperature(1.0)
		end
	end
end

function CommonTemplates.Update.Fridge(vehicle, part, elapsedMinutes)
	-- print("CommonTemplates.Update.Fridge")
	local currentTemp = part:getItemContainer():getTemprature()
	local minTemp = 0.2
	local maxTemp = 1.0
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00010 then
			if currentTemp < minTemp then
				part:getItemContainer():setCustomTemperature(minTemp)
			elseif currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - (0.04 * elapsedMinutes))
			end
			VehicleUtils.chargeBattery(vehicle, FridgeBatteryChange * elapsedMinutes)
		else
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + (0.04 * elapsedMinutes))
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
				part:setLightActive(false)
			end
		end
	end
end
--***********************************************************
--**                                                       **
--**                    Oven n Microwave                   **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.Oven(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("stove")
	end
	part:getModData().timer = 0
	part:getModData().timePassed = 0
	part:getModData().maxTemperature = 0
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Use.DefaultDevice(vehicle, part, player)
	if part:getItemContainer():isActive() then
		part:getItemContainer():setActive(false)
		player:getEmitter():playSound("ToggleStove")
		part:getModData().timePassed = 0
	else
		part:getItemContainer():setActive(true)
		part:setLightActive(true)
		player:getEmitter():playSound("ToggleStove")
	end
end

function CommonTemplates.Init.Oven(vehicle, part)
	part:setModelVisible("test", true)
	if part:getInventoryItem() and part:getItemContainer() 
			and part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00200 then
		part:getItemContainer():setCustomTemperature(2.0)
	else		
		part:getItemContainer():setCustomTemperature(1.0)
	end
end
a = 0
function CommonTemplates.Update.Oven(vehicle, part, elapsedMinutes)
	-- print("CommonTemplates.Update.Oven")
	local currentTemp = part:getItemContainer():getTemprature()
	-- print(currentTemp)
	local minTemp = 1.0
	local maxTemp = (part:getModData().maxTemperature + 100) / 100
	local contType = part:getItemContainer():getType()
	local emi = vehicle:getEmitter()
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00200 then
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + 0.2)
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
			end
			VehicleUtils.chargeBattery(vehicle, OvenBatteryChange)
			if part:getModData().timer > 0 then
				if part:getModData().timePassed < part:getModData().timer then
					part:getModData().timePassed = part:getModData().timePassed + 1
				else 
					emi:playSound("StoveTimerExpired")
					part:getModData().timer = 0
					part:getModData().timePassed = 0
				end
			end
		else
			part:getModData().timePassed = 0
			if currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - 0.2)
			elseif currentTemp <= minTemp then
				part:getItemContainer():setCustomTemperature(minTemp)
				part:setLightActive(false)
			end
		end
	end
end
--***********************************************************
--**                                                       **
--**                        Microwave                      **
--**                                                       **
--***********************************************************

function CommonTemplates.Create.Microwave(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("portablemicrowave")
	end
	part:getModData().timer = 0
	part:getModData().timePassed = 0
	part:getModData().maxTemperature = 0
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Use.Microwave(vehicle, part, player)
	if part:getItemContainer():isActive() then
		part:getItemContainer():setActive(false)
		vehicle:getEmitter():stopSoundByName("MicrowaveRunning")
		vehicle:getEmitter():playSound("MicrowaveTimerExpired")
		part:getModData().timer = 0
		part:getModData().timePassed = 0
	elseif part:getModData().timer > 0 then
		part:getModData().timePassed = 0.001
		part:getItemContainer():setActive(true)
		part:setLightActive(true)
		vehicle:getEmitter():playSound("ToggleStove")
		vehicle:getEmitter():playSoundLooped("MicrowaveRunning")
	end
end

function CommonTemplates.Update.Microwave(vehicle, part, elapsedMinutes)
	--print("CommonTemplates.Update.Microwave")
	local currentTemp = part:getItemContainer():getTemprature()
	local minTemp = 1.0
	local maxTemp = (part:getModData().maxTemperature + 100) / 100
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00200 then
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + 0.5)
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
			end
			VehicleUtils.chargeBattery(vehicle, MicrowaveBatteryChange)
			if part:getModData().timer > 0 then
				if part:getModData().timePassed < part:getModData().timer then
					part:getModData().timePassed = part:getModData().timePassed + 1
				else 
					vehicle:getEmitter():stopSoundByName("MicrowaveRunning")
					vehicle:getEmitter():playSound("MicrowaveTimerExpired")
					part:getItemContainer():setActive(false)
					part:getModData().timer = 0
					part:getModData().timePassed = 0
				end
			else
				vehicle:getEmitter():stopSoundByName("MicrowaveRunning")
				vehicle:getEmitter():playSound("MicrowaveTimerExpired")
				part:getItemContainer():setActive(false)
				part:getModData().timer = 0
				part:getModData().timePassed = 0
			end
		else
			part:getModData().timePassed = 0
			if currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - 0.5)
			elseif currentTemp <= minTemp then
				part:getItemContainer():setCustomTemperature(minTemp)
				part:setLightActive(false)
			end
		end
	end
end
--***********************************************************
--**                                                       **
--**                         Light                         **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.LightApi(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	-- if part:getId() == "HeadlightLeft" then
		-- part:createSpotLight(0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	-- elseif part:getId() == "HeadlightRight" then
		-- part:createSpotLight(-0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	-- end
	part:setInventoryItem(nil)
end

function CommonTemplates.Init.LightApi(boat, part)
	part:setModelVisible("test", true)
end

function CommonTemplates.Update.LightApi(boat, part, elapsedMinutes)
	local light = part:getLight()
	if not light then return end
	local active = boat:getHeadlightsOn()
	if active and (not part:getInventoryItem() or boat:getBatteryCharge() <= 0.0) then
		active = false
	end
	part:setLightActive(active)
	if active and not boat:isEngineRunning() then
		VehicleUtils.chargeBattery(boat, -0.000025 * elapsedMinutes)
	end
end

function CommonTemplates.Create.Light(boat, part)
	local item = BoatUtils.createPartInventoryItem(part)
	if part:getId() == "LightFloodlightLeft" then
		part:createSpotLight(0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	elseif part:getId() == "LightFloodlightRight" then
		part:createSpotLight(-0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	end
end

function CommonTemplates.Init.Light(boat, part)
	part:setModelVisible("test", true)
end

function CommonTemplates.InstallComplete.Cabinlight(boat, partt)
	print("Boats.InstallComplete.Cabinlight")
end

function CommonTemplates.UninstallComplete.Cabinlight(boat, partt)
	print("Boats.UninstallComplete.Cabinlight")
end

--***********************************************************
--**                                                       **
--**                        Another                        **
--**                                                       **
--***********************************************************

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


