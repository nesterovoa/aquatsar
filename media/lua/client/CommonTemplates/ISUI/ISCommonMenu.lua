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
	local ovenBySeat = "Oven" .. seat
	local fridgeBySeat = "Fridge" .. seat
	local freezerBySeat = "Freezer" .. seat
	local microwaveBySeat = "Microwave" .. seat
	local oven = vehicle:getPartById(ovenBySeat)
	local fridge = vehicle:getPartById(fridgeBySeat)
	local freezer = vehicle:getPartById(freezerBySeat)
	local microwave = vehicle:getPartById(microwaveBySeat)
	
	if oven then
		menu:addSlice(getText("IGUI_UseStove"), getTexture("media/ui/Container_Oven"), ISCommonMenu.onStoveSetting, playerObj, vehicle, oven, seat)
		-- if oven:getItemContainer():isActive() then
			-- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
		-- else
			-- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Oven"), ISCommonMenu.ToggleDevice, playerObj, vehicle, oven)
		-- end
	end
	
	if microwave then
		menu:addSlice(getText("IGUI_UseMicrowave"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.onMicrowaveSetting, playerObj, vehicle, microwave, seat)
		-- if microwave:getItemContainer():isActive() then
			-- menu:addSlice(getText("IGUI_Turn_Oven_Off"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.ToggleMicrowave, playerObj, vehicle, microwave)
		-- else
			-- menu:addSlice(getText("IGUI_Turn_Oven_On"), getTexture("media/ui/Container_Microwave"), ISCommonMenu.ToggleMicrowave, playerObj, vehicle, microwave)
		-- end
	end
		
	if fridge then
		if fridge:getItemContainer():isActive() then
			menu:addSlice(getText("IGUI_Turn_Fridge_Off"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDevice, playerObj, vehicle, fridge)
		else
			menu:addSlice(getText("IGUI_Turn_Fridge_On"), getTexture("media/ui/Container_Fridge"), ISCommonMenu.ToggleDevice, playerObj, vehicle, fridge)
		end
	end
	
	if freezer then
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
	
Events.OnKeyStartPressed.Add(ISCommonMenu.onKeyStartPressed)