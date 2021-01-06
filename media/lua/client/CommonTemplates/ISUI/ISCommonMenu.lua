ISCommonMenu = {}
require 'Boats/ISUI/ISBoatMenu'

local seatName = {"FrontLeft", "FrontRight", "MiddleLeft", "MiddleRight", "RearLeft", "RearRight"}

function ISCommonMenu.onKeyStartPressed(key)
	local playerObj = getPlayer()
	if not playerObj then return end
	if playerObj:isDead() then return end
	local vehicle = playerObj:getVehicle()
	if vehicle and key == getCore():getKey("VehicleRadialMenu") then
		ISCommonMenu.showRadialMenu(playerObj, vehicle)
	end
end

function ISCommonMenu.showRadialMenu(playerObj, vehicle)
	print("showRadialMenu ISCommonMenu")
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	if isPaused then return end
	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
	local seat = seatName[vehicle:getSeat(playerObj)+1]
	local oven = vehicle:getPartById("Oven" .. seat)
	local fridge = vehicle:getPartById("Fridge" .. seat)
	local freezer = vehicle:getPartById("Freezer" .. seat)
	local microwave = vehicle:getPartById("Microwave" .. seat)
	local lightswitch = vehicle:getPartById("SwitchLight" .. seat)
	local lightIsOn = true
	local timeHours = getGameTime():getHour()
	
	if lightswitch then
		if vehicle:getPartById("HeadlightRearRight") and vehicle:getPartById("HeadlightRearRight"):getInventoryItem() then
			menu:addSlice(getText("ContextMenu_BoatCabinelightsOff"), getTexture("media/ui/boats/boat_switch_off.png"), ISCommonMenu.offToggleCabinlights, playerObj)
		else
			if (timeHours > 22 or timeHours < 7) then
				menu:addSlice(getText("ContextMenu_BoatCabinelightsOn"), getTexture("media/ui/boats/boat_switch_on.png"), ISCommonMenu.onToggleCabinlights, playerObj)
				lightIsOn = false
			else
				menu:addSlice(getText("ContextMenu_BoatCabinelightsOn"), getTexture("media/ui/boats/boat_switch_on_day.png"), ISCommonMenu.onToggleCabinlights, playerObj)
			end
		end
	end
	
	if oven and lightIsOn then
		menu:addSlice(getText("IGUI_UseStove"), getTexture("media/ui/Container_Oven"), ISCommonMenu.onStoveSetting, playerObj, vehicle, oven, seat)
		-- if oven:getItemContainer():isActive() then
			-- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
		-- else
			-- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
		-- end
	end
	
	if microwave and lightIsOn then
		menu:addSlice(getText("IGUI_UseMicrowave"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.onMicrowaveSetting, playerObj, vehicle, microwave, seat)
		-- if microwave:getItemContainer():isActive() then
			-- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.ToggleMicrowave, playerObj, vehicle, microwave)
		-- else
			-- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.ToggleMicrowave, playerObj, vehicle, microwave)
		-- end
	end
		
	if fridge and lightIsOn then
		if fridge:getItemContainer():isActive() then
			menu:addSlice(getText("IGUI_Turn_Fridge_Off"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDevice, playerObj, vehicle, fridge)
		else
			menu:addSlice(getText("IGUI_Turn_Fridge_On"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDevice, playerObj, vehicle, fridge)
		end
	end
	
	if freezer and lightIsOn then
		if freezer:getItemContainer():isActive() then
			menu:addSlice(getText("IGUI_Turn_Freezer_Off"), getTexture("media/ui/Container_Freezer"), ISCommonMenu.ToggleDevice, playerObj, vehicle, freezer)
		else
			menu:addSlice(getText("IGUI_Turn_Freezer_On"), getTexture("media/ui/Container_Freezer"), ISCommonMenu.ToggleDevice, playerObj, vehicle, freezer)
		end
	end
end
	
function ISCommonMenu.ToggleDevice(playerObj, vehicle, part)
	CommonTemplates.Use.DefaultDevice(vehicle, part, playerObj)
end

function ISCommonMenu.ToggleMicrowave(playerObj, vehicle, part)
	CommonTemplates.Use.Microwave(vehicle, part, playerObj)
end

function ISCommonMenu.onStoveSetting(playerObj, vehicle, part, seat)
	ui = ISPortableOvenUI:new(0,0,430,310, playerObj, vehicle, part, seat)
	ui:initialise()
	ui:addToUIManager()
end

function ISCommonMenu.onMicrowaveSetting(playerObj, vehicle, part, seat)
	ui = ISPortableMicrowaveUI:new(0,0,430,310, playerObj, vehicle, part, seat)
	ui:initialise()
	ui:addToUIManager()
end

function ISCommonMenu.onToggleCabinlights(playerObj)
	local boat = playerObj:getVehicle()
	if not boat then return end
	local part = boat:getPartById("LightCabin")
	if part and part:getInventoryItem() then
		local apipart = boat:getPartById("HeadlightRearRight")
		local newInvItem = InventoryItemFactory.CreateItem("Base.LightBulb")
		print(newInvItem)
		newInvItem:setCondition(part:getInventoryItem():getCondition())
		apipart:setInventoryItem(newInvItem, 10)
		sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = true })
	else
		playerObj:Say(getText("IGUI_PlayerText_CabinlightDoNotWork"))
	end
	--sendClientCommand(playerObj, 'vehicle', 'setStoplightsOn', { on = not boat:getHeadlightsOn() })
end

function ISCommonMenu.offToggleCabinlights(playerObj)
	local boat = playerObj:getVehicle()
	if not boat then return end
	local part = boat:getPartById("HeadlightRearRight")
	part:setInventoryItem(nil)
	local lightIsOn = false
	part = boat:getPartById("HeadlightLeft")
	if part then
		if part:getInventoryItem() then
			lightIsOn = true
		end
	end
	part = boat:getPartById("HeadlightRight")
	if part then
		if part:getInventoryItem() then
			lightIsOn = true
		end
	end
	if not lightIsOn then
		sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = false })
	end
	
	
	--sendClientCommand(playerObj, 'vehicle', 'setStoplightsOn', { on = not boat:getHeadlightsOn() })
end

Events.OnKeyStartPressed.Add(ISCommonMenu.onKeyStartPressed)