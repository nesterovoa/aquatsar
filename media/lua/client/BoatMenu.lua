require 'Boats/Init'

function AquatsarYachts.getBoat(player)
	local square = player:getSquare()
	if square == nil then return nil end
	--print(square)
	for y=square:getY() - 6, square:getY() + 6 do
		for x=square:getX() - 6, square:getX() + 6 do
			local square2 = getCell():getGridSquare(x, y, 0)
			if square2 then
				-- print(square2:getX())
				-- print(square2:getY())
				-- print(square2:getZ())
				for i=1, square2:getMovingObjects():size() do
					local obj = square2:getMovingObjects():get(i-1)
					if obj~= nil and instanceof(obj, "BaseVehicle") then
						-- print(obj:getScript():getName())
						if string.match(string.lower(obj:getScript():getName()), "boat") then
							print("BOAT FOUND")
							return obj
						end
					end
				end
			end
		end
	end
	return nil
end

function AquatsarYachts.enterBoat(key)
	local playerObj = getPlayer(0)
	if playerObj == nil then return end
	if key == Keyboard.KEY_E then
		-- for i,v in ipairs(MainOptions.keys) do
			-- print(v.value)
		-- end
		
	
		print("BOAT-E")
		local vehicle = playerObj:getVehicle()
		if vehicle == nil then
			vehicle = AquatsarYachts.getBoat(playerObj)
			if vehicle ~= nil then
				print(vehicle:getScript():getName())
				--ISVehicleMenu.onEnterAux(playerObj, vehicle, 0) 
				-- TODO автоматически садиться на свободное сиденье.
				vehicle:getAttachmentWorldPos("exitLeft", AquatsarYachts.exitLeftVector)
				vehicle:getAttachmentWorldPos("exitRight", AquatsarYachts.exitRightVector)
				vehicle:getAttachmentWorldPos("exitRear", AquatsarYachts.exitRearVector)
				print(AquatsarYachts.exitLeftVector:x())
				print(AquatsarYachts.exitLeftVector:y())
				print(AquatsarYachts.exitLeftVector:z())
				--ISTimedActionQueue.add(ISPathFindAction:pathToLocationF(playerObj, AquatsarYachts.exitLeftVector:x(), AquatsarYachts.exitLeftVector:y(), 0))
				ISTimedActionQueue.add(ISEnterVehicle:new(playerObj, vehicle, 0))
				
			end
		elseif string.match(string.lower(vehicle:getScript():getName()), "boat") then
			vehicle:getAttachmentWorldPos("exitLeft", AquatsarYachts.exitLeftVector)
			vehicle:getAttachmentWorldPos("exitRight", AquatsarYachts.exitRightVector)
			vehicle:getAttachmentWorldPos("exitRear", AquatsarYachts.exitRearVector)
			--ISVehicleMenu.onExitAux(playerObj, 0)
			ISTimedActionQueue.add(ISExitBoat:new(playerObj))
		end
				
	end
end


Events.OnKeyStartPressed.Add(AquatsarYachts.enterBoat)