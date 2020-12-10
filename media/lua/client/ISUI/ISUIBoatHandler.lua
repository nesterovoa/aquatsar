--***********************************************************
--**                          iBrRus                       **
--***********************************************************

ISUIBoatHandler = {};

local function starts_with(str, start)
   return str:sub(1, #start) == start
end



ISUIBoatHandler.onKeyStartPressed = function(key)
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	if playerObj:isDead() then return end
	if key == getCore():getKey("VehicleRadialMenu") and playerObj then
		-- 'V' can be 'Toggle UI' when outside a vehicle
		local boat = ISBoatMenu.getBoatInside(playerObj)
		if boat then
			ISBoatMenu.showRadialMenu(playerObj)
			return
		end
		boat = ISBoatMenu.getBoatToInteractWith(playerObj)
		if boat then
			ISBoatMenu.showRadialMenuOutside(playerObj)
			return
		end
		local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)
		if vehicle~=nil and starts_with(string.lower(vehicle:getScript():getName()), "trailerwithboat") then
			ISVehicleMenuForTrailerWithBoat.launchRadialMenu(playerObj, vehicle)
		end
	end
end

ISUIBoatHandler.onKeyPressed = function(key)
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	if playerObj:isDead() then return end
	if key == getCore():getKey("VehicleRadialMenu") and playerObj then
		-- 'V' can be 'Toggle UI' when outside a vehicle
		if not getCore():getOptionRadialMenuKeyToggle() then
			-- Hide radial menu when 'V' is released.
			local menu = getPlayerRadialMenu(0)
			if menu:isReallyVisible() then
				
				
				local boat = ISBoatMenu.getBoatInside(playerObj)
				if boat then
					ISBoatMenu.showRadialMenu(playerObj)
					return
				end
				boat = ISBoatMenu.getBoatToInteractWith(playerObj)
				if boat then
					ISBoatMenu.showRadialMenuOutside(playerObj)
					return
				end
				
				
				
			end
		end
	end
end

Events.OnKeyStartPressed.Add(ISUIBoatHandler.onKeyStartPressed);
Events.OnKeyPressed.Add(ISUIBoatHandler.onKeyPressed);

