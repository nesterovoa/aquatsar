--***********************************************************
--**                          iBrRus                       **
--***********************************************************

ISUIBoatHandler = {};

ISUIBoatHandler.onKeyStartPressed = function(key)
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	if playerObj:isDead() then return end
	if key == getCore():getKey("VehicleRadialMenu") and playerObj then
		-- 'V' can be 'Toggle UI' when outside a vehicle
		local boat = ISBoatMenu.getNearBoat(playerObj)
		if boat then
			ISBoatMenu.showRadialMenuOutside(playerObj)
			return
		end
		boat = ISBoatMenu.getBoatInside(playerObj)
		if boat then
			print("Must show")
			ISBoatMenu.showRadialMenu(playerObj)
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
				local boat = ISBoatMenu.getNearBoat(playerObj)
				if boat then
					ISBoatMenu.showRadialMenuOutside(playerObj)
					return
				end
				boat = ISBoatMenu.getBoatInside(playerObj)
				if boat then
					print("Must show")
					ISBoatMenu.showRadialMenu(playerObj)
				end
			end
		end
	end
end

Events.OnKeyStartPressed.Add(ISUIBoatHandler.onKeyStartPressed);
Events.OnKeyPressed.Add(ISUIBoatHandler.onKeyPressed);

