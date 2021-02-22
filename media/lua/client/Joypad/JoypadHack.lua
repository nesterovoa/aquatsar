-- require "Boats/ISUI/ISBoatMenu"
-- require "ISUI/ISButtonPrompt"

oldGetBestBButtonAction = ISButtonPrompt.getBestAButtonAction

function ISButtonPrompt:getBestAButtonAction(dir)
	local playerObj = getSpecificPlayer(self.player)
	oldGetBestBButtonAction(self, dir)
	
	local boat = ISBoatMenu.getBoatInside(playerObj)
    if boat then
		if boat:getPartById("InCabin" .. seatNameTable[boat:getSeat(playerObj)+1]) then
			self:setAPrompt(nil, nil, nil)
		else
			self:setAPrompt(getText("IGUI_ExitBoat"), self.cmdExitBoat, playerObj)
		end
        return
    end
	boat = ISBoatMenu.getBoatToInteractWith(playerObj)
	if boat then
		self:setAPrompt(getText("IGUI_EnterBoat"), self.cmdEnterBoat, playerObj, boat)
		return
	end
	
	if (playerObj:isSprinting() or playerObj:isRunning()) and 
			not playerObj:getSquare():Is(IsoFlagType.water) then
		self:setAPrompt(getText("IGUI_JumpInWater"), fastSwim, Keyboard.KEY_SPACE, nil, nil)
        return
    end
end

function ISButtonPrompt:cmdExitBoat(playerObj)
    ISBoatMenu.onExit(playerObj)
end

function ISButtonPrompt:cmdEnterBoat(playerObj, boat)
    ISBoatMenu.onEnter(playerObj, boat)
end

function ISDPadWheels.onDisplayUp(joypadData)
-- print("ISDPadWheels.onDisplayUp")
	local playerObj = getSpecificPlayer(joypadData.player)
	local boat = ISBoatMenu.getBoatInside(playerObj)
	if boat then
		-- print("ISDPadWheels.onDisplayUp BOAT")
		ISBoatMenu.showRadialMenu(playerObj)
		return
	end
	boat = ISBoatMenu.getBoatToInteractWith(playerObj)
	if boat then
		-- print("ISDPadWheels.onDisplayUp BOAT STREET")
		ISBoatMenu.showRadialMenuOutside(playerObj)
		return
	end
	local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)
	ISVehicleMenu.showRadialMenu(playerObj)
	-- print(vehicle:getScript():getName())
	if vehicle ~= nil and AquaConfig.Trailers[vehicle:getScript():getName()] then
		-- print("ISDPadWheels.onDisplayUp BOAT TRAILER")
		if AquaConfig.Trailers[vehicle:getScript():getName()].isWithBoat then
			ISVehicleMenuForTrailerWithBoat.launchRadialMenu(playerObj, vehicle)
		else
			ISVehicleMenuForTrailerWithBoat.loadOntoTrailerRadialMenu(playerObj, vehicle)
		end
	end
end

