-- --***********************************************************
-- --**                   	   iBrRus                         **
-- --***********************************************************

require 'Boats/Init'

ISBoatMenu = {}

function ISBoatMenu.onKeyStartPressed(key)
	local playerObj = getPlayer()
	if not playerObj then return end
	if playerObj:isDead() then return end
	if key == Keyboard.KEY_E then
		print("BOAT-E")
		local boat = playerObj:getVehicle()
		if boat == nil then
			boat = ISBoatMenu.getBoatOutside(playerObj)
			if boat then
				ISTimedActionQueue.add(ISEnterVehicle:new(playerObj, boat, 0))
			end
		elseif string.match(string.lower(boat:getScript():getName()), "boat") then
			ISBoatMenu.onExit(playerObj, 0)
		end	
	end
end

function ISBoatMenu.getBoatInside(player)
	local boat = player:getVehicle()
	if boat and string.match(string.lower(boat:getScript():getName()), "boat") then
		return boat
	end
end

function ISBoatMenu.getNearBoat(player)
	local boat = player:getNearVehicle()
	if boat and string.match(string.lower(boat:getScript():getName()), "boat") then
		return boat
	end
end

function ISBoatMenu.getBoatOutside(player)
	local boat = ISBoatMenu.getNearBoat(player)
	if boat then
		return boat
	else
		local square = player:getSquare()
		if square == nil then return nil end
		for y=square:getY() - 5, square:getY() + 5 do
			for x=square:getX() - 5, square:getX() + 5 do
				local square2 = getCell():getGridSquare(x, y, 0)
				if square2 then
					for i=1, square2:getMovingObjects():size() do
						local boat = square2:getMovingObjects():get(i-1)
						if boat~= nil and instanceof(boat, "BaseVehicle") then
							if string.match(string.lower(boat:getScript():getName()), "boat") then
								print("BOAT FOUND")
								return boat
							end
						end
					end
				end
			end
		end
	end
	return nil
end


function ISBoatMenu.getExitPoint(boat)
	local exitVector = Vector3f.new()
	boat:getAttachmentWorldPos("exitLeft", exitVector)
	local squareUnderExit = getSquare(exitVector:x(), exitVector:y(), 0)
	if squareUnderExit ~= nil then 
		local tile = squareUnderExit:getFloor():getTextureName()
		if squareUnderExit:getFloor():getSprite():getProperties():Is(IsoFlagType.water)==false then
			return exitVector
		end
	end
	boat:getAttachmentWorldPos("exitRight", exitVector)
	squareUnderExit = getSquare(exitVector:x(), exitVector:y(), 0)
	if squareUnderExit ~= nil then 
		local tile = squareUnderExit:getFloor():getTextureName()
		if squareUnderExit:getFloor():getSprite():getProperties():Is(IsoFlagType.water)==false then
			return exitVector
		end
	end
	boat:getAttachmentWorldPos("exitRear", exitVector)
	squareUnderExit = getSquare(exitVector:x(), exitVector:y(), 0)
	if squareUnderExit ~= nil then 
		local tile = squareUnderExit:getFloor():getTextureName()
		if squareUnderExit:getFloor():getSprite():getProperties():Is(IsoFlagType.water)==false then
			return exitVector
		end
	end
	return false
end

function ISBoatMenu.getNearLand(boat)
	local square = boat:getSquare()
	if square == nil then return nil end
	for y=square:getY() - 5, square:getY() + 5 do
		for x=square:getX() - 5, square:getX() + 5 do
			local square2 = getCell():getGridSquare(x, y, 0)
			if square2 then
				--print(square2)
				if not WaterBorders.isWater(square2) and square2:isNotBlocked(true) then
					return Vector3f.new(square2:getX(), square2:getY(), 0)
				end
			end
		end
	end
	return nil
end

function ISBoatMenu.onExit(playerObj, seatFrom)
    local boat = playerObj:getVehicle()
	if not boat then return end
    boat:updateHasExtendOffsetForExit(playerObj)
	if string.match(string.lower(boat:getScript():getName()), "boat") then
		if boat:getCurrentSpeedKmHour() < 1 and boat:getCurrentSpeedKmHour() > -1 then 
			local exitPoint = ISBoatMenu.getExitPoint(boat)
			print(exitPoint)	
			if exitPoint then
				print("ExitPoint found")
				ISTimedActionQueue.add(ISExitBoat:new(playerObj, exitPoint))
				return
			end
			exitPoint = ISBoatMenu.getNearLand(boat)
			if exitPoint then
				ISTimedActionQueue.add(ISExitBoat:new(playerObj, exitPoint))
				return
			end
			playerObj:Say(getText("I can not swim!"))
		end
	end
end

function ISBoatMenu.onExitAux(playerObj, seat)
	local boat = playerObj:getVehicle()
	local doorPart = boat:getPassengerDoor(seat)
	if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
		local door = doorPart:getDoor()
		if door:isLocked() then
			ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, doorPart))
		end
		if not door:isOpen() then
			ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, boat, seat))
		end
		ISTimedActionQueue.add(ISExitVehicle:new(playerObj))
		ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, boat, doorPart))
	else
		ISTimedActionQueue.add(ISExitVehicle:new(playerObj))
	end
end

-- function ISBoatMenu.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
	-- local playerObj = getSpecificPlayer(player)
	-- local boat = playerObj:getVehicle()
	-- if not boat then
		-- if JoypadState.players[player+1] then
			-- local px = playerObj:getX()
			-- local py = playerObj:getY()
			-- local pz = playerObj:getZ()
			-- local sqs = {}
			-- sqs[1] = getCell():getGridSquare(px, py, pz)
			-- local dir = playerObj:getDir()
			-- if (dir == IsoDirections.N) then        sqs[2] = getCell():getGridSquare(px-1, py-1, pz); sqs[3] = getCell():getGridSquare(px, py-1, pz);   sqs[4] = getCell():getGridSquare(px+1, py-1, pz);
			-- elseif (dir == IsoDirections.NE) then   sqs[2] = getCell():getGridSquare(px, py-1, pz);   sqs[3] = getCell():getGridSquare(px+1, py-1, pz); sqs[4] = getCell():getGridSquare(px+1, py, pz);
			-- elseif (dir == IsoDirections.E) then    sqs[2] = getCell():getGridSquare(px+1, py-1, pz); sqs[3] = getCell():getGridSquare(px+1, py, pz);   sqs[4] = getCell():getGridSquare(px+1, py+1, pz);
			-- elseif (dir == IsoDirections.SE) then   sqs[2] = getCell():getGridSquare(px+1, py, pz);   sqs[3] = getCell():getGridSquare(px+1, py+1, pz); sqs[4] = getCell():getGridSquare(px, py+1, pz);
			-- elseif (dir == IsoDirections.S) then    sqs[2] = getCell():getGridSquare(px+1, py+1, pz); sqs[3] = getCell():getGridSquare(px, py+1, pz);   sqs[4] = getCell():getGridSquare(px-1, py+1, pz);
			-- elseif (dir == IsoDirections.SW) then   sqs[2] = getCell():getGridSquare(px, py+1, pz);   sqs[3] = getCell():getGridSquare(px-1, py+1, pz); sqs[4] = getCell():getGridSquare(px-1, py, pz);
			-- elseif (dir == IsoDirections.W) then    sqs[2] = getCell():getGridSquare(px-1, py+1, pz); sqs[3] = getCell():getGridSquare(px-1, py, pz);   sqs[4] = getCell():getGridSquare(px-1, py-1, pz);
			-- elseif (dir == IsoDirections.NW) then   sqs[2] = getCell():getGridSquare(px-1, py, pz);   sqs[3] = getCell():getGridSquare(px-1, py-1, pz); sqs[4] = getCell():getGridSquare(px, py-1, pz);
			-- end
			-- for _,sq in ipairs(sqs) do
				-- boat = sq:getVehicleContainer()
				-- if boat then
					-- return ISBoatMenu.FillMenuOutsideVehicle(player, context, boat, test)
				-- end
			-- end
			-- return
		-- end
		-- boat = IsoObjectPicker.Instance:PickVehicle(getMouseXScaled(), getMouseYScaled())
		-- if boat then
			-- return ISBoatMenu.FillMenuOutsideVehicle(player, context, boat, test)
		-- end
		-- return
	-- end
-- end

function ISBoatMenu.showRadialMenu(playerObj)
	print("showRadialMenu ISBoatMenu")
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	if isPaused then return end

	local boat = playerObj:getVehicle()
	if not boat then
		-- ISBoatMenu.showRadialMenuOutside(playerObj)
		return
	end

	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
	menu:clear()

	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerObj:getPlayerNum(), nil)
		end
		menu:undisplay()
		return
	end

	menu:setX(getPlayerScreenLeft(playerObj:getPlayerNum()) + getPlayerScreenWidth(playerObj:getPlayerNum()) / 2 - menu:getWidth() / 2)
	menu:setY(getPlayerScreenTop(playerObj:getPlayerNum()) + getPlayerScreenHeight(playerObj:getPlayerNum()) / 2 - menu:getHeight() / 2)
	
	local seat = boat:getSeat(playerObj)

	-- menu:addSlice(getText("IGUI_SwitchSeat"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISBoatMenu.onShowSeatUI, playerObj, boat )

	if boat:isDriver(playerObj) and boat:isEngineWorking() then
		if boat:isEngineRunning() then
			menu:addSlice(getText("ContextMenu_VehicleShutOff"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), ISBoatMenu.onShutOff, playerObj)
		else
			if boat:isEngineStarted() then
--				menu:addSlice("Ignition", getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISBoatMenu.onStartEngine, playerObj)
			else
				if (SandboxVars.VehicleEasyUse) then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISBoatMenu.onStartEngine, playerObj)
				elseif not boat:isHotwired() and (playerObj:getInventory():haveThisKeyId(boat:getKeyId()) or boat:isKeysInIgnition()) then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISBoatMenu.onStartEngine, playerObj)
				elseif not boat:isHotwired() and ((playerObj:getPerkLevel(Perks.Electricity) >= 1 and playerObj:getPerkLevel(Perks.Mechanics) >= 2) or playerObj:HasTrait("Burglar"))then
--					menu:addSlice("Hotwire boat", getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISBoatMenu.onHotwire, playerObj)
				elseif boat:isHotwired() then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISBoatMenu.onStartEngine, playerObj)
				else
--					menu:addSlice("You need keys or\nelectricity level 1 and\nmechanic level 2\nto hotwire", getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj)
				end
			end
		end
	end

	if boat:isDriver(playerObj) and
			not boat:isHotwired() and
			not boat:isEngineStarted() and
			not boat:isEngineRunning() and
			not SandboxVars.VehicleEasyUse and
			not boat:isKeysInIgnition() and
			not playerObj:getInventory():haveThisKeyId(boat:getKeyId()) then
		if ((playerObj:getPerkLevel(Perks.Electricity) >= 1 and playerObj:getPerkLevel(Perks.Mechanics) >= 2) or playerObj:HasTrait("Burglar")) then
			menu:addSlice(getText("ContextMenu_VehicleHotwire"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISBoatMenu.onHotwire, playerObj)
		else
			menu:addSlice(getText("ContextMenu_VehicleHotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj)
		end
	end

	if boat:isDriver(playerObj) and boat:hasHeadlights() then
		if boat:getHeadlightsOn() then
			menu:addSlice(getText("ContextMenu_VehicleHeadlightsOff"), getTexture("media/ui/vehicles/vehicle_lightsOFF.png"), ISBoatMenu.onToggleHeadlights, playerObj)
		else
			menu:addSlice(getText("ContextMenu_VehicleHeadlightsOn"), getTexture("media/ui/vehicles/vehicle_lightsON.png"), ISBoatMenu.onToggleHeadlights, playerObj)
		end
	end

	if boat:getPartById("Heater") then
		local tex = getTexture("media/ui/vehicles/vehicle_temperatureHOT.png")
		if (boat:getPartById("Heater"):getModData().temperature or 0) < 0 then
			tex = getTexture("media/ui/vehicles/vehicle_temperatureCOLD.png")
		end
		if boat:getPartById("Heater"):getModData().active then
			menu:addSlice(getText("ContextMenu_VehicleHeaterOff"), tex, ISBoatMenu.onToggleHeater, playerObj )
		else
			menu:addSlice(getText("ContextMenu_VehicleHeaterOn"), tex, ISBoatMenu.onToggleHeater, playerObj )
		end
	end
	
	if boat:isDriver(playerObj) and boat:hasHorn() then
		menu:addSlice(getText("ContextMenu_VehicleHorn"), getTexture("media/ui/vehicles/vehicle_horn.png"), ISBoatMenu.onHorn, playerObj)
	end
	
	if (boat:hasLightbar()) then
		menu:addSlice(getText("ContextMenu_VehicleLightbar"), getTexture("media/ui/vehicles/vehicle_lightbar.png"), ISBoatMenu.onLightbar, playerObj)
	end

	if seat <= 1 then -- only front seats can access the radio
		for partIndex=1,boat:getPartCount() do
			local part = boat:getPartByIndex(partIndex-1)
			if part:getDeviceData() and part:getInventoryItem() then
				menu:addSlice(getText("IGUI_DeviceOptions"), getTexture("media/ui/vehicles/vehicle_speakersON.png"), ISBoatMenu.onSignalDevice, playerObj, part)
			end
		end
	end

	-- local door = boat:getPassengerDoor(seat)
	-- local windowPart = VehicleUtils.getChildWindow(door)
	-- if windowPart and (not windowPart:getItemType() or windowPart:getInventoryItem()) then
		-- local window = windowPart:getWindow()
		-- if window:isOpenable() and not window:isDestroyed() then
			-- if window:isOpen() then
				-- option = menu:addSlice(getText("ContextMenu_Close_window"), getTexture("media/ui/vehicles/vehicle_windowCLOSED.png"), ISVehiclePartMenu.onOpenCloseWindow, playerObj, windowPart, false)
			-- else
				-- option = menu:addSlice(getText("ContextMenu_Open_window"), getTexture("media/ui/vehicles/vehicle_windowOPEN.png"), ISVehiclePartMenu.onOpenCloseWindow, playerObj, windowPart, true)
			-- end
		-- end
	-- end

	-- local locked = boat:isAnyDoorLocked()
	-- if JoypadState.players[playerObj:getPlayerNum()+1] then
		-- -- Hack: Mouse players click the trunk icon in the dashboard.
		-- locked = locked or boat:isTrunkLocked()
	-- end
	-- if locked then
		-- menu:addSlice(getText("ContextMenu_Unlock_Doors"), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehiclePartMenu.onLockDoors, playerObj, boat, false)
	-- else
		-- menu:addSlice(getText("ContextMenu_Lock_Doors"), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehiclePartMenu.onLockDoors, playerObj, boat, true)
	-- end
	
--	menu:addSlice("Honk", texture, { playerObj, ISBoatMenu.onHonk })
	if boat:getCurrentSpeedKmHour() > 1 then
		menu:addSlice(getText("ContextMenu_VehicleMechanicsStopCar"), getTexture("media/ui/vehicles/vehicle_repair.png"), nil, playerObj, boat )
	else
		-- if seat == 1 then
			-- if boat:isEngineRunning() then
				-- menu:addSlice(getText("NEWContextMenu_EngineMustBeStop"), getTexture("media/ui/vehicles/vehicle_repair.png"), nil, nil, nil) -- Необходимо заглушить двигатель
			-- else
		menu:addSlice(getText("ContextMenu_VehicleMechanics"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISBoatMenu.onMechanic, playerObj, boat )
			-- end
		--end
	end
	if (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
		local doSleep = true;
		if playerObj:getStats():getFatigue() <= 0.3 then
			menu:addSlice(getText("IGUI_Sleep_NotTiredEnough"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, boat)
			doSleep = false;
		elseif boat:getCurrentSpeedKmHour() > 1 or boat:getCurrentSpeedKmHour() < -1 then
			menu:addSlice(getText("IGUI_PlayerText_CanNotSleepInMovingCar"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, boat)
			doSleep = false;
		else
			-- Sleeping pills counter those sleeping problems
			if playerObj:getSleepingTabletEffect() < 2000 then
				-- In pain, can still sleep if really tired
				if playerObj:getMoodles():getMoodleLevel(MoodleType.Pain) >= 2 and playerObj:getStats():getFatigue() <= 0.85 then
					menu:addSlice(getText("ContextMenu_PainNoSleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, boat)
					doSleep = false;
					-- In panic
				elseif playerObj:getMoodles():getMoodleLevel(MoodleType.Panic) >= 1 then
					menu:addSlice(getText("ContextMenu_PanicNoSleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, boat)
					doSleep = false;
					-- tried to sleep not so long ago
				elseif (playerObj:getHoursSurvived() - playerObj:getLastHourSleeped()) <= 1 then
					menu:addSlice(getText("ContextMenu_NoSleepTooEarly"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, boat)
					doSleep = false;
				end
			end
		end
		if doSleep then
			menu:addSlice(getText("ContextMenu_Sleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), ISBoatMenu.onSleep, playerObj, boat);
		end
	end
	menu:addSlice(getText("IGUI_ExitVehicle"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISBoatMenu.onExit, playerObj)

	menu:addToUIManager()

	if JoypadState.players[playerObj:getPlayerNum()+1] then
		menu:setHideWhenButtonReleased(Joypad.DPadUp)
		setJoypadFocus(playerObj:getPlayerNum(), menu)
		playerObj:setJoypadIgnoreAimUntilCentered(true)
	end
end

-- function ISBoatMenu.getVehicleToInteractWith(playerObj)
	-- local boat = playerObj:getVehicle()
	-- if not boat then
		-- boat = playerObj:getUseableVehicle()
	-- end
	-- if not boat then
		-- boat = playerObj:getNearVehicle()
-- --[[
		-- local px = playerObj:getX()
		-- local py = playerObj:getY()
		-- local pz = playerObj:getZ()
		-- local sqs = {}
		-- sqs[1] = getCell():getGridSquare(px, py, pz)
		-- local dir = playerObj:getDir()
		-- if (dir == IsoDirections.N) then        sqs[2] = getCell():getGridSquare(px-1, py-1, pz); sqs[3] = getCell():getGridSquare(px, py-1, pz);   sqs[4] = getCell():getGridSquare(px+1, py-1, pz);
		-- elseif (dir == IsoDirections.NE) then   sqs[2] = getCell():getGridSquare(px, py-1, pz);   sqs[3] = getCell():getGridSquare(px+1, py-1, pz); sqs[4] = getCell():getGridSquare(px+1, py, pz);
		-- elseif (dir == IsoDirections.E) then    sqs[2] = getCell():getGridSquare(px+1, py-1, pz); sqs[3] = getCell():getGridSquare(px+1, py, pz);   sqs[4] = getCell():getGridSquare(px+1, py+1, pz);
		-- elseif (dir == IsoDirections.SE) then   sqs[2] = getCell():getGridSquare(px+1, py, pz);   sqs[3] = getCell():getGridSquare(px+1, py+1, pz); sqs[4] = getCell():getGridSquare(px, py+1, pz);
		-- elseif (dir == IsoDirections.S) then    sqs[2] = getCell():getGridSquare(px+1, py+1, pz); sqs[3] = getCell():getGridSquare(px, py+1, pz);   sqs[4] = getCell():getGridSquare(px-1, py+1, pz);
		-- elseif (dir == IsoDirections.SW) then   sqs[2] = getCell():getGridSquare(px, py+1, pz);   sqs[3] = getCell():getGridSquare(px-1, py+1, pz); sqs[4] = getCell():getGridSquare(px-1, py, pz);
		-- elseif (dir == IsoDirections.W) then    sqs[2] = getCell():getGridSquare(px-1, py+1, pz); sqs[3] = getCell():getGridSquare(px-1, py, pz);   sqs[4] = getCell():getGridSquare(px-1, py-1, pz);
		-- elseif (dir == IsoDirections.NW) then   sqs[2] = getCell():getGridSquare(px-1, py, pz);   sqs[3] = getCell():getGridSquare(px-1, py-1, pz); sqs[4] = getCell():getGridSquare(px, py-1, pz);
		-- end
		-- for _,sq in ipairs(sqs) do
			-- local vehicle2 = sq:getVehicleContainer()
			-- if vehicle2 then
				-- boat = vehicle2
				-- break
			-- end
		-- end
-- --]]
	-- end
	-- return boat
-- end

function ISBoatMenu.showRadialMenuOutside(playerObj)
	if playerObj:getVehicle() then return end
	
	local playerIndex = playerObj:getPlayerNum()
	local menu = getPlayerRadialMenu(playerIndex)

	-- For keyboard, toggle visibility
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerIndex, nil)
		end
		menu:removeFromUIManager()
		return
	end

	menu:clear()

	local boat = ISBoatMenu.getNearBoat(playerObj)

	if boat then
		-- menu:addSlice(getText("ContextMenu_VehicleMechanics"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISBoatMenu.onMechanic, playerObj, boat)
		
		if boat:getScript() and boat:getScript():getPassengerCount() > 0 then
			menu:addSlice(getText("NEWIGUI_EnterBoat"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISBoatMenu.onShowSeatUI, playerObj, boat )
		end
		
		--ISBoatMenu.FillPartMenu(playerIndex, nil, menu, boat)
	
		-- local doorPart = boat:getUseablePart(playerObj)
		-- if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
			-- local isHood = doorPart:getId() == "EngineDoor"
			-- local isTrunk = doorPart:getId() == "TrunkDoor" or doorPart:getId() == "DoorRear"
			-- if doorPart:getDoor():isOpen() then
				-- local label = "ContextMenu_Close_door"
				-- if isHood then label = "IGUI_CloseHood" end
				-- if isTrunk then label = "IGUI_CloseTrunk" end
				-- menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_exit.png"), ISBoatMenu.onCloseDoor, playerObj, doorPart)
			-- else
				-- local label = "ContextMenu_Open_door"
				-- if isHood then label = "IGUI_OpenHood" end
				-- if isTrunk then label = "IGUI_OpenTrunk" end
				-- menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_exit.png"), ISBoatMenu.onOpenDoor, playerObj, doorPart)
				-- if boat:canUnlockDoor(doorPart, playerObj) then
					-- label = "ContextMenu_UnlockDoor"
					-- if isHood then label = "IGUI_UnlockHood" end
					-- if isTrunk then label = "IGUI_UnlockTrunk" end
					-- menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISBoatMenu.onUnlockDoor, playerObj, doorPart)
				-- elseif boat:canLockDoor(doorPart, playerObj) then
					-- label = "ContextMenu_LockDoor"
					-- if isHood then label = "IGUI_LockHood" end
					-- if isTrunk then label = "IGUI_LockTrunk" end
					-- menu:addSlice(getText(label), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISBoatMenu.onLockDoor, playerObj, doorPart)
				-- end
			-- end
		-- end

		local part = boat:getClosestWindow(playerObj);
		if part then
			local window = part:getWindow()
			if not window:isDestroyed() and not window:isOpen() then
				menu:addSlice(getText("ContextMenu_Vehicle_Smashwindow", getText("IGUI_VehiclePart" .. part:getId())),
					getTexture("media/ui/vehicles/vehicle_smash_window.png"),
					ISVehiclePartMenu.onSmashWindow, playerObj, part)
			end
		end

		--ISBoatMenu.doTowingMenu(playerObj, boat, menu)
	end
	
	menu:setX(getPlayerScreenLeft(playerIndex) + getPlayerScreenWidth(playerIndex) / 2 - menu:getWidth() / 2)
	menu:setY(getPlayerScreenTop(playerIndex) + getPlayerScreenHeight(playerIndex) / 2 - menu:getHeight() / 2)
	menu:addToUIManager()
	if JoypadState.players[playerObj:getPlayerNum()+1] then
		menu:setHideWhenButtonReleased(Joypad.DPadUp)
		setJoypadFocus(playerObj:getPlayerNum(), menu)
		playerObj:setJoypadIgnoreAimUntilCentered(true)
	end
end

-- function ISBoatMenu.doTowingMenu(playerObj, boat, menu)
	-- if boat:getVehicleTowing() then
		-- menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer"), getTexture("media/ui/ZoomOut.png"), ISBoatMenu.onDetachTrailer, playerObj, boat, boat:getTowAttachmentSelf())
		-- return
	-- end
	-- if boat:getVehicleTowedBy() then
		-- menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer"), getTexture("media/ui/ZoomOut.png"), ISBoatMenu.onDetachTrailer, playerObj, boat:getVehicleTowedBy(), boat:getVehicleTowedBy():getTowAttachmentSelf())
		-- return
	-- end

	-- local attachmentA, attachmentB = "trailer", "trailer"
	-- local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- if vehicleB then
		-- local aName = ISBoatMenu.getVehicleDisplayName(boat)
		-- local bName = ISBoatMenu.getVehicleDisplayName(vehicleB)
		-- local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
		-- local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
		-- local burntA = string.contains(boat:getScriptName(), "Burnt")
		-- local trailerA = string.contains(boat:getScriptName(), "Trailer")
		-- local trailerB = string.contains(vehicleB:getScriptName(), "Trailer")
		-- local vehicleTowing = boat
		-- if burntA or trailerA then
			-- vehicleTowing = vehicleB
		-- end
		-- local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
		-- if trailerA or trailerB then
			-- text = getText("ContextMenu_Vehicle_AttachTrailer");
		-- end
		-- menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISBoatMenu.onAttachTrailer, playerObj, vehicleTowing, attachmentA, attachmentB)
		-- return
	-- end

	-- attachmentA, attachmentB = "trailerfront", "trailerfront"
	-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- if vehicleB then
		-- local aName = ISBoatMenu.getVehicleDisplayName(vehicleB)
		-- local bName = ISBoatMenu.getVehicleDisplayName(boat)
		-- local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
		-- local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
		-- local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
		-- menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISBoatMenu.onAttachTrailer, playerObj, boat, attachmentB, attachmentA)
		-- return
	-- end

	-- attachmentA, attachmentB = "trailer", "trailerfront"
	-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- if vehicleB then
		-- local aName = ISBoatMenu.getVehicleDisplayName(boat)
		-- local bName = ISBoatMenu.getVehicleDisplayName(vehicleB)
		-- local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
		-- local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
		-- local attachName = getText("IGUI_TrailerAttachName_" .. attachmentA)
		-- local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
		-- menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISBoatMenu.onAttachTrailer, playerObj, boat, attachmentA, attachmentB)
		-- return
	-- end

	-- attachmentA, attachmentB = "trailerfront", "trailer"
	-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- if vehicleB then
		-- local aName = ISBoatMenu.getVehicleDisplayName(vehicleB)
		-- local bName = ISBoatMenu.getVehicleDisplayName(boat)
		-- local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
		-- local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
		-- local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
		-- menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISBoatMenu.onAttachTrailer, playerObj, vehicleB, attachmentB, attachmentA)
		-- return
	-- end
-- end

-- local TowMenu = {}

-- function TowMenu.isBurnt(boat)
	-- return string.contains(boat:getScriptName(), "Burnt")
-- end

-- function TowMenu.isTrailer(boat)
	-- return string.contains(boat:getScriptName(), "Trailer")
-- end

-- function TowMenu.attachBurntToOther(playerObj, boat, menu)
	-- local attachmentA, attachmentB = "trailer", "trailer"
	-- local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailer", "trailerfront"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailerfront", "trailer"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailerfront", "trailerfront"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if vehicleB then
		-- if TowMenu.isBurnt(vehicleB) then
			-- TowMenu.addOption(playerObj, menu, boat, vehicleB, attachmentA, attachmentB)
		-- elseif TowMenu.isTrailer(vehicleB) then
			-- TowMenu.addOption(playerObj, menu, boat, vehicleB, attachmentA, attachmentB)
		-- else
			-- TowMenu.addOption(playerObj, menu, vehicleB, boat, attachmentB, attachmentA)
		-- end
	-- end
-- end

-- function TowMenu.attachTrailerToOther(playerObj, boat, menu)
	-- local attachmentA, attachmentB = "trailer", "trailer"
	-- local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailer", "trailerfront"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if vehicleB then
		-- if TowMenu.isBurnt(vehicleB) then
			-- TowMenu.addOption(playerObj, menu, vehicleB, boat, attachmentB, attachmentA)
		-- elseif TowMenu.isTrailer(vehicleB) then
			-- TowMenu.addOption(playerObj, menu, boat, vehicleB, attachmentA, attachmentB)
		-- else
			-- TowMenu.addOption(playerObj, menu, vehicleB, boat, attachmentB, attachmentA)
		-- end
	-- end
-- end

-- function TowMenu.attachVehicleToOther(playerObj, boat, menu)
	-- local attachmentA, attachmentB = "trailer", "trailer"
	-- local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailer", "trailerfront"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailerfront", "trailer"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if not vehicleB then
		-- attachmentA, attachmentB = "trailerfront", "trailerfront"
		-- vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(boat:getSquare(), boat, attachmentA, attachmentB)
	-- end

	-- if vehicleB then
		-- if TowMenu.isBurnt(vehicleB) then
			-- TowMenu.addOption(playerObj, menu, boat, vehicleB, attachmentA, attachmentB)
		-- elseif TowMenu.isTrailer(vehicleB) then
			-- TowMenu.addOption(playerObj, menu, boat, vehicleB, attachmentA, attachmentB)
		-- else
			-- TowMenu.addOption(playerObj, menu, boat, vehicleB, attachmentA, attachmentB)
		-- end
	-- end
-- end

-- function TowMenu.addOption(playerObj, menu, vehicleA, vehicleB, attachmentA, attachmentB)
	-- local aName = ISBoatMenu.getVehicleDisplayName(vehicleA)
	-- local bName = ISBoatMenu.getVehicleDisplayName(vehicleB)
	-- local text = getText("ContextMenu_Vehicle_AttachTrailer", bName, aName);
	-- menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISBoatMenu.onAttachTrailer, playerObj, vehicleA, attachmentA, attachmentB)
-- end

-- function ISBoatMenu.doTowingMenu(playerObj, boat, menu)
	-- if boat:getVehicleTowing() then
		-- local bName = ISBoatMenu.getVehicleDisplayName(boat:getVehicleTowing())
		-- menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer", bName), getTexture("media/ui/ZoomOut.png"), ISBoatMenu.onDetachTrailer, playerObj, boat, boat:getTowAttachmentSelf())
		-- return
	-- end

	-- if boat:getVehicleTowedBy() then
		-- local aName = ISBoatMenu.getVehicleDisplayName(boat)
		-- menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer", aName), getTexture("media/ui/ZoomOut.png"), ISBoatMenu.onDetachTrailer, playerObj, boat:getVehicleTowedBy(), boat:getVehicleTowedBy():getTowAttachmentSelf())
		-- return
	-- end

	-- if TowMenu.isBurnt(boat) then
		-- TowMenu.attachBurntToOther(playerObj, boat, menu)
	-- elseif TowMenu.isTrailer(boat) then
		-- TowMenu.attachTrailerToOther(playerObj, boat, menu)
	-- else
		-- TowMenu.attachVehicleToOther(playerObj, boat, menu)
	-- end
-- end

-- function ISBoatMenu.FillMenuOutsideVehicle(player, context, boat, test)
	-- local playerObj = getSpecificPlayer(player)
-- --[[
	-- local subOption = context:addOption("boat")
	-- local vehicleMenu = ISContextMenu:getNew(context)
	-- context:addSubMenu(subOption, vehicleMenu)
	-- vehicleMenu:addOption("Info", playerObj, ISBoatMenu.onInfo, boat)
-- --]]
-- --	context:addOption("boat Info", playerObj, ISBoatMenu.onInfo, boat)
	-- ISBoatMenu.FillPartMenu(player, context, nil, boat);
	
	-- context:addOption(getText("ContextMenu_VehicleMechanics"), playerObj, ISBoatMenu.onMechanic, boat);
	
	-- local part = boat:getClosestWindow(playerObj);
	-- if part then
		-- local window = part:getWindow()
		-- if not window:isDestroyed() and not window:isOpen() then
			-- context:addOption(getText("ContextMenu_Vehicle_Smashwindow", getText("IGUI_VehiclePart" .. part:getId())), playerObj, ISVehiclePartMenu.onSmashWindow, part)
		-- end
	-- end
	
	-- -- remove burnt vehicles
	-- if string.match(boat:getScript():getName(), "Burnt") then
		-- local option = context:addOption(getText("ContextMenu_RemoveBurntVehicle"), playerObj, ISBoatMenu.onRemoveBurntVehicle, boat);
		-- local toolTip = ISToolTip:new();
		-- toolTip:initialise();
		-- toolTip:setVisible(false);
		-- option.toolTip = toolTip;
		-- toolTip:setName(getText("ContextMenu_RemoveBurntVehicle"));
		-- toolTip.description = getText("Tooltip_removeBurntVehicle") .. " <LINE> <LINE> ";
		
		-- if playerObj:getInventory():containsTypeRecurse("WeldingMask") then
			-- toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.WeldingMask") .. " 1/1";
		-- else
			-- toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingMask") .. " 0/1";
			-- option.notAvailable = true;
		-- end
		
		-- local blowTorch = ISBlacksmithMenu.getBlowTorchWithMostUses(playerObj:getInventory());
		-- if blowTorch then
			-- local blowTorchUseLeft = blowTorch:getDrainableUsesInt();
			-- if blowTorchUseLeft >= 20 then
				-- toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.BlowTorch") .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. 20;
			-- else
				-- toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. 20;
				-- option.notAvailable = true;
			-- end
		-- else
			-- toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " 0/5";
			-- option.notAvailable = true;
		-- end
	-- end

	-- if ISWashVehicle.hasBlood(boat) then
		-- local option = context:addOption(getText("ContextMenu_Vehicle_Wash"), playerObj, ISBoatMenu.onWash, boat);
		-- local toolTip = ISToolTip:new();
		-- toolTip:initialise();
		-- toolTip:setVisible(false);
		-- toolTip:setName(getText("Tooltip_Vehicle_WashTitle"));
		-- toolTip.description = getText("Tooltip_Vehicle_WashWaterRequired1", 100 / ISWashVehicle.BLOOD_PER_WATER);
		-- local waterAvailable = ISWashVehicle.getWaterAmountForPlayer(playerObj);
		-- option.notAvailable = waterAvailable <= 0
		-- if waterAvailable == 1 then
			-- toolTip.description = toolTip.description .. " <BR> " .. getText("Tooltip_Vehicle_WashWaterRequired2");
		-- else
			-- toolTip.description = toolTip.description .. " <BR> " .. getText("Tooltip_Vehicle_WashWaterRequired3", waterAvailable);
		-- end
		-- option.toolTip = toolTip;
	-- end

	-- local vehicleMenu = nil
	-- if getCore():getDebug() or ISVehicleMechanics.cheat or (isClient() and isAdmin()) then
		-- local subOption = context:addOption("[DEBUG] boat")
		-- vehicleMenu = ISContextMenu:getNew(context)
		-- context:addSubMenu(subOption, vehicleMenu)
	-- end
	
	-- if getCore():getDebug() then
		-- vehicleMenu:addOption("Reload boat Textures", boat:getScript():getName(), reloadVehicleTextures)
		-- if ISVehicleMechanics.cheat then
			-- vehicleMenu:addOption("ISVehicleMechanics.cheat=false", playerObj, ISVehicleMechanics.onCheatToggle)
		-- else
			-- vehicleMenu:addOption("ISVehicleMechanics.cheat=true", playerObj, ISVehicleMechanics.onCheatToggle)
		-- end
		-- vehicleMenu:addOption("Roadtrip UI", playerObj, ISBoatMenu.onRoadtrip);
		-- vehicleMenu:addOption("boat Angles UI", playerObj, ISBoatMenu.onDebugAngles, boat);
		-- vehicleMenu:addOption("boat HSV UI", playerObj, ISBoatMenu.onDebugColor, boat);
		-- vehicleMenu:addOption("boat Blood UI", playerObj, ISBoatMenu.onDebugBlood, boat);
		-- vehicleMenu:addOption("boat Editor", playerObj, ISBoatMenu.onDebugEditor, boat);
		-- if not isClient() then
			-- ISBoatMenu.addSetScriptMenu(vehicleMenu, playerObj, boat)
		-- end
	-- end
	
	-- if getCore():getDebug() or ISVehicleMechanics.cheat or (isClient() and isAdmin()) then
		-- vehicleMenu:addOption("Remove boat", playerObj, ISVehicleMechanics.onCheatRemove, boat);
	-- end
-- end

-- function ISBoatMenu.getVehicleDisplayName(boat)
	-- local name = getText("IGUI_VehicleName" .. boat:getScript():getName())
	-- if string.match(boat:getScript():getName(), "Burnt") then
		-- local unburnt = string.gsub(boat:getScript():getName(), "Burnt", "")
		-- if getTextOrNull("IGUI_VehicleName" .. unburnt) then
			-- name = getText("IGUI_VehicleName" .. unburnt)
		-- end
		-- name = getText("IGUI_VehicleNameBurntCar", name)
	-- end
	-- return name
-- end

-- local function predicateBlowTorch(item)
	-- return item:getType() == "BlowTorch" and item:getDrainableUsesInt() >= 20
-- end

-- function ISBoatMenu.onRemoveBurntVehicle(player, boat)
	-- if luautils.walkAdj(player, boat:getSquare()) then
		-- ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), predicateBlowTorch, true);
		-- local mask = player:getInventory():getFirstTypeRecurse("WeldingMask");
		-- if mask then
			-- ISInventoryPaneContextMenu.wearItem(mask, player:getPlayerNum());
		-- end
		-- ISTimedActionQueue.add(ISRemoveBurntVehicle:new(player, boat));
	-- end
-- end

-- function ISBoatMenu.onRoadtrip(playerObj)
	-- local ui = ISVehicleRoadtripDebug:new(0, 0, playerObj);
	-- ui:initialise();
	-- ui:addToUIManager();
-- end

-- function ISBoatMenu.onDebugAngles(playerObj, boat)
	-- debugVehicleAngles(boat)
-- end

-- function ISBoatMenu.onDebugColor(playerObj, boat)
	-- debugVehicleColor(boat)
-- end

-- function ISBoatMenu.onDebugBlood(playerObj, boat)
	-- debugVehicleBloodUI(boat)
-- end

-- function ISBoatMenu.onDebugEditor(playerObj, boat)
	-- showVehicleEditor(boat:getScript():getFullName())
-- end

-- function ISBoatMenu.addSetScriptMenu(context, playerObj, boat)
	-- local option = context:addOption("Set Script", nil, nil)
	-- local subMenu = ISContextMenu:getNew(context)
	-- context:addSubMenu(option, subMenu)

	-- local optionBurnt = context:addOption("Set Script (Burnt)", nil, nil)
	-- local subMenuBurnt = ISContextMenu:getNew(context)
	-- context:addSubMenu(optionBurnt, subMenuBurnt)

	-- local scripts = getScriptManager():getAllVehicleScripts()
	-- local sorted = {}
	-- for i=1,scripts:size() do
		-- local script = scripts:get(i-1)
		-- table.insert(sorted, script)
	-- end
	-- table.sort(sorted, function(a,b) return not string.sort(a:getName(), b:getName()) end)
	-- for _,script in ipairs(sorted) do
		-- if script:getPartCount() == 0 then
			-- subMenuBurnt:addOption(script:getName(), playerObj, ISBoatMenu.onDebugSetScript, boat, script:getFullName())
		-- else
			-- subMenu:addOption(script:getName(), playerObj, ISBoatMenu.onDebugSetScript, boat, script:getFullName())
		-- end
	-- end
-- end

-- function ISBoatMenu.onDebugSetScript(playerObj, boat, scriptName)
	-- boat:setScriptName(scriptName)
	-- boat:scriptReloaded()
	-- boat:setSkinIndex(ZombRand(boat:getSkinCount()))
	-- boat:repair() -- so engine loudness/power/quality are recalculated
-- end

function ISBoatMenu.onMechanic(playerObj, boat)
	local ui = getPlayerMechanicsUI(playerObj:getPlayerNum())
	if ui:isReallyVisible() then
		ui:close()
		return
	end

	local engineHood = nil;
	local cheat = getCore():getDebug() and getDebugOptions():getBoolean("Cheat.boat.MechanicsAnywhere")
	-- if ISVehicleMechanics.cheat or (isClient() and isAdmin()) or cheat then
		-- ISTimedActionQueue.add(ISOpenMechanicsUIAction:new(playerObj, boat))
		-- return;
	-- end
	--engineHood = boat:getPartById("EngineDoor");
	-- if playerObj:getVehicle() then
		-- ISBoatMenu.onExit(playerObj)
	-- end
--		local closestDist;
--		local closestPart;
--		for i=0,boat:getPartCount()-1 do
--			local part = boat:getPartByIndex(i);
--			if (part:getCategory() == "tire" or part:getCategory() == "bodywork") and (not closestDist or closestDist > boat:getAreaDist(part:getArea(), playerObj))then
----				print("TIRE: ", part:getId(), " CLOSER");
--				closestDist = boat:getAreaDist(part:getArea(), playerObj);
--				closestPart = part;
--			end
--		end
	-- if engineHood then
		-- ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, engineHood:getArea()))
		-- if not engineHood:getDoor() or not engineHood:getInventoryItem() then
			-- engineHood = nil
		-- end
		-- if engineHood and not engineHood:getDoor():isOpen() then
			-- -- The hood is magically unlocked if any door/window is broken/open/uninstalled.
			-- -- If the player can get in the boat, they can pop the hood, no key required.
			-- if engineHood:getDoor():isLocked() and VehicleUtils.RequiredKeyNotFound(boat:getPartById("Engine"), playerObj) then
				-- ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, engineHood))
			-- end
			-- ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, boat, engineHood))
		-- end
	-- else
		-- -- Burned vehicles and trailers don't have a hood
		-- ISTimedActionQueue.add(ISPathFindAction:pathToVehicleAdjacent(playerObj, boat))
	-- end
	local data = getPlayerData(playerObj:getPlayerNum())
	print(data.mechanicsUI)
	data.mechanicsUI = ISBoatMechanics:new(0,0,playerObj,nil);
    data.mechanicsUI:setVisible(false);
    data.mechanicsUI:setEnabled(false);
	data.mechanicsUI:initialise();
	--data.mechanicsUI:addToUIManager();
	print(playerObj)
	print(boat)
	
	ISTimedActionQueue.add(ISOpenMechanicsUIAction:new(playerObj, boat, engineHood))
--	local ui = ISVehicleMechanics:new(0,0,playerObj,boat);
--	ui:initialise();
--	ui:addToUIManager();
--	local ui = getPlayerMechanicsUI(playerObj:getPlayerNum());
--	if ui:isReallyVisible() then
--		ui:close()
--		return
--	end
--	ui.boat = boat;
--	ui.usedHood = usedHood
--	ui:initParts();
--	ui:setVisible(true, JoypadState.players[playerObj:getPlayerNum()+1])
--	ui:addToUIManager()
	
--print("ONMECHANIC")
	-- get the closest tire to the player
--	local closestDist;
--	local closestPart;
--	for i=0,boat:getPartCount()-1 do
--		local part = boat:getPartByIndex(i);
--		if part:getCategory() == "tire" and (not closestDist or closestDist < boat:getAreaDist(part:getArea(), playerObj))then
--			print("TIRE: ", part:getId(), " CLOSER");
--			closestDist = boat:getAreaDist(part:getArea(), playerObj);
--			closestPart = part:getId();
--		end
--	end
--	local tire = boat:getPartById(closestPart);
--	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, tire:getArea()))
--	closestPart = ISBoatMenu.getNextTire(closestPart);
--	local tire = boat:getPartById(closestPart);
--	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, tire:getArea()))
--	closestPart = ISBoatMenu.getNextTire(closestPart);
--	local tire = boat:getPartById(closestPart);
--	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, tire:getArea()))
--	closestPart = ISBoatMenu.getNextTire(closestPart);
--	local tire = boat:getPartById(closestPart);
--	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, tire:getArea()))
--	local tire = boat:getPartById("TireFrontRight");
--	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, tire:getArea()))
end

-- -- cicle thru each tires clockwise
-- function ISBoatMenu.getNextTire(currentTire)
	-- if currentTire == "TireFrontLeft" then return "TireFrontRight"; end
	-- if currentTire == "TireFrontRight" then return "TireRearRight"; end
	-- if currentTire == "TireRearRight" then return "TireRearLeft"; end
	-- if currentTire == "TireRearLeft" then return "TireFrontLeft"; end
-- end

-- function ISBoatMenu.FillPartMenu(playerIndex, context, slice, boat)
	-- local playerObj = getSpecificPlayer(playerIndex);
	-- local typeToItem = VehicleUtils.getItems(playerIndex)
	-- for i=1,boat:getPartCount() do
		-- local part = boat:getPartByIndex(i-1)
		-- if not boat:isEngineStarted() and part:isContainer() and part:getContainerContentType() == "Gasoline" then
			-- if typeToItem["Base.PetrolCan"] and part:getContainerContentAmount() < part:getContainerCapacity() then
				-- if slice then
					-- slice:addSlice(getText("ContextMenu_VehicleAddGas"), getTexture("Item_Petrol"), ISVehiclePartMenu.onAddGasoline, playerObj, part)
				-- else
					-- context:addOption(getText("ContextMenu_VehicleAddGas"), playerObj,ISVehiclePartMenu.onAddGasoline, part)
				-- end
			-- end
			-- if ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem) and part:getContainerContentAmount() > 0 then
				-- if slice then
					-- slice:addSlice(getText("ContextMenu_VehicleSiphonGas"), getTexture("Item_Petrol"), ISVehiclePartMenu.onTakeGasoline, playerObj, part)
				-- else
					-- context:addOption(getText("ContextMenu_VehicleSiphonGas"), playerObj, ISVehiclePartMenu.onTakeGasoline, part)
				-- end
			-- end
			-- local square = ISVehiclePartMenu.getNearbyFuelPump(boat)
			-- if square and ((SandboxVars.AllowExteriorGenerator and square:haveElectricity()) or (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier)) then
				-- if square and part:getContainerContentAmount() < part:getContainerCapacity() then
					-- if slice then
						-- slice:addSlice(getText("ContextMenu_VehicleRefuelFromPump"), getTexture("media/ui/vehicles/vehicle_refuel_from_pump.png"), ISVehiclePartMenu.onPumpGasoline, playerObj, part)
					-- else
						-- context:addOption(getText("ContextMenu_VehicleRefuelFromPump"), playerObj, ISVehiclePartMenu.onPumpGasoline, part)
					-- end
				-- end
			-- end
		-- end
	-- end
-- end

-- function ISBoatMenu.onSwitchSeat(playerObj, seatTo)
	-- local boat = playerObj:getVehicle()
	-- if not boat then return end
	-- ISTimedActionQueue.add(ISSwitchVehicleSeat:new(playerObj, seatTo))
-- end

function ISBoatMenu.onToggleHeadlights(playerObj)
	local boat = playerObj:getVehicle()
	if not boat then return end
	sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = not boat:getHeadlightsOn() })
end

-- function ISBoatMenu.onToggleTrunkLocked(playerObj)
	-- local boat = playerObj:getVehicle();
	-- if not boat then return end
	-- sendClientCommand(playerObj, 'vehicle', 'setTrunkLocked', { locked = not boat:isTrunkLocked() });
-- end

function ISBoatMenu.onToggleHeater(playerObj)
	local playerNum = playerObj:getPlayerNum()
	if not ISBoatMenu.acui then
		ISBoatMenu.acui = {}
	end
	local ui = ISBoatMenu.acui[playerNum]
	if not ui or ui.character ~= playerObj then
		ui = ISVehicleACUI:new(0,0,playerObj)
		ui:initialise()
		ui:instantiate()
		ISBoatMenu.acui[playerNum] = ui
	end
	if ui:isReallyVisible() then
		ui:removeFromUIManager()
		if JoypadState.players[playerNum+1] then
			setJoypadFocus(playerNum, nil)
		end
	else
		ui:setVehicle(playerObj:getVehicle())
		ui:addToUIManager()
		if JoypadState.players[playerNum+1] then
			JoypadState.players[playerNum+1].focus = ui
		end
	end
end

function ISBoatMenu.onSignalDevice(playerObj, part)
	ISRadioWindow.activate(playerObj, part)
end

function ISBoatMenu.onStartEngine(playerObj)
--	local boat = playerObj:getVehicle()
--	if not boat then return end
--	if not boat:isEngineWorking() then return end
--	if not boat:isDriver(playerObj) then return end
	ISTimedActionQueue.add(ISStartVehicleEngine:new(playerObj))
end

function ISBoatMenu.onHotwire(playerObj)
	ISTimedActionQueue.add(ISHotwireVehicle:new(playerObj))
end

function ISBoatMenu.onShutOff(playerObj)
--	local boat = playerObj:getVehicle()
--	if not boat then return end
--	if not boat:isEngineStarted() then return end
--	if not boat:isDriver(playerObj) then return end
	ISTimedActionQueue.add(ISShutOffVehicleEngine:new(playerObj))
end

-- function ISBoatMenu.onInfo(playerObj, boat)
	-- local ui = getPlayerVehicleUI(playerObj:getPlayerNum())
	-- ui:setVehicle(boat)
	-- ui:setVisible(true)
	-- ui:bringToTop()
	-- if JoypadState.players[playerObj:getPlayerNum()+1] then
		-- JoypadState.players[playerObj:getPlayerNum()+1].focus = ui
	-- end
-- end

-- function ISBoatMenu.onSleep(playerObj, boat)
	-- if boat:getCurrentSpeedKmHour() > 1 or boat:getCurrentSpeedKmHour() < -1 then
		-- playerObj:Say(getText("IGUI_PlayerText_CanNotSleepInMovingCar"))
		-- return;
	-- end
	-- local playerNum = playerObj:getPlayerNum()
	-- local modal = ISModalDialog:new(0,0, 250, 150, getText("IGUI_ConfirmSleep"), true, nil, ISBoatMenu.onConfirmSleep, playerNum, playerNum, nil);
	-- modal:initialise()
	-- modal:addToUIManager()
	-- if JoypadState.players[playerNum+1] then
		-- setJoypadFocus(playerNum, modal)
	-- end
-- end

-- function ISBoatMenu.onConfirmSleep(this, button, player, bed)
	-- if button.internal == "YES" then
		-- ISWorldObjectContextMenu.onSleepWalkToComplete(player, nil)
	-- end
-- end

-- function ISBoatMenu.onOpenDoor(playerObj, part)
	-- local boat = part:getVehicle()
	-- if part:getDoor():isLocked() then
		-- -- The hood is magically unlocked if any door/window is broken/open/uninstalled.
		-- -- If the player can get in the boat, they can pop the hood, no key required.
		-- if not (part:getId() == "EngineDoor" and VehicleUtils.RequiredKeyNotFound(part, playerObj)) then
			-- ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, part))
		-- end
	-- end
	-- ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, part:getVehicle(), part))
	-- if part:getId() == "EngineDoor" then
		-- ISTimedActionQueue.add(ISOpenMechanicsUIAction:new(playerObj, boat, part))
	-- end
-- end

-- function ISBoatMenu.onCloseDoor(playerObj, part)
	-- ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, part:getVehicle(), part))
-- end

-- function ISBoatMenu.onLockDoor(playerObj, part)
	-- ISTimedActionQueue.add(ISLockVehicleDoor:new(playerObj, part))
-- end

-- function ISBoatMenu.onUnlockDoor(playerObj, part)
	-- ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, part))
-- end

-- function ISBoatMenu.onWash(playerObj, boat)
	-- local area = ISWashVehicle.chooseArea(playerObj, boat)
	-- if not area then return end
	-- ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, boat, area.area))
	-- ISTimedActionQueue.add(ISWashVehicle:new(playerObj, boat, area.id, area.area))
-- end

-- local SORTVARS = {
	-- pos = Vector3f.new()
-- }
-- local function distanceToPassengerPosition(seat)
	-- local script = SORTVARS.boat:getScript()
	-- local outside = SORTVARS.boat:getPassengerPosition(seat, "outside")
	-- local worldPos = SORTVARS.boat:getWorldPos(outside:getOffset(), SORTVARS.pos)
	-- return SORTVARS.playerObj:DistTo(worldPos:x(), worldPos:y())
-- end
-- local function getClosestSeat(playerObj, boat, seats)
	-- if #seats == 0 then
		-- return nil
	-- end
	-- -- Sort by distance from the player to the 'outside' position.
	-- SORTVARS.playerObj = playerObj
	-- SORTVARS.boat = boat
	-- table.sort(seats, function(a,b)
		-- local distA = distanceToPassengerPosition(a)
		-- local distB = distanceToPassengerPosition(b)
		-- return distA < distB
	-- end)
	-- return seats[1]
-- end

-- -- BaseVehicle.isEnterBlocked() returns true for passengers with no "outside"
-- -- position, which is the case for VanSeats' rear seats that are not accessible
-- -- by any door.  The player must enter through a front or middle door then
-- -- switch to the rear seat.
-- function ISBoatMenu.getBestSwitchSeatEnter(playerObj, boat, seat)
	-- local seats = {}
	-- for seat2=0,boat:getMaxPassengers()-1 do
		-- if seat ~= seat2 and
				-- boat:canSwitchSeat(seat2, seat) and
				-- not boat:isSeatOccupied(seat2) and
				-- not boat:isEnterBlocked(playerObj, seat2) then
			-- table.insert(seats, seat2)
		-- end
	-- end
	-- return getClosestSeat(playerObj, boat, seats)
-- end

-- function ISBoatMenu.getBestSwitchSeatExit(playerObj, boat, seat)
	-- local seats = {}
	-- for seat2=0,boat:getMaxPassengers()-1 do
		-- if seat ~= seat2 and
				-- boat:canSwitchSeat(seat, seat2) and
				-- not boat:isSeatOccupied(seat2) and
				-- not boat:isExitBlocked(seat2) then
			-- table.insert(seats, seat2)
		-- end
	-- end
	-- return getClosestSeat(playerObj, boat, seats)
-- end

-- function ISBoatMenu.moveItemsOnSeat(seat, newSeat, playerObj, moveThem, itemListIndex)
-- --	if moveThem then print("moving item on seat from", seat:getId(), "to", newSeat:getId()) end
	-- local itemList = {};
	-- local actualWeight = newSeat:getItemContainer():getCapacityWeight();
	-- for i=itemListIndex,seat:getItemContainer():getItems():size() -1 do
		-- local item = seat:getItemContainer():getItems():get(i);
		-- actualWeight = actualWeight + item:getUnequippedWeight();
		-- if newSeat:getItemContainer():hasRoomFor(playerObj, actualWeight) then
			-- table.insert(itemList, item);
		-- else
			-- break;
		-- end
	-- end
	-- if moveThem then
		-- for i,v in ipairs(itemList) do
			-- ISTimedActionQueue.add(ISInventoryTransferAction:new (playerObj, v, seat:getItemContainer(), newSeat:getItemContainer(), 10));
-- --			seat:getItemContainer():Remove(v);
-- --			newSeat:getItemContainer():AddItem(v);
		-- end
	-- end
	-- return #itemList + itemListIndex;
-- end

-- function ISBoatMenu.tryMoveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter, seatTo, itemListIndex)
	-- local currentSeat = boat:getPartForSeatContainer(seat);
	-- if currentSeat:getItemContainer():getItems():isEmpty() then return 0; end
	-- local newSeat = boat:getPartById(seatTo);
	-- if not newSeat then return 0; end
	-- if newSeat == currentSeat or (boat:getCharacter(newSeat:getContainerSeatNumber()) and playerObj ~= boat:getCharacter(newSeat:getContainerSeatNumber())) then return 0; end
	-- if newSeat then
		-- local movedItems = ISBoatMenu.moveItemsOnSeat(currentSeat, newSeat, playerObj, moveThem, itemListIndex);
		-- if doEnter and (movedItems == currentSeat:getItemContainer():getItems():size() or movedItems == currentSeat:getItemContainer():getItems():isEmpty()) then
			-- ISBoatMenu.processEnter(playerObj, boat, seat);
			-- return movedItems;
		-- end
		-- return movedItems;
	-- end
	-- return 0;
-- end

-- function ISBoatMenu.moveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter)
	-- -- if items are on the seats we'll try to move them to another empty seat, first rear seat then middle, then front left seats, never on driver's seat
	-- -- first rear seats
	-- local currentSeat = boat:getPartForSeatContainer(seat);
	-- local movedItems = ISBoatMenu.tryMoveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter, "SeatRearLeft", 0);
	-- if movedItems == currentSeat:getItemContainer():getItems():size() then return true; end
	-- movedItems = ISBoatMenu.tryMoveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter, "SeatRearRight", movedItems);
	-- if movedItems == currentSeat:getItemContainer():getItems():size() then return true; end
	-- movedItems = ISBoatMenu.tryMoveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter, "SeatFrontRight", movedItems);
	-- if movedItems == currentSeat:getItemContainer():getItems():size() then return true; end
	-- movedItems = ISBoatMenu.tryMoveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter, "SeatMiddleLeft", movedItems);
	-- if movedItems == currentSeat:getItemContainer():getItems():size() then return true; end
	-- movedItems = ISBoatMenu.tryMoveItemsFromSeat(playerObj, boat, seat, moveThem, doEnter, "SeatMiddleRight", movedItems);
	-- if movedItems == currentSeat:getItemContainer():getItems():size() then return true; end
	-- return false;
-- end

-- function ISBoatMenu.onEnter(playerObj, boat, seat)
	-- if boat:isSeatOccupied(seat) then
		-- if boat:getCharacter(seat) then
			-- playerObj:Say(getText("IGUI_PlayerText_VehicleSomeoneInSeat"))
		-- else
			-- if not ISBoatMenu.moveItemsFromSeat(playerObj, boat, seat, true, true) then
				-- playerObj:Say(getText("IGUI_PlayerText_VehicleItemInSeat"))
			-- end
		-- end
	-- else
		-- if boat:isPassengerUseDoor2(playerObj, seat) then
			-- ISBoatMenu.processEnter2(playerObj, boat, seat);
		-- else 
			-- ISBoatMenu.processEnter(playerObj, boat, seat);
		-- end
	-- end
-- end

-- function ISBoatMenu.processEnter(playerObj, boat, seat)
	-- if not boat:isSeatInstalled(seat) then
		-- playerObj:Say(getText("IGUI_PlayerText_VehicleSeatRemoved"))
	-- elseif not playerObj:isBlockMovement() then
		-- if boat:isEnterBlocked(playerObj, seat) then
			-- local seat2 = ISBoatMenu.getBestSwitchSeatEnter(playerObj, boat, seat)
			-- if seat2 then
				-- ISBoatMenu.onEnterAux(playerObj, boat, seat2)
				-- ISTimedActionQueue.add(ISSwitchVehicleSeat:new(playerObj, seat))
			-- end
		-- else
			-- ISBoatMenu.onEnterAux(playerObj, boat, seat)
		-- end
	-- end
-- end

-- function ISBoatMenu.onEnterAux(playerObj, boat, seat)
		-- ISTimedActionQueue.add(ISPathFindAction:pathToVehicleSeat(playerObj, boat, seat))
		-- local doorPart = boat:getPassengerDoor(seat)
		-- if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
			-- local door = doorPart:getDoor()
			-- if door:isLocked() then
				-- -- if the keys on on the car, we take them and open
				-- if boat:isKeyIsOnDoor() then
					-- local key = boat:getCurrentKey()
					-- boat:setKeyIsOnDoor(false);
					-- boat:setCurrentKey(nil)
					-- playerObj:getInventory():AddItem(key)
					-- if isClient() then
						-- sendClientCommand(playerObj, 'vehicle', 'removeKeyFromDoor', { boat = boat:getId() })
					-- end
				-- else
					-- ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, doorPart, seat))
				-- end
			-- end
			-- if not door:isOpen() then
				-- ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, boat, doorPart))
			-- end
			-- ISTimedActionQueue.add(ISEnterVehicle:new(playerObj, boat, seat))
			-- ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, boat, seat))
		-- else
			-- ISTimedActionQueue.add(ISEnterVehicle:new(playerObj, boat, seat))
		-- end
-- end

-- function ISBoatMenu.onEnter2(playerObj, boat, seat)
	-- if boat:isSeatOccupied(seat) then
		-- if boat:getCharacter(seat) then
			-- playerObj:Say(getText("IGUI_PlayerText_VehicleSomeoneInSeat"))
		-- else
			-- if not ISBoatMenu.moveItemsFromSeat(playerObj, boat, seat, true, true) then
				-- playerObj:Say(getText("IGUI_PlayerText_VehicleItemInSeat"))
			-- end
		-- end
	-- else
		-- ISBoatMenu.processEnter2(playerObj, boat, seat);
	-- end
-- end

-- function ISBoatMenu.processEnter2(playerObj, boat, seat)
	-- if not boat:isSeatInstalled(seat) then
		-- playerObj:Say(getText("IGUI_PlayerText_VehicleSeatRemoved"))
	-- elseif not playerObj:isBlockMovement() then
		-- if boat:isEnterBlocked2(playerObj, seat) then
			-- local seat2 = ISBoatMenu.getBestSwitchSeatEnter(playerObj, boat, seat)
			-- if seat2 then
				-- ISBoatMenu.onEnterAux(playerObj, boat, seat2)
				-- ISTimedActionQueue.add(ISSwitchVehicleSeat:new(playerObj, seat))
			-- end
		-- else
			-- ISBoatMenu.onEnterAux2(playerObj, boat, seat)
		-- end
	-- end
-- end

-- function ISBoatMenu.onEnterAux2(playerObj, boat, seat)
		-- ISTimedActionQueue.add(ISPathFindAction:pathToVehicleSeat(playerObj, boat, seat))
		-- local doorPart = boat:getPassengerDoor2(seat)
		-- if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
			-- local door = doorPart:getDoor()
			-- if door:isLocked() then
				-- -- if the keys on on the car, we take them and open
				-- if boat:isKeyIsOnDoor() then
					-- local key = boat:getCurrentKey()
					-- boat:setKeyIsOnDoor(false);
					-- boat:setCurrentKey(nil)
					-- playerObj:getInventory():AddItem(key)
					-- if isClient() then
						-- sendClientCommand(playerObj, 'vehicle', 'removeKeyFromDoor', { boat = boat:getId() })
					-- end
				-- else
					-- ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, doorPart, seat))
				-- end
			-- end
			-- if not door:isOpen() then
				-- ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, boat, doorPart))
			-- end
			-- ISTimedActionQueue.add(ISEnterVehicle:new(playerObj, boat, seat))
			-- ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, boat, doorPart))
		-- else
			-- ISTimedActionQueue.add(ISEnterVehicle:new(playerObj, boat, seat))
		-- end
-- end


-- function ISBoatMenu.onShowSeatUI(playerObj, boat)
	-- local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	-- if isPaused then return end

	-- local playerNum = playerObj:getPlayerNum()
	-- if not ISBoatMenu.seatUI then
		-- ISBoatMenu.seatUI = {}
	-- end
	-- local ui = ISBoatMenu.seatUI[playerNum]
	-- if not ui or ui.character ~= playerObj then
		-- ui = ISVehicleSeatUI:new(0, 0, playerObj)
		-- ui:initialise()
		-- ui:instantiate()
		-- ISBoatMenu.seatUI[playerNum] = ui
	-- end
	-- if ui:isReallyVisible() then
		-- ui:removeFromUIManager()
		-- if JoypadState.players[playerNum+1] then
			-- setJoypadFocus(playerNum, nil)
		-- end
	-- else
		-- ui:setVehicle(boat)
		-- ui:addToUIManager()
		-- if JoypadState.players[playerNum+1] then
			-- JoypadState.players[playerNum+1].focus = ui
		-- end
	-- end
-- end

-- function ISBoatMenu.onWalkPath(playerObj)
	-- ISTimedActionQueue.add(ISPathFindAction:new(playerObj))
-- end

-- function ISBoatMenu.onKeyPressed(key)
	-- local playerObj = getSpecificPlayer(0)
	-- if not playerObj then return end
	-- if playerObj:isDead() then return end
	-- local boat = playerObj:getVehicle()
	-- if not boat then
		-- boat = ISBoatMenu.getVehicleToInteractWith(playerObj)
		-- if boat then
			-- if key == getCore():getKey("VehicleMechanics") then
				-- ISBoatMenu.onMechanic(playerObj, boat)
				-- return
			-- end
		-- end
		-- return
	-- end
	-- if key == getCore():getKey("StartVehicleEngine") then
		-- if boat:isEngineRunning() then
			-- ISBoatMenu.onShutOff(playerObj)
		-- else
			-- ISBoatMenu.onStartEngine(playerObj)
		-- end
	-- elseif key == getCore():getKey("VehicleHeater") then
		-- ISBoatMenu.onToggleHeater(playerObj)
	-- elseif key == getCore():getKey("VehicleMechanics") then
		-- ISBoatMenu.onMechanic(playerObj, boat)
	-- elseif key == getCore():getKey("VehicleHorn") then
		-- if boat:isDriver(playerObj) then
			-- ISBoatMenu.onHornStop(playerObj)
		-- end
	-- end
	-- -- Could be same as VehicleHorn key
	-- if key == getCore():getKey("Shout") then
		-- if not boat:isDriver(playerObj) then
			-- playerObj:Callout()
		-- end
	-- end
-- end



function ISBoatMenu.onHorn(playerObj)
	ISTimedActionQueue.add(ISHorn:new(playerObj))
end

function ISBoatMenu.onHornStart(playerObj)
--	print "onHornStart"
	local boat = playerObj:getVehicle()
	if boat:getBatteryCharge() <= 0.0 then return end
	if isClient() then
		sendClientCommand(playerObj, 'vehicle', 'onHorn', {state="start"})
	else
		boat:onHornStart();
	end
end

function ISBoatMenu.onHornStop(playerObj)
--	print "onHornStop"
	local boat = playerObj:getVehicle()
	if isClient() then
		sendClientCommand(playerObj, 'vehicle', 'onHorn', {state="stop"})
	else
		boat:onHornStop();
	end
end

-- function ISBoatMenu.onLightbar(playerObj)
	-- ISTimedActionQueue.add(ISLightbarUITimedAction:new(playerObj))
-- end

-- function ISBoatMenu.onAttachTrailer(playerObj, boat, attachmentA, attachmentB)
	-- local square = boat:getCurrentSquare()
	-- local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(square, boat, attachmentA, attachmentB)
	-- if not vehicleB then return end
	-- local nextAction = ISAttachTrailerToVehicle:new(playerObj, boat, vehicleB, attachmentA, attachmentB)
	-- if not ISVehicleTrailerUtils.walkToTrailer(playerObj, boat, attachmentA, nextAction) then return end
-- end

-- function ISBoatMenu.onDetachTrailer(playerObj, boat, attachmentA)
	-- local nextAction = ISDetachTrailerFromVehicle:new(playerObj, boat, attachmentA)
	-- if not ISVehicleTrailerUtils.walkToTrailer(playerObj, boat, attachmentA, nextAction) then return end
-- end

-- Events.OnFillWorldObjectContextMenu.Add(ISBoatMenu.OnFillWorldObjectContextMenu)
-- Events.OnKeyPressed.Add(ISBoatMenu.onKeyPressed);
Events.OnKeyStartPressed.Add(ISBoatMenu.onKeyStartPressed);

